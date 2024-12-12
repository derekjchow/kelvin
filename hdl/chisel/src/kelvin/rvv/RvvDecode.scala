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

package kelvin.rvv

import chisel3._
import chisel3.util._
import common.{ForceZero, MakeInvalid, MakeValid, MakeWireBundle}


object RvvCompressedOpcode extends ChiselEnum {
  val RVVLOAD = Value(0.U)
  val RVVSTORE = Value(1.U)
  val RVVALU = Value(2.U)
}

class RvvCompressedInstruction extends Bundle {
  val pc = UInt(32.W)
  val opcode = RvvCompressedOpcode()
  val bits = UInt(25.W)

  def funct6(): UInt = {
    bits(24, 19)
  }

  def funct3(): UInt = {
    bits(7, 5)
  }

  def readsRs1(): Bool = {
    (opcode =/= RvvCompressedOpcode.RVVALU) ||
        (bits(7) && (bits(24, 23) =/= "b11".U))
  }

  def writesRd(): Bool = {
    // TODO(derekjchow): Finish me
    (opcode === RvvCompressedOpcode.RVVALU && funct3 === "b111".U) ||
    (opcode === RvvCompressedOpcode.RVVALU && funct3 === "b010".U && funct6 === "b010000".U)
  }

  override def toPrintable: Printable = {
    cf"[opcode=$opcode, bits=$bits%b]"
  }
}

object RvvCompressedInstruction {
  def from_uncompressed(inst: UInt, pc: UInt): Valid[RvvCompressedInstruction] = {
    val old_opcode = inst(6, 0)
    val bits = inst(31, 7)

    val new_opcode = MuxLookup(old_opcode, MakeInvalid(RvvCompressedOpcode()))(Seq(
      "b0000111".U -> MakeValid(RvvCompressedOpcode.RVVLOAD),
      "b0100111".U -> MakeValid(RvvCompressedOpcode.RVVSTORE),
      "b1010111".U -> MakeValid(RvvCompressedOpcode.RVVALU),
    ))

    // Fancy way to MakeValid.
    MakeWireBundle[ValidIO[RvvCompressedInstruction]](
      Valid(new RvvCompressedInstruction),
      _.valid -> new_opcode.valid,
      _.bits.opcode -> new_opcode.bits,
      _.bits.pc -> pc,
      _.bits.bits -> bits,
    )
  }
}


class RvvS1DecodeInstructionBase {
  def invalid() = MakeInvalid(new RvvS1DecodedInstruction)

  private def s1decode_opivv(f6vm: UInt, vs2: UInt, vs1: UInt, vd: UInt): Valid[RvvS1DecodedInstruction] = {
    val no_overlap = (vd =/= vs1 && vd =/= vs2)
    val op = MuxCase(MakeInvalid(RvvAluOp()), Seq(
      // We're assuming all instructions are mask-optional unless the spec says otherwise.
      (f6vm === BitPat("b000000_?")) -> MakeValid(RvvAluOp.VADD),
      (f6vm === BitPat("b000010_?")) -> MakeValid(RvvAluOp.VSUB),
      // No VRSUB.
      (f6vm === BitPat("b000100_?")) -> MakeValid(RvvAluOp.VMINU),
      (f6vm === BitPat("b000101_?")) -> MakeValid(RvvAluOp.VMIN),
      (f6vm === BitPat("b000110_?")) -> MakeValid(RvvAluOp.VMAXU),
      (f6vm === BitPat("b000111_?")) -> MakeValid(RvvAluOp.VMAX),
      (f6vm === BitPat("b001001_?")) -> MakeValid(RvvAluOp.VAND),
      (f6vm === BitPat("b001010_?")) -> MakeValid(RvvAluOp.VOR),
      (f6vm === BitPat("b001011_?")) -> MakeValid(RvvAluOp.VXOR),
      (f6vm === BitPat("b001100_?")) -> MakeValid(no_overlap, RvvAluOp.VRGATHER),
      (f6vm === BitPat("b001110_?")) -> MakeValid(no_overlap, RvvAluOp.VRGATHEREI16),
      // No VSLIDEUP.
      // No VSLIDEDOWN.
      (f6vm === "b010000_0".U) -> MakeValid(vd =/= "b00000".U, RvvAluOp.VADC),  // Mask required.
      (f6vm === BitPat("b010001_?")) -> MakeValid(RvvAluOp.VMADC),
      (f6vm === "b010010_0".U) -> MakeValid(vd =/= "b00000".U, RvvAluOp.VSBC),  // Mask required.
      (f6vm === BitPat("b010011_?")) -> MakeValid(RvvAluOp.VMSBC),
      (f6vm === "b010111_0".U) -> MakeValid(RvvAluOp.VMERGE),  // Mask required.
      (f6vm === "b010111_1".U) -> MakeValid(RvvAluOp.VMV),  // Mask not available
      (f6vm === "b011000_0".U) -> MakeValid(RvvAluOp.VMSEQ),  // Mask required.
      (f6vm === "b011001_0".U) -> MakeValid(RvvAluOp.VMSNE),  // Mask required.
      (f6vm === "b011010_0".U) -> MakeValid(RvvAluOp.VMSLTU),  // Mask required.
      (f6vm === "b011011_0".U) -> MakeValid(RvvAluOp.VMSLT),  // Mask required.
      (f6vm === "b011100_0".U) -> MakeValid(RvvAluOp.VMSLEU),  // Mask required.
      (f6vm === "b011101_0".U) -> MakeValid(RvvAluOp.VMSLE),  // Mask required.
      // No VMSGTU.
      // No VMSGT.
      (f6vm === BitPat("b100000_?")) -> MakeValid(RvvAluOp.VSADDU),
      (f6vm === BitPat("b100001_?")) -> MakeValid(RvvAluOp.VSADD),
      (f6vm === BitPat("b100010_?")) -> MakeValid(RvvAluOp.VSSUBU),
      (f6vm === BitPat("b100011_?")) -> MakeValid(RvvAluOp.VSSUB),
      (f6vm === BitPat("b100101_?")) -> MakeValid(RvvAluOp.VSLL),
      (f6vm === BitPat("b100111_?")) -> MakeValid(RvvAluOp.VSMUL),
      // No VMV1R.
      // No VMV2R.
      // No VMV4R.
      // No VMV8R.
      (f6vm === BitPat("b101000_?")) -> MakeValid(RvvAluOp.VSRL),
      (f6vm === BitPat("b101001_?")) -> MakeValid(RvvAluOp.VSRA),
      (f6vm === BitPat("b101010_?")) -> MakeValid(RvvAluOp.VSSRL),
      (f6vm === BitPat("b101011_?")) -> MakeValid(RvvAluOp.VSSRA),
      (f6vm === BitPat("b101100_?")) -> MakeValid(RvvAluOp.VNSRL),
      (f6vm === BitPat("b101101_?")) -> MakeValid(RvvAluOp.VNSRA),
      (f6vm === BitPat("b101110_?")) -> MakeValid(RvvAluOp.VNCLIPU),
      (f6vm === BitPat("b101111_?")) -> MakeValid(RvvAluOp.VNCLIP),
    ))

    ForceZero(MakeWireBundle[ValidIO[RvvS1DecodedInstruction]](
      Valid(new RvvS1DecodedInstruction),
      _.valid -> op.valid,
      _.bits.op -> op.bits,
    ))
  }

  private def s1decode_opivx(f6vm: UInt, vs2: UInt, rs1: UInt, vd: UInt): Valid[RvvS1DecodedInstruction] = {
    val no_overlap = (vd =/= vs2)
    val op = MuxCase(MakeInvalid(RvvAluOp()), Seq(
      (f6vm === BitPat("b000000_?")) -> MakeValid(RvvAluOp.VADD),
      (f6vm === BitPat("b000010_?")) -> MakeValid(RvvAluOp.VSUB),
      (f6vm === BitPat("b000011_?")) -> MakeValid(RvvAluOp.VRSUB),
      (f6vm === BitPat("b000100_?")) -> MakeValid(RvvAluOp.VMINU),
      (f6vm === BitPat("b000101_?")) -> MakeValid(RvvAluOp.VMIN),
      (f6vm === BitPat("b000110_?")) -> MakeValid(RvvAluOp.VMAXU),
      (f6vm === BitPat("b000111_?")) -> MakeValid(RvvAluOp.VMAX),
      (f6vm === BitPat("b001001_?")) -> MakeValid(RvvAluOp.VAND),
      (f6vm === BitPat("b001010_?")) -> MakeValid(RvvAluOp.VOR),
      (f6vm === BitPat("b001011_?")) -> MakeValid(RvvAluOp.VXOR),
      (f6vm === BitPat("b001100_?")) -> MakeValid(no_overlap, RvvAluOp.VRGATHER),
      // No VRGATHEREI16.
      (f6vm === BitPat("b001110_?")) -> MakeValid(no_overlap, RvvAluOp.VSLIDEUP),
      (f6vm === BitPat("b001111_?")) -> MakeValid(no_overlap, RvvAluOp.VSLIDEDOWN),
      (f6vm === "b010000_0".U) -> MakeValid(vd =/= "b00000".U, RvvAluOp.VADC),  // Mask required.
      (f6vm === BitPat("b010001_?")) -> MakeValid(RvvAluOp.VMADC),
      (f6vm === "b010010_0".U) -> MakeValid(vd =/= "b00000".U, RvvAluOp.VSBC),  // Mask required.
      (f6vm === BitPat("b010011_?")) -> MakeValid(RvvAluOp.VMSBC),
      (f6vm === "b010111_0".U) -> MakeValid(RvvAluOp.VMERGE),  // Mask required.
      (f6vm === "b010111_1".U) -> MakeValid(vs2 === "b00000".U, RvvAluOp.VMV),  // Mask not available
      (f6vm === "b011000_0".U) -> MakeValid(RvvAluOp.VMSEQ),  // Mask required.
      (f6vm === "b011001_0".U) -> MakeValid(RvvAluOp.VMSNE),  // Mask required.
      (f6vm === "b011010_0".U) -> MakeValid(RvvAluOp.VMSLTU),  // Mask required.
      (f6vm === "b011011_0".U) -> MakeValid(RvvAluOp.VMSLT),  // Mask required.
      (f6vm === "b011100_0".U) -> MakeValid(RvvAluOp.VMSLEU),  // Mask required.
      (f6vm === "b011101_0".U) -> MakeValid(RvvAluOp.VMSLE),  // Mask required.
      (f6vm === "b011110_0".U) -> MakeValid(RvvAluOp.VMSGTU),  // Mask required.
      (f6vm === "b011111_0".U) -> MakeValid(RvvAluOp.VMSGT),  // Mask required.
      (f6vm === BitPat("b100000_?")) -> MakeValid(RvvAluOp.VSADDU),
      (f6vm === BitPat("b100001_?")) -> MakeValid(RvvAluOp.VSADD),
      (f6vm === BitPat("b100010_?")) -> MakeValid(RvvAluOp.VSSUBU),
      (f6vm === BitPat("b100011_?")) -> MakeValid(RvvAluOp.VSSUB),
      (f6vm === BitPat("b100101_?")) -> MakeValid(RvvAluOp.VSLL),
      (f6vm === BitPat("b100111_?")) -> MakeValid(RvvAluOp.VSMUL),
      // No VMV1R.
      // No VMV2R.
      // No VMV4R.
      // No VMV8R.
      (f6vm === BitPat("b101000_?")) -> MakeValid(RvvAluOp.VSRL),
      (f6vm === BitPat("b101001_?")) -> MakeValid(RvvAluOp.VSRA),
      (f6vm === BitPat("b101010_?")) -> MakeValid(RvvAluOp.VSSRL),
      (f6vm === BitPat("b101011_?")) -> MakeValid(RvvAluOp.VSSRA),
      (f6vm === BitPat("b101100_?")) -> MakeValid(RvvAluOp.VNSRL),
      (f6vm === BitPat("b101101_?")) -> MakeValid(RvvAluOp.VNSRA),
      (f6vm === BitPat("b101110_?")) -> MakeValid(RvvAluOp.VNCLIPU),
      (f6vm === BitPat("b101111_?")) -> MakeValid(RvvAluOp.VNCLIP),
    ))

    ForceZero(MakeWireBundle[ValidIO[RvvS1DecodedInstruction]](
      Valid(new RvvS1DecodedInstruction),
      _.valid -> op.valid,
      _.bits.op -> op.bits,
    ))
  }

  private def s1decode_opivi(f6vm: UInt, vs2: UInt, imm5: UInt, vd: UInt): Valid[RvvS1DecodedInstruction] = {
    val no_overlap = (vd =/= vs2)
    val unary_align2 = (vd === BitPat("b????0")) && (vs2 === BitPat("b????0"))
    val unary_align4 = (vd === BitPat("b???00")) && (vs2 === BitPat("b???00"))
    val unary_align8 = (vd === BitPat("b??000")) && (vs2 === BitPat("b??000"))
    val op = MuxCase(MakeInvalid(RvvAluOp()), Seq(
      (f6vm === BitPat("b000000_?")) -> MakeValid(RvvAluOp.VADD),
      // No VSUB.
      (f6vm === BitPat("b000011_?")) -> MakeValid(RvvAluOp.VRSUB),
      // No VMINU.
      // No VMIN.
      // No VMAXU.
      // No VMAX.
      (f6vm === BitPat("b001001_?")) -> MakeValid(RvvAluOp.VAND),
      (f6vm === BitPat("b001010_?")) -> MakeValid(RvvAluOp.VOR),
      (f6vm === BitPat("b001011_?")) -> MakeValid(RvvAluOp.VXOR),
      (f6vm === BitPat("b001100_?")) -> MakeValid(no_overlap, RvvAluOp.VRGATHER),
      // No VRGATHEREI16.
      (f6vm === BitPat("b001110_?")) -> MakeValid(no_overlap, RvvAluOp.VSLIDEUP),
      (f6vm === BitPat("b001111_?")) -> MakeValid(no_overlap, RvvAluOp.VSLIDEDOWN),
      (f6vm === "b010000_0".U) -> MakeValid(vd =/= "b00000".U, RvvAluOp.VADC),  // Mask required.
      (f6vm === BitPat("b010001_?")) -> MakeValid(RvvAluOp.VMADC),
      // No VSBC.
      // No VMSBC.
      (f6vm === "b010111_0".U) -> MakeValid(RvvAluOp.VMERGE),  // Mask required.
      (f6vm === "b010111_1".U) -> MakeValid(vs2 === "b00000".U, RvvAluOp.VMV),  // Mask not available.
      (f6vm === "b011000_0".U) -> MakeValid(RvvAluOp.VMSEQ),  // Mask required.
      (f6vm === "b011001_0".U) -> MakeValid(RvvAluOp.VMSNE),  // Mask required.
      // No VMSLTU.
      // No VMSLT.
      (f6vm === "b011100_0".U) -> MakeValid(RvvAluOp.VMSLEU),  // Mask required.
      (f6vm === "b011101_0".U) -> MakeValid(RvvAluOp.VMSLE),  // Mask required.
      (f6vm === "b011110_0".U) -> MakeValid(RvvAluOp.VMSGTU),  // Mask required.
      (f6vm === "b011111_0".U) -> MakeValid(RvvAluOp.VMSGT),  // Mask required.
      (f6vm === BitPat("b100000_?")) -> MakeValid(RvvAluOp.VSADDU),
      (f6vm === BitPat("b100001_?")) -> MakeValid(RvvAluOp.VSADD),
      // No VSSUBU.
      // No VSSUB.
      (f6vm === BitPat("b100101_?")) -> MakeValid(RvvAluOp.VSLL),
      // No VSMUL.
      // TODO(davidgao): the 4 entries below looks ugly. Consider merging them into one function call.
      (f6vm === "b100111_1".U && imm5 === "b00000".U) -> MakeValid(RvvAluOp.VMV1R),  // Mask not available.
      (f6vm === "b100111_1".U && imm5 === "b00001".U) -> MakeValid(unary_align2, RvvAluOp.VMV2R),  // Mask not available.
      (f6vm === "b100111_1".U && imm5 === "b00011".U) -> MakeValid(unary_align4, RvvAluOp.VMV4R),  // Mask not available.
      (f6vm === "b100111_1".U && imm5 === "b00111".U) -> MakeValid(unary_align8, RvvAluOp.VMV8R),  // Mask not available.
      (f6vm === BitPat("b101000_?")) -> MakeValid(RvvAluOp.VSRL),
      (f6vm === BitPat("b101001_?")) -> MakeValid(RvvAluOp.VSRA),
      (f6vm === BitPat("b101010_?")) -> MakeValid(RvvAluOp.VSSRL),
      (f6vm === BitPat("b101011_?")) -> MakeValid(RvvAluOp.VSSRA),
      (f6vm === BitPat("b101100_?")) -> MakeValid(RvvAluOp.VNSRL),
      (f6vm === BitPat("b101101_?")) -> MakeValid(RvvAluOp.VNSRA),
      (f6vm === BitPat("b101110_?")) -> MakeValid(RvvAluOp.VNCLIPU),
      (f6vm === BitPat("b101111_?")) -> MakeValid(RvvAluOp.VNCLIP),
    ))

    ForceZero(MakeWireBundle[ValidIO[RvvS1DecodedInstruction]](
      Valid(new RvvS1DecodedInstruction),
      _.valid -> op.valid,
      _.bits.op -> op.bits,
    ))
  }

  protected def s1decode_opv(bits: UInt): Valid[RvvS1DecodedInstruction] = {
    // 7 LSB have already been consumed, 25 bits left.
    val vd = bits(4, 0)  // Or rd where applicable.
    val mode = bits(7, 5)
    val vs1 = bits(12, 8)  // Or rs1, or imm5, where applicable.
    val vs2 = bits(17, 13)  // Does not apply to 2 of the 3 config ops.
    val f6vm = bits(24, 18)  // Does not apply to config ops.
    // TODO: 24:13 for config ops

    MuxLookup(mode, invalid())(Seq(
      "b000".U -> s1decode_opivv(f6vm, vs2, vs1, vd),
      "b011".U -> s1decode_opivi(f6vm, vs2, vs1, vd),
      "b100".U -> s1decode_opivx(f6vm, vs2, vs1, vd),
    ))
  }
}

object RvvS1DecodeInstruction extends RvvS1DecodeInstructionBase {
  // RVV is an extension and does not directly handle undefined (illegal)
  // instructions.
  def apply(inst: UInt): Valid[RvvS1DecodedInstruction] = {
    // All instructions are 32 bits and all have 7-bit opcodes.
    val opcode = inst(6, 0)
    val bits = inst(31, 7)
    MuxLookup(opcode, invalid())(Seq(
      "b1010111".U -> s1decode_opv(bits),
      "b0000111".U -> invalid(),  // TODO LOAD-FP
      "b0100111".U -> invalid(),  // TODO STORE-FP
    ))
  }
}


object RvvS1DecodeCompressedInstruction extends RvvS1DecodeInstructionBase {
  // RVV is an extension and does not directly handle undefined (illegal)
  // instructions. This compressed format is only used within some of our
  // cores, and never exposed to sw.
  def apply(inst: RvvCompressedInstruction): Valid[RvvS1DecodedInstruction] = {
    // All instructions are 2-bit opcode plus 25 bits for further decoding.
    MuxLookup(inst.opcode, invalid())(Seq(
      RvvCompressedOpcode.RVVLOAD -> invalid(),  // TODO: implement this
      RvvCompressedOpcode.RVVSTORE -> invalid(),  // TODO: implement this
      RvvCompressedOpcode.RVVALU -> s1decode_opv(inst.bits),
    ))
  }

  def apply(inst: Valid[RvvCompressedInstruction]): Valid[RvvS1DecodedInstruction] = {
    // Wrapper to emit invalid output for invalid input.
    Mux(inst.valid, apply(inst.bits), MakeInvalid(new RvvS1DecodedInstruction))
  }
}
