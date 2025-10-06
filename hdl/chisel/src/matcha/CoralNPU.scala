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

import bus.CoralNPUMemIO
import java.nio.file.{Paths, Files, StandardOpenOption}
import java.nio.charset.{StandardCharsets}
import _root_.circt.stage.{ChiselStage}

object CoralNPU {
  def apply(p: coralnpu.Parameters): CoralNPU = {
    return Module(new CoralNPU(p, moduleName = "CoralNPU"))
  }
}

class CoralNPU(p: coralnpu.Parameters, moduleName: String) extends RawModule {
  override val desiredName = moduleName
  // IO ports. (RawModule removes default[clock, reset])
  val clk_i  = IO(Input(Clock()))
  val rst_ni = IO(Input(AsyncReset()))

  val mem = IO(new CoralNPUMemIO(p))

  val clk_freeze = IO(Input(Bool()))
  val ml_reset   = IO(Input(Bool()))
  val pc_start   = IO(Input(UInt(32.W)))
  val volt_sel   = IO(Input(Bool()))
  val debug_req  = IO(Input(Bool()))

  val finish   = IO(Output(Bool()))
  val host_req = IO(Output(Bool()))
  val fault    = IO(Output(Bool()))

  val slog = IO(new coralnpu.SLogIO(p))

  // ---------------------------------------------------------------------------
  // Gated Clock.
  val cg = Module(new coralnpu.ClockGate)
  cg.io.clk_i  := clk_i
  cg.io.enable := !clk_freeze
  cg.io.te := false.B
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

    val core = coralnpu.Core(p)
    val l1d = coralnpu.L1DCache(p)
    val l1i = coralnpu.L1ICache(p)
    val bus = Axi2Sram(p)

    // -------------------------------------------------------------------------
    // Control interface.
    finish   := core.io.halted
    host_req := false.B
    fault    := core.io.fault
    core.io.irq := false.B

    // -------------------------------------------------------------------------
    // Scalar Core logging.
    slog   := core.io.slog

    // -------------------------------------------------------------------------
    // Debug Interface.
    core.io.debug_req   := debug_req

    // -------------------------------------------------------------------------
    // L1Cache.
    l1d.io.dbus     <> core.io.dbus
    l1d.io.flush    <> core.io.dflush
    l1d.io.volt_sel := volt_sel

    l1i.io.ibus     <> core.io.ibus
    l1i.io.flush    <> core.io.iflush
    l1i.io.volt_sel := volt_sel

    // core.io.ebus <> 0.U.asTypeOf(core.io.ebus)
    core.io.ebus.dbus.ready := false.B
    core.io.ebus.dbus.rdata := 0.U.asTypeOf(core.io.ebus.dbus.rdata)
    core.io.ebus.fault.valid := false.B
    core.io.ebus.fault.bits := 0.U.asTypeOf(core.io.ebus.fault.bits)

    // -------------------------------------------------------------------------
    // Bus Mux.
    bus.io.l1d <> l1d.io.axi
    bus.io.l1i.read <> l1i.io.axi.read

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
    for (i <- 0 until p.csrInCount) {
      core.io.csr.in.value(i) := 0.U
    }

    core.io.csr.in.value(0) := pc_start
  }
}

object EmitCoralNPU extends App {
  val p = new coralnpu.MatchaParameters
  val core_p = new coralnpu.Parameters
  var moduleName = "CoralNPU"
  var chiselArgs = List[String]()
  var targetDir: Option[String] = None
  for (arg <- args) {
    if (arg.startsWith("--enableFetchL0")) {
      val argval = arg.split("=")(1).toBoolean
      p.enableFetchL0 = argval
      core_p.enableFetchL0 = argval
    } else if (arg.startsWith("--moduleName")) {
      moduleName = arg.split("=")(1)
    } else if (arg.startsWith("--enableVector")) {
      val argval = arg.split("=")(1).toBoolean
      p.enableVector = argval
      core_p.enableVector = argval
    } else if (arg.startsWith("--fetchDataBits")) {
      val argval = arg.split("=")(1).toInt
      p.fetchDataBits = argval
      core_p.fetchDataBits = argval
    } else if (arg.startsWith("--lsuDataBits")) {
      val argval = arg.split("=")(1).toInt
      p.lsuDataBits = argval
      core_p.lsuDataBits = argval
    } else if (arg.startsWith("--target-dir")) {
      targetDir = Some(arg.split("=")(1))
    } else {
      chiselArgs = chiselArgs :+ arg
    }
  }
  // The core module must be created in the ChiselStage context. Use lazy here
  // so it's created in ChiselStage, but referencable afterwards.
  lazy val core = new CoralNPU(p, moduleName)
  val firtoolOpts = Array(
      "-enable-layers=Verification",
  )
  val systemVerilogSource = ChiselStage.emitSystemVerilog(
    core, chiselArgs.toArray, firtoolOpts)
  // CIRCT adds a little extra data to the sv file at the end. Remove it as we
  // don't want it (it prevents the sv from being verilated).
  val resourcesSeparator =
      "// ----- 8< ----- FILE \"firrtl_black_box_resource_files.f\" ----- 8< -----"
  val strippedVerilogSource = systemVerilogSource.split(resourcesSeparator)(0)


  val header_str = coralnpu.EmitParametersHeader(core_p)
  targetDir match {
    case Some(targetDir) => {
      Files.write(
          Paths.get(targetDir + "/V" + moduleName + "_parameters.h"),
          header_str.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)
      Files.write(
          Paths.get(targetDir + "/" + core.name + ".sv"),
          strippedVerilogSource.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)
      ()
    }
    case None => ()
  }
}
