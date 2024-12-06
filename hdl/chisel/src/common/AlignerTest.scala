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
import chisel3.util._
import org.scalatest.freespec.AnyFreeSpec
import scala.util.Random

class AlignerTester[T <: Data](t: T, n: Int) extends Module {
    val io = IO(new Bundle {
        val in = Input(Vec(n, Valid(t)))
        val out = Output(Vec(n, Valid(t)))
    })
    val aligner = Module(new Aligner(t, n))
    for (i <- 0 until n) {
        aligner.io.in(i).valid := io.in(i).valid
        aligner.io.in(i).bits := io.in(i).bits.asUInt

        io.out(i).valid := aligner.io.out(i).valid
        io.out(i).bits := aligner.io.out(i).bits.asTypeOf(t)
    }
}

class AlignerSpec extends AnyFreeSpec with ChiselSim {
    "Basic" in {
        val n = 4
        simulate (new AlignerTester(UInt(32.W), n)) { dut =>
            for (i <- 0 until 1000) {
                var valid_in_count: BigInt = 0
                for (i <- 0 until n) {
                    val valid_in = Random.between(0, 2)
                    dut.io.in(i).valid.poke(valid_in)
                    valid_in_count += valid_in

                    val data_in = Random.between(0, Math.pow(2, 32)).toInt
                    dut.io.in(i).bits.poke(data_in)
                }

                var valid_out_count: BigInt = 0
                for (i <- 0 until n) {
                    valid_out_count += dut.io.out(i).valid.peek().litValue
                }
                assertResult(true) { valid_in_count == valid_out_count }

                var outIdx = 0
                for (i <- 0 until n) {
                    val valid_in = dut.io.in(i).valid.peek().litValue
                    val data_in = dut.io.in(i).bits.peek().litValue
                    val data_out = dut.io.out(outIdx).bits.peek().litValue
                    if (valid_in == 1) {
                        assertResult(true) { data_in == data_out }
                        outIdx = outIdx + 1
                    }
                }
            }
        }
    }

    "Bundle" in {
        val n = 4
        class bundleT extends Bundle {
            val a = UInt(32.W)
            val b = UInt(5.W)
            val c = UInt(12.W)
        }
        simulate (new AlignerTester(new bundleT, n)) { dut =>
            for (i <- 0 until 1000) {
                var valid_in_count: BigInt = 0
                for (i <- 0 until n) {
                    val valid_in = Random.between(0, 2)
                    dut.io.in(i).valid.poke(valid_in)
                    valid_in_count += valid_in

                    dut.io.in(i).bits.a.poke(Random.between(0, Math.pow(2, dut.io.in(i).bits.a.getWidth)).toInt)
                    dut.io.in(i).bits.b.poke(Random.between(0, Math.pow(2, dut.io.in(i).bits.b.getWidth)).toInt)
                    dut.io.in(i).bits.c.poke(Random.between(0, Math.pow(2, dut.io.in(i).bits.c.getWidth)).toInt)
                }

                var valid_out_count: BigInt = 0
                for (i <- 0 until n) {
                    valid_out_count += dut.io.out(i).valid.peek().litValue
                }
                assertResult(true) { valid_in_count == valid_out_count }

                var outIdx = 0
                for (i <- 0 until n) {
                    val valid_in = dut.io.in(i).valid.peek().litValue
                    if (valid_in == 1) {
                        assertResult(dut.io.in(i).bits.a.peek().litValue) { dut.io.out(outIdx).bits.a.peek().litValue }
                        assertResult(dut.io.in(i).bits.b.peek().litValue) { dut.io.out(outIdx).bits.b.peek().litValue }
                        assertResult(dut.io.in(i).bits.c.peek().litValue) { dut.io.out(outIdx).bits.c.peek().litValue }
                        outIdx = outIdx + 1
                    }
                }
            }
        }
    }
}