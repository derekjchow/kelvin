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
import kelvin._
import _root_.circt.stage.ChiselStage

object Axi2Sram {
  def apply(p: kelvin.Parameters): Axi2Sram = {
    return Module(new Axi2Sram(p))
  }
}

// AXI Bridge.
class Axi2Sram(p: kelvin.Parameters) extends Module {
  val io = IO(new Bundle {
    // Vector TCM
    val in0 = Flipped(new AxiMasterIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits))
    // Scalar DBus
    val in1 = Flipped(new AxiMasterIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits))
    // L1DCache
    val in2 = Flipped(new AxiMasterIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits))
    // L1ICache
    val in3 = new Bundle {
      val read = Flipped(new AxiMasterReadIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits))
    }
    // SRAM port
    val out = new CrossbarIO(p.axiSysAddrBits, p.axiSysDataBits, p.axiSysIdBits)
  })

  assert(p.axiSysIdBits == 7)
  assert(p.axiSysAddrBits == 32)
  assert(p.axiSysDataBits == 256)
  assert(p.vectorBits == 256)
  assert(p.axi0DataBits == 256)
  assert(p.axi1DataBits == 256)
  assert(p.axi2DataBits == 256)

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

  val cv0 = io.in0.read.addr.valid
  val cv1 = io.in1.read.addr.valid
  val cv2 = io.in2.read.addr.valid
  val cv3 = io.in3.read.addr.valid
  val cv4 = io.in0.write.addr.valid
  val cv5 = io.in1.write.addr.valid
  val cv6 = io.in2.write.addr.valid

  cctrl.io.in.valid := cv0 || cv1 || cv2 || cv3 || cv4 || cv5 || cv6

  cctrl.io.in.bits.cwrite := (cv4 || cv5 || cv6) && !(cv0 || cv1 || cv2 || cv3)

  wdata.io.in.valid := cctrl.io.in.bits.cwrite && cctrl.io.in.ready

  cctrl.io.in.bits.caddr := Mux(cv0, io.in0.read.addr.bits.addr,
                            Mux(cv1, io.in1.read.addr.bits.addr,
                            Mux(cv2, io.in2.read.addr.bits.addr,
                            Mux(cv3, io.in3.read.addr.bits.addr,
                            Mux(cv4, io.in0.write.addr.bits.addr,
                            Mux(cv5, io.in1.write.addr.bits.addr,
                                     io.in2.write.addr.bits.addr))))))

  cctrl.io.in.bits.cid := Mux(cv0, Encode(0, io.in0.read.addr.bits.id),
                          Mux(cv1, Encode(1, io.in1.read.addr.bits.id),
                          Mux(cv2, Encode(2, io.in2.read.addr.bits.id),
                          Mux(cv3, Encode(3, io.in3.read.addr.bits.id),
                                   0.U))))

  wdata.io.in.bits.wdata := Mux(cv4, io.in0.write.data.bits.data,
                            Mux(cv5, io.in1.write.data.bits.data,
                                     io.in2.write.data.bits.data))

  wdata.io.in.bits.wmask := Mux(cv4, io.in0.write.data.bits.strb,
                            Mux(cv5, io.in1.write.data.bits.strb,
                                     io.in2.write.data.bits.strb))

  io.in0.read.addr.ready  := cctrl.io.in.ready
  io.in1.read.addr.ready  := cctrl.io.in.ready && !(cv0)
  io.in2.read.addr.ready  := cctrl.io.in.ready && !(cv0 || cv1)
  io.in3.read.addr.ready  := cctrl.io.in.ready && !(cv0 || cv1 || cv2)
  io.in0.write.addr.ready := cctrl.io.in.ready && !(cv0 || cv1 || cv2 || cv3)
  io.in1.write.addr.ready := cctrl.io.in.ready && !(cv0 || cv1 || cv2 || cv3 || cv4)
  io.in2.write.addr.ready := cctrl.io.in.ready && !(cv0 || cv1 || cv2 || cv3 || cv4 || cv5)
  io.in0.write.data.ready := io.in0.write.addr.ready
  io.in1.write.data.ready := io.in1.write.addr.ready
  io.in2.write.data.ready := io.in2.write.addr.ready

  // ---------------------------------------------------------------------------
  // Response Multiplexor.
  val rs0 = Decode(0, rdata.io.out.bits.rid)
  val rs1 = Decode(1, rdata.io.out.bits.rid)
  val rs2 = Decode(2, rdata.io.out.bits.rid)
  val rs3 = Decode(3, rdata.io.out.bits.rid)

  rdata.io.out.ready := rs0 && io.in0.read.data.ready ||
                        rs1 && io.in1.read.data.ready ||
                        rs2 && io.in2.read.data.ready ||
                        rs3 && io.in3.read.data.ready

  io.in0.read.data.valid := rs0 && rdata.io.out.valid
  io.in1.read.data.valid := rs1 && rdata.io.out.valid
  io.in2.read.data.valid := rs2 && rdata.io.out.valid
  io.in3.read.data.valid := rs3 && rdata.io.out.valid

  io.in0.read.data.bits.data := rdata.io.out.bits.rdata
  io.in1.read.data.bits.data := rdata.io.out.bits.rdata
  io.in2.read.data.bits.data := rdata.io.out.bits.rdata
  io.in3.read.data.bits.data := rdata.io.out.bits.rdata

  io.in0.read.data.bits.id := rdata.io.out.bits.rid
  io.in1.read.data.bits.id := rdata.io.out.bits.rid
  io.in2.read.data.bits.id := rdata.io.out.bits.rid
  io.in3.read.data.bits.id := rdata.io.out.bits.rid

  io.in0.read.data.bits.resp := 0.U
  io.in1.read.data.bits.resp := 0.U
  io.in2.read.data.bits.resp := 0.U
  io.in3.read.data.bits.resp := 0.U

  // ---------------------------------------------------------------------------
  // Write response.
  val wrespvalid0 = RegInit(false.B)
  val wrespvalid1 = RegInit(false.B)
  val wrespvalid2 = RegInit(false.B)
  val wrespid = Reg(UInt(p.axiSysIdBits.W))

  wrespvalid0 := io.in0.write.addr.valid && io.in0.write.addr.ready
  wrespvalid1 := io.in1.write.addr.valid && io.in1.write.addr.ready
  wrespvalid2 := io.in2.write.addr.valid && io.in2.write.addr.ready

  when (io.in0.write.addr.valid && io.in0.write.addr.ready) {
    wrespid := io.in0.write.addr.bits.id
  } .elsewhen (io.in1.write.addr.valid && io.in1.write.addr.ready) {
    wrespid := io.in1.write.addr.bits.id
  } .elsewhen (io.in2.write.addr.valid && io.in2.write.addr.ready) {
    wrespid := io.in2.write.addr.bits.id
  }

  io.in0.write.resp.valid := wrespvalid0
  io.in1.write.resp.valid := wrespvalid1
  io.in2.write.resp.valid := wrespvalid2

  io.in0.write.resp.bits.id := wrespid
  io.in1.write.resp.bits.id := wrespid
  io.in2.write.resp.bits.id := wrespid

  io.in0.write.resp.bits.resp := 0.U
  io.in1.write.resp.bits.resp := 0.U
  io.in2.write.resp.bits.resp := 0.U

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
  assert(PopCount(Cat(io.in0.read.addr.valid && io.in0.read.addr.ready,
                      io.in1.read.addr.valid && io.in1.read.addr.ready,
                      io.in2.read.addr.valid && io.in2.read.addr.ready,
                      io.in3.read.addr.valid && io.in3.read.addr.ready,
                      io.in0.write.addr.valid && io.in0.write.addr.ready,
                      io.in1.write.addr.valid && io.in1.write.addr.ready,
                      io.in2.write.addr.valid && io.in2.write.addr.ready)) <= 1.U)

  assert(io.in0.write.addr.valid === io.in0.write.data.valid)
  assert(io.in1.write.addr.valid === io.in1.write.data.valid)
  assert(io.in2.write.addr.valid === io.in2.write.data.valid)

  assert(io.in0.write.addr.ready === io.in0.write.data.ready)
  assert(io.in1.write.addr.ready === io.in1.write.data.ready)
  assert(io.in2.write.addr.ready === io.in2.write.data.ready)

  assert(!(io.in0.read.data.valid && !io.in0.read.data.ready))
  assert(!(io.in1.read.data.valid && !io.in1.read.data.ready))
  assert(!(io.in2.read.data.valid && !io.in2.read.data.ready))
  assert(!(io.in3.read.data.valid && !io.in3.read.data.ready))

  assert(!(io.in0.write.resp.valid && !io.in0.write.resp.ready))
  assert(!(io.in1.write.resp.valid && !io.in1.write.resp.ready))
  assert(!(io.in2.write.resp.valid && !io.in2.write.resp.ready))

  assert(!(cctrl.io.in.valid && cctrl.io.in.ready && cctrl.io.in.bits.cwrite && !wdata.io.in.valid))
  assert(!(cctrl.io.in.valid && cctrl.io.in.ready && cctrl.io.in.bits.cwrite && !wdata.io.in.ready))

  assert(!(rdata.io.in.valid && !rdata.io.in.ready))

  assert(PopCount(Cat(rs0, rs1, rs2, rs3)) <= 1.U)
}

object EmitAxi2Sram extends App {
  val p = new kelvin.Parameters
  ChiselStage.emitSystemVerilogFile(new Axi2Sram(p), args)
}
