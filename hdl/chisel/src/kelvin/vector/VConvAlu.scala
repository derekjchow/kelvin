package kelvin

import chisel3._
import chisel3.util._

object VConvAlu {
  def apply(p: Parameters): VConvAlu = {
    return Module(new VConvAlu(p))
  }
}

class VConvAlu(p: Parameters) extends Module {
  val tcnt = p.vectorBits / 32

  val io = IO(new Bundle {
    val op = new Bundle {
      val conv  = Input(Bool())  // convolution
      val init  = Input(Bool())  // initialize
      val tran  = Input(Bool())  // transpose
      val clear = Input(Bool())  // clear accumulator
    }
    val index = Input(UInt(log2Ceil(tcnt).W))
    val adata = Input(UInt((tcnt * 32).W))
    val bdata = Input(UInt((tcnt * 32).W))
    val abias = Input(UInt(9.W))
    val bbias = Input(UInt(9.W))
    val asign = Input(Bool())
    val bsign = Input(Bool())
    val out = Output(Vec(tcnt, UInt((tcnt * 32).W)))
  })

  // MatMul
  //   B B B B
  // A . . . .
  // A . . . .
  // A . . . .
  // A . . . .

  val acc = Reg(Vec(tcnt, Vec(tcnt, UInt(32.W))))

  assert(PopCount(Cat(io.op.conv, io.op.tran, io.op.clear)) <= 1.U)

  // ---------------------------------------------------------------------------
  // Output interleave to match shift reductions.
  def Interleave(i: Int, j: Int): (Int, Int) = {
    val interleave = Seq(0, 2, 1, 3);
    val rbase = i & ~3;
    val rquad = i & 3;
    val word  = j;
    val si = rbase + interleave(word & 3);
    val sj = rquad * (tcnt / 4) + (word / 4);
    (si, sj)
  }

  // ---------------------------------------------------------------------------
  // Matrix Multiply.
  val dpa = Wire(Vec(tcnt, Vec(tcnt, UInt(32.W))))  // dot product accumulate

  for (i <- 0 until tcnt) {
    for (j <- 0 until tcnt) {
      val accum = MuxOR(io.op.conv, acc(i)(j))
      dpa(i)(j) := accum + VDot(io.op.conv,
          io.adata(i * 32 + 31, i * 32), io.bdata(j * 32 + 31, j * 32),
          io.abias, io.bbias, io.asign, io.bsign)
    }
  }

  // ---------------------------------------------------------------------------
  // Parallel load.
  val pload = MuxOR(io.op.tran, io.adata) |
              MuxOR(io.op.init, io.bdata)

  // ---------------------------------------------------------------------------
  // Accumulators.
  for (i <- 0 until tcnt) {
    for (j <- 0 until tcnt) {
      val (si, sj) = Interleave(i, j)

      val aclr = io.op.clear || reset.asBool
      val conv = io.op.conv
      val load = (io.op.init || io.op.tran) && si.U === io.index

      when (aclr || conv || load) {
        acc(i)(j) := Mux(conv, dpa(i)(j),
                         pload(sj * 32 + 31, sj * 32))
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Outputs.
  val out = Wire(Vec(tcnt, Vec(tcnt, UInt(32.W))))

  for (i <- 0 until tcnt) {
    for (j <- 0 until tcnt) {
      val (si, sj) = Interleave(i, j)
      out(si)(sj) := acc(i)(j)
    }
  }

  for (i <- 0 until tcnt) {
    io.out(i) := out(i).asUInt
  }
}

object EmitVConvAlu extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new VConvAlu(p), args)
}
