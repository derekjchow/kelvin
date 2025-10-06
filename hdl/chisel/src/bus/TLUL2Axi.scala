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
class TLUL2Axi[A_USER <: Data, D_USER <: Data](p: Parameters, userAGen: () => A_USER, userDGen: () => D_USER) extends Module {
  val tlul_p = new TLULParameters(p)
  val io = IO(new Bundle {
    val tl_a = Flipped(Decoupled(new TileLink_A_ChannelBase(tlul_p, userAGen))) // TileLink Input
    val tl_d = Decoupled(new TileLink_D_ChannelBase(tlul_p, userDGen))          // TileLink Output
    val axi = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })
  // --- Queue for incoming TileLink A-Channel requests ---
  val tl_a_q = Queue(io.tl_a, 2)

  val is_get = tl_a_q.bits.opcode === TLULOpcodesA.Get.asUInt
  val is_put = tl_a_q.bits.opcode === TLULOpcodesA.PutFullData.asUInt ||
               tl_a_q.bits.opcode === TLULOpcodesA.PutPartialData.asUInt

  // --- AXI Channel Generation ---
  // TODO: Consider gating these signals (on get/put)? Especially address.
  // Drive AXI write channels for Put requests
  val aw_q = Module(new Queue(new AxiAddress(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits), 1))
  aw_q.io.enq.valid := tl_a_q.valid && is_put
  aw_q.io.enq.bits.addr := tl_a_q.bits.address
  aw_q.io.enq.bits.id := tl_a_q.bits.source
  aw_q.io.enq.bits.len := 0.U
  aw_q.io.enq.bits.size := tl_a_q.bits.size
  aw_q.io.enq.bits.burst := AxiBurstType.INCR.asUInt
  aw_q.io.enq.bits.prot := 0.U
  aw_q.io.enq.bits.lock := 0.U
  aw_q.io.enq.bits.cache := 0.U
  aw_q.io.enq.bits.qos := 0.U
  aw_q.io.enq.bits.region := 0.U

  val w_q = Module(new Queue(new AxiWriteData(p.axi2DataBits, p.axi2IdBits), 1))
  w_q.io.enq.valid := tl_a_q.valid && is_put
  w_q.io.enq.bits.data := tl_a_q.bits.data
  w_q.io.enq.bits.strb := tl_a_q.bits.mask
  w_q.io.enq.bits.last := true.B

  io.axi.write.addr <> aw_q.io.deq
  io.axi.write.data <> w_q.io.deq

  // Drive AXI read channel for Get requests
  io.axi.read.addr.valid := tl_a_q.valid && is_get
  io.axi.read.addr.bits.addr := tl_a_q.bits.address
  io.axi.read.addr.bits.id   := tl_a_q.bits.source
  io.axi.read.addr.bits.len  := 0.U // No bursting
  io.axi.read.addr.bits.size := tl_a_q.bits.size
  io.axi.read.addr.bits.burst := AxiBurstType.INCR.asUInt // Doesn't matter
  io.axi.read.addr.bits.prot := 0.U // Default protection

  // Dequeue from TileLink queue when AXI transaction is accepted
  tl_a_q.ready := (is_get && io.axi.read.addr.ready) || (is_put && aw_q.io.enq.ready && w_q.io.enq.ready)

  io.axi.write.addr.bits.lock := 0.U
  io.axi.write.addr.bits.cache := 0.U
  io.axi.write.addr.bits.qos := 0.U
  io.axi.write.addr.bits.region := 0.U
  io.axi.read.addr.bits.lock := 0.U
  io.axi.read.addr.bits.cache := 0.U
  io.axi.read.addr.bits.qos := 0.U
  io.axi.read.addr.bits.region := 0.U

  // --- Response Path ---
  class TxInfo extends Bundle {
    val source = UInt(tlul_p.o.W)
    val size = UInt(tlul_p.z.W)
  }

  val read_tx_info_q = Module(new Queue(new TxInfo, entries = 2))
  val write_tx_info_q = Module(new Queue(new TxInfo, entries = 2))

  read_tx_info_q.io.enq.valid := tl_a_q.valid && is_get && io.axi.read.addr.ready
  read_tx_info_q.io.enq.bits.source := tl_a_q.bits.source
  read_tx_info_q.io.enq.bits.size := tl_a_q.bits.size

  write_tx_info_q.io.enq.valid := tl_a_q.valid && is_put && aw_q.io.enq.ready && w_q.io.enq.ready
  write_tx_info_q.io.enq.bits.source := tl_a_q.bits.source
  write_tx_info_q.io.enq.bits.size := tl_a_q.bits.size

  // --- TileLink D-Channel (Response) Generation ---
  val read_response = Wire(Decoupled(new TileLink_D_ChannelBase(tlul_p, userDGen)))
  val write_response = Wire(Decoupled(new TileLink_D_ChannelBase(tlul_p, userDGen)))

  // AXI Read Response -> TileLink AccessAckData
  read_response.valid := io.axi.read.data.valid && read_tx_info_q.io.deq.valid
  read_response.bits.opcode := TLULOpcodesD.AccessAckData.asUInt
  read_response.bits.param := 0.U
  read_response.bits.size := read_tx_info_q.io.deq.bits.size
  read_response.bits.source := read_tx_info_q.io.deq.bits.source
  read_response.bits.sink := 0.U
  read_response.bits.data := io.axi.read.data.bits.data
  read_response.bits.error := io.axi.read.data.bits.resp =/= 0.U
  read_response.bits.user := 0.U.asTypeOf(read_response.bits.user)

  // AXI Write Response -> TileLink AccessAck
  write_response.valid := io.axi.write.resp.valid && write_tx_info_q.io.deq.valid
  write_response.bits.opcode := TLULOpcodesD.AccessAck.asUInt
  write_response.bits.param := 0.U
  write_response.bits.size := write_tx_info_q.io.deq.bits.size
  write_response.bits.source := write_tx_info_q.io.deq.bits.source
  write_response.bits.sink := 0.U
  write_response.bits.data := 0.U
  write_response.bits.error := io.axi.write.resp.bits.resp =/= 0.U
  write_response.bits.user := 0.U.asTypeOf(write_response.bits.user)

  // Arbitrate between read and write responses for the D-channel
  val d_channel_arb = Module(new CoralNPURRArbiter(new TileLink_D_ChannelBase(tlul_p, userDGen), 2))
  d_channel_arb.io.in(0) <> read_response
  d_channel_arb.io.in(1) <> write_response
  io.tl_d <> Queue(d_channel_arb.io.out, 2)

  // Drive ready signals
  io.axi.read.data.ready := d_channel_arb.io.in(0).ready
  read_tx_info_q.io.deq.ready := d_channel_arb.io.in(0).ready && io.axi.read.data.valid

  io.axi.write.resp.ready := d_channel_arb.io.in(1).ready
  write_tx_info_q.io.deq.ready := d_channel_arb.io.in(1).ready && io.axi.write.resp.valid

}

@nowarn
object EmitTLUL2Axi extends App {
  val p = Parameters()
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new TLUL2Axi(p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}