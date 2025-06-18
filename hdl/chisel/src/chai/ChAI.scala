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

package chai

import chisel3._
import chisel3.util._

import bus._
import java.nio.file.{Paths, Files, StandardOpenOption}
import java.nio.charset.{StandardCharsets}
import _root_.circt.stage.{ChiselStage}

case class Parameters() {
  val sramReadPorts = 1
  val sramWritePorts = 1
  val sramReadWritePorts = 0
  val sramDataBits = 256
  val sramBytes = 4 * 1024 * 1024
  def sramDataEntries(): Int = {
    ((sramBytes * 8) / sramDataBits)
  }
  def sramAddrBits(): Int = {
    log2Ceil(sramDataEntries())
  }
}

object ChAI {
  def apply(p: Parameters): ChAI = {
    return Module(new ChAI(p))
  }
}

class ChAI(p: Parameters) extends RawModule {
  val io = IO(new Bundle {
    val clk_i = Input(Clock())
    val rst_ni = Input(AsyncReset())
    val sram = new Bundle {
      val write_address = Input(UInt(p.sramAddrBits().W))
      val write_enable = Input(Bool())
      val write_data = Input(UInt(p.sramDataBits.W))
    }
    val finish = Output(Bool())
    val fault = Output(Bool())
    val freeze = Input(Bool())

    val uart_rx = Input(Bool())
    val uart_tx = Output(Bool())
  })

  // TODO(atv): Compute that we don't have any overlaps in regions.
  val memoryRegions = Seq(
    new kelvin.MemoryRegion(0, 4 * 1024 * 1024, kelvin.MemoryRegionType.DMEM), // SRAM
    new kelvin.MemoryRegion(4 * 1024 * 1024, 4 * 1024 * 1024, kelvin.MemoryRegionType.Peripheral) // UART
  )
  val kelvin_p = kelvin.Parameters(memoryRegions)
  val rst_i = (!io.rst_ni.asBool).asAsyncReset

  val u_kelvin = matcha.Kelvin(kelvin_p)
  u_kelvin.clk_i := io.clk_i
  u_kelvin.rst_ni := io.rst_ni
  u_kelvin.clk_freeze := io.freeze
  u_kelvin.ml_reset := 0.U
  u_kelvin.pc_start := 0.U
  u_kelvin.volt_sel := 0.U
  u_kelvin.debug_req := 0.U

  io.finish := u_kelvin.finish
  io.fault := u_kelvin.fault

  withClockAndReset(io.clk_i, rst_i) {
    val tlul_p = new TLULParameters()
    val kelvin_to_tlul = KelvinToTlul(tlul_p, kelvin_p)
    kelvin_to_tlul.io.kelvin <> u_kelvin.mem

    val tlul_sram =
      SRAM(p.sramDataEntries(), UInt(p.sramDataBits.W), p.sramReadPorts, p.sramWritePorts, p.sramReadWritePorts)
    val tlul_adapter_sram = Module(new chai.TlulAdapterSram())
    tlul_adapter_sram.io.clk_i := io.clk_i
    tlul_adapter_sram.io.rst_ni := io.rst_ni
    tlul_adapter_sram.io.en_ifetch_i := 9.U // MuBi4False
    tlul_sram.readPorts(0).enable := tlul_adapter_sram.io.req_o
    tlul_sram.readPorts(0).address := tlul_adapter_sram.io.addr_o
    tlul_sram.writePorts(0).enable := Mux(io.freeze, io.sram.write_enable, tlul_adapter_sram.io.we_o)
    tlul_sram.writePorts(0).address := Mux(io.freeze, io.sram.write_address, tlul_adapter_sram.io.addr_o)
    tlul_sram.writePorts(0).data := Mux(io.freeze, io.sram.write_data, tlul_adapter_sram.io.wdata_o)
    tlul_adapter_sram.io.gnt_i := 1.U
    tlul_adapter_sram.io.rdata_i := tlul_sram.readPorts(0).data
    tlul_adapter_sram.io.rvalid_i := 1.U
    tlul_adapter_sram.io.rerror_i := 0.U

    val uart = Module(new chai.Uart(tlul_p))
    uart.io.clk_i := io.clk_i
    uart.io.rst_ni := io.rst_ni
    uart.io.alert_rx_i := 0.U
    uart.io.cio_rx_i := io.uart_rx
    io.uart_tx := uart.io.cio_tx_o

    val crossbar =
      Module(new TileLinkUL(tlul_p, kelvin_p.m, /* hosts= */ 1))
    crossbar.io.hosts_a(0) <> kelvin_to_tlul.io.tl_o
    crossbar.io.hosts_d(0) <> kelvin_to_tlul.io.tl_i
    crossbar.io.devices_a(0) <> tlul_adapter_sram.io.tl_i
    crossbar.io.devices_d(0) <> tlul_adapter_sram.io.tl_o
    crossbar.io.devices_a(1) <> uart.io.tl_i
    crossbar.io.devices_d(1) <> uart.io.tl_o
  }
}

object EmitChAI extends App {
  val p = new Parameters()
  var chiselArgs = List[String]()
  var targetDir: Option[String] = None
  for (arg <- args) {
    if (arg.startsWith("--target-dir")) {
      targetDir = Some(arg.split("=")(1))
    } else {
      chiselArgs = chiselArgs :+ arg
    }
  }

  lazy val core = new ChAI(p)
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

  targetDir match {
    case Some(targetDir) => {
      Files.write(
          Paths.get(targetDir + "/" + core.name + ".sv"),
          strippedVerilogSource.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)
      ()
    }
    case None => ()
  }
}
