package kelvin

import chisel3._
import chisel3.util._
import common._

object Bru {
  def apply(p: Parameters): Bru = {
    return Module(new Bru(p))
  }
}

case class BruOp() {
  val JAL  = 0
  val JALR = 1
  val BEQ  = 2
  val BNE  = 3
  val BLT  = 4
  val BGE  = 5
  val BLTU = 6
  val BGEU = 7
  val EBREAK = 8
  val ECALL = 9
  val EEXIT = 10
  val EYIELD = 11
  val ECTXSW = 12
  val MPAUSE = 13
  val MRET = 14
  val FENCEI = 15
  val UNDEF = 16
  val Entries = 17
}

class BruIO(p: Parameters) extends Bundle {
  val valid = Input(Bool())
  val fwd = Input(Bool())
  val op = Input(UInt(new BruOp().Entries.W))
  val pc = Input(UInt(p.programCounterBits.W))
  val target = Input(UInt(p.programCounterBits.W))
  val link = Input(UInt(5.W))
}

class BranchTakenIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val value = Output(UInt(p.programCounterBits.W))
}

class Bru(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = new BruIO(p)

    // Execute cycle.
    val csr = new CsrBruIO(p)
    val rs1 = Input(new RegfileReadDataIO)
    val rs2 = Input(new RegfileReadDataIO)
    val rd  = Flipped(new RegfileWriteDataIO)
    val taken = new BranchTakenIO(p)
    val target = Flipped(new RegfileBranchTargetIO)
    val interlock = Output(Bool())
    val iflush = Output(Bool())
  })

  val branch = new BruOp()

  val interlock = RegInit(false.B)

  val readRs = RegInit(false.B)
  val fwd = RegInit(false.B)
  val op = RegInit(0.U(branch.Entries.W))
  val target = Reg(UInt(p.programCounterBits.W))
  val linkValid = RegInit(false.B)
  val linkAddr = Reg(UInt(5.W))
  val linkData = Reg(UInt(p.programCounterBits.W))
  val pcEx = Reg(UInt(32.W))

  linkValid := io.req.valid && io.req.link =/= 0.U &&
               (io.req.op(branch.JAL) || io.req.op(branch.JALR))

  op := Mux(io.req.valid, io.req.op, 0.U)
  fwd := io.req.valid && io.req.fwd

  readRs := Mux(io.req.valid,
            io.req.op(branch.BEQ)  || io.req.op(branch.BNE) ||
            io.req.op(branch.BLT)  || io.req.op(branch.BGE) ||
            io.req.op(branch.BLTU) || io.req.op(branch.BGEU), false.B)

  val mode = io.csr.out.mode  // (0) machine, (1) user

  val pcDe  = io.req.pc
  val pc4De = io.req.pc + 4.U

  when (io.req.valid) {
    val mret = io.req.op(branch.MRET) && !mode
    val call = io.req.op(branch.MRET) && mode ||
               io.req.op(branch.EBREAK) ||
               io.req.op(branch.ECALL) ||
               io.req.op(branch.EEXIT) ||
               io.req.op(branch.EYIELD) ||
               io.req.op(branch.ECTXSW) ||
               io.req.op(branch.MPAUSE)
    target := Mux(mret, io.csr.out.mepc,
              Mux(call, io.csr.out.mtvec,
              Mux(io.req.fwd || io.req.op(branch.FENCEI), pc4De,
              Mux(io.req.op(branch.JALR), io.target.data,
                  io.req.target))))
    linkAddr := io.req.link
    linkData := pc4De
    pcEx := pcDe
  }

  interlock := io.req.valid && (io.req.op(branch.EBREAK) ||
                 io.req.op(branch.ECALL) || io.req.op(branch.EEXIT) ||
                 io.req.op(branch.EYIELD) || io.req.op(branch.ECTXSW) ||
                 io.req.op(branch.MPAUSE) || io.req.op(branch.MRET))

  io.interlock := interlock

  // This mux sits on the critical path.
  // val rs1 = Mux(readRs, io.rs1.data, 0.U)
  // val rs2 = Mux(readRs, io.rs2.data, 0.U)
  val rs1 = io.rs1.data
  val rs2 = io.rs2.data

  val eq  = rs1 === rs2
  val neq = !eq
  val lt  = rs1.asSInt < rs2.asSInt
  val ge  = !lt
  val ltu = rs1 < rs2
  val geu = !ltu

  io.taken.valid := op(branch.EBREAK) && mode ||
                    op(branch.ECALL)  && mode ||
                    op(branch.EEXIT)  && mode ||
                    op(branch.EYIELD) && mode ||
                    op(branch.ECTXSW) && mode ||
                    op(branch.MRET)   && !mode ||
                    op(branch.MRET)   && mode ||  // fault
                    op(branch.MPAUSE) && mode ||  // fault
                    op(branch.FENCEI) ||
                    (op(branch.JAL) ||
                     op(branch.JALR) ||
                     op(branch.BEQ)  && eq  ||
                     op(branch.BNE)  && neq ||
                     op(branch.BLT)  && lt  ||
                     op(branch.BGE)  && ge  ||
                     op(branch.BLTU) && ltu ||
                     op(branch.BGEU) && geu) =/= fwd

  io.taken.value := target

  io.rd.valid := linkValid
  io.rd.addr := linkAddr
  io.rd.data := linkData

  // Undefined Fault.
  val undefFault = op(branch.UNDEF)

  // Usage Fault.
  val usageFault = op(branch.EBREAK) && !mode ||
                   op(branch.ECALL)  && !mode ||
                   op(branch.EEXIT)  && !mode ||
                   op(branch.EYIELD) && !mode ||
                   op(branch.ECTXSW) && !mode ||
                   op(branch.MPAUSE) && mode ||
                   op(branch.MRET)   && mode

  io.csr.in.mode.valid := op(branch.EBREAK) && mode ||
                          op(branch.ECALL)  && mode ||
                          op(branch.EEXIT)  && mode ||
                          op(branch.EYIELD) && mode ||
                          op(branch.ECTXSW) && mode ||
                          op(branch.MPAUSE) && mode ||  // fault
                          op(branch.MRET)   && mode ||  // fault
                          op(branch.MRET)   && !mode
  io.csr.in.mode.bits := MuxOR(op(branch.MRET) && !mode, true.B)

  io.csr.in.mepc.valid := op(branch.EBREAK) && mode ||
                          op(branch.ECALL)  && mode ||
                          op(branch.EEXIT)  && mode ||
                          op(branch.EYIELD) && mode ||
                          op(branch.ECTXSW) && mode ||
                          op(branch.MPAUSE) && mode ||  // fault
                          op(branch.MRET)   && mode     // fault
  io.csr.in.mepc.bits := Mux(op(branch.EYIELD), linkData, pcEx)

  io.csr.in.mcause.valid := undefFault || usageFault ||
                            op(branch.EBREAK) && mode ||
                            op(branch.ECALL)  && mode ||
                            op(branch.EEXIT)  && mode ||
                            op(branch.EYIELD) && mode ||
                            op(branch.ECTXSW) && mode

  val faultMsb = 1.U << 31
  io.csr.in.mcause.bits := Mux(undefFault, 2.U  | faultMsb,
                           Mux(usageFault, 16.U | faultMsb,
                             MuxOR(op(branch.EBREAK), 1.U) |
                             MuxOR(op(branch.ECALL),  2.U) |
                             MuxOR(op(branch.EEXIT),  3.U) |
                             MuxOR(op(branch.EYIELD), 4.U) |
                             MuxOR(op(branch.ECTXSW), 5.U)))

  io.csr.in.mtval.valid := undefFault || usageFault
  io.csr.in.mtval.bits := pcEx

  io.iflush := op(branch.FENCEI)

  // Pipeline will be halted.
  io.csr.in.halt := op(branch.MPAUSE) && !mode || io.csr.in.fault
  io.csr.in.fault := undefFault && !mode || usageFault && !mode

  // Assertions.
  val valid = RegInit(false.B)
  val ignore = op(branch.JAL) || op(branch.JALR) || op(branch.EBREAK) ||
               op(branch.ECALL) || op(branch.EEXIT) || op(branch.EYIELD) ||
               op(branch.ECTXSW) || op(branch.MPAUSE) || op(branch.MRET) ||
               op(branch.FENCEI) || op(branch.UNDEF)

  valid := io.req.valid
  assert(!(valid && !io.rs1.valid) || ignore)
  assert(!(valid && !io.rs2.valid) || ignore)
}
