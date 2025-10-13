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


// Scalar Core Frontend
package coralnpu

import chisel3._
import chisel3.util._
import common._
import coralnpu.float.{FloatCore}
import coralnpu.rvv.{RvvCoreIO}
import _root_.circt.stage.ChiselStage

object SCore {
  def apply(p: Parameters): SCore = {
    return Module(new SCore(p))
  }
}

class SCore(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())
    val wfi = Output(Bool())
    val irq = Input(Bool())
    val dm = Option.when(p.useDebugModule)(new CoreDMIO(p))

    val ibus = new IBusIO(p)
    val dbus = new DBusIO(p)
    val ebus = new EBusIO(p)

    val vldst = Option.when(p.enableVector)(Output(Bool()))
    val vcore = Option.when(p.enableVector)(Flipped(new VCoreIO(p)))

    val rvvcore = Option.when(p.enableRvv)(Flipped(new RvvCoreIO(p)))

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  // The functional units that make up the core.
  val regfile = Regfile(p)
  val fetch = if (p.enableFetchL0) { Fetch(p) } else { Module(new UncachedFetch(p)) }

  val csr = Csr(p)
  val dispatch = if (p.useDispatchV2) {
      Module(new DispatchV2(p))
  } else {
      Module(new DispatchV1(p))
  }

  val retirement_buffer = Option.when(p.useRetirementBuffer)(Module(new RetirementBuffer(p)))
  if (p.useRetirementBuffer) {
    retirement_buffer.get.io.inst := dispatch.io.inst
    retirement_buffer.get.io.writeAddrScalar := dispatch.io.rdMark
    (0 until p.instructionLanes + 2).foreach(i => {
      retirement_buffer.get.io.writeDataScalar(i) := regfile.io.writeData(i)
    })
    dispatch.io.retirement_buffer_nSpace.get := retirement_buffer.get.io.nSpace
    if (p.enableRvv) {
      retirement_buffer.get.io.writeAddrVector.get := dispatch.io.rvvRdMark.get
      (0 until p.instructionLanes).foreach(i => {
        retirement_buffer.get.io.writeDataVector.get(i).valid := io.rvvcore.get.rd_rob2rt_o(i).w_valid
        retirement_buffer.get.io.writeDataVector.get(i).bits.addr := io.rvvcore.get.rd_rob2rt_o(i).w_index
        retirement_buffer.get.io.writeDataVector.get(i).bits.data := io.rvvcore.get.rd_rob2rt_o(i).w_data
      })
    }
  }

  if (p.useDebugModule) {
    dispatch.io.single_step.get := csr.io.dm.get.single_step || csr.io.dm.get.dcsr_step
    dispatch.io.debug_mode.get := csr.io.dm.get.debug_mode
  }

  val alu = Seq.fill(p.instructionLanes)(Alu(p))
  val bru = (0 until p.instructionLanes).map(x => Seq(Bru(p, x == 0))).reduce(_ ++ _)
  val lsu = Lsu(p)
  val mlu = Mlu(p)
  val dvu = Dvu(p)

  // Wire up the core.
  val branchTaken = bru.map(x => x.io.taken.valid).reduce(_||_)

  // ---------------------------------------------------------------------------
  // Flush logic
  io.dflush.valid := lsu.io.flush.valid && !lsu.io.flush.fencei
  io.dflush.all   := lsu.io.flush.all
  io.dflush.clean := lsu.io.flush.clean

  io.iflush.valid  := lsu.io.flush.valid && lsu.io.flush.fencei
  io.iflush.pcNext := lsu.io.flush.pcNext
  fetch.io.iflush.valid := lsu.io.flush.valid && lsu.io.flush.fencei
  fetch.io.iflush.pcNext := lsu.io.flush.pcNext

  lsu.io.flush.ready := lsu.io.flush.valid &&
      Mux(lsu.io.flush.fencei, fetch.io.iflush.ready, io.dflush.ready)

  // ---------------------------------------------------------------------------
  // Fetch
  fetch.io.csr := io.csr.in

  for (i <- 0 until p.instructionLanes) {
    fetch.io.branch(i) := bru(i).io.taken
  }

  fetch.io.linkPort := regfile.io.linkPort

  // ---------------------------------------------------------------------------
  // Decode
  // Decode/Dispatch
  dispatch.io.inst <> fetch.io.inst.lanes
  dispatch.io.halted := csr.io.halted || csr.io.wfi || csr.io.dm.map(_.debug_mode).getOrElse(false.B)
  dispatch.io.mactive := io.vcore.map(_.mactive).getOrElse(false.B)
  dispatch.io.lsuActive := lsu.io.active
  dispatch.io.lsuQueueCapacity := lsu.io.queueCapacity
  dispatch.io.scoreboard.comb := regfile.io.scoreboard.comb
  dispatch.io.scoreboard.regd := regfile.io.scoreboard.regd
  dispatch.io.branchTaken := branchTaken
  dispatch.io.interlock := bru(0).io.interlock.get || lsu.io.flush.valid

  // Connect fault signaling to FaultManager.
  val fault_manager = Module(new FaultManager(p))
  for (i <- 0 until p.instructionLanes) {
    fault_manager.io.in.fault(i).csr := dispatch.io.csrFault(i)
    fault_manager.io.in.fault(i).jal := dispatch.io.jalFault(i)
    fault_manager.io.in.fault(i).jalr := dispatch.io.jalrFault(i)
    fault_manager.io.in.fault(i).bxx := dispatch.io.bxxFault(i)
    fault_manager.io.in.fault(i).undef := dispatch.io.undefFault(i)
    if (p.enableRvv) {
      fault_manager.io.in.fault(i).rvv.get := dispatch.io.rvvFault.get(i)
    }
    fault_manager.io.in.pc(i).pc := fetch.io.inst.lanes(i).bits.addr
    fault_manager.io.in.jalr(i).target := regfile.io.target(i).data
    fault_manager.io.in.undef(i).inst := fetch.io.inst.lanes(i).bits.inst
    fault_manager.io.in.jal(i).target := dispatch.io.bruTarget(i)
  }
  fault_manager.io.in.memory_fault := MuxCase(MakeInvalid(new FaultInfo(p)), Seq(
    io.ibus.fault.valid -> io.ibus.fault,
    lsu.io.fault.valid -> lsu.io.fault,
  ))
  fault_manager.io.in.ibus_fault := io.ibus.fault.valid
  if (p.enableRvv) {
    fault_manager.io.in.rvv_fault.get.valid := io.rvvcore.get.trap.valid
    fault_manager.io.in.rvv_fault.get.bits.mepc := io.rvvcore.get.trap.bits.pc
    fault_manager.io.in.rvv_fault.get.bits.mcause := 2.U(32.W)
    fault_manager.io.in.rvv_fault.get.bits.mtval :=
        io.rvvcore.get.trap.bits.originalEncoding()
    fault_manager.io.in.rvv_fault.get.bits.decode := false.B
  }
  bru(0).io.fault_manager.get := fault_manager.io.out
  if (p.useRetirementBuffer) {
    retirement_buffer.get.io.fault := fault_manager.io.out
    retirement_buffer.get.io.storeComplete := lsu.io.storeComplete
  }

  // ---------------------------------------------------------------------------
  // ALU
  for (i <- 0 until p.instructionLanes) {
    alu(i).io.req := dispatch.io.alu(i)
    alu(i).io.rs1 := regfile.io.readData(2 * i + 0)
    alu(i).io.rs2 := regfile.io.readData(2 * i + 1)
  }

  // ---------------------------------------------------------------------------
  // Branch Unit
  for (i <- 0 until p.instructionLanes) {
    bru(i).io.req := dispatch.io.bru(i)
    bru(i).io.rs1 := regfile.io.readData(2 * i + 0)
    bru(i).io.rs2 := regfile.io.readData(2 * i + 1)
    bru(i).io.target := regfile.io.target(i)
    dispatch.io.jalrTarget(i) := regfile.io.target(i)
  }

  bru(0).io.csr.get <> csr.io.bru

  // Instruction counters
  csr.io.counters.rfwriteCount := regfile.io.rfwriteCount
  csr.io.counters.storeCount := lsu.io.storeCount
  csr.io.counters.branchCount := bru(0).io.taken.valid
  if (p.enableVector) {
    csr.io.counters.vrfwriteCount.get := io.vcore.get.vrfwriteCount
    csr.io.counters.vstoreCount.get := io.vcore.get.vstoreCount
  }

  // ---------------------------------------------------------------------------
  // Control Status Unit
  csr.io.csr <> io.csr
  csr.io.csr.in.value(12) := fetch.io.pc

  // Arbitrate requests from Dispatch and DM
  if (p.useDebugModule) {
    val csrReqArbiter = Module(new Arbiter(new CsrCmd, 2))
    csrReqArbiter.io.in(0).bits := dispatch.io.csr.bits
    csrReqArbiter.io.in(0).valid := dispatch.io.csr.valid
    csrReqArbiter.io.in(1).valid := io.dm.get.csr.valid
    csrReqArbiter.io.in(1).bits := io.dm.get.csr.bits
    csrReqArbiter.io.out.ready := true.B
    csr.io.req.bits := csrReqArbiter.io.out.bits
    csr.io.req.valid := csrReqArbiter.io.out.valid
  } else {
    csr.io.req.bits := dispatch.io.csr.bits
    csr.io.req.valid := dispatch.io.csr.valid
  }

  if (p.useDebugModule) {
    val dmRs1 = Wire(new RegfileReadDataIO)
    dmRs1.valid := true.B
    dmRs1.data := io.dm.get.csr_rs1
    csr.io.rs1 := Mux(RegNext(dispatch.io.csr.valid, false.B), regfile.io.readData(0), dmRs1)
    io.dm.get.csr_rd := MakeValid(csr.io.rd.valid, csr.io.rd.bits.data)
    csr.io.dm.get.next_pc := MuxCase(dispatch.io.inst(0).bits.addr, Seq(
      dispatch.io.inst(0).valid -> dispatch.io.inst(0).bits.addr,
      fetch.io.branch(0).valid -> fetch.io.branch(0).value,
      dispatch.io.bru(0).valid -> dispatch.io.bru(0).bits.target,
    ))
    csr.io.dm.get.debug_req := io.dm.get.debug_req || /* Request from external debugger */
                               (!csr.io.dm.get.debug_mode && csr.io.dm.get.dcsr_step && dispatch.io.inst(0).fire) /* Single-step via CSR */
    csr.io.dm.get.resume_req := io.dm.get.resume_req
    io.dm.get.debug_mode := csr.io.dm.get.debug_mode
  } else {
    csr.io.rs1 := regfile.io.readData(0)
  }

  if (p.enableVector) {
    csr.io.vcore.get.undef := io.vcore.get.undef
  }

  // ---------------------------------------------------------------------------
  // Status
  io.halted := csr.io.halted
  io.fault  := csr.io.fault
  io.wfi    := csr.io.wfi
  csr.io.irq := io.irq

  // ---------------------------------------------------------------------------
  // Load/Store Unit
  lsu.io.busPort := regfile.io.busPort
  lsu.io.req <> dispatch.io.lsu
  if (p.enableRvv) {
    lsu.io.rvvState.get := io.rvvcore.get.configState
    lsu.io.lsu2rvv.get <> io.rvvcore.get.lsu2rvv
    io.rvvcore.get.rvv2lsu <> lsu.io.rvv2lsu.get
  }

  // ---------------------------------------------------------------------------
  // Multiplier Unit
  for (i <- 0 until p.instructionLanes) {
    mlu.io.req(i) <> dispatch.io.mlu(i)
    mlu.io.rs1(i) := regfile.io.readData(2 * i)
    mlu.io.rs2(i) := regfile.io.readData((2 * i) + 1)
  }

  // ---------------------------------------------------------------------------
  // Divide Unit
  dvu.io.req <> dispatch.io.dvu(0)
  dvu.io.rs1 := regfile.io.readData(0)
  dvu.io.rs2 := regfile.io.readData(1)
  dvu.io.rd.ready := !mlu.io.rd.valid

  // TODO: make port conditional on pipeline index.
  for (i <- 1 until p.instructionLanes) {
    dispatch.io.dvu(i).ready := false.B
  }

  // ---------------------------------------------------------------------------
  // Register File
  for (i <- 0 until p.instructionLanes) {
    regfile.io.readAddr(2 * i + 0) := dispatch.io.rs1Read(i)
    regfile.io.readAddr(2 * i + 1) := dispatch.io.rs2Read(i)
    regfile.io.readSet(2 * i + 0) := dispatch.io.rs1Set(i)
    regfile.io.readSet(2 * i + 1) := dispatch.io.rs2Set(i)
    regfile.io.writeAddr(i) := dispatch.io.rdMark(i)
    regfile.io.busAddr(i) := dispatch.io.busRead(i)

    if (p.useDebugModule) {
      regfile.io.debugBusPort.get <> io.dm.get.scalar_rs
    }

    val csr0Valid = if (i == 0) csr.io.rd.valid else false.B
    val csr0Addr  = if (i == 0) csr.io.rd.bits.addr else 0.U
    val csr0Data  = if (i == 0) csr.io.rd.bits.data else 0.U

    val rvvCoreRdValid = io.rvvcore.map(_.rd(i).valid).getOrElse(false.B)
    val rvvCoreRdAddr = MuxOR(
        rvvCoreRdValid, io.rvvcore.map(_.rd(i).bits.addr).getOrElse(0.U))
    val rvvCoreRdData = MuxOR(
        rvvCoreRdValid, io.rvvcore.map(_.rd(i).bits.data).getOrElse(0.U))

    regfile.io.writeData(i).valid := csr0Valid ||
                                     alu(i).io.rd.valid || bru(i).io.rd.valid ||
                                     (if (p.enableVector) {
                                        io.vcore.get.rd(i).valid
                                      } else { false.B }) ||
                                     rvvCoreRdValid

    regfile.io.writeData(i).bits.addr :=
        MuxOR(csr0Valid, csr0Addr) |
        MuxOR(alu(i).io.rd.valid, alu(i).io.rd.bits.addr) |
        MuxOR(bru(i).io.rd.valid, bru(i).io.rd.bits.addr) |
        (if (p.enableVector) {
           MuxOR(io.vcore.get.rd(i).valid, io.vcore.get.rd(i).bits.addr)
         } else { false.B }) |
        rvvCoreRdAddr

    regfile.io.writeData(i).bits.data :=
        MuxOR(csr0Valid, csr0Data) |
        MuxOR(alu(i).io.rd.valid, alu(i).io.rd.bits.data) |
        MuxOR(bru(i).io.rd.valid, bru(i).io.rd.bits.data) |
        (if (p.enableVector) {
           MuxOR(io.vcore.get.rd(i).valid, io.vcore.get.rd(i).bits.data)
         } else { false.B }) |
        rvvCoreRdData

    if (p.enableVector) {
      assert((csr0Valid +&
              alu(i).io.rd.valid +& bru(i).io.rd.valid +&
              io.vcore.get.rd(i).valid) <= 1.U)
    } else {
      if (p.enableRvv) {
        assert((csr0Valid +&
                alu(i).io.rd.valid +& bru(i).io.rd.valid +&
                io.rvvcore.get.rd(i).valid) <= 1.U)
      } else {
        assert((csr0Valid +&
               alu(i).io.rd.valid +& bru(i).io.rd.valid) <= 1.U)
      }
    }
  }

  // RV32F extension
  val floatCore = Option.when(p.enableFloat)(FloatCore(p))
  val floatReadPorts = 3
  val floatWritePorts = 2
  val fRegfile = Option.when(p.enableFloat)(Module(new FRegfile(p, floatReadPorts, floatWritePorts)))
  if (p.enableFloat) {
    lsu.io.busPort_flt.get := fRegfile.get.io.busPort
    fRegfile.get.io.busPortAddr := dispatch.io.fbusPortAddr.get
    floatCore.get.io.read_ports <> fRegfile.get.io.read_ports
    floatCore.get.io.write_ports <> fRegfile.get.io.write_ports
    fRegfile.get.io.scoreboard_set :=
      MuxOR(dispatch.io.rdMark_flt.get.valid, UIntToOH(dispatch.io.rdMark_flt.get.addr))
    if (p.useDebugModule) {
      // Mux input to read port
      fRegfile.get.io.read_ports(0).valid := MuxCase(false.B, Seq(
        io.dm.get.float_rs.get.valid -> true.B,
        floatCore.get.io.read_ports(0).valid -> true.B,
      ))
      fRegfile.get.io.read_ports(0).addr := MuxCase(0.U, Seq(
        io.dm.get.float_rs.get.valid -> io.dm.get.float_rs.get.addr,
        floatCore.get.io.read_ports(0).valid -> floatCore.get.io.read_ports(0).addr,
      ))
      // Broadcast data back from read port
      io.dm.get.float_rs.get.data := fRegfile.get.io.read_ports(0).data
      floatCore.get.io.read_ports(0).data := fRegfile.get.io.read_ports(0).data

      // Mux input to write port
      fRegfile.get.io.write_ports(0).valid := MuxCase(false.B, Seq(
        io.dm.get.float_rd.get.valid -> true.B,
        floatCore.get.io.write_ports(0).valid -> true.B,
      ))
      fRegfile.get.io.write_ports(0).addr := MuxCase(0.U, Seq(
        io.dm.get.float_rd.get.valid -> io.dm.get.float_rd.get.addr,
        floatCore.get.io.write_ports(0).valid -> floatCore.get.io.write_ports(0).addr,
      ))
      fRegfile.get.io.write_ports(0).data := MuxCase(Fp32.Zero(false.B), Seq(
        io.dm.get.float_rd.get.valid -> io.dm.get.float_rd.get.data,
        floatCore.get.io.write_ports(0).valid -> floatCore.get.io.write_ports(0).data,
      ))
      fRegfile.get.io.dm_write_valid.get := io.dm.get.float_rd.get.valid
    }


    floatCore.get.io.inst <> dispatch.io.float.get
    dispatch.io.fscoreboard.get := fRegfile.get.io.scoreboard
    floatCore.get.io.csr <> csr.io.float.get
    floatCore.get.io.rs1 := regfile.io.readData(0)
    floatCore.get.io.rs2 := regfile.io.readData(1)

    floatCore.get.io.lsu_rd.valid := lsu.io.rd_flt.valid
    floatCore.get.io.lsu_rd.bits.addr := lsu.io.rd_flt.bits.addr
    floatCore.get.io.lsu_rd.bits.data := lsu.io.rd_flt.bits.data

    if (p.useRetirementBuffer) {
      retirement_buffer.get.io.writeAddrFloat.get := dispatch.io.rdMark_flt.get
      (0 until 2).foreach(i => {
        retirement_buffer.get.io.writeDataFloat.get(i).valid := fRegfile.get.io.write_ports(i).valid
        retirement_buffer.get.io.writeDataFloat.get(i).bits.addr := fRegfile.get.io.write_ports(i).addr
        retirement_buffer.get.io.writeDataFloat.get(i).bits.data := fRegfile.get.io.write_ports(i).data.asWord
      })
    }
  }

  val mluDvuOffset = p.instructionLanes
  val mluDvuInputs = Seq(mlu.io.rd, dvu.io.rd) ++
                     io.rvvcore.map(x => Seq(x.async_rd)).getOrElse(Seq()) ++
                     floatCore.map(x => Seq(x.io.scalar_rd)).getOrElse(Seq()) ++
                     io.dm.map(x => Seq(io.dm.get.scalar_rd)).getOrElse(Seq())

  val arb = Module(new Arbiter(new RegfileWriteDataIO, mluDvuInputs.length))
  arb.io.in <> mluDvuInputs
  arb.io.out.ready := true.B
  regfile.io.writeData(mluDvuOffset).valid := arb.io.out.valid
  regfile.io.writeData(mluDvuOffset).bits.addr := arb.io.out.bits.addr
  regfile.io.writeData(mluDvuOffset).bits.data := arb.io.out.bits.data
  // MLU/DVU port is never masked
  regfile.io.writeMask(p.instructionLanes).valid := false.B

  val lsuOffset = p.instructionLanes + 1
  regfile.io.writeData(lsuOffset).valid := lsu.io.rd.valid
  regfile.io.writeData(lsuOffset).bits.addr  := lsu.io.rd.bits.addr
  regfile.io.writeData(lsuOffset).bits.data  := lsu.io.rd.bits.data
  // Mask LSU based on fault for LsuV2 only
  regfile.io.writeMask(lsuOffset).valid := (
      if (p.useLsuV2) { lsu.io.fault.valid } else { false.B })

  val writeMask = bru.map(_.io.taken.valid).scan(false.B)(_||_)
  for (i <- 0 until p.instructionLanes) {
    regfile.io.writeMask(i).valid := writeMask(i)
  }
  if (p.useDebugModule) {
    regfile.io.debugWriteValid.get := io.dm.get.scalar_rd.valid
  }

  // ---------------------------------------------------------------------------
  // Vector Extension
  if (p.enableVector) {
    io.vcore.get.vinst <> dispatch.io.vinst.get
    io.vcore.get.rs := regfile.io.readData
  }

  // ---------------------------------------------------------------------------
  // Rvv Extension
  if (p.enableRvv) {
    // Connect dispatch
    dispatch.io.rvv.get <> io.rvvcore.get.inst
    dispatch.io.rvvState.get := io.rvvcore.get.configState
    dispatch.io.rvvIdle.get := io.rvvcore.get.rvv_idle
    dispatch.io.rvvQueueCapacity.get := io.rvvcore.get.queue_capacity

    // Register inputs
    io.rvvcore.get.rs := regfile.io.readData

    io.rvvcore.get.csr.vstart_write <> csr.io.rvv.get.vstart_write
    io.rvvcore.get.csr.vxrm_write <> csr.io.rvv.get.vxrm_write
    io.rvvcore.get.csr.vxsat_write <> csr.io.rvv.get.vxsat_write
    csr.io.rvv.get.vstart := io.rvvcore.get.csr.vstart
    csr.io.rvv.get.vl := io.rvvcore.get.configState.bits.vl
    csr.io.rvv.get.vtype := io.rvvcore.get.configState.bits.vtype
    csr.io.rvv.get.vxrm := io.rvvcore.get.csr.vxrm
    csr.io.rvv.get.vxsat := io.rvvcore.get.csr.vxsat
  }

  // ---------------------------------------------------------------------------
  // Fetch Bus
  // Mux valid
  io.ibus.valid := Mux(lsu.io.ibus.valid, lsu.io.ibus.valid, fetch.io.ibus.valid)
  // Mux addr
  io.ibus.addr := Mux(lsu.io.ibus.valid, lsu.io.ibus.addr, fetch.io.ibus.addr)
  // Arbitrate ready
  lsu.io.ibus.ready := Mux(lsu.io.ibus.valid, io.ibus.ready, false.B)
  fetch.io.ibus.ready := Mux(lsu.io.ibus.valid, false.B, io.ibus.ready)
  // Broadcast rdata
  lsu.io.ibus.rdata := io.ibus.rdata
  fetch.io.ibus.rdata := io.ibus.rdata

  // Tie-off ibus faults in fetch/lsu (unused)
  fetch.io.ibus.fault := MakeInvalid(new FaultInfo(p))
  lsu.io.ibus.fault := MakeInvalid(new FaultInfo(p))

  // ---------------------------------------------------------------------------
  // Local Data Bus Port
  io.dbus <> lsu.io.dbus
  io.ebus <> lsu.io.ebus

  if (p.enableVector) {
    io.vldst.get := lsu.io.vldst
  }

  // ---------------------------------------------------------------------------
  // Scalar logging interface
  val slogValid = RegInit(false.B)
  val slogAddr = RegInit(0.U(2.W))
  val slogEn = dispatch.io.slog

  slogValid := slogEn
  when (slogEn) {
    slogAddr := dispatch.io.inst(0).bits.inst(14,12)
  }

  io.slog.valid := slogValid
  io.slog.addr  := MuxOR(slogValid, slogAddr)
  io.slog.data  := MuxOR(slogValid, regfile.io.readData(0).data)

  // ---------------------------------------------------------------------------
  // DEBUG
  io.debug.cycles := csr.io.csr.out.value(4)

  val debugEn = RegInit(0.U(p.instructionLanes.W))
  val debugAddr = RegInit(VecInit.fill(p.instructionLanes)(0.U(32.W)))
  val debugInst = RegInit(VecInit.fill(p.instructionLanes)(0.U(32.W)))

  val debugBrch = Cat(bru.map(_.io.taken.valid).scanRight(false.B)(_ || _))

  debugEn := Cat(fetch.io.inst.lanes.map(x => x.valid && x.ready && !branchTaken))

  for (i <- 0 until p.instructionLanes) {
    debugAddr(i) := Mux(debugEn(i), fetch.io.inst.lanes(i).bits.addr, debugAddr(i))
    debugInst(i) := Mux(debugEn(i), fetch.io.inst.lanes(i).bits.inst, debugInst(i))
  }

  io.debug.en := debugEn & ~debugBrch

  io.debug.addr <> debugAddr
  io.debug.inst <> debugInst

  io.debug.dbus.valid := io.dbus.valid
  io.debug.dbus.bits.addr := io.dbus.addr
  io.debug.dbus.bits.wdata := io.dbus.wdata
  io.debug.dbus.bits.write := io.dbus.write

  for (i <- 0 until p.instructionLanes) {
    io.debug.dispatch(i).instFire := dispatch.io.inst(i).fire
    io.debug.dispatch(i).instAddr := dispatch.io.inst(i).bits.addr
    io.debug.dispatch(i).instInst := dispatch.io.inst(i).bits.inst
  }

  for (i <- 0 until p.instructionLanes) {
    io.debug.regfile.writeAddr(i).valid := regfile.io.writeAddr(i).valid
    io.debug.regfile.writeAddr(i).bits := regfile.io.writeAddr(i).addr
  }

  for (i <- 0 until p.instructionLanes + 2) {
    io.debug.regfile.writeData(i) := regfile.io.writeData(i)
  }

  if (p.enableFloat) {
    io.debug.float.get.writeAddr.valid := dispatch.io.rdMark_flt.get.valid
    io.debug.float.get.writeAddr.bits := dispatch.io.rdMark_flt.get.addr
    for (i <- 0 until 2) {
      io.debug.float.get.writeData(i).valid := fRegfile.get.io.write_ports(i).valid
      io.debug.float.get.writeData(i).bits.addr := fRegfile.get.io.write_ports(i).addr
      io.debug.float.get.writeData(i).bits.data := fRegfile.get.io.write_ports(i).data.asWord
    }
  }

  if (p.useRetirementBuffer) {
    io.debug.rb.get := retirement_buffer.get.io.debug
    val rvvi = Module(new RvviTrace(p))
    rvvi.io.rb := retirement_buffer.get.io.debug
    rvvi.io.csr := csr.io.trace.get
  }
}

object EmitSCore extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new SCore(p), args)
}
