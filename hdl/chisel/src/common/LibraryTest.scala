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

class Zip32Tester extends Module {
  val io = IO(new Bundle {
    val sz  = Input(UInt(3.W))
    val a   = Input(UInt(32.W))
    val b   = Input(UInt(32.W))
    val out = Output(UInt(64.W))
  })

  io.out := Zip32(io.sz, io.a, io.b)
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

  "Zip32 Words" in {
    test(new Zip32Tester) { dut =>
      dut.io.sz.poke(4)
      dut.io.a.poke(5)
      dut.io.b.poke(3163)
      assertResult((3163L << 32L) | 5) { dut.io.out.peekInt() }
    }
  }

  "Zip32 Halves" in {
    test(new Zip32Tester) { dut =>
      dut.io.sz.poke(2)
      dut.io.a.poke((7L << 16L) | 3)
      dut.io.b.poke((11L << 16L) | 5)
      assertResult((11L << 48L) | (7L << 32L) | (5L << 16L) | 3L) {
        dut.io.out.peekInt()
      }
    }
  }

  "Zip32 Bytes" in {
    test(new Zip32Tester) { dut =>
      dut.io.sz.poke(1)
      dut.io.a.poke((37L << 16L) | (7L << 8L) | 3)
      dut.io.b.poke((43L << 16L) | (11L << 8L) | 5)
      assertResult((43L << 40L) | (37L << 32L) | (11L << 24L) | (7L << 16L) | (5L << 8L) | 3L) {
        dut.io.out.peekInt()
      }
    }
  }
}
