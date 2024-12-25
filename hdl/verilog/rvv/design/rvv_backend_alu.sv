// description: 
// 1. Instantiate rvv_backend_alu_unit and connect to ALU Reservation Station and ROB.
//
// feature list:
// 1. The number of ALU units (`NUM_ALU) is configurable.
// 2. The size of vector length (`VLEN) is configurable.
// 3. Addsub unit for add and sub instructions reuses and combines the results of 8-bit adders to get 8,16,32-bit result. And sub instructions will reuse adder logic.
// 4. Shift unit for shift instructions reuse arithmetic right shift to complete arithmetic and logic right shift.
// 5. Mask unit can reuse logical operation for mask logical and regular logical instructions. And Mask unit can reuse find_first_1 logic for other mask instructions.

`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_alu
(
  pop_ex2rs,
  alu_uop_rs2ex,
  fifo_empty_rs2ex,
`ifdef MULTI_ALU
  fifo_almost_empty_rs2ex,
`endif
  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2alu
);

//
// interface signals
//
  // ALU RS to ALU unit
  output  logic       [`NUM_ALU-1:0]    pop_ex2rs;
  input   ALU_RS_t    [`NUM_ALU-1:0]    alu_uop_rs2ex;
  input   logic                         fifo_empty_rs2ex;
`ifdef MULTI_ALU
  input   logic       [`NUM_ALU-1:1]    fifo_almost_empty_rs2ex;
`endif

  // submit ALU result to ROB
  output  logic       [`NUM_ALU-1:0]    result_valid_ex2rob;
  output  PU2ROB_t    [`NUM_ALU-1:0]    result_ex2rob;
  input   logic       [`NUM_ALU-1:0]    result_ready_rob2alu;

//
// internal signals
//
  // ALU RS to ALU unit
  logic               [`NUM_ALU-1:0]    alu_uop_valid_rs2ex;    
  
  // for-loop
  genvar                                i;

//
// Instantiate 2 rvv_backend_alu_unit
//
  // generate valid signals
  assign alu_uop_valid_rs2ex[0] = !fifo_empty_rs2ex;

`ifdef MULTI_ALU
  generate 
    for (i=1;i<`NUM_ALU;i=i+1) begin: GET_UOP_VALID
      assign  alu_uop_valid_rs2ex[i] = !( fifo_empty_rs2ex || (|fifo_almost_empty_rs2ex[i:1]));
    end
  endgenerate
`endif
  
  // generate pop signals
  assign pop_ex2rs[0] = alu_uop_valid_rs2ex[0]&result_valid_ex2rob[0]&result_ready_rob2alu[0];

`ifdef MULTI_ALU
  generate
    for (i=1;i<`NUM_ALU;i=i+1) begin: POP_ALU_RS
      assign  pop_ex2rs[i] = alu_uop_valid_rs2ex[i]&result_valid_ex2rob[i]&result_ready_rob2alu[i]&(pop_ex2rs[i-1:0]=='1);
    end
  endgenerate
`endif

  // instantiate
  generate
    for (i=0;i<`NUM_ALU;i=i+1) begin: ALU_UNIT
      rvv_backend_alu_unit u_alu_unit
        (
          // inputs
          .alu_uop_valid          (alu_uop_valid_rs2ex[i]),
          .alu_uop                (alu_uop_rs2ex[i]),
          // outputs
          .result_valid           (result_valid_ex2rob[i]),
          .result                 (result_ex2rob[i])
        );
    end
  endgenerate

`ifdef ASSERT_ON
  `rvv_forbid(alu_uop_valid_rs2ex[0]&(!result_valid_ex2rob[0])) 
    else $error("rob_entry=%d. Something wrong in alu_unit0 decoding and execution.\n",alu_uop_rs2ex[0].rob_entry);

  `rvv_forbid(alu_uop_valid_rs2ex[1]&(!result_valid_ex2rob[1])) 
    else $error("rob_entry=%d. Something wrong in alu_unit1 decoding and execution.\n",alu_uop_rs2ex[1].rob_entry);
`endif

endmodule
