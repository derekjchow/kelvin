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
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

// VAluInt is foremost an ML depthwise and activiation unit with pipelining
// behaviors optimized to this functionality. All operations are pipelined with
// a result latency of 2cc geared towards the goal of simplicity of design.
//
// Note: widening operations modify the size from ISA defined destination to
// source read registers of sz/2.

class VAluInt(p: Parameters, aluid: Int) extends Module {
  val e = new VEncodeOp()

  val io = IO(new Bundle {
    val in = Input(new Bundle {
      val valid = Bool()
      val op = UInt(e.bits.W)
      val f2 = UInt(3.W)
      val sz = UInt(3.W)
      val vd = new AluAddr()  // write port 0
      val ve = new AluAddr()  // write port 1
      val sv = new Bundle { val data = UInt(32.W) }  // scala value
    })
    val read = Vec(7, Input(new Bundle {
      val data = UInt(p.vectorBits.W)
    }))
    val write = Vec(2, new VRegfileWriteIO(p))
    val whint = Vec(2, new VRegfileWhintIO(p))
  })

  class AluAddr extends Bundle {
    val addr = UInt(6.W)
  }

  val lanes = p.vectorBits / 32
  assert(lanes == 4 || lanes == 8 || lanes == 16)

  assert(!io.in.valid || PopCount(io.in.sz) <= 1.U)

  // ---------------------------------------------------------------------------
  // Tie-offs.
  for (i <- 0 until 2) {
    io.write(i).valid := false.B
    io.write(i).addr := 0.U
    io.write(i).data := 0.U
  }
  for (i <- 0 until 2) {
    io.whint(i).valid := false.B
    io.whint(i).addr := 0.U
  }

  // ---------------------------------------------------------------------------
  // Encodings.
  val e_absd  = io.in.op === e.vabsd.U
  val e_acc   = io.in.op === e.vacc.U
  val e_dup   = io.in.op === e.vdup.U
  val e_max   = io.in.op === e.vmax.U
  val e_min   = io.in.op === e.vmin.U
  val e_rsub  = io.in.op === e.vrsub.U
  val e_srans = io.in.op === e.vsrans.U
  val e_sraqs = if (aluid == 0) io.in.op === e.vsraqs.U else false.B

  val e_slidevn = io.in.op === e.vslidevn.U || io.in.op === e.vslidehn.U || io.in.op === e.vslidehn2.U
  val e_slidevp = io.in.op === e.vslidevp.U || io.in.op === e.vslidehp.U || io.in.op === e.vslidehp2.U
  val e_slidehn2 = io.in.op === e.vslidehn2.U
  val e_slidehp2 = io.in.op === e.vslidehp2.U
  val e_sel = io.in.op === e.vsel.U
  val e_evn = io.in.op === e.vevn.U || io.in.op === e.vevnodd.U
  val e_odd = io.in.op === e.vodd.U || io.in.op === e.vevnodd.U
  val e_zip = io.in.op === e.vzip.U

  val e_dwinit = io.in.op === e.adwinit.U
  val e_dwconv = io.in.op === e.vdwconv.U || io.in.op === e.adwconv.U
  val e_dwconva = io.in.op === e.adwconv.U

  val e_add_add  = io.in.op === e.vadd.U
  val e_add_adds = io.in.op === e.vadds.U
  val e_add_addw = io.in.op === e.vaddw.U
  val e_add_add3 = io.in.op === e.vadd3.U
  val e_add_hadd = io.in.op === e.vhadd.U
  val e_add = e_add_add || e_add_adds || e_add_addw || e_add_add3 || e_add_hadd

  val e_cmp_eq = io.in.op === e.veq.U
  val e_cmp_ne = io.in.op === e.vne.U
  val e_cmp_lt = io.in.op === e.vlt.U
  val e_cmp_le = io.in.op === e.vle.U
  val e_cmp_gt = io.in.op === e.vgt.U
  val e_cmp_ge = io.in.op === e.vge.U
  val e_cmp    = e_cmp_eq || e_cmp_ne || e_cmp_lt || e_cmp_le || e_cmp_gt || e_cmp_ge
  assert(PopCount(Cat(e_cmp_eq, e_cmp_ne, e_cmp_lt, e_cmp_le, e_cmp_gt, e_cmp_ge)) <= 1.U)

  val e_log_and  = io.in.op === e.vand.U
  val e_log_or   = io.in.op === e.vor.U
  val e_log_xor  = io.in.op === e.vxor.U
  val e_log_not  = io.in.op === e.vnot.U
  val e_log_rev  = io.in.op === e.vrev.U
  val e_log_ror  = io.in.op === e.vror.U
  val e_log_clb  = io.in.op === e.vclb.U
  val e_log_clz  = io.in.op === e.vclz.U
  val e_log_cpop = io.in.op === e.vcpop.U
  val e_log = e_log_and || e_log_or || e_log_xor || e_log_not || e_log_rev || e_log_ror || e_log_clb || e_log_clz || e_log_cpop
  assert(PopCount(Cat(e_log_and, e_log_or, e_log_xor, e_log_not, e_log_rev, e_log_ror, e_log_clb, e_log_clz, e_log_cpop)) <= 1.U)

  val e_mul0_dmulh = io.in.op === e.vdmulh.U || io.in.op === e.vdmulh2.U
  val e_mul0_mul   = io.in.op === e.vmul.U || io.in.op === e.vmul2.U
  val e_mul0_mulh  = io.in.op === e.vmulh.U || io.in.op === e.vmulh2.U
  val e_mul0_muls  = io.in.op === e.vmuls.U || io.in.op === e.vmuls2.U
  val e_mul0_mulw  = io.in.op === e.vmulw.U
  val e_mul0_madd  = io.in.op === e.vmadd.U
  val e_mul0 = e_mul0_dmulh || e_mul0_mul || e_mul0_mulh || e_mul0_muls || e_mul0_mulw || e_mul0_madd

  val e_mul1_dmulh = io.in.op === e.vdmulh2.U
  val e_mul1_mul   = io.in.op === e.vmul2.U
  val e_mul1_mulh  = io.in.op === e.vmulh2.U
  val e_mul1_muls  = io.in.op === e.vmuls2.U
  val e_mul1 = e_mul1_dmulh || e_mul1_mul || e_mul1_mulh || e_mul1_muls

  val e_mv2 = io.in.op === e.vmv2.U
  val e_mvp = io.in.op === e.vmvp.U
  val e_mv  = io.in.op === e.vmv.U || e_mv2 || e_mvp

  val e_padd_add = io.in.op === e.vpadd.U
  val e_padd_sub = io.in.op === e.vpsub.U
  val e_padd = e_padd_add || e_padd_sub

  val e_shf_shl = io.in.op === e.vshl.U
  val e_shf_shr = io.in.op === e.vshr.U
  val e_shf_shf = io.in.op === e.vshf.U
  val e_shf_l = e_shf_shl || e_shf_shf
  val e_shf_r = e_shf_shr || e_shf_shf

  val e_sub_sub  = io.in.op === e.vsub.U
  val e_sub_subs = io.in.op === e.vsubs.U
  val e_sub_subw = io.in.op === e.vsubw.U
  val e_sub_hsub = io.in.op === e.vhsub.U
  val e_sub = e_sub_sub || e_sub_subs || e_sub_subw || e_sub_hsub

  val e_negative = io.in.f2(0) && e_mul0_dmulh
  val e_round    = io.in.f2(1) && (e_add_hadd || e_sub_hsub || e_mul0_dmulh || e_mul0_mulh || e_shf_shf || e_srans || e_sraqs)
  val e_signed   = !io.in.f2(0) || e_mul0_dmulh

  assert(!(e_mul1_dmulh && !e_mul0_dmulh))
  assert(!(e_mul1_mul   && !e_mul0_mul))
  assert(!(e_mul1_mulh  && !e_mul0_mulh))
  assert(!(e_mul1_muls  && !e_mul0_muls))

  // ---------------------------------------------------------------------------
  // Control.
  val vdvalid0 = RegInit(false.B)
  val vdvalid1 = RegInit(false.B)
  val vevalid0 = RegInit(false.B)
  val vevalid1 = RegInit(false.B)
  val wmask = RegInit(false.B)
  val vdaddr0 = Reg(new AluAddr())
  val vdaddr1 = Reg(new AluAddr())
  val veaddr0 = Reg(new AluAddr())
  val veaddr1 = Reg(new AluAddr())
  val sz = RegInit(0.U(3.W))
  val f2 = RegInit(0.U(3.W))
  val sv = RegInit(0.U(32.W))

  when (io.in.valid) {
    // Note: sz is source size, not destination as is ISA defined.
    val nxt_vdvalid = e_dwconv || e_mul0 || e_absd || e_acc || e_add || e_cmp || e_dup || e_log || e_evn || e_max || e_min || e_mv || e_padd || e_rsub || e_sel || e_shf_l || e_shf_r || e_slidevn || e_slidevp || e_srans || e_sraqs || e_sub || e_zip
    val nxt_vevalid = e_dwconv || e_mul1 || e_mul0_mulw || e_acc || e_add_addw || e_mv2 || e_mvp || e_odd || e_slidehn2 || e_slidehp2 || e_sub_subw || e_zip
    val nxt_widen = e_acc || e_add_addw || e_mul0_mulw || e_sub_subw
    vdvalid0 := nxt_vdvalid
    vevalid0 := nxt_vevalid
    wmask := e_dwconva
    sz := MuxOR(nxt_vdvalid || nxt_vevalid, Mux(nxt_widen, io.in.sz >> 1.U, io.in.sz))
    f2 := io.in.f2
    sv := io.in.sv.data
  } .elsewhen (vdvalid0 || vevalid0) {
    vdvalid0 := false.B
    vevalid0 := false.B
    wmask := false.B
    sz := 0.U
    f2 := 0.U
    sv := 0.U
  }

  // Register VAluIntLane results, but mask io.write.valid outputs.
  vdvalid1 := vdvalid0 && !wmask
  vevalid1 := vevalid0 && !wmask

  when (io.in.valid) {
    vdaddr0 := io.in.vd
    veaddr0 := io.in.ve
  }

  when (vdvalid0) {
    vdaddr1 := vdaddr0
  }

  when (vevalid0) {
    veaddr1 := veaddr0
  }

  // ---------------------------------------------------------------------------
  // Side-bands.
  val negative = Reg(Bool())
  val round    = Reg(Bool())
  val signed   = Reg(Bool())

  when (io.in.valid) {
    negative := e_negative
    round    := e_round
    signed   := e_signed
  }

  // ---------------------------------------------------------------------------
  // Operations.
  val absd  = Reg(Bool())
  val acc   = Reg(Bool())
  val dup   = Reg(Bool())
  val max   = Reg(Bool())
  val min   = Reg(Bool())
  val srans = Reg(Bool())
  val sraqs = Reg(Bool())

  val slidevn  = Reg(Bool())
  val slidevp  = Reg(Bool())
  val slidehn2 = Reg(Bool())
  val slidehp2 = Reg(Bool())
  val sel      = Reg(Bool())
  val evn      = Reg(Bool())
  val odd      = Reg(Bool())
  val zip      = Reg(Bool())

  val dwinit     = Reg(Bool())
  val dwconv     = Reg(Bool())
  val dwconvData = Reg(Bool())

  val add      = Reg(Bool())
  val add_add  = Reg(Bool())
  val add_adds = Reg(Bool())
  val add_addw = Reg(Bool())
  val add_add3 = Reg(Bool())
  val add_hadd = Reg(Bool())

  val padd = Reg(Bool())
  val padd_add = Reg(Bool())
  val padd_sub = Reg(Bool())

  val rsub      = Reg(Bool())
  val rsub_rsub = Reg(Bool())

  val sub      = Reg(Bool())
  val sub_sub  = Reg(Bool())
  val sub_subs = Reg(Bool())
  val sub_subw = Reg(Bool())
  val sub_hsub = Reg(Bool())

  val cmp    = Reg(Bool())
  val cmp_eq = Reg(Bool())
  val cmp_ne = Reg(Bool())
  val cmp_lt = Reg(Bool())
  val cmp_le = Reg(Bool())
  val cmp_gt = Reg(Bool())
  val cmp_ge = Reg(Bool())

  val log      = Reg(Bool())
  val log_and  = Reg(Bool())
  val log_or   = Reg(Bool())
  val log_xor  = Reg(Bool())
  val log_not  = Reg(Bool())
  val log_rev  = Reg(Bool())
  val log_ror  = Reg(Bool())
  val log_clb  = Reg(Bool())
  val log_clz  = Reg(Bool())
  val log_cpop = Reg(Bool())

  val mul0       = Reg(Bool())
  val mul0_dmulh = Reg(Bool())
  val mul0_mul   = Reg(Bool())
  val mul0_mulh  = Reg(Bool())
  val mul0_muls  = Reg(Bool())
  val mul0_mulw  = Reg(Bool())
  val mul0_madd  = Reg(Bool())

  val mul1       = Reg(Bool())
  val mul1_dmulh = Reg(Bool())
  val mul1_mul   = Reg(Bool())
  val mul1_mulh  = Reg(Bool())
  val mul1_muls  = Reg(Bool())

  val mv  = Reg(Bool())
  val mv2 = Reg(Bool())
  val mvp = Reg(Bool())

  val shf_l   = Reg(Bool())
  val shf_r   = Reg(Bool())
  val shf_shl = Reg(Bool())
  val shf_shr = Reg(Bool())
  val shf_shf = Reg(Bool())

  val validClr = RegInit(false.B)
  validClr := io.in.valid

  when (io.in.valid || validClr) {
    val valid = io.in.valid

    absd  := valid && e_absd
    acc   := valid && e_acc
    dup   := valid && e_dup
    max   := valid && e_max
    min   := valid && e_min
    srans := valid && e_srans
    sraqs := valid && e_sraqs

    slidevn  := valid && e_slidevn
    slidevp  := valid && e_slidevp
    slidehn2 := valid && e_slidehn2
    slidehp2 := valid && e_slidehp2
    sel      := valid && e_sel
    evn      := valid && e_evn
    odd      := valid && e_odd
    zip      := valid && e_zip

    dwinit   := valid && e_dwinit
    dwconv   := valid && e_dwconv

    add := valid && e_add  // unit activation
    add_add  := valid && e_add_add
    add_adds := valid && e_add_adds
    add_addw := valid && e_add_addw
    add_add3 := valid && e_add_add3
    add_hadd := valid && e_add_hadd

    padd := valid && e_padd
    padd_add := valid && e_padd_add
    padd_sub := valid && e_padd_sub

    cmp := valid && (e_cmp || e_absd || e_max || e_min)  // unit activation
    cmp_eq := valid && e_cmp_eq
    cmp_ne := valid && e_cmp_ne
    cmp_lt := valid && e_cmp_lt
    cmp_le := valid && e_cmp_le
    cmp_gt := valid && e_cmp_gt
    cmp_ge := valid && e_cmp_ge

    log := valid && e_log  // unit activation
    log_and  := valid && e_log_and
    log_or   := valid && e_log_or
    log_xor  := valid && e_log_xor
    log_not  := valid && e_log_not
    log_rev  := valid && e_log_rev
    log_ror  := valid && e_log_ror
    log_clb  := valid && e_log_clb
    log_clz  := valid && e_log_clz
    log_cpop := valid && e_log_cpop

    mul0 := valid && e_mul0  // unit activation
    mul0_dmulh := valid && e_mul0_dmulh
    mul0_mul   := valid && e_mul0_mul
    mul0_mulh  := valid && e_mul0_mulh
    mul0_muls  := valid && e_mul0_muls
    mul0_mulw  := valid && e_mul0_mulw
    mul0_madd  := valid && e_mul0_madd

    mul1 := valid && e_mul1  // unit activation
    mul1_dmulh := valid && e_mul1_dmulh
    mul1_mul   := valid && e_mul1_mul
    mul1_mulh  := valid && e_mul1_mulh
    mul1_muls  := valid && e_mul1_muls

    mv  := valid && e_mv
    mv2 := valid && e_mv2
    mvp := valid && e_mvp

    rsub := valid && (e_rsub || e_absd)  // unit activation
    rsub_rsub := valid && e_rsub

    shf_l := valid && e_shf_l  // unit activation
    shf_r := valid && e_shf_r  // unit activation
    shf_shl := valid && e_shf_shl
    shf_shr := valid && e_shf_shr
    shf_shf := valid && e_shf_shf

    sub := valid && (e_sub || e_absd)
    sub_sub  := valid && e_sub_sub
    sub_subs := valid && e_sub_subs
    sub_subw := valid && e_sub_subw
    sub_hsub := valid && e_sub_hsub
  }

  // Second cycle of ALU pipeline.
  dwconvData := dwconv

  // ---------------------------------------------------------------------------
  // ALU segments.
  val valu = for (i <- 0 until lanes) yield {
    Module(new VAluIntLane)
  }

  val load = Wire(Vec(2, UInt(p.vectorBits.W)))

  for (i <- 0 until lanes) {
    val msb = 32 * i + 31
    val lsb = 32 * i
    valu(i).io.in.vdvalid := vdvalid0
    valu(i).io.in.vevalid := vevalid0
    valu(i).io.in.sz := sz
    for (j <- 0 until 7) {
      valu(i).io.read(j).data := io.read(j).data(msb, lsb)
    }
    for (j <- 0 until 2) {
      valu(i).io.load(j) := load(j)(msb, lsb)
    }
  }

  for (i <- 0 until lanes) {
    valu(i).io.in.negative := negative
    valu(i).io.in.round    := round
    valu(i).io.in.signed   := signed
  }

  for (i <- 0 until lanes) {
    valu(i).io.op.absd := absd
    valu(i).io.op.acc  := acc
    valu(i).io.op.dup  := dup
    valu(i).io.op.max  := max
    valu(i).io.op.min  := min
    valu(i).io.op.mv   := mv
    valu(i).io.op.mv2  := mv2
    valu(i).io.op.mvp  := mvp
    valu(i).io.op.srans := srans
    valu(i).io.op.sraqs := sraqs

    valu(i).io.op.dwinit := dwinit
    valu(i).io.op.dwconv := dwconv
    valu(i).io.op.dwconvData := dwconvData

    valu(i).io.op.add.en := add
    valu(i).io.op.add.add  := add_add
    valu(i).io.op.add.adds := add_adds
    valu(i).io.op.add.addw := add_addw
    valu(i).io.op.add.add3 := add_add3
    valu(i).io.op.add.hadd := add_hadd

    valu(i).io.op.cmp.en := cmp
    valu(i).io.op.cmp.eq := cmp_eq
    valu(i).io.op.cmp.ne := cmp_ne
    valu(i).io.op.cmp.lt := cmp_lt
    valu(i).io.op.cmp.le := cmp_le
    valu(i).io.op.cmp.gt := cmp_gt
    valu(i).io.op.cmp.ge := cmp_ge

    valu(i).io.op.log.en := log
    valu(i).io.op.log.and  := log_and
    valu(i).io.op.log.or   := log_or
    valu(i).io.op.log.xor  := log_xor
    valu(i).io.op.log.not  := log_not
    valu(i).io.op.log.rev  := log_rev
    valu(i).io.op.log.ror  := log_ror
    valu(i).io.op.log.clb  := log_clb
    valu(i).io.op.log.clz  := log_clz
    valu(i).io.op.log.cpop := log_cpop

    valu(i).io.op.mul0.en := mul0
    valu(i).io.op.mul0.dmulh := mul0_dmulh
    valu(i).io.op.mul0.mul   := mul0_mul
    valu(i).io.op.mul0.mulh  := mul0_mulh
    valu(i).io.op.mul0.muls  := mul0_muls
    valu(i).io.op.mul0.mulw  := mul0_mulw
    valu(i).io.op.mul0.madd  := mul0_madd

    valu(i).io.op.mul1.en := mul1
    valu(i).io.op.mul1.dmulh := mul1_dmulh
    valu(i).io.op.mul1.mul   := mul1_mul
    valu(i).io.op.mul1.mulh  := mul1_mulh
    valu(i).io.op.mul1.muls  := mul1_muls

    valu(i).io.op.padd.en := padd
    valu(i).io.op.padd.add := padd_add
    valu(i).io.op.padd.sub := padd_sub

    valu(i).io.op.rsub.en := rsub
    valu(i).io.op.rsub.rsub := rsub_rsub

    valu(i).io.op.shf.en.l := shf_l
    valu(i).io.op.shf.en.r := shf_r
    valu(i).io.op.shf.shl := shf_shl
    valu(i).io.op.shf.shr := shf_shr
    valu(i).io.op.shf.shf := shf_shf

    valu(i).io.op.sub.en := sub
    valu(i).io.op.sub.sub  := sub_sub
    valu(i).io.op.sub.subs := sub_subs
    valu(i).io.op.sub.subw := sub_subw
    valu(i).io.op.sub.hsub := sub_hsub
  }

  // ---------------------------------------------------------------------------
  // VSlide.
  def VSliden(sz: Int, sel: UInt, a: UInt, b: UInt): UInt = {
    val size = 8 << sz
    assert(sz == 0 || sz == 1 || sz == 2)
    assert(size == 8 || size == 16 || size == 32)
    assert(sel.getWidth == 2)

    val cnt = a.getWidth / size
    val cnt2 = cnt * 2
    val in = Wire(Vec(cnt2, UInt(size.W)))
    val sout1 = Wire(Vec(cnt, UInt(size.W)))
    val sout2 = Wire(Vec(cnt, UInt(size.W)))
    val sout3 = Wire(Vec(cnt, UInt(size.W)))
    val sout4 = Wire(Vec(cnt, UInt(size.W)))

    for (i <- 0 until cnt) {
      val l = i * size      // lsb
      val m = l + size - 1  // msb
      in(i)       := a(m,l)
      in(i + cnt) := b(m,l)
    }

    for (i <- 0 until cnt) {
      sout1(i) := in(i + 1)
      sout2(i) := in(i + 2)
      sout3(i) := in(i + 3)
      sout4(i) := in(i + 4)
    }

    val out = MuxOR(sel === 0.U, sout1.asUInt) |
              MuxOR(sel === 1.U, sout2.asUInt) |
              MuxOR(sel === 2.U, sout3.asUInt) |
              MuxOR(sel === 3.U, sout4.asUInt)
    assert(out.getWidth == a.getWidth)

    out
  }

  def VSlidep(sz: Int, sel: UInt, a: UInt, b: UInt): UInt = {
    val size = 8 << sz
    assert(sz == 0 || sz == 1 || sz == 2)
    assert(size == 8 || size == 16 || size == 32)
    assert(sel.getWidth == 2)

    val cnt = a.getWidth / size
    val cnt2 = cnt * 2
    val in = Wire(Vec(cnt2, UInt(size.W)))
    val sout1 = Wire(Vec(cnt, UInt(size.W)))
    val sout2 = Wire(Vec(cnt, UInt(size.W)))
    val sout3 = Wire(Vec(cnt, UInt(size.W)))
    val sout4 = Wire(Vec(cnt, UInt(size.W)))

    for (i <- 0 until cnt) {
      val l = i * size      // lsb
      val m = l + size - 1  // msb
      in(i)       := a(m,l)
      in(i + cnt) := b(m,l)
    }

    for (i <- 0 until cnt) {
      sout1(i) := in(i - 1 + cnt)
      sout2(i) := in(i - 2 + cnt)
      sout3(i) := in(i - 3 + cnt)
      sout4(i) := in(i - 4 + cnt)
    }

    val out = MuxOR(sel === 0.U, sout1.asUInt) |
              MuxOR(sel === 1.U, sout2.asUInt) |
              MuxOR(sel === 2.U, sout3.asUInt) |
              MuxOR(sel === 3.U, sout4.asUInt)
    assert(out.getWidth == a.getWidth)

    out
  }

  val slidenb0 = VSliden(0, f2(1,0), MuxOR(slidevn && sz(0), io.read(0).data), MuxOR(slidevn && sz(0), io.read(1).data))
  val slidenh0 = VSliden(1, f2(1,0), MuxOR(slidevn && sz(1), io.read(0).data), MuxOR(slidevn && sz(1), io.read(1).data))
  val slidenw0 = VSliden(2, f2(1,0), MuxOR(slidevn && sz(2), io.read(0).data), MuxOR(slidevn && sz(2), io.read(1).data))

  val slidenb1 = VSliden(0, f2(1,0), MuxOR(slidehn2 && sz(0), io.read(1).data), MuxOR(slidehn2 && sz(0), io.read(2).data))
  val slidenh1 = VSliden(1, f2(1,0), MuxOR(slidehn2 && sz(1), io.read(1).data), MuxOR(slidehn2 && sz(1), io.read(2).data))
  val slidenw1 = VSliden(2, f2(1,0), MuxOR(slidehn2 && sz(2), io.read(1).data), MuxOR(slidehn2 && sz(2), io.read(2).data))

  val slidepb0 = VSlidep(0, f2(1,0), MuxOR(slidevp && sz(0), io.read(0).data), MuxOR(slidevp && sz(0), io.read(1).data))
  val slideph0 = VSlidep(1, f2(1,0), MuxOR(slidevp && sz(1), io.read(0).data), MuxOR(slidevp && sz(1), io.read(1).data))
  val slidepw0 = VSlidep(2, f2(1,0), MuxOR(slidevp && sz(2), io.read(0).data), MuxOR(slidevp && sz(2), io.read(1).data))

  val slidepb1 = VSlidep(0, f2(1,0), MuxOR(slidehp2 && sz(0), io.read(1).data), MuxOR(slidehp2 && sz(0), io.read(2).data))
  val slideph1 = VSlidep(1, f2(1,0), MuxOR(slidehp2 && sz(1), io.read(1).data), MuxOR(slidehp2 && sz(1), io.read(2).data))
  val slidepw1 = VSlidep(2, f2(1,0), MuxOR(slidehp2 && sz(2), io.read(1).data), MuxOR(slidehp2 && sz(2), io.read(2).data))

  val slide0 = slidenb0 | slidenh0 | slidenw0 |
               slidepb0 | slideph0 | slidepw0

  val slide1 = slidenb1 | slidenh1 | slidenw1 |
               slidepb1 | slideph1 | slidepw1

  // ---------------------------------------------------------------------------
  // Select.
  def VSel(sz: Int, a: UInt, b: UInt, c: UInt): UInt = {
    val size = 8 << sz
    assert(sz == 0 || sz == 1 || sz == 2)
    assert(size == 8 || size == 16 || size == 32)

    val cnt = a.getWidth / size
    val sout = Wire(Vec(cnt, UInt(size.W)))

    for (i <- 0 until cnt) {
      val l = i * size      // lsb
      val m = l + size - 1  // msb
      sout(i) := Mux(a(l), c(m,l), b(m,l))
    }

    val out = sout.asUInt
    assert(out.getWidth == a.getWidth)

    out
  }

  val selb0 = VSel(0, MuxOR(sel && sz(0), io.read(0).data), MuxOR(sel && sz(0), io.read(1).data), MuxOR(sel && sz(0), io.read(2).data))
  val selh0 = VSel(1, MuxOR(sel && sz(1), io.read(0).data), MuxOR(sel && sz(1), io.read(1).data), MuxOR(sel && sz(1), io.read(2).data))
  val selw0 = VSel(2, MuxOR(sel && sz(2), io.read(0).data), MuxOR(sel && sz(2), io.read(1).data), MuxOR(sel && sz(2), io.read(2).data))

  val sel0 = selb0 | selh0 | selw0

  // ---------------------------------------------------------------------------
  // Even/Odd.
  def VEvnOdd(sel: Int, sz: Int, a: UInt, b: UInt): UInt = {
    val size = 8 << sz
    assert(sz == 0 || sz == 1 || sz == 2)
    assert(size == 8 || size == 16 || size == 32)
    assert(sel == 0 || sel == 1)

    val cnt = a.getWidth / size
    val evnodd = Wire(Vec(cnt, UInt(size.W)))

    for (i <- 0 until cnt / 2) {
      val j = i * 2 + sel
      val l = j * size      // lsb
      val m = l + size - 1  // msb
      evnodd(i) := a(m,l)
    }

    for (i <- cnt / 2 until cnt) {
      val j = (i - cnt / 2) * 2 + sel
      val l = j * size      // lsb
      val m = l + size - 1  // msb
      evnodd(i) := b(m,l)
    }

    val out = evnodd.asUInt
    assert(out.getWidth == a.getWidth)

    out
  }

  val evnb = VEvnOdd(0, 0, MuxOR(evn && sz(0), io.read(0).data), MuxOR(evn && sz(0), io.read(1).data))
  val evnh = VEvnOdd(0, 1, MuxOR(evn && sz(1), io.read(0).data), MuxOR(evn && sz(1), io.read(1).data))
  val evnw = VEvnOdd(0, 2, MuxOR(evn && sz(2), io.read(0).data), MuxOR(evn && sz(2), io.read(1).data))
  val oddb = VEvnOdd(1, 0, MuxOR(odd && sz(0), io.read(0).data), MuxOR(odd && sz(0), io.read(1).data))
  val oddh = VEvnOdd(1, 1, MuxOR(odd && sz(1), io.read(0).data), MuxOR(odd && sz(1), io.read(1).data))
  val oddw = VEvnOdd(1, 2, MuxOR(odd && sz(2), io.read(0).data), MuxOR(odd && sz(2), io.read(1).data))

  val evn0 = evnb | evnh | evnw
  val odd1 = oddb | oddh | oddw

  // ---------------------------------------------------------------------------
  // VZip.
  val zipIn0 = MuxOR(zip, io.read(0).data)
  val zipIn1 = MuxOR(zip, io.read(1).data)
  val zips = (0 until 8).map(x => Zip32(MuxOR(zip, sz),
                                        zipIn0(31 + (32 * x), (32 * x)),
                                        zipIn1(31 + (32 * x), (32 * x))))
  val zip0 = Cat(zips(3), zips(2), zips(1), zips(0))
  val zip1 = Cat(zips(7), zips(6), zips(5), zips(4))

  // ---------------------------------------------------------------------------
  // Depthwise.
  val (dwconv0, dwconv1) =
    if (aluid == 0) {
      VDot(aluid, dwconv,
           VecInit(io.read(0).data, io.read(1).data, io.read(2).data),
           VecInit(io.read(3).data, io.read(4).data, io.read(5).data), sv)
    } else {
      VDot(aluid, dwconv,
           VecInit(io.read(3).data, io.read(4).data, io.read(5).data),
           VecInit(io.read(0).data, io.read(1).data, io.read(2).data), sv)
    }

  // ---------------------------------------------------------------------------
  // Parallel Load registered VAluIntLane stage.
  load(0) := evn0 | zip0 | slide0 | dwconv0 | sel0
  load(1) := odd1 | zip1 | slide1 | dwconv1

  // ---------------------------------------------------------------------------
  // Outputs.
  val vddata = Wire(Vec(lanes, UInt(32.W)))
  val vedata = Wire(Vec(lanes, UInt(32.W)))

  for (i <- 0 until lanes) {
    vddata(i) := valu(i).io.write(0).data
    vedata(i) := valu(i).io.write(1).data
  }

  io.write(0).valid := vdvalid1
  io.write(0).addr := vdaddr1.addr
  io.write(0).data := vddata.asUInt

  io.write(1).valid := vevalid1
  io.write(1).addr := veaddr1.addr
  io.write(1).data := vedata.asUInt

  io.whint(0).valid := vdvalid0 && !wmask
  io.whint(0).addr := vdaddr0.addr

  io.whint(1).valid := vevalid0 && !wmask
  io.whint(1).addr := veaddr0.addr
}

class VAluIntLane extends Module {
  val e = new VEncodeOp()

  val io = IO(new Bundle {
    val in = Input(new Bundle {
      val vdvalid = Bool()
      val vevalid = Bool()
      val sz = UInt(3.W)
      val negative = Bool()
      val round = Bool()
      val signed = Bool()
    })
    val op = Input(new Bundle {
      val absd  = Bool()
      val acc   = Bool()
      val dup   = Bool()
      val max   = Bool()
      val min   = Bool()
      val mv   = Bool()
      val mv2  = Bool()
      val mvp  = Bool()
      val srans = Bool()
      val sraqs = Bool()

      val dwinit = Bool()
      val dwconv = Bool()
      val dwconvData = Bool()

      val add = new Bundle {
        val en = Bool()
        val add  = Bool()
        val adds = Bool()
        val addw = Bool()
        val add3 = Bool()
        val hadd = Bool()
      }

      val cmp = new Bundle {
        val en = Bool()
        val eq = Bool()
        val ne = Bool()
        val lt = Bool()
        val le = Bool()
        val gt = Bool()
        val ge = Bool()
      }

      val log = new Bundle {
        val en = Bool()
        val and  = Bool()
        val or   = Bool()
        val xor  = Bool()
        val not  = Bool()
        val rev  = Bool()
        val ror  = Bool()
        val clb  = Bool()
        val clz  = Bool()
        val cpop = Bool()
      }

      val mul0 = new Bundle {
        val en = Bool()
        val dmulh = Bool()
        val mul   = Bool()
        val mulh  = Bool()
        val muls  = Bool()
        val mulw  = Bool()
        val madd  = Bool()
      }

      val mul1 = new Bundle {
        val en = Bool()
        val dmulh = Bool()
        val mul   = Bool()
        val mulh  = Bool()
        val muls  = Bool()
      }

      val padd = new Bundle {
        val en = Bool()
        val add = Bool()
        val sub = Bool()
      }

      val rsub  = new Bundle {
        val en = Bool()
        val rsub = Bool()
      }

      val shf = new Bundle {
        val en = new Bundle {
          val l = Bool()  // left
          val r = Bool()  // right
        }
        val shl = Bool()
        val shr = Bool()
        val shf = Bool()
      }

      val sub  = new Bundle {
        val en = Bool()
        val sub  = Bool()
        val subs = Bool()
        val subw = Bool()
        val hsub = Bool()
      }
    })
      val read = Vec(7, Input(new Bundle {
      val data = UInt(32.W)
    }))
    val write = Vec(2, Output(new Bundle {
      val data = UInt(32.W)
    }))
    val load = Vec(2, Input(UInt(32.W)))  // parallel load data
  })

  def VAlu(sz: Int, a: UInt, b: UInt, c: UInt, d: UInt, e: UInt, f: UInt): (UInt, UInt, UInt, UInt, UInt, UInt) = {
    // Note: sz is source size, not destination as is ISA defined.
    val size = 8 << sz
    assert(sz == 0 || sz == 1 || sz == 2)
    assert(size == 8 || size == 16 || size == 32)
    assert(a.getWidth == b.getWidth)
    assert(a.getWidth == c.getWidth)
    assert(a.getWidth == 32)
    val cnt = a.getWidth / size
    val alu0 = Wire(Vec(cnt, UInt(size.W)))
    val alu1 = Wire(Vec(cnt, UInt(size.W)))
    val aluw0 = Wire(Vec(cnt / 2, UInt((2 * size).W)))
    val aluw1 = Wire(Vec(cnt / 2, UInt((2 * size).W)))
    val rnd0 = Wire(Vec(cnt, UInt(size.W)))
    val rnd1 = Wire(Vec(cnt, UInt(size.W)))

    // -------------------------------------------------------------------------
    // Controls.
    val negative = io.in.negative
    val round    = io.in.round
    val signed   = io.in.signed

    // -------------------------------------------------------------------------
    // Datapath.
    val aw = a
    val bw = b
    val cw = c
    val dw = d
    val fw = f

    val acc_a = MuxOR(io.op.acc, aw)
    val acc_b = MuxOR(io.op.acc, bw)
    val acc_c = MuxOR(io.op.acc, cw)

    val add_a = MuxOR(io.op.add.en, aw)
    val add_b = MuxOR(io.op.add.en, bw)
    val add_r = io.op.add.hadd && round

    val cmp_a = MuxOR(io.op.cmp.en, aw)
    val cmp_b = MuxOR(io.op.cmp.en, bw)

    val log_a = MuxOR(io.op.log.en, aw)
    val log_b = MuxOR(io.op.log.en, bw)

    val mul0_a = MuxOR(io.op.mul0.en, aw)
    val mul0_b = MuxOR(io.op.mul0.en, bw)
    val mul1_a = MuxOR(io.op.mul1.en, cw)
    val mul1_b = MuxOR(io.op.mul1.en, bw)

    val padd_a = MuxOR(io.op.padd.en, aw)

    val rsub_a = MuxOR(io.op.rsub.en, aw)
    val rsub_b = MuxOR(io.op.rsub.en, bw)

    val shl_a = MuxOR(io.op.shf.en.l, aw)
    val shl_b = MuxOR(io.op.shf.en.l, bw)
    val shr_a = MuxOR(io.op.shf.en.r, aw)
    val shr_b = MuxOR(io.op.shf.en.r, bw)

    val srans_a = MuxOR(io.op.srans, aw)
    val srans_b = MuxOR(io.op.srans, bw)
    val srans_c = MuxOR(io.op.srans, cw)

    val sraqs_a = MuxOR(io.op.sraqs, aw)
    val sraqs_b = MuxOR(io.op.sraqs, bw)
    val sraqs_c = MuxOR(io.op.sraqs, cw)
    val sraqs_d = MuxOR(io.op.sraqs, dw)
    val sraqs_f = MuxOR(io.op.sraqs, fw)

    val sub_a = MuxOR(io.op.sub.en, aw)
    val sub_b = MuxOR(io.op.sub.en, bw)
    val sub_r = io.op.sub.hsub && round

    // -------------------------------------------------------------------------
    // Functions.
    for (i <- 0 until cnt) {
      val l = i * size      // lsb
      val m = l + size - 1  // msb
      val ln = (i / 2) * 2 * size  // lsb narrowing
      val mn = ln + 2 * size - 1   // msb narrowing
      val lq = (i / 4) * 4 * size  // lsb narrowing
      val mq = lq + 4 * size - 1   // msb narrowing
      val mshamt = l + log2Ceil(size) - 1

      // -----------------------------------------------------------------------
      // Arithmetic.
      val add_sa = add_a(m) && signed
      val add_sb = add_b(m) && signed
      val adder = (Cat(add_sa, add_a(m,l)).asSInt +& Cat(add_sb, add_b(m,l)).asSInt).asUInt + add_r
      val sataddmsb = adder(size, size - 1)
      val sataddsel =
        Cat( signed && sataddmsb === 2.U,  // vadd.s -ve
             signed && sataddmsb === 1.U,  // vadd.s +ve
            !signed && sataddmsb(1))       // vadd.su +ve
      assert(PopCount(sataddsel) <= 1.U)

      val sub_sa = sub_a(m) && signed
      val sub_sb = sub_b(m) && signed
      val subtr = (Cat(sub_sa, sub_a(m,l)).asSInt -& Cat(sub_sb, sub_b(m,l)).asSInt).asUInt + sub_r
      val satsubmsb = subtr(size, size - 1)
      val satsubsel =
        Cat( signed && satsubmsb === 2.U,  // vsub.s -ve
             signed && satsubmsb === 1.U,  // vsub.s +ve
            !signed && satsubmsb(1))       // vsub.su 0
      assert(PopCount(satsubsel) <= 1.U)

      val rsubtr = rsub_b(m,l) - rsub_a(m,l)

      val xeq = cmp_a(m,l) === cmp_b(m,l)
      val xne = cmp_a(m,l) =/= cmp_b(m,l)
      val slt = cmp_a(m,l).asSInt < cmp_b(m,l).asSInt
      val ult = cmp_a(m,l) < cmp_b(m,l)
      val sle = slt || xeq
      val ule = ult || xeq

      val sult = Mux(signed, slt, ult)

      def Shift(a: UInt, b: UInt, sln: UInt, sra: UInt, srl: UInt): UInt = {
        assert(a.getWidth == size)
        assert(b.getWidth == size)
        assert(sln.getWidth == (2 * size - 1))
        assert(sra.getWidth == size)
        assert(srl.getWidth == size)
        val slnsz = sln(size - 1, 0)
        val input_neg = a(size - 1)
        val input_zero = a === 0.U
        val shamt_neg = b(size - 1)
        val rs = Wire(UInt(size.W))
        val ru = Wire(UInt(size.W))
        if (true) {
          val shamt_negsat = b.asSInt <= (-(size - 1)).S
          val shamt_possat = b.asSInt >= (size - 1).S
          val signb = ~0.U(size.W) >> (b(log2Ceil(size) - 1, 0) - 1.U)
          val possat = shamt_neg && !input_neg && (shamt_negsat || (sln(2 * size - 2, size - 1) =/= 0.U  )) && !input_zero
          val negsat = shamt_neg &&  input_neg && (shamt_negsat || (sln(2 * size - 2, size - 1) =/= signb))
          assert(!(possat && negsat))
          val posmax = Cat(0.U(1.W), ~0.U((size - 1).W))
          val negmin = Cat(1.U(1.W),  0.U((size - 1).W))
          assert(posmax.getWidth == size)
          assert(negmin.getWidth == size)

          rs := MuxOR(!shamt_neg && !shamt_possat, sra) |
                MuxOR(!shamt_neg &&  shamt_possat && input_neg, ~0.U(size.W)) |
                MuxOR( shamt_neg && !possat && !negsat, slnsz) |
                MuxOR( shamt_neg && possat, posmax) |
                MuxOR( shamt_neg && negsat, negmin)
        }
        if (true) {
          val shamt_negsat = b.asSInt <= -size.S
          val shamt_possat = b.asSInt >= size.S
          val possat = shamt_neg && (shamt_negsat || (sln(2 * size - 2, size) =/= 0.U)) && !input_zero
          val posmax = ~0.U(size.W)
          assert(posmax.getWidth == size)

          ru := MuxOR(!shamt_neg && !shamt_possat, srl) |
                MuxOR( shamt_neg && !possat, slnsz) |
                MuxOR( shamt_neg && possat, posmax)
        }
        Mux(signed, rs, ru)
      }

      def Round(a: UInt, b: UInt): UInt = {
        assert(a.getWidth == size)
        assert(b.getWidth == size)
        val input_neg = a(size - 1)
        val shamt_neg = b(size - 1)
        val shamt_zero = b === 0.U
        val rbit = Cat(a(size - 2, 0), a(size - 1))(b(log2Ceil(size) - 1, 0))  // shf: idx[8] == idx[0]
        val shamt_possat = Mux(signed, b.asSInt >= size.S, b.asSInt > size.S)
        val r = MuxOR(round && !shamt_possat && !shamt_neg && !shamt_zero, rbit) |
                MuxOR(round &&  shamt_possat && input_neg && signed, 1.U)
        assert(r.getWidth == 1)
        r
      }

      val shl = (shl_a(m,l) << shl_b(mshamt, l))(size - 1, 0)
      val sln = (shl_a(m,l) << (size.U - shl_b(mshamt, l)))(2 * size - 2, 0)
      val srl = shr_a(m,l) >> shr_b(mshamt, l)
      val srs = MuxOR(shr_a(m), ((~0.U(size.W)) << ((size - 1).U - shr_b(mshamt, l)))(size - 1, 0))
      val sra = srs | srl
      val shf = Shift(shl_a(m,l), shl_b(m,l), sln, sra, srl)
      val shr = Mux(signed, sra, srl)
      assert(shl.getWidth == size)
      assert(sln.getWidth == (2 * size - 1))
      assert(sra.getWidth == size)
      assert(srl.getWidth == size)
      assert(srs.getWidth == size)
      assert(shf.getWidth == size)

      val shf_rnd = Round(shl_a(m,l), shl_b(m,l))
      assert(shf_rnd.getWidth == 1)

      def Srans(s: Int, a: UInt, b: UInt): UInt = {
        assert(s == 2 || s == 4)
        assert(a.getWidth == size * s)
        assert(b.getWidth == size)

        val shamt = b(log2Ceil(s * size) - 1, 0)
        val srl = a >> shamt
        // Signed MSB padding for negative input a. Otherwise it should always
        // pad with zeros.
        val srs = MuxOR(a(s * size - 1) && signed,
                        ((~0.U((s * size).W)) << ((s * size - 1).U - shamt))(s * size - 1, 0))
        val sra = srs | srl
        assert(srl.getWidth == (s * size))
        assert(srs.getWidth == (s * size))
        val rbit = Cat(a(s * size - 2, 0), 0.U(1.W))(shamt)
        assert(rbit.getWidth == 1)

        val umax = ((1 << size) - 1).U((s * size).W)
        val smax = ((1 << (size - 1)) - 1).S((s * size).W)
        val smin = -(1 << (size - 1)).S((s * size).W)
        val rshf = Mux(round && rbit, sra + 1.U, sra)

        val is_umax = !signed && (rshf.asUInt > umax)
        // No unsigned negative capping because it's always >=0.
        val is_smax =  signed && (rshf.asSInt > smax)
        val is_smin =  signed && (rshf.asSInt < smin)
        val is_norm = !(is_umax || is_smax || is_smin)
        assert(PopCount(Cat(is_umax, is_smax, is_smin, is_norm)) <= 1.U)

        val r = MuxOR(is_umax, umax.asUInt(size - 1, 0)) |
                MuxOR(is_smax, smax.asUInt(size - 1, 0)) |
                MuxOR(is_smin, smin.asUInt(size - 1, 0)) |
                MuxOR(is_norm, rshf(size - 1, 0))
        assert(r.getWidth == size)
        r
      }

      def Rev(a: UInt, s: UInt): UInt = {
        if (size == 32) {
          val b = Mux(!s(0), a, Cat(a(30), a(31), a(28), a(29), a(26), a(27), a(24), a(25),
                                    a(22), a(23), a(20), a(21), a(18), a(19), a(16), a(17),
                                    a(14), a(15), a(12), a(13), a(10), a(11), a( 8), a( 9),
                                    a( 6), a( 7), a( 4), a( 5), a( 2), a( 3), a( 0), a( 1)))
          val c = Mux(!s(1), b, Cat(b(29,28), b(31,30), b(25,24), b(27,26),
                                    b(21,20), b(23,22), b(17,16), b(19,18),
                                    b(13,12), b(15,14), b( 9, 8), b(11,10),
                                    b( 5, 4), b( 7, 6), b( 1, 0), b( 3, 2)))
          val d = Mux(!s(2), c, Cat(c(27,24), c(31,28), c(19,16), c(23,20),
                                    c(11, 8), c(15,12), c( 3, 0), c( 7, 4)))
          val e = Mux(!s(3), d, Cat(d(23,16), d(31,24), d( 7, 0), d(15, 8)))
          val f = Mux(!s(4), e, Cat(e(15, 0), e(31,16)))
          assert(a.getWidth == 32)
          assert(b.getWidth == 32)
          assert(c.getWidth == 32)
          assert(d.getWidth == 32)
          assert(e.getWidth == 32)
          assert(f.getWidth == 32)
          f
        } else if (size == 16) {
          val b = Mux(!s(0), a, Cat(a(14), a(15), a(12), a(13), a(10), a(11), a( 8), a( 9),
                                    a( 6), a( 7), a( 4), a( 5), a( 2), a( 3), a( 0), a( 1)))
          val c = Mux(!s(1), b, Cat(b(13,12), b(15,14), b( 9, 8), b(11,10),
                                    b( 5, 4), b( 7, 6), b( 1, 0), b( 3, 2)))
          val d = Mux(!s(2), c, Cat(c(11, 8), c(15,12), c( 3, 0), c( 7, 4)))
          val e = Mux(!s(3), d, Cat(d( 7, 0), d(15, 8)))
          assert(a.getWidth == 16)
          assert(b.getWidth == 16)
          assert(c.getWidth == 16)
          assert(d.getWidth == 16)
          assert(e.getWidth == 16)
          e
        } else {
          val b = Mux(!s(0), a, Cat(a(6), a(7), a(4), a(5), a(2), a(3), a(0), a(1)))
          val c = Mux(!s(1), b, Cat(b(5, 4), b(7, 6), b(1, 0), b( 3, 2)))
          val d = Mux(!s(2), c, Cat(c(3, 0), c(7, 4)))
          assert(a.getWidth == 8)
          assert(b.getWidth == 8)
          assert(c.getWidth == 8)
          assert(d.getWidth == 8)
          d
        }
      }

      def Ror(a: UInt, s: UInt): UInt = {
        if (size == 32) {
          val b = Mux(!s(0), a, Cat(a(0), a(31,1)))
          val c = Mux(!s(1), b, Cat(b(1,0), b(31,2)))
          val d = Mux(!s(2), c, Cat(c(3,0), c(31,4)))
          val e = Mux(!s(3), d, Cat(d(7,0), d(31,8)))
          val f = Mux(!s(4), e, Cat(e(15,0), e(31,16)))
          assert(a.getWidth == 32)
          assert(b.getWidth == 32)
          assert(c.getWidth == 32)
          assert(d.getWidth == 32)
          assert(e.getWidth == 32)
          assert(f.getWidth == 32)
          f
        } else if (size == 16) {
          val b = Mux(!s(0), a, Cat(a(0), a(15,1)))
          val c = Mux(!s(1), b, Cat(b(1,0), b(15,2)))
          val d = Mux(!s(2), c, Cat(c(3,0), c(15,4)))
          val e = Mux(!s(3), d, Cat(d(7,0), d(15,8)))
          assert(a.getWidth == 16)
          assert(b.getWidth == 16)
          assert(c.getWidth == 16)
          assert(d.getWidth == 16)
          assert(e.getWidth == 16)
          e
        } else {
          val b = Mux(!s(0), a, Cat(a(0), a(7,1)))
          val c = Mux(!s(1), b, Cat(b(1,0), b(7,2)))
          val d = Mux(!s(2), c, Cat(c(3,0), c(7,4)))
          assert(a.getWidth == 8)
          assert(b.getWidth == 8)
          assert(c.getWidth == 8)
          assert(d.getWidth == 8)
          d
        }
      }

      val mul0_as = Cat(signed && mul0_a(m), mul0_a(m,l))
      val mul0_bs = Cat(signed && mul0_b(m), mul0_b(m,l))
      val mul0_sign = mul0_a(m) =/= mul0_b(m) && mul0_a(m,l) =/= 0.U && mul0_b(m,l) =/= 0.U
      val prod0 = (mul0_as.asSInt * mul0_bs.asSInt).asUInt
      val prodh0 = prod0(2 * size - 1, size)
      val proddh0 = prod0(2 * size - 2, size - 1)

      val mul1_as = Cat(signed && mul1_a(m), mul1_a(m,l))
      val mul1_bs = Cat(signed && mul1_b(m), mul1_b(m,l))
      val mul1_sign = mul1_a(m) =/= mul1_b(m) && mul1_a(m,l) =/= 0.U && mul1_b(m,l) =/= 0.U
      val prod1 = (mul1_as.asSInt * mul1_bs.asSInt).asUInt
      val prodh1 = prod1(2 * size - 1, size)
      val proddh1 = prod1(2 * size - 2, size - 1)

      val muls0_umax = !signed && prodh0 =/= 0.U
      val muls0_smax =  signed && !mul0_sign && ( prod0(size - 1) || prodh0 =/=  0.U(size.W))
      val muls0_smin =  signed &&  mul0_sign && (!prod0(size - 1) || prodh0 =/= ~0.U(size.W))
      val muls0_base = !(muls0_umax || muls0_smax || muls0_smin)
      assert(PopCount(Cat(muls0_umax, muls0_smax, muls0_smin, muls0_base)) <= 1.U)

      val muls1_umax = !signed && prodh1 =/= 0.U
      val muls1_smax =  signed && !mul1_sign && ( prod1(size - 1) || prodh1 =/=  0.U(size.W))
      val muls1_smin =  signed &&  mul1_sign && (!prod1(size - 1) || prodh1 =/= ~0.U(size.W))
      val muls1_base = !(muls1_umax || muls1_smax || muls1_smin)
      assert(PopCount(Cat(muls1_umax, muls1_smax, muls1_smin, muls1_base)) <= 1.U)

      val maxneg  = Cat(1.U(1.W), 0.U((size - 1).W))  // 0x80...

      val dmulh0_possat = mul0_a(m,l) === maxneg && mul0_b(m,l) === maxneg

      val dmulh1_possat = mul1_a(m,l) === maxneg && mul1_b(m,l) === maxneg

      val dmulh0 = MuxOR(!dmulh0_possat, proddh0) |
                   MuxOR(dmulh0_possat, Cat(0.U(1.W), ~0.U((size - 1).W)))    // 0x7f...

      val dmulh1 = MuxOR(!dmulh1_possat, proddh1) |
                   MuxOR(dmulh1_possat, Cat(0.U(1.W), ~0.U((size - 1).W)))    // 0x7f...

      val mulh0 = prodh0
      val mulh1 = prodh1

      val muls0 = MuxOR(muls0_umax, ~0.U(size.W)) |
                  MuxOR(muls0_smax, ~0.U((size - 1).W)) |
                  MuxOR(muls0_smin, Cat(1.U(1.W), 0.U((size - 1).W))) |
                  MuxOR(muls0_base, prod0(size - 1, 0))

      val muls1 = MuxOR(muls1_umax, ~0.U(size.W)) |
                  MuxOR(muls1_smax, ~0.U((size - 1).W)) |
                  MuxOR(muls1_smin, Cat(1.U(1.W), 0.U((size - 1).W))) |
                  MuxOR(muls1_base, prod1(size - 1, 0))

      val dmulh0_rnd = MuxOR(round && io.op.mul0.dmulh && io.in.sz(sz) && !dmulh0_possat,
                             Mux(negative && mul0_sign,
                                 MuxOR(!prod0(size - 2), ~0.U(size.W)),   // -1
                                 MuxOR( prod0(size - 2),  1.U(size.W))))  // +1

      val dmulh1_rnd = MuxOR(round && io.op.mul1.dmulh && io.in.sz(sz) && !dmulh1_possat,
                             Mux(negative && mul1_sign,
                                 MuxOR(!prod1(size - 2), ~0.U(size.W)),   // -1
                                 MuxOR( prod1(size - 2),  1.U(size.W))))  // +1

      val mulh0_rnd = round && io.op.mul0.mulh && prod0(size - 1)
      val mulh1_rnd = round && io.op.mul1.mulh && prod1(size - 1)

      // -----------------------------------------------------------------------
      // Operations.
      val absd = MuxOR(io.op.absd, Mux(sult, rsubtr, subtr(size - 1, 0)))
      assert(absd.getWidth == size)

      val acc = if (sz == 0 || sz == 1) {  // size / 2
                  if ((i & 1) == 0) {
                    acc_a(mn,ln) + SignExt(Cat(signed & acc_b(m), acc_b(m,l)), 2 * size)
                  } else {
                    acc_c(mn,ln) + SignExt(Cat(signed & acc_b(m), acc_b(m,l)), 2 * size)
                  }
                } else {
                  0.U((2 * size).W)
                }
      assert(acc.getWidth == (2 * size))

      val add = MuxOR(sataddsel(2) && io.op.add.adds, Cat(1.U(1.W), 0.U((size - 1).W))) |
                MuxOR(sataddsel(1) && io.op.add.adds, ~0.U((size - 1).W)) |
                MuxOR(sataddsel(0) && io.op.add.adds, ~0.U(size.W)) |
                MuxOR(sataddsel === 0.U && io.op.add.adds || io.op.add.add || io.op.add.add3, adder(size - 1, 0)) |
                MuxOR(io.op.add.hadd, adder(size, 1))

      val addw = MuxOR(io.op.add.addw, SignExt(adder, 2 * size))
      assert(addw.getWidth == (2 * size))

      val dup = MuxOR(io.op.dup, io.read(1).data(m,l))

      val max = MuxOR(io.op.max, Mux(sult, cmp_b(m,l), cmp_a(m,l)))
      val min = MuxOR(io.op.min, Mux(sult, cmp_a(m,l), cmp_b(m,l)))

      val mul0 = MuxOR(io.op.mul0.mul || io.op.mul0.madd, prod0(size - 1, 0)) |
                 MuxOR(io.op.mul0.dmulh, dmulh0) |
                 MuxOR(io.op.mul0.mulh, mulh0) |
                 MuxOR(io.op.mul0.muls, muls0)

      val mul1 = MuxOR(io.op.mul1.mul, prod1(size - 1, 0)) |
                 MuxOR(io.op.mul1.dmulh, dmulh1) |
                 MuxOR(io.op.mul1.mulh, mulh1) |
                 MuxOR(io.op.mul1.muls, muls1)

      val mulw = MuxOR(io.op.mul0.mulw, prod0(2 * size - 1, 0))

      val padd =
        if (sz == 1 || sz == 2) {
          val p0 = i * size
          val p1 = p0 + size / 2 - 1
          val p2 = p1 + 1
          val p3 = p0 + size - 1
          val a = Cat(signed && padd_a(p1), padd_a(p1,p0))
          val b = Cat(signed && padd_a(p3), padd_a(p3,p2))
          val add = MuxOR(io.op.padd.add, SignExt((a.asSInt +& b.asSInt).asUInt, size))
          val sub = MuxOR(io.op.padd.sub, SignExt((a.asSInt -& b.asSInt).asUInt, size))
          assert(add.getWidth == size)
          assert(sub.getWidth == size)
          add | sub
        } else {
          0.U(size.W)
        }

      val rsub = MuxOR(io.op.rsub.rsub, rsubtr)

      val srans = if (sz == 0 || sz == 1) {  // size / 2
                    if ((i & 1) == 0) {
                      Srans(2, srans_a(mn,ln), srans_b(m,l))
                    } else {
                      Srans(2, srans_c(mn,ln), srans_b(m,l))
                    }
                  } else {
                    0.U(size.W)
                  }

      val sraqs = if (sz == 0) {  // size / 4
                    if ((i & 3) == 0) {
                      Srans(4, sraqs_a(mq,lq), sraqs_b(m,l))
                    } else if ((i & 3) == 1) {
                      Srans(4, sraqs_d(mq,lq), sraqs_b(m,l))
                    } else if ((i & 3) == 2) {
                      Srans(4, sraqs_c(mq,lq), sraqs_b(m,l))
                    } else {
                      Srans(4, sraqs_f(mq,lq), sraqs_b(m,l))
                    }
                  } else {
                    0.U(size.W)
                  }

      val sub = MuxOR(satsubsel(2) && io.op.sub.subs, Cat(1.U(1.W), 0.U((size - 1).W))) |
                MuxOR(satsubsel(1) && io.op.sub.subs, ~0.U((size - 1).W)) |
                MuxOR(satsubsel(0) && io.op.sub.subs, 0.U(size.W)) |
                MuxOR(satsubsel === 0.U && io.op.sub.subs || io.op.sub.sub, subtr(size - 1, 0)) |
                MuxOR(io.op.sub.hsub, subtr(size, 1))

      val subw = MuxOR(io.op.sub.subw, SignExt(subtr, 2 * size))
      assert(subw.getWidth == (2 * size))

      val cmp = io.in.sz(sz) &&
                  (MuxOR(io.op.cmp.eq, xeq) |
                   MuxOR(io.op.cmp.ne, xne) |
                   MuxOR(io.op.cmp.lt &&  signed, slt) |
                   MuxOR(io.op.cmp.lt && !signed, ult) |
                   MuxOR(io.op.cmp.le &&  signed, sle) |
                   MuxOR(io.op.cmp.le && !signed, ule) |
                   MuxOR(io.op.cmp.gt &&  signed, !sle) |
                   MuxOR(io.op.cmp.gt && !signed, !ule) |
                   MuxOR(io.op.cmp.ge &&  signed, !slt) |
                   MuxOR(io.op.cmp.ge && !signed, !ult))
      assert(cmp.getWidth == 1)

      val log =
        MuxOR(io.op.log.and,  log_a(m,l) & log_b(m,l)) |
        MuxOR(io.op.log.or,   log_a(m,l) | log_b(m,l)) |
        MuxOR(io.op.log.xor,  log_a(m,l) ^ log_b(m,l)) |
        MuxOR(io.op.log.not,  MuxOR(io.in.sz(sz), ~log_a(m,l))) |
        MuxOR(io.op.log.rev,  Rev(log_a(m,l), log_b(m,l))) |
        MuxOR(io.op.log.ror,  MuxOR(io.in.sz(sz), Ror(log_a(m,l), log_b(m,l)))) |
        MuxOR(io.op.log.clb,  MuxOR(io.in.sz(sz), Clb(log_a(m,l)))) |
        MuxOR(io.op.log.clz,  MuxOR(io.in.sz(sz), Clz(log_a(m,l)))) |
        MuxOR(io.op.log.cpop, PopCount(log_a(m,l)))
      assert(log.getWidth == size)

      val shift =
        MuxOR(io.op.shf.shl, shl) |
        MuxOR(io.op.shf.shr, shr) |
        MuxOR(io.op.shf.shf, shf)
      assert(shf.getWidth == size)

      val alu_oh = Cat(absd  =/= 0.U,
                       add   =/= 0.U,
                       cmp   =/= 0.U,
                       dup   =/= 0.U,
                       log   =/= 0.U,
                       max   =/= 0.U,
                       min   =/= 0.U,
                       mul0  =/= 0.U,
                       padd  =/= 0.U,
                       rsub  =/= 0.U,
                       shift =/= 0.U,
                       srans =/= 0.U,
                       sraqs =/= 0.U,
                       sub   =/= 0.U)

      assert(PopCount(alu_oh) <= 1.U)

      alu0(i) := mul0 | absd | add | cmp | dup | log | max | min | padd | rsub | shift | srans | sraqs | sub |
                 MuxOR(io.op.mv, aw(m,l))

      alu1(i) := mul1 |
                 MuxOR(io.op.mvp, bw(m,l)) |
                 MuxOR(io.op.mv2, cw(m,l))

      rnd0(i) := dmulh0_rnd | mulh0_rnd | shf_rnd
      rnd1(i) := dmulh1_rnd | mulh1_rnd

      if (sz < 2) {
        if ((i & 1) == 0) {
          aluw0(i / 2) := acc | addw | mulw | subw
        } else {
          aluw1(i / 2) := acc | addw | mulw | subw
        }
      }
    }

    val out_alu0 = alu0.asUInt
    val out_alu1 = alu1.asUInt
    val out_rnd0 = rnd0.asUInt
    val out_rnd1 = rnd1.asUInt
    val out_aluw0 = aluw0.asUInt
    val out_aluw1 = aluw1.asUInt
    assert(out_alu0.getWidth == a.getWidth)
    assert(out_alu1.getWidth == a.getWidth)
    assert(out_rnd0.getWidth == a.getWidth)
    if (sz < 2) {
      assert(out_aluw0.getWidth == a.getWidth)
      assert(out_aluw1.getWidth == a.getWidth)
    }

    (out_alu0, out_alu1, out_rnd0, out_rnd1, out_aluw0, out_aluw1)
  }

  // ---------------------------------------------------------------------------
  // Data mux.
  val ina_b = MuxOR(io.in.sz(0), io.read(0).data)
  val inb_b = MuxOR(io.in.sz(0), io.read(1).data)
  val inc_b = MuxOR(io.in.sz(0), io.read(2).data)
  val ind_b = MuxOR(io.in.sz(0), io.read(3).data)
  val ine_b = MuxOR(io.in.sz(0), io.read(4).data)
  val inf_b = MuxOR(io.in.sz(0), io.read(5).data)

  val ina_h = MuxOR(io.in.sz(1), io.read(0).data)
  val inb_h = MuxOR(io.in.sz(1), io.read(1).data)
  val inc_h = MuxOR(io.in.sz(1), io.read(2).data)
  val ind_h = MuxOR(io.in.sz(1), io.read(4).data)
  val ine_h = MuxOR(io.in.sz(1), io.read(5).data)
  val inf_h = MuxOR(io.in.sz(1), io.read(6).data)

  val ina_w = MuxOR(io.in.sz(2), io.read(0).data)
  val inb_w = MuxOR(io.in.sz(2), io.read(1).data)
  val inc_w = MuxOR(io.in.sz(2), io.read(2).data)
  val ind_w = MuxOR(io.in.sz(2), io.read(3).data)
  val ine_w = MuxOR(io.in.sz(2), io.read(4).data)
  val inf_w = MuxOR(io.in.sz(2), io.read(5).data)

  val (outb0, outb1, rndb0, rndb1, outwb0, outwb1) = VAlu(0, ina_b, inb_b, inc_b, ind_b, ine_b, inf_b)
  val (outh0, outh1, rndh0, rndh1, outwh0, outwh1) = VAlu(1, ina_h, inb_h, inc_h, ind_h, ine_h, inf_h)
  val (outw0, outw1, rndw0, rndw1,      _,      _) = VAlu(2, ina_w, inb_w, inc_w, ind_w, ine_w, inf_w)

  val out0 = outb0 | outh0 | outw0 | outwb0 | outwh0
  val out1 = outb1 | outh1 | outw1 | outwb1 | outwh1
  val rnd0 = rndb0 | rndh0 | rndw0
  val rnd1 = rndb1 | rndh1 | rndw1

  // ---------------------------------------------------------------------------
  // Accumulator second input.
  val accvalid0 = io.op.dwinit || io.op.mul0.dmulh || io.op.mul0.mulh || io.op.add.add3 || io.op.mul0.madd || io.op.shf.shf
  val accvalid1 = io.op.dwinit || io.op.mul1.dmulh || io.op.mul1.mulh

  val accum0 = MuxOR(io.op.add.add3 ||
                     io.op.mul0.madd, io.read(2).data) |
               MuxOR(io.op.mul0.dmulh ||
                     io.op.mul0.mulh ||
                     io.op.shf.shf, rnd0) |
               MuxOR(io.op.dwinit, io.read(0).data)

  val accum1 = MuxOR(io.op.mul1.dmulh ||
                     io.op.mul1.mulh, rnd1) |
               MuxOR(io.op.dwinit, io.read(1).data)

  // ---------------------------------------------------------------------------
  // Registration.
  val wsz = RegInit(0.U(3.W))
  val waccvalid0 = RegInit(false.B)
  val waccvalid1 = RegInit(false.B)
  val wdata0 = Reg(UInt(32.W))
  val waccm0 = Reg(UInt(32.W))
  val wdata1 = Reg(UInt(32.W))
  val waccm1 = Reg(UInt(32.W))

  wsz := MuxOR(io.in.vdvalid || io.in.vevalid, io.in.sz)
  waccvalid0 := accvalid0 || io.op.dwconv
  waccvalid1 := accvalid1 || io.op.dwconv

  when (io.in.vdvalid) {
    wdata0 := out0 | io.load(0)
  }

  when (accvalid0) {
    waccm0 := accum0
  } .elsewhen (io.op.dwconvData) {
    waccm0 := io.write(0).data
  }

  when (io.in.vevalid) {
    wdata1 := out1 | io.load(1)
  }

  when (accvalid1) {
    waccm1 := accum1
  } .elsewhen (io.op.dwconvData) {
    waccm1 := io.write(1).data
  }

  def Accum(en: Bool, d: UInt, a: UInt): UInt = {
    val dm = MuxOR(en, d)
    val am = MuxOR(en, a)
    val rm = MuxOR(en && wsz(0), Cat(dm(31,24) + am(31,24),
                                     dm(23,16) + am(23,16),
                                     dm(15, 8) + am(15, 8),
                                     dm( 7, 0) + am( 7, 0))) |
             MuxOR(en && wsz(1), Cat(dm(31,16) + am(31,16),
                                     dm(15, 0) + am(15, 0))) |
             MuxOR(en && wsz(2), dm(31, 0) + am(31, 0))
    val rn = MuxOR(!en, d)
    assert(rm.getWidth == 32)
    assert(rn.getWidth == 32)
    rm | rn
  }

  io.write(0).data := Accum(waccvalid0, wdata0, waccm0)
  io.write(1).data := Accum(waccvalid1, wdata1, waccm1)
}

@nowarn
object EmitVAluInt extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new VAluInt(p, 0))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
