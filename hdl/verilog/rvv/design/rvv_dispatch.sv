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
    rst_n,
    uop_valid_uop2dp,
    uop_uop2dp,
    uop_ready_dp2uop,
    rs_valid_dp2alu,
    rs_dp2alu,
    rs_ready_alu2dp,
    rs_valid_dp2pmtrdt,
    rs_dp2pmt,
    rs_ready_pmtrdt2dp,
    rs_valid_dp2mul,
    rs_dp2mul,
    rs_ready_mul2dp,
    rs_valid_dp2div,
    rs_dp2div,
    rs_ready_div2dp,
    rs_valid_dp2lsu,
    rs_dp2lsu,
    rs_ready_lsu2dp,
    uop_valid_dp2rob,
    uop_dp2rob,
    uop_ready_rob2dp,
    rd_index_dp2vrf,        
    rd_data_vrf2dp,
    v0_mask_vrf2dp,
    rob_entry
);  
// ---port definition-------------------------------------------------
// global signal
    input   logic           clk;
    input   logic           rst_n;

// Uops Queue to Dispatch unit
    input  logic            uop_valid_uop2dp[`NUM_DP_UOP-1:0];
    input  UOP_QUEUE_t      uop_uop2dp[`NUM_DP_UOP-1:0];
    output logic            uop_ready_dp2uop[`NUM_DP_UOP-1:0];

// Dispatch unit sends oprations to reservation stations
// Dispatch unit to ALU reservation station
// rs_*: reservation station
    output logic            rs_valid_dp2alu[`NUM_DP_RS-1:0];
    output ALU_RS_t         rs_dp2alu[`NUM_DP_RS-1:0];
    input  logic            rs_ready_alu2dp[`NUM_DP_RS-1:0];

// Dispatch unit to PMT+RDT reservation station
    output logic            rs_valid_dp2pmtrdt[`NUM_DP_RS-1:0];
    output PMT_RDT_RS_t     rs_dp2pmt[`NUM_DP_RS-1:0];
    input  logic            rs_ready_pmtrdt2dp[`NUM_DP_RS-1:0];

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
    output logic            uop_valid_dp2rob[`NUM_DP_RC-1:0];
    output UOP_ROB_t        uop_dp2rob[`NUM_DP_RC-1:0];
    input  logic            uop_ready_rob2dp[`NUM_DP_RC-1:0];
    input  logic [`ROB_DEPTH_WIDTH-1:0] uop_index_rob2dp;

// Dispatch unit sends read request to VRF for vector data.
// Dispatch unit to VRF unit
// rd_data would be return from VRF at the current cycle.
    output [`REGFILE_INDEX_WIDTH-1:0] rd_index_dp2vrf[`NUM_DP_VRF-1:0];          
    input  [`VLEN-1:0]                rd_data_vrf2dp[`NUM_DP_VRF-1:0];
    input  [`VLEN-1:0]                v0_mask_vrf2dp;

// Dispatch unit accept all ROB entry to determine if vs_data of RS is from ROB or not
// ROB unit to Dispatch unit
    input  ROB_t            rob_entry[`ROB_DEPTH-1:0];

// ---internal singal definition--------------------------------------
    RAW_UOP_ROB_t [`NUM_DP_UOP-1:0]   raw_uop_rob; 
    // uop0 is the first uop so no need raw check between uops for it
    RAW_UOP_UOP_t [`NUM_DP_UOP-1:1]   raw_uop_uop; 
    ARCH_HAZARD_t                     arch_hazard;

    UOP_OPN_t     [`NUM_DP_UOP-1:0]   uop_operands;
    UOP_OPN_t     [`NUM_DP_UOP-1:0]   vrf_byp;

    UOP_OPN_BYTE_TYPE_t [`NUM_DP_UOP-1:0] uop_operands_byte_type;

// ---code start------------------------------------------------------
// RAW data hazard check between uop[*] and ROB
    genvar i;
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_raw_uop_rob
            rvv_dispatch_raw_uop_rob #(
                .PREUOP_NUM (`ROB_DEPTH)
            ) u_raw_uop_rob (
                .raw_uop_rob  (raw_uop_rob[i]),
                .suc_uop      (uop_uop2dp[i]),
                .pre_uop      (rob_entry)
            );
        end
    endgenerate

// RAW data hazard check between uop(s)
    generate
        for (i=1; i<`NUM_DP_UOP; i++) begin : gen_raw_uop_uop
            rvv_dispatch_raw_uop_uop #(
                .PREUOP_NUM (i)
            ) u_raw_uop_uop (
                .raw_uop_uop  (raw_uop_uop[i]),
                .suc_uop      (uop_uop2dp[i]),
                .pre_uop      (uop_uop2dp[i-1:0])
            );
        end
    endgenerate

// Structure hazard check and set read index for VRF
    rvv_dispatch_structure_hazard #(
        .UOP_NUM (`NUM_DP_UOP)
    ) u_structure_hazard (
        .rd_index     (rd_index_dp2vrf),
        .arch_hazard  (arch_hazard),
        .uop          (uop_uop2dp)
    );

// Bypass data for source operand of uop(s)
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_bypass
            rvv_dispatch_bypass #(
                .BYP_NUM (`ROB_DEPTH)
            ) u_bypass (
                .uop_operands (uop_operands[i]),
                .rob_byp      (rob_entry),
                .vrf_byp      (vrf_byp[i]),
                .raw_uop_rob  (raw_uop_rob[i])
            );
        end
    endgenerate

// Control handshae mechanism for uop_queue <-> dispath, dispatch <-> rs and dispatch <-> rob
    rvv_dispatch_ctrl #(
        .UOP_NUM (`NUM_DP_UOP)
    ) u_ctrl (
      // ctrl input signal
        .raw_uop_rob  (raw_uop_rob),
        .raw_uop_uop  (raw_uop_uop),
        .arch_hazard  (arch_hazard),
      // handshake signals
        .uop_valid_uop2dp   (uop_valid_uop2dp),
        .uop_ready_dp2uop   (uop_ready_uop2dp),
        .rs_valid_dp2alu    (rs_valid_dp2alu),
        .rs_ready_alu2dp    (rs_ready_alu2dp),
        .rs_valid_dp2pmtrdt (rs_valid_dp2pmtrdt),
        .rs_ready_pmtrdt2dp (rs_ready_pmtrdt2dp),
        .rs_valid_dp2mul    (rs_valid_dp2mul),
        .rs_ready_mul2dp    (rs_ready_mul2dp),
        .rs_valid_dp2div    (rs_valid_dp2div),
        .rs_ready_div2dp    (rs_ready_div2dp),
        .rs_valid_dp2lsu    (rs_valid_dp2lsu),
        .rs_ready_lsu2dp    (rs_ready_lsu2dp),
        .uop_valid_dp2rob   (uop_valid_dp2rob),
        .uop_ready_uop2dp   (uop_ready_rob2dp)
    );

// determine the type for each byte in uop's vector operands 
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_opr_bype_type
            rvv_dispatch_opr_byte_type #(
            ) u_opr_byte_type (
                .operands_byte_type (uop_operands_byte_type[i]),
                .uop                (uop_uop2dp[i]),
                .v0_mask            (uop_operands[i].v0)
            );
        end
    endgenerate

endmodule
