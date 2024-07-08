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

case class Parameters(m: Seq[MemoryRegion] = Seq(), hartId: UInt = 0.U(32.W)) {
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

import scala.reflect.runtime.{universe => ru}
object EmitParametersHeader extends App {
  val p = new Parameters
  val mirror = ru.runtimeMirror(ru.getClass.getClassLoader)
  val instanceMirror = mirror.reflect(p)
  val symbol = instanceMirror.symbol
  val typeSym = symbol.toType
  val fields = typeSym.decls.collect {
    case t: (ru.TermSymbol @unchecked) if t.isVal || t.isVar => t
  }

  println("#ifndef KELVIN_PARAMETERS_H_")
  println("#define KELVIN_PARAMETERS_H_")
  println("")
  println("#include <stdbool.h>")
  println("")
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
      println(s"#define KP_${x.name} ${value}")
      // println(s"${ctypeStr} KP_${x.name} = ${value};")
    }
  }
  println("#endif")
}
