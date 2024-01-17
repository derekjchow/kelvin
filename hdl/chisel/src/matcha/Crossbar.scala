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
import _root_.circt.stage.ChiselStage

object Crossbar {
  def apply(ports: Int, addrbits: Int, databits: Int, idbits: Int) = {
    Module(new Crossbar(ports, addrbits, databits, idbits))
  }
}

class CrossbarIO(addrbits: Int, databits: Int, idbits: Int) extends Bundle {
  // Command.
  val cvalid = Output(Bool())
  val cready = Input(Bool())
  val cwrite = Output(Bool())
  val caddr  = Output(UInt(addrbits.W))
  val cid    = Output(UInt(idbits.W))

  // Write.
  val wdata  = Output(UInt(databits.W))
  val wmask  = Output(UInt((databits / 8).W))

  // Read Response.
  val rvalid = Input(Bool())
  val rid    = Input(UInt(idbits.W))
  val rdata  = Input(UInt(databits.W))
}

class SramIO(addrbits: Int, databits: Int) extends Bundle {
  // 1cc read response.
  val valid = Output(Bool())
  val write = Output(Bool())
  val addr  = Output(UInt(addrbits.W))
  val wdata = Output(UInt(databits.W))
  val wmask = Output(UInt((databits / 8).W))
  val rdata = Input(UInt(databits.W))
}

class Crossbar(ports: Int, addrbits: Int, databits: Int, idbits: Int) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Vec(ports, new CrossbarIO(addrbits, databits, idbits)))
    val out = new SramIO(addrbits, databits)
  })

  // Register the command interface and the read data response. 3cc latency.
  //
  // Cycle0: arbitrate and controls registered io.in(*)
  // Cycle1: sram command io.out.valid
  // Cycle2: {sram data registered}
  // Cycle3: {pipelined read response}

  val pidbits = idbits + log2Ceil(ports)
  val alsb = log2Ceil(databits/8)
  val amsb = addrbits - 1
  val indexbits = addrbits - alsb

  withReset(reset.asAsyncReset) {
    // ---------------------------------------------------------------------------
    // Arbitrate.
    val csel0 = RegInit(1.U(ports.W))
    assert(PopCount(csel0) === 1.U)

    def PriorityEncodeValid(i: Int = 0, active: Bool = false.B, output: UInt = 0.U((ports).W)): UInt = {
      if (i == 0) {
        PriorityEncodeValid(
          i + 1,
          io.in(i).cvalid,
          io.in(i).cvalid
        )
      } else if (i < ports) {
        PriorityEncodeValid(
          i + 1,
          active || io.in(i).cvalid,
          Cat(io.in(i).cvalid && !active, output(i - 1, 0))
        )
      } else {
        output
      }
    }

    // Maintain last selection if no other activity.
    val cvalid = Wire(Vec(ports, Bool()))
    for (i <- 0 until ports) {
      cvalid(i) := io.in(i).cvalid
    }

    when (cvalid.asUInt =/= 0.U) {
      csel0 := PriorityEncodeValid()
    }

    for (i <- 0 until ports) {
      io.in(i).cready := csel0(i)
    }

    // ---------------------------------------------------------------------------
    // Controls.
    def CEnable(i: Int = 0, enable: Bool = false.B): Bool = {
      if (i < ports) {
        CEnable(
          i + 1,
          enable || io.in(i).cvalid && csel0(i)
        )
      } else {
        enable
      }
    }

    val cen0 = CEnable()

    // ---------------------------------------------------------------------------
    // Controls.
    val cvalid1 = RegInit(false.B)
    val cwrite1 = RegInit(false.B)
    val cindex1 = Reg(UInt(indexbits.W))
    val cid1    = Reg(UInt(pidbits.W))
    val wdata1  = Reg(UInt(databits.W))
    val wmask1  = Reg(UInt((databits / 8).W))

    def CData(i: Int = 0,
      iwrite: Bool = false.B, iindex: UInt = 0.U(indexbits.W), iid: UInt = 0.U(pidbits.W),
      idata: UInt = 0.U(databits.W), imask: UInt = 0.U((databits / 8).W)
    ): (Bool, UInt, UInt, UInt, UInt) = {
      if (i < ports) {
        CData(
          i + 1,
          iwrite || Mux(csel0(i), io.in(i).cwrite, false.B),
          iindex  | Mux(csel0(i), io.in(i).caddr(amsb,alsb), 0.U),
          iid     | Mux(csel0(i), Cat(i.U, io.in(i).cid), 0.U),
          idata   | Mux(csel0(i), io.in(i).wdata, 0.U),
          imask   | Mux(csel0(i), io.in(i).wmask, 0.U)
        )
      } else {
        (iwrite, iindex, iid, idata, imask)
      }
    }

    cvalid1 := cen0

    when (cen0) {
      val (cwriteNxt, cindexNxt, cidNxt, wdataNxt, wmaskNxt) = CData()
      cwrite1 := cwriteNxt
      cindex1 := cindexNxt
      cid1    := cidNxt
      when (cwriteNxt) {
        wdata1  := wdataNxt
        wmask1  := wmaskNxt
      }
    }

    io.out.valid := cvalid1
    io.out.write := cwrite1
    io.out.addr  := Cat(cindex1, 0.U(alsb.W))
    io.out.wdata := wdata1
    io.out.wmask := wmask1

    assert(!(io.out.valid && io.out.addr(alsb - 1, 0) =/= 0.U))

    // ---------------------------------------------------------------------------
    // Read Data.
    val rvalid2 = RegInit(false.B)
    val rid2    = Reg(UInt(pidbits.W))

    rvalid2 := cvalid1 && !cwrite1
    rid2    := cid1

    // ---------------------------------------------------------------------------
    // Read Response.
    val rvalid3 = RegInit(VecInit(Seq.fill(ports)(false.B)))
    val rid3    = Reg(UInt(idbits.W))
    val rdata3  = Reg(UInt(databits.W))

    if (ports > 1) {
      for (i <- 0 until ports) {
        rvalid3(i) := rvalid2 && rid2(pidbits - 1, idbits) === i.U
      }
    } else {
      rvalid3(0) := rvalid2
    }

    when (rvalid2) {
      rdata3 := io.out.rdata
      rid3   := rid2(idbits - 1, 0)
    }

    for (i <- 0 until ports) {
      io.in(i).rvalid := rvalid3(i)
      io.in(i).rdata  := Mux(rvalid3(i), rdata3, 0.U)
      io.in(i).rid    := Mux(rvalid3(i), rid3, 0.U)
    }
  }
}

object EmitCrossbar extends App {
  // 4MB = 2^22 = 2^17 * 256/8
  ChiselStage.emitSystemVerilogFile(new Crossbar(4, 22, 256, 8), args)
}
