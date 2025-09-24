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

module Sram_512x128(
  input          clock,
  input          enable,
  input          write,
  input  [8:0]   addr,
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
    TS1N12FFCLLSBLVTD512X128M4SWBSHO u_12ffcp_sram
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
      .A(addr),             // Address                               (input [8:0] DM)
      .D(wdata),            // Data                                  (input [127:0] DM)
      .BWEB(nwmask),        // Bit Write Enable Bar (active low BW)  (input [127:0])


      // BIST Mode Input
      .CEBM(1'b0),          // Chip Enable Bar for BIST Mode
      .WEBM(1'b0),          // Write Enable Bar for BIST Mode
      .AM(9'b0),            // Address for BIST Mode               (input [8:0])
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
      .WTSEL(2'b0)          // Write Test Select               (input [1:0])
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

    sasdulssd8LOW1p512x128m4b1w0c0p0d0l0rm3sdrw01 u_gf22_sram (
      .Q(rdata),
      .ADR(addr),
      .D(wdata),
      .WEM(nwmask),
      .WE(write),
      .ME(enable),
      .CLK(clock),
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
  reg [127:0] mem [0:511];
  reg [8:0] raddr;

  assign rdata = mem[raddr];

`ifndef SYNTHESIS
  task randomMemoryAll;
  for (int i = 0; i < 128; i++) begin
    for (int j = 0; j < 512; j++) begin
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
`endif

endmodule
