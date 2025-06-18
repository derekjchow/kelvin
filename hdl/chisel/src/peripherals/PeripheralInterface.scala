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

package peripheral

import chisel3._
import chisel3.util._

import bus._
import common._

/** Get a 32-bit AxiMasterReadIO that returns values from a read map.
  * @param idBits The bit-width of the id field in the AXI Interface.
  * @param reads A map of read names to a (address, value) pair.
  */
object ConnectAxiRead {
  def apply(idBits: Integer,
            reads: Map[String, (Int, UInt)]): AxiMasterReadIO = {
    val axiRead = Wire(Flipped(new AxiMasterReadIO(32, 32, idBits)))
    val readReq = Queue(axiRead.addr, 1, pipe=true)

    val readResp = readReq.map{req =>
      val resp = Wire(new AxiReadData(32, idBits))
      val regRead = MuxLookup(req.addr, MakeInvalid(UInt(32.W)))(
        reads.values.map{case (a, b) => (a.U(32.W) -> MakeValid(b))}.toSeq
      )

      resp.id := req.id
      resp.data := regRead.bits
      resp.resp := Mux(regRead.valid, 0.U(2.W), "b10".asUInt(2.W))
      resp.last := true.B

      resp
    }
    axiRead.data <> readResp

    axiRead
  }
}

/** Reads a 32-bit AxiMasterWriteIO and returns the value it tries to write.
  * @param idBits The bit-width of the id field in the AXI Interface.
  * @param reads A map of write names to target address.
  * Returns a map of names->written as well as the data written.
  */
object ConnectAxiWrite {
  def apply(idBits: Integer,
            writeMap: Map[String, Int],
            axiWrite: AxiMasterWriteIO): (Map[String, Bool], UInt) = {
    val writeAddrReq = Queue(axiWrite.addr, 1, true /*pipe*/)
    val writeDataReq = Queue(axiWrite.data, 1, true /*pipe*/)

    // Wait for both queues to be full before removing elements from them
    writeAddrReq.ready := writeDataReq.valid && axiWrite.resp.ready
    writeDataReq.ready := writeAddrReq.valid && axiWrite.resp.ready
    axiWrite.resp.valid := writeDataReq.valid && writeAddrReq.valid
    val writeAddr = writeAddrReq.bits.addr
    val writeData = writeDataReq.bits.data
    val writes = writeMap.view.mapValues(_.U(32.W) === writeAddr)
    axiWrite.resp.bits.id := writeAddrReq.bits.id
    axiWrite.resp.bits.resp := Mux(writes.values.toSeq.reduce(_||_),
                                   0.U(2.W), "b10".asUInt(2.W))

    (writes.toMap, writeData)
  }
}