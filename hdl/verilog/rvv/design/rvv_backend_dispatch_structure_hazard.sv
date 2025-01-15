// description:
// 1. rvv_backend_dispatch_structure_hazard sub-module is used to check structure hazard
//    for uop(s)
//

`include "rvv_backend.svh"
`include "rvv_backend_dispatch.svh"

module rvv_backend_dispatch_structure_hazard
(
    rd_index,
    arch_hazard,
    strct_uop
);

//---port definition--------------------------------------------------
    output logic [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_index;
    output ARCH_HAZARD_t                               arch_hazard;
    input  STRCT_UOP_t [`NUM_DP_UOP-1:0]               strct_uop;
//---internal signal definition---------------------------------------
//---code start-------------------------------------------------------
//determine rd_index for VRF read ports
//e.g. suppose issue 2 uop per cycle
//  rd0: uop0.vs2 or uop0.vs1
//  rd1: uop0.vs1 or uop1.vd
//  rd2: uop1.vs2 or uop1.vs1
//  rd3: uop1.vs1 or uop0.vd
    genvar i;
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_rd_index
            if (i[0] == 0) begin // i is even
                always_comb begin
                    case(strct_uop[i].uop_class)
                        VVV:begin                       
                          rd_index[2*i+1] = strct_uop[i].vs1_index;
                          rd_index[2*i] = strct_uop[i].vs2_index;
                        end
                        VV: begin
                          rd_index[2*i+1] = strct_uop[i].vs3_valid ? strct_uop[i].vd_index : strct_uop[i].vs1_index;
                          rd_index[2*i] = strct_uop[i].vs2_index;
                        end
                        VX: begin
                          // vmv only use vs1 as the operand.
                          rd_index[2*i+1] = strct_uop[i+1].vs3_valid ? strct_uop[i+1].vd_index : 'x;
                          rd_index[2*i] = strct_uop[i].vs2_valid ? strct_uop[i].vs2_index : strct_uop[i].vs1_index;
                        end
                        X: begin
                          rd_index[2*i+1] = strct_uop[i+1].vs3_valid ? strct_uop[i+1].vd_index : 'x;
                          rd_index[2*i] = 'x;
                        end
                        default: begin
                          rd_index[2*i+1] = strct_uop[i+1].vs3_valid ? strct_uop[i+1].vd_index : 'x;
                          rd_index[2*i] = 'x;
                        end
                    endcase
                end
            end
            else begin // i is odd
                always_comb begin
                    case(strct_uop[i].uop_class)
                        VVV:begin
                          rd_index[2*i+1] = strct_uop[i-1].vs3_valid ? strct_uop[i-1].vd_index : strct_uop[i].vs1_index;
                          rd_index[2*i] = strct_uop[i].vs2_index;
                        end
                        VV: begin
                          rd_index[2*i+1] = strct_uop[i-1].uop_class == VVV ? strct_uop[i-1].vd_index :
                                                                             strct_uop[i].vs3_valid ? strct_uop[i].vd_index 
                                                                                                    : strct_uop[i].vs1_index;
                          rd_index[2*i] = strct_uop[i].vs2_index;
                        end
                        VX: begin
                          // vmv only use vs1 as the operand.
                          rd_index[2*i+1] = strct_uop[i-1].vs3_valid ? strct_uop[i-1].vd_index : 'x;
                          rd_index[2*i] = strct_uop[i].vs2_valid ? strct_uop[i].vs2_index : strct_uop[i].vs1_index;
                        end
                        X: begin
                          rd_index[2*i+1] = strct_uop[i-1].vs3_valid ? strct_uop[i-1].vd_index : 'x;
                          rd_index[2*i] = 'x;
                        end
                        default: begin
                          rd_index[2*i+1] = strct_uop[i-1].vs3_valid ? strct_uop[i-1].vd_index : 'x;
                          rd_index[2*i] = 'x;
                        end
                    endcase
                end
            end
        end
    endgenerate

//check structure hazard
//the code as below is used for 2 uops issue.
//Please update the code if issue number is more than 2.
    always_comb begin
        case({strct_uop[0].uop_class, strct_uop[1].uop_class})
            {VV,  VVV},
            {VVV, VV},
            {VVV, VVV}: arch_hazard.vr_limit = 1'b1;
            default:    arch_hazard.vr_limit = 1'b0;
        endcase
    end

    always_comb begin
        case({strct_uop[0].uop_exe_unit, strct_uop[1].uop_exe_unit})
            {MAC, MAC}: arch_hazard.pu_limit = 1'b1;
            default:    arch_hazard.pu_limit = 1'b0;
        endcase
    end

endmodule
