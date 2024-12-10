/*
description: 
1. the ROB module receives uop information from Dispatch unit and uop result from Processor Unit (PU).
2. the ROB module provides all status for dispatch unit to foreward operand from ROB.
3. the ROB module send retire request to writeback unit.

feature list:
1. the ROB can receive 2 uop information form Dispatch unit at most per cycle.
2. the ROB can receive 9 uop result from PU at most per cycle.
    a. However, U-arch of RVV limit the result number from 9 to 8.
3. Because EMUL_max=8, the ROB will check at least 8 uops whether vector instruction are done or not per cycle. 
4. If all uops of instruction(s) are ready in ROB, the ROB can send 4 retire uops to writeback unit at most per cycle.
*/

`include "rvv.svh"

module rvv_rob
(
    clk,
    rstn,
    rc_valid_dp2rob,
    rc_dp2rob,
    rc_ready_rob2dp,
    wr_valid_alu2rob,
    wr_alu2rob,
    wr_ready_alu2rob,
    wr_valid_pmtred2rob,
    wr_pmtred2rob,
    wr_ready_pmtred2rob,
    wr_valid_mul2rob,
    wr_pmtred2rob,
    wr_ready_mul2rob,
    wr_valid_div2rob,
    wr_div2rob,
    wr_ready_div2rob,
    wr_valid_lsu2rob,
    wr_lsu2rob,
    wr_ready_lsu2rob,
    rd_valid_rob2wb,
    rd_rob2wb,
    rd_ready_rob2wb,
    rob_entry
);  
// global signal
    input   logic                   clk;
    input   logic                   rstn;

// push uop infomation to ROB
// Dispatch to ROB
    input  logic                    uop_valid_dp2rob[`NUM_DP_RC-1:0];
    input  UOP_ROB_t                uop_dp2rob[`NUM_DP_RC-1:0];
    output logic                    uop_ready_rob2dp[`NUM_DP_RC-1:0];
    output logic [`ROB_DEPTH_WIDTH-1:0] uop_index_rob2dp;

// push uop result to ROB
// ALU to ROB
    input   logic                   wr_valid_alu2rob[`NUM_ALU-1:0];
    input   ALU_ROB_t               wr_alu2rob[`NUM_ALU-1:0];
    output  logic                   wr_ready_alu2rob[`NUM_ALU-1:0];

// PMT+RED to ROB
    input   logic                   wr_valid_pmtred2rob[`NUM_PMTRED-1:0];
    input   PMTRED_ROB_t            wr_pmtred2rob[`NUM_PMTRED-1:0];
    output  logic                   wr_ready_pmtred2rob[`NUM_PMTRED-1:0];

// MUL to ROB
    input   logic                   wr_valid_mul2rob[`NUM_MUL-1:0];
    input   MUL_ROB_t               wr_pmtred2rob[`NUM_MUL-1:0];
    output  logic                   wr_ready_mul2rob[`NUM_MUL-1:0];

// DIV to ROB
    input   logic                   wr_valid_div2rob[`NUM_DIV-1:0];
    input   DIV_ROB_t               wr_div2rob[`NUM_DIV-1:0];
    output  logic                   wr_ready_div2rob[`NUM_DIV-1:0];

// LSU to ROB
    input   logic                   wr_valid_lsu2rob[`NUM_LSU-1:0];
    input   LSU_ROB_t               wr_lsu2rob[`NUM_LSU-1:0];
    output  logic                   wr_ready_lsu2rob[`NUM_LSU-1:0];

// retire uops
// pop vd_data from ROB and write to VRF
    output  logic                   rd_valid_rob2wb[`NUM_ROB_RD-1:0];
    output  ROB_WB_t                rd_rob2wb[`NUM_ROB_RD-1:0];
    input   logic                   rd_ready_rob2wb[`NUM_ROB_RD-1:0];

// bypass all rob entries to Dispatch unit
// rob_entries must be in program order instead of entry_index
    output  ROB_t                   rob_entry[`ROB_DEPTH-1:0];

endmodule
