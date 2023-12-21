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

module Sram_1rwm_256x288(
  input          clock,
  input          valid,
  input          write,
  input  [7:0]   addr,
  input  [287:0] wdata,
  input  [31:0]  wmask,
  output [287:0] rdata,
  input          volt_sel
);

`ifdef FPGA
reg [287:0] mem [0:255];
reg [7:0] raddr;

assign rdata = mem[raddr];

always @(posedge clock) begin
  for (int i = 0; i < 32; i++) begin
    if (valid & write & wmask[i]) begin
      mem[addr][i*9 +: 9] <= wdata[i*9 +: 9];
    end
  end
  if (valid & ~write) begin
    raddr <= addr;
  end
end

endmodule  // Sram_1rwm_256x288

`else  // !FPGA

Sram_1rw_256x9 u_bl00(clock, valid & (~write | wmask[0]),  write, addr, wdata[  0 +: 9], rdata[  0 +: 9], volt_sel);
Sram_1rw_256x9 u_bl01(clock, valid & (~write | wmask[1]),  write, addr, wdata[  9 +: 9], rdata[  9 +: 9], volt_sel);
Sram_1rw_256x9 u_bl02(clock, valid & (~write | wmask[2]),  write, addr, wdata[ 18 +: 9], rdata[ 18 +: 9], volt_sel);
Sram_1rw_256x9 u_bl03(clock, valid & (~write | wmask[3]),  write, addr, wdata[ 27 +: 9], rdata[ 27 +: 9], volt_sel);
Sram_1rw_256x9 u_bl04(clock, valid & (~write | wmask[4]),  write, addr, wdata[ 36 +: 9], rdata[ 36 +: 9], volt_sel);
Sram_1rw_256x9 u_bl05(clock, valid & (~write | wmask[5]),  write, addr, wdata[ 45 +: 9], rdata[ 45 +: 9], volt_sel);
Sram_1rw_256x9 u_bl06(clock, valid & (~write | wmask[6]),  write, addr, wdata[ 54 +: 9], rdata[ 54 +: 9], volt_sel);
Sram_1rw_256x9 u_bl07(clock, valid & (~write | wmask[7]),  write, addr, wdata[ 63 +: 9], rdata[ 63 +: 9], volt_sel);
Sram_1rw_256x9 u_bl08(clock, valid & (~write | wmask[8]),  write, addr, wdata[ 72 +: 9], rdata[ 72 +: 9], volt_sel);
Sram_1rw_256x9 u_bl09(clock, valid & (~write | wmask[9]),  write, addr, wdata[ 81 +: 9], rdata[ 81 +: 9], volt_sel);
Sram_1rw_256x9 u_bl10(clock, valid & (~write | wmask[10]), write, addr, wdata[ 90 +: 9], rdata[ 90 +: 9], volt_sel);
Sram_1rw_256x9 u_bl11(clock, valid & (~write | wmask[11]), write, addr, wdata[ 99 +: 9], rdata[ 99 +: 9], volt_sel);
Sram_1rw_256x9 u_bl12(clock, valid & (~write | wmask[12]), write, addr, wdata[108 +: 9], rdata[108 +: 9], volt_sel);
Sram_1rw_256x9 u_bl13(clock, valid & (~write | wmask[13]), write, addr, wdata[117 +: 9], rdata[117 +: 9], volt_sel);
Sram_1rw_256x9 u_bl14(clock, valid & (~write | wmask[14]), write, addr, wdata[126 +: 9], rdata[126 +: 9], volt_sel);
Sram_1rw_256x9 u_bl15(clock, valid & (~write | wmask[15]), write, addr, wdata[135 +: 9], rdata[135 +: 9], volt_sel);
Sram_1rw_256x9 u_bl16(clock, valid & (~write | wmask[16]), write, addr, wdata[144 +: 9], rdata[144 +: 9], volt_sel);
Sram_1rw_256x9 u_bl17(clock, valid & (~write | wmask[17]), write, addr, wdata[153 +: 9], rdata[153 +: 9], volt_sel);
Sram_1rw_256x9 u_bl18(clock, valid & (~write | wmask[18]), write, addr, wdata[162 +: 9], rdata[162 +: 9], volt_sel);
Sram_1rw_256x9 u_bl19(clock, valid & (~write | wmask[19]), write, addr, wdata[171 +: 9], rdata[171 +: 9], volt_sel);
Sram_1rw_256x9 u_bl20(clock, valid & (~write | wmask[20]), write, addr, wdata[180 +: 9], rdata[180 +: 9], volt_sel);
Sram_1rw_256x9 u_bl21(clock, valid & (~write | wmask[21]), write, addr, wdata[189 +: 9], rdata[189 +: 9], volt_sel);
Sram_1rw_256x9 u_bl22(clock, valid & (~write | wmask[22]), write, addr, wdata[198 +: 9], rdata[198 +: 9], volt_sel);
Sram_1rw_256x9 u_bl23(clock, valid & (~write | wmask[23]), write, addr, wdata[207 +: 9], rdata[207 +: 9], volt_sel);
Sram_1rw_256x9 u_bl24(clock, valid & (~write | wmask[24]), write, addr, wdata[216 +: 9], rdata[216 +: 9], volt_sel);
Sram_1rw_256x9 u_bl25(clock, valid & (~write | wmask[25]), write, addr, wdata[225 +: 9], rdata[225 +: 9], volt_sel);
Sram_1rw_256x9 u_bl26(clock, valid & (~write | wmask[26]), write, addr, wdata[234 +: 9], rdata[234 +: 9], volt_sel);
Sram_1rw_256x9 u_bl27(clock, valid & (~write | wmask[27]), write, addr, wdata[243 +: 9], rdata[243 +: 9], volt_sel);
Sram_1rw_256x9 u_bl28(clock, valid & (~write | wmask[28]), write, addr, wdata[252 +: 9], rdata[252 +: 9], volt_sel);
Sram_1rw_256x9 u_bl29(clock, valid & (~write | wmask[29]), write, addr, wdata[261 +: 9], rdata[261 +: 9], volt_sel);
Sram_1rw_256x9 u_bl30(clock, valid & (~write | wmask[30]), write, addr, wdata[270 +: 9], rdata[270 +: 9], volt_sel);
Sram_1rw_256x9 u_bl31(clock, valid & (~write | wmask[31]), write, addr, wdata[279 +: 9], rdata[279 +: 9], volt_sel);

endmodule  // Sram_1rwm_256x288

module Sram_1rw_256x9(
  input          clock,
  input          valid,
  input          write,
  input  [7:0]   addr,
  input  [8:0]   wdata,
  output [8:0]   rdata,
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

  begin
   MBH_ZSNL_IN22FDX_S1PL_NFLG_W00256B009M16C128  u_gf22_ml_dcache
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
    .bw({9{1'b1}}),
    .q(rdata)
    );
  end
`else

  reg [8:0] mem [0:255];
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
endmodule  // Sram_1rw_256x9

`endif  // FPGA
