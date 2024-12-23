/*
description: 
1. the VRF contains 32xVLEN register file. It support 4 read ports and 4 write ports

feature list:
*/
`include "rvv_backend.svh"

module rvv_backend_vrf(/*AUTOARG*/
   // Outputs
   vrf2dp_rd_data, vrf2dp_v0_data,
   // Inputs
   clk, rst_n, dp2vrf_rd_index, 
   rt2vrf_wr_valid, rt2vrf_wr_data
   );  
// global signal
input   logic                   clk;
input   logic                   rst_n;
    
// Dispatch unit to VRF unit
// Vs_data would be return from VRF at the current cycle.
input   logic     [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] dp2vrf_rd_index;

// VRF to Dispatch read data
output  logic     [`NUM_DP_VRF-1:0][`VLEN-1:0]  vrf2dp_rd_data;
output  logic                      [`VLEN-1:0]  vrf2dp_v0_data;

// Write back to VRF
input   logic     [`NUM_RT_UOP-1:0] rt2vrf_wr_valid;
input   RT2VRF_t  [`NUM_RT_UOP-1:0] rt2vrf_wr_data;


// Wires & Regs
wire [`REGFILE_INDEX_WIDTH-1:0] rd_addr0;
wire [`REGFILE_INDEX_WIDTH-1:0] rd_addr1;
wire [`REGFILE_INDEX_WIDTH-1:0] rd_addr2;
wire [`REGFILE_INDEX_WIDTH-1:0] rd_addr3;

wire wr_valid0;
wire wr_valid1;
wire wr_valid2;
wire wr_valid3;

wire [`REGFILE_INDEX_WIDTH-1:0] wr_addr0;
wire [`REGFILE_INDEX_WIDTH-1:0] wr_addr1;
wire [`REGFILE_INDEX_WIDTH-1:0] wr_addr2;
wire [`REGFILE_INDEX_WIDTH-1:0] wr_addr3;

wire [`VLEN-1:0] wr_data0;
wire [`VLEN-1:0] wr_data1;
wire [`VLEN-1:0] wr_data2;
wire [`VLEN-1:0] wr_data3;

wire [`VLENB-1:0] wr_we0;
wire [`VLENB-1:0] wr_we1;
wire [`VLENB-1:0] wr_we2;
wire [`VLENB-1:0] wr_we3;

wire [`VLEN-1:0] wr_web0;
wire [`VLEN-1:0] wr_web1;
wire [`VLEN-1:0] wr_web2;
wire [`VLEN-1:0] wr_web3;

reg [31:0] [`VLEN-1:0] vrf_wr_wenb0;
reg [31:0] [`VLEN-1:0] vrf_wr_data0;

reg [31:0] [`VLEN-1:0] vrf_wr_wenb1;
reg [31:0] [`VLEN-1:0] vrf_wr_data1;

reg [31:0] [`VLEN-1:0] vrf_wr_wenb2;
reg [31:0] [`VLEN-1:0] vrf_wr_data2;

reg [31:0] [`VLEN-1:0] vrf_wr_wenb3;
reg [31:0] [`VLEN-1:0] vrf_wr_data3;

reg [31:0] [`VLEN-1:0] vrf_wr_wenb_full;
reg [31:0] [`VLEN-1:0] vrf_wr_data_full;

wire [31:0] [`VLEN-1:0] vrf_rd_data_full;


// DP2VRF data unpack
assign rd_addr0 = dp2vrf_rd_index[0];
assign rd_addr1 = dp2vrf_rd_index[1];
assign rd_addr2 = dp2vrf_rd_index[2];
assign rd_addr3 = dp2vrf_rd_index[3];

// RT2VRF data unpack
assign wr_valid0 = rt2vrf_wr_valid[0];
assign wr_valid1 = rt2vrf_wr_valid[1];
assign wr_valid2 = rt2vrf_wr_valid[2];
assign wr_valid3 = rt2vrf_wr_valid[3];

assign wr_addr0 = rt2vrf_wr_data[0].rt_index;
assign wr_addr1 = rt2vrf_wr_data[1].rt_index;
assign wr_addr2 = rt2vrf_wr_data[2].rt_index;
assign wr_addr3 = rt2vrf_wr_data[3].rt_index;

assign wr_data0 = rt2vrf_wr_data[0].rt_data;
assign wr_data1 = rt2vrf_wr_data[1].rt_data;
assign wr_data2 = rt2vrf_wr_data[2].rt_data;
assign wr_data3 = rt2vrf_wr_data[3].rt_data;

assign wr_we0 = rt2vrf_wr_data[0].rt_strobe;
assign wr_we1 = rt2vrf_wr_data[1].rt_strobe;
assign wr_we2 = rt2vrf_wr_data[2].rt_strobe;
assign wr_we3 = rt2vrf_wr_data[3].rt_strobe;

assign wr_web0 = {{8{wr_we0[15]}},{8{wr_we0[14]}},{8{wr_we0[13]}},{8{wr_we0[12]}},{8{wr_we0[11]}},{8{wr_we0[10]}},{8{wr_we0[9]}},{8{wr_we0[8]}},{8{wr_we0[7]}},{8{wr_we0[6]}},{8{wr_we0[5]}},{8{wr_we0[4]}},{8{wr_we0[3]}},{8{wr_we0[2]}},{8{wr_we0[1]}},{8{wr_we0[0]}}};

assign wr_web1 = {{8{wr_we1[15]}},{8{wr_we1[14]}},{8{wr_we1[13]}},{8{wr_we1[12]}},{8{wr_we1[11]}},{8{wr_we1[10]}},{8{wr_we1[9]}},{8{wr_we1[8]}},{8{wr_we1[7]}},{8{wr_we1[6]}},{8{wr_we1[5]}},{8{wr_we1[4]}},{8{wr_we1[3]}},{8{wr_we1[2]}},{8{wr_we1[1]}},{8{wr_we1[0]}}};

assign wr_web2 = {{8{wr_we2[15]}},{8{wr_we2[14]}},{8{wr_we2[13]}},{8{wr_we2[12]}},{8{wr_we2[11]}},{8{wr_we2[10]}},{8{wr_we2[9]}},{8{wr_we2[8]}},{8{wr_we2[7]}},{8{wr_we2[6]}},{8{wr_we2[5]}},{8{wr_we2[4]}},{8{wr_we2[3]}},{8{wr_we2[2]}},{8{wr_we2[1]}},{8{wr_we2[0]}}};

assign wr_web3 = {{8{wr_we3[15]}},{8{wr_we3[14]}},{8{wr_we3[13]}},{8{wr_we3[12]}},{8{wr_we3[11]}},{8{wr_we3[10]}},{8{wr_we3[9]}},{8{wr_we3[8]}},{8{wr_we3[7]}},{8{wr_we3[6]}},{8{wr_we3[5]}},{8{wr_we3[4]}},{8{wr_we3[3]}},{8{wr_we3[2]}},{8{wr_we3[1]}},{8{wr_we3[0]}}};

// Access Core
// Only write will update input

always@(*) begin
  vrf_wr_wenb0 = 4096'b0;
  vrf_wr_data0 = 4096'b0;
  if (wr_valid0) begin
    vrf_wr_wenb0[wr_addr0] = wr_web0;
    vrf_wr_data0[wr_addr0] = (wr_data0 & wr_web0);
  end
end

always@(*) begin
  vrf_wr_wenb1 = 4096'b0;
  vrf_wr_data1 = 4096'b0;
  if (wr_valid1) begin
    vrf_wr_wenb1[wr_addr1] = wr_web1;
    vrf_wr_data1[wr_addr1] = (wr_data1 & wr_web1);
  end
end

always@(*) begin
  vrf_wr_wenb2 = 4096'b0;
  vrf_wr_data2 = 4096'b0;
  if (wr_valid2) begin
    vrf_wr_wenb2[wr_addr2] = wr_web2;
    vrf_wr_data2[wr_addr2] = (wr_data2 & wr_web2);
  end
end

always@(*) begin
  vrf_wr_wenb3 = 4096'b0;
  vrf_wr_data3 = 4096'b0;
  if (wr_valid3) begin
    vrf_wr_wenb3[wr_addr3] = wr_web3;
    vrf_wr_data3[wr_addr3] = (wr_data3 & wr_web3);
  end
end

// Mux 4 inputs to vrf_reg

always@(*) begin
  for(int i=0; i<32; i=i+1) begin
    vrf_wr_wenb_full[i] = vrf_wr_wenb3[i] | vrf_wr_wenb2[i] | vrf_wr_wenb1[i] | vrf_wr_wenb0[i];
    vrf_wr_data_full[i] = vrf_wr_data3[i] | vrf_wr_data2[i] | vrf_wr_data1[i] | vrf_wr_data0[i];
  end
end

//VRF core
rvv_backend_vrf_reg vrf_reg (
  //Outputs
  .vreg(vrf_rd_data_full), 
  //Inputs
  .clk(clk), 
  .rst_n(rst_n),
  .wenb(vrf_wr_wenb_full), 
  .wdata(vrf_wr_data_full));

// VRF2DP data pack
assign vrf2dp_rd_data[0] = vrf_rd_data_full[rd_addr0];
assign vrf2dp_rd_data[1] = vrf_rd_data_full[rd_addr1];
assign vrf2dp_rd_data[2] = vrf_rd_data_full[rd_addr2];
assign vrf2dp_rd_data[3] = vrf_rd_data_full[rd_addr3];
assign vrf2dp_v0_data = vrf_rd_data_full[0];


endmodule
