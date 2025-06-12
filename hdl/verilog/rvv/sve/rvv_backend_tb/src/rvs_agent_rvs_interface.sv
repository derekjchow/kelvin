`ifndef RVS_INTERFACE__SV
`define RVS_INTERFACE__SV

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"

interface rvs_interface (input bit clk, ref logic rst_n);

// vector instruction and scalar operand . 
  logic         [`ISSUE_LANE-1:0] insts_valid_rvs2cq;
  RVVCmd        [`ISSUE_LANE-1:0] insts_rvs2cq      ;
  logic         [`ISSUE_LANE-1:0] insts_ready_cq2rvs;  

// ROB dataout
  logic        [`NUM_RT_UOP-1:0]  rd_valid_rob2rt ;
  ROB2RT_t     [`NUM_RT_UOP-1:0]  rd_rob2rt       ;
  logic        [`NUM_RT_UOP-1:0]  rd_ready_rt2rob ;

// write back to VRF. These are internal signals after WAW-merge of RVV.
  RT2VRF_t      [`NUM_RT_UOP-1:0] rt_vrf_data_rob2rt ;
  logic         [`NUM_RT_UOP-1:0] rt_vrf_valid_rob2rt;

// write back to XRF. RVS arbitrates write ports of XRF by itself.
  RT2XRF_t      [`NUM_RT_UOP-1:0] rt_xrf_rvv2rvs      ;
  logic         [`NUM_RT_UOP-1:0] rt_xrf_valid_rvv2rvs;
  logic         [`NUM_RT_UOP-1:0] rt_xrf_ready_rvs2rvv;

// RT to VCSR.vxsat
  logic   [`NUM_RT_UOP-1:0]                         wr_vxsat_valid; // for each uops
  logic   [`NUM_RT_UOP-1:0] [`VCSR_VXSAT_WIDTH-1:0] wr_vxsat;       // for each uops
  logic                                             wr_vxsat_ready; // for all uops

// exception handler
  // the vcsr of last retired uop in last cycle
  logic                           vcsr_valid;
  RVVConfigState                  vector_csr;
  logic                           vcsr_ready;

// write back event (for each instruction)
  logic         [`NUM_RT_UOP-1:0] rt_uop;
  logic         [`NUM_RT_UOP-1:0] rt_last_uop;

// decode result of inst
  logic         [`NUM_DE_INST-1:0] inst_correct;
  logic         [`NUM_DE_INST-1:0] inst_discard;

// rvv idle
  logic         rvv_idle;
endinterface: rvs_interface

`endif // RVS_INTERFACE__SV
