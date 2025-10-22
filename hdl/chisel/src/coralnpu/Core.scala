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

package coralnpu

import chisel3._

import java.io.{File, FileOutputStream}
import java.util.zip._
import java.nio.file.{Paths, Files, StandardOpenOption}
import java.nio.charset.{StandardCharsets}
import coralnpu.rvv.{RvvCore}
import _root_.circt.stage.ChiselStage
import scala.collection.mutable.Stack

object Core {
  def apply(p: Parameters): Core = {
    return Module(new Core(p, "Core"))
  }
  def apply(p: Parameters, moduleName: String): Core = {
    return Module(new Core(p, moduleName))
  }
}

class Core(p: Parameters, moduleName: String) extends Module with RequireAsyncReset {
  override val desiredName = moduleName
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())
    val wfi = Output(Bool())
    val irq = Input(Bool())
    val debug_req = Input(Bool())
    val dm = Option.when(p.useDebugModule)(new CoreDMIO(p))

    // Bus between core and instruction memories.
    val ibus = new IBusIO(p)
    // Bus between core and data memories.
    val dbus = new DBusIO(p)
    // Bus between core and and external memories or peripherals.
    val ebus = new EBusIO(p)

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  val score = SCore(p)
  val vcore = Option.when(p.enableVector)(VCore(p))
  val rvvCore = Option.when(p.enableRvv)(RvvCore(p))
  if (p.enableRvv) {
    rvvCore.get.io <> score.io.rvvcore.get
  }

  // ---------------------------------------------------------------------------
  // Scalar Core outputs.
  io.csr    <> score.io.csr
  io.ibus   <> score.io.ibus
  io.ebus   <> score.io.ebus
  io.halted := score.io.halted
  io.fault  := score.io.fault
  io.wfi    := score.io.wfi
  score.io.irq := io.irq

  if (p.useDebugModule) {
    score.io.dm.get <> io.dm.get
  }

  io.iflush <> score.io.iflush
  io.dflush <> score.io.dflush
  io.slog   := score.io.slog
  io.debug  <> score.io.debug

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
}

object EmitCore extends App {
  val p = new Parameters
  var moduleName = "Core"
  var chiselArgs = List[String]()
  var targetDir: Option[String] = None
  var useAxi = false
  var useTlul = false
  for (arg <- args) {
    if (arg.startsWith("--enableFetchL0")) {
      p.enableFetchL0 = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--moduleName")) {
      moduleName = arg.split("=")(1)
    } else if (arg.startsWith("--fetchDataBits")) {
      p.fetchDataBits = arg.split("=")(1).toInt
    } else if (arg.startsWith("--enableVector")) {
      p.enableVector = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--enableRvv")) {
      p.enableRvv = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--enableFloat")) {
      p.enableFloat = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--enableVerification")) {
      p.enableVerification = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--enableDebug")) {
      p.enableDebug = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--enableDispatchV2")) {
      p.enableDispatchV2 = arg.split("=")(1).toBoolean
    } else if (arg.startsWith("--lsuDataBits")) {
      p.lsuDataBits = arg.split("=")(1).toInt
    } else if (arg.startsWith("--tcmHighmem")) {
      p.tcmHighmem = true
    } else if (arg.startsWith("--useAxi")) {
      useAxi = true
    } else if (arg.startsWith("--useTlul")) {
      useTlul = true
    } else if (arg.startsWith("--target-dir")) {
      targetDir = Some(arg.split("=")(1))
    } else {
      chiselArgs = chiselArgs :+ arg
    }
  }
  assert(!(useAxi && useTlul))

  val memoryRegions = if (p.tcmHighmem) { MemoryRegions.tcmHighmem } else { MemoryRegions.default }
  // The core module must be created in the ChiselStage context. Use lazy here
  // so it's created in ChiselStage, but referencable afterwards.
  lazy val core = if (useAxi) {
    p.m = memoryRegions
    new CoreAxi(p, moduleName)
  } else if (useTlul) {
    p.m = memoryRegions
    new CoreTlul(p, moduleName)
  } else {
    // "Matcha" memory layout
    p.m = Seq(
      new MemoryRegion(0x0, 0x400000, MemoryRegionType.DMEM),
    )
    new Core(p, moduleName)
  }

  val firtoolOpts = Array(
      // Disable `automatic logic =`, Suppress location comments
      "--lowering-options=disallowLocalVariables,locationInfoStyle=none",
      "-enable-layers=Verification",
  )
  val systemVerilogSource = ChiselStage.emitSystemVerilog(
    core, chiselArgs.toArray, firtoolOpts)
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
                "--split-verilog", "--target-dir", targetDir), firtoolOpts)
        val zip = new ZipOutputStream(new FileOutputStream(
            targetDir + "/" + coreName + ".zip"))
        val dirStack = new Stack[File](1)
        dirStack.push(new File(targetDir))
        println(s"target: ${targetDir}")
        while (!dirStack.isEmpty) {
          val dir = dirStack.pop()
          val files = dir.listFiles
          files.foreach { name =>
            if (name.isDirectory()) {
              dirStack.push(name)
            } else {
              val zipName = name.getPath().replace(targetDir + "/", "")
              zip.putNextEntry(new ZipEntry(zipName))
              zip.write(Files.readAllBytes(Paths.get(name.getPath())))
              zip.closeEntry()
            }
          }
        }
        zip.close()
      }

      Files.write(
          Paths.get(targetDir + "/V" + core.name + "_parameters.h"),
          header_str.getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)
      Files.write(
          Paths.get(targetDir + "/" + core.name + ".sv"),
          strippedVerilogSource.replace("exclude_file", "exclude_module").getBytes(StandardCharsets.UTF_8),
          StandardOpenOption.CREATE)

      ()
    }
    case None => ()
  }
}
