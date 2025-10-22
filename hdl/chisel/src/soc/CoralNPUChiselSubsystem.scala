package coralnpu.soc

import chisel3._
import chisel3.util.MixedVec
import bus._
import coralnpu.Parameters
import coralnpu.CoreTlul

/**
 * This is the IO bundle for the unified Chisel subsystem.
 */
class CoralNPUChiselSubsystemIO(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean, val enableHighmem: Boolean) extends Bundle {
  val cfg = SoCChiselConfig(enableHighmem).crossbar

  // --- Clocks and Resets ---
  val clk_i = Input(Clock())
  val rst_ni = Input(AsyncReset())

  // --- Dynamic Asynchronous Clock/Reset Ports ---
  val asyncHostDomains = cfg.hosts(enableTestHarness).map(_.clockDomain).distinct.filter(_ != "main")
  val async_ports_hosts = new Bundle {
    val clocks = Input(Vec(asyncHostDomains.length, Clock()))
    val resets = Input(Vec(asyncHostDomains.length, AsyncReset()))
  }

  val asyncDeviceDomains = cfg.devices.map(_.clockDomain).distinct.filter(_ != "main")
  val async_ports_devices = new Bundle {
    val clocks = Input(Vec(asyncDeviceDomains.length, Clock()))
    val resets = Input(Vec(asyncDeviceDomains.length, AsyncReset()))
  }

  // --- Identify Internal vs. External Connections ---
  val internalHosts = SoCChiselConfig(enableHighmem).modules.flatMap(_.hostConnections.values).toSet
  val internalDevices = SoCChiselConfig(enableHighmem).modules.flatMap(_.deviceConnections.values).toSet

  // These devices are handled specially within the subsystem (e.g., converted to AXI)
  // and should not have external TileLink ports created for them.
  val speciallyHandledDevices = Set("ddr_ctrl", "ddr_mem")

  val externalHostPorts = cfg.hosts(enableTestHarness).filterNot(h => internalHosts.contains(h.name))
  val externalDevicePorts = cfg.devices.filterNot(d =>
    internalDevices.contains(d.name) || speciallyHandledDevices.contains(d.name)
  )

  // --- Create External TileLink Ports ---
  val external_hosts = Flipped(new Bundle {
    val ports = MixedVec(externalHostPorts.map { h =>
      new OpenTitanTileLink.Host2Device(hostParams(cfg.hosts(enableTestHarness).indexWhere(_.name == h.name)))
    })
  })

  val external_devices = new Bundle {
    val ports = MixedVec(externalDevicePorts.map { d =>
      new OpenTitanTileLink.Host2Device(deviceParams(cfg.devices.indexWhere(_.name == d.name)))
    })
  }

  // --- Manually define peripheral ports for now ---
  val allExternalPortsConfig = SoCChiselConfig(enableHighmem).modules.flatMap(_.externalPorts)
  val external_ports = MixedVec(allExternalPortsConfig.map { p =>
    val port = p.portType match {
      case coralnpu.soc.Clk  => Clock()
      case coralnpu.soc.Bool => Bool()
    }
    if (p.direction == coralnpu.soc.In) Input(port) else Output(port)
  })

  val p = new Parameters
  val ddrCtrlWidth = cfg.devices.find(_.name == "ddr_ctrl").get.width
  val ddrMemWidth = cfg.devices.find(_.name == "ddr_mem").get.width
  val ddr_ctrl_axi = new AxiMasterIO(32, ddrCtrlWidth, p.axi2IdBits)
  // We specify the 256-bit AXI width and 1-bit ID for DDR here.
  // The output from the Xbar is 128-bits / 6-bits, and we instantiate
  // width and TL->AXI bridges elsewhere to adapt the interfaces.
  val ddr_mem_axi = new AxiMasterIO(32, 256, 1)
}

import chisel3.experimental.BaseModule
import chisel3.reflect.DataMirror
import scala.collection.mutable

/**
 * A generator for the entire Chisel-based subsystem of the CoralNPU SoC.
 */
class CoralNPUChiselSubsystem(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean, val enableHighmem: Boolean) extends RawModule {
  val testHarnessSuffix = if (enableTestHarness) "TestHarness" else ""
  val highmemSuffix = if (enableHighmem) "Highmem" else ""
  override val desiredName = "CoralNPUChiselSubsystem" + testHarnessSuffix + highmemSuffix
  val io = IO(new CoralNPUChiselSubsystemIO(hostParams, deviceParams, enableTestHarness, enableHighmem))
  val cfg = SoCChiselConfig(enableHighmem).crossbar

  /**
   * A helper function to recursively traverse a Chisel Bundle and populate a
   * map with the full hierarchical path to every port and sub-port.
   */
  def populatePorts(prefix: String, data: Data, map: mutable.Map[String, Data]): Unit = {
    map(prefix) = data
    data match {
      case b: Record =>
        b.elements.foreach { case (name, child) =>
          populatePorts(s"$prefix.$name", child, map)
        }
      case v: Vec[_] =>
        v.zipWithIndex.foreach { case (child, i) =>
          populatePorts(s"$prefix($i)", child, map)
        }
      case _ => // Leaf element
    }
  }

  withClockAndReset(io.clk_i, (!io.rst_ni.asBool).asAsyncReset) {
    // --- Instantiate Core Chisel Components ---
    val xbar = Module(new CoralNPUXbar(hostParams, deviceParams, enableTestHarness, enableHighmem))

    // --- Dynamic Module Instantiation ---
    def instantiateModule(config: ChiselModuleConfig): BaseModule = {
      config.params match {
        case p: CoreTlulParameters =>
          val core_p = new Parameters
          core_p.m = p.memoryRegions
          core_p.lsuDataBits = p.lsuDataBits
          core_p.enableRvv = p.enableRvv
          core_p.enableFetchL0 = p.enableFetchL0
          core_p.fetchDataBits = p.fetchDataBits
          core_p.enableVector = p.enableVector
          core_p.enableFloat = p.enableFloat
          core_p.tcmHighmem = p.tcmHighmem
          Module(new CoreTlul(core_p, config.name))

        case p: Spi2TlulParameters =>
          val spi_p = new Parameters
          spi_p.lsuDataBits = p.lsuDataBits
          Module(new Spi2TLUL(spi_p))
      }
    }

    val instantiatedModules = SoCChiselConfig(enableHighmem).modules.map {
      config =>
      config.name -> instantiateModule(config)
    }.toMap

    // --- Dynamic Wiring ---
    val hostMap = cfg.hosts(enableTestHarness).map(_.name).zipWithIndex.toMap
    val deviceMap = cfg.devices.map(_.name).zipWithIndex.toMap
    val externalPortsMap = io.allExternalPortsConfig.map(_.name).zip(io.external_ports).toMap

    // Create a map of all ports on all instantiated modules for easy lookup.
    val modulePorts = mutable.Map[String, Data]()
    instantiatedModules.foreach { case (moduleName, module) =>
      DataMirror.modulePorts(module).foreach { case (portName, port) =>
        populatePorts(s"$moduleName.$portName", port, modulePorts)
      }
    }

    // --- Clock & Reset Connections ---
    instantiatedModules.foreach { case (name, module) =>
      modulePorts.get(s"$name.io.clk").foreach(_ := io.clk_i)
      modulePorts.get(s"$name.io.clock").foreach(_ := io.clk_i)
      modulePorts.get(s"$name.io.rst_ni").foreach(_ := io.rst_ni)
      modulePorts.get(s"$name.io.reset").foreach(_ := (!io.rst_ni.asBool).asAsyncReset)
    }

    // Connect all modules based on the configuration.
    SoCChiselConfig(enableHighmem).modules.foreach {
      config =>
      config.hostConnections.foreach { case (modulePort, xbarPort) =>
        modulePorts(s"${config.name}.$modulePort") <> xbar.io.hosts(hostMap(xbarPort))
      }
      config.deviceConnections.foreach { case (modulePort, xbarPort) =>
        xbar.io.devices(deviceMap(xbarPort)) <> modulePorts(s"${config.name}.$modulePort")
      }
      config.externalPorts.foreach {
        extPort =>
        val moduleIo = modulePorts(s"${config.name}.${extPort.modulePort}")
        val topIo = externalPortsMap(extPort.name)
        if (extPort.direction == In) moduleIo := topIo else topIo := moduleIo
      }
    }

    // Connect external-facing TileLink ports
    io.externalHostPorts.map(_.name).zip(io.external_hosts.ports).foreach { case (name, port) =>
      xbar.io.hosts(hostMap(name)) <> port
    }
    io.externalDevicePorts.map(_.name).zip(io.external_devices.ports).foreach { case (name, port) =>
      port <> xbar.io.devices(deviceMap(name))
    }

    // Connect async clocks
    val asyncHostDomainMap = io.asyncHostDomains.zipWithIndex.toMap
    asyncHostDomainMap.foreach {
      case (domainName, index) =>
      val xbarPort = xbar.io.async_ports_hosts
      val ioPort = io.async_ports_hosts
      if (index < xbarPort.length) {
        xbarPort(index).clock := ioPort.clocks(index)
        xbarPort(index).reset := ioPort.resets(index)
      }
    }

    val asyncDeviceDomainMap = io.asyncDeviceDomains.zipWithIndex.toMap
    asyncDeviceDomainMap.foreach {
      case (domainName, index) =>
      val xbarPort = xbar.io.async_ports_devices
      val ioPort = io.async_ports_devices
      if (index < xbarPort.length) {
        xbarPort(index).clock := ioPort.clocks(index)
        xbarPort(index).reset := ioPort.resets(index)
      }
    }

    // --- DDR AXI Interface ---
    val ddrDomain = asyncDeviceDomainMap("ddr")
    val ddr_clk = io.async_ports_devices.clocks(ddrDomain)
    val ddr_rst = io.async_ports_devices.resets(ddrDomain)

    val ddr_ctrl_tlul_p = deviceParams(deviceMap("ddr_ctrl"))
    val ddr_ctrl_tl_p = new Parameters
    ddr_ctrl_tl_p.lsuDataBits = ddr_ctrl_tlul_p.w * 8
    val ddr_ctrl_axi_p = new Parameters
    ddr_ctrl_axi_p.lsuDataBits = ddr_ctrl_tlul_p.w * 8
    val ddr_ctrl_axi_conv = Module(new TLUL2Axi(ddr_ctrl_tl_p, ddr_ctrl_axi_p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User))
    ddr_ctrl_axi_conv.clock := ddr_clk
    ddr_ctrl_axi_conv.reset := ddr_rst
    ddr_ctrl_axi_conv.io.tl_a <> xbar.io.devices(deviceMap("ddr_ctrl")).a
    ddr_ctrl_axi_conv.io.tl_d <> xbar.io.devices(deviceMap("ddr_ctrl")).d
    io.ddr_ctrl_axi <> ddr_ctrl_axi_conv.io.axi

    // --- DDR Memory AXI Interface (128-bit TL -> 256-bit TL -> 256-bit AXI) ---
    // Define parameters for the 256-bit bus that exists AFTER the width bridge.
    val ddr_mem_256_coralnpu_p = {
      val p = new Parameters
      p.lsuDataBits = 256
      p
    }
    val ddr_mem_256_tlul_p = new bus.TLULParameters(ddr_mem_256_coralnpu_p)

    // Define parameters for the final 256-bit AXI port.
    val ddr_mem_axi_p = {
      val p = new Parameters
      p.lsuDataBits = 256
      p.axi2IdBits = 1
      p
    }

    // Instantiate the bridge: 128-bit (from xbar) to 256-bit.
    val ddr_mem_bridge = Module(new TlulWidthBridge(xbar.commonParams, ddr_mem_256_tlul_p))

    // Instantiate the AXI converter: 256-bit TL to 256-bit AXI.
    val ddr_mem_axi_conv = Module(new TLUL2Axi(ddr_mem_256_coralnpu_p, ddr_mem_axi_p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User))

    ddr_mem_bridge.clock := ddr_clk
    ddr_mem_bridge.reset := ddr_rst
    ddr_mem_axi_conv.clock := ddr_clk
    ddr_mem_axi_conv.reset := ddr_rst

    // Wire the components together: Xbar (128) -> Bridge -> AXI Conv (256) -> IO (256)
    ddr_mem_bridge.io.tl_h <> xbar.io.devices(deviceMap("ddr_mem"))
    ddr_mem_axi_conv.io.tl_a <> ddr_mem_bridge.io.tl_d.a
    ddr_mem_bridge.io.tl_d.d <> ddr_mem_axi_conv.io.tl_d
    io.ddr_mem_axi <> ddr_mem_axi_conv.io.axi
  }
}

import _root_.circt.stage.ChiselStage
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths, StandardOpenOption}

object CoralNPUChiselSubsystemEmitter extends App {
  val enableTestHarness = args.contains("--enableTestHarness")
  val enableHighmem = args.contains("--enableHighmem")
  val chiselArgs = args.filterNot(a =>
      a.startsWith("--enableTestHarness") ||
      a.startsWith("--enableHighmem") ||
      a.startsWith("--target-dir="))

  val hostParams = SoCChiselConfig(enableHighmem).crossbar.hosts(enableTestHarness).map {
    host =>
    val p = new Parameters
    p.lsuDataBits = host.width
    new bus.TLULParameters(p)
  }
  val deviceParams = SoCChiselConfig(enableHighmem).crossbar.devices.map {
    device =>
    val p = new Parameters
    p.lsuDataBits = device.width
    new bus.TLULParameters(p)
  }

  // Manually parse arguments to find the target directory.
  var targetDir: Option[String] = None
  args.foreach {
    case s if s.startsWith("--target-dir=") => targetDir = Some(s.stripPrefix("--target-dir="))
    case "--enableTestHarness" => // Already handled by filterNot
    case _ => // Ignore other arguments
  }

  // The subsystem module must be created in the ChiselStage context.
  lazy val subsystem = new CoralNPUChiselSubsystem(hostParams, deviceParams, enableTestHarness, enableHighmem)

  val firtoolOpts = Array(
      // Disable `automatic logic =`, Suppress location comments
      "--lowering-options=disallowLocalVariables,locationInfoStyle=none",
      "-enable-layers=Verification",
  )
  val systemVerilogSource = ChiselStage.emitSystemVerilog(
    subsystem, chiselArgs.toArray, firtoolOpts)

  // CIRCT adds extra data to the end of the file. Remove it.
  val resourcesSeparator =
      "// ----- 8< ----- FILE \"firrtl_black_box_resource_files.f\" ----- 8< -----"
  val strippedVerilogSource = systemVerilogSource.split(resourcesSeparator)(0)

  // Write the stripped Verilog to the target directory.
  targetDir.foreach {
    dir =>
      Files.write(
        Paths.get(dir, subsystem.name + ".sv"),
        strippedVerilogSource.getBytes(StandardCharsets.UTF_8),
        StandardOpenOption.CREATE,
        StandardOpenOption.TRUNCATE_EXISTING)
  }
}

