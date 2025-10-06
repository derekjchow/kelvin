package bus

import chisel3._
import chisel3.util._
import common.MakeInvalid
import coralnpu.Parameters

// A simple error responder that immediately generates an error response
// for any incoming request.
class TlulErrorResponder(p: TLULParameters) extends Module {
  val io = IO(new Bundle {
    val tl_h = Flipped(new OpenTitanTileLink.Host2Device(p))
  })

  io.tl_h.a.ready := true.B

  val d = RegInit(MakeInvalid(new OpenTitanTileLink.D_Channel(p)))

  d.valid := io.tl_h.a.fire
  d.bits.size := Mux(io.tl_h.a.fire, io.tl_h.a.bits.size, d.bits.size)
  d.bits.source := Mux(io.tl_h.a.fire, io.tl_h.a.bits.source, d.bits.source)
  d.bits.opcode := TLULOpcodesD.AccessAck.asUInt
  d.bits.param := 0.U
  d.bits.sink := 0.U
  d.bits.data := 0.U
  d.bits.error := true.B
  d.bits.user.rsp_intg := 0.U
  d.bits.user.data_intg := 0.U

  io.tl_h.d.valid := d.valid
  io.tl_h.d.bits := d.bits
}

class TlulSocket1N(
    p: TLULParameters,
    N: Int = 4,
    HReqPass: Boolean = true,
    HRspPass: Boolean = true,
    DReqPass: Seq[Boolean] = Nil,
    DRspPass: Seq[Boolean] = Nil,
    HReqDepth: Int = 1,
    HRspDepth: Int = 1,
    DReqDepth: Seq[Int] = Nil,
    DRspDepth: Seq[Int] = Nil,
    ExplicitErrs: Boolean = true,
    moduleName: String = "TlulSocket1N"
) extends Module {
  val DReqPass_ = if (DReqPass.isEmpty) Seq.fill(N)(true) else DReqPass
  val DRspPass_ = if (DRspPass.isEmpty) Seq.fill(N)(true) else DRspPass
  val DReqDepth_ = if (DReqDepth.isEmpty) Seq.fill(N)(1) else DReqDepth
  val DRspDepth_ = if (DRspDepth.isEmpty) Seq.fill(N)(1) else DRspDepth
  override val desiredName = moduleName
  val NWD = if (ExplicitErrs) log2Ceil(N + 1) else log2Ceil(N)

  val io = IO(new Bundle {
    val tl_h = Flipped(new OpenTitanTileLink.Host2Device(p))
    val tl_d = Vec(N, new OpenTitanTileLink.Host2Device(p))
    val dev_select_i = Input(UInt(NWD.W))
  })

  // Host-side FIFO
  val fifo_h = Module(
    new TlulFifoSync(
      p,
      reqDepth = HReqDepth,
      rspDepth = HRspDepth,
      reqPass = HReqPass,
      rspPass = HRspPass,
      spareReqW = NWD
    )
  )

  fifo_h.io.host <> io.tl_h
  fifo_h.io.spare_req_i := io.dev_select_i
  fifo_h.io.spare_rsp_i := 0.U // Tie off unused spare port
  val dev_select_t = fifo_h.io.spare_req_o

  // Outstanding request tracking
  val maxOutstanding = 1 << p.o
  val outstandingW = log2Ceil(maxOutstanding + 1)
  val num_req_outstanding = RegInit(0.U(outstandingW.W))
  val dev_select_outstanding = RegInit(0.U(NWD.W))
  val accept_t_req = fifo_h.io.device.a.fire
  val accept_t_rsp = fifo_h.io.device.d.fire

  when(accept_t_req) {
    dev_select_outstanding := dev_select_t
    when(!accept_t_rsp) {
      num_req_outstanding := num_req_outstanding + 1.U
    }
  }.elsewhen(accept_t_rsp) {
    num_req_outstanding := num_req_outstanding - 1.U
  }

  val hold_all_requests =
    (num_req_outstanding =/= 0.U) && (dev_select_t =/= dev_select_outstanding)

  // Device-side FIFOs and steering logic
  val tl_u_o = Wire(Vec(N + 1, new OpenTitanTileLink.Host2Device(p)))
  val tl_u_i = Wire(Vec(N + 1, new OpenTitanTileLink.Host2Device(p)))

  val blanked_auser = Wire(new OpenTitanTileLink_A_User)
  blanked_auser.rsvd := fifo_h.io.device.a.bits.user.rsvd
  blanked_auser.instr_type := fifo_h.io.device.a.bits.user.instr_type
  blanked_auser.cmd_intg := 0.U // Simplified for now
  blanked_auser.data_intg := 0.U // Simplified for now

  for (i <- 0 until N) {
    val dev_select = (dev_select_t === i.U) && !hold_all_requests

    tl_u_o(i).a.valid := fifo_h.io.device.a.valid && dev_select
    tl_u_o(i).a.bits := fifo_h.io.device.a.bits
    tl_u_o(i).a.bits.user := Mux(
      dev_select,
      fifo_h.io.device.a.bits.user,
      blanked_auser
    )
    tl_u_o(i).d.ready := fifo_h.io.device.d.ready

    val fifo_d = Module(
      new TlulFifoSync(
        p,
        reqDepth = DReqDepth_(i),
        rspDepth = DRspDepth_(i),
        reqPass = DReqPass_(i),
        rspPass = DRspPass_(i)
      )
    )
    fifo_d.io.host.a <> tl_u_o(i).a
    io.tl_d(i).a <> fifo_d.io.device.a
    tl_u_i(i).a := fifo_d.io.device.a

    tl_u_o(i).d <> fifo_d.io.host.d
    io.tl_d(i).d <> fifo_d.io.device.d
    tl_u_i(i).d := fifo_d.io.device.d

    fifo_d.io.spare_req_i := 0.U
    fifo_d.io.spare_rsp_i := 0.U
  }

  // Error responder instantiation
  if (ExplicitErrs && (1 << NWD) > N) {
    val err_resp = Module(new TlulErrorResponder(p))
    tl_u_o(N).a.valid := fifo_h.io.device.a.valid && (dev_select_t >= N.U) && !hold_all_requests
    tl_u_o(N).a.bits := fifo_h.io.device.a.bits
    tl_u_o(N).d.ready := fifo_h.io.device.d.ready
    err_resp.io.tl_h.a <> tl_u_o(N).a
    tl_u_o(N).d <> err_resp.io.tl_h.d

    tl_u_i(N).a.ready := err_resp.io.tl_h.a.ready
    tl_u_i(N).d <> err_resp.io.tl_h.d
    tl_u_i(N).d.ready := true.B

    // Tie off unused outputs of the wire to prevent "not fully initialized" errors
    tl_u_i(N).a.valid := false.B
    tl_u_i(N).a.bits := 0.U.asTypeOf(new OpenTitanTileLink.A_Channel(p))
  } else {
    tl_u_o(N).a.valid := false.B
    tl_u_o(N).a.bits := DontCare
    tl_u_o(N).d.ready := false.B
    tl_u_i(N).a.ready := false.B
    tl_u_i(N).d.valid := false.B
    tl_u_i(N).d.bits := DontCare
    tl_u_i(N).d.ready := false.B
  }

  // Response path selection
  val hfifo_reqready = Mux(
    hold_all_requests,
    false.B,
    MuxCase(
      // Default to error responder ready if it exists
      if (ExplicitErrs && (1 << NWD) > N) tl_u_o(N).a.ready else true.B,
      (0 until N).map(i => (dev_select_t === i.U) -> tl_u_o(i).a.ready)
    )
  )
  fifo_h.io.device.a.ready := fifo_h.io.device.a.valid && hfifo_reqready

  val tl_t_p = MuxCase(
    // Default to error responder if it exists
    tl_u_i(N).d.bits,
    (0 until N).map(i =>
      (dev_select_outstanding === i.U) -> tl_u_i(i).d.bits
    )
  )
  val d_valid = MuxCase(
    tl_u_i(N).d.valid,
    (0 until N).map(i => (dev_select_outstanding === i.U) -> tl_u_i(i).d.valid)
  )

  fifo_h.io.device.d.valid := d_valid
  fifo_h.io.device.d.bits := tl_t_p
}

import _root_.circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

@nowarn
object TlulSocket1N_128Emitter extends App {
  val p = new Parameters
  p.lsuDataBits = 128
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new TlulSocket1N(
          p = new bus.TLULParameters(p),
          N = 4, // Default value, will be overridden at instantiation
          DReqPass = Seq.fill(4)(true),
          DRspPass = Seq.fill(4)(true),
          DReqDepth = Seq.fill(4)(1),
          DRspDepth = Seq.fill(4)(1),
          moduleName = "TlulSocket1N_128"
        )
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
