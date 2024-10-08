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
  input logic [31:0] reg_read_data [(2*N)-1:0],

  // Scalar Regfile writeback for configuration functions.
  output logic reg_write_valid [N-1:0],
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

  wire [$clog2(2*N + 1)-1:0] valid_inst_sum = queue_capacity - valid_inst_psum[N-1];

  logic valids [N-1:0];
  always_comb begin
    for (int i = 0; i < N; i++) begin
      valids[i] = (valid_in_psum[i] < valid_inst_sum) && valid_in[i];
      ready_in[i] = valids[i];
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    for (int i = 0; i < N; i++) begin
      if (!rstn) begin
        valid_inst[i] <= 0;
        inst[i].op <= VADD;
        // TODO(derekjchow): check if RVV spec specifies arch state on reset.
        config_state.ma <= 0;
        config_state.ta <= 0;
        config_state.sew <= SEW8;
        config_state.lmul <= LMUL1;
        config_state.vl <= 128;
      end else begin
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
      if (valid_inst[i] && (inst[i].op == VSETVL)) begin
        inst_config_state[i].vl = reg_read_data[(2*i)][7:0];
        inst_config_state[i].lmul = RVVLMUL'(reg_read_data[(2*i) + 1][2:0]);
        inst_config_state[i].sew = RVVSEW'(reg_read_data[(2*i) + 1][5:3]);
        inst_config_state[i].ta = reg_read_data[(2*i) + 1][6];
        inst_config_state[i].ma = reg_read_data[(2*i) + 1][7];
        is_setvl[i] = 1;
        // TODO(derekjchow): Check for vill, illegal vl or reserved bits set?
      end else if (valid_inst[i] && (inst[i].op == VSETIVLI)) begin
        inst_config_state[i].vl = inst[i][4:0];
        inst_config_state[i].lmul = RVVLMUL'(inst[i][7:5]);
        inst_config_state[i].sew = RVVSEW'(inst[i][10:8]);
        inst_config_state[i].ta = inst[i][11];
        inst_config_state[i].ma = inst[i][12];
        // TODO(derekjchow): Check for vill, illegal vl or reserved bits set?
        is_setvl[i] = 1;
      end else if (valid_inst[i] && (inst[i].op == VSETVLI)) begin
        inst_config_state[i].vl = reg_read_data[(2*i)][7:0];
        inst_config_state[i].lmul = RVVLMUL'(inst[i][7:5]);
        inst_config_state[i].sew = RVVSEW'(inst[i][10:8]);
        inst_config_state[i].ta = inst[i][11];
        inst_config_state[i].ma = inst[i][12];
        // TODO(derekjchow): Check for vill, illegal vl or reserved bits set?
        is_setvl[i] = 1;
      end else begin
        is_setvl[i] = 0;
        inst_config_state[i+i] = inst_config_state[i];
      end
    end
  end

  // Propagate outputs
  always_comb begin
    for (int i = 0; i < N; i++) begin


      cmd_valid[i] = valid_inst[i] && !is_setvl[i];
      cmd_data[i].op = inst[i].op;
      cmd_data[i].has_imm = inst[i].has_imm;
      cmd_data[i].imm = inst[i].has_imm ? inst[i].imm :
          (reg_read_valid[i] ? reg_read_data[2*i] : 0);
      cmd_data[i].xd = inst[i].xd;
      cmd_data[i].vs1 = inst[i].vs1;
      cmd_data[i].vs2 = inst[i].vs2;
      cmd_data[i].arch_state = inst_config_state[i];

      // Write new value of vl into rd for configuration function.
      reg_write_valid[i] = is_setvl[i];
      reg_write_data[i] = inst_config_state[i].vl;

    end
  end

  // TODO(derekjchow): Assertions?
endmodule