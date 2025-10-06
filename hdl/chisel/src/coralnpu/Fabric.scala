// Copyright 2025 Google LLC
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

import common._

// Picks one of two fabric commands to route to a port. Priority is given to the
// first port.
class FabricArbiter(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val source = Vec(2, Flipped(new FabricIO(p)))
    val fabricBusy = Output(Bool())  // Back pressure for the second port
    val port = new FabricIO(p)
  })
  // Only read, or only write (or none) can be issued.
  assert(!(io.source(0).readDataAddr.valid && io.source(0).writeDataAddr.valid))
  assert(!(io.source(1).readDataAddr.valid && io.source(1).writeDataAddr.valid))
  val source0Valid = io.source(0).readDataAddr.valid ||
                     io.source(0).writeDataAddr.valid

  io.fabricBusy := source0Valid

  io.port.readDataAddr  := Mux(source0Valid, io.source(0).readDataAddr,
                                             io.source(1).readDataAddr)
  io.port.writeDataAddr := Mux(source0Valid, io.source(0).writeDataAddr,
                                             io.source(1).writeDataAddr)
  io.port.writeDataBits := Mux(source0Valid, io.source(0).writeDataBits,
                                             io.source(1).writeDataBits)
  io.port.writeDataStrb := Mux(source0Valid, io.source(0).writeDataStrb,
                                             io.source(1).writeDataStrb)

  // Broadcast SRAM outputs back
  io.source(0).readData := io.port.readData
  io.source(1).readData := io.port.readData
  io.source(0).writeResp := io.port.writeResp
  io.source(1).writeResp := io.port.writeResp
}

// Routes one fabric command from source to a given port.
class FabricMux(p: Parameters, regions: Seq[MemoryRegion]) extends Module {
  val portCount = regions.length
  val portIdxBits = log2Ceil(portCount)
  val portIdxType = UInt(log2Ceil(portCount).W)
  val io = IO(new Bundle {
    val source = Flipped(new FabricIO(p))
    val fabricBusy = Output(Bool())

    val ports = Vec(portCount, new FabricIO(p))
    val periBusy = Vec(portCount, Input(Bool()))
  })

  // Only read, or only write (or none) can be issued.
  assert(!(io.source.readDataAddr.valid && io.source.writeDataAddr.valid))

  // Determine which port to forward command to
  val sourceValid = io.source.readDataAddr.valid ||
                    io.source.writeDataAddr.valid
  val addr = MuxCase(0.U, Seq(
    io.source.readDataAddr.valid -> io.source.readDataAddr.bits,
    io.source.writeDataAddr.valid -> io.source.writeDataAddr.bits,
  ))
  val selected = MuxCase(MakeInvalid(portIdxType), (0 until portCount).map(
    x => (sourceValid && regions(x).contains(addr)) ->
        MakeValid(true.B, x.U(portIdxBits.W))
  ))

  val portSelected = (0 until portCount).map(
      i => selected.valid && (selected.bits === i.U) && !io.periBusy(i))
  assert(PopCount(VecInit(portSelected)) <= 1.U)  // Should only select one port

  io.fabricBusy := MuxCase(false.B, (0 until portCount).map(
    i => (selected.valid && (selected.bits === i.U)) -> io.periBusy(i)
  ))

  // Forward commands to ports
  for (i <- 0 until portCount) {
    val readAddr = io.source.readDataAddr.bits &
        ~regions(i).memStart.U(p.fetchAddrBits.W)
    val writeAddr = io.source.writeDataAddr.bits &
        ~regions(i).memStart.U(p.fetchAddrBits.W)

    io.ports(i).readDataAddr.valid :=
        portSelected(i) && io.source.readDataAddr.valid
    io.ports(i).readDataAddr.bits := Mux(portSelected(i), readAddr, 0.U)
    io.ports(i).writeDataAddr.valid :=
        portSelected(i) && io.source.writeDataAddr.valid
    io.ports(i).writeDataAddr.bits := Mux(portSelected(i), writeAddr, 0.U)
    io.ports(i).writeDataBits := 
        Mux(portSelected(i), io.source.writeDataBits, 0.U)
    io.ports(i).writeDataStrb := 
        Mux(portSelected(i), io.source.writeDataStrb, 0.U)
  }

  // Pick writeResp from the correct port
  io.source.writeResp := MuxCase(false.B, (0 until portCount).map(
      i => portSelected(i) -> io.ports(i).writeResp,
  ))

  // Pick readData from the correct port. Should be delayed by one cycle to
  // match behaviours of peripherals.
  val lastReadSelected = RegInit(MakeInvalid(portIdxType))
  lastReadSelected := MuxCase(MakeInvalid(portIdxType), (0 until portCount).map(
    i => (portSelected(i) && io.source.readDataAddr.valid) ->
        MakeValid(true.B, i.U(portIdxBits.W))
  ))
  io.source.readData := MuxCase(MakeInvalid(UInt(p.axi2DataBits.W)),
        (0 until portCount).map(i =>
            (lastReadSelected.valid && (lastReadSelected.bits === i.U)) ->
                io.ports(i).readData
        )
  )
}