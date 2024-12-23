`ifndef VRF_INTERFACE__SV
`define VRF_INTERFACE__SV

`include "rvv_backend_define.svh"

interface vrf_interface (input bit clk, input bit rst_n);
  logic [31:0] [`VLEN-1:0] vreg ;

  logic [31:0] [`VLEN-1:0] vreg_init_data;

  logic [`NUM_RT_UOP-1:0]  rt_event;

endinterface: vrf_interface

`endif // VRF_INTERFACE__SV
