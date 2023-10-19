/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package kelvin

import chisel3._
import chisel3.util._
import common._

object VLd {
  def apply(p: Parameters): VLd = {
    return Module(new VLd(p))
  }
}

class VLd(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Instructions.
    val in = Flipped(Decoupled(Vec(4, Valid(new VDecodeBits))))

    // VRegfile.
    val write = new VRegfileWriteIO(p)

    // Bus.
    val axi = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    // Status.
    val nempty = Output(Bool())
  })

  // Loads do not zero out-of-size lanes, all ALU lanes will be populated.
  // Memory may be initially zeroed so that one half of operation is zero.
  // Writes are masked so there is no harm to non-zero entries.

  // A usable depth of outstanding commands.
  val cmdqDepth = 8

  val maxvlb  = (p.vectorBits / 8).U(p.vectorCountBits.W)
  val maxvlbm = (p.vectorBits * 4 / 8).U(p.vectorCountBits.W)

  val bytes = p.lsuDataBits / 8

  val e = new VEncodeOp()

  // ---------------------------------------------------------------------------
  // Command Queue.
  class VLdCmdq extends Bundle {
    val op = UInt(new VEncodeOp().bits.W)
    val f2 = UInt(3.W)
    val sz = UInt(3.W)
    val addr = UInt(32.W)
    val offset = UInt(32.W)
    val remain = UInt(p.vectorCountBits.W)
    val vd = new VAddr()
    val last = Bool()
  }

  def Fin(in: VDecodeBits): VLdCmdq = {
    val out = Wire(new VLdCmdq)
    val stride = in.f2(1)
    val length = in.f2(0)
    assert(PopCount(in.sz) <= 1.U)
    assert(!(in.op === e.vld.U  && (!in.vd.valid ||  in.vs.valid)))

    val limit = Mux(in.m, maxvlbm, maxvlb)

    val data = MuxOR(in.sz(0), in.sv.data) |
               MuxOR(in.sz(1), Cat(in.sv.data, 0.U(1.W))) |
               MuxOR(in.sz(2), Cat(in.sv.data, 0.U(2.W)))

    val remain0 = maxvlbm
    val remain1 = Mux(data > limit, limit, data)(p.vectorCountBits - 1, 0)
    assert(remain0.getWidth == p.vectorCountBits)
    assert(remain1.getWidth == p.vectorCountBits)

    out.op := in.op
    out.f2 := in.f2
    out.sz := in.sz
    out.addr := in.sv.addr
    out.offset := Mux(stride, data(31,0), maxvlb)
    out.remain := Mux(length, remain1, remain0)
    out.vd := in.vd
    out.last := !in.m

    out
  }

  def Fout(in: VLdCmdq, m: Bool, step: UInt, valid: Bool): (VLdCmdq, Bool) = {
    val msb = log2Ceil(bytes) - 1
    val addrAlign = in.addr(msb, 0)
    val offsAlign = in.offset(msb, 0)
    assert(addrAlign === 0.U)
    assert(offsAlign === 0.U)
    assert(!valid || in.op === e.vld.U)

    val out = Wire(new VLdCmdq)
    val stride = in.f2(1)

    val outlast = !m || step === 2.U  // registered a cycle before 'last' usage

    val last = !m || step === 3.U

    out := in

    out.vd.addr := in.vd.addr + 1.U

    out.addr   := in.addr + in.offset
    out.remain := Mux(in.remain <= maxvlb, 0.U, in.remain - maxvlb)

    out.last := outlast

    (out, last)
  }

  def Factive(in: VLdCmdq, m: Bool, step: UInt): UInt = {
    assert(step.getWidth == 5)
    0.U
  }

  val q = VCmdq(cmdqDepth, new VLdCmdq, Fin, Fout, Factive)

  q.io.in <> io.in

  // ---------------------------------------------------------------------------
  // Axi.
  io.axi.addr.valid := q.io.out.valid
  io.axi.addr.bits.addr := Cat(0.U(1.W), q.io.out.bits.addr(30,0))
  io.axi.addr.bits.id := q.io.out.bits.vd.addr
  assert(!(q.io.out.valid && !q.io.out.bits.addr(31)))
  assert(!(io.axi.addr.valid && io.axi.addr.bits.addr(31)))

  q.io.out.ready := io.axi.addr.ready

  // ---------------------------------------------------------------------------
  // Write interface.
  io.write.valid := io.axi.data.valid
  io.write.data := io.axi.data.bits.data
  io.write.addr := io.axi.data.bits.id

  io.axi.data.ready := true.B

  // ---------------------------------------------------------------------------
  // Memory active status.
  val nempty = RegInit(false.B)
  val count = RegInit(0.U(7.W))
  val inc = io.axi.addr.valid && io.axi.addr.ready
  val dec = io.axi.data.valid && io.axi.data.ready

  when (inc || dec) {
    val nxtcount = count + inc - dec
    count := nxtcount
    nempty := nxtcount =/= 0.U
    assert(count <= 64.U)
  }

  io.nempty := q.io.nempty || nempty
}

object EmitVLd extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new VLd(p), args)
}
