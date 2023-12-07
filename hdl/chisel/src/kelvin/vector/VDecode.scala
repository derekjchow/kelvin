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
import common.Fifo4x4
import _root_.circt.stage.ChiselStage

object VDecode {
  def apply(p: Parameters): VDecode = {
    return Module(new VDecode(p))
  }
}

class VDecode(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Decoupled(Vec(4, Valid(new VectorInstructionLane))))
    val out = Vec(4, Decoupled(new VDecodeBits))
    val cmdq = Vec(4, Output(new VDecodeCmdq))
    val actv = Vec(4, Output(new VDecodeActive))  // used in testbench
    val stall = Output(Bool())
    val active = Input(UInt(64.W))
    val vrfsb = new VRegfileScoreboardIO
    val undef = Output(Bool())
    val nempty = Output(Bool())
  })

  val guard = 8  // two cycles of 4-way dispatch
  val depth = 16 + guard

  val enc = new VEncodeOp()

  val f = Fifo4x4(new VectorInstructionLane, depth)

  val d = Seq(Module(new VDecodeInstruction(p)),
              Module(new VDecodeInstruction(p)),
              Module(new VDecodeInstruction(p)),
              Module(new VDecodeInstruction(p)))

  val e = Wire(Vec(4, new VDecodeBits))

  val valid = RegInit(VecInit(Seq.fill(4)(false.B)))
  val data = Reg(Vec(4, new VDecodeBits))
  val cmdq = Reg(Vec(4, new VDecodeCmdq))
  val actv = Wire(Vec(4, new VDecodeActive))
  val actv2 = Reg(Vec(4, new VDecodeActive2))
  val dataNxt = Wire(Vec(4, new VDecodeBits))
  val cmdqNxt = Wire(Vec(4, new VDecodeCmdq))
  val actvNxt = Wire(Vec(4, new VDecodeActive2))

  // ---------------------------------------------------------------------------
  // Decode.
  for (i <- 0 until 4) {
    d(i).io.in := f.io.out(i).bits
  }

  // ---------------------------------------------------------------------------
  // Apply "out-of-order" tags to read/write registers.
  // Since only one write may be outstanding, track using 1bit which side of
  // write the read usage is occurring on.
  val tagReg = RegInit(0.U(64.W))

  val tag0 = tagReg
  val tag1 = tag0 ^ d(0).io.actv.wactive
  val tag2 = tag1 ^ d(1).io.actv.wactive
  val tag3 = tag2 ^ d(2).io.actv.wactive
  val tag4 = tag3 ^ d(3).io.actv.wactive

  val tags = Seq(tag0, tag1, tag2, tag3, tag4)

  // f.io.out is ordered, so can use a priority tree.
  when(f.io.out(3).valid && f.io.out(3).ready) {
    tagReg := tag4
  } .elsewhen(f.io.out(2).valid && f.io.out(2).ready) {
    tagReg := tag3
  } .elsewhen(f.io.out(1).valid && f.io.out(1).ready) {
    tagReg := tag2
  } .elsewhen(f.io.out(0).valid && f.io.out(0).ready) {
    tagReg := tag1
  }

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

  for (i <- 0 until 4) {
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
  io.undef := io.in.valid && (d(0).io.undef || d(1).io.undef || d(2).io.undef || d(3).io.undef)

  // ---------------------------------------------------------------------------
  // Fifo.
  f.io.in <> io.in

  val icount = MuxOR(io.in.valid, PopCount(Cat(io.in.bits(0).valid, io.in.bits(1).valid, io.in.bits(2).valid, io.in.bits(3).valid)))
  assert(icount.getWidth == 3)

  val ocount = PopCount(Cat(valid(0) && !(io.out(0).valid && io.out(0).ready),
                            valid(1) && !(io.out(1).valid && io.out(1).ready),
                            valid(2) && !(io.out(2).valid && io.out(2).ready),
                            valid(3) && !(io.out(3).valid && io.out(3).ready)))
  assert(ocount.getWidth == 3)

  for (i <- 0 until 4) {
    f.io.out(i).ready := (i.U + ocount) < 4.U
  }

  // ---------------------------------------------------------------------------
  // Valid.
  val fcount = PopCount(Cat(f.io.out(0).valid && f.io.out(0).ready,
                            f.io.out(1).valid && f.io.out(1).ready,
                            f.io.out(2).valid && f.io.out(2).ready,
                            f.io.out(3).valid && f.io.out(3).ready))
  assert(fcount.getWidth == 3)

  for (i <- 0 until 4) {
    valid(i) := (ocount + fcount) > i.U
  }

  // ---------------------------------------------------------------------------
  // Stall.
  io.stall := (f.io.count + icount) > (depth - guard).U

  // ---------------------------------------------------------------------------
  // Dependencies.
  val depends = Wire(Vec(4, Bool()))

  // Writes must not proceed past any outstanding reads or writes,
  // or past any dispatching writes.
  val wactive0 = io.vrfsb.data(63, 0) | io.vrfsb.data(127, 64) | io.active
  val wactive1 = actv(0).ractive | actv(0).wactive | wactive0
  val wactive2 = actv(1).ractive | actv(1).wactive | wactive1
  val wactive3 = actv(2).ractive | actv(2).wactive | wactive2
  val wactive = VecInit(wactive0, wactive1, wactive2, wactive3)

  // Reads must not proceed past any dispatching writes.
  val ractive0 = 0.U(64.W)
  val ractive1 = actv(0).wactive | ractive0
  val ractive2 = actv(1).wactive | ractive1
  val ractive3 = actv(2).wactive | ractive2
  val ractive = VecInit(ractive0, ractive1, ractive2, ractive3)

  for (i <- 0 until 4) {
    depends(i) := (wactive(i) & actv(i).wactive) =/= 0.U ||
                  (ractive(i) & actv(i).ractive) =/= 0.U
  }

  // ---------------------------------------------------------------------------
  // Data.
  val fvalid = VecInit(f.io.out(0).valid, f.io.out(1).valid,
                       f.io.out(2).valid, f.io.out(3).valid).asUInt
  assert(!(fvalid(1) && fvalid(0,0) =/= 1.U))
  assert(!(fvalid(2) && fvalid(1,0) =/= 3.U))
  assert(!(fvalid(3) && fvalid(2,0) =/= 7.U))

  // Register is updated when fifo has state or contents are active.
  val dataEn = fvalid(0) || valid.asUInt =/= 0.U

  for (i <- 0 until 4) {
    when (dataEn) {
      data(i) := dataNxt(i)
      cmdq(i) := cmdqNxt(i)
      actv2(i) := actvNxt(i)
    }
  }

  for (i <- 0 until 4) {
    actv(i).ractive := actv2(i).ractive
    actv(i).wactive := actv2(i).wactive(63, 0) | actv2(i).wactive(127, 64)
  }

  // Tag the decode wactive.
  val dactv = Wire(Vec(4, new VDecodeActive2))
  for (i <- 0 until 4) {
    val w0 = d(i).io.actv.wactive & ~tags(i + 1)
    val w1 = d(i).io.actv.wactive &  tags(i + 1)
    dactv(i).ractive := d(i).io.actv.ractive
    dactv(i).wactive := Cat(w1, w0)
  }

  // Data multiplexor of current values and fifo+decode output.
  val dataMux = VecInit(data(0), data(1), data(2), data(3),
                        e(0), e(1), e(2), e(3))

  val cmdqMux = VecInit(cmdq(0), cmdq(1), cmdq(2), cmdq(3),
                        d(0).io.cmdq, d(1).io.cmdq, d(2).io.cmdq, d(3).io.cmdq)

  val actvMux = VecInit(actv2(0), actv2(1), actv2(2), actv2(3),
                        dactv(0), dactv(1), dactv(2), dactv(3))

  // Mark the multiplexor entries that need to be kept.
  val marked0 = Wire(UInt(5.W))
  val marked1 = Wire(UInt(6.W))
  val marked2 = Wire(UInt(7.W))

  assert((marked1 & marked0) === marked0)
  assert((marked2 & marked0) === marked0)
  assert((marked2 & marked1) === marked1)

  val output = Cat(io.out(3).valid && io.out(3).ready,
                   io.out(2).valid && io.out(2).ready,
                   io.out(1).valid && io.out(1).ready,
                   io.out(0).valid && io.out(0).ready)

  when (valid(0) && !output(0)) {
    dataNxt(0) := dataMux(0)
    cmdqNxt(0) := cmdqMux(0)
    actvNxt(0) := actvMux(0)
    marked0 := 0x01.U
  } .elsewhen (valid(1) && !output(1)) {
    dataNxt(0) := dataMux(1)
    cmdqNxt(0) := cmdqMux(1)
    actvNxt(0) := actvMux(1)
    marked0 := 0x03.U
  } .elsewhen (valid(2) && !output(2)) {
    dataNxt(0) := dataMux(2)
    cmdqNxt(0) := cmdqMux(2)
    actvNxt(0) := actvMux(2)
    marked0 := 0x07.U
  } .elsewhen (valid(3) && !output(3)) {
    dataNxt(0) := dataMux(3)
    cmdqNxt(0) := cmdqMux(3)
    actvNxt(0) := actvMux(3)
    marked0 := 0x0f.U
  } .otherwise {
    dataNxt(0) := dataMux(4)
    cmdqNxt(0) := cmdqMux(4)
    actvNxt(0) := actvMux(4)
    marked0 := 0x1f.U
  }

  when (!marked0(1) && valid(1) && !output(1)) {
    dataNxt(1) := dataMux(1)
    cmdqNxt(1) := cmdqMux(1)
    actvNxt(1) := actvMux(1)
    marked1 := 0x03.U
  } .elsewhen (!marked0(2) && valid(2) && !output(2)) {
    dataNxt(1) := dataMux(2)
    cmdqNxt(1) := cmdqMux(2)
    actvNxt(1) := actvMux(2)
    marked1 := 0x07.U
  } .elsewhen (!marked0(3) && valid(3) && !output(3)) {
    dataNxt(1) := dataMux(3)
    cmdqNxt(1) := cmdqMux(3)
    actvNxt(1) := actvMux(3)
    marked1 := 0x0f.U
  } .elsewhen (!marked0(4)) {
    dataNxt(1) := dataMux(4)
    cmdqNxt(1) := cmdqMux(4)
    actvNxt(1) := actvMux(4)
    marked1 := 0x1f.U
  } .otherwise {
    dataNxt(1) := dataMux(5)
    cmdqNxt(1) := cmdqMux(5)
    actvNxt(1) := actvMux(5)
    marked1 := 0x3f.U
  }

  when (!marked1(2) && valid(2) && !output(2)) {
    dataNxt(2) := dataMux(2)
    cmdqNxt(2) := cmdqMux(2)
    actvNxt(2) := actvMux(2)
    marked2 := 0x07.U
  } .elsewhen (!marked1(3) && valid(3) && !output(3)) {
    dataNxt(2) := dataMux(3)
    cmdqNxt(2) := cmdqMux(3)
    actvNxt(2) := actvMux(3)
    marked2 := 0x0f.U
  } .elsewhen (!marked1(4)) {
    dataNxt(2) := dataMux(4)
    cmdqNxt(2) := cmdqMux(4)
    actvNxt(2) := actvMux(4)
    marked2 := 0x1f.U
  } .elsewhen (!marked1(5)) {
    dataNxt(2) := dataMux(5)
    cmdqNxt(2) := cmdqMux(5)
    actvNxt(2) := actvMux(5)
    marked2 := 0x3f.U
  } .otherwise {
    dataNxt(2) := dataMux(6)
    cmdqNxt(2) := cmdqMux(6)
    actvNxt(2) := actvMux(6)
    marked2 := 0x7f.U
  }

  when (!marked2(3) && valid(3) && !output(3)) {
    dataNxt(3) := dataMux(3)
    cmdqNxt(3) := cmdqMux(3)
    actvNxt(3) := actvMux(3)
  } .elsewhen (!marked2(4)) {
    dataNxt(3) := dataMux(4)
    cmdqNxt(3) := cmdqMux(4)
    actvNxt(3) := actvMux(4)
  } .elsewhen (!marked2(5)) {
    dataNxt(3) := dataMux(5)
    cmdqNxt(3) := cmdqMux(5)
    actvNxt(3) := actvMux(5)
  } .elsewhen (!marked2(6)) {
    dataNxt(3) := dataMux(6)
    cmdqNxt(3) := cmdqMux(6)
    actvNxt(3) := actvMux(6)
  } .otherwise {
    dataNxt(3) := dataMux(7)
    cmdqNxt(3) := cmdqMux(7)
    actvNxt(3) := actvMux(7)
  }

  // ---------------------------------------------------------------------------
  // Scoreboard.
  io.vrfsb.set.valid := output(0) || output(1) || output(2) || output(3)

  io.vrfsb.set.bits := (MuxOR(output(0), actv2(0).wactive) |
                        MuxOR(output(1), actv2(1).wactive) |
                        MuxOR(output(2), actv2(2).wactive) |
                        MuxOR(output(3), actv2(3).wactive))

  assert((io.vrfsb.set.bits(63, 0) & io.vrfsb.set.bits(127, 64)) === 0.U)
  assert(((io.vrfsb.data(63, 0) | io.vrfsb.data(127, 64)) & (io.vrfsb.set.bits(63, 0) | io.vrfsb.set.bits(127, 64))) === 0.U)

  // ---------------------------------------------------------------------------
  // Outputs.
  val outvalid = Wire(Vec(4, Bool()))
  val cmdsync = Wire(Vec(4, Bool()))

  for (i <- 0 until 4) {
    outvalid(i) := valid(i) && !depends(i)
    cmdsync(i) := data(i).cmdsync
  }

  for (i <- 0 until 4) {
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

object EmitVDecode extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new VDecode(p), args)
}
