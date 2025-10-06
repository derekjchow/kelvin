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
import common._
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

// A queue of commands, reducing VDecodeBits to just the necessary fields.
// <fin> retains just the needed fields or modifications.
// <fout> accepts the current stripmine bank step.
// <factive> returns the activation status for decode dependencies.

object VCmdq {
  def apply[T <: Data](p: Parameters, n: Int, t: T, fin: (VDecodeBits) => T, fout: (T, Bool, UInt, Bool) => (T, Bool), factive: (T, Bool, UInt) => UInt) = {
    Module(new VCmdq(p, n, t, fin, fout, factive))
  }
}

class VCmdq[T <: Data](p: Parameters, n: Int, t: T, fin: (VDecodeBits) => T, fout: (T, Bool, UInt, Bool) => (T, Bool), factive: (T, Bool, UInt) => UInt) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(Vec(p.instructionLanes, Valid(new VDecodeBits))))
    val out = Decoupled(t)
    val active = Output(UInt(64.W))
    val nempty = Output(Bool())
  })

  class VCmdqWrapper extends Bundle {
    val tin = Output(t)     // type input
    val m = Output(Bool())  // stripmine
  }

  val f = FifoXe(new VCmdqWrapper, p.instructionLanes, n)

  val active = RegInit(0.U(64.W))

  val valid = RegInit(false.B)
  val ready = io.out.ready
  val value = Reg(new VCmdqWrapper)

  // ---------------------------------------------------------------------------
  // Step controls.
  val step0 = 0.U(5.W)
  val step = RegInit(step0)

  val (tin, last) = fout(value.tin, value.m, step, valid)

  // ---------------------------------------------------------------------------
  // Fifo.
  f.io.in.valid := io.in.valid
  io.in.ready := f.io.in.ready

  for (i <- 0 until p.instructionLanes) {
    f.io.in.bits(i).valid := io.in.bits(i).valid
    f.io.in.bits(i).bits.tin := fin(io.in.bits(i).bits)
    f.io.in.bits(i).bits.m := io.in.bits(i).bits.m
  }

  f.io.out.ready := !valid || ready && last

  // ---------------------------------------------------------------------------
  // Output register.
  when (f.io.out.valid && f.io.out.ready) {
    valid := true.B
    value := f.io.out.bits
    step := 0.U
  } .elsewhen (io.out.valid && io.out.ready) {
    when (!last) {
      valid := true.B
      value.tin := tin
      value.m := value.m
      step := step + 1.U
    } .otherwise {
      //  Output value.tin == 0 when not active (eg. do not drive vreg reads).
      valid := false.B
      value.tin := 0.U.asTypeOf(t)
      value.m := false.B
      step := 0.U
    }
  }

  when (reset.asBool) {
    value.tin := 0.U.asTypeOf(t)
    value.m := false.B
  }

  // ---------------------------------------------------------------------------
  // Active.
  def ValueActive(data: UInt = 0.U(64.W), i: Int = 0): UInt = {
    assert(data.getWidth == 64)
    if (i < n) {
      val active = MuxOR(f.io.entry(i).valid, factive(f.io.entry(i).bits.tin, f.io.entry(i).bits.m, step0))
      ValueActive(data | active, i + 1)
    } else {
      val m = value.m
      val active0 = factive(value.tin, m, step + 0.U)
      val active1 = factive(value.tin, m, step + 1.U)
      val active = MuxOR(valid && (!ready || !last),
                         Mux(!ready, active0, active1))
      data | active
    }
  }

  when (io.in.valid && io.in.ready || io.out.valid && io.out.ready) {
    val fvalid = MuxOR(f.io.in.valid && f.io.in.ready,
                 Cat((0 until p.instructionLanes).reverse.map(x => f.io.in.bits(x).valid)))

    active := (0 until p.instructionLanes).map(x =>
      MuxOR(fvalid(x), factive(f.io.in.bits(x).bits.tin, f.io.in.bits(x).bits.m, step0))).reduce(_|_) |
      ValueActive()
  }

  // ---------------------------------------------------------------------------
  // Outputs.
  io.out.valid := valid
  io.out.bits := value.tin

  io.active := active

  io.nempty := f.io.nempty || valid
}

class VCmdqTestBundle extends Bundle {
  val op = UInt(new VEncodeOp().bits.W)
  val sz = UInt(3.W)
  val vd = new VAddr()
  val vs = new VAddrTag()
  val data = UInt(32.W)
}

object EmitVCmdq extends App {
  def VCmdqTestFin(in: VDecodeBits): VCmdqTestBundle = {
    val out = Wire(new VCmdqTestBundle)
    out.op := in.op
    out.sz := in.sz
    out.vd := in.vd
    out.vs := in.vs
    out.data := in.sv.data
    out
  }

  def VCmdqTestFout(in: VCmdqTestBundle, m: Bool, step: UInt, valid: Bool): (VCmdqTestBundle, Bool) = {
    val out = Wire(new VCmdqTestBundle)
    val last = !m || step === 3.U
    out.op := in.op
    out.sz := in.sz
    out.vd.valid := in.vd.valid
    out.vs.valid := in.vs.valid
    out.vd.addr := in.vd.addr + 1.U
    out.vs.addr := in.vs.addr + 1.U
    out.vs.tag := in.vs.tag
    out.data := in.data
    (out, last)
  }

  def VCmdqTestFactive(in: VCmdqTestBundle, m: Bool, step: UInt): UInt = {
    assert(step.getWidth == 5)
    val active = MuxOR(in.vd.valid, RegActive(m, step(2,0), in.vd.addr)) |
                 MuxOR(in.vs.valid, RegActive(m, step(2,0), in.vs.addr))
    assert(active.getWidth == 64)
    active
  }

  @nowarn
  def emit() = {
    val p = coralnpu.Parameters()
    (new ChiselStage).execute(
      Array("--target", "systemverilog") ++ args,
      Seq(ChiselGeneratorAnnotation(() => new VCmdq(p, 8, new VCmdqTestBundle, VCmdqTestFin, VCmdqTestFout, VCmdqTestFactive))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
    )
  }
  emit()
}
