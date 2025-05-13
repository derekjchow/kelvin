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
  def apply(instructionLanes: Integer, vlen: Integer): String = {
    var moduleInterface = """module RvvCoreWrapper(
        |    input clk,
        |    input rstn,
        |    input logic [VSTART_LEN:0] vstart,
        |    input logic [1:0] vxrm,
        |    input logic vxsat,
        |""".stripMargin.replaceAll("VSTART_LEN", (log2Ceil(vlen) - 1).toString)

    // Add instruction interface inputs
    for (i <- 0 until instructionLanes) {
        moduleInterface += """    input inst_GENI_valid,
            |    input [31:0] inst_GENI_bits_pc,
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
    moduleInterface += """    output async_rd_valid,
        |    output [4:0] async_rd_bits_addr,
        |    output [31:0] async_rd_bits_data,
        |    input async_rd_ready,
        |""".stripMargin

    // Add CSR output
    moduleInterface += """    output vcsr_valid,
        |    output [VSTART_LEN:0] vcsr_vstart,
        |    output [1:0] vcsr_xrm,
        |    input vcsr_ready,
        |""".stripMargin.replaceAll("VSTART_LEN", (log2Ceil(vlen) - 1).toString)

    // Remove last comma/linebreak
    moduleInterface = moduleInterface.dropRight(2)
    moduleInterface += "\n);\n"

    // Inst valid
    var coreInstantiation = "  logic [GENN-1:0] inst_valid;\n".replaceAll(
            "GENN", instructionLanes.toString)
    for (i <- 0 until instructionLanes) {
      coreInstantiation += "  assign inst_valid[GENI] = inst_GENI_valid;\n".replaceAll(
          "GENI", i.toString)
    }

    // Inst data
    coreInstantiation += "  RVVInstruction [GENN-1:0] inst_data;\n".replaceAll(
            "GENN", instructionLanes.toString)
    for (i <- 0 until instructionLanes) {
      // TODO(derekjchow): Plumb in pc later
      // coreInstantiation += "  assign inst_data[GENI].pc = inst_GENI_bits_pc;\n".replaceAll(
      //     "GENI", i.toString)
      coreInstantiation += "  assign inst_data[GENI].opcode = RVVOpCode'(inst_GENI_bits_opcode);\n".replaceAll(
          "GENI", i.toString)
      coreInstantiation += "  assign inst_data[GENI].bits = inst_GENI_bits_bits;\n".replaceAll(
          "GENI", i.toString)
    }

    // Inst ready temp output
    coreInstantiation += "  logic [GENN-1:0] inst_ready;\n".replaceAll(
        "GENN", instructionLanes.toString)

    // Scalar regfile read
    coreInstantiation += "  logic [2*GENN-1:0] reg_read_valid;\n".replaceAll(
            "GENN", instructionLanes.toString)
    for (i <- 0 until 2*instructionLanes) {
      coreInstantiation += "  assign reg_read_valid[GENI] = rs_GENI_valid;\n".replaceAll(
          "GENI", i.toString)
    }
    coreInstantiation += "  logic [2*GENN-1:0][31:0] reg_read_data;\n".replaceAll(
            "GENN", instructionLanes.toString)
    for (i <- 0 until 2*instructionLanes) {
      coreInstantiation += "  assign reg_read_data[GENI] = rs_GENI_data;\n".replaceAll(
          "GENI", i.toString)
    }

    // Scalar regfile write temp output
    coreInstantiation += """  logic [GENN-1:0] reg_write_valid;
        |  logic [GENN-1:0][4:0] reg_write_addr;
        |  logic [GENN-1:0][31:0] reg_write_data;
        |""".stripMargin.replaceAll("GENN", instructionLanes.toString)

    // VCSR temp output
    coreInstantiation += """  RVVConfigState vector_csr;
        |  assign vcsr_vstart = vector_csr.vstart;
        |  assign vcsr_xrm = vector_csr.xrm;
        |""".stripMargin

    coreInstantiation += """  RvvCore#(.N (GENN)) core(
        |      .clk(clk),
        |      .rstn(rstn),
        |      .vstart(vstart),
        |      .vxrm(vxrm),
        |      .vxsat(vxsat),
        |      .inst_valid(inst_valid),
        |      .inst_data(inst_data),
        |      .inst_ready(inst_ready),
        |      .reg_read_valid(reg_read_valid),
        |      .reg_read_data(reg_read_data),
        |      .reg_write_valid(reg_write_valid),
        |      .reg_write_addr(reg_write_addr),
        |      .reg_write_data(reg_write_data),
        |      .async_rd_valid(async_rd_valid),
        |      .async_rd_addr(async_rd_bits_addr),
        |      .async_rd_data(async_rd_bits_data),
        |      .async_rd_ready(async_rd_ready),
        |      .vcsr_valid(vcsr_valid),
        |      .vector_csr(vector_csr),
        |      .vcsr_ready(vcsr_ready)
        |""".stripMargin.replaceAll("GENN", instructionLanes.toString)
    coreInstantiation += "  );\n"

    // Connect temp outputs
    for (i <- 0 until instructionLanes) {
      coreInstantiation += "  assign inst_GENI_ready = inst_ready[GENI];\n".replaceAll("GENI", i.toString)
    }
    for (i <- 0 until instructionLanes) {
      coreInstantiation += """  assign rd_GENI_valid = reg_write_valid[GENI];
      |  assign rd_GENI_bits_addr = reg_write_addr[GENI];
      |  assign rd_GENI_bits_data = reg_write_data[GENI];
      |""".stripMargin.replaceAll("GENI", i.toString)
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

    val vstart = Input(UInt(log2Ceil(p.rvvVlen).W))
    val vxrm = Input(UInt(2.W))
    val vxsat = Input(UInt(1.W))

    val inst = Vec(p.instructionLanes,
        Flipped(Decoupled(new RvvCompressedInstruction)))

    val rs = Vec(p.instructionLanes * 2, Flipped(new RegfileReadDataIO))
    val rd = Vec(p.instructionLanes, Valid(new RegfileWriteDataIO))

    val async_rd = Decoupled(new RegfileWriteDataIO)

    val vcsr_valid = Output(Bool())
    val vcsr_vstart = Output(UInt(7.W))
    val vcsr_xrm = Output(UInt(2.W))
    val vcsr_ready = Input(Bool())
  })

  // Resources must be sorted topologically by dependency DAG
  addResource("hdl/verilog/rvv/inc/rvv_backend_config.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_define.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_sva.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_alu.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_dispatch.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_div.svh")
  addResource("hdl/verilog/rvv/inc/rvv_backend_pmtrdt.svh")
  addResource("hdl/verilog/rvv/common/cdffr.sv")
  addResource("hdl/verilog/rvv/common/compressor_3_2.sv")
  addResource("hdl/verilog/rvv/common/compressor_4_2.sv")
  addResource("hdl/verilog/rvv/common/dff.sv")
  addResource("hdl/verilog/rvv/common/edff.sv")
  addResource("hdl/verilog/rvv/common/edff_2d.sv")
  addResource("hdl/verilog/rvv/common/fifo_flopped.sv")
  addResource("hdl/verilog/rvv/common/fifo_flopped_2w2r.sv")
  addResource("hdl/verilog/rvv/common/fifo_flopped_4w2r.sv")
  addResource("hdl/verilog/rvv/common/multi_fifo.sv")
  addResource("hdl/verilog/rvv/design/Aligner.sv")
  addResource("hdl/verilog/rvv/design/MultiFifo.sv")
  addResource("hdl/verilog/rvv/design/RvvFrontEnd.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_addsub.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_execution_p1.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_mask_viota.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_mask.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_other.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit_shift.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_alu.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_decode_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_decode_unit_ari.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_decode_unit_lsu.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_decode_ctrl.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_decode.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_bypass.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_ctrl.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_operand.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_opr_byte_type.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_raw_uop_rob.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_raw_uop_uop.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch_structure_hazard.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_dispatch.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_div_unit_divider.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_div_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_div.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_lsu_remap.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_mul_unit_mul8.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_mac_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_mul_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_mulmac.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_pmtrdt_unit.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_pmtrdt.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_retire.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_rob.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_vrf_reg.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend_vrf.sv")
  addResource("hdl/verilog/rvv/design/rvv_backend.sv")
  addResource("hdl/verilog/rvv/design/RvvCore.sv")
  setInline("RvvCoreWrapper.sv", GenerateCoreShimSource(p.instructionLanes, p.rvvVlen))
}

// Shim class for RVVCore, which translates the SV RVVCore interfaces with the
// Chisel ones. Note, we name this class "RvvCoreShim" to avoid conflict with
// the "RvvCore" defined in SystemVerilog
class RvvCoreShim(p: Parameters) extends Module {
  val io = IO(new RvvCoreIO(p))

  val vstart = RegInit(0.U(log2Ceil(p.rvvVlen).W))
  val vxrm = RegInit(0.U(2.W))

  val rstn = (!reset.asBool).asAsyncReset
  val rvvCoreWrapper = Module(new RvvCoreWrapper(p))
  rvvCoreWrapper.io.clk := clock
  rvvCoreWrapper.io.rstn := rstn
  rvvCoreWrapper.io.inst <> io.inst
  rvvCoreWrapper.io.rs <> io.rs
  rvvCoreWrapper.io.rd <> io.rd
  rvvCoreWrapper.io.async_rd <> io.async_rd

  rvvCoreWrapper.io.vstart := vstart
  rvvCoreWrapper.io.vxrm := vxrm
  rvvCoreWrapper.io.vxsat := 0.U
  rvvCoreWrapper.io.vcsr_ready := true.B

  vstart := Mux(rvvCoreWrapper.io.vcsr_valid, rvvCoreWrapper.io.vcsr_vstart, vstart)
  vxrm := Mux(rvvCoreWrapper.io.vcsr_valid, rvvCoreWrapper.io.vcsr_xrm, vxrm)
}
