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

class Sram_12ffcp_128x128 extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock    = Input(Clock())
    val enable   = Input(Bool())
    val write    = Input(Bool())
    val addr     = Input(UInt(7.W))
    val wdata    = Input(UInt(128.W))
    val wmask    = Input(UInt(16.W))
    val rdata    = Output(UInt(128.W))
  })
  addResource("hdl/verilog/Sram_12ffcp_128x128.v")
}