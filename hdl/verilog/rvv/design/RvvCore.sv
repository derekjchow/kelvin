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
      .valid_in(inst_valid),
      .data_in(inst_data),
      .ready_in(inst_ready),
      .reg_read_valid(reg_read_valid),
      .reg_read_data(reg_read_data),
      .reg_write_valid(reg_write_valid),
      .reg_write_addr(reg_write_addr),
      .reg_write_data(reg_write_data),
      .cmd_valid(frontend_cmd_valid),
      .cmd_data(frontend_cmd_data),
      .queue_capacity(queue_capacity)
  );

  logic [$clog2(N+1)-1:0] frontend_cmd_valid_count;
  always_comb begin
    frontend_cmd_valid_count = 0;
    for (int i = 0; i < N; i++) begin
      frontend_cmd_valid_count = frontend_cmd_valid_count + frontend_cmd_valid[i];
    end
  end

  // logic [N-1:0] cmd_buffer_valid;
  RVVCmd [N-1:0] cmd_buffer_data;
  // TODO: Currently instructions are left in the queue (never dequeue).
  //       Dequeue eventually.
  logic [$clog2(N+1)-1:0] cmd_buffer_ready_out = 0;
  logic [$clog2(16+1)-1:0] cmd_buffer_fill_level;
  // logic [$clog2(N+1)-1:0] cmd_buffer_ready_in;
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

  // TODO(derekjchow): Only dequeue two instructions at a time
  // TODO(derekjchow): Connect into backend

  // TODO(derekjchow): Finish me
  always @(posedge clk) begin

    if (inst_valid != 0 || frontend_cmd_valid != 0) begin
      $fwrite(32'h80000002, "Tick\n");
    end
    if (inst_valid != 0) begin
      $fwrite(32'h80000002, "inst_valid=0b%b", inst_valid, "\n");
      $fwrite(32'h80000002, "queue_capacity=", queue_capacity, "\n");
    end
    if (cmd_buffer_fill_level > 0) begin
      $fwrite(32'h80000002, "cmd_buffer_fill_level=",
              cmd_buffer_fill_level, "\n");
      $error("Got RVV command!\n");
    end
  end

endmodule