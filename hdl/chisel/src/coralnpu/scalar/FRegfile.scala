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

package coralnpu

import chisel3._
import chisel3.util._
import common.Fp32

class FRegfile(p: Parameters, n_read: Int, n_write: Int) extends Module {
  val io = IO(new Bundle {
    val read_ports = Vec(n_read, new FRegfileRead)
    val write_ports = Vec(n_write, new FRegfileWrite)
    val dm_write_valid = Option.when(p.useDebugModule)(Input(Bool()))

    val scoreboard_set = Input(UInt(32.W))
    val scoreboard = Output(UInt(32.W))
    val exception = Output(Bool())

    val busPort = new RegfileBusPortIO(p)
    val busPortAddr = Input(UInt(5.W))
  })

  val fregfile = RegInit(VecInit.fill(32)(Fp32.fromWord("x00000000".U(32.W))))
  val scoreboard = RegInit(0.U(32.W))

  // Update scoreboard
  val scoreboard_clr = io.write_ports.map(x =>
      Mux(x.valid, UIntToOH(x.addr), 0.U)).reduce(_|_)
  scoreboard := (scoreboard & ~scoreboard_clr) | io.scoreboard_set
  io.scoreboard := scoreboard

  val scoreboard_error = RegInit(false.B)
  val dm_write_valid = io.dm_write_valid.getOrElse(false.B)
  scoreboard_error := ((scoreboard & scoreboard_clr) =/= scoreboard_clr) && !dm_write_valid
  assert(!scoreboard_error)

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

  io.busPort.addr(0) := 0.U
  // If there's a write in progress, forward the value. Otherwise, fetch from the regfile.
  // TOOD(atv): Generalize this a bit, such that if there is an incoming write on any port for the addr, we fwd it.
  io.busPort.data(0) := (if (n_read < 2) {
    0.U
  } else if (p.useDispatchV2) {
    fregfile(io.busPortAddr).asWord
  } else {
    Mux(io.write_ports(0).valid && (io.write_ports(0).addr === io.read_ports(1).addr),
            io.write_ports(0).data,
            fregfile(io.busPortAddr)).asWord
  })
  for (i <- 1 until p.instructionLanes) {
    io.busPort.addr(i) := 0.U
    io.busPort.data(i) := 0.U
  }
}
