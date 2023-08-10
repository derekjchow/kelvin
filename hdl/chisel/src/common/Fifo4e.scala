// Copyright 2023 Google LLC
package common

import chisel3._
import chisel3.util._

// Fifo4 with entry output and no output registration stage.

object Fifo4e {
  def apply[T <: Data](t: T, n: Int) = {
    Module(new Fifo4e(t, n))
  }
}

class Fifo4e[T <: Data](t: T, n: Int) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(Vec(4, Valid(t))))
    val out = Decoupled(t)
    val count = Output(UInt(log2Ceil(n+1).W))
    val entry = Output(Vec(n, Valid(t)))
    val nempty = Output(Bool())
  })

  def Increment(a: UInt, b: UInt): UInt = {
    val c = a +& b
    val d = Mux(c < n.U, c, c - n.U)(a.getWidth - 1, 0)
    d
  }

  val mem = Mem(n, t)

  val in0pos = RegInit(0.U(log2Ceil(n).W))
  val in1pos = RegInit(1.U(log2Ceil(n).W))
  val in2pos = RegInit(2.U(log2Ceil(n).W))
  val in3pos = RegInit(3.U(log2Ceil(n).W))
  val outpos = RegInit(0.U(log2Ceil(n).W))
  val mcount = RegInit(0.U(log2Ceil(n+1).W))
  val nempty = RegInit(false.B)

  io.count := mcount
  io.nempty := nempty

  val ivalid = io.in.valid && io.in.ready
  val ovalid = io.out.valid && io.out.ready

  val iactive = Cat(io.in.bits(3).valid, io.in.bits(2).valid,
                    io.in.bits(1).valid, io.in.bits(0).valid).asUInt

  val icount = io.in.bits(0).valid +& io.in.bits(1).valid +
               io.in.bits(2).valid +& io.in.bits(3).valid

  // ---------------------------------------------------------------------------
  // Fifo Control.
  when (ivalid) {
    in0pos := Increment(in0pos, icount)
    in1pos := Increment(in1pos, icount)
    in2pos := Increment(in2pos, icount)
    in3pos := Increment(in3pos, icount)
  }

  when (ovalid) {
    outpos := Increment(outpos, 1.U)
  }

  val inc = MuxOR(ivalid, icount)
  val dec = ovalid

  when (ivalid || ovalid) {
    val nxtcount = mcount + inc - dec
    mcount := nxtcount
    nempty := nxtcount =/= 0.U
  }

  // ---------------------------------------------------------------------------
  // Fifo Input.
  val (in0valid, in1valid, in2valid, in3valid) = Fifo4Valid(iactive)

  for (i <- 0 until n) {
    val valid = Cat(in0pos === i.U && in0valid(3) ||
                    in1pos === i.U && in1valid(3) ||
                    in2pos === i.U && in2valid(3) ||
                    in3pos === i.U && in3valid(3),
                    in0pos === i.U && in0valid(2) ||
                    in1pos === i.U && in1valid(2) ||
                    in2pos === i.U && in2valid(2),
                    in0pos === i.U && in0valid(1) ||
                    in1pos === i.U && in1valid(1),
                    in0pos === i.U && in0valid(0))

    // Couldn't get the following to work properly.
    //
    // val data = MuxOR(valid(0), io.in.bits(0).bits.asUInt) |
    //            MuxOR(valid(1), io.in.bits(1).bits.asUInt) |
    //            MuxOR(valid(2), io.in.bits(2).bits.asUInt) |
    //            MuxOR(valid(3), io.in.bits(3).bits.asUInt)
    //
    // when (ivalid && valid =/= 0.U) {
    //   mem(i) := data.asTypeOf(t)
    // }
    when (ivalid) {
      when (valid(0)) {
        mem(i) := io.in.bits(0).bits
      } .elsewhen (valid(1)) {
        mem(i) := io.in.bits(1).bits
      } .elsewhen (valid(2)) {
        mem(i) := io.in.bits(2).bits
      } .elsewhen (valid(3)) {
        mem(i) := io.in.bits(3).bits
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Valid Entries.
  val active = RegInit(0.U(n.W))

  val activeSet = MuxOR(ivalid,
      ((icount >= 1.U) << in0pos) | ((icount >= 2.U) << in1pos) |
      ((icount >= 3.U) << in2pos) | ((icount >= 4.U) << in3pos))

  val activeClr = MuxOR(io.out.valid && io.out.ready, 1.U << outpos)

  when (io.in.valid && io.in.ready || io.out.valid && io.out.ready) {
    active := (active | activeSet) & ~activeClr
  }

  // ---------------------------------------------------------------------------
  // Interface.
  io.in.ready := mcount <= (n.U - icount)

  io.out.valid := mcount =/= 0.U
  io.out.bits := mem(outpos)

  assert(mcount <= n.U)

  for (i <- 0 until n) {
    io.entry(i).valid := active(i)
    io.entry(i).bits := mem(i)
  }
}

object EmitFifo4e extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Fifo4e(UInt(8.W), 10), args)
}
