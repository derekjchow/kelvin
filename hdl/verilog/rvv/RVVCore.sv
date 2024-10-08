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

module RVVFrontEnd#(parameter N = 4)
(
  input clk,
  input rstn,

  // Instruction input.
  input logic valid_in [N-1:0],
  input RVVInstruction data_in [N-1:0],
  output logic ready_in [N-1:0],

  // Register file input
  input logic reg_read_valid [(2*N)-1:0],
  input [31:0] reg_read_data [(2*N)-1:0],

  // Scalar Regfile writeback for configuration (VSET*VL*) functions.
  output logic reg_write_valid [N-1:0],
  output logic [31:0] reg_write_data [N-1:0],

  // Scalar Regfile writeback for vmv.x.s instructions
  output logic vmvx_write_valid,
  output logic [31:0] vmvx_write_data
);

  logic cmd_valid [N-1:0];
  RVVCmd cmd_data[N-1:0];
  logic [$clog2(2*N + 1)-1:0] clipped_queue_capacity;
  RVVFrontEnd #(.N (N))
  front_end(
      .clk(clk),
      .rstn(rstn),
      .valid_in(valid_in),
      .data_in(data_in),
      .ready_in(ready_in),
      .reg_read_valid(reg_read_valid),
      .reg_read_data(reg_read_data),
      .reg_write_valid(reg_write_valid),
      .reg_write_data(reg_write_data),
      .cmd_valid(cmd_valid),
      .cmd_data(cmd_data),
      .queue_capacity(queue_capacity)
  );

  logic aligned_cmd_valid [N-1:0];
  RVVCmd aligned_cmd_data[N-1:0];
  Aligner#(.T (RVVCmd), .N (N))
  aligner(
      .valid_in(cmd_valid),
      .data_in(cmd_data),
      .valid_out(aligned_cmd_valid),
      .data_out(aligned_cmd_data)
  );

  logic [$clog2(16 + 1)-1:0] queue_capacity;
  clipped_queue_capacity = (queue_capacity > 2*N) ? 2*N : queue_capacity;
  logic [$clog2(N+1)-1:0] cmd_queue_valid;
  RVVCmd [N-1:0] cmd_queue_data;
  logic [$clog2(N+1)-1:0] cmd_queue_ready;
  MultiFifo#(.T (RVVCmd), .N (N), .MAX_CAPACITY (16))
  command_queue(
      .clk(clk),
      .rstn(rstn),
      .valid_in(aligned_cmd_valid),
      .data_in(aligned_cmd_data),
      .ready_in(),
      .capacity(queue_capacity),
      .valid_out(cmd_queue_valid),
      .data_out(cmd_queue_data),
      .ready_out(cmd_queue_ready)
  );

  logic ren[3:0];
  logic [ADDR_WIDTH-1:0] raddr[3:0];
  RVVRegfile(.DATA_WIDTH (128), .NUM_REGS (32), .NUM_READ_PORTS (4) )
  regfile(
      .clk(clk),
      .rstn(rstn),
      // TODO Finish me
  );

  RVVDispatch(.N (N))
  dispatch(
      .clk(clk),
      .rstn(rstn),
      .cmd_valid(command_queue.valid_out),
      .cmd_data(command_queue.data_out),
      .cmd_ready(cmd_queue_ready),
      // TODO Finish me
      .ren(ren),
      .raddr(raddr),
      .vmvx_write_valid(vmvx_write_valid),
      .vmvx_write_data(vmvx_write_data)
  );

  for (genvar i = 0; i < 2; i++) begin
    RVVAlu alu(
        .clk(clk), 
        .rstn(rstn),
        .cmd_valid(command_queue.valid_out),
        .cmd_data(command_queue.data_out));
  end

endmodule