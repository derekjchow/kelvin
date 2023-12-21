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

`ifdef GF22_ML_CACHE
  logic [1:0] ma_sawl;
  logic [1:0] ma_wras;
  logic       ma_wrasd;

  always_comb begin
    if(volt_sel)begin
     ma_sawl = 2'b11;
     ma_wras = 2'b10;
     ma_wrasd = 1'b0;
    end
    else begin
     ma_sawl = 2'b00;
     ma_wras = 2'b00;
     ma_wrasd = 1'b1;
    end
  end

  MBH_ZSNL_IN22FDX_S1PL_NFLG_W00256B256M04C128  u_gf22_ml_icache
    (
     .clk(clock),
     .cen(~valid),
     .rdwen(~write),
     .deepsleep(1'b0),
     .powergate(1'b0),
     .MA_SAWL0(ma_sawl[0]),
     .MA_SAWL1(ma_sawl[1]),
     .MA_WRAS0(ma_wras[0]),
     .MA_WRAS1(ma_wras[1]),
     .MA_WRASD(ma_wrasd),
     .a(addr),
     .d(wdata),
     .bw({256{1'b1}}),
     .q(rdata)
     );
`else
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
`endif // GF22_ML_CACHE
endmodule
