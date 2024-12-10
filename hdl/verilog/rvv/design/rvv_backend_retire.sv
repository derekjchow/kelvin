/*
description: 
1. It will get retired uops from ROB, and write the results back to VRF/XRF and trap handle.

feature list:
1. When write back to VRF, if it find vector WAW, it will merge the vma and vta policy on the corresponding elements
   between the latter uop and the former uop.
2. When write back to VRF, it will check tma vma policy to enable byte write strobe.
3. There are 4 write ports for VRF, 4 write ports for XRF. RVS arbitrates write ports of XRF by itself.
4. It will store the VCSR value of last written uop in every cycle to help trap handler.
*/

`include "rvv.svh"

module rvv_writeback
(
    clk,
    rstn,
    rd_valid_rob2wb,
    rd_rob2wb,
    rd_ready_rob2wb,
    wb_xrf_valid_wb2rvs,
    wb_xrf_wb2rvs,
    wb_xrf_ready_wb2rvs,
    wb_vrf_valid_wb2vrf,
    wb_vrf_wb2vrf,
    wb_vrf_ready_wb2vrf,
    vxsat_valid,
    vxsat,
    trap_apply_rvs2rvv,
    trap_ready_rvv2rvs,
    vcsr_valid,
    vector_csr,
    stop_cmdq_wb2if,
    flush_cmdq_wb2if,
    flush_uopsq_wb2de
);  
// global signal
    input   logic                       clk;
    input   logic                       rstn;

// ROB dataout  
    input   logic                       rd_valid_rob2wb[`NUM_ROB_RD-1:0];
    input   ROB_WB_t                    rd_rob2wb[`NUM_ROB_RD-1:0];
    output  logic                       rd_ready_rob2wb[`NUM_ROB_RD-1:0];

// write back to XRF    
    output  logic                       wb_xrf_valid_wb2rvs[`NUM_WB_UOP-1:0];
    output  WB_XRF_t                    wb_xrf_wb2rvs[`NUM_WB_UOP-1:0];
    input   logic                       wb_xrf_ready_wb2rvs[`NUM_WB_UOP-1:0];

// write back to VRF    
    output  logic                       wb_vrf_valid_wb2vrf[`NUM_WB_UOP-1:0];
    output  WB_VRF_t                    wb_vrf_wb2vrf[`NUM_WB_UOP-1:0];
    input   logic                       wb_vrf_ready_wb2vrf[`NUM_WB_UOP-1:0];

// vxsat
    output  logic                       vxsat_valid;
    output  logic   [`VCSR_VXSAT-1:0]   vxsat;  
    
// exception handler
    // trap signal handshake
    input   TRAP_t                      trap_apply_rvs2rvv;
    output  logic                       trap_ready_rvv2rvs;    
    // the vcsr of last retired uop in last cycle
    output  logic                       vcsr_valid;
    output  VECTOR_CSR_t                vector_csr;
    // when trap occurs, it will stop CQ to receive new instructions
    output  logic                       stop_cmdq_wb2if;
    // flush cmdq and uopsq when trap_apply_rvs2rvv.trap_info is LSU.
    output  logic                       flush_cmdq_wb2if;           // If RVS find some illegal instructions when complete LSU transaction, like bus error,
    output  logic                       flush_uopsq_wb2de;          // it means a trap occurs to the instruction that is executing in RVV.
                                                                    // So RVV will top CQ to receive new instructions and flush Command Queue and Uops Queue, 
                                                                    // and complete the instructions in EX, ME and WB stage. And RVS need to send rob_entry of that exception instruction.
                                                                    // After RVV retire all uops before that exception instruction, RVV response a ready signal for trap application.      

endmodule