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

// A module for synchronizing Asynchronous external reset to
// an internal synchronous deassert reset
// Clock is disabled while reset is asserted to prevent a race
// between clock and reset.
module RstSync
    (
        // Input clock
        input clk_i,
        // Input active-low async reset
        input rstn_i,
        // Functional clock gate enable. clk_o is enabled when clk_en
        // is 1, and we are out of reset
        // clk_en is assumed to be synchronous to clk_o or clk_i
        input clk_en,
        input te,

        // Output clock
        output clk_o,
        // Output reset active low
        output rstn_o);

  localparam RST_DELAY = 2;
  localparam CLK_DELAY = 2;

  logic [RST_DELAY + CLK_DELAY - 1 : 0] rst_delay_reg;
  always_ff @(posedge clk_i or negedge rstn_i) begin
    if (~rstn_i)
      rst_delay_reg <= '0;
    else
      rst_delay_reg <= {rst_delay_reg[RST_DELAY + CLK_DELAY - 2 : 0], 1'b1};
  end

  assign rstn_o = rst_delay_reg[RST_DELAY - 1];

  logic clk_en_int;
  assign clk_en_int = clk_en & rst_delay_reg[CLK_DELAY + RST_DELAY - 1];

  ClockGate icg(.clk_i(clk_i),
                .enable(clk_en_int),
                .te(te),
                .clk_o(clk_o));

`ifndef SYNTHESIS
  initial begin
    assert (RST_DELAY >= 2);
    assert (CLK_DELAY >= 2);
  end
`endif
endmodule
