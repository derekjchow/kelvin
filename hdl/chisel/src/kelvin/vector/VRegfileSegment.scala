package kelvin

import chisel3._
import chisel3.util._

class VRegfileSegment(p: Parameters) extends Module {
  val readPorts = 7
  val writePorts = 6
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

object EmitVRegfileSegment extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new VRegfileSegment(p), args)
}
