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
import chisel3.experimental.BundleLiterals._


class MluSpec extends AnyFreeSpec with ChiselScalatestTester {
  val p = new Parameters

  "Initialization" in {
    test(new Mlu(p)) { dut =>
      assertResult(0) { dut.io.rd.valid.peekInt() }
    }
  }

  "Multiply" in {
    test(new Mlu(p)) { dut =>
        dut.io.req(0).bits.addr.poke(13)
        dut.io.req(0).bits.op.poke(MluOp.MUL)
        dut.io.req(0).valid.poke(true.B)
        dut.io.req(1).valid.poke(false.B)
        dut.io.req(2).valid.poke(false.B)
        dut.io.req(3).valid.poke(false.B)
        for(i <- 0 until 4){
            dut.io.rs1(i).valid.poke(true.B)
            dut.io.rs1(i).data.poke(i + 2)
            dut.io.rs2(i).valid.poke(true.B)
            dut.io.rs2(i).data.poke(i + 2)
        }

        dut.clock.step()
        dut.io.req(0).valid.poke(false.B)

        dut.clock.step()
        assertResult(1) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.addr.peekInt() }
        assertResult(4) { dut.io.rd.data.peekInt() }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
    }
  }
}
