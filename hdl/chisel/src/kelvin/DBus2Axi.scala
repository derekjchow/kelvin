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

import bus.AxiMasterIO
import common._
import _root_.circt.stage.ChiselStage

object DBus2Axi {
  def apply(p: Parameters): DBus2Axi = {
    return Module(new DBus2Axi(p))
  }
}

class DBus2Axi(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val dbus = Flipped(new DBusIO(p))
    val axi = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })
  io.axi.defaults()

  val linebit = log2Ceil(p.lsuDataBits / 8)

  val sraddrActive = RegInit(false.B)
  val sdata = Reg(UInt(p.axi2DataBits.W))

  when (io.axi.read.data.valid && io.axi.read.data.ready) {
    sraddrActive := false.B
    assert(sraddrActive)
    assert(!io.axi.read.addr.valid)
  } .elsewhen (io.axi.read.addr.valid && io.axi.read.addr.ready) {
    sraddrActive := true.B
    assert(!sraddrActive)
    assert(!io.axi.read.data.valid)
  }

  when (io.axi.read.data.valid && io.axi.read.data.ready) {
    sdata := io.axi.read.data.bits.data
  }

  io.dbus.ready := Mux(io.dbus.write,
                       io.axi.write.data.ready,
                       io.axi.read.data.valid && io.axi.read.data.ready)
  io.dbus.rdata := sdata

  val saddr = Cat(io.dbus.addr(31, linebit), 0.U(linebit.W))

  io.axi.write.addr.valid := io.dbus.valid && io.dbus.write
  io.axi.write.addr.bits.addr := saddr
  io.axi.write.addr.bits.id := 0.U
  io.axi.write.addr.bits.prot := 2.U

  io.axi.write.data.valid := io.dbus.valid && io.dbus.write
  io.axi.write.data.bits.strb := io.dbus.wmask
  io.axi.write.data.bits.data := io.dbus.wdata
  io.axi.write.data.bits.last := true.B

  io.axi.write.resp.ready := true.B

  io.axi.read.addr.valid := io.dbus.valid && !io.dbus.write && !sraddrActive
  io.axi.read.addr.bits.addr := saddr
  io.axi.read.addr.bits.id := 0.U
  io.axi.read.addr.bits.prot := 2.U

  io.axi.read.data.ready := true.B
}

object EmitDBus2Axi extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new DBus2Axi(p), args)
}
