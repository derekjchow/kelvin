// description: 
// 1. It will get uops from mac Reservation station and execute this uop.
//
// feature list:
// 1. 

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif

module rvv_backend_mac_unit (
  // Outputs
  mac2rob_uop_valid, mac2rob_uop_data,
  // Inputs
  clk, rst_n, rs2mac_uop_valid, rs2mac_uop_data,
  mac_stg0_vld_en, mac_stg0_data_en
  );

input             clk;
input             rst_n;

input             rs2mac_uop_valid;
input MUL_RS_t    rs2mac_uop_data;

input             mac_stg0_vld_en;
input             mac_stg0_data_en;

output            mac2rob_uop_valid;
output PU2ROB_t   mac2rob_uop_data;

// Wires & Regs
logic [`ROB_DEPTH_WIDTH-1:0]  mac_uop_rob_entry;
logic [`FUNCT6_WIDTH-1:0]     mac_uop_funct6;
logic [`FUNCT3_WIDTH-1:0]     mac_uop_funct3;
logic [1:0]                   mac_uop_xrm;
logic [2:0]                   mac_top_vs_eew;
logic [`VLEN-1:0]             mac_uop_vs1_data;
logic [`VLEN-1:0]             mac_uop_vs2_data;
logic [`XLEN-1:0]             mac_uop_rs1_data;
logic [`VLEN-1:0]             mac_uop_vs3_data;
logic                         mac_uop_index;

logic                         is_vv; //1:op*vv; 0:op*vx
logic [`VLEN-1:0]             mac_src2;
logic [`VLEN-1:0]             mac_src1;
logic [`VLEN-1:0]             mac_addsrc;
logic                         mac_src2_is_signed;
logic                         mac_src1_is_signed;
logic                         mac_is_widen;
logic                         mac_keep_low_bits;
logic                         mac_mul_reverse;
logic                         is_vsmul;
logic                         is_vmac;

logic [`VLEN-1:0]             mac_src2_mux;
logic [`VLEN-1:0]             mac_src1_mux;
logic [15:0]                  mac_src2_is_signed_extend;
logic [15:0]                  mac_src1_is_signed_extend;

logic [7:0]                   mac8_in0[15:0];
logic [15:0]                  mac8_in0_is_signed;
logic [7:0]                   mac8_in1[15:0];
logic [15:0]                  mac8_in1_is_signed;
logic [15:0]                  mac8_out[63:0];

logic [15:0]                  mac8_out_d1[63:0];
logic [`VLEN-1:0]             mac_addsrc_d1;
logic [2*`VLEN-1:0]           mac_addsrc_widen_d1;

logic                         rs2mac_uop_valid_d1;
logic                         mac_src2_is_signed_d1;
logic                         mac_src1_is_signed_d1;
logic                         mac_is_widen_d1;
logic                         mac_keep_low_bits_d1;
logic                         mac_mul_reverse_d1;
logic                         is_vsmul_d1;
logic                         is_vmac_d1;
logic [1:0]                   mac_uop_xrm_d1;
logic [2:0]                   mac_top_vs_eew_d1;
logic [`ROB_DEPTH_WIDTH-1:0]  mac_uop_rob_entry_d1;

logic [15:0]                  mac_rslt_full_eew8_d1[15:0];
logic [2*`VLEN-1:0]           mac_rslt_eew8_widen_d1;
logic [`VLEN-1:0]             mac_rslt_eew8_no_widen_d1;
logic [15:0]                  vsmul_round_incr_eew8_d1;
logic [`VLEN-1:0]             vsmul_rslt_eew8_d1;
logic [15:0]                  vsmul_sat_eew8_d1;
logic [`VLEN-1:0]             mac_rslt_eew8_d1;
logic [`VLENB-1:0]            update_vxsat_eew8_d1;
logic [8:0]                   vmac_mul_add_eew8_no_widen_d1[0:15];
logic [8:0]                   vmac_mul_sub_eew8_no_widen_d1[0:15];
logic [`VLEN-1:0]             vmac_rslt_eew8_no_widen_d1;
logic [16:0]                  vmac_mul_add_eew8_widen_d1[0:15];
logic [16:0]                  vmac_mul_sub_eew8_widen_d1[0:15];
logic [2*`VLEN-1:0]           vmac_rslt_eew8_widen_d1;

logic [31:0]                  mac_rslt_full_eew16_d1[7:0];
logic [2*`VLEN-1:0]           mac_rslt_eew16_widen_d1;
logic [`VLEN-1:0]             mac_rslt_eew16_no_widen_d1;
logic [7:0]                   vsmul_round_incr_eew16_d1;
logic [`VLEN-1:0]             vsmul_rslt_eew16_d1;
logic [7:0]                   vsmul_sat_eew16_d1;
logic [`VLEN-1:0]             mac_rslt_eew16_d1;
logic [`VLENB-1:0]            update_vxsat_eew16_d1;
logic [16:0]                  vmac_mul_add_eew16_no_widen_d1[0:7];
logic [16:0]                  vmac_mul_sub_eew16_no_widen_d1[0:7];
logic [`VLEN-1:0]             vmac_rslt_eew16_no_widen_d1;
logic [32:0]                  vmac_mul_add_eew16_widen_d1[0:7];
logic [32:0]                  vmac_mul_sub_eew16_widen_d1[0:7];
logic [2*`VLEN-1:0]           vmac_rslt_eew16_widen_d1;

logic [63:0]                  mac_rslt_full_eew32_d1[3:0];
logic [2*`VLEN-1:0]           mac_rslt_eew32_widen_d1;
logic [`VLEN-1:0]             mac_rslt_eew32_no_widen_d1;
logic [3:0]                   vsmul_round_incr_eew32_d1;
logic [`VLEN-1:0]             vsmul_rslt_eew32_d1;
logic [3:0]                   vsmul_sat_eew32_d1;
logic [`VLEN-1:0]             mac_rslt_eew32_d1;
logic [`VLENB-1:0]            update_vxsat_eew32_d1;
logic [32:0]                  vmac_mul_add_eew32_no_widen_d1[0:3];
logic [32:0]                  vmac_mul_sub_eew32_no_widen_d1[0:3];
logic [`VLEN-1:0]             vmac_rslt_eew32_no_widen_d1;
logic [64:0]                  vmac_mul_add_eew32_widen_d1[0:4];
logic [64:0]                  vmac_mul_sub_eew32_widen_d1[0:4];
logic [2*`VLEN-1:0]           vmac_rslt_eew32_widen_d1;

`ifdef TB_SUPPORT
logic [`PC_WIDTH-1:0]         mac_uop_pc;
logic [`PC_WIDTH-1:0]         mac_uop_pc_d1;
`endif

//Int & Genvar
integer i,j;
genvar z,x,y;

// Input struct decode
assign mac_uop_rob_entry = rs2mac_uop_data.rob_entry;
assign mac_uop_funct6 = rs2mac_uop_data.uop_funct6.ari_funct6;
assign mac_uop_funct3 = rs2mac_uop_data.uop_funct3;
assign mac_uop_xrm = rs2mac_uop_data.vxrm;
assign mac_top_vs_eew = rs2mac_uop_data.vs2_eew;

assign mac_uop_vs1_data = rs2mac_uop_data.vs1_data;

assign mac_uop_vs2_data = rs2mac_uop_data.vs2_data;

assign mac_uop_vs3_data = rs2mac_uop_data.vs3_data;

assign mac_uop_rs1_data = rs2mac_uop_data.rs1_data;

assign mac_uop_index = rs2mac_uop_data.uop_index[0];

`ifdef TB_SUPPORT
assign mac_uop_pc = rs2mac_uop_data.uop_pc;
`endif

// Global EU control
always@(*) begin
  case ({rs2mac_uop_valid,mac_uop_funct3}) 
    {1'b1,OPMVV} : begin
      is_vv = 1'b1;
      case (mac_uop_funct6) 
        VMACC : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VNMSAC : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b1;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VMADD : begin
          mac_src2 = mac_uop_vs3_data; //vd
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = mac_uop_vs2_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VNMSUB : begin
          mac_src2 = mac_uop_vs3_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = mac_uop_vs2_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b1;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACCU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACC : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACCSU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VMUL: begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULH : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULHU : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULHSU : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMUL : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMULU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMULSU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {64'b0,mac_uop_vs1_data[mac_uop_index*64 +: 64]};
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        default : begin //default use VMUL
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end//end default
      endcase//end funct6
    end//end OPMVV
    {1'b1,OPMVX} : begin
      is_vv = 1'b0;
      case (mac_uop_funct6) 
        VMACC : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VNMSAC : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc =mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b1;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VMADD : begin
          mac_src2 = mac_uop_vs3_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs2_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VNMSUB : begin
          mac_src2 = mac_uop_vs3_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs2_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b1;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACCU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACC : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACCSU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VWMACCUS : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = mac_uop_vs3_data;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b1;
        end
        VMUL : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULH : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULHU : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VMULHSU : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMUL : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMULU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b0;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        VWMULSU : begin
          mac_src2 = {64'b0,mac_uop_vs2_data[mac_uop_index*64 +: 64]};
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b0;
          mac_is_widen = 1'b1;
          mac_keep_low_bits = 1'b0;//if widen, keep_low doesnt matter
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end
        default : begin //default use VMUL
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b1;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b0;
          is_vmac = 1'b0;
        end//end default
      endcase
    end//end OPMVX
    {1'b1,OPIVV} : begin
      is_vv = 1'b1;
      case (mac_uop_funct6) 
        VSMUL_VMVNRR : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b1;
          is_vmac = 1'b0;
        end
        default : begin //currently put default the same as VSMUL_VMVNRR
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = mac_uop_vs1_data;
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b1;
          is_vmac = 1'b0;
        end//end default
      endcase//end funct6
    end//end OPIVV
    {1'b1,OPIVX} : begin
      is_vv = 1'b0;
      case (mac_uop_funct6) 
        VSMUL_VMVNRR : begin
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b1;
          is_vmac = 1'b0;
        end
        default : begin //currently put default the same as VSMUL_VMVNRR
          mac_src2 = mac_uop_vs2_data;
          mac_src1 = {{(`VLEN-`XLEN){mac_uop_rs1_data[`XLEN-1]&&mac_src1_is_signed}},mac_uop_rs1_data}; //use rs1
          mac_addsrc = `VLEN'b0;
          mac_src2_is_signed = 1'b1;
          mac_src1_is_signed = 1'b1;
          mac_is_widen = 1'b0;
          mac_keep_low_bits = 1'b0;
          mac_mul_reverse = 1'b0;
          is_vsmul = 1'b1;
          is_vmac = 1'b0;
        end//end default
      endcase//end funct6
    end//end OPIVX
    default : begin
      is_vv = 1'b1;
      mac_src2 = `VLEN'b0;
      mac_src1 = `VLEN'b0;
      mac_addsrc = `VLEN'b0;
      mac_src2_is_signed = 1'b0;
      mac_src1_is_signed = 1'b0;
      mac_is_widen = 1'b0;
      mac_keep_low_bits = 1'b0;
      mac_mul_reverse = 1'b0;
      is_vsmul = 1'b0;
      is_vmac = 1'b0;
    end//end default
  endcase//end funct3
end

// Before using mac alu, 
//  1.group sub-elements' sign bit
// (TODO) let input is 0 when not use that EU
always@(*) begin
  case (mac_top_vs_eew) 
    EEW8 : begin
      mac_src2_mux = mac_src2;
      mac_src1_mux = is_vv ? mac_src1 : {16{mac_src1[7:0]}};
      mac_src2_is_signed_extend = {16{mac_src2_is_signed}};
      mac_src1_is_signed_extend = {16{mac_src1_is_signed}};
    end//end eew8
    EEW16 : begin
      mac_src2_mux = mac_src2;
      mac_src1_mux = is_vv ? mac_src1 : {8{mac_src1[15:0]}};
      mac_src2_is_signed_extend = {8{mac_src2_is_signed,1'b0}};
      mac_src1_is_signed_extend = {8{mac_src1_is_signed,1'b0}};
    end//end eew16
    EEW32 : begin
      mac_src2_mux = mac_src2;
      mac_src1_mux = is_vv ? mac_src1 : {4{mac_src1[31:0]}};
      mac_src2_is_signed_extend = {4{mac_src2_is_signed,3'b0}};
      mac_src1_is_signed_extend = {4{mac_src1_is_signed,3'b0}};
    end//end eew32
    default : begin //default use eew8
      mac_src2_mux = mac_src2;
      mac_src1_mux = is_vv ? mac_src1 : {16{mac_src1[7:0]}};
      mac_src2_is_signed_extend = {16{mac_src2_is_signed}};
      mac_src1_is_signed_extend = {16{mac_src1_is_signed}};
    end//end default
  endcase
end

// Before mac, always depart 128 bits into 16x8 sub-elements
always@(*) begin
  for (i=0; i<16; i=i+1) begin
      mac8_in0[i] = mac_src2_mux[i*8 +: 8];
      mac8_in1[i] = mac_src1_mux[i*8 +: 8];
      mac8_in0_is_signed[i] = mac_src2_is_signed_extend[i];
      mac8_in1_is_signed[i] = mac_src1_is_signed_extend[i];
  end
end

// mul alus with d1_reg
//  in a 4 of 4x4 tiled way for instantiation
generate 
  for (z=0; z<4; z=z+1) begin 
    for (x=0; x<4; x=x+1) begin
      for (y=0; y<4; y=y+1) begin
        rvv_backend_mul_unit_mul8 u_mul8 (
          .out(mac8_out[z*16+y*4+x]), //16bit out
          .in0(mac8_in0[z*4+x]), 
          .in0_is_signed(mac8_in0_is_signed[z*4+x]),
          .in1(mac8_in1[z*4+y]), 
          .in1_is_signed(mac8_in1_is_signed[z*4+y]));

        edff #(.T(logic [16-1:0])) u_mul8_delay (
          .q(mac8_out_d1[z*16+y*4+x]), 
          .clk(clk), 
          .rst_n(rst_n), 
          .e(mac_stg0_data_en),
          .d(mac8_out[z*16+y*4+x]));
      end
    end
  end
endgenerate

edff #(.T(logic [`VLEN-1:0])) u_addsrc_delay (.q(mac_addsrc_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_addsrc));
assign mac_addsrc_widen_d1 = {2{mac_addsrc_d1}}; //when widen, copy low half to high, for widen add
edff #(.T(logic)) u_valid_delay (.q(rs2mac_uop_valid_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_vld_en), .d(rs2mac_uop_valid));
edff #(.T(logic)) u_src2_is_signed_delay (.q(mac_src2_is_signed_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_src2_is_signed));
edff #(.T(logic)) u_src1_is_signed_delay (.q(mac_src1_is_signed_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_src1_is_signed));
edff #(.T(logic)) u_is_widen_delay (.q(mac_is_widen_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_is_widen));
edff #(.T(logic)) u_keep_low_bits_delay (.q(mac_keep_low_bits_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_keep_low_bits));
edff #(.T(logic)) u_is_vsmul_delay (.q(is_vsmul_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(is_vsmul));
edff #(.T(logic)) u_mul_reverse_delay (.q(mac_mul_reverse_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_mul_reverse));
edff #(.T(logic)) u_is_vmac_delay (.q(is_vmac_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(is_vmac));

edff #(.T(logic [2-1:0])) u_xrm_delay (.q(mac_uop_xrm_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_uop_xrm));
edff #(.T(logic [3-1:0])) u_eew_delay (.q(mac_top_vs_eew_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_top_vs_eew));


edff #(.T(logic [`ROB_DEPTH_WIDTH-1:0])) u_rob_entry_delay (.q(mac_uop_rob_entry_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_uop_rob_entry));

`ifdef TB_SUPPORT
edff #(.T(logic [`PC_WIDTH-1:0])) u_PC_delay (.q(mac_uop_pc_d1), .clk(clk), .rst_n(rst_n), .e(mac_stg0_data_en), .d(mac_uop_pc));
`endif


/////////////////////////////////////////////////
///////Enter d1_stage ///////////////////////////
/////////////////////////////////////////////////

// After mac, calculte eew8, eew16, eew32 results
// Here we have a ([15:0] [63:0] mac8_out_d1)
//eew8
//full rslt is 16bit
always@(*) begin
  for (i=0; i<4; i=i+1) begin //z
    for (j=0; j<4; j=j+1) begin //x
        mac_rslt_full_eew8_d1[i*4+j] = mac8_out_d1[i*16+j*5];
        mac_rslt_eew8_widen_d1[16*(i*4+j) +: 16] = mac_rslt_full_eew8_d1[i*4+j];//widen, and convert to [255:0]
        mac_rslt_eew8_no_widen_d1[8*(i*4+j) +: 8] = mac_keep_low_bits_d1 ? mac_rslt_full_eew8_d1[i*4+j][7:0] : mac_rslt_full_eew8_d1[i*4+j][15:8];
        //Below are for rounding mul (vsmul.vv, vsmul.vx)
        //right shift bit is 7 not 8 !
        //(TODO) Improve to make this readable
        vsmul_round_incr_eew8_d1[i*4+j] = mac_uop_xrm_d1==2'd3 ? !mac_rslt_full_eew8_d1[i*4+j][7] && (|mac_rslt_full_eew8_d1[i*4+j][6:0]) : //ROD
                                          mac_uop_xrm_d1==2'd2 ? 1'b0  : //RDN
                                          mac_uop_xrm_d1==2'd1 ? mac_rslt_full_eew8_d1[i*4+j][6] && (|(mac_rslt_full_eew8_d1[i*4+j][5:0]) || mac_rslt_full_eew8_d1[i*4+j][7]) : //RNE
                                                                 mac_rslt_full_eew8_d1[i*4+j][6]; //RNU
        vsmul_rslt_eew8_d1[8*(i*4+j) +:8]= mac_rslt_full_eew8_d1[i*4+j][15:14] == 2'b01 ? 8'h7f : //saturate
                                                                                      mac_rslt_full_eew8_d1[i*4+j][7+:8] + {7'b0,vsmul_round_incr_eew8_d1[i*4+j]};//right shift 7bit then +"1"
        vsmul_sat_eew8_d1[i*4+j] = mac_rslt_full_eew8_d1[i*4+j][15:14] == 2'b01;
        //Below are for vmac related instructions
        vmac_mul_add_eew8_no_widen_d1[i*4+j] = {1'b0,mac_addsrc_d1[8*(i*4+j) +: 8]} + {1'b0,mac_rslt_eew8_no_widen_d1[8*(i*4+j) +: 8]};//9bit
        vmac_mul_sub_eew8_no_widen_d1[i*4+j] = {1'b0,mac_addsrc_d1[8*(i*4+j) +: 8]} - {1'b0,mac_rslt_eew8_no_widen_d1[8*(i*4+j) +: 8]};
        vmac_rslt_eew8_no_widen_d1[8*(i*4+j) +:8] = mac_mul_reverse_d1 ? vmac_mul_sub_eew8_no_widen_d1[i*4+j][7:0] :
                                                                         vmac_mul_add_eew8_no_widen_d1[i*4+j][7:0];
        vmac_mul_add_eew8_widen_d1[i*4+j] = {1'b0,mac_addsrc_widen_d1[16*(i*4+j) +: 16]} + {1'b0,mac_rslt_eew8_widen_d1[16*(i*4+j) +: 16]};//17bit
        vmac_mul_sub_eew8_widen_d1[i*4+j] = {1'b0,mac_addsrc_widen_d1[16*(i*4+j) +: 16]} - {1'b0,mac_rslt_eew8_widen_d1[16*(i*4+j) +: 16]};
        vmac_rslt_eew8_widen_d1[16*(i*4+j) +: 16] = mac_mul_reverse_d1 ? vmac_mul_sub_eew8_widen_d1[i*4+j][15:0] :
                                                                        vmac_mul_add_eew8_widen_d1[i*4+j][15:0];
    end
  end
end
assign mac_rslt_eew8_d1 = is_vmac_d1 ? mac_is_widen_d1 ? vmac_rslt_eew8_widen_d1[`VLEN-1:0]    : //mac widen
                                                         vmac_rslt_eew8_no_widen_d1            : //mac normal
                                       is_vsmul_d1     ? vsmul_rslt_eew8_d1                    : //vsmul
                                       mac_is_widen_d1 ? mac_rslt_eew8_widen_d1[`VLEN-1:0]     : //mul widen
                                                         mac_rslt_eew8_no_widen_d1; //mul normal
assign update_vxsat_eew8_d1 = vsmul_sat_eew8_d1;
//eew16
//full rslt is 32bit
always@(*) begin
  for (i=0; i<4; i=i+1) begin //z
    for (j=0; j<2; j=j+1) begin //x
      mac_rslt_full_eew16_d1[i*2+j] = {mac8_out_d1[i*16+j*10+5],16'b0} + 
                                   {{8{mac8_out_d1[i*16+j*10+4][15]&&mac_src1_is_signed_d1}},mac8_out_d1[i*16+j*10+4],8'b0} + 
                                   {{8{mac8_out_d1[i*16+j*10+1][15]&&mac_src2_is_signed_d1}},mac8_out_d1[i*16+j*10+1],8'b0} + 
                                   {16'b0,mac8_out_d1[i*16+j*10]};
      mac_rslt_eew16_widen_d1[32*(i*2+j) +: 32] = mac_rslt_full_eew16_d1[i*2+j];//widen, and convert to [255:0]
      mac_rslt_eew16_no_widen_d1[16*(i*2+j) +: 16] = mac_keep_low_bits_d1 ? mac_rslt_full_eew16_d1[i*2+j][15:0] : mac_rslt_full_eew16_d1[i*2+j][31:16];
      //Below are for rounding mac (vsmul.vv, vsmul.vx)
      //right shift bit is 16-1=15 not 16 !
      //(TODO) Improve to make this readable
      vsmul_round_incr_eew16_d1[i*2+j] = mac_uop_xrm_d1==2'd3 ? !mac_rslt_full_eew16_d1[i*2+j][15] && (|mac_rslt_full_eew16_d1[i*2+j][14:0]) : //ROD
                                         mac_uop_xrm_d1==2'd2 ? 1'b0  : //RDN
                                         mac_uop_xrm_d1==2'd1 ? mac_rslt_full_eew16_d1[i*2+j][14] && (|(mac_rslt_full_eew16_d1[i*2+j][13:0]) || mac_rslt_full_eew16_d1[i*2+j][15]) : //RNE
                                                                mac_rslt_full_eew16_d1[i*2+j][14]; //RNU
      vsmul_rslt_eew16_d1[16*(i*2+j) +:16]= mac_rslt_full_eew16_d1[i*2+j][31:30] == 2'b01 ? 16'h7fff : //saturate
                                                                                       mac_rslt_full_eew16_d1[i*2+j][15+:16] + {15'b0,vsmul_round_incr_eew16_d1[i*2+j]};//right shift 15bit then +"1"
      vsmul_sat_eew16_d1[i*2+j] = mac_rslt_full_eew16_d1[i*2+j][31:30] == 2'b01;
      //Below are for vmac related instructions
      vmac_mul_add_eew16_no_widen_d1[i*2+j] = {1'b0,mac_addsrc_d1[16*(i*2+j) +: 16]} + {1'b0,mac_rslt_eew16_no_widen_d1[16*(i*2+j) +: 16]};//17bit
      vmac_mul_sub_eew16_no_widen_d1[i*2+j] = {1'b0,mac_addsrc_d1[16*(i*2+j) +: 16]} - {1'b0,mac_rslt_eew16_no_widen_d1[16*(i*2+j) +: 16]};
      vmac_rslt_eew16_no_widen_d1[16*(i*2+j) +:16] = mac_mul_reverse_d1 ? vmac_mul_sub_eew16_no_widen_d1[i*2+j][15:0] :
                                                                          vmac_mul_add_eew16_no_widen_d1[i*2+j][15:0];
      vmac_mul_add_eew16_widen_d1[i*2+j] = {1'b0,mac_addsrc_widen_d1[32*(i*2+j) +: 32]} + {1'b0,mac_rslt_eew16_widen_d1[32*(i*2+j) +: 32]};//33bit
      vmac_mul_sub_eew16_widen_d1[i*2+j] = {1'b0,mac_addsrc_widen_d1[32*(i*2+j) +: 32]} - {1'b0,mac_rslt_eew16_widen_d1[32*(i*2+j) +: 32]};
      vmac_rslt_eew16_widen_d1[32*(i*2+j) +: 32] = mac_mul_reverse_d1 ? vmac_mul_sub_eew16_widen_d1[i*2+j][31:0] :
                                                                       vmac_mul_add_eew16_widen_d1[i*2+j][31:0];
    end
  end
end
assign mac_rslt_eew16_d1 = is_vmac_d1 ? mac_is_widen_d1 ? vmac_rslt_eew16_widen_d1[`VLEN-1:0] : //mac widen
                                                          vmac_rslt_eew16_no_widen_d1         : //mac normal
                                        is_vsmul_d1     ? vsmul_rslt_eew16_d1                 : //vsmul
                                        mac_is_widen_d1 ? mac_rslt_eew16_widen_d1[`VLEN-1:0]  : //mul widen
                                                          mac_rslt_eew16_no_widen_d1; //mul normal
assign update_vxsat_eew16_d1 = {vsmul_sat_eew16_d1[7],1'b0,
                                vsmul_sat_eew16_d1[6],1'b0,
                                vsmul_sat_eew16_d1[5],1'b0,
                                vsmul_sat_eew16_d1[4],1'b0,
                                vsmul_sat_eew16_d1[3],1'b0,
                                vsmul_sat_eew16_d1[2],1'b0,
                                vsmul_sat_eew16_d1[1],1'b0,
                                vsmul_sat_eew16_d1[0],1'b0};
//eew32
//full rslt is 64bit
always@(*) begin
  for (i=0; i<4; i=i+1) begin //z
    mac_rslt_full_eew32_d1[i] = {mac8_out_d1[i*16+15],48'b0} + 
                             {{8{mac8_out_d1[i*16+14][15]&&mac_src1_is_signed_d1}},mac8_out_d1[i*16+14],40'b0} + 
                             {{8{mac8_out_d1[i*16+11][15]&&mac_src2_is_signed_d1}},mac8_out_d1[i*16+11],40'b0} + 
                             {{16{mac8_out_d1[i*16+13][15]&& mac_src1_is_signed_d1}},mac8_out_d1[i*16+13],32'b0} + 
                             {16'b0,mac8_out_d1[i*16+10],32'b0} + 
                             {{16{mac8_out_d1[i*16+7][15]&&mac_src2_is_signed_d1}},mac8_out_d1[i*16+7],32'b0} + 
                             {{24{mac8_out_d1[i*16+12][15]&& mac_src1_is_signed_d1}},mac8_out_d1[i*16+12],24'b0} + 
                             {24'b0,mac8_out_d1[i*16+9],24'b0} +
                             {24'b0,mac8_out_d1[i*16+6],24'b0} + 
                             {{24{mac8_out_d1[i*16+3][15]&&mac_src2_is_signed_d1}},mac8_out_d1[i*16+3],24'b0} + 
                             {32'b0,mac8_out_d1[i*16+8],16'b0} + 
                             {32'b0,mac8_out_d1[i*16+5],16'b0} +
                             {32'b0,mac8_out_d1[i*16+2],16'b0} + 
                             {40'b0,mac8_out_d1[i*16+4],8'b0} + 
                             {40'b0,mac8_out_d1[i*16+1],8'b0} + 
                             {48'b0,mac8_out_d1[i*16]};
    mac_rslt_eew32_widen_d1[64*i +: 64] = mac_rslt_full_eew32_d1[i];//widen, and convert to [255:0]
    mac_rslt_eew32_no_widen_d1[32*i +: 32] = mac_keep_low_bits_d1 ? mac_rslt_full_eew32_d1[i][31:0] : mac_rslt_full_eew32_d1[i][63:32];
    //Below are for rounding mac (vsmul.vv, vsmul.vx)
    //right shift bit is 32-1=31 not 32 !
    //(TODO) Improve to make this readable
    vsmul_round_incr_eew32_d1[i] = mac_uop_xrm_d1==2'd3 ? !mac_rslt_full_eew32_d1[i][31] && (|mac_rslt_full_eew32_d1[i][30:0]) : //ROD
                                   mac_uop_xrm_d1==2'd2 ? 1'b0  : //RDN
                                   mac_uop_xrm_d1==2'd1 ? mac_rslt_full_eew32_d1[i][30] && (|(mac_rslt_full_eew32_d1[i][29:0]) || mac_rslt_full_eew32_d1[i][31]) : //RNE
                                                          mac_rslt_full_eew32_d1[i][30]; //RNU      
    vsmul_rslt_eew32_d1[32*i +:32]= mac_rslt_full_eew32_d1[i][63:62] == 2'b01 ? 32'h7fff_ffff : //saturate
                                                                             mac_rslt_full_eew32_d1[i][31+:32] + {31'b0,vsmul_round_incr_eew32_d1[i]};//right shift 31bit then +"1"
    vsmul_sat_eew32_d1[i] = mac_rslt_full_eew32_d1[i][63:62] == 2'b01;
    //Below are for vmac related instructions
    vmac_mul_add_eew32_no_widen_d1[i] = {1'b0,mac_addsrc_d1[32*i +: 32]} + {1'b0,mac_rslt_eew32_no_widen_d1[32*i +: 32]};//33bit
    vmac_mul_sub_eew32_no_widen_d1[i] = {1'b0,mac_addsrc_d1[32*i +: 32]} - {1'b0,mac_rslt_eew32_no_widen_d1[32*i +: 32]};
    vmac_rslt_eew32_no_widen_d1[32*i +:32] = mac_mul_reverse_d1 ? vmac_mul_sub_eew32_no_widen_d1[i][31:0] :
                                                                  vmac_mul_add_eew32_no_widen_d1[i][31:0];
    vmac_mul_add_eew32_widen_d1[i] = {1'b0,mac_addsrc_widen_d1[64*i +: 64]} + {1'b0,mac_rslt_eew32_widen_d1[64*i +: 64]};//65bit
    vmac_mul_sub_eew32_widen_d1[i] = {1'b0,mac_addsrc_widen_d1[64*i +: 64]} - {1'b0,mac_rslt_eew32_widen_d1[64*i +: 64]};
    vmac_rslt_eew32_widen_d1[64*i +: 64] = mac_mul_reverse_d1 ? vmac_mul_sub_eew32_widen_d1[i][63:0] :
                                                               vmac_mul_add_eew32_widen_d1[i][63:0];
  end
end
assign mac_rslt_eew32_d1 = is_vmac_d1 ? mac_is_widen_d1 ? vmac_rslt_eew32_widen_d1[`VLEN-1:0] : //mac widen
                                                          vmac_rslt_eew32_no_widen_d1         : //mac normal
                                        is_vsmul_d1     ? vsmul_rslt_eew32_d1 : //vsmul
                                        mac_is_widen_d1 ? mac_rslt_eew32_widen_d1[`VLEN-1:0] : //mul widen
                                                          mac_rslt_eew32_no_widen_d1; //mul normal
assign update_vxsat_eew32_d1 = {vsmul_sat_eew32_d1[3],3'b0,
                                vsmul_sat_eew32_d1[2],3'b0,
                                vsmul_sat_eew32_d1[1],3'b0,
                                vsmul_sat_eew32_d1[0],3'b0};
//Output pack
assign mac2rob_uop_valid = rs2mac_uop_valid_d1;

assign mac2rob_uop_data.rob_entry = mac_uop_rob_entry_d1;
assign mac2rob_uop_data.w_data = mac_top_vs_eew_d1==EEW32 ? mac_rslt_eew32_d1 : 
                                 mac_top_vs_eew_d1==EEW16 ? mac_rslt_eew16_d1 :
                                                            mac_rslt_eew8_d1; //all possible cases are 8/16/32
assign mac2rob_uop_data.w_valid = rs2mac_uop_valid_d1;
assign mac2rob_uop_data.vsaturate = is_vsmul_d1 ? mac_top_vs_eew_d1==EEW32 ? update_vxsat_eew32_d1 :
                                                  mac_top_vs_eew_d1==EEW16 ? update_vxsat_eew16_d1 :
                                                                             update_vxsat_eew8_d1  :
                                                                             {`VLENB{1'b0}};
`ifdef TB_SUPPORT
assign mac2rob_uop_data.uop_pc = mac_uop_pc_d1;
`endif
endmodule
