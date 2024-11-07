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

package kelvin.rvv

import chisel3._
import chisel3.util._
import kelvin.{Parameters,RegfileReadDataIO,RegfileWriteDataIO}
import common.{MakeInvalid}

object RvvCore {
  def apply(p: Parameters): RvvCoreShim = {
    return Module(new RvvCoreShim(p))
  }
}

object GenerateCoreShimSource {
  def apply(instructionLanes: Integer): String = {

        var moduleInterface = """module RvvCoreWrapper(
            |    input clk,
            |    input rstn,
            |""".stripMargin
        // Add instruction interface inputs
        for (i <- 0 until instructionLanes) {
            moduleInterface += """    input inst_GENI_valid,
                |    input [1:0] inst_GENI_bits_opcode,
                |    input [24:0] inst_GENI_bits_bits,
                |""".stripMargin.replaceAll("GENI", i.toString)
        }

        // Add regfile read interface inputs
        for (i <- 0 until 2*instructionLanes) {
            moduleInterface += """    input rs_GENI_valid,
                |    input [31:0] rs_GENI_data,
                |""".stripMargin.replaceAll("GENI", i.toString)
        }

        // Add instruction interface outputs (backpressure)
        for (i <- 0 until instructionLanes) {
            moduleInterface += "    output inst_GENI_ready,\n".replaceAll(
                "GENI", i.toString)
        }

        // Add regfile write interface outputs
        for (i <- 0 until instructionLanes) {
            moduleInterface += """    output rd_GENI_valid,
                |    output [4:0] rd_GENI_bits_addr,
                |    output [31:0] rd_GENI_bits_data,
                |""".stripMargin.replaceAll("GENI", i.toString)
        }

        // Remove last comma/linebreak
        moduleInterface = moduleInterface.dropRight(2)
        moduleInterface += "\n);\n"

        // Inst valid
        var coreInstantiation = "  logic inst_valid[GENN-1:0] = {\n".replaceAll(
                "GENN", instructionLanes.toString)
        for (i <- 0 until instructionLanes) {
            coreInstantiation += "      inst_GENI_valid,\n".replaceAll(
                "GENI", i.toString)
        }
        coreInstantiation = coreInstantiation.dropRight(2)
        coreInstantiation += "\n  };\n"

        // Inst data
        coreInstantiation += "  RVVInstruction inst_data[GENN-1:0];\n".replaceAll(
                "GENN", instructionLanes.toString)
        for (i <- 0 until instructionLanes) {
            coreInstantiation += "  assign inst_data[GENI].opcode = inst_GENI_bits_opcode;\n".replaceAll(
                "GENI", i.toString)
            coreInstantiation += "  assign inst_data[GENI].bits = inst_GENI_bits_bits;\n".replaceAll(
                "GENI", i.toString)
        }

        // Inst ready temp output
        coreInstantiation += "  wire inst_ready[GENN-1:0];\n".replaceAll(
                "GENN", instructionLanes.toString)

        // Scalar regfile read
        coreInstantiation += "  logic reg_read_valid[2*GENN-1:0] = {\n".replaceAll(
                "GENN", instructionLanes.toString)
        for (i <- 0 until 2*instructionLanes) {
            coreInstantiation += "      rs_GENI_valid,\n".replaceAll(
                "GENI", i.toString)
        }
        coreInstantiation = coreInstantiation.dropRight(2)
        coreInstantiation += "\n  };\n"
        coreInstantiation += "  logic [31:0] reg_read_data[2*GENN-1:0] = {\n".replaceAll(
                "GENN", instructionLanes.toString)
        for (i <- 0 until 2*instructionLanes) {
            coreInstantiation += "      rs_GENI_data,\n".replaceAll(
                "GENI", i.toString)
        }
        coreInstantiation = coreInstantiation.dropRight(2)
        coreInstantiation += "\n  };\n"

        // Scalar regfile write temp output
        coreInstantiation += """  wire reg_write_valid[GENN-1:0];
            |  wire [4:0] reg_write_addr [GENN-1:0];
            |  wire [31:0] reg_write_data [GENN-1:0];
            |""".stripMargin.replaceAll("GENN", instructionLanes.toString)

        coreInstantiation += """  RvvCore#(.N (GENN)) core(
            |      .clk(clk),
            |      .rstn(rstn),
            |      .inst_valid(inst_valid),
            |      .inst_data(inst_data),
            |      .inst_ready(inst_ready),
            |      .reg_read_valid(reg_read_valid),
            |      .reg_read_data(reg_read_data),
            |      .reg_write_valid(reg_write_valid),
            |      .reg_write_addr(reg_write_addr),
            |      .reg_write_data(reg_write_data)
            |""".stripMargin.replaceAll("GENN", instructionLanes.toString)
        coreInstantiation += "  );\n"

        // Connect temp outputs
        for (i <- 0 until instructionLanes) {
          coreInstantiation += "  assign inst_GENI_ready = inst_ready[GENI];\n".replaceAll("GENI", i.toString)
        }
        for (i <- 0 until instructionLanes) {
          coreInstantiation += """  assign rd_GENI_valid = reg_write_valid[GENI];
          |  assign rd_GENI_bits_addr = reg_write_addr[GENI];
          |  assign rd_GENI_bits_data = reg_write_data[GENI];""".stripMargin.replaceAll("GENI", i.toString)
        }

        moduleInterface + coreInstantiation + "endmodule\n"
    }
}

// Shim class for RVVCore, which invokes the RVV SV interface with the correct
// parameters.
class RvvCoreWrapper(p: Parameters) extends BlackBox with HasBlackBoxInline
                                                     with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clk  = Input(Clock())
    val rstn = Input(AsyncReset())
 
    val inst = Vec(p.instructionLanes,
        Flipped(Decoupled(new RvvCompressedInstruction)))

    val rs = Vec(p.instructionLanes * 2, Flipped(new RegfileReadDataIO))
    val rd = Vec(p.instructionLanes, Valid(new RegfileWriteDataIO))
  })

  addResource("hdl/verilog/rvv/interfaces.sv")
  addResource("hdl/verilog/rvv/RvvCore.sv")
  setInline("RvvCoreWrapper.sv", GenerateCoreShimSource(p.instructionLanes))
}

// Shim class for RVVCore, which translates the SV RVVCore interfaces with the
// Chisel ones
class RvvCoreShim(p: Parameters) extends Module {
  val io = IO(new RvvCoreIO(p))

  val rstn = (!reset.asBool).asAsyncReset
  val rvvCoreWrapper = Module(new RvvCoreWrapper(p))
  rvvCoreWrapper.io.clk := clock
  rvvCoreWrapper.io.rstn := rstn
  rvvCoreWrapper.io.inst <> io.inst
  rvvCoreWrapper.io.rs <> io.rs
  rvvCoreWrapper.io.rd <> io.rd

  // val inst = RegInit(
  //     VecInit.fill(p.instructionLanes)(MakeInvalid(new RvvCompressedInstruction)))

  // // Decode stage
  // for (i <- 0 until p.instructionLanes) {
  //   // TODO(derekjchow): Handle back pressure correctly
  //   io.inst(i).ready := true.B
  //   when (io.inst(i).valid) {
  //     printf(cf"Got rvv instruction ${io.inst(i).bits}\n")
  //   }

  //   inst(i).valid := io.inst(i).valid
  //   inst(i).bits := io.inst(i).bits

  //   assert(!io.inst(i).valid)
  // }

  // for (i <- 0 until p.instructionLanes) {
  //   io.rd(i).valid := false.B
  //   io.rd(i).bits.addr := 0.U
  //   io.rd(i).bits.data := 0.U
  // }
}