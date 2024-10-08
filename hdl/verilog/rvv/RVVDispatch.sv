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

module RVVDispatch#(parameter N = 4)
(
  input clk,
  input rstn,

  // Command input.
  input logic cmd_valid [N-1:0],
  input RVVCmd cmd_data[N-1:0],
  output logic cmd_ready [N-1:0],

  // ALU interface.
  output logic alu_cmd_valid[1:0],
  output RVVAluCmd alu_cmd_data[1:0],
  input logic alu_cmd_ready[1:0],

  // Register file interface.
  output logic ren[3:0],
  output logic [ADDR_WIDTH-1:0] raddr[3:0],

  // Scalar Regfile writeback for vmv.x.s instructions
  output logic vmvx_write_valid,
  output logic [31:0] vmvx_write_data
);
  // Tie-off, to be completed
  always_comb begin
    cmd_ready = 0;
    alu_cmd_ready = 0;
    vmvx_write_valid = 0;
    vmvx_write_data = 0;
  end
endmodule