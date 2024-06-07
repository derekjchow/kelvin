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
