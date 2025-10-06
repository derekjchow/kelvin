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
import common.CoralNPURRArbiter

import coralnpu.Parameters

/**
  * Axi2TLUL: A Chisel module that serves as a bridge between an AXI4 master
  * and a TileLink-UL slave.
  *
  * This module translates AXI read and write transactions into TileLink Get and Put
  * operations, respectively. It uses a dataflow approach with queues to manage
  * the protocol conversion.
  *
  * Note: This implementation handles single-beat AXI transactions (len=0). AXI
  * bursting would require more complex logic to be added.
  *
  * @param p The CoralNPU parameters.
  */
class Axi2TLUL[A_USER <: Data, D_USER <: Data](p: Parameters, userAGen: () => A_USER, userDGen: () => D_USER) extends Module {
  val tlul_p = new TLULParameters(p)
  val io = IO(new Bundle {
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val tl_a = Decoupled(new TileLink_A_ChannelBase(tlul_p, userAGen)) // TileLink Output
    val tl_d = Flipped(Decoupled(new TileLink_D_ChannelBase(tlul_p, userDGen))) // TileLink Input
  })

  assert(io.axi.read.addr.bits.len === 0.U || !io.axi.read.addr.valid, "Axi2TLUL: AXI read bursts not supported")
  assert(io.axi.write.addr.bits.len === 0.U || !io.axi.write.addr.valid, "Axi2TLUL: AXI write bursts not supported")

  val read_addr_q = Queue(io.axi.read.addr, entries = 2)
  val write_addr_q = Queue(io.axi.write.addr, entries = 2)
  val write_data_q = Queue(io.axi.write.data, entries = 2)

  private def axiToTl(addr: AxiAddress, data: Option[AxiWriteData]): TileLink_A_ChannelBase[A_USER] = {
    val tl_a = Wire(new TileLink_A_ChannelBase(tlul_p, userAGen))
    tl_a.opcode  := data.map(_ => TLULOpcodesA.PutFullData.asUInt).getOrElse(TLULOpcodesA.Get.asUInt)
    tl_a.param   := 0.U
    tl_a.address := addr.addr
    tl_a.source  := addr.id
    tl_a.size    := addr.size
    tl_a.mask    := data.map(_.strb).getOrElse(0.U(tlul_p.w.W))
    tl_a.data    := data.map(_.data).getOrElse(0.U((8 * p.axi2DataBits).W))
    tl_a.user    := 0.U.asTypeOf(io.tl_a.bits.user)
    tl_a
  }

  val read_stream = read_addr_q.map(axiToTl(_, None))

  val write_stream = Wire(Decoupled(new TileLink_A_ChannelBase(tlul_p, userAGen)))
  write_stream.valid := write_addr_q.valid && write_data_q.valid
  write_stream.bits  := axiToTl(write_addr_q.bits, Some(write_data_q.bits))

  // Reads are given higher priority.
  val arb = Module(new CoralNPURRArbiter(new TileLink_A_ChannelBase(tlul_p, userAGen), 2))
  arb.io.in(0) <> read_stream
  arb.io.in(1) <> write_stream
  io.tl_a <> arb.io.out

  write_addr_q.ready := write_stream.fire
  write_data_q.ready := write_stream.fire

  val d_is_write = io.tl_d.bits.opcode === TLULOpcodesD.AccessAck.asUInt
  val d_is_read = io.tl_d.bits.opcode === TLULOpcodesD.AccessAckData.asUInt

  io.axi.write.resp.valid := io.tl_d.valid && d_is_write
  io.axi.write.resp.bits.id := io.tl_d.bits.source
  io.axi.write.resp.bits.resp := Mux(io.tl_d.bits.error, AxiResponseType.SLVERR.asUInt, AxiResponseType.OKAY.asUInt)

  io.axi.read.data.valid := io.tl_d.valid && d_is_read
  io.axi.read.data.bits.id := io.tl_d.bits.source
  io.axi.read.data.bits.data := io.tl_d.bits.data
  io.axi.read.data.bits.resp := Mux(io.tl_d.bits.error, AxiResponseType.SLVERR.asUInt, AxiResponseType.OKAY.asUInt)
  io.axi.read.data.bits.last := true.B

  io.tl_d.ready := Mux(d_is_read, io.axi.read.data.ready, io.axi.write.resp.ready)
}

import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

@nowarn
object EmitAxi2TLUL extends App {
  val p = Parameters()
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new Axi2TLUL(p, () => new NoUser, () => new NoUser))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
