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

package peripheral

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._

import bus._
import common._

class CounterAxiPeripheral extends Module { //extends AxiCsrInterface(3) {
  val io = IO(new Bundle{
    val count = Output(UInt(32.W))
    val axi = Flipped(new AxiMasterIO(32, 32, 6))
  })

  val count = RegInit(0.U(32.W))
  val limit = RegInit(256.U(32.W))
  val enable = RegInit(0.U(32.W))  // Counts if non-zero

  val readMap = Map.apply(
      "count" -> (0, count),
      "limit" -> (4, limit),
      "enable" -> (8, enable),
  )
  io.axi.read <> ConnectAxiRead(6, readMap)

  val writeMap = Map.apply(
      "count" -> 0,
      "limit" -> 4,
      "enable" -> 8,
  )
  val (writes, writeData) = ConnectAxiWrite(6, writeMap, io.axi.write)

  val hasWrite = Wire(Bool())
  val axiWriteAddr = Wire(UInt(32.W))
  val axiWriteData = Wire(UInt(32.W))
  hasWrite := false.B
  axiWriteAddr := 0.U
  axiWriteData := 0.U

  val increment = enable =/= 0.U
  val incCount = count + increment
  val overflowCount = Mux(incCount >= limit, 0.U, incCount)
  count := Mux(writes("count"), writeData, overflowCount)

  when (writes("limit")) {
    limit := writeData
  }

  when (writes("enable")) {
    enable := writeData
  }

  io.count := count
}



class PeripheralInterfaceSpec extends AnyFreeSpec with ChiselScalatestTester {
  "Does Nothing" in {
    test(new CounterAxiPeripheral) { dut =>
      for (i <- 0 until 32) {
        assertResult(0) { dut.io.count.peekInt() }
        dut.clock.step()
      }
    }
  }

  "Read" in {
    test(new CounterAxiPeripheral) { dut =>
      dut.io.axi.read.data.ready.poke(1)
      dut.io.axi.read.addr.valid.poke(1)

      // Read limit
      dut.io.axi.read.addr.bits.addr.poke(4)
      dut.clock.step()
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(256) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.resp.peekInt() }

      // Read count
      dut.io.axi.read.addr.bits.addr.poke(0)
      dut.clock.step()
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.resp.peekInt() }

      // Read read invalid address
      dut.io.axi.read.addr.bits.addr.poke(3)
      dut.clock.step()
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(2) { dut.io.axi.read.data.bits.resp.peekInt() }
    }
  }

  "Write" in {
    test(new CounterAxiPeripheral) { dut =>
      dut.io.axi.write.addr.valid.poke(1)
      dut.io.axi.write.data.valid.poke(1)
      dut.io.axi.write.resp.ready.poke(1)

      // Write count
      dut.io.axi.write.addr.bits.addr.poke(0)
      dut.io.axi.write.data.bits.data.poke(64)
      dut.clock.step()
      assertResult(1) { dut.io.axi.write.resp.valid.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }

      // Write limit
      dut.io.axi.write.addr.bits.addr.poke(4)
      dut.io.axi.write.data.bits.data.poke(2048)
      dut.clock.step()
      assertResult(1) { dut.io.axi.write.resp.valid.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }

      // Write invalid
      dut.io.axi.write.addr.bits.addr.poke(6)
      dut.io.axi.write.data.bits.data.poke(9001)
      dut.clock.step()
      assertResult(1) { dut.io.axi.write.resp.valid.peekInt() }
      assertResult(2) { dut.io.axi.write.resp.bits.resp.peekInt() }

      dut.io.axi.write.addr.valid.poke(0)
      dut.io.axi.write.data.valid.poke(0)

      // Read results
      dut.io.axi.read.data.ready.poke(1)
      dut.io.axi.read.addr.valid.poke(1)

      // Read count
      dut.io.axi.read.addr.bits.addr.poke(0)
      dut.clock.step()
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(64) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.resp.peekInt() }

      // Read limit
      dut.io.axi.read.addr.bits.addr.poke(4)
      dut.clock.step()
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(2048) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(0) { dut.io.axi.read.data.bits.resp.peekInt() }
    }
  }

  "Enable" in {
    test(new CounterAxiPeripheral) { dut =>
      dut.io.axi.write.addr.valid.poke(1)
      dut.io.axi.write.data.valid.poke(1)
      dut.io.axi.write.resp.ready.poke(1)

      // Write enable
      dut.io.axi.write.addr.bits.addr.poke(8)
      dut.io.axi.write.data.bits.data.poke(1)
      dut.clock.step()
      assertResult(1) { dut.io.axi.write.resp.valid.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }
      dut.io.axi.write.addr.valid.poke(0)
      dut.io.axi.write.data.valid.poke(0)

      for (i <- 0 until 64) {
        dut.clock.step()
        assertResult(i) { dut.io.count.peekInt() }
      }
    }
  }
}