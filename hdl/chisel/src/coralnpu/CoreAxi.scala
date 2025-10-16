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

import bus._
import common._

class CoreAxi(p: Parameters, coreModuleName: String) extends RawModule {
  override val desiredName = coreModuleName + "Axi"
  val memoryRegions = p.m
  val io = IO(new Bundle {
    // AXI
    val aclk = Input(Clock())
    val aresetn = Input(AsyncReset())
    // ITCM, DTCM, CSR
    val axi_slave = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val axi_master = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    // Core status interrupts
    val halted = Output(Bool())
    val fault = Output(Bool())
    val wfi = Output(Bool())
    val irq = Input(Bool())
    // Debug data interface
    val debug = new DebugIO(p)
    // String logging interface
    val slog = new SLogIO(p)
    val te = Input(Bool())
  })
  dontTouch(io)

  val rst_sync = Module(new RstSync())
  rst_sync.io.clk_i := io.aclk
  rst_sync.io.rstn_i := io.aresetn
  rst_sync.io.clk_en := true.B
  rst_sync.io.te := io.te

  val global_reset = (!Mux(io.te, io.aresetn, rst_sync.io.rstn_o).asBool).asAsyncReset
  withClockAndReset(rst_sync.io.clk_o, global_reset) {
    // Build CSR
    val csr = Module(new CoreCSR(p))
    csr.io.internal := false.B

    // Build core and connect with CSR
    val cg = Module(new ClockGate)
    cg.io.clk_i := rst_sync.io.clk_o
    cg.io.te := io.te

    val dm = Option.when(p.useDebugModule)(Module(new DebugModule(p)))
    if (p.useDebugModule) {
      dontTouch(dm.get.io)
      val dmEnable = RegInit(false.B)
      dmEnable := true.B
      dm.get.io.ext.req <> GateDecoupled(csr.io.debug.get.req, dmEnable)
      csr.io.debug.get.rsp <> GateDecoupled(dm.get.io.ext.rsp, dmEnable)
    }

    val core_reset = Mux(io.te, (!io.aresetn.asBool).asAsyncReset, (csr.io.reset || dm.map(_.io.ndmreset).getOrElse(false.B)).asAsyncReset)
    val core = withClockAndReset(cg.io.clk_o, core_reset) { Core(p, coreModuleName) }
    cg.io.enable := io.irq || (!csr.io.cg && !core.io.wfi) || dm.map(_.io.haltreq(0)).getOrElse(false.B)
    io.halted := core.io.halted
    io.fault := core.io.fault
    io.wfi := core.io.wfi
    core.io.irq := io.irq || dm.map(_.io.haltreq(0)).getOrElse(false.B)
    csr.io.halted := core.io.halted
    csr.io.fault := core.io.fault
    csr.io.coralnpu_csr := core.io.csr.out
    core.io.debug_req := true.B
    core.io.csr.in.value(0) := csr.io.pcStart
    for (i <- 1 until p.csrInCount) {
      core.io.csr.in.value(i) := 0.U
    }
    io.slog <> core.io.slog
    io.debug <> core.io.debug
    // Tie-offs (no cache to flush)
    core.io.dflush.ready := true.B
    core.io.iflush.ready := true.B


    if (p.useDebugModule) {
      core.io.dm.get.debug_req := dm.get.io.haltreq(0)
      core.io.dm.get.resume_req := dm.get.io.resumereq(0)
      dm.get.io.resumeack(0) := !core.io.dm.get.debug_mode && RegNext(core.io.dm.get.debug_mode, false.B)
      dm.get.io.halted(0) := core.io.dm.get.debug_mode
      dm.get.io.running(0) := !core.io.dm.get.debug_mode
      dm.get.io.havereset(0) := false.B
      core.io.dm.get.csr := dm.get.io.csr
      core.io.dm.get.csr_rs1 := dm.get.io.csr_rs1
      dm.get.io.csr_rd := core.io.dm.get.csr_rd
      dm.get.io.scalar_rd <> core.io.dm.get.scalar_rd
      dm.get.io.scalar_rs <> core.io.dm.get.scalar_rs
      if (p.enableFloat) {
        dm.get.io.float_rd.get <> core.io.dm.get.float_rd.get
        dm.get.io.float_rs.get <> core.io.dm.get.float_rs.get
      }
    }

    // Build ITCM and connect to ibus
    val itcmSizeBytes: Int = 1024 * (if (p.tcmHighmem) { 1024 } else { 8 }) // default 8 kB, highmem 1MB
    val itcmSubEntryWidth = 8
    val itcmWidth = p.axi2DataBits
    val itcmEntries = itcmSizeBytes / (itcmWidth / 8)
    val itcm = Module(new TCM128(itcmSizeBytes, itcmSubEntryWidth))
    dontTouch(itcm.io)
    val itcmWrapper = Module(new SRAM(p, log2Ceil(itcmEntries)))
    itcm.io.addr := itcmWrapper.io.sram.address
    itcm.io.enable := itcmWrapper.io.sram.enable
    itcm.io.write := itcmWrapper.io.sram.isWrite
    itcm.io.wdata := itcmWrapper.io.sram.writeData
    itcm.io.wmask := itcmWrapper.io.sram.mask
    itcmWrapper.io.sram.readData := itcm.io.rdata
    val itcmArbiter = Module(new FabricArbiter(p))
    itcmArbiter.io.port <> itcmWrapper.io.fabric
    itcmArbiter.io.source(0).readDataAddr := MakeValid(
        core.io.ibus.valid, core.io.ibus.addr)
    itcmArbiter.io.source(0).writeDataAddr :=
        MakeInvalid(UInt(p.axi2AddrBits.W))
    itcmArbiter.io.source(0).writeDataBits := 0.U
    itcmArbiter.io.source(0).writeDataStrb := 0.U
    core.io.ibus.rdata := itcmArbiter.io.source(0).readData.bits
    core.io.ibus.ready := true.B  // Can always read from TCM
    /// Connect fault for the ibus.
    core.io.ibus.fault.valid :=
        core.io.ibus.valid && !(memoryRegions(0).contains(core.io.ibus.addr))
    core.io.ibus.fault.bits.write := false.B
    core.io.ibus.fault.bits.addr := 0.U
    core.io.ibus.fault.bits.epc := core.io.ibus.addr

    // Build DTCM and connect to dbus
    val dtcmSizeBytes: Int = 1024 * (if (p.tcmHighmem) { 1024 } else { 32 }) // default 32 kB, highmem 1MB
    val dtcmWidth = p.axi2DataBits
    val dtcmEntries = dtcmSizeBytes / (dtcmWidth / 8)
    val dtcmSubEntryWidth = 8
    val dtcm = Module(new TCM128(dtcmSizeBytes, dtcmSubEntryWidth))
    dontTouch(dtcm.io)
    val dtcmWrapper = Module(new SRAM(p, log2Ceil(dtcmEntries)))
    dtcm.io.addr := dtcmWrapper.io.sram.address
    dtcm.io.enable := dtcmWrapper.io.sram.enable
    dtcm.io.write := dtcmWrapper.io.sram.isWrite
    dtcm.io.wdata := dtcmWrapper.io.sram.writeData
    dtcm.io.wmask := dtcmWrapper.io.sram.mask
    dtcmWrapper.io.sram.readData := dtcm.io.rdata
    val dtcmArbiter = Module(new FabricArbiter(p))
    dtcmArbiter.io.port <> dtcmWrapper.io.fabric
    dtcmArbiter.io.source(0).readDataAddr := MakeValid(
        core.io.dbus.valid && !core.io.dbus.write, core.io.dbus.addr)
    dtcmArbiter.io.source(0).writeDataAddr := MakeValid(
        core.io.dbus.valid && core.io.dbus.write, core.io.dbus.addr)
    dtcmArbiter.io.source(0).writeDataBits := core.io.dbus.wdata
    dtcmArbiter.io.source(0).writeDataStrb := core.io.dbus.wmask
    core.io.dbus.rdata := dtcmArbiter.io.source(0).readData.bits
    core.io.dbus.ready := true.B  // Can always read/write TCM

    // Connect TCMs and CSR into fabric
    val fabricMux = Module(new FabricMux(p, memoryRegions))
    fabricMux.io.ports(0) <> itcmArbiter.io.source(1)
    fabricMux.io.periBusy(0) := itcmArbiter.io.fabricBusy
    fabricMux.io.ports(1) <> dtcmArbiter.io.source(1)
    fabricMux.io.periBusy(1) := dtcmArbiter.io.fabricBusy
    fabricMux.io.ports(2) <> csr.io.fabric
    fabricMux.io.periBusy(2) := false.B

    // Create AXI Slave interface and connect internal fabric to AXI
    val axiSlave = Module(new AxiSlave(p))
    val axiSlaveEnable = RegInit(false.B)
    axiSlaveEnable := true.B
    axiSlave.io.fabric <> fabricMux.io.source
    axiSlave.io.periBusy := fabricMux.io.fabricBusy
    axiSlave.io.axi.write.addr <> GateDecoupled(io.axi_slave.write.addr, axiSlaveEnable)
    axiSlave.io.axi.write.data <> GateDecoupled(io.axi_slave.write.data, axiSlaveEnable)
    io.axi_slave.write.resp <> GateDecoupled(axiSlave.io.axi.write.resp, axiSlaveEnable)
    axiSlave.io.axi.read.addr <> GateDecoupled(io.axi_slave.read.addr, axiSlaveEnable)
    io.axi_slave.read.data <> GateDecoupled(axiSlave.io.axi.read.data, axiSlaveEnable)

    // Connect ebus to AXI Master
    val ebus2axi = DBus2Axi(p)
    ebus2axi.io.dbus <> core.io.ebus.dbus
    ebus2axi.io.axi <> io.axi_master
    ebus2axi.io.fault <> core.io.ebus.fault
  }
}
