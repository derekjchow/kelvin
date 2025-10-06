package bus

import chisel3._
import freechips.rocketchip.util.{AsyncQueue, AsyncQueueParams}
import coralnpu.Parameters

class TlulFifoAsync(
    p: TLULParameters,
    reqDepth: Int = 4,
    rspDepth: Int = 4,
    moduleName: String = "TlulFifoAsync"
) extends RawModule {
  override val desiredName = moduleName

  val io = IO(new Bundle {
    val clk_h_i = Input(Clock())
    val rst_h_i = Input(Bool())
    val clk_d_i = Input(Clock())
    val rst_d_i = Input(Bool())
    val tl_h = Flipped(new OpenTitanTileLink.Host2Device(p))
    val tl_d = new OpenTitanTileLink.Host2Device(p)
  })

  val req_queue = Module(new AsyncQueue(new OpenTitanTileLink.A_Channel(p), AsyncQueueParams(depth = reqDepth)))
  req_queue.io.enq_clock := io.clk_h_i
  req_queue.io.enq_reset := io.rst_h_i
  req_queue.io.deq_clock := io.clk_d_i
  req_queue.io.deq_reset := io.rst_d_i
  req_queue.io.enq <> io.tl_h.a
  io.tl_d.a <> req_queue.io.deq

  val rsp_queue = Module(new AsyncQueue(new OpenTitanTileLink.D_Channel(p), AsyncQueueParams(depth = rspDepth)))
  rsp_queue.io.enq_clock := io.clk_d_i
  rsp_queue.io.enq_reset := io.rst_d_i
  rsp_queue.io.deq_clock := io.clk_h_i
  rsp_queue.io.deq_reset := io.rst_h_i
  rsp_queue.io.enq <> io.tl_d.d
  io.tl_h.d <> rsp_queue.io.deq
}

import _root_.circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

@nowarn
object TlulFifoAsync128Emitter extends App {
  val p = new Parameters
  p.lsuDataBits = 128
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new TlulFifoAsync(
          p = new bus.TLULParameters(p),
          reqDepth = 1,
          rspDepth = 1,
          moduleName = "TlulFifoAsync128"
        )
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
