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

object VCore {
  def apply(p: Parameters): VCore = {
    return Module(new VCore(p))
  }
}

class VCore(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Score <> VCore
    val score = new VCoreIO(p)

    // Data bus interface.
    val dbus = new DBusIO(p)
    val last = Output(Bool())
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
  val vrf    = VRegfile(p)

  io.score.vrfwriteCount := vrf.io.vrfwriteCount
  io.score.vstoreCount := vldst.io.vstoreCount

  vinst.io.in <> io.score.vinst
  vinst.io.rs <> io.score.rs
  vinst.io.rd <> io.score.rd

  assert(PopCount(Cat(vldst.io.read.valid && vldst.io.read.ready)) <= 1.U)

  // ---------------------------------------------------------------------------
  // VDecode.
  vdec.io.vrfsb <> vrf.io.vrfsb

  vdec.io.active := valu.io.active | vconv.io.active | vldst.io.active

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
  for (i <- 0 until vrf.writePorts) {
    vrf.io.write(i).valid := false.B
    vrf.io.write(i).addr := 0.U
    vrf.io.write(i).data := 0.U
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

  vrf.io.read <> valu.io.read
  for (i <- 0 until vrf.writePorts - 2) {
    vrf.io.write(i) := valu.io.write(i)
  }

  vrf.io.whint := valu.io.whint
  vrf.io.scalar := valu.io.scalar

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

  vldst.io.read.ready := true.B
  vldst.io.read.data := vrf.io.read(vrf.readPorts - 1).data

  vldst.io.vrfsb := vrf.io.vrfsb.data

  io.dbus <> vldst.io.dbus
  io.last := vldst.io.last


  // ---------------------------------------------------------------------------
  // Load write.
  vrf.io.write(vrf.readPorts - 3) := vldst.io.write

  // ---------------------------------------------------------------------------
  // Store read.
  vrf.io.read(vrf.readPorts - 1).valid := vldst.io.read.valid
  vrf.io.read(vrf.readPorts - 1).addr := vldst.io.read.addr
  vrf.io.read(vrf.readPorts - 1).tag := vldst.io.read.tag

  // ---------------------------------------------------------------------------
  // VDecode.
  for (i <- 0 until p.instructionLanes) {
    vdec.io.out(i).ready := aluready(i) || convready(i) || ldstready(i)
  }

  // ---------------------------------------------------------------------------
  // Memory active status.
  io.score.mactive := vinst.io.nempty || vdec.io.nempty
}

