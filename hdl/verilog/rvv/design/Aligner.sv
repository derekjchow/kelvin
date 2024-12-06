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

// A module that moves valid inputs to the front of the output.
// Example:
// valid_in = [0, 1, 0, 1], data_in = [A, B, C, D]
// valid_out = [1, 1, 0, 0], data_out = [B, D, X, X]
module Aligner#(type T=logic [7:0], parameter N = 8)
(
  // Command input.
  input logic [N-1:0] valid_in,
  input T [N-1:0] data_in,

  // Command output.
  output logic [N-1:0] valid_out,
  output T [N-1:0] data_out
);
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
  localparam COUNTBITS = $clog2(N);
  typedef logic [COUNTBITS-1:0] count_t;

  // Build count
  count_t valid_count [N-1:0];
  always_comb begin
    valid_count[0] = 0;
    for (int i = 0; i < N-1; i++) begin
        valid_count[i+1] = valid_count[i] + valid_in[i];
    end
  end

  logic [N-1:0][N-1:0] output_valid_map;
  count_t valid_idx [N-1:0];
  always_comb begin
    
    for (int o = 0; o < N; o++) begin
      valid_idx[o] = 0;
      for (int i = 0; i < N; i++) begin
        output_valid_map[o][i] = (valid_count[i] == o) && valid_in[i];
        valid_idx[o] = valid_idx[o] | (output_valid_map[o][i] ? i : 0);
      end

      // Assign outputs
      valid_out[o] = |output_valid_map[o];
      data_out[o] = data_in[valid_idx[o]];
    end
  end
/* verilator lint_on WIDTHTRUNC */
/* verilator lint_on WIDTHEXPAND */

endmodule
