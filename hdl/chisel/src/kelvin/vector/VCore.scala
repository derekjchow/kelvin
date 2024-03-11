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

package kelvin

import chisel3._
import chisel3.util._

import bus._
import common._

object VCore {
  def apply(p: Parameters): VCore = {
    return Module(new VCore(p))
  }
}

class VCoreIO(p: Parameters) extends Bundle {
  // Decode cycle.
  val vinst = Vec(p.instructionLanes, Flipped(Decoupled(new VInstCmd)))

  // Execute cycle.
  val rs = Vec(p.instructionLanes * 2, Flipped(new RegfileReadDataIO))
  val rd = Vec(p.instructionLanes, Flipped(new RegfileWriteDataIO))

  // Status.
  val mactive = Output(Bool())

  // Faults.
  val undef = Output(Bool())

  val vrfwriteCount = Output(UInt(3.W))
  val vstoreCount = Output(UInt(2.W))
}

class VCore(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Score <> VCore
    val score = new VCoreIO(p)

    // Data bus interface.
    val dbus = new DBusIO(p)
    val last = Output(Bool())

    // AXI interface.
    val ld = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val st = new AxiMasterWriteIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })

  // Decode    : VInst.in
  // Execute+0 : VInst.slice
  // Execute+1 : VInst.out <> VDec::Fifo.in
  // Execute+2 : VDec::Fifo.out <> VDec::Shuffle.in
  // Execute+3 : VDec::Shuffle.out <> VCmdq::Fifo.in
  // Execute+4 : VCmdq::Fifo.out <> VCmdq::Reg.in
  // Execute+5 : VCmdq::Reg.out <> {VLdSt, VAlu, ...}

  val vinst  = VInst(p)
  val vdec   = VDecode(p)
  val valu   = VAlu(p)
  val vconv  = VConvCtrl(p)
  val vldst  = VLdSt(p)
  val vld    = VLd(p)
  val vst    = VSt(p)
  val vrf    = VRegfile(p)

  io.score.vrfwriteCount := vrf.io.vrfwriteCount
  io.score.vstoreCount := vst.io.vstoreCount + vldst.io.vstoreCount

  vinst.io.in <> io.score.vinst
  vinst.io.rs <> io.score.rs
  vinst.io.rd <> io.score.rd

  assert(PopCount(Cat(vst.io.read.valid && vst.io.read.ready,
                      vldst.io.read.valid && vldst.io.read.ready)) <= 1.U)

  // ---------------------------------------------------------------------------
  // VDecode.
  vdec.io.vrfsb <> vrf.io.vrfsb

  vdec.io.active := valu.io.active | vconv.io.active | vldst.io.active | vst.io.active

  vdec.io.in.valid := vinst.io.out.valid
  vinst.io.out.ready := vdec.io.in.ready
  assert(!(vdec.io.in.valid && !vdec.io.in.ready))

  vinst.io.out.stall := vdec.io.stall  // decode backpressure

  for (i <- 0 until p.instructionLanes) {
    vdec.io.in.bits(i) := vinst.io.out.lane(i)
  }

  io.score.undef := vdec.io.undef

  // ---------------------------------------------------------------------------
  // VRegfile.
  for (i <- 0 until vrf.readPorts) {
    vrf.io.read(i).valid := false.B
    vrf.io.read(i).addr := 0.U
    vrf.io.read(i).tag := 0.U
  }

  for (i <- 0 until vrf.writePorts) {
    vrf.io.write(i).valid := false.B
    vrf.io.write(i).addr := 0.U
    vrf.io.write(i).data := 0.U
  }

  for (i <- 0 until vrf.whintPorts) {
    vrf.io.whint(i).valid := false.B
    vrf.io.whint(i).addr := 0.U
  }

  for (i <- 0 until vrf.scalarPorts) {
    vrf.io.scalar(i).valid := false.B
    vrf.io.scalar(i).data := 0.U
  }

  vrf.io.transpose.valid := false.B
  vrf.io.transpose.index := 0.U
  vrf.io.transpose.addr  := 0.U

  // ---------------------------------------------------------------------------
  // VALU.
  val aluvalid = (0 until p.instructionLanes).map(x => vdec.io.out(x).valid && vdec.io.cmdq(x).alu)
  val aluready = (0 until p.instructionLanes).map(x => valu.io.in.ready && vdec.io.cmdq(x).alu)

  valu.io.in.valid := aluvalid.reduce(_ || _)

  for (i <- 0 until p.instructionLanes) {
    valu.io.in.bits(i).valid := aluvalid(i)
    valu.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  for (i <- 0 until vrf.readPorts) {
    vrf.io.read(i).valid := valu.io.read(i).valid
    vrf.io.read(i).addr := valu.io.read(i).addr
    vrf.io.read(i).tag  := valu.io.read(i).tag
  }

  for (i <- 0 until vrf.readPorts) {
    valu.io.read(i).data := vrf.io.read(i).data
  }

  for (i <- 0 until vrf.writePorts - 2) {
    vrf.io.write(i).valid := valu.io.write(i).valid
    vrf.io.write(i).addr := valu.io.write(i).addr
    vrf.io.write(i).data := valu.io.write(i).data
  }

  for (i <- 0 until vrf.whintPorts) {
    vrf.io.whint(i).valid := valu.io.whint(i).valid
    vrf.io.whint(i).addr := valu.io.whint(i).addr
  }

  for (i <- 0 until vrf.scalarPorts) {
    vrf.io.scalar(i).valid := valu.io.scalar(i).valid
    vrf.io.scalar(i).data := valu.io.scalar(i).data
  }

  valu.io.vrfsb := vrf.io.vrfsb.data

  // ---------------------------------------------------------------------------
  // VCONV.
  val convvalid = (0 until p.instructionLanes).map(x => vdec.io.out(x).valid && vdec.io.cmdq(x).conv)
  val convready = (0 until p.instructionLanes).map(x => vconv.io.in.ready && vdec.io.cmdq(x).conv)

  vconv.io.in.valid := convvalid.reduce(_ || _)

  for (i <- 0 until p.instructionLanes) {
    vconv.io.in.bits(i).valid := convvalid(i)
    vconv.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  vrf.io.conv := vconv.io.out

  vconv.io.vrfsb := vrf.io.vrfsb.data

  // ---------------------------------------------------------------------------
  // VLdSt.
  val ldstvalid = (0 until p.instructionLanes).map(x => vdec.io.out(x).valid && vdec.io.cmdq(x).ldst)
  val ldstready = (0 until p.instructionLanes).map(x => vldst.io.in.ready && vdec.io.cmdq(x).ldst)

  vldst.io.in.valid := ldstvalid.reduce(_ || _)

  for (i <- 0 until p.instructionLanes) {
    vldst.io.in.bits(i).valid := ldstvalid(i)
    vldst.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  vldst.io.read.ready := !vst.io.read.valid
  vldst.io.read.data := vrf.io.read(vrf.readPorts - 1).data

  vldst.io.vrfsb := vrf.io.vrfsb.data

  io.dbus <> vldst.io.dbus
  io.last := vldst.io.last

  // ---------------------------------------------------------------------------
  // VLd.
  val ldvalid = (0 until p.instructionLanes).map(x => vdec.io.cmdq(x).ld && vdec.io.out(x).valid)
  val ldready = (0 until p.instructionLanes).map(x => vdec.io.cmdq(x).ld && vld.io.in.ready)

  vld.io.in.valid := ldvalid.reduce(_ || _)

  for (i <- 0 until p.instructionLanes) {
    vld.io.in.bits(i).valid := ldvalid(i)
    vld.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  io.ld <> vld.io.axi

  // ---------------------------------------------------------------------------
  // VSt.
  val stvalid = (0 until p.instructionLanes).map(x => vdec.io.out(x).valid && vdec.io.cmdq(x).st)
  val stready = (0 until p.instructionLanes).map(x => vst.io.in.ready && vdec.io.cmdq(x).st)

  vst.io.in.valid := stvalid.reduce(_ || _)

  for (i <- 0 until p.instructionLanes) {
    vst.io.in.bits(i).valid := stvalid(i)
    vst.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  io.st <> vst.io.axi

  vst.io.vrfsb := vrf.io.vrfsb.data

  vst.io.read.ready := true.B
  vst.io.read.data := vrf.io.read(vrf.readPorts - 1).data

  // ---------------------------------------------------------------------------
  // Load write.
  vrf.io.write(vrf.readPorts - 3).valid := vldst.io.write.valid
  vrf.io.write(vrf.readPorts - 3).addr := vldst.io.write.addr
  vrf.io.write(vrf.readPorts - 3).data := vldst.io.write.data

  vrf.io.write(vrf.readPorts - 2).valid := vld.io.write.valid
  vrf.io.write(vrf.readPorts - 2).addr := vld.io.write.addr
  vrf.io.write(vrf.readPorts - 2).data := vld.io.write.data

  // ---------------------------------------------------------------------------
  // Store read.
  vrf.io.read(vrf.readPorts - 1).valid := vst.io.read.valid || vldst.io.read.valid
  vrf.io.read(vrf.readPorts - 1).addr := Mux(vst.io.read.valid, vst.io.read.addr,
                             vldst.io.read.addr)
  vrf.io.read(vrf.readPorts - 1).tag := Mux(vst.io.read.valid, vst.io.read.tag,
                            vldst.io.read.tag)

  // ---------------------------------------------------------------------------
  // VDecode.
  for (i <- 0 until p.instructionLanes) {
    vdec.io.out(i).ready := aluready(i) || convready(i) || ldstready(i) ||
                            ldready(i) || stready(i)
  }

  // ---------------------------------------------------------------------------
  // Memory active status.
  io.score.mactive := vinst.io.nempty || vdec.io.nempty ||
                      vld.io.nempty || vst.io.nempty
}

