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

package coralnpu

import chisel3._
import chisel3.util._
import common._

object VInst {
  def apply(p: Parameters): VInst = {
    return Module(new VInst(p))
  }
}

class VectorInstructionIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())
  val stall = Input(Bool())
  val lane = Vec(p.instructionLanes, Valid(new VectorInstructionLane))
}

class VectorInstructionLane extends Bundle {
  val inst = UInt(32.W)
  val addr = UInt(32.W)
  val data = UInt(32.W)
}

class VAddressActive extends Bundle {
  val entry = Vec(8, new Bundle {
    val valid = Output(Bool())
    val store = Output(Bool())
    val addr  = Output(UInt(32.W))
  })
}

class VInst(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Decode cycle.
    val in = Vec(p.instructionLanes, Flipped(Decoupled(new VInstCmd)))

    // Execute cycle.
    val rs = Vec(p.instructionLanes * 2, Flipped(new RegfileReadDataIO))
    val rd = Vec(p.instructionLanes, Valid(Flipped(new RegfileWriteDataIO)))

    // Vector interface.
    val out = new VectorInstructionIO(p)

    // Status.
    val nempty = Output(Bool())
  })

  val maxvlb  = (p.vectorBits / 8).U(p.vectorCountBits.W)
  val maxvlh  = (p.vectorBits / 16).U(p.vectorCountBits.W)
  val maxvlw  = (p.vectorBits / 32).U(p.vectorCountBits.W)
  val maxvlbm = (p.vectorBits * 4 / 8).U(p.vectorCountBits.W)
  val maxvlhm = (p.vectorBits * 4 / 16).U(p.vectorCountBits.W)
  val maxvlwm = (p.vectorBits * 4 / 32).U(p.vectorCountBits.W)
  assert(maxvlw >= 4.U)

  val slice = Slice(Vec(p.instructionLanes, new Bundle {
    val vld = Output(Bool())
    val vst = Output(Bool())
    val lane = Valid(new VectorInstructionLane)
  }), true)

  val reqvalid = VecInit(io.in.map(x => x.valid && x.ready))
  val reqaddr = VecInit(io.in.map(_.bits.inst(19,15)))

  // ---------------------------------------------------------------------------
  // Response to Decode.
  for (i <- 0 until p.instructionLanes) {
    io.in(i).ready := !io.out.stall
  }

  // ---------------------------------------------------------------------------
  // Controls.
  val vld_o = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val vld_u = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val vst_o = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val vst_u = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val vst_q = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val getvl = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val getmaxvl = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))

  val rdAddr = Reg(Vec(p.instructionLanes, UInt(5.W)))

  for (i <- 0 until p.instructionLanes) {
    when (reqvalid(i)) {
      rdAddr(i) := io.in(i).bits.addr
    }
  }

  // ---------------------------------------------------------------------------
  // Vector Interface.
  val vvalid = RegInit(false.B)
  val vinstValid = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val vinstInst = Reg(Vec(p.instructionLanes, UInt(32.W)))
  val nxtVinstValid = Wire(Vec(p.instructionLanes, Bool()))

  vvalid := nxtVinstValid.asUInt =/= 0.U

  for (i <- 0 until p.instructionLanes) {
    nxtVinstValid(i) := reqvalid(i) && io.in(i).bits.op.isOneOf(
            VInstOp.VLD, VInstOp.VST, VInstOp.VIOP)
    vinstValid(i) := nxtVinstValid(i)
    vinstInst(i) := io.in(i).bits.inst
  }

  for (i <- 0 until p.instructionLanes) {
    val p = io.in(i).bits.inst(28)  // func2
    val q = io.in(i).bits.inst(30)  // func2
    val op = io.in(i).bits.op
    vld_o(i) := reqvalid(i) && (op === VInstOp.VLD) && !p
    vld_u(i) := reqvalid(i) && (op === VInstOp.VLD) &&  p
    vst_o(i) := reqvalid(i) && (op === VInstOp.VST) && !p
    vst_u(i) := reqvalid(i) && (op === VInstOp.VST) &&  p && !q
    vst_q(i) := reqvalid(i) && (op === VInstOp.VST) &&  p &&  q
    getvl(i) := reqvalid(i) && (op === VInstOp.GETVL)
    getmaxvl(i) := reqvalid(i) && (op === VInstOp.GETMAXVL)
  }

  // ---------------------------------------------------------------------------
  // Register write port.
  val lsuAdder = Wire(Vec(p.instructionLanes, UInt(32.W)))
  val getvlValue = Wire(Vec(p.instructionLanes, UInt(p.vectorCountBits.W)))  // bytes
  val getmaxvlValue = Wire(Vec(p.instructionLanes, UInt(p.vectorCountBits.W)))  // bytes

  for (i <- 0 until p.instructionLanes) {
    val rs1 = io.rs(2 * i + 0).data
    val rs2 = io.rs(2 * i + 1).data
    val m  = vinstInst(i)(5)
    val sz = vinstInst(i)(13,12)
    val sl = vinstInst(i)(27,26)  // func2
    val q  = vinstInst(i)(30)
    val count = rs2(31,0)
    val xs2zero = vinstInst(i)(24,20) === 0.U

    val max = MuxOR(sz === 0.U && !m, maxvlb) |
              MuxOR(sz === 1.U && !m, maxvlh) |
              MuxOR(sz === 2.U && !m, maxvlw) |
              MuxOR(sz === 0.U && m, maxvlbm) |
              MuxOR(sz === 1.U && m, maxvlhm) |
              MuxOR(sz === 2.U && m, maxvlwm)

    val cmp = Mux(count < max, count, max)

    val bytes = (MuxOR(sz === 0.U && sl(0), cmp) |
                 MuxOR(sz === 1.U && sl(0), Cat(cmp, 0.U(1.W))) |
                 MuxOR(sz === 2.U && sl(0), Cat(cmp, 0.U(2.W))) |
                 MuxOR(!sl(0) && !m, maxvlb) |
                 MuxOR(!sl(0) && m, maxvlbm)
                )(31,0)
    assert(bytes.getWidth == 32)

    val rt = (MuxOR(sz === 0.U, rs2) |
              MuxOR(sz === 1.U, Cat(rs2, 0.U(1.W))) |
              MuxOR(sz === 2.U, Cat(rs2, 0.U(2.W)))
             )(31,0)

    val rtm = (Cat(rt, 0.U(2.W)))(31,0)
    val rtq = (Cat(rt, 0.U(4.W)))(31,0)

    val p_x   = sl === 0.U &&  xs2zero
    val p_xx  = sl === 0.U && !xs2zero
    val lp_xx = sl === 1.U
    val sp_xx = sl === 2.U && !q
    val qp_xx = sl === 2.U &&  q  // vstq.sp
    val tp_xx = sl === 3.U
    assert(PopCount(Cat(p_x, p_xx, lp_xx, sp_xx, qp_xx, tp_xx)) <= 1.U)

    val offset = MuxOR(p_x,   Mux(m, maxvlbm, maxvlb)) |
                 MuxOR(p_xx,  rt) |
                 MuxOR(lp_xx, bytes) |
                 MuxOR(sp_xx, Mux(m, rtm, rt)) |
                 MuxOR(tp_xx, maxvlb) |
                 MuxOR(qp_xx, Mux(m, rtq, rtm))
    assert(offset.getWidth == 32)

    lsuAdder(i) := rs1 + offset
  }

  for (i <- 0 until p.instructionLanes) {
    val len = Wire(UInt(p.vectorCountBits.W))  // bytes
    val rs1 = io.rs(2 * i + 0).data
    val rs2 = io.rs(2 * i + 1).data
    val getvlsz = vinstInst(i)(26,25)
    val getvlm  = vinstInst(i)(27)
    val maxvl = MuxOR(getvlsz === 0.U && !getvlm, maxvlb) |
                MuxOR(getvlsz === 1.U && !getvlm, maxvlh) |
                MuxOR(getvlsz === 2.U && !getvlm, maxvlw) |
                MuxOR(getvlsz === 0.U &&  getvlm, maxvlbm) |
                MuxOR(getvlsz === 1.U &&  getvlm, maxvlhm) |
                MuxOR(getvlsz === 2.U &&  getvlm, maxvlwm)

    val rs2nonzero = vinstInst(i)(24,20) =/= 0.U

    when (rs2 < maxvl && rs2 < rs1 && rs2nonzero) {
      len := rs2
    } .elsewhen (rs1 < maxvl) {
      len := rs1
    } .otherwise {
      len := maxvl
    }

    getvlValue(i) := len
    getmaxvlValue(i) := maxvl
  }

  for (i <- 0 until p.instructionLanes) {
    io.rd(i).valid := getvl(i) || getmaxvl(i) || vld_u(i) || vst_u(i) || vst_q(i)
    io.rd(i).bits.addr := rdAddr(i)

    io.rd(i).bits.data :=
        MuxOR(getvl(i), getvlValue(i)) |
        MuxOR(getmaxvl(i), getmaxvlValue(i)) |
        MuxOR(vld_u(i) || vst_u(i) || vst_q(i), lsuAdder(i))
  }

  // ---------------------------------------------------------------------------
  // Vector Extension Opcodes.
  slice.io.in.valid := vvalid
  slice.io.out.ready := io.out.ready
  io.out.valid := slice.io.out.valid

  // Instruction in execute should always succeed.
  // Resolve back-pressure with stall to io.in in decode.
  assert(!(slice.io.in.valid && !slice.io.in.ready))

  for (i <- 0 until p.instructionLanes) {
    slice.io.in.bits(i).vld := vld_o(i) || vld_u(i)
    slice.io.in.bits(i).vst := vst_o(i) || vst_u(i) || vst_q(i)
    slice.io.in.bits(i).lane.valid := vinstValid(i)
    slice.io.in.bits(i).lane.bits.inst := vinstInst(i)
    slice.io.in.bits(i).lane.bits.addr := io.rs(2 * i + 0).data
    slice.io.in.bits(i).lane.bits.data := io.rs(2 * i + 1).data
  }

  for (i <- 0 until p.instructionLanes) {
    io.out.lane(i) := slice.io.out.bits(i).lane
  }

  // Note: slice.io.in.ready is not used in the flow control.
  // Require the vector core to signal a stall signal into decode,
  // such that the double buffered slice never overruns.
  assert(!(vvalid && !slice.io.in.ready))

  // ---------------------------------------------------------------------------
  // Status.
  val nempty = RegInit(false.B)

  // Simple implementation, will overlap downstream units redundantly.
  nempty := io.in.map(x => x.valid).reduce(_ || _) || vvalid || io.out.valid

  io.nempty := nempty
}
