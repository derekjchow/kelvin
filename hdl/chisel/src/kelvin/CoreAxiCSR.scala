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

import bus.{AxiBurstType, AxiMasterIO}
import common._

class CoreAxiCSR(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))

    val reset = Output(Bool())
    val cg = Output(Bool())
    val pcStart = Output(UInt(p.fetchAddrBits.W))
    val halted = Input(Bool())
    val fault = Input(Bool())
    val kelvin_csr = Input(new CsrOutIO(p))
  })

  // Bit 0 - Reset (Active High)
  // Bit 1 - Clock Gate (Active High)
  // By default, be in reset and with the clock gated.
  val resetReg = RegInit(3.U(p.fetchAddrBits.W))
  val pcStartReg = RegInit(0.U(p.fetchAddrBits.W))
  val statusReg = RegInit(0.U(p.fetchAddrBits.W))

  io.reset := resetReg(0)
  io.cg := resetReg(1)
  io.pcStart := pcStartReg
  statusReg := Cat(io.fault, io.halted)

  val readAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits)))
  val readBaseAddr = RegInit(0.U.asTypeOf(io.axi.read.addr.bits.addr))
  io.axi.read.addr.ready := !readAddr.valid
  val canRead = !readAddr.valid && io.axi.read.addr.valid
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

  val alignedAddr = (io.axi.read.addr.bits.addr >> io.axi.read.addr.bits.size) << io.axi.read.addr.bits.size
  val readData =
    MuxCase(0.U, Array(
      (readAddr.bits.addr === 0x0.U) -> resetReg,
      (readAddr.bits.addr === 0x4.U) -> pcStartReg,
      (readAddr.bits.addr === 0x8.U) -> statusReg,
      (readAddr.bits.addr === 0x100.U) -> io.kelvin_csr.value(0),
      (readAddr.bits.addr === 0x104.U) -> io.kelvin_csr.value(1),
      (readAddr.bits.addr === 0x108.U) -> io.kelvin_csr.value(2),
      (readAddr.bits.addr === 0x10C.U) -> io.kelvin_csr.value(3),
      (readAddr.bits.addr === 0x110.U) -> io.kelvin_csr.value(4),
      (readAddr.bits.addr === 0x114.U) -> io.kelvin_csr.value(5),
      (readAddr.bits.addr === 0x118.U) -> io.kelvin_csr.value(6),
      (readAddr.bits.addr === 0x11C.U) -> io.kelvin_csr.value(7),
    ))
  val readDataShift = ((io.axi.read.addr.bits.addr - alignedAddr) << 3.U)(8,0)
  io.axi.read.data.bits.data := Mux(readValid, (readData << readDataShift), 0.U)
  io.axi.read.data.bits.id := Mux(readAddr.valid, readAddr.bits.id, 0.U)
  io.axi.read.data.bits.resp := 0.U
  io.axi.read.data.bits.last := Mux(readAddr.valid, readAddr.bits.len === 0.U, false.B)

  val writeAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits)))
  val writeBaseAddr = RegInit(0.U.asTypeOf(io.axi.write.addr.bits.addr))
  io.axi.write.addr.ready := !writeAddr.valid
  val canWrite = !writeAddr.valid && io.axi.write.addr.valid
  when (canWrite) {
    writeAddr := MakeValid(true.B, io.axi.write.addr.bits)
    val writeMask = VecInit((0 until io.axi.write.addr.bits.addr.getWidth).map(x => !(x.U < io.axi.write.addr.bits.size)))
    writeBaseAddr := io.axi.write.addr.bits.addr & writeMask.asUInt
  }

  val writeData = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits)))
  io.axi.write.data.ready := !writeData.valid
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

  val doWrite = writeData.valid && writeAddr.valid
  val writeRespValid = RegInit(false.B)
  writeRespValid := writeAddr.valid && writeData.valid && writeAddr.bits.len === 0.U && writeData.bits.last
  io.axi.write.resp.valid := writeRespValid
  when (io.axi.write.resp.fire) {
    writeAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits))
    writeBaseAddr := 0.U.asTypeOf(io.axi.write.addr.bits.addr)
  }

  io.axi.write.resp.bits.resp := 0.U
  io.axi.write.resp.bits.id := Mux(doWrite, writeAddr.bits.id, 0.U.asTypeOf(io.axi.write.resp.bits.id))

  // TODO(atv): What bits are allowed to change in these? Add a mask or something.
  resetReg := Mux(doWrite && writeAddr.bits.addr === 0x0.U, writeData.bits.data(31,0), resetReg)
  pcStartReg := Mux(doWrite && writeAddr.bits.addr === 0x4.U, writeData.bits.data(31,0), pcStartReg)
}