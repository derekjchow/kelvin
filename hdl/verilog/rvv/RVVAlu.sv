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

// RVV operations
`define RVVAluOperationBits 6
typedef enum logic [`RVVAluOperationBits-1:0] {
  VADD=1,
  VSUB=2,
  // TODO: Add all the operations
} RVVAluOperation;

typedef struct packed {
  RVVAluOperation op;
  logic has_imm;
  // Largest set of immediates is for vsetivli at 16 bits, but the union of
  // all possible bits is 16 bits. These correspnd to the range of [30:15] in
  // the original instruction encoding.
  // See Section 5. Vector Instruction Formats
  logic [15:0] imm;
  // The following can represent vd or rd, etc based on op type.
  logic [4:0] xd;
  logic [4:0] vs1;
  logic [4:0] vs2;
} RVVAluCmd;

module RVVAlu#(parameter DATA_WIDTH = 128)
(
  input clk,
  input rstn,

  // Command input.
  input logic cmd_valid,
  input RVVAluCmd cmd_data,
  output logic cmd_ready,

  // Register file input
  input logic vreg_read0_valid,
  input [DATA_WIDTH-1:0] vreg_read0_data,
  input logic vreg_read1_valid,
  input [DATA_WIDTH-1:0] vreg_read1_data,

  output logic vreg_write_valid,
  output logic [DATA_WIDTH-1:0] vreg_write_data,
);
  // Tie-off, to be completed
  always_comb begin
    cmd_ready = 0;
    vreg_write_valid = 0;
    vreg_write_data = 0;
  end
endmodule