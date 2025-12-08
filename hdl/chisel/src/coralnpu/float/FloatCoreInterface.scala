// Copyright 2025 Google LLC
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

package coralnpu.float

import common.{MakeWireBundle, MakeValid, MakeInvalid}
import chisel3._
import chisel3.util._
import coralnpu.{FRegfileRead, FRegfileWrite, RegfileReadDataIO, RegfileWriteDataIO, Parameters}

class CsrFloatIO(p: Parameters) extends Bundle {
  val in = new Bundle {
    val fflags = Valid(UInt(5.W))
  }
  val out = Input(new Bundle {
    val frm = UInt(3.W)
  })
}

// Bits (6,2) from the instruction
object FloatOpcode extends ChiselEnum {
    val LOADFP = Value
    val STOREFP = Value
    val OPFP = Value
    val MADD = Value
    val MSUB = Value
    val NMADD = Value
    val NMSUB = Value
}

class FloatInstruction extends Bundle {
    val opcode = FloatOpcode()
    val funct5 = UInt(5.W)
    val rs3 = UInt(5.W)
    val rs2 = UInt(5.W)
    val rs1 = UInt(5.W)
    val rm = UInt(3.W)
    val inst = UInt(32.W)
    val pc = UInt(32.W)
    val scalar_rd = Bool()
    val scalar_rs1 = Bool()
    val float_rs1 = Bool()
    val rd = UInt(5.W)
    val uses_rs3 = Bool()
    val uses_rs2 = Bool()

    def valid_frm(csr_rm: UInt): Bool = {
      assert(csr_rm.getWidth == 3)
      (rm <= 4.U) ||                          // Instruction FRM is valid
      ((rm === "b111".U) && (csr_rm <= 4.U)) // CSR is valid
    }

    def requires_frm(): Bool = {
      opcode.isOneOf(FloatOpcode.MADD,
                     FloatOpcode.MSUB,
                     FloatOpcode.NMSUB,
                     FloatOpcode.NMADD) ||
      ((opcode === FloatOpcode.OPFP) && (
        (funct5 === "b00000".U) || // fadd
        (funct5 === "b00001".U) || // fsub
        (funct5 === "b00010".U) || // fmul
        (funct5 === "b00011".U) || // fdiv
        (funct5 === "b00100".U) || // fsqrt
        (funct5 === "b11010".U)    // fcvt (both f->x and x->f)
      ))
    }

    // Validates that the instruction has a valid FRM, or does not depend on it.
    def validate_csrfrm(csr_rm: UInt): Bool = {
      !requires_frm() || valid_frm(csr_rm)
    }
}

object FloatInstruction {
  def decode(inst: UInt, addr: UInt): Valid[FloatInstruction] = {
    val in_opcode = inst(6,2)
    // `fmt` is always 0 for FP32
    val fmt = inst(26,25)
    val funct5 = inst(31,27)
    val rs3 = inst(31,27)
    val rs2 = inst(24,20)
    val rs1 = inst(19,15)
    val rm = inst(14,12)
    val rd = inst(11,7)

    // Guard load/store by the `width` field (encoded in `rm`).
    // Other values are reserved for D, Q, and V extensions.
    val load_store_rm_valid = (rm === "b01".U) || (rm === "b10".U)
    val opcode = MuxLookup(in_opcode, MakeInvalid(FloatOpcode()))(Seq(
        "b00001".U -> Mux(load_store_rm_valid, MakeValid(FloatOpcode.LOADFP), MakeInvalid(FloatOpcode())),
        "b01001".U -> Mux(load_store_rm_valid, MakeValid(FloatOpcode.STOREFP), MakeInvalid(FloatOpcode())),
        "b10100".U -> MakeValid(FloatOpcode.OPFP),
        "b10000".U -> MakeValid(FloatOpcode.MADD),
        "b10001".U -> MakeValid(FloatOpcode.MSUB),
        "b10010".U -> MakeValid(FloatOpcode.NMSUB),
        "b10011".U -> MakeValid(FloatOpcode.NMADD),
    ))

    // TODO(atv): Hook scalar_rd and scalar_rs1 into scalar scoreboard
    // TODO(atv): FMV and FCLASS match the same... do we need to check RM too?
    val scalar_rd = MuxLookup(funct5, false.B)(Seq(
        "b11100".U -> true.B, // FMV.X.W
        "b10100".U -> true.B, // FEQ, FLT, FLE
        "b11100".U -> true.B, // FCLASS
        "b11000".U -> true.B, // FCVT.W.S
    )) && (opcode.bits === FloatOpcode.OPFP)

    val scalar_rs1 = MuxLookup(funct5, false.B)(Seq(
        "b11110".U -> true.B, // FMV.W.X
        "b11010".U -> true.B, // FCVT.S.W
    ))

    val uses_rs3 = opcode.bits.isOneOf(FloatOpcode.MADD, FloatOpcode.MSUB, FloatOpcode.NMADD, FloatOpcode.NMSUB)
    val uses_rs2 = opcode.bits.isOneOf(FloatOpcode.STOREFP) || ((opcode.bits === FloatOpcode.OPFP) && MuxLookup(funct5, true.B)(Seq(
      "b11100".U -> false.B, // FMV.X.W
      "b11100".U -> false.B, // FCLASS
      "b11000".U -> false.B, // FCVT.W.S
      "b11110".U -> false.B, // FMV.W.X
      "b11010".U -> false.B, // FCVT.S.W
      "b01011".U -> false.B, // FSQRT.W
    )))
    // All float instructions EXCEPT loads, stores, fmv.w.x, and fcvt.s.w, use float rs1.
    val float_rs1 = !opcode.bits.isOneOf(FloatOpcode.STOREFP, FloatOpcode.LOADFP) && !scalar_rs1

    MakeWireBundle[ValidIO[FloatInstruction]](
      Valid(new FloatInstruction),
      // Non-load/store must have fmt == 2
      _.valid -> (opcode.valid && (opcode.bits === FloatOpcode.LOADFP || opcode.bits === FloatOpcode.STOREFP || (fmt === 0.U(2.W)))),
      _.bits.opcode -> opcode.bits,
      _.bits.funct5 -> funct5,
      _.bits.rs3 -> rs3,
      _.bits.rs2 -> rs2,
      _.bits.rs1 -> rs1,
      _.bits.rm -> rm,
      _.bits.inst -> inst,
      _.bits.pc -> addr,
      _.bits.scalar_rd -> scalar_rd,
      _.bits.scalar_rs1 -> scalar_rs1,
      _.bits.float_rs1 -> float_rs1,
      _.bits.rd -> rd,
      _.bits.uses_rs3 -> uses_rs3,
      _.bits.uses_rs2 -> uses_rs2,
    )
  }
}

class FloatCoreIO(p: Parameters) extends Bundle {
  // Decode
  val inst = Flipped(Decoupled(new FloatInstruction))
  val read_ports = Flipped(Vec(3, new FRegfileRead))
  val write_ports = Flipped(Vec(2, new FRegfileWrite))

  // Execute
  val rs1 = Flipped(new RegfileReadDataIO)
  val rs2 = Flipped(new RegfileReadDataIO)
  val scalar_rd = Decoupled(new RegfileWriteDataIO)
  val csr = new CsrFloatIO(p)
  val lsu_rd = Flipped(Valid(new RegfileWriteDataIO))
}