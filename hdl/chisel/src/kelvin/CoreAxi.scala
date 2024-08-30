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
import chisel3.util.experimental.decode._

import bus.{AxiAddress, AxiMasterIO, AxiMasterReadIO, AxiWriteData}
import common._
import _root_.circt.stage.ChiselStage

class CoreAxi(p: Parameters, coreModuleName: String) extends RawModule {
  override val desiredName = coreModuleName + "Axi"
  val io = IO(new Bundle {
    // AXI
    val aclk = Input(Clock())
    val aresetn = Input(AsyncReset())
    // ITCM, DTCM, CSR
    val axi_slave = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val axi_master = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    // Incoming interrupts
    val intr = Input(Vec(16, Bool()))
    // Core status interrupts
    val halted = Output(Bool())
    val fault = Output(Bool())
    // Debug data interface
    val debug = new DebugIO(p)
    // String logging interface
    val slog = new SLogIO(p)
  })
  dontTouch(io)


  withClockAndReset(io.aclk, io.aresetn) {
    val itcmSizeBytes = 8 * 1024 // 8 kB
    val itcmSubEntryWidth = 8
    val itcmWidth = p.axi2DataBits
    val itcmEntries = itcmSizeBytes / (itcmWidth / 8)
    val itcmSubEntries = itcmWidth / itcmSubEntryWidth

    //TODO(stefanhall@): add support for HexMemoryFile
    val itcm = Module(new TCM(p, itcmSizeBytes, itcmSubEntryWidth))

    dontTouch(itcm.io)
    val itcmArbiter =
      Module(new Arbiter(
        new SRAMInterface(itcmEntries, Vec(itcmSubEntries, UInt(itcmSubEntryWidth.W)), 0, 0, 1, true),
      2))

    val dtcmSizeBytes = 32 * 1024 // 32 kB
    val dtcmWidth = p.axi2DataBits
    val dtcmEntries = dtcmSizeBytes / (dtcmWidth / 8)
    val dtcmSubEntryWidth = 8
    val dtcmSubEntries = dtcmWidth / dtcmSubEntryWidth
    val dtcm = Module(new TCM(p, dtcmSizeBytes, dtcmSubEntryWidth))

    val dtcmArbiter =
      Module(new Arbiter(
        new SRAMInterface(dtcmEntries, Vec(dtcmSubEntries, UInt(dtcmSubEntryWidth.W)), 0, 0, 1, true),
      2))

    val csr = Module(new CoreAxiCSR(p))
    val cg = Module(new ClockGate())
    cg.io.clk_i := io.aclk
    cg.io.enable := !csr.io.cg
    val core = withClockAndReset(cg.io.clk_o, csr.io.reset) { Core(p, coreModuleName) }
    csr.io.kelvin_csr := core.io.csr.out

    val itcmBridge = Module(new AxiSlave2ChiselSRAM(p, log2Ceil(itcmEntries)))

    itcmArbiter.io.in(0).bits.readwritePorts(0).address := itcmBridge.io.sramAddress
    itcmArbiter.io.in(0).bits.readwritePorts(0).enable := itcmBridge.io.sramEnable
    itcmArbiter.io.in(0).bits.readwritePorts(0).isWrite := itcmBridge.io.sramIsWrite
    itcmArbiter.io.in(0).bits.readwritePorts(0).writeData := itcmBridge.io.sramWriteData
    itcmArbiter.io.in(0).bits.readwritePorts(0).mask.get := itcmBridge.io.sramMask
    itcmArbiter.io.in(0).bits.readwritePorts(0).readData := itcm.io.rdata
    itcmBridge.io.sramReadData := itcmArbiter.io.in(0).bits.readwritePorts(0).readData

    val lsb = log2Ceil(p.axi2DataBits / 8)
    itcmArbiter.io.in(1).bits.readwritePorts(0).address := core.io.ibus.addr(log2Ceil(itcmEntries) + lsb - 1, lsb)
    itcmArbiter.io.in(1).bits.readwritePorts(0).enable := core.io.ibus.ready
    itcmArbiter.io.in(1).bits.readwritePorts(0).isWrite := false.B
    itcmArbiter.io.in(1).bits.readwritePorts(0).writeData := 0.U.asTypeOf(itcmArbiter.io.in(1).bits.readwritePorts(0).writeData)
    itcmArbiter.io.in(1).bits.readwritePorts(0).mask.get := -1.S.asTypeOf(itcmArbiter.io.in(1).bits.readwritePorts(0).mask.get)
    itcmArbiter.io.in(1).bits.readwritePorts(0).readData := itcm.io.rdata
    core.io.ibus.rdata := Cat(itcmArbiter.io.in(1).bits.readwritePorts(0).readData)

    itcm.io.addr := itcmArbiter.io.out.bits.readwritePorts(0).address
    itcm.io.enable := itcmArbiter.io.out.bits.readwritePorts(0).enable
    itcm.io.write := itcmArbiter.io.out.bits.readwritePorts(0).isWrite
    itcm.io.wdata := itcmArbiter.io.out.bits.readwritePorts(0).writeData
    itcm.io.wmask := itcmArbiter.io.out.bits.readwritePorts(0).mask.get

    itcmArbiter.io.in(0).valid := itcmBridge.io.txnInProgress
    itcmArbiter.io.in(1).valid := core.io.ibus.valid
    itcmArbiter.io.out.ready := true.B
    core.io.ibus.ready := core.io.ibus.valid && itcmArbiter.io.chosen === 1.U

    itcmBridge.io.periBusy := core.io.ibus.valid
    io.halted := core.io.halted
    io.fault := core.io.fault
    csr.io.halted := core.io.halted
    csr.io.fault := core.io.fault
    core.io.debug_req := true.B

    val dtcmBridge = Module(new AxiSlave2ChiselSRAM(p, log2Ceil(dtcmEntries)))
    dtcmBridge.io.periBusy := core.io.dbus.valid

    dtcmArbiter.io.in(0).bits.readwritePorts(0).address := dtcmBridge.io.sramAddress
    dtcmArbiter.io.in(0).bits.readwritePorts(0).enable := dtcmBridge.io.sramEnable
    dtcmArbiter.io.in(0).bits.readwritePorts(0).isWrite := dtcmBridge.io.sramIsWrite
    dtcmArbiter.io.in(0).bits.readwritePorts(0).writeData := dtcmBridge.io.sramWriteData
    dtcmArbiter.io.in(0).bits.readwritePorts(0).mask.get := dtcmBridge.io.sramMask
    dtcmArbiter.io.in(0).bits.readwritePorts(0).readData := dtcm.io.rdata
    dtcmBridge.io.sramReadData := dtcmArbiter.io.in(0).bits.readwritePorts(0).readData

    dtcmArbiter.io.in(1).bits.readwritePorts(0).address := core.io.dbus.addr(log2Ceil(dtcmEntries) + lsb - 1, lsb)
    dtcmArbiter.io.in(1).bits.readwritePorts(0).enable := core.io.dbus.ready
    dtcmArbiter.io.in(1).bits.readwritePorts(0).isWrite := core.io.dbus.write
    dtcmArbiter.io.in(1).bits.readwritePorts(0).writeData := UIntToVec(core.io.dbus.wdata, 8)
    dtcmArbiter.io.in(1).bits.readwritePorts(0).mask.get := core.io.dbus.wmask.asBools
    dtcmArbiter.io.in(1).bits.readwritePorts(0).readData := dtcm.io.rdata

    dtcm.io.addr := dtcmArbiter.io.out.bits.readwritePorts(0).address
    dtcm.io.enable := dtcmArbiter.io.out.bits.readwritePorts(0).enable
    dtcm.io.write := dtcmArbiter.io.out.bits.readwritePorts(0).isWrite
    dtcm.io.wdata := dtcmArbiter.io.out.bits.readwritePorts(0).writeData
    dtcm.io.wmask := dtcmArbiter.io.out.bits.readwritePorts(0).mask.get

    core.io.dbus.rdata := Cat(dtcmArbiter.io.out.bits.readwritePorts(0).readData)
    core.io.dbus.ready := core.io.dbus.valid && dtcmArbiter.io.chosen === 1.U

    dtcmArbiter.io.in(0).valid := dtcmBridge.io.txnInProgress
    dtcmArbiter.io.in(1).valid := core.io.dbus.valid
    dtcmArbiter.io.out.ready := true.B

    val memoryRegions = Seq(
      new MemoryRegion(0x0000, 0x2000, false, p.axi2DataBits), // ITCM
      new MemoryRegion(0x8000, 0x8000, false, p.axi2DataBits), // DTCM
      new MemoryRegion(0x2000, 0x2000, false, p.axi2DataBits), // CSR
    )
    val axi_mux = Module(new CoreAxiSlaveMux(p, memoryRegions))
    axi_mux.io.axi_slave <> io.axi_slave
    axi_mux.io.ports(0) <> itcmBridge.io.axi
    axi_mux.io.ports(1) <> dtcmBridge.io.axi
    axi_mux.io.ports(2) <> csr.io.axi

    core.io.csr <> 0.U.asTypeOf(core.io.csr)
    core.io.csr.in.value(0) := csr.io.pcStart

    io.slog <> core.io.slog
    io.debug <> core.io.debug

    // Tie-offs
    io.axi_master <> 0.U.asTypeOf(io.axi_master)
    core.io.axi1 <> 0.U.asTypeOf(core.io.axi1)
    core.io.dflush.ready := true.B
    core.io.iflush.ready := false.B
  }
}
