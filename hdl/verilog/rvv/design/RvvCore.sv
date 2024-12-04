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

module RvvCore#(parameter N = 4,
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
  input logic async_rd_ready
);

  // Tie-offs
  assign async_rd_valid = 0;
  assign async_rd_addr = 0;
  assign async_rd_data = 0;

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

  // Backend
	logic  insts_valid_rvs2cq[`NUM_DP_UOP-1:0];
	INST_t insts_rvs2cq[`NUM_DP_UOP-1:0];
  logic  insts_ready_cq2rvs[`NUM_DP_UOP-1:0];
  logic [$clog2(`NUM_DP_UOP+1)-1:0] insts_ready_n_cq2rvs;
  always_comb begin
    for (int i = 0; i < `NUM_DP_UOP; i++) begin
      insts_valid_rvs2cq[i] = (i < cmd_buffer_fill_level);
      insts_rvs2cq[i] = cmd_buffer_data[i];
    end

    // Back-pressure cmd_buffer_ready_out
    insts_ready_n_cq2rvs = 0;
    for (int i = 0; i < `NUM_DP_UOP; i++) begin
      insts_ready_n_cq2rvs += insts_ready_cq2rvs[i];
    end
    if (insts_ready_n_cq2rvs > cmd_buffer_fill_level) begin
      cmd_buffer_ready_out = cmd_buffer_fill_level;
    end else begin
      cmd_buffer_ready_out = insts_ready_n_cq2rvs;
    end
  end

	logic								uop_valid[`NUM_DP_UOP-1:0];
	UOP_LSU_RVV2RVS_t   uop_lsu_rvv2rvs[`NUM_DP_UOP-1:0];
	logic								uop_ready[`NUM_DP_UOP-1:0];
  always_comb begin
    for (int i = 0; i < `NUM_DP_UOP; i++) begin
      uop_ready[i] = 0;
    end
  end

	logic								uop_done_valid[`NUM_DP_UOP-1:0];
	UOP_LSU_RVV2RVS_t					uop_done_rvs2rvv[`NUM_DP_UOP-1:0];
	logic								uop_done_ready[`NUM_DP_UOP-1:0];
  always_comb begin
    for (int i = 0; i < `NUM_DP_UOP; i++) begin
      uop_done_valid[i] = 0;
      uop_done_rvs2rvv[i].uop_pc = 0;
      uop_done_rvs2rvv[i].uop_id = 0;
      uop_done_rvs2rvv[i].vidx_valid = 0;
      uop_done_rvs2rvv[i].vidx_addr = 0;
      uop_done_rvs2rvv[i].vidx_data = 0;
      uop_done_rvs2rvv[i].vs2_type = 0;
      uop_done_rvs2rvv[i].vregfile_read_valid = 0;
      uop_done_rvs2rvv[i].vregfile_read_addr = 0;
      uop_done_rvs2rvv[i].vregfile_read_data = 0;
      uop_done_rvs2rvv[i].vs3_type = 0;
    end
  end

  // write back to XRF. TODO(derekjchow): Make this scalar?
  WB_XRF_t  wb_xrf_wb2rvs[`NUM_WB_UOP-1:0];
  logic     wb_xrf_valid_wb2rvs[`NUM_WB_UOP-1:0];
	logic     wb_xrf_ready_wb2rvs[`NUM_WB_UOP-1:0];
  always_comb begin
    for (int i = 0; i < `NUM_WB_UOP; i++) begin
      wb_xrf_ready_wb2rvs[i] = 0;
    end
  end

  logic         trap_rvs2rvv;
  logic         ready_rvv2rvs;
	logic         vcsr_valid;
  VECTOR_CSR_t  vector_csr;
  always_comb begin
    trap_rvs2rvv = 0;
  end

  RvvBackend backend(
    .clk(clk),
    .rstn(rstn),
	  .insts_valid_rvs2cq(insts_valid_rvs2cq),
	  .insts_rvs2cq(insts_rvs2cq),
	  .insts_ready_cq2rvs(insts_ready_cq2rvs),
	  .uop_valid(uop_valid),
	  .uop_lsu_rvv2rvs(uop_lsu_rvv2rvs),
	  .uop_ready(uop_ready),
	  .uop_done_valid(uop_done_valid),
	  .uop_done_rvs2rvv(uop_done_rvs2rvv),
	  .uop_done_ready(uop_done_ready),
	  .wb_xrf_wb2rvs(wb_xrf_wb2rvs),
	  .wb_xrf_valid_wb2rvs(wb_xrf_valid_wb2rvs),
	  .wb_xrf_ready_wb2rvs(wb_xrf_ready_wb2rvs),
	  .trap_rvs2rvv(trap_rvs2rvv),
	  .ready_rvv2rvs(ready_rvv2rvs),
	  .vcsr_valid(vcsr_valid),
	  .vector_csr(vector_csr)
  );

  // TODO(derekjchow): Only dequeue two instructions at a time
  // TODO(derekjchow): Connect into backend

  // TODO(derekjchow): Finish me
  always @(posedge clk) begin
    if (frontend_cmd_valid_count > 0) begin
      $fwrite(32'h80000002, "Enqueuing ", frontend_cmd_valid_count,
              " RVV instructions\n");
    end
  end

endmodule