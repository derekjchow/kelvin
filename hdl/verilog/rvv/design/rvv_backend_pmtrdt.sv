// description
// 1. the module is responsible for 3 kinds of vector instructions.
//    a. compare instruction.
//    b. reduction instruction.
//    c. permutation instruction.
//
// feature list:
// 1. pmtrdt unit[0] can support compare/reduction/compress intructions
//    a. compress instruction is a specified instruction in permutation.
//    b. vd EMUL for compare/reduction instruction is always 1.
// 2. the latency of the module is 2-cycle for each uop.

`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_pmtrdt
(
  clk,
  rst_n,

  pop_ex2rs,
  pmtrdt_uop_rs2ex,
  fifo_empty_rs2ex,
  fifo_almost_empty_rs2ex,
  all_uop_data,

  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2ex
);
// ---port definition-------------------------------------------------
// global signal
  input   logic           clk;
  input   logic           rst_n;

// PMTRDT RS to PMTRDT unit
  output  logic        [`NUM_PMTRDT-1:0]  pop_ex2rs;
  input   PMT_RDT_RS_t [`NUM_PMTRDT-1:0]  pmtrdt_uop_rs2ex;
  input   logic                           fifo_empty_rs2ex;
  input   logic        [`NUM_PMTRDT-1:1]  fifo_almost_empty_rs2ex;
  input   PMT_RDT_RS_t [`PMTRDT_RS_DEPTH-1:0] all_uop_data;

// PMTRDT unit to ROB
  output  logic        [`NUM_PMTRDT-1:0]  result_valid_ex2rob;
  output  PU2ROB_t     [`NUM_PMTRDT-1:0]  result_ex2rob;
  input   logic        [`NUM_PMTRDT-1:0]  result_ready_rob2ex;

// ---internal signal definition--------------------------------------
  logic         [`NUM_PMTRDT-1:0] pmtrdt_uop_valid;
  PMT_RDT_RS_t  [`NUM_PMTRDT-1:0] pmtrdt_uop;
  logic         [`NUM_PMTRDT-1:0] pmtrdt_uop_ready;

  logic         [`NUM_PMTRDT-1:0] pmtrdt_res_valid;
  PU2ROB_t      [`NUM_PMTRDT-1:0] pmtrdt_res;
  logic         [`NUM_PMTRDT-1:0] pmtrdt_res_ready;

  genvar i;
// ---code start------------------------------------------------------
// compress instruction is a specified instruction in PMT.
// the vl of vd in compress can not be acknowledged untill decode vs1 value.
// in order to simplify design, the compress instruciton can only executed in pmtrdt_unit0.
//TODO

  generate
    for (i=0; i<`NUM_PMTRDT; i++) begin
      assign pmtrdt_uop[i] = pmtrdt_uop_rs2ex[i];
      if (i==0)
        assign pmtrdt_uop_valid[0] = ~fifo_empty_rs2ex;
      else
        assign pmtrdt_uop_valid[i] = ~fifo_almost_empty_rs2ex[i];
      assign pop_ex2rs[i] = pmtrdt_uop_valid[i] & pmtrdt_uop_ready[i];

      assign result_valid_ex2rob[i] = pmtrdt_res_valid[i];
      assign result_ex2rob[i]       = pmtrdt_res[i];
      assign pmtrdt_res_ready[i]    = result_ready_rob2ex[i]; 
    end
  endgenerate

// instance the pmtrdt unit
  generate
    for (i=0; i<`NUM_PMTRDT; i++) begin : gen_pmtrdt_unit
      if (i==0)
        rvv_backend_pmtrdt_unit #(
          .RDT_CMP      (1'b1),
          .COMPRESS     (1'b1)
        ) u_pmtrdt_unit0 (
          .clk                (clk),
          .rst_n              (rst_n),
          .pmtrdt_uop_valid   (pmtrdt_uop_valid[0]),
          .pmtrdt_uop         (pmtrdt_uop[0]),
          .pmtrdt_uop_ready   (pmtrdt_uop_ready[0]),
          .pmtrdt_res_valid   (pmtrdt_res_valid[0]),
          .pmtrdt_res         (pmtrdt_res[0]),
          .pmtrdt_res_ready   (pmtrdt_res_ready[0]),
          .uop_data           (all_uop_data)
        );
      else
        rvv_backend_pmtrdt_unit #(
        ) u_pmtrdt_unit (
          .clk                (clk),
          .rst_n              (rst_n),
          .pmtrdt_uop_valid   (pmtrdt_uop_valid[i]),
          .pmtrdt_uop         (pmtrdt_uop[i]),
          .pmtrdt_uop_ready   (pmtrdt_uop_ready[i]),
          .pmtrdt_res_valid   (pmtrdt_res_valid[i]),
          .pmtrdt_res         (pmtrdt_res[i]),
          .pmtrdt_res_ready   (pmtrdt_res_ready[i]),
          .uop_data           (all_uop_data)
        );
    end
  endgenerate

endmodule
