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

package common

import chisel3._
import chisel3.util._

object FpuOp extends ChiselEnum {
  val FpuMul = Value
}

class FpuCmd extends Bundle {
  val op = FpuOp()
  val ina = new Fp32
  val inb = new Fp32
}

class FpuState1 extends Bundle {
  val zero        = Bool()
  val inf         = Bool()
  val nan         = Bool()
  val sign        = Bool()
  val exponent    = SInt(10.W)
  val significand = UInt(48.W)
}

object Fpu {
  def apply(cmd: FpuCmd): Fp32 = {
    FpuStage2(FpuStage1(cmd))
  }

  def FpuStage1(cmd: FpuCmd): FpuState1 = {
    val state = Wire(new FpuState1)

    state.zero := cmd.ina.isZero() || cmd.inb.isZero()
    state.inf := cmd.ina.isInf() || cmd.inb.isInf()
    state.nan := cmd.ina.isNan() || cmd.inb.isNan()

    state.sign := cmd.ina.sign ^ cmd.inb.sign
    state.exponent := (cmd.ina.exponent +& cmd.inb.exponent).zext - 127.S
    state.significand := cmd.ina.significand() * cmd.inb.significand()
    state
  }

  def FpuStage2(state: FpuState1): Fp32 = {
    // Grab 24-bits of the mantissa for rounding. At least one of the MSB (for
    // when the significand product >= 2) or 2nd MSB is guarenteed to be set.
    // The below mux effectively picks the correct 25-bit truncated significand
    // depending if the MSB is set, then returns the lower 24-bits of that
    // result (the mantissa of the truncated significand).
    val mantissa24 = Mux(
        state.significand(47),
        state.significand(46, 23),
        state.significand(45, 22))
    // TODO(derekjchow): Rounding modes
    val mantissa = ((mantissa24 + 1.U(1.W)) >> 1)(22, 0)

    // If the significand product >= 2, we "shift the decimal" to the right
    // by one bit. Add 1 to the exponent to compensate.
    val exponent = state.exponent + state.significand(47).asUInt.zext
    // Check for overflow.
    val inf = state.inf || (exponent >= (1 << 8).S)
    // Check for very small numbers that should round to zero.
    val zero = state.zero || (exponent < 0.S)

    MuxCase(
        Fp32(state.sign, exponent(7, 0), mantissa),
        Array(
            state.nan -> Fp32(false.B, ((1<<8)-1).U, mantissa),
            (state.zero && state.inf) -> Fp32.NaN(),
            inf -> Fp32.Inf(state.sign),
            zero -> Fp32.Zero(state.sign)
        ))
  }
}
