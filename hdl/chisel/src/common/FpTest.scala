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

class Fp32Tester extends Module {
  val io = IO(new Bundle {
    val in     = Input(UInt(32.W))
    val is_zero = Output(Bool())
    val is_inf  = Output(Bool())
    val is_nan  = Output(Bool())
  })

  val fp = Fp32.fromWord(io.in)
  io.is_zero := fp.isZero()
  io.is_inf := fp.isInf()
  io.is_nan := fp.isNan()
}

class FpSpec extends AnyFreeSpec with ChiselScalatestTester {
  "Zero" in {
    test(new Fp32Tester()) { dut =>
      dut.io.in.poke(0.U)
      assert(dut.io.is_zero.peekInt() == 1)
      assert(dut.io.is_inf.peekInt() == 0)
      assert(dut.io.is_nan.peekInt() == 0)
    }
  }

  "Inf" in {
    test(new Fp32Tester()) { dut =>
      dut.io.in.poke(BigInt(
          "0" + "11111111" + "00000000000000000000000", 2))
      assert(dut.io.is_zero.peekInt() == 0)
      assert(dut.io.is_inf.peekInt() == 1)
      assert(dut.io.is_nan.peekInt() == 0)

      dut.io.in.poke(BigInt(
          "1" + "11111111" + "00000000000000000000000", 2))
      assert(dut.io.is_zero.peekInt() == 0)
      assert(dut.io.is_inf.peekInt() == 1)
      assert(dut.io.is_nan.peekInt() == 0)
    }
  }

  "Nan" in {
    test(new Fp32Tester()) { dut =>
      dut.io.in.poke(BigInt(
          "0" + "11111111" + "00011000011000111000100", 2))
      assert(dut.io.is_zero.peekInt() == 0)
      assert(dut.io.is_inf.peekInt() == 0)
      assert(dut.io.is_nan.peekInt() == 1)

      dut.io.in.poke(BigInt(
          "1" + "11111111" + "00011000011000111000100", 2))
      assert(dut.io.is_zero.peekInt() == 0)
      assert(dut.io.is_inf.peekInt() == 0)
      assert(dut.io.is_nan.peekInt() == 1)
    }
  }
}