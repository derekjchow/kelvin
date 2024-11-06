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

// A ClockGate module. The underlying implementation varies based on
// preprocessor.
// Default: ASIC implementation
// USE_GENERIC default: Verilator implementation (adapted from OpenTitan)
// USE_GENERIC and FPGA_XILINX: UltraScale Plus specific clockgate.
module ClockGate(
  input         clk_i,
  input         enable,  // '1' passthrough, '0' disable.
  input         te,      // test enable
  output        clk_o
);

`ifndef USE_GENERIC
CKLNQD10BWP16P90LVT u_cg(
  .TE(te),
  .E(enable),
  .CP(clk_i),
  .Q(clk_o)
);
`else

`ifdef FPGA_XILINX
  BUFGCE #(
    .SIM_DEVICE("ULTRASCALE_PLUS")
  ) u_bufgce (
    .I (clk_i),
    .CE(enable | te),
    .O (clk_o)
  );
`else
  logic en_latch /* verilator clock_enable */;
  always_latch begin
    if (!clk_i) begin
      en_latch = enable | te;
    end
  end
  assign clk_o = en_latch & clk_i;
`endif  // FPGA_XILINX

`endif  // USE_GENERIC

endmodule  // ClockGate
