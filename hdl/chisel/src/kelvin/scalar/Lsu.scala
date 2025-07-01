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
import kelvin.rvv._

class DFlushFenceiIO(p: Parameters) extends DFlushIO(p) {
  val fencei = Output(Bool())
  val pcNext = Output(UInt(32.W))
}

class Lsu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Vec(p.instructionLanes, Flipped(Decoupled(new LsuCmd(p))))
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

    val rvv2lsu = Option.when(p.enableRvv)(
        Vec(2, Flipped(Decoupled(new Rvv2Lsu(p)))))
    val lsu2rvv = Option.when(p.enableRvv)(Vec(2, Decoupled(new Lsu2Rvv(p))))

    // RVV config state
    val rvvState = Option.when(p.enableRvv)(Input(Valid(new RvvConfigState(p))))

    val storeCount = Output(UInt(2.W))
    val active = Output(Bool())
  })
}

object Lsu {
  def apply(p: Parameters): Lsu = {
    if (p.useLsuV2) {
      return Module(new LsuV2(p))
    } else {
      return Module(new LsuV1(p))
    }
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

  // Vector instructions.
  val VLOAD_UNIT = Value
  val VLOAD_STRIDED = Value
  val VLOAD_OINDEXED = Value
  val VLOAD_UINDEXED = Value
  val VSTORE_UNIT = Value
  val VSTORE_STRIDED = Value
  val VSTORE_OINDEXED = Value
  val VSTORE_UINDEXED = Value

  def isVector(op: LsuOp.Type): Bool = {
    op.isOneOf(LsuOp.VLOAD_UNIT, LsuOp.VLOAD_STRIDED,
               LsuOp.VLOAD_OINDEXED, LsuOp.VLOAD_UINDEXED,
               LsuOp.VSTORE_UNIT, LsuOp.VSTORE_STRIDED,
               LsuOp.VSTORE_OINDEXED, LsuOp.VSTORE_UINDEXED)
  }

  def isFlush(op: LsuOp.Type): Bool = {
    op.isOneOf(LsuOp.FENCEI, LsuOp.FLUSHAT, LsuOp.FLUSHALL)
  }
}

class LsuCmd(p: Parameters) extends Bundle {
  val store = Bool()
  val addr = UInt(5.W)
  val op = LsuOp()
  val pc = UInt(32.W)
  val elemWidth = Option.when(p.enableRvv) { UInt(3.W) }
}

class LsuUOp(p: Parameters) extends Bundle {
  val store = Bool()
  val rd = UInt(5.W)
  val op = LsuOp()
  val pc = UInt(32.W)
  val addr = UInt(32.W)
  val data = UInt(32.W)  // Doubles as rs2
  val elemWidth = Option.when(p.enableRvv) { UInt(3.W) }

  override def toPrintable: Printable = {
    cf"LsuUOp(store -> ${store}, rd -> ${rd}, op -> ${op}, " +
    cf"pc -> 0x${pc}%x, addr -> 0x${addr}%x, data -> ${data})"
  }
}

object LsuUOp {
  def apply(p: Parameters,
            i: Int,
            cmd: LsuCmd,
            sbus: RegfileBusPortIO,
            fbus: Option[RegfileBusPortIO]): LsuUOp = {
    val result = Wire(new LsuUOp(p))
    result.store := cmd.store
    result.rd := cmd.addr
    result.op := cmd.op
    result.pc := cmd.pc
    if (fbus.isDefined) {
      result.addr := sbus.addr(i)
      result.data := Mux(
          cmd.op === LsuOp.FLOAT, fbus.get.data(i), sbus.data(i))
    } else {
      result.addr := sbus.addr(i)
      result.data := sbus.data(i)
    }
    if (p.enableRvv) {
      result.elemWidth.get := cmd.elemWidth.get
    }

    result
  }
}

// bytesPerSlot is the number of bytes in a vector register
// bytesPerLine is the number of bytes in the AXI bus
class LsuSlot(bytesPerSlot: Int, bytesPerLine: Int) extends Bundle {
  val elemBits = log2Ceil(bytesPerLine)

  val op = LsuOp()
  val rd = UInt(5.W)
  val store = Bool()
  val pc = UInt(32.W)
  val active = Vec(bytesPerSlot, Bool())
  val addrs = Vec(bytesPerSlot, UInt(32.W))
  val data = Vec(bytesPerSlot, UInt(8.W))
  val pendingVector = Bool()
  val pendingWriteback = Bool()

  // If the slot has no pending tasks and can accept a new operation
  def slotIdle(): Bool = {
    !(active.reduce(_||_) || pendingWriteback)
  }

  // If the slot has any active transactions.
  def activeTransaction(): Bool = {
    active.reduce(_||_)
  }

  def lineAddresses(): Vec[UInt] = {
    VecInit(addrs.map(x => x(31, elemBits)))
  }

  def elemAddresses(): Vec[UInt] = {
    VecInit(addrs.map(x => x(elemBits-1, 0)))
  }

  def targetLineAddress(lastRead: Valid[UInt]): Valid[UInt] = {
    // Determine which lines are active. If a read was issued last cycle,
    // supress those lines.
    val lineAddrs = lineAddresses()
    val lineActive = (0 until bytesPerSlot).map(i =>
        active(i) && (!lastRead.valid || (lastRead.bits =/= lineAddrs(i))))

    MuxCase(MakeInvalid(UInt((32-elemBits).W)), (0 until bytesPerSlot).map(
        i => lineActive(i) -> MakeValid(true.B, lineAddrs(i))))
  }

  def vectorUpdate(updated: Bool, rvv2lsu: Rvv2Lsu): LsuSlot = {
    val result = Wire(new LsuSlot(bytesPerSlot, bytesPerLine))
    result.op := op
    result.rd := rd
    result.store := store
    result.pc := pc
    result.pendingWriteback := pendingWriteback
    // TODO(derekjchow): Set addrs correctly for indexed
    result.addrs := Mux(
        updated && LsuOp.isVector(op) && rvv2lsu.idx.valid,
        VecInit(UIntToVec(rvv2lsu.idx.bits.data, 8).map(x =>
            Cat(0.U(24.W), x)
        )),
        addrs)

    result.data := Mux(updated && LsuOp.isVector(op) && rvv2lsu.vregfile.valid,
        UIntToVec(rvv2lsu.vregfile.bits.data, 8), data)
    result.active := Mux(updated && LsuOp.isVector(op) && rvv2lsu.mask.valid,
        VecInit(rvv2lsu.mask.bits.asBools), active)
    result.pendingVector := pendingVector && !updated
    result
  }

  // Updates the slot based on a previous read.
  // TODO(derekjchow): Update me for vector
  def loadUpdate(valid: Bool,
                 lineAddr: UInt,
                 lineData: UInt): LsuSlot = {
    // TODO(derekjchow): Check ordering semantics
    val lineAddrs = lineAddresses()
    val lineActive = VecInit((0 until bytesPerSlot).map(i =>
        !store &&     // Don't update if a store
        (!LsuOp.isVector(op) || !pendingVector) &&  // Has vector data if needed
        valid &&      // Update only if a valid read last cycle
        active(i) &&  // Update only if active
        (lineAddrs(i) === lineAddr)))  // Line must match read line
    val lineDataVec = UIntToVec(lineData, 8)
    val gatheredData = Gather(elemAddresses(), lineDataVec)

    val result = Wire(new LsuSlot(bytesPerSlot, bytesPerLine))
    result.op := op
    result.rd := rd
    result.store := store
    result.pc := pc
    result.addrs := addrs
    result.pendingWriteback := pendingWriteback
    result.pendingVector := pendingVector
    result.active := (0 until bytesPerSlot).map(
        i => active(i) & ~lineActive(i))
    result.data := VecInit((0 until bytesPerSlot).map(
        i => Mux(lineActive(i), gatheredData(i), data(i))))

    result
  }

  // If the load transaction is finished, but the result needs to be written
  // back to the regfile.
  def shouldWriteback(): Bool = {
    pendingWriteback && !pendingVector && !active.reduce(_||_)
  }

  // Updates the slot if its result is written back to the regfile.
  def writebackUpdate(writeback: Bool): LsuSlot = {
    val result = Wire(new LsuSlot(bytesPerSlot, bytesPerLine))
    result.op := op
    result.rd := rd
    result.store := store
    result.pc := pc
    result.addrs := addrs
    result.pendingWriteback := pendingWriteback && !writeback
    result.pendingVector := pendingVector
    result.active := active
    result.data := data

    result
  }

  // TODO(derekjchow): Update me for vector
  def scatter(lineAddr: UInt): (Vec[UInt], Vec[Bool], Vec[Bool]) = {
    val canScatter = store && (!LsuOp.isVector(op) || !pendingVector)
    val lineAddrs = lineAddresses()
    val lineActive = VecInit((0 until bytesPerSlot).map(i =>
        canScatter && active(i) & (lineAddrs(i) === lineAddr)))
    Scatter(lineActive, elemAddresses(), data)
  }

  // TODO(derekjchow): Update me for vector
  def storeUpdate(selected: Vec[Bool]): LsuSlot = {
    assert(selected.length == active.length)
    val result = Wire(new LsuSlot(bytesPerSlot, bytesPerLine))
    result.op := op
    result.rd := rd
    result.store := store
    result.pc := pc
    result.pendingWriteback := pendingWriteback
    result.pendingVector := pendingVector
    result.active := (0 until bytesPerSlot).map(i => active(i) & ~selected(i))
    result.addrs := addrs
    result.data := data
    result
  }

  def scalarLoadResult(): UInt = {
    val word = Cat(data(3), data(2), data(1), data(0))
    val half = Cat(data(1), data(0))
    val byte =  data(0)
    // Sign extends the result of a load operation when necessary.
    val halfSigned = Wire(SInt(32.W))
    halfSigned := half.asSInt
    val byteSigned = Wire(SInt(32.W))
    byteSigned := byte.asSInt
    MuxCase(0.U, Seq(
      (op === LsuOp.LB) -> byteSigned.asUInt,
      (op === LsuOp.LBU) -> byte,
      (op === LsuOp.LH) -> halfSigned.asUInt,
      (op === LsuOp.LHU) -> half,
      (op === LsuOp.LW) -> word,
      (op === LsuOp.FLOAT) -> word,
    ))
  }

  override def toPrintable: Printable = {
    val lines = (0 until bytesPerSlot).map(i =>
        cf"  $i: ${active(i)}, 0x${addrs(i)}%x, 0x${data(i)}%x\n")
    cf"store: $store\n  op: ${op}\n" + lines.reduce(_+_)
  }
}

object LsuSlot {
  def inactive(p: Parameters, bytesPerSlot: Int): LsuSlot = {
    0.U.asTypeOf(new LsuSlot(bytesPerSlot, p.lsuDataBytes))
  }

  def computeStridedAddrs(bytesPerSlot: Int,
                          baseAddr: UInt,
                          stride: UInt,
                          elemWidth: UInt): Vec[UInt] = {
    MuxCase(VecInit.fill(bytesPerSlot)(0.U(32.W)), Seq(
      // elemWidth validation is done at decode time.
      // TODO: pass this as an enum.
      (elemWidth === "b000".U) -> VecInit((0 until bytesPerSlot).map(i => (baseAddr + (i.U*stride))(31, 0))),  // 1-byte elements
      (elemWidth === "b101".U) -> VecInit((0 until bytesPerSlot).map(i => (baseAddr + ((i >> 1).U*stride))(31, 0) + (i & 1).U)),  // 2-byte elements
      (elemWidth === "b110".U) -> VecInit((0 until bytesPerSlot).map(i => (baseAddr + ((i >> 2).U*stride))(31, 0) + (i & 3).U)),  // 4-byte elements
    ))
  }

  def fromLsuUOp(uop: LsuUOp, p: Parameters, bytesPerSlot: Int): LsuSlot = {
    val result = Wire(new LsuSlot(bytesPerSlot, p.lsuDataBytes))
    result.op := uop.op
    result.rd := uop.rd
    result.store := uop.store
    result.pc := uop.pc

    // TODO(derekjchow): Fix me
    result.pendingWriteback := !uop.store || LsuOp.isVector(uop.op)
    result.pendingVector := LsuOp.isVector(uop.op)

    val active = MuxCase(0.U(bytesPerSlot.W), Seq(
      uop.op.isOneOf(LsuOp.LB, LsuOp.LBU, LsuOp.SB) -> "b1".U(bytesPerSlot.W),
      uop.op.isOneOf(LsuOp.LH, LsuOp.LHU, LsuOp.SH) -> "b11".U(bytesPerSlot.W),
      uop.op.isOneOf(LsuOp.LW, LsuOp.SW, LsuOp.FLOAT) -> "b1111".U(bytesPerSlot.W),
      // Vector
      LsuOp.isVector(uop.op) -> ~0.U(bytesPerSlot.W),
    ))
    result.active := active.asBools

    // Compute addrs
    result.addrs := Mux(
        uop.op.isOneOf(LsuOp.VLOAD_STRIDED, LsuOp.VSTORE_STRIDED),
        computeStridedAddrs(bytesPerSlot, uop.addr, uop.data, uop.elemWidth.getOrElse(0.U(3.W))),
        VecInit((0 until bytesPerSlot).map(i => uop.addr + i.U)))

    result.data(0) := uop.data(7, 0)
    result.data(1) := uop.data(15, 8)
    result.data(2) := uop.data(23, 16)
    result.data(3) := uop.data(31, 24)
    for (i <- 4 until bytesPerSlot) {
      result.data(i) := 0.U
    }

    result
  }
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

object LsuBus extends ChiselEnum {
  val IBUS = Value
  val DBUS = Value
  val EXTERNAL = Value
}

class LsuRead(lineBits: Int) extends Bundle {
  val bus = LsuBus()
  val lineAddr = UInt(lineBits.W)
}

object LsuRead {
  def apply(bus: LsuBus.Type, lineAddr: UInt): LsuRead = {
    val result = Wire(new LsuRead(lineAddr.getWidth))
    result.bus := bus
    result.lineAddr := lineAddr
    result
  }
}

class FlushCmd extends Bundle {
  val all = Bool()
  val fencei = Bool()
  val pcNext = UInt(32.W)
}

object FlushCmd {
  def apply(cmd: LsuCmd): FlushCmd = {
    val result = Wire(new FlushCmd)
    result.all    := cmd.op.isOneOf(LsuOp.FENCEI, LsuOp.FLUSHALL)
    result.fencei := (cmd.op === LsuOp.FENCEI)
    result.pcNext := cmd.pc + 4.U
    result
  }
}

class LsuV1(p: Parameters) extends Lsu(p) {
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

    val regionType = MuxCase(MemoryRegionType.External, Seq(
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
  io.fault := MuxCase(MakeInvalid(new FaultInfo(p)), Seq(
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

class LsuV2(p: Parameters) extends Lsu(p) {
  // Tie-offs
  io.vldst := 0.U
  io.storeCount := 0.U

  val opQueue = Module(new Queue(new LsuUOp(p), 4))

  // Flush state
  // DispatchV2 will only flush on first slot, when LSU is inactive.

  val flushCmd = RegInit(MakeInvalid(new FlushCmd))  // Track pending flush + pc
  io.flush.valid  := flushCmd.valid
  io.flush.all    := flushCmd.bits.all
  io.flush.clean  := true.B
  io.flush.fencei := flushCmd.bits.fencei
  io.flush.pcNext := flushCmd.bits.pcNext

  flushCmd := MuxCase(flushCmd, Seq(
    // New flush command
    (io.req(0).fire && LsuOp.isFlush(io.req(0).bits.op))
        -> MakeValid(true.B, FlushCmd(io.req(0).bits)),
    // Finish flush command
    (io.flush.valid && io.flush.ready) -> MakeInvalid(new FlushCmd),
  ))

  // Accept one instruction per cycle.
  // TODO(derekjchow): Accept multiple when primitives are ready.
  val canAccept = opQueue.io.enq.ready
  val queueSpace = Mux(canAccept, 1.U, 0.U)
  val validSum = io.req.map(_.valid).scan(
      0.U(log2Ceil(p.instructionLanes + 1).W))(_+_)

  for (i <- 0 until p.instructionLanes) {
    io.req(i).ready := (validSum(i) < queueSpace) && !flushCmd.valid
  }

  val ops = (0 until p.instructionLanes).map(i =>
      LsuUOp(p, i, io.req(i).bits, io.busPort, io.busPort_flt))
  val enq = MuxCase(
      MakeInvalid(new LsuUOp(p)),
      (0 until p.instructionLanes).map(i =>
          ((io.req(i).fire && !io.req(i).bits.op.isOneOf(LsuOp.FENCEI, LsuOp.FLUSHAT, LsuOp.FLUSHALL)) -> MakeValid(true.B, ops(i)))))
  opQueue.io.enq.valid := enq.valid
  opQueue.io.enq.bits := enq.bits

  val nextSlot = LsuSlot.fromLsuUOp(opQueue.io.deq.bits, p, 16)

  // Tracks if a read has been fired last cycle.
  val readFired = RegInit(MakeInvalid(new LsuRead(32 - nextSlot.elemBits)))
  val slot = RegInit(LsuSlot.inactive(p, 16))
  
  val readData = MuxLookup(readFired.bits.bus, 0.U)(Seq(
      LsuBus.IBUS -> io.ibus.rdata,
      LsuBus.DBUS -> io.dbus.rdata,
      LsuBus.EXTERNAL -> io.ebus.dbus.rdata,
  ))

  // TODO(derekjchow): Finish up store path
  val vectorUpdatedSlot =
  if (p.enableRvv) {
    io.rvv2lsu.get(0).ready := slot.pendingVector
    io.rvv2lsu.get(1).ready := false.B
    slot.vectorUpdate(
        io.rvv2lsu.get(0).fire, io.rvv2lsu.get(0).bits)
  } else {
    slot.vectorUpdate(false.B, 0.U.asTypeOf(new Rvv2Lsu(p)))
  }

  // First stage of load update: Update results based on bus read
  val loadUpdatedSlot = vectorUpdatedSlot.loadUpdate(
      readFired.valid, readFired.bits.lineAddr, readData)

  // Scalar writeback
  io.rd.valid := loadUpdatedSlot.shouldWriteback() &&
      loadUpdatedSlot.op.isOneOf(LsuOp.LB, LsuOp.LBU, LsuOp.LH, LsuOp.LHU,
                                 LsuOp.LW)
  io.rd.bits.data := loadUpdatedSlot.scalarLoadResult()
  io.rd.bits.addr := loadUpdatedSlot.rd

  // Float writeback
  io.rd_flt.valid := loadUpdatedSlot.shouldWriteback() &&
                     (loadUpdatedSlot.op === LsuOp.FLOAT) && !loadUpdatedSlot.store
  io.rd_flt.bits.addr := loadUpdatedSlot.rd
  io.rd_flt.bits.data := loadUpdatedSlot.scalarLoadResult()

  // Vector writeback
  // TODO(derekjchow): Write back for stores
  if (p.enableRvv) {
    io.lsu2rvv.get(0).valid := loadUpdatedSlot.shouldWriteback() &&
        LsuOp.isVector(loadUpdatedSlot.op)
    // io.lsu2rvv.get(0).valid := loadUpdatedSlot.shouldWriteback() &&
    //     loadUpdatedSlot.op.isOneOf(LsuOp.VLOAD_UNIT, LsuOp.VLOAD_STRIDED,
    //                                LsuOp.VLOAD_OINDEXED, LsuOp.VLOAD_UINDEXED)
    io.lsu2rvv.get(0).bits.addr := loadUpdatedSlot.rd
    io.lsu2rvv.get(0).bits.data := Cat(loadUpdatedSlot.data.reverse)
    io.lsu2rvv.get(0).bits.last := loadUpdatedSlot.shouldWriteback() &&
        loadUpdatedSlot.op.isOneOf(LsuOp.VSTORE_UNIT, LsuOp.VSTORE_STRIDED,
                                   LsuOp.VSTORE_OINDEXED, LsuOp.VSTORE_UINDEXED)

    // when (io.lsu2rvv.get(0).fire) {
    //   printf(cf"Fire to rvv ${io.lsu2rvv.get(0).bits}\n")
    // }

    io.lsu2rvv.get(1).valid := false.B
    io.lsu2rvv.get(1).bits.addr := 0.U
    io.lsu2rvv.get(1).bits.data := 0.U
    io.lsu2rvv.get(1).bits.last := true.B
  }

  // Second stage of load update: Update results based on regfile writeback
  val loadUpdate2Slot = loadUpdatedSlot.writebackUpdate(
      io.rd.valid || io.rd_flt.valid || (if (p.enableRvv) { io.lsu2rvv.get(0).fire } else { false.B }))

  val targetLine = loadUpdate2Slot.targetLineAddress(
      MakeValid(readFired.valid, readFired.bits.lineAddr))
  val targetLineAddr = targetLine.bits << 4
  val itcm = p.m.filter(_.memType == MemoryRegionType.IMEM)
                .map(_.contains(targetLineAddr)).reduceOption(_ || _).getOrElse(false.B)
  val dtcm = p.m.filter(_.memType == MemoryRegionType.DMEM)
                .map(_.contains(targetLineAddr)).reduceOption(_ || _).getOrElse(true.B)
  val peri = p.m.filter(_.memType == MemoryRegionType.Peripheral)
                .map(_.contains(targetLineAddr)).reduceOption(_ || _).getOrElse(false.B)
  val external = !(itcm || dtcm || peri)
  assert(PopCount(Cat(itcm | dtcm | peri)) <= 1.U)

  // Use slot here for timing, as "loadUpdate2Slot" applies to loads only
  val (wdata, wmask, wactive) = vectorUpdatedSlot.scatter(targetLine.bits)

  // ibus data path
  io.ibus.valid := loadUpdate2Slot.activeTransaction() && itcm && !slot.store
  io.ibus.addr := targetLineAddr

  // dbus data path
  io.dbus.valid := dtcm && Mux(vectorUpdatedSlot.store,
                               vectorUpdatedSlot.activeTransaction(),
                               loadUpdate2Slot.activeTransaction())
  io.dbus.write := slot.store
  io.dbus.pc := slot.pc
  io.dbus.addr := targetLineAddr
  io.dbus.adrx := targetLineAddr
  io.dbus.size := 16.U  // TODO(derekjchow): Don't be lazy
  io.dbus.wdata := Cat(wdata.reverse)
  io.dbus.wmask := Cat(wmask.reverse)

  // ebus data path
  io.ebus.dbus.valid := loadUpdate2Slot.activeTransaction() && (external || peri)
  io.ebus.dbus.write := slot.store
  io.ebus.dbus.addr := targetLineAddr
  io.ebus.dbus.adrx := targetLineAddr
  io.ebus.dbus.size := 16.U  // TODO(derekjchow): Don't be lazy
  // TODO(derekjchow): Check direction
  io.ebus.dbus.wdata := Cat(wdata.reverse)
  io.ebus.dbus.wmask := Cat(wmask.reverse)
  io.ebus.dbus.pc := slot.pc
  io.ebus.internal := peri

  val ibusFired = io.ibus.valid && io.ibus.ready
  val dbusFired = io.dbus.valid && io.dbus.ready
  val ebusFired = io.ebus.dbus.valid && io.ebus.dbus.ready
  assert(PopCount(Seq(ibusFired, dbusFired, ebusFired)) <= 1.U)
  val slotFired = ebusFired || dbusFired || ibusFired

  val readFiredValid = ibusFired || (dbusFired && !io.dbus.write) || (ebusFired && !io.ebus.dbus.write)
  readFired := MakeValid(readFiredValid,
    MuxCase(readFired.bits, Seq(
      (ibusFired) -> LsuRead(LsuBus.IBUS, targetLine.bits),
      (dbusFired && !io.dbus.write) -> LsuRead(LsuBus.DBUS, targetLine.bits),
      (ebusFired && !io.ebus.dbus.write) -> LsuRead(LsuBus.EXTERNAL, targetLine.bits),
    )))

  // Fault handling
  val ibusFault = Wire(Valid(new FaultInfo(p)))
  ibusFault.valid := loadUpdate2Slot.activeTransaction() && itcm && slot.store
  ibusFault.bits.write := true.B
  ibusFault.bits.addr := targetLineAddr
  ibusFault.bits.epc := slot.pc

  io.fault := MuxCase(MakeInvalid(new FaultInfo(p)), Seq(
      io.ebus.fault.valid -> io.ebus.fault,
      ibusFault.valid -> ibusFault,
  ))

  // TODO(derekjchow): Improve timing?
  opQueue.io.deq.ready := slot.slotIdle()

  // when (opQueue.io.deq.fire) {
  //   printf(cf"Handling op ${opQueue.io.deq.bits}\n")
  // }

  // Slot update
  slot := MuxCase(slot, Seq(
    // Move to inactive if error.
    io.fault.valid -> LsuSlot.inactive(p, 16),
    // When inactive, dequeue if possible
    (vectorUpdatedSlot.slotIdle() && opQueue.io.deq.valid) -> nextSlot,
    // Handle pending writeback here?
    (vectorUpdatedSlot.shouldWriteback() && vectorUpdatedSlot.store) -> loadUpdate2Slot,
    // Guard writes with slot fired as that when updates.
    (!vectorUpdatedSlot.slotIdle() && vectorUpdatedSlot.store && slotFired) ->
        vectorUpdatedSlot.storeUpdate(wactive),
    // Updates based on readFired (high cycle after slotFired).
    (!vectorUpdatedSlot.slotIdle() && !vectorUpdatedSlot.store) ->
        loadUpdate2Slot,
  ))

  io.active := !slot.slotIdle() || (opQueue.io.count =/= 0.U)
}

