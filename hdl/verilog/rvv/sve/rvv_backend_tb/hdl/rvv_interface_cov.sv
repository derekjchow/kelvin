`ifndef RVV_INTERFACE_COV__SV
`define RVV_INTERFACE_COV__SV
module rvv_interface_cov (
  input logic clk, 
  input logic rst_n, 
  rvv_intern_interface rvv_intern_if);

// Normal toggle cov -------------------------------------------------
  covergroup Cov_bit_toggle (ref logic in) @(posedge clk);
    option.per_instance = 1;
    toggle: coverpoint in {
      bins bit_assert = (0=>1);
      bins bit_deassert = (0=>1);
    }
  endgroup
  Cov_bit_toggle cg_alu_rs_full_toggle;
  Cov_bit_toggle cg_mul_rs_full_toggle;
  Cov_bit_toggle cg_div_rs_full_toggle;
  Cov_bit_toggle cg_pmtrdt_rs_full_toggle;
  Cov_bit_toggle cg_alu_rs_empty_toggle;
  Cov_bit_toggle cg_mul_rs_empty_toggle;
  Cov_bit_toggle cg_div_rs_empty_toggle;
  Cov_bit_toggle cg_pmtrdt_rs_empty_toggle;

// WAW cov -----------------------------------------------------------
  logic [`NUM_RT_UOP-1:0] [`NUM_RT_UOP-1:0] vidx_eq;
  event rob2rt_cov_event;

  always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      vidx_eq <= '0;
    end else begin
      if(|(rvv_intern_if.rob2rt_write_valid & rvv_intern_if.rt2rob_write_ready)) begin
        for(int i=0; i<`NUM_RT_UOP; i++) begin
          for(int j=0; j<`NUM_RT_UOP; j++) begin
            vidx_eq[i][j] <= ((rvv_intern_if.rob2rt_write_data[i].w_type === 1'b0) && rvv_intern_if.rob2rt_write_data[i].w_valid) && 
                             ((rvv_intern_if.rob2rt_write_data[j].w_type === 1'b0) && rvv_intern_if.rob2rt_write_data[j].w_valid) &&
                             (rvv_intern_if.rob2rt_write_data[i].w_index === rvv_intern_if.rob2rt_write_data[j].w_index);
          end
        end
        -> rob2rt_cov_event;
      end
    end
  end

  covergroup Cov_waw @(rob2rt_cov_event);
    WAW:
      coverpoint {vidx_eq[3][2], vidx_eq[3][1], vidx_eq[3][0], vidx_eq[2][1], vidx_eq[2][0], vidx_eq[1][0]} {
        bins waw4 = {6'b1_1_1_1_1_1  //  3 &  2 &  1  &  0
                    };        

        bins waw3 = {6'b1_1_0_1_0_0, //  3 &  2 &  1  & !0
                     6'b1_0_1_0_1_0, //  3 &  2 & !1  &  0
                     6'b0_1_1_0_0_1, //  3 & !2 &  1  &  0
                     6'b0_0_0_1_1_1  // !3 &  2 &  1  &  0
                    };

        bins waw2_1 = {6'b1_0_0_0_0_0, //  3 &  2 & !1  & !0
                       6'b0_1_0_0_0_0, //  3 & !2 &  1  & !0
                       6'b0_0_1_0_0_0, //  3 & !2 & !1  &  0
                       6'b0_0_0_1_0_0, // !3 &  2 &  1  & !0
                       6'b0_0_0_0_1_0, // !3 &  2 & !1  &  0
                       6'b0_0_0_0_0_1  // !3 & !2 &  1  &  0
                      };

        bins waw2_2 = {6'b1_0_0_0_0_1,//  3 &  2 ,  1  &  0
                       6'b0_1_0_0_1_0,//  3 &  1 ,  2  &  0
                       6'b0_0_1_1_0_0 //  3 &  0 ,  2  &  1
                      };
                    
        bins waw1 = {6'b0_0_0_0_0_0
                    };

        illegal_bins misc = default;

      }
  endgroup
  Cov_waw cg_waw;

// Decode cov --------------------------------------------------------
  covergroup Cov_uops_valid_de2uq @(posedge clk);
    inst0:
      coverpoint {rvv_intern_if.uop_valid_de2uq[0]} {
        bins uop0 = {4'b0000};  
        bins uop1 = {4'b0001};  
        bins uop2 = {4'b0011};  
        bins uop3 = {4'b0111};  
        bins uop4 = {4'b1111};  
        illegal_bins misc = default;
      }
    inst1:
      coverpoint {rvv_intern_if.uop_valid_de2uq[1]} {
        bins uop0 = {4'b0000};  
        bins uop1 = {4'b0001};  
        bins uop2 = {4'b0011};  
        bins uop3 = {4'b0111};  
        bins uop4 = {4'b1111};  
        illegal_bins misc = default;
      }
    cross inst0, inst1;
  endgroup
  Cov_uops_valid_de2uq cg_uops_valid_de2uq;

// FIFO cov ----------------------------------------------------------
  covergroup Cov_exe_unit_state @(posedge clk);
    alu:
      coverpoint rvv_intern_if.alu_rs_empty {
        bins exec = {0};
        bins idle = {1};
      }

    mul:
      coverpoint rvv_intern_if.mul_rs_empty {
        bins exec = {0};
        bins idle = {1};
      }
      
    div:
      coverpoint rvv_intern_if.div_rs_empty {
        bins exec = {0};
        bins idle = {1};
      }
      
    pmtrdt:
      coverpoint rvv_intern_if.pmtrdt_rs_empty {
        bins exec = {0};
        bins idle = {1};
      }

    cross alu, mul, div, pmtrdt;
  endgroup
  Cov_exe_unit_state cg_exe_unit_state;

// -------------------------------------------------------------------
  initial begin
    cg_alu_rs_full_toggle = new(rvv_intern_if.alu_rs_full);
    cg_mul_rs_full_toggle = new(rvv_intern_if.mul_rs_full);
    cg_div_rs_full_toggle = new(rvv_intern_if.div_rs_full);
    cg_pmtrdt_rs_full_toggle = new(rvv_intern_if.pmtrdt_rs_full);
    cg_alu_rs_empty_toggle = new(rvv_intern_if.alu_rs_empty);
    cg_mul_rs_empty_toggle = new(rvv_intern_if.mul_rs_empty);
    cg_div_rs_empty_toggle = new(rvv_intern_if.div_rs_empty);
    cg_pmtrdt_rs_empty_toggle = new(rvv_intern_if.pmtrdt_rs_empty);

    cg_waw = new();
    cg_uops_valid_de2uq = new();
    cg_exe_unit_state = new();
  end
endmodule 
`endif // RVV_INTERFACE_COV__SV
