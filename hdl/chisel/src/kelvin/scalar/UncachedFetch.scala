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
import _root_.circt.stage.ChiselStage

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

  val ctrlValid = Reg(Bool())
  val ctrlAddr = Reg(UInt(p.fetchAddrBits.W))
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
  ibusCmd := MakeValid(ibusFired, Mux(ibusFired, io.ctrl.bits, 0.U))
  io.ibusFired := ibusFired
}

class FetchControl(p: Parameters) extends Module {
    val io = IO(new Bundle {
        val csr = new CsrInIO(p)
        val iflush = Input(Bool())
        val branch = Input(Valid(UInt(p.fetchAddrBits.W)))
        val fetchData = Input(Valid(new FetchResponse(p)))
        val linkPort = Flipped(new RegfileLinkPortIO)
        val ibusFired = Input(Bool())

        val fetchAddr = Decoupled(UInt(p.fetchAddrBits.W))
        val bufferRequest = DecoupledVectorIO(new FetchInstruction(p), p.fetchInstrSlots)
    })

    def PredictJump(addr: UInt, inst: UInt): ValidIO[UInt] = {
      assert(p.instructionBits == 32)
      val jal = DecodeBits(inst, "xxxxxxxxxxxxxxxxxxxx_xxxxx_1101111")
      val immjal = Cat(Fill(12, inst(31)), inst(19,12), inst(20), inst(30,21), 0.U(1.W))
      val bxx = DecodeBits(inst, "xxxxxxx_xxxxx_xxxxx_xxx_xxxxx_1100011") &&
                  inst(31) && inst(14,13) =/= 1.U
      val immbxx = Cat(Fill(20, inst(31)), inst(7), inst(30,25), inst(11,8), 0.U(1.W))
      val immed = Mux(inst(2), immjal, immbxx)

      val valid = jal || bxx
      val target = addr + immed

      MakeValid(valid, target)
    }

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
            val jump = PredictJump(addr, inst)
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
                          !reset.asBool &&
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

    val branchLatch = Reg(Valid(UInt(p.fetchAddrBits.W)))
    when (io.branch.valid && fetch.valid) {
      branchLatch := io.branch
    } .elsewhen (!fetch.valid) {
      branchLatch := MakeValid(false.B, 0.U(p.fetchAddrBits.W))
    }

    pc := MuxCase(MakeValid(false.B, 0x0badd00d.U(p.fetchAddrBits.W)), Array(
        io.branch.valid -> MakeValid(true.B, io.branch.bits),
        branchLatch.valid -> MakeValid(true.B, branchLatch.bits),
        io.fetchData.valid -> MakeValid(true.B, predecode.nextPc),
        pc.valid -> Mux(io.fetchAddr.ready && io.fetchAddr.valid, MakeValid(false.B, 0.U(p.fetchAddrBits.W)), pc),
        !pc.valid -> MakeValid(true.B, Cat(io.csr.value(0)(31,2), 0.U(2.W))),
    ))

    io.fetchAddr.valid := fetch.valid
    io.fetchAddr.bits := fetch.bits

    // Handle back pressure correctly
    io.bufferRequest.nValid := Mux(reset.asBool || io.branch.valid || branchLatch.valid, 0.U, Mux(io.fetchData.valid, predecode.count, 0.U))
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
  ctrl.io.iflush <> io.iflush.valid
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
      new FetchInstruction(p), p.fetchInstrSlots, window, true))
  instructionBuffer.io.feedIn <> ctrl.io.bufferRequest
  io.inst.lanes <> instructionBuffer.io.out.take(4)
  instructionBuffer.io.flush.get := io.iflush.valid || branch.valid
  instructionBuffer.io.out.takeRight(window - 4).foreach(x => x.ready := false.B)

  val pc = RegInit(0.U(p.fetchAddrBits.W))
  pc := Mux(instructionBuffer.io.out(0).valid, instructionBuffer.io.out(0).bits.addr, pc)
  io.pc := pc
}
