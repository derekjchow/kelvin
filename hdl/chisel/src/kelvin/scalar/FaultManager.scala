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

package kelvin

import chisel3._
import chisel3.util._

class FaultManagerOutput extends Bundle {
  val mepc = UInt(32.W)
  val mtval = UInt(32.W)
  val mcause = UInt(32.W)
}

class FaultManager(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val in = new Bundle {
      val fault = Input(Vec(p.instructionLanes, new Bundle {
        val csr = Bool()
        val jal = Bool()
        val jalr = Bool()
        val bxx = Bool()
        val undef = Bool()
        val rvv = if (p.enableRvv) Some(Bool()) else None
      }))
      val pc = Input(Vec(p.instructionLanes, new Bundle {
        val pc = UInt(32.W)
      }))
      val memory_fault = Input(Valid(new FaultInfo(p)))
      val ibus_fault = Input(Bool())
      val undef = Input(Vec(p.instructionLanes, new Bundle {
        val inst = UInt(32.W)
      }))
      val jal = Input(Vec(p.instructionLanes, new Bundle {
        val target = UInt(32.W)
      }))
      val jalr = Input(Vec(p.instructionLanes, new Bundle {
        val target = UInt(32.W)
      }))
    }
    val out = Output(Valid(new FaultManagerOutput))
  })

  val faults = VecInit((0 until p.instructionLanes).map(x => (
      io.in.fault(x).csr |
      io.in.fault(x).jal |
      io.in.fault(x).jalr |
      io.in.fault(x).bxx |
      io.in.fault(x).undef |
      io.in.fault(x).rvv.getOrElse(false.B))))
  val fault = faults.reduce(_|_)
  val first_fault = PriorityEncoder(faults)
  val undef_fault = io.in.fault.map(_.undef).reduce(_|_)
  val undef_fault_idx = PriorityEncoder(io.in.fault.map(_.undef))
  val csr_fault = io.in.fault.map(_.csr).reduce(_|_)
  val csr_fault_idx = PriorityEncoder(io.in.fault.map(_.csr))
  val jal_fault = io.in.fault.map(_.jal).reduce(_|_)
  val jal_fault_idx = PriorityEncoder(io.in.fault.map(_.jal))
  val jalr_fault = io.in.fault.map(_.jalr).reduce(_|_)
  val jalr_fault_idx = PriorityEncoder(io.in.fault.map(_.jalr))
  val bxx_fault = io.in.fault.map(_.bxx).reduce(_|_)
  val bxx_fault_idx = PriorityEncoder(io.in.fault.map(_.bxx))
  val rvv_fault = io.in.fault.map(_.rvv.getOrElse(false.B)).reduce(_|_)
  val rvv_fault_idx = PriorityEncoder(io.in.fault.map(_.rvv.getOrElse(false.B)))
  val instr_access_fault = io.in.memory_fault.valid && io.in.ibus_fault
  val load_fault = io.in.memory_fault.valid && !io.in.memory_fault.bits.write && !io.in.ibus_fault
  val store_fault = io.in.memory_fault.valid && io.in.memory_fault.bits.write && !io.in.ibus_fault

  io.out.valid := fault || io.in.memory_fault.valid
  io.out.bits.mepc := MuxCase(0.U(32.W), Seq(
    load_fault -> io.in.memory_fault.bits.epc,
    store_fault -> io.in.memory_fault.bits.epc,
    instr_access_fault -> io.in.memory_fault.bits.epc,
    fault -> io.in.pc(first_fault).pc,
  ))
  io.out.bits.mcause := MuxCase(0.U(32.W), Seq(
    load_fault -> 5.U(32.W),
    store_fault -> 7.U(32.W),
    instr_access_fault -> 1.U(32.W),
    (csr_fault && (csr_fault_idx === first_fault)) -> 2.U(32.W),
    (jal_fault && (jal_fault_idx === first_fault)) -> 0.U(32.W),
    (jalr_fault && (jalr_fault_idx === first_fault)) -> 0.U(32.W),
    (bxx_fault && (bxx_fault_idx === first_fault)) -> 0.U(32.W),
    (undef_fault && (undef_fault_idx === first_fault)) -> 2.U(32.W),
    (rvv_fault && (rvv_fault_idx === first_fault)) -> 2.U(32.W),
  ))
  io.out.bits.mtval := MuxCase(0.U(32.W), Seq(
    load_fault -> io.in.memory_fault.bits.addr,
    store_fault -> io.in.memory_fault.bits.addr,
    instr_access_fault -> 0.U(32.W),
    (csr_fault && (csr_fault_idx === first_fault)) -> 0.U,
    (jal_fault && (jal_fault_idx === first_fault)) -> io.in.jal(jal_fault_idx).target,
    (jalr_fault && (jalr_fault_idx === first_fault)) -> (io.in.jalr(jalr_fault_idx).target & "xFFFFFFFE".U),
    (bxx_fault && (bxx_fault_idx === first_fault)) -> 0.U(32.W),
    (undef_fault && (undef_fault_idx === first_fault)) -> io.in.undef(undef_fault_idx).inst,
    (rvv_fault && (rvv_fault_idx === first_fault)) -> io.in.undef(rvv_fault_idx).inst,
  ))
}