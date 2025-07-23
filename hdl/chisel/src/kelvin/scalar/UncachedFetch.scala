// Copyright 2024 Google LLC
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

def PredictJump(p: Parameters, addr: UInt, inst: UInt): ValidIO[UInt] = {
  assert(p.instructionBits == 32)
  val jal = inst === BitPat("b????????????????????_?????_1101111")
  val immjal = Cat(Fill(12, inst(31)), inst(19,12), inst(20), inst(30,21), 0.U(1.W))
  val bxx = inst === BitPat("b???????_?????_?????_???_?????_1100011") &&
              inst(31) && inst(14,13) =/= 1.U
  val immbxx = Cat(Fill(20, inst(31)), inst(7), inst(30,25), inst(11,8), 0.U(1.W))
  val immed = Mux(inst(2), immjal, immbxx)

  val valid = jal || bxx
  val target = addr + immed

  MakeValid(valid, target)
}

class PredecodedInstruction(p: Parameters) extends Bundle {
  val addr = UInt(p.fetchAddrBits.W)
  val inst = UInt(p.instructionBits.W)
  val pcNext = UInt(p.fetchAddrBits.W)
  val branchFwd = Bool()
}

object PredecodedInstruction {
  def apply(p: Parameters, addr: UInt, inst: UInt): PredecodedInstruction = {
    val jump = PredictJump(p, addr, inst)
    val result = Wire(new PredecodedInstruction(p))
    result.addr := addr
    result.inst := inst
    result.pcNext := Mux(jump.valid, jump.target, addr + 4.U)
    result.branchFwd := jump.valid

    result := inst
  }
}

class PredecodeOutput(p: Parameters) extends Bundle {
    val addr = UInt(p.fetchAddrBits.W)
    val inst = Vec(p.fetchInstrSlots, UInt(p.instructionBits.W))
    val startIdx = UInt(3.W)
    val count = UInt(4.W)
    val nextPc = UInt(p.instructionBits.W)
}

class FetchResponse(p: Parameters) extends Bundle {
    val addr = UInt(p.fetchAddrBits.W)
    val inst = Vec(p.fetchInstrSlots, UInt(p.instructionBits.W))
}

class Instruction(p: Parameters) extends Bundle {
    val addr = UInt(p.fetchAddrBits.W)
    val inst = UInt(p.instructionBits.W)
}

// TODO(atv): Privatize this and FetchControl
// Module which is responsible for performing
// memory fetches which are requested by
// `FetchControl`.
// `ibus` should be treated like Chisel's
// `IrrevocableIO`.
class Fetcher(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val ctrl = Flipped(Decoupled(UInt(p.fetchAddrBits.W)))
    val fetch = Output(Valid(new FetchResponse(p)))
    val ibus = new IBusIO(p)
    val ibusFired = Output(Bool())
  })

  val ibusCmd = RegInit(MakeValid(false.B, 0.U(32.W)))

  io.fetch.valid := ibusCmd.valid
  io.fetch.bits.addr := Mux(ibusCmd.valid, ibusCmd.bits, 0.U)
  val data = Mux(ibusCmd.valid, io.ibus.rdata, 0.U)
  for (i <- 0 until p.fetchInstrSlots) {
    val offset = p.instructionBits * i
    io.fetch.bits.inst(i) := data(offset + p.instructionBits - 1, offset)
  }

  val ctrlValid = RegInit(false.B)
  val ctrlAddr = RegInit(0.U(p.fetchAddrBits.W))
  ctrlValid := io.ctrl.valid || ctrlValid && !io.ibus.ready
  ctrlAddr := Mux(io.ctrl.valid || ctrlValid && !io.ibus.ready,
    ctrlAddr, io.ctrl.bits
  )
  val lsb = log2Ceil(p.fetchDataBits / 8)
  assert((p.fetchDataBits == 128 && lsb == 4) || (p.fetchDataBits == 256 && lsb == 5))
  io.ibus.valid := io.ctrl.valid
  io.ibus.addr := Cat(io.ctrl.bits(p.fetchAddrBits - 1, lsb), 0.U(lsb.W))
  io.ctrl.ready := io.ibus.ready

  val ibusFired = io.ctrl.valid && io.ibus.ready
  ibusCmd := MakeValid(ibusFired, Mux(ibusFired, io.ctrl.bits, ibusCmd.bits))
  io.ibusFired := ibusFired
}

class FetchControl(p: Parameters) extends Module {
    val io = IO(new Bundle {
        val csr = new CsrInIO(p)
        val iflush = Input(Valid(UInt(32.W)))
        val branch = Input(Valid(UInt(p.fetchAddrBits.W)))
        val fetchData = Input(Valid(new FetchResponse(p)))
        val linkPort = Flipped(new RegfileLinkPortIO)
        val ibusFired = Input(Bool())

        val fetchAddr = Decoupled(UInt(p.fetchAddrBits.W))
        val bufferRequest = DecoupledVectorIO(new FetchInstruction(p), p.fetchInstrSlots)
    })

    def Predecode(fetchResponse: FetchResponse): (PredecodeOutput, Vec[Bool]) = {
      val insts = (0 until p.fetchInstrSlots).map(i => fetchResponse.inst(i))
      val addr = fetchResponse.addr
      val lsb = log2Ceil(p.fetchDataBits / 8)
      assert((p.fetchDataBits == 128 && lsb == 4) || (p.fetchDataBits == 256 && lsb == 5))
      val baseAddr = addr(p.fetchAddrBits - 1, lsb)
      val startElem = addr(lsb - 1, lsb - log2Ceil(p.fetchInstrSlots))
      val addrs = (0 until p.fetchInstrSlots).map(i => Cat(baseAddr, i.U((lsb - 2).W), 0.U(2.W)))

      val branchTargets = (addrs zip insts).map {
          case (addr, inst) => {
            val jump = PredictJump(p, addr, inst)
            jump
          }
      }

      val jumped = Wire(Vec(p.fetchInstrSlots, Bool()))
      for (i <- 0 until p.fetchInstrSlots) {
        val validInst = i.U >= startElem
        jumped(i) := validInst && branchTargets(i).valid
      }

      val lastInstIdx = MuxCase(p.fetchInstrSlots.U, (0 until p.fetchInstrSlots).map(i => jumped(i) -> i.U))
      val nextFetchPc = MuxCase(Cat(baseAddr + 1.U, 0.U(lsb.W)),
          (0 until p.fetchInstrSlots).map(i => jumped(i) -> branchTargets(i).bits))

      val startElemW = Wire(UInt(log2Ceil(p.fetchInstrSlots).W))
      startElemW := startElem
      val result = Wire(new PredecodeOutput(p))
      result.addr := Cat(baseAddr, 0.U(lsb.W))
      result.inst := insts
      result.startIdx := startElemW
      result.count := Mux(lastInstIdx === p.fetchInstrSlots.U,
                          lastInstIdx - startElem,
                          lastInstIdx + 1.U - startElem)
      result.nextPc := nextFetchPc

      (result, jumped)
    }

    val pc = RegInit(MakeValid(false.B, 0.U(32.W)))

    val (predecode, jumped) = Predecode(io.fetchData.bits)
    var predecodeValids = (0 until p.fetchInstrSlots).map(i =>
        i.U >= predecode.startIdx && i.U < (predecode.startIdx +& predecode.count)
    )
    for (i <- 0 until p.fetchInstrSlots) {
        val selectHot = PrioritySelect(predecodeValids)
        io.bufferRequest.bits(i).addr :=
          MuxCase(0.U(p.fetchAddrBits.W),
                  (0 until p.fetchInstrSlots).map(x => selectHot(x) -> (predecode.addr + (4 * x).U)))
        io.bufferRequest.bits(i).inst :=
          MuxCase(0.U(p.instructionBits.W),
                  (0 until p.fetchInstrSlots).map(x => selectHot(x) -> predecode.inst(x)))
        io.bufferRequest.bits(i).brchFwd :=
          MuxCase(false.B,
                  (0 until p.fetchInstrSlots).map(x => selectHot(x) -> jumped(x)))
        predecodeValids = VecInit((predecodeValids zip selectHot).map({case (p, s) => p && !s}))
    }

    // We can fill up to p.fetchInstrSlots elements in the instruction buffer from each ibus
    // request. Use number of elements ready as a back-pressure signal.
    val fetchValid = !io.branch.valid &&
                          !io.iflush.valid &&
                          pc.valid &&
                          (io.bufferRequest.nReady >= p.fetchInstrSlots.U)
    val fetch = RegInit(MakeInvalid(UInt(p.fetchAddrBits.W)))
    fetch := Mux(io.ibusFired,
                 MakeValid(false.B, 0.U(p.fetchAddrBits.W)),
                 Mux(fetch.valid,
                     fetch,
                     MakeValid(fetchValid, Mux(pc.valid, pc.bits, 0.U(p.fetchAddrBits.W)))
                )
             )

    val branchLatch = RegInit(MakeValid(false.B, 0.U(p.fetchAddrBits.W)))
    branchLatch := MuxCase(branchLatch, Seq(
      (io.iflush.valid && fetch.valid) -> io.iflush,
      (io.branch.valid && fetch.valid) -> io.branch,
      (!fetch.valid) -> MakeValid(false.B, 0.U(p.fetchAddrBits.W)),
    ))

    pc := MuxCase(MakeValid(false.B, 0x0badd00d.U(p.fetchAddrBits.W)), Seq(
        io.iflush.valid -> MakeValid(true.B, io.iflush.bits),
        io.branch.valid -> MakeValid(true.B, io.branch.bits),
        branchLatch.valid -> MakeValid(true.B, branchLatch.bits),
        io.fetchData.valid -> MakeValid(true.B, predecode.nextPc),
        pc.valid -> Mux(io.fetchAddr.ready && io.fetchAddr.valid, MakeValid(false.B, 0.U(p.fetchAddrBits.W)), pc),
        !pc.valid -> MakeValid(true.B, Cat(io.csr.value(0)(31,2), 0.U(2.W))),
    ))

    io.fetchAddr.valid := fetch.valid
    io.fetchAddr.bits := fetch.bits

    // Handle back pressure correctly
    io.bufferRequest.nValid := MuxCase(predecode.count, Seq(
      (io.iflush.valid) -> 0.U,
      (io.branch.valid || branchLatch.valid) -> 0.U,
      !io.fetchData.valid -> 0.U,
    ))
}

class UncachedFetch(p: Parameters) extends FetchUnit(p) {
  // TODO(derekjchow): Make Bru use valid interface
  val branch = MuxCase(
      MakeValid(false.B, 0.U(p.fetchAddrBits.W)),
      (0 until p.instructionLanes).map(i =>
          io.branch(i).valid -> MakeValid(true.B, io.branch(i).value)
      ))

  val ctrl = Module(new FetchControl(p))
  ctrl.io.csr <> io.csr
  ctrl.io.branch := branch
  ctrl.io.iflush.valid := io.iflush.valid
  ctrl.io.iflush.bits := io.iflush.pcNext
  ctrl.io.linkPort := io.linkPort
  // TODO(derekjchow): Maybe do something with back pressure?
  io.iflush.ready := true.B

  val fetcher = Module(new Fetcher(p))
  fetcher.io.ctrl <> ctrl.io.fetchAddr
  ctrl.io.fetchData := fetcher.io.fetch
  fetcher.io.ibus <> io.ibus
  ctrl.io.ibusFired := fetcher.io.ibusFired

  val window = p.fetchInstrSlots * 2
  val instructionBuffer = Module(new InstructionBuffer(
      new FetchInstruction(p), p.fetchInstrSlots, window))
  instructionBuffer.io.feedIn <> ctrl.io.bufferRequest
  io.inst.lanes <> instructionBuffer.io.out.take(4)
  instructionBuffer.io.flush := io.iflush.valid || branch.valid

  val pc = RegInit(0.U(p.fetchAddrBits.W))
  pc := Mux(instructionBuffer.io.out(0).valid, instructionBuffer.io.out(0).bits.addr, pc)
  io.pc := pc
}

class UncachedFetchV2(p.Parameters) extends FetchUnit(p) {
  // Register to track what ibus read was issued last cycle (if any).
  val issuedRead = RegInit(MakeValid(false.B, 0.U(32.W)))
  issuedRead := MakeValid(io.ibus.valid && io.ibus.ready, io.ibus.addr)

  // Register to track which instruction we want to fetch next (if any).
  val desiredPc = RegInit(MakeValid(false.B, 0.U(32.W)))

  // Register to track which PC to read next
  val insts = UIntToVec(io.ibus.rdata, 32)
  val predecodedInsts = VecInit((0 until p.fetchInstrSlots).map(i =>
    PredecodedInstruction(issuedRead.bits + (4.U * i.U), insts(i))
  ))
  val fetchLineAddrBits = log2Ceil(p.fetchDataBytes)
  val lineAddr = issuedRead.bits(fetchLineAddrBits-1, 2)
  val alignedPredecodedInsts = ShiftVectorLeft(predecodedInsts, lineAddr)
  val targetNext = MuxCase(
      MakeValid(true.B, issuedRead.bits + p.fetchDataBytes.U),
      Seq((0 until p.fetchInstrSlots).map(i =>
        val inst = predecodedInsts(i)
        ((i.U >= lineAddr) && inst.branchFwd) -> pcNext
      ))
  )

  val nextRead = MuxCase(desiredPc, Seq(
    // If an instruction flush has been issued, go to instruction after flush.
    io.iflush.valid -> MakeValid(true.B, io.iflush.bits),
    // If a branch instruction has been issued, go to branch
    io.branch.valid -> MakeValid(true.B, io.branch.bits),
    // If no branch/flush but valid read last cycle, get targetNext PC
    issuedRead.valid -> targetNext,
  ))

  // Define next read
  io.ibus.valid := nextRead.valid
  io.ibus.addr := nextRead

  desiredPc := Mux(io.ibus.valid && io.ibus.ready,
                   MakeValid(false.B, 0.U(32.W)),
                   nextRead)
}