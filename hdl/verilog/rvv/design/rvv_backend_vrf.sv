/*
description: 
1. the VRF contains 32xVLEN register file. It support 4 read ports and 4 write ports

feature list:
*/
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif

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
genvar  j,k;

//
// code start
//
logic [`NUM_RT_UOP-1:0]                           wr_valid;
logic [`NUM_RT_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] wr_addr;
logic [`NUM_RT_UOP-1:0][`VLEN-1:0]                wr_data;
logic [`NUM_RT_UOP-1:0][`VLENB-1:0]               wr_we;              // byte enable
logic [`NUM_RT_UOP-1:0][`VLEN-1:0]                wr_web;             // bit enable
logic [`NUM_RT_UOP-1:0][`NUM_VRF-1:0][`VLENB-1:0] vrf_wr_wen;
logic [`NUM_RT_UOP-1:0][`NUM_VRF-1:0][`VLEN-1:0]  vrf_wr_data;
logic [`NUM_VRF-1:0][`VLENB-1:0]                  vrf_wr_wen_full;
logic [`NUM_VRF-1:0][`VLEN-1:0]                   vrf_wr_data_full;
logic [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_addr;
logic [`NUM_VRF-1:0][`VLEN-1:0]                   vrf_rd_data_full;   // full 32 VLEN data from VRF

// RT2VRF data unpack
generate
  for (j=0;j<`NUM_RT_UOP;j++) begin: GET_WT_DATA
    assign wr_valid[j] = rt2vrf_wr_valid[j];
    assign wr_addr[j]  = rt2vrf_wr_data[j].rt_index;
    assign wr_data[j]  = rt2vrf_wr_data[j].rt_data;
    assign wr_we[j]    = rt2vrf_wr_data[j].rt_strobe;

    // generate write bit-enable
    for(k=0;k<`VLENB;k++) begin: GET_WE_BIT
      assign wr_web[j][k*`BYTE_WIDTH +: `BYTE_WIDTH] = {`BYTE_WIDTH{wr_we[j][k]}};
    end

    // access VRF. Only write will update input
    always_comb begin
      vrf_wr_wen[j]  = 'b0;
      vrf_wr_data[j] = 'b0;

      if(wr_valid[j]) begin
        vrf_wr_wen[j][wr_addr[j]] = wr_we[j];
        vrf_wr_data[j][wr_addr[j]] = wr_data[j]&wr_web[j];
      end
    end
  end
endgenerate

// merge all retire data
always_comb begin
  vrf_wr_wen_full = 'b0;
  vrf_wr_data_full = 'b0;

  for(int i=0; i<`NUM_VRF; i++) begin
    for(int h=0; h<`NUM_RT_UOP; h++) begin
      vrf_wr_wen_full[i] = vrf_wr_wen_full[i] | vrf_wr_wen[h][i];
      vrf_wr_data_full[i] = vrf_wr_data_full[i] | vrf_wr_data[h][i];
    end
  end
end

//VRF core
rvv_backend_vrf_reg
vrf_reg (
  //Outputs
  .vreg   (vrf_rd_data_full),
  //Inputs
  .clk    (clk), 
  .rst_n  (rst_n),
  .wen    (vrf_wr_wen_full),
  .wdata  (vrf_wr_data_full)
);

// VRF2DP data pack
assign vrf2dp_v0_data = vrf_rd_data_full[0];

generate
  for (j=0;j<`NUM_DP_VRF;j++) begin: GET_RD_DATA
    assign rd_addr[j]        = dp2vrf_rd_index[j];
    assign vrf2dp_rd_data[j] = vrf_rd_data_full[rd_addr[j]];
  end
endgenerate


endmodule
