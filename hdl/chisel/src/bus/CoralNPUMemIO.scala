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

package bus

import chisel3._

class CoralNPUMemIO(p: coralnpu.Parameters) extends Bundle {
  val cvalid = (Output(Bool()))
  val cready = (Input(Bool()))
  val cwrite = (Output(Bool()))
  val caddr  = (Output(UInt(p.axiSysAddrBits.W)))
  val cid    = (Output(UInt(p.axiSysIdBits.W)))
  val wdata  = (Output(UInt(p.axiSysDataBits.W)))
  val wmask  = (Output(UInt((p.axiSysDataBits / 8).W)))
  val rvalid = (Input(Bool()))
  val rid    = (Input(UInt(p.axiSysIdBits.W)))
  val rdata  = (Input(UInt(p.axiSysDataBits.W)))
}
