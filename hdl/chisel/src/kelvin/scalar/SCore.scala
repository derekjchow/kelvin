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
package kelvin

import chisel3._
import chisel3.util._
import common._
import kelvin.rvv.{RvvCoreIO}
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

  val dispatch = if (p.useDispatchV2) {
      Module(new DispatchV2(p))
  } else {
      Module(new DispatchV1(p))
  }
  val alu = Seq.fill(p.instructionLanes)(Alu(p))
  val bru = (0 until p.instructionLanes).map(x => Seq(Bru(p, x == 0))).reduce(_ ++ _)
  val csr = Csr(p)
  val lsu = Lsu(p)
  val mlu = Mlu(p)
  val dvu = Dvu(p)

  // Wire up the core.
  val branchTaken = bru.map(x => x.io.taken.valid).reduce(_||_)

  // ---------------------------------------------------------------------------
  // IFlush
  val iflush = RegInit(false.B)

  when (bru(0).io.iflush.get) {
    iflush := true.B
  } .elsewhen (fetch.io.iflush.ready && io.iflush.ready &&
               lsu.io.flush.ready && lsu.io.flush.fencei) {
    iflush := false.B
  }

  io.dflush.valid := lsu.io.flush.valid
  io.dflush.all   := lsu.io.flush.all
  io.dflush.clean := lsu.io.flush.clean
  lsu.io.flush.ready := io.dflush.ready

  // ---------------------------------------------------------------------------
  // Fetch
  fetch.io.csr := io.csr.in

  for (i <- 0 until p.instructionLanes) {
    fetch.io.branch(i) := bru(i).io.taken
  }

  fetch.io.linkPort := regfile.io.linkPort

  fetch.io.iflush.valid := iflush

  // ---------------------------------------------------------------------------
  // Decode
  // Decode/Dispatch
  dispatch.io.inst <> fetch.io.inst.lanes
  dispatch.io.halted := csr.io.halted || csr.io.wfi
  dispatch.io.mactive := io.vcore.map(_.mactive).getOrElse(false.B)
  dispatch.io.lsuActive := lsu.io.active
  dispatch.io.scoreboard.comb := regfile.io.scoreboard.comb
  dispatch.io.scoreboard.regd := regfile.io.scoreboard.regd
  dispatch.io.branchTaken := branchTaken
  dispatch.io.interlock := bru(0).io.interlock.get

  // Connect fault signaling from IBUS/LSU to BRU.
  bru(0).io.fault := MuxCase(MakeInvalid(new FaultInfo(p)), Array(
    io.ibus.fault.valid -> io.ibus.fault,
    lsu.io.fault.valid -> lsu.io.fault,
  ))
  bru(0).io.ibus_fault := io.ibus.fault.valid
  for (i <- 1 until p.instructionLanes) {
    bru(i).io.fault := 0.U.asTypeOf(bru(i).io.fault)
    bru(i).io.ibus_fault := 0.U.asTypeOf(bru(i).io.ibus_fault)
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
  }

  bru(0).io.csr.get <> csr.io.bru

  io.iflush.valid := iflush

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

  csr.io.req <> dispatch.io.csr
  csr.io.rs1 := regfile.io.readData(0)

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

  val mluDvuOffset = p.instructionLanes
  val mluDvuInputs = if (p.enableRvv) { 3 } else { 2 }
  val arb = Module(new Arbiter(new RegfileWriteDataIO, mluDvuInputs))
  arb.io.in(0) <> mlu.io.rd
  arb.io.in(1) <> dvu.io.rd
  if (p.enableRvv) {
    arb.io.in(2) <> io.rvvcore.get.async_rd
  }
  arb.io.out.ready := true.B
  regfile.io.writeData(mluDvuOffset).valid := arb.io.out.valid
  regfile.io.writeData(mluDvuOffset).bits.addr := arb.io.out.bits.addr
  regfile.io.writeData(mluDvuOffset).bits.data := arb.io.out.bits.data

  val lsuOffset = p.instructionLanes + 1
  regfile.io.writeData(lsuOffset).valid := lsu.io.rd.valid
  regfile.io.writeData(lsuOffset).bits.addr  := lsu.io.rd.bits.addr
  regfile.io.writeData(lsuOffset).bits.data  := lsu.io.rd.bits.data

  val writeMask = bru.map(_.io.taken.valid).scan(false.B)(_||_)
  for (i <- 0 until p.instructionLanes) {
    regfile.io.writeMask(i).valid := writeMask(i)
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

    // Register inputs
    io.rvvcore.get.rs := regfile.io.readData
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
    debugAddr(i) := fetch.io.inst.lanes(i).bits.addr
    debugInst(i) := fetch.io.inst.lanes(i).bits.inst
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
}

object EmitSCore extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new SCore(p), args)
}
