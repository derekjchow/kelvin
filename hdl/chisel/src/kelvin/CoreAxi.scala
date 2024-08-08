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

import bus.{AxiMasterIO,AxiMasterReadIO}
import common._
import _root_.circt.stage.ChiselStage

class CoreAxi(p: Parameters, coreModuleName: String) extends Module {
  override val desiredName = coreModuleName + "Axi"
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())
    val debug_req = Input(Bool())

    val axi0 = if (p.enableVector) {
      Some(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    } else { None }
    val axi1 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    // ibus
    val axi2 = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    // dbus
    val axi3 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  val core = Core(p, coreModuleName)
  io.csr <> core.io.csr
  io.halted := core.io.halted
  io.fault := core.io.fault
  core.io.debug_req := io.debug_req
  if (p.enableVector) {
    io.axi0.get <> core.io.axi0.get
  }
  io.axi1 <> core.io.axi1

  // axi2
  val ibus2axi = IBus2Axi(p)
  ibus2axi.io.axi <> io.axi2
  ibus2axi.io.ibus <> core.io.ibus
  // axi3
  val dbus2axi = DBus2Axi(p)
  dbus2axi.io.axi <> io.axi3
  dbus2axi.io.dbus <> core.io.dbus


  io.iflush <> core.io.iflush
  io.dflush <> core.io.dflush
  io.slog <> core.io.slog
  io.debug <> core.io.debug
}
