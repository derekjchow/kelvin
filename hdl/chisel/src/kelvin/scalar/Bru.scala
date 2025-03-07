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

object Bru {
  def apply(p: Parameters, first: Boolean): Bru = {
    return Module(new Bru(p, first))
  }
}

object BruOp extends ChiselEnum {
  val JAL  = Value
  val JALR = Value
  val BEQ  = Value
  val BNE  = Value
  val BLT  = Value
  val BGE  = Value
  val BLTU = Value
  val BGEU = Value
  val EBREAK = Value
  val ECALL = Value
  val EEXIT = Value
  val EYIELD = Value
  val ECTXSW = Value
  val MPAUSE = Value
  val MRET = Value
  val FENCEI = Value
  val WFI = Value
  val UNDEF = Value
}

class BruCmd(p: Parameters) extends Bundle {
  val fwd = Bool()
  val op = BruOp()
  val pc = UInt(p.programCounterBits.W)
  val target = UInt(p.programCounterBits.W)
  val link = UInt(5.W)
  val inst = UInt(32.W)
}

class BranchState(p: Parameters) extends Bundle {
  val fwd = Bool()
  val op = BruOp()
  val target = UInt(p.programCounterBits.W)
  val linkValid = Bool()
  val linkAddr = UInt(5.W)
  val linkData = UInt(p.programCounterBits.W)
  val pcEx = UInt(32.W)
  val inst = UInt(32.W)
}

object BranchState {
  def default(p: Parameters): BranchState = {
    val result = Wire(new BranchState(p))
    result.fwd := false.B
    result.op := BruOp.JAL
    result.target := 0.U
    result.linkValid := false.B
    result.linkAddr := 0.U
    result.linkData := 0.U
    result.pcEx := 0.U
    result.inst := 0.U
    result
  }
}

/** A unit which calculates branch targets and handles
 * associated control flow changes and exceptions.
 * @param p Parameters for the overall core.
 * @param first Whether this unit is the first in the
                pipeline of branch units.
 */
class Bru(p: Parameters, first: Boolean) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Flipped(Valid(new BruCmd(p)))
    val fault = Flipped(Valid(new FaultInfo(p)))
    val ibus_fault = Input(Bool())

    // Execute cycle.
    val csr = Option.when(first)(new CsrBruIO(p))
    val rs1 = Input(new RegfileReadDataIO)
    val rs2 = Input(new RegfileReadDataIO)
    val rd  = Valid(Flipped(new RegfileWriteDataIO))
    val taken = new BranchTakenIO(p)
    val target = Flipped(new RegfileBranchTargetIO)
    val interlock = Option.when(first)(Output(Bool()))
    val iflush = Option.when(first)(Output(Bool()))
  })

  // Interlock
  if (first) {
    val interlock = RegInit(false.B)
    interlock := io.req.valid && io.req.bits.op.isOneOf(
        BruOp.EBREAK, BruOp.ECALL, BruOp.EEXIT, BruOp.EYIELD, BruOp.ECTXSW,
        BruOp.MPAUSE, BruOp.MRET)
    io.interlock.get := interlock
  }

  // Assign state
  val mode = if (first) { io.csr.get.out.mode } else { CsrMode.Machine }

  val pcDe  = io.req.bits.pc
  val pc4De = io.req.bits.pc + 4.U


  val stateReg = RegInit(MakeValid(false.B, BranchState.default(p)))
  val nextState = Wire(new BranchState(p))
  nextState.linkValid := io.req.valid && (io.req.bits.link =/= 0.U) &&
               (io.req.bits.op.isOneOf(BruOp.JAL, BruOp.JALR))

  nextState.op := io.req.bits.op
  nextState.fwd := io.req.valid && io.req.bits.fwd

  nextState.linkAddr := io.req.bits.link
  nextState.linkData := pc4De
  nextState.pcEx := pcDe
  nextState.inst := io.req.bits.inst

  val pipeline0Target = if (first) {
    val mret = (io.req.bits.op === BruOp.MRET) && mode === CsrMode.Machine
    val ecall = io.req.bits.op === BruOp.ECALL
    val call = ((io.req.bits.op === BruOp.MRET) && mode === CsrMode.User) ||
        io.req.bits.op.isOneOf(BruOp.EBREAK, BruOp.EEXIT,
                               BruOp.EYIELD, BruOp.ECTXSW, BruOp.MPAUSE)
    MuxCase(io.req.bits.target, Seq(
      mret -> io.csr.get.out.mepc,
      ecall -> Cat(io.csr.get.out.mtvec(31,2), 0.U(2.W)),
      call -> io.csr.get.out.mepc,
      ((io.req.bits.op === BruOp.FENCEI) || (io.req.bits.op === BruOp.WFI)) -> pc4De,
    ))
  } else { io.req.bits.target }
  nextState.target := MuxCase(pipeline0Target, Seq(
      io.req.bits.fwd -> pc4De,
      (io.req.bits.op === BruOp.JALR) -> io.target.data,
  ))
  stateReg.valid := io.req.valid
  stateReg.bits := nextState

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

  val op = stateReg.bits.op
  // These ops should only be decoded on pipeline0.
  if (!first) {
    assert(!op.isOneOf(
      BruOp.EBREAK,
      BruOp.ECALL,
      BruOp.EEXIT,
      BruOp.EYIELD,
      BruOp.ECTXSW,
      BruOp.MPAUSE,
      BruOp.MRET,
      BruOp.FENCEI,
      BruOp.WFI,
    ))
  }

  // This mux contains the subset of ops that are only emitted in pipeline slot 0.
  val pipeline0Taken = if (first) {
    MuxLookup(op, false.B)(Seq(
      BruOp.EBREAK -> (mode === CsrMode.User),
      // Any mode can execute `ecall`, but the value of `mcause` will be different.
      BruOp.ECALL  -> true.B,
      BruOp.EEXIT  -> (mode === CsrMode.User),
      BruOp.EYIELD -> (mode === CsrMode.User),
      BruOp.ECTXSW -> (mode === CsrMode.User),
      BruOp.MPAUSE -> (mode === CsrMode.User),
      BruOp.MRET   -> (mode === CsrMode.Machine),
      BruOp.FENCEI -> true.B,
      BruOp.WFI    -> true.B,
    ))
  } else { false.B }

  io.taken.valid := stateReg.valid && MuxLookup(op, pipeline0Taken)(Seq(
    BruOp.JAL    -> (true.B =/= stateReg.bits.fwd),
    BruOp.JALR   -> (true.B =/= stateReg.bits.fwd),
    BruOp.BEQ    -> (eq  =/= stateReg.bits.fwd),
    BruOp.BNE    -> (neq =/= stateReg.bits.fwd),
    BruOp.BLT    -> (lt  =/= stateReg.bits.fwd),
    BruOp.BGE    -> (ge  =/= stateReg.bits.fwd),
    BruOp.BLTU   -> (ltu =/= stateReg.bits.fwd),
    BruOp.BGEU   -> (geu =/= stateReg.bits.fwd),
  ))
  io.taken.value := stateReg.bits.target

  io.rd.valid := stateReg.valid && stateReg.bits.linkValid
  io.rd.bits.addr := stateReg.bits.linkAddr
  io.rd.bits.data := stateReg.bits.linkData

  if (first) {
    val mret = (io.req.bits.op === BruOp.MRET) && mode === CsrMode.Machine
    val jalr_fault = io.req.valid && (io.req.bits.op === BruOp.JALR) && ((io.target.data & 0x3.U) =/= 0.U)
    val mret_fault = io.req.valid && mret && ((io.csr.get.out.mepc & 0x3.U) =/= 0.U)
    val jal_fault = io.req.valid && (io.req.bits.op === BruOp.JAL) && ((io.req.bits.target & 0x3.U) =/= 0.U)
    val bxx_fault =
      io.req.valid &&
      (io.req.bits.op.isOneOf(BruOp.BEQ, BruOp.BNE, BruOp.BLT, BruOp.BGE, BruOp.BLTU, BruOp.BGEU) &&
      ((io.req.bits.target & 0x3.U) =/= 0.U))

    // Undefined Fault.
    val undefFault = stateReg.valid && (op === BruOp.UNDEF)

    // Usage Fault.
    val usageFault = (stateReg.valid && Mux(
              (mode === CsrMode.User),
              op.isOneOf(BruOp.MPAUSE, BruOp.MRET),
              op.isOneOf(BruOp.EBREAK, BruOp.EEXIT, BruOp.EYIELD,
                         BruOp.ECTXSW)))

    io.csr.get.in.mode.valid := stateReg.valid && Mux(
        (mode === CsrMode.User), op.isOneOf(BruOp.EBREAK, BruOp.ECALL, BruOp.EEXIT, BruOp.EYIELD,
                         BruOp.ECTXSW, BruOp.MPAUSE, BruOp.MRET),
              (op === BruOp.MRET))
    io.csr.get.in.mode.bits := Mux(((op === BruOp.MRET) && (mode === CsrMode.Machine)), CsrMode.Machine, CsrMode.User)

    io.csr.get.in.mepc.valid :=
      (stateReg.valid && (op === BruOp.ECALL)) ||
      io.fault.valid ||
      jalr_fault ||
      mret_fault ||
      jal_fault ||
      bxx_fault ||
      undefFault
    io.csr.get.in.mepc.bits := MuxCase(stateReg.bits.pcEx, Array(
      io.fault.valid -> io.fault.bits.epc,
      jalr_fault -> pcDe,
      mret_fault -> io.csr.get.out.mepc,
      jal_fault -> pcDe,
      bxx_fault -> pcDe,
      undefFault -> stateReg.bits.pcEx,
    ))

    io.csr.get.in.mcause.valid := (stateReg.valid &&
      (undefFault || usageFault ||
      op.isOneOf(BruOp.ECALL) ||
      ((mode === CsrMode.User) &&
            /* user mode mcause triggers */
            op.isOneOf(BruOp.EBREAK,
                       BruOp.EEXIT, BruOp.EYIELD,
                       BruOp.ECTXSW),
      )) || io.fault.valid || jalr_fault || mret_fault || jal_fault || bxx_fault
    )

    io.csr.get.in.mcause.bits := MuxCase(0.U, Seq(
        // RISC-V standard exceptions, in priority order.
        (op === BruOp.EBREAK) -> 3.U,
        (io.fault.valid && io.ibus_fault) -> 1.U,
        jalr_fault            -> 0.U,
        mret_fault            -> 0.U,
        jal_fault             -> 0.U,
        bxx_fault             -> 0.U,
        undefFault            -> 2.U,
        (op === BruOp.ECALL && mode === CsrMode.Machine)  -> 11.U,
        (op === BruOp.ECALL && mode === CsrMode.User)  -> 8.U,
        (io.fault.valid && io.fault.bits.write) -> 7.U,
        (io.fault.valid && !io.fault.bits.write) -> 5.U,
        // Kelvin-specific things, use the custom reserved region of the encoding space.
        usageFault            -> (24 + 1).U,
        (op === BruOp.EEXIT)  -> (24 + 2).U,
        (op === BruOp.EYIELD) -> (24 + 3).U,
        (op === BruOp.ECTXSW) -> (24 + 4).U,
    ))

    io.csr.get.in.mtval.valid :=
      (stateReg.valid && (undefFault || usageFault)) ||
      io.fault.valid ||
      jalr_fault ||
      mret_fault ||
      jal_fault || bxx_fault
    io.csr.get.in.mtval.bits := MuxCase(stateReg.bits.pcEx, Array(
      io.fault.valid -> io.fault.bits.addr,
      jalr_fault -> 0.U,
      mret_fault -> 0.U,
      jal_fault -> 0.U,
      bxx_fault -> 0.U,
      undefFault -> stateReg.bits.inst,
    ))
    // Pipeline will be halted.
    io.csr.get.in.halt := (stateReg.valid && (op === BruOp.MPAUSE) && (mode === CsrMode.Machine)) ||
                      io.csr.get.in.fault
    io.csr.get.in.fault :=
      (undefFault && (mode === CsrMode.Machine)) || (usageFault && (mode === CsrMode.Machine)) ||
      io.fault.valid ||
      jalr_fault || mret_fault || jal_fault || bxx_fault
    io.csr.get.in.wfi := stateReg.valid && (op === BruOp.WFI)

    io.iflush.get := stateReg.valid && op.isOneOf(BruOp.FENCEI, BruOp.WFI)
  }

  // Assertions.
  val ignore = op.isOneOf(BruOp.JAL, BruOp.JALR, BruOp.EBREAK, BruOp.ECALL,
                          BruOp.EEXIT, BruOp.EYIELD, BruOp.ECTXSW, BruOp.MPAUSE,
                          BruOp.MRET, BruOp.FENCEI, BruOp.UNDEF, BruOp.WFI)

  assert(!(stateReg.valid && !io.rs1.valid) || ignore)
  assert(!(stateReg.valid && !io.rs2.valid) || ignore)
}
