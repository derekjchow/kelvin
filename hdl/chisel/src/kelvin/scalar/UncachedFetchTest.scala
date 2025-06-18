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
      dut.io.bufferRequest.nReady.poke(8.U)  // Upstream can accept 8 buffers
      dut.io.csr.value(0).poke(0x20000000.U)
      dut.io.fetchAddr.ready.poke(true.B)
      dut.reset.poke(true.B)
      dut.clock.step()
      dut.io.fetchAddr.valid.expect(0)
      dut.reset.poke(false.B)
      dut.clock.step()
      dut.clock.step()
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x20000000)
    }
  }

  "Branch" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.fetchAddr.valid.expect(0)
      dut.io.bufferRequest.nReady.poke(8.U)  // Upstream can accept 8 buffers
      dut.io.branch.valid.poke(true.B)
      dut.io.branch.bits.poke(0x30000000.U)
      dut.io.fetchAddr.ready.poke(true.B)
      dut.clock.step()
      dut.io.branch.valid.poke(false.B)
      dut.clock.step()
      dut.io.fetchAddr.valid.expect(1)
      dut.io.fetchAddr.bits.expect(0x30000000)
    }
  }

  "FetchAligned" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.fetchAddr.valid.expect(0)
      dut.io.fetchData.valid.expect(0)
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      dut.clock.step()
      dut.clock.step()
      dut.clock.step()
      dut.io.fetchAddr.bits.expect(0x20000020)
    }
  }

  "FetchWithBranch" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.fetchAddr.valid.expect(0)
      dut.io.fetchData.valid.expect(0)
      dut.io.fetchData.valid.poke(true.B)
      dut.io.fetchData.bits.addr.poke(0x20000000)
      for (i <- 0 until dut.io.fetchData.bits.inst.length) {
        dut.io.fetchData.bits.inst(i).poke(i.U)
      }
      dut.io.fetchData.bits.inst(3).poke("x0000006f".U)
      dut.clock.step()
      dut.clock.step()
      dut.clock.step()
      dut.io.fetchAddr.bits.expect(0x2000000c)
    }
  }

  "Backpressure" in {
    simulate(new FetchControl(p)) { dut =>
      dut.io.fetchAddr.valid.expect(0)
      dut.io.csr.value(0).poke(0x20000000.U)
      dut.io.fetchAddr.ready.poke(true.B)
      dut.reset.poke(true.B)
      dut.clock.step()
      dut.reset.poke(false.B)
      dut.io.bufferRequest.nReady.poke(4)  // Upstream accepts < 8 buffers
      dut.clock.step()
      dut.io.fetchAddr.valid.expect(0)
      dut.io.bufferRequest.nReady.poke(9)
      dut.clock.step()
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