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

class AxiSlave2ChiselSRAMSpec extends AnyFreeSpec with ChiselScalatestTester {
  var p = new Parameters
  p.enableVector = false

  "Initialization" in {
    test(new AxiSlave2ChiselSRAM(p, 4)) { dut =>
      assertResult(1) { dut.io.axi.read.addr.ready.peekInt() }
      assertResult(0) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(1) { dut.io.axi.write.addr.ready.peekInt() }
      assertResult(1) { dut.io.axi.write.data.ready.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.valid.peekInt() }

      assertResult(0) { dut.io.sramEnable.peekInt() }
      assertResult(0) { dut.io.txnInProgress.peekInt() }
    }
  }

  "Read" in {
    test (new AxiSlave2ChiselSRAM(p, 4)) { dut =>
      // Configure Read Address
      dut.io.periBusy.poke(false.B)
      dut.io.axi.read.addr.valid.poke(true.B)
      dut.io.axi.read.addr.bits.addr.poke(32)
      assertResult(1) { dut.io.axi.read.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi.read.addr.valid.poke(false.B)
      assertResult(0) { dut.io.axi.read.addr.ready.peekInt() }
      dut.clock.step()
      // Setup SRAM response, and read data response
      dut.io.sramReadData((p.fetchDataBits / 8) - 1).poke(0xB0.U)
      dut.io.axi.read.data.ready.poke(true.B)
      assertResult(1) { dut.io.sramEnable.peekInt() }
      assertResult(1) { dut.io.axi.read.data.valid.peekInt() }
      assertResult(0) { dut.io.sramIsWrite.peekInt() }
      assertResult(0xB0) { dut.io.axi.read.data.bits.data.peekInt() }
      assertResult(1) { dut.io.axi.read.data.bits.last.peekInt() }
      assertResult((32 * 8) / p.fetchDataBits) { dut.io.sramAddress.peekInt() }
      dut.clock.step()
      dut.io.axi.read.data.ready.poke(false.B)
      dut.clock.step()
      dut.clock.step()
      // Check that we're ready for the next read
      assertResult(1) { dut.io.axi.read.addr.ready.peekInt() }
    }
  }

  "Write" in {
    test (new AxiSlave2ChiselSRAM(p, 4)) { dut =>
      // Configure write address
      dut.io.periBusy.poke(false.B)
      dut.io.axi.write.addr.valid.poke(true.B)
      dut.io.axi.write.addr.bits.addr.poke(32)
      dut.io.axi.write.addr.bits.len.poke(0.U)
      assertResult(1) { dut.io.axi.write.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi.write.addr.valid.poke(false.B)
      assertResult(0) { dut.io.axi.write.addr.ready.peekInt() }
      assertResult(1) { dut.io.axi.write.data.ready.peekInt() }

      // Configure write data
      dut.io.axi.write.data.bits.data.poke(0xB0.U)
      dut.io.axi.write.data.bits.strb.poke(1.U)
      dut.io.axi.write.data.bits.last.poke(true.B)
      dut.io.axi.write.data.valid.poke(true.B)
      dut.clock.step()
      assertResult(0) { dut.io.axi.write.data.ready.peekInt() }
      dut.io.axi.write.data.valid.poke(false.B)
      assertResult(1) { dut.io.sramEnable.peekInt() }
      assertResult(1) { dut.io.sramIsWrite.peekInt() }
      assertResult(0xB0) { dut.io.sramWriteData(0).peekInt() }
      assertResult(1) { dut.io.sramMask(0).peekInt() }

      // Write response phase
      dut.io.axi.write.resp.ready.poke(true.B)
      dut.clock.step()
      assertResult(1) { dut.io.axi.write.resp.valid.peekInt() }
      assertResult(0) { dut.io.axi.write.resp.bits.resp.peekInt() }
      dut.clock.step()
      dut.io.axi.write.resp.ready.poke(false.B)
      assertResult(1) { dut.io.axi.write.addr.ready.peekInt() }
    }
  }
}