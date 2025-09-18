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
import coralnpu.Parameters
import common.CoralNPURRArbiter
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

/**
  * TLUL2Axi: A Chisel module that serves as a bridge between a TileLink-UL master
  * and an AXI4 slave.
  *
  * This module translates TileLink Get and Put operations into AXI read and write
  * transactions, respectively. It uses a dataflow approach with queues and an
  * arbiter to manage the protocol conversion.
  *
  * @param p The CoralNPU parameters.
  */
class TLUL2Axi[A_USER <: Data, D_USER <: Data](p_tl: Parameters, p_axi: Parameters, userAGen: () => A_USER, userDGen: () => D_USER) extends Module {
  val tlul_p = new TLULParameters(p_tl)
  val io = IO(new Bundle {
    val tl_a = Flipped(Decoupled(new TileLink_A_ChannelBase(tlul_p, userAGen))) // TileLink Input
    val tl_d = Decoupled(new TileLink_D_ChannelBase(tlul_p, userDGen))          // TileLink Output
    val axi = new AxiMasterIO(p_axi.axi2AddrBits, p_axi.axi2DataBits, p_axi.axi2IdBits)
  })

  // --- AXI ID Mapper and Transaction Limiter ---
  val axiIdWidth = p_axi.axi2IdBits
  val idWidthMismatch = tlul_p.o > axiIdWidth

  val p_tl_remapped_params = new Parameters(p_tl.m, p_tl.hartId)
  p_tl_remapped_params.lsuDataBits = p_tl.lsuDataBits
  p_tl_remapped_params.axi2IdBits = axiIdWidth
  val p_tl_remapped = new TLULParameters(p_tl_remapped_params)

  val tl_a_q = Module(new Queue(chiselTypeOf(io.tl_a.bits), 2))
  tl_a_q.io.enq <> io.tl_a

  val tl_a_q_remapped = Wire(Decoupled(new TileLink_A_ChannelBase(p_tl_remapped, userAGen)))

  val d_channel_arb = Module(new CoralNPURRArbiter(new TileLink_D_ChannelBase(p_tl_remapped, userDGen), 2))

  var id_remapper: TlulIdRemapper[A_USER, D_USER] = null
  if (idWidthMismatch) {
    id_remapper = Module(new TlulIdRemapper(tlul_p, p_tl_remapped, userAGen, userDGen))
    id_remapper.io.tl_a_in <> tl_a_q.io.deq
    tl_a_q_remapped <> id_remapper.io.tl_a_out
    id_remapper.io.tl_d_in <> d_channel_arb.io.out
    io.tl_d <> id_remapper.io.tl_d_out
  } else {
    tl_a_q_remapped <> tl_a_q.io.deq
    io.tl_d <> Queue(d_channel_arb.io.out, 2)
  }

  class TxInfo extends Bundle {
    val size = UInt(p_tl_remapped.z.W)
  }
  val read_tx_info_q = Module(new Queue(new TxInfo, entries = 2))
  val write_tx_info_q = Module(new Queue(new TxInfo, entries = 2))

  // --- Queue for incoming TileLink A-Channel requests ---
  val is_get = tl_a_q_remapped.bits.opcode === TLULOpcodesA.Get.asUInt
  val is_put = tl_a_q_remapped.bits.opcode === TLULOpcodesA.PutFullData.asUInt ||
               tl_a_q_remapped.bits.opcode === TLULOpcodesA.PutPartialData.asUInt

  // --- AXI Channel Generation ---
  // TODO: Consider gating these signals (on get/put)? Especially address.
  // Drive AXI write channels for Put requests
  val aw_q = Module(new Queue(new AxiAddress(p_axi.axi2AddrBits, p_axi.axi2DataBits, p_axi.axi2IdBits), 1))
  aw_q.io.enq.valid := tl_a_q_remapped.valid && is_put
  aw_q.io.enq.bits.addr := tl_a_q_remapped.bits.address
  aw_q.io.enq.bits.id := tl_a_q_remapped.bits.source
  aw_q.io.enq.bits.len := 0.U
  aw_q.io.enq.bits.size := tl_a_q_remapped.bits.size
  aw_q.io.enq.bits.burst := AxiBurstType.INCR.asUInt
  aw_q.io.enq.bits.prot := 0.U
  aw_q.io.enq.bits.lock := 0.U
  aw_q.io.enq.bits.cache := 0.U
  aw_q.io.enq.bits.qos := 0.U
  aw_q.io.enq.bits.region := 0.U

  val w_q = Module(new Queue(new AxiWriteData(p_axi.axi2DataBits, p_axi.axi2IdBits), 1))
  w_q.io.enq.valid := tl_a_q_remapped.valid && is_put
  w_q.io.enq.bits.data := tl_a_q_remapped.bits.data
  w_q.io.enq.bits.strb := tl_a_q_remapped.bits.mask
  w_q.io.enq.bits.last := true.B

  io.axi.write.addr <> aw_q.io.deq
  io.axi.write.data <> w_q.io.deq

  // Drive AXI read channel for Get requests
  io.axi.read.addr.valid := tl_a_q_remapped.valid && is_get && read_tx_info_q.io.enq.ready
  io.axi.read.addr.bits.addr := tl_a_q_remapped.bits.address
  io.axi.read.addr.bits.id   := tl_a_q_remapped.bits.source
  io.axi.read.addr.bits.len  := 0.U // No bursting
  io.axi.read.addr.bits.size := tl_a_q_remapped.bits.size
  io.axi.read.addr.bits.burst := AxiBurstType.INCR.asUInt // Doesn't matter
  io.axi.read.addr.bits.prot := 0.U // Default protection

  // Dequeue from TileLink queue when AXI transaction is accepted
  val get_ready = io.axi.read.addr.ready && read_tx_info_q.io.enq.ready
  val put_ready = aw_q.io.enq.ready && w_q.io.enq.ready && write_tx_info_q.io.enq.ready
  tl_a_q_remapped.ready := (is_get && get_ready) || (is_put && put_ready)

  io.axi.write.addr.bits.lock := 0.U
  io.axi.write.addr.bits.cache := 0.U
  io.axi.write.addr.bits.qos := 0.U
  io.axi.write.addr.bits.region := 0.U
  io.axi.read.addr.bits.lock := 0.U
  io.axi.read.addr.bits.cache := 0.U
  io.axi.read.addr.bits.qos := 0.U
  io.axi.read.addr.bits.region := 0.U

  // --- Response Path ---

  read_tx_info_q.io.enq.valid := tl_a_q_remapped.valid && is_get && io.axi.read.addr.ready
  read_tx_info_q.io.enq.bits.size := Mux((p_axi.axi2DataBits == 256).B, 5.U, tl_a_q_remapped.bits.size)

  write_tx_info_q.io.enq.valid := tl_a_q_remapped.valid && is_put && aw_q.io.enq.ready && w_q.io.enq.ready
  write_tx_info_q.io.enq.bits.size := Mux((p_axi.axi2DataBits == 256).B, 5.U, tl_a_q_remapped.bits.size)

  // --- TileLink D-Channel (Response) Generation ---
  val read_response = Wire(Decoupled(new TileLink_D_ChannelBase(p_tl_remapped, userDGen)))
  val write_response = Wire(Decoupled(new TileLink_D_ChannelBase(p_tl_remapped, userDGen)))

  // AXI Read Response -> TileLink AccessAckData
  val read_response_intg = Module(new ResponseIntegrityGen(p_tl_remapped))
  val read_resp_raw = Wire(new TileLink_D_ChannelBase(p_tl_remapped, userDGen))
  read_resp_raw.opcode := TLULOpcodesD.AccessAckData.asUInt
  read_resp_raw.param := 0.U
  read_resp_raw.size := read_tx_info_q.io.deq.bits.size
  read_resp_raw.source := io.axi.read.data.bits.id.asUInt
  read_resp_raw.sink := 0.U
  read_resp_raw.data := io.axi.read.data.bits.data
  read_resp_raw.error := io.axi.read.data.bits.resp =/= 0.U
  read_resp_raw.user := 0.U.asTypeOf(read_response.bits.user)

  read_response_intg.io.d_i := read_resp_raw
  read_response.bits := read_response_intg.io.d_o
  read_response.valid := io.axi.read.data.valid && read_tx_info_q.io.deq.valid

  // AXI Write Response -> TileLink AccessAck
  val write_response_intg = Module(new ResponseIntegrityGen(p_tl_remapped))
  val write_resp_raw = Wire(new TileLink_D_ChannelBase(p_tl_remapped, userDGen))
  write_resp_raw.opcode := TLULOpcodesD.AccessAck.asUInt
  write_resp_raw.param := 0.U
  write_resp_raw.size := write_tx_info_q.io.deq.bits.size
  write_resp_raw.source := io.axi.write.resp.bits.id.asUInt
  write_resp_raw.sink := 0.U
  write_resp_raw.data := 0.U
  write_resp_raw.error := io.axi.write.resp.bits.resp =/= 0.U
  write_resp_raw.user := 0.U.asTypeOf(write_response.bits.user)

  write_response_intg.io.d_i := write_resp_raw
  write_response.bits := write_response_intg.io.d_o
  write_response.valid := io.axi.write.resp.valid && write_tx_info_q.io.deq.valid

  d_channel_arb.io.in(0) <> read_response
  d_channel_arb.io.in(1) <> write_response

  // Drive ready signals
  io.axi.read.data.ready := d_channel_arb.io.in(0).ready
  read_tx_info_q.io.deq.ready := io.axi.read.data.valid && d_channel_arb.io.in(0).ready

  io.axi.write.resp.ready := d_channel_arb.io.in(1).ready
  write_tx_info_q.io.deq.ready := d_channel_arb.io.in(1).ready && io.axi.write.resp.valid

}

@nowarn
object EmitTLUL2Axi extends App {
  val p_tl = Parameters()
  val p_axi = Parameters()
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new TLUL2Axi(p_tl, p_axi, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}