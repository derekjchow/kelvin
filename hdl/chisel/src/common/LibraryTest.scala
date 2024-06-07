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

class ForceZeroTester extends Module {
  val io = IO(new Bundle {
    val in  = Input(Valid(SInt(32.W)))
    val out = Output(Valid(SInt(32.W)))
  })

  io.out := ForceZero(io.in)
}

class LibrarySpec extends AnyFreeSpec with ChiselScalatestTester {
  "ForceZero when invalid" in {
    test(new ForceZeroTester) { dut =>
      dut.io.in.bits.poke(9001)
      dut.io.in.valid.poke(0)
      dut.clock.step()
      assertResult(0) { dut.io.out.bits.peekInt() }
    }
  }

  "ForceZeroForceZero propogates when valid" in {
    test(new ForceZeroTester) { dut =>
      dut.io.in.bits.poke(9001)
      dut.io.in.valid.poke(1)
      dut.clock.step()
      assertResult(9001) { dut.io.out.bits.peekInt() }
    }
  }
}
