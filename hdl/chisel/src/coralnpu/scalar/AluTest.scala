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

import common.{ProcessTestResults}


class AluSpec extends AnyFreeSpec with ChiselSim {
  val p = new Parameters

  "Initialization" in {
    simulate(new Alu(p)) { dut =>
      dut.io.rd.valid.expect(0)
    }
  }

  private def test_unary_op(
      dut: Alu,
      addr: UInt,
      op: AluOp.Type,
      // Long because Scala has no unsigned int.
      cases: Seq[(Long, Long)]) = {
    val good = cases.map { case (rs1, exp_rd) =>
      dut.io.req.valid.poke(true)
      dut.io.req.bits.addr.poke(addr)
      dut.io.req.bits.op.poke(op)
      dut.io.rs1.valid.poke(true)
      dut.io.rs1.data.poke(rs1)
      dut.clock.step()
      val good1 = {
        (dut.io.rd.valid.peek().litValue == 1) && (dut.io.rd.bits.data.peek().litValue == exp_rd)
      }
      dut.io.req.valid.poke(true)
      dut.clock.step()
      val good2 = {
        (dut.io.rd.valid.peek().litValue == 1) && (dut.io.rd.bits.addr.peek().litValue == addr.litValue)
      }
      good1 & good2
    }
    if (!ProcessTestResults(good, printfn = info(_))) fail()
  }

  "Sign Extend Byte" in {
    val test_cases = Seq(
      (0x0000007FL, 0x0000007FL),
      (0x00000080L, 0xFFFFFF80L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.SEXTB, test_cases))
  }

  "Sign Extend Half Word" in {
    val test_cases = Seq(
      (0x00007FFFL, 0x00007FFFL),
      (0x00008000L, 0xFFFF8000L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.SEXTH, test_cases))
  }
  "Zero Extend Half Word" in {
    val test_cases = Seq(
      (0x00007FFFL, 0x00007FFFL),
      (0x00008000L, 0x00008000L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.ZEXTH, test_cases))
  }

  "CLZ" in {
    val test_cases = Seq(
      (0L, 32L),
      (1L, 31L),
      (3L, 30L),
      (0xFFFF8000L, 0L),
      (0x00800000L, 8L),
      (0x00007FFFL, 17L),
      (0x7FFFFFFFL, 1L),
      (0x0007FFFFL, 13L),
      (0x80000000L, 0L),
      (0x121F5000L, 3L),
      (0x04000000L, 5L),
      (0x0000000EL, 28L),
      (0x20401341L, 2L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.CLZ, test_cases))
  }

  "CTZ" in {
    val test_cases = Seq(
      (0x00000000L, 32L),
      (0x00000001L, 0L),
      (0x00000003L, 0L),
      (0xffff8000L, 15L),
      (0x00800000L, 23L),
      (0x00007fffL, 0L),
      (0x7fffffffL, 0L),
      (0x0007ffffL, 0L),
      (0x80000000L, 31L),
      (0x121f5000L, 12L),
      (0xc0000000L, 30L),
      (0x0000000eL, 1L),
      (0x20401341L, 0L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.CTZ, test_cases))
  }

  "CPOP" in {
    val test_cases = Seq(
      (0x00000000L, 0L),
      (0x00000001L, 1L),
      (0x00000003L, 2L),
      (0xffff8000L, 17L),
      (0x00800000L, 1L),
      (0x00007fffL, 15L),
      (0x7fffffffL, 31L),
      (0x0007ffffL, 19L),
      (0x80000000L, 1L),
      (0x121f5000L, 9L),
      (0xc0000000L, 2L),
      (0x0000000eL, 3L),
      (0x20401341L, 7L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.CPOP, test_cases))
  }

  "ORCB" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L),
      (0x00000001L, 0x000000ffL),
      (0x00000003L, 0x000000ffL),
      (0xffff8000L, 0xffffff00L),
      (0x00800000L, 0x00ff0000L),
      (0xffff8000L, 0xffffff00L),
      (0x00007fffL, 0x0000ffffL),
      (0x7fffffffL, 0xffffffffL),
      (0x0007ffffL, 0x00ffffffL),
      (0x80000000L, 0xff000000L),
      (0x121f5000L, 0xffffff00L),
      (0x00000000L, 0x00000000L),
      (0x0000000EL, 0x000000FFL),
      (0x20401341L, 0xffffffffL),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.ORCB, test_cases))
  }

  "REV8" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L),
      (0x00000001L, 0x01000000L),
      (0x00000003L, 0x03000000L),
      (0xffff8000L, 0x0080ffffL),
      (0x00800000L, 0x00008000L),
      (0x00007fffL, 0xff7f0000L),
      (0x7fffffffL, 0xffffff7fL),
      (0x0007ffffL, 0xffff0700L),
      (0x80000000L, 0x00000080L),
      (0x121f5000L, 0x00501f12L),
      (0x0000000eL, 0x0e000000L),
      (0x20401341L, 0x41134020L),
    )
    simulate(new Alu(p))(test_unary_op(_, 13.U, AluOp.REV8, test_cases))
  }

  private def testBinaryOp(
      dut: Alu,
      addr: UInt,
      op: AluOp.Type,
      // Long because Scala has no unsigned int.
      cases: Seq[(Long, Long, Long)]) = {
    dut.io.req.valid.poke(true)
    dut.io.req.bits.addr.poke(addr)
    dut.io.req.bits.op.poke(op)
    val good = cases.map { case (rs1, rs2, exp_rd) =>
      dut.io.rs1.valid.poke(true)
      dut.io.rs1.data.poke(rs1)
      dut.io.rs2.valid.poke(true)
      dut.io.rs2.data.poke(rs2)
      dut.clock.step()
      (dut.io.rd.valid.peek().litValue == 1) && (dut.io.rd.bits.data.peek().litValue == exp_rd) && (dut.io.rd.bits.addr.peek().litValue == addr.litValue)
    }
    if (!ProcessTestResults(good, printfn = info(_))) fail()
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
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.XNOR, test_cases))
  }

  "ORN(Not OR)" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0xFFFFFFFFL),
      (0x00000000L, 0x12345678L, 0xEDCBA987L),
      (0x00000000L, 0xFFFFFFFFL, 0x00000000L),
      (0x12345678L, 0x00000000L, 0xFFFFFFFFL),
      (0x12345678L, 0x12345678L, 0xFFFFFFFFL),
      (0x12345678L, 0xFFFFFFFFL, 0x12345678L),
      (0xFFFFFFFFL, 0x00000000L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x12345678L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0xFFFFFFFFL, 0xFFFFFFFFL),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ORN, test_cases))
  }

  "ANDN(Not AND)" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0x00000000L),
      (0x00000000L, 0x12345678L, 0x00000000L),
      (0x00000000L, 0xFFFFFFFFL, 0x00000000L),
      (0x12345678L, 0x00000000L, 0x12345678L),
      (0x12345678L, 0x12345678L, 0x00000000L),
      (0x12345678L, 0xFFFFFFFFL, 0x00000000L),
      (0xFFFFFFFFL, 0x00000000L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x12345678L, 0xEDCBA987L),
      (0xFFFFFFFFL, 0xFFFFFFFFL, 0x00000000L),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ANDN, test_cases))
  }

  "MAX" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0x00000000L),
      (0x00000001L, 0x00000001L, 0x00000001L),
      (0x00000003L, 0x00000007L, 0x00000007L),
      (0x00000000L, 0xffff8000L, 0x00000000L),
      (0xffff8000L, 0x00000000L, 0x00000000L),
      (0x00000000L, 0x00007fffL, 0x00007fffL),
      (0x00007fffL, 0x00000000L, 0x00007fffL),
      (0x7fffffffL, 0x00000000L, 0x7fffffffL),
      (0x00000000L, 0x7fffffffL, 0x7fffffffL),
      (0x7fffffffL, 0x80000000L, 0x7fffffffL),
      (0xffffffffL, 0x00000001L, 0x00000001L),
      (0x00000001L, 0xffffffffL, 0x00000001L),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.MAX, test_cases))
  }

  "MAXU" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0x00000000L),
      (0x00000001L, 0x00000001L, 0x00000001L),
      (0x00000003L, 0x00000007L, 0x00000007L),
      (0x00000000L, 0xffff8000L, 0xffff8000L),
      (0xffff8000L, 0x00000000L, 0xffff8000L),
      (0x00000000L, 0x00007fffL, 0x00007fffL),
      (0x00007fffL, 0x00000000L, 0x00007fffL),
      (0x7fffffffL, 0x00000000L, 0x7fffffffL),
      (0x00000000L, 0x7fffffffL, 0x7fffffffL),
      (0x7fffffffL, 0x80000000L, 0x80000000L),
      (0xffffffffL, 0x00000001L, 0xffffffffL),
      (0x00000001L, 0xffffffffL, 0xffffffffL),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.MAXU, test_cases))
  }

  "MIN" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0x00000000L),
      (0x00000001L, 0x00000001L, 0x00000001L),
      (0x00000003L, 0x00000007L, 0x00000003L),
      (0x00000000L, 0xffff8000L, 0xffff8000L),
      (0xffff8000L, 0x00000000L, 0xffff8000L),
      (0x00000000L, 0x00007fffL, 0x00000000L),
      (0x00007fffL, 0x00000000L, 0x00000000L),
      (0x7fffffffL, 0x00000000L, 0x00000000L),
      (0x00000000L, 0x7fffffffL, 0x00000000L),
      (0x7fffffffL, 0x80000000L, 0x80000000L),
      (0xffffffffL, 0x00000001L, 0xffffffffL),
      (0x00000001L, 0xffffffffL, 0xffffffffL),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.MIN, test_cases))
  }

  "MINU" in {
    val test_cases = Seq(
      (0x00000000L, 0x00000000L, 0x00000000L),
      (0x00000001L, 0x00000001L, 0x00000001L),
      (0x00000003L, 0x00000007L, 0x00000003L),
      (0x00000000L, 0xffff8000L, 0x00000000L),
      (0xffff8000L, 0x00000000L, 0x00000000L),
      (0x00000000L, 0x00007fffL, 0x00000000L),
      (0x00007fffL, 0x00000000L, 0x00000000L),
      (0x7fffffffL, 0x00000000L, 0x00000000L),
      (0x00000000L, 0x7fffffffL, 0x00000000L),
      (0x7fffffffL, 0x80000000L, 0x7fffffffL),
      (0xffffffffL, 0x00000001L, 0x00000001L),
      (0x00000001L, 0xffffffffL, 0x00000001L),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.MINU, test_cases))
  }

  "ROL" in {
    val test_cases = Seq(
      (0x00000001L, 0x00000000L, 0x00000001L),
      (0x00000001L, 0x00000001L, 0x00000002L),
      (0x00000001L, 0x00000007L, 0x00000080L),
      (0x00000001L, 0x0000000EL, 0x00004000L),
      (0x00000001L, 0x0000001FL, 0x80000000L),
      (0xFFFFFFFFL, 0x00000000L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x00000001L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x00000007L, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x0000000EL, 0xFFFFFFFFL),
      (0xFFFFFFFFL, 0x0000001FL, 0xFFFFFFFFL),
      (0x21212121L, 0x00000000L, 0x21212121L),
      (0x21212121L, 0x00000001L, 0x42424242L),
      (0x21212121L, 0x00000007L, 0x90909090L),
      (0x21212121L, 0x0000000EL, 0x48484848L),
      (0x21212121L, 0x0000001FL, 0x90909090L),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ROL, test_cases))
  }

  "ROR" in {
    val test_cases = Seq(
      (0x00000001L, 0x00000000L, 0x00000001L),
      (0x00000001L, 0x00000001L, 0x80000000L),
      (0x00000001L, 0x00000007L, 0x02000000L),
      (0x00000001L, 0x0000000EL, 0x00040000L),
      (0x00000001L, 0x0000001FL, 0x00000002L),
      (0xFFFFFFFFL, 0x00000000L, 0xffffffffL),
      (0xFFFFFFFFL, 0x00000001L, 0xffffffffL),
      (0xFFFFFFFFL, 0x00000007L, 0xffffffffL),
      (0xFFFFFFFFL, 0x0000000EL, 0xffffffffL),
      (0xFFFFFFFFL, 0x0000001FL, 0xffffffffL),
      (0x21212121L, 0x00000000L, 0x21212121L),
      (0x21212121L, 0x00000001L, 0x90909090L),
      (0x21212121L, 0x00000007L, 0x42424242L),
      (0x21212121L, 0x0000000EL, 0x84848484L),
      (0x21212121L, 0x0000001FL, 0x42424242L),
    )
    simulate(new Alu(p))(testBinaryOp(_, 13.U, AluOp.ROR, test_cases))
  }
}
