package kelvin

import chisel3._
import chisel3.util._
import common._

// Debug signals for HDL development.
class DebugIO(p: Parameters) extends Bundle {
  val en = Output(UInt(4.W))
  val addr0 = Output(UInt(32.W))
  val addr1 = Output(UInt(32.W))
  val addr2 = Output(UInt(32.W))
  val addr3 = Output(UInt(32.W))
  val inst0 = Output(UInt(32.W))
  val inst1 = Output(UInt(32.W))
  val inst2 = Output(UInt(32.W))
  val inst3 = Output(UInt(32.W))
  val cycles = Output(UInt(32.W))
}
