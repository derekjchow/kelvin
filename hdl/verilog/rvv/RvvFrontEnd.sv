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

// A module that assembles RVVInstructions into RVVCmds before storing into the
// RVVInstructionQueue. It's also responsible for handling architectural
// configuration state (ie. LMUL, SEW).
// Arguments from the scalar register file (for vx or configuration
// instructions) arrive one cycle after the Instruction is dispatched, so this
// module introduces one cycle of latency before putting the command into the
// queue.
module RvvFrontEnd#(parameter N = 4)
(
  input clk,
  input rstn,

  // Instruction input.
  input logic valid_in [N-1:0],
  input RVVInstruction data_in [N-1:0],
  output logic ready_in [N-1:0],

  // Register file input
  input logic reg_read_valid [(2*N)-1:0],
  input logic [31:0] reg_read_data [(2*N)-1:0],

  // Scalar Regfile writeback for configuration functions.
  output logic reg_write_valid [N-1:0],
  output logic [31:0] reg_write_addr [N-1:0],
  output logic [31:0] reg_write_data [N-1:0],

  // Command output.
  output logic cmd_valid [N-1:0],
  output RVVCmd cmd_data[N-1:0],
  input logic [$clog2(2*N + 1)-1:0] queue_capacity  // Number of elements in instruction queue
);
  localparam COUNTBITS = $clog2(N + 1);
  typedef logic [COUNTBITS-1:0] count_t;

  // vtype architectural state
  logic vill;
  RVVConfigState config_state;

  // Instructions to assemble into commands
  logic [N-1:0] valid_inst;
  RVVInstruction inst [N-1:0];

  // Backpressure
  count_t valid_inst_psum [N:0];
  count_t valid_in_psum [N:0];
  always_comb begin
    valid_inst_psum[0] = 0;
    valid_in_psum[0] = 0;
    for (int i = 0; i < N; i++) begin
      valid_inst_psum[i+1] =
          valid_inst_psum[i] + {{(COUNTBITS-1){1'b0}}, valid_inst[i]};
      valid_in_psum[i+1] =
          valid_in_psum[i] + {{(COUNTBITS-1){1'b0}}, valid_in[i]};
    end
  end

  wire [$clog2(2*N + 1)-1:0] valid_inst_sum = (
      queue_capacity - valid_inst_psum[N-1]);

  logic valids [N-1:0];
  always_comb begin
    for (int i = 0; i < N; i++) begin
      valids[i] = (valid_in_psum[i] < valid_inst_sum) && valid_in[i];
      ready_in[i] = valids[i];
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (int i = 0; i < N; i++) begin
        valid_inst[i] <= 0;
      end;
    end else begin
      for (int i = 0; i < N; i++) begin
        valid_inst[i] <= valids[i];
        inst[i] <= data_in[i];
      end
    end
  end

  // Update configuration architectural state
  RVVConfigState inst_config_state [N:0];
  logic is_setvl [N-1:0];
  always_comb begin
    inst_config_state[0] = config_state;
    for (int i = 0; i < N; i++) begin
      inst_config_state[i+1] = inst_config_state[i];
      is_setvl[i] = 0;

      if (valid_inst[i] &&
          (inst[i].opcode == RVV) &&
          (inst[i].bits[7:5] == 3'b111)) begin
        if (inst[i].bits[24] == 0) begin  // vsetvli
          inst_config_state[i+1].vl = reg_read_data[2*i];
          inst_config_state[i+1].lmul = RVVLMUL'(inst[i].bits[15:13]);
          inst_config_state[i+1].sew = RVVSEW'(inst[i].bits[18:16]);
          inst_config_state[i+1].ta = inst[i].bits[19];
          inst_config_state[i+1].ma = inst[i].bits[20];
          is_setvl[i] = 1;
        end else if (inst[i].bits[24:23] == 2'b11) begin  // vsetivli
          inst_config_state[i+1].vl = inst[i].bits[12:8];
          inst_config_state[i+1].lmul = RVVLMUL'(inst[i].bits[15:13]);
          inst_config_state[i+1].sew = RVVSEW'(inst[i].bits[18:16]);
          inst_config_state[i+1].ta = inst[i].bits[19];
          inst_config_state[i+1].ma = inst[i].bits[20];
          is_setvl[i] = 1;
        end else if (inst[i].bits[24:23] == 2'b10) begin  // vsetvl
          inst_config_state[i+1].vl = reg_read_data[2*i];
          inst_config_state[i+1].lmul = RVVLMUL'(reg_read_data[(2*i) + 1][0:2]);
          inst_config_state[i+1].sew = RVVSEW'(reg_read_data[(2*i) + 1][5:3]);
          inst_config_state[i+1].ta = reg_read_data[(2*i) + 1][6];
          inst_config_state[i+1].ma = reg_read_data[(2*i) + 1][7];
          is_setvl[i] = 1;
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // TODO(derekjchow): check if RVV spec specifies arch state on reset.
      config_state.ma <= 0;
      config_state.ta <= 0;
      config_state.sew <= SEW8;
      config_state.lmul <= LMUL1;
      config_state.vl <= 16;
    end else begin
      // Update config state next cycle
      config_state <= inst_config_state[N];
    end
  end

  // Propagate outputs
  always_comb begin
    for (int i = 0; i < N; i++) begin
      cmd_valid[i] = valid_inst[i] && !is_setvl[i];

      // Combine instruction + arch state into command
      cmd_data[i].opcode = inst[i].opcode;
      cmd_data[i].bits = inst[i].bits;
      // TODO: Handle rs propagation for loads/stores
      cmd_data[i].rs1 = inst[i].bits[7] ? reg_read_data[2*i] : 0;
      cmd_data[i].arch_state = inst_config_state[i];

      // Write new value of vl into rd for configuration function.
      reg_write_valid[i] = is_setvl[i];
      reg_write_addr[i] = 0;  // TODO(derekjchow): set address correctly
      reg_write_data[i] = inst_config_state[i].vl;
    end
  end

  // TODO(derekjchow): Assertions?
endmodule