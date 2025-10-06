/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package coralnpu

import chisel3._
import chisel3.util._
import common._
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

object VLdSt {
  def apply(p: Parameters): VLdSt = {
    return Module(new VLdSt(p))
  }
}

class VLdSt(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Instructions.
    val in = Flipped(Decoupled(Vec(p.instructionLanes, Valid(new VDecodeBits))))
    val active = Output(UInt(64.W))

    // VRegfile.
    val vrfsb = Input(UInt(128.W))
    val read  = new VRegfileReadHsIO(p)
    val write = new VRegfileWriteIO(p)

    // Bus.
    val dbus = new DBusIO(p)
    val last = Output(Bool())

    val vstoreCount = Output(UInt(1.W))
  })


  // A usable amount of outstanding transactions.
  val cmdqDepth = 8

  // The minimum depth to cover pipeline delays in this unit.
  val dbusDepth = 3

  val maxvlb  = (p.vectorBits / 8).U(p.vectorCountBits.W)
  val maxvlbm = (p.vectorBits * 4 / 8).U(p.vectorCountBits.W)

  val bytes = p.lsuDataBits / 8

  val e = new VEncodeOp()

  // ---------------------------------------------------------------------------
  // Swizzle datapath.
  def Swizzle(positive: Boolean, size: Int, addr: UInt, data: UInt): UInt = {
    val msb = log2Ceil(bytes) - 1
    val datain = Wire(Vec(bytes, UInt(size.W)))
    val dataout = Wire(Vec(bytes, UInt(size.W)))

    for (i <- 0 until bytes) {
      datain(i) := data(size * i + (size - 1), size * i)
    }

    val index = addr(msb, 0)
    for (i <- 0 until bytes) {
      val idx = if (positive) i.U + index else i.U - index
      dataout(i) := VecAt(datain, idx)
      assert(idx.getWidth == (msb + 1))
    }

    dataout.asUInt
  }

  // ---------------------------------------------------------------------------
  // Command Queue.
  class VLdStCmdq extends Bundle {
    val op = UInt(new VEncodeOp().bits.W)
    val f2 = UInt(3.W)
    val sz = UInt(3.W)
    val addr = UInt(32.W)
    val offset = UInt(32.W)
    val remain = UInt(p.vectorCountBits.W)
    val vd = new VAddr()
    val vs = new VAddrTag()
    val quad = UInt(2.W)  // vstq position
    val last = Bool()

    def IsLoad(): Bool = {
      op === e.vld.U
    }

    def IsStore(): Bool = {
      op === e.vst.U || op === e.vstq.U
    }
  }

  def Fin(in: VDecodeBits): VLdStCmdq = {
    val out = Wire(new VLdStCmdq)
    val stride = in.f2(1)
    val length = in.f2(0)
    assert(PopCount(in.sz) <= 1.U)
    assert(!(in.op === e.vst.U  && ( in.vd.valid || !in.vs.valid)))
    assert(!(in.op === e.vstq.U && ( in.vd.valid || !in.vs.valid)))
    assert(!(in.op === e.vld.U  && (!in.vd.valid ||  in.vs.valid)))

    val limit = Mux(in.m, maxvlbm, maxvlb)

    val data = MuxOR(in.sz(0), in.sv.data) |
               MuxOR(in.sz(1), Cat(in.sv.data, 0.U(1.W))) |
               MuxOR(in.sz(2), Cat(in.sv.data, 0.U(2.W)))

    val remain0 = maxvlbm
    val remain1 = Mux(data > limit, limit, data)(p.vectorCountBits - 1, 0)
    assert(remain0.getWidth == p.vectorCountBits)
    assert(remain1.getWidth == p.vectorCountBits)

    out.op := in.op
    out.f2 := in.f2
    out.sz := in.sz
    out.addr := in.sv.addr
    out.offset := Mux(stride, data(31,0), Mux(in.op === e.vstq.U, maxvlb >> 2, maxvlb))
    out.remain := Mux(length, remain1, remain0)
    out.vd := in.vd
    out.vs := in.vs
    out.last := !in.m && in.op =/= e.vstq.U

    out.quad := 0.U

    out
  }

  def Fout(in: VLdStCmdq, m: Bool, step: UInt, valid: Bool): (VLdStCmdq, Bool) = {
    assert(!valid || in.op === e.vld.U || in.op === e.vst.U || in.op === e.vstq.U)

    val out = Wire(new VLdStCmdq)
    val vstq = in.op === e.vstq.U

    val fmaxvlb = Mux(in.op === e.vstq.U, maxvlb >> 2, maxvlb)

    val outlast1 = !m || step === 2.U  // registered a cycle before 'last' usage
    val outlast2 = Mux(m, step === 14.U, step === 2.U)
    val outlast = Mux(vstq, outlast2, outlast1)

    val last1 = !m || step === 3.U
    val last2 = Mux(m, step === 15.U, step === 3.U)
    val last = Mux(vstq, last2, last1)

    out := in

    out.vd.addr := Mux(vstq && step(1,0) =/= 3.U, in.vd.addr, in.vd.addr + 1.U)
    out.vs.addr := Mux(vstq && step(1,0) =/= 3.U, in.vs.addr, in.vs.addr + 1.U)

    out.addr   := in.addr + in.offset
    out.remain := Mux(in.remain <= fmaxvlb, 0.U, in.remain - fmaxvlb)

    out.last := outlast

    out.quad := Mux(in.op === e.vstq.U, step + 1.U, 0.U)

    (out, last)
  }

  def Factive(in: VLdStCmdq, m: Bool, step: UInt): UInt = {
    assert(step.getWidth == 5)
    val vstq = in.op === e.vstq.U
    val stepq = Mux(vstq, step(4,2), step(2,0))
    // Only reads are reported in active, vrfsb tracks writes.
    val active = MuxOR(in.vs.valid, RegActive(m, stepq, in.vs.addr))
    assert(active.getWidth == 64)
    active
  }

  val q = VCmdq(p, cmdqDepth, new VLdStCmdq, Fin, Fout, Factive)

  q.io.in <> io.in

  val ctrlready = Wire(Bool())
  q.io.out.ready := ScoreboardReady(q.io.out.bits.vs, io.vrfsb) && ctrlready

  // ---------------------------------------------------------------------------
  // Read register.
  io.read.valid := q.io.out.valid && q.io.out.bits.vs.valid
  io.read.stall := !q.io.out.ready  // testbench signal
  io.read.addr := q.io.out.bits.vs.addr
  io.read.tag := OutTag(q.io.out.bits.vs)

  // ---------------------------------------------------------------------------
  // DBus.
  class DBusCtrl extends Bundle {
    val last = Bool()
    val write = Bool()
    val addr = UInt(p.lsuAddrBits.W)
    val adrx = UInt(p.lsuAddrBits.W)
    val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
    val widx = UInt(6.W)
  }

  class DBusWData extends Bundle {
    val wdata = UInt(p.lsuDataBits.W)
    val wmask = UInt((p.lsuDataBits / 8).W)
  }

  class RegWrite extends Bundle {
    val widx = UInt(6.W)
    val addr = UInt(log2Ceil(bytes).W)  // bus address
    val size = UInt((log2Ceil(p.lsuDataBits / 8) + 1).W)
  }

  val lineoffset = (p.lsuDataBits / 8)

  // Combinatorial paths back to command queue are to be avoided.
  val ctrl = Fifo(new DBusCtrl, dbusDepth)
  val data = Fifo(new DBusWData, dbusDepth)
  val rdataEn = RegInit(false.B)
  val rdataSize = Reg(UInt(p.vectorCountBits.W))
  val rdataAddr = Reg(UInt(log2Ceil(bytes).W))
  val rdataAshf = Reg(UInt(log2Ceil(bytes).W))

  ctrlready := ctrl.io.in.ready && (io.read.ready || !ctrl.io.in.bits.write)

  val qoutEn = q.io.out.valid && q.io.out.ready
  val rdataEnNxt = qoutEn && ctrl.io.in.bits.write

  val qmaxvlb = Mux(q.io.out.bits.op === e.vstq.U, maxvlb >> 2.U, maxvlb)
  val qsize = Mux(q.io.out.bits.remain > qmaxvlb, qmaxvlb, q.io.out.bits.remain)
  val rdataWmask = Wire(Vec(p.lsuDataBits / 8, Bool()))

  when (rdataEnNxt) {
    val quad = q.io.out.bits.quad(1,0)
    rdataSize := qsize
    rdataAddr := q.io.out.bits.addr
    rdataAshf := q.io.out.bits.addr - (quad * (maxvlb >> 2.U))
  }

  for (i <- 0 until p.lsuDataBits / 8) {
    rdataWmask(i) := rdataSize > i.U
  }

  rdataEn := rdataEnNxt
  ctrl.io.in.valid := qoutEn

  ctrl.io.in.bits.addr  := q.io.out.bits.addr
  ctrl.io.in.bits.adrx  := q.io.out.bits.addr + lineoffset.U
  ctrl.io.in.bits.size  := qsize
  ctrl.io.in.bits.last  := q.io.out.bits.last
  ctrl.io.in.bits.write := q.io.out.bits.IsStore()
  ctrl.io.in.bits.widx  := q.io.out.bits.vd.addr
  assert(!(ctrl.io.in.valid && !ctrl.io.in.ready))
  io.vstoreCount := ctrl.io.in.valid && ctrl.io.in.ready;

  data.io.in.valid := rdataEn
  data.io.in.bits.wdata := Swizzle(false, 8, rdataAshf, io.read.data)
  data.io.in.bits.wmask := Swizzle(false, 1, rdataAddr, rdataWmask.asUInt)
  assert(!(data.io.in.valid && !data.io.in.ready))

  ctrl.io.out.ready := io.dbus.ready && (data.io.out.valid || !ctrl.io.out.bits.write)
  data.io.out.ready := io.dbus.ready && (ctrl.io.out.valid &&  ctrl.io.out.bits.write)
  assert(!(data.io.out.valid && !ctrl.io.out.valid))

  io.dbus.valid := ctrl.io.out.valid && (data.io.out.valid || !ctrl.io.out.bits.write)
  io.dbus.write := ctrl.io.out.bits.write
  io.dbus.addr := Cat(0.U(1.W), ctrl.io.out.bits.addr(30,0))
  io.dbus.adrx := Cat(0.U(1.W), ctrl.io.out.bits.adrx(30,0))
  io.dbus.size := ctrl.io.out.bits.size
  io.dbus.wdata := data.io.out.bits.wdata
  io.dbus.wmask := data.io.out.bits.wmask
  io.dbus.pc := 0.U.asTypeOf(io.dbus.pc)
  assert(!(ctrl.io.out.valid && ctrl.io.out.bits.addr(31)))
  assert(!(ctrl.io.out.valid && ctrl.io.out.bits.adrx(31)))
  assert(!(io.dbus.valid && io.dbus.addr(31)))
  assert(!(io.dbus.valid && io.dbus.adrx(31)))

  io.last := ctrl.io.out.bits.last

  // ---------------------------------------------------------------------------
  // Write register.
  val wrega = Slice(new RegWrite, true, true)
  val wregd = Slice(UInt(p.vectorBits.W), false, true)
  val wdataEn = RegInit(false.B)

  wdataEn := io.dbus.valid && io.dbus.ready && !io.dbus.write

  wrega.io.in.valid := ctrl.io.out.valid && io.dbus.ready && !ctrl.io.out.bits.write
  wrega.io.in.bits.widx := ctrl.io.out.bits.widx
  wrega.io.in.bits.addr := ctrl.io.out.bits.addr
  wrega.io.in.bits.size := ctrl.io.out.bits.size
  wrega.io.out.ready := wregd.io.out.valid
  assert(!(wrega.io.in.valid && !wrega.io.in.ready))

  wregd.io.in.valid := wdataEn
  wregd.io.in.bits := io.dbus.rdata
  wregd.io.out.ready := wrega.io.out.valid
  assert(!(wregd.io.in.valid && !wregd.io.in.ready))

  val maskb = Wire(Vec(p.vectorBits / 8, UInt(8.W)))
  val mask = maskb.asUInt

  for (i <- 0 until p.vectorBits / 8) {
    maskb(i) := MuxOR(i.U < wrega.io.out.bits.size, 0xff.U)
  }

  io.write.valid := wrega.io.out.valid && wregd.io.out.valid
  io.write.addr := wrega.io.out.bits.widx
  io.write.data := Swizzle(true, 8, wrega.io.out.bits.addr, wregd.io.out.bits) & mask

  // ---------------------------------------------------------------------------
  // Active.
  io.active := q.io.active
}

@nowarn
object EmitVLdSt extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VLdSt(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
