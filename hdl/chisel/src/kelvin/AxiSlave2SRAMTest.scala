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

class AxiSlave2SRAMSpec extends AnyFreeSpec with ChiselScalatestTester {
  var p = new Parameters
  p.enableVector = false

  "Initialization" in {
    test(new AxiSlave2SRAM(p, 4)) { dut =>
      assertResult(1) { dut.io.axi.read.addr.ready.peekInt() }
      assertResult(0) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(1) { dut.io.axi.write.addr.ready.peekInt() }
      assertResult(1) { dut.io.axi.write.data.ready.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.valid.peekInt() }

      assertResult(0) { dut.io.sram.enable.peekInt() }
      assertResult(0) { dut.io.txnInProgress.peekInt() }
    }
  }

  "Read" in {
    test (new AxiSlave2SRAM(p, 4)) { dut =>
      // Configure Read Address
      dut.io.periBusy.poke(false.B)
      dut.io.axi.read.addr.valid.poke(true.B)
      dut.io.axi.read.addr.bits.addr.poke(32)
      dut.io.axi.read.addr.bits.len.poke(0)
      assertResult(1) { dut.io.axi.read.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi.read.addr.valid.poke(false.B)

      // Wait for read on SRAM side
      while (dut.io.sram.enable.peekInt() != 1) {
        dut.clock.step()
      }
      assertResult(1) { dut.io.sram.enable.peekInt() }
      assertResult(0) { dut.io.sram.isWrite.peekInt() }
      assertResult(32 / (p.lsuDataBits / 8)) { dut.io.sram.address.peekInt() }

      // Setup SRAM response, and read data response
      dut.io.sram.readData((p.fetchDataBits / 8) - 1).poke(0xB0.U)
      dut.clock.step()
      // There should be no pending read (only one issued)
      assertResult(0) { dut.io.sram.enable.peekInt() }

      // Wait for AXI read response
      while (dut.io.axi.read.data.valid.peekInt() != 1) {
        dut.clock.step()
      }
      assertResult(0xB0) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(1) { dut.io.axi.read.data.bits.last.peekInt() }

      // Accept read response, check no pending read
      dut.io.axi.read.data.ready.poke(true.B)
      for (i <- 0 until 10) {
        dut.clock.step()
        assertResult(0) { dut.io.axi.read.data.valid.peekInt() }
      }
    }
  }

  "Write" in {
    test (new AxiSlave2SRAM(p, 4)) { dut =>
      // Configure write address
      dut.io.periBusy.poke(false.B)
      dut.io.axi.write.addr.valid.poke(true.B)
      dut.io.axi.write.addr.bits.addr.poke(96)
      dut.io.axi.write.addr.bits.len.poke(0.U)
      assertResult(1) { dut.io.axi.write.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi.write.addr.valid.poke(false.B)

      // Configure write data
      dut.io.axi.write.data.bits.data.poke(0xB0.U)
      dut.io.axi.write.data.bits.strb.poke(1.U)
      dut.io.axi.write.data.bits.last.poke(true.B)
      dut.io.axi.write.data.valid.poke(true.B)
      assertResult(1) { dut.io.axi.write.data.ready.peekInt() }
      dut.clock.step()
      dut.io.axi.write.data.valid.poke(false.B)

      // Wait for write on SRAM side
      while (dut.io.sram.enable.peekInt() != 1) {
        dut.clock.step()
      }
      assertResult(1) { dut.io.sram.enable.peekInt() }
      assertResult(1) { dut.io.sram.isWrite.peekInt() }
      assertResult(96 / (p.lsuDataBits / 8)) { dut.io.sram.address.peekInt() }
      assertResult(0xB0) { dut.io.sram.writeData(0).peekInt() }
      assertResult(1) { dut.io.sram.mask(0).peekInt() }

      // There should be no pending operation on the SRAM side once processed.
      dut.clock.step()
      assertResult(0) { dut.io.sram.enable.peekInt() }

      // Wait for the AXI write response
      while (dut.io.axi.write.resp.valid.peekInt() != 1) {
        dut.clock.step()
      }
      assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }

      // Accept response, should be no pending write
      dut.io.axi.write.resp.ready.poke(true.B)
      for (i <- 0 until 10) {
        dut.clock.step()
        assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }
      }
    }
  }
}
