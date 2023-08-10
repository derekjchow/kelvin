package kelvin

import chisel3._
import chisel3.util._

case class Parameters() {
  case object Core {
    val tiny = 0
    val little = 1
    val big = 2
  }

  // Vector Length (register-file and compute).
  // 128 = faster builds, but not production(?).
  val vectorBits = sys.env.get("KELVIN_SIMD").getOrElse("256").toInt
  assert(vectorBits == 512 || vectorBits == 256 || vectorBits == 128)

  val core = vectorBits match {
    case 128 => Core.tiny
    case 256 => Core.little
    case 512 => Core.big
  }

  // Machine.
  val programCounterBits = 32
  val instructionBits = 32
  val instructionLanes = 4

  val vectorCountBits = log2Ceil(vectorBits / 8) + 1 + 2  // +2 stripmine

  // Vector queue.
  val vectorFifoDepth = 16

  // L0ICache Fetch unit.
  // val fetchCacheBytes = 2048
  val fetchCacheBytes = 1024
  // val fetchCacheBytes = 128

  // Scalar Core Fetch bus.
  val fetchAddrBits = 32   // do not change
  val fetchDataBits = 256  // do not change

  // Scalar Core Load Store Unit bus.
  val lsuAddrBits = 32  // do not change
  val lsuDataBits = vectorBits

  // [External] Core AXI interface.
  val axiSysIdBits = 7
  val axiSysAddrBits = 32
  val axiSysDataBits = vectorBits

  // [Internal] L1ICache interface.
  val l1islots = 256
  val axi0IdBits = 4  // (1x banks, 4 bits unused)
  val axi0AddrBits = 32
  val axi0DataBits = fetchDataBits

  // [Internal] L1DCache interface.
  val l1dslots = 256  // (x2 banks)
  val axi1IdBits = 4  // (x2 banks, 3 bits unused)
  val axi1AddrBits = 32
  val axi1DataBits = vectorBits

  // [Internal] TCM[Vector,Scalar] interface.
  val axi2IdBits = 6
  val axi2AddrBits = 32
  val axi2DataBits = vectorBits
}
