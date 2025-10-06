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

import coralnpu.Parameters
import coralnpu.MemoryRegion

class TLULParameters(p: Parameters) {
  val w = p.axi2DataBits / 8
  val a = p.axi2AddrBits
  val z = log2Ceil(w)
  val o = p.axi2IdBits
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

class OpenTitanTileLink_A_User extends Bundle {
  val rsvd = UInt(5.W)
  val instr_type = UInt(4.W) // mubi4_t
  val cmd_intg = UInt(7.W)
  val data_intg = UInt(7.W)
}

class OpenTitanTileLink_D_User extends Bundle {
  val rsp_intg = UInt(7.W)
  val data_intg = UInt(7.W)
}

class NoUser extends Bundle {}

class TileLink_A_ChannelBase[T <: Data](p: TLULParameters, val userGen: () => T) extends Bundle {
  val opcode = UInt(3.W)
  val param = UInt(3.W)
  val size = UInt(p.z.W)
  val source = UInt(p.o.W)
  val address = UInt(p.a.W)
  val mask = UInt(p.w.W)
  val data = UInt((8 * p.w).W)
  val user = userGen()
}

class TileLink_D_ChannelBase[T <: Data](p: TLULParameters, val userGen: () => T) extends Bundle {
  val opcode = UInt(3.W)
  val param = UInt(3.W)
  val size = UInt(p.z.W)
  val source = UInt(p.o.W)
  val sink = UInt(p.i.W)
  val data = UInt((8 * p.w).W)
  val user = userGen()
  val error = Bool()
}

class TileLink_A_Channel(p: TLULParameters) extends TileLink_A_ChannelBase(p, () => new NoUser) {}
class TileLink_D_Channel(p: TLULParameters) extends TileLink_D_ChannelBase(p, () => new NoUser) {}

class TLULHost2Device[A_USER <: Data, D_USER <: Data](p: TLULParameters, userAGen: () => A_USER, userDGen: () => D_USER) extends Bundle {
  val a = Decoupled(new TileLink_A_ChannelBase(p, userAGen))
  val d = Flipped(Decoupled(new TileLink_D_ChannelBase(p, userDGen)))
}

class TLULDevice2Host[A_USER <: Data, D_USER <: Data](p: TLULParameters, userAGen: () => A_USER, userDGen: () => D_USER) extends Bundle {
  val a = Flipped(Decoupled(new TileLink_A_ChannelBase(p, userAGen)))
  val d = Decoupled(new TileLink_D_ChannelBase(p, userDGen))
}

object OpenTitanTileLink {
  class A_Channel(p: TLULParameters) extends TileLink_A_ChannelBase(p, () => new OpenTitanTileLink_A_User) {}
  class D_Channel(p: TLULParameters) extends TileLink_D_ChannelBase(p, () => new OpenTitanTileLink_D_User) {}
  class Host2Device(p: TLULParameters) extends TLULHost2Device(p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User) {}
  class Device2Host(p: TLULParameters) extends TLULDevice2Host(p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User) {}
}

// NB: Stuff below here is for ChAI -- it's not likely that you want
// to use these for new development.
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
    val host_d = io.hosts_d(source)
    val host_a = io.hosts_a(source)

    host_d :<>= device_d
    device_a :<>= host_a
  }
}