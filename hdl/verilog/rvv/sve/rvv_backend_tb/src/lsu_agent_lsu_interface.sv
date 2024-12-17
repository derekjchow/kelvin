`ifndef LSU_INTERFACE__SV
`define LSU_INTERFACE__SV

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"

interface lsu_interface (input bit clk, input bit rst_n);


// load/store unit interface
  // RVV send LSU uop to RVS
  logic              [`NUM_DP_UOP-1:0] uop_valid_lsu_rvv2rvs;
  UOP_LSU_RVV2RVS_t  [`NUM_DP_UOP-1:0] uop_lsu_rvv2rvs      ;
  logic              [`NUM_DP_UOP-1:0] uop_ready_lsu_rvs2rvv;
  // LSU feedback to RVV                                       
  logic              [`NUM_DP_UOP-1:0] uop_valid_lsu_rvs2rvv;
  UOP_LSU_RVS2RVV_t  [`NUM_DP_UOP-1:0] uop_lsu_rvs2rvv      ;
  logic              [`NUM_DP_UOP-1:0] uop_ready_rvv2rvs    ;

endinterface: lsu_interface

`endif // LSU_INTERFACE__SV
