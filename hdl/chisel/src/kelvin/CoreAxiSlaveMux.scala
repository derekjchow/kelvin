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

class CoreAxiSlaveMux(p: Parameters, regions: Seq[MemoryRegion], sourceCount: Int) extends Module {
  val portCount = regions.length
  val io = IO(new Bundle {
    val axi_slave = Vec(sourceCount, Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)))
    val ports = Vec(portCount, new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
  })

  val portTieOff = 0.U.asTypeOf(io.ports(0))
  val sourceTieOff = 0.U.asTypeOf(io.axi_slave(0))
  val readTarget = RegInit(0.U(portCount.W))
  val readSource = RegInit(0.U(sourceCount.W))
  val readAddrValids = VecInit(io.axi_slave.map(_.read.addr.valid)).asUInt
  when (readAddrValids.orR && !readTarget.orR) {
    val source = PriorityEncoderOH(readAddrValids)
    readSource := source
    val contains = VecInit(regions.map(_.contains(io.axi_slave(OHToUInt(source)).read.addr.bits.addr))).asUInt
    assert(PopCount(contains) <= 1.U)
    readTarget := contains
  }

  for (i <- 0 until portCount) {
    when (readTarget(i)) {
      io.ports(i).read.addr <> io.axi_slave(OHToUInt(readSource)).read.addr
      io.ports(i).read.addr.bits.addr := io.axi_slave(OHToUInt(readSource)).read.addr.bits.addr & ~regions(i).memStart.U(p.fetchAddrBits.W)
      io.axi_slave(OHToUInt(readSource)).read.data <> io.ports(i).read.data
    } .otherwise {
      io.ports(i).read.addr <> portTieOff.read.addr
      portTieOff.read.data <> io.ports(i).read.data
    }
  }

  when (io.axi_slave(OHToUInt(readSource)).read.data.fire && io.axi_slave(OHToUInt(readSource)).read.data.bits.last) {
    readTarget := 0.U(portCount.W)
    readSource := 0.U(sourceCount.W)
  }

  val writeTarget = RegInit(0.U(portCount.W))
  val writeSource = RegInit(0.U(sourceCount.W))
  val writeAddrValids = VecInit(io.axi_slave.map(_.write.addr.valid)).asUInt
  when (writeAddrValids.orR && !writeTarget.orR) {
    val source = PriorityEncoderOH(writeAddrValids)
    writeSource := source
    val contains = VecInit(regions.map(_.contains(io.axi_slave(OHToUInt(source)).write.addr.bits.addr))).asUInt
    assert(PopCount(contains) <= 1.U)
    writeTarget := contains
  }

  for (i <- 0 until portCount) {
    when (writeTarget(i)) {
      io.ports(i).write.addr <> io.axi_slave(OHToUInt(writeSource)).write.addr
      io.ports(i).write.addr.bits.addr := io.axi_slave(OHToUInt(writeSource)).write.addr.bits.addr & ~regions(i).memStart.U(p.fetchAddrBits.W)
      io.ports(i).write.data <> io.axi_slave(OHToUInt(writeSource)).write.data
      io.axi_slave(OHToUInt(writeSource)).write.resp <> io.ports(i).write.resp
    } .otherwise {
      io.ports(i).write.addr <> portTieOff.write.addr
      io.ports(i).write.data <> portTieOff.write.data
      portTieOff.write.resp <> io.ports(i).write.resp
    }
  }

  when (io.axi_slave(OHToUInt(writeSource)).write.resp.fire) {
    writeTarget := 0.U(portCount.W)
    writeSource := 0.U(sourceCount.W)
  }

  for (i <- 0 until sourceCount) {
    io.axi_slave(i).write.addr.ready :=
      Mux(writeTarget.orR && OHToUInt(writeSource) === i.U,
          io.ports(OHToUInt(writeTarget)).write.addr.ready, false.B)

    io.axi_slave(i).write.data.ready :=
      Mux(writeTarget.orR && OHToUInt(writeSource) === i.U,
          io.ports(OHToUInt(writeTarget)).write.data.ready, false.B)

    io.axi_slave(i).write.resp.valid :=
      Mux(writeTarget.orR && OHToUInt(writeSource) === i.U,
          io.ports(OHToUInt(writeTarget)).write.resp.valid, false.B)
    io.axi_slave(i).write.resp.bits.id :=
      Mux(writeTarget.orR && OHToUInt(writeSource) === i.U,
          io.ports(OHToUInt(writeTarget)).write.resp.bits.id, 0.U)
    io.axi_slave(i).write.resp.bits.resp :=
      Mux(writeTarget.orR && OHToUInt(writeSource) === i.U,
          io.ports(OHToUInt(writeTarget)).write.resp.bits.resp, 0.U)

    io.axi_slave(i).read.addr.ready :=
      Mux(readTarget.orR && OHToUInt(readSource) === i.U,
          io.ports(OHToUInt(readTarget)).read.addr.ready, false.B)

    io.axi_slave(i).read.data.valid :=
      Mux(readTarget.orR && OHToUInt(readSource) === i.U,
          io.ports(OHToUInt(readTarget)).read.data.valid, false.B)
    io.axi_slave(i).read.data.bits :=
      Mux(readTarget.orR && OHToUInt(readSource) === i.U,
          io.ports(OHToUInt(readTarget)).read.data.bits, 0.U.asTypeOf(io.axi_slave(i).read.data.bits))
  }
}