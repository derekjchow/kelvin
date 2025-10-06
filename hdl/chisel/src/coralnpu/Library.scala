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

package coralnpu

import chisel3._
import chisel3.util._

object Mux0 {
  def apply(valid: Bool, data: UInt): UInt = {
    Mux(valid, data, 0.U(data.getWidth.W))
  }

  def apply(valid: Bool, data: Bool): Bool = {
    Mux(valid, data, false.B)
  }
}

object MuxOR {
  def apply(valid: Bool, data: UInt): UInt = {
    Mux(valid, data, 0.U(data.getWidth.W))
  }

  def apply(valid: Bool, data: Bool): Bool = {
    Mux(valid, data, false.B)
  }
}

object Min {
  def apply(a: UInt, b: UInt): UInt = {
    assert(a.getWidth == b.getWidth)
    Mux(a < b, a, b)
  }
}

object Max {
  def apply(a: UInt, b: UInt): UInt = {
    assert(a.getWidth == b.getWidth)
    Mux(a > b, a, b)
  }
}

object Repeat {
  def apply(b: Bool, n: Int): UInt = {
    val r = VecInit(Seq.fill(n)(b))
    r.asUInt
  }
}

object SignExt {
  def apply(v: UInt, n: Int): UInt = {
    val s = v.getWidth
    val r = Cat(Repeat(v(s - 1), n - s), v)
    assert(r.getWidth == n)
    r.asUInt
  }
}

// ORs vector lanes.
//  Vec(4, UInt(7.W)) -> UInt(7.W)
//  for (i <- 0 until count) out |= in(i)
object VecOR {
  def apply(vec: Vec[UInt], count: Int, index: Int, bits: UInt): UInt = {
    if (index < count) {
      apply(vec, count, index+1, bits | vec(index))
    } else {
      bits
    }
  }

  def apply(vec: Vec[Bool], count: Int, index: Int, bits: Bool): Bool = {
    if (index < count) {
      apply(vec, count, index+1, bits || vec(index))
    } else {
      bits
    }
  }

  def apply(vec: Vec[UInt], count: Int): UInt = {
    apply(vec, count, 0, 0.U)
  }

  def apply(vec: Vec[Bool], count: Int): Bool = {
    apply(vec, count, 0, false.B)
  }

  def apply(vec: Vec[UInt]): UInt = {
    val count = vec.length
    apply(vec, count, 0, 0.U)
  }

  def apply(vec: Vec[Bool]): Bool = {
    val count = vec.length
    apply(vec, count, 0, false.B)
  }
}

object IndexMask {
  def apply(data: Vec[UInt], index: UInt): Vec[UInt] = {
    val count = data.length
    val width = data(0).getWidth.W
    val value = Wire(Vec(count, UInt(width)))
    for (i <- 0 until count) {
      value(i) := Mux(i.U === index, data(i), 0.U)
    }
    value
  }
}

object OrReduce {
  def apply(data: Vec[UInt]): UInt = {
    if (data.length > 1) {
      val count = data.length / 2
      val odd   = data.length & 1
      val width = data(0).getWidth.W
      val value = Wire(Vec(count + odd, UInt(width)))
      for (i <- 0 until count) {
        value(i) := data(2 * i + 0) | data(2 * i + 1)
      }
      if (odd != 0) {
        value(count) := data(2 * count)
      }
      OrReduce(value)
    } else {
      data(0)
    }
  }
}

object VecAt {
  def apply(data: Vec[Bool], index: UInt): Bool = {
    assert(data.length == (1 << index.getWidth))
    val count = data.length
    val dataUInt = Wire(Vec(count, UInt(1.W)))
    for (i <- 0 until count) {
      dataUInt(i) := data(i)
    }
    OrReduce(IndexMask(dataUInt, index)) =/= 0.U
  }

  def apply(data: Vec[UInt], index: UInt): UInt = {
    assert(data.length == (1 << index.getWidth))
    OrReduce(IndexMask(data, index))
  }
}

object BoolAt {
  def apply(udata: UInt, index: UInt): Bool = {
    assert(udata.getWidth == (1 << index.getWidth))
    val width = udata.getWidth
    val data = Wire(Vec(width, UInt(1.W)))
    for (i <- 0 until width) {
      data(i) := udata(i)
    }
    OrReduce(IndexMask(data, index)) =/= 0.U
  }
}

object WiredAND {
  def apply(bits: UInt): Bool = {
    WiredAND(VecInit(bits.asBools))
  }

  def apply(bits: Vec[Bool]): Bool = {
    val count = bits.length
    if (count > 1) {
      val limit = (count + 1) / 2
      val value = Wire(Vec(limit, Bool()))
      for (i <- 0 until limit) {
        if (i * 2 + 1 >= count) {
          value(i) := bits(2 * i + 0)
        } else {
          value(i) := bits(2 * i + 0) & bits(2 * i + 1)
        }
      }
      WiredAND(value)
    } else {
      bits(0)
    }
  }
}

object WiredOR {
  def apply(bits: UInt): Bool = {
    WiredOR(VecInit(bits.asBools))
  }

  def apply(bits: Vec[Bool]): Bool = {
    val count = bits.length
    if (count > 1) {
      val limit = (count + 1) / 2
      val value = Wire(Vec(limit, Bool()))
      for (i <- 0 until limit) {
        if (i * 2 + 1 >= count) {
          value(i) := bits(2 * i + 0)
        } else {
          value(i) := bits(2 * i + 0) | bits(2 * i + 1)
        }
      }
      WiredOR(value)
    } else {
      bits(0)
    }
  }
}

// Page mask for two address ranges, factoring unaligned address overflow.
object PageMaskShift {
  def apply(address: UInt, length: UInt): UInt = {
    assert(address.getWidth == 32)

    // Find the power2 page size that contains the range offset+length.
    // The address width is one less than length, as we want to use the
    // page base of zero and length to match the page size.
    val psel = Cat((address(9,0) +& length) <= 1024.U,
                   (address(8,0) +& length) <= 512.U,
                   (address(7,0) +& length) <= 256.U,
                   (address(6,0) +& length) <= 128.U,
                   (address(5,0) +& length) <= 64.U,
                   (address(4,0) +& length) <= 32.U,
                   (address(3,0) +& length) <= 16.U,
                   (address(2,0) +& length) <= 8.U,
                   (address(1,0) +& length) <= 4.U)

    val pshift =
        Mux(psel(0), 2.U, Mux(psel(1), 3.U, Mux(psel(2), 4.U, Mux(psel(3), 5.U,
        Mux(psel(4), 6.U, Mux(psel(5), 7.U, Mux(psel(6), 8.U, Mux(psel(7), 9.U,
        Mux(psel(8), 10.U, 0.U)))))))))

    // Determine the longest run of lsb 1's. We OR 1's of the address lsb so
    // that base+length overflow ripple extends as far as needed.
    // Include an additional lsb 1 to round us to the next page size, as we will
    // not perform in page test beyond the segmentBits size.
    val addrmask = Cat(address(31,10), ~0.U(10.W), 1.U(1.W))
    val cto = PriorityEncoder(~addrmask)
    assert(cto.getWidth == 6)

    // Mask shift value.
    val shift = Mux(psel =/= 0.U, pshift, cto)
    assert(shift.getWidth == 6)

    shift
  }
}

// Modulo, where divisor must be a power of two.
object Mod2 {
  def apply(dividend: UInt, divisor: UInt) = {
    dividend & (divisor - 1.U)
  }
}

object Cto {
  def apply(bits: UInt): UInt = {
    PriorityEncoder(Cat(1.U(1.W), ~bits))
  }
}

object Ctz {
  def apply(bits: UInt): UInt = {
    PriorityEncoder(Cat(1.U(1.W), bits))
  }
}

// Unused
object Clb {
  def apply(bits: UInt): UInt = {
    val clo = Clo(bits)
    val clz = Clz(bits)
    Mux(bits(bits.getWidth - 1), clo, clz)
  }
}

// Unused
object Clo {
  def apply(bits: UInt): UInt = {
    PriorityEncoder(Cat(1.U(1.W), Reverse(~bits)))
  }
}

object Clz {
  def apply(bits: UInt): UInt = {
    PriorityEncoder(Cat(1.U(1.W), Reverse(bits)))
  }
}

object WCtz {
  def apply(bits: UInt, offset: Int = 0): UInt = {
    assert((bits.getWidth % 32) == 0)
    val z = Ctz(bits(31, 0))
    val v = z | offset.U
    assert(z.getWidth == 6)
    if (bits.getWidth > 32) {
      Mux(!z(5), v, WCtz(bits(bits.getWidth - 1, 32), offset + 32))
    } else {
      Mux(!z(5), v, (offset + 32).U)
    }
  }
}

/** A bundle that extends Data with an addr field. The lifted Data type will be
  * contained in the "bits" field.
  * @param width The bit-width of the addr field.
  * @param gen The type of data to wrap.
  */
class WithAddr[+T <: Data](width: Int, gen: T) extends Bundle {
  val addr = UInt(width.W)
  val bits = gen
}

object WithAddr {
  def apply[T <: Data](width: Int, gen: T): WithAddr[T] = new WithAddr(width, gen)

  def create[T <: Data](addr: UInt, bits: T) = {
    val result = Wire(WithAddr(addr.getWidth, chiselTypeOf(bits)))
    result.addr := addr
    result.bits := bits
    result
  }
}

/** A transformation that lifts a function f = (x => y) to a new function
  * f = (WithAddr[x] => WithAddr[y]). The addr field of the lifted function
  * is preserved between the inputs and outputs.
  * @param width The bit-width of the addr field.
  * @param f The function to lift.
  */
object LiftAddr {
  def apply[X <: Data, Y <: Data](width: Int, f: X => Y) = {
    (x: WithAddr[X]) => WithAddr.create(x.addr, f(x.bits))
  }
}

/** Inhibit the propagation of valid/ready signals while enable is low.
  * @param iface The DecoupledIO interface to gate.
  * @param enable The signal to use to control the gate.
  */
object GateDecoupled {
  def apply[T <: Bundle](iface: DecoupledIO[T], enable: Bool): DecoupledIO[T] = {
    val out = Wire(chiselTypeOf(iface))
    iface.bits <> out.bits
    iface.ready := out.ready && (enable)
    out.valid := iface.valid && (enable)
    out
  }
}

/**
   * Generates two bitmasks based on an address, transaction sizes, and the total number of bytes.
   * These masks are typically used to identify which bytes are affected by two sequential transactions.
   *
   * @param nBytes The total number of bytes for which the mask is being generated.
   * @param addr The starting address of the first transaction. The lower bits of this address are used as an offset.
   * @param txnSizes A vector of UInts representing the sizes of the transactions.
   * @return A tuple containing two UInts:
   * - A bitmask for the first transaction.
   * - A bitmask for the second transaction.
   */
object GenerateMasks {
  def apply(nBytes: Int, addr: UInt, txnSizes: Vec[UInt]): (UInt, UInt) = {
    val bottom = addr(log2Ceil(nBytes),0)
    val mask0 = VecInit((0 until nBytes).map(i => i.U < txnSizes(0))).asUInt.rotateLeft(bottom)
    val mask1 = VecInit((0 until nBytes).map(i => i.U < txnSizes(1))).asUInt.rotateLeft(bottom + txnSizes(0))
    (mask0, mask1)
  }
}

// Convert masks where each bit represents a byte,
// to masks where each bit represents a bit.
object BytemaskToBitmask {
  def apply(bytemask: UInt): UInt = {
    VecInit(bytemask.asBools.map(Mux(_, 255.U(8.W), 0.U(8.W)))).asUInt
  }
}
