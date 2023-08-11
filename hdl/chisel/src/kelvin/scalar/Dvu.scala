// Copyright 2023 Google LLC
package kelvin

import chisel3._
import chisel3.util._
import common._

object Dvu {
  def apply(p: Parameters): Dvu = {
    return Module(new Dvu(p))
  }
}

case class DvuOp() {
  val DIV  = 0
  val DIVU = 1
  val REM  = 2
  val REMU = 3
  val Entries = 4
}

class DvuIO(p: Parameters) extends Bundle {
  val valid = Input(Bool())
  val ready = Output(Bool())
  val addr = Input(UInt(5.W))
  val op = Input(UInt(new DvuOp().Entries.W))
}

class Dvu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = new DvuIO(p)

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rs2 = Flipped(new RegfileReadDataIO)
    val rd  = new Bundle {  // RegfileWriteDataIO
      val valid = Output(Bool())
      val ready = Input(Bool())
      val addr  = Output(UInt(5.W))
      val data  = Output(UInt(32.W))
    }
  })

  // This implemention differs to common::idiv by supporting early termination,
  // and only performs one bit per cycle.
  val dvu = new DvuOp()

  def Divide(prvDivide: UInt, prvRemain: UInt, denom: UInt): (UInt, UInt) = {
    val shfRemain = Cat(prvRemain(30,0), prvDivide(31))
    val subtract = shfRemain -& denom
    assert(subtract.getWidth == 33)
    val divDivide = Wire(UInt(32.W))
    val divRemain = Wire(UInt(32.W))

    when (!subtract(32)) {
      divDivide := Cat(prvDivide(30,0), 1.U(1.W))
      divRemain := subtract(31,0)
    } .otherwise {
      divDivide := Cat(prvDivide(30,0), 0.U(1.W))
      divRemain := shfRemain
    }

    (divDivide, divRemain)
  }

  val active = RegInit(false.B)
  val compute = RegInit(false.B)

  val addr1    = Reg(UInt(5.W))
  val signed1  = Reg(Bool())
  val divide1  = Reg(Bool())
  val addr2    = Reg(UInt(5.W))
  val signed2d = Reg(Bool())
  val signed2r = Reg(Bool())
  val divide2  = Reg(Bool())

  val count = Reg(UInt(6.W))

  val divide = Reg(UInt(32.W))
  val remain = Reg(UInt(32.W))
  val denom  = Reg(UInt(32.W))

  val divByZero = io.rs2.data === 0.U

  io.req.ready := !active && !compute && !count(5)

  // This is not a Clz, one value too small.
  def Clz1(bits: UInt): UInt = {
    val msb = bits.getWidth - 1
    Mux(bits(msb), 0.U, PriorityEncoder(Reverse(bits(msb - 1, 0))))
  }

  // Disable active second to last cycle.
  when (io.req.valid && io.req.ready) {
    active := true.B
  } .elsewhen (count === 30.U) {
    active := false.B
  }

  // Compute is delayed by one cycle.
  compute := active

  when (io.req.valid && io.req.ready) {
    addr1   := io.req.addr
    signed1 := io.req.op(dvu.DIV) || io.req.op(dvu.REM)
    divide1 := io.req.op(dvu.DIV) || io.req.op(dvu.DIVU)
  }

  when (active && !compute) {
    addr2    := addr1
    signed2d := signed1 && (io.rs1.data(31) =/= io.rs2.data(31)) && !divByZero
    signed2r := signed1 && io.rs1.data(31)
    divide2  := divide1

    val inp = Mux(signed1 && io.rs1.data(31), ~io.rs1.data + 1.U, io.rs1.data)

    // The divBy0 uses full latency to simplify logic.
    // Count the leading zeroes, which is one less than the priority encoding.
    val clz = Mux(io.rs2.data === 0.U, 0.U, Clz1(inp))

    denom  := Mux(signed1 && io.rs2.data(31), ~io.rs2.data + 1.U, io.rs2.data)
    divide := inp << clz
    remain := 0.U
    count  := clz
  } .elsewhen (compute && count < 32.U) {
    val (div, rem) = Divide(divide, remain, denom)
    divide := div
    remain := rem
    count := count + 1.U
  } .elsewhen (io.rd.valid && io.rd.ready) {
    count := 0.U
  }

  val div = Mux(signed2d, ~divide + 1.U, divide)
  val rem = Mux(signed2r, ~remain + 1.U, remain)

  io.rd.valid := count(5)
  io.rd.addr := addr2
  io.rd.data := Mux(divide2, div, rem)
}

object EmitDvu extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new Dvu(p), args)
}
