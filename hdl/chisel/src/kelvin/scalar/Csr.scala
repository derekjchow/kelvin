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

object Csr {
  def apply(p: Parameters): Csr = {
    return Module(new Csr(p))
  }
}

case class CsrOp() {
  val CSRRW = 0
  val CSRRS = 1
  val CSRRC = 2
  val Entries = 3
}

class CsrInIO(p: Parameters) extends Bundle {
  val value = Input(Vec(12, UInt(32.W)))
}

class CsrOutIO(p: Parameters) extends Bundle {
  val value = Output(Vec(8, UInt(32.W)))
}

class CsrInOutIO(p: Parameters) extends Bundle {
  val in  = new CsrInIO(p)
  val out = new CsrOutIO(p)
}

class CsrCounters(p: Parameters) extends Bundle {
  val rfwriteCount = UInt(3.W)
  val storeCount = UInt(2.W)
  val branchCount = UInt(1.W)
  val vrfwriteCount = UInt(3.W)
  val vstoreCount = UInt(2.W)
}

class CsrBruIO(p: Parameters) extends Bundle {
  val in = new Bundle {
    val mode   = Valid(Bool())
    val mcause = Valid(UInt(32.W))
    val mepc   = Valid(UInt(32.W))
    val mtval  = Valid(UInt(32.W))
    val halt   = Output(Bool())
    val fault  = Output(Bool())
  }
  val out = new Bundle {
    val mode  = Input(Bool())
    val mepc  = Input(UInt(32.W))
    val mtvec = Input(UInt(32.W))
  }
  def defaults() = {
    out.mode := false.B
    out.mepc := 0.U
    out.mtvec := 0.U
  }
}

class CsrIO(p: Parameters) extends Bundle {
  val valid = Input(Bool())
  val addr = Input(UInt(5.W))
  val index = Input(UInt(12.W))
  val op = Input(UInt(new CsrOp().Entries.W))
}

class Csr(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Reset and shutdown.
    val csr = new CsrInOutIO(p)

    // Decode cycle.
    val req = new CsrIO(p)

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rd  = Flipped(new RegfileWriteDataIO)
    val bru = Flipped(new CsrBruIO(p))

    // Vector core.
    val vcore = Input(new Bundle { val undef = Bool() })

    val counters = Input(new CsrCounters(p))

    // Pipeline Control.
    val halted = Output(Bool())
    val fault  = Output(Bool())
  })

  val csr = new CsrOp()

  val valid = RegInit(false.B)
  val addr = Reg(UInt(5.W))
  val index = Reg(UInt(12.W))
  val op = RegInit(0.U(csr.Entries.W))

  // Pipeline Control.
  val halted = RegInit(false.B)
  val fault = RegInit(false.B)

  // Machine(0)/User(1) Mode.
  val mode = RegInit(false.B)

  // CSRs parallel loaded when(reset).
  val mpc       = Reg(UInt(32.W))
  val msp       = Reg(UInt(32.W))
  val mcause    = Reg(UInt(32.W))
  val mtval     = Reg(UInt(32.W))
  val mcontext0 = Reg(UInt(32.W))
  val mcontext1 = Reg(UInt(32.W))
  val mcontext2 = Reg(UInt(32.W))
  val mcontext3 = Reg(UInt(32.W))
  val mcontext4 = Reg(UInt(32.W))
  val mcontext5 = Reg(UInt(32.W))
  val mcontext6 = Reg(UInt(32.W))
  val mcontext7 = Reg(UInt(32.W))

  // CSRs with initialization.
  val fflags    = RegInit(0.U(5.W))
  val frm       = RegInit(0.U(3.W))
  val mie       = RegInit(0.U(1.W))
  val mtvec     = RegInit(0.U(32.W))
  val mscratch  = RegInit(0.U(32.W))
  val mepc      = RegInit(0.U(32.W))

  val mhartid   = RegInit(p.hartId)

  val mcycle    = RegInit(0.U(64.W))
  val minstret  = RegInit(0.U(64.W))

  // 32-bit MXLEN, I,M,X extensions
  val misa      = RegInit(0x40801100.U(32.W))
  // Kelvin-specific ISA register.
  val kisa      = RegInit(0.U(32.W))

  // 0x426 - Google's Vendor ID
  val mvendorid = RegInit(0x426.U(32.W))

  // Unimplemented -- explicitly return zero.
  val marchid   = RegInit(0.U(1.W))
  val mimpid    = RegInit(0.U(1.W))

  val fcsr = Cat(frm, fflags)

  // Decode the Index.
  val fflagsEn    = index === 0x001.U
  val frmEn       = index === 0x002.U
  val fcsrEn      = index === 0x003.U
  val misaEn      = index === 0x301.U
  val mieEn       = index === 0x304.U
  val mtvecEn     = index === 0x305.U
  val mscratchEn  = index === 0x340.U
  val mepcEn      = index === 0x341.U
  val mcauseEn    = index === 0x342.U
  val mtvalEn     = index === 0x343.U
  val mcontext0En = index === 0x7C0.U
  val mcontext1En = index === 0x7C1.U
  val mcontext2En = index === 0x7C2.U
  val mcontext3En = index === 0x7C3.U
  val mcontext4En = index === 0x7C4.U
  val mcontext5En = index === 0x7C5.U
  val mcontext6En = index === 0x7C6.U
  val mcontext7En = index === 0x7C7.U
  val mpcEn       = index === 0x7E0.U
  val mspEn       = index === 0x7E1.U
  // M-mode performance CSRs.
  val mcycleEn    = index === 0xB00.U
  val minstretEn  = index === 0xB02.U
  val mcyclehEn   = index === 0xB80.U
  val minstrethEn = index === 0xB82.U
  // M-mode information CSRs.
  val mvendoridEn = index === 0xF11.U
  val marchidEn   = index === 0xF12.U
  val mimpidEn    = index === 0xF13.U
  val mhartidEn   = index === 0xF14.U
  // Start of custom CSRs.
  val kisaEn      = index === 0xFC0.U

  // Control registers.
  when (io.req.valid) {
    valid := io.req.valid
    addr := io.req.addr
    index := io.req.index
    op := io.req.op
  } .elsewhen (valid) {
    valid := false.B
    addr := 0.U
    index := 0.U
    op := 0.U
  }

  // Pipeline Control.
  when (io.bru.in.halt || io.vcore.undef) {
    halted := true.B
  }

  when (io.bru.in.fault || io.vcore.undef) {
    fault := true.B
  }

  io.halted := halted
  io.fault  := fault

  assert(!(io.fault && !io.halted))

  // Register state.
  val rs1 = io.rs1.data

  val rdata = MuxOR(fflagsEn,     fflags) |
              MuxOR(frmEn,        frm) |
              MuxOR(fcsrEn,       fcsr) |
              MuxOR(misaEn,       misa) |
              MuxOR(mieEn,        mie) |
              MuxOR(mtvecEn,      mtvec) |
              MuxOR(mscratchEn,   mscratch) |
              MuxOR(mepcEn,       mepc) |
              MuxOR(mcauseEn,     mcause) |
              MuxOR(mtvalEn,      mtval) |
              MuxOR(mcontext0En,  mcontext0) |
              MuxOR(mcontext1En,  mcontext1) |
              MuxOR(mcontext2En,  mcontext2) |
              MuxOR(mcontext3En,  mcontext3) |
              MuxOR(mcontext4En,  mcontext4) |
              MuxOR(mcontext5En,  mcontext5) |
              MuxOR(mcontext6En,  mcontext6) |
              MuxOR(mcontext7En,  mcontext7) |
              MuxOR(mpcEn,        mpc) |
              MuxOR(mspEn,        msp) |
              MuxOR(mcycleEn,     mcycle(31,0)) |
              MuxOR(mcyclehEn,    mcycle(63,32)) |
              MuxOR(minstretEn,   minstret(31,0)) |
              MuxOR(minstrethEn,  minstret(63,32)) |
              MuxOR(mvendoridEn,  mvendorid) |
              MuxOR(marchidEn,    marchid) |
              MuxOR(mimpidEn,     mimpid) |
              MuxOR(mhartidEn,    mhartid) |
              MuxOR(kisaEn,       kisa)

  val wdata = MuxOR(op(csr.CSRRW), rs1) |
              MuxOR(op(csr.CSRRS), rdata | rs1) |
              MuxOR(op(csr.CSRRC), rdata & ~rs1)

  when (valid) {
    when (fflagsEn)     { fflags    := wdata }
    when (frmEn)        { frm       := wdata }
    when (fcsrEn)       { fflags    := wdata(4,0)
                          frm       := wdata(7,5) }
    when (mieEn)        { mie       := wdata }
    when (mtvecEn)      { mtvec     := wdata }
    when (mscratchEn)   { mscratch  := wdata }
    when (mepcEn)       { mepc      := wdata }
    when (mcauseEn)     { mcause    := wdata }
    when (mtvalEn)      { mtval     := wdata }
    when (mpcEn)        { mpc       := wdata }
    when (mspEn)        { msp       := wdata }
    when (mcontext0En)  { mcontext0 := wdata }
    when (mcontext1En)  { mcontext1 := wdata }
    when (mcontext2En)  { mcontext2 := wdata }
    when (mcontext3En)  { mcontext3 := wdata }
    when (mcontext4En)  { mcontext4 := wdata }
    when (mcontext5En)  { mcontext5 := wdata }
    when (mcontext6En)  { mcontext6 := wdata }
    when (mcontext7En)  { mcontext7 := wdata }
  }

  // mcycle implementation
  // If one of the enable signals for
  // the register are true, overwrite the enabled half
  // of the register.
  // Increment the value of mcycle by 1.
  val mcycle_th = Mux(mcyclehEn, wdata, mcycle(63,32))
  val mcycle_tl = Mux(mcycleEn, wdata, mcycle(31,0))
  val mcycle_t = Cat(mcycle_th, mcycle_tl)
  mcycle := Mux(valid, mcycle_t, mcycle) + 1.U


  val minstret_th = Mux(minstrethEn, wdata, minstret(63,32))
  val minstret_tl = Mux(minstretEn, wdata, minstret(31,0))
  val minstret_t = Cat(minstret_th, minstret_tl)
  minstret := Mux(valid, minstret_t, minstret) +
    io.counters.rfwriteCount +
    io.counters.storeCount +
    io.counters.branchCount +
    io.counters.vrfwriteCount +
    io.counters.vstoreCount

  when (io.bru.in.mode.valid) {
    mode := io.bru.in.mode.bits
  }

  val firstFault = !mcause(31)

  when (io.bru.in.mcause.valid && firstFault) {
    mcause := io.bru.in.mcause.bits
  }

  when (io.bru.in.mtval.valid && firstFault) {
    mtval := io.bru.in.mtval.bits
  }

  when (io.bru.in.mepc.valid) {
    mepc := io.bru.in.mepc.bits
  }

  // This pattern of separate when() blocks requires resets after the data.
  when (reset.asBool) {
    mpc       := io.csr.in.value(0)
    msp       := io.csr.in.value(1)
    mcause    := io.csr.in.value(2)
    mtval     := io.csr.in.value(3)
    mcontext0 := io.csr.in.value(4)
    mcontext1 := io.csr.in.value(5)
    mcontext2 := io.csr.in.value(6)
    mcontext3 := io.csr.in.value(7)
    mcontext4 := io.csr.in.value(8)
    mcontext5 := io.csr.in.value(9)
    mcontext6 := io.csr.in.value(10)
    mcontext7 := io.csr.in.value(11)
  }

  // Forwarding.
  io.bru.out.mode  := mode
  io.bru.out.mepc  := Mux(mepcEn, wdata, mepc)
  io.bru.out.mtvec := Mux(mtvecEn, wdata, mtvec)

  io.csr.out.value(0) := mpc
  io.csr.out.value(1) := msp
  io.csr.out.value(2) := mcause
  io.csr.out.value(3) := mtval
  io.csr.out.value(4) := mcontext0
  io.csr.out.value(5) := mcontext1
  io.csr.out.value(6) := mcontext2
  io.csr.out.value(7) := mcontext3

  // Write port.
  io.rd.valid := valid
  io.rd.addr  := addr
  io.rd.data  := rdata

  // Assertions.
  assert(!(valid && !io.rs1.valid))
}
