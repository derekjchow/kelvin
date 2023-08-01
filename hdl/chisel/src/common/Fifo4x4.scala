package common

import chisel3._
import chisel3.util._

object Fifo4x4 {
  def apply[T <: Data](t: T, n: Int) = {
    Module(new Fifo4x4(t, n))
  }
}

// Input accepted with a common handshake and per lane select.
// Outputs are transacted independently, and ordered {[0], [0,1], [0,1,2], [0,1,2,3]}.
// Outputs are not registered, assumes passes directly into shallow combinatorial.
class Fifo4x4[T <: Data](t: T, n: Int) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(Vec(4, Valid(t))))
    val out = Vec(4, Decoupled(t))
    val count = Output(UInt(log2Ceil(n+1).W))
    val nempty = Output(Bool())
  })

  val m = n

  val mb  = log2Ceil(m)
  val n1b = log2Ceil(n + 1)

  def Increment(a: UInt, b: UInt): UInt = {
    val c = a +& b
    val d = Mux(c < m.U, c, c - m.U)(a.getWidth - 1, 0)
    d
  }

  val mem = Reg(Vec(n, t))

  val inpos  = Reg(Vec(4, UInt(mb.W)))  // reset below
  val outpos = Reg(Vec(4, UInt(mb.W)))  // reset below

  val mcount = RegInit(0.U(n1b.W))
  val nempty = RegInit(false.B)
  val inready = RegInit(false.B)
  val outvalid = RegInit(0.U(4.W))

  val ivalid = io.in.valid && io.in.ready

  val iactive = Cat(io.in.bits(3).valid, io.in.bits(2).valid,
                    io.in.bits(1).valid, io.in.bits(0).valid).asUInt

  val icount = (io.in.bits(0).valid +& io.in.bits(1).valid +&
                io.in.bits(2).valid +& io.in.bits(3).valid)(2,0)

  val oactiveBits = Cat(io.out(3).valid && io.out(3).ready,
                        io.out(2).valid && io.out(2).ready,
                        io.out(1).valid && io.out(1).ready,
                        io.out(0).valid && io.out(0).ready)

  val ovalid = oactiveBits =/= 0.U

  val ocount = (oactiveBits(0) +& oactiveBits(1) +&
                oactiveBits(2) +& oactiveBits(3))(2,0)

  assert(!(oactiveBits(1) === 1.U && oactiveBits(0,0) =/= 1.U))
  assert(!(oactiveBits(2) === 1.U && oactiveBits(1,0) =/= 3.U))
  assert(!(oactiveBits(3) === 1.U && oactiveBits(2,0) =/= 7.U))

  val ovalidBits = Cat(io.out(3).valid, io.out(2).valid,
                       io.out(1).valid, io.out(0).valid)

  assert(!(ovalidBits(1) === 1.U && ovalidBits(0,0) =/= 1.U))
  assert(!(ovalidBits(2) === 1.U && ovalidBits(1,0) =/= 3.U))
  assert(!(ovalidBits(3) === 1.U && ovalidBits(2,0) =/= 7.U))

  val oreadyBits = Cat(io.out(3).ready, io.out(2).ready,
                       io.out(1).ready, io.out(0).ready)

  assert(!(oreadyBits(1) === 1.U && oreadyBits(0,0) =/= 1.U))
  assert(!(oreadyBits(2) === 1.U && oreadyBits(1,0) =/= 3.U))
  assert(!(oreadyBits(3) === 1.U && oreadyBits(2,0) =/= 7.U))

  // ---------------------------------------------------------------------------
  // Fifo Control.
  when (reset.asBool) {
    for (i <- 0 until 4) {
      inpos(i) := i.U
    }
  } .elsewhen (ivalid) {
    for (i <- 0 until 4) {
      inpos(i) := Increment(inpos(i), icount)
    }
  }

  when (reset.asBool) {
    for (i <- 0 until 4) {
      outpos(i) := i.U
    }
  } .elsewhen (ovalid) {
    for (i <- 0 until 4) {
      outpos(i) := Increment(outpos(i), ocount)
    }
  }

  val inc = MuxOR(ivalid, icount)
  val dec = MuxOR(ovalid, ocount)

  when (ivalid || ovalid) {
    val nxtmcount = mcount + inc - dec
    inready := nxtmcount <= (m.U - 4.U)
    mcount := nxtmcount
    nempty := nxtmcount =/= 0.U
    outvalid := Cat(nxtmcount >= 4.U,
                    nxtmcount >= 3.U,
                    nxtmcount >= 2.U,
                    nxtmcount >= 1.U)
  } .otherwise {
    inready := mcount <= (m.U - 4.U)
    outvalid := Cat(mcount >= 4.U,
                    mcount >= 3.U,
                    mcount >= 2.U,
                    mcount >= 1.U)
  }

  // ---------------------------------------------------------------------------
  // Fifo Input.
  val (in0valid, in1valid, in2valid, in3valid) = Fifo4Valid(iactive)

  for (i <- 0 until m) {
    val valid = Cat(inpos(0) === i.U && in0valid(3) ||
                    inpos(1) === i.U && in1valid(3) ||
                    inpos(2) === i.U && in2valid(3) ||
                    inpos(3) === i.U && in3valid(3),

                    inpos(0) === i.U && in0valid(2) ||
                    inpos(1) === i.U && in1valid(2) ||
                    inpos(2) === i.U && in2valid(2),

                    inpos(0) === i.U && in0valid(1) ||
                    inpos(1) === i.U && in1valid(1),

                    inpos(0) === i.U && in0valid(0))

    if (true) {
      val data = MuxOR(valid(0), io.in.bits(0).bits.asUInt) |
                 MuxOR(valid(1), io.in.bits(1).bits.asUInt) |
                 MuxOR(valid(2), io.in.bits(2).bits.asUInt) |
                 MuxOR(valid(3), io.in.bits(3).bits.asUInt)

      when (ivalid && valid =/= 0.U) {
        mem(i) := data.asTypeOf(t)
      }
    } else {
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
  }

  // ---------------------------------------------------------------------------
  // Interface.
  io.in.ready := inready

  for (i <- 0 until 4) {
    io.out(i).valid := outvalid(i)
    io.out(i).bits := mem(outpos(i))  // TODO: VecAt()
  }

  io.count := mcount

  io.nempty := nempty

  assert(io.count <= m.U)
}

object EmitFifo4x4 extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Fifo4x4(UInt(32.W), 24), args)
}
