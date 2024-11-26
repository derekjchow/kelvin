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

`ifndef ALIGNER_TB_N
`define ALIGNER_TB_N 4
`endif

module Aligner_tb();
  localparam N = `ALIGNER_TB_N;
  localparam ITERATIONS = 100;
  typedef logic[31:0] MyInt;

  logic valid_in[N-1:0];
  MyInt [N-1:0] data_in;

  logic valid_out[N-1:0];
  MyInt [N-1:0] data_out;

  Aligner#(.T (logic [31:0]), .N (N))
  dut(
    valid_in,
    data_in,
    valid_out,
    data_out
  );

  task automatic run_random_test;
    automatic logic [3:0] outIdx = 0;
    for (int it = 0; it < ITERATIONS; it++) begin
      $display("*** RVVFrontEnd_tb iteration ", it, " ***");
      for (int i = 0; i < N; i++) begin
        valid_in[i] = $urandom_range(0, 1);
        data_in[i] = $urandom;
      end

      #1

      for (int o = 0; o < N; o++) begin
        if (valid_out[o] != (o < $countones(valid_in))) begin
          $error("valid_out o=", 0, " was set incorrectly. valid_in=",
                  valid_in);
        end
      end

      outIdx = 0;
      for (int i = 0; i < N; i++) begin
        if (valid_in[i] == 1) begin
          if (data_in[i] != data_out[outIdx]) begin
            $error("Bad data_out, expected ", data_in[i], " got ",
                    data_out[outIdx]);
          end
          outIdx = outIdx + 1;
        end
      end
    end

    $finish;
  endtask

  initial
    begin: initialize_all_signals
      $display("*** RVVFrontEnd_tb test begin ***");
      $display("Testing N=", N);
      run_random_test;
    end

  final
    begin
      $display("*** Test finished ***");
    end

endmodule
