// Copyright 2024 Google LLC
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

object VInstOp extends ChiselEnum {
  val GETVL = Value
  val GETMAXVL = Value
  val VLD = Value
  val VST = Value
  val VIOP = Value
}

class VInstCmd extends Bundle {
  val addr = UInt(5.W)
  val inst = UInt(32.W)
  val op = VInstOp()
}

class VCoreIO(p: Parameters) extends Bundle {
  // Decode cycle.
  val vinst = Vec(p.instructionLanes, Flipped(Decoupled(new VInstCmd)))

  // Execute cycle.
  val rs = Vec(p.instructionLanes * 2, Flipped(new RegfileReadDataIO))
  val rd = Vec(p.instructionLanes, Valid(Flipped(new RegfileWriteDataIO)))

  // Status.
  val mactive = Output(Bool())

  // Faults.
  val undef = Output(Bool())

  val vrfwriteCount = Output(UInt(3.W))
  val vstoreCount = Output(UInt(2.W))
}

class CsrInIO(p: Parameters) extends Bundle {
  val value = Input(Vec(p.csrInCount, UInt(32.W)))
}

class CsrOutIO(p: Parameters) extends Bundle {
  val value = Output(Vec(p.csrOutCount, UInt(32.W)))
}

class CsrInOutIO(p: Parameters) extends Bundle {
  val in  = new CsrInIO(p)
  val out = new CsrOutIO(p)
}

class BranchTakenIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val value = Output(UInt(p.programCounterBits.W))
}

class RegfileLinkPortIO extends Bundle {
  val valid = Output(Bool())
  val value = Output(UInt(32.W))
}

// When `valid` as asserted, `addr` must remain constant
// until `ready` is fired.
class IBusIO(p: Parameters) extends Bundle {
  // Control Phase.
  val valid = Output(Bool())
  val ready = Input(Bool())
  val addr = Output(UInt(p.fetchAddrBits.W))
  // Read Phase.
  val rdata = Input(UInt(p.fetchDataBits.W))
}

class FetchInstruction(p: Parameters) extends Bundle {
  val addr = UInt(p.programCounterBits.W)
  val inst = UInt(p.instructionBits.W)
  val brchFwd = Bool()
}

class FetchIO(p: Parameters) extends Bundle {
  val lanes = Vec(p.instructionLanes, Decoupled(new FetchInstruction(p)))
}

abstract class FetchUnit(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val csr = new CsrInIO(p)
    val ibus = new IBusIO(p)
    val inst = new FetchIO(p)
    val branch = Flipped(Vec(p.instructionLanes, new BranchTakenIO(p)))
    val linkPort = Flipped(new RegfileLinkPortIO)
    val iflush = Flipped(new IFlushIO(p))
    val pc = UInt(p.fetchAddrBits.W)
  })
}

abstract class SRAM128(addrWidth: Int) extends BlackBox {
  val io = IO(new Bundle {
    val clock    = Input(Clock())
    val enable   = Input(Bool())
    val write    = Input(Bool())
    val addr     = Input(UInt(addrWidth.W))
    val wdata    = Input(UInt(128.W))
    val wmask    = Input(UInt(16.W))
    val rdata    = Output(UInt(128.W))
  })
}

class DBusIO(p: Parameters, bank: Boolean = false) extends Bundle {
  // Control Phase.
  val valid = Output(Bool())
  val ready = Input(Bool())
  val write = Output(Bool())
  val addr = Output(UInt((p.lsuAddrBits - (if (bank) 1 else 0)).W))
  val adrx = Output(UInt((p.lsuAddrBits - (if (bank) 1 else 0)).W))
  val size = Output(UInt(p.dbusSize.W))
  val wdata = Output(UInt(p.lsuDataBits.W))
  val wmask = Output(UInt((p.lsuDataBits / 8).W))
  // Read Phase.
  val rdata = Input(UInt(p.lsuDataBits.W))
}

class EBusIO(p: Parameters) extends Bundle {
  val dbus = new DBusIO(p)
  val internal = Output(Bool())
}

class IFlushIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())
}

class DFlushIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val ready = Input(Bool())
  val all   = Output(Bool())  // all=0, see io.dbus.addr for line address.
  val clean = Output(Bool())  // clean and flush
}

class SLogIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(5.W))
  val data = Output(UInt(32.W))
}

// Debug signals for HDL development.
class DebugIO(p: Parameters) extends Bundle {
  val en = Output(UInt(4.W))
  val addr = Vec(p.instructionLanes, UInt(32.W))
  val inst = Vec(p.instructionLanes, UInt(32.W))
  val cycles = Output(UInt(32.W))
}

class RegfileReadDataIO extends Bundle {
  val valid = Output(Bool())
  val data  = Output(UInt(32.W))
}

class RegfileWriteDataIO extends Bundle {
  val addr  = Input(UInt(5.W))
  val data  = Input(UInt(32.W))
}

class FabricIO(p: Parameters) extends Bundle {
    val readDataAddr = Output(Valid(UInt(p.axi2AddrBits.W)))
    val readData = Input(Valid(UInt(p.axi2DataBits.W)))
    val writeDataAddr = Output(Valid(UInt(p.axi2AddrBits.W)))
    val writeDataBits = Output(UInt(p.axi2DataBits.W))
    val writeDataStrb = Output(UInt((p.axi2DataBits / 8).W))
    val writeResp = Input(Bool())
}
