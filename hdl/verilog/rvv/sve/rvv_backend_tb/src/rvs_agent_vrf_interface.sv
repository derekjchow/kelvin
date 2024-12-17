`ifndef VRF_INTERFACE__SV
`define VRF_INTERFACE__SV

`include "rvv_backend_define.svh"

interface vrf_interface (input bit clk, input bit rst_n);
  logic [`VLEN-1:0] vreg [31:0];

endinterface: vrf_interface

`endif // VRF_INTERFACE__SV
