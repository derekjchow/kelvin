`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_DISPATCH__SVH
`include "rvv_backend_dispatch.svh"
`endif

module rvv_backend_dispatch_operand
(
  vrf_byp,
  uop_uop2dp,
  rd_data_vrf2dp,
  v0_mask_vrf2dp
);
// ---port definition-------------------------------------------------
  output  UOP_OPN_t   [`NUM_DP_UOP-1:0]             vrf_byp;
  input   UOP_QUEUE_t [`NUM_DP_UOP-1:0]             uop_uop2dp;
  input   logic       [`NUM_DP_VRF-1:0][`VLEN-1:0]  rd_data_vrf2dp;
  input   logic       [`VLEN-1:0]                   v0_mask_vrf2dp;

// get the operand from VRF
`ifdef ISSUE_3_READ_PORT_6  
  always_comb begin
    vrf_byp[0].v0  = v0_mask_vrf2dp;
    vrf_byp[0].vs1 = rd_data_vrf2dp[0];
    vrf_byp[0].vs2 = rd_data_vrf2dp[1];
    vrf_byp[0].vd  = rd_data_vrf2dp[2];
    vrf_byp[1].v0  = v0_mask_vrf2dp;
    vrf_byp[1].vs1 = rd_data_vrf2dp[3];
    vrf_byp[1].vs2 = rd_data_vrf2dp[4];
    vrf_byp[1].vd  = rd_data_vrf2dp[5];
    vrf_byp[2].v0  = v0_mask_vrf2dp;
    vrf_byp[2].vs1 = 'b0;
    vrf_byp[2].vs2 = 'b0;
    vrf_byp[2].vd  = 'b0;

    case(uop_uop2dp[2].uop_class)
      XXV,
      XVX,
      VXX: begin
        case(uop_uop2dp[0].uop_class)
          XXV,
          XVV: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[2];
            vrf_byp[2].vs2 = rd_data_vrf2dp[2];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          XXX,
          XVX,
          VXX,
          VVX: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[0];
            vrf_byp[2].vd  = rd_data_vrf2dp[0];
          end

          VVV: begin 
            case(uop_uop2dp[1].uop_class)
              XXV,
              XVV: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[5];
                vrf_byp[2].vs2 = rd_data_vrf2dp[5];
                vrf_byp[2].vd  = rd_data_vrf2dp[5];
              end

              XXX,
              XVX,
              VXX,
              VVX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = rd_data_vrf2dp[3];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end
            endcase
          end
        endcase
      end
      
      XVV,
      VVX: begin
        case(uop_uop2dp[0].uop_class)
          XXX,
          VXX: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[0];
          end

          XXV: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[2];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          XVX: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[2];
            vrf_byp[2].vd  = rd_data_vrf2dp[0];
          end

          XVV,
          VVX: begin
            case(uop_uop2dp[1].uop_class)
              XXX,
              VXX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = rd_data_vrf2dp[4];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end

              XXV: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[5];
                vrf_byp[2].vs2 = rd_data_vrf2dp[4];
                vrf_byp[2].vd  = rd_data_vrf2dp[5];
              end

              XVX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = rd_data_vrf2dp[5];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end   

              VVX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = uop_uop2dp[0].vs1_index_valid ? rd_data_vrf2dp[2] : rd_data_vrf2dp[0];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end

              XVV: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[5];
                vrf_byp[2].vs2 = uop_uop2dp[0].vs1_index_valid ? rd_data_vrf2dp[2] : rd_data_vrf2dp[0];
                vrf_byp[2].vd  = rd_data_vrf2dp[5];
              end
            endcase
          end

          VVV: begin 
            case(uop_uop2dp[1].uop_class)
              XXX,
              VXX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = rd_data_vrf2dp[4];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end

              XVX: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[3];
                vrf_byp[2].vs2 = rd_data_vrf2dp[5];
                vrf_byp[2].vd  = rd_data_vrf2dp[3];
              end

              XXV: begin
                vrf_byp[2].vs1 = rd_data_vrf2dp[4];
                vrf_byp[2].vs2 = rd_data_vrf2dp[5];
                vrf_byp[2].vd  = rd_data_vrf2dp[4];
              end
            endcase
          end
        endcase
      end

      VVV: begin
        case({uop_uop2dp[0].uop_class,uop_uop2dp[1].uop_class})
          {XXX,XXX},
          {XXX,XXV},
          {XXX,XVX},
          {XXX,VXX},
          {XXX,XVV},
          {XXX,VVX},
          {XXX,VVV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          {XXV,XXX},
          {XVX,XXX},
          {VXX,XXX},
          {XVV,XXX},
          {VVX,XXX},
          {VVV,XXX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[4];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end

          {XXV,VXX},
          {XXV,VVX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end
          
          {XXV,XXV},
          {XXV,XVX},
          {XXV,XVV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[5];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end
          
          {XVX,VXX},
          {XVX,VVX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[3];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          {XVX,XXV},
          {XVX,XVX},
          {XVX,XVV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[5];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          {VXX,VXX},
          {VXX,VVX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[3];
          end

          {VXX,XXV},
          {VXX,XVX},
          {VXX,XVV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[1];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end

          {XVV,VXX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[4];
            vrf_byp[2].vd  = rd_data_vrf2dp[2];
          end

          {XVV,XVX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[2];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end

          {XVV,XXV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[2];
            vrf_byp[2].vs2 = rd_data_vrf2dp[4];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end

          {VVX,VXX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[4];
            vrf_byp[2].vd  = rd_data_vrf2dp[0];
          end

          {VVX,XVX}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[3];
            vrf_byp[2].vs2 = rd_data_vrf2dp[0];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end

          {VVX,XXV}: begin
            vrf_byp[2].vs1 = rd_data_vrf2dp[0];
            vrf_byp[2].vs2 = rd_data_vrf2dp[4];
            vrf_byp[2].vd  = rd_data_vrf2dp[5];
          end
        endcase
      end
    endcase
  end   

`elsif ISSUE_2_READ_PORT_6  
  always_comb begin
    vrf_byp[0].v0  = v0_mask_vrf2dp;
    vrf_byp[0].vs1 = rd_data_vrf2dp[0];
    vrf_byp[0].vs2 = rd_data_vrf2dp[1];
    vrf_byp[0].vd  = rd_data_vrf2dp[2];
    vrf_byp[1].v0  = v0_mask_vrf2dp;
    vrf_byp[1].vs1 = rd_data_vrf2dp[3];
    vrf_byp[1].vs2 = rd_data_vrf2dp[4];
    vrf_byp[1].vd  = rd_data_vrf2dp[5];
  end

`else //ISSUE_2_READ_PORT_4
  always_comb begin
    vrf_byp[0].v0  = v0_mask_vrf2dp;
    vrf_byp[0].vs1 = 'b0;
    vrf_byp[0].vs2 = 'b0;
    vrf_byp[0].vd  = 'b0;
    vrf_byp[1].v0  = v0_mask_vrf2dp;
    vrf_byp[1].vs1 = 'b0;
    vrf_byp[1].vs2 = 'b0;
    vrf_byp[1].vd  = 'b0;

    case(uop_uop2dp[0].uop_class)
      VVV:begin
        vrf_byp[0].vd  = rd_data_vrf2dp[3];
        vrf_byp[0].vs1 = rd_data_vrf2dp[1];
        vrf_byp[0].vs2 = rd_data_vrf2dp[0];
      end                       
      XVV: begin
        vrf_byp[0].vs1 = rd_data_vrf2dp[1];
        vrf_byp[0].vs2 = rd_data_vrf2dp[0];
      end
      VVX: begin
        vrf_byp[0].vd  = rd_data_vrf2dp[1];
        vrf_byp[0].vs2 = rd_data_vrf2dp[0];
      end
      VXX: begin
        vrf_byp[0].vd  = rd_data_vrf2dp[0];
      end
      XVX: begin
        vrf_byp[0].vs2 = rd_data_vrf2dp[0];
      end
      XXV: begin
        vrf_byp[0].vs1 = rd_data_vrf2dp[0];
      end
    endcase

    case(uop_uop2dp[1].uop_class)
      VVV:begin
        vrf_byp[1].vd  = rd_data_vrf2dp[1];
        vrf_byp[1].vs1 = rd_data_vrf2dp[3];
        vrf_byp[1].vs2 = rd_data_vrf2dp[2];
      end
      XVV: begin
        vrf_byp[1].vs1 = rd_data_vrf2dp[3];
        vrf_byp[1].vs2 = rd_data_vrf2dp[2];
      end
      VVX: begin
        vrf_byp[1].vd  = rd_data_vrf2dp[3];
        vrf_byp[1].vs2 = rd_data_vrf2dp[2];
      end
      VXX: begin
        vrf_byp[1].vd = rd_data_vrf2dp[2];
      end
      XVX: begin
        vrf_byp[1].vs2 = rd_data_vrf2dp[2];
      end
      XXV: begin
        vrf_byp[1].vs1 = rd_data_vrf2dp[2];
      end
    endcase
  end
`endif

endmodule
