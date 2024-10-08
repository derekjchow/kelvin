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

module RVVRegfile#(parameter int DATA_WIDTH = 128,
                   parameter int NUM_REGS = 32,
                   parameter int NUM_READ_PORTS = 2,
                   parameter int NUM_WRITE_PORTS = 2,
                   parameter int ADDR_WIDTH = $clog2(NUM_REGS))
(
  input clk,
  input rstn,

  input logic [NUM_READ_PORTS-1:0]                  ren,
  input logic [NUM_READ_PORTS-1:0][ADDR_WIDTH-1:0]  raddr,
  output logic [NUM_READ_PORTS-1:0]                 rvalid,
  output logic [NUM_READ_PORTS-1:0][DATA_WIDTH-1:0] rdata,

  input logic [NUM_WRITE_PORTS-1:0]                 wen,
  input logic [NUM_WRITE_PORTS-1:0][DATA_WIDTH-1:0] wdata,
  input logic [NUM_WRITE_PORTS-1:0][ADDR_WIDTH-1:0] waddr
);
  always_comb begin
    for (int i = 0; i < NUM_READ_PORTS; i++) begin
      rvalid[i] = 0;
      rdata[i] = 0;
    end
  end
endmodule