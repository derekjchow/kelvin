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

class SRAMIO(p: Parameters, sramAddressWidth: Int) extends Bundle {
  val address = Output(UInt(sramAddressWidth.W))
  val enable = Output(Bool())
  val isWrite = Output(Bool())
  val readData = Input(Vec(p.axi2DataBits / 8, UInt(8.W)))
  val writeData = Output(Vec(p.axi2DataBits / 8, UInt(8.W)))
  val mask = Output(Vec(p.axi2DataBits / 8, Bool()))
}

class SRAM(p: Parameters, sramAddressWidth: Int) extends Module {
  val io = IO(new Bundle{
    val fabric = Flipped(new FabricIO(p))
    val sram = new SRAMIO(p, sramAddressWidth)
  })

  val lsb = log2Ceil(p.axi2DataBits / 8)
  io.sram.address := MuxCase(0.U, Array(
    io.fabric.writeDataAddr.valid -> io.fabric.writeDataAddr.bits(sramAddressWidth + lsb - 1, lsb),
    io.fabric.readDataAddr.valid -> io.fabric.readDataAddr.bits(sramAddressWidth + lsb - 1, lsb)
  ))

  val readData = Cat(io.sram.readData)
  io.fabric.readData.bits := Mux(
      io.fabric.readDataAddr.valid, readData, 0.U.asTypeOf(io.fabric.readData.bits))
  io.fabric.readData.valid := io.fabric.readDataAddr.valid

  io.sram.enable := (io.fabric.readDataAddr.valid || io.fabric.writeDataAddr.valid)
  io.sram.isWrite := io.fabric.writeDataAddr.valid
  val writeDataLeftShift = (io.fabric.writeDataBits << (io.fabric.writeDataAddr.bits(3,0) << 3))(io.fabric.writeDataBits.getWidth - 1,0)
  val writeDataVec = UIntToVec(writeDataLeftShift, 8)
  val writeStrbLeftShift = (io.fabric.writeDataStrb << (io.fabric.writeDataAddr.bits(3,0)))(io.fabric.writeDataStrb.getWidth - 1,0)
  val writeMaskData = VecInit(writeStrbLeftShift.asBools)
  io.sram.writeData := Mux(io.fabric.writeDataAddr.valid, writeDataVec, 0.U.asTypeOf(writeDataVec))
  val readMaskData = RegInit(VecInit(Seq.fill(io.fabric.writeDataBits.getWidth / 8)(true.B)))
  val maskData = Mux(io.fabric.writeDataAddr.valid, writeMaskData, readMaskData)
  io.sram.mask := maskData
  io.fabric.writeResp := true.B
}

class AxiSlave2SRAM(p: Parameters,
                    sramAddressWidth: Int,
                    axiReadAddrDelay: Int = 0,
                    axiReadDataDelay: Int = 0) extends Module {
  val io = IO(new Bundle{
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val sram = new SRAMIO(p, sramAddressWidth)
    // Output indicating a transaction is progress (to force arbiter lock)
    val txnInProgress = Output(Bool())
    // Input to indicate that the arbiter is elsewhere -- gate our ready signals
    val periBusy = Input(Bool())
  })

  val axi = Module(new AxiSlave(p))
  io.axi.write <> axi.io.axi.write
  // Optionally delay AXI read channel. This helps break up a long timing path
  // from SRAM.
  axi.io.axi.read.addr <> Queue(io.axi.read.addr, axiReadAddrDelay)
  io.axi.read.data <> Queue(axi.io.axi.read.data, axiReadDataDelay)
  axi.io.periBusy := io.periBusy
  io.txnInProgress := axi.io.txnInProgress

  val sram = Module(new SRAM(p, sramAddressWidth))
  sram.io.fabric <> axi.io.fabric
  sram.io.sram <> io.sram
}