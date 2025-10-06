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

package coralnpu

import chisel3._
import chisel3.util._
import _root_.circt.stage.ChiselStage

object Dvu {
  def apply(p: Parameters): Dvu = {
    return Module(new Dvu(p))
  }
}

object DvuOp extends ChiselEnum {
  val DIV  = Value
  val DIVU = Value
  val REM  = Value
  val REMU = Value
}

class DvuCmd extends Bundle {
  val addr = UInt(5.W)
  val op = DvuOp()
}

class Dvu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val req = Flipped(Decoupled(new DvuCmd))

    // Execute cycle.
    val rs1 = Flipped(new RegfileReadDataIO)
    val rs2 = Flipped(new RegfileReadDataIO)
    val rd  = Decoupled(new RegfileWriteDataIO)
  })

  // This implemention differs to common::idiv by supporting early termination,
  // and only performs one bit per cycle.

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

  val addr1    = RegInit(0.U(5.W))
  val signed1  = RegInit(false.B)
  val divide1  = RegInit(false.B)
  val addr2    = RegInit(0.U(5.W))
  val signed2d = RegInit(false.B)
  val signed2r = RegInit(false.B)
  val divide2  = RegInit(false.B)

  val count  = RegInit(0.U(6.W))

  val divide = RegInit(0.U(32.W))
  val remain = RegInit(0.U(32.W))
  val denom  = RegInit(0.U(32.W))

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

  addr1   := Mux(io.req.fire, io.req.bits.addr, addr1)
  signed1 := Mux(
      io.req.fire, io.req.bits.op.isOneOf(DvuOp.DIV, DvuOp.REM), signed1)
  divide1 := Mux(
      io.req.fire, io.req.bits.op.isOneOf(DvuOp.DIV, DvuOp.DIVU), divide1)

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
  io.rd.bits.addr := addr2
  io.rd.bits.data := Mux(divide2, div, rem)
}

object EmitDvu extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new Dvu(p), args)
}
