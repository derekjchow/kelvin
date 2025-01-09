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
//  rd0: uop0.vs2
//  rd1: uop0.vs1 or uop1.vd
//  rd2: uop1.vs2
//  rd3: uop1.vs1 or uop0.vd
    genvar i;
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_rd_index
            assign rd_index[2*i] = strct_uop[i].vs2_index;

            if (i%2 == 0) // i is even
                always_comb begin
                    case(strct_uop[i].uop_class)
                        VV:  rd_index[2*i+1] = strct_uop[i].vs3_valid ? strct_uop[i].vd_index
                                                                      : strct_uop[i].vs1_index;
                        VVV: rd_index[2*i+1] = strct_uop[i].vs1_index;
                        VX,
                        X  : rd_index[2*i+1] = strct_uop[i+1].vd_index;
                        default: rd_index[2*i+1] = 'x;
                    endcase
                end
            else // i is odd
                always_comb begin
                    case(strct_uop[i-1].uop_class)
                        VVV: rd_index[2*i+1] = strct_uop[i-1].vd_index;
                        VV:  rd_index[2*i+1] = strct_uop[i].vs3_valid ? strct_uop[i].vd_index
                                                                      : strct_uop[i].vs1_index;
                        VX,
                        X  : rd_index[2*i+1] = strct_uop[i].vs1_index;
                        default: rd_index[2*i+1] = 'x;
                    endcase
                end
            `ifdef ASSERT_ON
                `rvv_forbid($isunknown(rd_index[2*i+1]))
                  else $error("READ VRF: read index [%d] is X-state", 2*i+1);
            `endif
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
