// Copyright 2023 Google LLC
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

object MuxOR {
  def apply(valid: Bool, data: UInt): UInt = {
    Mux(valid, data, 0.U(data.getWidth.W))
  }

  def apply(valid: Bool, data: Bool): Bool = {
    Mux(valid, data, false.B)
  }
}

object MakeValid {
  def apply[T <: Data](valid: Bool, bits: T): ValidIO[T] = {
    val result = Wire(Valid(chiselTypeOf(bits)))
    result.valid := valid
    result.bits := bits
    result
  }

  def apply[T <: Data](bits: T): ValidIO[T] = {
    apply(true.B, bits)
  }
}

object MakeInvalid {
  def apply[T <: Data](gen: T): ValidIO[T] = {
    val result = Wire(Valid(gen))
      result.valid := false.B
      result.bits := 0.U.asTypeOf(gen)
      result
  }
}

// Gate the bits of an interface based on it's validity bit. This prevents
// invalid data from propagating down stream, thus reducing dynamic power
object ForceZero {
  def apply[T <: Data](input: ValidIO[T]): ValidIO[T] = {
    val result = Wire(chiselTypeOf(input))
    result.valid := input.valid
    result.bits  := Mux(input.valid, input.bits, 0.U.asTypeOf(input).bits)
    result
  }
}

object Clz {
  def apply(bits: UInt): UInt = {
    PriorityEncoder(Cat(1.U(1.W), Reverse(bits)))
  }
}

// Zip bytes/half-words in a pair of words.
object Zip32 {
  def apply(sz: UInt, a0: UInt, b0: UInt): UInt = {
    assert(sz.getWidth == 3)
    assert(a0.getWidth == 32)
    assert(b0.getWidth == 32)

    // Zip half-words
    val zipHalf = sz(0) | sz(1)
    val a1 = Cat(Mux(zipHalf, b0(15, 0), a0(31, 16)), a0(15, 0))
    val b1 = Cat(b0(31, 16), Mux(zipHalf, a0(31, 16), b0(15, 0)))

    // Zip bytes
    val zipBytes = sz(0)
    val a2 = Cat(a1(31, 24),
                 Mux(zipBytes, Cat(a1(15, 8), a1(23, 16)), a1(23, 8)),
                 a1(7, 0))
    val b2 = Cat(b1(31, 24),
                 Mux(zipBytes, Cat(b1(15, 8), b1(23, 16)), b1(23, 8)),
                 b1(7, 0))

    Cat(b2, a2)
  }
}
