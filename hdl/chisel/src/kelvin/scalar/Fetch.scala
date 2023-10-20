// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package kelvin

import chisel3._
import chisel3.util._
import common._

object Fetch {
  def apply(p: Parameters): Fetch = {
    return Module(new Fetch(p))
  }
}

class IBusIO(p: Parameters) extends Bundle {
  // Control Phase.
  val valid = Output(Bool())
  val ready = Input(Bool())
  val addr = Output(UInt(p.fetchAddrBits.W))
  // Read Phase.
  val rdata = Input(UInt(p.fetchDataBits.W))
}

class FetchInstruction(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())
  val addr = Output(UInt(p.programCounterBits.W))
  val inst = Output(UInt(p.instructionBits.W))
  val brchFwd = Output(Bool())
}

class FetchIO(p: Parameters) extends Bundle {
  val lanes = Vec(p.instructionLanes, new FetchInstruction(p))
}

class Fetch(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val csr = new CsrInIO(p)
    val ibus = new IBusIO(p)
    val inst = new FetchIO(p)
    val branch = Flipped(Vec(4, new BranchTakenIO(p)))
    val linkPort = Flipped(new RegfileLinkPortIO)
    val iflush = Flipped(new IFlushIO(p))
  })

  // This is the only compiled and tested configuration (at this time).
  assert(p.fetchAddrBits == 32)
  assert(p.fetchDataBits == 256)

  val aslice = Slice(UInt(p.fetchAddrBits.W), true)
  val readAddr = Reg(UInt(p.fetchAddrBits.W))
  val readDataEn = RegInit(false.B)

  val readAddrEn = io.ibus.valid && io.ibus.ready
  val readData = io.ibus.rdata
  readDataEn := readAddrEn && !io.iflush.valid

  io.iflush.ready := !aslice.io.out.valid

  // L0 cache
  // ____________________________________
  // |        Tag           |Index|xxxxx|
  // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  val lanes    = p.fetchDataBits / p.instructionBits  // input lanes
  val indices  = p.fetchCacheBytes * 8 / p.fetchDataBits
  val indexLsb = log2Ceil(p.fetchDataBits / 8)
  val indexMsb = log2Ceil(indices) + indexLsb - 1
  val tagLsb   = indexMsb + 1
  val tagMsb   = p.fetchAddrBits - 1
  val indexCountBits = log2Ceil(indices - 1)

  if (p.fetchCacheBytes == 1024) {
    assert(indexLsb == 5)
    assert(indexMsb == 9)
    assert(tagLsb == 10)
    assert(tagMsb == 31)
    assert(indices == 32)
    assert(indexCountBits == 5)
    assert(lanes == 8)
  }

  val l0valid = RegInit(0.U(indices.W))
  val l0req   = RegInit(0.U(indices.W))
  val l0tag   = Reg(Vec(indices, UInt((tagMsb - tagLsb + 1).W)))
  val l0data  = Reg(Vec(indices, UInt(p.fetchDataBits.W)))

  // Instruction outputs.
  val instValid = RegInit(VecInit(Seq.fill(4)(false.B)))
  val instAddr  = Reg(Vec(4, UInt(p.instructionBits.W)))
  val instBits  = Reg(Vec(4, UInt(p.instructionBits.W)))

  val instAligned0 = Cat(instAddr(0)(31, indexLsb), 0.U(indexLsb.W))
  val instAligned1 = instAligned0 + Cat(1.U, 0.U(indexLsb.W))

  val instIndex0 = instAligned0(indexMsb, indexLsb)
  val instIndex1 = instAligned1(indexMsb, indexLsb)

  val instTag0 = instAligned0(tagMsb, tagLsb)
  val instTag1 = instAligned1(tagMsb, tagLsb)

  val l0valid0 = l0valid(instIndex0)
  val l0valid1 = l0valid(instIndex1)

  val l0tag0 = VecAt(l0tag, instIndex0)
  val l0tag1 = VecAt(l0tag, instIndex1)

  val match0 = l0valid0 && instTag0 === l0tag0
  val match1 = l0valid1 && instTag1 === l0tag1

  // Read interface.
  // Do not request entries that are already inflight.
  // Perform a branch tag lookup to see if target is in cache.
  def Predecode(addr: UInt, op: UInt): (Bool, UInt) = {
    val jal = DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_1101111")
    val immed = Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
    val target = addr + immed
    (jal, target)
  }

  val (preBranchTaken0, preBranchTarget0) =
      Predecode(instAddr(0), instBits(0))
  val (preBranchTaken1, preBranchTarget1) =
      Predecode(instAddr(1), instBits(1))
  val (preBranchTaken2, preBranchTarget2) =
      Predecode(instAddr(2), instBits(2))
  val (preBranchTaken3, preBranchTarget3) =
      Predecode(instAddr(3), instBits(3))

  val preBranchTaken = io.inst.lanes(0).valid && preBranchTaken0 ||
                       io.inst.lanes(1).valid && preBranchTaken1 ||
                       io.inst.lanes(2).valid && preBranchTaken2 ||
                       io.inst.lanes(3).valid && preBranchTaken3

  val preBranchTarget = Mux(preBranchTaken0, preBranchTarget0,
                        Mux(preBranchTaken1, preBranchTarget1,
                        Mux(preBranchTaken2, preBranchTarget2,
                            preBranchTarget3)))

  val preBranchTag = preBranchTarget(tagMsb, tagLsb)
  val preBranchIndex = preBranchTarget(indexMsb, indexLsb)

  val branchTag0 = io.branch(0).value(tagMsb, tagLsb)
  val branchTag1 = io.branch(1).value(tagMsb, tagLsb)
  val branchTag2 = io.branch(2).value(tagMsb, tagLsb)
  val branchTag3 = io.branch(3).value(tagMsb, tagLsb)
  val branchIndex0 = io.branch(0).value(indexMsb, indexLsb)
  val branchIndex1 = io.branch(1).value(indexMsb, indexLsb)
  val branchIndex2 = io.branch(2).value(indexMsb, indexLsb)
  val branchIndex3 = io.branch(3).value(indexMsb, indexLsb)

  val l0validB0 = l0valid(branchIndex0)
  val l0validB1 = l0valid(branchIndex1)
  val l0validB2 = l0valid(branchIndex2)
  val l0validB3 = l0valid(branchIndex3)
  val l0validP  = l0valid(preBranchIndex)

  val l0tagB0 = VecAt(l0tag, branchIndex0)
  val l0tagB1 = VecAt(l0tag, branchIndex1)
  val l0tagB2 = VecAt(l0tag, branchIndex2)
  val l0tagB3 = VecAt(l0tag, branchIndex3)
  val l0tagP  = VecAt(l0tag, preBranchIndex)

  val reqB0 = io.branch(0).valid && !l0req(branchIndex0) &&
      (branchTag0 =/= l0tagB0 || !l0validB0)
  val reqB1 = io.branch(1).valid && !l0req(branchIndex1) &&
      (branchTag1 =/= l0tagB1 || !l0validB1) &&
      !io.branch(0).valid
  val reqB2 = io.branch(2).valid && !l0req(branchIndex2) &&
      (branchTag2 =/= l0tagB2 || !l0validB2) &&
      !io.branch(0).valid && !io.branch(1).valid
  val reqB3 = io.branch(3).valid && !l0req(branchIndex3) &&
      (branchTag3 =/= l0tagB3 || !l0validB3) &&
      !io.branch(0).valid && !io.branch(1).valid && !io.branch(2).valid
  val reqP = preBranchTaken && !l0req(preBranchIndex) && (preBranchTag =/= l0tagP || !l0validP)
  val req0 = !match0 && !l0req(instIndex0)
  val req1 = !match1 && !l0req(instIndex1)

  aslice.io.in.valid := (reqB0 || reqB1 || reqB2 || reqB3 || reqP || req0 || req1) && !io.iflush.valid
  aslice.io.in.bits  := Mux(reqB0, Cat(io.branch(0).value(31,indexLsb), 0.U(indexLsb.W)),
                        Mux(reqB1, Cat(io.branch(1).value(31,indexLsb), 0.U(indexLsb.W)),
                        Mux(reqB2, Cat(io.branch(2).value(31,indexLsb), 0.U(indexLsb.W)),
                        Mux(reqB3, Cat(io.branch(3).value(31,indexLsb), 0.U(indexLsb.W)),
                        Mux(reqP,  Cat(preBranchTarget(31,indexLsb), 0.U(indexLsb.W)),
                        Mux(req0, instAligned0, instAligned1))))))

  when (readAddrEn) {
    readAddr := io.ibus.addr
  }

  io.ibus.valid := aslice.io.out.valid
  aslice.io.out.ready := io.ibus.ready || io.iflush.valid
  io.ibus.addr := aslice.io.out.bits

  // initialize tags to 1s as 0xfffxxxxx are invalid instruction addresses
  val l0validClr = WireInit(0.U(indices.W))
  val l0validSet = WireInit(0.U(indices.W))
  val l0reqClr = WireInit(0.U(indices.W))
  val l0reqSet = WireInit(0.U(indices.W))

  val readIdx = readAddr(indexMsb, indexLsb)

  for (i <- 0 until indices) {
    when (readDataEn && readIdx === i.U) {
      l0tag(i.U)  := readAddr(tagMsb, tagLsb)
      l0data(i.U) := readData
    }
  }

  when (readDataEn) {
    val bits = OneHot(readIdx, indices)
    l0validSet := bits
    l0reqClr   := bits
  }

  when (io.iflush.valid) {
    val clr = ~(0.U(l0validClr.getWidth.W))
    l0validClr := clr
    l0reqClr   := clr
  }

  when (aslice.io.in.valid && aslice.io.in.ready) {
    l0reqSet := OneHot(aslice.io.in.bits(indexMsb, indexLsb), indices)
  }

  when (l0validClr =/= 0.U || l0validSet =/= 0.U) {
    l0valid := (l0valid | l0validSet) & ~l0validClr
  }

  when (l0reqClr =/= 0.U || l0reqSet =/= 0.U) {
    l0req := (l0req | l0reqSet) & ~l0reqClr
  }

  // Instruction Outputs
  // Do not use the next instruction address directly in the lookup, as that
  // creates excessive timing pressure. We know that the match is either on
  // the old line or the next line, so can late mux on lookups of prior.
  // Widen the arithmetic paths and select from results.
  val fetchEn = Wire(Vec(4, Bool()))

  for (i <- 0 until 4) {
    fetchEn(i) := io.inst.lanes(i).valid && io.inst.lanes(i).ready
  }

  val fsel = Cat(fetchEn(3),
                 fetchEn(2) && !fetchEn(3),
                 fetchEn(1) && !fetchEn(2) && !fetchEn(3),
                 fetchEn(0) && !fetchEn(1) && !fetchEn(2) && !fetchEn(3),
                 !fetchEn(0) && !fetchEn(1) && !fetchEn(2) && !fetchEn(3))

  val nxtInstAddr0 = instAddr(0)          // 0
  val nxtInstAddr1 = instAddr(1)          // 4
  val nxtInstAddr2 = instAddr(2)          // 8
  val nxtInstAddr3 = instAddr(3)          // 12
  val nxtInstAddr4 = instAddr(0) + 16.U   // 16
  val nxtInstAddr5 = instAddr(1) + 16.U   // 20
  val nxtInstAddr6 = instAddr(2) + 16.U   // 24
  val nxtInstAddr7 = instAddr(3) + 16.U   // 28

  val nxtInstAddr = Wire(Vec(4, UInt(p.instructionBits.W)))

  nxtInstAddr(0) := Mux(fsel(4), nxtInstAddr4, 0.U) |
                    Mux(fsel(3), nxtInstAddr3, 0.U) |
                    Mux(fsel(2), nxtInstAddr2, 0.U) |
                    Mux(fsel(1), nxtInstAddr1, 0.U) |
                    Mux(fsel(0), nxtInstAddr0, 0.U)

  nxtInstAddr(1) := Mux(fsel(4), nxtInstAddr5, 0.U) |
                    Mux(fsel(3), nxtInstAddr4, 0.U) |
                    Mux(fsel(2), nxtInstAddr3, 0.U) |
                    Mux(fsel(1), nxtInstAddr2, 0.U) |
                    Mux(fsel(0), nxtInstAddr1, 0.U)

  nxtInstAddr(2) := Mux(fsel(4), nxtInstAddr6, 0.U) |
                    Mux(fsel(3), nxtInstAddr5, 0.U) |
                    Mux(fsel(2), nxtInstAddr4, 0.U) |
                    Mux(fsel(1), nxtInstAddr3, 0.U) |
                    Mux(fsel(0), nxtInstAddr2, 0.U)

  nxtInstAddr(3) := Mux(fsel(4), nxtInstAddr7, 0.U) |
                    Mux(fsel(3), nxtInstAddr6, 0.U) |
                    Mux(fsel(2), nxtInstAddr5, 0.U) |
                    Mux(fsel(1), nxtInstAddr4, 0.U) |
                    Mux(fsel(0), nxtInstAddr3, 0.U)

  val nxtInstIndex0 = nxtInstAddr(0)(indexMsb, indexLsb)
  val nxtInstIndex1 = nxtInstAddr(3)(indexMsb, indexLsb)

  val readFwd0 =
      readDataEn && readAddr(31,indexLsb) === instAligned0(31,indexLsb)
  val readFwd1 =
      readDataEn && readAddr(31,indexLsb) === instAligned1(31,indexLsb)

  val nxtMatch0Fwd = match0 || readFwd0
  val nxtMatch1Fwd = match1 || readFwd1

  val nxtMatch0 =
      Mux(instIndex0(0) === nxtInstIndex0(0), nxtMatch0Fwd, nxtMatch1Fwd)
  val nxtMatch1 =
      Mux(instIndex0(0) === nxtInstIndex1(0), nxtMatch0Fwd, nxtMatch1Fwd)

  val nxtInstValid = Wire(Vec(4, Bool()))

  val nxtInstBits0 = Mux(readFwd0, readData, VecAt(l0data, instIndex0))
  val nxtInstBits1 = Mux(readFwd1, readData, VecAt(l0data, instIndex1))
  val nxtInstBits = Wire(Vec(16, UInt(p.instructionBits.W)))

  for (i <- 0 until 8) {
    val offset = 32 * i
    nxtInstBits(i + 0) := nxtInstBits0(31 + offset, offset)
    nxtInstBits(i + 8) := nxtInstBits1(31 + offset, offset)
  }

  def BranchMatchDe(valid: Bool, value: UInt):
      (Bool, UInt, Vec[UInt], Vec[UInt]) = {

    val addr = VecInit(value,
                       value + 4.U,
                       value + 8.U,
                       value + 12.U)

    val match0 = l0valid(addr(0)(indexMsb,indexLsb)) &&
        addr(0)(tagMsb,tagLsb) === VecAt(l0tag, addr(0)(indexMsb,indexLsb))
    val match1 = l0valid(addr(3)(indexMsb,indexLsb)) &&
        addr(3)(tagMsb,tagLsb) === VecAt(l0tag, addr(3)(indexMsb,indexLsb))

    val vvalid = VecInit(Mux(addr(0)(4,2) <= 7.U, match0, match1),
                         Mux(addr(0)(4,2) <= 6.U, match0, match1),
                         Mux(addr(0)(4,2) <= 5.U, match0, match1),
                         Mux(addr(0)(4,2) <= 4.U, match0, match1))

    val muxbits0 = VecAt(l0data, addr(0)(indexMsb,indexLsb))
    val muxbits1 = VecAt(l0data, addr(3)(indexMsb,indexLsb))
    val muxbits = Wire(Vec(16, UInt(p.instructionBits.W)))

    for (i <- 0 until 8) {
      val offset = 32 * i
      muxbits(i + 0) := muxbits0(31 + offset, offset)
      muxbits(i + 8) := muxbits1(31 + offset, offset)
    }

    val bits = Wire(Vec(4, UInt(p.instructionBits.W)))
    for (i <- 0 until 4) {
      val idx = Cat(addr(0)(5) =/= addr(i)(5), addr(i)(4,2))
      bits(i) := VecAt(muxbits, idx)
    }

    (valid, vvalid.asUInt, addr, bits)
  }

  def BranchMatchEx(branch: Vec[BranchTakenIO]):
      (Bool, UInt, Vec[UInt], Vec[UInt]) = {
    val valid = branch(0).valid || branch(1).valid ||
                branch(2).valid || branch(3).valid

    val addr = VecInit(Mux(branch(0).valid, branch(0).value,
                       Mux(branch(1).valid, branch(1).value,
                       Mux(branch(2).valid, branch(2).value,
                                            branch(3).value))),
                       Mux(branch(0).valid, branch(0).value + 4.U,
                       Mux(branch(1).valid, branch(1).value + 4.U,
                       Mux(branch(2).valid, branch(2).value + 4.U,
                                            branch(3).value + 4.U))),
                       Mux(branch(0).valid, branch(0).value + 8.U,
                       Mux(branch(1).valid, branch(1).value + 8.U,
                       Mux(branch(2).valid, branch(2).value + 8.U,
                                            branch(3).value + 8.U))),
                       Mux(branch(0).valid, branch(0).value + 12.U,
                       Mux(branch(1).valid, branch(1).value + 12.U,
                       Mux(branch(2).valid, branch(2).value + 12.U,
                                            branch(3).value + 12.U))))

    val match0 = l0valid(addr(0)(indexMsb,indexLsb)) &&
        addr(0)(tagMsb,tagLsb) === VecAt(l0tag, addr(0)(indexMsb,indexLsb))
    val match1 = l0valid(addr(3)(indexMsb,indexLsb)) &&
        addr(3)(tagMsb,tagLsb) === VecAt(l0tag, addr(3)(indexMsb,indexLsb))

    val vvalid = VecInit(Mux(addr(0)(4,2) <= 7.U, match0, match1),
                         Mux(addr(0)(4,2) <= 6.U, match0, match1),
                         Mux(addr(0)(4,2) <= 5.U, match0, match1),
                         Mux(addr(0)(4,2) <= 4.U, match0, match1))

    val muxbits0 = VecAt(l0data, addr(0)(indexMsb,indexLsb))
    val muxbits1 = VecAt(l0data, addr(3)(indexMsb,indexLsb))
    val muxbits = Wire(Vec(16, UInt(p.instructionBits.W)))

    for (i <- 0 until 8) {
      val offset = 32 * i
      muxbits(i + 0) := muxbits0(31 + offset, offset)
      muxbits(i + 8) := muxbits1(31 + offset, offset)
    }

    val bits = Wire(Vec(4, UInt(p.instructionBits.W)))
    for (i <- 0 until 4) {
      val idx = Cat(addr(0)(5) =/= addr(i)(5), addr(i)(4,2))
      bits(i) := VecAt(muxbits, idx)
    }

    (valid, vvalid.asUInt, addr, bits)
  }

  def PredecodeDe(addr: UInt, op: UInt): (Bool, UInt) = {
    val jal = DecodeBits(op, "xxxxxxxxxxxxxxxxxxxx_xxxxx_1101111")
    val ret = DecodeBits(op, "000000000000_00001_000_00000_1100111") &&
                io.linkPort.valid
    val bxx = DecodeBits(op, "xxxxxxx_xxxxx_xxxxx_xxx_xxxxx_1100011") &&
                op(31) && op(14,13) =/= 1.U
    val immjal = Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
    val immbxx = Cat(Fill(20, op(31)), op(7), op(30,25), op(11,8), 0.U(1.W))
    val immed = Mux(op(2), immjal, immbxx)
    val target = Mux(ret, io.linkPort.value, addr + immed)
    (jal || ret || bxx, target)
  }

  val (brchTakenDe0, brchTargetDe0) = PredecodeDe(instAddr(0), instBits(0))
  val (brchTakenDe1, brchTargetDe1) = PredecodeDe(instAddr(1), instBits(1))
  val (brchTakenDe2, brchTargetDe2) = PredecodeDe(instAddr(2), instBits(2))
  val (brchTakenDe3, brchTargetDe3) = PredecodeDe(instAddr(3), instBits(3))

  val brchTakenDeOr =
      io.inst.lanes(0).valid && io.inst.lanes(0).ready && brchTakenDe0 ||
      io.inst.lanes(1).valid && io.inst.lanes(1).ready && brchTakenDe1 ||
      io.inst.lanes(2).valid && io.inst.lanes(2).ready && brchTakenDe2 ||
      io.inst.lanes(3).valid && io.inst.lanes(3).ready && brchTakenDe3

  val brchTargetDe = Mux(brchTakenDe0, brchTargetDe0,
                     Mux(brchTakenDe1, brchTargetDe1,
                     Mux(brchTakenDe2, brchTargetDe2,
                         brchTargetDe3)))

  val (brchTakenDe, brchValidDe, brchAddrDe, brchBitsDe) =
      BranchMatchDe(brchTakenDeOr, brchTargetDe)

  val (brchTakenEx, brchValidEx, brchAddrEx, brchBitsEx) =
      BranchMatchEx(io.branch)

  val brchValidDeMask =
      Cat(!brchTakenDe0 && !brchTakenDe1 && !brchTakenDe2,
          !brchTakenDe0 && !brchTakenDe1,
          !brchTakenDe0,
          true.B)

  val brchFwd = Cat(
      brchTakenDe3 && !brchTakenDe0 && !brchTakenDe1 && !brchTakenDe2,
      brchTakenDe2 && !brchTakenDe0 && !brchTakenDe1,
      brchTakenDe1 && !brchTakenDe0,
      brchTakenDe0)

  for (i <- 0 until 4) {
    // 1, 11, 111, ...
    nxtInstValid(i) := Mux(nxtInstAddr(0)(4,2) <= (7 - i).U, nxtMatch0, nxtMatch1)

    val nxtInstValidUInt = nxtInstValid.asUInt
    instValid(i) := Mux(brchTakenEx, brchValidEx(i,0) === ~0.U((i+1).W),
                    Mux(brchTakenDe, brchValidDe(i,0) === ~0.U((i+1).W),
                    nxtInstValidUInt(i,0) === ~0.U((i+1).W))) && !io.iflush.valid

    instAddr(i) := Mux(brchTakenEx, brchAddrEx(i),
                   Mux(brchTakenDe, brchAddrDe(i), nxtInstAddr(i)))

    // The (2,0) bits are the offset within the base line plus the next line.
    // The (3) bit of the index must factor the base difference of addresses
    // instAddr and nxtInstAddr which are line aligned.
    val idx = Cat(instAddr(0)(5) =/= nxtInstAddr(i)(5), nxtInstAddr(i)(4,2))
    instBits(i) := Mux(brchTakenEx, brchBitsEx(i),
                   Mux(brchTakenDe, brchBitsDe(i),
                   VecAt(nxtInstBits, idx)))
  }

  // This pattern of separate when() blocks requires resets after the data.
  when (reset.asBool) {
    val addr = Cat(io.csr.value(0)(31,2), 0.U(2.W))
    instAddr(0) := addr
    instAddr(1) := addr + 4.U
    instAddr(2) := addr + 8.U
    instAddr(3) := addr + 12.U
  }

  // Outputs
  for (i <- 0 until 4) {
    io.inst.lanes(i).valid := instValid(i) & brchValidDeMask(i)
    io.inst.lanes(i).addr  := instAddr(i)
    io.inst.lanes(i).inst  := instBits(i)
    io.inst.lanes(i).brchFwd := brchFwd(i)
  }

  // Assertions.
  assert(instAddr(0) + 4.U === instAddr(1))
  assert(instAddr(0) + 8.U === instAddr(2))
  assert(instAddr(0) + 12.U === instAddr(3))

  assert(fsel.getWidth == 5)
  assert(PopCount(fsel) <= 1.U)

  val instValidUInt = instValid.asUInt
  assert(!(!instValidUInt(0) && (instValidUInt(3,1) =/= 0.U)))
  assert(!(!instValidUInt(1) && (instValidUInt(3,2) =/= 0.U)))
  assert(!(!instValidUInt(2) && (instValidUInt(3,3) =/= 0.U)))

  val instLanesReady = Cat(io.inst.lanes(3).ready, io.inst.lanes(2).ready,
                           io.inst.lanes(1).ready, io.inst.lanes(0).ready)
  assert(!(!instLanesReady(0) && (instLanesReady(3,1) =/= 0.U)))
  assert(!(!instLanesReady(1) && (instLanesReady(3,2) =/= 0.U)))
  assert(!(!instLanesReady(2) && (instLanesReady(3,3) =/= 0.U)))
}

object EmitFetch extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new Fetch(p), args)
}
