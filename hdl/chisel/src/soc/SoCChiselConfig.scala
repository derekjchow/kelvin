package coralnpu.soc

import coralnpu.{MemoryRegion, MemoryRegions}

// --- External Port Definitions ---

/** A simple enumeration for port directions. */
sealed trait PortDirection
case object In extends PortDirection
case object Out extends PortDirection

/** A simple enumeration for basic port types. */
sealed trait PortType
case object Clk extends PortType
case object Bool extends PortType

/**
 * Defines a non-TileLink port to be exposed at the subsystem boundary.
 *
 * @param name The name of the port on the subsystem's IO bundle.
 * @param portType The Chisel type of the port (e.g., Clock, Bool).
 * @param direction The direction of the port (In or Out).
 * @param modulePort The full path to the port on the instantiated module
 *                   (e.g., "io.halted", "io.spi.csb").
 */
case class ExternalPort(
  name: String,
  portType: PortType,
  direction: PortDirection,
  modulePort: String
)

// --- Type-Safe Module Parameter Definitions ---

/** A trait representing the parameters for any configurable Chisel module. */
sealed trait ModuleParameters

/** Parameters for the CoreTlul module. */
case class CoreTlulParameters(
  lsuDataBits: Int,
  enableRvv: Boolean,
  enableFetchL0: Boolean,
  fetchDataBits: Int,
  enableVector: Boolean,
  enableFloat: Boolean,
  memoryRegions: Seq[MemoryRegion],
  tcmHighmem: Boolean,
) extends ModuleParameters

/** Parameters for the Spi2TLUL module. */
case class Spi2TlulParameters(
  lsuDataBits: Int
) extends ModuleParameters


/**
 * Defines the parameters for a Chisel module to be instantiated within the subsystem.
 *
 * @param name A unique instance name for the module.
 * @param moduleClass The fully qualified Scala class name of the Chisel Module to instantiate.
 * @param hostConnections A map where keys are port names on the module that are TileLink hosts,
 *                        and values are the names of the host ports on the crossbar to connect to.
 * @param deviceConnections A map where keys are port names on the module that are TileLink devices,
 *                          and values are the names of the device ports on the crossbar to connect to.
 * @param externalPorts A sequence of non-TileLink ports that need to be wired to the subsystem's top-level IO.
 */
case class ChiselModuleConfig(
  name: String,
  moduleClass: String,
  params: ModuleParameters,
  hostConnections: Map[String, String] = Map.empty,
  deviceConnections: Map[String, String] = Map.empty,
  externalPorts: Seq[ExternalPort] = Seq.empty
)

/**
 * The single source of truth for the entire Chisel-based portion of the SoC.
 */
object SoCChiselConfig {
  def apply(enableHighmem: Boolean = false): SoCChiselConfig = {
    new SoCChiselConfig(enableHighmem)
  }
}

class SoCChiselConfig(enableHighmem: Boolean) {
  val crossbar = CrossbarConfig(enableHighmem)
  val modules = Seq(
    ChiselModuleConfig(
      name = "rvv_core",
      moduleClass = "coralnpu.CoreTlul",
      params = CoreTlulParameters(
        lsuDataBits = 128,
        enableRvv = true,
        enableFetchL0 = false,
        fetchDataBits = 128,
        enableVector = false,
        enableFloat = true,
        memoryRegions = if (enableHighmem) {
          MemoryRegions.tcmHighmem
        } else {
          MemoryRegions.default
        },
        tcmHighmem = enableHighmem,
      ),
      hostConnections = Map("io.tl_host" -> "coralnpu_core"),
      deviceConnections = Map("io.tl_device" -> "coralnpu_device"),
      externalPorts = Seq(
        ExternalPort("halted", Bool, Out, "io.halted"),
        ExternalPort("fault",  Bool, Out, "io.fault"),
        ExternalPort("wfi",    Bool, Out, "io.wfi"),
        ExternalPort("irq",    Bool, In,  "io.irq"),
        ExternalPort("te",     Bool, In,  "io.te")
      )
    ),
    ChiselModuleConfig(
      name = "spi2tlul",
      moduleClass = "bus.Spi2TLUL",
      params = Spi2TlulParameters(lsuDataBits = 128),
      hostConnections = Map("io.tl" -> "spi2tlul"),
      externalPorts = Seq(
        ExternalPort("spi_clk",  Clk,  In,  "io.spi.clk"),
        ExternalPort("spi_csb",  Bool, In,  "io.spi.csb"),
        ExternalPort("spi_mosi", Bool, In,  "io.spi.mosi"),
        ExternalPort("spi_miso", Bool, Out, "io.spi.miso")
      )
    )
  )
}
