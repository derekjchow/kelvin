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

import bus.{AxiMasterIO, AxiResponseType}
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
    val fault = Valid(new FaultInfo(p))
  })
  io.axi.defaults()
  assert(!(io.dbus.valid && PopCount(io.dbus.size) =/= 1.U))

  val linebit = log2Ceil(p.lsuDataBits / 8)

  val sraddrActive = RegInit(false.B)
  val sdata = RegInit(0.U(p.axi2DataBits.W))

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
                       io.axi.write.resp.valid && io.axi.write.resp.ready,
                       io.axi.read.data.valid && io.axi.read.data.ready)
  io.dbus.rdata := sdata

  val writePc = RegInit(MakeValid(false.B, 0.U(32.W)))
  writePc := MuxCase(writePc, Array(
    io.axi.write.resp.valid -> MakeValid(false.B, 0.U(32.W)),
    (io.dbus.valid && io.dbus.write) -> MakeValid(true.B, io.dbus.pc),
  ))
  val writeAddr = RegInit(MakeValid(false.B, 0.U(32.W)))
  writeAddr := MuxCase(writeAddr, Array(
    io.axi.write.resp.valid -> MakeValid(false.B, 0.U(32.W)),
    (io.dbus.valid && io.dbus.write) -> MakeValid(true.B, io.dbus.addr),
  ))
  val writeAddrFired = RegInit(false.B)
  writeAddrFired := MuxCase(writeAddrFired, Array(
    (io.axi.write.addr.ready && io.axi.write.addr.valid) -> true.B,
    io.axi.write.resp.fire -> false.B,
  ))
  io.axi.write.addr.valid := io.dbus.valid && io.dbus.write && writeAddr.valid && !writeAddrFired
  io.axi.write.addr.bits.addr := writeAddr.bits
  io.axi.write.addr.bits.id := 0.U
  io.axi.write.addr.bits.prot := 2.U
  io.axi.write.addr.bits.size := Ctz(io.dbus.size)

  val writeData = RegInit(MakeValid(false.B, 0.U(io.dbus.wdata.getWidth.W)))
  writeData := MuxCase(writeData, Array(
    io.axi.write.resp.valid -> MakeValid(false.B, 0.U(io.dbus.wdata.getWidth.W)),
    (io.dbus.valid && io.dbus.write) -> MakeValid(true.B, io.dbus.wdata)
  ))
  val writeStrb = RegInit(MakeValid(false.B, 0.U(io.dbus.wmask.getWidth.W)))
  writeStrb := MuxCase(writeStrb, Array(
    io.axi.write.resp.valid -> MakeValid(false.B, 0.U(io.dbus.wmask.getWidth.W)),
    (io.dbus.valid && io.dbus.write) -> MakeValid(true.B, io.dbus.wmask)
  ))
  val writeDataFired = RegInit(false.B)
  writeDataFired := MuxCase(writeDataFired, Array(
    (io.axi.write.data.ready && io.axi.write.data.valid) -> true.B,
    io.axi.write.resp.fire -> false.B,
  ))
  io.axi.write.data.valid := io.dbus.valid && io.dbus.write && writeData.valid && !writeDataFired
  io.axi.write.data.bits.strb := writeStrb.bits
  io.axi.write.data.bits.data := writeData.bits
  io.axi.write.data.bits.last := true.B

  io.axi.write.resp.ready := io.axi.write.resp.valid

  val readPc = RegInit(MakeValid(false.B, 0.U(32.W)))
  readPc := MuxCase(readPc, Array(
    io.axi.read.data.valid -> MakeValid(false.B, 0.U(32.W)),
    (io.dbus.valid && !io.dbus.write && !sraddrActive) -> MakeValid(true.B, io.dbus.pc),
  ))
  val readAddr = RegInit(MakeValid(false.B, 0.U(32.W)))
  readAddr := MuxCase(readAddr, Array(
    io.axi.read.data.valid -> MakeValid(false.B, 0.U(32.W)),
    (io.dbus.valid && !io.dbus.write && !sraddrActive) -> MakeValid(true.B, io.dbus.addr),
  ))
  io.axi.read.addr.valid := io.dbus.valid && !io.dbus.write && !sraddrActive
  io.axi.read.addr.bits.addr := io.dbus.addr
  io.axi.read.addr.bits.id := 0.U
  io.axi.read.addr.bits.prot := 2.U
  io.axi.read.addr.bits.size := Ctz(io.dbus.size)

  io.axi.read.data.ready := true.B

  io.fault.valid := MuxCase(false.B, Array(
    io.axi.write.resp.valid ->
      ((io.axi.write.resp.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.write.resp.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
    io.axi.read.data.valid ->
      ((io.axi.read.data.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.read.data.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
  ))
  io.fault.bits.write := io.axi.write.resp.valid
  io.fault.bits.addr := MuxCase(0.U, Array(
    writeAddr.valid -> writeAddr.bits,
    readAddr.valid -> readAddr.bits,
  ))
  io.fault.bits.epc := MuxCase(0.U, Array(
    writePc.valid -> writePc.bits,
    readPc.valid -> readPc.bits,
  ))
}

object EmitDBus2Axi extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new DBus2Axi(p), args)
}
