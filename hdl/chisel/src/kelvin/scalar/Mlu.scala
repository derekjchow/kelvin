// Copyright 2023 Google LLC
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
import common._
import _root_.circt.stage.ChiselStage

object Mlu {
  def apply(p: Parameters): Mlu = {
    return Module(new Mlu(p))
  }
}

object MluOp extends ChiselEnum {
  val MUL = Value
  val MULH = Value
  val MULHSU = Value
  val MULHU = Value
  val MULHR = Value
  val MULHSUR = Value
  val MULHUR = Value
  val DMULH = Value
  val DMULHR = Value
  val Entries = Value
}

class MluCmd extends Bundle {
  val addr = UInt(5.W)
  val op = MluOp()
}

class Mlu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Flipped(Vec(4, Valid(new MluCmd)))

    // Execute cycle.
    val rs1 = Vec(4, Flipped(new RegfileReadDataIO))
    val rs2 = Vec(4, Flipped(new RegfileReadDataIO))
    val rd  = Flipped(new RegfileWriteDataIO)
  })

  val op = Reg(MluOp())
  val valid1 = RegInit(false.B)
  val valid2 = RegInit(false.B)
  val addr1 = Reg(UInt(5.W))
  val addr2 = Reg(UInt(5.W))
  val sel = Reg(UInt(4.W))

  valid1 := io.req.map(_.valid).reduce(_||_)
  valid2 := valid1

  when (io.req(0).valid) {
    op := io.req(0).bits.op
    addr1 := io.req(0).bits.addr
    sel := 1.U
  } .elsewhen (io.req(1).valid) {
    op := io.req(1).bits.op
    addr1 := io.req(1).bits.addr
    sel := 2.U
  } .elsewhen (io.req(2).valid) {
    op := io.req(2).bits.op
    addr1 := io.req(2).bits.addr
    sel := 4.U
  } .elsewhen (io.req(3).valid) {
    op := io.req(3).bits.op
    addr1 := io.req(3).bits.addr
    sel := 8.U
  }

  val rs1 = MuxOR(valid1 & sel(0), io.rs1(0).data) |
            MuxOR(valid1 & sel(1), io.rs1(1).data) |
            MuxOR(valid1 & sel(2), io.rs1(2).data) |
            MuxOR(valid1 & sel(3), io.rs1(3).data)

  val rs2 = MuxOR(valid1 & sel(0), io.rs2(0).data) |
            MuxOR(valid1 & sel(1), io.rs2(1).data) |
            MuxOR(valid1 & sel(2), io.rs2(2).data) |
            MuxOR(valid1 & sel(3), io.rs2(3).data)

  // Multiplier has a registered output.
  val mul2 = Reg(UInt(32.W))
  val round2 = Reg(UInt(1.W))

  when (valid1) {
    val rs2signed = op.isOneOf(MluOp.MULH, MluOp.MULHR, MluOp.DMULH, MluOp.DMULHR)
    val rs1signed = op.isOneOf(MluOp.MULHSU, MluOp.MULHSUR) || rs2signed
    val rs1s = Cat(rs1signed && rs1(31), rs1).asSInt
    val rs2s = Cat(rs2signed && rs2(31), rs2).asSInt
    val prod = rs1s.asSInt * rs2s.asSInt
    assert(prod.getWidth == 66)

    addr2 := addr1
    round2 := prod(30) && op.isOneOf(MluOp.DMULHR) ||
              prod(31) && (op.isOneOf(MluOp.MULHR, MluOp.MULHSUR, MluOp.MULHUR))

    when (op === MluOp.MUL) {
      mul2 := prod(31,0)
    } .elsewhen (op.isOneOf(MluOp.MULH, MluOp.MULHSU, MluOp.MULHU, MluOp.MULHR, MluOp.MULHSUR, MluOp.MULHUR)) {
      mul2 := prod(63,32)
    } .elsewhen (op.isOneOf(MluOp.DMULH, MluOp.DMULHR)) {
      val maxneg = 2.U(2.W)
      val halfneg = 1.U(2.W)
      val sat = rs1(29,0) === 0.U && rs2(29,0) === 0.U &&
                (rs1(31,30) === maxneg && rs2(31,30) === maxneg ||
                 rs1(31,30) === maxneg && rs2(31,30) === halfneg ||
                 rs2(31,30) === maxneg && rs1(31,30) === halfneg)
      when (sat) {
        when (prod(65)) {
          mul2 := 0x7fffffff.U(32.W)
        } .otherwise {
          mul2 := Cat(1.U(1.W), 0.U(31.W))
        }
      } .otherwise {
        mul2 := prod(62,31)
      }
    }
  }

  io.rd.valid := valid2
  io.rd.addr  := addr2
  io.rd.data  := mul2 + round2

  // Assertions.
  for (i <- 0 until 4) {
    assert(!(valid1 && sel(i) && !io.rs1(i).valid))
    assert(!(valid1 && sel(i) && !io.rs2(i).valid))
  }
}

object EmitMlu extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new Mlu(p), args)
}
