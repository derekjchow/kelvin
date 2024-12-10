// description: 
// 1. Instantiate rvv_backend_alu_unit and connect to ALU Reservation Station and ROB.
//
// feature list:
// 1. It will instantiate 2 rvv_backend_alu_unit.

`include "rvv_backend.svh"

module _alu
(
  pop0_ex2rs,
  pop1_ex2rs,
  alu_uop0_rs2ex,
  alu_uop1_rs2ex,
  fifo_empty_rs2ex,
  fifo_1left_to_empty_rs2ex,
  
  result0_valid_ex2rob,
  result0_ex2rob,
  result0_ready_rob2alu,
  result1_valid_ex2rob,
  result1_ex2rob,
  result1_ready_rob2alu
);

//
// interface signals
//
  // ALU RS to ALU unit
  output  logic             pop0_ex2rs;
  output  logic             pop1_ex2rs;
  input   ALU_RS_t          alu_uop0_rs2ex;
  input   ALU_RS_t          alu_uop1_rs2ex;
  input   logic             fifo_empty_rs2ex;
  input   logic             fifo_1left_to_empty_rs2ex;

  // submit ALU result to ROB
  output  logic             result0_valid_ex2rob;
  output  ALU2ROB_t         result0_ex2rob;
  input   logic             result0_ready_rob2alu;
  output  logic             result1_valid_ex2rob;
  output  ALU2ROB_t         result1_ex2rob;
  input   logic             result1_ready_rob2alu;

//
// internal signals
//
  // ALU RS to ALU unit
  logic                     alu_uop0_valid_rs2ex;                   
  logic                     alu_uop1_valid_rs2ex;                   

//
// Instantiate 2 rvv_backend_alu_unit
//
  // generate valid signals
  assign  alu_uop0_valid_rs2ex = !fifo_empty_rs2ex;
  assign  alu_uop1_valid_rs2ex = !(fifo_empty_rs2ex&fifo_1left_to_empty_rs2ex);
  
  // generate pop signals
  // it can pop alu_uop1 when it can also pop alu_uop0. Otherwise, it cannot pop alu_uop1.(That's in-ordered issue from RS) 
  assign  pop0_ex2rs = alu_uop0_valid_rs2ex&result0_valid_ex2rob&result0_ready_rob2alu;
  assign  pop1_ex2rs = pop0&(alu_uop1_valid_rs2ex&result1_valid_ex2rob&result1_ready_rob2alu);  

  // instantiate
  rvv_backend_alu_unit u_alu_unit0
  (
    // inputs
    .alu_uop_valid          (alu_uop0_valid_rs2ex),
    .alu_uop                (alu_uop0_rs2ex),
    // outputs
    .result_ex2rob_valid    (result0_valid_ex2rob),
    .result_ex2rob          (result0_ex2rob)
  );

  rvv_backend_alu_unit u_alu_unit1
  (
    // inputs
    .alu_uop_valid          (alu_uop1_valid_rs2ex),
    .alu_uop                (alu_uop1_rs2ex),
    // outputs
    .result_valid_ex2rob    (result1_valid_ex2rob),
    .result_ex2rob          (result1_ex2rob)
  );


`ifdef ASSERT_ON
  `rvv_forbid(alu_uop0_valid_rs2ex&(!result0_valid_ex2rob)) 
    else $error("rob_entry=%d. Something wrong in alu_unit0 decoding and execution.\n",alu_uop0_rs2ex.rob_entry);

  `rvv_forbid(alu_uop1_valid_rs2ex&(!result1_valid_ex2rob)) 
    else $error("rob_entry=%d. Something wrong in alu_unit1 decoding and execution.\n",alu_uop1_rs2ex.rob_entry);
`endif
endmodule
