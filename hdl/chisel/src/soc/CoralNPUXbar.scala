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

package coralnpu.soc

import chisel3._
import chisel3.util.{MixedVec, MuxCase}
import bus._
import bus.TlulWidthBridge
import coralnpu.Parameters

/**
 * A dynamically generated IO bundle for the CoralNPUXbar.
 *
 * This bundle's ports are derived from the CrossbarConfig object. It automatically
 * creates clock and reset ports for any asynchronous domains defined in the config.
 *
 * @param hostParams A sequence of TileLink parameters, one for each host.
 * @param deviceParams A sequence of TileLink parameters, one for each device.
 */
class CoralNPUXbarIO(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean, val enableHighmem: Boolean) extends Bundle {
  val cfg = CrossbarConfig(enableHighmem)

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
 * A data-driven TileLink crossbar generator for the CoralNPU SoC.
 *
 * This RawModule constructs a crossbar by interpreting the CrossbarConfig object.
 * This gives explicit control over clock and reset signals, which is critical
 * for a multi-domain design.
 *
 * @param p The TileLink UL parameters for the bus.
 */
class CoralNPUXbar(val hostParams: Seq[bus.TLULParameters], val deviceParams: Seq[bus.TLULParameters], val enableTestHarness: Boolean, val enableHighmem: Boolean) extends Module {
  override val desiredName = if (enableTestHarness) "CoralNPUXbarTestHarness" else "CoralNPUXbar"
  // Load the single source of truth for the crossbar configuration.
  val cfg = CrossbarConfig(enableHighmem)

  // Create simple maps from name to index for easy port access.
  val hostMap = cfg.hosts(enableTestHarness).map(_.name).zipWithIndex.toMap
  val deviceMap = cfg.devices.map(_.name).zipWithIndex.toMap

  // Instantiate the dynamically generated IO bundle.
  val io = IO(new CoralNPUXbarIO(hostParams, deviceParams, enableTestHarness, enableHighmem))

  // Find all unique clock domains from the config, excluding the main one.
  val asyncDeviceDomains = cfg.devices.map(_.clockDomain).distinct.filter(_ != "main")
  val asyncHostDomains = cfg.hosts(enableTestHarness).map(_.clockDomain).distinct.filter(_ != "main")
  val asyncDeviceDomainMap = asyncDeviceDomains.zipWithIndex.toMap
  val asyncHostDomainMap = asyncHostDomains.zipWithIndex.toMap

  // --- 1. Graph Analysis ---
  // Analyze the configuration to understand the connection topology. This will be
  // used to determine the size of sockets and how to wire them up.
  val hostConnections = cfg.connections(enableTestHarness)
  val deviceFanIn = cfg.devices.map { device =>
    device.name -> cfg.hosts(enableTestHarness).filter(h => hostConnections(h.name).contains(device.name))
  }.toMap

  // --- 2. Programmatic Instantiation (within the main clock domain) ---
  // We use withClockAndReset to provide the explicit clock and reset signals
  // required by the child modules, as CoralNPUXbar itself is a RawModule.
  // The top-level reset is active-low, so we invert it for the active-high
  // modules instantiated within this block.
  // Define common parameters for the unified internal bus.
  val commonParams = {
    val p = new Parameters
    p.lsuDataBits = 128
    new bus.TLULParameters(p)
  }
  val commonWidth = 128

  // --- 2. Programmatic Instantiation and Interface Standardization ---
  // All modules are instantiated and wired within their correct clock domains.
  // This process produces two maps of standardized TileLink interfaces, one for
  // hosts and one for devices, that are all in the main clock domain and use
  // the common bus width. This greatly simplifies the final wiring stage.
  val (hostInterfaces, deviceInterfaces, hostSockets, deviceSockets) = withClockAndReset(clock, reset) {

    // A. Standardize Host Interfaces
    val hostInterfaces = cfg.hosts(enableTestHarness).map { host =>
      val hostId = hostMap(host.name)
      var currentIface: bus.OpenTitanTileLink.Host2Device = io.hosts(hostId)

      // Step 1: Clock Domain Crossing (if necessary)
      // Host-side FIFOs are at the host's native width. The FIFO output is in the main clock domain.
      if (host.clockDomain != "main") {
        val domainIndex = asyncHostDomainMap(host.clockDomain)
        val fifo = Module(new TlulFifoAsync(hostParams(hostId)))
        fifo.io.clk_h_i := io.async_ports_hosts(domainIndex).clock
        fifo.io.rst_h_i := io.async_ports_hosts(domainIndex).reset.asBool
        fifo.io.clk_d_i := clock
        fifo.io.rst_d_i := reset.asBool
        fifo.io.tl_h <> currentIface
        currentIface = fifo.io.tl_d
      }

      // Step 2: Width Conversion (if necessary)
      // All interfaces are brought up to the common bus width.
      if ((hostParams(hostId).w * 8) < commonWidth) {
        val bridge = Module(new TlulWidthBridge(hostParams(hostId), commonParams))
        bridge.io.tl_h <> currentIface
        currentIface = bridge.io.tl_d
      }
      host.name -> currentIface
    }.toMap

    // B. Standardize Device Interfaces
    // We create a set of standardized input interfaces (from the Xbar's perspective).
    // The conversion logic is wired up here, connecting these standardized interfaces
    // to the final output ports.
    val deviceInterfaces = cfg.devices.map { device =>
      val deviceId = deviceMap(device.name)
      // This is the standardized interface, in the main clock domain at the common width.
      val standardizedIface = Wire(new bus.OpenTitanTileLink.Host2Device(commonParams))
      var currentIface: bus.OpenTitanTileLink.Host2Device = standardizedIface

      // Step 1: Clock Domain Crossing (if necessary)
      // The FIFO input is at the common width and in the main clock domain.
      if (device.clockDomain != "main") {
        val domainIndex = asyncDeviceDomainMap(device.clockDomain)
        val fifo = Module(new TlulFifoAsync(commonParams))
        fifo.io.clk_h_i := clock
        fifo.io.rst_h_i := reset.asBool
        fifo.io.clk_d_i := io.async_ports_devices(domainIndex).clock
        fifo.io.rst_d_i := io.async_ports_devices(domainIndex).reset.asBool
        fifo.io.tl_h <> currentIface
        currentIface = fifo.io.tl_d
      }

      // Step 2: Width Conversion (if necessary)
      // This bridge is in the device's clock domain.
      if ((deviceParams(deviceId).w * 8) != commonWidth) {
        val bridge = if (device.clockDomain != "main") {
          val domainIndex = asyncDeviceDomainMap(device.clockDomain)
          withClockAndReset(io.async_ports_devices(domainIndex).clock, io.async_ports_devices(domainIndex).reset) {
            Module(new TlulWidthBridge(commonParams, deviceParams(deviceId)))
          }
        } else {
          Module(new TlulWidthBridge(commonParams, deviceParams(deviceId)))
        }
        bridge.io.tl_h <> currentIface
        currentIface = bridge.io.tl_d
      }

      // Connect the end of the conversion chain to the actual device IO port.
      io.devices(deviceId) <> currentIface

      device.name -> standardizedIface
    }.toMap

    // C. Instantiate Sockets
    // All sockets are now instantiated with the common parameters.
    val hostSockets = hostConnections.map { case (name, devices) =>
      name -> Module(new TlulSocket1N(commonParams, N = devices.length))
    }.toMap

    val deviceSockets = deviceFanIn.collect { case (name, hosts) if hosts.length > 1 =>
      name -> Module(new TlulSocketM1(commonParams, M = hosts.length))
    }.toMap

    (hostInterfaces, deviceInterfaces, hostSockets, deviceSockets)
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

    // Make the logic purely combinational by removing the 'when' block.
    // This ensures the select signal is stable in the same cycle as a_valid.
    socket.io.dev_select_i := MuxCase(errorIdx,
      connectedDevices.zipWithIndex.map { case (devName, idx) =>
        val devConfig = cfg.devices.find(_.name == devName).get
        // Check if the address falls within any of the device's address ranges.
        val addrMatch = devConfig.addr.map(_.contains(address)).reduce(_ || _)
        addrMatch -> idx.U
      }
    )
  }

  // --- 4. Programmatic Wiring ---
  // With standardized interfaces, wiring is now straightforward.

  // A. Connect Hosts -> Host Sockets
  for ((hostName, hostSocket) <- hostSockets) {
    hostSocket.io.tl_h <> hostInterfaces(hostName)
  }

  // B. Connect Host Sockets -> Device Sockets (or Devices)
  for ((hostName, hostSocket) <- hostSockets) {
    val connections = hostConnections(hostName)
    for ((deviceName, portIndex) <- connections.zipWithIndex) {
      val fanIn = deviceFanIn(deviceName).length
      val socketOut = hostSocket.io.tl_d(portIndex)

      if (fanIn > 1) {
        val fanInIndex = deviceFanIn(deviceName).indexWhere(_.name == hostName)
        deviceSockets(deviceName).io.tl_h(fanInIndex) <> socketOut
      } else {
        // Direct connection for 1:1 cases
        deviceInterfaces(deviceName) <> socketOut
      }
    }
  }

  // C. Connect Device Sockets -> Devices
  for ((deviceName, deviceSocket) <- deviceSockets) {
    deviceInterfaces(deviceName) <> deviceSocket.io.tl_d
  }
}

import _root_.circt.stage.{ChiselStage, FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import coralnpu.Parameters
import scala.annotation.nowarn

/**
 * A standalone main object to generate the SystemVerilog for the CoralNPUXbar.
 *
 * This can be run via Bazel to produce the final Verilog output.
 */
@nowarn
object CoralNPUXbarEmitter extends App {
  // Basic argument parsing for --enableTestHarness
  val enableTestHarness = args.contains("--enableTestHarness")
  val chiselArgs = args.filterNot(_ == "--enableTestHarness")

  // Create a sequence of TLULParameters for hosts and devices based on the config.
  val hostParams = CrossbarConfig().hosts(enableTestHarness).map { host =>
    val p = new Parameters
    p.lsuDataBits = host.width
    new bus.TLULParameters(p)
  }
  val deviceParams = CrossbarConfig().devices.map { device =>
    val p = new Parameters
    p.lsuDataBits = device.width
    new bus.TLULParameters(p)
  }

  // Use ChiselStage to generate the Verilog.
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ chiselArgs,
    Seq(
      ChiselGeneratorAnnotation(() =>
        new CoralNPUXbar(hostParams, deviceParams, enableTestHarness, false)
      )
    ) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}