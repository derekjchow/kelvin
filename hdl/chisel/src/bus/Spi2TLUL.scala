// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package bus

import chisel3._
import chisel3.util._
import freechips.rocketchip.util._

import kelvin.Parameters

class Spi2TLUL(p: Parameters) extends Module {
    val tlul_p = new TLULParameters(p)
    val io = IO(new Bundle {
        val spi = new Bundle {
            val clk = Input(Clock())
            val csb = Input(Bool())
            val mosi = Input(Bool())
            val miso = Output(Bool())
        }
        val tl = new OpenTitanTileLink.Host2Device(new TLULParameters(p))
    })


    // Synchronize the main asynchronous reset to the SPI clock domain.
    val spi_domain_reset = withClock(io.spi.clk) {
        val rst_sync = RegNext(RegNext(reset.asBool, true.B), true.B)
        rst_sync.asAsyncReset
    }

    // Combine the main reset with the chip-select reset.
    // Reset is active when csb is high (inactive) OR when the main reset is active.
    val combined_reset = io.spi.csb || spi_domain_reset.asBool

    val (mosi_data_reg, miso_data_reg, miso_valid_reg, bit_count_reg, deq_attempted_reg) =
        withClockAndReset(io.spi.clk, combined_reset.asAsyncReset) {
            val mosi = RegInit(0.U(8.W))
            val miso = RegInit(0.U(8.W))
            // Gate MISO output until the first SPI clock cycle to prevent X propagation.
            val miso_valid = RegInit(false.B)
            val bit_count = RegInit(0.U(3.W))
            val deq_attempted = RegInit(false.B)
            (mosi, miso, miso_valid, bit_count, deq_attempted)
        }
    miso_valid_reg := miso_valid_reg || !io.spi.csb
    io.spi.miso := Mux(miso_valid_reg, miso_data_reg(7), 0.U)

    val spi2tlul_q = Module(new AsyncQueue(UInt(8.W), AsyncQueueParams(depth = 2, safe = false)))
    spi2tlul_q.io.enq_clock := io.spi.clk
    spi2tlul_q.io.enq_reset := reset.asBool
    spi2tlul_q.io.deq_clock := clock
    spi2tlul_q.io.deq_reset := reset.asBool

    val completed_byte = Cat(mosi_data_reg(6,0), io.spi.mosi)
    spi2tlul_q.io.enq.valid := bit_count_reg === 7.U
    spi2tlul_q.io.enq.bits  := completed_byte
    dontTouch(spi2tlul_q.io.enq)

    object SpiState extends ChiselEnum {
        val sIDLE, sWAIT_WRITE_DATA, sSEND_READ_DATA = Value
    }
    val spi_state_reg = RegInit(SpiState.sIDLE)

    // Define the SPI register map
    object SpiRegAddress extends ChiselEnum {
        val TL_ADDR_REG_0 = 0x00.U
        val TL_ADDR_REG_1 = 0x01.U
        val TL_ADDR_REG_2 = 0x02.U
        val TL_ADDR_REG_3 = 0x03.U
        val TL_LEN_REG    = 0x04.U
        val TL_CMD_REG    = 0x05.U
        val TL_STATUS_REG = 0x06.U
        val DATA_BUF_PORT = 0x07.U
        val TL_WRITE_STATUS_REG = 0x08.U
    }

    // Physical registers backing the map
    val tl_addr_reg = RegInit(VecInit(Seq.fill(4)(0.U(8.W))))
    val tl_len_reg = RegInit(0.U(8.W))
    // Command and Status registers are handled by the TL FSM, not stored directly here.
    val data_buffer = RegInit(VecInit(Seq.fill(16)(0.U(128.W))))
    val bulk_read_ptr = RegInit(0.U(8.W)) // Byte pointer into the data buffer
    val bulk_write_ptr = RegInit(0.U(8.W)) // Byte pointer for writes

    val addr_reg = RegInit(0.U(7.W))

    // === TileLink Read FSM ===
    object TlReadState extends ChiselEnum {
        val sIdle, sSendBeat, sWaitBeatAck, sDone, sError = Value
    }
    val tl_read_state_reg = RegInit(TlReadState.sIdle)

    // Internal registers for the TL transaction
    val tl_addr_fsm_reg = RegInit(0.U(32.W))
    val tl_len_fsm_reg = RegInit(0.U(8.W))
    val tl_beat_count_reg = RegInit(0.U(8.W))

    // === TileLink Write FSM ===
    object TlWriteState extends ChiselEnum {
        val sIdle, sSendBeat, sWaitBeatAck, sDone, sError = Value
    }
    val tl_write_state_reg = RegInit(TlWriteState.sIdle)

    // Internal registers for the TL write transaction
    val tl_write_addr_fsm_reg = RegInit(0.U(32.W))
    val tl_write_len_fsm_reg = RegInit(0.U(8.W))
    val tl_write_beat_count_reg = RegInit(0.U(8.W))

    // Wire to detect a write to the command register
    val do_write = spi_state_reg === SpiState.sWAIT_WRITE_DATA && spi2tlul_q.io.deq.fire
    val tl_cmd_reg_write = do_write && (addr_reg === SpiRegAddress.TL_CMD_REG.asUInt)
    val tl_cmd_reg_data  = spi2tlul_q.io.deq.bits

    val tlul2spi_q = Module(new AsyncQueue(UInt(8.W), AsyncQueueParams.singleton(safe = false)))
    tlul2spi_q.io.enq_clock := clock
    tlul2spi_q.io.enq_reset := reset.asBool
    tlul2spi_q.io.deq_clock := io.spi.clk
    tlul2spi_q.io.deq_reset := reset.asBool

    // Add queues for TileLink channels to handle backpressure
    val tl_a_q = Module(new Queue(new OpenTitanTileLink.A_Channel(tlul_p), 1))
    val tl_d_q = Module(new Queue(new OpenTitanTileLink.D_Channel(tlul_p), 1))
    io.tl.a <> tl_a_q.io.deq
    io.tl.a.bits := RequestIntegrityGen(tlul_p, tl_a_q.io.deq.bits)
    tl_d_q.io.enq <> io.tl.d
    tlul2spi_q.io.deq.ready := !io.spi.csb && !deq_attempted_reg

    // FSM logic
    val deq_ready = spi_state_reg === SpiState.sIDLE ||
                    spi_state_reg === SpiState.sWAIT_WRITE_DATA
    spi2tlul_q.io.deq.ready := deq_ready
    tlul2spi_q.io.enq.valid := (spi_state_reg === SpiState.sSEND_READ_DATA)

    val is_write = spi2tlul_q.io.deq.bits(7)
    val state_next = MuxCase(spi_state_reg, Seq(
      (spi_state_reg === SpiState.sIDLE && spi2tlul_q.io.deq.fire) ->
        Mux(is_write, SpiState.sWAIT_WRITE_DATA, SpiState.sSEND_READ_DATA),
      (spi_state_reg === SpiState.sWAIT_WRITE_DATA && spi2tlul_q.io.deq.fire) ->
        SpiState.sIDLE,
      (spi_state_reg === SpiState.sSEND_READ_DATA && tlul2spi_q.io.enq.fire) ->
        SpiState.sIDLE
    ))
    spi_state_reg := state_next

    // sIDLE
    val addr_reg_next = spi2tlul_q.io.deq.bits(6,0)
    addr_reg := Mux(spi_state_reg === SpiState.sIDLE && spi2tlul_q.io.deq.fire,
                    addr_reg_next,
                    addr_reg)

    // sWAIT_WRITE_DATA
    val data = spi2tlul_q.io.deq.bits
    val writing_addr_reg = spi_state_reg === SpiState.sWAIT_WRITE_DATA && spi2tlul_q.io.deq.fire
    for (i <- 0 until 4) {
      tl_addr_reg(i) := Mux(writing_addr_reg && (addr_reg === (SpiRegAddress.TL_ADDR_REG_0 + i.U)), data, tl_addr_reg(i))
    }

    val writing_len_reg = do_write && addr_reg === SpiRegAddress.TL_LEN_REG.asUInt
    tl_len_reg := Mux(writing_len_reg, data, tl_len_reg)

    val write_word_index = bulk_write_ptr(7,4)
    val write_byte_index = bulk_write_ptr(3,0)
    val write_shift = write_byte_index << 3
    val write_mask = ~(0xFF.U << write_shift)
    val write_old_word = data_buffer(write_word_index)
    val write_new_word = (write_old_word & write_mask) | (data << write_shift)
    val write_cmd_fire = tl_cmd_reg_write && tl_cmd_reg_data === 2.U
    val writing_data_buf = do_write && addr_reg === SpiRegAddress.DATA_BUF_PORT.asUInt
    bulk_write_ptr := Mux(write_cmd_fire, 0.U,
                      Mux(writing_data_buf, bulk_write_ptr + 1.U, bulk_write_ptr))

    // sSEND_READ_DATA
    val word_index = bulk_read_ptr(7,4)
    val byte_index = bulk_read_ptr(3,0)
    val selected_word = data_buffer(word_index)

    val status_map = Seq(
        TlReadState.sIdle.asUInt -> 0x00.U,
        TlReadState.sSendBeat.asUInt -> 0x01.U,
        TlReadState.sWaitBeatAck.asUInt -> 0x01.U,
        TlReadState.sDone.asUInt -> 0x02.U,
        TlReadState.sError.asUInt -> 0xFF.U
    )

    val write_status_map = Seq(
        TlWriteState.sIdle.asUInt -> 0x00.U,
        TlWriteState.sSendBeat.asUInt -> 0x01.U,
        TlWriteState.sWaitBeatAck.asUInt -> 0x01.U,
        TlWriteState.sDone.asUInt -> 0x02.U,
        TlWriteState.sError.asUInt -> 0xFF.U
    )

    val read_map = Seq(
        SpiRegAddress.TL_ADDR_REG_0.asUInt -> tl_addr_reg(0),
        SpiRegAddress.TL_ADDR_REG_1.asUInt -> tl_addr_reg(1),
        SpiRegAddress.TL_ADDR_REG_2.asUInt -> tl_addr_reg(2),
        SpiRegAddress.TL_ADDR_REG_3.asUInt -> tl_addr_reg(3),
        SpiRegAddress.TL_LEN_REG.asUInt    -> tl_len_reg,
        SpiRegAddress.TL_STATUS_REG.asUInt -> MuxLookup(tl_read_state_reg.asUInt, 0.U)(status_map),
        SpiRegAddress.TL_WRITE_STATUS_REG.asUInt ->
            MuxLookup(tl_write_state_reg.asUInt, 0.U)(write_status_map),
        SpiRegAddress.DATA_BUF_PORT.asUInt -> (selected_word.asUInt >> (byte_index << 3.U))(7,0),
    )
    tlul2spi_q.io.enq.bits := MuxLookup(addr_reg, 0.U(8.W))(read_map)

    val read_cmd_fire = tl_cmd_reg_write && tl_cmd_reg_data === 1.U
    val reading_data_buf = spi_state_reg === SpiState.sSEND_READ_DATA &&
                           tlul2spi_q.io.enq.fire &&
                           addr_reg === SpiRegAddress.DATA_BUF_PORT.asUInt
    bulk_read_ptr := Mux(read_cmd_fire, 0.U,
                     Mux(reading_data_buf, bulk_read_ptr + 1.U, bulk_read_ptr))

    withClock(io.spi.clk) {
        mosi_data_reg := Cat(mosi_data_reg(6,0), io.spi.mosi)
        bit_count_reg := bit_count_reg + 1.U

        deq_attempted_reg := Mux(bit_count_reg === 0.U, true.B, deq_attempted_reg)

        miso_data_reg := MuxCase(miso_data_reg, Seq(
            (bit_count_reg === 0.U && tlul2spi_q.io.deq.fire) -> tlul2spi_q.io.deq.bits,
            (bit_count_reg =/= 0.U)                           -> Cat(miso_data_reg(6,0), 0.U(1.W)),
        ))
    }

    // === TileLink FSM Logic ===
    val read_fsm_active = tl_read_state_reg =/= TlReadState.sIdle
    val write_fsm_active = tl_write_state_reg =/= TlWriteState.sIdle

    tl_a_q.io.enq.valid := MuxCase(false.B, Seq(
      read_fsm_active  -> (tl_read_state_reg === TlReadState.sSendBeat),
      write_fsm_active -> (tl_write_state_reg === TlWriteState.sSendBeat)
    ))

    tl_d_q.io.deq.ready := MuxCase(false.B, Seq(
      read_fsm_active  -> (tl_read_state_reg === TlReadState.sWaitBeatAck),
      write_fsm_active -> (tl_write_state_reg === TlWriteState.sWaitBeatAck)
    ))

    val a_bits = Wire(new OpenTitanTileLink.A_Channel(tlul_p))
    a_bits.param    := 0.U
    a_bits.size     := log2Ceil(tlul_p.w).U
    a_bits.source   := 0.U
    a_bits.mask     := Fill(tlul_p.w, 1.U)
    a_bits.user     := 0.U.asTypeOf(a_bits.user)
    a_bits.user.instr_type := 9.U // MuBi4False

    a_bits.opcode   := Mux(write_fsm_active, TLULOpcodesA.PutFullData.asUInt, TLULOpcodesA.Get.asUInt)
    a_bits.address  := Mux(write_fsm_active,
                           tl_write_addr_fsm_reg + (tl_write_beat_count_reg << log2Ceil(tlul_p.w)),
                           tl_addr_fsm_reg + (tl_beat_count_reg << log2Ceil(tlul_p.w)))
    a_bits.data     := Mux(write_fsm_active, data_buffer(tl_write_beat_count_reg(3,0)), 0.U)

    tl_a_q.io.enq.bits := a_bits

    val reading_tl = tl_read_state_reg === TlReadState.sWaitBeatAck &&
                     tl_d_q.io.deq.fire &&
                     !tl_d_q.io.deq.bits.error
    for (i <- 0 until data_buffer.length) {
        val write_to_buffer = i.U === write_word_index && writing_data_buf
        val read_from_buffer = i.U === tl_beat_count_reg(3,0) && reading_tl
        data_buffer(i) := MuxCase(data_buffer(i), Seq(
            write_to_buffer -> write_new_word,
            read_from_buffer -> tl_d_q.io.deq.bits.data,
        ))
    }

    val clear_command = tl_cmd_reg_write && tl_cmd_reg_data === 0.U

    // === TileLink Read FSM Logic ===
    val tl_state_next = MuxCase(tl_read_state_reg, Seq(
      (tl_read_state_reg === TlReadState.sIdle && read_cmd_fire) -> TlReadState.sSendBeat,
      (tl_read_state_reg === TlReadState.sSendBeat && tl_a_q.io.enq.fire) ->
        TlReadState.sWaitBeatAck,
      (tl_read_state_reg === TlReadState.sWaitBeatAck && tl_d_q.io.deq.fire) ->
        MuxCase(TlReadState.sSendBeat, Seq(
            tl_d_q.io.deq.bits.error -> TlReadState.sError,
            (tl_beat_count_reg === tl_len_fsm_reg) -> TlReadState.sDone
        )),
      (tl_read_state_reg === TlReadState.sDone && clear_command) -> TlReadState.sIdle,
      (tl_read_state_reg === TlReadState.sError && clear_command) -> TlReadState.sIdle
    ))
    tl_read_state_reg := tl_state_next

    val tl_beat_count_next = Mux(tl_read_state_reg === TlReadState.sWaitBeatAck &&
                                 tl_d_q.io.deq.fire &&
                                 !tl_d_q.io.deq.bits.error,
                                 tl_beat_count_reg + 1.U,
                                 tl_beat_count_reg)
    tl_beat_count_reg := Mux(read_cmd_fire, 0.U, tl_beat_count_next)

    tl_addr_fsm_reg := Mux(read_cmd_fire, tl_addr_reg.asUInt, tl_addr_fsm_reg)
    tl_len_fsm_reg := Mux(read_cmd_fire, tl_len_reg, tl_len_fsm_reg)

    // === TileLink Write FSM Logic ===
    val tl_write_state_next = MuxCase(tl_write_state_reg, Seq(
      (tl_write_state_reg === TlWriteState.sIdle && write_cmd_fire) -> TlWriteState.sSendBeat,
      (tl_write_state_reg === TlWriteState.sSendBeat && tl_a_q.io.enq.fire) ->
        TlWriteState.sWaitBeatAck,
      (tl_write_state_reg === TlWriteState.sWaitBeatAck && tl_d_q.io.deq.fire) ->
        MuxCase(TlWriteState.sSendBeat, Seq(
            tl_d_q.io.deq.bits.error -> TlWriteState.sError,
            (tl_write_beat_count_reg === tl_write_len_fsm_reg) -> TlWriteState.sDone
        )),
      (tl_write_state_reg === TlWriteState.sDone && clear_command) -> TlWriteState.sIdle,
      (tl_write_state_reg === TlWriteState.sError && clear_command) -> TlWriteState.sIdle
    ))
    tl_write_state_reg := tl_write_state_next

    val tl_write_beat_count_next = Mux(tl_write_state_reg === TlWriteState.sWaitBeatAck &&
                                       tl_d_q.io.deq.fire &&
                                       !tl_d_q.io.deq.bits.error,
                                       tl_write_beat_count_reg + 1.U,
                                       tl_write_beat_count_reg)
    tl_write_beat_count_reg := Mux(write_cmd_fire, 0.U, tl_write_beat_count_next)

    tl_write_addr_fsm_reg := Mux(write_cmd_fire, tl_addr_reg.asUInt, tl_write_addr_fsm_reg)
    tl_write_len_fsm_reg := Mux(write_cmd_fire, tl_len_reg, tl_write_len_fsm_reg)
}

import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

@nowarn
object Spi2TLUL_128_Emitter extends App {
    var p = Parameters()
    p.lsuDataBits = 128
    (new ChiselStage).execute(
      Array("--target", "systemverilog") ++ args,
      Seq(ChiselGeneratorAnnotation(() => new Spi2TLUL(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
    )
}
