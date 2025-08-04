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

import bus._



package object sram_params {
  val SramAw = 17
  val SramDw = 256
  val Outstanding = 1
  val ByteAccess = 1
  val ErrOnRead = 0
  val EnableDataIntgPt = 0
}

class TlulAdapterSram(p: TLULParameters) extends BlackBox {
  val io = IO(new Bundle {
    val clk_i = Input(Clock())
    val rst_ni = Input(AsyncReset())

    // TL-UL
    val tl_i = Input(new TileLinkULIO_H2D(p))
    val tl_o = Output(new TileLinkULIO_D2H(p))

    // control
    val en_ifetch_i = Input(UInt(4.W)) // mubi4_t

    // SRAM interface
    val req_o = Output(Bool())
    val req_type_o = Output(UInt(4.W)) // mubi4_t
    val gnt_i = Input(Bool())
    val we_o = Output(Bool())
    val addr_o = Output(UInt(sram_params.SramAw.W))
    val wdata_o = Output(UInt(sram_params.SramDw.W))
    val wmask_o = Output(UInt(sram_params.SramDw.W))
    val intg_error_o = Output(Bool())
    val rdata_i = Input(UInt(sram_params.SramDw.W))
    val rvalid_i = Input(Bool())
    val rerror_i = Input(UInt(2.W))
  })
}
