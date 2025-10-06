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

import bus.AxiMasterIO

object CoreCsrAddrs {
  val DbgReqAddr = 0x800.U
  val DbgReqData = 0x804.U
  val DbgReqOp   = 0x808.U
  val DbgRspData = 0x80c.U
  val DbgRspOp   = 0x810.U
  val DbgStatus  = 0x814.U
}

class CoreCSR(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val fabric = Flipped(new FabricIO(p))
    // Input indicating that the transaction is coming from inside CoralNPU.
    val internal = Input(Bool())

    val reset = Output(Bool())
    val cg = Output(Bool())
    val pcStart = Output(UInt(p.fetchAddrBits.W))
    val halted = Input(Bool())
    val fault = Input(Bool())
    val coralnpu_csr = Input(new CsrOutIO(p))
    val debug = Option.when(p.useDebugModule)(Flipped(new DebugModuleIO(p)))
  })

  // Bit 0 - Reset (Active High)
  // Bit 1 - Clock Gate (Active High)
  // By default, be in reset and with the clock gated.
  val resetReg = RegInit(3.U(p.fetchAddrBits.W))
  val pcStartReg = RegInit(0.U(p.fetchAddrBits.W))
  val statusReg = RegInit(0.U(p.fetchAddrBits.W))

  // Debug module registers, conditionally present.
  val debugReqAddrReg = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val debugReqDataReg = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val debugReqOpReg = Option.when(p.useDebugModule)(RegInit(DmReqOp.NOP.asUInt))

  val writeEn = io.fabric.writeDataAddr.valid && !io.internal
  val writeAddr = io.fabric.writeDataAddr.bits
  val writeData = io.fabric.writeDataBits

  // Debug module handling logic.
  val rsp_queue = if (p.useDebugModule) {
    // Queue for debug responses.
    val queue = Module(new Queue(new DebugModuleRspIO(p), 1))
    queue.io.enq <> io.debug.get.rsp

    // Pulse valid signal for a single cycle on a write to the op register.
    val req_valid_pulse = RegInit(false.B)
    val write_to_op_reg = writeEn && writeAddr === CoreCsrAddrs.DbgReqOp
    req_valid_pulse := Mux(write_to_op_reg && io.debug.get.req.ready, true.B, false.B)
    io.debug.get.req.valid := req_valid_pulse

    // Wire up debug request signals.
    io.debug.get.req.bits.address := debugReqAddrReg.get
    io.debug.get.req.bits.data := debugReqDataReg.get
    val (req_op, req_op_valid) = DmReqOp.safe(debugReqOpReg.get)
    io.debug.get.req.bits.op := Mux(req_op_valid, req_op, DmReqOp.NOP)

    // Dequeue from the response queue when the status register is written to.
    val write_to_status_reg = writeEn && writeAddr === CoreCsrAddrs.DbgStatus
    queue.io.deq.ready := write_to_status_reg
    Some(queue)
  } else {
    None
  }

  val readAddr = io.fabric.readDataAddr.bits
  // Align the read address to the AXI data bus width.
  val alignedAddr = readAddr & ~((p.axi2DataBytes - 1).U(readAddr.getWidth.W))

  val kRegWidthBits = 32
  val kRegWidthBytes = kRegWidthBits / 8
  val kCsrBaseAddr = 0x100

  val regsPerBus = p.axi2DataBits / kRegWidthBits
  val readData = Wire(Vec(regsPerBus, UInt(kRegWidthBits.W)))
  for (i <- 0 until regsPerBus) {
    readData(i) := 0.U
  }

  // Map of core control registers.
  val coreRegMap = Map(
    0x0 -> resetReg,
    0x4 -> pcStartReg,
    0x8 -> statusReg,
  )

  // Map of CoralNPU's internal CSRs.
  val csrRegs = io.coralnpu_csr.value
  val csrRegMap = (0 until p.csrOutCount).map { i =>
    (kCsrBaseAddr + i * kRegWidthBytes) -> csrRegs(i)
  }.toMap

  // Map of debug registers, conditionally present.
  val debugReadMap = if (p.useDebugModule) {
    val debugStatusReg = Cat(rsp_queue.get.io.deq.valid, io.debug.get.req.ready)
    val regs = Seq(
      CoreCsrAddrs.DbgReqAddr -> debugReqAddrReg.get,
      CoreCsrAddrs.DbgReqData -> debugReqDataReg.get,
      CoreCsrAddrs.DbgReqOp   -> debugReqOpReg.get,
      CoreCsrAddrs.DbgRspData -> rsp_queue.get.io.deq.bits.data,
      CoreCsrAddrs.DbgRspOp   -> rsp_queue.get.io.deq.bits.op.asUInt,
      CoreCsrAddrs.DbgStatus  -> debugStatusReg,
    )
    regs.map { case (k, v) => k.litValue.toInt -> v }.toMap
  } else {
    Map[Int, Data]()
  }

  // Combine all register maps.
  val allReadRegs = coreRegMap ++ csrRegMap ++ debugReadMap

  // Group registers by their aligned base address to prevent multiple writers.
  val groupedRegs = allReadRegs.groupBy { case (offset, _) =>
    offset & ~(p.axi2DataBytes - 1)
  }

  // Generate read logic for all registers.
  for ((base, regs) <- groupedRegs) {
    when(alignedAddr === base.U) {
      for ((offset, reg) <- regs) {
        // Place the register value into the correct 32-bit lane of the output bus.
        readData((offset % p.axi2DataBytes) / kRegWidthBytes) := reg
      }
    }
  }

  // A read is valid if it hits any of the registers in our map.
  val readDataValid = MuxLookup(readAddr, false.B)(
    allReadRegs.keys.map(addr => (addr.U -> true.B)).toSeq
  )

  // Delay reads by one cycle for timing.
  val readDataNext = Pipe(readDataValid, readData.asUInt, 1)
  io.fabric.readData := readDataNext

  io.reset := resetReg(0)
  io.cg := resetReg(1)
  io.pcStart := pcStartReg
  statusReg := Cat(io.fault, io.halted)

  // Register write logic.
  resetReg := Mux(writeEn && writeAddr === 0x0.U, writeData(31,0), resetReg)
  pcStartReg := Mux(writeEn && writeAddr === 0x4.U, writeData(63,32), pcStartReg)
  if (p.useDebugModule) {
    debugReqAddrReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqAddr, writeData(31,0), debugReqAddrReg.get)
    debugReqDataReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqData, writeData(63,32), debugReqDataReg.get)
    debugReqOpReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqOp, writeData(95,64), debugReqOpReg.get)
  }

  // Map of valid write addresses for the debug module.
  val debugWriteValidMap = if (p.useDebugModule) {
    Map(
      CoreCsrAddrs.DbgReqAddr.litValue.toInt -> true.B,
      CoreCsrAddrs.DbgReqData.litValue.toInt -> true.B,
      CoreCsrAddrs.DbgReqOp.litValue.toInt   -> true.B,
      CoreCsrAddrs.DbgStatus.litValue.toInt  -> true.B,
    )
  } else {
    Map[Int, Bool]()
  }

  val allWriteRegs = Map(
    0x0 -> true.B,
    0x4 -> true.B,
  ) ++ debugWriteValidMap

  io.fabric.writeResp := writeEn && MuxLookup(writeAddr, false.B)(
    allWriteRegs.map { case (k, v) => k.U -> v }.toSeq
  )
}

class CoreAxiCSR(p: Parameters,
                    axiReadAddrDelay: Int = 0,
                    axiReadDataDelay: Int = 0) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    // Input indicating that the transaction is coming from inside CoralNPU.
    val internal = Input(Bool())

    val reset = Output(Bool())
    val cg = Output(Bool())
    val pcStart = Output(UInt(p.fetchAddrBits.W))
    val halted = Input(Bool())
    val fault = Input(Bool())
    val coralnpu_csr = Input(new CsrOutIO(p))
    val debug = Option.when(p.useDebugModule)(Flipped(new DebugModuleIO(p)))
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
  csr.io.coralnpu_csr := io.coralnpu_csr
  if (p.useDebugModule) {
    io.debug.get <> csr.io.debug.get
  }
}
