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

package bus

import chisel3._
import chisel3.util._

case object AxiResponse {
  val okay = 0
  val rsvd = 1
  val slverr = 2
  val mmuerr = 3
}

// case object AxiBurst {
//   val fixed = 0
//   val incr = 1
//   val wrap = 2
// }

// case object AxiSize {
//   val bytes1 = 0
//   val bytes2 = 1
//   val bytes4 = 2
//   val bytes8 = 3
//   val bytes16 = 4
//   val bytes32 = 5
//   val bytes64 = 6
//   val bytes128 = 7
// }

class AxiAddress(addrWidthBits: Int, idBits: Int) extends Bundle {
  val addr  = UInt(addrWidthBits.W)
  val id    = UInt(idBits.W)
  // val burst = UInt(2.W)
  // val size  = UInt(3.W)

  def defaults() = {
    addr  := 0.U
    id    := 0.U
    // burst := new AxiBurst().fixed
    // size  := new AxiSize().bytes4
  }
}

class AxiWriteData(dataWidthBits: Int) extends Bundle {
  val data = UInt(dataWidthBits.W)
  val strb = UInt((dataWidthBits/8).W)

  def defaults() = {
    data := 0.U
    strb := ((1 << (dataWidthBits/8)) - 1).U
  }
}

class AxiWriteResponse(idBits: Int) extends Bundle {
  val id   = UInt(idBits.W)
  val resp = UInt(2.W)

  def defaults() = {
    id   := 0.U
    resp := 0.U
  }

  def defaultsFlipped() = {
    id   := 0.U
    resp := 0.U
  }
}

class AxiReadData(dataWidthBits: Int, idBits: Int) extends Bundle {
  val resp = UInt(2.W)
  val id   = UInt(idBits.W)
  val data = UInt(dataWidthBits.W)
  // val last = Bool()

  def defaultsFlipped() = {
    resp := 0.U
    id := 0.U
    data := 0.U
    // last := false.B
  }
}

class AxiLiteAddress(addrWidthBits: Int) extends Bundle {
  val addr = UInt(addrWidthBits.W)
  val prot = UInt(3.W)
}

class AxiLiteWriteData(dataWidthBits: Int) extends Bundle {
  val data = UInt(dataWidthBits.W)
  val strb = UInt((dataWidthBits/8).W)
}

class AxiLiteReadData(dataWidthBits: Int) extends Bundle {
  val data = UInt(dataWidthBits.W)
  val resp = UInt(2.W)
}

class AxiMasterIO(addrWidthBits: Int, dataWidthBits: Int, idBits: Int)
    extends Bundle {
  val write = new AxiMasterWriteIO(addrWidthBits, dataWidthBits, idBits)
  val read = new AxiMasterReadIO(addrWidthBits, dataWidthBits, idBits)

  def defaults() = {
    write.defaults()
    read.defaults()
  }

  def defaultsFlipped() = {
    write.defaultsFlipped()
    read.defaultsFlipped()
  }
}

class AxiMasterWriteIO(addrWidthBits: Int, dataWidthBits: Int, idBits: Int)
    extends Bundle {
  val addr = Decoupled(new AxiAddress(addrWidthBits, idBits))
  val data = Decoupled(new AxiWriteData(dataWidthBits))
  val resp = Flipped(Decoupled(new AxiWriteResponse(idBits)))

  def defaults() = {
    addr.bits.defaults()
    data.bits.defaults()
    addr.valid := false.B
    data.valid := false.B
    resp.ready := true.B
  }

  def defaultsFlipped() = {
    addr.ready := false.B
    data.ready := false.B
    resp.valid := false.B
    resp.bits.defaultsFlipped()
  }
}

class AxiMasterReadIO(addrWidthBits: Int, dataWidthBits: Int, idBits: Int)
    extends Bundle {
  val addr = Decoupled(new AxiAddress(addrWidthBits, idBits))
  val data = Flipped(Decoupled(new AxiReadData(dataWidthBits, idBits)))

  def defaults() = {
    addr.bits.defaults()
    addr.valid := false.B
    data.ready := false.B
  }

  def defaultsFlipped() = {
    addr.ready := false.B
    data.valid := false.B
    data.bits.defaultsFlipped()
  }
}

class AxiLiteMasterIO(val addrWidthBits: Int, val dataWidthBits: Int) extends Bundle {
  val read  = new AxiLiteMasterReadIO(addrWidthBits, dataWidthBits)
  val write = new AxiLiteMasterWriteIO(addrWidthBits, dataWidthBits)
}

class AxiLiteMasterWriteIO(val addrWidthBits: Int, val dataWidthBits: Int) extends Bundle {
  val addr = Decoupled(new AxiLiteAddress(addrWidthBits))
  val data = Decoupled(new AxiLiteWriteData(dataWidthBits))
  val resp = Flipped(Decoupled(UInt(2.W)))
}

class AxiLiteMasterReadIO(addrWidthBits: Int, dataWidthBits: Int)
    extends Bundle {
  val addr = Decoupled(new AxiLiteAddress(addrWidthBits))
  val data = Flipped(Decoupled(new AxiLiteReadData(dataWidthBits)))
}
