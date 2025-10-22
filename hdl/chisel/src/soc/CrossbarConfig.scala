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

/**
 * A simple case class for defining memory regions.
 *
 * @param base The base address of the memory region.
 * @param size The size of the memory region in bytes.
 */
case class AddressRange(base: BigInt, size: BigInt) {
  /**
   * Checks if a given dynamic address is within this range.
   * @param addr The address to check.
   * @return A Chisel Bool indicating if the address is contained.
   */
  def contains(addr: UInt): Bool = {
    (addr >= base.U) && (addr < (base + size).U)
  }
}

/**
 * Defines the parameters for a host (master) in the crossbar.
 * @param name The unique name of the host.
 * @param width The data width of the host interface.
 */
case class HostConfig(name: String, width: Int, clockDomain: String = "main")

/**
 * Defines the parameters for a device (slave) in the crossbar.
 * @param name The unique name of the device.
 * @param addr A sequence of AddressRanges that this device occupies.
 * @param clockDomain An identifier for the clock domain this device belongs to.
 * @param width The data width of the device interface.
 */
case class DeviceConfig(
  name: String,
  addr: Seq[AddressRange],
  clockDomain: String = "main",
  width: Int = 32
)

object CrossbarConfig {
  def apply(enableHighmem: Boolean = false): CrossbarConfig = {
    new CrossbarConfig(enableHighmem)
  }
}

class CrossbarConfig(enableHighmem: Boolean) {
  // List of all host (master) interfaces.
  def hosts(enableTestHarness: Boolean): Seq[HostConfig] = {
    val baseHosts = Seq(
      HostConfig("coralnpu_core", width = 128),
      HostConfig("spi2tlul", width = 128)
    )
    if (enableTestHarness) {
      baseHosts :+ HostConfig("test_host_32", width = 32, clockDomain = "test")
    } else {
      baseHosts
    }
  }

  val coralnpu_ranges = if (enableHighmem) {
    Seq(
      AddressRange(0x00000000, 0x100000),    // 1MB
      AddressRange(0x00100000, 0x100000),    // 1MB
      AddressRange(0x00200000, 0x1000)     // 4kB
    )
  } else {
    Seq(
      AddressRange(0x00000000, 0x2000),    // 8kB
      AddressRange(0x00010000, 0x8000),    // 32kB
      AddressRange(0x00030000, 0x1000)     // 4kB
    )
  }

  // List of all device (slave) interfaces with their address maps.
  val devices = Seq(
    DeviceConfig("coralnpu_device", coralnpu_ranges, width = 128),
    DeviceConfig("rom",  Seq(AddressRange(0x10000000, 0x8000))),      // 32kB
    DeviceConfig("sram", Seq(AddressRange(0x20000000, 0x400000))),    // 4MB
    DeviceConfig("uart0", Seq(AddressRange(0x40000000, 0x1000))),
    DeviceConfig("uart1", Seq(AddressRange(0x40010000, 0x1000))),
    DeviceConfig("ddr_ctrl", Seq(AddressRange(0x70000000, 0x1000)), clockDomain = "ddr", width = 32), // 4kB for DDR Control
    DeviceConfig("ddr_mem",  Seq(AddressRange(BigInt("80000000", 16), BigInt("80000000", 16))), clockDomain = "ddr", width = 128)     // 2GB for DDR Memory
  )

  // A map defining which hosts are allowed to connect to which devices.
  def connections(enableTestHarness: Boolean): Map[String, Seq[String]] = {
    val baseConnections = Map(
      "coralnpu_core" -> Seq("sram", "uart1", "coralnpu_device", "rom", "uart0", "ddr_ctrl", "ddr_mem"),
      "spi2tlul" -> Seq("coralnpu_device", "sram", "ddr_ctrl", "ddr_mem")
    )
    if (enableTestHarness) {
      baseConnections + ("test_host_32" -> Seq("rom", "sram", "uart0", "coralnpu_device", "ddr_ctrl", "ddr_mem"))
    } else {
      baseConnections
    }
  }
}

/**
 * A standalone validator for the CrossbarConfig.
 *
 * This object can be run to check for configuration errors, such as overlapping
 * address ranges between devices.
 */
object CrossbarConfigValidator extends App {
  val devices = CrossbarConfig().devices

  println("Running CrossbarConfig validation...")

  // Check for address range collisions
  for (i <- devices.indices) {
    for (j <- i + 1 until devices.length) {
      val dev1 = devices(i)
      val dev2 = devices(j)

      for (range1 <- dev1.addr) {
        for (range2 <- dev2.addr) {
          val start1 = range1.base
          val end1 = range1.base + range1.size
          val start2 = range2.base
          val end2 = range2.base + range2.size

          // Check for overlap: max(start1, start2) < min(end1, end2)
          val overlap = (start1 < end2) && (start2 < end1)

          if (overlap) {
            val errorMsg =
              s"""
                 |FATAL: Address range collision detected!
                 |  Device 1: ${dev1.name} -> Range [0x${start1.toString(16)}, 0x${(end1 - 1).toString(16)}]
                 |  Device 2: ${dev2.name} -> Range [0x${start2.toString(16)}, 0x${(end2 - 1).toString(16)}]
               """
            System.err.println(errorMsg)
            throw new Exception("Crossbar configuration validation failed.")
          }
        }
      }
    }
  }

  println("Validation successful: No address range collisions found.")

  def printConfig(enableTestHarness: Boolean): Unit = {
    println(s"\n--- Crossbar Configuration (TestHarness: $enableTestHarness) ---")
    println("Hosts:")
    CrossbarConfig().hosts(enableTestHarness).foreach(h => println(s"  - ${h.name}"))

    println("\nDevices:")
    CrossbarConfig().devices.foreach {
      d =>
        println(s"  - ${d.name} (${d.clockDomain} clock domain)")
        d.addr.foreach {
          a =>
            println(f"    - 0x${a.base}%08x - 0x${a.base + a.size - 1}%08x (Size: ${a.size / 1024}kB)")
        }
    }

    println("\nConnections:")
    CrossbarConfig().connections(enableTestHarness).foreach {
      case (host, devices) =>
        println(s"  - ${host} -> [${devices.mkString(", ")}]")
    }
    println("\n--------------------------")
  }

  printConfig(false)
  printConfig(true)
}
