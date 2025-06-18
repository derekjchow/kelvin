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

class GatherTester extends Module {
  val io = IO(new Bundle {
    val indices  = Input(Vec(16, UInt(4.W)))
    val data  = Input(Vec(16, UInt(8.W)))
    val out = Output(Vec(16, UInt(8.W)))
  })

  io.out := Gather(io.indices, io.data)
}

class ScatterTester extends Module {
  val io = IO(new Bundle {
    val indicesValid = Input(Vec(16, Bool()))
    val indices = Input(Vec(16, UInt(4.W)))
    val data = Input(Vec(16, UInt(8.W)))

    val indicesSelected = Output(Vec(16, Bool()))
    val writeMask = Output(Vec(16, Bool()))
    val outData = Output(Vec(16, UInt(8.W)))

    val maskCount = Output(UInt(5.W))
  })

  val (result, writeMask, indicesSelected) = Scatter(
      io.indicesValid, io.indices, io.data)

  io.indicesSelected := indicesSelected
  io.writeMask := writeMask
  io.outData := result
  io.maskCount := PopCount(writeMask)
}

class GatherSpec extends AnyFreeSpec with ChiselSim {
  "Random Test" in {
    simulate(new GatherTester) { dut =>
      for (_ <- 0 until 100) {
        // Set inputs
        val indices = Seq.fill(16)(Random.between(0, 16))
        val data = Seq.fill(16)(Random.between(0, 256))
        for (i <- 0 until 16) {
          dut.io.indices(i).poke(indices(i))
          dut.io.data(i).poke(data(i))
        }

        // Check results
        for (i <- 0 until 16) {
          dut.io.out(i).expect(data(indices(i)))
        }
      }
    }
  }
}

class ScatterSpec extends AnyFreeSpec with ChiselSim {
  "Random Test" in {
    simulate(new ScatterTester) { dut =>
      for (_ <- 0 until 500) {
        // Set inputs
        val indices = Seq.fill(16)(Random.between(0, 16))
        val data = Seq.fill(16)(Random.between(0, 256))
        val valid = Seq.fill(16)(Random.nextBoolean())
        for (i <- 0 until 16) {
          dut.io.indices(i).poke(indices(i))
          dut.io.data(i).poke(data(i))
          dut.io.indicesValid(i).poke(valid(i))

        }

        // Check results
        val indicesSet = Array.fill(16)(false)
        var nIndicesSet = 0
        for (i <- 0 until 16) {
          if (dut.io.indicesSelected(i).peek().litValue == 1) {
            assertResult(true) { valid(i) }
            assertResult(false) { indicesSet(indices(i)) }
            indicesSet(indices(i)) = true
            nIndicesSet = nIndicesSet + 1
            dut.io.outData(indices(i)).expect(data(i))
            dut.io.writeMask(indices(i)).expect(1)
          }
        }
        dut.io.maskCount.expect(nIndicesSet)
      }
    }
  }
}