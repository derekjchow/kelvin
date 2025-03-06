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

class CoreCSR(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val fabric = Flipped(new FabricIO(p))
    // Input indicating that the transaction is coming from inside Kelvin.
    val internal = Input(Bool())

    val reset = Output(Bool())
    val cg = Output(Bool())
    val pcStart = Output(UInt(p.fetchAddrBits.W))
    val halted = Input(Bool())
    val fault = Input(Bool())
    val kelvin_csr = Input(new CsrOutIO(p))
  })

  // Bit 0 - Reset (Active High)
  // Bit 1 - Clock Gate (Active High)
  // By default, be in reset and with the clock gated.
  val resetReg = RegInit(3.U(p.fetchAddrBits.W))
  val pcStartReg = RegInit(0.U(p.fetchAddrBits.W))
  val statusReg = RegInit(0.U(p.fetchAddrBits.W))

  val readData =
    MuxLookup(io.fabric.readDataAddr.bits, 0.U)(Seq(
      0x0.U -> Cat(0.U(96.W), resetReg),
      0x4.U -> Cat(0.U(64.W), pcStartReg, 0.U(32.W)),
      0x8.U -> Cat(0.U(32.W), statusReg, 0.U(64.W)),
    ) ++ ((0 until p.csrOutCount).map(
      x => ((0x100 + 4*x).U -> (io.kelvin_csr.value(x) << (32 * (x % 4)).U))
    )))
  val readDataValid =
    MuxLookup(io.fabric.readDataAddr.bits, false.B)(Seq(
      0x0.U -> true.B,
      0x4.U -> true.B,
      0x8.U -> true.B,
    ) ++ ((0 until p.csrOutCount).map(x => ((0x100 + 4*x).U -> true.B))))

  // Delay reads by one cycle
  val readDataNext = RegInit(MakeValid(false.B, 0.U(p.axi2DataBits.W)))
  readDataNext := MakeValid(readDataValid, readData)
  io.fabric.readData := readDataNext

  io.reset := resetReg(0)
  io.cg := resetReg(1)
  io.pcStart := pcStartReg
  statusReg := Cat(io.fault, io.halted)

  // TODO(atv): What bits are allowed to change in these? Add a mask or something.
  resetReg := Mux(io.fabric.writeDataAddr.valid && io.fabric.writeDataAddr.bits === 0x0.U && !io.internal, io.fabric.writeDataBits(31,0), resetReg)
  pcStartReg := Mux(io.fabric.writeDataAddr.valid && io.fabric.writeDataAddr.bits === 0x4.U && !io.internal, io.fabric.writeDataBits(63,32), pcStartReg)
  io.fabric.writeResp := io.fabric.writeDataAddr.valid && MuxLookup(io.fabric.writeDataAddr.bits, false.B)(Seq(
    0x0.U -> true.B,
    0x4.U -> true.B,
  ))
}

class CoreAxiCSR(p: Parameters,
                    axiReadAddrDelay: Int = 0,
                    axiReadDataDelay: Int = 0) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    // Input indicating that the transaction is coming from inside Kelvin.
    val internal = Input(Bool())

    val reset = Output(Bool())
    val cg = Output(Bool())
    val pcStart = Output(UInt(p.fetchAddrBits.W))
    val halted = Input(Bool())
    val fault = Input(Bool())
    val kelvin_csr = Input(new CsrOutIO(p))
  })

  val axi = Module(new AxiSlave(p))
  // Optionally delay AXI read channel. This helps break up single cycle read path into into multi cycle as necessary to meet timing
  io.axi.write <> axi.io.axi.write
  axi.io.axi.read.addr <> Queue(io.axi.read.addr, axiReadAddrDelay)
  io.axi.read.data <> Queue(axi.io.axi.read.data, axiReadDataDelay)

  axi.io.periBusy := false.B

  val csr = Module(new CoreCSR(p))
  csr.io.fabric <> axi.io.fabric
  csr.io.internal := io.internal

  io.reset := csr.io.reset
  io.cg := csr.io.cg
  io.pcStart := csr.io.pcStart
  csr.io.halted := io.halted
  csr.io.fault := io.fault
  csr.io.kelvin_csr := io.kelvin_csr
}
