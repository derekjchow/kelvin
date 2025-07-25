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

// An easy way to build a Wire(T) and (partially) connect some of its
// contents.
// This is essentially somewhere between WireDefault (which does not like
// bundle members) and bundle literals (which only likes literals)
// See MakeValid for usage example.
// TODO: add more examples for advanced usage:
// - _.member1.member2 on LHS
// - _.something on RHS (only, or both)
// - _ (no member) on LHS
// TODO: add tests
object MakeWireBundle {
  def apply[T <: Bundle](gen: T, exp: T => (Data, Data)*): T = {
    val ret = Wire(gen)
    exp.foreach { e =>
      val (x, y) = e(ret)
      x := y
    }
    ret
  }
}

object MakeValid {
  def apply[T <: Data](valid: Bool, bits: T): ValidIO[T] = {
    // Explicitly stating the type here allows the function types to be
    // inferred.
    MakeWireBundle[ValidIO[T]](
      Valid(chiselTypeOf(bits)),
      _.valid -> valid,
      _.bits -> bits,
    )
  }

  def apply[T <: Data](bits: T): ValidIO[T] = {
    apply(true.B, bits)
  }
}

object MakeInvalid {
  def apply[T <: Data](gen: T): ValidIO[T] = MakeWireBundle[ValidIO[T]](
    Valid(gen),
    _.valid -> false.B,
    _.bits -> 0.U.asTypeOf(gen),
  )
}

object MakeDecoupled {
  def apply[T <: Data](valid: Bool, ready: Bool, bits: T): DecoupledIO[T] = {
    MakeWireBundle[DecoupledIO[T]](
      Decoupled(chiselTypeOf(bits)),
      _.valid -> valid,
      _.ready -> ready,
      _.bits -> bits
    )
  }
}

// Gate the bits of an interface based on it's validity bit. This prevents
// invalid data from propagating down stream, thus reducing dynamic power
object ForceZero {
  def apply[T <: Data](input: ValidIO[T]): ValidIO[T] = MakeWireBundle[ValidIO[T]](
    chiselTypeOf(input),
    _.valid -> input.valid,
    _.bits  -> Mux(input.valid, input.bits, 0.U.asTypeOf(input).bits),
  )
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

object UIntToVec {
  def apply(in: UInt, elemWidth: Int): Vec[UInt] = {
    assert((in.getWidth % elemWidth) == 0)
    VecInit((0 until in.getWidth by elemWidth).map(
      x => in(x + elemWidth - 1, x)
    ))
  }
}

object Contains {
  def apply(idx: UInt, start: UInt, end: UInt): Bool = {
    (idx >= start) && (idx < end)
  }
}

// Rotates elements in a vector.
// Result[i] = data[(i + shift) % data.size]
object RotateVectorLeft {
  def apply[T <: Data](data: Vec[T], shift: UInt): Vec[T] = {
    val elemSize = data(0).asUInt.getWidth
    val rotated = data.asUInt.rotateLeft(shift * elemSize.U)
    rotated.asTypeOf(chiselTypeOf(data))
  }
}

// Rotates elements in a vector.
// Result[i] = data[(i - shift) % data.size]
object RotateVectorRight {
  def apply[T <: Data](data: Vec[T], shift: UInt): Vec[T] = {
    val elemSize = data(0).asUInt.getWidth
    val rotated = data.asUInt.rotateRight(shift * elemSize.U)
    rotated.asTypeOf(chiselTypeOf(data))
  }
}

// Shifts elements in a vector, and fills empty space w/ zeroes.
// Result[i] = data[(i + shift) % data.size]
object ShiftVectorLeft {
  def apply[T <: Data](data: Vec[T], shift: UInt): Vec[T] = {
    val elemSize = data(0).asUInt.getWidth
    val shifted = data.asUInt << (shift * elemSize.U)
    shifted.asTypeOf(chiselTypeOf(data))
  }
}

// Shifts elements in a vector, and fills empty space w/ zeroes.
// Result[i] = data[(i - shift) % data.size]
object ShiftVectorRight {
  def apply[T <: Data](data: Vec[T], shift: UInt): Vec[T] = {
    val elemSize = data(0).asUInt.getWidth
    val shifted = data.asUInt >> (shift * elemSize.U)
    shifted.asTypeOf(chiselTypeOf(data))
  }
}

// Check valids, fires, or other bool vec/seq is set in order, fail if not (1100 OK, 1101 NOT OK)
object OneHotInOrder {
  def apply(oneHotBits: Seq[Bool]): Bool = {
    val failed = (0 until oneHotBits.length - 1).map(i => !oneHotBits(i) && oneHotBits(i + 1)).reduce(_||_)
    !failed
  }
}