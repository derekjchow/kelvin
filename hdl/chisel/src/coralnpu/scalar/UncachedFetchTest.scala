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

package coralnpu

import chisel3._
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.freespec.AnyFreeSpec


class FetchControlSpec extends AnyFreeSpec with ChiselSim {
  val p = new Parameters

  "Initialization" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.fetchAddr.valid.expect(0)
    }
  }

  "ResetPC" in {
    simulate(new FetchControl(p)) { dut =>
      // Upstream can accept 8 buffers
      dut.io.bufferRequest.nReady.poke(8.U)
      dut.io.bufferSpaces.poke(8.U)
      dut.io.csr.value(0).poke(0x20000000.U)
      dut.reset.poke(true.B)
      dut.clock.step()
      dut.io.fetchAddr.valid.expect(0)
      dut.reset.poke(false.B)
      dut.clock.step()
      dut.io.bufferRequest.nValid.expect(0.U)
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x20000000)
    }
  }

  "Branch" in {
    simulate(new FetchControl(p)) { dut =>
      dut.clock.step()  // Clear reset.
      // Upstream can accept 16 buffers
      dut.io.bufferRequest.nReady.poke(8.U)
      dut.io.bufferSpaces.poke(16.U)
      dut.io.branch.valid.poke(true.B)
      dut.io.branch.bits.poke(0x30000000.U)
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      dut.io.fetchAddr.valid.expect(0)
      dut.clock.step()
      dut.io.branch.valid.poke(false.B)
      // We should initiate new fetch now, but old results should still be
      // discarded.
      dut.io.bufferRequest.nValid.expect(0.U)
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x30000000)
      dut.io.fetchData.bits.addr.poke(0x30000000)
      dut.clock.step()
      // Now we can accept results
      dut.io.bufferRequest.nValid.expect(8.U)
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x30000020)
    }
  }

  "FetchAligned" in {
    simulate(new FetchControl(p)) { dut =>
      dut.clock.step()  // Clear reset.
      // Upstream can accept 16 buffers
      dut.io.bufferRequest.nReady.poke(8.U)
      dut.io.bufferSpaces.poke(16.U)
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      dut.io.bufferRequest.nValid.expect(8.U)
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x20000020)
    }
  }

  "FetchWithBranch" in {
    simulate(new FetchControl(p)) { dut =>
      dut.clock.step()  // Clear reset.
      // Upstream can accept 12 buffers
      dut.io.bufferRequest.nReady.poke(8.U)
      dut.io.bufferSpaces.poke(12.U)
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      dut.io.fetchData.bits.inst(3).poke("x0000006f".U)
      dut.io.bufferRequest.nValid.expect(4.U)
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x2000000c)
    }
  }

  "Backpressure" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.csr.value(0).poke(0x20000000.U)
      dut.io.fetchAddr.ready.poke(true.B)
      dut.reset.poke(true.B)
      dut.clock.step()
      dut.reset.poke(false.B)
      dut.clock.step()
      // Cannot fetch the first 8.
      dut.io.bufferRequest.nReady.poke(4)
      dut.io.bufferSpaces.poke(4.U)
      dut.io.fetchAddr.valid.expect(0)
      dut.clock.step()
      // Can now fetch the first 8.
      dut.io.bufferRequest.nReady.poke(8)
      dut.io.bufferSpaces.poke(8.U)
      dut.io.fetchAddr.valid.expect(1)
    }
  }

  "BackpressureStaged" in {
    simulate(new FetchControl(p)) { dut =>
      dut.clock.step()  // Clear reset.
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      // Just fetched 8, cannot fetch another 8.
      dut.io.bufferRequest.nReady.poke(8)
      dut.io.bufferSpaces.poke(8.U)
      dut.io.bufferRequest.nValid.expect(8)
      dut.io.fetchAddr.valid.expect(0)
      dut.clock.step()
      dut.io.fetchData.valid.poke(false.B)  // Prev fetched instructions buffered.
      // Can now fetch another 8.
      dut.io.bufferRequest.nReady.poke(8)
      dut.io.bufferSpaces.poke(8.U)
      dut.io.fetchAddr.valid.expect(1)
    }
  }
}


class FetcherSpec extends AnyFreeSpec with ChiselSim {
  val p = new Parameters

  "Initialization" in {
    simulate(new Fetcher(p)) { dut =>
      dut.io.fetch.valid.expect(0)
    }
  }

  "Fetch" in {
    simulate(new Fetcher(p)) { dut =>
      dut.io.ctrl.bits.poke(32.U)
      dut.io.ctrl.valid.poke(true.B)
      dut.clock.step()
      dut.io.ibus.valid.expect(1)
      dut.io.ibus.ready.expect(0)
      dut.io.fetch.valid.expect(0)
      dut.io.ibus.ready.poke(true.B)
      dut.io.ibus.rdata.poke("x0012d678000000000012d687".U(256.W))
      dut.clock.step()
      dut.io.ctrl.ready.expect(1)
      dut.io.fetch.valid.expect(1)
      dut.io.fetch.bits.addr.expect(32)
      dut.io.fetch.bits.inst(0).expect(1234567)
      dut.io.fetch.bits.inst(1).expect(0)
      dut.io.fetch.bits.inst(2).expect(1234552)
    }
  }
}