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

package coralnpu

import chisel3._
import chisel3.util._

import bus.AxiMasterReadIO

object IBus2Axi {
  def apply(p: Parameters): IBus2Axi = {
    return Module(new IBus2Axi(p))
  }
}

class IBus2Axi(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val ibus = Flipped(new IBusIO(p))
    val axi = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })
  io.axi.defaults()

  val linebit = log2Ceil(p.lsuDataBits / 8)

  val sraddrActive = RegInit(false.B)
  val sdata = RegInit(0.U(p.axi2DataBits.W))

  when (io.axi.data.valid && io.axi.data.ready) {
    sraddrActive := false.B
    assert(sraddrActive)
    assert(!io.axi.addr.valid)
  } .elsewhen (io.axi.addr.valid && io.axi.addr.ready) {
    sraddrActive := true.B
    assert(!sraddrActive)
    assert(!io.axi.data.valid)
  }

  when (io.axi.data.valid && io.axi.data.ready) {
    sdata := io.axi.data.bits.data
  }

  io.ibus.ready := io.axi.data.valid && sraddrActive
  io.ibus.rdata := sdata

  val saddr = Cat(io.ibus.addr(31, linebit), 0.U(linebit.W))

  io.axi.addr.valid := io.ibus.valid && !sraddrActive
  io.axi.addr.bits.addr := saddr
  io.axi.addr.bits.id := 0.U
  io.axi.addr.bits.prot := 2.U

  io.axi.data.ready := true.B
}
