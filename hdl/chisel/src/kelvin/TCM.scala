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

class TCM128(tcmSizeBytes: Int, tcmSubEntryWidth: Int) extends Module {
  val tcmWidth = 128
  val tcmEntries = tcmSizeBytes / (tcmWidth / 8)
  val tcmSubEntries = tcmWidth / tcmSubEntryWidth

  val io = IO(new Bundle {
    val addr = Input(UInt(log2Ceil(tcmEntries).W)) // 9 for 512 rows to address
    val enable = Input(Bool())
    val write = Input(Bool())
    val wdata = Input(Vec(tcmSubEntries, UInt(tcmSubEntryWidth.W)))
    val wmask = Input(Vec(tcmSubEntries, Bool()))
    val rdata = Output(Vec(tcmSubEntries, UInt(tcmSubEntryWidth.W)))
  })

  val sram = Module(new Sram_Nx128(tcmEntries))
  sram.io.addr := io.addr
  sram.io.enable := io.enable
  sram.io.write := Cat(io.write)
  sram.io.wdata := Cat(io.wdata)
  sram.io.wmask := Cat(io.wmask)
  io.rdata := UIntToVec(sram.io.rdata, tcmSubEntryWidth)
}

class TCM(p: Parameters, tcmSizeBytes: Int, tcmSubEntryWidth: Int) extends Module {
  val tcmWidth = p.axi2DataBits
  val tcmEntries = tcmSizeBytes / (tcmWidth / 8)
  val tcmSubEntries = tcmWidth / tcmSubEntryWidth

  val io = IO(new Bundle {
    val addr = Input(UInt(log2Ceil(tcmEntries).W))
    val enable = Input(Bool())
    val write = Input(Bool())
    val wdata = Input(Vec(tcmSubEntries, UInt(tcmSubEntryWidth.W)))
    val wmask = Input(Vec(tcmSubEntries, Bool()))
    val rdata = Output(Vec(tcmSubEntries, UInt(tcmSubEntryWidth.W)))
  })

  val wdataAsUint = Cat(io.wdata)
  val wmaskAsUint = Cat(io.wmask)

  val memoryRows = 128
  val memoryWidth = 128
  val memoryModulesRequired = (tcmSizeBytes * 8 /(memoryWidth * memoryRows))
  val selectSramBits = log2Ceil(memoryModulesRequired)
  val selectSramModule = io.addr(io.addr.getWidth - 1, io.addr.getWidth-selectSramBits)
  val selectSramModuleRead = RegNext(selectSramModule)
  val addrInternal = io.addr(io.addr.getWidth - 1 - selectSramBits, 0)

  val tcmSrams = (0 until memoryModulesRequired).map(x =>
      Module(new Sram_12ffcp_128x128))

  // Tie-offs (tie unselected memory inputs to 0)
  val tcmSramAddrTie = 0.U.asTypeOf(tcmSrams(0).io.addr)
  val tcmSramEnableTie = 0.U.asTypeOf(tcmSrams(0).io.enable)
  val tcmSramWriteTie = 0.U.asTypeOf(tcmSrams(0).io.write)
  val tcmSramWdataTie = 0.U.asTypeOf(tcmSrams(0).io.wdata)
  val tcmSramWmaskTie = 0.U.asTypeOf(tcmSrams(0).io.wmask)

  for (i <- 0 until memoryModulesRequired) {
    when (selectSramModule === i.U) {
      tcmSrams(i).io.addr := io.addr
      tcmSrams(i).io.enable := io.enable
      tcmSrams(i).io.write := io.write
      tcmSrams(i).io.wdata := wdataAsUint
      tcmSrams(i).io.wmask := wmaskAsUint
    } .otherwise {
      tcmSrams(i).io.addr := tcmSramAddrTie
      tcmSrams(i).io.enable := tcmSramEnableTie
      tcmSrams(i).io.write := tcmSramWriteTie
      tcmSrams(i).io.wdata := tcmSramWdataTie
      tcmSrams(i).io.wmask := wmaskAsUint
    }
    tcmSrams(i).io.clock := clock
  }

  val rdataSelectedUint = VecInit(tcmSrams.map(_.io.rdata))(selectSramModuleRead)
  val rdataSelected = UIntToVec(rdataSelectedUint, tcmSubEntryWidth)

  io.rdata := rdataSelected
}
