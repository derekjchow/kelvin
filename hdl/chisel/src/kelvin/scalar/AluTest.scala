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


class AluSpec extends AnyFreeSpec with ChiselScalatestTester {
  val p = new Parameters

  "Initialization" in {
    test(new Alu(p)) { dut =>
      assertResult(0) { dut.io.rd.valid.peekInt() }
    }
  }

  "Sign Extend Byte" in {
    test(new Alu(p)) { dut =>
        dut.io.req.bits.addr.poke(13)
        dut.io.req.bits.op.poke(AluOp.SEXTB)
        dut.io.req.valid.poke(true.B)

        // Confirm that if top bit of lower byte is unset, value is unchanged
        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x0000007F))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        var compareValue = BigInt(0x0000007F)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt() }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }

        // Confirm sign extends if top bit of lower byte is set
        dut.io.req.valid.poke(true.B)

        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x00000080))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        compareValue = BigInt(0xFFFFFF80)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt().toInt }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }

    }
  }
  "Sign Extend Half Word" in {
    test(new Alu(p)) { dut =>
        dut.io.req.bits.addr.poke(13)
        dut.io.req.bits.op.poke(AluOp.SEXTH)
        dut.io.req.valid.poke(true.B)

        // Confirm that if top bit of lower half-word is unset, value is unchanged
        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x00007FFF))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        var compareValue = BigInt(0x00007FFF)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt() }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }

        // Confirm sign extends if top bit of lower half-word is set
        dut.io.req.valid.poke(true.B)

        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x00008000))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        compareValue = BigInt(0xFFFF8000)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt().toInt }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }
    }
  }
  "Zero Extend Half Word" in {
    test(new Alu(p)) { dut =>
        dut.io.req.bits.addr.poke(13)
        dut.io.req.bits.op.poke(AluOp.ZEXTH)
        dut.io.req.valid.poke(true.B)

        // Confirm that if top bit of lower half-word is unset, value is unchanged
        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x00007FFF))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        var compareValue = BigInt(0x00007FFF)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt() }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }

        // Confirm that if top bit of lower half-word is set, value remains unchanged
        dut.io.req.valid.poke(true.B)

        dut.io.rs1.valid.poke(true.B)
        dut.io.rs1.data.poke(BigInt(0x00008000))

        dut.clock.step()
        dut.io.req.valid.poke(false.B)
        assertResult(1) { dut.io.rd.valid.peekInt() }
        compareValue = BigInt(0x00008000)
        assertResult(compareValue) { dut.io.rd.bits.data.peekInt().toInt }

        dut.clock.step()
        assertResult(0) { dut.io.rd.valid.peekInt() }
        assertResult(13) { dut.io.rd.bits.addr.peekInt() }
    }
  }
}
