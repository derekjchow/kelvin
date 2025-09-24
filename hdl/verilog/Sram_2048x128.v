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

module Sram_2048x128(
  input          clock,
  input          enable,
  input          write,
  input  [10:0]   addr,
  input  [127:0] wdata,
  input  [15:0] wmask,
  output [127:0] rdata
);

///////////////////////////
///// SRAM Selection //////
///////////////////////////
`ifdef USE_TSMC12FFC
///////////////////////////
///// TSMC12FFC SRAM //////
///////////////////////////
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
`elsif USE_GF22
///////////////////////////
//////// GF22 SRAM ////////
///////////////////////////
    wire [127:0] nwmask;
    genvar i;
    generate
      for (i = 0; i < 16; i++) begin
        assign nwmask[8*i +: 8] = {8{wmask[i]}};
      end
    endgenerate

    sasdulssd8LOW1p2048x128m4b2w0c0p0d0l0rm3sdrw01 u_gf22_sram (
      // Data Output
      .Q(rdata),            // Data Output [127:0]
      // Data Input
      .ADR(addr),           // Address [10:0]
      .D(wdata),            // Data Input [127:0]
      .WEM(nwmask),         // Write Enable Mask [127:0] (active high)
      .WE(write),           // Write Enable (active high)
      .ME(enable),          // Memory Enable (active high)
      .CLK(clock),          // Clock
      // Test and Power-saving pins - tied off
      .TEST1(1'b0),
      .TEST_RNM(1'b0),
      .RME(1'b0),
      .RM(4'b0),
      .WA(2'b0),
      .WPULSE(3'b0),
      .LS(1'b0),
      .BC0(1'b0),
      .BC1(1'b0),
      .BC2(1'b0)
    );
`else
///////////////////////////
////// Generic SRAM ///////
///////////////////////////
  reg [127:0] mem [0:2047];
  reg [10:0] raddr;

  assign rdata = mem[raddr];

`ifndef SYNTHESIS
  task randomMemoryAll;
  for (int i = 0; i < 128; i++) begin
    for (int j = 0; j < 2048; j++) begin
      mem[i][j] = $random;
    end
  end
  endtask

  initial begin
    randomMemoryAll;
  end
`endif

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
