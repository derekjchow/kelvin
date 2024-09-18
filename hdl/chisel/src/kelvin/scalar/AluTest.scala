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

  // TODO(davidgao): move to somewhere else.
  // Performs a (partial) assertion on a bundle as part of a test.
  // - Accepts same input as bundle literals.
  // - Prints a summary in case of failure.
  // - Returns the result. It does not throw anything.
  private def assertPartial[T <: Bundle](act: T, hint: String, exp: T => (Data, Data)*): Boolean = {
    val good = exp.map { e =>
      val (x, y) = e(act)
      x.litValue == y.litValue
    }
    val all_pass = good.fold(true)((x, y) => x & y)
    if (!all_pass) {
      val exp_bundle = chiselTypeOf(act).Lit(exp:_*)
      println(s"- Assertion failure: $hint")
      println(s"  - Expected: $exp_bundle")
      println(s"  - Actual: $act")
    }
    all_pass
  }

  // TODO(davidgao): move to somewhere else.
  // Prints a summary from a sequence of test results, and triggers
  // a failure if it contains any failure(s).
  private def processResults(good: Seq[Boolean]) = {
    val good_count = good.count(x => x)
    val count = good.length
    println(s"- $good_count / $count passed")
    if (good_count != good.length) fail
  }

  private def testBinaryOp(
      dut: Alu,
      addr: UInt,
      op: AluOp.Type,
      // Long because Scala has no unsigned int.
      cases: Seq[(Long, Long, Long)]) = {
    dut.io.req.poke(chiselTypeOf(dut.io.req).Lit(
      _.valid -> true.B,
      _.bits.addr -> addr,
      _.bits.op -> op,
    ))
    val good = cases.map { case (rs1, rs2, exp_rd) =>
      dut.io.rs1.poke(chiselTypeOf(dut.io.rs1).Lit(
        _.valid -> true.B,
        _.data -> rs1.U,
      ))
      dut.io.rs2.poke(chiselTypeOf(dut.io.rs2).Lit(
        _.valid -> true.B,
        _.data -> rs2.U,
      ))
      dut.clock.step()
      assertPartial[Valid[RegfileWriteDataIO]](
        dut.io.rd.peek(),
        s"rs1=$rs1, rs2=$rs2",
        _.bits.addr -> addr,
        _.valid -> true.B,
        _.bits.data -> exp_rd.U,
      )
    }
    processResults(good)
  }

  "XNOR(Not XOR)" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0xFFFFFFFFL),
      (0x00000000L, 0x12345678L, 0xEDCBA987L),
      (0x00000000L, 0xFFFFFFFFL, 0x00000000L),
      (0x12345678L, 0x00000000L, 0xEDCBA987L),
      (0x12345678L, 0x12345678L, 0xFFFFFFFFL),
      (0x12345678L, 0xFFFFFFFFL, 0x12345678L),
      (0xFFFFFFFFL, 0x00000000L, 0x00000000L),
      (0xFFFFFFFFL, 0x12345678L, 0x12345678L),
      (0xFFFFFFFFL, 0xFFFFFFFFL, 0xFFFFFFFFL),
    )
    test(new Alu(p))(testBinaryOp(_, 13.U, AluOp.XNOR, test_cases))
  }

  "ORN(Not OR)" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0xFFFFFFFFL),
      (0x00000000L, 0x12345678L, 0xEDCBA987L),
      (0x00000000L, 0xFFFFFFFFL, 0x00000000L),
      (0x12345678L, 0x00000000L, 0xEDCBA987L),
      (0x12345678L, 0x12345678L, 0xEDCBA987L),
      (0x12345678L, 0xFFFFFFFFL, 0x00000000L),
      (0xFFFFFFFFL, 0x00000000L, 0x00000000L),
      (0xFFFFFFFFL, 0x12345678L, 0x00000000L),
      (0xFFFFFFFFL, 0xFFFFFFFFL, 0x00000000L),
    )
    test(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ORN, test_cases))
  }

  "ANDN(Not AND)" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0xFFFFFFFFL),
      (0x00000000L, 0x12345678L, 0xFFFFFFFFL),
      (0x00000000L, 0xFFFFFFFFL, 0xFFFFFFFFL),
      (0x12345678L, 0x00000000L, 0xFFFFFFFFL),
      (0x12345678L, 0x12345678L, 0xEDCBA987L),
      (0x12345678L, 0xFFFFFFFFL, 0xEDCBA987L),
      (0xFFFFFFFFL, 0x00000000L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x12345678L, 0xEDCBA987L),
      (0xFFFFFFFFL, 0xFFFFFFFFL, 0x00000000L),
    )
    test(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ANDN, test_cases))
  }
}
