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

object VRegfile {
  def apply(p: Parameters): VRegfile = {
    return Module(new VRegfile(p))
  }
}

class VRegfileReadIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(6.W))
  val tag  = Output(UInt(1.W))
  val data = Input(UInt(p.vectorBits.W))
}

class VRegfileReadHsIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())   // handshake
  val stall = Output(Bool())  // Testbench signal.
  val addr = Output(UInt(6.W))
  val tag  = Output(UInt(1.W))
  val data = Input(UInt(p.vectorBits.W))
}

class VRegfileScalarIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val data = Output(UInt(32.W))
}

class VRegfileTransposeIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val tcnt = 16.min(p.vectorBits / 32)
  val addr = Output(UInt(6.W))
  val index = Output(UInt(log2Ceil(tcnt).W))
  val data = Input(UInt((tcnt * 32).W))
}

class VRegfileWrite(p: Parameters) extends Bundle {
  val addr = UInt(6.W)
  val data = UInt(p.vectorBits.W)
}

class VRegfileWriteIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(6.W))
  val data = Output(UInt(p.vectorBits.W))
}

class VRegfileWriteHsIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())  // handshake used in arbitration logic
  val addr = Output(UInt(6.W))
  val data = Output(UInt(p.vectorBits.W))
}

// Write internal.
class VRegfileWrintIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(6.W))
  val data = Output(UInt(p.vectorBits.W))
}

// Write internal.
class VRegfileWhintIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(6.W))
}

class VRegfileConvIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())     // registered signal suitable for mux control
  val ready = Output(Bool())     // combinatoral from scheduling logic
  val op = new Bundle {
    val conv = Output(Bool())  // convolution to accum
    val init = Output(Bool())  // set accum
    val tran = Output(Bool())  // transpose to accum
    val wclr = Output(Bool())  // write accum to vreg and clear accum
  }
  val addr1 = Output(UInt(6.W))  // narrow: transpose
  val addr2 = Output(UInt(6.W))  // wide:   internal
  val mode  = Output(UInt(2.W))
  val index = Output(UInt(log2Ceil(p.vectorBits / 32).W))
  val abias = Output(UInt(9.W))
  val bbias = Output(UInt(9.W))
  val asign = Output(Bool())
  val bsign = Output(Bool())
}

class VRegfileScoreboardIO extends Bundle {
  // 64 registers sequenced from even/odd tags.
  val set  = Valid(UInt(128.W))
  val data = Input(UInt(128.W))
}

class VRegfile(p: Parameters) extends Module {
  val readPorts = p.vectorReadPorts
  val scalarPorts = p.vectorScalarPorts
  val writePorts = p.vectorWritePorts
  val whintPorts = p.vectorWhintPorts

  val io = IO(new Bundle {
    val read = Vec(readPorts, Flipped(new VRegfileReadIO(p)))
    val scalar = Vec(scalarPorts, Flipped(new VRegfileScalarIO(p)))
    val write = Vec(writePorts, Flipped(new VRegfileWrintIO(p)))
    val whint = Vec(whintPorts, Flipped(new VRegfileWhintIO(p)))
    val conv = Flipped(new VRegfileConvIO(p))
    val transpose = Flipped(new VRegfileTransposeIO(p))
    val vrfsb = Flipped(new VRegfileScoreboardIO)
    val vrfwriteCount = Output(UInt(3.W))
  })

  val segcnt = p.vectorBits / 32
  val segcntBits = log2Ceil(segcnt)

  // ---------------------------------------------------------------------------
  // Register file storage.
  val vreg = for (i <- 0 until segcnt) yield {
    Module(new VRegfileSegment(p))
  }

  // ---------------------------------------------------------------------------
  // Convolution unit.
  val vconv = VConvAlu(p)

  // ---------------------------------------------------------------------------
  // Assert state.
  val writeCurr = Wire(UInt(64.W))
  val writePrev = RegInit(0.U(64.W))
  val writeSet = Wire(Vec(writePorts, UInt(64.W)))

  for (i <- 0 until writePorts) {
    writeSet(i) := MuxOR(io.write(i).valid, 1.U << io.write(i).addr)
  }

  writeCurr := VecOR(writeSet)
  writePrev := writeCurr

  // ---------------------------------------------------------------------------
  // Write port interface and registration.
  val writevalidBool = Wire(Vec(writePorts, Bool()))
  val writevalid = writevalidBool.asUInt
  val writebits = Wire(Vec(writePorts, new VRegfileWrite(p)))
  val writevalidReg = RegInit(0.U(writePorts.W))
  val writebitsReg = Reg(Vec(writePorts, new VRegfileWrite(p)))

  for (i <- 0 until writePorts) {
    writevalidBool(i) := io.write(i).valid
    writebits(i).addr := io.write(i).addr
    writebits(i).data := io.write(i).data
  }

  writevalidReg := writevalid

  for (i <- 0 until writePorts) {
    when (io.write(i).valid) {
      writebitsReg(i).addr := io.write(i).addr
      writebitsReg(i).data := io.write(i).data
    }
  }

  io.vrfwriteCount := writevalid(0)

  // ---------------------------------------------------------------------------
  // Write ports.
  for (i <- 0 until writePorts) {
    for (j <- 0 until segcnt) {
      vreg(j).io.write(i).valid := writevalidReg(i)
      vreg(j).io.write(i).addr := writebitsReg(i).addr
      vreg(j).io.write(i).data := writebitsReg(i).data(32 * j + 31, 32 * j)
    }
  }

  // ---------------------------------------------------------------------------
  // Read ports.
  val readData = Reg(Vec(readPorts, UInt(p.vectorBits.W)))

  def ReadScalar(i: Int): (Bool, UInt) = {
    val valid  = Wire(Bool())
    val scalar = Wire(UInt(32.W))

    if (i == 1 || i == 4) {
      valid  := io.scalar(i / 3).valid
      scalar := io.scalar(i / 3).data
    } else {
      valid  := false.B
      scalar := 0.U
    }

    val lanes = p.vectorBits / 32
    val values = Wire(Vec(lanes, UInt(32.W)))
    for (i <- 0 until lanes) {
      values(i) := scalar
    }

    val result = values.asUInt
    assert(result.getWidth == p.vectorBits)
    (valid, result)
  }

  val rdata = Wire(Vec(readPorts, Vec(segcnt, UInt(32.W))))

  for (i <- 0 until readPorts) {
    for (j <- 0 until segcnt) {
      vreg(j).io.read(i).addr := io.read(i).addr
      rdata(i)(j) := vreg(j).io.read(i).data
    }
  }

  for (i <- 0 until readPorts) {
    // Forwarding of internal write-staging registers.
    val f1validBits = Wire(Vec(writePorts, Bool()))
    val f1valid = f1validBits.asUInt
    assert(PopCount(f1valid) <= 1.U)

    val f2validBits = Wire(Vec(writePorts, Bool()))
    val f2valid = f2validBits.asUInt
    assert(PopCount(f2valid) <= 1.U)

    for (j <- 0 until writePorts) {
      f1validBits(j) := writevalid(j) &&
                        writebits(j).addr === io.read(i).addr
    }

    for (j <- 0 until writePorts) {
      f2validBits(j) := writevalidReg(j) &&
                        writebitsReg(j).addr === io.read(i).addr
    }

    val f1dataBits = Wire(Vec(writePorts, UInt(p.vectorBits.W)))
    val f1data = VecOR(f1dataBits, writePorts)

    for (j <- 0 until writePorts) {
      f1dataBits(j) := MuxOR(f1valid(j), writebits(j).data)
    }

    val f2dataBits = Wire(Vec(writePorts, UInt(p.vectorBits.W)))
    val f2data = VecOR(f2dataBits, writePorts)

    for (j <- 0 until writePorts) {
      f2dataBits(j) := MuxOR(f2valid(j), writebitsReg(j).data)
    }

    val (scalarValid, scalarData) = ReadScalar(i)

    val sel = Cat(scalarValid,
                  !scalarValid && f1valid =/= 0.U,
                  !scalarValid && f1valid === 0.U && f2valid =/= 0.U,
                  !scalarValid && f1valid === 0.U && f2valid === 0.U)
    assert(PopCount(sel) <= 1.U)

    val data = MuxOR(sel(3), scalarData) |
               MuxOR(sel(2), f1data) |
               MuxOR(sel(1), f2data) |
               MuxOR(sel(0), rdata(i).asUInt)

    val rvalid =
      if (i == 1 || i == 4) {
        assert(!(io.read(i).valid && io.scalar(i / 3).valid))
        io.read(i).valid || io.scalar(i / 3).valid
      } else {
        io.read(i).valid
      }

    when (rvalid) {
      readData(i) := data
    }
  }

  for (i <- 0 until readPorts) {
    io.read(i).data := readData(i)
  }

  // ---------------------------------------------------------------------------
  // Conv port.
  val convConv = RegInit(false.B)
  val convInit = RegInit(false.B)
  val convTran = RegInit(false.B)
  val convClear = RegInit(false.B)
  val convIndex = Reg(UInt(log2Ceil(p.vectorBits / 32).W))
  val convAbias = Reg(UInt(9.W))
  val convBbias = Reg(UInt(9.W))
  val convAsign = Reg(Bool())
  val convBsign = Reg(Bool())
  val internalData = Reg(UInt(p.vectorBits.W))

  // io.conv.valid controls read multiplexors
  // io.conv.ready frames data phase readiness
  convConv  := io.conv.valid && io.conv.ready && io.conv.op.conv
  convInit  := io.conv.valid && io.conv.ready && io.conv.op.init
  convTran  := io.conv.valid && io.conv.ready && io.conv.op.tran
  convClear := io.conv.valid && io.conv.ready && io.conv.op.wclr
  convIndex := io.conv.index

  assert(!(io.conv.valid && io.conv.ready) ||
         PopCount(Cat(io.conv.op.conv, io.conv.op.wclr, io.conv.op.init, io.conv.op.tran)) === 1.U)

  val idata = Wire(Vec(segcnt, UInt(32.W)))
  for (i <- 0 until segcnt) {
    idata(i) := vreg(i).io.internal.data
  }

  for (i <- 0 until segcnt) {
    vreg(i).io.internal.addr := io.conv.addr2
  }

  when (io.conv.valid) {
    internalData := idata.asUInt
  }

  when (io.conv.valid) {
    convAbias  := io.conv.abias
    convBbias  := io.conv.bbias
    convAsign  := io.conv.asign
    convBsign  := io.conv.bsign
  }

  for (i <- 0 until segcnt) {
    vreg(i).io.conv.valid := convClear
    for (j <- 0 until segcnt) {
      vreg(i).io.conv.data(j) := vconv.io.out(j)(32 * i + 31, 32 * i)  // note index are reversed
    }
  }

  // Note: do not assert if read touches any of the conv read/write registers.
  // Other scheduling mechanisms are used to not advance the opcode.
  val convRead0  = io.conv.valid && io.conv.ready && io.conv.op.conv
  val convClear0 = io.conv.valid && io.conv.ready && io.conv.op.wclr

  assert(!(convRead0 && io.conv.mode =/= 0.U))
  // assert(!(convRead0 && io.conv.addr1(5,4) === 3.U))
  // assert(!(convRead0 && io.conv.addr2(5,4) === 3.U))
  assert(!(convRead0 && io.conv.addr1(3,0) =/= 0.U))
  assert(!(convRead0 && io.conv.addr1(5,2) === io.conv.addr2(5,2) && (p.vectorBits == 128).B))
  assert(!(convRead0 && io.conv.addr1(5,3) === io.conv.addr2(5,3) && (p.vectorBits == 256).B))
  assert(!(convRead0 && io.conv.addr1(5,4) === io.conv.addr2(5,4) && (p.vectorBits == 512).B))

  // Convolution reads must not be under pipelined writes.
  assert(!(convRead0 && writeCurr(io.conv.addr2)))
  assert(!(convRead0 && writePrev(io.conv.addr2)))

  val convmaska = 0xffff.U << 48.U
  assert(!(convClear0 && (writeCurr & convmaska) =/= 0.U))
  assert(!(convClear0 && (writePrev & convmaska) =/= 0.U))
  // // Note: writePrev check not needed since accumulator is a cycle after reads.
  // // assert(!(convClear0 && (writePrev & convmaska) =/= 0.U))

  for (i <- 0 until writePorts) {
    assert(!((convClear0 || convClear) && io.write(i).valid && io.write(i).addr >= 48.U))
  }

  // ---------------------------------------------------------------------------
  // Convolution.
  vconv.io.op.conv := convConv
  vconv.io.op.init := convInit
  vconv.io.op.tran := convTran
  vconv.io.op.clear := convClear
  vconv.io.index := convIndex
  vconv.io.adata := io.transpose.data
  vconv.io.bdata := internalData
  vconv.io.abias := convAbias
  vconv.io.bbias := convBbias
  vconv.io.asign := convAsign
  vconv.io.bsign := convBsign

  // ---------------------------------------------------------------------------
  // Transpose port.
  val transposeData = Reg(UInt(io.transpose.data.getWidth.W))
  val transposeDataMux = Wire(Vec(segcnt, UInt(io.transpose.data.getWidth.W)))

  for (i <- 0 until segcnt) {
    vreg(i).io.transpose.addr := Mux(io.conv.valid, io.conv.addr1, io.transpose.addr)
    transposeDataMux(i) := vreg(i).io.transpose.data
  }

  when (io.conv.valid || io.transpose.valid) {
    val index = Mux(io.conv.valid, io.conv.index, io.transpose.index)
    transposeData := VecAt(transposeDataMux, index)
  }

  io.transpose.data := transposeData

  // Transpose reads must not be under pipelined writes.
  for (i <- 0 until segcnt) {
    assert(!(io.transpose.valid && writeCurr(io.transpose.addr + i.U)))
    assert(!(io.transpose.valid && writePrev(io.transpose.addr + i.U)))
  }

  assert(!(io.transpose.valid && io.conv.valid))
  assert(!(io.transpose.valid && convConv))

  // ---------------------------------------------------------------------------
  // Scoreboard.
  def SbClr(valid: Bool = false.B, data: UInt = 0.U(128.W), i: Int = 0): (Bool, UInt) = {
    if (i < writePorts) {
      val wvalid = io.write(i).valid
      val hvalid = if (i < whintPorts) io.whint(i).valid else false.B
      val woh = MuxOR(io.write(i).valid, UIntToOH(io.write(i).addr, 64))
      val hoh = if (i < whintPorts) MuxOR(io.whint(i).valid, UIntToOH(io.whint(i).addr, 64)) else 0.U
      val whoh = woh | hoh
      val whdata = Cat(whoh, whoh)
      assert(whdata.getWidth == 128)
      SbClr(valid || wvalid || hvalid, data | whdata, i + 1)
    } else {
      val cvalid = convClear  // delayed one cycle beyond io.conv.wclr, no forwarding to read ports
      val cdataH = Wire(UInt(16.W))
      val cdata  = MuxOR(cvalid, Cat(cdataH, 0.U(48.W), cdataH, 0.U(48.W)))
      assert(cdata.getWidth == 128)
      if (p.vectorBits == 128) cdataH := 0x000f.U
      if (p.vectorBits == 256) cdataH := 0x00ff.U
      if (p.vectorBits == 512) cdataH := 0xffff.U

      (valid || cvalid, data | cdata)
    }
  }

  val vrfsb = RegInit(0.U(128.W))
  val vrfsbSetEn = io.vrfsb.set.valid
  val vrfsbSet = MuxOR(io.vrfsb.set.valid, io.vrfsb.set.bits)
  val (vrfsbClrEn, vrfsbClr) = SbClr()

  when (vrfsbSetEn || vrfsbClrEn) {
    vrfsb := (vrfsb & ~vrfsbClr) | vrfsbSet
  }

  io.vrfsb.data := vrfsb
}

@nowarn
object EmitVRegfile extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VRegfile(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
