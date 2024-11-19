/*
description:
1. Dispatch unit receives uop instructions from uop queue
2. Dispatch unit check rules to determine if the uops are sent to reservation stations(RS). 
   There are two ways to solve: 
    a. stall pipeline
    b. foreward data from ROB
3. Dispatch unit read vector data from VRF for uops.

feature list:
1. Dispatch module can issue 2 uops at most.
    a. Uop sequence must be in-order.
    b. Issuing uop(s) use valid-ready handshake mechanism.
2. Dispatch rules
    a. RAW data hazard: 
        I. uop0 Vs rob_entry(s). if rob_entry.vd_valid is 'b0, then stall pipeline (do not issue uop0)
        II.uop1 Vs rob_entry(s). if rob_entry.vd_valid is 'b0, then do not issue uop1
        II.uop1 Vs uop0. if uop0.vd_valid is the src of uop1, then do not issue uop0
    b. Structure hazard:
        I. the src-operand number of uops is more than 4, then only issue uop0
*/

`include "rvv.svh"

module rvv_dispatch
(
    clk,
    rstn,
    uops_valid_de2dp,
    uops_de2dp,
    uops_ready_dp2de,
    rs_valid_dp2alu,
    rs_dp2alu,
    rs_ready_alu2dp,
    rs_valid_dp2pmt,
    rs_dp2pmt,
    rs_ready_pmt2dp,
    rs_valid_dp2mul,
    rs_dp2mul,
    rs_ready_mul2dp,
    rs_valid_dp2div,
    rs_dp2div,
    rs_ready_div2dp,
    rs_valid_dp2lsu,
    rs_dp2lsu,
    rs_ready_lsu2dp,
    rc_valid_dp2rob,
    rc_dp2rob,
    rc_ready_rob2dp,
    vs_index_dp2vrf,        
    vs_data_vrf2dp,
    v0_mask_vrf2dp,
    rob_entry
);  
// global signal
    input   logic           clk;
    input   logic           rstn;

// Uops Queue to Dispatch unit
    input  logic            uops_valid_de2dp[`NUM_DP_UOP-1:0];
    input  UOP_QUEUE_t      uops_de2dp[`NUM_DP_UOP-1:0];
    output logic            uops_ready_dp2de[`NUM_DP_UOP-1:0];

// Dispatch unit sends oprations to reservation stations
// Dispatch unit to ALU reservation station
// rs_*: reservation station
    output logic            rs_valid_dp2alu[`NUM_DP_RS-1:0];
    output ALU_RS_t         rs_dp2alu[`NUM_DP_RS-1:0];
    input  logic            rs_ready_alu2dp[`NUM_DP_RS-1:0];

// Dispatch unit to PMT+RDT reservation station
    output logic            rs_valid_dp2pmt[`NUM_DP_RS-1:0];
    output PMT_RDT_RS_t     rs_dp2pmt[`NUM_DP_RS-1:0];
    input  logic            rs_ready_pmt2dp[`NUM_DP_RS-1:0];

// Dispatch unit to MUL reservation station
    output logic            rs_valid_dp2mul[`NUM_DP_RS-1:0];
    output MUL_RS_t         rs_dp2mul[`NUM_DP_RS-1:0];
    input  logic            rs_ready_mul2dp[`NUM_DP_RS-1:0];

// Dispatch unit to DIV reservation station
    output logic            rs_valid_dp2div[`NUM_DP_RS-1:0];
    output DIV_RS_t         rs_dp2div[`NUM_DP_RS-1:0];
    input  logic            rs_ready_div2dp[`NUM_DP_RS-1:0];

// Dispatch unit to LSU reservation station
    output logic            rs_valid_dp2lsu[`NUM_DP_RS-1:0];
    output LSU_RS_t         rs_dp2lsu[`NUM_DP_RS-1:0];
    input  logic            rs_ready_lsu2dp[`NUM_DP_RS-1:0];

// Dispatch unit pushes operations to ROB unit
// rc_*: register completation
    output logic            rc_valid_dp2rob[`NUM_DP_RC-1:0];
    output RC_t             rc_dp2rob[`NUM_DP_RC-1:0];
    input  logic            rc_ready_rob2dp[`NUM_DP_RC-1:0];

// Dispatch unit sends read request to VRF for vector data.
// Dispatch unit to VRF unit
// Vs_data would be return from VRF at the current cycle.
    output [`REGFILE_INDEX_WIDTH-1:0] vs_index_dp2vrf[`NUM_DP_VRF-1:0];          
    input  [`VLEN-1:0]                vs_data_vrf2dp[`NUM_DP_VRF-1:0];
    input  [`VLEN-1:0]                v0_mask_vrf2dp;

// Dispatch unit accept all ROB entry to determine if vs_data of RS is from ROB or not
// ROB unit to Dispatch unit
    input  ROB_t            rob_entry[`ROB_DEPTH-1:0];

endmodule
