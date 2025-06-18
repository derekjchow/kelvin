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

/** An interface which encapsulates up-to n DecoupledIO interfaces. The
  * convention is that the first nValid interfaces are considered valid.
  */
class DecoupledVectorIO[T <: Data](gen: T, n: Int) extends Bundle {
  val nReady = Input(UInt(log2Up(n+1).W))
  val nValid = Output(UInt(log2Up(n+1).W))
  val bits = Output(Vec(n, gen))
}

object DecoupledVectorIO {
  def apply[T <: Data](gen: T, n: Int): DecoupledVectorIO[T] = new DecoupledVectorIO(gen, n)
}

/** Returns the one-hot vec with only the least significant valid bit set, or
  * all false if all bits are false.
  * @param in A sequences of booleans
  * @return The priority selected boolean.
  */
object PrioritySelect {
  def apply(in: Seq[Bool]): Vec[Bool] = {
    val seenValid = in.scan(false.B)(_ || _).take(in.length)
    VecInit((in zip seenValid).map({case (x, seen) => x && !seen}))
  }
}

/** A FIFO queue that enqueues/dequeues multiple elements a cycle, but also
  * contains a bypass interface that allows dequeuing elements out of order and
  * optional flush.
  * The general structure of this module looks as follows:
  *
  *                       Out
  *                        ^
  *                        |
  *               +-----------------------------+
  *               |        |                    |
  *               |        |                    |
  *               |        |                    |
  *               |        |                    |
  *               |        |   New Buffer       |
  *               |        |    |     ^         |
  *               |        |    V     |         |
  *               |        Buffer     |         |
  *               |         |         |         |
  *               |         +------> Align -----|-> feedOut
  *               |                   ^         |
  *               |                   |         |
  *       feedIn -|-------------------+         |
  *               |                             |
  *               +-----------------------------+
  *
  * We can compose InstructionBufferSlice's together to create a bigger window
  * to extract elements from. This looks like:
  *
  *                                   Out
  *                                    ^
  *                                    |
  *                     +--------------+------------+
  *                     |            Concat         |
  *                     +--------------+------------+
  *                        ^                     ^
  *                        |                     |
  *         +------------------------+    +------------------------+
  * feedIn -| InstructionBufferSlice | -> | InstructionBufferSlice | -> feedOut
  *         +------------------------+    +------------------------+
  */
class InstructionBufferSlice[T <: Data](
    val gen: T, val n: Int, val hasFlush: Boolean = false) extends Module {
  val io = IO(new Bundle {
    val feedIn = Flipped(DecoupledVectorIO(gen, n))
    val feedOut = DecoupledVectorIO(gen, n)
    val out = Vec(n, Decoupled(gen))
    val flush = if (hasFlush) { Some(Input(Bool())) } else { None }
  })
  val buffer = RegInit(VecInit.fill(n)(MakeValid(false.B, 0.U.asTypeOf(gen))))

  // Withdraw elements from buffer
  val remainderValid = Wire(Vec(n, Bool()))
  for (i <- 0 until n) {
    if (hasFlush) {
      io.out(i).valid := buffer(i).valid && !io.flush.get
    } else {
      io.out(i).valid := buffer(i).valid
    }
    io.out(i).bits := buffer(i).bits

    remainderValid(i) := buffer(i).valid && !io.out(i).ready
  }

  // Sort remainder buffer
  val sortedRemainderBuffer = Wire(Vec(n, gen))
  var prevValids = remainderValid
  for (i <- 0 until n) {
    val selectHot = PrioritySelect(prevValids)
    sortedRemainderBuffer(i) := MuxCase(
        0.U.asTypeOf(gen), (0 until n).map(x => selectHot(x) -> buffer(x).bits))
    prevValids = VecInit((prevValids zip selectHot).map(
        {case (p, s) => p && !s}))
  }

  // Request buffers from feedIn
  val nRemaining = PopCount(remainderValid)
  val nRequesting = io.feedOut.nReady +& n.U - nRemaining
  val satRequesting = Mux(nRequesting > n.U, n.U, nRequesting)
  io.feedIn.nReady := satRequesting
  assert(io.feedIn.nValid <= satRequesting)

  // Sort available elements
  val nAvailable = io.feedIn.nValid +& nRemaining
  val available = Wire(Vec(2*n, gen))
  for (i <- 0 until 2*n) {
    available(i) := MuxCase(
        /* i.U < nRemaining */ sortedRemainderBuffer(i.U(log2Ceil(n) - 1, 0)),
        Seq(
            (i.U >= nAvailable) -> 0.U.asTypeOf(gen),
            (i.U >= nRemaining) -> io.feedIn.bits((i.U - nRemaining)(log2Ceil(n) - 1, 0)),
    ))
  }

  // Populate feedOut
  val nFeedOut = Mux(
      nAvailable > io.feedOut.nReady, io.feedOut.nReady, nAvailable)
  io.feedOut.nValid := nFeedOut
  for (i <- 0 until n) {
    io.feedOut.bits(i) := Mux(i.U < nFeedOut, available(i), 0.U.asTypeOf(gen))
  }

  // Populate new buffer
  val nextBuffer = Wire(Vec(n, Valid(gen)))
  for (i <- 0 until n) {
    val idx = i.U +& nFeedOut
    val valid = idx < nAvailable
    nextBuffer(i).valid := valid
    nextBuffer(i).bits := Mux(valid, available(idx(log2Ceil(2*n) - 1, 0)), 0.U.asTypeOf(gen))
  }
  if (hasFlush) {
    buffer := Mux(io.flush.get,
                  VecInit.fill(n)(MakeValid(false.B, 0.U.asTypeOf(gen))),
                  nextBuffer)
  } else {
    buffer := nextBuffer
  }
}

/** A data structure where elements are inserted in order, but can be removed
  * in an arbitrary order. This can be used to implement the instruction window
  * of a processor.
  *
  * There are a few of notable limitations for this module:
  * 1) It is expected that up to "n" elements can be removed each cycle.
  *    Downstream consumers of the out interface should be sure to only  set up
  *    to "n" ready signals.
  * 2) The window parameter must be a multiple of n.
  */
class InstructionBuffer[T <: Data](val gen: T,
                                   val n: Int,
                                   val window: Int,
                                   val hasFlush: Boolean = false) extends Module {
  val slices: Int = window / n
  assert(window % n == 0)
  assert(slices > 0)
  val io = IO(new Bundle {
    val feedIn = Flipped(DecoupledVectorIO(gen, n))
    val out = Vec(window, Decoupled(gen))
    val flush = if (hasFlush) { Some(Input(Bool())) } else { None }
  })

  // Compose InstructionBufferSlices
  var feedIn = io.feedIn
  var outputs: Seq[DecoupledIO[T]] = Seq()
  for (s <- 0 until slices) {
    val slice = Module(new InstructionBufferSlice(gen, n, hasFlush))
    if (hasFlush) {
      slice.io.flush.get := io.flush.get
    }
    slice.io.feedIn <> feedIn
    feedIn = slice.io.feedOut
    outputs = slice.io.out ++ outputs
  }

  // Terminate
  feedIn.nReady := 0.U

  io.out <> VecInit(outputs)
}