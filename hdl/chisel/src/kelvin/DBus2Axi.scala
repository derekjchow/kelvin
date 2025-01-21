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

package kelvin

import chisel3._
import chisel3.util._

import bus.{AxiMasterIO, AxiResponseType, AxiWriteData}
import common._
import _root_.circt.stage.ChiselStage

object DBus2Axi {
  def apply(p: Parameters): DBus2Axi = {
    return Module(new DBus2Axi(p))
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

object GenerateMasks {
  def apply(nBytes: Int, addr: UInt, size: UInt): (UInt, UInt) = {
    val bottom = addr(log2Ceil(nBytes),0)
    val unshiftedMask = VecInit((0 until nBytes).map(i => i.U < size)).asUInt
    val shiftedMask = unshiftedMask << bottom
    val mask0 = shiftedMask(nBytes - 1, 0)
    val mask1 = shiftedMask(2 * nBytes - 1, nBytes)
    (mask0, mask1)
  }
}

class DBus2Axi(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val dbus = Flipped(new DBusIO(p))
    val axi = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val fault = Valid(new FaultInfo(p))
  })

  io.axi.defaults()
  assert(!(io.dbus.valid && PopCount(io.dbus.size) =/= 1.U))

  val linebit = log2Ceil(p.lsuDataBits / 8)
  val lsb = log2Ceil(p.axi2DataBytes)
  val sraddrActive = RegInit(false.B)
  val sdata = RegInit(0.U(p.axi2DataBits.W))
  val readCtrl = RegInit(MakeInvalid(new ReadCtrl(p)))

  when (io.axi.read.data.valid && io.axi.read.data.ready && io.axi.read.data.bits.last) {
    sraddrActive := false.B
    assert(sraddrActive)
    assert(!io.axi.read.addr.valid)
  } .elsewhen (io.axi.read.addr.valid && io.axi.read.addr.ready) {
    sraddrActive := true.B
    sdata := 0.U
    assert(!sraddrActive)
    assert(!io.axi.read.data.valid)
  }

  when (io.axi.read.data.valid && io.axi.read.data.ready) {
    val (rmask0, rmask1) = GenerateMasks(
        p.axi2DataBytes, readCtrl.bits.addr, io.dbus.size)

    val rbitmask = Mux(
        (rmask1 === 0.U) || !io.axi.read.data.bits.last, rmask0, rmask1)
    val rbytemask = VecInit(
        rbitmask.asBools.map(Mux(_, 255.U(8.W), 0.U(8.W)))).asUInt
    sdata := (sdata & ~rbytemask) | (io.axi.read.data.bits.data & rbytemask)
  }

  readCtrl := MuxCase(readCtrl, Array(
    (io.axi.read.data.valid && io.axi.read.data.bits.last) -> MakeInvalid(new ReadCtrl(p)),
    (io.dbus.valid && !io.dbus.write && !sraddrActive) -> MakeWireBundle[ValidIO[ReadCtrl]](
      Valid(new ReadCtrl(p)),
      _.valid     -> true.B,
      _.bits.addr -> io.dbus.addr,
      _.bits.size -> io.dbus.size,
      _.bits.pc   -> io.dbus.pc,
  )))
  val rbase_addr = Cat(io.dbus.addr(31,lsb), 0.U(lsb.W))
  val rnext_page = (rbase_addr + p.axi2DataBytes.U)(31,0)
  val rlast_byte = io.dbus.addr + io.dbus.size - 1.U
  val raligned_addr = MuxCase(io.dbus.addr, Array(
    (io.dbus.size === 4.U) -> Cat(io.dbus.addr(31,2), 0.U(2.W)),
    (io.dbus.size === 2.U) -> Cat(io.dbus.addr(31,1), 0.U(1.W)),
  ))
  io.axi.read.addr.valid := io.dbus.valid && !io.dbus.write && !sraddrActive
  io.axi.read.addr.bits.addr := io.dbus.addr
  io.axi.read.addr.bits.id := 0.U
  io.axi.read.addr.bits.prot := 2.U
  io.axi.read.addr.bits.size := Ctz(io.dbus.size)
  io.axi.read.addr.bits.len := Mux((rlast_byte >= rnext_page) || (raligned_addr =/= io.dbus.addr), 1.U, 0.U)

  io.axi.read.data.ready := true.B
  io.dbus.rdata := sdata

  val writeCtrl = RegInit(MakeInvalid(new WriteCtrl(p)))
  writeCtrl := MuxCase(writeCtrl, Array(
    io.axi.write.resp.valid -> MakeInvalid(new WriteCtrl(p)),
    (io.dbus.valid && io.dbus.write) -> MakeWireBundle[ValidIO[WriteCtrl]](
      Valid(new WriteCtrl(p)),
      _.valid     -> true.B,
      _.bits.addr -> io.dbus.addr,
      _.bits.pc   -> io.dbus.pc,
  )))
  val writeAddrFired = RegInit(false.B)
  writeAddrFired := MuxCase(writeAddrFired, Array(
    (io.axi.write.addr.ready && io.axi.write.addr.valid) -> true.B,
    io.axi.write.resp.fire -> false.B,
  ))

  val base_addr = Cat(writeCtrl.bits.addr(31,lsb), 0.U(lsb.W))
  val next_page = (base_addr + p.axi2DataBytes.U)(31,0)
  val last_byte = writeCtrl.bits.addr + io.dbus.size - 1.U
  val aligned_addr = MuxCase(writeCtrl.bits.addr, Array(
    (io.dbus.size === 4.U) -> Cat(writeCtrl.bits.addr(31,2), 0.U(2.W)),
    (io.dbus.size === 2.U) -> Cat(writeCtrl.bits.addr(31,1), 0.U(1.W)),
  ))
  val wunaligned = (last_byte >= next_page) || (aligned_addr =/= writeCtrl.bits.addr)

  io.axi.write.addr.valid := io.dbus.valid && io.dbus.write && writeCtrl.valid && !writeAddrFired
  io.axi.write.addr.bits.addr := writeCtrl.bits.addr
  io.axi.write.addr.bits.id := 0.U
  io.axi.write.addr.bits.prot := 2.U
  io.axi.write.addr.bits.size := Ctz(io.dbus.size)
  io.axi.write.addr.bits.len := Mux(wunaligned, 1.U, 0.U)

  val writeDataQueued = RegInit(false.B)
  val writeDataQ = FifoX(new AxiWriteData(p.axi2DataBits, p.axi2IdBits), 2, 3)
  writeDataQ.io.in.valid := io.dbus.valid && io.dbus.write && (writeDataQ.io.count === 0.U) && !writeDataQueued && writeCtrl.valid
  writeDataQueued := MuxCase(writeDataQueued, Array(
    (io.dbus.valid && io.dbus.write && (writeDataQ.io.count === 0.U) && !writeDataQueued && writeCtrl.valid) -> true.B,
    (io.axi.write.resp.fire) -> false.B,
  ))

  val (wmask0, wmask1) = GenerateMasks(
      p.axi2DataBytes, writeCtrl.bits.addr, io.dbus.size)

  writeDataQ.io.in.bits(0).valid := true.B
  writeDataQ.io.in.bits(0).bits.strb := Mux((last_byte >= next_page), wmask0, io.dbus.wmask)
  writeDataQ.io.in.bits(0).bits.data := io.dbus.wdata
  writeDataQ.io.in.bits(0).bits.last := !wunaligned

  writeDataQ.io.in.bits(1).valid := wunaligned
  writeDataQ.io.in.bits(1).bits.strb := wmask1
  writeDataQ.io.in.bits(1).bits.data := io.dbus.wdata
  writeDataQ.io.in.bits(1).bits.last := true.B

  writeDataQ.io.out.ready := (io.axi.write.data.ready && io.axi.write.data.valid)

  io.axi.write.data.valid := writeDataQ.io.out.valid
  io.axi.write.data.bits.strb := writeDataQ.io.out.bits.strb
  io.axi.write.data.bits.data := writeDataQ.io.out.bits.data
  io.axi.write.data.bits.last := writeDataQ.io.out.bits.last

  io.axi.write.resp.ready := io.axi.write.resp.valid

  // Signal ready back to the data bus
  io.dbus.ready := Mux(io.dbus.write,
                       io.axi.write.resp.valid && io.axi.write.resp.ready,
                       io.axi.read.data.valid && io.axi.read.data.ready && io.axi.read.data.bits.last)


  // Fault reporting
  io.fault.valid := MuxCase(false.B, Array(
    io.axi.write.resp.valid ->
      ((io.axi.write.resp.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.write.resp.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
    (io.axi.read.data.valid && io.axi.read.data.bits.last) ->
      ((io.axi.read.data.bits.resp =/= AxiResponseType.OKAY.asUInt) &&
      (io.axi.read.data.bits.resp =/= AxiResponseType.EXOKAY.asUInt)),
  ))
  io.fault.bits.write := io.axi.write.resp.valid
  io.fault.bits.addr := MuxCase(0.U, Array(
    writeCtrl.valid -> writeCtrl.bits.addr,
    readCtrl.valid -> readCtrl.bits.addr,
  ))
  io.fault.bits.epc := MuxCase(0.U, Array(
    writeCtrl.valid -> writeCtrl.bits.pc,
    readCtrl.valid -> readCtrl.bits.pc,
  ))
}

object EmitDBus2Axi extends App {
  val p = new Parameters
  ChiselStage.emitSystemVerilogFile(new DBus2Axi(p), args)
}
