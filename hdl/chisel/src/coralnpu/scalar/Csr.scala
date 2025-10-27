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
import coralnpu.float.{CsrFloatIO}

class CsrRvvIO(p: Parameters) extends Bundle {
  // To Csr from RvvCore
  val vstart = Input(UInt(log2Ceil(p.rvvVlen).W))
  val vl = Input(UInt(log2Ceil(p.rvvVlen).W))
  val vtype = Input(UInt(32.W))
  val vxrm = Input(UInt(2.W))
  val vxsat = Input(Bool())
  // From Csr to RvvCore
  val vstart_write = Output(Valid(UInt(log2Ceil(p.rvvVlen).W)))
  val vxrm_write = Output(Valid(UInt(2.W)))
  val vxsat_write = Output(Valid(Bool()))
}

object Csr {
  def apply(p: Parameters): Csr = {
    return Module(new Csr(p))
  }
}

object CsrAddress extends ChiselEnum {
  val FFLAGS    = Value(0x001.U(12.W))
  val FRM       = Value(0x002.U(12.W))
  val FCSR      = Value(0x003.U(12.W))
  val VSTART    = Value(0x008.U(12.W))
  val VXSAT     = Value(0x009.U(12.W))
  val VXRM      = Value(0x00A.U(12.W))
  val MSTATUS   = Value(0x300.U(12.W))
  val MISA      = Value(0x301.U(12.W))
  val MIE       = Value(0x304.U(12.W))
  val MTVEC     = Value(0x305.U(12.W))
  val MSCRATCH  = Value(0x340.U(12.W))
  val MEPC      = Value(0x341.U(12.W))
  val MCAUSE    = Value(0x342.U(12.W))
  val MTVAL     = Value(0x343.U(12.W))
  val TSELECT   = Value(0x7A0.U(12.W))
  val TDATA1    = Value(0x7A1.U(12.W))
  val TDATA2    = Value(0x7A2.U(12.W))
  val TINFO     = Value(0x7A4.U(12.W))
  val DCSR      = Value(0x7B0.U(12.W))
  val DPC       = Value(0x7B1.U(12.W))
  val DSCRATCH0 = Value(0x7B2.U(12.W))
  val DSCRATCH1 = Value(0x7B3.U(12.W))
  val MCONTEXT0 = Value(0x7C0.U(12.W))
  val MCONTEXT1 = Value(0x7C1.U(12.W))
  val MCONTEXT2 = Value(0x7C2.U(12.W))
  val MCONTEXT3 = Value(0x7C3.U(12.W))
  val MCONTEXT4 = Value(0x7C4.U(12.W))
  val MCONTEXT5 = Value(0x7C5.U(12.W))
  val MCONTEXT6 = Value(0x7C6.U(12.W))
  val MCONTEXT7 = Value(0x7C7.U(12.W))
  val MPC       = Value(0x7E0.U(12.W))
  val MSP       = Value(0x7E1.U(12.W))
  val MCYCLE    = Value(0xB00.U(12.W))
  val MINSTRET  = Value(0xB02.U(12.W))
  val MCYCLEH   = Value(0xB80.U(12.W))
  val MINSTRETH = Value(0xB82.U(12.W))
  val VL        = Value(0xC20.U(12.W))
  val VTYPE     = Value(0xC21.U(12.W))
  val VLENB     = Value(0xC22.U(12.W))
  val MVENDORID = Value(0xF11.U(12.W))
  val MARCHID   = Value(0xF12.U(12.W))
  val MIMPID    = Value(0xF13.U(12.W))
  val MHARTID   = Value(0xF14.U(12.W))
  val KISA      = Value(0xFC0.U(12.W))
  val KSCM0     = Value(0xFC4.U(12.W))
  val KSCM1     = Value(0xFC8.U(12.W))
  val KSCM2     = Value(0xFCC.U(12.W))
  val KSCM3     = Value(0xFD0.U(12.W))
  val KSCM4     = Value(0xFD4.U(12.W))
}

object CsrMode extends ChiselEnum {
  val Machine = Value(0.U(2.W))
  val User = Value(1.U(2.W))
  val Debug = Value(2.U(2.W))
}

/* For details, see The RISC-V Debug Specification v1.0, chapter 4.9.1 */
class Dcsr extends Bundle {
  val debugver = UInt(4.W)
  val extcause = UInt(3.W)
  val cetrig = Bool()
  val pelp = Bool()
  val ebreakvs = Bool()
  val ebreakvu = Bool()
  val ebreakm = Bool()
  val ebreaks = Bool()
  val ebreaku = Bool()
  val stepie = Bool()
  val stopcount = Bool()
  val stoptime = Bool()
  val cause = UInt(3.W)
  val v = Bool()
  val mprven = Bool()
  val nmip = Bool()
  val step = Bool()
  val prv = UInt(2.W)

  def asWord: UInt = {
    val ret = Cat(debugver, 0.U(1.W), extcause, 0.U(4.W), cetrig, pelp, ebreakvs, ebreakvu, ebreakm, 0.U(1.W),
                  ebreaks, ebreaku, stepie, stopcount, stoptime, cause, v, mprven, nmip, step, prv)
    assert(ret.getWidth == 32)
    ret
  }
}

/* For details, see The RISC-V Debug Specification v1.0, chapter 5.7.2 */
class Tdata1 extends Bundle {
  val type_ = UInt(4.W)
  val dmode = Bool()
  val data = UInt(27.W)

  def asWord: UInt = {
    val ret = Cat(type_, dmode, data)
    assert(ret.getWidth == 32)
    ret
  }

  def isTrigger6: Bool = {
    type_ === 6.U(4.W)
  }
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
    val float = Option.when(p.enableFloat) { Flipped(new CsrFloatIO(p)) }
    val rvv = Option.when(p.enableRvv) { new CsrRvvIO(p) }

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
    val dm = Option.when(p.useDebugModule)(new Bundle {
      val debug_req = Input(Bool())
      val resume_req = Input(Bool())
      val debug_mode = Output(Bool())
      val single_step = Output(Bool())
      val dcsr_step = Output(Bool())
      val next_pc = Input(UInt(32.W))
    })
    val trace = Option.when(p.useRetirementBuffer)(Output(new CsrTraceIO(p)))
  })

  def LegalizeTdata1(wdata: UInt): Tdata1 = {
    assert(wdata.getWidth == 32)
    val newWdata = Wire(new Tdata1)
    val newType = wdata(31,28)
    val newTypeTrigger6 = (newType === 6.U(4.W))
    newWdata.type_ := Mux(newTypeTrigger6, newType, 15.U(4.W))
    newWdata.data := MuxOR(newTypeTrigger6, wdata(26,0))
    newWdata.dmode := wdata(27)
    newWdata
  }

  // Control registers.
  val req = Pipe(io.req)

  // Pipeline Control.
  val halted = RegInit(false.B)
  val fault  = RegInit(false.B)
  val wfi    = RegInit(false.B)

  // Machine(0)/User(1)/Debug(2) Mode.
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

  // Debug mode CSRs
  val dcsr      = Option.when(p.useDebugModule)(RegInit(0.U.asTypeOf(new Dcsr)))
  val dpc       = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val dscratch0 = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val dscratch1 = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  // Trigger CSRs
  val tselect   = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val tdata1    = Option.when(p.useDebugModule)(RegInit(0.U.asTypeOf(new Tdata1)))
  val tdata2    = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  /* For details, see The RISC-V Debug Specification v1.0, chapter 5.7.5 */
  val tinfo     = Option.when(p.useDebugModule)(RegInit(0x01000040.U(32.W)))

  // CSRs with initialization.
  val fflags    = RegInit(0.U(5.W))
  val frm       = RegInit(0.U(3.W))
  val mie       = RegInit(0.U(1.W))
  val mtvec     = RegInit(0.U(32.W))
  val mscratch  = RegInit(0.U(32.W))
  val mepc      = RegInit(0.U(32.W))
  val mpp       = RegInit(0.U(2.W))

  val mhartid   = RegInit(p.hartId.U(32.W))

  val mcycle    = RegInit(0.U(64.W))
  val minstret  = RegInit(0.U(64.W))

  // 32-bit MXLEN, I,M,X extensions
  val misa      = RegInit(((
      0x40001100 |
      (if (p.enableVector) { 1 << 23 /* 'X' */ } else { 0 }) |
      (if (p.enableRvv) { 1 << 21 /* 'V' */ } else { 0 }) |
      (if (p.enableFloat) { 1 << 5 /* 'F' */ } else { 0 })
  ).U)(32.W))
  // CoralNPU-specific ISA register.
  val kisa      = RegInit(0.U(32.W))
  // SCM Revision (spread over 5 indices)
  val kscm      = RegInit(((new ScmInfo).revision).U(160.W))

  // 0x426 - Google's Vendor ID
  val mvendorid = RegInit(0x426.U(32.W))

  // Unimplemented -- explicitly return zero.
  val marchid   = RegInit(0.U(1.W))
  val mimpid    = RegInit(0.U(1.W))

  val fcsr = Cat(frm, fflags)

  // TODO(b/452672880): Implement the dirty feature for fs and vs.
  val fs = if (p.enableFloat) 1.U(2.W) else 0.U(2.W)
  val vs = if (p.enableRvv) 1.U(2.W) else 0.U(2.W)

  // Decode the Index.
  val (csr_address, csr_address_valid) = CsrAddress.safe(req.bits.index)
  assert(!(req.valid && !csr_address_valid))
  val fflagsEn    = csr_address === CsrAddress.FFLAGS
  val frmEn       = csr_address === CsrAddress.FRM
  val fcsrEn      = csr_address === CsrAddress.FCSR
  val vstartEn    = Option.when(p.enableRvv) { csr_address === CsrAddress.VSTART }
  val vlEn        = Option.when(p.enableRvv) { csr_address === CsrAddress.VL }
  val vtypeEn     = Option.when(p.enableRvv) { csr_address === CsrAddress.VTYPE }
  val vxrmEn      = Option.when(p.enableRvv) { csr_address === CsrAddress.VXRM }
  val vxsatEn     = Option.when(p.enableRvv) { csr_address === CsrAddress.VXSAT }
  val mstatusEn   = csr_address === CsrAddress.MSTATUS
  val misaEn      = csr_address === CsrAddress.MISA
  val mieEn       = csr_address === CsrAddress.MIE
  val mtvecEn     = csr_address === CsrAddress.MTVEC
  val mscratchEn  = csr_address === CsrAddress.MSCRATCH
  val mepcEn      = csr_address === CsrAddress.MEPC
  val mcauseEn    = csr_address === CsrAddress.MCAUSE
  val mtvalEn     = csr_address === CsrAddress.MTVAL
  // Debug CSRs.
  val tselectEn   = Option.when(p.useDebugModule)(csr_address === CsrAddress.TSELECT)
  val tdata1En    = Option.when(p.useDebugModule)(csr_address === CsrAddress.TDATA1)
  val tdata2En    = Option.when(p.useDebugModule)(csr_address === CsrAddress.TDATA2)
  val tinfoEn     = Option.when(p.useDebugModule)(csr_address === CsrAddress.TINFO)
  val dcsrEn      = Option.when(p.useDebugModule)(csr_address === CsrAddress.DCSR)
  val dpcEn       = Option.when(p.useDebugModule)(csr_address === CsrAddress.DPC)
  val dscratch0En = Option.when(p.useDebugModule)(csr_address === CsrAddress.DSCRATCH0)
  val dscratch1En = Option.when(p.useDebugModule)(csr_address === CsrAddress.DSCRATCH1)
  val mcontext0En = csr_address === CsrAddress.MCONTEXT0
  val mcontext1En = csr_address === CsrAddress.MCONTEXT1
  val mcontext2En = csr_address === CsrAddress.MCONTEXT2
  val mcontext3En = csr_address === CsrAddress.MCONTEXT3
  val mcontext4En = csr_address === CsrAddress.MCONTEXT4
  val mcontext5En = csr_address === CsrAddress.MCONTEXT5
  val mcontext6En = csr_address === CsrAddress.MCONTEXT6
  val mcontext7En = csr_address === CsrAddress.MCONTEXT7
  val mpcEn       = csr_address === CsrAddress.MPC
  val mspEn       = csr_address === CsrAddress.MSP
  // M-mode performance CSRs.
  val mcycleEn    = csr_address === CsrAddress.MCYCLE
  val minstretEn  = csr_address === CsrAddress.MINSTRET
  val mcyclehEn   = csr_address === CsrAddress.MCYCLEH
  val minstrethEn = csr_address === CsrAddress.MINSTRETH
  // Vector CSRs.
  val vlenbEn     = Option.when(p.enableRvv) { csr_address === CsrAddress.VLENB }
  // M-mode information CSRs.
  val mvendoridEn = csr_address === CsrAddress.MVENDORID
  val marchidEn   = csr_address === CsrAddress.MARCHID
  val mimpidEn    = csr_address === CsrAddress.MIMPID
  val mhartidEn   = csr_address === CsrAddress.MHARTID
  // Start of custom CSRs.
  val kisaEn      = csr_address === CsrAddress.KISA
  val kscm0En     = csr_address === CsrAddress.KSCM0
  val kscm1En     = csr_address === CsrAddress.KSCM1
  val kscm2En     = csr_address === CsrAddress.KSCM2
  val kscm3En     = csr_address === CsrAddress.KSCM3
  val kscm4En     = csr_address === CsrAddress.KSCM4

  // Pipeline Control.
  val vcoreUndef = if (p.enableVector) { io.vcore.get.undef } else { false.B }
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

  val rdata = MuxCase(0.U(32.W), Seq(
      fflagsEn    -> Cat(0.U(27.W), fflags),
      frmEn       -> Cat(0.U(29.W), frm),
      fcsrEn      -> Cat(0.U(24.W), fcsr),
      mstatusEn   -> Cat(0.U(17.W), fs, mpp, vs, 0.U(9.W)),
      misaEn      -> misa,
      mieEn       -> Cat(0.U(31.W), mie),
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
      marchidEn   -> Cat(0.U(31.W), marchid),
      mimpidEn    -> Cat(0.U(31.W), mimpid),
      mhartidEn   -> mhartid,
      kisaEn      -> kisa,
      kscm0En     -> kscm(31,0),
      kscm1En     -> kscm(63,32),
      kscm2En     -> kscm(95,64),
      kscm3En     -> kscm(127,96),
      kscm4En     -> kscm(159,128),
    ) ++
      Option.when(p.enableRvv) {
        Seq(
          vstartEn.get -> io.rvv.get.vstart,
          vlEn.get     -> io.rvv.get.vl,
          vtypeEn.get  -> io.rvv.get.vtype,
          vxrmEn.get   -> io.rvv.get.vxrm,
          vxsatEn.get  -> io.rvv.get.vxsat,
          vlenbEn.get -> 16.U(32.W),  // Vector length in Bytes
        )
      }.getOrElse(Seq())
      ++
      Option.when(p.useDebugModule) {
        Seq(
          tselectEn.get   -> tselect.get,
          tdata1En.get    -> tdata1.get.asWord,
          tdata2En.get    -> tdata2.get,
          tinfoEn.get     -> tinfo.get,
          dcsrEn.get      -> dcsr.get.asWord,
          dpcEn.get       -> dpc.get,
          dscratch0En.get -> dscratch0.get,
          dscratch1En.get -> dscratch1.get,
        )
      }.getOrElse(Seq())
  )

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
    when (mstatusEn)    { mpp       := wdata(12,11) }
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
    if (p.useDebugModule) {
      when (dscratch0En.get)  { dscratch0.get := wdata }
      when (dscratch1En.get)  { dscratch1.get := wdata }
      when (tdata1En.get)     { tdata1.get := LegalizeTdata1(wdata) }
      when (tdata2En.get)     { tdata2.get := wdata }
    }
  }

  if (p.enableRvv) {
    io.rvv.get.vstart_write.valid := req.valid && vstartEn.get
    io.rvv.get.vstart_write.bits  := wdata(log2Ceil(p.rvvVlen)-1, 0)
    io.rvv.get.vxrm_write.valid   := req.valid && vxrmEn.get
    io.rvv.get.vxrm_write.bits    := wdata(1,0)
    io.rvv.get.vxsat_write.valid  := req.valid && vxsatEn.get
    io.rvv.get.vxsat_write.bits   := wdata(0)
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
  val minstretThisCycle = io.counters.rfwriteCount +
    io.counters.storeCount +
    io.counters.branchCount +
    (if (p.enableVector) {
      io.counters.vrfwriteCount.get +
      io.counters.vstoreCount.get
    } else { 0.U })
  minstret := MuxCase(minstret, Seq(
    req.valid -> minstret_t,
    (minstretThisCycle =/= 0.U) -> (minstret + minstretThisCycle),
  ))

  if (p.useDebugModule) {
    val trigger_enabled = tdata1.get.isTrigger6
    val trigger_match = (trigger_enabled && io.dm.get.next_pc === tdata2.get)

    val entering_debug_mode = (mode =/= CsrMode.Debug) && (io.dm.get.debug_req || trigger_match)
    val exiting_debug_mode = (mode === CsrMode.Debug) && (io.dm.get.resume_req)
    mode := MuxCase(mode, Seq(
      entering_debug_mode -> CsrMode.Debug,
      exiting_debug_mode -> CsrMode.Machine,
      io.bru.in.mode.valid -> io.bru.in.mode.bits,
    ))
    io.dm.get.debug_mode := (mode === CsrMode.Debug)
    dcsr.get := MuxCase(dcsr.get, Seq(
      entering_debug_mode -> {
        val newDcsr = Wire(new Dcsr)
        newDcsr := dcsr.get
        newDcsr.extcause := false.B
        val causeWidth = newDcsr.cause.getWidth.W
        newDcsr.cause := MuxCase(7.U(causeWidth), Seq(
          (io.dm.get.debug_req && !io.dm.get.dcsr_step) -> 3.U(causeWidth),
          trigger_match -> 2.U(causeWidth),
          io.dm.get.dcsr_step -> 4.U(causeWidth),
        ))
        newDcsr.prv := Mux(mode === CsrMode.Machine, 3.U(2.W), 0.U(2.W))
        newDcsr
      },
      (req.valid && dcsrEn.get) -> wdata.asTypeOf(new Dcsr),
    ))
    dpc.get := MuxCase(io.dm.get.next_pc, Seq(
      entering_debug_mode -> io.dm.get.next_pc,
      (req.valid && dpcEn.get) -> wdata,
    ))

    io.dm.get.dcsr_step := dcsr.get.step
    io.dm.get.single_step := trigger_enabled
  } else {
    when (io.bru.in.mode.valid) {
      mode := io.bru.in.mode.bits
    }
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

  if (p.enableFloat) {
    when (io.float.get.in.fflags.valid) {
      fflags := io.float.get.in.fflags.bits | fflags
    }
  }

  // Forwarding.
  io.bru.out.mode  := mode
  io.bru.out.mepc  := Mux(mepcEn && req.valid, wdata, mepc)
  io.bru.out.mtvec := Mux(mtvecEn && req.valid, wdata, mtvec)

  if (p.enableFloat) {
    io.float.get.out.frm := Mux(frmEn && req.valid, wdata(2,0), frm)
  }

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

  if (p.useRetirementBuffer) {
    io.trace.get.valid := req.valid
    io.trace.get.addr := req.bits.index
    io.trace.get.data := wdata
  }

  // Assertions.
  assert(!(req.valid && !io.rs1.valid))
}
