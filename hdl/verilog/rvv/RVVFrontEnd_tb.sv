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

module RVVFrontEnd_tb();
  localparam N = 4;

  logic clk, rstn;

  logic valid_in[N-1:0];
  RVVInstruction data_in[N-1:0];
  logic ready_in [N-1:0];

  logic reg_read_valid[(2*N)-1:0];
  logic [31:0] reg_read_data[(2*N)-1:0];

  logic reg_write_valid [N-1:0];
  logic [31:0] reg_write_data [N-1:0];

  logic cmd_valid[N-1:0];
  RVVCmd cmd_data[N-1:0];
  logic [$clog2(2*N + 1)-1:0] queue_capacity;

  RVVFrontEnd #(.N (N))
  dut(
      .clk,
      .rstn,
      .valid_in,
      .data_in,
      .ready_in,
      .reg_read_valid,
      .reg_read_data,
      .reg_write_valid,
      .reg_write_data,
      .cmd_valid,
      .cmd_data,
      .queue_capacity
  );

  task automatic run_test;
    $display("TODO()");

    // No back pressure for this test.
    queue_capacity = 8;

    // Reset
    rstn = 0;
    clk = 0;
    #5
    clk = 1;
    #5
    clk = 0;
    rstn = 1;

    for (int i = 0; i < N; i++) begin
      valid_in[i] = 0;
      reg_read_valid[i] = 0;
      reg_read_data[i] = 0;
    end
    valid_in[0] = 1;
    data_in[0].op = VADD;
    data_in[0].has_imm = 0;
    data_in[0].imm = 0;
    data_in[0].xd = 1;
    data_in[0].vs1 = 2;
    data_in[0].vs2 = 3;

    clk = 1;
    #5
    clk = 0;
    #5

    valid_in[0] = 0;

    

    $display("cmd_valid ", cmd_valid[0]);
    $display("cmd_data op ", cmd_data[0].op);
    $display("cmd_data has_imm ", cmd_data[0].has_imm);
    $display("cmd_data imm ", cmd_data[0].imm);
    $display("cmd_data xd ", cmd_data[0].xd);
    $display("cmd_data vs1 ", cmd_data[0].vs1);
    $display("cmd_data vs2 ", cmd_data[0].vs2);

    // Put in one add to do something

    $finish;
  endtask

  initial
    begin: start
      $display("*** RVVFrontEnd_tb test begin ***");
      $display("Testing N=", N);
      run_test;
    end

  final
    begin
      $display("*** Test finished ***");
    end

//   // Clocking block for applying/sampling stimulus
//   clocking cb @(posedge clk);
//     default input negedge output negedge;
//     input   inReady, cmdValid, cmdData;
//     output  inValid, inData, regReadValid, regReadData, queueCapacity;
//   endclocking // ckb

//   // TODO(derekjchow): Start hacking on me
//   initial
//     begin: inital_all_signals
//       $display("*** RVVFrontEnd_tb test begin ***");
//       for (int i = 0; i < N; i++) begin
//         valid_in[i] <= '0;
//       end
//       //regReadValid = 0;
//       queue_capacity = 4;
//     end

//   final
//     begin
//       $display("*** Test finished ***");
//     end



endmodule