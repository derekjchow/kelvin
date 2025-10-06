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

object VConvCtrl {
  def apply(p: Parameters): VConvCtrl = {
    return Module(new VConvCtrl(p))
  }
}

class VConvCtrl(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Instructions.
    val in = Flipped(Decoupled(Vec(p.instructionLanes, Valid(new VDecodeBits))))
    val active = Output(UInt(64.W))

    // RegisterFile.
    val vrfsb = Input(UInt(128.W))
    val out = new VRegfileConvIO(p)
  })

  // A usable depth of outstanding commands.
  val cmdqDepth = p.instructionLanes

  val e = new VEncodeOp()

  // ---------------------------------------------------------------------------
  // Command Queue.
  class VConvCtrlCmdq extends Bundle {
    val conv   = Bool()  // convolution
    val init   = Bool()  // initialize (set)
    val tran   = Bool()  // transpose
    val wclr   = Bool()  // get and clear (marks last cycle)
    val addr1  = UInt(6.W)
    val addr2  = UInt(6.W)
    val base2  = UInt(6.W)
    val mode   = UInt(2.W)
    val mark2  = UInt((p.vectorBits / 32).W)
    val index  = UInt(log2Ceil(p.vectorBits / 32).W)
    val end    = UInt(log2Ceil(p.vectorBits / 32).W)
    val abias  = UInt(9.W)
    val bbias  = UInt(9.W)
    val asign  = Bool()
    val bsign  = Bool()
  }

  def Fin(in: VDecodeBits): VConvCtrlCmdq = {
    val out = Wire(new VConvCtrlCmdq)

    val vcget  = in.op === e.vcget.U
    val acset  = in.op === e.acset.U
    val actr   = in.op === e.actr.U
    val aconv  = in.op === e.aconv.U

    val addr1 = in.vs.addr
    val addr2 = Mux(acset, in.vs.addr, in.vu.addr)
    val data  = in.sv.data
    val sp    = (p.vectorBits / 32) - 1
    val mark2 = Wire(UInt((p.vectorBits / 32).W))
    val start = Mux(acset || actr, 0.U,  data(6,2))
    val stop  = Mux(acset || actr, sp.U, data(11,7))

    if (p.vectorBits == 128) {
      mark2 := 0xf.U >> (3.U - (stop(1,0) - start(1,0)))
    } else if (p.vectorBits == 256) {
      mark2 := 0xff.U >> (7.U - (stop(2,0) - start(2,0)))
    } else if (p.vectorBits == 512) {
      mark2 := 0xffff.U >> (15.U - (stop(3,0) - start(3,0)))
    } else {
      assert(false)
    }

    out.conv  := aconv
    out.init  := acset
    out.tran  := actr
    out.wclr  := vcget
    out.addr1 := addr1
    out.addr2 := addr2
    out.base2 := addr2
    out.mode  := data(1,0)
    out.mark2 := mark2
    out.index := start
    out.end   := stop
    out.abias := data(20,12)
    out.asign := data(21)
    out.bbias := data(30,22)
    out.bsign := data(31)

    out
  }

  def Fout(in: VConvCtrlCmdq, m: Bool, step: UInt, valid: Bool): (VConvCtrlCmdq, Bool) = {
    when (valid) {
      assert(m === false.B)
      assert(in.index <= in.end)

      if (p.vectorBits == 128) {
        assert(in.addr1(1,0) === 0.U)
      } else if (p.vectorBits == 256) {
        assert(in.addr1(2,0) === 0.U)
      } else if (p.vectorBits == 512) {
        assert(in.addr1(3,0) === 0.U)
      }
    }

    val out = Wire(new VConvCtrlCmdq)
    val last = in.index === in.end || in.wclr

    out := in
    out.index := in.index + 1.U
    out.addr2 := in.addr2 + 1.U

    (out, last)
  }

  def Factive(in: VConvCtrlCmdq, m: Bool, step: UInt): UInt = {
    val active1 = Wire(UInt(64.W))
    val active2 = Wire(UInt(64.W))

    val addr1 = in.addr1

    // (mark2 & (mark2 << step)) clears the lsb bits.
    if (p.vectorBits == 128) {
      active1 := 0xf.U << Cat(addr1(5,2), 0.U(2.W))
      active2 := ((in.mark2 & (in.mark2 << step(1,0))) << in.base2)(63,0)
    } else if (p.vectorBits == 256) {
      active1 := 0xff.U << Cat(addr1(5,3), 0.U(3.W))
      active2 := ((in.mark2 & (in.mark2 << step(2,0))) << in.base2)(63,0)
    } else if (p.vectorBits == 512) {
      active1 := 0xffff.U << Cat(addr1(5,4), 0.U(4.W))
      active2 := ((in.mark2 & (in.mark2 << step(3,0))) << in.base2)(63,0)
    } else {
      assert(false)
    }

    // Only reads are reported in active, vrfsb tracks writes.
    val active = MuxOR(in.conv || in.tran, active1) |
                 MuxOR(in.conv || in.init, active2)

    active
  }

  val q = VCmdq(p, cmdqDepth, new VConvCtrlCmdq, Fin, Fout, Factive)

  q.io.in <> io.in

  // ---------------------------------------------------------------------------
  // VRegfile Conv.
  val active = Factive(q.io.out.bits, false.B, 0.U)

  // Write ports take 2 cycles to commit to register store, but 3 cycles need
  // to be factored due to ALU-to-ALU scoreboard forwarding.
  val vrfsb0 = io.vrfsb(63,0) | io.vrfsb(127,64)
  val vrfsb1 = RegInit(0.U(64.W))
  val vrfsb2 = RegInit(0.U(64.W))
  val vrfsb = vrfsb0 | vrfsb1 | vrfsb2
  vrfsb1 := vrfsb0
  vrfsb2 := vrfsb1

  val ready = (active & vrfsb) === 0.U

  q.io.out.ready := ready

  io.out.valid := q.io.out.valid
  io.out.ready := ready

  io.out.op.conv := q.io.out.bits.conv
  io.out.op.init := q.io.out.bits.init
  io.out.op.tran := q.io.out.bits.tran
  io.out.op.wclr := q.io.out.bits.wclr

  io.out.mode  := q.io.out.bits.mode
  io.out.index := q.io.out.bits.index
  io.out.addr1 := q.io.out.bits.addr1
  io.out.addr2 := q.io.out.bits.addr2
  io.out.abias := q.io.out.bits.abias
  io.out.asign := q.io.out.bits.asign
  io.out.bbias := q.io.out.bits.bbias
  io.out.bsign := q.io.out.bits.bsign

  assert(!(q.io.out.bits.wclr && !q.io.out.ready))

  assert(!(io.out.valid && io.out.ready) ||
         PopCount(Cat(io.out.op.conv, io.out.op.init, io.out.op.tran, io.out.op.wclr)) === 1.U)

  // ---------------------------------------------------------------------------
  // Active.
  io.active := q.io.active
}

@nowarn
object EmitVConvCtrl extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VConvCtrl(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
