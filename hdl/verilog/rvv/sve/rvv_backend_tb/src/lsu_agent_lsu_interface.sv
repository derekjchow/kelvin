`ifndef LSU_INTERFACE__SV
`define LSU_INTERFACE__SV

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"

interface lsu_interface (input bit clk, input bit rst_n);


// load/store unit interface
  // RVV send LSU uop to RVS
  logic             [`NUM_LSU-1:0]          uop_lsu_valid_rvv2lsu;
  UOP_RVV2LSU_t     [`NUM_LSU-1:0]          uop_lsu_rvv2lsu;
  logic             [`NUM_LSU-1:0]          uop_lsu_ready_lsu2rvv;
  // LSU feedback to RVV
  logic             [`NUM_LSU-1:0]          uop_lsu_valid_lsu2rvv;
  UOP_LSU2RVV_t     [`NUM_LSU-1:0]          uop_lsu_lsu2rvv;
  logic             [`NUM_LSU-1:0]          uop_lsu_ready_rvv2lsu;

// exception handler
  // trap signal handshake
  logic                           trap_valid_rvs2rvv;
  logic                           trap_ready_rvv2rvs;    
  logic             [31:0]        trap_pc;
  logic             [2:0]         trap_uop_index;

endinterface: lsu_interface

`endif // LSU_INTERFACE__SV
