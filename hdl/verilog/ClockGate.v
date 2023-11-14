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

module ClockGate(
  input         clk_i,
  input         enable,  // '1' passthrough, '0' disable.
  output        clk_o
);
// Note: Bypass clock gate for now. It causes FPGA build failures and
// simulation issues
assign clk_o = clk_i;
/*
reg clk_en;
`ifdef FPGA
    assign clk_o = clk_i;
`else
    // Capture 'enable' during low phase of the clock.
    always @(clk_i or enable)
    begin
      if (~clk_i)
      clk_en = enable;
    end

  assign clk_o = clk_i & clk_en;
`endif
*/
endmodule  // ClockGate
