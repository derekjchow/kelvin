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

case class AluOp() {
  val ADD  = 0
  val SUB  = 1
  val SLT  = 2
  val SLTU = 3
  val XOR  = 4
  val OR   = 5
  val AND  = 6
  val SLL  = 7
  val SRL  = 8
  val SRA  = 9
  val LUI  = 10
  val CLZ  = 11
  val CTZ  = 12
  val PCNT = 13
  val MIN  = 14
  val MINU = 15
  val MAX  = 16
  val MAXU = 17
  val Entries = 18
}

class AluIO(p: Parameters) extends Bundle {
  val valid = Input(Bool())
  val addr = Input(UInt(5.W))
  val op = Input(UInt(new AluOp().Entries.W))
}

class Alu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = new AluIO(p)

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rs2 = Flipped(new RegfileReadDataIO)
    val rd  = Flipped(new RegfileWriteDataIO)
  })

  val alu = new AluOp()

  val valid = RegInit(false.B)
  val addr = Reg(UInt(5.W))
  val op = RegInit(0.U(alu.Entries.W))

  // Pulse the cycle after the decoded request.
  valid := io.req.valid

  // Avoid output toggles by not updating state between uses.
  // The Regfile has the same behavior, leaving read ports unchanged.
  when (io.req.valid) {
    addr := io.req.addr
    op := io.req.op
  }

  // val rs1 = MuxOR(valid, io.rs1.data)
  // val rs2 = MuxOR(valid, io.rs2.data)
  val rs1 = io.rs1.data
  val rs2 = io.rs2.data
  val shamt = rs2(4,0)

  // TODO: should we be masking like this for energy?
  // TODO: a single addsub for add/sub/slt/sltu
  // val add  = MuxOR(op(alu.ADD), rs1) +  MuxOR(op(alu.ADD), rs2)
  // val sub  = MuxOR(op(alu.SUB), rs1) -  MuxOR(op(alu.SUB), rs2)
  // val sll  = MuxOR(op(alu.SLL), rs1) << MuxOR(op(alu.SLL), shamt)
  // val srl  = MuxOR(op(alu.SRL), rs1) >> MuxOR(op(alu.SRL), shamt)
  // val sra  = (MuxOR(op(alu.SRA), rs1.asSInt, 0.S) >> MuxOR(op(alu.SRA), shamt)).asUInt
  // val slt  = MuxOR(op(alu.SLT), rs1.asSInt, 0.S) < MuxOR(op(alu.SLT), rs2.asSInt, 0.S)
  // val sltu = MuxOR(op(alu.SLTU), rs1) < MuxOR(op(alu.SLTU), rs2)
  // val and  = MuxOR(op(alu.AND), rs1) &  MuxOR(op(alu.AND), rs2)
  // val or   = MuxOR(op(alu.OR), rs1) |  MuxOR(op(alu.OR), rs2)
  // val xor  = MuxOR(op(alu.XOR), rs1) ^  MuxOR(op(alu.XOR), rs2)
  // val lui  = MuxOR(op(alu.LUI), rs2)
  // val clz  = MuxOR(op(alu.CLZ), CLZ(rs1))
  // val ctz  = MuxOR(op(alu.CTZ), CTZ(rs1))
  // val pcnt = MuxOR(op(alu.PCNT), PopCount(rs1))

  // io.rd.data := add | sub | sll | srl | sra | slt | sltu | and | or | xor | lui

  io.rd.valid := valid
  io.rd.addr  := addr
  io.rd.data  := MuxOR(op(alu.ADD),  rs1 + rs2) |
                 MuxOR(op(alu.SUB),  rs1 - rs2) |
                 MuxOR(op(alu.SLT),  rs1.asSInt < rs2.asSInt) |
                 MuxOR(op(alu.SLTU), rs1 < rs2) |
                 MuxOR(op(alu.XOR),  rs1 ^ rs2) |
                 MuxOR(op(alu.OR),   rs1 | rs2) |
                 MuxOR(op(alu.AND),  rs1 & rs2) |
                 MuxOR(op(alu.SLL),  rs1 << shamt) |
                 MuxOR(op(alu.SRL),  rs1 >> shamt) |
                 MuxOR(op(alu.SRA),  (rs1.asSInt >> shamt).asUInt) |
                 MuxOR(op(alu.LUI),  rs2) |
                 MuxOR(op(alu.CLZ),  Clz(rs1)) |
                 MuxOR(op(alu.CTZ),  Ctz(rs1)) |
                 MuxOR(op(alu.PCNT), PopCount(rs1)) |
                 MuxOR(op(alu.MIN),  Mux(rs1.asSInt < rs2.asSInt, rs1, rs2)) |
                 MuxOR(op(alu.MAX),  Mux(rs1.asSInt > rs2.asSInt, rs1, rs2)) |
                 MuxOR(op(alu.MINU), Mux(rs1 < rs2, rs1, rs2)) |
                 MuxOR(op(alu.MAXU), Mux(rs1 > rs2, rs1, rs2))

  // Assertions.
  assert(!(valid && !io.rs1.valid && !op(alu.LUI)))
  assert(!(valid && !io.rs2.valid))
}
