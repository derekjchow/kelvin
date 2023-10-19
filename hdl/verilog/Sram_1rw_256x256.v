// Copyright 2023 Google LLC
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

module Sram_1rw_256x256(
  input          clock,
  input          valid,
  input          write,
  input  [7:0]   addr,
  input  [255:0] wdata,
  output [255:0] rdata,
  input          volt_sel
);

  reg [255:0] mem [0:255];
  reg [7:0] raddr;

  assign rdata = mem[raddr];

  always @(posedge clock) begin
    if (valid & write) begin
      mem[addr] <= wdata;
    end
    if (valid & ~write) begin
      raddr <= addr;
    end
  end
endmodule
