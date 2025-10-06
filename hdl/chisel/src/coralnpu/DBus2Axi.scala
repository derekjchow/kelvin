// Copyright 2023 Google LLC
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

import bus.{AxiAddress, AxiMasterIO, AxiResponseType, AxiWriteData}
import common._
import _root_.circt.stage.{ChiselStage,FirtoolOption}
import chisel3.stage.ChiselGeneratorAnnotation
import scala.annotation.nowarn

object DBus2Axi {
  def apply(p: Parameters): DBus2Axi = {
    if (p.useLsuV2) {
      return Module(new DBus2AxiV2(p))
    } else {
      return Module(new DBus2AxiV1(p))
    }
  }
}

class ReadCtrl(p: Parameters) extends Bundle {
  val addr = UInt(p.axi2AddrBits.W)
  val size = UInt(p.axi2DataBits.W)
  val pc = UInt(p.programCounterBits.W)
}

class WriteCtrl(p: Parameters) extends Bundle {
  val addr = UInt(p.axi2AddrBits.W)
  val pc = UInt(p.programCounterBits.W)
}

class DBus2Axi(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val dbus = Flipped(new DBusIO(p))
    val axi = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val fault = Valid(new FaultInfo(p))
  })
}

class DBus2AxiV1(p: Parameters) extends DBus2Axi(p) {
  // Top-level state machine
  assert(!(io.dbus.valid && PopCount(io.dbus.size) =/= 1.U))
  val txnActive = RegInit(false.B)
  txnActive := MuxCase(txnActive, Seq(
    (io.dbus.valid && io.dbus.ready) -> false.B,
    (io.dbus.valid) -> true.B,
  ))
  assert(!(txnActive && !io.dbus.valid))
  val newTxn = io.dbus.valid && !txnActive

  val linebit = log2Ceil(p.lsuDataBits / 8)
  val lsb = log2Ceil(p.axi2DataBytes)
  val sdata = RegInit(0.U(p.axi2DataBits.W))

  val misalignment = Mod2(io.dbus.addr, io.dbus.size)(p.dbusSize - 1,0)
  val crossLineBoundary = Mod2(io.dbus.addr, p.axi2DataBytes.U) + io.dbus.size > p.axi2DataBytes.U
  val belowLineBoundary = (p.axi2DataBytes.U - Mod2(io.dbus.addr, p.axi2DataBytes.U))(2,0)
  val txnCount = Mux(misalignment =/= 0.U || crossLineBoundary, 2.U, 1.U)
  val txnSizes = MuxCase(VecInit(io.dbus.size, 0.U), Seq(
    crossLineBoundary -> VecInit(belowLineBoundary, io.dbus.size - belowLineBoundary),
    (misalignment =/= 0.U) -> VecInit(io.dbus.size - misalignment, misalignment),
  ))
  val dbusAddrAligned = io.dbus.addr - Mod2(io.dbus.addr, io.dbus.size)
  val dbusLineAddr = Cat(io.dbus.addr(31,lsb), 0.U(lsb.W))
  val transactionsCompleted = RegInit(0.U(2.W))
  transactionsCompleted := MuxCase(transactionsCompleted, Seq(
    newTxn -> 0.U,
    (txnActive && io.dbus.write && io.axi.write.resp.fire) -> (transactionsCompleted + 1.U),
    (txnActive && !io.dbus.write && io.axi.read.data.fire) -> (transactionsCompleted + 1.U),
  ))
  assert(!(io.dbus.valid && txnCount === 0.U))

  // Read state machine
  val readAddrQ = FifoX(new AxiAddress(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits), 2, 3)
  // Global enable for the FIFO input, which is ANDed with the enable for each channel.
  // If we are inserting anything, we *always* insert at least on the first channel.
  readAddrQ.io.in.valid := newTxn && !io.dbus.write
  assert(!(newTxn && readAddrQ.io.count =/= 0.U))
  readAddrQ.io.in.bits(0).valid := true.B
  readAddrQ.io.in.bits(0).bits.defaults()
  readAddrQ.io.in.bits(0).bits.addr := io.dbus.addr
  readAddrQ.io.in.bits(0).bits.size := Ctz(io.dbus.size)
  readAddrQ.io.in.bits(0).bits.len := MuxCase(0.U, Seq(
    ((misalignment =/= 0.U) && !crossLineBoundary) -> 1.U,
  ))
  readAddrQ.io.in.bits(0).bits.prot := 2.U
  readAddrQ.io.in.bits(0).bits.id := 0.U

  readAddrQ.io.in.bits(1).valid := crossLineBoundary
  readAddrQ.io.in.bits(1).bits.defaults()
  readAddrQ.io.in.bits(1).bits.addr := (io.dbus.addr + p.axi2DataBytes.U(p.programCounterBits.W)) & ~(p.axi2DataBytes - 1).U(p.programCounterBits.W) // Next page
  readAddrQ.io.in.bits(1).bits.size := Ctz(io.dbus.size)
  readAddrQ.io.in.bits(1).bits.len := 0.U
  readAddrQ.io.in.bits(1).bits.prot := 2.U
  readAddrQ.io.in.bits(1).bits.id := 0.U

  readAddrQ.io.out.ready := (io.axi.read.addr.ready && io.axi.read.addr.valid)
  io.axi.read.addr.valid := readAddrQ.io.out.valid
  io.axi.read.addr.bits := readAddrQ.io.out.bits

  val (rmask0, rmask1) = GenerateMasks(
      p.axi2DataBytes, io.dbus.addr, txnSizes)

  val crossLineMask = MuxLookup(transactionsCompleted, 0.U)(Seq(
    0.U -> rmask0,
    1.U -> rmask1,
  ))
  val rbitmask = Mux(crossLineBoundary, crossLineMask, Mux(
      (rmask1 === 0.U) || !io.axi.read.data.bits.last, rmask0, rmask1))
  val rbytemask = VecInit(
      rbitmask.asBools.map(Mux(_, 255.U(8.W), 0.U(8.W)))).asUInt
  sdata := MuxCase(sdata, Seq(
    (io.axi.read.data.valid && io.axi.read.data.ready) -> ((sdata & ~rbytemask) | (io.axi.read.data.bits.data & rbytemask)),
    newTxn -> 0.U,
  ))

  io.axi.read.data.ready := io.axi.read.data.valid
  assert(!(io.axi.read.data.fire && io.axi.read.data.bits.id =/= 0.U))
  io.dbus.rdata := sdata

  // Write state machine
  val writeAddrQ = FifoX(new AxiAddress(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits), 2, 3)
  // Global enable for the FIFO input, which is ANDed with the enable for each channel.
  // If we are inserting anything, we *always* insert at least on the first channel.
  writeAddrQ.io.in.valid := newTxn && io.dbus.write
  assert(!(newTxn && writeAddrQ.io.count =/= 0.U))
  writeAddrQ.io.in.bits(0).valid := true.B
  writeAddrQ.io.in.bits(0).bits.defaults()
  writeAddrQ.io.in.bits(0).bits.addr := dbusAddrAligned
  writeAddrQ.io.in.bits(0).bits.size := Ctz(io.dbus.size)
  writeAddrQ.io.in.bits(0).bits.prot := 2.U
  writeAddrQ.io.in.bits(0).bits.id := 0.U

  writeAddrQ.io.in.bits(1).valid := txnCount >= 2.U
  writeAddrQ.io.in.bits(1).bits.defaults()
  writeAddrQ.io.in.bits(1).bits.addr := dbusAddrAligned + io.dbus.size
  writeAddrQ.io.in.bits(1).bits.size := Ctz(io.dbus.size)
  writeAddrQ.io.in.bits(1).bits.prot := 2.U
  writeAddrQ.io.in.bits(1).bits.id := 0.U

  writeAddrQ.io.out.ready := (io.axi.write.addr.ready && io.axi.write.addr.valid)
  io.axi.write.addr.valid := writeAddrQ.io.out.valid
  io.axi.write.addr.bits := writeAddrQ.io.out.bits

  val writeDataQ = FifoX(new AxiWriteData(p.axi2DataBits, p.axi2IdBits), 2, 3)
  // Global enable for the FIFO input, which is ANDed with the enable for each channel.
  // If we are inserting anything, we *always* insert at least on the first channel.
  writeDataQ.io.in.valid := newTxn && io.dbus.write
  assert(!(newTxn && writeDataQ.io.count =/= 0.U))

  val (wmask0, wmask1) = GenerateMasks(
      p.axi2DataBytes, io.dbus.addr, txnSizes)
  val wbitmask0 = VecInit(
      wmask0.asBools.map(Mux(_, 255.U(8.W), 0.U(8.W)))).asUInt
  val wbitmask1 = VecInit(
      wmask1.asBools.map(Mux(_, 255.U(8.W), 0.U(8.W)))).asUInt

  writeDataQ.io.in.bits(0).valid := true.B
  writeDataQ.io.in.bits(0).bits.strb := wmask0
  writeDataQ.io.in.bits(0).bits.data := io.dbus.wdata & wbitmask0
  writeDataQ.io.in.bits(0).bits.last := true.B

  writeDataQ.io.in.bits(1).valid := txnCount >= 2.U
  writeDataQ.io.in.bits(1).bits.strb := wmask1
  writeDataQ.io.in.bits(1).bits.data := io.dbus.wdata & wbitmask1
  writeDataQ.io.in.bits(1).bits.last := true.B

  writeDataQ.io.out.ready := (io.axi.write.data.ready && io.axi.write.data.valid)

  io.axi.write.data.valid := writeDataQ.io.out.valid
  io.axi.write.data.bits.strb := writeDataQ.io.out.bits.strb
  io.axi.write.data.bits.data := writeDataQ.io.out.bits.data
  io.axi.write.data.bits.last := writeDataQ.io.out.bits.last

  io.axi.write.resp.ready := io.axi.write.resp.valid
  assert(!(io.axi.write.resp.fire && io.axi.write.resp.bits.id =/= 0.U))

  // Signal ready back to the data bus
  io.dbus.ready := Mux(io.dbus.write,
                       io.axi.write.resp.fire && (writeAddrQ.io.count === 0.U) && (writeDataQ.io.count === 0.U) && (transactionsCompleted + 1.U === txnCount),
                       io.axi.read.data.fire && io.axi.read.data.bits.last && (transactionsCompleted + 1.U === txnCount))


  // Fault reporting
  io.fault.valid := MuxCase(false.B, Seq(
    io.axi.write.resp.valid ->
      ((io.axi.write.resp.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.write.resp.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
    (io.axi.read.data.valid && io.axi.read.data.bits.last) ->
      ((io.axi.read.data.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.read.data.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
  ))
  io.fault.bits.write := io.axi.write.resp.valid
  io.fault.bits.addr := io.dbus.addr
  io.fault.bits.epc := io.dbus.pc
}

class DBus2AxiV2(p: Parameters) extends DBus2Axi(p) {
  assert(!(io.dbus.valid && PopCount(io.dbus.size) =/= 1.U),
         cf"Invalid dbus size=${io.dbus.size}")

  // ---------------------------------------------------------------------------
  // Write Path
  val waddrFired = RegInit(false.B)
  io.axi.write.addr.valid := !waddrFired && io.dbus.valid && io.dbus.write
  io.axi.write.addr.bits.defaults()
  io.axi.write.addr.bits.addr := io.dbus.addr
  io.axi.write.addr.bits.size := Ctz(io.dbus.size)
  io.axi.write.addr.bits.prot := 2.U
  io.axi.write.addr.bits.id := 0.U

  val wdataFired = RegInit(false.B)
  val wdataQueue = Module(new Queue(new AxiWriteData(p.axi2DataBits, p.axi2IdBits), 2))
  wdataQueue.io.enq.valid := !wdataFired && io.dbus.valid && io.dbus.write
  wdataQueue.io.enq.bits.data := io.dbus.wdata
  wdataQueue.io.enq.bits.strb := io.dbus.wmask
  wdataQueue.io.enq.bits.last := true.B
  io.axi.write.data <> wdataQueue.io.deq

  val wrespReceived = RegInit(false.B)
  io.axi.write.resp.ready := !wrespReceived && io.dbus.valid && io.dbus.write

  val writeFinished = (io.axi.write.addr.fire || waddrFired) &&
                      (wdataQueue.io.enq.fire || wdataFired) &&
                      (io.axi.write.resp.fire || wrespReceived)
  waddrFired := MuxCase(waddrFired, Seq(
    writeFinished -> false.B,
    io.axi.write.addr.fire -> true.B,
  ))
  wdataFired := MuxCase(wdataFired, Seq(
    writeFinished -> false.B,
    wdataQueue.io.enq.fire -> true.B,
  ))
  wrespReceived := MuxCase(wrespReceived, Seq(
    writeFinished -> false.B,
    io.axi.write.resp.fire -> true.B,
  ))

  // ---------------------------------------------------------------------------
  // Read Path
  val raddrFired = RegInit(false.B)
  io.axi.read.addr.valid := !raddrFired && io.dbus.valid && !io.dbus.write
  io.axi.read.addr.bits.defaults()
  io.axi.read.addr.bits.addr := io.dbus.addr
  io.axi.read.addr.bits.size := Ctz(io.dbus.size)
  io.axi.read.addr.bits.prot := 2.U
  io.axi.read.addr.bits.id := 0.U

  val rdataReceived = RegInit(MakeInvalid(UInt(p.axi2DataBits.W)))
  io.axi.read.data.ready :=
      !rdataReceived.valid && io.dbus.valid && !io.dbus.write
  // Assert we only received single beat bursts.
  assert(!io.axi.read.data.fire || io.axi.read.data.bits.last)

  val readFinished = (io.axi.read.addr.fire || raddrFired) &&
                     (io.axi.read.data.fire || rdataReceived.valid)
  raddrFired := MuxCase(raddrFired, Seq(
    readFinished -> false.B,
    io.axi.read.addr.fire -> true.B,
  ))
  rdataReceived := MuxCase(rdataReceived, Seq(
    readFinished -> MakeInvalid(UInt(p.axi2DataBits.W)),
    io.axi.read.data.fire -> MakeValid(true.B, io.axi.read.data.bits.data),
  ))
  // Insert delay register to match dbus interface expecations, changing on
  // fire.
  val readNext = RegInit(0.U(p.axi2DataBits.W))
  readNext := Mux(
      readFinished,
      Mux(io.axi.read.data.fire, io.axi.read.data.bits.data, rdataReceived.bits),
      readNext)
  io.dbus.rdata := readNext

  // ---------------------------------------------------------------------------
  // DBus Response
  io.dbus.ready := Mux(io.dbus.write, writeFinished, readFinished)

  // ---------------------------------------------------------------------------
  // Fault Handling
  io.fault.valid := io.dbus.valid && Mux(
    io.dbus.write,
    io.axi.write.resp.valid && (io.axi.write.resp.bits.resp =/= AxiResponseType.OKAY.asUInt),
    // TODO(derekjchow): Does read resp come in last? If not, wait until
    // transaction is totally complete before returning error.
    io.axi.read.data.valid && (io.axi.read.data.bits.resp =/= AxiResponseType.OKAY.asUInt))
  io.fault.bits.write := io.dbus.write
  // TODO(derekjchow): Make sure this targets the actual address instead of
  // line address (to report a more accurate exception).
  io.fault.bits.addr := io.dbus.addr
  io.fault.bits.epc := io.dbus.pc
}

@nowarn
object EmitDBus2Axi extends App {
  val p = new Parameters
  (new ChiselStage).execute(
    Array("--target", "systemverilog") ++ args,
    Seq(ChiselGeneratorAnnotation(() => new DBus2AxiV1(p))) ++ Seq(FirtoolOption("-enable-layers=Verification"))
  )
}
