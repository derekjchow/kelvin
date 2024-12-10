// description: 
// 1. Instantiate ALU reservation station. 
//
// feature list:
// 1. ALU reservation station is 2 write and 2 read ports of SFIFO.

`include "rvv_backend.svh"

module rvv_backend_alu_rs
(
  clk,
  rst_n,

  push_dp2rs,
  alu_uop_dprs,
  pop_ex2rs,

  alu_uop_rs2ex,
  fifo_full_rs2dp,
  fifo_1left_to_full_rs2dp, 
  fifo_halffull_rs2dp,
  fifo_empty_rs2ex,
  fifo_1left_to_empty_rs2ex
);

//
// interface signals
//
  // global signals
  input logic                           clk;
  input logic                           rst_n;

  // Dispatch to ALU RS
  input   logic     [`NUM_ALU_UOP-1:0]  push_dp2rs;
  input   ALU_RS_t  [`NUM_ALU_UOP-1:0]  alu_uop_dp2rs;
  input   logic     [`NUM_ALU_UOP-1:0]  pop_ex2rs;

  output  ALU_RS_t  [`NUM_ALU_UOP-1:0]  alu_uop_rs2ex;
  output  logic                         fifo_full_rs2dp;           
  output  logic                         fifo_1left_to_full_rs2dp; 
  output  logic                         fifo_halffull_rs2dp;     
  output  logic                         fifo_empty_rs2ex;
  output  logic                         fifo_1left_to_empty_rs2ex;

//
// Instantiate ALU reservation station
//
fifo_flopped_2w2r
#(
  .DWIDTH                   (`ALU_RS_WIDTH)
)
rs_alu
(
   // Inputs
   clk                      (clk), 
   rst_n                    (rst_n), 
   push0                    (push_dp2rs[0]),
   inData0                  (alu_uop_dp2rs[0]), 
   pop0                     (pop_ex2rs[0]), 
   push1                    (push_dp2rs[1]), 
   inData1                  (alu_uop_dp2rs[1]), 
   pop1                     (pop_ex2rs[1]),
   // Outputs
   outData0                 (alu_uop_rs2ex[0]), 
   outData1                 (alu_uop_rs2ex[1]), 
   fifo_halfFull            (fifo_halffull_rs2dp),  
   fifo_full                (fifo_full_rs2dp), 
   fifo_1left_to_full       (fifo_1left_to_full_rs2dp),
   fifo_empty               (fifo_empty_rs2ex), 
   fifo_1left_to_empty      (fifo_1left_to_empty_rs2ex) 
   //fifo_idle                ()
);


endmodule
