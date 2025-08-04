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

import kelvin.Parameters

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
  * @param p The Kelvin parameters.
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

  // Prioritize reads over writes.
  val is_write = write_addr_q.valid && write_data_q.valid
  val is_read = read_addr_q.valid

  io.tl_a.valid := is_read || is_write
  read_addr_q.ready := false.B
  write_addr_q.ready := false.B
  write_data_q.ready := false.B

  read_addr_q.ready := Mux(is_read, io.tl_a.ready, false.B)
  write_addr_q.ready := !is_read && io.tl_a.ready
  write_data_q.ready := !is_read && io.tl_a.ready

  io.tl_a.bits.opcode := Mux(is_read, TLULOpcodesA.Get.asUInt, TLULOpcodesA.PutFullData.asUInt)
  io.tl_a.bits.param := 0.U
  io.tl_a.bits.address := Mux(is_read, read_addr_q.bits.addr, write_addr_q.bits.addr)
  io.tl_a.bits.source := Mux(is_read, read_addr_q.bits.id, write_addr_q.bits.id)
  io.tl_a.bits.size := Mux(is_read, read_addr_q.bits.size, write_addr_q.bits.size)
  io.tl_a.bits.mask := Mux(is_read, 0.U, write_data_q.bits.strb)
  io.tl_a.bits.data := Mux(is_read, 0.U, write_data_q.bits.data)
  io.tl_a.bits.user      := 0.U.asTypeOf(io.tl_a.bits.user)

  val d_is_write = io.tl_d.bits.opcode === TLULOpcodesD.AccessAck.asUInt
  val d_is_read = io.tl_d.bits.opcode === TLULOpcodesD.AccessAckData.asUInt

  io.axi.write.resp.valid := io.tl_d.valid && d_is_write
  io.axi.write.resp.bits.id := io.tl_d.bits.source
  io.axi.write.resp.bits.resp := 0.U

  io.axi.read.data.valid := io.tl_d.valid && d_is_read
  io.axi.read.data.bits.id := io.tl_d.bits.source
  io.axi.read.data.bits.data := io.tl_d.bits.data
  io.axi.read.data.bits.resp := Mux(io.tl_d.bits.error, "b10".U, "b00".U)
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
