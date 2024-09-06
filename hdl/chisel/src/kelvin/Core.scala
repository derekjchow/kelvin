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

package kelvin

import chisel3._
import chisel3.util._

import bus.AxiMasterIO
import common._
import java.io.{File, FileOutputStream}
import java.util.zip._
import java.nio.file.{Paths, Files, StandardOpenOption}
import java.nio.charset.{StandardCharsets}
import _root_.circt.stage.ChiselStage

object Core {
  def apply(p: Parameters): Core = {
    return Module(new Core(p, "Core"))
  }
  def apply(p: Parameters, moduleName: String): Core = {
    return Module(new Core(p, moduleName))
  }
}

class Core(p: Parameters, moduleName: String) extends Module with RequireSyncReset {
  override val desiredName = moduleName
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())
    val debug_req = Input(Bool())

    // Bus between core and instruction memories.
    val ibus = new IBusIO(p)
    // Bus between core and data memories.
    val dbus = new DBusIO(p)
    // Bus between core and and external memories or peripherals.
    val ebus = new DBusIO(p)

    val axi0 = if (p.enableVector) {
      Some(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    } else { None }
    val axi1 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  val score = SCore(p)
  val vcore = if (p.enableVector) { Some(VCore(p)) } else { None }

  // ---------------------------------------------------------------------------
  // Scalar Core outputs.
  io.csr    <> score.io.csr
  io.ibus   <> score.io.ibus
  io.ebus   <> score.io.ebus
  io.halted := score.io.halted
  io.fault  := score.io.fault
  io.iflush <> score.io.iflush
  io.dflush <> score.io.dflush
  io.slog   := score.io.slog
  io.debug  := score.io.debug

  // ---------------------------------------------------------------------------
  // Vector core.
  if (p.enableVector) {
    score.io.vcore.get <> vcore.get.io.score
  }

  // ---------------------------------------------------------------------------
  // Local Data Bus Port
  if (p.enableVector) {
    val dbusmux = DBusMux(p)
    dbusmux.io.vldst := score.io.vldst.get
    dbusmux.io.vlast := vcore.get.io.last
    dbusmux.io.vcore <> vcore.get.io.dbus
    dbusmux.io.score <> score.io.dbus
    io.dbus <> dbusmux.io.dbus
  } else {
    io.dbus <> score.io.dbus
  }

  // ---------------------------------------------------------------------------
  // Scalar DBus to AXI.
  val dbus2axi = DBus2Axi(p)
  dbus2axi.io.dbus <> score.io.ubus

  // ---------------------------------------------------------------------------
  // AXI ports.
  if (p.enableVector) {
    io.axi0.get.read  <> vcore.get.io.ld
    io.axi0.get.write <> vcore.get.io.st
  }

  io.axi1 <> dbus2axi.io.axi
}

object EmitCore extends App {
  val p = new Parameters
  var moduleName = "Core"
  var chiselArgs = List[String]()
  var targetDir: Option[String] = None
  var useAxi = false
  for (arg <- args) {
    if (arg.startsWith("--enableFetchL0")) {
      p.enableFetchL0 = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--moduleName")) {
      moduleName = arg.split("=")(1)
    } else if (arg.startsWith("--fetchDataBits")) {
      p.fetchDataBits = arg.split("=")(1).toInt
    } else if (arg.startsWith("--enableVector")) {
      p.enableVector = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--lsuDataBits")) {
      p.lsuDataBits = arg.split("=")(1).toInt
    } else if (arg.startsWith("--useAxi")) {
      useAxi = true
    } else if (arg.startsWith("--target-dir")) {
      targetDir = Some(arg.split("=")(1))
    } else {
      chiselArgs = chiselArgs :+ arg
    }
  }

  // The core module must be created in the ChiselStage context. Use lazy here
  // so it's created in ChiselStage, but referencable afterwards.
  lazy val core = if (useAxi) {
    new CoreAxi(p, moduleName)
  } else {
    new Core(p, moduleName)
  }

  val systemVerilogSource = ChiselStage.emitSystemVerilog(
    core, chiselArgs.toArray)
  // CIRCT adds a little extra data to the sv file at the end. Remove it as we
  // don't want it (it prevents the sv from being verilated).
  val resourcesSeparator =
      "// ----- 8< ----- FILE \"firrtl_black_box_resource_files.f\" ----- 8< -----"
  val strippedVerilogSource = systemVerilogSource.split(resourcesSeparator)(0)
  val coreName = core.name

  val header_str = EmitParametersHeader(p)

  targetDir match {
    case Some(targetDir) => {
      {
        lazy val core2 = if (useAxi) {
          new CoreAxi(p, moduleName)
        } else {
          new Core(p, moduleName)
        }

        ChiselStage.emitSystemVerilogFile(
            core2, chiselArgs.toArray ++ Array(
                "--split-verilog", "--target-dir", targetDir))
        val files = (new File(targetDir)).listFiles
        val zip = new ZipOutputStream(new FileOutputStream(
            targetDir + "/" + coreName + ".zip"))
        files.foreach { name =>
          zip.putNextEntry(new ZipEntry(name.getName()))
          Files.copy(Paths.get(name.getPath), zip)
          zip.closeEntry()
        }
        zip.close()
      }

      var headerRet = Files.write(
          Paths.get(targetDir + "/V" + core.name + "_parameters.h"),
          header_str.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)
      var svRet = Files.write(
          Paths.get(targetDir + "/" + core.name + ".sv"),
          strippedVerilogSource.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)

      ()
    }
    case None => ()
  }
}
