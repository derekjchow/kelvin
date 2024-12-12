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

object CsrOp extends ChiselEnum {
  val CSRRW = Value
  val CSRRS = Value
  val CSRRC = Value
}

object CsrMode extends ChiselEnum {
  val Machine = Value(0.U(1.W))
  val User = Value(1.U(1.W))
}

class CsrCounters(p: Parameters) extends Bundle {
  val rfwriteCount = UInt(3.W)
  val storeCount = UInt(2.W)
  val branchCount = UInt(1.W)
  val vrfwriteCount = if (p.enableVector) {
    Some(UInt(3.W))
  } else { None }
  val vstoreCount = if (p.enableVector) {
    Some(UInt(2.W))
  } else { None }
}

class CsrBruIO(p: Parameters) extends Bundle {
  val in = new Bundle {
    val mode   = Valid(CsrMode())
    val mcause = Valid(UInt(32.W))
    val mepc   = Valid(UInt(32.W))
    val mtval  = Valid(UInt(32.W))
    val halt   = Output(Bool())
    val fault  = Output(Bool())
    val wfi    = Output(Bool())
  }
  val out = new Bundle {
    val mode  = Input(CsrMode())
    val mepc  = Input(UInt(32.W))
    val mtvec = Input(UInt(32.W))
  }
  def defaults() = {
    out.mode := CsrMode.Machine
    out.mepc := 0.U
    out.mtvec := 0.U
  }
}

class CsrRvvIO extends Bundle {
  // TODO(derekjchow): Finish me
}

class CsrCmd extends Bundle {
  val addr = UInt(5.W)
  val index = UInt(12.W)
  val op = CsrOp()
}

class Csr(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Reset and shutdown.
    val csr = new CsrInOutIO(p)

    // Decode cycle.
    val req = Flipped(Valid(new CsrCmd))

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rd  = Valid(Flipped(new RegfileWriteDataIO))
    val bru = Flipped(new CsrBruIO(p))

    // Vector core.
    val vcore = (if (p.enableVector) {
      Some(Input(new Bundle { val undef = Bool() }))
    } else { None })

    val counters = Input(new CsrCounters(p))

    // Pipeline Control.
    val halted = Output(Bool())
    val fault  = Output(Bool())
    val wfi    = Output(Bool())
    val irq    = Input(Bool())
  })

  // Control registers.
  val req = Pipe(io.req)

  // Pipeline Control.
  val halted = RegInit(false.B)
  val fault  = RegInit(false.B)
  val wfi    = RegInit(false.B)

  // Machine(0)/User(1) Mode.
  val mode = RegInit(CsrMode.Machine)

  // CSRs parallel loaded when(reset).
  val mpc       = RegInit(0.U(32.W))
  val msp       = RegInit(0.U(32.W))
  val mcause    = RegInit(0.U(32.W))
  val mtval     = RegInit(0.U(32.W))
  val mcontext0 = RegInit(0.U(32.W))
  val mcontext1 = RegInit(0.U(32.W))
  val mcontext2 = RegInit(0.U(32.W))
  val mcontext3 = RegInit(0.U(32.W))
  val mcontext4 = RegInit(0.U(32.W))
  val mcontext5 = RegInit(0.U(32.W))
  val mcontext6 = RegInit(0.U(32.W))
  val mcontext7 = RegInit(0.U(32.W))

  // CSRs with initialization.
  val fflags    = RegInit(0.U(5.W))
  val frm       = RegInit(0.U(3.W))
  val mie       = RegInit(0.U(1.W))
  val mtvec     = RegInit(0.U(32.W))
  val mscratch  = RegInit(0.U(32.W))
  val mepc      = RegInit(0.U(32.W))

  // TODO(derekjchow): Check initialization
  val vstart = Option.when(p.enableRvv)(RegInit(0.U(log2Ceil(p.rvvVlen).W)))
  val vxsat  = Option.when(p.enableRvv)(RegInit(0.U(1.W)))
  val vxrm   = Option.when(p.enableRvv)(RegInit(0.U(2.W)))
  // val vcsr   = Option.when(p.enableRvv)(RegInit(0.U(32.W)))
  // TODO(derekjchow): Read only CSRs


  val mhartid   = RegInit(p.hartId.U(32.W))

  val mcycle    = RegInit(0.U(64.W))
  val minstret  = RegInit(0.U(64.W))

  // 32-bit MXLEN, I,M,X extensions
  val misa      = RegInit(((0x40001100 | (if (p.enableVector) { 1 << 23 /* 'X' */ } else { 0 })).U)(32.W))
  // Kelvin-specific ISA register.
  val kisa      = RegInit(0.U(32.W))
  // SCM Revision (spread over 5 indices)
  val kscm      = RegInit(((new ScmInfo).revision).U(160.W))

  // 0x426 - Google's Vendor ID
  val mvendorid = RegInit(0x426.U(32.W))

  // Unimplemented -- explicitly return zero.
  val marchid   = RegInit(0.U(1.W))
  val mimpid    = RegInit(0.U(1.W))

  val fcsr = Cat(frm, fflags)

  // Decode the Index.
  val fflagsEn    = req.bits.index === 0x001.U
  val frmEn       = req.bits.index === 0x002.U
  val fcsrEn      = req.bits.index === 0x003.U

  val vstartEn = if (p.enableRvv) { req.bits.index === 0x08.U } else { false.B }
  val vxsatEn  = if (p.enableRvv) { req.bits.index === 0x09.U } else { false.B }
  val vxrmEn   = if (p.enableRvv) { req.bits.index === 0x0A.U } else { false.B }
  val vcsrEn   = if (p.enableRvv) { req.bits.index === 0x0F.U } else { false.B }

  val misaEn      = req.bits.index === 0x301.U
  val mieEn       = req.bits.index === 0x304.U
  val mtvecEn     = req.bits.index === 0x305.U
  val mscratchEn  = req.bits.index === 0x340.U
  val mepcEn      = req.bits.index === 0x341.U
  val mcauseEn    = req.bits.index === 0x342.U
  val mtvalEn     = req.bits.index === 0x343.U
  val mcontext0En = req.bits.index === 0x7C0.U
  val mcontext1En = req.bits.index === 0x7C1.U
  val mcontext2En = req.bits.index === 0x7C2.U
  val mcontext3En = req.bits.index === 0x7C3.U
  val mcontext4En = req.bits.index === 0x7C4.U
  val mcontext5En = req.bits.index === 0x7C5.U
  val mcontext6En = req.bits.index === 0x7C6.U
  val mcontext7En = req.bits.index === 0x7C7.U
  val mpcEn       = req.bits.index === 0x7E0.U
  val mspEn       = req.bits.index === 0x7E1.U
  // M-mode performance CSRs.
  val mcycleEn    = req.bits.index === 0xB00.U
  val minstretEn  = req.bits.index === 0xB02.U
  val mcyclehEn   = req.bits.index === 0xB80.U
  val minstrethEn = req.bits.index === 0xB82.U
  // M-mode information CSRs.
  val mvendoridEn = req.bits.index === 0xF11.U
  val marchidEn   = req.bits.index === 0xF12.U
  val mimpidEn    = req.bits.index === 0xF13.U
  val mhartidEn   = req.bits.index === 0xF14.U
  // Start of custom CSRs.
  val kisaEn      = req.bits.index === 0xFC0.U
  val kscm0En     = req.bits.index === 0xFC4.U
  val kscm1En     = req.bits.index === 0xFC8.U
  val kscm2En     = req.bits.index === 0xFCC.U
  val kscm3En     = req.bits.index === 0xFD0.U
  val kscm4En     = req.bits.index === 0xFD4.U

  // Pipeline Control.
  // val vcoreUndef = if (p.enableVector) { io.vcore.get.undef } else { false.B }
  val vcoreUndef = io.vcore.map(_.undef).getOrElse(false.B)
  when (io.bru.in.halt || vcoreUndef) {
    halted := true.B
  }

  when (io.bru.in.fault || vcoreUndef) {
    fault := true.B
  }

  wfi := Mux(wfi, !io.irq, io.bru.in.wfi)

  io.halted := halted
  io.fault  := fault
  io.wfi    := wfi

  assert(!(io.fault && !io.halted && !io.wfi))

  // Register state.
  val rs1 = io.rs1.data

  val rdata = MuxCase(0.U, Seq(
      fflagsEn    -> fflags,
      frmEn       -> frm,
      fcsrEn      -> fcsr,
      misaEn      -> misa,
      mieEn       -> mie,
      mtvecEn     -> mtvec,
      mscratchEn  -> mscratch,
      mepcEn      -> mepc,
      mcauseEn    -> mcause,
      mtvalEn     -> mtval,
      mcontext0En -> mcontext0,
      mcontext1En -> mcontext1,
      mcontext2En -> mcontext2,
      mcontext3En -> mcontext3,
      mcontext4En -> mcontext4,
      mcontext5En -> mcontext5,
      mcontext6En -> mcontext6,
      mcontext7En -> mcontext7,
      mpcEn       -> mpc,
      mspEn       -> msp,
      mcycleEn    -> mcycle(31,0),
      mcyclehEn   -> mcycle(63,32),
      minstretEn  -> minstret(31,0),
      minstrethEn -> minstret(63,32),
      mvendoridEn -> mvendorid,
      marchidEn   -> marchid,
      mimpidEn    -> mimpid,
      mhartidEn   -> mhartid,
      kisaEn      -> kisa,
      kscm0En     -> kscm(31,0),
      kscm1En     -> kscm(63,32),
      kscm2En     -> kscm(95,64),
      kscm3En     -> kscm(127,96),
      kscm4En     -> kscm(159,128),
  ) ++ (if (p.enableRvv) { Seq(
      vstartEn -> vstart.get,
      vxsatEn  -> vxsat.get,
      vxrmEn   -> vxrm.get,
      vcsrEn   -> Cat(vxrm.get, vxsat.get),
  )} else { Seq() }))

  val wdata = MuxLookup(req.bits.op, 0.U)(Seq(
      CsrOp.CSRRW -> rs1,
      CsrOp.CSRRS -> (rdata | rs1),
      CsrOp.CSRRC -> (rdata & ~rs1)
  ))

  when (req.valid) {
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
    if (p.enableRvv) {
      when (vstartEn) { vstart.get := wdata }
      when (vxsatEn)  { vxsat.get  := wdata }
      when (vxrmEn)   { vxrm.get   := wdata }
    }
  }

  // mcycle implementation
  // If one of the enable signals for
  // the register are true, overwrite the enabled half
  // of the register.
  // Increment the value of mcycle by 1.
  val mcycle_th = Mux(mcyclehEn, wdata, mcycle(63,32))
  val mcycle_tl = Mux(mcycleEn, wdata, mcycle(31,0))
  val mcycle_t = Cat(mcycle_th, mcycle_tl)
  mcycle := Mux(req.valid, mcycle_t, mcycle) + 1.U


  val minstret_th = Mux(minstrethEn, wdata, minstret(63,32))
  val minstret_tl = Mux(minstretEn, wdata, minstret(31,0))
  val minstret_t = Cat(minstret_th, minstret_tl)
  minstret := Mux(req.valid, minstret_t, minstret) +
    io.counters.rfwriteCount +
    io.counters.storeCount +
    io.counters.branchCount +
    (if (p.enableVector) {
      io.counters.vrfwriteCount.get +
      io.counters.vstoreCount.get
    } else { 0.U })

  when (io.bru.in.mode.valid) {
    mode := io.bru.in.mode.bits
  }

  // High bit of mcause is set for an external interrupt.
  val interrupt = mcause(31)

  when (io.bru.in.mcause.valid) {
    mcause := io.bru.in.mcause.bits
  }

  when (io.bru.in.mtval.valid) {
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
  io.bru.out.mepc  := Mux(mepcEn && req.valid, wdata, mepc)
  io.bru.out.mtvec := Mux(mtvecEn && req.valid, wdata, mtvec)

  io.csr.out.value(0) := io.csr.in.value(12)
  io.csr.out.value(1) := mepc
  io.csr.out.value(2) := mtval
  io.csr.out.value(3) := mcause
  io.csr.out.value(4) := mcycle(31,0)
  io.csr.out.value(5) := mcycle(63,32)
  io.csr.out.value(6) := minstret(31,0)
  io.csr.out.value(7) := minstret(63,32)

  // Write port.
  io.rd.valid := req.valid
  io.rd.bits.addr  := req.bits.addr
  io.rd.bits.data  := rdata

  // Assertions.
  assert(!(req.valid && !io.rs1.valid))
}
