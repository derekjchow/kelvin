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

class KelvinArbiterSpec extends AnyFreeSpec with ChiselScalatestTester {
  "KelvinArbiter" in {
    test(new KelvinRRArbiter(UInt(32.W), 2)) { dut =>
      dut.io.in(0).valid.poke(0.U)
      dut.io.in(0).bits.poke(42.U)
      dut.io.in(1).valid.poke(0.U)
      dut.io.in(1).bits.poke(142.U)

      assert(dut.io.out.valid.peekInt() == 0)

      // Input 0 only
      dut.io.in(0).valid.poke(1.U)
      assert(dut.io.out.valid.peekInt() == 1)
      assert(dut.io.out.bits.peekInt() == 42)
      assert(dut.io.chosen.peekInt() == 0)
      dut.io.out.ready.poke(0.U)
      assert(dut.io.in(0).ready.peekInt() == 0)
      assert(dut.io.in(1).ready.peekInt() == 0)
      dut.io.out.ready.poke(1.U)
      assert(dut.io.in(0).ready.peekInt() == 1)

      // Input 1 only
      dut.io.in(0).valid.poke(0.U)
      dut.io.in(1).valid.poke(1.U)
      assert(dut.io.out.valid.peekInt() == 1)
      assert(dut.io.out.bits.peekInt() == 142)
      assert(dut.io.chosen.peekInt() == 1)
      dut.io.out.ready.poke(0.U)
      assert(dut.io.in(0).ready.peekInt() == 0)
      assert(dut.io.in(1).ready.peekInt() == 0)
      dut.io.out.ready.poke(1.U)
      assert(dut.io.in(1).ready.peekInt() == 1)

      // Both inputs, locks to 1 first cycle as 0 was lastGrant
      dut.io.in(0).valid.poke(1.U)
      assert(dut.io.out.valid.peekInt() == 1)
      assert(dut.io.out.bits.peekInt() == 142)
      assert(dut.io.chosen.peekInt() == 1)
      dut.io.out.ready.poke(0.U)
      assert(dut.io.in(0).ready.peekInt() == 0)
      assert(dut.io.in(1).ready.peekInt() == 0)
      dut.io.out.ready.poke(1.U)
      assert(dut.io.in(0).ready.peekInt() == 0)
      assert(dut.io.in(1).ready.peekInt() == 1)

      // Move to next cycle, should lock to 0 as 1 was lastGrant
      dut.clock.step()
      assert(dut.io.out.valid.peekInt() == 1)
      assert(dut.io.out.bits.peekInt() == 42)
      assert(dut.io.chosen.peekInt() == 0)
      dut.io.out.ready.poke(0.U)
      assert(dut.io.in(0).ready.peekInt() == 0)
      assert(dut.io.in(1).ready.peekInt() == 0)
      dut.io.out.ready.poke(1.U)
      assert(dut.io.in(0).ready.peekInt() == 1)
      assert(dut.io.in(1).ready.peekInt() == 0)
    }
  }
}
