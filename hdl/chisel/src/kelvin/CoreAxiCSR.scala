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

object CoreCsrAddrs {
  val DbgReqAddr = 0x1000.U
  val DbgReqData = 0x1004.U
  val DbgReqOp   = 0x1008.U
  val DbgRspData = 0x100c.U
  val DbgRspOp   = 0x1010.U
  val DbgStatus  = 0x1014.U
}

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
    val debug = Option.when(p.useDebugModule)(Flipped(new DebugModuleIO(p)))
  })

  // Bit 0 - Reset (Active High)
  // Bit 1 - Clock Gate (Active High)
  // By default, be in reset and with the clock gated.
  val resetReg = RegInit(3.U(p.fetchAddrBits.W))
  val pcStartReg = RegInit(0.U(p.fetchAddrBits.W))
  val statusReg = RegInit(0.U(p.fetchAddrBits.W))
  val debugReqAddrReg = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val debugReqDataReg = Option.when(p.useDebugModule)(RegInit(0.U(32.W)))
  val debugReqOpReg = Option.when(p.useDebugModule)(RegInit(DmReqOp.NOP.asUInt))

  val writeEn = io.fabric.writeDataAddr.valid && !io.internal
  val writeAddr = io.fabric.writeDataAddr.bits
  val writeData = io.fabric.writeDataBits

  val rsp_queue = if (p.useDebugModule) {
    val queue = Module(new Queue(new DebugModuleRspIO(p), 1))
    queue.io.enq <> io.debug.get.rsp

    val req_valid_pulse = RegInit(false.B)
    val write_to_op_reg = writeEn && writeAddr === CoreCsrAddrs.DbgReqOp
    req_valid_pulse := Mux(write_to_op_reg && io.debug.get.req.ready, true.B, false.B)
    io.debug.get.req.valid := req_valid_pulse

    io.debug.get.req.bits.address := debugReqAddrReg.get
    io.debug.get.req.bits.data := debugReqDataReg.get
    val (req_op, req_op_valid) = DmReqOp.safe(debugReqOpReg.get)
    io.debug.get.req.bits.op := Mux(req_op_valid, req_op, DmReqOp.NOP)

    val write_to_status_reg = writeEn && writeAddr === CoreCsrAddrs.DbgStatus
    queue.io.deq.ready := write_to_status_reg
    Some(queue)
  } else {
    None
  }

  val debugReadMap = if (p.useDebugModule) {
    val debugStatusReg = Cat(rsp_queue.get.io.deq.valid, io.debug.get.req.ready)
    Seq(
      CoreCsrAddrs.DbgReqAddr -> Cat(0.U(96.W), debugReqAddrReg.get),
      CoreCsrAddrs.DbgReqData -> Cat(0.U(64.W), debugReqDataReg.get, 0.U(32.W)),
      CoreCsrAddrs.DbgReqOp   -> Cat(0.U(32.W), debugReqOpReg.get, 0.U(64.W)),
      CoreCsrAddrs.DbgRspData -> Cat(rsp_queue.get.io.deq.bits.data, 0.U(96.W)),
      CoreCsrAddrs.DbgRspOp   -> Cat(0.U(96.W), rsp_queue.get.io.deq.bits.op.asUInt),
      CoreCsrAddrs.DbgStatus  -> Cat(0.U(64.W), debugStatusReg, 0.U(32.W)),
    )
  } else {
    Seq()
  }

  val readData =
    MuxLookup(io.fabric.readDataAddr.bits, 0.U)(Seq(
      0x0.U -> Cat(0.U(96.W), resetReg),
      0x4.U -> Cat(0.U(64.W), pcStartReg, 0.U(32.W)),
      0x8.U -> Cat(0.U(32.W), statusReg, 0.U(64.W)),
    ) ++ debugReadMap
      ++ ((0 until p.csrOutCount).map(
      x => ((0x100 + 4*x).U -> (io.kelvin_csr.value(x) << (32 * (x % 4)).U))
    )))

  val debugReadValidMap = if (p.useDebugModule) {
    Seq(
      CoreCsrAddrs.DbgReqAddr -> true.B,
      CoreCsrAddrs.DbgReqData -> true.B,
      CoreCsrAddrs.DbgReqOp   -> true.B,
      CoreCsrAddrs.DbgRspData -> true.B,
      CoreCsrAddrs.DbgRspOp   -> true.B,
      CoreCsrAddrs.DbgStatus  -> true.B,
    )
  } else {
    Seq()
  }

  val readDataValid =
    MuxLookup(io.fabric.readDataAddr.bits, false.B)(Seq(
      0x0.U -> true.B,
      0x4.U -> true.B,
      0x8.U -> true.B,
    ) ++ debugReadValidMap
      ++ ((0 until p.csrOutCount).map(x => ((0x100 + 4*x).U -> true.B))))

  // Delay reads by one cycle
  val readDataNext = Pipe(readDataValid, readData, 1)
  io.fabric.readData := readDataNext

  io.reset := resetReg(0)
  io.cg := resetReg(1)
  io.pcStart := pcStartReg
  statusReg := Cat(io.fault, io.halted)

  // Register writes
  resetReg := Mux(writeEn && writeAddr === 0x0.U, writeData(31,0), resetReg)
  pcStartReg := Mux(writeEn && writeAddr === 0x4.U, writeData(63,32), pcStartReg)
  if (p.useDebugModule) {
    debugReqAddrReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqAddr, writeData(31,0), debugReqAddrReg.get)
    debugReqDataReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqData, writeData(63,32), debugReqDataReg.get)
    debugReqOpReg.get := Mux(writeEn && writeAddr === CoreCsrAddrs.DbgReqOp, writeData(95,64), debugReqOpReg.get)
  }

  val debugWriteValidMap = if (p.useDebugModule) {
    Seq(
      CoreCsrAddrs.DbgReqAddr -> true.B,
      CoreCsrAddrs.DbgReqData -> true.B,
      CoreCsrAddrs.DbgReqOp   -> true.B,
      CoreCsrAddrs.DbgStatus  -> true.B,
    )
  } else {
    Seq()
  }

  io.fabric.writeResp := writeEn && MuxLookup(writeAddr, false.B)(Seq(
    0x0.U -> true.B,
    0x4.U -> true.B,
  ) ++ debugWriteValidMap)
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
  csr.io.kelvin_csr := io.kelvin_csr
  if (p.useDebugModule) {
    io.debug.get <> csr.io.debug.get
  }
}
