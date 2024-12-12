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

// A module that assembles RVVInstructions into INST_t before storing into the
// RVVInstructionQueue. It's also responsible for handling architectural
// configuration state (ie. LMUL, SEW). Inputs to this module maybe unaligned
// (ie [invalid, valid, valid, invalid]) while outputs will always be aligned
// (ie [valid, valid, invalid, invalid]).
// Arguments from the scalar register file (for vx or configuration
// instructions) arrive one cycle after the Instruction is dispatched, so this
// module introduces one cycle of latency before putting the command into the
// queue.
module RvvFrontEnd#(parameter N = 4,
                    parameter CAPACITYBITS=$clog2(2*N + 1))
(
  input clk,
  input rstn,

  input logic [`VSTART_WIDTH-1:0]     vstart_i,
  input logic [`VCSR_VXRM_WIDTH-1:0]  vxrm_i,
  input logic [`VCSR_VXSAT_WIDTH-1:0] vxsat_i,

  // Instruction input.
  input logic [N-1:0] inst_valid_i,
  input RVVInstruction [N-1:0] inst_data_i,
  output logic [N-1:0] inst_ready_o,

  // Register file input
  input logic [(2*N)-1:0] reg_read_valid_i,
  input logic [(2*N)-1:0][31:0] reg_read_data_i,

  // Scalar Regfile writeback for configuration functions.
  output logic [N-1:0] reg_write_valid_o,
  output logic [N-1:0][4:0] reg_write_addr_o,
  output logic [N-1:0][31:0] reg_write_data_o,

  // Command output.
  output logic [N-1:0] cmd_valid_o,
  output INST_t [N-1:0] cmd_data_o,
  input logic [CAPACITYBITS-1:0] queue_capacity_i  // Number of elements in instruction queue
);
  localparam COUNTBITS = $clog2(N + 1);
  typedef logic [COUNTBITS-1:0] count_t;

  // vtype architectural state
  logic vill;
  RVVConfigState config_state_q;

  // Instructions to assemble into commands
  logic [N-1:0] valid_inst_q;
  RVVInstruction inst_q [N-1:0];

  // Backpressure
  count_t num_valid_inst;
  count_t valid_in_psum [N:0];
  always_comb begin
    num_valid_inst = 0;
    valid_in_psum[0] = 0;
    for (int i = 0; i < N; i++) begin
      num_valid_inst += valid_inst_q[i];
      valid_in_psum[i+1] = valid_in_psum[i] + inst_valid_i[i];
    end
  end

  logic [CAPACITYBITS-1:0] valid_inst_sum = queue_capacity_i - num_valid_inst;

  logic inst_accepted [N-1:0];
  always_comb begin
    for (int i = 0; i < N; i++) begin
      inst_accepted[i] = (valid_in_psum[i] < valid_inst_sum) && inst_valid_i[i];
      inst_ready_o[i] = inst_accepted[i];
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (int i = 0; i < N; i++) begin
        valid_inst_q[i] <= 0;
      end;
    end else begin
      for (int i = 0; i < N; i++) begin
        valid_inst_q[i] <= inst_accepted[i];
        inst_q[i] <= inst_data_i[i];
      end
    end
  end

  // Update configuration architectural state
  RVVConfigState inst_config_state [N:0];
  logic is_setvl [N-1:0];
  always_comb begin
    inst_config_state[0] = config_state_q;
    for (int i = 0; i < N; i++) begin
      inst_config_state[i+1] = inst_config_state[i];
      is_setvl[i] = 0;

      if (valid_inst_q[i] &&
          (inst_q[i].opcode == RVV) &&
          (inst_q[i].bits[7:5] == 3'b111)) begin
        if (inst_q[i].bits[24] == 0) begin  // vsetvli
          inst_config_state[i+1].vl = reg_read_data_i[2*i];
          inst_config_state[i+1].lmul = RVVLMUL'(inst_q[i].bits[15:13]);
          inst_config_state[i+1].sew = RVVSEW'(inst_q[i].bits[18:16]);
          inst_config_state[i+1].ta = inst_q[i].bits[19];
          inst_config_state[i+1].ma = inst_q[i].bits[20];
          is_setvl[i] = 1;
        end else if (inst_q[i].bits[24:23] == 2'b11) begin  // vsetivli
          inst_config_state[i+1].vl = inst_q[i].bits[12:8];
          inst_config_state[i+1].lmul = RVVLMUL'(inst_q[i].bits[15:13]);
          inst_config_state[i+1].sew = RVVSEW'(inst_q[i].bits[18:16]);
          inst_config_state[i+1].ta = inst_q[i].bits[19];
          inst_config_state[i+1].ma = inst_q[i].bits[20];
          is_setvl[i] = 1;
        end else if (inst_q[i].bits[24:23] == 2'b10) begin  // vsetvl
          inst_config_state[i+1].vl = reg_read_data_i[2*i];
          inst_config_state[i+1].lmul =
              RVVLMUL'(reg_read_data_i[(2*i) + 1][2:0]);
          inst_config_state[i+1].sew =
              RVVSEW'(reg_read_data_i[(2*i) + 1][5:3]);
          inst_config_state[i+1].ta = reg_read_data_i[(2*i) + 1][6];
          inst_config_state[i+1].ma = reg_read_data_i[(2*i) + 1][7];
          is_setvl[i] = 1;
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // TODO(derekjchow): check if RVV spec specifies arch state on reset.
      config_state_q.ma <= 0;
      config_state_q.ta <= 0;
      config_state_q.sew <= SEW8;
      config_state_q.lmul <= LMUL1;
      config_state_q.vl <= 16;
    end else begin
      // Update config state next cycle
      config_state_q <= inst_config_state[N];
    end
  end

  // Propagate outputs
  logic [N-1:0] unaligned_cmd_valid;
  INST_t [N-1:0] unaligned_cmd_data;
  always_comb begin
    for (int i = 0; i < N; i++) begin
      unaligned_cmd_valid[i] = valid_inst_q[i] && !is_setvl[i];

      // Combine instruction + arch state into command
      unaligned_cmd_data[i].insts_pc = inst_q[i].pc;
      unaligned_cmd_data[i].opcode = inst_q[i].opcode;
      unaligned_cmd_data[i].bits = inst_q[i].bits;
      unaligned_cmd_data[i].vector_csr.vstart = vstart_i;
      unaligned_cmd_data[i].vector_csr.vl = inst_config_state[i].vl;
      unaligned_cmd_data[i].vector_csr.vtype.vill = 0;  // TODO(derekjchow): Set me
      unaligned_cmd_data[i].vector_csr.vtype.vma = inst_config_state[i].ma;
      unaligned_cmd_data[i].vector_csr.vtype.vta = inst_config_state[i].ta;
      unaligned_cmd_data[i].vector_csr.vtype.vsew = inst_config_state[i].sew;
      unaligned_cmd_data[i].vector_csr.vtype.vlmul = inst_config_state[i].lmul;
      unaligned_cmd_data[i].vector_csr.vcsr.vxrm = vxrm_i;
      unaligned_cmd_data[i].vector_csr.vcsr.vxsat = vxsat_i;
      // TODO: Handle rs propagation for loads/stores
      unaligned_cmd_data[i].rs1_data =
          inst_q[i].bits[7] ? reg_read_data_i[2*i] : 0;

      // Write new value of vl into rd for configuration function.
      reg_write_valid_o[i] = is_setvl[i];
      reg_write_addr_o[i] = inst_q[i].bits[4:0];
      reg_write_data_o[i] = inst_config_state[i].vl;
    end
  end

  // Align outputs
  Aligner#(.T(RVVCmd), .N(N)) cmd_aligner(
      .valid_in(unaligned_cmd_valid),
      .data_in(unaligned_cmd_data),
      .valid_out(cmd_valid_o),
      .data_out(cmd_data_o)
  );

  // TODO(derekjchow): Assertions?
endmodule