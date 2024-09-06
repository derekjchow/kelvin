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

class CoreAxiSlaveMuxSpec extends AnyFreeSpec with ChiselScalatestTester {
  var p = new Parameters
  p.enableVector = false

  val memoryRegions = Seq(
    new MemoryRegion(0x0000, 0x2000, MemoryRegionType.IMEM),
    new MemoryRegion(0x2000, 0x2000, MemoryRegionType.Peripheral),
    // Hole from 0x4000-0x8000
    new MemoryRegion(0x8000, 0x8000, MemoryRegionType.DMEM),
  )

  "Initialization" in {
    test(new CoreAxiSlaveMux(p, memoryRegions)) { dut =>
      assertResult(0) { dut.io.axi_slave.read.addr.ready.peekInt() }
      assertResult(0) { dut.io.axi_slave.read.data.valid.peekInt() }
      assertResult(0) { dut.io.axi_slave.write.addr.ready.peekInt() }
      assertResult(0) { dut.io.axi_slave.write.data.ready.peekInt() }
      assertResult(0) { dut.io.axi_slave.write.resp.valid.peekInt() }
    }
  }

  "Read" in {
    test(new CoreAxiSlaveMux(p, memoryRegions)) { dut =>
      dut.io.axi_slave.read.addr.valid.poke(true.B)
      dut.io.axi_slave.read.addr.bits.addr.poke(0x2000.U)
      dut.clock.step()
      assertResult(1) { dut.io.ports(1).read.addr.valid.peekInt() }
      dut.io.ports(1).read.addr.ready.poke(true.B)
      assertResult(1) { dut.io.axi_slave.read.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi_slave.read.addr.valid.poke(false.B)
      dut.clock.step()
      assertResult(0) { dut.io.axi_slave.read.addr.valid.peekInt() }
    }
  }

  "Write" in {
    test(new CoreAxiSlaveMux(p, memoryRegions)) { dut =>
      dut.io.axi_slave.write.addr.valid.poke(true.B)
      dut.io.axi_slave.write.addr.bits.addr.poke(0x2000.U)
      dut.clock.step()
      assertResult(1) { dut.io.ports(1).write.addr.valid.peekInt() }
      dut.io.ports(1).write.addr.ready.poke(true.B)
      assertResult(1) { dut.io.axi_slave.write.addr.ready.peekInt() }
      dut.clock.step()
      dut.io.axi_slave.write.addr.valid.poke(false.B)
      dut.clock.step()
      assertResult(0) { dut.io.axi_slave.write.addr.valid.peekInt() }
    }
  }
}
