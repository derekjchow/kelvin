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

import bus.{AxiBurstType, AxiMasterIO, AxiResponseType}

import common._

class AxiSlave(p: Parameters) extends Module {
  val io = IO(new Bundle{
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val fabric = new FabricIO(p)
    // Output indicating that a transaction is in progress
    val txnInProgress = Output(Bool())
    // Input indicating that the peripheral is busy -- do not accept AXI transactions
    val periBusy = Input(Bool())
  })

  val readAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits)))
  val readBaseAddr = RegInit(0.U.asTypeOf(io.axi.read.addr.bits.addr))
  io.axi.read.addr.ready := !readAddr.valid && !io.periBusy
  val canRead = !readAddr.valid && io.axi.read.addr.valid && !io.periBusy
  when (canRead) {
    readAddr := MakeValid(true.B, io.axi.read.addr.bits)
    val readMask = VecInit((0 until io.axi.read.addr.bits.addr.getWidth).map(x => !(x.U < io.axi.read.addr.bits.size)))
    readBaseAddr := io.axi.read.addr.bits.addr & readMask.asUInt;
  }

  val readValid = RegInit(false.B)
  val doRead = readAddr.valid && !readValid
  readValid := doRead
  io.axi.read.data.valid := readValid
  when (io.axi.read.data.fire) {
    when (io.axi.read.data.bits.last) {
      readAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits))
    } .otherwise {
      val (burst, burstValid) = AxiBurstType.safe(readAddr.bits.burst)
      readAddr.bits.addr := MuxOR(burstValid, MuxLookup(burst, 0.U)(Seq(
        AxiBurstType.FIXED -> readAddr.bits.addr,
        AxiBurstType.INCR -> (readAddr.bits.addr +  (1.U << readAddr.bits.size)),
        AxiBurstType.WRAP -> {
          val newAddr = readAddr.bits.addr + (1.U << readAddr.bits.size)
          val newAddrWrapped = Mux(newAddr >= readBaseAddr + (p.axi2DataBits / 8).U, readBaseAddr, newAddr)
          newAddrWrapped(31,0)
        }
      )))
      readAddr.bits.len := MuxOR(burstValid, readAddr.bits.len - 1.U)
    }
  }
  io.fabric.readDataAddr := MakeValid(readAddr.valid, readAddr.bits.addr)

  val alignedAddrMask = VecInit((0 until io.axi.read.addr.bits.addr.getWidth).map(
    x => !(x.U < io.axi.read.addr.bits.size)
  ))
  val alignedAddr = io.axi.read.addr.bits.addr & alignedAddrMask.asUInt
  val msb = log2Ceil(p.axi2DataBits) - 1
  val readDataShift = ((io.axi.read.addr.bits.addr - alignedAddr) << 3.U)(msb,0)
  io.axi.read.data.bits.data := io.fabric.readData.bits << readDataShift
  io.axi.read.data.bits.id := Mux(readAddr.valid, readAddr.bits.id, 0.U)
  // If readData is valid, return AXI OK. Otherwise, return AXI SLVERR.
  io.axi.read.data.bits.resp := Mux(io.fabric.readData.valid, AxiResponseType.OKAY.asUInt, AxiResponseType.SLVERR.asUInt);
  io.axi.read.data.bits.last := Mux(readAddr.valid, readAddr.bits.len === 0.U, false.B)

  val writeAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits)))
  val writeBaseAddr = RegInit(0.U.asTypeOf(io.axi.write.addr.bits.addr))
  io.axi.write.addr.ready := !writeAddr.valid && !io.periBusy
  val canWrite = !writeAddr.valid && io.axi.write.addr.valid
  when (canWrite) {
    writeAddr := MakeValid(true.B, io.axi.write.addr.bits)
    val writeMask = VecInit((0 until io.axi.write.addr.bits.addr.getWidth).map(x => !(x.U < io.axi.write.addr.bits.size)))
    writeBaseAddr := io.axi.write.addr.bits.addr & writeMask.asUInt
  }

  val writeData = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits)))
  io.axi.write.data.ready := !writeData.valid && !io.periBusy
  val canWriteData = !writeData.valid && io.axi.write.data.valid
  when (canWriteData) {
    writeData := MakeValid(true.B, io.axi.write.data.bits)
  }
  when (writeData.valid) {
    writeData := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits))
    val (burst, burstValid) = AxiBurstType.safe(writeAddr.bits.burst)
    writeAddr.bits.addr := MuxOR(burstValid, MuxLookup(burst, 0.U)(Seq(
      AxiBurstType.FIXED -> writeAddr.bits.addr,
      AxiBurstType.INCR -> (writeAddr.bits.addr + (1.U << writeAddr.bits.size)),
      AxiBurstType.WRAP -> {
        val newAddr = writeAddr.bits.addr + (1.U << writeAddr.bits.size)
        val newAddrWrapped = Mux(newAddr >= writeBaseAddr + (p.axi2DataBits / 8).U, writeBaseAddr, newAddr)
        newAddrWrapped(31,0)
      },
    )))
    writeAddr.bits.len := MuxOR(burstValid, writeAddr.bits.len - 1.U)
  }
  io.fabric.writeDataAddr := MakeValid(writeData.valid, writeAddr.bits.addr)
  io.fabric.writeDataBits := writeData.bits.data
  io.fabric.writeDataStrb := writeData.bits.strb

  val doWrite = writeData.valid && writeAddr.valid
  val writeRespValid = RegInit(false.B)
  writeRespValid := writeAddr.valid && writeData.valid && writeAddr.bits.len === 0.U && writeData.bits.last
  val writeResp = RegInit(false.B)
  writeResp := io.fabric.writeResp
  io.axi.write.resp.valid := writeRespValid
  // If writeResp is true, return AXI OK. Otherwise, return AXI SLVERR.
  io.axi.write.resp.bits.resp := Mux(writeResp, AxiResponseType.OKAY.asUInt, AxiResponseType.SLVERR.asUInt)
  when (io.axi.write.resp.fire) {
    writeAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits))
    writeBaseAddr := 0.U.asTypeOf(io.axi.write.addr.bits.addr)
  }

  io.axi.write.resp.bits.id := Mux(doWrite, writeAddr.bits.id, 0.U.asTypeOf(io.axi.write.resp.bits.id))
  io.txnInProgress := readAddr.valid || writeAddr.valid
}