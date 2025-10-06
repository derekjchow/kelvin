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
import chisel3.simulator.scalatest.ChiselSim
import chisel3.util._
import org.scalatest.freespec.AnyFreeSpec

class DBus2AxiSpec extends AnyFreeSpec with ChiselSim {
  var p = new Parameters

  def rotateLeft(num: BigInt, shift: Int, width: Int): BigInt = {
    val effectiveShift = shift % width // Handle shifts larger than width
    val leftPart = (num << effectiveShift) & ((BigInt(1) << width) - 1)
    val rightPart = num >> (width - effectiveShift)
    leftPart | rightPart
  }

  def generateMasks(addr: Int, size: Int, txnSizes: Seq[Int]): List[BigInt] = {
    val bottom: Int = addr & 0x1F
    val mask0 = rotateLeft((31 to 0 by -1).map(i => i < txnSizes(0)).foldLeft(0L) { (acc, b) => (acc << 1 | (if (b) 1L else 0L))}, bottom, 32)
    val mask1 = rotateLeft((31 to 0 by -1).map(i => i < txnSizes(1)).foldLeft(0L) { (acc, b) => (acc << 1 | (if (b) 1L else 0L))}, bottom + txnSizes(0), 32)
    List(mask0, mask1)
  }

  def generateBitmask(bytemask: BigInt): BigInt = {
    var bitmask: BigInt = 0
    for (i <- 31 to 0 by -1) {
      bitmask = (bitmask | (if (bytemask.testBit(i)) 255 else 0)) << 8
    }
    bitmask >>= 8
    bitmask
  }

  class Case(val addr: Int, val size: Int, val data: BigInt, val mask: Long) {}
  "Unaligned Write then Read" in {
    simulate(new DBus2AxiV1(p)) { dut =>
      val cases = Array(
        new Case(0x00000001, 4, 0x11223344, 0x0000001EL),
        new Case(0x00000002, 4, 0x11223344, 0x0000003CL),
        new Case(0x00000003, 4, 0x11223344, 0x00000078L),
        new Case(0x00000005, 4, 0x11223344, 0x000001E0L),
        new Case(0x00000006, 4, 0x11223344, 0x000003C0L),
        new Case(0x00000007, 4, 0x11223344, 0x00000780L),
        new Case(0x00000009, 4, 0x11223344, 0x00001E00L),
        new Case(0x0000000a, 4, 0x11223344, 0x00003C00L),
        new Case(0x0000000b, 4, 0x11223344, 0x00007800L),
        new Case(0x0000000d, 4, 0x11223344, 0x0001E000L),
        new Case(0x0000000e, 4, 0x11223344, 0x0003C000L),
        new Case(0x0000000f, 4, 0x11223344, 0x00078000L),
        new Case(0x00000011, 4, 0x11223344, 0x001E0000L),
        new Case(0x00000012, 4, 0x11223344, 0x003C0000L),
        new Case(0x00000013, 4, 0x11223344, 0x00780000L),
        new Case(0x00000015, 4, 0x11223344, 0x01E00000L),
        new Case(0x00000016, 4, 0x11223344, 0x03C00000L),
        new Case(0x00000017, 4, 0x11223344, 0x07800000L),
        new Case(0x00000019, 4, 0x11223344, 0x1E000000L),
        new Case(0x0000001a, 4, 0x11223344, 0x3C000000L),
        new Case(0x0000001b, 4, 0x11223344, 0x78000000L),
        new Case(0x0000001d, 4, 0x11223344, 0xE0000001L),
        new Case(0x0000001e, 4, 0x11223344, 0xC0000003L),
        new Case(0x0000001f, 4, 0x11223344, 0x80000007L),
        new Case(0x0000001f, 2, 0x1122, 0x80000001L),
      )
      cases.foreach(c => {
        val alignedAddr = c.addr - (c.addr % c.size)
        val misalignment = c.addr % c.size
        val crossLineBoundary = ((c.addr % 32) + c.size - 1) >= 32
        val belowLineBoundary = (32 - (c.addr % 32)) & 0x7
        val txnCount = if (misalignment != 0) { 2 } else { 1 }
        val txnSizes =
          if (crossLineBoundary) {
            Seq(belowLineBoundary, c.size - belowLineBoundary)
          } else if (misalignment != 0) {
            Seq(c.size - misalignment, misalignment)
          } else {
            Seq(c.size, 0)
          }
        val rotatedData = rotateLeft(c.data, 8 * c.addr, p.axi2DataBits)

        val masks = generateMasks(c.addr, c.size, txnSizes)

        dut.io.axi.read.addr.ready.poke(false.B)
        dut.io.axi.read.data.valid.poke(false.B)
        dut.io.axi.write.data.ready.poke(false.B)
        dut.io.axi.write.addr.ready.poke(false.B)
        dut.io.axi.write.resp.valid.poke(false.B)
        dut.clock.step()

        dut.io.dbus.valid.poke(true.B)
        dut.io.dbus.addr.poke(c.addr.U)
        dut.io.dbus.write.poke(true.B)
        dut.io.dbus.wdata.poke(rotatedData.U)
        dut.io.dbus.wmask.poke(c.mask.U)
        dut.io.dbus.size.poke(c.size.U)

        for (i <- 0 until txnCount) {
          // Receive master write addr
          val (waddr, wsize, wlen) = {
            dut.io.axi.write.addr.ready.poke(true.B)
            while (dut.io.axi.write.addr.valid.peek().litValue != 1 || dut.io.axi.write.addr.ready.peek().litValue != 1) {
              dut.clock.step()
            }
            val rv = (
              dut.io.axi.write.addr.bits.addr.peek().litValue,
              dut.io.axi.write.addr.bits.size.peek().litValue,
              dut.io.axi.write.addr.bits.len.peek().litValue,
            )
            dut.clock.step()
            dut.io.axi.write.addr.ready.poke(false.B)
            rv
          }

          assertResult(waddr) { alignedAddr + (i * c.size) }
          assertResult(wsize) { log2Ceil(c.size) }
          assertResult(wlen) { 0 }

          // Receive master write data
          val (wdata, wstrb) = {
            dut.io.axi.write.data.ready.poke(true.B)
            while (dut.io.axi.write.data.valid.peek().litValue != 1 || dut.io.axi.write.data.ready.peek().litValue != 1) {
              dut.clock.step()
            }
            dut.io.axi.write.data.bits.last.expect(1)
            val rv = (
              dut.io.axi.write.data.bits.data.peek().litValue,
              dut.io.axi.write.data.bits.strb.peek().litValue,
            )
            dut.clock.step()
            dut.io.axi.write.data.ready.poke(false.B)
            rv
          }

          assertResult(wdata) { rotatedData & generateBitmask(masks(i)) }
          assertResult(wstrb) { masks(i) }

          // Emit master write response
          {
            dut.io.axi.write.resp.valid.poke(true.B)
            dut.io.axi.write.resp.bits.id.poke(0.U)
            dut.io.axi.write.resp.bits.resp.poke(0.U)
            while (dut.io.axi.write.resp.ready.peek().litValue != 1 || dut.io.axi.write.resp.valid.peek().litValue != 1) {
              dut.clock.step()
            }
            if (i == 1) {
              assertResult(1) { dut.io.dbus.ready.peek().litValue }
            }
            dut.clock.step()
            if (i == 1) {
              dut.io.dbus.valid.poke(false.B)
            }
            dut.io.axi.write.resp.valid.poke(false.B)
          }
        }

        assertResult(0) { dut.io.dbus.ready.peek().litValue }
        dut.io.dbus.valid.poke(true.B)
        dut.io.dbus.addr.poke(c.addr.U)
        dut.io.dbus.write.poke(false.B)
        dut.io.dbus.size.poke(c.size.U)
        dut.clock.step()

        val readTxnCount = if (crossLineBoundary) { 2 } else { 1 }
        for (txn <- 0 until readTxnCount) {
          // Receive read addr
          val (len, addr, size) = {
            assertResult(0) { dut.io.axi.read.addr.ready.peek().litValue }
            dut.io.axi.read.addr.ready.poke(true.B)
            while (dut.io.axi.read.addr.valid.peek().litValue != 1 || dut.io.axi.read.addr.ready.peek().litValue != 1) {
              dut.clock.step()
            }
            val rv = (
              dut.io.axi.read.addr.bits.len.peek().litValue,
              dut.io.axi.read.addr.bits.addr.peek().litValue,
              dut.io.axi.read.addr.bits.size.peek().litValue,
            )
            dut.clock.step()
            dut.io.axi.read.addr.ready.poke(false.B)
            rv
          }

          assertResult(len) { if (misalignment != 0 && !crossLineBoundary) 1 else 0 }
          assertResult(size) { log2Ceil(c.size) }
          assertResult(addr) { if (txn == 0) { c.addr } else { (c.addr + 32) & ~31 } }

          // Transmit read data
          {
            assertResult(0) { dut.io.axi.read.data.valid.peek().litValue }
            for (i <- 0 to (len).toInt) {
              dut.io.axi.read.data.valid.poke(true.B)
              dut.io.axi.read.data.bits.id.poke(0.U)
              dut.io.axi.read.data.bits.data.poke(0.U)
              dut.io.axi.read.data.bits.resp.poke(0.U) // OKAY
              dut.io.axi.read.data.bits.last.poke(if (i == len) { 1 } else { 0 })
              if (i == len && txn == (readTxnCount - 1)) {
                assertResult(1) { dut.io.dbus.ready.peek().litValue }
              }
              dut.clock.step()
              while (dut.io.axi.read.data.valid.peek().litValue != 1 || dut.io.axi.read.data.ready.peek().litValue != 1) {
                dut.clock.step()
              }
              if (i == len && txn == (readTxnCount - 1)) {
                dut.io.dbus.valid.poke(false.B)
              }
              dut.io.axi.read.data.valid.poke(false.B)
              dut.clock.step()
            }
            dut.io.axi.read.data.valid.poke(false.B)
            dut.clock.step()
          }
        }
      })
    }
  }

  "Aligned Write then Read" in {
    simulate(new DBus2AxiV1(p)) { dut =>
      val cases = Array(
        new Case(0x00000000, 4, 0x11223344, 0x0000000fL),
        new Case(0x00000004, 4, 0x22334455, 0x000000f0L),
        new Case(0x00000008, 4, 0x33445566, 0x00000f00L),
        new Case(0x0000000c, 4, 0x44556677, 0x0000f000L),
        new Case(0x00000010, 4, 0x55667788, 0x000f0000L),
        new Case(0x00000014, 4, 0x66778899, 0x00f00000L),
        new Case(0x00000018, 4, 0x778899aa, 0x0f000000L),
        new Case(0x0000001c, 4, 0x0899aabb, 0xf0000000L),
        new Case(0x00000000, 2, 0x1111, 0x00000003L),
        new Case(0x00000002, 2, 0x2222, 0x0000000cL),
        new Case(0x00000004, 2, 0x3333, 0x00000030L),
        new Case(0x00000006, 2, 0x4444, 0x000000c0L),
        new Case(0x00000008, 2, 0x5555, 0x00000300L),
        new Case(0x0000000a, 2, 0x6666, 0x00000c00L),
        new Case(0x0000000c, 2, 0x7777, 0x00003000L),
        new Case(0x0000000e, 2, 0x8888, 0x0000c000L),
        new Case(0x00000010, 2, 0x9999, 0x00030000L),
        new Case(0x00000012, 2, 0xaaaa, 0x000c0000L),
        new Case(0x00000014, 2, 0xbbbb, 0x00300000L),
        new Case(0x00000016, 2, 0xcccc, 0x00c00000L),
        new Case(0x00000018, 2, 0xdddd, 0x03000000L),
        new Case(0x0000001a, 2, 0xeeee, 0x0c000000L),
        new Case(0x0000001c, 2, 0xffff, 0x30000000L),
        new Case(0x0000001e, 2, 0x1111, 0xc0000000L),
        new Case(0x00000000, 1, 0x1, 0x00000001L),
        new Case(0x00000001, 1, 0x2, 0x00000002L),
        new Case(0x00000002, 1, 0x3, 0x00000004L),
        new Case(0x00000003, 1, 0x4, 0x00000008L),
        new Case(0x00000004, 1, 0x5, 0x00000010L),
        new Case(0x00000005, 1, 0x6, 0x00000020L),
        new Case(0x00000006, 1, 0x7, 0x00000040L),
        new Case(0x00000007, 1, 0x8, 0x00000080L),
        new Case(0x00000008, 1, 0x9, 0x00000100L),
        new Case(0x00000009, 1, 0xa, 0x00000200L),
        new Case(0x0000000a, 1, 0xb, 0x00000400L),
        new Case(0x0000000b, 1, 0xc, 0x00000800L),
        new Case(0x0000000c, 1, 0xd, 0x00001000L),
        new Case(0x0000000d, 1, 0xe, 0x00002000L),
        new Case(0x0000000e, 1, 0xf, 0x00004000L),
        new Case(0x0000000f, 1, 0x1, 0x00008000L),
        new Case(0x00000010, 1, 0x2, 0x00010000L),
        new Case(0x00000011, 1, 0x3, 0x00020000L),
        new Case(0x00000012, 1, 0x4, 0x00040000L),
        new Case(0x00000013, 1, 0x5, 0x00080000L),
        new Case(0x00000014, 1, 0x6, 0x00100000L),
        new Case(0x00000015, 1, 0x7, 0x00200000L),
        new Case(0x00000016, 1, 0x8, 0x00400000L),
        new Case(0x00000017, 1, 0x9, 0x00800000L),
        new Case(0x00000018, 1, 0xa, 0x01000000L),
        new Case(0x00000019, 1, 0xb, 0x02000000L),
        new Case(0x0000001a, 1, 0xc, 0x04000000L),
        new Case(0x0000001b, 1, 0xd, 0x08000000L),
        new Case(0x0000001c, 1, 0xe, 0x10000000L),
        new Case(0x0000001d, 1, 0xf, 0x20000000L),
        new Case(0x0000001e, 1, 0x1, 0x40000000L),
        new Case(0x0000001f, 1, 0x2, 0x80000000L),
      )
      cases.foreach(c => {
        val shiftedData: BigInt = c.data << (c.addr * 8)
        val alignedAddr = c.addr - (c.addr % c.size)

        dut.io.axi.read.addr.ready.poke(false.B)
        dut.io.axi.read.data.valid.poke(false.B)
        dut.io.axi.write.data.ready.poke(false.B)
        dut.io.axi.write.addr.ready.poke(false.B)
        dut.io.axi.write.resp.valid.poke(false.B)
        dut.clock.step()

        // Build a DBus transaction
        dut.io.dbus.valid.poke(true.B)
        dut.io.dbus.addr.poke(c.addr.U)
        dut.io.dbus.write.poke(true.B)
        dut.io.dbus.wdata.poke(shiftedData.U(p.axi2DataBits.W))
        dut.io.dbus.wmask.poke(c.mask.U)
        dut.io.dbus.size.poke(c.size.U)

        val (waddr, wsize, wlen) = {
          dut.io.axi.write.addr.ready.poke(true.B)
          while (dut.io.axi.write.addr.valid.peek().litValue != 1 || dut.io.axi.write.addr.ready.peek().litValue != 1) {
            dut.clock.step()
          }
          val rv = (
            dut.io.axi.write.addr.bits.addr.peek().litValue,
            dut.io.axi.write.addr.bits.size.peek().litValue,
            dut.io.axi.write.addr.bits.len.peek().litValue,
          )
          dut.clock.step()
          dut.io.axi.write.addr.ready.poke(false.B)
          rv
        }

        assertResult(waddr) { alignedAddr }
        assertResult(wsize) { log2Ceil(c.size) }
        assertResult(wlen) { 0 }

        val (wdata, wstrb) = {
          dut.io.axi.write.data.ready.poke(true.B)
          while (dut.io.axi.write.data.valid.peek().litValue != 1 || dut.io.axi.write.data.ready.peek().litValue != 1) {
            dut.clock.step()
          }
          assertResult(1) { dut.io.axi.write.data.bits.last.peek().litValue }
          val rv = (
            dut.io.axi.write.data.bits.data.peek().litValue,
            dut.io.axi.write.data.bits.strb.peek().litValue,
          )
          dut.clock.step()
          dut.io.axi.write.data.ready.poke(false.B)
          rv
        }

        assertResult(wdata) { shiftedData & generateBitmask(c.mask) }
        assertResult(wstrb) { c.mask }

        {
          dut.io.axi.write.resp.valid.poke(true.B)
          dut.io.axi.write.resp.bits.id.poke(0.U)
          dut.io.axi.write.resp.bits.resp.poke(0.U)
          while (dut.io.axi.write.resp.ready.peek().litValue != 1 || dut.io.axi.write.resp.valid.peek().litValue != 1) {
            dut.clock.step()
          }
          assertResult(1) { dut.io.dbus.ready.peek().litValue }
          dut.clock.step()
          dut.io.dbus.valid.poke(false.B)
          dut.io.axi.write.resp.valid.poke(false.B)
        }

        assertResult(0) { dut.io.dbus.ready.peek().litValue }
        dut.io.dbus.valid.poke(true.B)
        dut.io.dbus.addr.poke(c.addr.U)
        dut.io.dbus.write.poke(false.B)
        dut.io.dbus.size.poke(c.size.U)
        dut.clock.step()

        val (len, addr, size) = {
          assertResult(0) { dut.io.axi.read.addr.ready.peek().litValue }
          dut.io.axi.read.addr.ready.poke(true.B)
          while (dut.io.axi.read.addr.valid.peek().litValue != 1 || dut.io.axi.read.addr.ready.peek().litValue != 1) {
            dut.clock.step()
          }
          val rv = (
            dut.io.axi.read.addr.bits.len.peek().litValue,
            dut.io.axi.read.addr.bits.addr.peek().litValue,
            dut.io.axi.read.addr.bits.size.peek().litValue,
          )
          dut.clock.step()
          dut.io.axi.read.addr.ready.poke(false.B)
          rv
        }

        assertResult(len) { 0 }
        assertResult(size) { log2Ceil(c.size) }
        assertResult(addr) { c.addr }

        {
          assertResult(0) { dut.io.axi.read.data.valid.peek().litValue }
          for (i <- 0 to (len).toInt) {
            dut.io.axi.read.data.valid.poke(true)
            dut.io.axi.read.data.bits.id.poke(0)
            dut.io.axi.read.data.bits.data.poke(0)
            dut.io.axi.read.data.bits.resp.poke(0) // OKAY
            dut.io.axi.read.data.bits.last.poke(true)
            assertResult(1) { dut.io.dbus.ready.peek().litValue }
            dut.clock.step()
            while (dut.io.axi.read.data.valid.peek().litValue != 1 || dut.io.axi.read.data.ready.peek().litValue != 1) {
              dut.clock.step()
            }
            dut.io.dbus.valid.poke(false.B)
            dut.io.axi.read.data.valid.poke(false.B)
            dut.clock.step()
          }
          dut.io.axi.read.data.valid.poke(false.B)
          dut.clock.step()
        }
      })
    }
  }
}
