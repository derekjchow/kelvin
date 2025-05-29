// Copyright 2025 Google LLC
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

class RetirementBuffer(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val inst = Input(Vec(p.instructionLanes, Decoupled(new FetchInstruction(p))))
    val writeAddrScalar = Input(Vec(p.instructionLanes, new RegfileWriteAddrIO))
    val writeDataScalar = Input(Vec(p.instructionLanes + 2, Valid(new RegfileWriteDataIO)))
    val writeAddrFloat = Option.when(p.enableFloat)(Input(new RegfileWriteAddrIO))
    val writeDataFloat = Option.when(p.enableFloat)(Input(Vec(2, Valid(new RegfileWriteDataIO))))
    val nSpace = Output(UInt(32.W))
    val debug = Output(new RetirementBufferDebugIO(p))
  })

  val idxWidth = p.retirementBufferIdxWidth
  val floatRegisterBase = 32.U
  val noWriteRegIdx = ~0.U(idxWidth.W)
  class Instruction extends Bundle {
    val addr = UInt(32.W) // Memory address
    val inst = UInt(32.W) // Instruction bits
    val idx = UInt(idxWidth.W) // Register Index
  }
  val bufferSize = p.retirementBufferSize
  assert(bufferSize >= p.instructionLanes)
  assert(bufferSize >= io.writeDataScalar.length)
  // Construct a circular buffer of `bufferSize`, that can enqueue and dequeue `bufferSize` elements
  // per cycle. This will be used to store information about dispatched instructions.
  val instBuffer = Module(new CircularBufferMulti(new Instruction,
                                              /* needs to be at least writeDataScalar count */ bufferSize,
                                              /* chosen sort-of-arbitrarily */ bufferSize))
  // Check that we see no instructions fire after the first non-fire.
  val instFires = io.inst.map(_.fire)
  val seenFalseV = (instFires.scanLeft(false.B) { (acc, curr) => acc || !curr }).drop(1)
  assert(!(seenFalseV.zip(instFires).map({ case (seenFalse, fire) => seenFalse && fire }).reduce(_|_)))

  // Create Instruction wires out of io.inst + io.writeAddrScalar, and align.
  def WireInstruction(i: Int) = {
    val floatValid = (i == 0).B && io.writeAddrFloat.map(x => x.valid).getOrElse(false.B)
    val floatAddr = io.writeAddrFloat.map(x => x.addr).getOrElse(0.U)

    val scalarValid = io.writeAddrScalar(i).valid
    val scalarAddr = io.writeAddrScalar(i).addr

    val instr = Wire(new Instruction)
    instr.addr := io.inst(i).bits.addr
    instr.inst := io.inst(i).bits.inst
    instr.idx := MuxCase(noWriteRegIdx, Seq(
      floatValid -> (floatAddr +& floatRegisterBase),
      (scalarValid && scalarAddr =/= 0.U) -> scalarAddr,
    ))
    instr
  }
  val insts = (0 until p.instructionLanes).map(x => WireInstruction(x))

  val instsWithWriteFired = PopCount(io.inst.map(_.fire))
  instBuffer.io.enqValid := instsWithWriteFired
  instBuffer.io.flush := false.B
  io.nSpace := instBuffer.io.nSpace

  for (i <- 0 until p.instructionLanes) {
    instBuffer.io.enqData(i) := insts(i)
  }
  for (i <- p.instructionLanes until bufferSize) {
    instBuffer.io.enqData(i) := 0.U.asTypeOf(instBuffer.io.enqData(i))
  }

  // Maintain a re-order buffer of instruction completion result.
  // The order and alignment of these buffers should correspond to the
  // output of `instBuffer`.
  val resultBuffer = RegInit(VecInit(Seq.fill(bufferSize)(MakeInvalid(UInt(32.W)))))
  // Compute update based on register writeback.
  // Note: The shift when committing instructions will be handled in a later block.
  val resultUpdate = Wire(Vec(bufferSize, Valid(UInt(32.W))))

  for (i <- 0 until bufferSize) {
    val bufferEntry = instBuffer.io.dataOut(i)
    // Check which incoming (scalar,float) write port matches this entry's needed address.
    val scalarWriteIdxMap = io.writeDataScalar.map(
        x => x.valid && (x.bits.addr === bufferEntry.idx))
    val floatWriteIdxMap = io.writeDataFloat.map(y => y.map(
        x => x.valid && ((x.bits.addr +& floatRegisterBase) ===
            bufferEntry.idx))).getOrElse(Seq(false.B))
    // Check if this entry is an operation that doesn't require a register write (e.g., a store).
    val nonWritingInstr = bufferEntry.idx === noWriteRegIdx
    // The entry is active if it's validly enqueued and not already complete.
    val validBufferEntry = (i.U < instBuffer.io.nEnqueued) && (!resultBuffer(i).valid)

    // If the entry is active and its data dependency is met (or it has no dependency)...
    val updated = (validBufferEntry && (scalarWriteIdxMap.reduce(_|_) || floatWriteIdxMap.reduce(_|_) || nonWritingInstr))
    // Find the index of the first write port that provides the needed data.
    val scalarWriteIdx = PriorityEncoder(scalarWriteIdxMap)
    val floatWriteIdx = PriorityEncoder(floatWriteIdxMap)
    // Select the actual data from the winning write port.
    val writeDataScalar = io.writeDataScalar(scalarWriteIdx).bits.data
    val writeDataFloat = io.writeDataFloat.map(x => x(floatWriteIdx).bits.data).getOrElse(0.U)
    // If updated, mark this buffer entry as complete for the next cycle.
    resultUpdate(i).valid := Mux(updated, true.B, resultBuffer(i).valid) // true.B
    // Select the correct write-back data to store, if updated (FP has priority).
    resultUpdate(i).bits := Mux(updated, MuxCase(0.U, Seq(
      floatWriteIdxMap.reduce(_|_) -> writeDataFloat,
      scalarWriteIdxMap.reduce(_|_) -> writeDataScalar,
    )), resultBuffer(i).bits)
  }

  val deqReady = Cto(VecInit(resultUpdate.map(_.valid)).asUInt)
  instBuffer.io.deqReady := deqReady
  resultBuffer := ShiftVectorRight(resultUpdate, deqReady)

  for (i <- 0 until bufferSize) {
    val valid = (i.U < instBuffer.io.deqReady)
    io.debug.inst(i).valid := valid
    io.debug.inst(i).bits.pc := MuxOR(valid, instBuffer.io.dataOut(i).addr)
    io.debug.inst(i).bits.inst := MuxOR(valid, instBuffer.io.dataOut(i).inst)
    io.debug.inst(i).bits.idx := MuxOR(valid, instBuffer.io.dataOut(i).idx)
    io.debug.inst(i).bits.data := MuxOR(valid, resultUpdate(i).bits)
  }
}
