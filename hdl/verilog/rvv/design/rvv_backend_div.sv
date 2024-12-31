
`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_div
( 
  clk,
  rst_n,
  pop_ex2rs,
  div_uop_rs2ex,
  fifo_empty_rs2ex,
`ifdef MULTI_DIV
  fifo_almost_empty_rs2ex,
`endif
  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2div
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
`ifdef MULTI_DIV
  input   logic     [`NUM_DIV-1:1]  fifo_almost_empty_rs2ex;
`endif
  output  logic     [`NUM_DIV-1:0]  pop_ex2rs;

  // submit DIV result to ROB
  output  logic     [`NUM_DIV-1:0]  result_valid_ex2rob;
  output  PU2ROB_t  [`NUM_DIV-1:0]  result_ex2rob;
  input   logic     [`NUM_DIV-1:0]  result_ready_rob2div;

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

`ifdef MULTI_DIV
  generate
    for (i=1;i<`NUM_DIV;i=i+1) begin: GET_UOP_VALID
      assign  div_uop_valid_rs2ex[i] = !( fifo_empty_rs2ex || (|fifo_almost_empty_rs2ex[i:1]));
    end
  endgenerate
`endif

  // generate pop signals
  assign pop_ex2rs[0] = div_uop_valid_rs2ex[0]&result_valid_ex2rob[0]&result_ready_rob2div[0];
    
`ifdef MULTI_DIV
  generate
    for (i=1;i<`NUM_DIV;i=i+1) begin: POP_DIV_RS
      assign pop_ex2rs[i] = div_uop_valid_rs2ex[i]&result_valid_ex2rob[i]&result_ready_rob2div[i]&(pop_ex2rs[i-1:0]=='1);
    end
  endgenerate
`endif

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
          .result_ready   (result_ready_rob2div[i])
        );
    end
  endgenerate

`ifdef ASSERT_ON
  `rvv_forbid(div_uop_valid_rs2ex[0]&(!result_valid_ex2rob[0])) 
    else $error("rob_entry=%d. Something wrong in alu_unit0 decoding and execution.\n",div_uop_rs2ex[0].rob_entry);
`endif

endmodule
