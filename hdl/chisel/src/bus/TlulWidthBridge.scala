package bus

import chisel3._
import chisel3.util._
import common.FifoX

class TlulWidthBridge(val host_p: TLULParameters, val device_p: TLULParameters) extends Module {
  val io = IO(new Bundle {
    val tl_h = Flipped(new OpenTitanTileLink.Host2Device(host_p))
    val tl_d = new OpenTitanTileLink.Host2Device(device_p)

    val fault_a_o = Output(Bool())
    val fault_d_o = Output(Bool())
  })

  // ==========================================================================
  // Parameters and Constants
  // ==========================================================================
  val hostWidth = host_p.w * 8
  val deviceWidth = device_p.w * 8

  // Default fault outputs
  io.fault_a_o := false.B
  io.fault_d_o := false.B

  // ==========================================================================
  // Wide to Narrow Path (e.g., 128-bit host to 32-bit device)
  // ==========================================================================
  if (hostWidth > deviceWidth) {
    val ratio = hostWidth / deviceWidth
    val narrowBytes = deviceWidth / 8
    val hostBytes = hostWidth / 8

    // ------------------------------------------------------------------------
    // Response Path (D Channel): Assemble narrow responses into a wide one
    // ------------------------------------------------------------------------
    val d_data_reg = RegInit(VecInit(Seq.fill(ratio)(0.U(deviceWidth.W))))
    val d_resp_reg = RegInit(0.U.asTypeOf(new OpenTitanTileLink.D_Channel(host_p)))
    val d_valid_reg = RegInit(false.B)
    val beat_count = RegInit(0.U(log2Ceil(ratio+1).W))
    val d_fault_reg = RegInit(false.B)

    val d_check = Module(new ResponseIntegrityCheck(device_p))
    d_check.io.d_i := io.tl_d.d.bits
    io.fault_d_o := d_fault_reg

    val d_gen = Module(new ResponseIntegrityGen(host_p))
    val wide_resp = Wire(new OpenTitanTileLink.D_Channel(host_p))
    wide_resp := d_resp_reg

    val req_info_q = Module(new Queue(new Bundle {
      val source = UInt(host_p.o.W)
      val beats = UInt(log2Ceil(ratio+1).W)
      val offset = UInt(log2Ceil(hostBytes).W)
      val size = UInt(host_p.z.W)
    }, 2))

    wide_resp.source := req_info_q.io.deq.bits.source
    wide_resp.size := req_info_q.io.deq.bits.size
    wide_resp.data := d_data_reg.asUInt
    d_gen.io.d_i := wide_resp

    io.tl_d.d.ready := !d_valid_reg
    io.tl_h.d.valid := d_valid_reg
    io.tl_h.d.bits := d_gen.io.d_o
    io.tl_h.d.bits.data := (d_data_reg.asUInt >> (req_info_q.io.deq.bits.offset << 3.U)).asUInt
    io.tl_h.d.bits.error := d_resp_reg.error || d_fault_reg

    when(io.tl_d.d.fire) {
      // On the first beat, clear any fault and check for a new one.
      // On subsequent beats, make the fault sticky.
      when(beat_count === 0.U) {
        d_fault_reg := d_check.io.fault
      }.otherwise {
        when(d_check.io.fault) {
          d_fault_reg := true.B
        }
      }

      val beat_index = (io.tl_d.d.bits.source - req_info_q.io.deq.bits.source)(log2Ceil(ratio)-1, 0)
      d_data_reg(beat_index) := io.tl_d.d.bits.data
      d_resp_reg := io.tl_d.d.bits
      d_resp_reg.size := req_info_q.io.deq.bits.size
      beat_count := beat_count + 1.U
      when(beat_count === (req_info_q.io.deq.bits.beats - 1.U)) {
        d_valid_reg := true.B
      }
    }

    when(io.tl_h.d.fire) {
      d_valid_reg := false.B
      d_fault_reg := false.B
      beat_count := 0.U
      req_info_q.io.deq.ready := true.B
    }.otherwise {
      req_info_q.io.deq.ready := false.B
    }

    // ------------------------------------------------------------------------
    // Request Path (A Channel): Split wide request into multiple narrow ones
    // ------------------------------------------------------------------------
    val a_check = Module(new RequestIntegrityCheck(host_p))
    a_check.io.a_i := io.tl_h.a.bits
    io.fault_a_o := a_check.io.fault

    val req_fifo = Module(new FifoX(new OpenTitanTileLink.A_Channel(device_p), ratio, ratio + 1))

    val beats = Wire(Vec(ratio, Valid(new OpenTitanTileLink.A_Channel(device_p))))
    req_fifo.io.in.bits := beats

    val is_write = io.tl_h.a.bits.opcode === TLULOpcodesA.PutFullData.asUInt ||
                   io.tl_h.a.bits.opcode === TLULOpcodesA.PutPartialData.asUInt

    val align_mask = (~(hostBytes - 1).U(host_p.a.W))
    val aligned_address = io.tl_h.a.bits.address & align_mask
    val address_offset = io.tl_h.a.bits.address(log2Ceil(hostBytes) - 1, 0)

    val size_in_bytes = 1.U << io.tl_h.a.bits.size
    val read_mask = (((1.U << size_in_bytes) - 1.U) << address_offset)(hostBytes - 1, 0)
    val effective_mask = Mux(is_write, io.tl_h.a.bits.mask, read_mask)

    for (i <- 0 until ratio) {
      val req_gen = Module(new RequestIntegrityGen(device_p))

      val narrow_req = Wire(new OpenTitanTileLink.A_Channel(device_p))
      val narrow_mask = (effective_mask >> (i * narrowBytes)).asUInt(narrowBytes-1, 0)
      val is_full_beat = narrow_mask === ((1 << narrowBytes) - 1).U
      narrow_req.opcode := Mux(is_write,
                             Mux(io.tl_h.a.bits.opcode === TLULOpcodesA.PutFullData.asUInt && is_full_beat,
                                 TLULOpcodesA.PutFullData.asUInt,
                                 TLULOpcodesA.PutPartialData.asUInt),
                             io.tl_h.a.bits.opcode)
      narrow_req.param   := io.tl_h.a.bits.param
      narrow_req.size    := log2Ceil(device_p.w).U
      narrow_req.source  := io.tl_h.a.bits.source + i.U
      narrow_req.address := aligned_address + (i * narrowBytes).U
      narrow_req.mask    := narrow_mask
      narrow_req.data    := (io.tl_h.a.bits.data >> (i * deviceWidth)).asUInt
      narrow_req.user    := io.tl_h.a.bits.user

      req_gen.io.a_i := narrow_req
      beats(i).bits := req_gen.io.a_o
      beats(i).valid := narrow_mask =/= 0.U
    }

    io.tl_d.a <> req_fifo.io.out
    req_fifo.io.in.valid := io.tl_h.a.valid && !a_check.io.fault && req_info_q.io.enq.ready
    io.tl_h.a.ready := req_fifo.io.in.ready && !a_check.io.fault && req_info_q.io.enq.ready

    val total_beats = PopCount(beats.map(_.valid))

    req_info_q.io.enq.valid := io.tl_h.a.fire
    req_info_q.io.enq.bits.source := io.tl_h.a.bits.source
    req_info_q.io.enq.bits.beats := total_beats
    req_info_q.io.enq.bits.offset := address_offset
    req_info_q.io.enq.bits.size := io.tl_h.a.bits.size
    assert(!req_info_q.io.enq.valid || req_info_q.io.enq.ready)

  // ==========================================================================
  // Narrow to Wide Path (e.g., 32-bit host to 128-bit device)
  // ==========================================================================
  } else if (hostWidth < deviceWidth) {
    val wideBytes = deviceWidth / 8
    val numSourceIds = 1 << host_p.i
    val addr_lsb_width = log2Ceil(wideBytes)
    val index_width = log2Ceil(numSourceIds)
    val addr_lsb_regs = RegInit(VecInit(Seq.fill(numSourceIds)(0.U(addr_lsb_width.W))))

    val req_addr_lsb = io.tl_h.a.bits.address(addr_lsb_width - 1, 0)

    when (io.tl_h.a.fire) {
      addr_lsb_regs(io.tl_h.a.bits.source(index_width-1, 0)) := req_addr_lsb
    }

    val a_check = Module(new RequestIntegrityCheck(host_p))
    a_check.io.a_i := io.tl_h.a.bits
    io.fault_a_o := a_check.io.fault

    val a_gen = Module(new RequestIntegrityGen(device_p))
    val wide_req = Wire(new OpenTitanTileLink.A_Channel(device_p))
    val is_put_full = io.tl_h.a.bits.opcode === TLULOpcodesA.PutFullData.asUInt
    val align_mask = ~((deviceWidth / 8) - 1).U(host_p.a.W)

    wide_req.opcode  := Mux(is_put_full, TLULOpcodesA.PutPartialData.asUInt, io.tl_h.a.bits.opcode)
    wide_req.param   := io.tl_h.a.bits.param
    wide_req.size    := log2Ceil(device_p.w).U
    wide_req.source  := io.tl_h.a.bits.source
    wide_req.address := io.tl_h.a.bits.address & align_mask
    wide_req.user    := io.tl_h.a.bits.user
    wide_req.mask    := (io.tl_h.a.bits.mask.asUInt << req_addr_lsb).asUInt
    wide_req.data    := (io.tl_h.a.bits.data.asUInt << (req_addr_lsb << 3.U)).asUInt
    a_gen.io.a_i := wide_req

    io.tl_d.a.valid := io.tl_h.a.valid && !a_check.io.fault
    io.tl_d.a.bits := a_gen.io.a_o
    io.tl_h.a.ready := io.tl_d.a.ready && !a_check.io.fault

    val d_check = Module(new ResponseIntegrityCheck(device_p))
    d_check.io.d_i := io.tl_d.d.bits
    io.fault_d_o := d_check.io.fault

    val d_gen = Module(new ResponseIntegrityGen(host_p))
    val narrow_resp = Wire(new OpenTitanTileLink.D_Channel(host_p))
    val resp_addr_lsb = addr_lsb_regs(io.tl_d.d.bits.source(index_width-1, 0))
    narrow_resp := io.tl_d.d.bits
    narrow_resp.source := io.tl_d.d.bits.source
    narrow_resp.data := (io.tl_d.d.bits.data >> (resp_addr_lsb << 3.U)).asUInt
    narrow_resp.error := io.tl_d.d.bits.error || d_check.io.fault
    d_gen.io.d_i := narrow_resp

    io.tl_h.d.valid := io.tl_d.d.valid
    io.tl_h.d.bits := d_gen.io.d_o
    io.tl_d.d.ready := io.tl_h.d.ready

  // ==========================================================================
  // Equal Widths Path
  // ==========================================================================
  } else {
    // Widths are equal, just pass through
    io.tl_d <> io.tl_h
  }
}
