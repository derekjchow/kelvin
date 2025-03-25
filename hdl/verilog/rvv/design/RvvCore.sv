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

module RvvCore #(parameter N = 4,
                 parameter CMD_BUFFER_MAX_CAPACITY = 16,
                 type RegDataT=logic [31:0],
                 type RegAddrT=logic [4:0])
(
  input clk,
  input rstn,

  input logic [`VSTART_WIDTH-1:0] vstart,
  input logic [1:0] vxrm,
  input logic vxsat,

  // Instruction input.
  input logic [N-1:0] inst_valid,
  input RVVInstruction [N-1:0] inst_data,
  output logic [N-1:0] inst_ready,

  // Register file input
  input logic [(2*N)-1:0] reg_read_valid,
  input RegDataT [(2*N)-1:0] reg_read_data,

  // Scalar Regfile writeback for configuration functions.
  output logic [N-1:0] reg_write_valid,
  output RegAddrT [N-1:0] reg_write_addr,
  output RegDataT [N-1:0] reg_write_data,

  // Scalar Regfile writeback for non-configuration functions.
  output logic async_rd_valid,
  output RegAddrT async_rd_addr,
  output RegDataT async_rd_data,
  input logic async_rd_ready,

  // Vector CSR writeback
  output vcsr_valid,
  output RVVConfigState vector_csr,
  input vcsr_ready
);
  logic [N-1:0] frontend_cmd_valid;
  RVVCmd [N-1:0] frontend_cmd_data;
  logic [$clog2(2*N + 1)-1:0] queue_capacity;
  RvvFrontEnd#(.N(N)) frontend(
      .clk(clk),
      .rstn(rstn),
      .vstart_i(vstart),
      .vxrm_i(vxrm),
      .vxsat_i(vxsat),
      .inst_valid_i(inst_valid),
      .inst_data_i(inst_data),
      .inst_ready_o(inst_ready),
      .reg_read_valid_i(reg_read_valid),
      .reg_read_data_i(reg_read_data),
      .reg_write_valid_o(reg_write_valid),
      .reg_write_addr_o(reg_write_addr),
      .reg_write_data_o(reg_write_data),
      .cmd_valid_o(frontend_cmd_valid),
      .cmd_data_o(frontend_cmd_data),
      .queue_capacity_i(queue_capacity)
  );

  logic [$clog2(N+1)-1:0] frontend_cmd_valid_count;
  always_comb begin
    frontend_cmd_valid_count = 0;
    for (int i = 0; i < N; i++) begin
      frontend_cmd_valid_count = frontend_cmd_valid_count + frontend_cmd_valid[i];
    end
  end

  RVVCmd [N-1:0] cmd_buffer_data;
  logic [$clog2(N+1)-1:0] cmd_buffer_ready_out;
  logic [$clog2(16+1)-1:0] cmd_buffer_fill_level;
  MultiFifo#(.T(RVVCmd),
             .N(N),
             .MAX_CAPACITY(CMD_BUFFER_MAX_CAPACITY)) cmd_buffer(
      .clk(clk),
      .rstn(rstn),
      .valid_in(frontend_cmd_valid_count),
      .data_in(frontend_cmd_data),
      .fill_level(cmd_buffer_fill_level),
      .data_out(cmd_buffer_data),
      .ready_out(cmd_buffer_ready_out)
  );

  // Back-pressure frontend
  logic [$clog2(16+1)-1:0] cmd_buffer_empty_count =
      (CMD_BUFFER_MAX_CAPACITY - N) - cmd_buffer_fill_level;
  always_comb begin
    if (cmd_buffer_empty_count > 2*N) begin
      queue_capacity = 2*N;
    end else begin
      queue_capacity = cmd_buffer_empty_count;
    end
  end

  // Convert multi-fifo to rvv_backend interface
  logic   [`ISSUE_LANE-1:0] insts_valid_rvs2cq;
  logic   [`ISSUE_LANE-1:0] insts_ready_cq2rvs;  
  always_comb begin
    cmd_buffer_ready_out = 0;
    for (int i = 0; i < `ISSUE_LANE; i++) begin
      cmd_buffer_ready_out = cmd_buffer_ready_out + insts_ready_cq2rvs[i];
      insts_valid_rvs2cq[i] = i < cmd_buffer_fill_level;
    end
  end

  // Back-end ============================================================

  // LSU Tie-offs
  // RVV send LSU uop to RVS
    logic             [`NUM_LSU-1:0]          uop_lsu_valid_rvv2lsu;
    UOP_RVV2LSU_t     [`NUM_LSU-1:0]          uop_lsu_rvv2lsu;
    logic             [`NUM_LSU-1:0]          uop_lsu_ready_lsu2rvv;
  // LSU feedback to RVV
    logic             [`NUM_LSU-1:0]          uop_lsu_valid_lsu2rvv;
    UOP_LSU2RVV_t     [`NUM_LSU-1:0]          uop_lsu_lsu2rvv;
    logic             [`NUM_LSU-1:0]          uop_lsu_ready_rvv2lsu;
  always_comb begin
    uop_lsu_ready_lsu2rvv = 0;
    uop_lsu_valid_lsu2rvv = 0;
    for (int i = 0; i < `NUM_LSU; i++) begin
`ifdef TB_SUPPORT
      uop_lsu_lsu2rvv[i].uop_pc = 0;
      uop_lsu_lsu2rvv[i].uop_index = 0;
`endif
      uop_lsu_lsu2rvv[i].vregfile_write_valid = 0;
      uop_lsu_lsu2rvv[i].vregfile_write_addr = 0;
      uop_lsu_lsu2rvv[i].vregfile_write_data = 0;
      uop_lsu_lsu2rvv[i].lsu_vstore_last = 0;
    end
  end

  // Scalar regfile write-back tie-offs
  // TODO(derekjchow): Properly arbitrate write-back tie-offs by extending
  // interface. For time being, only accept from slot 0.
  logic    [`NUM_RT_UOP-1:0] rt_xrf_valid_rvv2rvs;
  RT2XRF_t [`NUM_RT_UOP-1:0] rt_xrf_rvv2rvs;
  logic    [`NUM_RT_UOP-1:0] rt_xrf_ready_rvs2rvv;
  always_comb begin
    rt_xrf_ready_rvs2rvv[0] = async_rd_ready;
    async_rd_valid = rt_xrf_valid_rvv2rvs[0];
    async_rd_addr = rt_xrf_rvv2rvs[0].rt_index;
    async_rd_data = rt_xrf_rvv2rvs[0].rt_data;
    for (int i = 1; i < `NUM_RT_UOP; i++) begin
      rt_xrf_ready_rvs2rvv[i] = 0;
    end
  end

  // Backpressure
  logic wr_vxsat_ready;
  always_comb begin
    // TODO(derekjchow): Actually accept
    wr_vxsat_ready = 1;
  end

  // CSR Update, unused for now
  logic                            wr_vxsat_valid;
  logic    [`VCSR_VXSAT_WIDTH-1:0] wr_vxsat;

  // Trap handling tie-off
  logic  trap_valid_rvs2rvv;
  TRAP_t trap_rvs2rvv;
  logic  trap_ready_rvv2rvs;
  always_comb begin
    trap_valid_rvs2rvv = 0;
    trap_rvs2rvv.trap_uop_rob_entry = 0;
  end

  rvv_backend backend(
      .clk(clk),
      .rst_n(rstn),
      .insts_valid_rvs2cq(insts_valid_rvs2cq),
      .insts_rvs2cq(cmd_buffer_data),
      .insts_ready_cq2rvs(insts_ready_cq2rvs),

      .uop_lsu_valid_rvv2lsu(uop_lsu_valid_rvv2lsu),
      .uop_lsu_rvv2lsu(uop_lsu_rvv2lsu),
      .uop_lsu_ready_lsu2rvv(uop_lsu_ready_lsu2rvv),
      .uop_lsu_valid_lsu2rvv(uop_lsu_valid_lsu2rvv),
      .uop_lsu_lsu2rvv(uop_lsu_lsu2rvv),
      .uop_lsu_ready_rvv2lsu(uop_lsu_ready_rvv2lsu),

      .rt_xrf_rvv2rvs(rt_xrf_rvv2rvs),
      .rt_xrf_valid_rvv2rvs(rt_xrf_valid_rvv2rvs),
      .rt_xrf_ready_rvs2rvv(rt_xrf_ready_rvs2rvv),
      .wr_vxsat_valid(wr_vxsat_valid),
      .wr_vxsat(wr_vxsat),
      .wr_vxsat_ready(wr_vxsat_ready),
      .trap_valid_rvs2rvv(trap_valid_rvs2rvv),
      .trap_rvs2rvv(trap_rvs2rvv),
      .trap_ready_rvv2rvs(trap_ready_rvv2rvs),
      .vcsr_valid(vcsr_valid),
      .vector_csr(vector_csr),
      .vcsr_ready(vcsr_ready)
  );

endmodule
