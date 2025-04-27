`ifndef RVV_INTERFACE_COV__SV
`define RVV_INTERFACE_COV__SV

module rvv_interface_cov (
  input logic clk, 
  input logic rst_n, 
  rvv_intern_interface rvv_intern_if,
  rvs_interface rvs_if);

// Normal toggle cov -------------------------------------------------
  covergroup Cov_bit_toggle (ref logic in) @(posedge clk);
    option.per_instance = 1;
    toggle: coverpoint in {
      bins bit_assert = (0=>1);
      bins bit_deassert = (0=>1);
    }
  endgroup

  initial begin
    Cov_bit_toggle cg_alu_rs_full_toggle     = new(rvv_intern_if.alu_rs_full);    
    Cov_bit_toggle cg_mul_rs_full_toggle     = new(rvv_intern_if.mul_rs_full);    
    Cov_bit_toggle cg_div_rs_full_toggle     = new(rvv_intern_if.div_rs_full);    
    Cov_bit_toggle cg_pmtrdt_rs_full_toggle  = new(rvv_intern_if.pmtrdt_rs_full); 
    Cov_bit_toggle cg_alu_rs_empty_toggle    = new(rvv_intern_if.alu_rs_empty);   
    Cov_bit_toggle cg_mul_rs_empty_toggle    = new(rvv_intern_if.mul_rs_empty);   
    Cov_bit_toggle cg_div_rs_empty_toggle    = new(rvv_intern_if.div_rs_empty);   
    Cov_bit_toggle cg_pmtrdt_rs_empty_toggle = new(rvv_intern_if.pmtrdt_rs_empty);
  end

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

  initial begin
    Cov_waw cg_waw = new();
  end

// Decode cov --------------------------------------------------------
`ifdef ISSUE_3_READ_PORT_6
  covergroup Cov_uops_valid_de2uq @(posedge clk);
    inst0:
      coverpoint {rvv_intern_if.uop_valid_de2uq[0]} {
        bins uop0 = {6'b00_0000};
        bins uop1 = {6'b00_0001};
        bins uop2 = {6'b00_0011};
        bins uop3 = {6'b00_0111};
        bins uop4 = {6'b00_1111};
        bins uop5 = {6'b01_1111};
        bins uop6 = {6'b11_1111};
        illegal_bins misc = default;
      }
    inst1:
      coverpoint {rvv_intern_if.uop_valid_de2uq[1]} {
        bins uop0 = {6'b00_0000};
        bins uop1 = {6'b00_0001};
        bins uop2 = {6'b00_0011};
        bins uop3 = {6'b00_0111};
        bins uop4 = {6'b00_1111};
        bins uop5 = {6'b01_1111};
        bins uop6 = {6'b11_1111};
        illegal_bins misc = default;
      }
    cross inst0, inst1;
  endgroup
`else // ISSUE_3_READ_PORT_6
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
`endif // ISSUE_*

  initial begin
    Cov_uops_valid_de2uq cg_uops_valid_de2uq = new();
  end

// Dispatch cov ------------------------------------------------------
  logic [`NUM_DP_UOP-1:0] [4:0] dipsatch_unit;
  always_comb begin
    dipsatch_unit = '0;
    for(int i=0; i<`NUM_DP_UOP; i++) begin
      dipsatch_unit[i][0] = rvv_intern_if.rs_valid_dp2alu[i] & rvv_intern_if.rs_valid_dp2alu[i];
      dipsatch_unit[i][1] = rvv_intern_if.rs_valid_dp2pmtrdt[i] & rvv_intern_if.rs_valid_dp2pmtrdt[i];
      dipsatch_unit[i][2] = rvv_intern_if.rs_valid_dp2mul[i] & rvv_intern_if.rs_valid_dp2mul[i];
      dipsatch_unit[i][3] = rvv_intern_if.rs_valid_dp2div[i] & rvv_intern_if.rs_valid_dp2div[i];
      dipsatch_unit[i][4] = rvv_intern_if.rs_valid_dp2lsu[i] & rvv_intern_if.rs_valid_dp2lsu[i];
    end
  end
  covergroup Cov_dispatch_unit @(posedge clk);
    uop0_dispatch_unit:
      coverpoint dipsatch_unit[0] {
        bins to_none = {5'b00000};
        bins to_alu = {5'b00001};  
        bins to_pmtrdt = {5'b00010};  
        bins to_mul = {5'b00100};  
        bins to_div = {5'b01000};  
        bins to_lsu = {5'b10000};  
        illegal_bins misc = default;
      }
    uop1_dispatch_unit:
      coverpoint dipsatch_unit[1] {
        bins to_none = {5'b00000};
        bins to_alu = {5'b00001};  
        bins to_pmtrdt = {5'b00010};  
        bins to_mul = {5'b00100};  
        bins to_div = {5'b01000};  
        bins to_lsu = {5'b10000};  
        illegal_bins misc = default;
      }
    cross uop0_dispatch_unit, uop1_dispatch_unit;
  endgroup

  initial begin
    Cov_dispatch_unit cg_dispatch_unit = new();
  end

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

  initial begin
    Cov_exe_unit_state cg_exe_unit_state = new();
  end

// Inst cov ----------------------------------------------------------
`include "rvv_zve32x_coverage.svh"

endmodule 
`endif // RVV_INTERFACE_COV__SV
