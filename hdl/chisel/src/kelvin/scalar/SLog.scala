package kelvin

import chisel3._
import chisel3.util._
import common._

// Scalar instrumentation logging (printf).
class SLogIO(p: Parameters) extends Bundle {
  val valid = Output(Bool())
  val addr = Output(UInt(5.W))
  val data = Output(UInt(32.W))
}
