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

class FmaCmd extends Bundle {
  val ina = new Fp32
  val inb = new Fp32
  val inc = new Fp32
}

class FmaState1 extends Bundle {
  // Multiply variables
  val ab_inf      = Bool()
  val ab_sign     = Bool()
  val exponent    = SInt(10.W)
  val significand = UInt(48.W)

  // Addition variables
  val c_inf         = Bool()
  val c_significand = UInt(48.W)
  val shift         = SInt(11.W)
  val sub           = Bool()

  val nan           = Bool()
}

class FmaState2 extends Bundle {
  val ab_inf      = Bool()
  val c_inf       = Bool()
  val sign        = Bool()
  val exponent    = SInt(10.W)
  val significand = UInt(49.W)

  val nan           = Bool()
}

object Fma {
  def apply(cmd: FmaCmd): Fp32 = {
    FmaStage3(FmaStage2(FmaStage1(cmd)))
  }

  def FmaStage1(cmd: FmaCmd): FmaState1 = {
    val state = Wire(new FmaState1)

    val ab_zero = cmd.ina.isZero() || cmd.inb.isZero()
    val ab_inf = cmd.ina.isInf() || cmd.inb.isInf()
    state.ab_inf := ab_inf
    state.c_inf := cmd.inc.isInf()

    // Compute ina * inb % normalization
    val ab_sign = cmd.ina.sign ^ cmd.inb.sign
    state.ab_sign := ab_sign
    state.significand := cmd.ina.significand() * cmd.inb.significand()
    val product_exponent = (cmd.ina.exponent +& cmd.inb.exponent).zext - 127.S

    // Right pad c significand to match product, no propagation delay.
    val padded_c_significand = cmd.inc.significand() << 23.U
    // Compute shift, saturate and take 6 bits to barrel shift.
    // We saturate to 6 bits max as ceil(log2(48)) = 5.
    val raw_right_shift = product_exponent -& cmd.inc.exponent.zext
    val right_shift = Clamp(raw_right_shift, 0.S, 63.S).asUInt
    state.c_significand := padded_c_significand >> right_shift(5, 0)
    state.shift := raw_right_shift

    // Mark next cycle as a subtraction if the signs of ab and c differ.
    state.sub := (ab_sign ^ cmd.inc.sign)

    // Take max exponent of (a*b) or c. The smaller of the two will be right
    // shifted (a*b in stage 2 or c in stage 2)
    state.exponent := Mux(
        raw_right_shift > 0.S, product_exponent, cmd.inc.exponent.zext)

    state.nan := cmd.ina.isNan() || cmd.inb.isNan() || cmd.inc.isNan() ||
                 (ab_zero && ab_inf)

    state
  }

  def FmaStage2(state1: FmaState1): FmaState2 = {
    val state2 = Wire(new FmaState2)

    // Variables to forward to next cycle.
    state2.ab_inf := state1.ab_inf
    state2.c_inf := state1.c_inf
    state2.exponent := state1.exponent
    // Inf - Inf = NaN
    state2.nan := state1.nan || (state1.ab_inf && state1.c_inf && state1.sub)

    // Compute shift, saturate and take 6 bits to barrel shift ab_significand.
    // Hopefully shift here matches propagation delay of potential C inversion.
    val shift = (Clamp(-state1.shift, 0.S, 63.S).asUInt)(5, 0)
    val ab_significand = (state1.significand >> shift).zext
    assert(ab_significand.getWidth == 49)
    // Zext and invert if necessary
    val c_significand = Mux(
      state1.sub, -(state1.c_significand.zext), state1.c_significand.zext)
    assert(c_significand.getWidth == 49)

    val significand_sum = ab_significand +& c_significand
    assert(significand_sum.getWidth == 50)
    val sign            = significand_sum(49)
    val new_significand = (significand_sum.abs.asUInt)(48, 0)
    assert(new_significand.getWidth == 49)
    state2.sign := state1.ab_sign ^ sign
    state2.significand := new_significand

    state2
  }

  def FmaStage3(state: FmaState2): Fp32 = {
    // Compute mantissa
    val left_shamt =
        PriorityEncoder(Cat(1.U(1.W), Reverse(state.significand)))(5,0)
    val shifted_significand =
        (state.significand << left_shamt)(state.significand.getWidth, 0)
    // Grab 25 bit significand
    val reduced_significand = shifted_significand(shifted_significand.getWidth - 1,
                                                  shifted_significand.getWidth - 26)
    // Perform rounding step, going to 26 bits
    // TODO(derekjchow): Rounding mode
    val rounded_significand = reduced_significand +& 1.U(1.W)
    // Get new mantissa
    val mantissa = Mux(rounded_significand(25),
                       rounded_significand(24, 2),
                       rounded_significand(23, 1))

    // Compute new exponent
    // The +2.S comes from two widening operations in previous stages
    val exponent = state.exponent - left_shamt.zext + 2.S +
                   rounded_significand(25).asUInt.zext
    // Check for overflow.
    val inf = state.ab_inf || state.c_inf || (exponent >= (1 << 8).S)
    // Check for very small numbers that should round to zero.
    val zero = (reduced_significand === 0.U) || (exponent < 0.S)
    val nan = state.nan

    MuxCase(
        Fp32(state.sign, exponent(7, 0), mantissa),
        Seq(
            nan -> Fp32.NaN(),
            inf -> Fp32.Inf(state.sign),
            zero -> Fp32.Zero(state.sign)
        ))
  }
}
