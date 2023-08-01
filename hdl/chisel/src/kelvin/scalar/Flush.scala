package kelvin

import chisel3._
import chisel3.util._
import common._

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

class DFlushFenceiIO(p: Parameters) extends DFlushIO(p) {
  val fencei = Output(Bool())
}
