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
import scala.math.{ceil}

class Sram_Nx128(tcmEntries: Int) extends Module {
  override val desiredName = "SRAM_" + tcmEntries + "x128"
  val addrBits = log2Ceil(tcmEntries)
  val sramSelectBits = addrBits - 7
  assert(sramSelectBits > 0)
  val io = IO(new Bundle {
    val addr = Input(UInt(addrBits.W))
    val enable = Input(Bool())
    val write = Input(Bool())
    val wdata = Input(UInt(128.W))
    val wmask = Input(UInt(16.W))
    val rdata = Output(UInt(128.W))
  })

  // Setup SRAM modules
  val nSramModules = ceil(tcmEntries / 128.0).toInt
  val sramModules = (0 until nSramModules).map(x =>
      Module(new Sram_12ffcp_128x128))
  val selectedSram = io.addr(addrBits - 1, 7)
  assert(selectedSram.getWidth == sramSelectBits)

  // Hook in inputs
  for (i <- 0 until nSramModules) {
    sramModules(i).io.clock := clock
    sramModules(i).io.addr := io.addr(6, 0)
    sramModules(i).io.enable := (selectedSram === i.U) && io.enable
    sramModules(i).io.write := io.write
    sramModules(i).io.wdata := io.wdata
    sramModules(i).io.wmask := io.wmask
  }

  // Mux read output
  val selectedSramRead = RegNext(selectedSram)
  io.rdata := MuxLookup(selectedSramRead, 0.U(7.W))(
      (0 until nSramModules).map(i => i.U -> sramModules(i).io.rdata))
}
