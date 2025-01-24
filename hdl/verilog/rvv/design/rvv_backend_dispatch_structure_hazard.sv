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
    generate
`ifdef DISPATCH_ISSUE2
      if (`NUM_DP_VRF==6) begin
        // 6 read ports of VRF
        // rd0 : uop0.vs1
        // rd1 : uop0.vs2
        // rd2 : uop0.vs3
        // rd3 : uop1.vs1
        // rd4 : uop1.vs2
        // rd5 : uop1.vs3
        assign rd_index[0] = strct_uop[0].vs1_index;
        assign rd_index[1] = strct_uop[0].vs2_index;
        assign rd_index[2] = strct_uop[0].vd_index;
        assign rd_index[3] = strct_uop[1].vs1_index;
        assign rd_index[4] = strct_uop[1].vs2_index;
        assign rd_index[5] = strct_uop[1].vd_index;
      end         
      else if(`NUM_DP_VRF==4) begin
        // 4 read ports of VRF
        // rd0: uop0.vs2 or uop0.vs1 or uop0.vd
        // rd1: uop0.vs1 or uop1.vd
        // rd2: uop1.vs2 or uop1.vs1 or uop1.vd
        // rd3: uop1.vs1 or uop0.vd
        always_comb begin
          // read port[0] of VRF
          case(strct_uop[0].uop_class)
            VVV,
            XVV,                      
            VVX,
            XVX: begin
              rd_index[0] = strct_uop[0].vs2_index;
            end
            VXX: begin
              rd_index[0] = strct_uop[0].vd_index;
            end
            XXV: begin
              rd_index[0] = strct_uop[0].vs1_index;
            end
            default: begin
              rd_index[0] = 'x;
            end
          endcase
          // rd[1]
          case(strct_uop[0].uop_class)
            VVV,
            XVV:begin                       
              rd_index[1] = strct_uop[0].vs1_index;
            end
            VVX: begin
              rd_index[1] = strct_uop[0].vd_index;
            end
            VXX,
            XVX,
            XXV,
            XXX: begin
              rd_index[1] = strct_uop[1].uop_class==VVV ? strct_uop[1].vd_index : 'x;
            end
            default: begin
              rd_index[1] = strct_uop[1].uop_class==VVV ? strct_uop[1].vd_index : 'x;
            end
          endcase
          // rd[2]
          case(strct_uop[1].uop_class)
            VVV,
            XVV,                      
            VVX,
            XVX: begin
              rd_index[2] = strct_uop[1].vs2_index;
            end
            VXX: begin
              rd_index[2] = strct_uop[1].vd_index;
            end
            XXV: begin
              rd_index[2] = strct_uop[1].vs1_index;
            end
            default: begin
              rd_index[2] = 'x;
            end
          endcase
          // rd[3]
          case(strct_uop[1].uop_class)
            VVV,
            XVV:begin                       
              rd_index[3] = strct_uop[0].uop_class==VVV ? strct_uop[0].vd_index : strct_uop[1].vs1_index;
            end
            VVX: begin
              rd_index[3] = strct_uop[0].uop_class==VVV ? strct_uop[0].vd_index : strct_uop[1].vd_index;
            end
            VXX,
            XVX,
            XXV,
            XXX: begin
              rd_index[3] = strct_uop[0].uop_class==VVV ? strct_uop[0].vd_index : 'x;
            end
            default: begin
              rd_index[3] = strct_uop[0].uop_class==VVV ? strct_uop[0].vd_index : 'x;
            end
          endcase
        end
      end 
`endif
    endgenerate

//check structure hazard
//the code as below is used for 2 uops issue.
//Please update the code if issue number is more than 2.  
  generate
`ifdef DISPATCH_ISSUE2
    if (`NUM_DP_VRF==6) begin
      assign arch_hazard.vr_limit = 1'b0;
      assign arch_hazard.pu_limit = 1'b0;
    end
    else if (`NUM_DP_VRF==4) begin
      always_comb begin
        case({strct_uop[0].uop_class, strct_uop[1].uop_class})
          {VVV, VVV},
          {VVV, XVV},
          {VVV, VVX},
          {XVV, VVV},
          {VVX, VVV}: arch_hazard.vr_limit = 1'b1;
          default:    arch_hazard.vr_limit = 1'b0;
        endcase
      end

      always_comb begin
        case({strct_uop[0].uop_exe_unit, strct_uop[1].uop_exe_unit})
          {MAC, MAC}: arch_hazard.pu_limit = 1'b1;
          default:    arch_hazard.pu_limit = 1'b0;
        endcase
      end
    end
`endif
  endgenerate

endmodule
