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

package kelvin

import chisel3._
import chisel3.util._
import _root_.circt.stage.ChiselStage

case class TLULParameters() {
  val w = 32
  val a = 32
  val z = 6
  val o = 10
  val i = 1
}

object TLULOpcodesA extends ChiselEnum {
  val PutFullData = Value(0.U(3.W))
  val PutPartialData = Value(1.U(3.W))
  val Get = Value(4.U(3.W))
  val End = Value(7.U(3.W))
}

object TLULOpcodesD extends ChiselEnum {
  val AccessAck = Value(0.U(3.W))
  val AccessAckData = Value(1.U(3.W))
  val End = Value(7.U(3.W))
}

class TileLinkULIO_H2D(p: TLULParameters) extends Bundle {
  val a_valid = (Bool())
  val a_opcode = (UInt(3.W))
  val a_param = (UInt(3.W))
  val a_size = (UInt(p.z.W))
  val a_source = (UInt(p.o.W))
  val a_address = (UInt(p.a.W))
  val a_mask = (UInt(p.w.W))
  val a_data = (UInt((8 * p.w).W))
  val a_user = new Bundle {
    val rsvd = UInt(5.W)
    val instr_type = UInt(4.W) // mubi4_t
    val cmd_intg = UInt(7.W)
    val data_intg = UInt(7.W)
  }
  val d_ready = (Bool())
}

class TileLinkULIO_D2H(p: TLULParameters) extends Bundle {
  val d_valid = (Bool())
  val d_opcode = (UInt(3.W))
  val d_param = (UInt(3.W))
  val d_size = (UInt(p.z.W))
  val d_source = (UInt(p.o.W))
  val d_sink = (UInt(p.i.W))
  val d_data = (UInt((8 * p.w).W))
  val d_user = new Bundle {
    val rsp_intg = UInt(7.W)
    val data_intg = UInt(7.W)
  }
  val d_error = (Bool())
  val a_ready = (Bool())
}

class TileLinkUL(p: TLULParameters, m: Seq[MemoryRegion], hosts: Int) extends Module {
  val devices = m.length
  val io = IO(new Bundle {
    val hosts_a = Vec(hosts, Input(new TileLinkULIO_H2D(p)))
    val hosts_d = Vec(hosts, Output(new TileLinkULIO_D2H(p)))
    val devices_a = Vec(devices, Output(new TileLinkULIO_H2D(p)))
    val devices_d = Vec(devices, Input(new TileLinkULIO_D2H(p)))
  })


  for (i <- 0 until hosts) {
    io.hosts_d(i) := 0.U.asTypeOf(new TileLinkULIO_D2H(p))
  }
  for (i <- 0 until devices) {
    io.devices_a(i) := 0.U.asTypeOf(new TileLinkULIO_H2D(p))
  }

  val aValids = io.hosts_a.map(x => x.a_valid)
  val anyAValid = PopCount(aValids) > 0.U
  when(anyAValid) {
    val aValidIndex = PriorityEncoder(aValids)
    val host_a = io.hosts_a(aValidIndex)
    val host_d = io.hosts_d(aValidIndex)
    val address = host_a.a_address

    val addressOk = (0 until devices).map(x => m(x).contains(address))
    val startAddresses = VecInit(m.map(x => x.memStart.U(p.a.W)))
    assert(PopCount(addressOk) === 1.U)
    val deviceIndex = PriorityEncoder(addressOk)
    val device_a = io.devices_a(deviceIndex)
    val device_d = io.devices_d(deviceIndex)

    device_a :<>= host_a
    device_a.a_address := host_a.a_address - startAddresses(deviceIndex)
    host_d :<>= device_d
  }

  val dValids = io.devices_d.map(x => x.d_valid)
  val anyDValid = dValids.reduce(_ || _)
  when(anyDValid) {
    val dValidIndex = PriorityEncoder(dValids)
    val device_d = io.devices_d(dValidIndex)
    val device_a = io.devices_a(dValidIndex)
    val source = device_d.d_source
    val sink = device_d.d_sink
    val host_d = io.hosts_d(source)
    val host_a = io.hosts_a(source)

    host_d :<>= device_d
    device_a :<>= host_a
  }
}
