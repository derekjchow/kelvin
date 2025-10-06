// Copyright 2024 Google LLC
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

package coralnpu

import chisel3._
import chisel3.util._
import common.Fp32
import common.Fma
import common.FmaCmd

object FpuOptype extends ChiselEnum {
  val FpuAdd = Value
  val FpuSub = Value
  val FpuMul = Value
  val FpuFma = Value
  val FpuFms = Value
  val FpuFnma = Value
  val FpuFnms = Value
}

class FpuCmd extends Bundle {
  val optype = FpuOptype()
  val ina = new Fp32
  val inb = new Fp32
  val inc = new Fp32
  val waddr = UInt(5.W)
}

object FpuCmd {
  def ToFmaCmd(fpuCmd: FpuCmd): WithAddr[FmaCmd] = {
    val invert_ab = (fpuCmd.optype === FpuOptype.FpuFnma) ||
                    (fpuCmd.optype === FpuOptype.FpuFnms)
    val invert_c = (fpuCmd.optype === FpuOptype.FpuSub) ||
                   (fpuCmd.optype === FpuOptype.FpuFms) ||
                   (fpuCmd.optype === FpuOptype.FpuFnms)

    val fmaCmd = Wire(WithAddr(5, new FmaCmd))
    fmaCmd.bits.ina := Mux(invert_ab, fpuCmd.ina.negate(), fpuCmd.ina)
    fmaCmd.bits.inb := Mux((fpuCmd.optype === FpuOptype.FpuAdd) ||
                           (fpuCmd.optype === FpuOptype.FpuSub),
                           Fp32(false.B, 127.U(8.W), 0.U(23.W)),
                           fpuCmd.inb)
    fmaCmd.bits.inc := Mux((fpuCmd.optype === FpuOptype.FpuMul),
                           Fp32.fromWord(0.U(32.W)),
                           Mux(invert_c, fpuCmd.inc.negate(), fpuCmd.inc))
    fmaCmd.addr := fpuCmd.waddr
    fmaCmd
  }
}

class Fpu extends Module {
  val io = IO(new Bundle {
    val cmd = Flipped(Decoupled(new FpuCmd))
    val output = Decoupled(WithAddr(5, new Fp32))
  })

  val fmaCmd = io.cmd.map(FpuCmd.ToFmaCmd)
  val state1 = fmaCmd.map(LiftAddr(5, Fma.FmaStage1))
  val state2 = Queue(state1, 1, true).map(LiftAddr(5, Fma.FmaStage2))
  io.output <> Queue(state2, 1, true).map(LiftAddr(5, Fma.FmaStage3))
}