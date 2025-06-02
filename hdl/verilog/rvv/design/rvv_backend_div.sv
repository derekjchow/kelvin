`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_div
( 
  clk,
  rst_n,
  pop_ex2rs,
  div_uop_rs2ex,
  fifo_empty_rs2ex,
  fifo_almost_empty_rs2ex,
  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2div,
  trap_flush_rvv
);

//
// interface signals
//
  // global signals
  input   logic     clk;
  input   logic     rst_n;

  // DIV RS to DIV unit
  input   DIV_RS_t  [`NUM_DIV-1:0]  div_uop_rs2ex;
  input   logic                     fifo_empty_rs2ex;
  input   logic     [`NUM_DIV-1:0]  fifo_almost_empty_rs2ex;
  output  logic     [`NUM_DIV-1:0]  pop_ex2rs;

  // submit DIV result to ROB
  output  logic     [`NUM_DIV-1:0]  result_valid_ex2rob;
  output  PU2ROB_t  [`NUM_DIV-1:0]  result_ex2rob;
  input   logic     [`NUM_DIV-1:0]  result_ready_rob2div;

  // trap-flush
  input   logic                     trap_flush_rvv;

//
// internal signals
//
  // DIV RS to DIV unit
  logic             [`NUM_DIV-1:0]  div_uop_valid_rs2ex;    
  
  // for-loop
  genvar                            i;

//
// Instantiate rvv_backend_div_unit
//
  // generate valid signals
  assign div_uop_valid_rs2ex[0] = !fifo_empty_rs2ex;

  generate
    for (i=1;i<`NUM_DIV;i=i+1) begin: GET_UOP_VALID
      assign  div_uop_valid_rs2ex[i] = !fifo_almost_empty_rs2ex[i];
    end
  endgenerate

  // generate pop signals
  assign pop_ex2rs[0] = div_uop_valid_rs2ex[0]&result_valid_ex2rob[0]&result_ready_rob2div[0];
    
  generate
    for (i=1;i<`NUM_DIV;i=i+1) begin: POP_DIV_RS
      assign pop_ex2rs[i] = div_uop_valid_rs2ex[i]&result_valid_ex2rob[i]&result_ready_rob2div[i]&(pop_ex2rs[i-1:0]=='1);
    end
  endgenerate

  // instantiate
  generate
    for (i=0;i<`NUM_DIV;i++) begin: DIV_UNIT
      rvv_backend_div_unit u_div_unit
        (
          .clk            (clk),
          .rst_n          (rst_n),
          .div_uop_valid  (div_uop_valid_rs2ex[i]),
          .div_uop        (div_uop_rs2ex[i]),
          .result_valid   (result_valid_ex2rob[i]),
          .result         (result_ex2rob[i]),
          .result_ready   (result_ready_rob2div[i]),
          .trap_flush_rvv (trap_flush_rvv)
        );
    end
  endgenerate

endmodule
