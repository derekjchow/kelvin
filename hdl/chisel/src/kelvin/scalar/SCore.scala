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

    val ibus = new IBusIO(p)
    val dbus = new DBusIO(p)
    val ubus = new DBusIO(p)
    val vldst = Output(Bool())

    val vcore = Flipped(new VCoreIO(p))

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  // The functional units that make up the core.
  val regfile = Regfile(p)
  val fetch = Fetch(p)
  val decode = Seq(Decode(p, 0), Decode(p, 1), Decode(p, 2), Decode(p, 3))
  val alu = Seq.fill(4)(Alu(p))
  val bru = Seq.fill(4)(Bru(p))
  val csr = Csr(p)
  val lsu = Lsu(p)
  val mlu = Mlu(p)
  val dvu = Dvu(p)

  // Wire up the core.
  val branchTaken = bru(0).io.taken.valid || bru(1).io.taken.valid ||
                    bru(2).io.taken.valid || bru(3).io.taken.valid

  // ---------------------------------------------------------------------------
  // IFlush
  val iflush = RegInit(false.B)

  when (bru(0).io.iflush) {
    iflush := true.B
  } .elsewhen (fetch.io.iflush.ready && io.iflush.ready &&
               lsu.io.flush.ready && lsu.io.flush.fencei) {
    iflush := false.B
  }

  io.dflush.valid := lsu.io.flush.valid
  io.dflush.all   := lsu.io.flush.all
  io.dflush.clean := lsu.io.flush.clean
  lsu.io.flush.ready := io.dflush.ready

  assert(!bru(1).io.iflush)
  assert(!bru(2).io.iflush)
  assert(!bru(3).io.iflush)

  // ---------------------------------------------------------------------------
  // Fetch
  fetch.io.csr := io.csr.in

  for (i <- 0 until 4) {
    fetch.io.branch(i) := bru(i).io.taken
  }

  fetch.io.linkPort := regfile.io.linkPort

  fetch.io.iflush.valid := iflush

  // ---------------------------------------------------------------------------
  // Decode
  val mask = VecInit(true.B,
                     decode(0).io.inst.ready,
                     decode(0).io.inst.ready && decode(1).io.inst.ready,
                     decode(0).io.inst.ready && decode(1).io.inst.ready &&
                       decode(2).io.inst.ready)

  for (i <- 0 until 4) {
    decode(i).io.inst.valid := fetch.io.inst.lanes(i).valid && mask(i)
    fetch.io.inst.lanes(i).ready := decode(i).io.inst.ready && mask(i)
    decode(i).io.inst.addr := fetch.io.inst.lanes(i).addr
    decode(i).io.inst.inst := fetch.io.inst.lanes(i).inst
    decode(i).io.inst.brchFwd := fetch.io.inst.lanes(i).brchFwd

    decode(i).io.branchTaken := branchTaken
    decode(i).io.halted := csr.io.halted
  }

  // Interlock based on regfile write port dependencies.
  decode(0).io.interlock := bru(0).io.interlock
  decode(1).io.interlock := decode(0).io.interlock
  decode(2).io.interlock := decode(1).io.interlock
  decode(3).io.interlock := decode(2).io.interlock

  // Serialize opcodes with only one pipeline.
  decode(0).io.serializeIn.defaults()
  decode(1).io.serializeIn := decode(0).io.serializeOut
  decode(2).io.serializeIn := decode(1).io.serializeOut
  decode(3).io.serializeIn := decode(2).io.serializeOut

  // In decode update multi-issue scoreboard state.
  val scoreboard_spec1 = decode(0).io.scoreboard.spec
  val scoreboard_spec2 = decode(1).io.scoreboard.spec | scoreboard_spec1
  val scoreboard_spec3 = decode(2).io.scoreboard.spec | scoreboard_spec2
  assert(scoreboard_spec1.getWidth == 32)
  assert(scoreboard_spec2.getWidth == 32)
  assert(scoreboard_spec3.getWidth == 32)

  decode(0).io.scoreboard.comb := regfile.io.scoreboard.comb
  decode(0).io.scoreboard.regd := regfile.io.scoreboard.regd
  decode(1).io.scoreboard.comb := regfile.io.scoreboard.comb | scoreboard_spec1
  decode(1).io.scoreboard.regd := regfile.io.scoreboard.regd | scoreboard_spec1
  decode(2).io.scoreboard.comb := regfile.io.scoreboard.comb | scoreboard_spec2
  decode(2).io.scoreboard.regd := regfile.io.scoreboard.regd | scoreboard_spec2
  decode(3).io.scoreboard.comb := regfile.io.scoreboard.comb | scoreboard_spec3
  decode(3).io.scoreboard.regd := regfile.io.scoreboard.regd | scoreboard_spec3


  decode(0).io.mactive := io.vcore.mactive
  decode(1).io.mactive := false.B
  decode(2).io.mactive := false.B
  decode(3).io.mactive := false.B

  // ---------------------------------------------------------------------------
  // ALU
  for (i <- 0 until 4) {
    alu(i).io.req := decode(i).io.alu
    alu(i).io.rs1 := regfile.io.readData(2 * i + 0)
    alu(i).io.rs2 := regfile.io.readData(2 * i + 1)
  }

  // ---------------------------------------------------------------------------
  // Branch Unit
  for (i <- 0 until 4) {
    bru(i).io.req := decode(i).io.bru
    bru(i).io.rs1 := regfile.io.readData(2 * i + 0)
    bru(i).io.rs2 := regfile.io.readData(2 * i + 1)
    bru(i).io.target := regfile.io.target(i)
  }

  bru(0).io.csr <> csr.io.bru
  bru(1).io.csr.defaults()
  bru(2).io.csr.defaults()
  bru(3).io.csr.defaults()

  io.iflush.valid := iflush

  // ---------------------------------------------------------------------------
  // Control Status Unit
  csr.io.csr <> io.csr

  csr.io.req <> decode(0).io.csr
  csr.io.rs1 := regfile.io.readData(0)

  csr.io.vcore.undef := io.vcore.undef

  // ---------------------------------------------------------------------------
  // Status
  io.halted := csr.io.halted
  io.fault  := csr.io.fault

  // ---------------------------------------------------------------------------
  // Load/Store Unit
  lsu.io.busPort := regfile.io.busPort

  for (i <- 0 until 4) {
    lsu.io.req(i).valid := decode(i).io.lsu.valid
    lsu.io.req(i).store := decode(i).io.lsu.store
    lsu.io.req(i).addr  := decode(i).io.lsu.addr
    lsu.io.req(i).op    := decode(i).io.lsu.op
    decode(i).io.lsu.ready := lsu.io.req(i).ready
  }

  // ---------------------------------------------------------------------------
  // Multiplier Unit
  mlu.io.req(0) := decode(0).io.mlu
  mlu.io.req(1) := decode(1).io.mlu
  mlu.io.req(2) := decode(2).io.mlu
  mlu.io.req(3) := decode(3).io.mlu
  mlu.io.rs1(0) := regfile.io.readData(0)
  mlu.io.rs1(1) := regfile.io.readData(2)
  mlu.io.rs1(2) := regfile.io.readData(4)
  mlu.io.rs1(3) := regfile.io.readData(6)
  mlu.io.rs2(0) := regfile.io.readData(1)
  mlu.io.rs2(1) := regfile.io.readData(3)
  mlu.io.rs2(2) := regfile.io.readData(5)
  mlu.io.rs2(3) := regfile.io.readData(7)

  // ---------------------------------------------------------------------------
  // Divide Unit
  dvu.io.req <> decode(0).io.dvu
  dvu.io.rs1 := regfile.io.readData(0)
  dvu.io.rs2 := regfile.io.readData(1)
  dvu.io.rd.ready := !mlu.io.rd.valid

  // TODO: make port conditional on pipeline index.
  for (i <- 1 until 4) {
    decode(i).io.dvu.ready := false.B
  }

  // ---------------------------------------------------------------------------
  // Register File
  for (i <- 0 until 4) {
    regfile.io.readAddr(2 * i + 0) := decode(i).io.rs1Read
    regfile.io.readAddr(2 * i + 1) := decode(i).io.rs2Read
    regfile.io.readSet(2 * i + 0) := decode(i).io.rs1Set
    regfile.io.readSet(2 * i + 1) := decode(i).io.rs2Set
    regfile.io.writeAddr(i) := decode(i).io.rdMark
    regfile.io.busAddr(i) := decode(i).io.busRead

    val csr0Valid = if (i == 0) csr.io.rd.valid else false.B
    val csr0Addr  = if (i == 0) csr.io.rd.addr else 0.U
    val csr0Data  = if (i == 0) csr.io.rd.data else 0.U


    regfile.io.writeData(i).valid := csr0Valid ||
                                     alu(i).io.rd.valid || bru(i).io.rd.valid ||
                                     io.vcore.rd(i).valid

    regfile.io.writeData(i).addr :=
        MuxOR(csr0Valid, csr0Addr) |
        MuxOR(alu(i).io.rd.valid, alu(i).io.rd.addr) |
        MuxOR(bru(i).io.rd.valid, bru(i).io.rd.addr) |
        MuxOR(io.vcore.rd(i).valid, io.vcore.rd(i).addr)

    regfile.io.writeData(i).data :=
        MuxOR(csr0Valid, csr0Data) |
        MuxOR(alu(i).io.rd.valid, alu(i).io.rd.data) |
        MuxOR(bru(i).io.rd.valid, bru(i).io.rd.data) |
        MuxOR(io.vcore.rd(i).valid, io.vcore.rd(i).data)

    assert((csr0Valid +&
            alu(i).io.rd.valid +& bru(i).io.rd.valid +&
            io.vcore.rd(i).valid) <= 1.U)
  }

  regfile.io.writeData(4).valid := mlu.io.rd.valid || dvu.io.rd.valid
  regfile.io.writeData(4).addr := Mux(mlu.io.rd.valid, mlu.io.rd.addr, dvu.io.rd.addr)
  regfile.io.writeData(4).data := Mux(mlu.io.rd.valid, mlu.io.rd.data, dvu.io.rd.data)
  assert(!(mlu.io.rd.valid && (dvu.io.rd.valid && dvu.io.rd.ready)))  // TODO: stall dvu on mlu write

  regfile.io.writeData(5).valid := lsu.io.rd.valid
  regfile.io.writeData(5).addr  := lsu.io.rd.addr
  regfile.io.writeData(5).data  := lsu.io.rd.data

  regfile.io.writeMask(0).valid := false.B
  regfile.io.writeMask(1).valid := regfile.io.writeMask(0).valid ||
                                     bru(0).io.taken.valid
  regfile.io.writeMask(2).valid := regfile.io.writeMask(1).valid ||
                                     bru(1).io.taken.valid
  regfile.io.writeMask(3).valid := regfile.io.writeMask(2).valid ||
                                     bru(2).io.taken.valid

  // ---------------------------------------------------------------------------
  // Vector Extension
  for (i <- 0 until 4) {
    io.vcore.vinst(i) <> decode(i).io.vinst
  }

  for (i <- 0 until 8) {
    io.vcore.rs(i) := regfile.io.readData(i)
  }

  // ---------------------------------------------------------------------------
  // Fetch Bus
  io.ibus <> fetch.io.ibus

  // ---------------------------------------------------------------------------
  // Local Data Bus Port
  io.dbus <> lsu.io.dbus
  io.ubus <> lsu.io.ubus

  io.vldst := lsu.io.vldst

  // ---------------------------------------------------------------------------
  // Scalar logging interface
  val slogValid = RegInit(false.B)
  val slogAddr = Reg(UInt(2.W))
  val slogEn = decode(0).io.slog

  slogValid := slogEn
  when (slogEn) {
    slogAddr := decode(0).io.inst.inst(14,12)
  }

  io.slog.valid := slogValid
  io.slog.addr  := MuxOR(slogValid, slogAddr)
  io.slog.data  := MuxOR(slogValid, regfile.io.readData(0).data)

  // ---------------------------------------------------------------------------
  // DEBUG
  val cycles = RegInit(0.U(32.W))
  cycles := cycles + 1.U
  io.debug.cycles := cycles

  val debugEn = RegInit(0.U(4.W))
  val debugAddr = Reg(Vec(4, UInt(32.W)))
  val debugInst = Reg(Vec(4, UInt(32.W)))

  val debugBrch =
    Cat(bru(0).io.taken.valid || bru(1).io.taken.valid || bru(2).io.taken.valid,
        bru(0).io.taken.valid || bru(1).io.taken.valid,
        bru(0).io.taken.valid,
        false.B)

  debugEn := Cat(fetch.io.inst.lanes(3).valid && fetch.io.inst.lanes(3).ready && !branchTaken,
                 fetch.io.inst.lanes(2).valid && fetch.io.inst.lanes(2).ready && !branchTaken,
                 fetch.io.inst.lanes(1).valid && fetch.io.inst.lanes(1).ready && !branchTaken,
                 fetch.io.inst.lanes(0).valid && fetch.io.inst.lanes(0).ready && !branchTaken)

  debugAddr(0) := fetch.io.inst.lanes(0).addr
  debugAddr(1) := fetch.io.inst.lanes(1).addr
  debugAddr(2) := fetch.io.inst.lanes(2).addr
  debugAddr(3) := fetch.io.inst.lanes(3).addr
  debugInst(0) := fetch.io.inst.lanes(0).inst
  debugInst(1) := fetch.io.inst.lanes(1).inst
  debugInst(2) := fetch.io.inst.lanes(2).inst
  debugInst(3) := fetch.io.inst.lanes(3).inst

  io.debug.en := debugEn & ~debugBrch

  io.debug.addr0 := debugAddr(0)
  io.debug.addr1 := debugAddr(1)
  io.debug.addr2 := debugAddr(2)
  io.debug.addr3 := debugAddr(3)
  io.debug.inst0 := debugInst(0)
  io.debug.inst1 := debugInst(1)
  io.debug.inst2 := debugInst(2)
  io.debug.inst3 := debugInst(3)
}

object EmitSCore extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new SCore(p), args)
}
