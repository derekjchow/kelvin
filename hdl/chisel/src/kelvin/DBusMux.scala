// Copyright 2023 Google LLC
package kelvin

import chisel3._
import chisel3.util._
import common._

object DBusMux {
  def apply(p: Parameters): DBusMux = {
    return Module(new DBusMux(p))
  }
}

class DBusMux(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val vldst = Input(Bool())  // score.lsu
    val vlast = Input(Bool())  // vcore.vldst
    val vcore = Flipped(new DBusIO(p))
    val score = Flipped(new DBusIO(p))
    val dbus  = new DBusIO(p)
  })

  io.dbus.valid := Mux(io.vldst, io.vcore.valid, io.score.valid)
  io.dbus.write := Mux(io.vldst, io.vcore.write, io.score.write)
  io.dbus.addr  := Mux(io.vldst, io.vcore.addr,  io.score.addr)
  io.dbus.adrx  := Mux(io.vldst, io.vcore.adrx,  io.score.adrx)
  io.dbus.size  := Mux(io.vldst, io.vcore.size,  io.score.size)
  io.dbus.wdata := Mux(io.vldst, io.vcore.wdata, io.score.wdata)
  io.dbus.wmask := Mux(io.vldst, io.vcore.wmask, io.score.wmask)

  io.score.rdata := io.dbus.rdata
  io.vcore.rdata := io.dbus.rdata

  // Scalar core fifo syncs to vector core vldst, removed on last transaction.
  io.score.ready := io.dbus.ready && (!io.vldst || io.vcore.valid && io.vlast)
  io.vcore.ready := io.dbus.ready && io.vldst
}

object EmitDBusMux extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new DBusMux(p), args)
}
