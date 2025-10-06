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
import _root_.circt.stage.ChiselStage

class VDecodeInstruction(p: Parameters) extends Module {
  val dec = new VDecodeOp()
  val enc = new VEncodeOp()

  val io = IO(new Bundle {
    val in = new Bundle {
      val inst = Input(UInt(32.W))
      val addr = Input(UInt(32.W))
      val data = Input(UInt(32.W))
    }
    val out = Output(new VDecodeBits)
    val cmdq = Output(new VDecodeCmdq)
    val actv = Output(new VDecodeActive)
    val undef = Output(Bool())
  })

  val inst = io.in.inst
  val addr = io.in.addr
  val data = io.in.data

  val v     = inst(0)  // .vv .vx
  val x     = inst(1)  // .vx
  val x3    = inst(2)  // .vxv
  val func1 = inst(4,2)
  val m     = inst(5)
  val sz    = inst(13,12)
  val func2 = inst(31,26)

  val vdbits = inst(11,6)
  val vsbits = inst(19,14)
  val vtbits = inst(25,20)
  val vubits = inst(31,26)

  val quad = m && x  // dual issue across ALUs

  def DecodeFmt(f1: Int, f2: Int, mask: Int = 0): Bool = {
    assert(inst.getWidth == 32)
    val m2 = ~mask.U(6.W)  // unsigned, rounding, ...
    v === 0.U && func1 === f1.U && (func2 & m2) === (f2.U & m2) && sz < 3.U
  }

  def ToM(a: UInt): UInt = {
    val bbits = Wire(Vec(16, UInt(4.W)))
    for (i <- 0 until 16) {
      val v = a(i)
      bbits(i) := Cat(v, v, v, v)
    }
    val b = bbits.asUInt
    assert(a.getWidth == 16)
    assert(b.getWidth == 64)
    b
  }

  def RActiveVsVt(i: Int): UInt = {
    assert(i == 2 || i == 3)
    val vs  = UIntToOH(vsbits, 64)
    val vsm = MuxOR(m, ToM(UIntToOH(vsbits(5,2), 16)))
    val vt =
      if (i == 2) {
        MuxOR(!x, UIntToOH(vtbits, 64))
      } else {
        MuxOR(!x3, UIntToOH(vtbits, 64))
      }
    val vtm =
      if (i == 2) {
        MuxOR(m && !x, ToM(UIntToOH(vtbits(5,2), 16)))
      } else {
        MuxOR(m && !x3, ToM(UIntToOH(vtbits(5,2), 16)))
      }
    assert(vs.getWidth == 64)
    assert(vt.getWidth == 64)
    assert(vsm.getWidth == 64)
    assert(vtm.getWidth == 64)
    vs | vsm | vt | vtm
  }

  def RActiveVs1(): UInt = {
    // {vs+1} or {vsm+4}
    val vs  = Cat(UIntToOH(vsbits, 64), 0.U(1.W))(63,0)
    val vsm = MuxOR(m, Cat(ToM(UIntToOH(vsbits(5,2), 16)), 0.U(4.W))(63,0))
    assert(vs.getWidth == 64)
    assert(vsm.getWidth == 64)
    vs | vsm
  }

  def RActiveVs2(): UInt = {
    // {vs+2} or {vsm+8}
    val vs  = Cat(UIntToOH(vsbits, 64), 0.U(2.W))(63,0)
    val vsm = MuxOR(m, Cat(ToM(UIntToOH(vsbits(5,2), 16)), 0.U(8.W))(63,0))
    assert(vs.getWidth == 64)
    assert(vsm.getWidth == 64)
    vs | vsm
  }

  def RActiveVs3(): UInt = {
    // {vs+3} or {vsm+12}
    val vs  = Cat(UIntToOH(vsbits, 64), 0.U(3.W))(63,0)
    val vsm = MuxOR(m, Cat(ToM(UIntToOH(vsbits(5,2), 16)), 0.U(12.W))(63,0))
    assert(vs.getWidth == 64)
    assert(vsm.getWidth == 64)
    vs | vsm
  }

  def RActiveVd(): UInt = {
    val vd  = UIntToOH(vdbits, 64)
    val vdm = MuxOR(m, ToM(UIntToOH(vdbits(5,2), 16)))
    assert(vd.getWidth == 64)
    assert(vdm.getWidth == 64)
    vd | vdm
  }

  def RActiveVu(): UInt = {
    val vu  = UIntToOH(vubits, 64)
    val vum = MuxOR(m, ToM(UIntToOH(vubits(5,2), 16)))
    assert(vu.getWidth == 64)
    assert(vum.getWidth == 64)
    vu | vum
  }

  def WActiveVd(): UInt = {
    val vd  = UIntToOH(vdbits, 64)
    val vdm = MuxOR(m, ToM(UIntToOH(vdbits(5,2), 16)))
    assert(vd.getWidth == 64)
    assert(vdm.getWidth == 64)
    vd | vdm
  }

  def WActiveVd1(): UInt = {
    // {vd+1} or {vdm+4}
    val vd  = Cat(UIntToOH(vdbits, 64), 0.U(1.W))(63,0)
    val vdm = MuxOR(m, Cat(ToM(UIntToOH(vdbits(5,2), 16)), 0.U(4.W))(63,0))
    assert(vd.getWidth == 64)
    assert(vdm.getWidth == 64)
    vd | vdm
  }

  def DepthwiseRead(): (UInt, UInt, UInt, UInt, UInt, UInt, UInt) = {
    val vstbl = VecInit(0.U, 1.U, 2.U, 3.U, 4.U, 5.U, 6.U, 1.U, 1.U, 3.U, 5.U, 7.U, 2.U, 4.U, 6.U, 8.U)
    val vttbl = VecInit(1.U, 2.U, 3.U, 4.U, 5.U, 6.U, 7.U, 0.U, 2.U, 4.U, 6.U, 8.U, 0.U, 0.U, 0.U, 0.U)
    val vutbl = VecInit(2.U, 3.U, 4.U, 5.U, 6.U, 7.U, 8.U, 2.U, 0.U, 0.U, 0.U, 0.U, 1.U, 1.U, 1.U, 1.U)

    val regbase = data(7,4)

    val vs = vsbits + vstbl(regbase)
    val vt = vsbits + vttbl(regbase)
    val vu = vsbits + vutbl(regbase)
    assert(vs.getWidth == 6)
    assert(vt.getWidth == 6)
    assert(vu.getWidth == 6)

    val vx = vubits
    val vy = vubits + Mux(m, 4.U, 1.U)
    val vz = vubits + Mux(m, 8.U, 2.U)
    assert(vx.getWidth == 6)
    assert(vy.getWidth == 6)
    assert(vz.getWidth == 6)

    val ra_vs  = UIntToOH(vs, 64)
    val ra_vt  = UIntToOH(vt, 64)
    val ra_vu  = UIntToOH(vu, 64)
    val ra_vx  = UIntToOH(vx, 64)
    val ra_vy  = UIntToOH(vy, 64)
    val ra_vz  = UIntToOH(vz, 64)
    val ra_vxm = MuxOR(m, ToM(UIntToOH(vx(5,2), 16)))
    val ra_vym = MuxOR(m, ToM(UIntToOH(vy(5,2), 16)))
    val ra_vzm = MuxOR(m, ToM(UIntToOH(vz(5,2), 16)))
    assert(ra_vs.getWidth == 64)
    assert(ra_vt.getWidth == 64)
    assert(ra_vu.getWidth == 64)
    assert(ra_vx.getWidth == 64)
    assert(ra_vy.getWidth == 64)
    assert(ra_vz.getWidth == 64)
    assert(ra_vxm.getWidth == 64)
    assert(ra_vym.getWidth == 64)
    assert(ra_vzm.getWidth == 64)

    val ractive = ra_vs | ra_vt | ra_vu | ra_vx | ra_vy | ra_vz | ra_vxm | ra_vym | ra_vzm
    assert(ractive.getWidth == 64)

    (vs, vt, vu, vx, vy, vz, ractive)
  }

  def SlideRead(): (UInt, UInt, UInt, UInt, UInt, UInt, UInt) = {
    val s = func2(3)  // next(0) previous(1)
    val vs = Mux(s, vsbits + 3.U, vsbits + 0.U)
    val vt = Mux(s, vtbits + 0.U, vsbits + 1.U)
    val vu = Mux(s, vtbits + 1.U, vsbits + 2.U)
    val vx = Mux(s, vtbits + 1.U, vsbits + 2.U)
    val vy = Mux(s, vtbits + 2.U, vsbits + 3.U)
    val vz = Mux(s, vtbits + 3.U, vtbits + 0.U)
    assert(vs.getWidth == 6)
    assert(vt.getWidth == 6)
    assert(vu.getWidth == 6)
    assert(vx.getWidth == 6)
    assert(vy.getWidth == 6)
    assert(vz.getWidth == 6)

    val ra_vs  =                 UIntToOH(vs, 64)
    val ra_vt  = MuxOR(!x || !s, UIntToOH(vt, 64))
    val ra_vu  = MuxOR(!x || !s, UIntToOH(vu, 64))
    val ra_vx  = MuxOR(!x || !s, UIntToOH(vx, 64))
    val ra_vy  = MuxOR(!x || !s, UIntToOH(vy, 64))
    val ra_vz  = MuxOR(!x,       UIntToOH(vz, 64))
    assert(ra_vs.getWidth == 64)
    assert(ra_vt.getWidth == 64)
    assert(ra_vu.getWidth == 64)
    assert(ra_vx.getWidth == 64)
    assert(ra_vy.getWidth == 64)
    assert(ra_vz.getWidth == 64)

    val ractive = ra_vs | ra_vt | ra_vu | ra_vx | ra_vy | ra_vz
    assert(ractive.getWidth == 64)

    (vs, vt, vu, vx, vy, vz, ractive)
  }

  // ---------------------------------------------------------------------------
  // Decode the instruction bits.

  // Duplicate
  val vdup = inst === BitPat("b01000?_0?????_000000_??_??????_?_111_11") && sz < 3.U
  val vdupf2 = inst(31,27) === 8.U  // used to prevent vdup and vldst op collision only

  // Load/Store
  val vldstdec = inst === BitPat("b??????_0?????_?????0_??_??????_?_111_11") && sz < 3.U && !vdupf2
  assert(!(vdup && vldstdec))

  val vld  = vldstdec && (func2 === 0.U || func2 === 1.U || func2 === 2.U ||
                          func2 === 4.U || func2 === 5.U || func2 === 6.U ||
                          func2 === 7.U)

  val vst  = vldstdec && (func2 === 8.U || func2 === 9.U || func2 === 10.U ||
                          func2 === 12.U || func2 === 13.U || func2 === 14.U ||
                          func2 === 15.U)

  val vstq = vldstdec && (func2 === 26.U || func2 === 30.U)

  val vldst = vld || vst || vstq

  // Format0
  val vadd  = DecodeFmt(0, dec.vadd)
  val vsub  = DecodeFmt(0, dec.vsub)
  val vrsub = DecodeFmt(0, dec.vrsub)
  val veq   = DecodeFmt(0, dec.veq)
  val vne   = DecodeFmt(0, dec.vne)
  val vlt   = DecodeFmt(0, dec.vlt, 1)
  val vle   = DecodeFmt(0, dec.vle, 1)
  val vgt   = DecodeFmt(0, dec.vgt, 1)
  val vge   = DecodeFmt(0, dec.vge, 1)
  val vabsd = DecodeFmt(0, dec.vabsd, 1)
  val vmax  = DecodeFmt(0, dec.vmax, 1)
  val vmin  = DecodeFmt(0, dec.vmin, 1)
  val vadd3 = DecodeFmt(0, dec.vadd3)

  val vfmt0 = vadd || vsub || vrsub || veq || vne || vlt || vle || vgt || vge || vabsd || vmax || vmin || vadd3

  // Format1
  val vand  = DecodeFmt(1, dec.vand)
  val vor   = DecodeFmt(1, dec.vor)
  val vxor  = DecodeFmt(1, dec.vxor)
  val vnot  = DecodeFmt(1, dec.vnot)
  val vrev  = DecodeFmt(1, dec.vrev)
  val vror  = DecodeFmt(1, dec.vror)
  val vclb  = DecodeFmt(1, dec.vclb)
  val vclz  = DecodeFmt(1, dec.vclz)
  val vcpop = DecodeFmt(1, dec.vcpop)
  val vmv   = DecodeFmt(1, dec.vmv) && !quad
  val vmv2  = DecodeFmt(1, dec.vmv) &&  quad
  val vmvp  = DecodeFmt(1, dec.vmvp)

  val vfmt1 = vand || vor || vxor || vnot || vrev || vror || vclb || vclz || vcpop || vmv || vmv2 || vmvp

  // do not include in 'vfmt1'
  val acset   = DecodeFmt(1, dec.acset) && x && !m && vtbits === 0.U
  val actr    = DecodeFmt(1, dec.actr)  && x && !m && vtbits === 0.U
  val adwinit = DecodeFmt(1, dec.adwinit)

  // Format2
  val vsll   = DecodeFmt(2, dec.vsll)
  val vsra   = DecodeFmt(2, dec.vsra)
  val vsrl   = DecodeFmt(2, dec.vsrl)
  val vsha   = DecodeFmt(2, dec.vsha, 2)
  val vshl   = DecodeFmt(2, dec.vshl, 2)
  val vsrans = DecodeFmt(2, dec.vsrans, 3)
  val vsraqs = DecodeFmt(2, dec.vsraqs, 3)

  val vfmt2 = vsll || vsra || vsrl || vsha || vshl || vsrans || vsraqs

  // Format3
  val vmul    = DecodeFmt(3, dec.vmul) && !quad
  val vmul2   = DecodeFmt(3, dec.vmul) &&  quad
  val vmuls   = DecodeFmt(3, dec.vmuls, 1) && !quad
  val vmuls2  = DecodeFmt(3, dec.vmuls, 1) &&  quad
  val vmulh   = DecodeFmt(3, dec.vmulh, 2) && !quad
  val vmulh2  = DecodeFmt(3, dec.vmulh, 2) &&  quad
  val vmulhu  = DecodeFmt(3, dec.vmulhu, 2) && !quad
  val vmulhu2 = DecodeFmt(3, dec.vmulhu, 2) &&  quad
  val vdmulh  = DecodeFmt(3, dec.vdmulh, 3) && !quad
  val vdmulh2 = DecodeFmt(3, dec.vdmulh, 3) &&  quad
  val vmulw   = DecodeFmt(3, dec.vmulw, 1)
  val vmacc   = DecodeFmt(3, dec.vmacc)
  val vmadd   = DecodeFmt(3, dec.vmadd)

  val vfmt3 = vmul || vmul2 || vmuls || vmuls2 || vmulh || vmulh2 || vmulhu || vmulhu2 || vdmulh || vdmulh2 || vmulw || vmacc || vmadd

  // Format4
  val vadds  = DecodeFmt(4, dec.vadds, 1)
  val vsubs  = DecodeFmt(4, dec.vsubs, 1)
  val vaddw  = DecodeFmt(4, dec.vaddw, 1)
  val vsubw  = DecodeFmt(4, dec.vsubw, 1)
  val vacc   = DecodeFmt(4, dec.vacc, 1)
  val vpadd  = DecodeFmt(4, dec.vpadd, 1)
  val vpsub  = DecodeFmt(4, dec.vpsub, 1)
  val vhadd  = DecodeFmt(4, dec.vhadd, 3)
  val vhsub  = DecodeFmt(4, dec.vhsub, 3)

  val vfmt4 = vadds || vsubs || vaddw || vsubw || vacc || vpadd || vpsub || vhadd || vhsub

  // Format6
  val vslidevn  = DecodeFmt(6, dec.vslidevn, 3)
  val vslidehn  = DecodeFmt(6, dec.vslidehn, 3) && !m
  val vslidehn2 = DecodeFmt(6, dec.vslidehn, 3) && m
  val vslidevp  = DecodeFmt(6, dec.vslidevp, 3)
  val vslidehp  = DecodeFmt(6, dec.vslidehp, 3) && !m
  val vslidehp2 = DecodeFmt(6, dec.vslidehp, 3) && m
  val vsel      = DecodeFmt(6, dec.vsel)
  val vevn      = DecodeFmt(6, dec.vevn)
  val vodd      = DecodeFmt(6, dec.vodd)
  val vevnodd   = DecodeFmt(6, dec.vevnodd)
  val vzip      = DecodeFmt(6, dec.vzip)

  val vslideh2 = vslidehn2 || vslidehp2
  val vevn3 = vevn || vevnodd || vodd

  val vfmt6 = vslidevn | vslidehn | vslidehn2 | vslidevp | vslidehp | vslidehp2 | vsel | vevn | vodd | vevnodd | vzip

  // FormatVVV
  val aconv   = inst === BitPat("b??????_1?????_??????_10_??????_0_00_101")
  val vcget   = inst === BitPat("b010100_000000_000000_??_??????_?_111_11")

  val vdwconv = inst === BitPat("b??????_0?????_??????_10_??????_?_10_101")
  val adwconv = inst === BitPat("b??????_1?????_??????_10_??????_?_10_101")
  val vadwconv = vdwconv || adwconv

  // Undef
  val vopbits = Cat(
    // Duplicate
    vdup,
    // Load/Store
    vld, vst, vstq,
    // Misc
    vcget,
    // Format0
    vadd, vsub, vrsub, veq, vne, vlt, vle, vgt, vge, vabsd, vmax, vmin, vadd3,
    // Format1
    vand, vor, vxor, vnot, vrev, vror, vclb, vclz, vcpop, vmv, vmv2, vmvp, acset, actr, adwinit,
    // Format2
    vsll, vsra, vsrl, vsha, vshl, vsrans, vsraqs,
    // Format3
    vmul, vmul2, vmuls, vmuls2, vmulh, vmulh2, vmulhu, vmulhu2, vdmulh, vdmulh2, vmulw, vmacc, vmadd,
    // Format4
    vadds, vsubs, vaddw, vsubw, vacc, vpadd, vpsub, vhadd, vhsub,
    // Format6
    vslidevn, vslidehn, vslidehn2, vslidevp, vslidehp, vslidehp2, vsel, vevn, vodd, vevnodd, vzip,
    // FormatVVV
    aconv, vdwconv, adwconv)

  val undef = !WiredOR(vopbits)
  assert(PopCount(Cat(vopbits, undef)) === 1.U)

  // Encode the opcode.
  val op =
      // Duplicate
      MuxOR(vdup, enc.vdup.U) |
      // Load/Store
      MuxOR(vld,  enc.vld.U) |
      MuxOR(vst,  enc.vst.U) |
      MuxOR(vstq, enc.vstq.U) |
      // Misc
      MuxOR(vcget, enc.vcget.U) |
      // Format0
      MuxOR(vadd,  enc.vadd.U) |
      MuxOR(vsub,  enc.vsub.U) |
      MuxOR(vrsub, enc.vrsub.U) |
      MuxOR(veq,   enc.veq.U) |
      MuxOR(vne,   enc.vne.U) |
      MuxOR(vlt,   enc.vlt.U) |
      MuxOR(vle,   enc.vle.U) |
      MuxOR(vgt,   enc.vgt.U) |
      MuxOR(vge,   enc.vge.U) |
      MuxOR(vabsd, enc.vabsd.U) |
      MuxOR(vmax,  enc.vmax.U) |
      MuxOR(vmin,  enc.vmin.U) |
      MuxOR(vadd3, enc.vadd3.U) |
      // Format1
      MuxOR(vand,  enc.vand.U) |
      MuxOR(vor,   enc.vor.U) |
      MuxOR(vxor,  enc.vxor.U) |
      MuxOR(vnot,  enc.vnot.U) |
      MuxOR(vrev,  enc.vrev.U) |
      MuxOR(vror,  enc.vror.U) |
      MuxOR(vclb,  enc.vclb.U) |
      MuxOR(vclz,  enc.vclz.U) |
      MuxOR(vcpop, enc.vcpop.U) |
      MuxOR(vmv,   enc.vmv.U) |
      MuxOR(vmv2,  enc.vmv2.U) |
      MuxOR(vmvp,  enc.vmvp.U) |
      MuxOR(acset, enc.acset.U) |
      MuxOR(actr,  enc.actr.U) |
      MuxOR(adwinit, enc.adwinit.U) |
      // Format2
      MuxOR(vsll,   enc.vshl.U) |
      MuxOR(vsra,   enc.vshr.U) |
      MuxOR(vsrl,   enc.vshr.U) |
      MuxOR(vsha,   enc.vshf.U) |
      MuxOR(vshl,   enc.vshf.U) |
      MuxOR(vsrans, enc.vsrans.U) |
      MuxOR(vsraqs, enc.vsraqs.U) |
      // Format3
      MuxOR(vmul,    enc.vmul.U) |
      MuxOR(vmul2,   enc.vmul2.U) |
      MuxOR(vmuls,   enc.vmuls.U) |
      MuxOR(vmuls2,  enc.vmuls2.U) |
      MuxOR(vmulh,   enc.vmulh.U) |
      MuxOR(vmulh2,  enc.vmulh2.U) |
      MuxOR(vmulhu,  enc.vmulh.U) |
      MuxOR(vmulhu2, enc.vmulh2.U) |
      MuxOR(vdmulh,  enc.vdmulh.U) |
      MuxOR(vdmulh2, enc.vdmulh2.U) |
      MuxOR(vmulw,   enc.vmulw.U) |
      MuxOR(vmacc,   enc.vmadd.U) |
      MuxOR(vmadd,   enc.vmadd.U) |
      // Format4
      MuxOR(vadds,  enc.vadds.U) |
      MuxOR(vsubs,  enc.vsubs.U) |
      MuxOR(vaddw,  enc.vaddw.U) |
      MuxOR(vsubw,  enc.vsubw.U) |
      MuxOR(vacc,   enc.vacc.U) |
      MuxOR(vpadd,  enc.vpadd.U) |
      MuxOR(vpsub,  enc.vpsub.U) |
      MuxOR(vhadd,  enc.vhadd.U) |
      MuxOR(vhsub,  enc.vhsub.U) |
      // Format6
      MuxOR(vslidevn,  enc.vslidevn.U) |
      MuxOR(vslidehn,  enc.vslidehn.U) |
      MuxOR(vslidehn2, enc.vslidehn2.U) |
      MuxOR(vslidevp,  enc.vslidevp.U) |
      MuxOR(vslidehp,  enc.vslidehp.U) |
      MuxOR(vslidehp2, enc.vslidehp2.U) |
      MuxOR(vsel,     enc.vsel.U) |
      MuxOR(vevn,     enc.vevn.U) |
      MuxOR(vodd,     enc.vodd.U) |
      MuxOR(vevnodd,  enc.vevnodd.U) |
      MuxOR(vzip,     enc.vzip.U) |
      // FormatVVV
      MuxOR(aconv,    enc.aconv.U) |
      MuxOR(vdwconv,  enc.vdwconv.U) |
      MuxOR(adwconv,  enc.adwconv.U)

  // Scalar.
  def ScalarData(sz: UInt, data: UInt): UInt = {
    assert(sz.getWidth == 2)
    assert(data.getWidth == 32)
    MuxOR(sz === 0.U, Cat(data(7,0), data(7,0), data(7,0), data(7,0))) |
          MuxOR(sz === 1.U, Cat(data(15,0), data(15,0))) |
          MuxOR(sz === 2.U, data(31,0))
  }

  // Depthwise read.
  val (vsdw, vtdw, vudw, vxdw, vydw, vzdw, ractivedw) = DepthwiseRead()

  val ractivedi = ToM(UIntToOH(vsbits(5,2), 16))
  val wactivedw = ToM(UIntToOH(vdbits(5,2), 16))

  // Slide composite read.
  val (vssl, vtsl, vusl, vxsl, vysl, vzsl, ractivesl) = SlideRead()

  // Convolution read/write.
  val ractiveconv1 = Wire(UInt(64.W))
  val ractiveconv2 = Wire(UInt(64.W))
  val ractiveaset  = Wire(UInt(64.W))
  val wactiveconv  = Wire(UInt(64.W))

  // Narrow reads (vs) are aligned to 16 register base (v0, v16, v32, v48).
  // Wide reads (vu) are aligned to SIMD width(4,8,16), assumes scalar control
  // field does not access beyond this bounds.
  if (p.vectorBits == 128) {
    ractiveconv1 := 0x000f.U << Cat(vsbits(5,4), 0.U(4.W))
    ractiveconv2 := 0x000f.U << Cat(vubits(5,2), 0.U(2.W))
    ractiveaset  := 0x000f.U << Cat(vsbits(5,2), 0.U(2.W))
    wactiveconv  := 0x000f.U << Cat(vdbits(5,4), 0.U(4.W))
  } else if (p.vectorBits == 256) {
    ractiveconv1 := 0x00ff.U << Cat(vsbits(5,4), 0.U(4.W))
    ractiveconv2 := 0x00ff.U << Cat(vubits(5,3), 0.U(3.W))
    ractiveaset  := 0x00ff.U << Cat(vsbits(5,3), 0.U(3.W))
    wactiveconv  := 0x00ff.U << Cat(vdbits(5,4), 0.U(4.W))
  } else  if (p.vectorBits == 512) {
    ractiveconv1 := 0xffff.U << Cat(vsbits(5,4), 0.U(4.W))
    ractiveconv2 := 0xffff.U << Cat(vubits(5,4), 0.U(4.W))
    ractiveaset  := 0xffff.U << Cat(vsbits(5,4), 0.U(4.W))
    wactiveconv  := 0xffff.U << Cat(vdbits(5,4), 0.U(4.W))
  } else {
    assert(false);
  }

  // Outputs.
  io.undef := undef

  io.out.op := op
  io.out.f2 := func2(2,0)
  io.out.sz := Cat(sz === 2.U, sz === 1.U, sz === 0.U)
  io.out.m  := m && !vdmulh2 && !vmul2 && !vmulh2 && !vmulhu2 && !vmuls2 && !vmv2 && !vslidehn2 && !vslidehp2
  io.out.cmdsync := adwinit || vadwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2 || vsraqs

  io.out.vd.valid := vdwconv || vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6 || vld || vdup || vcget
  io.out.ve.valid := vdwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vacc || vmv2 || vmvp || vmulw || vaddw || vsubw || vevnodd || vslideh2 || vzip
  io.out.vf.valid := vdwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2
  io.out.vg.valid := vdwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2
  io.out.vs.valid := vadwconv || adwinit || vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6 || vst || vstq || aconv
  io.out.vt.valid := vadwconv || adwinit || !x && (vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6)
  io.out.vu.valid := vadwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vacc || vadd3 || vmacc || vmadd || aconv || vsrans || vsraqs || vsel || vslideh2 || m && vevn3
  io.out.vx.valid := vadwconv || adwinit || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2 || vsraqs
  io.out.vy.valid := vadwconv || adwinit || vslideh2 || !x && (vsraqs)
  io.out.vz.valid := vadwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2 || vsraqs
  io.out.sv.valid := x && (vdup || vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6)

  io.out.vd.addr := vdbits
  io.out.ve.addr := Mux(vodd, vdbits,
                    Mux(vadwconv || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2 || vslideh2 || vzip, vdbits + 1.U,
                    Mux(m, vdbits + 4.U, vdbits + 1.U)))
  io.out.vf.addr := vdbits + 2.U
  io.out.vg.addr := vdbits + 3.U
  io.out.vs.addr := Mux(vadwconv, vsdw,
                    Mux(vslideh2, vssl,
                    Mux(vmadd || vst || vstq, vdbits,
                      vsbits)))
  io.out.vt.addr := Mux(vadwconv, vtdw,
                    Mux(adwinit, vsbits + 1.U,
                    Mux(vslideh2, vtsl,
                    Mux(m && vevn3, vsbits + 1.U,
                      vtbits))))
  io.out.vu.addr := Mux(vadwconv, vudw,
                    Mux(vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2, vsbits + 1.U,
                    Mux(vslideh2, vusl,
                    Mux(vacc || vsrans, Mux(m, vsbits + 4.U, vsbits + 1.U),
                    Mux(vsraqs, Mux(m, vsbits + 4.U, vsbits + 1.U),
                    Mux(vmacc || vadd3 || vsel, vdbits,
                    Mux(vmadd, vsbits,
                    Mux(vevn3, vtbits,
                      vubits))))))))
  io.out.vx.addr := Mux(vadwconv, vxdw,
                    Mux(adwinit || vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2, vsbits + 2.U,
                    Mux(vsraqs, Mux(m, vsbits + 8.U, vsbits + 2.U),
                      vxsl)))
  io.out.vy.addr := Mux(vadwconv, vydw,
                    Mux(adwinit, vsbits + 3.U,
                    Mux(vsraqs, vtbits,
                      vysl)))
  io.out.vz.addr := Mux(vadwconv, vzdw,
                    Mux(vdmulh2 || vmul2 || vmulh2 || vmulhu2 || vmuls2 || vmv2, vsbits + 3.U,
                    Mux(vsraqs, Mux(m, vsbits + 12.U, vsbits + 3.U),
                      vzsl)))

  io.out.vs.tag := 0.U
  io.out.vt.tag := 0.U
  io.out.vu.tag := 0.U
  io.out.vx.tag := 0.U
  io.out.vy.tag := 0.U
  io.out.vz.tag := 0.U

  io.out.sv.addr := addr
  io.out.sv.data := Mux(vldstdec, data,
                    Mux(vaddw || vmulw || vsubw, ScalarData(sz - 1.U, data),
                      ScalarData(sz, data)))

  assert(PopCount(io.out.sz) <= 1.U)
  assert(!(io.out.vx.valid && !io.out.cmdsync))
  assert(!(io.out.vy.valid && !io.out.cmdsync))
  assert(!(io.out.vz.valid && !io.out.cmdsync))

  io.cmdq.alu  := vdup || vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6 || vadwconv || adwinit
  io.cmdq.conv := aconv || vcget || acset || actr
  io.cmdq.ldst := vldst
  io.cmdq.ld := false.B
  io.cmdq.st := false.B

  val cmdqchk = Cat(io.undef, io.cmdq.alu, io.cmdq.conv, io.cmdq.ldst, io.cmdq.ld, io.cmdq.st)
  assert(PopCount(cmdqchk) === 1.U)

  io.actv.ractive :=
    MuxOR(vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 ||
          vfmt6 && !vslideh2,                                  RActiveVsVt(2)) |
    MuxOR(vsraqs || vsrans,                                      RActiveVs1()) |
    MuxOR(vsraqs,                                                RActiveVs2()) |
    MuxOR(vsraqs,                                                RActiveVs3()) |
    MuxOR(vmacc || vmadd || vst || vstq,                          RActiveVd()) |
    MuxOR(vadwconv,                                                 ractivedw) |
    MuxOR(adwinit,                                                  ractivedi) |
    MuxOR(vslideh2,                                                 ractivesl) |
    MuxOR(aconv || actr,                                         ractiveconv1) |
    MuxOR(aconv,                                                 ractiveconv2) |
    MuxOR(acset,                                                  ractiveaset)

  io.actv.wactive :=
    MuxOR(vfmt0 || vfmt1 || vfmt2 || vfmt3 || vfmt4 || vfmt6 ||
          vdup || vld,                                            WActiveVd()) |
    MuxOR(vmvp || vmulw || vacc || vaddw || vsubw || vevnodd || vzip,
                                                                 WActiveVd1()) |
    MuxOR(vdwconv,                                                  wactivedw) |
    MuxOR(vcget,                                                    wactiveconv)
}

object EmitVDecodeInstruction extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new VDecodeInstruction(p), args)
}
