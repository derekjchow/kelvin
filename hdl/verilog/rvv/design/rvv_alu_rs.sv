// description: 
// 1. Instantiate ALU reservation station. 
//
// feature list:
// 1. ALU reservation station is 2 write and 2 read ports of SFIFO.

`include 'rvv.svh'

module rvv_alu_rs
(
  clk,
  rst_n,

  push0_dp2rs,
  alu_uop0_dprs,
  pop0_ex2rs,
  push1_dp2rs,
  alu_uop1_dp2rs,
  pop1_ex2rs,

  alu_uop0_rs2ex,
  alu_uop1_rs2ex,
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
  input logic             clk;
  input logic             rst_n;

  // Dispatch to ALU RS
  input   logic           push0_dp2rs;
  input   ALU_RS_t        alu_uop0_dp2rs;
  input   logic           pop0_ex2rs;
  input   logic           push1_dp2rs;
  input   ALU_RS_t        alu_uop1_dp2rs;
  input   logic           pop1_ex2rs;

  output  ALU_RS_t        alu_uop0_rs2ex;
  output  ALU_RS_t        alu_uop1_rs2ex;
  output  logic           fifo_full_rs2dp;           
  output  logic           fifo_1left_to_full_rs2dp; 
  output  logic           fifo_halffull_rs2dp;     
  output  logic           fifo_empty_rs2ex;
  output  logic           fifo_1left_to_empty_rs2ex;

//
// Instantiate ALU reservation station
//
fifo_flopped_2w2r
#(
  .DWIDTH                   (`ALU_RS_WIDTH)
)(
   // Inputs
   clk                      (clk), 
   rst_n                    (rst_n), 
   push0                    (push0_dp2rs),
   inData0                  (alu_uop0_dp2rs), 
   push1                    (push1_dp2rs), 
   inData1                  (alu_uop1_dp2rs), 
   pop0                     (pop0_ex2rs), 
   pop1                     (pop1_ex2rs),
   // Outputs
   outData0                 (alu_uop0_rs2ex), 
   outData1                 (alu_uop1_rs2ex), 
   fifo_halfFull            (fifo_halffull_rs2dp),  
   fifo_full                (fifo_full_rs2dp), 
   fifo_1left_to_full       (fifo_1left_to_full_rs2dp),
   fifo_empty               (fifo_empty_rs2ex), 
   fifo_1left_to_empty      (fifo_1left_to_empty_rs2ex) 
   //fifo_idle                ()
);


endmodule
