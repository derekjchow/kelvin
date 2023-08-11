// Copyright 2023 Google LLC
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
    val alu = Flipped(new AluIO(p))

    // Branch interface.
    val bru = Flipped(new BruIO(p))

    // CSR interface.
    val csr = Flipped(new CsrIO(p))

    // LSU interface.
    val lsu = Flipped(new LsuIO(p))

    // Multiplier interface.
    val mlu = Flipped(new MluIO(p))

    // Divide interface.
    val dvu = Flipped(new DvuIO(p))

    // Vector interface.
    val vinst = Flipped(new VInstIO)

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
  val d = Module(new DecodedInstruction(p, pipeline))
  d.io.addr := io.inst.addr
  d.io.inst := io.inst.inst

  val vldst = d.io.vld || d.io.vst
  val vldst_wb = vldst && io.inst.inst(28)

  val rdAddr  = Mux(vldst, io.inst.inst(19,15), io.inst.inst(11,7))
  val rs1Addr = io.inst.inst(19,15)
  val rs2Addr = io.inst.inst(24,20)
  val rs3Addr = io.inst.inst(31,27)

  val isAluImm = d.io.addi || d.io.slti || d.io.sltiu || d.io.xori ||
                 d.io.ori || d.io.andi || d.io.slli || d.io.srli || d.io.srai

  val isAluReg = d.io.add || d.io.sub || d.io.slt || d.io.sltu || d.io.xor ||
                 d.io.or || d.io.and || d.io.sll || d.io.srl || d.io.sra

  val isAlu1Bit = d.io.clz || d.io.ctz || d.io.pcnt
  val isAlu2Bit = d.io.min || d.io.minu || d.io.max || d.io.maxu

  val isCondBr = d.io.beq || d.io.bne || d.io.blt || d.io.bge ||
                 d.io.bltu || d.io.bgeu

  val isCsr = d.io.csrrw || d.io.csrrs || d.io.csrrc
  val isCsrImm = isCsr &&  io.inst.inst(14)
  val isCsrReg = isCsr && !io.inst.inst(14)

  val isLoad = d.io.lb || d.io.lh || d.io.lw || d.io.lbu || d.io.lhu
  val isStore = d.io.sb || d.io.sh || d.io.sw
  val isLsu = isLoad || isStore || d.io.vld || d.io.vst || d.io.flushat || d.io.flushall

  val isMul = d.io.mul || d.io.mulh || d.io.mulhsu || d.io.mulhu || d.io.mulhr || d.io.mulhsur || d.io.mulhur || d.io.dmulh || d.io.dmulhr

  val isDvu = d.io.div || d.io.divu || d.io.rem || d.io.remu

  val isVIop = io.vinst.op(new VInstOp().VIOP)

  val isVIopVs1 = isVIop
  val isVIopVs2 = isVIop && io.inst.inst(1,0) === 0.U  // exclude: .vv
  val isVIopVs3 = isVIop && io.inst.inst(2,0) === 1.U  // exclude: .vvv

  // Use the forwarded scoreboard to interlock on multicycle operations.
  val aluRdEn  = !io.scoreboard.comb(rdAddr)  || isVIopVs1 || isStore || isCondBr
  val aluRs1En = !io.scoreboard.comb(rs1Addr) || isVIopVs1 || isLsu || d.io.auipc
  val aluRs2En = !io.scoreboard.comb(rs2Addr) || isVIopVs2 || isLsu || d.io.auipc || isAluImm || isAlu1Bit
  // val aluRs3En = !io.scoreboard.comb(rs3Addr) || isVIopVs3
  // val aluEn = aluRdEn && aluRs1En && aluRs2En && aluRs3En  // TODO: is aluRs3En needed?
  val aluEn = aluRdEn && aluRs1En && aluRs2En

  // Interlock jalr but special case return.
  val bruEn = !d.io.jalr || !io.scoreboard.regd(rs1Addr) ||
              io.inst.inst(31,20) === 0.U

  // Require interlock on address generation as there is no write forwarding.
  val lsuEn = !isLsu ||
              !io.serializeIn.lsu && io.lsu.ready &&
              (!isLsu || !io.serializeIn.brcond) &&  // TODO: can this line be removed?
              !(Mux(io.busRead.bypass, io.scoreboard.comb(rs1Addr),
                    io.scoreboard.regd(rs1Addr)) ||
                    io.scoreboard.comb(rs2Addr) && (isStore || vldst))

  // Interlock mul, only one lane accepted.
  val mulEn = !isMul || !io.serializeIn.mul


  // Vector extension interlock.
  val vinstEn = !(io.serializeIn.vinst || isVIop && io.serializeIn.brcond) &&
                !(io.vinst.op =/= 0.U && !io.vinst.ready)

  // Fence interlock.
  // Input mactive used passthrough, prefer to avoid registers in Decode.
  val fenceEn = !(d.io.fence && io.mactive)

  // ALU opcode.
  val alu = new AluOp()
  val aluOp = Wire(Vec(alu.Entries, Bool()))
  val aluValid = WiredOR(io.alu.op)  // used without decodeEn
  io.alu.valid := decodeEn && aluValid
  io.alu.addr := rdAddr
  io.alu.op := aluOp.asUInt

  aluOp(alu.ADD)  := d.io.auipc || d.io.addi || d.io.add
  aluOp(alu.SUB)  := d.io.sub
  aluOp(alu.SLT)  := d.io.slti || d.io.slt
  aluOp(alu.SLTU) := d.io.sltiu || d.io.sltu
  aluOp(alu.XOR)  := d.io.xori || d.io.xor
  aluOp(alu.OR)   := d.io.ori || d.io.or
  aluOp(alu.AND)  := d.io.andi || d.io.and
  aluOp(alu.SLL)  := d.io.slli || d.io.sll
  aluOp(alu.SRL)  := d.io.srli || d.io.srl
  aluOp(alu.SRA)  := d.io.srai || d.io.sra
  aluOp(alu.LUI)  := d.io.lui
  aluOp(alu.CLZ)  := d.io.clz
  aluOp(alu.CTZ)  := d.io.ctz
  aluOp(alu.PCNT) := d.io.pcnt
  aluOp(alu.MIN)  := d.io.min
  aluOp(alu.MINU) := d.io.minu
  aluOp(alu.MAX)  := d.io.max
  aluOp(alu.MAXU) := d.io.maxu

  // Branch conditional opcode.
  val bru = new BruOp()
  val bruOp = Wire(Vec(bru.Entries, Bool()))
  val bruValid = WiredOR(io.bru.op)  // used without decodeEn
  io.bru.valid := decodeEn && bruValid
  io.bru.fwd := io.inst.brchFwd
  io.bru.op := bruOp.asUInt
  io.bru.pc := io.inst.addr
  io.bru.target := io.inst.addr + Mux(io.inst.inst(2), d.io.immjal, d.io.immbr)
  io.bru.link := rdAddr

  bruOp(bru.JAL)  := d.io.jal
  bruOp(bru.JALR) := d.io.jalr
  bruOp(bru.BEQ)  := d.io.beq
  bruOp(bru.BNE)  := d.io.bne
  bruOp(bru.BLT)  := d.io.blt
  bruOp(bru.BGE)  := d.io.bge
  bruOp(bru.BLTU) := d.io.bltu
  bruOp(bru.BGEU) := d.io.bgeu
  bruOp(bru.EBREAK) := d.io.ebreak
  bruOp(bru.ECALL)  := d.io.ecall
  bruOp(bru.EEXIT)  := d.io.eexit
  bruOp(bru.EYIELD) := d.io.eyield
  bruOp(bru.ECTXSW) := d.io.ectxsw
  bruOp(bru.MPAUSE) := d.io.mpause
  bruOp(bru.MRET)   := d.io.mret
  bruOp(bru.FENCEI) := d.io.fencei
  bruOp(bru.UNDEF)  := d.io.undef

  // CSR opcode.
  val csr = new CsrOp()
  val csrOp = Wire(Vec(csr.Entries, Bool()))
  val csrValid = WiredOR(io.csr.op)  // used without decodeEn
  io.csr.valid := decodeEn && csrValid
  io.csr.addr := rdAddr
  io.csr.index := io.inst.inst(31,20)
  io.csr.op := csrOp.asUInt

  csrOp(csr.CSRRW) := d.io.csrrw
  csrOp(csr.CSRRS) := d.io.csrrs
  csrOp(csr.CSRRC) := d.io.csrrc

  // LSU opcode.
  val lsu = new LsuOp()
  val lsuOp = Wire(Vec(lsu.Entries, Bool()))
  val lsuValid = WiredOR(io.lsu.op)  // used without decodeEn
  io.lsu.valid := decodeEn && lsuValid
  io.lsu.store := io.inst.inst(5)
  io.lsu.addr := rdAddr
  io.lsu.op := lsuOp.asUInt

  lsuOp(lsu.LB)  := d.io.lb
  lsuOp(lsu.LH)  := d.io.lh
  lsuOp(lsu.LW)  := d.io.lw
  lsuOp(lsu.LBU) := d.io.lbu
  lsuOp(lsu.LHU) := d.io.lhu
  lsuOp(lsu.SB)  := d.io.sb
  lsuOp(lsu.SH)  := d.io.sh
  lsuOp(lsu.SW)  := d.io.sw
  lsuOp(lsu.FENCEI)   := d.io.fencei
  lsuOp(lsu.FLUSHAT)  := d.io.flushat
  lsuOp(lsu.FLUSHALL) := d.io.flushall

  lsuOp(lsu.VLDST) := d.io.vld || d.io.vst

  // MLU opcode.
  val mlu = new MluOp()
  val mluOp = Wire(Vec(mlu.Entries, Bool()))
  val mluValid = WiredOR(io.mlu.op)  // used without decodeEn
  io.mlu.valid := decodeEn && mluValid
  io.mlu.addr := rdAddr
  io.mlu.op := mluOp.asUInt

  mluOp(mlu.MUL)     := d.io.mul
  mluOp(mlu.MULH)    := d.io.mulh
  mluOp(mlu.MULHSU)  := d.io.mulhsu
  mluOp(mlu.MULHU)   := d.io.mulhu
  mluOp(mlu.MULHR)   := d.io.mulhr
  mluOp(mlu.MULHSUR) := d.io.mulhsur
  mluOp(mlu.MULHUR)  := d.io.mulhur
  mluOp(mlu.DMULH)   := d.io.dmulh
  mluOp(mlu.DMULHR)  := d.io.dmulhr

  // DIV opcode.
  val dvu = new DvuOp()
  val dvuOp = Wire(Vec(dvu.Entries, Bool()))
  val dvuValid = WiredOR(io.dvu.op)  // used without decodeEn
  io.dvu.valid := decodeEn && dvuValid
  io.dvu.addr := rdAddr
  io.dvu.op := dvuOp.asUInt

  dvuOp(dvu.DIV)  := d.io.div
  dvuOp(dvu.DIVU) := d.io.divu
  dvuOp(dvu.REM)  := d.io.rem
  dvuOp(dvu.REMU) := d.io.remu

  val dvuEn = WiredOR(io.dvu.op) === 0.U || io.dvu.ready

  // Vector instructions.
  val vinst = new VInstOp()
  val vinstOp = Wire(Vec(vinst.Entries, Bool()))
  val vinstValid = WiredOR(vinstOp)  // used without decodeEn

  io.vinst.valid := decodeEn && vinstValid
  io.vinst.addr := rdAddr
  io.vinst.inst := io.inst.inst
  io.vinst.op := vinstOp.asUInt

  vinstOp(vinst.VLD) := d.io.vld
  vinstOp(vinst.VST) := d.io.vst
  vinstOp(vinst.VIOP) := d.io.viop
  vinstOp(vinst.GETVL) := d.io.getvl
  vinstOp(vinst.GETMAXVL) := d.io.getmaxvl

  // Scalar logging.
  io.slog := decodeEn && d.io.slog

  // Register file read ports.
  io.rs1Read.valid := decodeEn && (isCondBr || isAluReg || isAluImm || isAlu1Bit || isAlu2Bit ||
                      isCsrImm || isCsrReg || isMul || isDvu || d.io.slog ||
                      d.io.getvl || d.io.vld || d.io.vst)
  io.rs2Read.valid := decodeEn && (isCondBr || isAluReg || isAlu2Bit || isStore ||
                      isCsrReg || isMul || isDvu || d.io.slog || d.io.getvl ||
                      d.io.vld || d.io.vst || d.io.viop)

  // rs1 is on critical path to busPortAddr.
  io.rs1Read.addr := Mux(io.inst.inst(0), rs1Addr, rs3Addr)

  // rs2 is used for the vector operation scalar value.
  io.rs2Read.addr := rs2Addr

  // Register file set ports.
  io.rs1Set.valid := decodeEn && (d.io.auipc || isCsrImm)
  io.rs2Set.valid := io.rs1Set.valid || decodeEn && (isAluImm || isAlu1Bit || d.io.lui)

  io.rs1Set.value := Mux(isCsr, d.io.immcsr, io.inst.addr)  // Program Counter (PC)

  io.rs2Set.value := MuxCase(d.io.imm12,
                     IndexedSeq((d.io.auipc || d.io.lui) -> d.io.imm20))

  // Register file write address ports. We speculate without knowing the decode
  // enable status to improve timing, and under a branch is ignored anyway.
  val rdMark_valid =
      aluValid || csrValid || mluValid || dvuValid && io.dvu.ready ||
      lsuValid && isLoad ||
      d.io.getvl || d.io.getmaxvl || vldst_wb ||
      bruValid && (bruOp(bru.JAL) || bruOp(bru.JALR)) && rdAddr =/= 0.U

  // val scoreboard_spec = Mux(rdMark_valid || d.io.vst, OneHot(rdAddr, 32), 0.U)  // TODO: why was d.io.vst included?
  val scoreboard_spec = Mux(rdMark_valid, OneHot(rdAddr, 32), 0.U)
  io.scoreboard.spec := Cat(scoreboard_spec(31,1), 0.U(1.W))

  io.rdMark.valid := decodeEn && rdMark_valid
  io.rdMark.addr  := rdAddr

  // Register file bus address port.
  // Pointer chasing bypass if immediate is zero.
  // Load/Store immediate selection keys off bit5, and RET off bit6.
  io.busRead.valid := lsuValid
  io.busRead.bypass := io.inst.inst(31,25) === 0.U &&
    Mux(!io.inst.inst(5) || io.inst.inst(6), io.inst.inst(24,20) === 0.U,
                                             io.inst.inst(11,7) === 0.U)

  // SB,SH,SW   0100011
  // FSW        0100111 //TODO(hoangm)
  val storeSelect = io.inst.inst(6,3) === 4.U && io.inst.inst(1,0) === 3.U
  io.busRead.immen := !d.io.flushat
  io.busRead.immed := Cat(d.io.imm12(31,5),
                          Mux(storeSelect, d.io.immst(4,0), d.io.imm12(4,0)))

  // Decode ready signalling to fetch.
  // This must not factor branchTaken, which will be done directly in the
  // fetch unit. Note above decodeEn resolves for branch for execute usage.
  io.inst.ready := aluEn && bruEn && lsuEn && mulEn && dvuEn && vinstEn && fenceEn &&
                   !io.serializeIn.jump && !io.halted && !io.interlock &&
                   (pipeline.U === 0.U || !d.io.undef)

  // Serialize Interface.
  // io.serializeOut.lsu  := io.serializeIn.lsu || lsuValid || vldst  // vldst interlock for address generation cycle in vinst
  // io.serializeOut.lsu  := io.serializeIn.lsu || vldst  // vldst interlock for address generation cycle in vinst
  io.serializeOut.lsu  := io.serializeIn.lsu
  io.serializeOut.mul  := io.serializeIn.mul || mluValid
  io.serializeOut.jump := io.serializeIn.jump || d.io.jal || d.io.jalr ||
                          d.io.ebreak || d.io.ecall || d.io.eexit ||
                          d.io.eyield || d.io.ectxsw || d.io.mpause || d.io.mret
  io.serializeOut.brcond := io.serializeIn.brcond |
      d.io.beq || d.io.bne || d.io.blt || d.io.bge || d.io.bltu || d.io.bgeu
  io.serializeOut.vinst := io.serializeIn.vinst
}

class DecodedInstruction(p: Parameters, pipeline: Int) extends Module {
  val io = IO(new Bundle {
    val addr = Input(UInt(32.W))
    val inst = Input(UInt(32.W))

    // Immediates
    val imm12  = Output(UInt(32.W))
    val imm20  = Output(UInt(32.W))
    val immjal = Output(UInt(32.W))
    val immbr  = Output(UInt(32.W))
    val immcsr = Output(UInt(32.W))
    val immst  = Output(UInt(32.W))

    // RV32I
    val lui   = Output(Bool())
    val auipc = Output(Bool())
    val jal   = Output(Bool())
    val jalr  = Output(Bool())
    val beq   = Output(Bool())
    val bne   = Output(Bool())
    val blt   = Output(Bool())
    val bge   = Output(Bool())
    val bltu  = Output(Bool())
    val bgeu  = Output(Bool())
    val csrrw = Output(Bool())
    val csrrs = Output(Bool())
    val csrrc = Output(Bool())
    val lb    = Output(Bool())
    val lh    = Output(Bool())
    val lw    = Output(Bool())
    val lbu   = Output(Bool())
    val lhu   = Output(Bool())
    val sb    = Output(Bool())
    val sh    = Output(Bool())
    val sw    = Output(Bool())
    val fence = Output(Bool())
    val addi  = Output(Bool())
    val slti  = Output(Bool())
    val sltiu = Output(Bool())
    val xori  = Output(Bool())
    val ori   = Output(Bool())
    val andi  = Output(Bool())
    val slli  = Output(Bool())
    val srli  = Output(Bool())
    val srai  = Output(Bool())
    val add   = Output(Bool())
    val sub   = Output(Bool())
    val slt   = Output(Bool())
    val sltu  = Output(Bool())
    val xor   = Output(Bool())
    val or    = Output(Bool())
    val and   = Output(Bool())
    val sll   = Output(Bool())
    val srl   = Output(Bool())
    val sra   = Output(Bool())

    // RV32M
    val mul     = Output(Bool())
    val mulh    = Output(Bool())
    val mulhsu  = Output(Bool())
    val mulhu   = Output(Bool())
    val mulhr   = Output(Bool())
    val mulhsur = Output(Bool())
    val mulhur  = Output(Bool())
    val dmulh   = Output(Bool())
    val dmulhr  = Output(Bool())
    val div     = Output(Bool())
    val divu    = Output(Bool())
    val rem     = Output(Bool())
    val remu    = Output(Bool())

    // RV32B
    val clz  = Output(Bool())
    val ctz  = Output(Bool())
    val pcnt = Output(Bool())
    val min  = Output(Bool())
    val minu = Output(Bool())
    val max  = Output(Bool())
    val maxu = Output(Bool())

    // Vector instructions.
    val getvl = Output(Bool())
    val getmaxvl = Output(Bool())
    val vld = Output(Bool())
    val vst = Output(Bool())
    val viop = Output(Bool())

    // Core controls.
    val ebreak = Output(Bool())
    val ecall  = Output(Bool())
    val eexit  = Output(Bool())
    val eyield = Output(Bool())
    val ectxsw = Output(Bool())
    val mpause = Output(Bool())
    val mret   = Output(Bool())
    val undef  = Output(Bool())

    // Fences.
    val fencei = Output(Bool())
    val flushat = Output(Bool())
    val flushall = Output(Bool())

    // Scalar logging.
    val slog = Output(Bool())
  })

  val op = io.inst

  // Immediates
  io.imm12  := Cat(Fill(20, op(31)), op(31,20))
  io.imm20  := Cat(op(31,12), 0.U(12.W))
  io.immjal := Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
  io.immbr  := Cat(Fill(20, op(31)), op(7), op(30,25), op(11,8), 0.U(1.W))
  io.immcsr := op(19,15)
  io.immst  := Cat(Fill(20, op(31)), op(31,25), op(11,7))

  // RV32I
  io.lui   := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_0110111")
  io.auipc := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_0010111")
  io.jal   := DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_1101111")
  io.jalr  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_1100111")
  io.beq   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_000_xxxxx_1100011")
  io.bne   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_001_xxxxx_1100011")
  io.blt   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_100_xxxxx_1100011")
  io.bge   := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_101_xxxxx_1100011")
  io.bltu  := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_110_xxxxx_1100011")
  io.bgeu  := DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_111_xxxxx_1100011")
  io.csrrw := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x01_xxxxx_1110011")
  io.csrrs := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x10_xxxxx_1110011")
  io.csrrc := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_x11_xxxxx_1110011")
  io.lb    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0000011")
  io.lh    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_001_xxxxx_0000011")
  io.lw    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0000011")
  io.lbu   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_100_xxxxx_0000011")
  io.lhu   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_101_xxxxx_0000011")
  io.sb    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0100011")
  io.sh    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_001_xxxxx_0100011")
  io.sw    := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0100011")
  io.fence := DecodeBits(op, "0000_xxxx_xxxx_00000_000_00000_0001111")
  io.addi  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_000_xxxxx_0010011")
  io.slti  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_010_xxxxx_0010011")
  io.sltiu := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_011_xxxxx_0010011")
  io.xori  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_100_xxxxx_0010011")
  io.ori   := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_110_xxxxx_0010011")
  io.andi  := DecodeBits(op, "xxxxxxxxxxxx_xxxxx_111_xxxxx_0010011")
  io.slli  := DecodeBits(op, "0000000_xxxxx_xxxxx_001_xxxxx_0010011")
  io.srli  := DecodeBits(op, "0000000_xxxxx_xxxxx_101_xxxxx_0010011")
  io.srai  := DecodeBits(op, "0100000_xxxxx_xxxxx_101_xxxxx_0010011")
  io.add   := DecodeBits(op, "0000000_xxxxx_xxxxx_000_xxxxx_0110011")
  io.sub   := DecodeBits(op, "0100000_xxxxx_xxxxx_000_xxxxx_0110011")
  io.slt   := DecodeBits(op, "0000000_xxxxx_xxxxx_010_xxxxx_0110011")
  io.sltu  := DecodeBits(op, "0000000_xxxxx_xxxxx_011_xxxxx_0110011")
  io.xor   := DecodeBits(op, "0000000_xxxxx_xxxxx_100_xxxxx_0110011")
  io.or    := DecodeBits(op, "0000000_xxxxx_xxxxx_110_xxxxx_0110011")
  io.and   := DecodeBits(op, "0000000_xxxxx_xxxxx_111_xxxxx_0110011")
  io.sll   := DecodeBits(op, "0000000_xxxxx_xxxxx_001_xxxxx_0110011")
  io.srl   := DecodeBits(op, "0000000_xxxxx_xxxxx_101_xxxxx_0110011")
  io.sra   := DecodeBits(op, "0100000_xxxxx_xxxxx_101_xxxxx_0110011")

  // RV32M
  io.mul     := DecodeBits(op, "0000_001_xxxxx_xxxxx_000_xxxxx_0110011")
  io.mulh    := DecodeBits(op, "0000_001_xxxxx_xxxxx_001_xxxxx_0110011")
  io.mulhsu  := DecodeBits(op, "0000_001_xxxxx_xxxxx_010_xxxxx_0110011")
  io.mulhu   := DecodeBits(op, "0000_001_xxxxx_xxxxx_011_xxxxx_0110011")
  io.mulhr   := DecodeBits(op, "0010_001_xxxxx_xxxxx_001_xxxxx_0110011")
  io.mulhsur := DecodeBits(op, "0010_001_xxxxx_xxxxx_010_xxxxx_0110011")
  io.mulhur  := DecodeBits(op, "0010_001_xxxxx_xxxxx_011_xxxxx_0110011")
  io.dmulh   := DecodeBits(op, "0000_010_xxxxx_xxxxx_001_xxxxx_0110011")
  io.dmulhr  := DecodeBits(op, "0010_010_xxxxx_xxxxx_001_xxxxx_0110011")
  io.div     := DecodeBits(op, "0000_001_xxxxx_xxxxx_100_xxxxx_0110011")
  io.divu    := DecodeBits(op, "0000_001_xxxxx_xxxxx_101_xxxxx_0110011")
  io.rem     := DecodeBits(op, "0000_001_xxxxx_xxxxx_110_xxxxx_0110011")
  io.remu    := DecodeBits(op, "0000_001_xxxxx_xxxxx_111_xxxxx_0110011")

  // RV32B
  io.clz  := DecodeBits(op, "0110000_00000_xxxxx_001_xxxxx_0010011")
  io.ctz  := DecodeBits(op, "0110000_00001_xxxxx_001_xxxxx_0010011")
  io.pcnt := DecodeBits(op, "0110000_00010_xxxxx_001_xxxxx_0010011")
  io.min  := DecodeBits(op, "0000101_xxxxx_xxxxx_100_xxxxx_0110011")
  io.minu := DecodeBits(op, "0000101_xxxxx_xxxxx_101_xxxxx_0110011")
  io.max  := DecodeBits(op, "0000101_xxxxx_xxxxx_110_xxxxx_0110011")
  io.maxu := DecodeBits(op, "0000101_xxxxx_xxxxx_111_xxxxx_0110011")

  // Decode scalar log.
  val slog = DecodeBits(op, "01111_00_00000_xxxxx_0xx_00000_11101_11")

  // Vector length.
  io.getvl    := DecodeBits(op, "0001x_xx_xxxxx_xxxxx_000_xxxxx_11101_11") && op(26,25) =/= 3.U && (op(24,20) =/= 0.U || op(19,15) =/= 0.U)
  io.getmaxvl := DecodeBits(op, "0001x_xx_00000_00000_000_xxxxx_11101_11") && op(26,25) =/= 3.U

  // Vector load/store.
  io.vld := DecodeBits(op, "000xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11")     // vld

  io.vst := DecodeBits(op, "001xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11") ||  // vst
            DecodeBits(op, "011xxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11")     // vstq

  // Convolution transfer accumulators to vregs. Also decodes acset/actr ops.
  val vconv = DecodeBits(op, "010100_000000_000000_xx_xxxxxx_x_111_11")

  // Duplicate
  val vdup = DecodeBits(op, "01000x_0xxxxx_000000_xx_xxxxxx_x_111_11") && op(13,12) <= 2.U
  val vdupi = vdup && op(26) === 0.U

  // Vector instructions.
  io.viop := op(0) === 0.U ||     // .vv .vx
             op(1,0) === 1.U ||  // .vvv .vxv
             vconv || vdupi

  // [extensions] Core controls.
  io.ebreak := DecodeBits(op, "000000000001_00000_000_00000_11100_11")
  io.ecall  := DecodeBits(op, "000000000000_00000_000_00000_11100_11")
  io.eexit  := DecodeBits(op, "000000100000_00000_000_00000_11100_11")
  io.eyield := DecodeBits(op, "000001000000_00000_000_00000_11100_11")
  io.ectxsw := DecodeBits(op, "000001100000_00000_000_00000_11100_11")
  io.mpause := DecodeBits(op, "000010000000_00000_000_00000_11100_11")
  io.mret   := DecodeBits(op, "001100000010_00000_000_00000_11100_11")

  // Fences.
  io.fencei   := DecodeBits(op, "0000_0000_0000_00000_001_00000_0001111")
  io.flushat  := DecodeBits(op, "0010x_xx_00000_xxxxx_000_00000_11101_11") && op(19,15) =/= 0.U
  io.flushall := DecodeBits(op, "0010x_xx_00000_00000_000_00000_11101_11")

  // [extensions] Scalar logging.
  io.slog := slog

  // Stub out decoder state not used beyond pipeline0.
  if (pipeline > 0) {
    io.csrrw := false.B
    io.csrrs := false.B
    io.csrrc := false.B

    io.div := false.B
    io.divu := false.B
    io.rem := false.B
    io.remu := false.B

    io.ebreak := false.B
    io.ecall  := false.B
    io.eexit  := false.B
    io.eyield := false.B
    io.ectxsw := false.B
    io.mpause := false.B
    io.mret   := false.B

    io.fence    := false.B
    io.fencei   := false.B
    io.flushat  := false.B
    io.flushall := false.B

    io.slog := false.B
  }

  // Generate the undefined opcode.
  val decoded = Cat(io.lui, io.auipc,
                    io.jal, io.jalr,
                    io.beq, io.bne, io.blt, io.bge, io.bltu, io.bgeu,
                    io.csrrw, io.csrrs, io.csrrc,
                    io.lb, io.lh, io.lw, io.lbu, io.lhu,
                    io.sb, io.sh, io.sw, io.fence,
                    io.addi, io.slti, io.sltiu, io.xori, io.ori, io.andi,
                    io.add, io.sub, io.slt, io.sltu, io.xor, io.or, io.and,
                    io.slli, io.srli, io.srai, io.sll, io.srl, io.sra,
                    io.mul, io.mulh, io.mulhsu, io.mulhu, io.mulhr, io.mulhsur, io.mulhur, io.dmulh, io.dmulhr,
                    io.div, io.divu, io.rem, io.remu,
                    io.clz, io.ctz, io.pcnt, io.min, io.minu, io.max, io.maxu,
                    io.viop, io.vld, io.vst,
                    io.getvl, io.getmaxvl,
                    io.ebreak, io.ecall, io.eexit, io.eyield, io.ectxsw,
                    io.mpause, io.mret, io.fencei, io.flushat, io.flushall, io.slog)

  io.undef := !WiredOR(decoded)

  // Delay the assert until the next cycle, so that logs appear on console.
  val onehot_failed = RegInit(false.B)
  assert(!onehot_failed)

  val onehot_decode = PopCount(decoded)
  when ((onehot_decode + io.undef) =/= 1.U) {
    onehot_failed := true.B
    printf("[FAIL] decode  inst=%x  addr=%x  decoded=0b%b  pipeline=%d\n",
      io.inst, io.addr, decoded, pipeline.U)
  }
}
