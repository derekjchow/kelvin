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

import bus.AxiMasterWriteIO
import common._
import _root_.circt.stage.ChiselStage

object VSt {
  def apply(p: Parameters): VSt = {
    return Module(new VSt(p))
  }
}

class VSt(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Instructions.
    val in = Flipped(Decoupled(Vec(p.instructionLanes, Valid(new VDecodeBits))))
    val active = Output(UInt(64.W))

    // VRegfile.
    val vrfsb = Input(UInt(128.W))
    val read  = new VRegfileReadHsIO(p)

    // Bus.
    val axi = new AxiMasterWriteIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    // Status.
    val nempty = Output(Bool())

    val vstoreCount = Output(UInt(1.W))
  })

  // A usable depth of outstanding commands.
  val cmdqDepth = 8

  val maxvlb  = (p.vectorBits / 8).U(p.vectorCountBits.W)
  val maxvlbm = (p.vectorBits * 4 / 8).U(p.vectorCountBits.W)

  val bytes = p.lsuDataBits / 8
  val msb = log2Ceil(bytes)

  val e = new VEncodeOp()

  // ---------------------------------------------------------------------------
  // Tie-offs
  io.active := 0.U

  io.in.ready := false.B

  io.read.valid := false.B
  io.read.stall := false.B
  io.read.addr := 0.U
  io.read.tag := 0.U

  io.axi.addr.valid := false.B
  io.axi.addr.bits.addr := 0.U
  io.axi.addr.bits.id := 0.U

  io.axi.data.valid := false.B
  io.axi.data.bits.strb := 0.U
  io.axi.data.bits.data := 0.U

  io.axi.resp.ready := false.B

  // ---------------------------------------------------------------------------
  // Command Queue.
  class VStCmdq extends Bundle {
    val op = UInt(new VEncodeOp().bits.W)
    val f2 = UInt(3.W)
    val sz = UInt(3.W)
    val addr = UInt(32.W)
    val offset = UInt(32.W)
    val remain = UInt(p.vectorCountBits.W)
    val vs = new VAddrTag()
    val quad = UInt(2.W)  // vstq position
    val last = Bool()
  }

  def Fin(in: VDecodeBits): VStCmdq = {
    val out = Wire(new VStCmdq)
    val stride = in.f2(1)
    val length = in.f2(0)
    assert(PopCount(in.sz) <= 1.U)
    assert(!(in.op === e.vst.U  && !in.vs.valid))
    assert(!(in.op === e.vstq.U && !in.vs.valid))

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
    out.offset := Mux(stride, data(31,0), Mux(in.op === e.vstq.U, maxvlb >> 2, maxvlb))
    out.remain := Mux(length, remain1, remain0)
    out.vs := in.vs
    out.last := !in.m && in.op =/= e.vstq.U

    out.quad := 0.U

    out
  }

  def Fout(in: VStCmdq, m: Bool, step: UInt, valid: Bool): (VStCmdq, Bool) = {
    val addrAlign = Mux(in.op === e.vstq.U, in.addr(msb - 3, 0), in.addr(msb - 1, 0))
    val offsAlign = Mux(in.op === e.vstq.U, in.offset(msb - 3, 0), in.offset(msb - 1, 0))
    assert(addrAlign === 0.U)
    assert(offsAlign === 0.U)
    assert(!valid || in.op === e.vst.U || in.op === e.vstq.U)

    val out = Wire(new VStCmdq)
    val vstq = in.op === e.vstq.U
    val stride = in.f2(1)

    val fmaxvlb = Mux(in.op === e.vstq.U, maxvlb >> 2, maxvlb)

    val outlast1 = !m || step === 2.U  // registered a cycle before 'last' usage
    val outlast2 = Mux(m, step === 14.U, step === 2.U)
    val outlast = Mux(vstq, outlast2, outlast1)

    val last1 = !m || step === 3.U
    val last2 = Mux(m, step === 15.U, step === 3.U)
    val last = Mux(vstq, last2, last1)

    out := in

    out.vs.addr := Mux(vstq && step(1,0) =/= 3.U, in.vs.addr, in.vs.addr + 1.U)

    out.addr   := in.addr + in.offset
    out.remain := Mux(in.remain <= fmaxvlb, 0.U, in.remain - fmaxvlb)

    out.last := outlast

    out.quad := Mux(in.op === e.vstq.U, step + 1.U, 0.U)

    (out, last)
  }

  def Factive(in: VStCmdq, m: Bool, step: UInt): UInt = {
    assert(step.getWidth == 5)
    val vstq = in.op === e.vstq.U
    val stepq = Mux(vstq, step(4,2), step(2,0))
    val active = MuxOR(in.vs.valid, RegActive(m, stepq, in.vs.addr))
    assert(active.getWidth == 64)
    active
  }

  class Ctrl extends Bundle {
    val addr = UInt(p.lsuAddrBits.W)
    val id   = UInt(6.W)
    val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
    val vstq = Bool()
    val quad = UInt(2.W)
  }

  class Data extends Bundle {
    val data = UInt(p.lsuDataBits.W)
    val strb = UInt((p.lsuDataBits / 8).W)
  }

  val q = VCmdq(p, cmdqDepth, new VStCmdq, Fin, Fout, Factive)

  val ctrl = Slice(new Ctrl, false, true)
  val data = Slice(new Data, false, true, true)

  val dataEn = RegInit(false.B)

  // ---------------------------------------------------------------------------
  // Swizzle.
  def SwizzleData(): UInt = {
    val dsb = p.vectorBits / 4

    val addr = ctrl.io.out.bits.addr
    val vstq = ctrl.io.out.bits.vstq
    val quad = ctrl.io.out.bits.quad
    val data = io.read.data

    val d0 = data(1 * dsb - 1, 0 * dsb)
    val d1 = data(2 * dsb - 1, 1 * dsb)
    val d2 = data(3 * dsb - 1, 2 * dsb)
    val d3 = data(4 * dsb - 1, 3 * dsb)

    val dataout = MuxOR(!vstq, data) |
                  MuxOR(vstq && quad === 0.U, Cat(d0, d0, d0, d0)) |
                  MuxOR(vstq && quad === 1.U, Cat(d1, d1, d1, d1)) |
                  MuxOR(vstq && quad === 2.U, Cat(d2, d2, d2, d2)) |
                  MuxOR(vstq && quad === 3.U, Cat(d3, d3, d3, d3))
    assert(dataout.getWidth == p.vectorBits)

    dataout
  }

  def SwizzleStrb(): UInt = {
    val n4 = bytes / 4
    val n = bytes

    val strbB = Wire(Vec(n, Bool()))
    val strb = strbB.asUInt
    val strbq = strb(n4 - 1, 0)
    val addr = ctrl.io.out.bits.addr
    val size = ctrl.io.out.bits.size
    val vstq = ctrl.io.out.bits.vstq
    val quad = addr(msb - 1, msb - 2)
    val zeroq = Cat(0.U(n4.W))

    for (i <- 0 until p.lsuDataBits / 8) {
      strbB(i) := size > i.U
    }

    val strbout = MuxOR(!vstq, strb) |
       MuxOR(vstq && quad === 0.U, Cat(zeroq, zeroq, zeroq, strbq)) |
       MuxOR(vstq && quad === 1.U, Cat(zeroq, zeroq, strbq, zeroq)) |
       MuxOR(vstq && quad === 2.U, Cat(zeroq, strbq, zeroq, zeroq)) |
       MuxOR(vstq && quad === 3.U, Cat(strbq, zeroq, zeroq, zeroq))
    assert(strbout.getWidth == p.vectorBits / 8)

    strbout
  }

  // ---------------------------------------------------------------------------
  // Instruction queue.
  q.io.in <> io.in

  val ctrlready = Wire(Bool())
  q.io.out.ready := ScoreboardReady(q.io.out.bits.vs, io.vrfsb) && ctrlready

  val qmaxvlb = Mux(q.io.out.bits.op === e.vstq.U, maxvlb >> 2.U, maxvlb)
  val qsize = Mux(q.io.out.bits.remain > qmaxvlb, qmaxvlb, q.io.out.bits.remain)

  val qoutEn = q.io.out.valid && q.io.out.ready

  // ---------------------------------------------------------------------------
  // Register read.
  io.read.valid := q.io.out.valid && q.io.out.bits.vs.valid
  io.read.stall := !q.io.out.ready
  io.read.addr := q.io.out.bits.vs.addr
  io.read.tag := OutTag(q.io.out.bits.vs)

  dataEn := qoutEn

  data.io.in.valid := dataEn
  assert(!(data.io.in.valid && !data.io.in.ready))

  data.io.out.ready := io.axi.addr.ready

  data.io.in.bits.data := SwizzleData()
  data.io.in.bits.strb := SwizzleStrb()

  // ---------------------------------------------------------------------------
  // Control.
  ctrl.io.in.valid := qoutEn

  ctrl.io.in.bits.addr := q.io.out.bits.addr
  ctrl.io.in.bits.id   := q.io.out.bits.vs.addr
  ctrl.io.in.bits.size := qsize
  ctrl.io.in.bits.vstq := q.io.out.bits.op === e.vstq.U
  ctrl.io.in.bits.quad := q.io.out.bits.quad

  ctrl.io.out.ready := io.axi.addr.ready

  ctrlready := io.read.ready && ctrl.io.in.ready && data.io.in.ready

  // ---------------------------------------------------------------------------
  // Axi.
  io.axi.addr.valid := ctrl.io.out.valid
  io.axi.addr.bits.addr := Cat(0.U(1.W), ctrl.io.out.bits.addr(30, msb), 0.U(msb.W))
  io.axi.addr.bits.id := ctrl.io.out.bits.id
  assert(!(ctrl.io.out.valid && !ctrl.io.out.bits.addr(31)))
  assert(!(io.axi.addr.valid && io.axi.addr.bits.addr(31)))

  io.axi.data.valid := ctrl.io.out.valid
  io.axi.data.bits.data := data.io.out.bits.data
  io.axi.data.bits.strb := data.io.out.bits.strb

  io.axi.resp.ready := true.B

  assert(io.axi.addr.valid === io.axi.data.valid)
  assert(io.axi.addr.ready === io.axi.data.ready)

  io.vstoreCount := ctrl.io.out.valid

  // ---------------------------------------------------------------------------
  // Active.
  io.active := q.io.active

  // ---------------------------------------------------------------------------
  // Memory active status.
  val nempty = RegInit(false.B)
  val count = RegInit(0.U(9.W))
  val inc = io.axi.addr.valid && io.axi.addr.ready
  val dec = io.axi.resp.valid && io.axi.resp.ready

  when (inc || dec) {
    val nxtcount = count + inc - dec
    count := nxtcount
    nempty := nxtcount =/= 0.U
    assert(count <= 256.U)
  }

  io.nempty := q.io.nempty || ctrl.io.out.valid || nempty
}

object EmitVSt extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new VSt(p), args)
}
