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

// interface RVVFrontEndInteface(input logic clk, rstn);
//   logic valid_in [3:0],
//   RVVInstruction data_in [3:0],
//   logic ready_in [3:0],

//   // Register file input
//   input logic reg_read_valid [(2*N)-1:0],
//   input logic [31:0] reg_read_data [(2*N)-1:0],

//   // Scalar Regfile writeback for configuration functions.
//   output logic reg_write_valid [N-1:0],
//   output logic [31:0] reg_write_data [N-1:0],

//   // Command output.
//   output logic cmd_valid [N-1:0],
//   output RVVCmd cmd_data[N-1:0],
//   input logic [$clog2(2*N + 1)-1:0] queue_capacity


//   clocking driver_cb @(posedge clk);
//     default input negedge output negedge;
//     input capacity, valid_out, data_out, ready_in;
//     output valid_in, data_in, ready_out;
//   endclocking

//   modport DRIVER (clocking driver_cb, input clk, rstn);

// endinterface

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

  function print_cmd(int i, logic valid, RVVCmd cmd);
    $display("cmd_valid[", i, "] ", valid);
    if (valid) begin
      $write("  is_load_store=", cmd.is_load_store, " bits=", cmd.bits);
      $display("  SEW=", cmd.arch_state.sew.name()," vl ", cmd.arch_state.vl);
    end
  endfunction

  task automatic run_test;
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
    #5

    $display("Done reset");

    for (int i = 0; i < N; i++) begin
      valid_in[i] = 0;
      reg_read_valid[i] = 0;
      reg_read_data[i] = 0;
    end

    // Set instruction 0
    valid_in[0] = 1;
    data_in[0].is_load_store = 0;
    data_in[0].bits = 'b1100110000001000011100000;
    // Set instruction 1
    valid_in[1] = 1;
    data_in[1].is_load_store = 0;
    data_in[1].bits = 'b0101111000000000001101000;
    // Set instruction 2
    valid_in[2] = 1;
    data_in[2].is_load_store = 0;
    data_in[2].bits = 'b0101111000000000101101001;
    // Set instruction 3
    valid_in[3] = 1;
    data_in[3].is_load_store = 0;
    data_in[3].bits = 'b0101001000001000101001010;

    // Debug what gets accepted
    #5
    $display("ready_in[0] ", ready_in[0]);
    $display("ready_in[1] ", ready_in[1]);
    $display("ready_in[2] ", ready_in[2]);
    $display("ready_in[3] ", ready_in[3]);

    $display("Moving posedge");
    clk = 1;
    #5
    clk = 0;
    #5

    valid_in[0] = 0;

    
    for (int i = 0; i < N; i++) begin
      print_cmd(i, cmd_valid[i], cmd_data[i]);
      if (reg_write_valid[i]) begin
        $display("Writing ", reg_write_data[i]);
      end
    end


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

endmodule