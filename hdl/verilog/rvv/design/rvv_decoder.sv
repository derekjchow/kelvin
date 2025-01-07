/*
description: 
1. It will read instructions from Command Queue and decode the instructions to uops and write to Uops Queue.

feature list:
1. Decode unit can decode 2 instructions at most and write 4 uops to Uops Queue at most per cycle.
2. One instruction can be decoded to 8 uops at most.
3. uops_de2dp.rs1_data could be from X[rs1] and imm(insts[19:15]). If it is imm, the 5-bit imm(insts[19:15]) will be SIGN-extended or ZERO-extended to XLEN-bit. 
*/

`include "rvv.svh"

module rvv_decoder
(
    clk,
    rstn,
    insts_valid_cq2de,
    insts_cq2de,
    insts_ready_de2cq,
    uops_valid_de2dp,
    uops_de2dp,
    uops_ready_dp2de,
    flush_uopsq_wb2de
);  
// global signal
    input   logic                   clk;
    input   logic                   rstn;
    
// Command Queue to Decoder 
    input   logic                   insts_valid_cq2de[`NUM_DE_INST-1:0];
    input   INST_t                  insts_cq2de[`NUM_DE_INST-1:0];
    output  logic                   insts_ready_de2cq[`NUM_DE_INST-1:0];
    
// Uops Queue to Dispatch unit  
    output  logic                   uops_valid_de2dp[`NUM_DP_UOP-1:0];
    output  UOP_QUEUE_t             uops_de2dp[`NUM_DP_UOP-1:0];
    input   logic                   uops_ready_dp2de[`NUM_DE_INST-1:0];

// Trap handler to Command Queue
    // If RVS find some illegal instructions when complete LSU transaction, like bus error,
    // it means a trap occurs to the instruction that is executing in RVV.
    // So RVV will top CQ to receive new instructions and flush Command Queue and Uops Queue, 
    // and complete the instructions in EX, ME and WB stage. And RVS need to send rob_entry of that exception instruction.
    // After RVV retire all uops before that exception instruction, RVV response a ready signal for trap application.      
    input   logic                   flush_uopsq_wb2de;   










  // the start uop index of decoding instruction
  logic   [`UOP_INDEX_WIDTH-1:0]      uop_index_reg_in;      
  logic   [`UOP_INDEX_WIDTH-1:0]      uop_index_reg_out;     
  
  // update uop index    
  edff #(`UOP_INDEX_WIDTH) uop_index_reg ( 
    .clk		(clk), 
		.rst_n	(rst_n), 
		.e		  (1'b1), 
		.d		  (uop_index_reg_in),
		.q		  (uop_index_reg_out)
	);



endmodule
