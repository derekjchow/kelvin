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
import common.Fp32

class FRegfileRead extends Bundle {
  val valid = Input(Bool())
  val addr  = Input(UInt(5.W))
  val data  = Output(new Fp32)
}

class FRegfileWrite extends Bundle {
  val valid = Input(Bool())
  val addr  = Input(UInt(5.W))
  val data  = Input(new Fp32)
}

class FRegfile(n_read: Int, n_write: Int) extends Module {
  val io = IO(new Bundle {
    val read_ports = Vec(n_read, new FRegfileRead)
    val write_ports = Vec(n_write, new FRegfileWrite)

    val scoreboard_set = Input(UInt(32.W))
    val scoreboard = Output(UInt(32.W))
    val exception = Output(Bool())
  })

  val fregfile = Reg(Vec(32, new Fp32))
  val scoreboard = RegInit(0.U(32.W))

  // Update scoreboard
  val scoreboard_clr = io.write_ports.map(x =>
      Mux(x.valid, UIntToOH(x.addr), 0.U)).reduce(_|_)
  scoreboard := (scoreboard & ~scoreboard_clr) | io.scoreboard_set
  io.scoreboard := scoreboard

  // Writes
  val register_write_error = Wire(Vec(32, Bool()))
  for (i <- 0 until 32) {
    val valid = io.write_ports.map(x => x.valid & x.addr === i.U)
    val data = PriorityMux(valid, io.write_ports.map(_.data))
    register_write_error(i) := PopCount(valid) > 1.U
    when (valid.reduce(_|_)) {
      fregfile(i) := data
    }
  }
  io.exception := register_write_error.reduce(_|_)

  // Reads
  for (i <- 0 until n_read) {
    val read_port = io.read_ports(i)
    read_port.data := Mux(read_port.valid,
                          fregfile(read_port.addr),
                          Fp32.Zero(false.B))
  }
}
