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


// Fetch Unit: 4 way fetcher that directly feeds the 4 decoders.
// The fetcher itself has a partial decoder to identify branches, where backwards
// branches are assumed taken and forward branches assumed not taken.

package coralnpu

import chisel3._
import chisel3.util._
import common._
import _root_.circt.stage.ChiselStage

object Fetch {
  def apply(p: Parameters): Fetch = {
    return Module(new Fetch(p))
  }
}

// Instruction fetch unit, with an integrated L0 cache
class Fetch(p: Parameters) extends FetchUnit(p) {
  // Stub
  io.pc := 0.U
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
  val instValid = RegInit(VecInit(Seq.fill(p.instructionLanes)(false.B)))
  val instAddr  = Reg(Vec(p.instructionLanes, UInt(p.instructionBits.W)))
  val instBits  = Reg(Vec(p.instructionLanes, UInt(p.instructionBits.W)))

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
    val jal = op === BitPat("b????????????????????_?????_1101111")
    val immed = Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
    val target = addr + immed
    (jal, target)
  }

  val preBranch = (0 until p.instructionLanes).map(x => Predecode(instAddr(x), instBits(x)))
  val preBranchTakens = preBranch.map { case (taken, target) => taken }
  val preBranchTargets = preBranch.map { case (taken, target) => target }

  val preBranchTaken = (0 until p.instructionLanes).map(i =>
    io.inst.lanes(i).valid && preBranchTakens(i)).reduce(_ || _)

  val preBranchTarget = MuxCase(
    preBranchTargets(p.instructionLanes - 1),
    (0 until p.instructionLanes - 1).map(i => preBranchTakens(i) -> preBranchTargets(i))
  )

  val preBranchTag = preBranchTarget(tagMsb, tagLsb)
  val preBranchIndex = preBranchTarget(indexMsb, indexLsb)

  val branchTags = io.branch.map(x => x.value(tagMsb, tagLsb))
  val branchIndices = io.branch.map(x => x.value(indexMsb, indexLsb))

  val l0valids = (0 until p.instructionLanes).map(x => l0valid(branchIndices(x)))
  val l0validP  = l0valid(preBranchIndex)

  val l0tags = (0 until p.instructionLanes).map(x => VecAt(l0tag, branchIndices(x)))
  val l0tagP  = VecAt(l0tag, preBranchIndex)

  val reqBValid = (0 until p.instructionLanes).map(x =>
      io.branch(x).valid && !l0req(branchIndices(x)) &&
      (branchTags(x) =/= l0tags(x) || !l0valids(x)))
  val prevValid = io.branch.map(_.valid).scan(false.B)(_||_)
  val reqs = (0 until p.instructionLanes).map(x => reqBValid(x) && !prevValid(x))

  val reqP = preBranchTaken && !l0req(preBranchIndex) && (preBranchTag =/= l0tagP || !l0validP)
  val req0 = !match0 && !l0req(instIndex0)
  val req1 = !match1 && !l0req(instIndex1)

  aslice.io.in.valid := (reqs ++ Seq(reqP, req0, req1)).reduce(_ || _) && !io.iflush.valid
  aslice.io.in.bits := MuxCase(instAligned1,
    (0 until p.instructionLanes).map(x => reqs(x) -> Cat(io.branch(x).value(31,indexLsb), 0.U(indexLsb.W))) ++
    Array(
      reqP -> Cat(preBranchTarget(31,indexLsb), 0.U(indexLsb.W)),
      req0 -> instAligned0,
    )
  )

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
    val bits = UIntToOH(readIdx, indices)
    l0validSet := bits
    l0reqClr   := bits
  }

  when (io.iflush.valid) {
    val clr = ~(0.U(l0validClr.getWidth.W))
    l0validClr := clr
    l0reqClr   := clr
  }

  when (aslice.io.in.valid && aslice.io.in.ready) {
    l0reqSet := UIntToOH(aslice.io.in.bits(indexMsb, indexLsb), indices)
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
  val fetchEn = Wire(Vec(p.instructionLanes, Bool()))

  for (i <- 0 until p.instructionLanes) {
    fetchEn(i) := io.inst.lanes(i).valid && io.inst.lanes(i).ready
  }

  val fsela = Cat((0 until p.instructionLanes).reverse.map(x =>
    (x until p.instructionLanes).map(y =>
      (if (y == x) { fetchEn(y) } else { !fetchEn(y) })
    ).reduce(_ && _)
  ))
  val fselb = (0 until p.instructionLanes).map(x => !fetchEn(x)).reduce(_ && _)
  val fsel = Cat(fsela, fselb)

  val nxtInstAddrOffset = instAddr.map(x => x) ++ instAddr.map(x => x + (p.instructionLanes * 4).U)
  val nxtInstAddr = (0 until p.instructionLanes).map(i =>
      (0 until (p.instructionLanes + 1)).map(
          j => MuxOR(fsel(j), nxtInstAddrOffset(j + i))).reduce(_|_))

  val nxtInstIndex0 = nxtInstAddr(0)(indexMsb, indexLsb)
  val nxtInstIndex1 = nxtInstAddr(p.instructionLanes - 1)(indexMsb, indexLsb)

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

  val nxtInstValid = Wire(Vec(p.instructionLanes, Bool()))

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

    val addr = VecInit((0 until p.instructionLanes).map(x => value + (x * 4).U))

    val match0 = l0valid(addr(0)(indexMsb,indexLsb)) &&
        addr(0)(tagMsb,tagLsb) === VecAt(l0tag, addr(0)(indexMsb,indexLsb))
    val match1 = l0valid(addr(p.instructionLanes - 1)(indexMsb,indexLsb)) &&
        addr(p.instructionLanes - 1)(tagMsb,tagLsb) === VecAt(l0tag, addr(p.instructionLanes - 1)(indexMsb,indexLsb))

    val vvalid = VecInit((0 until p.instructionLanes).map(x =>
      Mux(addr(0)(4,2) <= (7 - x).U, match0, match1)))

    val muxbits0 = VecAt(l0data, addr(0)(indexMsb,indexLsb))
    val muxbits1 = VecAt(l0data, addr(p.instructionLanes - 1)(indexMsb,indexLsb))
    val muxbits = Wire(Vec(16, UInt(p.instructionBits.W)))

    for (i <- 0 until 8) {
      val offset = 32 * i
      muxbits(i + 0) := muxbits0(31 + offset, offset)
      muxbits(i + 8) := muxbits1(31 + offset, offset)
    }

    val bits = Wire(Vec(p.instructionLanes, UInt(p.instructionBits.W)))
    for (i <- 0 until p.instructionLanes) {
      val idx = Cat(addr(0)(5) =/= addr(i)(5), addr(i)(4,2))
      bits(i) := VecAt(muxbits, idx)
    }

    (valid, vvalid.asUInt, addr, bits)
  }

  def BranchMatchEx(branch: Vec[BranchTakenIO]):
      (Bool, UInt, Vec[UInt], Vec[UInt]) = {
    val valid = branch.map(x => x.valid).reduce(_ || _)


    val addrBase = MuxCase(branch(branch.length - 1).value, (0 until branch.length - 1).map(x => branch(x).valid -> branch(x).value))
    val addr = VecInit((0 until branch.length).map(x => addrBase + (x * 4).U))

    val match0 = l0valid(addr(0)(indexMsb,indexLsb)) &&
        addr(0)(tagMsb,tagLsb) === VecAt(l0tag, addr(0)(indexMsb,indexLsb))
    val match1 = l0valid(addr(branch.length - 1)(indexMsb,indexLsb)) &&
        addr(branch.length - 1)(tagMsb,tagLsb) === VecAt(l0tag, addr(branch.length - 1)(indexMsb,indexLsb))

    val vvalid = VecInit((0 until branch.length).map(x =>
      Mux(addr(0)(4,2) <= (7 - x).U, match0, match1)))

    val muxbits0 = VecAt(l0data, addr(0)(indexMsb,indexLsb))
    val muxbits1 = VecAt(l0data, addr(branch.length - 1)(indexMsb,indexLsb))
    val muxbits = Wire(Vec(16, UInt(p.instructionBits.W)))

    for (i <- 0 until 8) {
      val offset = 32 * i
      muxbits(i + 0) := muxbits0(31 + offset, offset)
      muxbits(i + 8) := muxbits1(31 + offset, offset)
    }

    val bits = Wire(Vec(branch.length, UInt(p.instructionBits.W)))
    for (i <- 0 until branch.length) {
      val idx = Cat(addr(0)(5) =/= addr(i)(5), addr(i)(4,2))
      bits(i) := VecAt(muxbits, idx)
    }

    (valid, vvalid.asUInt, addr, bits)
  }

  def PredecodeDe(addr: UInt, op: UInt): (Bool, UInt) = {
    val jal = op === BitPat("b????????????????????_?????_1101111")
    val ret = op === BitPat("b000000000000_00001_000_00000_1100111") &&
                io.linkPort.valid
    val bxx = op === BitPat("b???????_?????_?????_???_?????_1100011") &&
                op(31) && op(14,13) =/= 1.U
    val immjal = Cat(Fill(12, op(31)), op(19,12), op(20), op(30,21), 0.U(1.W))
    val immbxx = Cat(Fill(20, op(31)), op(7), op(30,25), op(11,8), 0.U(1.W))
    val immed = Mux(op(2), immjal, immbxx)
    val target = Mux(ret, io.linkPort.value, addr + immed)
    (jal || ret || bxx, target)
  }

  val brchDe = (0 until p.instructionLanes).map(x => PredecodeDe(instAddr(x), instBits(x)))
  val brchTakensDe = brchDe.map { case (taken, target) => taken }
  val brchTargetsDe = brchDe.map { case (taken, target) => target }

  val brchTakenDeOr = (0 until p.instructionLanes).map(x =>
    io.inst.lanes(x).ready && io.inst.lanes(x).valid && brchTakensDe(x)
  ).reduce(_ || _)

  val brchTargetDe = MuxCase(brchTargetsDe(p.instructionLanes - 1),
    (0 until p.instructionLanes - 1).map(x => brchTakensDe(x) -> brchTargetsDe(x))
  )

  val (brchTakenDe, brchValidDe, brchAddrDe, brchBitsDe) =
      BranchMatchDe(brchTakenDeOr, brchTargetDe)

  val (brchTakenEx, brchValidEx, brchAddrEx, brchBitsEx) =
      BranchMatchEx(io.branch)


  val brchValidDeMask =
      Cat((0 until p.instructionLanes).reverse.map(x =>
        if (x == 0) { true.B } else {
          (0 until x).map(y =>
            !brchTakensDe(y)
          ).reduce(_ && _)
        }
      ))

  val brchFwd =
    Cat((0 until p.instructionLanes).reverse.map(x =>
      brchTakensDe(x) && (if (x == 0) { true.B } else { (0 until x).map(y => !brchTakensDe(y)).reduce(_ && _) })
    ))

  for (i <- 0 until p.instructionLanes) {
    // 1, 11, 111, ...
    nxtInstValid(i) := Mux(
      nxtInstAddr(0)(4,2) <= (7 - i).U,
      nxtMatch0,
      nxtMatch1)

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
    instAddr := (0 until p.instructionLanes).map(i => addr + (4 * i).U)
  }

  // Outputs
  for (i <- 0 until p.instructionLanes) {
    io.inst.lanes(i).valid := instValid(i) & brchValidDeMask(i)
    io.inst.lanes(i).bits.addr  := instAddr(i)
    io.inst.lanes(i).bits.inst  := instBits(i)
    io.inst.lanes(i).bits.brchFwd := brchFwd(i)
  }

  // Assertions.
  for (i <- 1 until p.instructionLanes) {
    assert(instAddr(0) + (4 * i).U === instAddr(i))
  }

  assert(fsel.getWidth == (p.instructionLanes + 1))
  assert(PopCount(fsel) <= 1.U)

  val instValidUInt = instValid.asUInt
  val instLanesReady = Cat((0 until p.instructionLanes).reverse.map(x => io.inst.lanes(x).ready))
  for (i <- 0 until p.instructionLanes - 1) {
    assert(!(!instValidUInt(i) && (instValidUInt(p.instructionLanes - 1, i + 1) =/= 0.U)))
    assert(!(!instLanesReady(i) && (instLanesReady(p.instructionLanes - 1, i + 1) =/= 0.U)))
  }
}

object EmitFetch extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new Fetch(p), args)
}
