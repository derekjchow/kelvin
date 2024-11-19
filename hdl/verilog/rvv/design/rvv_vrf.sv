/*
description: 
1. the VRF contains 32xVLEN register file. It support 4 read ports and 4 write ports

feature list:
*/

`include "rvv.svh"

module rvv_vrf
(
    clk,
    rstn,
    vs_index_dp2vrf,         
    vs_data_vrf2dp,
    v0_mask_vrf2dp,
    wb_vrf_valid_wb2vrf,
    wb_vrf_wb2vrf,
    wb_vrf_ready_wb2vrf,
);  
// global signal
    input   logic                   clk;
    input   logic                   rstn;
    
// Dispatch unit to VRF unit
// Vs_data would be return from VRF at the current cycle.
    input  [`REGFILE_INDEX_WIDTH-1:0] vs_index_dp2vrf[`NUM_DP_VRF-1:0];          
    output [`VLEN-1:0]                vs_data_vrf2dp[`NUM_DP_VRF-1:0];
    output [`VLEN-1:0]                v0_mask_vrf2dp;

// write back to XRF
    input   logic                     wb_vrf_valid_wb2vrf[`NUM_WB_UOP-1:0];
    input   WB_XRF_t                  wb_vrf_wb2vrf[`NUM_WB_UOP-1:0];
    output  logic                     wb_vrf_ready_wb2vrf[`NUM_WB_UOP-1:0];

endmodule
