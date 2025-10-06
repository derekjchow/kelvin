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

object VDot {
  // Conv2D
  def apply(en: Bool, adata: UInt, bdata: UInt,
      abias: UInt, bbias: UInt, asign: Bool, bsign: Bool): UInt = {
    assert(abias.getWidth == 9)
    assert(bbias.getWidth == 9)
    assert(adata.getWidth == 32)
    assert(bdata.getWidth == 32)

    val mul = Wire(Vec(4, SInt(20.W)))

    // input clamps
    val adatac = MuxOR(en, adata)
    val bdatac = MuxOR(en, bdata)
    val abiasc = MuxOR(en, abias)
    val bbiasc = MuxOR(en, bbias)

    for (i <- 0 until 4) {
      val as = adatac(8 * i + 7) & asign
      val bs = bdatac(8 * i + 7) & bsign
      val aval = Cat(as, adatac(8 * i + 7, 8 * i)).asSInt +& abiasc.asSInt
      val bval = Cat(bs, bdatac(8 * i + 7, 8 * i)).asSInt +& bbiasc.asSInt
      val mval = aval * bval
      mul(i) := mval

      assert(aval.getWidth == 10)
      assert(bval.getWidth == 10)
      assert(mval.getWidth == 20)
    }

    val dotp = (mul(0) +& mul(1)) +& (mul(2) +& mul(3))
    val sdotp = Cat(MuxOR(dotp(21), ~0.U(10.W)), dotp)

    assert(dotp.getWidth == 22)
    assert(sdotp.getWidth == 32)

    sdotp
  }

  // Depthwise
  def apply(alu: Int, en: Bool, adata: Vec[UInt], bdata: Vec[UInt],
      scalar: UInt): (UInt, UInt) = {
    assert(adata.length == 3)
    assert(bdata.length == 3)
    assert(scalar.getWidth == 32)
    val sparse = scalar(3,2)
    val abias = scalar(20,12)
    val asign = scalar(21)
    val bbias = scalar(30,22)
    val bsign = scalar(31)

    val sparse0 = sparse === 0.U
    val sparse1 = sparse === 1.U
    val sparse2 = sparse === 2.U

    val w = adata(0).getWidth
    val cnt = w / 32
    val dout0 = Wire(Vec(cnt, UInt(32.W)))
    val dout1 = Wire(Vec(cnt, UInt(32.W)))

    // Input clamps and dense/sparse swizzle.
    val adatac = Wire(Vec(3, Vec(cnt, UInt(32.W))))
    val bdatac = Wire(Vec(3, Vec(cnt, UInt(32.W))))

    val abiasc = MuxOR(en, abias)
    val bbiasc = MuxOR(en, bbias)

    // Sparse 1 [n-1,n,n+1].
    val adata1 = Wire(Vec(cnt + 2, UInt(32.W)))
    if (true) {
      val lsb = (cnt - 1) * 32
      val msb = lsb + 32 - 1
      adata1(0) := MuxOR(en && sparse1, adata(0)(msb,lsb))
    }
    for (i <- 0 until cnt) {
      val lsb = i * 32
      val msb = lsb + 32 - 1
      adata1(i + 1) := MuxOR(en && sparse1, adata(1)(msb,lsb))
    }
    if (true) {
      val lsb = 0
      val msb = 31
      adata1(cnt + 1) := MuxOR(en && sparse1, adata(2)(msb,lsb))
    }

    // Sparse 2 [n,n+1,n+2].
    val adata2 = Wire(Vec(cnt + 2, UInt(32.W)))
    for (i <- 0 until cnt) {
      val lsb = i * 32
      val msb = lsb + 32 - 1
      adata2(i) := MuxOR(en && sparse2, adata(0)(msb,lsb))
    }
    for (i <- 0 until 2) {
      val lsb = i * 32
      val msb = lsb + 32 - 1
      adata2(cnt + i) := MuxOR(en && sparse2, adata(1)(msb,lsb))
    }

    // vdot(a,b) for sparse[0,1,2].
    for (j <- 0 until 3) {
      for (i <- 0 until cnt) {
        val lsb = i * 32
        val msb = lsb + 32 - 1
        val k = i + j

        val adata0 = MuxOR(en && sparse0, adata(j)(msb,lsb))

        adatac(j)(i) := adata0 | adata1(k) | adata2(k)
        bdatac(j)(i) := MuxOR(en, bdata(j)(msb,lsb))
      }
    }

    for (i <- 0 until cnt) {
      val ad = VecInit(adatac(0)(i), adatac(1)(i), adatac(2)(i))
      val bd = VecInit(bdatac(0)(i), bdatac(1)(i), bdatac(2)(i))
      val (o0, o1) = dwlane(alu, en, ad, bd, abiasc, bbiasc, asign, bsign)
      dout0(i) := o0
      dout1(i) := o1
    }

    val out0 = dout0.asUInt
    val out1 = dout1.asUInt
    assert(out0.getWidth == w)
    assert(out1.getWidth == w)
    (out0, out1)
  }

  private def dwlane(alu: Int, en: Bool, adata: Vec[UInt], bdata: Vec[UInt],
      abias: UInt, bbias: UInt, asign: Bool, bsign: Bool):
        (UInt, UInt) = {
    assert(adata.length == 3)
    assert(bdata.length == 3)
    assert(abias.getWidth == 9)
    assert(bbias.getWidth == 9)
    for (i <- 0 until 3) {
      assert(adata(i).getWidth == 32)
      assert(bdata(i).getWidth == 32)
    }

    val out = Wire(Vec(2, UInt(32.W)))

    for (j <- 0 until 2) {
      val m = 2 * j + alu  // alu[0]: {0, 2}; alu[1]: {1, 3}
      val mul = Wire(Vec(3, SInt(20.W)))

      for (i <- 0 until 3) {
        val as = adata(i)(8 * m + 7) & asign
        val bs = bdata(i)(8 * m + 7) & bsign
        val aval = Cat(as, adata(i)(8 * m + 7, 8 * m)).asSInt +& abias.asSInt
        val bval = Cat(bs, bdata(i)(8 * m + 7, 8 * m)).asSInt +& bbias.asSInt
        val mval = aval * bval
        mul(i) := mval

        assert(aval.getWidth == 10)
        assert(bval.getWidth == 10)
        assert(mval.getWidth == 20)
      }

      val dotp = (mul(0) +& mul(1)) +& mul(2)
      val sdotp = Cat(MuxOR(dotp(21), ~0.U(10.W)), dotp)
      assert(dotp.getWidth == 22)
      assert(sdotp.getWidth == 32)

      out(j) := sdotp
    }

    (out(0), out(1))
  }
}
