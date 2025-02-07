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

package kelvin

import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.expose
import org.scalatest.freespec.AnyFreeSpec

class FabricArbiterSpec extends AnyFreeSpec with ChiselScalatestTester {
  var p = new Parameters
  p.enableVector = false

  "Kelvin Read - AXI Slave Any" in {
    test(new FabricArbiter(p)) { dut =>
      dut.io.source(0).readDataAddr.valid.poke(true.B)
      dut.io.source(0).readDataAddr.bits.poke(0x8080.U)
      dut.io.source(0).writeDataAddr.valid.poke(false.B)

      dut.io.source(1).readDataAddr.bits.poke(0x4080.U)
      dut.io.source(1).writeDataAddr.bits.poke(0x4080.U)
      dut.io.source(1).writeDataBits.poke(0x5080.U)
      dut.io.source(1).writeDataStrb.poke(0x1.U)

      for (i <- 0 until 3) {
        if (i == 0) {  // None
          dut.io.source(1).readDataAddr.valid.poke(false.B)
          dut.io.source(1).writeDataAddr.valid.poke(false.B)
        } else if (i == 1) {  // Read
          dut.io.source(1).readDataAddr.valid.poke(true.B)
          dut.io.source(1).writeDataAddr.valid.poke(false.B)
        } else {  // Write
          dut.io.source(1).readDataAddr.valid.poke(false.B)
          dut.io.source(1).writeDataAddr.valid.poke(true.B)
        }

        // Check read command is accurate
        assertResult(1) { dut.io.fabricBusy.peekInt() }
        assertResult(1) { dut.io.port.readDataAddr.valid.peekInt() }
        assertResult(0) { dut.io.port.writeDataAddr.valid.peekInt() }
        assertResult(0x8080) { dut.io.port.readDataAddr.bits.peekInt() }

        dut.clock.step()

        // Check response is propagated back to source 0
        dut.io.port.readData.valid.poke(true.B)
        dut.io.port.readData.bits.poke(300 + i)
        assertResult(1) { dut.io.source(0).readData.valid.peekInt() }
        assertResult(300 + i) { dut.io.source(0).readData.bits.peekInt() }
      }
    }
  }

  "Kelvin Write - AXI Slave Any" in {
    test(new FabricArbiter(p)) { dut =>
      dut.io.source(0).readDataAddr.valid.poke(false.B)
      dut.io.source(0).writeDataAddr.valid.poke(true.B)
      dut.io.source(0).writeDataAddr.bits.poke(0x80B0.U)
      dut.io.source(0).writeDataBits.poke(0x50B0.U)
      dut.io.source(0).writeDataStrb.poke(0xF.U)

      dut.io.source(1).readDataAddr.bits.poke(0x40B0.U)
      dut.io.source(1).writeDataAddr.bits.poke(0x40B0.U)
      dut.io.source(1).writeDataBits.poke(0x60B0.U)
      dut.io.source(1).writeDataStrb.poke(0x12.U)

      for (i <- 0 until 3) {
        if (i == 0) {  // None
          dut.io.source(1).readDataAddr.valid.poke(false.B)
          dut.io.source(1).writeDataAddr.valid.poke(false.B)
        } else if (i == 1) {  // Read
          dut.io.source(1).readDataAddr.valid.poke(true.B)
          dut.io.source(1).writeDataAddr.valid.poke(false.B)
        } else {  // Write
          dut.io.source(1).readDataAddr.valid.poke(false.B)
          dut.io.source(1).writeDataAddr.valid.poke(true.B)
        }

        // Check write command is accurate
        assertResult(1) { dut.io.fabricBusy.peekInt() }
        assertResult(0) { dut.io.port.readDataAddr.valid.peekInt() }
        assertResult(1) { dut.io.port.writeDataAddr.valid.peekInt() }
        assertResult(0x80B0) { dut.io.port.writeDataAddr.bits.peekInt() }
        assertResult(0x50B0) { dut.io.port.writeDataBits.peekInt() }
        assertResult(0xF) { dut.io.port.writeDataStrb.peekInt() }
      }
    }
  }

  "Kelvin None - AXI Slave Read" in {
    test(new FabricArbiter(p)) { dut =>
      dut.io.source(0).readDataAddr.valid.poke(false.B)
      dut.io.source(0).writeDataAddr.valid.poke(false.B)

      dut.io.source(1).readDataAddr.valid.poke(true.B)
      dut.io.source(1).readDataAddr.bits.poke(0x40B0.U)
      dut.io.source(1).writeDataAddr.valid.poke(false.B)

      assertResult(0) { dut.io.fabricBusy.peekInt() }
      assertResult(1) { dut.io.port.readDataAddr.valid.peekInt() }
      assertResult(0x40B0) { dut.io.port.readDataAddr.bits.peekInt() }
      assertResult(0) { dut.io.port.writeDataAddr.valid.peekInt() }

      dut.clock.step()

      dut.io.port.readData.valid.poke(true.B)
      dut.io.port.readData.bits.poke(777)
      assertResult(1) { dut.io.source(1).readData.valid.peekInt() }
      assertResult(777) { dut.io.source(1).readData.bits.peekInt() }
    }
  }

  "Kelvin None - AXI Slave Write" in {
    test(new FabricArbiter(p)) { dut =>
      dut.io.source(0).readDataAddr.valid.poke(false.B)
      dut.io.source(0).writeDataAddr.valid.poke(false.B)

      dut.io.source(1).readDataAddr.valid.poke(false.B)
      dut.io.source(1).writeDataAddr.valid.poke(true.B)
      dut.io.source(1).writeDataAddr.bits.poke(0xB0B0.U)
      dut.io.source(1).writeDataBits.poke(0xA0B0.U)
      dut.io.source(1).writeDataStrb.poke(0xA.U)

    
      assertResult(0) { dut.io.fabricBusy.peekInt() }
      assertResult(0) { dut.io.port.readDataAddr.valid.peekInt() }
      assertResult(1) { dut.io.port.writeDataAddr.valid.peekInt() }
      assertResult(0xB0B0) { dut.io.port.writeDataAddr.bits.peekInt() }
    }
  }

  "Both None" in {
    test(new FabricArbiter(p)) { dut =>
      dut.io.source(0).readDataAddr.valid.poke(false.B)
      dut.io.source(0).writeDataAddr.valid.poke(false.B)
      dut.io.source(1).readDataAddr.valid.poke(false.B)
      dut.io.source(1).writeDataAddr.valid.poke(false.B)
    
      assertResult(0) { dut.io.fabricBusy.peekInt() }
      assertResult(0) { dut.io.port.readDataAddr.valid.peekInt() }
      assertResult(0) { dut.io.port.writeDataAddr.valid.peekInt() }
    }
  }
}

class FabricMuxSpec extends AnyFreeSpec with ChiselScalatestTester {
  var p = new Parameters
  p.enableVector = false

  val memoryRegions = Seq(
    new MemoryRegion(0x0000, 0x2000, MemoryRegionType.IMEM), // ITCM
    new MemoryRegion(0x10000, 0x8000, MemoryRegionType.DMEM), // DTCM
    new MemoryRegion(0x30000, 0x2000, MemoryRegionType.Peripheral), // CSR
  )

  "Writes" in {
    test(new FabricMux(p, memoryRegions)) { dut =>
      val inputAddrs = Seq(0x10, 0x10020, 0x30004)
      val outputAddrs = Seq(0x10, 0x20, 0x4)
      for (i <- 0 until memoryRegions.length) {
        dut.io.source.readDataAddr.valid.poke(false.B)
        dut.io.source.writeDataAddr.valid.poke(true.B)
        dut.io.source.writeDataAddr.bits.poke(inputAddrs(i).U)
        dut.io.source.writeDataBits.poke((123 + i).U)
        dut.io.source.writeDataStrb.poke((21 + i).U)

        for (j <- 0 until memoryRegions.length) {
          assertResult(0) { dut.io.ports(j).readDataAddr.valid.peekInt() }
          if (i == j) {
            assertResult(1) { dut.io.ports(j).writeDataAddr.valid.peekInt() }
            assertResult(outputAddrs(i)) {
                dut.io.ports(j).writeDataAddr.bits.peekInt() }
            assertResult(123 + i) { dut.io.ports(j).writeDataBits.peekInt() }
            assertResult(21 + i) { dut.io.ports(j).writeDataStrb.peekInt() }
          } else {
            assertResult(0) { dut.io.ports(j).writeDataAddr.valid.peekInt() }
          }
        }

        // Check periBusy gets forwarded correctly
        dut.io.periBusy(i).poke(true.B)
        assertResult(1) { dut.io.fabricBusy.peekInt() }
        dut.io.periBusy(i).poke(false.B)
        assertResult(0) { dut.io.fabricBusy.peekInt() }
      }

      // Invalid write
      dut.io.source.writeDataAddr.bits.poke(0x90000.U)
      dut.io.source.writeDataBits.poke(1123.U)
      dut.io.source.writeDataStrb.poke(11.U)
      for (j <- 0 until memoryRegions.length) {
        assertResult(0) { dut.io.ports(j).readDataAddr.valid.peekInt() }
        assertResult(0) { dut.io.ports(j).writeDataAddr.valid.peekInt() }
      }
    }
  }

  "Reads" in {
    test(new FabricMux(p, memoryRegions)) { dut =>
      val inputAddrs = Seq(0x10, 0x10020, 0x30004)
      val outputAddrs = Seq(0x10, 0x20, 0x4)
      for (i <- 0 until memoryRegions.length) {
        dut.io.source.readDataAddr.valid.poke(true.B)
        dut.io.source.readDataAddr.bits.poke(inputAddrs(i).U)
        dut.io.source.writeDataAddr.valid.poke(false.B)

        // Check command was forwarded correctly
        for (j <- 0 until memoryRegions.length) {
          assertResult(0) { dut.io.ports(j).writeDataAddr.valid.peekInt() }
          if (i == j) {
            assertResult(1) { dut.io.ports(j).readDataAddr.valid.peekInt() }
            assertResult(outputAddrs(i)) {
                dut.io.ports(j).readDataAddr.bits.peekInt() }
          } else {
            assertResult(0) { dut.io.ports(j).readDataAddr.valid.peekInt() }
          }
        }

        // Check periBusy gets forwarded correctly
        dut.io.periBusy(i).poke(true.B)
        assertResult(1) { dut.io.fabricBusy.peekInt() }
        dut.io.periBusy(i).poke(false.B)
        assertResult(0) { dut.io.fabricBusy.peekInt() }

        dut.clock.step()

        // Check correct response is picked
        for (j <- 0 until memoryRegions.length) {
          dut.io.ports(j).readData.valid.poke(false.B)
          dut.io.ports(j).readData.bits.poke((800 + j).U)
        }
        dut.io.ports(i).readData.valid.poke(true.B)
        assertResult(1) { dut.io.source.readData.valid.peekInt() }
        assertResult(800 + i) { dut.io.source.readData.bits.peekInt() }
      }

      // Invalid read
      dut.io.source.readDataAddr.valid.poke(true.B)
      dut.io.source.readDataAddr.bits.poke(0x90000.U)
      dut.io.source.writeDataAddr.valid.poke(false.B)
      for (i <- 0 until memoryRegions.length) {
        assertResult(0) { dut.io.ports(i).readDataAddr.valid.peekInt() }
      }
    }
  }
}