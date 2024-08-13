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

import bus.{AxiAddress, AxiMasterIO, AxiMasterReadIO, AxiWriteData}
import common._
import _root_.circt.stage.ChiselStage

object UIntToVec {
  def apply(in: UInt, elemWidth: Int): Vec[UInt] = {
    assert((in.getWidth % elemWidth) == 0)
    VecInit((0 until in.getWidth by elemWidth).map(
      x => in(x + elemWidth - 1, x)
    ))
  }
}

class AxiSlave2ChiselSRAM(p: Parameters, sramAddressWidth: Int) extends Module {
  val io = IO(new Bundle{
    val axi = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    val sramAddress = Output(UInt(sramAddressWidth.W))
    val sramEnable = Output(Bool())
    val sramIsWrite = Output(Bool())
    val sramReadData = Input(Vec(p.axi2DataBits / 8, UInt(8.W)))
    val sramWriteData = Output(Vec(p.axi2DataBits / 8, UInt(8.W)))
    val sramMask = Output(Vec(p.axi2DataBits / 8, Bool()))
    // Output indicating a transaction is progress (to force arbiter lock)
    val txnInProgress = Output(Bool())
    // Input to indicate that the arbiter is elsewhere -- gate our ready signals
    val periBusy = Input(Bool())
  })

  val readAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits)))
  io.axi.read.addr.ready := readAddr.valid && !io.periBusy
  val canRead = !readAddr.valid && io.axi.read.addr.valid && !io.periBusy
  when (canRead) {
    readAddr := MakeValid(true.B, io.axi.read.addr.bits)
  }

  val readValid = RegInit(false.B)
  val doRead = readAddr.valid && !readValid
  val readDataFired = RegInit(false.B)
  val readDataFired2 = RegInit(false.B)
  readValid := doRead
  io.axi.read.data.valid := readValid
  when (io.axi.read.data.fire) {
    readDataFired := true.B
  }
  when (readDataFired) {
    readDataFired := false.B
    readDataFired2 := true.B
  }
  when (readDataFired2) {
    readDataFired2 := false.B
    readAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.read.addr.bits))
  }

  val writeAddr = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits)))
  io.axi.write.addr.ready := writeAddr.valid && !io.periBusy
  val canWrite = !writeAddr.valid && io.axi.write.addr.valid
  when (canWrite) {
    writeAddr := MakeValid(true.B, io.axi.write.addr.bits)
  }

  val writeData = RegInit(MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits)))
  io.axi.write.data.ready := !writeData.valid
  val canWriteData = !writeData.valid && io.axi.write.data.valid
  when (canWriteData) {
    writeData := MakeValid(true.B, io.axi.write.data.bits)
  }

  val doWrite = writeData.valid && writeAddr.valid
  val writeRespValid = RegInit(false.B)
  val writeRespFired = RegInit(false.B)
  writeRespValid := doWrite && !writeRespFired
  io.axi.write.resp.valid := writeRespValid
  when (io.axi.write.resp.fire) {
    writeRespFired := true.B
    writeAddr := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.addr.bits))
  }
  when (writeRespFired) {
    writeRespFired := false.B
    writeData := MakeValid(false.B, 0.U.asTypeOf(io.axi.write.data.bits))
  }
  val readData = Cat(io.sramReadData.reverse)
  val readDataRightShift = readData >> (readAddr.bits.addr(3,0) << 3)

  val maxSize = log2Ceil(p.axi2DataBits / 8)
  val readDataMask = Cat(
    Cat((1 to maxSize).reverse.map(x => {
      val width = (scala.math.pow(2, (x - 1)).toInt) * 8
      (Mux(readAddr.bits.size >= x.U, -1.S(width.W).asUInt, 0.U(width.W)))
    })),
    "xFF".U(8.W)
  )
  io.axi.read.data.bits.data := Mux(readValid,
    readDataRightShift & readDataMask,
    0.U.asTypeOf(io.axi.read.data.bits.data))
  io.axi.read.data.bits.id := Mux(readValid, readAddr.bits.id, 0.U.asTypeOf(io.axi.read.data.bits.id))
  io.axi.read.data.bits.resp := 0.U
  io.axi.read.data.bits.last := true.B

  io.axi.write.resp.bits.resp := 0.U
  io.axi.write.resp.bits.id := Mux(doWrite, writeAddr.bits.id, 0.U.asTypeOf(io.axi.write.resp.bits.id))

  io.sramAddress := MuxCase(0.U, Array(
    doWrite -> writeAddr.bits.addr(sramAddressWidth + 4 - 1, 4),
    readAddr.valid -> readAddr.bits.addr(sramAddressWidth + 4 - 1, 4)
  ))
  io.sramEnable := Mux(readAddr.valid || writeAddr.valid, true.B, false.B)
  io.sramIsWrite := Mux(writeAddr.valid && writeData.valid, true.B, false.B)
  val dummyWriteData = RegInit(VecInit(Seq.fill(writeData.bits.data.getWidth / 8)(0.U(8.W))))
  val writeDataLeftShift = (writeData.bits.data << (writeAddr.bits.addr(3,0) << 3))(writeData.bits.data.getWidth - 1,0)
  val writeDataVec = UIntToVec(writeDataLeftShift, 8)
  val writeStrbLeftShift = (writeData.bits.strb << (writeAddr.bits.addr(3,0)))(writeData.bits.strb.getWidth - 1,0)
  val writeMaskData = VecInit(writeStrbLeftShift.asBools)
  io.sramWriteData := Mux(doWrite, writeDataVec, dummyWriteData)
  val readMaskData = RegInit(VecInit(Seq.fill(writeData.bits.data.getWidth / 8)(true.B)))
  val maskData = Mux(doWrite, writeMaskData, readMaskData)
  io.sramMask := maskData
  io.txnInProgress := readAddr.valid || writeAddr.valid
}

class CoreAxi(p: Parameters, coreModuleName: String) extends RawModule {
  override val desiredName = coreModuleName + "Axi"
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())
    val debug_req = Input(Bool())

    val axi0 = if (p.enableVector) {
      Some(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))
    } else { None }
    val axi1 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    // AXI
    val aclk = Input(Clock())
    val aresetn = Input(AsyncReset())
    val axi_to_itcm = Flipped(new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits))

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })


  withClockAndReset(io.aclk, io.aresetn) {
    val itcmSizeBytes = 8 * 1024 // 8 kB
    val itcmWidth = p.axi2DataBits
    val itcmEntries = itcmSizeBytes / itcmWidth
    val itcmSubEntryWidth = 8
    val itcmSubEntries = itcmWidth / itcmSubEntryWidth
    val itcm =
      if (p.itcmMemoryFile == "") {
        SRAM.masked(itcmEntries, Vec(itcmSubEntries, UInt(itcmSubEntryWidth.W)), 0, 0, 1)
      } else {
        SRAM.masked(itcmEntries, Vec(itcmSubEntries, UInt(itcmSubEntryWidth.W)), 0, 0, 1,
                    new HexMemoryFile(p.itcmMemoryFile))
      }
    dontTouch(itcm)
    val itcmArbiter =
      Module(new Arbiter(
        new SRAMInterface(itcmEntries, Vec(itcmSubEntries, UInt(itcmSubEntryWidth.W)), 0, 0, 1, true),
      2))

    val dtcmSizeBytes = 32 * 1024 // 32 kB
    val dtcmWidth = p.axi2DataBits
    val dtcmEntries = dtcmSizeBytes / dtcmWidth
    val dtcmSubEntryWidth = 8
    val dtcmSubEntries = dtcmWidth / dtcmSubEntryWidth
    val dtcm =
      SRAM.masked(dtcmEntries, Vec(dtcmSubEntries, UInt(dtcmSubEntryWidth.W)), 0, 0, 1)

    val core = Core(p, coreModuleName)
    dontTouch(core.io)

    val bridge = Module(new AxiSlave2ChiselSRAM(p, log2Ceil(itcmEntries)))
    dontTouch(bridge.io)
    bridge.io.axi <> io.axi_to_itcm

    itcmArbiter.io.in(0).bits.readwritePorts(0).address := bridge.io.sramAddress
    itcmArbiter.io.in(0).bits.readwritePorts(0).enable := bridge.io.sramEnable
    itcmArbiter.io.in(0).bits.readwritePorts(0).isWrite := bridge.io.sramIsWrite
    itcmArbiter.io.in(0).bits.readwritePorts(0).writeData := bridge.io.sramWriteData
    itcmArbiter.io.in(0).bits.readwritePorts(0).mask.get := bridge.io.sramMask
    itcmArbiter.io.in(0).bits.readwritePorts(0).readData := itcm.readwritePorts(0).readData
    // TODO(atv): Mask this if not chosen?
    bridge.io.sramReadData := itcmArbiter.io.in(0).bits.readwritePorts(0).readData

    itcmArbiter.io.in(1).bits.readwritePorts(0).address := core.io.ibus.addr(log2Ceil(itcmEntries) + 4 - 1, 4)
    itcmArbiter.io.in(1).bits.readwritePorts(0).enable := core.io.ibus.ready
    itcmArbiter.io.in(1).bits.readwritePorts(0).isWrite := false.B
    itcmArbiter.io.in(1).bits.readwritePorts(0).writeData := 0.U.asTypeOf(itcmArbiter.io.in(1).bits.readwritePorts(0).writeData)
    itcmArbiter.io.in(1).bits.readwritePorts(0).mask.get := -1.S.asTypeOf(itcmArbiter.io.in(1).bits.readwritePorts(0).mask.get)
    itcmArbiter.io.in(1).bits.readwritePorts(0).readData := itcm.readwritePorts(0).readData.reverse
    // TODO(atv): Mask this if not chosen?
    core.io.ibus.rdata := Cat(itcmArbiter.io.in(1).bits.readwritePorts(0).readData)

    itcm.readwritePorts(0).address := itcmArbiter.io.out.bits.readwritePorts(0).address
    itcm.readwritePorts(0).enable := itcmArbiter.io.out.bits.readwritePorts(0).enable
    itcm.readwritePorts(0).isWrite := itcmArbiter.io.out.bits.readwritePorts(0).isWrite
    itcm.readwritePorts(0).writeData := itcmArbiter.io.out.bits.readwritePorts(0).writeData
    itcm.readwritePorts(0).mask.get := itcmArbiter.io.out.bits.readwritePorts(0).mask.get

    itcmArbiter.io.in(0).valid := bridge.io.txnInProgress
    itcmArbiter.io.in(1).valid := core.io.ibus.valid
    itcmArbiter.io.out.ready := true.B
    core.io.ibus.ready := core.io.ibus.valid && itcmArbiter.io.chosen === 1.U

    bridge.io.periBusy := core.io.ibus.valid
    io.csr <> core.io.csr
    io.halted := core.io.halted
    io.fault := core.io.fault
    core.io.debug_req := io.debug_req
    if (p.enableVector) {
      io.axi0.get <> core.io.axi0.get
    }
    io.axi1 <> core.io.axi1

    dtcm.readwritePorts(0).address := core.io.dbus.addr
    dtcm.readwritePorts(0).enable := core.io.dbus.valid
    dtcm.readwritePorts(0).isWrite := core.io.dbus.write
    dtcm.readwritePorts(0).writeData := UIntToVec(core.io.dbus.wdata, 8)
    core.io.dbus.rdata := Cat(dtcm.readwritePorts(0).readData)
    dtcm.readwritePorts(0).mask.get := core.io.dbus.wmask.asBools
    core.io.dbus.ready := true.B

    io.iflush <> core.io.iflush
    io.dflush <> core.io.dflush
    io.slog <> core.io.slog
    io.debug <> core.io.debug
  }
}
