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
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.freespec.AnyFreeSpec

class InstructionBufferSpec extends AnyFreeSpec with ChiselSim {
  "InstructionBufferSlice Fill Empty" in {
    simulate(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      for (n <- 0 to 4) {
        // Reset
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)

        // Next slice isn't requesting data, module should request all the data
        dut.io.feedOut.nReady.poke(0)
        dut.io.feedIn.nReady.expect(4)

        // Feed in 0-4 elements
        dut.io.feedIn.nValid.poke(n)
        for (i <- 0 until n) {
          dut.io.feedIn.bits(i).poke(42 + i)
        }
        dut.io.feedOut.nValid.expect(0)

        dut.clock.step()
        for (i <- 0 until 4) {
          if (i < n) {
            dut.io.out(i).valid.expect(1)
            dut.io.out(i).bits.expect(42 + i)
          } else {
            dut.io.out(i).valid.expect(0)
          }
        }
      }
    }
  }

  "InstructionBufferSlice Pass-Through" in {
    simulate(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      for (n <- 0 to 4) {
        // Reset
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)

        // Pull as much data as possible
        dut.io.feedOut.nReady.poke(4)
        dut.io.feedIn.nReady.expect(4)

        // Feed in 0-4 elements
        dut.io.feedIn.nValid.poke(n)
        for (i <- 0 until n) {
          dut.io.feedIn.bits(i).poke(84 + i)
        }
        dut.io.feedOut.nValid.expect(n)
        for (i <- 0 until n) {
          dut.io.feedOut.bits(i).expect(84 + i)
        }

        // Check values were not enqueued
        dut.clock.step()
        for (i <- 0 until 4) {
          dut.io.out(i).valid.expect(0)
        }
      }
    }
  }

  "InstructionBufferSlice Remove" in {
    simulate(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
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
          dut.io.out(i).valid.expect(1)
      }
      dut.io.out(0).bits.expect(30)
      dut.io.out(1).bits.expect(32)
      dut.io.out(2).bits.expect(33)
      dut.io.out(3).valid.expect(0)
    }
  }

  "InstructionBufferSlice Split Input" in {
    simulate(new InstructionBufferSlice(UInt(16.W), 4)) { dut =>
      // Enqueue two elements
      dut.io.feedOut.nReady.poke(0)
      dut.io.feedIn.nValid.poke(2)
      dut.io.feedIn.bits(0).poke(101)
      dut.io.feedIn.bits(1).poke(102)
      dut.clock.step()
      dut.io.out(0).valid.expect(1)
      dut.io.out(0).bits.expect(101)
      dut.io.out(1).valid.expect(1)
      dut.io.out(1).bits.expect(102)
      dut.io.out(2).valid.expect(0)
      dut.io.out(3).valid.expect(0)

      // Enqueue 4 elements, check that feedOut takes them in FIFO order
      dut.io.feedOut.nReady.poke(4)
      dut.io.feedIn.nReady.expect(4)
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(201)
      dut.io.feedIn.bits(1).poke(202)
      dut.io.feedIn.bits(2).poke(203)
      dut.io.feedIn.bits(3).poke(204)
      dut.io.feedOut.nValid.expect(4)
      dut.io.feedOut.bits(0).expect(101)
      dut.io.feedOut.bits(1).expect(102)
      dut.io.feedOut.bits(2).expect(201)
      dut.io.feedOut.bits(3).expect(202)

      // Check two elements remaining in next cycle
      dut.clock.step()
      dut.io.out(0).valid.expect(1)
      dut.io.out(0).bits.expect(203)
      dut.io.out(1).valid.expect(1)
      dut.io.out(1).bits.expect(204)
      dut.io.out(2).valid.expect(0)
      dut.io.out(3).valid.expect(0)
    }
  }

  "InstructionBufferSlice Flush" in {
    simulate(new InstructionBufferSlice(UInt(16.W), 4, true)) { dut =>
      dut.io.feedOut.nReady.poke(0)
      dut.io.feedIn.nValid.poke(4)
      for (i <- 0 until 4) {
        dut.io.feedIn.bits(i).poke(30 + i)
      }
      dut.clock.step()
      dut.io.feedIn.nValid.poke(0)
      dut.io.flush.get.poke(1)
      dut.clock.step()
      for (i <- 0 until 4) {
          dut.io.out(i).valid.expect(0)
      }
    }
  }

  "InstructionBuffer Fill" in {
    simulate(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(500)
      dut.io.feedIn.bits(1).poke(501)
      dut.io.feedIn.bits(2).poke(502)
      dut.io.feedIn.bits(3).poke(503)
      dut.clock.step()
      for (i <- 0 until 4) {
        dut.io.out(i).valid.expect(1)
        dut.io.out(i).bits.expect(500 + i)
      }
      for (i <- 4 until 12) {
        dut.io.out(i).valid.expect(0)
      }
      dut.io.feedIn.nReady.expect(4)
      dut.io.feedIn.bits(0).poke(504)
      dut.io.feedIn.bits(1).poke(505)
      dut.io.feedIn.bits(2).poke(506)
      dut.io.feedIn.bits(3).poke(507)
      dut.clock.step()
      for (i <- 0 until 8) {
        dut.io.out(i).valid.expect(1)
        dut.io.out(i).bits.expect(500 + i)
      }
      for (i <- 8 until 12) {
        dut.io.out(i).valid.expect(0)
      }
      dut.io.feedIn.nReady.expect(4)
      dut.io.feedIn.bits(0).poke(508)
      dut.io.feedIn.bits(1).poke(509)
      dut.io.feedIn.bits(2).poke(510)
      dut.io.feedIn.bits(3).poke(511)
      dut.clock.step()
      for (i <- 0 until dut.io.out.length) {
        dut.io.out(i).valid.expect(1)
        dut.io.out(i).bits.expect(500 + i)
      }
      dut.io.feedIn.nReady.expect(0)
    }
  }

  "InstructionBuffer Remove" in {
    simulate(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
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
        dut.io.out(i).valid.expect(1)
      }
      for (i <- 8 until 12) {
        dut.io.out(i).valid.expect(0)
      }

      // Check 1, 5, 6 and 10 are not present
      dut.io.out(0).bits.expect(500)
      dut.io.out(1).bits.expect(502)
      dut.io.out(2).bits.expect(503)
      dut.io.out(3).bits.expect(504)
      dut.io.out(4).bits.expect(507)
      dut.io.out(5).bits.expect(508)
      dut.io.out(6).bits.expect(509)
      dut.io.out(7).bits.expect(511)
    }
  }

  "InstructionBuffer Add and Remove" in {
    simulate(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
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
        dut.io.out(i).valid.expect(1)
      }
      for (i <- 5 until 12) {
        dut.io.out(i).valid.expect(0)
      }

      dut.io.out(0).bits.expect(300)
      dut.io.out(1).bits.expect(303)
      dut.io.out(2).bits.expect(400)
      dut.io.out(3).bits.expect(401)
      dut.io.out(4).bits.expect(402)
    }
  }

  "InstructionBuffer Add and Remove Max Capacity" in {
    simulate(new InstructionBuffer(UInt(16.W), 4, 12)) { dut =>
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
      dut.io.feedIn.nReady.expect(4)
      dut.io.feedIn.bits(0).poke(100)
      dut.io.feedIn.bits(1).poke(101)
      dut.io.feedIn.bits(2).poke(102)
      dut.io.feedIn.bits(3).poke(103)
      dut.clock.step()

      for (i <- 0 until 12) {
        dut.io.out(i).valid.expect(1)
      }

      dut.io.out(0).bits.expect(300)
      dut.io.out(1).bits.expect(303)
      dut.io.out(2).bits.expect(304)
      dut.io.out(3).bits.expect(305)
      dut.io.out(4).bits.expect(307)
      dut.io.out(5).bits.expect(308)
      dut.io.out(6).bits.expect(309)
      dut.io.out(7).bits.expect(310)
      dut.io.out(8).bits.expect(100)
      dut.io.out(9).bits.expect(101)
      dut.io.out(10).bits.expect(102)
      dut.io.out(11).bits.expect(103)
    }
  }

  "InstructionBuffer Flush" in {
    simulate(new InstructionBuffer(UInt(16.W), 4, 12, true)) { dut =>
      dut.io.feedIn.nValid.poke(4)
      dut.io.feedIn.bits(0).poke(500)
      dut.io.feedIn.bits(1).poke(501)
      dut.io.feedIn.bits(2).poke(502)
      dut.io.feedIn.bits(3).poke(503)
      dut.clock.step()
      dut.io.feedIn.nValid.poke(3)
      dut.io.feedIn.bits(0).poke(900)
      dut.io.feedIn.bits(1).poke(301)
      dut.io.feedIn.bits(2).poke(102)
      dut.clock.step()

      dut.io.flush.get.poke(1)
      dut.clock.step()
      for (i <- 0 until 12) {
        dut.io.out(i).valid.expect(0)
      }
    }
  }
}