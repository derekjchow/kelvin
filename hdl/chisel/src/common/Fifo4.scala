// Copyright 2023 Google LLC
package common

import chisel3._
import chisel3.util._

object Fifo4 {
  def apply[T <: Data](t: T, n: Int) = {
    Module(new Fifo4(t, n))
  }
}

// 4way decode, used for Fifo4 style input controls.
object Fifo4Valid {
  def apply(in: UInt): (UInt, UInt, UInt, UInt) = {
    assert(in.getWidth == 4)

    val in0 = Cat(in(3,0) === 8.U,  // 8
                  in(2,0) === 4.U,  // 4, 12
                  in(1,0) === 2.U,  // 2, 6, 10, 14
                  in(0))            // 1, 3, 5, 7, 9, 11, 13, 15

    val in1 = Cat(in(3,0) === 12.U ||
                  in(3,0) === 10.U ||
                  in(3,0) === 9.U,  // 9, 10, 12
                  in(2,0) === 6.U ||
                  in(2,0) === 5.U,  // 5, 6, 13, 14
                  in(1,0) === 3.U,  // 3, 7, 11, 15
                  false.B)

    val in2 = Cat(in(3,0) === 14.U ||
                  in(3,0) === 13.U ||
                  in(3,0) === 11.U,  // 11, 13, 14
                  in(2,0) === 15.U ||
                  in(2,0) === 7.U,   // 7, 15
                  false.B, false.B)

    val in3 = Cat(in(3,0) === 15.U,  // 15
                  false.B, false.B, false.B)

    (in0.asUInt, in1.asUInt, in2.asUInt, in3.asUInt)
  }
}

class Fifo4[T <: Data](t: T, n: Int) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(Vec(4, Valid(t))))
    val out = Decoupled(t)
    val count = Output(UInt(log2Ceil(n+1).W))
  })

  val m = n - 1  // n = Mem(n-1) + Slice

  def Increment(a: UInt, b: UInt): UInt = {
    val c = a +& b
    val d = Mux(c < m.U, c, c - m.U)(a.getWidth - 1, 0)
    d
  }

  val mem = Mem(m, t)
  val mslice = Slice(t, false, true)

  val in0pos = RegInit(0.U(log2Ceil(m).W))
  val in1pos = RegInit(1.U(log2Ceil(m).W))
  val in2pos = RegInit(2.U(log2Ceil(m).W))
  val in3pos = RegInit(3.U(log2Ceil(m).W))
  val outpos = RegInit(0.U(log2Ceil(m).W))
  val mcount = RegInit(0.U(log2Ceil(n+1).W))

  io.count := mcount + io.out.valid

  val ivalid = io.in.valid && io.in.ready
  val ovalid = mslice.io.in.valid && mslice.io.in.ready

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
  val dec = mslice.io.in.valid && mslice.io.in.ready

  when (ivalid || ovalid) {
    mcount := mcount + inc - dec
  }

  // ---------------------------------------------------------------------------
  // Fifo Input.
  val (in0valid, in1valid, in2valid, in3valid) = Fifo4Valid(iactive)

  for (i <- 0 until m) {
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

  mslice.io.in.valid := false.B
  mslice.io.in.bits := io.in.bits(0).bits  // defaults

  when (mcount > 0.U) {
    when (io.out.ready) {
      mslice.io.in.valid := true.B
    }
  } .otherwise {
    when (ivalid && iactive =/= 0.U) {
      mslice.io.in.valid := true.B
    }
  }

  when (mcount > 0.U) {
    mslice.io.in.bits := mem(outpos)
  } .elsewhen (ivalid) {
    // As above, couldn't get MuxOR to work.
    when (iactive(0)) {
      mslice.io.in.bits := io.in.bits(0).bits
    } .elsewhen (iactive(1)) {
      mslice.io.in.bits := io.in.bits(1).bits
    } .elsewhen (iactive(2)) {
      mslice.io.in.bits := io.in.bits(2).bits
    } .elsewhen (iactive(3)) {
      mslice.io.in.bits := io.in.bits(3).bits
    }
  }

  // ---------------------------------------------------------------------------
  // Valid Entries.
  val active = RegInit(0.U(m.W))

  val activeSet = MuxOR(ivalid,
      ((icount >= 1.U) << in0pos) | ((icount >= 2.U) << in1pos) |
      ((icount >= 3.U) << in2pos) | ((icount >= 4.U) << in3pos))

  val activeClr = MuxOR(mslice.io.in.valid && mslice.io.in.ready, 1.U << outpos)

  active := (active | activeSet) & ~activeClr

  // ---------------------------------------------------------------------------
  // Interface.
  io.in.ready := mcount <= (m.U - icount)
  io.out <> mslice.io.out

  assert(mcount <= m.U)
}

object EmitFifo4 extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Fifo4(UInt(8.W), 11), args)
}
