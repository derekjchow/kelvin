// description: 
// 1. Instantiate rvv_backend_alu_unit and connect to ALU Reservation Station and ROB.
//
// feature list:
// 1. The number of ALU units (`NUM_ALU) is configurable.
// 2. The size of vector length (`VLEN) is configurable.

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_alu
(
  clk,
  rst_n,
  pop_ex2rs,
  alu_uop_rs2ex,
  fifo_empty_rs2ex,
  fifo_almost_empty_rs2ex,
  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2alu,
  trap_flush_rvv
);

//
// interface signals
//
  // global signal
  input   logic                         clk;
  input   logic                         rst_n;

  // ALU RS to ALU unit
  output  logic       [`NUM_ALU-1:0]    pop_ex2rs;
  input   ALU_RS_t    [`NUM_ALU-1:0]    alu_uop_rs2ex;
  input   logic                         fifo_empty_rs2ex;
  input   logic       [`NUM_ALU-1:0]    fifo_almost_empty_rs2ex;

  // submit ALU result to ROB
  output  logic       [`NUM_ALU-1:0]    result_valid_ex2rob;
  output  PU2ROB_t    [`NUM_ALU-1:0]    result_ex2rob;
  input   logic       [`NUM_ALU-1:0]    result_ready_rob2alu;

  // trap-flush
  input   logic                         trap_flush_rvv;

//
// internal signals
//
  // ALU RS to ALU unit
  logic               [`NUM_ALU-1:0]    alu_uop_valid_rs2ex;    
  logic               [`NUM_ALU-1:0]    pop_valid;
  logic               [`NUM_ALU-1:0]    result_valid_ex;
  
  // for-loop
  genvar                                i;

//
// Instantiate 2 rvv_backend_alu_unit
//
  // generate valid signals
  assign alu_uop_valid_rs2ex[0] = !fifo_empty_rs2ex;

  generate 
    for (i=1;i<`NUM_ALU;i=i+1) begin: GET_UOP_VALID
      assign  alu_uop_valid_rs2ex[i] = !fifo_almost_empty_rs2ex[i];
    end
  endgenerate

  // instantiate
  generate
    for (i=0;i<`NUM_ALU;i=i+1) begin: ALU_UNIT
      rvv_backend_alu_unit u_alu_unit
        (
          // inputs
          .clk            (clk),
          .rst_n          (rst_n),
          .alu_uop_valid  (alu_uop_valid_rs2ex[i]),
          .alu_uop        (alu_uop_rs2ex[i]),
          .result_ready   (result_ready_rob2alu[i]),
          // outputs
          .pop_rs         (pop_valid[i]),
          .result_valid   (result_valid_ex[i]),
          .result         (result_ex2rob[i]),
          // trap-flush
          .trap_flush_rvv (trap_flush_rvv)
        );
    end
  endgenerate

  // generate pop signals
  assign pop_ex2rs[0] = pop_valid[0]&result_ready_rob2alu[0];
  
  generate
    for (i=1;i<`NUM_ALU;i=i+1) begin: POP_ALU_RS
      assign pop_ex2rs[i] = pop_valid[i]&result_ready_rob2alu[i]&(&pop_valid[i-1:0]);
    end
  endgenerate

  assign result_valid_ex2rob = result_valid_ex;

endmodule
