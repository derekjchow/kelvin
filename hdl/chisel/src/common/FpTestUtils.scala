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

/** Effectively "reinterpret_casts" a float32 into a BigInt. BigInt is used
  * because there's no easy uint32 type in scala, but BigInt works well enough
  * for Chisel use cases.
  * @param f A scala float.
  * @return A BigInt (representing uint32) bit interpretation of the float.
  */
object Float2BigInt {
  def apply(f: Float): BigInt = {
    val abs = f.abs
    var int = BigInt(java.lang.Float.floatToIntBits(abs))
    if (f < 0) {
      int += (BigInt(1) << 31)
    }
    int
  }
}

/** Breaks down a float32 into it's sign, exponent and mantissa.
  * @param f A scala float.
  * @return A tuple of the sign, exponent and mantissa.
  */
object Float2Bits {
  def apply(f: Float): (Boolean, Int, Int) = {
    val abs = f.abs
    val int = java.lang.Float.floatToIntBits(abs)

    val sign: Boolean = (f < 0)
    val exponent: Int = int >> 23
    val mantissa: Int = int & ((1 << 23) - 1)

    (sign, exponent, mantissa)
  }
}

/** Pokes a float.
  * @param dut The float input.
  * @param f A scala float.
  */
object PokeFloat {
  def apply(dut: Fp32, f: Float) = {
    val int = java.lang.Float.floatToRawIntBits(f)
    val sign = if (int < 0) { true.B } else { false.B }
    val mantissa = int & 0x7FFFFF
    val exponent = (int >> 23) & 0xFF

    dut.sign := sign
    dut.mantissa := mantissa.U
    dut.exponent := exponent.U
  }
}

/** Peeks a float.
  * @param dut The float input.
  * @param f A scala float.
  */
object PeekFloat {
  def apply(sign: Int, exponent: Int, mantissa: Int): Float = {
    val i = (sign << 31) + (exponent << 23) + mantissa
    java.lang.Float.intBitsToFloat(i.toInt)
  }
}