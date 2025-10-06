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

package matcha

import chisel3._
import chisel3.util._

import bus._
import common._
import _root_.circt.stage.ChiselStage

object Axi2Sram {
  def apply(p: coralnpu.Parameters): Axi2Sram = {
    return Module(new Axi2Sram(p))
  }
}

// AXI Bridge.
class Axi2Sram(p: coralnpu.Parameters) extends Module {
  val io = IO(new Bundle {
    // L1DCache
    val l1d = Flipped(new AxiMasterIO(p.axiSysAddrBits, p.axi1DataBits, p.axiSysIdBits))
    // L1ICache
    val l1i = new Bundle {
      val read = Flipped(new AxiMasterReadIO(p.axiSysAddrBits, p.axi0DataBits, p.axiSysIdBits))
    }
    // SRAM port
    val out = new CrossbarIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits)
  })

  assert(p.axiSysIdBits == 7)
  assert(p.axiSysAddrBits == 32)
  assert(p.axiSysDataBits == 256 || p.axiSysDataBits == 128)
  assert(p.vectorBits == 256)
  assert(p.axi0DataBits == 256 || p.axi0DataBits == 128)
  assert(p.axi1DataBits == 256 || p.axi1DataBits == 128)
  assert(p.axi2DataBits == 256 || p.axi2DataBits == 128)

  def Decode(i: Int, id: UInt): Bool = {
    assert(id.getWidth == 7)
    if (i == 0) {
      id(6,6) === "b0".U
    } else if (i == 1) {
      id(6,5) === "b10".U
    } else if (i == 2) {
      id(6,4) === "b110".U
    } else if (i == 3) {
      id(6,4) === "b111".U
    } else {
      assert(false)
      false.B
    }
  }

  def Encode(i: Int, id: UInt): UInt = {
    val e = Wire(UInt(7.W))
    if (i == 0) {
      assert(p.axi2IdBits == 6)
      e := "b0000000".U(7.W) | id(5, 0)
    } else if (i == 1) {
      assert(p.axi0IdBits == 4)
      e := "b1000000".U(7.W) | id(3, 0)
    } else if (i == 2) {
      assert(p.axi1IdBits == 4)
      e := "b1100000".U(7.W) | id(3, 0)
    } else if (i == 3) {
      assert(p.axi0IdBits == 4)
      e := "b1110000".U(7.W) | id(3, 0)
    } else {
      assert(false)
      e := 0.U
    }
    e
  }

  // ---------------------------------------------------------------------------
  // AXI Registered Multiplexor.
  val cctrl = Slice(new Bundle {
    val cwrite = Bool()
    val caddr  = UInt(p.axiSysAddrBits.W)
    val cid    = UInt(p.axiSysIdBits.W)
  } , true)

  val wdata = Slice(new Bundle {
    val wdata  = UInt(p.axiSysDataBits.W)
    val wmask  = UInt((p.axiSysDataBits / 8).W)
  }, true)

  val rdata = Slice(new Bundle {
    val rid    = UInt(p.axiSysIdBits.W)
    val rdata  = UInt(p.axiSysDataBits.W)
  }, true)

  val readInterfaces = Seq(io.l1d.read, io.l1i.read)
  val readIds = Seq(0, 1)
  val writeInterfaces = Seq(io.l1d.write)
  val readCv = readInterfaces.map(_.addr.valid)
  val writeCv = writeInterfaces.map(_.addr.valid)
  val readValid = readCv.reduce(_ || _)
  val writeValid = writeCv.reduce(_ || _)

  cctrl.io.in.valid := readValid || writeValid

  cctrl.io.in.bits.cwrite := writeValid && !readValid

  wdata.io.in.valid := cctrl.io.in.bits.cwrite && cctrl.io.in.ready

  cctrl.io.in.bits.caddr :=
      MuxCase(0.U, readInterfaces.map(x => x.addr.valid -> x.addr.bits.addr) ++
                   writeInterfaces.map(x => x.addr.valid -> x.addr.bits.addr))
  cctrl.io.in.bits.cid := MuxCase(
      0.U,
      (0 until readInterfaces.length).map(i =>
          readInterfaces(i).addr.valid ->
              Encode(i, readInterfaces(i).addr.bits.id)))
  wdata.io.in.bits.wdata :=
      MuxCase(0.U, writeInterfaces.map(x => x.addr.valid -> x.data.bits.data))
  wdata.io.in.bits.wmask :=
      MuxCase(0.U, writeInterfaces.map(x => x.addr.valid -> x.data.bits.strb))

  val allCv = readCv ++ writeCv
  val prevCv = allCv.scan(false.B)(_ || _)
  for (i <- 0 until readInterfaces.length) {
    readInterfaces(i).addr.ready := cctrl.io.in.ready && !prevCv(i)
  }
  for (i <- 0 until writeInterfaces.length) {
    writeInterfaces(i).addr.ready :=
        cctrl.io.in.ready && !prevCv(i + readInterfaces.length)
  }
  writeInterfaces.foreach(x => x.data.ready := x.addr.ready)

  // ---------------------------------------------------------------------------
  // Response Multiplexor.
  val rs = (0 until readInterfaces.length).map(
      i => Decode(readIds(i), rdata.io.out.bits.rid))
  rdata.io.out.ready := (0 until readInterfaces.length).map(i =>
      rs(i) && readInterfaces(i).data.ready).reduce(_||_)
  for (i <- 0 until readInterfaces.length) {
    readInterfaces(i).data.valid := rs(i) && rdata.io.out.valid
    readInterfaces(i).data.bits.data := rdata.io.out.bits.rdata
    readInterfaces(i).data.bits.id := rdata.io.out.bits.rid
    readInterfaces(i).data.bits.resp := 0.U
    readInterfaces(i).data.bits.last := true.B
  }

  // ---------------------------------------------------------------------------
  // Write response.
  val wrespvalid = RegInit(VecInit.fill(writeInterfaces.length)(false.B))
  val wrespid = Reg(UInt(p.axiSysIdBits.W))
  val writeFire = writeInterfaces.map(x => x.addr.valid && x.addr.ready)
  wrespvalid := writeFire
  wrespid := MuxCase(0.U, (0 until writeInterfaces.length).map(
    i => writeFire(i) -> writeInterfaces(i).addr.bits.id))

  for (i <- 0 until writeInterfaces.length) {
    writeInterfaces(i).resp.valid := wrespvalid(i)
    writeInterfaces(i).resp.bits.id := wrespid
    writeInterfaces(i).resp.bits.resp := 0.U
  }

  // ---------------------------------------------------------------------------
  // SRAM interface.
  io.out.cvalid := cctrl.io.out.valid
  io.out.cwrite := cctrl.io.out.bits.cwrite
  io.out.caddr  := cctrl.io.out.bits.caddr
  io.out.cid    := cctrl.io.out.bits.cid
  cctrl.io.out.ready := io.out.cready
  wdata.io.out.ready := io.out.cready && cctrl.io.out.valid && cctrl.io.out.bits.cwrite

  io.out.wdata := wdata.io.out.bits.wdata
  io.out.wmask := wdata.io.out.bits.wmask

  rdata.io.in.valid := io.out.rvalid
  rdata.io.in.bits.rid   := io.out.rid
  rdata.io.in.bits.rdata := io.out.rdata

  // ---------------------------------------------------------------------------
  // Assertions.
  val allInterfacesFire = readInterfaces.map(x => x.addr.valid && x.addr.ready) ++
      writeInterfaces.map(x => x.addr.valid && x.addr.ready)
  assert(PopCount(allInterfacesFire) <= 1.U)

  for (x <- writeInterfaces) {
    assert(x.addr.valid === x.data.valid)
    assert(x.addr.ready === x.data.ready)
    assert(!(x.resp.valid && !x.resp.ready))
  }

  for (x <- readInterfaces) {
    assert(!x.data.valid || x.data.ready)
  }

  assert(!(cctrl.io.in.valid && cctrl.io.in.ready && cctrl.io.in.bits.cwrite && !wdata.io.in.valid))
  assert(!(cctrl.io.in.valid && cctrl.io.in.ready && cctrl.io.in.bits.cwrite && !wdata.io.in.ready))

  assert(!(rdata.io.in.valid && !rdata.io.in.ready))

  assert(PopCount(rs) <= 1.U)
}

object EmitAxi2Sram extends App {
  val p = new coralnpu.Parameters
  ChiselStage.emitSystemVerilogFile(new Axi2Sram(p), args)
}
