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

object Alu {
  def apply(p: Parameters): Alu = {
    return Module(new Alu(p))
  }
}

object AluOp extends ChiselEnum {
  val ADD  = Value
  val SUB  = Value
  val SLT  = Value
  val SLTU = Value
  val XOR  = Value
  val OR   = Value
  val AND  = Value
  val SLL  = Value
  val SRL  = Value
  val SRA  = Value
  val LUI  = Value
  val CLZ  = Value
  val CTZ  = Value
  val PCNT = Value
  val MIN  = Value
  val MINU = Value
  val MAX  = Value
  val MAXU = Value
}

class AluCmd extends Bundle {
  val addr = UInt(5.W)
  val op = AluOp()
}

class Alu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Flipped(Valid(new AluCmd))

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rs2 = Flipped(new RegfileReadDataIO)
    val rd  = Flipped(new RegfileWriteDataIO)
  })

  val valid = RegInit(false.B)
  val addr = Reg(UInt(5.W))
  val op = RegInit(AluOp.ADD)

  // Pulse the cycle after the decoded request.
  valid := io.req.valid

  // Avoid output toggles by not updating state between uses.
  // The Regfile has the same behavior, leaving read ports unchanged.
  when (io.req.valid) {
    addr := io.req.bits.addr
    op := io.req.bits.op
  }

  val rs1 = io.rs1.data
  val rs2 = io.rs2.data
  val shamt = rs2(4,0)

  io.rd.valid := valid
  io.rd.addr  := addr

  io.rd.data  := MuxLookup(op, 0.U)(Seq(
      AluOp.ADD  -> (rs1 + rs2),
      AluOp.SUB  -> (rs1 - rs2),
      AluOp.SLT  -> (rs1.asSInt < rs2.asSInt),
      AluOp.SLTU -> (rs1 < rs2),
      AluOp.XOR  -> (rs1 ^ rs2),
      AluOp.OR   -> (rs1 | rs2),
      AluOp.AND  -> (rs1 & rs2),
      AluOp.SLL  -> (rs1 << shamt),
      AluOp.SRL  -> (rs1 >> shamt),
      AluOp.SRA  -> (rs1.asSInt >> shamt).asUInt,
      AluOp.LUI  -> rs2,
      AluOp.CLZ  -> Clz(rs1),
      AluOp.CTZ  -> Ctz(rs1),
      AluOp.PCNT -> PopCount(rs1),
      AluOp.MIN  -> Mux(rs1.asSInt < rs2.asSInt, rs1, rs2),
      AluOp.MAX  -> Mux(rs1.asSInt > rs2.asSInt, rs1, rs2),
      AluOp.MINU -> Mux(rs1 < rs2, rs1, rs2),
      AluOp.MAXU -> Mux(rs1 > rs2, rs1, rs2)
  ))

  // Assertions.
  assert(!(valid && !io.rs1.valid && !op.isOneOf(AluOp.LUI)))
  assert(!(valid && !io.rs2.valid))
}
