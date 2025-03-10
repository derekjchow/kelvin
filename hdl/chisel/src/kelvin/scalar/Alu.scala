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
  val XNOR = Value
  val ORN  = Value
  val ANDN = Value
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
  val SEXTB = Value
  val SEXTH = Value
  val ZEXTH = Value
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
    val rd  = Valid(Flipped(new RegfileWriteDataIO))
  })

  val valid = RegInit(false.B)
  val addr = RegInit(0.U(5.W))
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
  io.rd.bits.addr  := addr

  val r2IsGreater = rs1.asSInt < rs2.asSInt
  val r2IsGreaterU = rs1 < rs2

  val rsWidth  = 32
  val rsWidthH = 32/2

  def SignExtend(x: UInt, length: Int): UInt = {
    val ext = Wire(SInt(length.W))
    ext := x.asSInt
    ext.asUInt
  }

  io.rd.bits.data  := MuxLookup(op, 0.U)(Seq(
    AluOp.ADD  -> (rs1 + rs2),
    AluOp.SUB  -> (rs1 - rs2),
    AluOp.SLT  -> (r2IsGreater),
    AluOp.SLTU -> (r2IsGreaterU),
    AluOp.XOR  -> (rs1 ^ rs2),
    AluOp.OR   -> (rs1 | rs2),
    AluOp.AND  -> (rs1 & rs2),
    AluOp.XNOR -> ~(rs1 ^ rs2),
    AluOp.ORN  -> (rs1 | ~rs2),
    AluOp.ANDN -> (rs1 & ~rs2),
    AluOp.SLL  -> (rs1 << shamt),
    AluOp.SRL  -> (rs1 >> shamt),
    AluOp.SRA  -> (rs1.asSInt >> shamt).asUInt,
    AluOp.LUI  -> rs2,
    AluOp.CLZ  -> Clz(rs1),
    AluOp.CTZ  -> Ctz(rs1),
    AluOp.PCNT -> PopCount(rs1),
    AluOp.MIN  -> Mux(r2IsGreater,  rs1, rs2),
    AluOp.MAX  -> Mux(r2IsGreater,  rs2, rs1),
    AluOp.MINU -> Mux(r2IsGreaterU, rs1, rs2),
    AluOp.MAXU -> Mux(r2IsGreaterU, rs2, rs1),
    AluOp.SEXTB -> SignExtend(rs1(7, 0), rsWidth),
    AluOp.SEXTH -> SignExtend(rs1(rsWidthH-1,0), rsWidth),
    AluOp.ZEXTH -> rs1(rsWidthH - 1, 0)
  ))


  // Assertions.
  val rs1Only = op.isOneOf(AluOp.CLZ, AluOp.CTZ, AluOp.PCNT, AluOp.ZEXTH, AluOp.SEXTH, AluOp.SEXTB)
  assert(!(valid && !io.rs1.valid && !op.isOneOf(AluOp.LUI)))
  assert(!(valid && !io.rs2.valid && !rs1Only))
}

object EmitAlu extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new Alu(p), args)
}
