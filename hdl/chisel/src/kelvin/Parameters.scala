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

class MemoryRegion(
  val memStart: Int,
  val memSize: Int,
  val cacheable: Boolean,
  val dataWidthBits: Int,
) {

def contains(addr: UInt): Bool = {
  val addrWidth = addr.getWidth.W
  (addr >= memStart.U(addrWidth)) && (addr < memStart.U(addrWidth) + memSize.U(addrWidth))
}

}

case class Parameters(m: Seq[MemoryRegion] = Seq()) {
  case object Core {
    val tiny = 0
    val little = 1
    val big = 2
  }

  // Vector Length (register-file and compute).
  // 128 = faster builds, but not production.
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

  // Enable Vector
  val enableVector = true

  // Vector queue.
  val vectorFifoDepth = 16

  // L0ICache Fetch unit.
  val fetchCacheBytes = 1024

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
