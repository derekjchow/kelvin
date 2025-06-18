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

package bus

import chisel3._
import chisel3.util._

import bus._

object KelvinToTlul {
  object State extends ChiselEnum {
    val sIdle, sWaitForReady, sWaitForResponse = Value
  }

  def apply(tlul_p: TLULParameters, kelvin_p: kelvin.Parameters): KelvinToTlul = {
    return Module(new KelvinToTlul(tlul_p, kelvin_p))
  }
}

class KelvinToTlul(tlul_p: TLULParameters, kelvin_p: kelvin.Parameters) extends Module {
  import KelvinToTlul.State._

  val io = IO(new Bundle {
    val tl_i = Input(new TileLinkULIO_D2H(tlul_p))
    val tl_o = Output(new TileLinkULIO_H2D(tlul_p))
    val kelvin = Flipped(new KelvinMemIO(kelvin_p))
  })
  val state = RegInit(sIdle)

  val wmask_width = io.kelvin.wmask.getWidth
  val wmask_bits = (0 until wmask_width)
    .map(x => Mux(io.kelvin.wmask(x), 0xff.U(wmask_width.W) << (x * 8).U, 0.U(wmask_width.W)))
    .reduce(_ | _)

  io.tl_o := 0.U.asTypeOf(new TileLinkULIO_H2D(tlul_p))
  io.tl_o.a_user.instr_type := 9.U
  io.tl_o.a_source := 0.U
  io.tl_o.d_ready := true.B
  io.kelvin.rid := 0.U
  io.kelvin.cready := true.B
  io.kelvin.rvalid := false.B
  io.kelvin.rdata := 0.U
  io.tl_o.a_mask := -1.S(io.tl_o.a_mask.getWidth.W).asUInt
  io.tl_o.a_param := 0.U
  io.tl_o.a_size := 5.U

  // state            | transition       | next state
  // sIdle            | valid & a_ready  | sWaitForResponse
  // sIdle            | valid & !a_ready | sWaitForReady
  // sWaitForReady    | a_ready          | sWaitForResponse
  // sWaitForResponse | d_valid          | sIdle
  switch(state) {
    is(sIdle) {
      io.kelvin.cready := true.B
      when(io.kelvin.cvalid) {
        io.kelvin.cready := false.B
        io.tl_o.a_valid := true.B
        io.tl_o.a_address := io.kelvin.caddr
        val cwrite = io.kelvin.cwrite
        io.tl_o.a_opcode := Mux(cwrite, TLULOpcodesA.PutFullData.asUInt, TLULOpcodesA.Get.asUInt)
        io.tl_o.a_data := Mux(cwrite, io.kelvin.wdata & wmask_bits, 0.U)
        state := Mux(io.tl_i.a_ready, sWaitForResponse, sWaitForReady)
      }
    }
    is(sWaitForReady) {
      when(io.tl_i.a_ready) {
        state := sWaitForResponse
      }
    }
    is(sWaitForResponse) {
      io.tl_o.a_valid := false.B
      when(io.tl_i.d_valid) {
        val (value, valid) = TLULOpcodesD.safe(io.tl_i.d_opcode)
        val valid2 = valid && (value =/= TLULOpcodesD.End)
        assert(valid2, "Received invalid TLUL-D opcode\n")

        val rdata = chisel3.util.MuxLookup(value, 0.U(32.W))(
          Seq(
            TLULOpcodesD.AccessAck -> 0.U,
            TLULOpcodesD.AccessAckData -> io.tl_i.d_data
          )
        )
        val rvalid = chisel3.util.MuxLookup(value, false.B)(
          Seq(
            TLULOpcodesD.AccessAck -> false.B,
            TLULOpcodesD.AccessAckData -> true.B
          )
        )
        val rid = chisel3.util.MuxLookup(value, 0.U)(
          Seq(
            TLULOpcodesD.AccessAck -> 0.U,
            TLULOpcodesD.AccessAckData -> io.kelvin.cid
          )
        )
        io.kelvin.rvalid := rvalid
        io.kelvin.rdata := rdata
        io.kelvin.cready := true.B
        io.kelvin.rid := rid
        state := sIdle
      }
    }
  }
}
