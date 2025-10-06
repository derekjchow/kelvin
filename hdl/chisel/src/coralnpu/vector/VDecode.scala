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

package coralnpu

import chisel3._
import chisel3.util._
import common.FifoIxO
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

object VDecode {
  def apply(p: Parameters): VDecode = {
    return Module(new VDecode(p))
  }
}

class VDecode(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Decoupled(Vec(p.instructionLanes, Valid(new VectorInstructionLane))))
    val out = Vec(p.instructionLanes, Decoupled(new VDecodeBits))
    val cmdq = Vec(p.instructionLanes, Output(new VDecodeCmdq))
    val actv = Vec(p.instructionLanes, Output(new VDecodeActive))  // used in testbench
    val stall = Output(Bool())
    val active = Input(UInt(64.W))
    val vrfsb = new VRegfileScoreboardIO
    val undef = Output(Bool())
    val nempty = Output(Bool())
  })

  val guard = 8  // two cycles of 4-way dispatch
  val depth = 16 + guard

  val enc = new VEncodeOp()

  val f = FifoIxO(new VectorInstructionLane, p.instructionLanes, p.instructionLanes, depth)

  val d = Seq.fill(p.instructionLanes)(Module(new VDecodeInstruction(p)))

  val e = Wire(Vec(p.instructionLanes, new VDecodeBits))

  val valid = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val data = Reg(Vec(p.instructionLanes, new VDecodeBits))
  val cmdq = Reg(Vec(p.instructionLanes, new VDecodeCmdq))
  val actv = Wire(Vec(p.instructionLanes, new VDecodeActive))
  val actv2 = Reg(Vec(p.instructionLanes, new VDecodeActive2))
  val dataNxt = Wire(Vec(p.instructionLanes, new VDecodeBits))
  val cmdqNxt = Wire(Vec(p.instructionLanes, new VDecodeCmdq))
  val actvNxt = Wire(Vec(p.instructionLanes, new VDecodeActive2))

  // ---------------------------------------------------------------------------
  // Decode.
  for (i <- 0 until p.instructionLanes) {
    d(i).io.in := f.io.out(i).bits
  }

  // ---------------------------------------------------------------------------
  // Apply "out-of-order" tags to read/write registers.
  // Since only one write may be outstanding, track using 1bit which side of
  // write the read usage is occurring on.
  val tagReg = RegInit(0.U(64.W))

  val tags = (0 until p.instructionLanes).map(x => d(x).io.actv.wactive).scan(tagReg)(_ ^ _)
  assert(tags.length == p.instructionLanes + 1)

  // f.io.out is ordered, so can use a priority tree.
  tagReg := MuxCase(tags(0), (0 until p.instructionLanes).reverse.map(x => (f.io.out(x).valid && f.io.out(x).ready) -> tags(x + 1)))

  def TagAddr(tag: UInt, v: VAddrTag): VAddrTag = {
    assert(tag.getWidth == 64)
    assert(v.addr.getWidth == 6)
    assert(v.tag === 0.U)
    val addr = v.addr
    val addrm = addr(5,2)
    val tagm = Wire(Vec(16, UInt(4.W)))
    for (i <- 0 until 16) {
      tagm(i) := tag(4 * i + 3, 4 * i)
    }
    val r = Wire(new VAddrTag())
    r.valid := v.valid
    r.addr := v.addr
    r.tag := VecAt(tagm, addrm)
    r
  }

  for (i <- 0 until p.instructionLanes) {
    e(i) := d(i).io.out
    e(i).vs := TagAddr(tags(i), d(i).io.out.vs)
    e(i).vt := TagAddr(tags(i), d(i).io.out.vt)
    e(i).vu := TagAddr(tags(i), d(i).io.out.vu)
    e(i).vx := TagAddr(tags(i), d(i).io.out.vx)
    e(i).vy := TagAddr(tags(i), d(i).io.out.vy)
    e(i).vz := TagAddr(tags(i), d(i).io.out.vz)
  }

  // ---------------------------------------------------------------------------
  // Undef.  (io.in.ready ignored to signal as early as possible)
  io.undef := io.in.valid && d.map(x => x.io.undef).reduce(_ || _)

  // ---------------------------------------------------------------------------
  // Fifo.
  f.io.in <> io.in

  val icount = MuxOR(io.in.valid,
    PopCount(io.in.bits.map(_.valid))
  )

  val ocount = PopCount((0 until p.instructionLanes).map(x => valid(x) && !(io.out(x).valid && io.out(x).ready)))

  for (i <- 0 until p.instructionLanes) {
    f.io.out(i).ready := (i.U + ocount) < p.instructionLanes.U
  }

  // ---------------------------------------------------------------------------
  // Valid.
  val fcount = PopCount(f.io.out.map(x => x.valid && x.ready))

  for (i <- 0 until p.instructionLanes) {
    valid(i) := (ocount + fcount) > i.U
  }

  // ---------------------------------------------------------------------------
  // Stall.
  io.stall := (f.io.count + icount) > (depth - guard).U

  // ---------------------------------------------------------------------------
  // Writes must not proceed past any outstanding reads or writes,
  // or past any dispatching writes.
  val wactive = VecInit((0 until p.instructionLanes).map(x => actv(x).ractive | actv(x).wactive).scan(io.vrfsb.data(63,0) | io.vrfsb.data(127,64) | io.active)(_ | _))

  // Reads must not proceed past any dispatching writes.
  val ractive = VecInit((0 until p.instructionLanes).map(x => actv(x).wactive).scan(0.U(64.W))(_ | _))

  // Dependencies.
  val depends = VecInit((0 until p.instructionLanes).map(i =>
    (wactive(i) & actv(i).wactive) =/= 0.U ||
    (ractive(i) & actv(i).ractive) =/= 0.U
  ))

  // ---------------------------------------------------------------------------
  // Data.
  val fvalid = VecInit(f.io.out.map(_.valid)).asUInt
  for (i <- 0 until p.instructionLanes) {
    assert(!(fvalid(i) && PopCount(fvalid(i,0)) =/= (i + 1).U))
  }

  // Register is updated when fifo has state or contents are active.
  val dataEn = fvalid(0) || valid.asUInt =/= 0.U

  for (i <- 0 until p.instructionLanes) {
    when (dataEn) {
      data(i) := dataNxt(i)
      cmdq(i) := cmdqNxt(i)
      actv2(i) := actvNxt(i)
    }
  }

  for (i <- 0 until p.instructionLanes) {
    actv(i).ractive := actv2(i).ractive
    actv(i).wactive := actv2(i).wactive(63, 0) | actv2(i).wactive(127, 64)
  }

  // Tag the decode wactive.
  val dactv = Wire(Vec(p.instructionLanes, new VDecodeActive2))
  for (i <- 0 until p.instructionLanes) {
    val w0 = d(i).io.actv.wactive & ~tags(i + 1)
    val w1 = d(i).io.actv.wactive &  tags(i + 1)
    dactv(i).ractive := d(i).io.actv.ractive
    dactv(i).wactive := Cat(w1, w0)
  }

  // Data multiplexor of current values and fifo+decode output.
  val dataMux = VecInit(data ++ e)
  val cmdqMux = VecInit(cmdq ++ d.map(x => x.io.cmdq))
  val actvMux = VecInit(actv2 ++ dactv)

  def GenerateMarked(start: Int, count: Int): Seq[UInt] = {
    (0 until count).map(x => Wire(UInt((start + x).W)))
  }
  // Mark the multiplexor entries that need to be kept.
  val marked = GenerateMarked((p.instructionLanes + 1), p.instructionLanes - 1)
  val output = Cat((0 until p.instructionLanes).reverse.map(x => io.out(x).valid && io.out(x).ready))
  val validNotOutput = (0 until (p.instructionLanes * 2) - 1).map(x =>
    if (x < valid.length) { valid(x) && !output(x) } else { true.B })
  val prevMarked = (0 until p.instructionLanes).map(x =>
    if (x == 0) { None } else { Some(marked(x - 1)) }
  )

  for (i <- 0 until p.instructionLanes) {
    val idx = MuxCase((i + p.instructionLanes).U, (i until p.instructionLanes + i).map(x =>
      (!prevMarked(i).getOrElse(false.B)(x) && validNotOutput(x)) -> (x).U
    ))
    dataNxt(i) := dataMux(idx)
    cmdqNxt(i) := cmdqMux(idx)
    actvNxt(i) := actvMux(idx)
    if (i < marked.length) {
      val width = marked(i).getWidth
      marked(i) := ~0.U(width.W) >> ((width - 1).U - idx)
    }
  }

  // ---------------------------------------------------------------------------
  // Scoreboard.
  // io.vrfsb.set.valid := output(0) || output(1) || output(2) || output(3)
  io.vrfsb.set.valid := output =/= 0.U

  io.vrfsb.set.bits := (0 until p.instructionLanes).map(x => MuxOR(output(x), actv2(x).wactive)).reduce(_ | _)

  assert((io.vrfsb.set.bits(63, 0) & io.vrfsb.set.bits(127, 64)) === 0.U)
  assert(((io.vrfsb.data(63, 0) | io.vrfsb.data(127, 64)) & (io.vrfsb.set.bits(63, 0) | io.vrfsb.set.bits(127, 64))) === 0.U)

  // ---------------------------------------------------------------------------
  // Outputs.
  val outvalid = VecInit((0 until p.instructionLanes).map(i => valid(i) && !depends(i)))
  val cmdsync = VecInit((0 until p.instructionLanes).map(i => data(i).cmdsync))

  for (i <- 0 until p.instructionLanes) {
    // Synchronize commands at cmdsync instance or if found in history.
    // Note: {vdwinit, vdwconv, vdmulh}, vdmulh must not issue before vdwconv.
    val synchronize = cmdsync.asUInt(i,0) =/= 0.U
    val ordered = (~outvalid.asUInt(i,0)) === 0.U
    val unorder = outvalid(i)
    if (false) {
      io.out(i).valid := Mux(synchronize, ordered, unorder)
    } else {
      io.out(i).valid := ordered
    }
    io.out(i).bits := data(i)
    io.cmdq(i) := cmdq(i)
    io.actv(i) := actv(i)
  }

  // ---------------------------------------------------------------------------
  // Status.
  val nempty = RegInit(false.B)

  // Simple implementation, will overlap downstream units redundantly.
  nempty := io.in.valid || f.io.nempty || valid.asUInt =/= 0.U

  io.nempty := nempty
}

class VDecodeBits extends Bundle {
  val op = UInt(new VEncodeOp().bits.W)
  val f2 = UInt(3.W)  // func2
  val sz = UInt(3.W)  // onehot size
  val m  = Bool()     // stripmine

  val vd = new VAddr()
  val ve = new VAddr()
  val vf = new VAddr()
  val vg = new VAddr()
  val vs = new VAddrTag()
  val vt = new VAddrTag()
  val vu = new VAddrTag()
  val vx = new VAddrTag()
  val vy = new VAddrTag()
  val vz = new VAddrTag()
  val sv = new SAddrData()

  val cmdsync = Bool()  // Dual command queues synchronize.
}

class VDecodeCmdq extends Bundle {
  val alu   = Bool()  // ALU
  val conv  = Bool()  // Convolution vregfile
  val ldst  = Bool()  // L1Dcache load/store
  val ld    = Bool()  // Uncached load
  val st    = Bool()  // Uncached store
}

class VDecodeActive extends Bundle {
  val ractive = UInt(64.W)
  val wactive = UInt(64.W)
}

class VDecodeActive2 extends Bundle {
  val ractive = UInt(64.W)
  val wactive = UInt(128.W)  // even/odd tags
}

class VAddr extends Bundle {
  val valid = Bool()
  val addr = UInt(6.W)
}

class VAddrTag extends Bundle {
  val valid = Bool()
  val addr = UInt(6.W)
  val tag = UInt(4.W)
}

class SAddrData extends Bundle {
  val valid = Bool()
  val addr = UInt(32.W)
  val data = UInt(32.W)
}

class SData extends Bundle {
  val valid = Bool()
  val data = UInt(32.W)
}

@nowarn
object EmitVDecode extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VDecode(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
