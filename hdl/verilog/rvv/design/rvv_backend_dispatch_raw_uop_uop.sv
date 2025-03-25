// description:
// 1. the rvv_backend_dispatch_raw_uop_uop is a sub-module for rvv_backend_dispatch module
//    a. check RAW hazard between suc_uop and pre_uop(s)
//

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_DISPATCH__SVH
`include "rvv_backend_dispatch.svh"
`endif

module rvv_backend_dispatch_raw_uop_uop
(
    raw_uop_uop,
    suc_uop,
    pre_uop
);

// ---parameter definition--------------------------------------------
    parameter PREUOP_NUM = 1;

// ---port definition-------------------------------------------------
    output  RAW_UOP_UOP_t     raw_uop_uop;
    input   SUC_UOP_RAW_t     suc_uop;
    input   PRE_UOP_RAW_t [PREUOP_NUM-1:0]  pre_uop;

// ---internal signal definition--------------------------------------
    logic [PREUOP_NUM-1:0]    vs1_cmp;  // comparison result for vs1
    logic [PREUOP_NUM-1:0]    vs2_cmp;  // comparison result for vs2
    logic [PREUOP_NUM-1:0]    vd_cmp;   // comparison result for vd
    logic [PREUOP_NUM-1:0]    v0_cmp;   // comparison result for v0

    logic [PREUOP_NUM-1:0]    vs1_hit;  // set if the destination of pre_uop is the source of suc_uop
    logic [PREUOP_NUM-1:0]    vs2_hit;  
    logic [PREUOP_NUM-1:0]    vd_hit;   
    logic [PREUOP_NUM-1:0]    v0_hit;   

    logic  [PREUOP_NUM-1:0]   vs1_wait; // set if the destination of pre_uop is not valid when RAW occurs  
    logic  [PREUOP_NUM-1:0]   vs2_wait;  
    logic  [PREUOP_NUM-1:0]   vd_wait;   
    logic  [PREUOP_NUM-1:0]   v0_wait;   
// ---code start------------------------------------------------------
    genvar i;
    generate
        for (i=0; i<PREUOP_NUM; i++) begin : gen_compare_result
            assign vs1_cmp[i] = (suc_uop.vs1_index == pre_uop[i].w_index);
            assign vs2_cmp[i] = (suc_uop.vs2_index == pre_uop[i].w_index);
            assign vd_cmp[i]  = (suc_uop.vd_index  == pre_uop[i].w_index);
            assign v0_cmp[i]  = (`V0_INDEX         == pre_uop[i].w_index);
        end
    endgenerate

// conditions when RAW occurs: a & b & c
// a. compare result indicates src_index equal dst_index
// b. successor uop do need src vector register -> *_valid is asserted
// c. predecessor uop is a valid uop
    generate
        for (i=0; i<PREUOP_NUM; i++) begin : gen_hit_result
            assign vs1_hit[i] = vs1_cmp[i] & suc_uop.vs1_valid & pre_uop[i].valid & (pre_uop[i].w_type==VRF);
            assign vs2_hit[i] = vs2_cmp[i] & suc_uop.vs2_valid & pre_uop[i].valid & (pre_uop[i].w_type==VRF);
            assign vd_hit[i]  = vd_cmp[i]  & suc_uop.vs3_valid & pre_uop[i].valid & (pre_uop[i].w_type==VRF);
            assign v0_hit[i]  = v0_cmp[i]  & (~suc_uop.vm)     & pre_uop[i].valid & (pre_uop[i].w_type==VRF);
        end
    endgenerate

    generate
        for (i=0; i<PREUOP_NUM; i++) begin : gen_wait_result
            assign vs1_wait[i] = vs1_hit[i] & (~pre_uop[i].w_valid);
            assign vs2_wait[i] = vs2_hit[i] & (~pre_uop[i].w_valid);
            assign vd_wait[i]  = vd_hit[i]  & (~pre_uop[i].w_valid);
            assign v0_wait[i]  = v0_hit[i]  & (~pre_uop[i].w_valid);
        end
    endgenerate

// output result
    assign raw_uop_uop.vs1_wait = |vs1_wait;
    assign raw_uop_uop.vs2_wait = |vs2_wait;
    assign raw_uop_uop.vd_wait  = |vd_wait;
    assign raw_uop_uop.v0_wait  = |v0_wait;

endmodule
