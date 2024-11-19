/*
description:
1. Command Queue receives vector instructions from RVS and write to Command Queue.

feature list:
1. When RVS send instructions to RVV, the instructions are all vector instructions except vsetvli, vsetivli and vsetvl.
2. Command Queue can receive 4 vector instructions per cycle at most and they are labeled as inst0, inst1, inst2 and inst3. 
   If CQ has only 1 free space, it will only store inst0; If 2 free space, it will store inst0 and inst1; 
   If 3, store inst0-inst2; If more, store inst0-inst3. RVS need to ensure the instructions are sent to RVV in sequence.

3. Command Queue can pop 2 vector intructions to decoder per cycle at most and they are labeled as inst0 and inst1. 
   If decoder receive 2 instruction, it will be inst0 and inst1.
   If decoder only receive 1 instruction, it will be inst0, not inst1.
4. If RVV receive a trap apply from RVS, Command Queue is NOT allowed receiving new instructions.
*/

`include "rvv.svh"

module rvv_cmdq
(
    clk,
    rstn,
    insts_valid_rvs2cq,
    insts_rvs2cq,
    insts_ready_cq2rvs,
    insts_valid_cq2de,
    insts_cq2de,
    insts_ready_de2cq,
    stop_cmdq_wb2if,
    flush_cmdq_wb2if
);  
// global signal
    input   logic           clk;
    input   logic           rstn;

// RVS to Command Queue
    input   logic           insts_valid_rvs2cq[`ISSUE_LANE-1:0];
    input   INST_t          insts_rvs2cq[`ISSUE_LANE-1:0];
    output  logic           insts_ready_cq2rvs[`ISSUE_LANE-1:0];

// Command Queue to Decoder
    output  logic           insts_valid_cq2de[`NUM_DE_INST-1:0];
    output  INST_t          insts_cq2de[`NUM_DE_INST-1:0];
    input   logic           insts_ready_de2cq[`NUM_DE_INST-1:0];

// Trap handler to Command Queue
    // If RVS find some illegal instructions when complete LSU transaction, like bus error,
    // it means a trap occurs to the instruction that is executing in RVV.
    // So RVV will top CQ to receive new instructions and flush Command Queue and Uops Queue, 
    // and complete the instructions in EX, ME and WB stage. And RVS need to send rob_entry of that exception instruction.
    // After RVV retire all uops before that exception instruction, RVV response a ready signal for trap application.      
    input   logic           stop_cmdq_wb2if;    
    input   logic           flush_cmdq_wb2if;   

endmodule