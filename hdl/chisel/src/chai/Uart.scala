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

package chai

import chisel3._
import chisel3.util._

class Uart(tlul_p: kelvin.TLULParameters) extends BlackBox {
  val io = IO(new Bundle {
    val clk_i = Input(Clock())
    val rst_ni = Input(AsyncReset())

    val tl_i = Input(new kelvin.TileLinkULIO_H2D(tlul_p))
    val tl_o = Output(new kelvin.TileLinkULIO_D2H(tlul_p))

    // These have some alert_{rx|tx}_t types.
    val alert_rx_i = Input(UInt(4.W))
    val alert_tx_o = Output(UInt(2.W))

    val cio_rx_i = Input(Bool())
    val cio_tx_o = Output(Bool())
    val cio_tx_en_o = Output(Bool())

    val intr_tx_watermark_o = Output(Bool())
    val intr_rx_watermark_o = Output(Bool())
    val intr_tx_empty_o = Output(Bool())
    val intr_rx_overflow_o = Output(Bool())
    val intr_rx_frame_err_o = Output(Bool())
    val intr_rx_break_err_o = Output(Bool())
    val intr_rx_timeout_o = Output(Bool())
    val intr_rx_parity_err_o = Output(Bool())
  })
}
