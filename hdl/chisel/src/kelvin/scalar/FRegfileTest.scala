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

package kelvin

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._

import common.Fp32

class FRegfileSpec extends AnyFreeSpec with ChiselScalatestTester {
  val p = new Parameters
  "Initialization" in {
    test(new FRegfile(p, 1, 1)) { dut =>
      assertResult(0) { dut.io.scoreboard.peekInt() }
      for (i <- 0 until 32) {
        dut.io.read_ports(0).valid.poke(true.B)
        dut.io.read_ports(0).addr.poke(i)
        assertResult(0) { dut.io.read_ports(0).data.sign.peekInt() }
        assertResult(0) { dut.io.read_ports(0).data.exponent.peekInt() }
        assertResult(0) { dut.io.read_ports(0).data.mantissa.peekInt() }
      }
    }
  }

  "Basic read/write" in {
    test(new FRegfile(p, 1, 1)) { dut =>
      for (i <- 0 until 32) {
        dut.io.scoreboard_set.poke((BigInt(1) << i).U)
        dut.clock.step()
        dut.io.write_ports(0).valid.poke(true.B)
        dut.io.write_ports(0).addr.poke(i)
        dut.io.write_ports(0).data.sign.poke(0)
        dut.io.write_ports(0).data.exponent.poke(i+127)
        dut.io.write_ports(0).data.mantissa.poke(0)
        dut.clock.step()
      }

      for (i <- 0 until 32) {
        dut.io.read_ports(0).valid.poke(true.B)
        dut.io.read_ports(0).addr.poke(i)
        assertResult(0) { dut.io.read_ports(0).data.sign.peekInt() }
        assertResult(i+127) { dut.io.read_ports(0).data.exponent.peekInt() }
        assertResult(0) { dut.io.read_ports(0).data.mantissa.peekInt() }
      }
    }
  }

  "Multiread" in {
    test(new FRegfile(p, 2, 1)) { dut =>
      for (i <- 0 until 32) {
        dut.io.scoreboard_set.poke((BigInt(1) << i).U)
        dut.clock.step()
        dut.io.write_ports(0).valid.poke(true.B)
        dut.io.write_ports(0).addr.poke(i)
        dut.io.write_ports(0).data.sign.poke(0)
        dut.io.write_ports(0).data.exponent.poke(i+127)
        dut.io.write_ports(0).data.mantissa.poke(0)
        dut.clock.step()
      }

      dut.io.write_ports(0).valid.poke(false.B)

      dut.io.read_ports(0).valid.poke(true.B)
      dut.io.read_ports(0).addr.poke(0)
      assertResult(0) { dut.io.read_ports(0).data.sign.peekInt() }
      assertResult(127) { dut.io.read_ports(0).data.exponent.peekInt() }
      assertResult(0) { dut.io.read_ports(0).data.mantissa.peekInt() }

      dut.io.read_ports(1).valid.poke(true.B)
      dut.io.read_ports(1).addr.poke(20)
      assertResult(0) { dut.io.read_ports(1).data.sign.peekInt() }
      assertResult(147) { dut.io.read_ports(1).data.exponent.peekInt() }
      assertResult(0) { dut.io.read_ports(1).data.mantissa.peekInt() }
    }
  }

  "Multiwrite" in {
    test(new FRegfile(p, 2, 2)) { dut =>
      for (i <- 0 until 32) {
        dut.io.scoreboard_set.poke((BigInt(1) << i).U)
        dut.clock.step()
        dut.io.write_ports(0).valid.poke(true.B)
        dut.io.write_ports(0).addr.poke(i)
        dut.io.write_ports(0).data.sign.poke(0)
        dut.io.write_ports(0).data.exponent.poke(0)
        dut.io.write_ports(0).data.mantissa.poke(0)
        dut.clock.step()
      }

      dut.io.scoreboard_set.poke((BigInt(1) << 3).U)
      dut.clock.step()
      dut.io.write_ports(0).valid.poke(true.B)
      dut.io.write_ports(0).addr.poke(3)
      dut.io.write_ports(0).data.sign.poke(0)
      dut.io.write_ports(0).data.exponent.poke(37)
      dut.io.write_ports(0).data.mantissa.poke(44)

      dut.io.scoreboard_set.poke((BigInt(1) << 12).U)
      dut.clock.step()
      dut.io.write_ports(1).valid.poke(true.B)
      dut.io.write_ports(1).addr.poke(12)
      dut.io.write_ports(1).data.sign.poke(0)
      dut.io.write_ports(1).data.exponent.poke(14)
      dut.io.write_ports(1).data.mantissa.poke(560)

      dut.clock.step()

      dut.io.read_ports(0).valid.poke(true.B)
      dut.io.read_ports(0).addr.poke(3)
      assertResult(0) { dut.io.read_ports(0).data.sign.peekInt() }
      assertResult(37) { dut.io.read_ports(0).data.exponent.peekInt() }
      assertResult(44) { dut.io.read_ports(0).data.mantissa.peekInt() }

      dut.io.read_ports(1).valid.poke(true.B)
      dut.io.read_ports(1).addr.poke(12)
      assertResult(0) { dut.io.read_ports(1).data.sign.peekInt() }
      assertResult(14) { dut.io.read_ports(1).data.exponent.peekInt() }
      assertResult(560) { dut.io.read_ports(1).data.mantissa.peekInt() }
    }
  }

  "Scoreboard" in {
    test(new FRegfile(p, 1, 2)) { dut =>
      assertResult(0) { dut.io.scoreboard.peekInt() }
      dut.io.scoreboard_set.poke(31)
      dut.clock.step()
      assertResult(31) { dut.io.scoreboard.peekInt() }

      // Clear the two LSBs
      dut.io.scoreboard_set.poke(0)
      dut.io.write_ports(0).valid.poke(true.B)
      dut.io.write_ports(0).addr.poke(0)
      dut.io.write_ports(1).valid.poke(true.B)
      dut.io.write_ports(1).addr.poke(1)
      dut.clock.step()
      assertResult(28) { dut.io.scoreboard.peekInt() }

      // Clear the two entries and set 1 in the same cycle
      dut.io.scoreboard_set.poke(1)
      dut.io.write_ports(0).valid.poke(true.B)
      dut.io.write_ports(0).addr.poke(2)
      dut.io.write_ports(1).valid.poke(true.B)
      dut.io.write_ports(1).addr.poke(3)
      dut.clock.step()
      assertResult(17) { dut.io.scoreboard.peekInt() }
    }
  }

  "Multiwrite Exception" in {
    test(new FRegfile(p, 2, 2)) { dut =>
      for (i <- 0 until 32) {
        dut.io.scoreboard_set.poke((BigInt(1) << i).U)
        dut.clock.step()
        dut.io.write_ports(0).valid.poke(true.B)
        dut.io.write_ports(0).addr.poke(i)
        dut.io.write_ports(0).data.sign.poke(0)
        dut.io.write_ports(0).data.exponent.poke(0)
        dut.io.write_ports(0).data.mantissa.poke(0)
        dut.clock.step()
      }

      dut.io.write_ports(0).valid.poke(true.B)
      dut.io.write_ports(0).addr.poke(3)
      dut.io.write_ports(0).data.sign.poke(0)
      dut.io.write_ports(0).data.exponent.poke(37)
      dut.io.write_ports(0).data.mantissa.poke(44)

      dut.io.write_ports(1).valid.poke(true.B)
      dut.io.write_ports(1).addr.poke(3)
      dut.io.write_ports(1).data.sign.poke(0)
      dut.io.write_ports(1).data.exponent.poke(14)
      dut.io.write_ports(1).data.mantissa.poke(560)

      assertResult(1) { dut.io.exception.peekInt() }
    }
  }
}
