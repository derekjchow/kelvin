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
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._

class InstructionBufferSpec extends AnyFreeSpec with ChiselScalatestTester {
  "InstructionBufferSlice Fill Empty" in {
    test(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      for (n <- 0 to 4) {
        // Reset
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)

        // Next slice isn't requesting data, module should request all the data
        dut.io.feedOut.nReady.poke(0)
        assertResult(4) { dut.io.feedIn.nReady.peekInt() }

        // Feed in 0-4 elements
        dut.io.feedIn.nValid.poke(n)
        for (i <- 0 until n) {
          dut.io.feedIn.bits(i).poke(42 + i)
        }
        assertResult(0) { dut.io.feedOut.nValid.peekInt() }

        dut.clock.step()
        for (i <- 0 until 4) {
          if (i < n) {
            assertResult(1) { dut.io.out(i).valid.peekInt() }
            assertResult(42 + i) { dut.io.out(i).bits.peekInt() }
          } else {
            assertResult(0) { dut.io.out(i).valid.peekInt() }
          }
        }
      }
    }
  }

  "InstructionBufferSlice Pass-Through" in {
    test(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      for (n <- 0 to 4) {
        // Reset
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)

        // Pull as much data as possible
        dut.io.feedOut.nReady.poke(4)
        assertResult(4) { dut.io.feedIn.nReady.peekInt() }

        // Feed in 0-4 elements
        dut.io.feedIn.nValid.poke(n)
        for (i <- 0 until n) {
          dut.io.feedIn.bits(i).poke(84 + i)
        }
        assertResult(n) { dut.io.feedOut.nValid.peekInt() }
        for (i <- 0 until n) {
          assertResult(84 + i) { dut.io.feedOut.bits(i).peekInt() }
        }

        // Check values were not enqueued
        dut.clock.step()
        for (i <- 0 until 4) {
          assertResult(0) { dut.io.out(i).valid.peekInt() }
        }
      }
    }
  }

  "InstructionBufferSlice Remove" in {
    test(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      dut.io.feedOut.nReady.poke(0)
      dut.io.feedIn.nValid.poke(4)
      for (i <- 0 until 4) {
        dut.io.feedIn.bits(i).poke(30 + i)
      }
      dut.clock.step()
      dut.io.feedIn.nValid.poke(0)
      dut.io.out(1).ready.poke(1)
      dut.clock.step()

      for (i <- 0 until 3) {
          assertResult(1) { dut.io.out(i).valid.peekInt() }
      }
      assertResult(30) { dut.io.out(0).bits.peekInt() }
      assertResult(32) { dut.io.out(1).bits.peekInt() }
      assertResult(33) { dut.io.out(2).bits.peekInt() }
      assertResult(0) { dut.io.out(3).valid.peekInt() }
    }
  }

  "InstructionBufferSlice Split Input" in {
    test(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      // Enqueue two elements
      dut.io.feedOut.nReady.poke(0)
      dut.io.feedIn.nValid.poke(2)
      dut.io.feedIn.bits(0).poke(101)
      dut.io.feedIn.bits(1).poke(102)
      dut.clock.step()
      assertResult(1) { dut.io.out(0).valid.peekInt() }
      assertResult(101) { dut.io.out(0).bits.peekInt() }
      assertResult(1) { dut.io.out(1).valid.peekInt() }
      assertResult(102) { dut.io.out(1).bits.peekInt() }
      assertResult(0) { dut.io.out(2).valid.peekInt() }
      assertResult(0) { dut.io.out(3).valid.peekInt() }

      // Enqueue 4 elements, check that feedOut takes them in FIFO order
      dut.io.feedOut.nReady.poke(4)
      assertResult(4) { dut.io.feedIn.nReady.peekInt() }
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(201)
      dut.io.feedIn.bits(1).poke(202)
      dut.io.feedIn.bits(2).poke(203)
      dut.io.feedIn.bits(3).poke(204)
      assertResult(4) { dut.io.feedOut.nValid.peekInt() }
      assertResult(101) { dut.io.feedOut.bits(0).peekInt() }
      assertResult(102) { dut.io.feedOut.bits(1).peekInt() }
      assertResult(201) { dut.io.feedOut.bits(2).peekInt() }
      assertResult(202) { dut.io.feedOut.bits(3).peekInt() }

      // Check two elements remaining in next cycle
      dut.clock.step()
      assertResult(1) { dut.io.out(0).valid.peekInt() }
      assertResult(203) { dut.io.out(0).bits.peekInt() }
      assertResult(1) { dut.io.out(1).valid.peekInt() }
      assertResult(204) { dut.io.out(1).bits.peekInt() }
      assertResult(0) { dut.io.out(2).valid.peekInt() }
      assertResult(0) { dut.io.out(3).valid.peekInt() }
    }
  }

  "InstructionBuffer Fill" in {
    test(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(500)
      dut.io.feedIn.bits(1).poke(501)
      dut.io.feedIn.bits(2).poke(502)
      dut.io.feedIn.bits(3).poke(503)
      dut.clock.step()
      for (i <- 0 until 4) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
        assertResult(500 + i) { dut.io.out(i).bits.peekInt() }
      }
      for (i <- 4 until 12) {
        assertResult(0) { dut.io.out(i).valid.peekInt() }
      }
      assertResult(4) { dut.io.feedIn.nReady.peekInt() }
      dut.io.feedIn.bits(0).poke(504)
      dut.io.feedIn.bits(1).poke(505)
      dut.io.feedIn.bits(2).poke(506)
      dut.io.feedIn.bits(3).poke(507)
      dut.clock.step()
      for (i <- 0 until 8) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
        assertResult(500 + i) { dut.io.out(i).bits.peekInt() }
      }
      for (i <- 8 until 12) {
        assertResult(0) { dut.io.out(i).valid.peekInt() }
      }
      assertResult(4) { dut.io.feedIn.nReady.peekInt() }
      dut.io.feedIn.bits(0).poke(508)
      dut.io.feedIn.bits(1).poke(509)
      dut.io.feedIn.bits(2).poke(510)
      dut.io.feedIn.bits(3).poke(511)
      dut.clock.step()
      for (i <- 0 until dut.io.out.length) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
        assertResult(500 + i) { dut.io.out(i).bits.peekInt() }
      }
      assertResult(0) { dut.io.feedIn.nReady.peekInt() }
    }
  }

  "InstructionBuffer Remove" in {
    test(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(500)
      dut.io.feedIn.bits(1).poke(501)
      dut.io.feedIn.bits(2).poke(502)
      dut.io.feedIn.bits(3).poke(503)
      dut.clock.step()
      dut.io.feedIn.bits(0).poke(504)
      dut.io.feedIn.bits(1).poke(505)
      dut.io.feedIn.bits(2).poke(506)
      dut.io.feedIn.bits(3).poke(507)
      dut.clock.step()
      dut.io.feedIn.bits(0).poke(508)
      dut.io.feedIn.bits(1).poke(509)
      dut.io.feedIn.bits(2).poke(510)
      dut.io.feedIn.bits(3).poke(511)
      dut.clock.step()

      // Remove 1, 5, 6 and 10
      dut.io.feedIn.nValid.poke(0)
      dut.io.out(1).ready.poke(1)
      dut.io.out(5).ready.poke(1)
      dut.io.out(6).ready.poke(1)
      dut.io.out(10).ready.poke(1)
      dut.clock.step()

      for (i <- 0 until 8) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
      }
      for (i <- 8 until 12) {
        assertResult(0) { dut.io.out(i).valid.peekInt() }
      }

      // Check 1, 5, 6 and 10 are not present
      assertResult(500) { dut.io.out(0).bits.peekInt() }
      assertResult(502) { dut.io.out(1).bits.peekInt() }
      assertResult(503) { dut.io.out(2).bits.peekInt() }
      assertResult(504) { dut.io.out(3).bits.peekInt() }
      assertResult(507) { dut.io.out(4).bits.peekInt() }
      assertResult(508) { dut.io.out(5).bits.peekInt() }
      assertResult(509) { dut.io.out(6).bits.peekInt() }
      assertResult(511) { dut.io.out(7).bits.peekInt() }
    }
  }

  "InstructionBuffer Add and Remove" in {
    test(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(300)
      dut.io.feedIn.bits(1).poke(301)
      dut.io.feedIn.bits(2).poke(302)
      dut.io.feedIn.bits(3).poke(303)
      dut.clock.step()

      // Remove 1 and 2
      dut.io.out(1).ready.poke(1)
      dut.io.out(2).ready.poke(1)

      // Add 3 elements
      dut.io.feedIn.nValid.poke(3)
      dut.io.feedIn.bits(0).poke(400)
      dut.io.feedIn.bits(1).poke(401)
      dut.io.feedIn.bits(2).poke(402)

      dut.clock.step()

      for (i <- 0 until 5) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
      }
      for (i <- 5 until 12) {
        assertResult(0) { dut.io.out(i).valid.peekInt() }
      }

      assertResult(300) { dut.io.out(0).bits.peekInt() }
      assertResult(303) { dut.io.out(1).bits.peekInt() }
      assertResult(400) { dut.io.out(2).bits.peekInt() }
      assertResult(401) { dut.io.out(3).bits.peekInt() }
      assertResult(402) { dut.io.out(4).bits.peekInt() }
    }
  }

  "InstructionBuffer Add and Remove Max Capacity" in {
    test(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(300)
      dut.io.feedIn.bits(1).poke(301)
      dut.io.feedIn.bits(2).poke(302)
      dut.io.feedIn.bits(3).poke(303)
      dut.clock.step()
      dut.io.feedIn.bits(0).poke(304)
      dut.io.feedIn.bits(1).poke(305)
      dut.io.feedIn.bits(2).poke(306)
      dut.io.feedIn.bits(3).poke(307)
      dut.clock.step()
      dut.io.feedIn.bits(0).poke(308)
      dut.io.feedIn.bits(1).poke(309)
      dut.io.feedIn.bits(2).poke(310)
      dut.io.feedIn.bits(3).poke(311)
      dut.clock.step()

      // Remove 1, 2, 6, 11
      dut.io.out(1).ready.poke(1)
      dut.io.out(2).ready.poke(1)
      dut.io.out(6).ready.poke(1)
      dut.io.out(11).ready.poke(1)

      // Even if buffer is at capacity, accept more to fill evicting
      assertResult(4) { dut.io.feedIn.nReady.peekInt() }
      dut.io.feedIn.bits(0).poke(100)
      dut.io.feedIn.bits(1).poke(101)
      dut.io.feedIn.bits(2).poke(102)
      dut.io.feedIn.bits(3).poke(103)
      dut.clock.step()

      for (i <- 0 until 12) {
        assertResult(1) { dut.io.out(i).valid.peekInt() }
      }

      assertResult(300) { dut.io.out(0).bits.peekInt() }
      assertResult(303) { dut.io.out(1).bits.peekInt() }
      assertResult(304) { dut.io.out(2).bits.peekInt() }
      assertResult(305) { dut.io.out(3).bits.peekInt() }
      assertResult(307) { dut.io.out(4).bits.peekInt() }
      assertResult(308) { dut.io.out(5).bits.peekInt() }
      assertResult(309) { dut.io.out(6).bits.peekInt() }
      assertResult(310) { dut.io.out(7).bits.peekInt() }
      assertResult(100) { dut.io.out(8).bits.peekInt() }
      assertResult(101) { dut.io.out(9).bits.peekInt() }
      assertResult(102) { dut.io.out(10).bits.peekInt() }
      assertResult(103) { dut.io.out(11).bits.peekInt() }
    }
  }
}