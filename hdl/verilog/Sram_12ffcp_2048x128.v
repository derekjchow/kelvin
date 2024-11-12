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

module Sram_12ffcp_2048x128(
  input          clock,
  input          enable,
  input          write,
  input  [10:0]   addr,
  input  [127:0] wdata,
  input  [15:0] wmask,
  output [127:0] rdata
);

`ifndef USE_GENERIC
    wire [127:0] nwmask;
    genvar i;
    generate
      for (i = 0; i < 16; i++) begin
        assign nwmask[8*i +: 8] = {8{~wmask[i]}};
      end
    endgenerate
    TS1N12FFCLLMBLVTD2048X128M4SWBSHO u_12ffcp_sram
    (
      // Mode Control
      .BIST(1'b0),          // Built-In Self-Test (active high)
      // Normal Mode Input
      .SLP(1'b0),           // Sleep
      .DSLP(1'b0),          // Deep Sleep
      .SD(1'b0),            // Shut Down
      .CLK(clock),          // Clock
      .CEB(~enable),        // Chip Enable Bar (active low en)
      .WEB(~write),         // Write Enable Bar (active low WE)
      .A(addr),             // Address                               (input [10:0] DM)
      .D(wdata),            // Data                                  (input [127:0] DM)
      .BWEB(nwmask),        // Bit Write Enable Bar (active low BW)  (input [127:0])


      // BIST Mode Input
      .CEBM(1'b0),          // Chip Enable Bar for BIST Mode
      .WEBM(1'b0),          // Write Enable Bar for BIST Mode
      .AM(11'b0),           // Address for BIST Mode               (input [10:0])
      .DM(128'b0),          // Data Input for BIST Mode            (input [127:0] DM)
      .BWEBM({128{1'b1}}),  // Bit Write Enable Bar for BIST Mode  (input [127:0] DM)

      // Data Output
      .Q(rdata),            // Data Output                          (output [127:0])
      .PUDELAY(),           // Power-Up Delay - Connect for tuning timing in late stage design

      // Test Mode
`ifndef SIMULATION
      .RTSEL(2'b0),         // Read Test Select                (input [1:0])
      .WTSEL(2'b0)          // Write Test Select               (input [1:0])
`else
      .RTSEL(2'b1),         // Read Test Select                (input [1:0])
      .WTSEL(2'b1)          // Write Test Select               (input [1:0])
`endif
     );

`else
  reg [127:0] mem [0:2047];
  reg [10:0] raddr;

  assign rdata = mem[raddr];

  always @(posedge clock) begin
    for (int i = 0; i < 16; i++) begin
      if (enable & write & wmask[i]) begin
        mem[addr][i*8 +: 8] <= wdata[8*i +: 8];
      end
    end

    if (enable & ~write) begin
      raddr <= addr;
    end
  end
`endif // FFCP12_SRAM

endmodule
