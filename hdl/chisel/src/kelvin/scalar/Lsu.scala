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

object Lsu {
  def apply(p: Parameters): Lsu = {
    return Module(new Lsu(p))
  }
}

object LsuOp extends ChiselEnum {
  val LB  = Value
  val LH  = Value
  val LW  = Value
  val LBU = Value
  val LHU = Value
  val SB  = Value
  val SH  = Value
  val SW  = Value
  val FENCEI = Value
  val FLUSHAT = Value
  val FLUSHALL = Value
  val VLDST = Value
  val FLOAT = Value
}

class LsuCmd extends Bundle {
  val store = Bool()
  val addr = UInt(5.W)
  val op = LsuOp()
  val pc = UInt(32.W)
}

class LsuCtrl(p: Parameters) extends Bundle {
  val pc = UInt(32.W)
  val addr = UInt(32.W)
  val adrx = UInt(32.W)
  val data = UInt(32.W)
  val index = UInt(5.W)
  val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val fullsize = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val write = Bool()
  val sext = Bool()
  val iload = Bool()
  val fencei = Bool()
  val flushat = Bool()
  val flushall = Bool()
  val sldst = Bool()  // scalar load/store cached
  val vldst = Bool()  // vector load/store
  val fldst = Bool() // float load/store
  val regionType = MemoryRegionType()
  val mask = UInt(p.lsuDataBytes.W)
  val last = Bool()
}

class LsuReadData(p: Parameters) extends Bundle {
  val addr = UInt(32.W)
  val index = UInt(5.W)
  val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val fullsize = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val sext = Bool()
  val iload = Bool()
  val sldst = Bool()
  val fldst = Bool()
  val regionType = MemoryRegionType()
  val mask = UInt(p.lsuDataBytes.W)
  val last = Bool()
}

class Lsu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Vec(p.instructionLanes, Flipped(Decoupled(new LsuCmd)))
    val busPort = Flipped(new RegfileBusPortIO(p))
    val busPort_flt = Option.when(p.enableFloat)(Flipped(new RegfileBusPortIO(p)))

    // Execute cycle(s).
    val rd = Valid(Flipped(new RegfileWriteDataIO))
    val rd_flt = Valid(Flipped(new RegfileWriteDataIO))

    // Cached interface.
    val ibus = new IBusIO(p)
    val dbus = new DBusIO(p)
    val flush = new DFlushFenceiIO(p)
    val fault = Valid(new FaultInfo(p))

    // DBus that will eventually reach an external bus.
    // Intended for sending a transaction to an external
    // peripheral, likely on TileLink or AXI.
    val ebus = new EBusIO(p)

    // Vector switch.
    val vldst = Output(Bool())

    val storeCount = Output(UInt(2.W))
    val active = Output(Bool())
  })

  // AXI Queues.
  val n = 9
  val ctrl = FifoX(new LsuCtrl(p), p.instructionLanes * 2, n)
  val data = Slice(new LsuReadData(p), true, true)

  // Match and mask.
  io.active :=
    (ctrl.io.count =/= 0.U || data.io.count =/= 0.U)
  val ctrlready = (1 to p.instructionLanes).reverse.map(x => ctrl.io.count <= (n - (2 * x)).U)

  for (i <- 0 until p.instructionLanes) {
    io.req(i).ready := ctrlready(i) && data.io.in.ready
  }

  // Address phase must use simple logic to resolve mask for unaligned address.
  val linebit = log2Ceil(p.lsuDataBits / 8)
  val lineoffset = (p.lsuDataBits / 8)

  // ---------------------------------------------------------------------------
  // Control Port Inputs.
  ctrl.io.in.valid := io.req.map(_.valid).reduce(_||_)

  for (i <- 0 until p.instructionLanes) {
    val itcm = p.m.filter(_.memType == MemoryRegionType.IMEM)
                  .map(_.contains(io.busPort.addr(i))).reduceOption(_ || _).getOrElse(false.B)
    val dtcm = p.m.filter(_.memType == MemoryRegionType.DMEM)
                  .map(_.contains(io.busPort.addr(i))).reduceOption(_ || _).getOrElse(true.B)
    val peri = p.m.filter(_.memType == MemoryRegionType.Peripheral)
                  .map(_.contains(io.busPort.addr(i))).reduceOption(_ || _).getOrElse(false.B)
    val external = !(itcm || dtcm || peri)
    assert(PopCount(Cat(itcm | dtcm | peri)) <= 1.U)

    val opstore = io.req(i).bits.op.isOneOf(LsuOp.SW, LsuOp.SH, LsuOp.SB)
    val opiload = io.req(i).bits.op.isOneOf(LsuOp.LW, LsuOp.LH, LsuOp.LB, LsuOp.LHU, LsuOp.LBU)
    val opload  = opiload || (io.req(i).bits.op === LsuOp.FLOAT && !io.req(i).bits.store)
    val opfencei   = (io.req(i).bits.op === LsuOp.FENCEI)
    val opflushat  = (io.req(i).bits.op === LsuOp.FLUSHAT)
    val opflushall = (io.req(i).bits.op === LsuOp.FLUSHALL)
    val opsldst = (opstore || opload) && (io.req(i).bits.op =/= LsuOp.FLOAT)
    val opvldst = (io.req(i).bits.op === LsuOp.VLDST)
    val opsext = io.req(i).bits.op.isOneOf(LsuOp.LB, LsuOp.LH)
    val opsize = Cat(io.req(i).bits.op.isOneOf(LsuOp.LW, LsuOp.SW, LsuOp.FLOAT),
                     io.req(i).bits.op.isOneOf(LsuOp.LH, LsuOp.LHU, LsuOp.SH),
                     io.req(i).bits.op.isOneOf(LsuOp.LB, LsuOp.LBU, LsuOp.SB))
    val opfldst = (io.req(i).bits.op === LsuOp.FLOAT)

    val regionType = MuxCase(MemoryRegionType.External, Array(
      dtcm -> MemoryRegionType.DMEM,
      itcm -> MemoryRegionType.IMEM,
      peri -> MemoryRegionType.Peripheral,
    ))
    val crossLineBoundary =
      (Mod2(io.busPort.addr(i), p.lsuDataBytes.U) + opsize > p.lsuDataBytes.U)
    val twoLines = crossLineBoundary && (dtcm || itcm)
    val belowLineBoundary = (p.lsuDataBytes.U - Mod2(io.busPort.addr(i), p.lsuDataBytes.U))(2,0)
    val txnSizes = Mux(twoLines, VecInit(belowLineBoundary, (opsize - belowLineBoundary)), VecInit(opsize, 0.U))
    val (mask0, mask1) = GenerateMasks(p.lsuDataBytes, io.busPort.addr(i), txnSizes)

    ctrl.io.in.bits(i * 2 + 1).valid := io.req(i).valid && ctrlready(i)
    ctrl.io.in.bits(i * 2 + 1).bits.pc := io.req(i).bits.pc
    ctrl.io.in.bits(i * 2 + 1).bits.addr := io.busPort.addr(i)
    ctrl.io.in.bits(i * 2 + 1).bits.adrx := io.busPort.addr(i) + lineoffset.U
    ctrl.io.in.bits(i * 2 + 1).bits.data := (if (p.enableFloat) {
      Mux(opfldst, io.busPort_flt.get.data(i), io.busPort.data(i))
    } else {
      io.busPort.data(i)
    })
    ctrl.io.in.bits(i * 2 + 1).bits.index := io.req(i).bits.addr
    ctrl.io.in.bits(i * 2 + 1).bits.sext := opsext
    ctrl.io.in.bits(i * 2 + 1).bits.size := txnSizes(0)
    ctrl.io.in.bits(i * 2 + 1).bits.fullsize := opsize
    ctrl.io.in.bits(i * 2 + 1).bits.iload := opiload
    ctrl.io.in.bits(i * 2 + 1).bits.fencei   := opfencei
    ctrl.io.in.bits(i * 2 + 1).bits.flushat  := opflushat
    ctrl.io.in.bits(i * 2 + 1).bits.flushall := opflushall
    ctrl.io.in.bits(i * 2 + 1).bits.sldst := opsldst
    ctrl.io.in.bits(i * 2 + 1).bits.vldst := opvldst
    ctrl.io.in.bits(i * 2 + 1).bits.fldst := opfldst
    ctrl.io.in.bits(i * 2 + 1).bits.write := !opload
    ctrl.io.in.bits(i * 2 + 1).bits.regionType := regionType
    ctrl.io.in.bits(i * 2 + 1).bits.mask := mask0
    ctrl.io.in.bits(i * 2 + 1).bits.last := true.B

    ctrl.io.in.bits(i * 2).valid := io.req(i).valid && ctrlready(i) && twoLines
    ctrl.io.in.bits(i * 2).bits.pc := io.req(i).bits.pc
    ctrl.io.in.bits(i * 2).bits.addr := Cat(io.busPort.addr(i)(31,linebit) + 1.U, 0.U(linebit.W))
    ctrl.io.in.bits(i * 2).bits.adrx := Cat(io.busPort.addr(i)(31,linebit) + 1.U, 0.U(linebit.W)) + lineoffset.U
    ctrl.io.in.bits(i * 2).bits.data := (if (p.enableFloat) {
      Mux(opfldst, io.busPort_flt.get.data(i), io.busPort.data(i))
    } else {
      io.busPort.data(i)
    }).rotateRight(txnSizes(0) * 8.U)
    ctrl.io.in.bits(i * 2).bits.index := io.req(i).bits.addr
    ctrl.io.in.bits(i * 2).bits.sext := opsext
    ctrl.io.in.bits(i * 2).bits.size := txnSizes(1)
    ctrl.io.in.bits(i * 2).bits.fullsize := opsize
    ctrl.io.in.bits(i * 2).bits.iload := opiload
    ctrl.io.in.bits(i * 2).bits.fencei   := opfencei
    ctrl.io.in.bits(i * 2).bits.flushat  := opflushat
    ctrl.io.in.bits(i * 2).bits.flushall := opflushall
    ctrl.io.in.bits(i * 2).bits.sldst := opsldst
    ctrl.io.in.bits(i * 2).bits.vldst := opvldst
    ctrl.io.in.bits(i * 2).bits.fldst := opfldst
    ctrl.io.in.bits(i * 2).bits.write := !opload
    ctrl.io.in.bits(i * 2).bits.regionType := regionType
    ctrl.io.in.bits(i * 2).bits.mask := mask1
    ctrl.io.in.bits(i * 2).bits.last := false.B
  }

  // ---------------------------------------------------------------------------
  // Control Port Outputs.
  val wsel = ctrl.io.out.bits.addr(1,0)
  val wda = ctrl.io.out.bits.data
  val wdataS =
    MuxOR(wsel === 0.U, wda(31,0)) |
    MuxOR(wsel === 1.U, Cat(wda(23,16), wda(15,8), wda(7,0), wda(31,24))) |
    MuxOR(wsel === 2.U, Cat(wda(15,8), wda(7,0), wda(31,24), wda(23,16))) |
    MuxOR(wsel === 3.U, Cat(wda(7,0), wda(31,24), wda(23,16), wda(15,8)))
  val wmaskB = p.lsuDataBits / 8
  val wmaskT = (~0.U(wmaskB.W)) >> (wmaskB.U - ctrl.io.out.bits.size)
  val wmaskS = (wmaskT << ctrl.io.out.bits.addr(linebit-1,0)) |
               (wmaskT >> (lineoffset.U - ctrl.io.out.bits.addr(linebit-1,0)))
  val wdata = Wire(UInt(p.lsuDataBits.W))
  val wmask = wmaskS(lineoffset - 1, 0)

  if (p.lsuDataBits == 128) {
    wdata := Cat(wdataS, wdataS, wdataS, wdataS)
  } else if (p.lsuDataBits == 256) {
    wdata := Cat(wdataS, wdataS, wdataS, wdataS,
                 wdataS, wdataS, wdataS, wdataS)
  } else if (p.lsuDataBits == 512) {
    wdata := Cat(wdataS, wdataS, wdataS, wdataS,
                 wdataS, wdataS, wdataS, wdataS,
                 wdataS, wdataS, wdataS, wdataS,
                 wdataS, wdataS, wdataS, wdataS)
  } else {
    assert(false)
  }

  val busFired = (io.dbus.valid && io.dbus.ready ||
                  io.ebus.dbus.valid && io.ebus.dbus.ready ||
                  io.ibus.valid && io.ibus.ready)

  io.dbus.valid := ctrl.io.out.valid && (ctrl.io.out.bits.sldst || ctrl.io.out.bits.fldst) && (ctrl.io.out.bits.regionType === MemoryRegionType.DMEM)
  io.dbus.write := ctrl.io.out.bits.write
  io.dbus.addr  := Cat(0.U(1.W), ctrl.io.out.bits.addr(30,0))
  io.dbus.adrx  := Cat(0.U(1.W), ctrl.io.out.bits.adrx(30,0))
  io.dbus.size  := ctrl.io.out.bits.size
  io.dbus.wdata := wdata
  io.dbus.wmask := wmask
  io.dbus.pc := ctrl.io.out.bits.pc

  assert(!(io.dbus.valid && ctrl.io.out.bits.addr(31)))
  assert(!(io.dbus.valid && io.dbus.addr(31)))
  assert(!(io.dbus.valid && io.dbus.adrx(31)))

  io.ebus.dbus.valid := ctrl.io.out.valid && (ctrl.io.out.bits.sldst || ctrl.io.out.bits.fldst) &&
    ((ctrl.io.out.bits.regionType === MemoryRegionType.External) || (ctrl.io.out.bits.regionType === MemoryRegionType.Peripheral))
  io.ebus.dbus.write := ctrl.io.out.bits.write
  io.ebus.dbus.addr := ctrl.io.out.bits.addr
  io.ebus.dbus.adrx := ctrl.io.out.bits.adrx
  io.ebus.dbus.size := ctrl.io.out.bits.size
  io.ebus.dbus.wdata := wdata
  io.ebus.dbus.wmask := wmask
  io.ebus.dbus.pc := ctrl.io.out.bits.pc
  io.ebus.internal := ctrl.io.out.bits.regionType === MemoryRegionType.Peripheral

  io.ibus.valid :=
    ctrl.io.out.valid && (ctrl.io.out.bits.sldst || ctrl.io.out.bits.fldst) &&
    (ctrl.io.out.bits.regionType === MemoryRegionType.IMEM) &&
    !ctrl.io.out.bits.write
  io.ibus.addr := ctrl.io.out.bits.addr

  // All stores to IMEM are disallowed.
  val imem_store_fault =
    (ctrl.io.out.valid && (ctrl.io.out.bits.sldst || ctrl.io.out.bits.fldst) &&
    (ctrl.io.out.bits.regionType === MemoryRegionType.IMEM) &&
    ctrl.io.out.bits.write)
  val ebus_fault = io.ebus.fault.valid
  io.fault := MuxCase(MakeInvalid(new FaultInfo(p)), Array(
    imem_store_fault -> (MakeWireBundle[ValidIO[FaultInfo]](
      Valid(new FaultInfo(p)),
      _.valid -> true.B,
      _.bits.write -> true.B,
      _.bits.addr -> ctrl.io.out.bits.addr,
      _.bits.epc -> ctrl.io.out.bits.pc,
    )),
    ebus_fault -> (MakeWireBundle[ValidIO[FaultInfo]](
      Valid(new FaultInfo(p)),
      _.valid -> true.B,
      _.bits.write -> io.ebus.fault.bits.write,
      _.bits.addr -> io.ebus.fault.bits.addr,
      _.bits.epc -> io.ebus.fault.bits.epc,
    )),
  ))

  io.storeCount := PopCount(Cat(
    io.dbus.valid && io.dbus.write,
    io.ebus.dbus.valid && io.ebus.dbus.write
  ))

  io.flush.valid  := ctrl.io.out.valid && (ctrl.io.out.bits.fencei || ctrl.io.out.bits.flushat || ctrl.io.out.bits.flushall)
  io.flush.all    := ctrl.io.out.bits.fencei || ctrl.io.out.bits.flushall
  io.flush.clean  := true.B
  io.flush.fencei := ctrl.io.out.bits.fencei
  io.flush.pcNext := ctrl.io.out.bits.pc + 4.U

  ctrl.io.out.ready := io.flush.valid && io.flush.ready ||
                       imem_store_fault ||
                       ctrl.io.out.bits.vldst && io.dbus.ready ||
                       (busFired)

  io.vldst := ctrl.io.out.valid && ctrl.io.out.bits.vldst

  // ---------------------------------------------------------------------------
  // Load response.
  val dataFired = (io.dbus.valid && io.dbus.ready && !io.dbus.write ||
                      io.ebus.dbus.valid && io.ebus.dbus.ready && !io.ebus.dbus.write ||
                      io.ibus.valid && io.ibus.ready)
  data.io.in.valid := dataFired

  data.io.in.bits.addr  := ctrl.io.out.bits.addr
  data.io.in.bits.index := ctrl.io.out.bits.index
  data.io.in.bits.sext  := ctrl.io.out.bits.sext
  data.io.in.bits.size  := ctrl.io.out.bits.size
  data.io.in.bits.fullsize  := ctrl.io.out.bits.fullsize
  data.io.in.bits.iload := ctrl.io.out.bits.iload
  data.io.in.bits.sldst := ctrl.io.out.bits.sldst
  data.io.in.bits.fldst := ctrl.io.out.bits.fldst
  data.io.in.bits.regionType := ctrl.io.out.bits.regionType
  data.io.in.bits.mask := ctrl.io.out.bits.mask
  data.io.in.bits.last := ctrl.io.out.bits.last

  data.io.out.ready := true.B

  assert(!(ctrl.io.in.valid && !data.io.in.ready))

  // ---------------------------------------------------------------------------
  // Register file ports.
  val rvalid = data.io.out.valid && data.io.out.bits.last
  val rsext = data.io.out.bits.sext
  val rsize = data.io.out.bits.fullsize
  val rsel  = data.io.out.bits.addr(linebit - 1, 0)

  // Rotate and sign extend.
  def RotSignExt(datain: UInt, dataout: UInt = 0.U(p.lsuDataBits.W), i: Int = 0): UInt = {
    assert(datain.getWidth  == p.lsuDataBits)
    assert(dataout.getWidth == p.lsuDataBits)

    if (i < p.lsuDataBits / 8) {
      val mod = p.lsuDataBits

      val rdata = Cat(datain((8 * (i + 3) + 7) % mod, (8 * (i + 3)) % mod),
                      datain((8 * (i + 2) + 7) % mod, (8 * (i + 2)) % mod),
                      datain((8 * (i + 1) + 7) % mod, (8 * (i + 1)) % mod),
                      datain((8 * (i + 0) + 7) % mod, (8 * (i + 0)) % mod))

      val sizeMask = Mux(rsize === 4.U, 0xffffffff.S(32.W).asUInt,
                     Mux(rsize === 3.U, 0x00ffffff.S(32.W).asUInt,
                     Mux(rsize === 2.U, 0x0000ffff.U(32.W), 0x000000ff.U(32.W))))

      val signExtend = Mux(rsext,
                         Mux(rsize === 2.U,
                           Mux(rdata(15), 0xffff0000.S(32.W).asUInt, 0.U(32.W)),
                           Mux(rdata(7),  0xffffff00.S(32.W).asUInt, 0.U(32.W))),
                         0.U)
      assert(sizeMask.getWidth == 32)
      assert(signExtend.getWidth == 32)

      val sdata = MuxOR(rsel === i.U, rdata & sizeMask | signExtend)
      RotSignExt(datain, dataout | sdata, i + 1)
    } else {
      dataout
    }
  }

  val regionType = data.io.out.bits.regionType
  val srdata = (MuxLookup(regionType, 0.U.asTypeOf(io.dbus.rdata))(Seq(
    MemoryRegionType.DMEM -> io.dbus.rdata,
    MemoryRegionType.IMEM -> io.ibus.rdata,
    MemoryRegionType.External -> io.ebus.dbus.rdata,
    MemoryRegionType.Peripheral -> io.ebus.dbus.rdata,
  )))
  val srdataMasked = (srdata & BytemaskToBitmask(data.io.out.bits.mask))
  val prevSrdataReg = RegNext(srdataMasked, 0.U(p.lsuDataBits.W))
  val prevSrdata = MuxOR(data.io.out.bits.fullsize =/= data.io.out.bits.size, prevSrdataReg(p.lsuDataBits-1,0))
  val combinedSrdata = RotSignExt(srdataMasked | prevSrdata)

  val rdata = MuxOR(data.io.out.bits.sldst, combinedSrdata)
  val frdata = MuxOR(data.io.out.bits.fldst, combinedSrdata)

  // pass-through
  val io_rd_pre_pipe = Wire(Valid(Flipped(new RegfileWriteDataIO)))
  io_rd_pre_pipe.valid := rvalid && data.io.out.bits.iload
  io_rd_pre_pipe.bits.addr  := data.io.out.bits.index
  io_rd_pre_pipe.bits.data  := rdata

  // Add one cycle pipeline delay to io.rd passthrough for timing
  val io_rd_pipe = Pipe(io_rd_pre_pipe, p.lsuDelayPipelineLen)
  io.rd := io_rd_pipe

  val io_rd_flt_pre_pipe = Wire(Valid(Flipped(new RegfileWriteDataIO)))
  io_rd_flt_pre_pipe.valid := rvalid && data.io.out.bits.fldst
  io_rd_flt_pre_pipe.bits.addr := data.io.out.bits.index
  io_rd_flt_pre_pipe.bits.data := frdata

  val io_rd_flt_pipe = Pipe(io_rd_flt_pre_pipe, p.lsuDelayPipelineLen)
  io.rd_flt := io_rd_flt_pipe

  assert(!ctrl.io.out.valid || PopCount(Cat(ctrl.io.out.bits.fldst, ctrl.io.out.bits.sldst, ctrl.io.out.bits.vldst)) <= 1.U)
  assert(!data.io.out.valid || PopCount(Cat(data.io.out.bits.fldst, data.io.out.bits.sldst)) <= 1.U)
}
