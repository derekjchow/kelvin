// Copyright 2025 Google LLC
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

package kelvin.soc

import chisel3._
import chisel3.util.{MixedVec, MuxCase}
import bus._
import bus.TlulWidthBridge

/**
 * A dynamically generated IO bundle for the KelvinXbar.
 *
 * This bundle's ports are derived from the CrossbarConfig object. It automatically
 * creates clock and reset ports for any asynchronous domains defined in the config.
 *
 * @param hostParams A sequence of TileLink parameters, one for each host.
 * @param deviceParams A sequence of TileLink parameters, one for each device.
 */
class KelvinXbarIO(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean) extends Bundle {
  val cfg = CrossbarConfig

  // --- Primary Clock and Reset ---
  val clk_i = Input(Clock())
  val rst_ni = Input(AsyncReset()) // Use AsyncReset for concrete reset type

  // --- Host (Master) Ports ---
  val hosts = Flipped(MixedVec(hostParams.map(p => new OpenTitanTileLink.Host2Device(p))))

  // --- Device (Slave) Ports ---
  val devices = MixedVec(deviceParams.map(p => new OpenTitanTileLink.Host2Device(p)))

  // --- Dynamic Asynchronous Clock/Reset Ports ---
  // Find all unique clock domains from the config, excluding the main one.
  val asyncDeviceDomains = cfg.devices.map(_.clockDomain).distinct.filter(_ != "main")
  val asyncHostDomains = cfg.hosts(enableTestHarness).map(_.clockDomain).distinct.filter(_ != "main")

  // Create a Vec of Bundles for clock and reset inputs for each async domain.
  val async_ports_devices = Input(Vec(asyncDeviceDomains.length, new Bundle {
    val clock = Clock()
    val reset = AsyncReset()
  }))

  val async_ports_hosts = Input(Vec(asyncHostDomains.length, new Bundle {
    val clock = Clock()
    val reset = AsyncReset()
  }))
}

/**
 * A data-driven TileLink crossbar generator for the Kelvin SoC.
 *
 * This RawModule constructs a crossbar by interpreting the CrossbarConfig object.
 * This gives explicit control over clock and reset signals, which is critical
 * for a multi-domain design.
 *
 * @param p The TileLink UL parameters for the bus.
 */
class KelvinXbar(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean) extends RawModule {
  override val desiredName = if (enableTestHarness) "KelvinXbarTestHarness" else "KelvinXbar"
  // Load the single source of truth for the crossbar configuration.
  val cfg = CrossbarConfig

  // Create simple maps from name to index for easy port access.
  val hostMap = cfg.hosts(enableTestHarness).map(_.name).zipWithIndex.toMap
  val deviceMap = cfg.devices.map(_.name).zipWithIndex.toMap

  // Instantiate the dynamically generated IO bundle.
  val io = IO(new KelvinXbarIO(hostParams, deviceParams, enableTestHarness))

  // Find all unique clock domains from the config, excluding the main one.
  val asyncDeviceDomains = cfg.devices.map(_.clockDomain).distinct.filter(_ != "main")
  val asyncHostDomains = cfg.hosts(enableTestHarness).map(_.clockDomain).distinct.filter(_ != "main")

  // --- 1. Graph Analysis ---
  // Analyze the configuration to understand the connection topology. This will be
  // used to determine the size of sockets and how to wire them up.
  val hostConnections = cfg.connections(enableTestHarness)
  val deviceFanIn = cfg.devices.map { device =>
    device.name -> cfg.hosts(enableTestHarness).filter(h => hostConnections(h.name).contains(device.name))
  }.toMap

  // --- 2. Programmatic Instantiation (within the main clock domain) ---
  // We use withClockAndReset to provide the explicit clock and reset signals
  // required by the child modules, as KelvinXbar itself is a RawModule.
  // The top-level reset is active-low, so we invert it for the active-high
  // modules instantiated within this block.
  val (hostSockets, deviceSockets, asyncDeviceFifos, asyncHostFifos, widthBridges) = withClockAndReset(io.clk_i, (!io.rst_ni.asBool).asAsyncReset) {
    // Create a 1-to-N socket for each host.
    val hostSocket = hostConnections.map { case (name, devices) =>
      val hostId = hostMap(name)
      name -> Module(new TlulSocket1N(hostParams(hostId), N = devices.length))
    }.toMap

    // Create an M-to-1 socket for each device with more than one master.
    val deviceSocket = deviceFanIn.collect { case (name, hosts) if hosts.length > 1 =>
      val deviceId = deviceMap(name)
      name -> Module(new TlulSocketM1(deviceParams(deviceId), M = hosts.length))
    }.toMap

    // Create an asynchronous FIFO for each device in a different clock domain.
    val asyncDeviceFifo = cfg.devices.filter(_.clockDomain != "main").map { device =>
      val deviceId = deviceMap(device.name)
      device.name -> Module(new TlulFifoAsync(deviceParams(deviceId)))
    }.toMap

    // Create an asynchronous FIFO for each host in a different clock domain.
    val asyncHostFifo = cfg.hosts(enableTestHarness).filter(_.clockDomain != "main").map { host =>
      val hostId = hostMap(host.name)
      host.name -> Module(new TlulFifoAsync(hostParams(hostId)))
    }.toMap

    // Create a width bridge for each host-device connection with mismatched widths.
    val widthBridge = hostConnections.flatMap { case (hostName, deviceNames) =>
      deviceNames.map { deviceName =>
        val hostId = hostMap(hostName)
        val deviceId = deviceMap(deviceName)
        val hostWidth = hostParams(hostId).w * 8
        val deviceWidth = deviceParams(deviceId).w * 8
        if (hostWidth != deviceWidth) {
          val bridge = Module(new TlulWidthBridge(hostParams(hostId), deviceParams(deviceId)))
          bridge.io.clk_i := io.clk_i
          bridge.io.rst_ni := io.rst_ni
          Some((s"${hostName}_to_${deviceName}", bridge))
        } else {
          None
        }
      }
    }.flatten.toMap
    (hostSocket, deviceSocket, asyncDeviceFifo, asyncHostFifo, widthBridge)
  }

  // --- 3. Programmatic Address Decoding ---
  // Generate the dev_select logic for each host socket from the address map.
  hostSockets.foreach { case (hostName, socket) =>
    // Get the address from the host socket's input channel.
    val address = socket.io.tl_h.a.bits.address
    // Find the list of devices this host is allowed to connect to.
    val connectedDevices = hostConnections(hostName)
    // The default selection is an index one beyond the number of connected
    // devices, which routes the request to the internal error responder.
    val errorIdx = connectedDevices.length.U

    socket.io.dev_select_i := errorIdx
    when(socket.io.tl_h.a.valid) {
      socket.io.dev_select_i := MuxCase(errorIdx,
        connectedDevices.zipWithIndex.map { case (devName, idx) =>
          val devConfig = cfg.devices.find(_.name == devName).get
          // Check if the address falls within any of the device's address ranges.
          val addrMatch = devConfig.addr.map(_.contains(address)).reduce(_ || _)
          addrMatch -> idx.U
        }
      )
    }
  }

  // --- 4. Programmatic Wiring ---
  // This section programmatically connects the entire crossbar graph.

  // A map from async domain name to its index in the IO bundle's Vec.
  val asyncDeviceDomainMap = asyncDeviceDomains.zipWithIndex.toMap
  val asyncHostDomainMap = asyncHostDomains.zipWithIndex.toMap

  // Connect top-level host IOs to the host-side of the 1-to-N sockets.
  for ((hostName, socket) <- hostSockets) {
    val hostConfig = cfg.hosts(enableTestHarness).find(_.name == hostName).get
    if (hostConfig.clockDomain != "main") {
      asyncHostFifos(hostName).io.tl_h <> io.hosts(hostMap(hostName))
      socket.io.tl_h <> asyncHostFifos(hostName).io.tl_d
    } else {
      socket.io.tl_h <> io.hosts(hostMap(hostName))
    }
  }

  // Connect the async FIFOs to their specific clocks and resets.
  for ((deviceName, fifo) <- asyncDeviceFifos) {
    val deviceConfig = cfg.devices.find(_.name == deviceName).get
    val domainIndex = asyncDeviceDomainMap(deviceConfig.clockDomain)
    fifo.io.clk_h_i := io.clk_i
    fifo.io.rst_h_i := !io.rst_ni.asBool
    fifo.io.clk_d_i := io.async_ports_devices(domainIndex).clock
    fifo.io.rst_d_i := !io.async_ports_devices(domainIndex).reset.asBool
  }

  for ((hostName, fifo) <- asyncHostFifos) {
    val hostConfig = cfg.hosts(enableTestHarness).find(_.name == hostName).get
    val domainIndex = asyncHostDomainMap(hostConfig.clockDomain)
    fifo.io.clk_h_i := io.async_ports_hosts(domainIndex).clock
    fifo.io.rst_h_i := !io.async_ports_hosts(domainIndex).reset.asBool
    fifo.io.clk_d_i := io.clk_i
    fifo.io.rst_d_i := !io.rst_ni.asBool
  }

  // Connect the device-side outputs of the M-to-1 sockets.
  for ((deviceName, socket) <- deviceSockets) {
    val deviceConfig = cfg.devices.find(_.name == deviceName).get
    if (deviceConfig.clockDomain != "main") {
      // If the device is async, connect the socket to the async FIFO.
      asyncDeviceFifos(deviceName).io.tl_h <> socket.io.tl_d
    } else {
      // Otherwise, connect it directly to the top-level device IO.
      io.devices(deviceMap(deviceName)) <> socket.io.tl_d
    }
  }

  // Connect the device-side of the async FIFOs to the top-level device IOs.
  for ((deviceName, fifo) <- asyncDeviceFifos) {
    io.devices(deviceMap(deviceName)) <> fifo.io.tl_d
  }

  // Connect the device-side outputs of the 1-to-N host sockets.
  for ((hostName, hostSocket) <- hostSockets) {
    val connections = hostConnections(hostName)
    for ((deviceName, portIndex) <- connections.zipWithIndex) {
      val deviceConfig = cfg.devices.find(_.name == deviceName).get
      val fanIn = deviceFanIn(deviceName).length

      val hostWidth = hostParams(hostMap(hostName)).w * 8
      val deviceWidth = deviceParams(deviceMap(deviceName)).w * 8

      val socket_out = Wire(new OpenTitanTileLink.Host2Device(hostParams(hostMap(hostName))))
      socket_out <> hostSocket.io.tl_d(portIndex)

      val finalPort =
        if (fanIn > 1) {
          deviceSockets(deviceName).io.tl_h(deviceFanIn(deviceName).indexWhere(_.name == hostName))
        } else if (deviceConfig.clockDomain != "main") {
          asyncDeviceFifos(deviceName).io.tl_h
        } else {
          io.devices(deviceMap(deviceName))
        }

      if (hostWidth != deviceWidth) {
        val bridge = widthBridges(s"${hostName}_to_${deviceName}")
        bridge.io.tl_h <> socket_out
        finalPort <> bridge.io.tl_d
      } else {
        finalPort <> socket_out
      }
    }
  }
}

import _root_.circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import kelvin.Parameters
import scala.annotation.nowarn

/**
 * A standalone main object to generate the SystemVerilog for the KelvinXbar.
 *
 * This can be run via Bazel to produce the final Verilog output.
 */
@nowarn
object KelvinXbarEmitter extends App {
  // Basic argument parsing for --enableTestHarness
  val enableTestHarness = args.contains("--enableTestHarness")
  val chiselArgs = args.filterNot(_ == "--enableTestHarness")

  // Create a sequence of TLULParameters for hosts and devices based on the config.
  val hostParams = CrossbarConfig.hosts(enableTestHarness).map { host =>
    val p = new Parameters
    p.lsuDataBits = host.width
    new bus.TLULParameters(p)
  }
  val deviceParams = CrossbarConfig.devices.map { device =>
    val p = new Parameters
    p.lsuDataBits = device.width
    new bus.TLULParameters(p)
  }

  // Use ChiselStage to generate the Verilog.
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ chiselArgs,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new KelvinXbar(hostParams, deviceParams, enableTestHarness)
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
