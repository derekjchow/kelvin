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

class FpuTester extends Module {
  val io = IO(new Bundle {
    val ina    = Input(UInt(32.W))
    val inb    = Input(UInt(32.W))
    val op     = Input(FpuOp())
    val out    = Output(new Fp32)
  })

  val fp_a = Fp32.fromWord(io.ina)
  val fp_b = Fp32.fromWord(io.inb)

  val cmd = Wire(new FpuCmd)
  cmd.ina := fp_a
  cmd.inb := fp_b
  cmd.op := io.op

  val stage1 = Fpu.FpuStage1(cmd)
  io.out := Fpu.FpuStage2(stage1)
}

class FpuSpec extends AnyFreeSpec with ChiselScalatestTester {
  def Float2BigInt(x: Float): BigInt = {
    val abs = x.abs
    var int = BigInt(java.lang.Float.floatToIntBits(abs))
    if (x < 0) {
      int += (BigInt(1) << 31)
    }
    int
  }

  "Zero" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(0))
      dut.io.inb.poke(Float2BigInt(42))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(0) { dut.io.out.exponent.peekInt() }
      assertResult(0) { dut.io.out.mantissa.peekInt() }
    }
  }

  "Identity" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(1))
      dut.io.inb.poke(Float2BigInt(42))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(132) { dut.io.out.exponent.peekInt() }
      assertResult(2621440) { dut.io.out.mantissa.peekInt() }
    }
  }

  "Negative" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(-1.0f))
      dut.io.inb.poke(Float2BigInt(42))
      assertResult(1) { dut.io.out.sign.peekInt() }
      assertResult(132) { dut.io.out.exponent.peekInt() }
      assertResult(2621440) { dut.io.out.mantissa.peekInt() }
    }
  }

  "Half" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(0.5f))
      dut.io.inb.poke(Float2BigInt(42))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(131) { dut.io.out.exponent.peekInt() }
      assertResult(2621440) { dut.io.out.mantissa.peekInt() }
    }
  }

  "Overflow" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(2e30f))
      dut.io.inb.poke(Float2BigInt(2e30f))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(255) { dut.io.out.exponent.peekInt() }
      assertResult(0) { dut.io.out.mantissa.peekInt() }
    }
  }

  "Rounds to Zero" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(1e-30f))
      dut.io.inb.poke(Float2BigInt(1e-30f))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(0) { dut.io.out.exponent.peekInt() }
      assertResult(0) { dut.io.out.mantissa.peekInt() }
    }
  }

  "NaN" in {
    test(new FpuTester()) { dut =>
      dut.io.op.poke(FpuOp.FpuMul)
      dut.io.ina.poke(Float2BigInt(Float.NaN))
      dut.io.inb.poke(Float2BigInt(4.0f))
      assertResult(0) { dut.io.out.sign.peekInt() }
      assertResult(255) { dut.io.out.exponent.peekInt() }
      assert(dut.io.out.mantissa.peekInt() != 0)
    }
  }
}