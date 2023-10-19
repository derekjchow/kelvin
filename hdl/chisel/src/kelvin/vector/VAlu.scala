/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package kelvin

import chisel3._
import chisel3.util._
import common._

object VAlu {
  def apply(p: Parameters): VAlu = {
    return Module(new VAlu(p))
  }
}

class VAlu(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Instructions.
    val in = Flipped(Decoupled(Vec(4, Valid(new VDecodeBits))))
    val active = Output(UInt(64.W))

    // VRegfile.
    val vrfsb = Input(UInt(128.W))
    val read  = Vec(7, new VRegfileReadIO(p))
    val write = Vec(4, new VRegfileWriteIO(p))
    val whint = Vec(4, new VRegfileWhintIO(p))
    val scalar = Vec(2, new VRegfileScalarIO(p))

    // Testbench signals.
    val read_0_ready = Output(Bool())
    val read_1_ready = Output(Bool())
    val read_2_ready = Output(Bool())
    val read_3_ready = Output(Bool())
    val read_4_ready = Output(Bool())
    val read_5_ready = Output(Bool())
    val read_6_ready = Output(Bool())
  })

  val cmdqDepth = 8

  val e = new VEncodeOp()

  // ---------------------------------------------------------------------------
  // Tie-offs.
  for (i <- 0 until 7) {
    io.read(i).valid := false.B
    io.read(i).addr := 0.U
    io.read(i).tag  := 0.U
  }

  for (i <- 0 until 4) {
    io.write(i).valid := false.B
    io.write(i).addr := 0.U
    io.write(i).data := 0.U
  }

  for (i <- 0 until 4) {
    io.whint(i).valid := false.B
    io.whint(i).addr := 0.U
  }

  // ---------------------------------------------------------------------------
  // Opcode checks.
  for (i <- 0 until 4) {
    when (io.in.valid && io.in.ready) {
      when (io.in.bits(i).valid) {
        val op = io.in.bits(i).bits.op
        val supported =
            // Arithmetic
            op === e.vabsd.U ||
            op === e.vacc.U ||
            op === e.vadd.U ||
            op === e.vadds.U ||
            op === e.vaddw.U ||
            op === e.vadd3.U ||
            op === e.vdup.U ||
            op === e.vhadd.U ||
            op === e.vhsub.U ||
            op === e.vmax.U ||
            op === e.vmin.U ||
            op === e.vpadd.U ||
            op === e.vpsub.U ||
            op === e.vrsub.U ||
            op === e.vsub.U ||
            op === e.vsubs.U ||
            op === e.vsubw.U ||
            // Compare.
            op === e.veq.U ||
            op === e.vne.U ||
            op === e.vlt.U ||
            op === e.vle.U ||
            op === e.vgt.U ||
            op === e.vge.U ||
            // Logical.
            op === e.vand.U ||
            op === e.vclb.U ||
            op === e.vclz.U ||
            op === e.vcpop.U ||
            op === e.vmv.U ||
            op === e.vmv2.U ||
            op === e.vmvp.U ||
            op === e.adwinit.U ||
            op === e.vnot.U ||
            op === e.vor.U ||
            op === e.vrev.U ||
            op === e.vror.U ||
            op === e.vxor.U ||
            // Shift.
            op === e.vshl.U ||
            op === e.vshr.U ||
            op === e.vshf.U ||
            op === e.vsrans.U ||
            op === e.vsraqs.U ||
            // Multiply.
            op === e.vdmulh.U ||
            op === e.vdmulh2.U ||
            op === e.vmadd.U ||
            op === e.vmul.U ||
            op === e.vmul2.U ||
            op === e.vmulh.U ||
            op === e.vmulh2.U ||
            op === e.vmuls.U ||
            op === e.vmuls2.U ||
            op === e.vmulw.U ||
            // Shuffle.
            op === e.vslidevn.U ||
            op === e.vslidevp.U ||
            op === e.vslidehn2.U ||
            op === e.vslidehp2.U ||
            op === e.vsel.U ||
            op === e.vevn.U ||
            op === e.vodd.U ||
            op === e.vevnodd.U ||
            op === e.vzip.U ||
            // ML
            op === e.vdwconv.U ||
            op === e.adwconv.U

        when (!supported) {
          printf("**Op=%d unsupported\n", op)
        }
        assert(supported)

        assert(!(io.in.bits(i).bits.vt.valid && io.in.bits(i).bits.sv.valid))

        when (op === e.vdwconv.U || op === e.adwconv.U) {
          val sparse = io.in.bits(i).bits.sv.data(3,2)
          assert(io.in.bits(i).bits.m === false.B)
          assert(io.in.bits(i).bits.sz === 4.U)
          assert(io.in.bits(i).bits.sv.valid === false.B)
          assert(sparse < 3.U)
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Command Queue.
  class VAluCmdq extends Bundle {
    val op = UInt(new VEncodeOp().bits.W)
    val f2 = UInt(3.W)
    val sz = UInt(3.W)
    val vd = new VAddr()
    val ve = new VAddr()
    val vs = new VAddrTag()
    val vt = new VAddrTag()
    val vu = new VAddrTag()
    val sv = new SData()
    val cmdsync = Bool()
  }

  def Fin(in: VDecodeBits, alu: Int): VAluCmdq = {
    val out = Wire(new VAluCmdq)
    out.op := in.op
    out.f2 := in.f2
    out.sz := in.sz
    out.cmdsync := in.cmdsync
    when ((alu == 0).B || !in.cmdsync) {
      out.vd := in.vd
      out.ve := in.ve
      out.vs := in.vs
      out.vt := in.vt
      out.vu := in.vu
    } .otherwise {
      out.vd := in.vf
      out.ve := in.vg
      out.vs := in.vx
      out.vt := in.vy
      out.vu := in.vz
    }
    out.sv := in.sv
    out
  }

  def Fin0(in: VDecodeBits): VAluCmdq = {
    Fin(in, 0)
  }

  def Fin1(in: VDecodeBits): VAluCmdq = {
    Fin(in, 1)
  }

  def Fout(in: VAluCmdq, m: Bool, step: UInt, valid: Bool): (VAluCmdq, Bool) = {
    val vevnodd = in.op === e.vevn.U || in.op === e.vodd.U || in.op === e.vevnodd.U
    val vzip = in.op === e.vzip.U
    val out = Wire(new VAluCmdq)
    val last = !m || step === 3.U
    out := in
    out.vd.addr := in.vd.addr + 1.U
    out.ve.addr := in.ve.addr + 1.U
    out.vs.addr := in.vs.addr + 1.U
    out.vt.addr := in.vt.addr + 1.U
    out.vu.addr := in.vu.addr + 1.U
    when (m && vevnodd) {
      out.vu.addr := in.vu.addr
      when (step === 1.U) {  // halfway
        out.vs.addr := in.vu.addr + 0.U
        out.vt.addr := in.vu.addr + 1.U
      } .otherwise {
        out.vs.addr := in.vs.addr + 2.U
        out.vt.addr := in.vt.addr + 2.U
      }
    }
    when (vzip) {
      assert(in.ve.addr === (in.vd.addr + 1.U))
      out.vd.addr := in.vd.addr + 2.U
      out.ve.addr := in.ve.addr + 2.U
    }
    (out, last)
  }

  def Factive(in: VAluCmdq, m: Bool, step: UInt): UInt = {
    assert(step.getWidth == 5)
    assert(step <= 4.U)
    // Only reads are reported in active, vrfsb tracks writes.
    val active = MuxOR(in.vs.valid, RegActive(m, step(2,0), in.vs.addr)) |
                 MuxOR(in.vt.valid, RegActive(m, step(2,0), in.vt.addr)) |
                 MuxOR(in.vu.valid, RegActive(m, step(2,0), in.vu.addr))
    assert(active.getWidth == 64)
    active
  }

  val q0 = VCmdq(cmdqDepth, new VAluCmdq, Fin0, Fout, Factive)
  val q1 = VCmdq(cmdqDepth, new VAluCmdq, Fin1, Fout, Factive)

  q0.io.in.valid := io.in.valid && q1.io.in.ready
  q1.io.in.valid := io.in.valid && q0.io.in.ready
  io.in.ready := q0.io.in.ready && q1.io.in.ready

  q0.io.in.bits := io.in.bits
  q1.io.in.bits := io.in.bits

  val q0ready = ScoreboardReady(q0.io.out.bits.vs, io.vrfsb) &&
                ScoreboardReady(q0.io.out.bits.vt, io.vrfsb) &&
                ScoreboardReady(q0.io.out.bits.vu, io.vrfsb)

  val q1ready = ScoreboardReady(q1.io.out.bits.vs, io.vrfsb) &&
                ScoreboardReady(q1.io.out.bits.vt, io.vrfsb) &&
                ScoreboardReady(q1.io.out.bits.vu, io.vrfsb)

  q0.io.out.ready := q0ready && (!q0.io.out.bits.cmdsync || q1.io.out.valid && q1ready && q1.io.out.bits.cmdsync)
  q1.io.out.ready := q1ready && (!q1.io.out.bits.cmdsync || q0.io.out.valid && q0ready && q0.io.out.bits.cmdsync)

  // ---------------------------------------------------------------------------
  // ALU Selection interleaving.
  val alureg = RegInit(false.B)
  val alusel = Wire(Vec(5, Bool()))

  // Toggle if previous was valid and was not a synchronized dual command.
  alusel(0) := alureg
  alusel(1) := Mux(io.in.bits(0).valid && !io.in.bits(0).bits.cmdsync, !alusel(0), alusel(0))
  alusel(2) := Mux(io.in.bits(1).valid && !io.in.bits(1).bits.cmdsync, !alusel(1), alusel(1))
  alusel(3) := Mux(io.in.bits(2).valid && !io.in.bits(2).bits.cmdsync, !alusel(2), alusel(2))
  alusel(4) := Mux(io.in.bits(3).valid && !io.in.bits(3).bits.cmdsync, !alusel(3), alusel(3))

  when (io.in.valid && io.in.ready) {
    alureg := alusel(4)
  }

  for (i <- 0 until 4) {
    q0.io.in.bits(i).valid := io.in.bits(i).valid && (alusel(i) === 0.U || io.in.bits(i).bits.cmdsync)
    q1.io.in.bits(i).valid := io.in.bits(i).valid && (alusel(i) === 1.U || io.in.bits(i).bits.cmdsync)
  }

  // ---------------------------------------------------------------------------
  // Read ports.
  io.read(0).valid := q0.io.out.bits.vs.valid
  io.read(1).valid := q0.io.out.bits.vt.valid
  io.read(2).valid := q0.io.out.bits.vu.valid
  io.read(3).valid := q1.io.out.bits.vs.valid
  io.read(4).valid := q1.io.out.bits.vt.valid
  io.read(5).valid := q1.io.out.bits.vu.valid

  io.read(0).addr := q0.io.out.bits.vs.addr
  io.read(1).addr := q0.io.out.bits.vt.addr
  io.read(2).addr := q0.io.out.bits.vu.addr
  io.read(3).addr := q1.io.out.bits.vs.addr
  io.read(4).addr := q1.io.out.bits.vt.addr
  io.read(5).addr := q1.io.out.bits.vu.addr

  io.read(0).tag := OutTag(q0.io.out.bits.vs)
  io.read(1).tag := OutTag(q0.io.out.bits.vt)
  io.read(2).tag := OutTag(q0.io.out.bits.vu)
  io.read(3).tag := OutTag(q1.io.out.bits.vs)
  io.read(4).tag := OutTag(q1.io.out.bits.vt)
  io.read(5).tag := OutTag(q1.io.out.bits.vu)

  io.scalar(0).valid := q0.io.out.bits.sv.valid
  io.scalar(1).valid := q1.io.out.bits.sv.valid

  io.scalar(0).data := q0.io.out.bits.sv.data
  io.scalar(1).data := q1.io.out.bits.sv.data

  io.read_0_ready := io.read(0).valid && q0.io.out.ready
  io.read_1_ready := io.read(1).valid && q0.io.out.ready
  io.read_2_ready := io.read(2).valid && q0.io.out.ready
  io.read_3_ready := io.read(3).valid && q1.io.out.ready
  io.read_4_ready := io.read(4).valid && q1.io.out.ready
  io.read_5_ready := io.read(5).valid && q1.io.out.ready
  io.read_6_ready := false.B

  // ---------------------------------------------------------------------------
  // Alu0.
  val alu0 = Module(new VAluInt(p, 0))

  alu0.io.in.valid := q0.io.out.valid && q0.io.out.ready
  alu0.io.in.op := q0.io.out.bits.op
  alu0.io.in.f2 := q0.io.out.bits.f2
  alu0.io.in.sz := q0.io.out.bits.sz
  alu0.io.in.vd.addr := q0.io.out.bits.vd.addr
  alu0.io.in.ve.addr := q0.io.out.bits.ve.addr
  alu0.io.in.sv.data := q0.io.out.bits.sv.data

  alu0.io.read(0).data := io.read(0).data
  alu0.io.read(1).data := io.read(1).data
  alu0.io.read(2).data := io.read(2).data
  alu0.io.read(3).data := io.read(3).data
  alu0.io.read(4).data := io.read(4).data
  alu0.io.read(5).data := io.read(5).data
  alu0.io.read(6).data := io.read(6).data

  io.write(0).valid := alu0.io.write(0).valid
  io.write(0).addr := alu0.io.write(0).addr
  io.write(0).data := alu0.io.write(0).data

  io.write(1).valid := alu0.io.write(1).valid
  io.write(1).addr := alu0.io.write(1).addr
  io.write(1).data := alu0.io.write(1).data

  io.whint(0).valid := alu0.io.whint(0).valid
  io.whint(0).addr := alu0.io.whint(0).addr

  io.whint(1).valid := alu0.io.whint(1).valid
  io.whint(1).addr := alu0.io.whint(1).addr

  // ---------------------------------------------------------------------------
  // Alu1.
  val alu1 = Module(new VAluInt(p, 1))

  alu1.io.in.valid := q1.io.out.valid && q1.io.out.ready
  alu1.io.in.op := q1.io.out.bits.op
  alu1.io.in.f2 := q1.io.out.bits.f2
  alu1.io.in.sz := q1.io.out.bits.sz
  alu1.io.in.vd.addr := q1.io.out.bits.vd.addr
  alu1.io.in.ve.addr := q1.io.out.bits.ve.addr
  alu1.io.in.sv.data := q1.io.out.bits.sv.data

  alu1.io.read(0).data := io.read(3).data
  alu1.io.read(1).data := io.read(4).data
  alu1.io.read(2).data := io.read(5).data
  alu1.io.read(3).data := io.read(0).data
  alu1.io.read(4).data := io.read(1).data
  alu1.io.read(5).data := io.read(2).data
  alu1.io.read(6).data := io.read(6).data

  io.write(2).valid := alu1.io.write(0).valid
  io.write(2).addr := alu1.io.write(0).addr
  io.write(2).data := alu1.io.write(0).data

  io.write(3).valid := alu1.io.write(1).valid
  io.write(3).addr := alu1.io.write(1).addr
  io.write(3).data := alu1.io.write(1).data

  io.whint(2).valid := alu1.io.whint(0).valid
  io.whint(2).addr := alu1.io.whint(0).addr

  io.whint(3).valid := alu1.io.whint(1).valid
  io.whint(3).addr := alu1.io.whint(1).addr

  // ---------------------------------------------------------------------------
  // Active.
  io.active := q0.io.active | q1.io.active
}

object EmitVAlu extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new VAlu(p), args)
}
