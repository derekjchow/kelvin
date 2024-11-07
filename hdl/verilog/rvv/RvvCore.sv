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

module RvvCore#(parameter N = 4)
(
  input clk,
  input rstn,

  // Instruction input.
  input logic inst_valid [N-1:0],
  input RVVInstruction inst_data [N-1:0],
  output logic inst_ready [N-1:0],

  // Register file input
  input logic reg_read_valid [(2*N)-1:0],
  input logic [31:0] reg_read_data [(2*N)-1:0],

  // Scalar Regfile writeback for configuration functions.
  output logic reg_write_valid [N-1:0],
  output logic [4:0] reg_write_addr [N-1:0],
  output logic [31:0] reg_write_data [N-1:0]
);

  always_comb begin
    for (int i = 0; i < N; i++) begin
      inst_ready[i] = 1;
      reg_write_valid[i] = 0;
      reg_write_addr[i] = 0;
      reg_write_data[i] = 0;
    end
  end

  always_comb begin
    for (int i = 0; i < N; i++) begin
      if (inst_valid[i]) begin
        $error("Got RVV instruction!\n");
      end
    end
  end

  // TODO(derekjchow): Print some data here.

endmodule