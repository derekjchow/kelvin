// Copyright 2023 Google LLC
package kelvin

import chisel3._
import chisel3.util._
import common._

class ClockGate extends BlackBox {
  val io = IO(new Bundle {
    val clk_i  = Input(Clock())
    val enable = Input(Bool())  // '1' passthrough, '0' disable.
    val clk_o  = Output(Clock())
  })
}
