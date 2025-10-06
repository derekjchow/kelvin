package bus

import chisel3._
import chisel3.util._
import common.CoralNPURRArbiter
import coralnpu.Parameters


class TlulFifoSync_(p: TLULParameters,
                    reqDepth: Int,
                    rspDepth: Int,
                    reqPass: Boolean,
                    rspPass: Boolean,
                    socketName: String)
  extends TlulFifoSync(p, reqDepth, rspDepth, reqPass, rspPass) {
  override val desiredName = s"${socketName}_TlulFifoSync_d${reqDepth}r${rspDepth}"
}



class TlulSocketM1(
    p: TLULParameters,
    M: Int = 4,
    HReqPass: Seq[Boolean] = Nil,
    HRspPass: Seq[Boolean] = Nil,
    HReqDepth: Seq[Int] = Nil,
    HRspDepth: Seq[Int] = Nil,
    DReqPass: Boolean = true,
    DRspPass: Boolean = true,
    DReqDepth: Int = 1,
    DRspDepth: Int = 1,
    moduleName: String = "TlulSocketM1"
) extends Module {
  val HReqPass_ = if (HReqPass.isEmpty) Seq.fill(M)(true) else HReqPass
  val HRspPass_ = if (HRspPass.isEmpty) Seq.fill(M)(true) else HRspPass
  val HReqDepth_ = if (HReqDepth.isEmpty) Seq.fill(M)(1) else HReqDepth
  val HRspDepth_ = if (HRspDepth.isEmpty) Seq.fill(M)(1) else HRspDepth
  override val desiredName = moduleName
  val StIdW = log2Ceil(M)

  val io = IO(new Bundle {
    val tl_h = Flipped(Vec(M, new OpenTitanTileLink.Host2Device(p)))
    val tl_d = new OpenTitanTileLink.Host2Device(p)
  })

  // Host-side FIFOs
  val hreq_fifo_o = Wire(Vec(M, Decoupled(new OpenTitanTileLink.A_Channel(p))))
  val hrsp_fifo_i = Wire(Vec(M, Flipped(Decoupled(new OpenTitanTileLink.D_Channel(p)))))

  for (i <- 0 until M) {
    val hreq_fifo_i = Wire(new OpenTitanTileLink.A_Channel(p))
    hreq_fifo_i := io.tl_h(i).a.bits
    hreq_fifo_i.source := Cat(io.tl_h(i).a.bits.source, i.U(StIdW.W))

    val fifo = Module(new TlulFifoSync_(
      p,
      reqDepth = HReqDepth_(i),
      rspDepth = HRspDepth_(i),
      reqPass = HReqPass_(i),
      rspPass = HRspPass_(i),
      socketName = moduleName
    ))
    fifo.io.host.a.valid := io.tl_h(i).a.valid
    fifo.io.host.a.bits := hreq_fifo_i
    io.tl_h(i).a.ready := fifo.io.host.a.ready

    hreq_fifo_o(i) <> fifo.io.device.a

    io.tl_h(i).d <> fifo.io.host.d
    fifo.io.device.d <> hrsp_fifo_i(i)

    fifo.io.spare_req_i := 0.U
    fifo.io.spare_rsp_i := 0.U
  }

  // Arbiter
  val arb = Module(new CoralNPURRArbiter(new OpenTitanTileLink.A_Channel(p), M, moduleName = Some(s"${moduleName}_CoralNPURRArbiter_${M}")))
  for (i <- 0 until M) {
    arb.io.in(i) <> hreq_fifo_o(i)
  }

  // Device-side FIFO
  val dfifo = Module(new TlulFifoSync_(
    p,
    reqDepth = DReqDepth,
    rspDepth = DRspDepth,
    reqPass = DReqPass,
    rspPass = DRspPass,
    socketName = moduleName
  ))

  dfifo.io.host.a <> arb.io.out
  io.tl_d.a <> dfifo.io.device.a
  dfifo.io.device.d <> io.tl_d.d
  dfifo.io.spare_req_i := 0.U
  dfifo.io.spare_rsp_i := 0.U

  // Response steering
  val rsp_arb_grant = Mux(io.tl_d.d.valid, UIntToOH(io.tl_d.d.bits.source(StIdW - 1, 0)), 0.U(M.W))
  for (i <- 0 until M) {
    hrsp_fifo_i(i).valid := io.tl_d.d.valid && rsp_arb_grant(i)
    hrsp_fifo_i(i).bits := io.tl_d.d.bits
    hrsp_fifo_i(i).bits.source := io.tl_d.d.bits.source >> StIdW
  }
  io.tl_d.d.ready := (VecInit(hrsp_fifo_i.map(_.ready)).asUInt & rsp_arb_grant).orR
  dfifo.io.host.d.ready := (VecInit(hrsp_fifo_i.map(_.ready)).asUInt & rsp_arb_grant).orR
}

import _root_.circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

@nowarn
object TlulSocketM1_2_128Emitter extends App {
  val p = new Parameters
  p.lsuDataBits = 128
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new TlulSocketM1(
          p = new bus.TLULParameters(p),
          M = 2,
          HReqDepth = Seq.fill(2)(0),
          HRspDepth = Seq.fill(2)(0),
          DReqDepth = 0,
          DRspDepth = 0,
          moduleName = "TlulSocketM1_2_128"
        )
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}

@nowarn
object TlulSocketM1_3_128Emitter extends App {
  val p = new Parameters
  p.lsuDataBits = 128
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new TlulSocketM1(
          p = new bus.TLULParameters(p),
          M = 3,
          HReqDepth = Seq.fill(3)(0),
          HRspDepth = Seq.fill(3)(0),
          DReqDepth = 0,
          DRspDepth = 0,
          moduleName = "TlulSocketM1_3_128"
        )
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
