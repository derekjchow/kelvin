`ifndef VRF_INTERFACE__SV
`define VRF_INTERFACE__SV

`include "rvv_backend_define.svh"

interface vrf_interface (input bit clk, input bit rst_n);
  logic [31:0] [`VLEN-1:0] vreg ;

  logic [31:0] [`VLEN-1:0] vrf_wr_wenb_full;
  logic [31:0] [`VLEN-1:0] vrf_wr_data_full;
  logic [31:0] [`VLEN-1:0] vrf_rd_data_full;


  logic [`NUM_RT_UOP-1:0]  rt_uop;
  logic [`NUM_RT_UOP-1:0]  rt_last_uop;

  task set_dut_vrf(input int reg_idx, input logic[`VLEN-1:0] value);
    `VRF_PATH.vrf_wr_wen_full[reg_idx] = '1;
    `VRF_PATH.vrf_wr_data_full[reg_idx] = value;
    @(posedge clk);
    `VRF_PATH.vrf_wr_wen_full[reg_idx] = '0;
    @(posedge clk);
  endtask: set_dut_vrf

  function logic[`VLEN-1:0] get_dut_vrf(input int reg_idx);
    get_dut_vrf = `VRF_PATH.vrf_rd_data_full[reg_idx];
  endfunction: get_dut_vrf

endinterface: vrf_interface

`endif // VRF_INTERFACE__SV
