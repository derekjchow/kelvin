`ifndef LSU_INTERFACE__SV
`define LSU_INTERFACE__SV

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"

interface lsu_interface (input bit clk, input bit rst_n);


// load/store unit interface
  // RVV send LSU uop to RVS
    logic             [`NUM_LSU-1:0]          uop_lsu_valid_rvv2rvs;
    LSU_RS_t          [`NUM_LSU-1:0]          uop_lsu_rvv2rvs;
    logic             [`NUM_LSU-1:0]          uop_lsu_ready_rvs2rvv;
  // LSU feedback to RVV
    logic             [`NUM_LSU-1:0]          uop_lsu_valid_rvs2rvv;
    UOP_LSU_RVS2RVV_t [`NUM_LSU-1:0]          uop_lsu_rvs2rvv;
    logic             [`NUM_LSU-1:0]          uop_lsu_ready_rvv2rvs;

endinterface: lsu_interface

`endif // LSU_INTERFACE__SV
