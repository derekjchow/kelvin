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

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_pmtrdt
(
  clk,
  rst_n,

  pop_ex2rs,
  pmtrdt_uop_rs2ex,
  fifo_empty_rs2ex,
  fifo_almost_empty_rs2ex,
  all_uop_data,
  all_uop_cnt,

  result_valid_ex2rob,
  result_ex2rob,
  result_ready_rob2ex,

  trap_flush_rvv
);
// ---port definition-------------------------------------------------
// global signal
  input   logic           clk;
  input   logic           rst_n;

// PMTRDT RS to PMTRDT unit
  output  logic        [`NUM_PMTRDT-1:0]  pop_ex2rs;
  input   PMT_RDT_RS_t [`NUM_PMTRDT-1:0]  pmtrdt_uop_rs2ex;
  input   logic                           fifo_empty_rs2ex;
  input   logic        [`NUM_PMTRDT-1:0]  fifo_almost_empty_rs2ex;
  input   PMT_RDT_RS_t [`PMTRDT_RS_DEPTH-1:0] all_uop_data;
  input   logic        [$clog2(`PMTRDT_RS_DEPTH):0] all_uop_cnt;

// PMTRDT unit to ROB
  output  logic        [`NUM_PMTRDT-1:0]  result_valid_ex2rob;
  output  PU2ROB_t     [`NUM_PMTRDT-1:0]  result_ex2rob;
  input   logic        [`NUM_PMTRDT-1:0]  result_ready_rob2ex;

// trap-flush
  input   logic                           trap_flush_rvv;

// ---internal signal definition--------------------------------------
  logic         [`NUM_PMTRDT-1:0] pmtrdt_uop_valid;
  PMT_RDT_RS_t  [`NUM_PMTRDT-1:0] pmtrdt_uop;
  logic         [`NUM_PMTRDT-1:0] pmtrdt_uop_ready;

  logic         [`NUM_PMTRDT-1:0] pmtrdt_res_valid;
  PU2ROB_t      [`NUM_PMTRDT-1:0] pmtrdt_res;
  logic         [`NUM_PMTRDT-1:0] pmtrdt_res_ready;

  genvar i;
// ---code start------------------------------------------------------
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
        rvv_backend_pmtrdt_unit #(
          .GEN_RDT      (1'b1),
          .GEN_CMP      (1'b1),
          .GEN_PMT      (1'b1)
        ) u_pmtrdt_unit0 (
          .clk                (clk),
          .rst_n              (rst_n),
          .pmtrdt_uop_valid   (pmtrdt_uop_valid[i]),
          .pmtrdt_uop         (pmtrdt_uop[i]),
          .pmtrdt_uop_ready   (pmtrdt_uop_ready[i]),
          .pmtrdt_res_valid   (pmtrdt_res_valid[i]),
          .pmtrdt_res         (pmtrdt_res[i]),
          .pmtrdt_res_ready   (pmtrdt_res_ready[i]),
          .uop_data           (all_uop_data),
          .uop_cnt            (all_uop_cnt),
          .trap_flush_rvv     (trap_flush_rvv)
        );
    end
  endgenerate

endmodule
