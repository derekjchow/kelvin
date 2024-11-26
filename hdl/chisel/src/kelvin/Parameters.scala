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
import scala.collection.mutable.StringBuilder

object MemoryRegionType extends ChiselEnum {
  val IMEM = Value
  val DMEM = Value
  val Peripheral = Value
  val External = Value
}

class MemoryRegion(
  val memStart: Int,
  val memSize: Int,
  val memType: MemoryRegionType.Type,
) {

def contains(addr: UInt): Bool = {
  val addrWidth = addr.getWidth.W
  (addr >= memStart.U(addrWidth)) && (addr < memStart.U(addrWidth) + memSize.U(addrWidth))
}

}

object Parameters {
  def apply(): Parameters = {
    return new Parameters()
  }
  def apply(m: Seq[MemoryRegion]): Parameters = {
    return new Parameters(m)
  }
}

class Parameters(var m: Seq[MemoryRegion] = Seq(), val hartId: Int = 0) {
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
  var enableVector = true
  val vectorAluCount = 2
  val vectorReadPorts = (vectorAluCount * 3) + 1
  val vectorWritePorts = 6
  val vectorWhintPorts = 4
  val vectorScalarPorts = 2

  // Vector queue.
  val vectorFifoDepth = 16

  // Enable RVV. This differs from Vector in that it conforms to the RVV1.0 spec
  var enableRvv = false

  // L0ICache Fetch unit.
  var enableFetchL0 = true
  val fetchCacheBytes = 1024

  // Scalar Core Fetch bus.
  val fetchAddrBits = 32   // do not change
  var fetchDataBits = 256  // do not change
  def fetchInstrSlots: Int = {
    assert(fetchDataBits % 32 == 0)
    assert(instructionBits % 32 == 0)
    assert(fetchDataBits % instructionBits == 0)
    fetchDataBits / instructionBits
  }

  // Scalar Core Load Store Unit bus.
  val lsuAddrBits = 32  // do not change
  var lsuDataBits = vectorBits
  val lsuDelayPipelineLen = 1
  def dbusSize: Int = { log2Ceil(lsuDataBits / 8) + 1 }

  // [External] Core AXI interface.
  val axiSysIdBits = 7
  val axiSysAddrBits = 32
  def axiSysDataBits: Int = { lsuDataBits }

  // [Internal] L1ICache interface.
  val l1islots = 256
  val l1iassoc = 4
  val axi0IdBits = 4  // (1x banks, 4 bits unused)
  val axi0AddrBits = 32
  def axi0DataBits: Int = { fetchDataBits }

  // [Internal] L1DCache interface.
  val l1dslots = 256  // (x2 banks)
  val axi1IdBits = 4  // (x2 banks, 3 bits unused)
  val axi1AddrBits = 32
  def axi1DataBits: Int = { lsuDataBits } /* axiSysDataBits */ /* vectorBits */

  // [Internal] TCM[Vector,Scalar] interface.
  val axi2IdBits = 6
  val axi2AddrBits = 32
  def axi2DataBits: Int = { lsuDataBits } // vectorBits

  // If set, itcmMemoryFile should contain a path to a Verilog mem file.
  // NB: Only used by CoreAxi
  val itcmMemoryFile = ""

  val csrInCount = 13
  val csrOutCount = 8
}

import scala.reflect.runtime.{universe => ru}
object EmitParametersHeader {
  def apply(p: Parameters): String = {
    val mirror = ru.runtimeMirror(ru.getClass.getClassLoader)
    val instanceMirror = mirror.reflect(p)
    val symbol = instanceMirror.symbol
    val typeSym = symbol.toType
    val fields = typeSym.decls.collect {
      case t: (ru.TermSymbol @unchecked) if t.isVal || t.isVar => t
    }

    var builder = new StringBuilder()
    builder = builder.append("#ifndef KELVIN_PARAMETERS_H_\n")
    builder = builder.append("#define KELVIN_PARAMETERS_H_\n")
    builder = builder.append("\n")
    builder = builder.append("#include <stdbool.h>\n")
    builder = builder.append("\n")
    fields.foreach { x =>
      val fieldMirror = instanceMirror.reflectField(x.asTerm)
      val fieldType = x.asTerm.typeSignature
      val value = fieldMirror.get
      val ctype = fieldType match {
        case t if t =:= ru.typeOf[Int] => Some("int")
        case t if t =:= ru.typeOf[Boolean] => Some("bool")
        case _ => None
      }
      if (ctype != None) {
        val ctypeStr = ctype.get
        builder = builder.append(s"#define KP_${x.name} ${value}\n")
      }
    }
    // TODO(atv): See if we can improve the reflection above to execute
    // the methods for our dynamic parameters.
    builder = builder.append(s"#define KP_dbusSize ${p.dbusSize}\n")
    builder = builder.append("#endif\n")
    builder.result()
  }
}
