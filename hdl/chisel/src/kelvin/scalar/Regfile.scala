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

// Regfile: 32 entry scalar register file with 8 read ports and 6
// write ports. Houses a global scoreboard that informs of interlock
// deps inside the decoders.

package kelvin

import chisel3._
import chisel3.util._
import common._
import _root_.circt.stage.ChiselStage

object Regfile {
  def apply(p: Parameters): Regfile = {
    return Module(new Regfile(p))
  }
}

class RegfileReadAddrIO extends Bundle {
  val valid = Input(Bool())
  val addr  = Input(UInt(5.W))
}

class RegfileReadSetIO extends Bundle {
  val valid = Input(Bool())
  val value = Input(UInt(32.W))
}

class RegfileReadDataIO extends Bundle {
  val valid = Output(Bool())
  val data  = Output(UInt(32.W))
}

class RegfileWriteAddrIO extends Bundle {
  val valid = Input(Bool())
  val addr  = Input(UInt(5.W))
}

class RegfileWriteDataIO extends Bundle {
  val valid = Input(Bool())
  val addr  = Input(UInt(5.W))
  val data  = Input(UInt(32.W))
}

class RegfileBusAddrIO extends Bundle {
  val valid = Input(Bool())
  val bypass = Input(Bool())
  val immen = Input(Bool())
  val immed = Input(UInt(32.W))
}

class RegfileBusPortIO extends Bundle {
  val addr = Output(Vec(4, UInt(32.W)))
  val data = Output(Vec(4, UInt(32.W)))
}

class RegfileLinkPortIO extends Bundle {
  val valid = Output(Bool())
  val value = Output(UInt(32.W))
}

class RegfileBranchTargetIO extends Bundle {
  val data = Output(UInt(32.W))
}

class Regfile(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val readAddr = Vec(8, new RegfileReadAddrIO)
    val readSet  = Vec(8, new RegfileReadSetIO)
    val writeAddr = Vec(4, new RegfileWriteAddrIO)
    val busAddr = Vec(4, new RegfileBusAddrIO)
    val target = Vec(4, new RegfileBranchTargetIO)
    val linkPort = new RegfileLinkPortIO
    val busPort = new RegfileBusPortIO

    // Execute cycle.
    val readData = Vec(8, new RegfileReadDataIO)
    val writeData = Vec(6, new RegfileWriteDataIO)
    val writeMask = Vec(4, new Bundle {val valid = Input(Bool())})
    val scoreboard = new Bundle {
      val regd = Output(UInt(32.W))
      val comb = Output(UInt(32.W))
    }

    val rfwriteCount = Output(UInt(6.W))
  })


  // The scalar registers.
  val regfile = Reg(Vec(32, UInt(32.W)))

  // ***************************************************************************
  // The scoreboard.
  // ***************************************************************************
  val scoreboard = RegInit(0.U(32.W))

  // The write Addr:Data contract is against speculated opcodes. If an opcode
  // is in the shadow of a taken branch it will still Set:Clr the scoreboard,
  // but the actual write will be Masked.
  val scoreboard_set = io.writeAddr
      .map(x => MuxOR(x.valid, UIntToOH(x.addr, 32))).reduce(_|_)

  val scoreboard_clr0 = io.writeData
      .map(x => MuxOR(x.valid, UIntToOH(x.addr, 32))).reduce(_|_)

  val scoreboard_clr = Cat(scoreboard_clr0(31,1), 0.U(1.W))

  when (scoreboard_set =/= 0.U || scoreboard_clr =/= 0.U) {
    val nxtScoreboard = (scoreboard & ~scoreboard_clr) | scoreboard_set
    scoreboard := Cat(nxtScoreboard(31,1), 0.U(1.W))
  }

  io.scoreboard.regd := scoreboard
  io.scoreboard.comb := scoreboard & ~scoreboard_clr

  // ***************************************************************************
  // The read port response.
  // ***************************************************************************
  val readDataReady = RegInit(VecInit(Seq.fill(8){false.B}))
  val readDataBits  = Reg(Vec(8, UInt(32.W)))
  val nxtReadDataBits = Wire(Vec(8, UInt(32.W)))

  for (i <- 0 until 8) {
    io.readData(i).valid := readDataReady(i)
    io.readData(i).data  := readDataBits(i)
  }

  // ***************************************************************************
  // One hot write ports.
  // ***************************************************************************
  val writeValid = Wire(Vec(32, Bool()))
  val writeData  = Wire(Vec(32, UInt(32.W)))

  writeValid(0) := true.B  // do not require special casing of indices
  writeData(0)  := 0.U     // regfile(0) is optimized away

  for (i <- 1 until 32) {
    val valid = Cat(io.writeData(5).valid && io.writeData(5).addr === i.U,
                    io.writeData(4).valid && io.writeData(4).addr === i.U,
                    io.writeData(3).valid && io.writeData(3).addr === i.U &&
                      !io.writeMask(3).valid,
                    io.writeData(2).valid && io.writeData(2).addr === i.U &&
                      !io.writeMask(2).valid,
                    io.writeData(1).valid && io.writeData(1).addr === i.U &&
                      !io.writeMask(1).valid,
                    io.writeData(0).valid && io.writeData(0).addr === i.U &&
                      !io.writeMask(0).valid)

    val data  = MuxOR(valid(0), io.writeData(0).data) |
                MuxOR(valid(1), io.writeData(1).data) |
                MuxOR(valid(2), io.writeData(2).data) |
                MuxOR(valid(3), io.writeData(3).data) |
                MuxOR(valid(4), io.writeData(4).data) |
                MuxOR(valid(5), io.writeData(5).data)

    writeValid(i) := valid =/= 0.U
    writeData(i)  := data

    assert(PopCount(valid) <= 1.U)
  }

  for (i <- 0 until 32) {
    when (writeValid(i)) {
      regfile(i) := writeData(i)
    }
  }

  // We care if someone tried to write x0 (e.g. nop is encoded this way), but want
  // it separate for above mentioned optimization.
  val x0 =
    (0 until 4).map(x =>
      io.writeData(x).valid &&
      io.writeData(x).addr === 0.U &&
      !io.writeMask(x).valid) ++
    (4 until 6).map(x => io.writeData(x).valid && io.writeData(x).addr === 0.U)

  io.rfwriteCount := PopCount(writeValid) - writeValid(0) + PopCount(x0)

  // ***************************************************************************
  // Read ports with write forwarding.
  // ***************************************************************************
  val rdata = Wire(Vec(8, UInt(32.W)))
  val wdata = Wire(Vec(8, UInt(32.W)))
  val rwdata = Wire(Vec(8, UInt(32.W)))
  for (i <- 0 until 8) {
    val idx = io.readAddr(i).addr
    val write = VecAt(writeValid, idx)
    rdata(i) := VecAt(regfile, idx)
    wdata(i) := VecAt(writeData, idx)
    rwdata(i) := Mux(write, wdata(i), rdata(i))
  }

  for (i <- 0 until 8) {
    val setValid = io.readSet(i).valid
    val setValue = io.readSet(i).value

    val nxtReadDataReady = io.readAddr(i).valid || setValid

    readDataReady(i) := nxtReadDataReady

    nxtReadDataBits(i) := Mux(setValid, setValue, rwdata(i))

    when (nxtReadDataReady) {
      readDataBits(i) := nxtReadDataBits(i)
    }
  }

  // Bus port priority encoded address.
  val busAddr = Wire(Vec(4, UInt(32.W)))
  val busValid = Cat(io.busAddr(3).valid, io.busAddr(2).valid,
                     io.busAddr(1).valid, io.busAddr(0).valid)

  for (i <- 0 until 4) {
    busAddr(i) := Mux(io.busAddr(i).bypass, rwdata(2 * i),
                  Mux(io.busAddr(i).immen, rdata(2 * i) + io.busAddr(i).immed,
                      rdata(2 * i)))
  }

  for (i <- 0 until 4) {
    io.busPort.addr(i) := busAddr(i)
    io.busPort.data(i) := nxtReadDataBits(2 * i + 1)
  }

  // Branch target address combinatorial.
  for (i <- 0 until 4) {
    io.target(i).data := busAddr(i)
  }

  // ***************************************************************************
  // Link port.
  // ***************************************************************************
  io.linkPort.valid := !scoreboard(1)
  io.linkPort.value := regfile(1)

  // ***************************************************************************
  // Assertions.
  // ***************************************************************************
  for (i <- 0 until 4) {
    assert(busAddr(i).getWidth == p.lsuAddrBits)
  }

  for (i <- 0 until 6) {
    for (j <- (i+1) until 6) {
      // Delay the failure a cycle for debugging purposes.
      val write_fail = RegInit(false.B)
      write_fail := io.writeData(i).valid && io.writeData(j).valid &&
                    io.writeData(i).addr === io.writeData(j).addr &&
                    io.writeData(i).addr =/= 0.U
      assert(!write_fail)
    }
  }

  val scoreboard_error = RegInit(false.B)
  scoreboard_error := (scoreboard & scoreboard_clr) =/= scoreboard_clr
  assert(!scoreboard_error)
}

object EmitRegfile extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new Regfile(p), args)
}
