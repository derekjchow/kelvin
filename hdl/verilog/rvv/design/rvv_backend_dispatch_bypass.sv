// description:
// 1. the rvv_backend_dispatch_bypass is a sub-module for rvv_backend_dispatch module
//    a. select source operand(s) for uop(s) from ROB and VRF.

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_DISPATCH__SVH
`include "rvv_backend_dispatch.svh"
`endif

module rvv_backend_dispatch_bypass
(
    uop_operand,
    rob_byp,
    vrf_byp,
    raw_uop_rob
);
// ---port definition-------------------------------------------------
    output UOP_OPN_t                  uop_operand;
    input  ROB_BYP_t [`ROB_DEPTH-1:0] rob_byp;
    input  UOP_OPN_t                  vrf_byp;
    input  RAW_UOP_ROB_t              raw_uop_rob;

// ---internal signal definition--------------------------------------
    logic [`ROB_DEPTH-1:0][`VLENB-1:0] vs1_sel; // one-hot code
    logic [`ROB_DEPTH-1:0][`VLENB-1:0] vs2_sel; // one-hot code
    logic [`ROB_DEPTH-1:0][`VLENB-1:0] vd_sel;  // one-hot code
    logic [`ROB_DEPTH-1:0][`VLENB-1:0] v0_sel;  // one-hot code
    logic [`ROB_DEPTH-1:0][`VLENB-1:0] agnostic; // one-hot code

// ---code start------------------------------------------------------
    genvar i,j;
    generate
        for (i=0; i<`ROB_DEPTH; i++) begin : gen_data_sel
            for (j=0; j<`VLENB; j++) begin
                assign vs1_sel[i][j]  = (raw_uop_rob.vs1_hit[i] == 1'b1) & 
                                        (rob_byp[i].byte_type[j] == BODY_ACTIVE |
                                         rob_byp[i].byte_type[j] == BODY_INACTIVE & rob_byp[i].inactive_one |
                                         rob_byp[i].byte_type[j] == TAIL & rob_byp[i].tail_one);

                assign vs2_sel[i][j]  = (raw_uop_rob.vs2_hit[i] == 1'b1) & 
                                        (rob_byp[i].byte_type[j] == BODY_ACTIVE |
                                         rob_byp[i].byte_type[j] == BODY_INACTIVE & rob_byp[i].inactive_one |
                                         rob_byp[i].byte_type[j] == TAIL & rob_byp[i].tail_one);

                assign vd_sel[i][j]   = (raw_uop_rob.vd_hit[i] == 1'b1) & 
                                        (rob_byp[i].byte_type[j] == BODY_ACTIVE |
                                         rob_byp[i].byte_type[j] == BODY_INACTIVE & rob_byp[i].inactive_one |
                                         rob_byp[i].byte_type[j] == TAIL & rob_byp[i].tail_one);

                assign v0_sel[i][j]   = (raw_uop_rob.v0_hit[i] == 1'b1) & 
                                        (rob_byp[i].byte_type[j] == BODY_ACTIVE |
                                         rob_byp[i].byte_type[j] == BODY_INACTIVE & rob_byp[i].inactive_one |
                                         rob_byp[i].byte_type[j] == TAIL & rob_byp[i].tail_one);

                assign agnostic[i][j] = (rob_byp[i].byte_type[j] == BODY_INACTIVE & rob_byp[i].inactive_one |
                                        rob_byp[i].byte_type[j] == TAIL & rob_byp[i].tail_one);
            end
        end
        for (j=0; j<`VLENB; j++) begin : gen_vs1_data
          // Suppose ROB Depth is 8.
          // Please update the logic if ROB Depth is NOT 8.
            always_comb begin
                priority case (1'b1)
                    vs1_sel[7][j]: uop_operand.vs1[8*j+:8] = agnostic[7][j] ? 8'hFF : rob_byp[7].w_data[8*j+:8];
                    vs1_sel[6][j]: uop_operand.vs1[8*j+:8] = agnostic[6][j] ? 8'hFF : rob_byp[6].w_data[8*j+:8];
                    vs1_sel[5][j]: uop_operand.vs1[8*j+:8] = agnostic[5][j] ? 8'hFF : rob_byp[5].w_data[8*j+:8];
                    vs1_sel[4][j]: uop_operand.vs1[8*j+:8] = agnostic[4][j] ? 8'hFF : rob_byp[4].w_data[8*j+:8];
                    vs1_sel[3][j]: uop_operand.vs1[8*j+:8] = agnostic[3][j] ? 8'hFF : rob_byp[3].w_data[8*j+:8];
                    vs1_sel[2][j]: uop_operand.vs1[8*j+:8] = agnostic[2][j] ? 8'hFF : rob_byp[2].w_data[8*j+:8];
                    vs1_sel[1][j]: uop_operand.vs1[8*j+:8] = agnostic[1][j] ? 8'hFF : rob_byp[1].w_data[8*j+:8];
                    vs1_sel[0][j]: uop_operand.vs1[8*j+:8] = agnostic[0][j] ? 8'hFF : rob_byp[0].w_data[8*j+:8];
                    default:       uop_operand.vs1[8*j+:8] = vrf_byp.vs1[8*j+:8];
                endcase

                priority case (1'b1)
                    vs2_sel[7][j]: uop_operand.vs2[8*j+:8] = agnostic[7][j] ? 8'hFF : rob_byp[7].w_data[8*j+:8];
                    vs2_sel[6][j]: uop_operand.vs2[8*j+:8] = agnostic[6][j] ? 8'hFF : rob_byp[6].w_data[8*j+:8];
                    vs2_sel[5][j]: uop_operand.vs2[8*j+:8] = agnostic[5][j] ? 8'hFF : rob_byp[5].w_data[8*j+:8];
                    vs2_sel[4][j]: uop_operand.vs2[8*j+:8] = agnostic[4][j] ? 8'hFF : rob_byp[4].w_data[8*j+:8];
                    vs2_sel[3][j]: uop_operand.vs2[8*j+:8] = agnostic[3][j] ? 8'hFF : rob_byp[3].w_data[8*j+:8];
                    vs2_sel[2][j]: uop_operand.vs2[8*j+:8] = agnostic[2][j] ? 8'hFF : rob_byp[2].w_data[8*j+:8];
                    vs2_sel[1][j]: uop_operand.vs2[8*j+:8] = agnostic[1][j] ? 8'hFF : rob_byp[1].w_data[8*j+:8];
                    vs2_sel[0][j]: uop_operand.vs2[8*j+:8] = agnostic[0][j] ? 8'hFF : rob_byp[0].w_data[8*j+:8];
                    default:       uop_operand.vs2[8*j+:8] = vrf_byp.vs2[8*j+:8];
                endcase

                priority case (1'b1)
                    vd_sel[7][j]:  uop_operand.vd[8*j+:8]  = agnostic[7][j] ? 8'hFF : rob_byp[7].w_data[8*j+:8];
                    vd_sel[6][j]:  uop_operand.vd[8*j+:8]  = agnostic[6][j] ? 8'hFF : rob_byp[6].w_data[8*j+:8];
                    vd_sel[5][j]:  uop_operand.vd[8*j+:8]  = agnostic[5][j] ? 8'hFF : rob_byp[5].w_data[8*j+:8];
                    vd_sel[4][j]:  uop_operand.vd[8*j+:8]  = agnostic[4][j] ? 8'hFF : rob_byp[4].w_data[8*j+:8];
                    vd_sel[3][j]:  uop_operand.vd[8*j+:8]  = agnostic[3][j] ? 8'hFF : rob_byp[3].w_data[8*j+:8];
                    vd_sel[2][j]:  uop_operand.vd[8*j+:8]  = agnostic[2][j] ? 8'hFF : rob_byp[2].w_data[8*j+:8];
                    vd_sel[1][j]:  uop_operand.vd[8*j+:8]  = agnostic[1][j] ? 8'hFF : rob_byp[1].w_data[8*j+:8];
                    vd_sel[0][j]:  uop_operand.vd[8*j+:8]  = agnostic[0][j] ? 8'hFF : rob_byp[0].w_data[8*j+:8];
                    default:       uop_operand.vd[8*j+:8]  = vrf_byp.vd[8*j+:8];
                endcase

                priority case (1'b1)
                    v0_sel[7][j]:  uop_operand.v0[8*j+:8]  = agnostic[7][j] ? 8'hFF : rob_byp[7].w_data[8*j+:8];
                    v0_sel[6][j]:  uop_operand.v0[8*j+:8]  = agnostic[6][j] ? 8'hFF : rob_byp[6].w_data[8*j+:8];
                    v0_sel[5][j]:  uop_operand.v0[8*j+:8]  = agnostic[5][j] ? 8'hFF : rob_byp[5].w_data[8*j+:8];
                    v0_sel[4][j]:  uop_operand.v0[8*j+:8]  = agnostic[4][j] ? 8'hFF : rob_byp[4].w_data[8*j+:8];
                    v0_sel[3][j]:  uop_operand.v0[8*j+:8]  = agnostic[3][j] ? 8'hFF : rob_byp[3].w_data[8*j+:8];
                    v0_sel[2][j]:  uop_operand.v0[8*j+:8]  = agnostic[2][j] ? 8'hFF : rob_byp[2].w_data[8*j+:8];
                    v0_sel[1][j]:  uop_operand.v0[8*j+:8]  = agnostic[1][j] ? 8'hFF : rob_byp[1].w_data[8*j+:8];
                    v0_sel[0][j]:  uop_operand.v0[8*j+:8]  = agnostic[0][j] ? 8'hFF : rob_byp[0].w_data[8*j+:8];
                    default:       uop_operand.v0[8*j+:8]  = vrf_byp.v0[8*j+:8];
                endcase
            end
        end
    endgenerate

endmodule
