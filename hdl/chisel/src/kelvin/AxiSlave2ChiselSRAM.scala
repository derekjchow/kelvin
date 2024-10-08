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

import bus.AxiMasterIO
import common._

class AxiSlave2ChiselSRAM(p: Parameters, sramAddressWidth: Int) extends Module {
  val io = IO(new Bundle{
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val sramAddress = Output(UInt(sramAddressWidth.W))
    val sramEnable = Output(Bool())
    val sramIsWrite = Output(Bool())
    val sramReadData = Input(Vec(p.axi2DataBits / 8, UInt(8.W)))
    val sramWriteData = Output(Vec(p.axi2DataBits / 8, UInt(8.W)))
    val sramMask = Output(Vec(p.axi2DataBits / 8, Bool()))
    // Output indicating a transaction is progress (to force arbiter lock)
    val txnInProgress = Output(Bool())
    // Input to indicate that the arbiter is elsewhere -- gate our ready signals
    val periBusy = Input(Bool())
  })

  val readAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits)))
  io.axi.read.addr.ready := !readAddr.valid && !io.periBusy
  val canRead = !readAddr.valid && io.axi.read.addr.valid && !io.periBusy
  when (canRead) {
    readAddr := MakeValid(true.B, io.axi.read.addr.bits)
  }

  val readValid = RegInit(false.B)
  val doRead = readAddr.valid && !readValid
  readValid := doRead
  io.axi.read.data.valid := readValid
  when (io.axi.read.data.fire) {
    when (io.axi.read.data.bits.last) {
      readAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits))
    } .otherwise {
      readAddr.bits.addr := readAddr.bits.addr +  (1.U << readAddr.bits.size)
      readAddr.bits.len := readAddr.bits.len - 1.U
    }
  }

  val writeAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits)))
  io.axi.write.addr.ready := !writeAddr.valid && !io.periBusy
  val canWrite = !writeAddr.valid && io.axi.write.addr.valid
  when (canWrite) {
    writeAddr := MakeValid(true.B, io.axi.write.addr.bits)
  }

  val writeData = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits)))
  io.axi.write.data.ready := !writeData.valid && !io.periBusy
  val canWriteData = !writeData.valid && io.axi.write.data.valid
  when (canWriteData) {
    writeData := MakeValid(true.B, io.axi.write.data.bits)
  }
  when (writeData.valid) {
    writeData := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits))
    writeAddr.bits.addr := writeAddr.bits.addr + (1.U << writeAddr.bits.size)
    writeAddr.bits.len := writeAddr.bits.len - 1.U
  }

  val doWrite = writeData.valid && writeAddr.valid
  val writeRespValid = RegInit(false.B)
  writeRespValid := writeAddr.valid && writeData.valid && writeAddr.bits.len === 0.U && writeData.bits.last
  io.axi.write.resp.valid := writeRespValid
  when (io.axi.write.resp.fire) {
    writeAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits))
  }
  val readData = Cat(io.sramReadData)
  val readDataRightShift = readData >> (readAddr.bits.addr(3,0) << 3)

  val maxSize = log2Ceil(p.axi2DataBits / 8)
  val readDataMask = Cat(
    Cat((1 to maxSize).reverse.map(x => {
      val width = (scala.math.pow(2, (x - 1)).toInt) * 8
      (Mux(readAddr.bits.size >= x.U, -1.S(width.W).asUInt, 0.U(width.W)))
    })),
    "xFF".U(8.W)
  )
  io.axi.read.data.bits.data := Mux(readValid,
    readDataRightShift & readDataMask,
    0.U.asTypeOf(io.axi.read.data.bits.data))
  io.axi.read.data.bits.id := Mux(readValid, readAddr.bits.id, 0.U.asTypeOf(io.axi.read.data.bits.id))
  io.axi.read.data.bits.resp := 0.U
  io.axi.read.data.bits.last := Mux(readValid, readAddr.bits.len === 0.U, false.B)

  io.axi.write.resp.bits.resp := 0.U
  io.axi.write.resp.bits.id := Mux(doWrite, writeAddr.bits.id, 0.U.asTypeOf(io.axi.write.resp.bits.id))

  val lsb = log2Ceil(p.axi2DataBits / 8)
  io.sramAddress := MuxCase(0.U, Array(
    doWrite -> writeAddr.bits.addr(sramAddressWidth + lsb - 1, lsb),
    readAddr.valid -> readAddr.bits.addr(sramAddressWidth + lsb - 1, lsb)
  ))
  io.sramEnable := (readAddr.valid || writeAddr.valid)
  io.sramIsWrite := (writeAddr.valid && writeData.valid)
  val dummyWriteData = RegInit(VecInit.fill(writeData.bits.data.getWidth / 8)(0.U(8.W)))
  val writeDataLeftShift = (writeData.bits.data << (writeAddr.bits.addr(3,0) << 3))(writeData.bits.data.getWidth - 1,0)
  val writeDataVec = UIntToVec(writeDataLeftShift, 8)
  val writeStrbLeftShift = (writeData.bits.strb << (writeAddr.bits.addr(3,0)))(writeData.bits.strb.getWidth - 1,0)
  val writeMaskData = VecInit(writeStrbLeftShift.asBools)
  io.sramWriteData := Mux(doWrite, writeDataVec, dummyWriteData)
  val readMaskData = RegInit(VecInit(Seq.fill(writeData.bits.data.getWidth / 8)(true.B)))
  val maskData = Mux(doWrite, writeMaskData, readMaskData)
  io.sramMask := maskData
  io.txnInProgress := readAddr.valid || writeAddr.valid
}