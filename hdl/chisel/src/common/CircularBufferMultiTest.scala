// Copyright 2025 Google LLC
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
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._

class CircularBufferMultiSpec extends AnyFreeSpec with ChiselScalatestTester {
  "Basic" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      dut.io.enqValid.poke(2)
      dut.io.enqData(0).poke(3)
      dut.io.enqData(1).poke(5)
      dut.clock.step()

      assertResult(2) { dut.io.nEnqueued.peekInt() }
      assertResult(3) { dut.io.dataOut(0).peekInt() }
      assertResult(5) { dut.io.dataOut(1).peekInt() }

      dut.io.enqValid.poke(1)
      dut.io.enqData(0).poke(9001)
      dut.io.enqData(1).poke(0)
      dut.clock.step()

      assertResult(3) { dut.io.nEnqueued.peekInt() }
      assertResult(3) { dut.io.dataOut(0).peekInt() }
      assertResult(5) { dut.io.dataOut(1).peekInt() }
      assertResult(9001) { dut.io.dataOut(2).peekInt() }

      dut.io.enqValid.poke(0)
      dut.io.deqReady.poke(1)
      dut.clock.step()

      assertResult(2) { dut.io.nEnqueued.peekInt() }
      assertResult(5) { dut.io.dataOut(0).peekInt() }
      assertResult(9001) { dut.io.dataOut(1).peekInt() }
    }
  }

  "Write n" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      for (n <- 0 until 4) {
        dut.io.enqData(n).poke(n)
      }
      dut.io.enqValid.poke(4)
      dut.clock.step()

      assertResult(4) { dut.io.nEnqueued.peekInt() }

      for (n <- 0 until 4) {
        assertResult(n) { dut.io.dataOut(n).peekInt() }
      }
    }
  }

  "Fill Buffer" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Fill buffer completely
      for (writeCount <- 0 until 4) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
        // Confirm nEnqueued increments the amount corresponding to #enqValid each cycle
        assertResult((writeCount+1)*4) { dut.io.nEnqueued.peekInt() }
      }
    }
  }

  "Fill and Empty Buffer" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Fill buffer completely
      for (writeCount <- 0 until 4) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)
      assertResult(16) { dut.io.nEnqueued.peekInt() }

      // Empty buffer completely
      for (writeCount <- 0 until 4) {
        for (nIndex <- 0 until 4) {
          var outdata = writeCount*4 + nIndex
          assertResult(outdata) { dut.io.dataOut(nIndex).peekInt() }
        }
        dut.io.deqReady.poke(4)
        dut.clock.step()
      }
      dut.io.deqReady.poke(0)
      assertResult(0) { dut.io.nEnqueued.peekInt() }
    }
  }
  "Fill, Remove 4 items, and fill back to the top" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Fill buffer completely
      // Use 4x transactions of n=4 items to fill up to size 16, incrementing each transaction
      for (writeCount <- 0 until 4) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)
      assertResult(16) { dut.io.nEnqueued.peekInt() }

      // Remove 4x items
      for (writeCount <- 0 until 1) {
        for (nIndex <- 0 until 4) {
          var outdata = writeCount*4 + nIndex
          assertResult(outdata) { dut.io.dataOut(nIndex).peekInt() }
        }
        dut.io.deqReady.poke(4)
        dut.clock.step()
      }
      dut.io.deqReady.poke(0)
      assertResult(12) { dut.io.nEnqueued.peekInt() }

      // Add back n=4 items
      for (writeCount <- 4 until 5) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)
      assertResult(16) { dut.io.nEnqueued.peekInt() }
      // Remove 4x items
      for (writeCount <- 1 until 2) {
        for (nIndex <- 0 until 4) {
          var outdata = writeCount*4 + nIndex
          assertResult(outdata) { dut.io.dataOut(nIndex).peekInt() }
        }
        dut.io.deqReady.poke(4)
        dut.clock.step()
      }
      assertResult(12) { dut.io.nEnqueued.peekInt() }
    }
  }

  "Flush Test" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Fill buffer completely and flush
      for (writeCount <- 0 until 4) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)

      assertResult(16) { dut.io.nEnqueued.peekInt() }

      dut.io.flush.poke(true)
      dut.clock.step()
      dut.clock.step()
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Add 4x items and flush
      for (writeCount <- 0 until 1) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)

      assertResult(4) { dut.io.nEnqueued.peekInt() }

      dut.io.flush.poke(true)
      dut.clock.step()
      dut.clock.step()
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)
      }
    }

  "Read and Write Buffer on Same Cycle" in {
    test(new CircularBufferMulti(UInt(32.W), 4, 16)) { dut =>
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)

      // Use 2x transactions of n=4 items to fill up to size 8, incrementing each transaction
      for (writeCount <- 0 until 2) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      dut.io.enqValid.poke(0)
      assertResult(8) { dut.io.nEnqueued.peekInt() }

      // Enque and Deque on same cycle
      dut.io.enqValid.poke(3)
      dut.io.enqData(0).poke(3)
      dut.io.enqData(1).poke(5)
      dut.io.enqData(2).poke(7)

      dut.io.deqReady.poke(4)

      dut.clock.step()
      dut.io.deqReady.poke(0)
      dut.io.enqValid.poke(0)
      assertResult(7) { dut.io.nEnqueued.peekInt() }

      // Flush
      dut.io.flush.poke(true)
      dut.clock.step()
      dut.clock.step()
      assertResult(0) { dut.io.nEnqueued.peekInt() }
      dut.io.flush.poke(false)
      dut.clock.step()

      // Fill buffer up to 12 items
      for (writeCount <- 0 until 3) {
        for (nIndex <- 0 until 4) {
          var indata = writeCount*4 + nIndex
          dut.io.enqData(nIndex).poke(indata)
        }
        dut.io.enqValid.poke(4)
        dut.clock.step()
      }
      assertResult(12) { dut.io.nEnqueued.peekInt() }

      // Fill buffer completely and dequeue on same cycle
      for (nIndex <- 0 until 4) {
        var indata = nIndex
        dut.io.enqData(nIndex).poke(indata)
      }
      dut.io.enqValid.poke(4)
      dut.io.deqReady.poke(4)
      dut.clock.step()
      dut.io.enqValid.poke(0)
      dut.io.deqReady.poke(0)

      assertResult(12) { dut.io.nEnqueued.peekInt() }
    }
  }

}

