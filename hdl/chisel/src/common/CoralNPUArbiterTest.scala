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
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.freespec.AnyFreeSpec

class CoralNPUArbiterSpec extends AnyFreeSpec with ChiselSim {
  "CoralNPUArbiter" in {
    simulate(new CoralNPURRArbiter(UInt(32.W), 2)) { dut =>
      dut.io.in(0).valid.poke(false)
      dut.io.in(0).bits.poke(42.U)
      dut.io.in(1).valid.poke(false)
      dut.io.in(1).bits.poke(142.U)

      dut.io.out.valid.expect(0)

      // Input 0 only
      dut.io.in(0).valid.poke(true)
      dut.io.out.valid.expect(1)
      dut.io.out.bits.expect(42)
      dut.io.chosen.expect(0)
      dut.io.out.ready.poke(false)
      dut.io.in(0).ready.expect(0)
      dut.io.in(1).ready.expect(0)
      dut.io.out.ready.poke(true)
      dut.io.in(0).ready.expect(1)

      // Input 1 only
      dut.io.in(0).valid.poke(false)
      dut.io.in(1).valid.poke(true)
      dut.io.out.valid.expect(1)
      dut.io.out.bits.expect(142)
      dut.io.chosen.expect(1)
      dut.io.out.ready.poke(false)
      dut.io.in(0).ready.expect(0)
      dut.io.in(1).ready.expect(0)
      dut.io.out.ready.poke(true)
      dut.io.in(1).ready.expect(1)

      // Both inputs, locks to 1 first cycle as 0 was lastGrant
      dut.io.in(0).valid.poke(true)
      dut.io.out.valid.expect(1)
      dut.io.out.bits.expect(142)
      dut.io.chosen.expect(1)
      dut.io.out.ready.poke(false)
      dut.io.in(0).ready.expect(0)
      dut.io.in(1).ready.expect(0)
      dut.io.out.ready.poke(true)
      dut.io.in(0).ready.expect(0)
      dut.io.in(1).ready.expect(1)

      // Move to next cycle, should lock to 0 as 1 was lastGrant
      dut.clock.step()
      dut.io.out.valid.expect(1)
      dut.io.out.bits.expect(42)
      dut.io.chosen.expect(0)
      dut.io.out.ready.poke(false)
      dut.io.in(0).ready.expect(0)
      dut.io.in(1).ready.expect(0)
      dut.io.out.ready.poke(true)
      dut.io.in(0).ready.expect(1)
      dut.io.in(1).ready.expect(0)
    }
  }
}
