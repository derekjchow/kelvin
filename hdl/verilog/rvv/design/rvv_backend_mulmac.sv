// description: 
// This is the top module of MUL/MAC wrapper
// Contains instantiation of MUL_ex and MAC_ex
// Contains ex arbiter
//
// feature list:
// 1. Instantiation of MUL ex and MAC ex
// 2. Arbitration to uop0/1 to use MUL or MAC
// 3. Pop MUL_RS 


`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_mulmac (
  //Outputs
  ex2rob_valid, ex2rob_data, ex2rs_fifo_pop,
  //Inputs
  clk, rst_n, rs2ex_uop_data, 
  rs2ex_fifo_empty, rs2ex_fifo_1left_to_empty, 
  rob2ex_ready, trap_flush_rvv
);

//global signals
input             clk;
input             rst_n;
input             trap_flush_rvv;

//MUL_RS to MUL_EX 
input MUL_RS_t [`NUM_MUL-1:0] rs2ex_uop_data;
input logic                   rs2ex_fifo_empty;
input logic                   rs2ex_fifo_1left_to_empty;
output logic [`NUM_MUL-1:0]   ex2rs_fifo_pop;

//MUL_EX to ROB
output  logic       [`NUM_MUL-1:0] ex2rob_valid;
output  PU2ROB_t    [`NUM_MUL-1:0] ex2rob_data;
input   logic       [`NUM_MUL-1:0] rob2ex_ready;

// Wires & Regs
logic [`NUM_MUL-1:0]          rs2mac_uop_valid;
logic [`NUM_MUL-1:0]          mac2rs_uop_ready;
MUL_RS_t [`NUM_MUL-1:0]       rs2mac_uop_data;

logic [`NUM_MUL-1:0]          mac2rob_uop_valid;
PU2ROB_t [`NUM_MUL-1:0]       mac2rob_uop_data;

logic [`NUM_MUL-1:0]          mac_stg0_vld_en;
logic [`NUM_MUL-1:0]          mac_stg0_data_en;
//Generate uop valid
// empty        0  |  0  |  1  |  1
// 1left2empty  0  |  1  |  0  |  1
// dataLeft     >1 |  1  | N/A |  0
assign rs2mac_uop_valid[0] = !rs2ex_fifo_empty && !trap_flush_rvv; //clear d0 when trap flush
assign rs2mac_uop_valid[1] = !(rs2ex_fifo_empty || rs2ex_fifo_1left_to_empty) && !trap_flush_rvv; //clear d0 when trap flush
assign rs2mac_uop_data[0] = rs2ex_uop_data[0];
assign rs2mac_uop_data[1] = rs2ex_uop_data[1];

// Inst of MUL-ex and MAC-ex
//MAC 0
rvv_backend_mac_unit u_mac0 (
  // Outputs
  .mac2rob_uop_valid(mac2rob_uop_valid[0]),
  .mac2rob_uop_data(mac2rob_uop_data[0]),
  // Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .rs2mac_uop_valid(rs2mac_uop_valid[0]), 
  .rs2mac_uop_data(rs2mac_uop_data[0]),
  .mac_stg0_vld_en (mac_stg0_vld_en[0]),
  .mac_stg0_data_en(mac_stg0_data_en[0]));

//MAC 1
rvv_backend_mac_unit u_mac1 (
  // Outputs
  .mac2rob_uop_valid(mac2rob_uop_valid[1]),
  .mac2rob_uop_data(mac2rob_uop_data[1]),
  // Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .rs2mac_uop_valid(rs2mac_uop_valid[1]), 
  .rs2mac_uop_data(rs2mac_uop_data[1]),
  .mac_stg0_vld_en (mac_stg0_vld_en[1]),
  .mac_stg0_data_en(mac_stg0_data_en[1]));

// Pop RS fifo generation
assign ex2rs_fifo_pop[0] = rs2mac_uop_valid[0] && mac2rs_uop_ready[0];
assign ex2rs_fifo_pop[1] = rs2mac_uop_valid[1] && mac2rs_uop_ready[1] && ex2rs_fifo_pop[0];//forbid pop1=1 while pop0=0

assign mac_stg0_data_en[0] = ex2rs_fifo_pop[0]; //generate stg_data_en for MAC0
assign mac_stg0_data_en[1] = ex2rs_fifo_pop[1]; //generate stg_data_en for MAC1

assign mac_stg0_vld_en[0] = ex2rs_fifo_pop[0] || mac2rob_uop_valid[0] && mac2rs_uop_ready[0]; //generate vld_en for MAC0 handshake
assign mac_stg0_vld_en[1] = ex2rs_fifo_pop[1] || mac2rob_uop_valid[1] && mac2rs_uop_ready[1]; //generate vld_en for MAC1 handshake

//Pack output to ROB
//high pack MAC 1; low pack MAC 0
assign ex2rob_valid[0] = mac2rob_uop_valid[0] && !trap_flush_rvv; //clear d1 when trap flush
assign ex2rob_data[0] = mac2rob_uop_data[0];
assign mac2rs_uop_ready[0] = !mac2rob_uop_valid[0] | rob2ex_ready[0];

assign ex2rob_valid[1] = mac2rob_uop_valid[1] && !trap_flush_rvv; //clear d1 when trap flush
assign ex2rob_data[1] = mac2rob_uop_data[1];
assign mac2rs_uop_ready[1] = !mac2rob_uop_valid[1] | rob2ex_ready[1];

endmodule
