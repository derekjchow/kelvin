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

import bus.AxiMasterIO
import common._

class CoreAxiSlaveMux(p: Parameters, regions: Seq[MemoryRegion]) extends Module {
  val portCount = regions.length
  val io = IO(new Bundle {
    val axi_slave = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val ports = Vec(portCount, new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
  })

  // Today's map:
  // ITCM: (base + 0x0, base + 0x2000)
  // CSR: (base + 0x2000, base + 0x4000)
  // gap: (base + 0x4000, base + 0x8000)
  // DTCM: (base + 0x8000, base + 0x10000)
  val portTieOff = 0.U.asTypeOf(io.ports(0))
  val readTarget = RegInit(0.U(portCount.W))
  when (io.axi_slave.read.addr.valid && !readTarget.orR) {
    val contains = VecInit(regions.map(_.contains(io.axi_slave.read.addr.bits.addr))).asUInt
    assert(PopCount(contains) <= 1.U)
    readTarget := contains
  }

  for (i <- 0 until portCount) {
    when (readTarget(i)) {
      io.ports(i).read.addr <> io.axi_slave.read.addr
      io.ports(i).read.addr.bits.addr := io.axi_slave.read.addr.bits.addr & ~regions(i).memStart.U(p.fetchAddrBits.W)
      io.axi_slave.read.data <> io.ports(i).read.data
    } .otherwise {
      io.ports(i).read.addr <> portTieOff.read.addr
      portTieOff.read.data <> io.ports(i).read.data
    }
  }

  when (io.axi_slave.read.data.fire) {
    readTarget := 0.U(portCount.W)
  }

  val writeTarget = RegInit(0.U(portCount.W))
  when (io.axi_slave.write.addr.valid && !writeTarget.orR) {
    val contains = VecInit(regions.map(_.contains(io.axi_slave.write.addr.bits.addr))).asUInt
    assert(PopCount(contains) <= 1.U)
    writeTarget := contains
  }

  for (i <- 0 until portCount) {
    when (writeTarget(i)) {
      io.ports(i).write.addr <> io.axi_slave.write.addr
      io.ports(i).write.addr.bits.addr := io.axi_slave.write.addr.bits.addr & ~regions(i).memStart.U(p.fetchAddrBits.W)
      io.ports(i).write.data <> io.axi_slave.write.data
      io.axi_slave.write.resp <> io.ports(i).write.resp
    } .otherwise {
      io.ports(i).write.addr <> portTieOff.write.addr
      io.ports(i).write.data <> portTieOff.write.data
      portTieOff.write.resp <> io.ports(i).write.resp
    }
  }

  when (io.axi_slave.write.resp.fire) {
    writeTarget := 0.U(portCount.W)
  }

  io.axi_slave.write.addr.ready :=
    Mux(writeTarget.orR, io.ports(OHToUInt(writeTarget)).write.addr.ready, false.B)

  io.axi_slave.write.data.ready :=
    Mux(writeTarget.orR, io.ports(OHToUInt(writeTarget)).write.data.ready, false.B)

  io.axi_slave.write.resp.valid :=
    Mux(writeTarget.orR, io.ports(OHToUInt(writeTarget)).write.resp.valid, false.B)
  io.axi_slave.write.resp.bits.id :=
    Mux(writeTarget.orR, io.ports(OHToUInt(writeTarget)).write.resp.bits.id, 0.U)
  io.axi_slave.write.resp.bits.resp :=
    Mux(writeTarget.orR, io.ports(OHToUInt(writeTarget)).write.resp.bits.resp, 0.U)

  io.axi_slave.read.addr.ready :=
    Mux(readTarget.orR, io.ports(OHToUInt(readTarget)).read.addr.ready, false.B)

  io.axi_slave.read.data.valid :=
    Mux(readTarget.orR, io.ports(OHToUInt(readTarget)).read.data.valid, false.B)
  io.axi_slave.read.data.bits :=
    Mux(readTarget.orR, io.ports(OHToUInt(readTarget)).read.data.bits, 0.U.asTypeOf(io.axi_slave.read.data.bits))
}