package kelvin.soc

import chisel3._
import chisel3.util.MixedVec
import bus._
import kelvin.Parameters
import kelvin.CoreTlul

/**
 * This is the IO bundle for the unified Chisel subsystem.
 */
class KelvinChiselSubsystemIO(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean) extends Bundle {
  val cfg = SoCChiselConfig.crossbar

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
  val internalHosts = SoCChiselConfig.modules.flatMap(_.hostConnections.values).toSet
  val internalDevices = SoCChiselConfig.modules.flatMap(_.deviceConnections.values).toSet

  val externalHostPorts = cfg.hosts(enableTestHarness).filterNot(h => internalHosts.contains(h.name))
  val externalDevicePorts = cfg.devices.filterNot(d => internalDevices.contains(d.name))

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
  val allExternalPortsConfig = SoCChiselConfig.modules.flatMap(_.externalPorts)
  val external_ports = MixedVec(allExternalPortsConfig.map { p =>
    val port = p.portType match {
      case kelvin.soc.Clk  => Clock()
      case kelvin.soc.Bool => Bool()
    }
    if (p.direction == kelvin.soc.In) Input(port) else Output(port)
  })
}

import chisel3.experimental.BaseModule
import chisel3.reflect.DataMirror
import scala.collection.mutable

/**
 * A generator for the entire Chisel-based subsystem of the Kelvin SoC.
 */
class KelvinChiselSubsystem(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean) extends RawModule {
  override val desiredName = if (enableTestHarness) "KelvinChiselSubsystemTestHarness" else "KelvinChiselSubsystem"
  val io = IO(new KelvinChiselSubsystemIO(hostParams, deviceParams, enableTestHarness))
  val cfg = SoCChiselConfig.crossbar

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
    val xbar = Module(new KelvinXbar(hostParams, deviceParams, enableTestHarness))

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
          Module(new CoreTlul(core_p, config.name))

        case p: Spi2TlulParameters =>
          val spi_p = new Parameters
          spi_p.lsuDataBits = p.lsuDataBits
          Module(new Spi2TLUL(spi_p))
      }
    }

    val instantiatedModules = SoCChiselConfig.modules.map {
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
    xbar.io.clk_i := io.clk_i
    xbar.io.rst_ni := io.rst_ni
    instantiatedModules.foreach { case (name, module) =>
      modulePorts.get(s"$name.io.clk").foreach(_ := io.clk_i)
      modulePorts.get(s"$name.io.clock").foreach(_ := io.clk_i)
      modulePorts.get(s"$name.io.rst_ni").foreach(_ := io.rst_ni)
      modulePorts.get(s"$name.io.reset").foreach(_ := io.rst_ni)
    }

    // Connect all modules based on the configuration.
    SoCChiselConfig.modules.foreach {
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
  }
}

import _root_.circt.stage.ChiselStage
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths, StandardOpenOption}

object KelvinChiselSubsystemEmitter extends App {
  val enableTestHarness = args.contains("--enableTestHarness")
  val chiselArgs = args.filterNot(a => a.startsWith("--enableTestHarness") || a.startsWith("--target-dir="))

  val hostParams = SoCChiselConfig.crossbar.hosts(enableTestHarness).map {
    host =>
    val p = new Parameters
    p.lsuDataBits = host.width
    new bus.TLULParameters(p)
  }
  val deviceParams = SoCChiselConfig.crossbar.devices.map {
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
  lazy val subsystem = new KelvinChiselSubsystem(hostParams, deviceParams, enableTestHarness)

  val firtoolOpts = Array("-enable-layers=Verification")
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

