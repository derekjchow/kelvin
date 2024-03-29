// Copyright 2023 Google LLC
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

package matcha

import chisel3._
import chisel3.util._
import common._
import _root_.circt.stage.ChiselStage

class KelvinMemIO(p: kelvin.Parameters) extends Bundle {
  val cvalid = (Output(Bool()))
  val cready = (Input(Bool()))
  val cwrite = (Output(Bool()))
  val caddr  = (Output(UInt(p.axiSysAddrBits.W)))
  val cid    = (Output(UInt(p.axiSysIdBits.W)))
  val wdata  = (Output(UInt(p.axiSysDataBits.W)))
  val wmask  = (Output(UInt((p.axiSysDataBits / 8).W)))
  val rvalid = (Input(Bool()))
  val rid    = (Input(UInt(p.axiSysIdBits.W)))
  val rdata  = (Input(UInt(p.axiSysDataBits.W)))
}

object Kelvin {
  def apply(p: kelvin.Parameters): Kelvin = {
    return Module(new Kelvin(p))
  }
}

class Kelvin(p: kelvin.Parameters) extends RawModule {
  // IO ports. (RawModule removes default[clock, reset])
  val clk_i  = IO(Input(Clock()))
  val rst_ni = IO(Input(AsyncReset()))

  val mem = IO(new KelvinMemIO(p))

  val clk_freeze = IO(Input(Bool()))
  val ml_reset   = IO(Input(Bool()))
  val pc_start   = IO(Input(UInt(32.W)))
  val volt_sel   = IO(Input(Bool()))

  val finish   = IO(Output(Bool()))
  val host_req = IO(Output(Bool()))
  val fault    = IO(Output(Bool()))

  val slog = IO(new kelvin.SLogIO(p))

  // ---------------------------------------------------------------------------
  // Gated Clock.
  val cg = Module(new kelvin.ClockGate())
  cg.io.clk_i  := clk_i
  cg.io.enable := !clk_freeze
  val clk_g = cg.io.clk_o

  // ---------------------------------------------------------------------------
  // Reset inverter and synchronizer.
  //
  // Most registers in the design are loaded by literals and it is safe to use
  // rst_i directly. However some registers {fetch.instAddr} load from io ports
  // or use "reset.asBool" to initialize state which infers synchronous resets.
  // This hybrid design allows for interfaces to reset immediately on reset
  // assertion while ensuring all internal state will eventually be reset
  // correctly before usage.
  val rst_i = (!rst_ni.asBool || ml_reset).asAsyncReset
  val rst_core = Wire(Bool())

  withClockAndReset(clk_i, rst_i) {
    val rst_q1 = RegInit(true.B)
    val rst_q2 = RegInit(true.B)
    rst_q1 := false.B
    rst_q2 := rst_q1
    rst_core := rst_q2
  }

  // ---------------------------------------------------------------------------
  // Connect clock and reset.
  withClockAndReset(clk_g, rst_core.asAsyncReset) {
    assert(p.vectorBits == 256)

    val core = kelvin.Core(p)
    val l1d = kelvin.L1DCache(p)
    val l1i = kelvin.L1ICache(p)
    val bus = Axi2Sram(p)

    // -------------------------------------------------------------------------
    // Control interface.
    finish   := core.io.halted
    host_req := false.B
    fault    := core.io.fault

    // -------------------------------------------------------------------------
    // Scalar Core logging.
    slog   := core.io.slog

    // -------------------------------------------------------------------------
    // L1Cache.
    l1d.io.dbus     <> core.io.dbus
    l1d.io.flush    <> core.io.dflush
    l1d.io.volt_sel := volt_sel

    l1i.io.ibus     <> core.io.ibus
    l1i.io.flush    <> core.io.iflush
    l1i.io.volt_sel := volt_sel

    // -------------------------------------------------------------------------
    // Bus Mux.
    bus.io.in0 <> core.io.axi0
    bus.io.in1 <> core.io.axi1
    bus.io.in2 <> l1d.io.axi
    bus.io.in3.read <> l1i.io.axi.read

    // -------------------------------------------------------------------------
    // SRAM bridge.
    mem.cvalid := bus.io.out.cvalid
    bus.io.out.cready := mem.cready
    mem.cwrite := bus.io.out.cwrite
    mem.caddr  := bus.io.out.caddr
    mem.cid    := bus.io.out.cid
    mem.wdata  := bus.io.out.wdata
    mem.wmask  := bus.io.out.wmask
    bus.io.out.rvalid := mem.rvalid
    bus.io.out.rid := mem.rid
    bus.io.out.rdata := mem.rdata

    // -------------------------------------------------------------------------
    // Command interface.
    for (i <- 0 until 12) {
      core.io.csr.in.value(i) := 0.U
    }

    core.io.csr.in.value(0) := pc_start
  }
}

object EmitKelvin extends App {
  val p = new kelvin.Parameters(Seq())
  ChiselStage.emitSystemVerilogFile(new Kelvin(p), args)
}
