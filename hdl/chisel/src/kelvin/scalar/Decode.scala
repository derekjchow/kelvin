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


// Decode: Contains decode logic to be forwarded to the appropriate functional
// block. A serialization mechanism is introduced to stall a decoded instruction
// from bring presented to the functional block until next cycle if the block has
// already been presented with an instruction from another decoder.

package kelvin

import chisel3._
import chisel3.util._
import common._

object Decode {
  def apply(p: Parameters, pipeline: Int): Decode = {
    return Module(new Decode(p, pipeline))
  }
}

class DecodeSerializeIO extends Bundle {
  val lsu = Output(Bool())
  val mul = Output(Bool())
  val jump = Output(Bool())
  val brcond = Output(Bool())
  val vinst = Output(Bool())     // all vector instructions

  def defaults() = {
    lsu := false.B
    mul := false.B
    jump := false.B
    brcond := false.B
    vinst := false.B
  }
}

class DecodedInstruction extends Bundle {
  // Immediates
  val imm12  = UInt(32.W)
  val imm20  = UInt(32.W)
  val immjal = UInt(32.W)
  val immbr  = UInt(32.W)
  val immcsr = UInt(32.W)
  val immst  = UInt(32.W)

  // RV32I
  val lui   = Bool()
  val auipc = Bool()
  val jal   = Bool()
  val jalr  = Bool()
  val beq   = Bool()
  val bne   = Bool()
  val blt   = Bool()
  val bge   = Bool()
  val bltu  = Bool()
  val bgeu  = Bool()
  val csrrw = Bool()
  val csrrs = Bool()
  val csrrc = Bool()
  val lb    = Bool()
  val lh    = Bool()
  val lw    = Bool()
  val lbu   = Bool()
  val lhu   = Bool()
  val sb    = Bool()
  val sh    = Bool()
  val sw    = Bool()
  val fence = Bool()
  val addi  = Bool()
  val slti  = Bool()
  val sltiu = Bool()
  val xori  = Bool()
  val ori   = Bool()
  val andi  = Bool()
  val slli  = Bool()
  val srli  = Bool()
  val srai  = Bool()
  val add   = Bool()
  val sub   = Bool()
  val slt   = Bool()
  val sltu  = Bool()
  val xor   = Bool()
  val or    = Bool()
  val and   = Bool()
  val sll   = Bool()
  val srl   = Bool()
  val sra   = Bool()

  // RV32M
  val mul     = Bool()
  val mulh    = Bool()
  val mulhsu  = Bool()
  val mulhu   = Bool()
  val mulhr   = Bool()
  val mulhsur = Bool()
  val mulhur  = Bool()
  val dmulh   = Bool()
  val dmulhr  = Bool()
  val div     = Bool()
  val divu    = Bool()
  val rem     = Bool()
  val remu    = Bool()

  // RV32B
  val clz  = Bool()
  val ctz  = Bool()
  val pcnt = Bool()
  val min  = Bool()
  val minu = Bool()
  val max  = Bool()
  val maxu = Bool()

  // Vector instructions.
  val getvl = Bool()
  val getmaxvl = Bool()
  val vld = Bool()
  val vst = Bool()
  val viop = Bool()

  // Core controls.
  val ebreak = Bool()
  val ecall  = Bool()
  val eexit  = Bool()
  val eyield = Bool()
  val ectxsw = Bool()
  val mpause = Bool()
  val mret   = Bool()
  val undef  = Bool()

  // Fences.
  val fencei = Bool()
  val flushat = Bool()
  val flushall = Bool()

  // Scalar logging.
  val slog = Bool()

  def isAluImm(): Bool = {
      addi || slti || sltiu || xori || ori || andi || slli || srli || srai
  }
  def isAluReg(): Bool = {
      add || sub || slt || sltu || xor || or || and || sll || srl || sra
  }
  def isAlu1Bit(): Bool = { clz || ctz || pcnt }
  def isAlu2Bit(): Bool = { min || minu || max || maxu }
  def isCsr(): Bool = { csrrw || csrrs || csrrc }
  def isCondBr(): Bool = { beq || bne || blt || bge || bltu || bgeu }
  def isLoad(): Bool = { lb || lh || lw || lbu || lhu }
  def isStore(): Bool = { sb || sh || sw }
  def isLsu(): Bool = { isLoad() || isStore() || vld || vst || flushat || flushall }
  def isMul(): Bool = { mul || mulh || mulhsu || mulhu || mulhr || mulhsur || mulhur || dmulh || dmulhr }
  def isDvu(): Bool = { div || divu || rem || remu }
  def isVector(): Bool = { vld || vst || viop || getvl || getmaxvl }
}

class Decode(p: Parameters, pipeline: Int) extends Module {
  val io = IO(new Bundle {
    // Core controls.
    val halted = Input(Bool())

    // Decode input interface.
    val inst = Flipped(new FetchInstruction(p))
    val scoreboard = new Bundle {
      val regd = Input(UInt(32.W))
      val comb = Input(UInt(32.W))
      val spec = Output(UInt(32.W))
    }
    val mactive = Input(Bool())  // memory active

    // Register file decode cycle interface.
    val rs1Read = Flipped(new RegfileReadAddrIO)
    val rs1Set  = Flipped(new RegfileReadSetIO)
    val rs2Read = Flipped(new RegfileReadAddrIO)
    val rs2Set  = Flipped(new RegfileReadSetIO)
    val rdMark  = Flipped(new RegfileWriteAddrIO)
    val busRead = Flipped(new RegfileBusAddrIO)

    // ALU interface.
    val alu = Valid(new AluCmd)

    // Branch interface.
    val bru = Flipped(new BruIO(p))

    // CSR interface.
    val csr = Valid(new CsrCmd)

    // LSU interface.
    val lsu = Decoupled(new LsuCmd)

    // Multiplier interface.
    val mlu = Valid(new MluCmd)

    // Divide interface.
    val dvu = Decoupled(new DvuCmd)

    // Vector interface.
    val vinst = if (p.enableVector) {
      Some(Decoupled(new VInstCmd))
    } else { None }

    // Branch status.
    val branchTaken = Input(Bool())

    // Interlock Controls
    val interlock = Input(Bool())
    val serializeIn  = Flipped(new DecodeSerializeIO)
    val serializeOut = new DecodeSerializeIO

    // Scalar logging.
    val slog = Output(Bool())
  })

  val decodeEn = io.inst.valid && io.inst.ready && !io.branchTaken

  // The decode logic.
  val d = DecodeInstruction(p, pipeline, io.inst.addr, io.inst.inst)

  val vldst = d.vld || d.vst
  val vldst_wb = vldst && io.inst.inst(28)

  val rdAddr  = Mux(vldst, io.inst.inst(19,15), io.inst.inst(11,7))
  val rs1Addr = io.inst.inst(19,15)
  val rs2Addr = io.inst.inst(24,20)
  val rs3Addr = io.inst.inst(31,27)

  val isCsrImm = d.isCsr() &&  io.inst.inst(14)
  val isCsrReg = d.isCsr() && !io.inst.inst(14)

  val isVIop = if (p.enableVector) {
    io.vinst.get.bits.op === VInstOp.VIOP
  } else { false.B }

  val isVIopVs1 = isVIop
  val isVIopVs2 = isVIop && io.inst.inst(1,0) === 0.U  // exclude: .vv
  val isVIopVs3 = isVIop && io.inst.inst(2,0) === 1.U  // exclude: .vvv

  // Use the forwarded scoreboard to interlock on multicycle operations.
  val aluRdEn  = !io.scoreboard.comb(rdAddr)  || isVIopVs1 || d.isStore() || d.isCondBr()
  val aluRs1En = !io.scoreboard.comb(rs1Addr) || isVIopVs1 || d.isLsu() || d.auipc
  val aluRs2En = !io.scoreboard.comb(rs2Addr) || isVIopVs2 || d.isLsu() || d.auipc || d.isAluImm() || d.isAlu1Bit()
  // val aluRs3En = !io.scoreboard.comb(rs3Addr) || isVIopVs3
  // val aluEn = aluRdEn && aluRs1En && aluRs2En && aluRs3En  // TODO: is aluRs3En needed?
  val aluEn = aluRdEn && aluRs1En && aluRs2En

  // Interlock jalr but special case return.
  val bruEn = !d.jalr || !io.scoreboard.regd(rs1Addr) ||
              io.inst.inst(31,20) === 0.U

  // Require interlock on address generation as there is no write forwarding.
  val lsuEn = !d.isLsu() ||
              !io.serializeIn.lsu && io.lsu.ready &&
              (!d.isLsu() || !io.serializeIn.brcond) &&  // TODO: can this line be removed?
              !(Mux(io.busRead.bypass, io.scoreboard.comb(rs1Addr),
                    io.scoreboard.regd(rs1Addr)) ||
                    io.scoreboard.comb(rs2Addr) && (d.isStore() || vldst))

  // Interlock mul, only one lane accepted.
  val mulEn = (!d.isMul() || !io.serializeIn.mul) && !io.serializeIn.brcond


  // Vector extension interlock.
  val vinstEn = if (p.enableVector) {
      !(io.serializeIn.vinst || isVIop && io.serializeIn.brcond) &&
      !(d.isVector() && !io.vinst.get.ready)
  } else { false.B }

  // Fence interlock.
  // Input mactive used passthrough, prefer to avoid registers in Decode.
  val fenceEn = !(d.fence && io.mactive)

  // ALU opcode.
  val alu = MuxCase(MakeValid(false.B, AluOp.ADD), Seq(
    (d.auipc || d.addi || d.add) -> MakeValid(true.B, AluOp.ADD),
    d.sub                        -> MakeValid(true.B, AluOp.SUB),
    (d.slti || d.slt)            -> MakeValid(true.B, AluOp.SLT),
    (d.sltiu || d.sltu)          -> MakeValid(true.B, AluOp.SLTU),
    (d.xori || d.xor)            -> MakeValid(true.B, AluOp.XOR),
    (d.ori || d.or)              -> MakeValid(true.B, AluOp.OR),
    (d.andi || d.and)            -> MakeValid(true.B, AluOp.AND),
    (d.slli || d.sll)            -> MakeValid(true.B, AluOp.SLL),
    (d.srli || d.srl)            -> MakeValid(true.B, AluOp.SRL),
    (d.srai || d.sra)            -> MakeValid(true.B, AluOp.SRA),
    d.lui                        -> MakeValid(true.B, AluOp.LUI),
    d.clz                        -> MakeValid(true.B, AluOp.CLZ),
    d.ctz                        -> MakeValid(true.B, AluOp.CTZ),
    d.pcnt                       -> MakeValid(true.B, AluOp.PCNT),
    d.min                        -> MakeValid(true.B, AluOp.MIN),
    d.minu                       -> MakeValid(true.B, AluOp.MINU),
    d.max                        -> MakeValid(true.B, AluOp.MAX),
    d.maxu                       -> MakeValid(true.B, AluOp.MAXU)
  ))
  io.alu.valid := decodeEn && alu.valid
  io.alu.bits.addr := rdAddr
  io.alu.bits.op := alu.bits

  // Branch conditional opcode.
  val bru = new BruOp()
  val bruOp = Wire(Vec(bru.Entries, Bool()))
  val bruValid = WiredOR(io.bru.op)  // used without decodeEn
  io.bru.valid := decodeEn && bruValid
  io.bru.fwd := io.inst.brchFwd
  io.bru.op := bruOp.asUInt
  io.bru.pc := io.inst.addr
  io.bru.target := io.inst.addr + Mux(io.inst.inst(2), d.immjal, d.immbr)
  io.bru.link := rdAddr

  bruOp(bru.JAL)  := d.jal
  bruOp(bru.JALR) := d.jalr
  bruOp(bru.BEQ)  := d.beq
  bruOp(bru.BNE)  := d.bne
  bruOp(bru.BLT)  := d.blt
  bruOp(bru.BGE)  := d.bge
  bruOp(bru.BLTU) := d.bltu
  bruOp(bru.BGEU) := d.bgeu
  bruOp(bru.EBREAK) := d.ebreak
  bruOp(bru.ECALL)  := d.ecall
  bruOp(bru.EEXIT)  := d.eexit
  bruOp(bru.EYIELD) := d.eyield
  bruOp(bru.ECTXSW) := d.ectxsw
  bruOp(bru.MPAUSE) := d.mpause
  bruOp(bru.MRET)   := d.mret
  bruOp(bru.FENCEI) := d.fencei
  bruOp(bru.UNDEF)  := d.undef

  // CSR opcode.
  val csr = MuxCase(MakeValid(false.B, CsrOp.CSRRW), Seq(
    d.csrrw -> MakeValid(true.B, CsrOp.CSRRW),
    d.csrrs -> MakeValid(true.B, CsrOp.CSRRS),
    d.csrrc -> MakeValid(true.B, CsrOp.CSRRC)
  ))
  io.csr.valid := decodeEn && csr.valid
  io.csr.bits.addr := rdAddr
  io.csr.bits.index := io.inst.inst(31,20)
  io.csr.bits.op := csr.bits

  // LSU opcode.
  val lsu = MuxCase(MakeValid(false.B, LsuOp.LB), Seq(
    d.lb             -> MakeValid(true.B, LsuOp.LB),
    d.lh             -> MakeValid(true.B, LsuOp.LH),
    d.lw             -> MakeValid(true.B, LsuOp.LW),
    d.lbu            -> MakeValid(true.B, LsuOp.LBU),
    d.lhu            -> MakeValid(true.B, LsuOp.LHU),
    d.sb             -> MakeValid(true.B, LsuOp.SB),
    d.sh             -> MakeValid(true.B, LsuOp.SH),
    d.sw             -> MakeValid(true.B, LsuOp.SW),
    d.fencei         -> MakeValid(true.B, LsuOp.FENCEI),
    d.flushat        -> MakeValid(true.B, LsuOp.FLUSHAT),
    d.flushall       -> MakeValid(true.B, LsuOp.FLUSHALL),
    (d.vld || d.vst) -> MakeValid(true.B, LsuOp.VLDST),
  ))
  io.lsu.valid := decodeEn && lsu.valid
  io.lsu.bits.store := io.inst.inst(5)
  io.lsu.bits.addr := rdAddr
  io.lsu.bits.op := lsu.bits

  // MLU opcode.
  val mlu = MuxCase(MakeValid(false.B, MluOp.MUL), Seq(
    d.mul     -> MakeValid(true.B, MluOp.MUL),
    d.mulh    -> MakeValid(true.B, MluOp.MULH),
    d.mulhsu  -> MakeValid(true.B, MluOp.MULHSU),
    d.mulhu   -> MakeValid(true.B, MluOp.MULHU),
    d.mulhr   -> MakeValid(true.B, MluOp.MULHR),
    d.mulhsur -> MakeValid(true.B, MluOp.MULHSUR),
    d.mulhur  -> MakeValid(true.B, MluOp.MULHUR),
    d.dmulh   -> MakeValid(true.B, MluOp.DMULH),
    d.dmulhr  -> MakeValid(true.B, MluOp.DMULHR),
  ))
  io.mlu.valid := decodeEn && mlu.valid
  io.mlu.bits.addr := rdAddr
  io.mlu.bits.op := mlu.bits

  // DIV opcode.
  val dvu = MuxCase(MakeValid(false.B, DvuOp.DIV), Seq(
    d.div  -> MakeValid(true.B, DvuOp.DIV),
    d.divu -> MakeValid(true.B, DvuOp.DIVU),
    d.rem  -> MakeValid(true.B, DvuOp.REM),
    d.remu -> MakeValid(true.B, DvuOp.REMU)
  ))
  io.dvu.valid := decodeEn && dvu.valid
  io.dvu.bits.addr := rdAddr
  io.dvu.bits.op := dvu.bits
  val dvuEn = !dvu.valid || io.dvu.ready

  // Vector instructions.
  val vinst = MuxCase(MakeValid(false.B, VInstOp.VLD), Seq(
    d.vld      -> MakeValid(true.B, VInstOp.VLD),
    d.vst      -> MakeValid(true.B, VInstOp.VST),
    d.viop     -> MakeValid(true.B, VInstOp.VIOP),
    d.getvl    -> MakeValid(true.B, VInstOp.GETVL),
    d.getmaxvl -> MakeValid(true.B, VInstOp.GETMAXVL),
  ))
  if (p.enableVector) {
    io.vinst.get.valid := decodeEn && vinst.valid
    io.vinst.get.bits.addr := rdAddr
    io.vinst.get.bits.inst := io.inst.inst
    io.vinst.get.bits.op := vinst.bits
  }

  // Scalar logging.
  io.slog := decodeEn && d.slog

  // Register file read ports.
  io.rs1Read.valid := decodeEn && (d.isCondBr() || d.isAluReg() || d.isAluImm() || d.isAlu1Bit() || d.isAlu2Bit() ||
                      isCsrImm || isCsrReg || d.isMul() || d.isDvu() || d.slog ||
                      d.getvl || d.vld || d.vst)
  io.rs2Read.valid := decodeEn && (d.isCondBr() || d.isAluReg() || d.isAlu2Bit() || d.isStore() ||
                      isCsrReg || d.isMul() || d.isDvu() || d.slog || d.getvl ||
                      d.vld || d.vst || d.viop)

  // rs1 is on critical path to busPortAddr.
  io.rs1Read.addr := Mux(io.inst.inst(0), rs1Addr, rs3Addr)

  // rs2 is used for the vector operation scalar value.
  io.rs2Read.addr := rs2Addr

  // Register file set ports.
  io.rs1Set.valid := decodeEn && (d.auipc || isCsrImm)
  io.rs2Set.valid := io.rs1Set.valid || decodeEn && (d.isAluImm() || d.isAlu1Bit() || d.lui)

  io.rs1Set.value := Mux(d.isCsr, d.immcsr, io.inst.addr)  // Program Counter (PC)

  io.rs2Set.value := MuxCase(d.imm12,
                     IndexedSeq((d.auipc || d.lui) -> d.imm20))

  // Register file write address ports. We speculate without knowing the decode
  // enable status to improve timing, and under a branch is ignored anyway.
  val rdMark_valid =
      alu.valid || csr.valid || mlu.valid || dvu.valid && io.dvu.ready ||
      lsu.valid && d.isLoad() ||
      d.getvl || d.getmaxvl || vldst_wb ||
      bruValid && (bruOp(bru.JAL) || bruOp(bru.JALR)) && rdAddr =/= 0.U

  // val scoreboard_spec = Mux(rdMark_valid || d.io.vst, UIntToOH(rdAddr, 32), 0.U)  // TODO: why was d.io.vst included?
  val scoreboard_spec = Mux(rdMark_valid, UIntToOH(rdAddr, 32), 0.U)
  io.scoreboard.spec := Cat(scoreboard_spec(31,1), 0.U(1.W))

  io.rdMark.valid := decodeEn && rdMark_valid
  io.rdMark.addr  := rdAddr

  // Register file bus address port.
  // Pointer chasing bypass if immediate is zero.
  // Load/Store immediate selection keys off bit5, and RET off bit6.
  io.busRead.valid := lsu.valid
  io.busRead.bypass := io.inst.inst(31,25) === 0.U &&
    Mux(!io.inst.inst(5) || io.inst.inst(6), io.inst.inst(24,20) === 0.U,
                                             io.inst.inst(11,7) === 0.U)

  // SB,SH,SW   0100011
  val storeSelect = io.inst.inst(6,3) === 4.U && io.inst.inst(1,0) === 3.U
  io.busRead.immen := !d.flushat
  io.busRead.immed := Cat(d.imm12(31,5),
                          Mux(storeSelect, d.immst(4,0), d.imm12(4,0)))

  // Decode ready signalling to fetch.
  // This must not factor branchTaken, which will be done directly in the
  // fetch unit. Note above decodeEn resolves for branch for execute usage.
  io.inst.ready := aluEn && bruEn && lsuEn && mulEn && dvuEn && vinstEn && fenceEn &&
                   !io.serializeIn.jump && !io.halted && !io.interlock &&
                   (pipeline.U === 0.U || !d.undef)

  // Serialize Interface.
  // io.serializeOut.lsu  := io.serializeIn.lsu || lsu.valid || vldst  // vldst interlock for address generation cycle in vinst
  // io.serializeOut.lsu  := io.serializeIn.lsu || vldst  // vldst interlock for address generation cycle in vinst
  io.serializeOut.lsu  := io.serializeIn.lsu
  io.serializeOut.mul  := io.serializeIn.mul || mlu.valid
  io.serializeOut.jump := io.serializeIn.jump || d.jal || d.jalr ||
                          d.ebreak || d.ecall || d.eexit ||
                          d.eyield || d.ectxsw || d.mpause || d.mret
  io.serializeOut.brcond := io.serializeIn.brcond |
      d.beq || d.bne || d.blt || d.bge || d.bltu || d.bgeu
  io.serializeOut.vinst := io.serializeIn.vinst
}

object DecodeInstruction {
  def apply(p: Parameters, pipeline: Int, addr: UInt, op: UInt): DecodedInstruction = {
    val d = Wire(new DecodedInstruction)

    // Immediates
    d.imm12  := Cat(Fill(20, op(31)), op(31,20))
    d.imm20  := Cat(op(31,12), 0.U(12.W))
    d.immjal := Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
    d.immbr  := Cat(Fill(20, op(31)), op(7), op(30,25), op(11,8), 0.U(1.W))
    d.immcsr := op(19,15)
    d.immst  := Cat(Fill(20, op(31)), op(31,25), op(11,7))

    // RV32I
    d.lui   := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_0110111")
    d.auipc := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_0010111")
    d.jal   := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_1101111")
    d.jalr  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_1100111")
    d.beq   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_000_xxxxx_1100011")
    d.bne   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_001_xxxxx_1100011")
    d.blt   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_100_xxxxx_1100011")
    d.bge   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_101_xxxxx_1100011")
    d.bltu  := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_110_xxxxx_1100011")
    d.bgeu  := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_111_xxxxx_1100011")
    d.csrrw := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x01_xxxxx_1110011")
    d.csrrs := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x10_xxxxx_1110011")
    d.csrrc := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x11_xxxxx_1110011")
    d.lb    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0000011")
    d.lh    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_001_xxxxx_0000011")
    d.lw    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0000011")
    d.lbu   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_100_xxxxx_0000011")
    d.lhu   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_101_xxxxx_0000011")
    d.sb    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0100011")
    d.sh    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_001_xxxxx_0100011")
    d.sw    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0100011")
    d.fence := DecodeBits(op, "0000_xxxx_xxxx_00000_000_00000_0001111")
    d.addi  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0010011")
    d.slti  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0010011")
    d.sltiu := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_011_xxxxx_0010011")
    d.xori  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_100_xxxxx_0010011")
    d.ori   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_110_xxxxx_0010011")
    d.andi  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_111_xxxxx_0010011")
    d.slli  := DecodeBits(op, "0000000_xxxxx_xxxxx_001_xxxxx_0010011")
    d.srli  := DecodeBits(op, "0000000_xxxxx_xxxxx_101_xxxxx_0010011")
    d.srai  := DecodeBits(op, "0100000_xxxxx_xxxxx_101_xxxxx_0010011")
    d.add   := DecodeBits(op, "0000000_xxxxx_xxxxx_000_xxxxx_0110011")
    d.sub   := DecodeBits(op, "0100000_xxxxx_xxxxx_000_xxxxx_0110011")
    d.slt   := DecodeBits(op, "0000000_xxxxx_xxxxx_010_xxxxx_0110011")
    d.sltu  := DecodeBits(op, "0000000_xxxxx_xxxxx_011_xxxxx_0110011")
    d.xor   := DecodeBits(op, "0000000_xxxxx_xxxxx_100_xxxxx_0110011")
    d.or    := DecodeBits(op, "0000000_xxxxx_xxxxx_110_xxxxx_0110011")
    d.and   := DecodeBits(op, "0000000_xxxxx_xxxxx_111_xxxxx_0110011")
    d.sll   := DecodeBits(op, "0000000_xxxxx_xxxxx_001_xxxxx_0110011")
    d.srl   := DecodeBits(op, "0000000_xxxxx_xxxxx_101_xxxxx_0110011")
    d.sra   := DecodeBits(op, "0100000_xxxxx_xxxxx_101_xxxxx_0110011")

    // RV32M
    d.mul     := DecodeBits(op, "0000_001_xxxxx_xxxxx_000_xxxxx_0110011")
    d.mulh    := DecodeBits(op, "0000_001_xxxxx_xxxxx_001_xxxxx_0110011")
    d.mulhsu  := DecodeBits(op, "0000_001_xxxxx_xxxxx_010_xxxxx_0110011")
    d.mulhu   := DecodeBits(op, "0000_001_xxxxx_xxxxx_011_xxxxx_0110011")
    d.mulhr   := DecodeBits(op, "0010_001_xxxxx_xxxxx_001_xxxxx_0110011")
    d.mulhsur := DecodeBits(op, "0010_001_xxxxx_xxxxx_010_xxxxx_0110011")
    d.mulhur  := DecodeBits(op, "0010_001_xxxxx_xxxxx_011_xxxxx_0110011")
    d.dmulh   := DecodeBits(op, "0000_010_xxxxx_xxxxx_001_xxxxx_0110011")
    d.dmulhr  := DecodeBits(op, "0010_010_xxxxx_xxxxx_001_xxxxx_0110011")
    d.div     := DecodeBits(op, "0000_001_xxxxx_xxxxx_100_xxxxx_0110011")
    d.divu    := DecodeBits(op, "0000_001_xxxxx_xxxxx_101_xxxxx_0110011")
    d.rem     := DecodeBits(op, "0000_001_xxxxx_xxxxx_110_xxxxx_0110011")
    d.remu    := DecodeBits(op, "0000_001_xxxxx_xxxxx_111_xxxxx_0110011")

    // RV32B
    d.clz  := DecodeBits(op, "0110000_00000_xxxxx_001_xxxxx_0010011")
    d.ctz  := DecodeBits(op, "0110000_00001_xxxxx_001_xxxxx_0010011")
    d.pcnt := DecodeBits(op, "0110000_00010_xxxxx_001_xxxxx_0010011")
    d.min  := DecodeBits(op, "0000101_xxxxx_xxxxx_100_xxxxx_0110011")
    d.minu := DecodeBits(op, "0000101_xxxxx_xxxxx_101_xxxxx_0110011")
    d.max  := DecodeBits(op, "0000101_xxxxx_xxxxx_110_xxxxx_0110011")
    d.maxu := DecodeBits(op, "0000101_xxxxx_xxxxx_111_xxxxx_0110011")

    // Decode scalar log.
    val slog = DecodeBits(op, "01111_00_00000_xxxxx_0xx_00000_11101_11")

    if (p.enableVector) {
      // Vector length.
      d.getvl    := DecodeBits(op, "0001x_xx_xxxxx_xxxxx_000_xxxxx_11101_11") && op(26,25) =/= 3.U && (op(24,20) =/= 0.U || op(19,15) =/= 0.U)
      d.getmaxvl := DecodeBits(op, "0001x_xx_00000_00000_000_xxxxx_11101_11") && op(26,25) =/= 3.U

      // Vector load/store.
      d.vld := DecodeBits(op, "000xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11")     // vld

      d.vst := DecodeBits(op, "001xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11") ||  // vst
               DecodeBits(op, "011xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11")     // vstq

      // Convolution transfer accumulators to vregs. Also decodes acset/actr ops.
      val vconv = DecodeBits(op, "010100_000000_000000_xx_xxxxxx_x_111_11")

      // Duplicate
      val vdup = DecodeBits(op, "01000x_0xxxxx_000000_xx_xxxxxx_x_111_11") && op(13,12) <= 2.U
      val vdupi = vdup && op(26) === 0.U

      // Vector instructions.
      d.viop := op(0) === 0.U ||     // .vv .vx
                op(1,0) === 1.U ||  // .vvv .vxv
                vconv || vdupi
    } else {
      d.getvl    := false.B
      d.getmaxvl := false.B
      d.vld      := false.B
      d.vst      := false.B
      d.viop     := false.B
    }

    // [extensions] Core controls.
    d.ebreak := DecodeBits(op, "000000000001_00000_000_00000_11100_11")
    d.ecall  := DecodeBits(op, "000000000000_00000_000_00000_11100_11")
    d.eexit  := DecodeBits(op, "000000100000_00000_000_00000_11100_11")
    d.eyield := DecodeBits(op, "000001000000_00000_000_00000_11100_11")
    d.ectxsw := DecodeBits(op, "000001100000_00000_000_00000_11100_11")
    d.mpause := DecodeBits(op, "000010000000_00000_000_00000_11100_11")
    d.mret   := DecodeBits(op, "001100000010_00000_000_00000_11100_11")

    // Fences.
    d.fencei   := DecodeBits(op, "0000_0000_0000_00000_001_00000_0001111")
    d.flushat  := DecodeBits(op, "0010x_xx_00000_xxxxx_000_00000_11101_11") && op(19,15) =/= 0.U
    d.flushall := DecodeBits(op, "0010x_xx_00000_00000_000_00000_11101_11")

    // [extensions] Scalar logging.
    d.slog := slog

    // Stub out decoder state not used beyond pipeline0.
    if (pipeline > 0) {
      d.csrrw := false.B
      d.csrrs := false.B
      d.csrrc := false.B

      d.div := false.B
      d.divu := false.B
      d.rem := false.B
      d.remu := false.B

      d.ebreak := false.B
      d.ecall  := false.B
      d.eexit  := false.B
      d.eyield := false.B
      d.ectxsw := false.B
      d.mpause := false.B
      d.mret   := false.B

      d.fence    := false.B
      d.fencei   := false.B
      d.flushat  := false.B
      d.flushall := false.B

      d.slog := false.B
    }

    // Generate the undefined opcode.
    val decoded = Cat(d.lui, d.auipc,
                      d.jal, d.jalr,
                      d.beq, d.bne, d.blt, d.bge, d.bltu, d.bgeu,
                      d.csrrw, d.csrrs, d.csrrc,
                      d.lb, d.lh, d.lw, d.lbu, d.lhu,
                      d.sb, d.sh, d.sw, d.fence,
                      d.addi, d.slti, d.sltiu, d.xori, d.ori, d.andi,
                      d.add, d.sub, d.slt, d.sltu, d.xor, d.or, d.and,
                      d.slli, d.srli, d.srai, d.sll, d.srl, d.sra,
                      d.mul, d.mulh, d.mulhsu, d.mulhu, d.mulhr, d.mulhsur, d.mulhur, d.dmulh, d.dmulhr,
                      d.div, d.divu, d.rem, d.remu,
                      d.clz, d.ctz, d.pcnt, d.min, d.minu, d.max, d.maxu,
                      d.viop, d.vld, d.vst,
                      d.getvl, d.getmaxvl,
                      d.ebreak, d.ecall, d.eexit, d.eyield, d.ectxsw,
                      d.mpause, d.mret, d.fencei, d.flushat, d.flushall, d.slog)

    d.undef := !WiredOR(decoded)

    d
  }
}
