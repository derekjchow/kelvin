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

class DBusIO(p: Parameters, bank: Boolean = false) extends Bundle {
  // Control Phase.
  val valid = Output(Bool())
  val ready = Input(Bool())
  val write = Output(Bool())
  val addr = Output(UInt((p.lsuAddrBits - (if (bank) 1 else 0)).W))
  val adrx = Output(UInt((p.lsuAddrBits - (if (bank) 1 else 0)).W))
  val size = Output(UInt((log2Ceil(p.lsuDataBits / 8) + 1).W))
  val wdata = Output(UInt(p.lsuDataBits.W))
  val wmask = Output(UInt((p.lsuDataBits / 8).W))
  // Read Phase.
  val rdata = Input(UInt(p.lsuDataBits.W))
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
}

class LsuCmd extends Bundle {
  val store = Bool()
  val addr = UInt(5.W)
  val op = LsuOp()
}

class LsuCtrl(p: Parameters) extends Bundle {
  val addr = UInt(32.W)
  val adrx = UInt(32.W)
  val data = UInt(32.W)
  val index = UInt(5.W)
  val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val write = Bool()
  val sext = Bool()
  val iload = Bool()
  val fencei = Bool()
  val flushat = Bool()
  val flushall = Bool()
  val sldst = Bool()  // scalar load/store cached
  val vldst = Bool()  // vector load/store
  val suncd = Bool()  // scalar load/store uncached
}

class LsuReadData(p: Parameters) extends Bundle {
  val addr = UInt(32.W)
  val index = UInt(5.W)
  val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  val sext = Bool()
  val iload = Bool()
  val sldst = Bool()
  val suncd = Bool()
}

class Lsu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Vec(p.instructionLanes, Flipped(Decoupled(new LsuCmd)))
    val busPort = Flipped(new RegfileBusPortIO(p))

    // Execute cycle(s).
    val rd = Valid(Flipped(new RegfileWriteDataIO))

    // Cached interface.
    val dbus = new DBusIO(p)
    val flush = new DFlushFenceiIO(p)

    // Uncached interface.
    val ubus = new DBusIO(p)

    // Vector switch.
    val vldst = Output(Bool())

    val storeCount = Output(UInt(2.W))
  })

  // AXI Queues.
  val n = 8
  val ctrl = FifoX(new LsuCtrl(p), p.instructionLanes, n)
  val data = Slice(new LsuReadData(p), true, true)

  // Match and mask.
  val ctrlready = (1 to p.instructionLanes).reverse.map(x => ctrl.io.count <= (n - x).U)
  // val ctrlready = Cat(
  //   (1 to p.instructionLanes).reverse.map(
  //     x => ctrl.io.count <= (n - x).U
  //   )
  // )

  for (i <- 0 until p.instructionLanes) {
    io.req(i).ready := ctrlready(i) && data.io.in.ready
  }

  // Address phase must use simple logic to resolve mask for unaligned address.
  val linebit = log2Ceil(p.lsuDataBits / 8)
  val lineoffset = (p.lsuDataBits / 8)

  // ---------------------------------------------------------------------------
  // Control Port Inputs.
  ctrl.io.in.valid := io.req.map(_.valid).reduce(_||_)

  val uncacheable = p.m.filter(x => !x.cacheable)
  for (i <- 0 until p.instructionLanes) {
    val uncached = io.busPort.addr(i)(31) ||
      (if (uncacheable.length > 0) uncacheable.map(x => (io.busPort.addr(i) >= x.memStart.U) && (io.busPort.addr(i) < (x.memStart + x.memSize).U)).reduce(_||_) else false.B)

    val opstore = io.req(i).bits.op.isOneOf(LsuOp.SW, LsuOp.SH, LsuOp.SB)
    val opiload = io.req(i).bits.op.isOneOf(LsuOp.LW, LsuOp.LH, LsuOp.LB, LsuOp.LHU, LsuOp.LBU)
    val opload  = opiload
    val opfencei   = (io.req(i).bits.op === LsuOp.FENCEI)
    val opflushat  = (io.req(i).bits.op === LsuOp.FLUSHAT)
    val opflushall = (io.req(i).bits.op === LsuOp.FLUSHALL)
    val opsldst = opstore || opload
    val opvldst = (io.req(i).bits.op === LsuOp.VLDST)
    val opsext = io.req(i).bits.op.isOneOf(LsuOp.LB, LsuOp.LH)
    val opsize = Cat(io.req(i).bits.op.isOneOf(LsuOp.LW, LsuOp.SW),
                     io.req(i).bits.op.isOneOf(LsuOp.LH, LsuOp.LHU, LsuOp.SH),
                     io.req(i).bits.op.isOneOf(LsuOp.LB, LsuOp.LBU, LsuOp.SB))

    ctrl.io.in.bits(i).valid := io.req(i).valid && ctrlready(i) && !(opvldst && uncached)

    ctrl.io.in.bits(i).bits.addr := io.busPort.addr(i)
    ctrl.io.in.bits(i).bits.adrx := io.busPort.addr(i) + lineoffset.U
    ctrl.io.in.bits(i).bits.data := io.busPort.data(i)
    ctrl.io.in.bits(i).bits.index := io.req(i).bits.addr
    ctrl.io.in.bits(i).bits.sext := opsext
    ctrl.io.in.bits(i).bits.size := opsize
    ctrl.io.in.bits(i).bits.iload := opiload
    ctrl.io.in.bits(i).bits.fencei   := opfencei
    ctrl.io.in.bits(i).bits.flushat  := opflushat
    ctrl.io.in.bits(i).bits.flushall := opflushall
    ctrl.io.in.bits(i).bits.sldst := opsldst && !uncached
    ctrl.io.in.bits(i).bits.vldst := opvldst
    ctrl.io.in.bits(i).bits.suncd := opsldst && uncached
    ctrl.io.in.bits(i).bits.write := !opload
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

  io.dbus.valid := ctrl.io.out.valid && ctrl.io.out.bits.sldst
  io.dbus.write := ctrl.io.out.bits.write
  io.dbus.addr  := Cat(0.U(1.W), ctrl.io.out.bits.addr(30,0))
  io.dbus.adrx  := Cat(0.U(1.W), ctrl.io.out.bits.adrx(30,0))
  io.dbus.size  := ctrl.io.out.bits.size
  io.dbus.wdata := wdata
  io.dbus.wmask := wmask
  assert(!(io.dbus.valid && ctrl.io.out.bits.addr(31)))
  assert(!(io.dbus.valid && io.dbus.addr(31)))
  assert(!(io.dbus.valid && io.dbus.adrx(31)))

  io.ubus.valid := ctrl.io.out.valid && ctrl.io.out.bits.suncd
  io.ubus.write := ctrl.io.out.bits.write
  io.ubus.addr  := Cat(0.U(1.W), ctrl.io.out.bits.addr(30,0))
  io.ubus.adrx  := Cat(0.U(1.W), ctrl.io.out.bits.adrx(30,0))
  io.ubus.size  := ctrl.io.out.bits.size
  io.ubus.wdata := wdata
  io.ubus.wmask := wmask
  assert(!(io.ubus.valid && io.dbus.addr(31)))
  assert(!(io.ubus.valid && io.dbus.adrx(31)))

  io.storeCount := PopCount(Cat(
    io.dbus.valid && io.dbus.write,
    io.ubus.valid && io.ubus.write
  ))

  io.flush.valid  := ctrl.io.out.valid && (ctrl.io.out.bits.fencei || ctrl.io.out.bits.flushat || ctrl.io.out.bits.flushall)
  io.flush.all    := ctrl.io.out.bits.fencei || ctrl.io.out.bits.flushall
  io.flush.clean  := true.B
  io.flush.fencei := ctrl.io.out.bits.fencei

  ctrl.io.out.ready := io.flush.valid && io.flush.ready ||
                       io.dbus.valid && io.dbus.ready ||
                       io.ubus.valid && io.ubus.ready ||
                       ctrl.io.out.bits.vldst && io.dbus.ready

  io.vldst := ctrl.io.out.valid && ctrl.io.out.bits.vldst

  // ---------------------------------------------------------------------------
  // Load response.
  data.io.in.valid := io.dbus.valid && io.dbus.ready && !io.dbus.write ||
                      io.ubus.valid && io.ubus.ready && !io.ubus.write

  data.io.in.bits.addr  := ctrl.io.out.bits.addr
  data.io.in.bits.index := ctrl.io.out.bits.index
  data.io.in.bits.sext  := ctrl.io.out.bits.sext
  data.io.in.bits.size  := ctrl.io.out.bits.size
  data.io.in.bits.iload := ctrl.io.out.bits.iload
  data.io.in.bits.sldst := ctrl.io.out.bits.sldst
  data.io.in.bits.suncd := ctrl.io.out.bits.suncd

  data.io.out.ready := true.B

  assert(!(ctrl.io.in.valid && !data.io.in.ready))

  // ---------------------------------------------------------------------------
  // Register file ports.
  val rvalid = data.io.out.valid
  val rsext = data.io.out.bits.sext
  val rsize = data.io.out.bits.size
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
                     Mux(rsize === 2.U, 0x0000ffff.U(32.W), 0x000000ff.U(32.W)))

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

  val rdata = RotSignExt(MuxOR(data.io.out.bits.sldst, io.dbus.rdata) |
                         MuxOR(data.io.out.bits.suncd, io.ubus.rdata))

  // pass-through
  io.rd.valid := rvalid && data.io.out.bits.iload
  io.rd.bits.addr  := data.io.out.bits.index
  io.rd.bits.data  := rdata

  assert(!ctrl.io.out.valid || PopCount(Cat(ctrl.io.out.bits.sldst, ctrl.io.out.bits.vldst, ctrl.io.out.bits.suncd)) <= 1.U)
  assert(!data.io.out.valid || PopCount(Cat(data.io.out.bits.sldst, data.io.out.bits.suncd)) <= 1.U)
}
