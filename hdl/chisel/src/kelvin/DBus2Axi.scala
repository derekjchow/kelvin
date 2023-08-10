// Copyright 2023 Google LLC
package kelvin

import chisel3._
import chisel3.util._
import common._

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
                       io.axi.write.addr.valid && io.axi.write.addr.ready,
                       io.axi.read.data.valid && sraddrActive)
  io.dbus.rdata := sdata

  val saddr = Cat(io.dbus.addr(31, linebit), 0.U(linebit.W))

  io.axi.write.addr.valid := io.dbus.valid && io.dbus.write
  io.axi.write.addr.bits.addr := saddr
  io.axi.write.addr.bits.id := 0.U

  io.axi.write.data.valid := io.dbus.valid && io.dbus.write
  io.axi.write.data.bits.strb := io.dbus.wmask
  io.axi.write.data.bits.data := io.dbus.wdata

  io.axi.write.resp.ready := true.B

  io.axi.read.addr.valid := io.dbus.valid && !io.dbus.write && !sraddrActive
  io.axi.read.addr.bits.addr := saddr
  io.axi.read.addr.bits.id := 0.U

  io.axi.read.data.ready := true.B
}

object EmitDBus2Axi extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new DBus2Axi(p), args)
}
