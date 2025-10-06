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
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

class VRegfileSegment(p: Parameters) extends Module {
  val readPorts = p.vectorReadPorts
  val writePorts = p.vectorWritePorts
  val tcnt = 16.min(p.vectorBits / 32)

  val io = IO(new Bundle {
    val read = Vec(readPorts, new Bundle {
      val addr = Input(UInt(6.W))
      val data = Output(UInt(32.W))
    })

    val transpose = new Bundle {
      val addr = Input(UInt(6.W))
      val data = Output(UInt((tcnt * 32).W))
    }

    val internal = new Bundle {
      val addr = Input(UInt(6.W))
      val data = Output(UInt(32.W))
    }

    val write = Vec(writePorts, new Bundle {
      val valid = Input(Bool())
      val addr = Input(UInt(6.W))
      val data = Input(UInt(32.W))
    })

    val conv = new Bundle {
      val valid = Input(Bool())
      val data = Input(Vec(tcnt, UInt(32.W)))
    }
  })

  // Do not use a memory object, this breaks the synthesis.
  //  eg. val vreg = Mem(64, UInt(32.W))
  val vreg = Reg(Vec(64, UInt(32.W)))

  // ---------------------------------------------------------------------------
  // Read.
  for (i <- 0 until readPorts) {
    val ridx = io.read(i).addr
    io.read(i).data := VecAt(vreg, ridx)
  }

  // ---------------------------------------------------------------------------
  // Transpose.
  val tdata = Wire(Vec(tcnt, UInt(32.W)))
  for (i <- 0 until tcnt) {
    val tidx = Cat(io.transpose.addr(5,4), i.U(4.W))  // only supports [v0, v16, v32, v48].
    assert(tidx.getWidth == 6)
    tdata(i) := VecAt(vreg, tidx)
  }
  io.transpose.data := tdata.asUInt
  assert(io.transpose.addr(3,0) === 0.U)

  // ---------------------------------------------------------------------------
  // Internal.
  io.internal.data := VecAt(vreg, io.internal.addr)

  // ---------------------------------------------------------------------------
  // Write.
  for (i <- 0 until 64) {
    val wvalidBits = Wire(Vec(writePorts, Bool()))
    val wdataBits = Wire(Vec(writePorts, UInt(32.W)))
    assert(PopCount(wvalidBits.asUInt) <= 1.U)

    for (j <- 0 until writePorts) {
      wvalidBits(j) := io.write(j).valid && io.write(j).addr === i.U
      wdataBits(j) := MuxOR(wvalidBits(j), io.write(j).data)
    }

    val wvalid = VecOR(wvalidBits, writePorts)
    val wdata = VecOR(wdataBits, writePorts)

    when (wvalid) {
      vreg(i) := wdata
    }
  }

  // ---------------------------------------------------------------------------
  // Convolution parallel load interface.
  // Data has been transposed in VRegfile.
  //  [48, 49, 50, ...] = data
  when (io.conv.valid) {
    for (i <- 0 until tcnt) {
      vreg(i + 48) := io.conv.data(i)
    }
  }

  for (i <- 0 until writePorts) {
    assert(!(io.conv.valid && io.write(i).valid && io.write(i).addr >= 48.U))
  }
}

@nowarn
object EmitVRegfileSegment extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VRegfileSegment(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
