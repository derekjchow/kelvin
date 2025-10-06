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

package coralnpu

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
  val MPAUSE = Value
  val MRET = Value
  val WFI = Value
  val FAULT = Value
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

    // Execute cycle.
    val csr = Option.when(first)(new CsrBruIO(p))
    val rs1 = Input(new RegfileReadDataIO)
    val rs2 = Input(new RegfileReadDataIO)
    val rd  = Valid(Flipped(new RegfileWriteDataIO))
    val taken = new BranchTakenIO(p)
    val target = Flipped(new RegfileBranchTargetIO)
    val interlock = Option.when(first)(Output(Bool()))

    val fault_manager = Option.when(first)(Input(Valid(Flipped(new FaultManagerOutput))))
  })

  // Assign state
  val mode = if (first) { io.csr.get.out.mode } else { CsrMode.Machine }
  val fault_manager_valid = io.fault_manager.map(_.valid).getOrElse(false.B)

  val pcDe  = io.req.bits.pc
  val pc4De = io.req.bits.pc + 4.U

  val stateReg = RegInit(MakeValid(false.B, BranchState.default(p)))
  val nextState = Wire(new BranchState(p))
  nextState.linkValid := io.req.valid && (io.req.bits.link =/= 0.U) &&
               (io.req.bits.op.isOneOf(BruOp.JAL, BruOp.JALR))

  nextState.op := Mux(fault_manager_valid, BruOp.FAULT, io.req.bits.op)
  nextState.fwd := io.req.valid && io.req.bits.fwd

  nextState.linkAddr := io.req.bits.link
  nextState.linkData := pc4De
  nextState.pcEx := pcDe
  nextState.inst := io.req.bits.inst

  val mtvec = if (first) { Cat(io.csr.get.out.mtvec(31,2), 0.U(2.W)) } else { 0.U(32.W )}
  val pipeline0Target = if (first) {
    val mret = (io.req.bits.op === BruOp.MRET) && mode === CsrMode.Machine
    val ecall = io.req.bits.op === BruOp.ECALL
    val call = ((io.req.bits.op === BruOp.MRET) && mode === CsrMode.User) ||
        io.req.bits.op.isOneOf(BruOp.EBREAK, BruOp.MPAUSE)
    MuxCase(io.req.bits.target, Seq(
      ecall -> mtvec,
      mret -> io.csr.get.out.mepc,
      call -> io.csr.get.out.mepc,
      (io.req.bits.op === BruOp.WFI) -> pc4De,
    ))
  } else { io.req.bits.target }
  nextState.target := MuxCase(pipeline0Target, Seq(
      // Faults
      fault_manager_valid -> mtvec,
      // Normal operation
      io.req.bits.fwd -> pc4De,
      ((io.req.bits.op === BruOp.JALR)) -> (io.target.data & "xFFFFFFFE".U),
  ))
  val stateRegValid = io.req.valid || fault_manager_valid
  stateReg.valid := stateRegValid
  stateReg.bits := Mux(stateRegValid, nextState, stateReg.bits)

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
      BruOp.MPAUSE,
      BruOp.MRET,
      BruOp.WFI,
    ))
  }

  // This mux contains the subset of ops that are only emitted in pipeline slot 0.
  val pipeline0Taken = if (first) {
    MuxLookup(op, false.B)(Seq(
      BruOp.EBREAK -> (mode === CsrMode.User),
      // Any mode can execute `ecall`, but the value of `mcause` will be different.
      BruOp.ECALL  -> true.B,
      BruOp.MPAUSE -> (mode === CsrMode.User),
      BruOp.MRET   -> (mode === CsrMode.Machine),
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
    BruOp.FAULT  -> true.B,
  ))

  io.taken.value := stateReg.bits.target

  io.rd.valid := stateReg.valid && stateReg.bits.linkValid
  io.rd.bits.addr := stateReg.bits.linkAddr
  io.rd.bits.data := stateReg.bits.linkData

  if (first) {
    io.interlock.get := stateReg.valid &&
      op.isOneOf(
        BruOp.EBREAK, BruOp.ECALL,
        BruOp.MPAUSE, BruOp.MRET, BruOp.FAULT)
    // Usage Fault.
    val usageFault = (stateReg.valid && Mux(
              (mode === CsrMode.User),
              op.isOneOf(BruOp.MPAUSE, BruOp.MRET),
              op.isOneOf(BruOp.EBREAK)))

    io.csr.get.in.mode.valid := stateReg.valid && Mux(
        (mode === CsrMode.User), op.isOneOf(BruOp.EBREAK, BruOp.ECALL,
                                            BruOp.MPAUSE, BruOp.MRET, BruOp.FAULT),
              (op === BruOp.MRET))
    io.csr.get.in.mode.bits := Mux(((op === BruOp.MRET) && (mode === CsrMode.Machine)), CsrMode.Machine, CsrMode.User)

    io.csr.get.in.mepc.valid :=
      (stateReg.valid && (op === BruOp.ECALL)) ||
      io.fault_manager.get.valid
    io.csr.get.in.mepc.bits := MuxCase(stateReg.bits.pcEx, Seq(
      io.fault_manager.get.valid -> io.fault_manager.get.bits.mepc,
    ))

    io.csr.get.in.mcause.valid := (stateReg.valid &&
      (
        usageFault ||
        (op === BruOp.ECALL) ||
        ((mode === CsrMode.User) && (op === BruOp.EBREAK))
      ) || io.fault_manager.get.valid
    )

    io.csr.get.in.mcause.bits := MuxCase(0.U, Seq(
        // RISC-V standard exceptions.
        io.fault_manager.get.valid -> io.fault_manager.get.bits.mcause,
        (op === BruOp.ECALL && mode === CsrMode.Machine)  -> 11.U,
        (op === BruOp.ECALL && mode === CsrMode.User)  -> 8.U,
        (op === BruOp.EBREAK) -> 3.U,
        // CoralNPU-specific things, use the custom reserved region of the encoding space.
        usageFault            -> (24 + 1).U,
    ))

    io.csr.get.in.mtval.valid :=
      (stateReg.valid && usageFault) || io.fault_manager.get.valid
    io.csr.get.in.mtval.bits := MuxCase(stateReg.bits.pcEx, Seq(
      io.fault_manager.get.valid -> io.fault_manager.get.bits.mtval,
    ))

    // Pipeline will be halted.
    io.csr.get.in.halt := (stateReg.valid && (op === BruOp.MPAUSE) && (mode === CsrMode.Machine)) ||
                      io.csr.get.in.fault
    // Faults that should halt the processor.
    // A fault that can be handled by software exception routines should
    // not be captured here.
    io.csr.get.in.fault :=
      ((usageFault && (mode === CsrMode.Machine)))
    io.csr.get.in.wfi := stateReg.valid && (op === BruOp.WFI)
  }

  // Assertions.
  val ignore = op.isOneOf(BruOp.JAL, BruOp.JALR, BruOp.EBREAK, BruOp.ECALL,
                          BruOp.MPAUSE, BruOp.MRET, BruOp.WFI, BruOp.FAULT)

  assert(!(stateReg.valid && !io.rs1.valid) || ignore)
  assert(!(stateReg.valid && !io.rs2.valid) || ignore)
}
