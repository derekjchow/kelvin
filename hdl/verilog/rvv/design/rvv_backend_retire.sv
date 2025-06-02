/*
description:
1. It will get retired uops from ROB, and write the results back to VRF/XRF 

feature list:
1. This module is all combinational logic!!!
2. Input has 4 entries. The 4 entries have their dependency. 0(oldest) > 1 > 2 > 3(latest)
3. This module decodes the uop info from ROB
4. Write back to VRF
  4.1. Generate mask(strobe) based on Byte-enable locally
  4.2. Check vector write-after-write (WAW), and update mask to one-hot type
  4.3. Pack data to VRF struct
5. Write back to XRF
  5.1. Pack data to XRF struct
6. Check trap flag, clean the latter valid after trap uop
7. Write VCSR when trap occurs
8. There are 4 write ports for VRF, 4 write ports for XRF. RVS arbitrates write ports of XRF by itself
*/

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif

module rvv_backend_retire(/*AUTOARG*/
   // Outputs
   rt2rob_write_ready, 
   rt2xrf_write_valid, rt2xrf_write_data, 
   rt2vrf_write_valid, rt2vrf_write_data, 
   rt2vcsr_write_valid, rt2vcsr_write_data, 
   rt2vxsat_write_valid, rt2vxsat_write_data,
   // Inputs
   rob2rt_write_valid, rob2rt_write_data,
   xrf2rt_write_ready, vcsr2rt_write_ready,
   vxsat2rt_write_ready
   );
// global signal
// Pure combinational logic, thus no clk no rst_n

// ROB dataout
    input   logic    [`NUM_RT_UOP-1:0]  rob2rt_write_valid;
    input   ROB2RT_t [`NUM_RT_UOP-1:0]  rob2rt_write_data;
    output  logic    [`NUM_RT_UOP-1:0]  rt2rob_write_ready;

// write back to XRF
    output  logic    [`NUM_RT_UOP-1:0]  rt2xrf_write_valid;
    output  RT2XRF_t [`NUM_RT_UOP-1:0]  rt2xrf_write_data;
    input   logic    [`NUM_RT_UOP-1:0]  xrf2rt_write_ready;

// write back to VRF
    output  logic    [`NUM_RT_UOP-1:0]  rt2vrf_write_valid;
    output  RT2VRF_t [`NUM_RT_UOP-1:0]  rt2vrf_write_data;//update vrf has no ready @output

// write to update vcsr
    output  logic                       rt2vcsr_write_valid;
    output  RVVConfigState              rt2vcsr_write_data;
    input   logic                       vcsr2rt_write_ready;

// vxsat
    output  logic                             rt2vxsat_write_valid;
    output  logic   [`VCSR_VXSAT_WIDTH-1:0]   rt2vxsat_write_data;
    input   logic                             vxsat2rt_write_ready;

////////////Wires & Regs  ///////////////
logic                            w_type0;
logic                            w_type1;
logic                            w_type2;
logic                            w_type3;

BYTE_TYPE_t                      vd_type0;
BYTE_TYPE_t                      vd_type1;
BYTE_TYPE_t                      vd_type2;
BYTE_TYPE_t                      vd_type3;

logic [`VLENB-1:0]               w_enB0;
logic [`VLENB-1:0]               w_enB1;
logic [`VLENB-1:0]               w_enB2;
logic [`VLENB-1:0]               w_enB3;

logic [`REGFILE_INDEX_WIDTH-1:0] w_addr0;
logic [`REGFILE_INDEX_WIDTH-1:0] w_addr1;
logic [`REGFILE_INDEX_WIDTH-1:0] w_addr2;
logic [`REGFILE_INDEX_WIDTH-1:0] w_addr3;

logic                            w_valid0;
logic                            w_valid1;
logic                            w_valid2;
logic                            w_valid3;

logic [`VLEN-1:0]                w_data0;
logic [`VLEN-1:0]                w_data1;
logic [`VLEN-1:0]                w_data2;
logic [`VLEN-1:0]                w_data3;

logic                            trap_flag0;
logic                            trap_flag1;
logic                            trap_flag2;
logic                            trap_flag3;

RVVConfigState                  w_vcsr0;
RVVConfigState                  w_vcsr1;
RVVConfigState                  w_vcsr2;
RVVConfigState                  w_vcsr3;

logic [`VLENB-1:0]              w_vxsaturate0;
logic [`VLENB-1:0]              w_vxsaturate1;
logic [`VLENB-1:0]              w_vxsaturate2;
logic [`VLENB-1:0]              w_vxsaturate3;

logic [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat0;
logic [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat1;
logic [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat2;
logic [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat3;

logic [`NUM_RT_UOP-1:0]          rob2rt_is_to_vrf;

logic [`VLENB-1:0]               waw2_in_enB0;
logic [`REGFILE_INDEX_WIDTH-1:0] waw2_in_addr0;
logic [`VLENB-1:0]               waw2_in_enB1;
logic [`REGFILE_INDEX_WIDTH-1:0] waw2_in_addr1;
logic [`VLENB-1:0]               w_enB0_waw2_int;

logic [`VLENB-1:0]               waw3_in_enB0;
logic [`REGFILE_INDEX_WIDTH-1:0] waw3_in_addr0;
logic [`VLENB-1:0]               waw3_in_enB1;
logic [`REGFILE_INDEX_WIDTH-1:0] waw3_in_addr1;
logic [`VLENB-1:0]               waw3_in_enB2;
logic [`REGFILE_INDEX_WIDTH-1:0] waw3_in_addr2;
logic [`VLENB-1:0]               w_enB0_waw3_int;
logic [`VLENB-1:0]               w_enB1_waw3_int;

logic [`VLENB-1:0]               waw4_in_enB0;
logic [`REGFILE_INDEX_WIDTH-1:0] waw4_in_addr0;
logic [`VLENB-1:0]               waw4_in_enB1;
logic [`REGFILE_INDEX_WIDTH-1:0] waw4_in_addr1;
logic [`VLENB-1:0]               waw4_in_enB2;
logic [`REGFILE_INDEX_WIDTH-1:0] waw4_in_addr2;
logic [`VLENB-1:0]               waw4_in_enB3;
logic [`REGFILE_INDEX_WIDTH-1:0] waw4_in_addr3;
logic [`VLENB-1:0]               w_enB0_waw4_int;
logic [`VLENB-1:0]               w_enB1_waw4_int;
logic [`VLENB-1:0]               w_enB2_waw4_int;

logic [`VLENB-1:0]               w_enB1_waw3_int_tmp;
logic [`VLENB-1:0]               w_enB1_waw4_int_tmp;
logic [`VLENB-1:0]               w_enB2_waw4_int_tmp;

logic [`VLENB-1:0]               w_enB0_mux;
logic [`VLENB-1:0]               w_enB1_mux;
logic [`VLENB-1:0]               w_enB2_mux;
logic [`VLENB-1:0]               w_enB3_mux;

logic                            w_valid0_chkTrap;
logic                            w_valid1_chkTrap;
logic                            w_valid2_chkTrap;
logic                            w_valid3_chkTrap;

logic                            retire_has_trap;
logic                            retire_has_vxsat;
logic                            vxsat2rt_ready_int;

genvar                           j;

/////////////////////////////////
////////////Decode///////////////
/////////////////////////////////
assign w_type0 = rob2rt_write_data[0].w_type; //0:vrf 1:xrf
assign w_type1 = rob2rt_write_data[1].w_type;
assign w_type2 = rob2rt_write_data[2].w_type;
assign w_type3 = rob2rt_write_data[3].w_type;

assign vd_type0 = rob2rt_write_data[0].vd_type;
assign vd_type1 = rob2rt_write_data[1].vd_type;
assign vd_type2 = rob2rt_write_data[2].vd_type;
assign vd_type3 = rob2rt_write_data[3].vd_type;

assign w_addr0 = rob2rt_write_data[0].w_index;
assign w_addr1 = rob2rt_write_data[1].w_index;
assign w_addr2 = rob2rt_write_data[2].w_index;
assign w_addr3 = rob2rt_write_data[3].w_index;

assign w_valid0 = rob2rt_write_data[0].w_valid;
assign w_valid1 = rob2rt_write_data[1].w_valid;
assign w_valid2 = rob2rt_write_data[2].w_valid;
assign w_valid3 = rob2rt_write_data[3].w_valid;

assign w_data0 = rob2rt_write_data[0].w_data;
assign w_data1 = rob2rt_write_data[1].w_data;
assign w_data2 = rob2rt_write_data[2].w_data;
assign w_data3 = rob2rt_write_data[3].w_data;

assign trap_flag0 = rob2rt_write_data[0].trap_flag;
assign trap_flag1 = rob2rt_write_data[1].trap_flag;
assign trap_flag2 = rob2rt_write_data[2].trap_flag;
assign trap_flag3 = rob2rt_write_data[3].trap_flag;

assign w_vcsr0 = rob2rt_write_data[0].vector_csr;
assign w_vcsr1 = rob2rt_write_data[1].vector_csr;
assign w_vcsr2 = rob2rt_write_data[2].vector_csr;
assign w_vcsr3 = rob2rt_write_data[3].vector_csr;

generate
  for (j=0;j<`VLENB;j++) begin: GET_SAT
    assign w_vxsaturate0[j] = (vd_type0[j]==BODY_ACTIVE) ? rob2rt_write_data[0].vxsaturate[j] : 1'b0;
    assign w_vxsaturate1[j] = (vd_type1[j]==BODY_ACTIVE) ? rob2rt_write_data[1].vxsaturate[j] : 1'b0;
    assign w_vxsaturate2[j] = (vd_type2[j]==BODY_ACTIVE) ? rob2rt_write_data[2].vxsaturate[j] : 1'b0;
    assign w_vxsaturate3[j] = (vd_type3[j]==BODY_ACTIVE) ? rob2rt_write_data[3].vxsaturate[j] : 1'b0;
  end
endgenerate

assign w_vxsat0 = w_vxsaturate0!='b0;
assign w_vxsat1 = w_vxsaturate1!='b0;
assign w_vxsat2 = w_vxsaturate2!='b0;
assign w_vxsat3 = w_vxsaturate3!='b0;

/////////////////////////////////
////////////Main  ///////////////
/////////////////////////////////
//1. Check whether uop is a VRF req
assign rob2rt_is_to_vrf[0] = rob2rt_write_valid[0] && !w_type0 && w_valid0;
assign rob2rt_is_to_vrf[1] = rob2rt_write_valid[1] && !w_type1 && w_valid1;
assign rob2rt_is_to_vrf[2] = rob2rt_write_valid[2] && !w_type2 && w_valid2;
assign rob2rt_is_to_vrf[3] = rob2rt_write_valid[3] && !w_type3 && w_valid3;

//2. Mask update if the bit is body-active
always@(*) begin
  for(int i=0; i<`VLENB; i=i+1) begin
    w_enB0[i] = (rob2rt_write_data[0].vd_type[i] == 2'b11);
    w_enB1[i] = (rob2rt_write_data[1].vd_type[i] == 2'b11);
    w_enB2[i] = (rob2rt_write_data[2].vd_type[i] == 2'b11);
    w_enB3[i] = (rob2rt_write_data[3].vd_type[i] == 2'b11);
  end
end

//3. Shared resources for Write-After-Write (WAW) check 
//  3.1. Submodule: WAW among 2 uops
always@(*) begin
  for(int i=0; i<`VLENB; i=i+1) begin
    if (waw2_in_addr0 == waw2_in_addr1) begin//check waw01
      w_enB0_waw2_int[i] = waw2_in_enB0[i] && !waw2_in_enB1[i];
    end
    else begin
      w_enB0_waw2_int[i] = waw2_in_enB0[i];
    end
  end //end for
end

//  3.2. Submodule: WAW among 3 uops
always@(*) begin
  for(int i=0; i<`VLENB; i=i+1) begin
    if (waw3_in_addr1 == waw3_in_addr2) begin //check waw12 first
      w_enB1_waw3_int[i] = waw3_in_enB1[i] && !waw3_in_enB2[i];
      w_enB1_waw3_int_tmp[i] = waw3_in_enB1[i] || waw3_in_enB2[i]; //tmp perform OR to cover 12
      if (waw3_in_addr0 == waw3_in_addr1) begin //waw012 all happens
        w_enB0_waw3_int[i] = waw3_in_enB0[i] && !w_enB1_waw3_int_tmp[i];
      end
      else begin //only waw12
        w_enB0_waw3_int[i] = waw3_in_enB0[i];
      end
    end //end addr1==addr2
    else if (waw3_in_addr0 == waw3_in_addr2) begin //check waw02
      w_enB0_waw3_int[i] = waw3_in_enB0[i] && !waw3_in_enB2[i];
      w_enB1_waw3_int[i] = waw3_in_enB1[i];
    end
    else if (waw3_in_addr0 == waw3_in_addr1) begin //check waw01
      w_enB0_waw3_int[i] = waw3_in_enB0[i] && !waw3_in_enB1[i];
      w_enB1_waw3_int[i] = waw3_in_enB1[i];
    end
    else begin
      w_enB0_waw3_int[i] = waw3_in_enB0[i];
      w_enB1_waw3_int[i] = waw3_in_enB1[i];
    end
  end//end for
end//end always

//  3.3. Submodule: WAW among 4 uops
always@(*) begin
  for(int i=0; i<`VLENB; i=i+1) begin
    if (waw4_in_addr2 == waw4_in_addr3) begin//check waw23 first
      w_enB2_waw4_int[i] = waw4_in_enB2[i] && !waw4_in_enB3[i];
      w_enB2_waw4_int_tmp[i] = waw4_in_enB2[i] || waw4_in_enB3[i]; //tmp perform OR to cover 23
      if (waw4_in_addr1 == waw4_in_addr2) begin //2=3, 1=2
        w_enB1_waw4_int[i] = waw4_in_enB1[i] && !w_enB2_waw4_int_tmp[i];
        w_enB1_waw4_int_tmp[i] = waw4_in_enB1[i] || w_enB2_waw4_int_tmp[i];//tmp perform OR to cover 123
        if (waw4_in_addr0 == waw4_in_addr1) begin //2=3, 1=2, 0=1 #case1
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !w_enB1_waw4_int_tmp[i];
        end
        else begin//2=3, 1=2, 0!=1 #case2
          w_enB0_waw4_int[i] = waw4_in_enB0[i];
        end
      end
      else if (waw4_in_addr0 == waw4_in_addr2) begin //2=3, 1!=2, 0=2 #case3
        w_enB0_waw4_int[i] = waw4_in_enB0[i] && !w_enB2_waw4_int_tmp[i];
        w_enB1_waw4_int[i] = waw4_in_enB1[i];
      end
      else if (waw4_in_addr0 == waw4_in_addr1) begin //2=3, 1!=2, 0=1 #case4
        w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB1[i];
        w_enB1_waw4_int[i] = waw4_in_enB1[i];
      end
      else begin //2=3, 0!=1!=2 #case5
        w_enB0_waw4_int[i] = waw4_in_enB0[i];
        w_enB1_waw4_int[i] = waw4_in_enB1[i];
      end
    end//end 2=3 if
    else begin //2!=3
      w_enB2_waw4_int[i] = waw4_in_enB2[i];
      if (waw4_in_addr1 == waw4_in_addr2) begin //2!=3, 1=2
        w_enB1_waw4_int[i] = waw4_in_enB1[i] && !waw4_in_enB2[i];
        w_enB1_waw4_int_tmp[i] = waw4_in_enB1[i] || waw4_in_enB2[i]; //tmp perform OR to cover 12
        if (waw4_in_addr0 == waw4_in_addr1) begin //2!=3, 1=2, 0=1 #case6
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !w_enB1_waw4_int_tmp[i]; 
        end
        else if (waw4_in_addr0 == waw4_in_addr3) begin //2!=3, 1=2, 0=3 #case7
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB3[i];
        end
        else begin //2!=3, 1=2, 0!=1 && 0!=3 # case8
          w_enB0_waw4_int[i] = waw4_in_enB0[i];
        end
      end
      else if (waw4_in_addr1 == waw4_in_addr3) begin //2!=3, 1!=2, 1=3
        w_enB1_waw4_int[i] = waw4_in_enB1[i] && !waw4_in_enB3[i];
        w_enB1_waw4_int_tmp[i] = waw4_in_enB1[i] || waw4_in_enB3[i]; //tmp perform OR to cover 13
        if (waw4_in_addr0 == waw4_in_addr2) begin //2!=3, 1!=2, 1=3, 0=2 #case9
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB2[i];
        end
        else if (waw4_in_addr0 == waw4_in_addr1) begin //2!=3, 1!=2, 1=3, 0=1 #case10
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !w_enB1_waw4_int_tmp[i];
        end
        else begin //2!=3, 1!=2, 1=3, 0!=1 #case11
          w_enB0_waw4_int[i] = waw4_in_enB0[i];
        end
      end
      else begin //2!=3, 1!=2, 1!=3
        w_enB1_waw4_int[i] = waw4_in_enB1[i];
        if (waw4_in_addr0 == waw4_in_addr3) begin //2!=3, 1!=2, 1!=3, 0=3 #case12
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB3[i];
        end
        else if (waw4_in_addr0 == waw4_in_addr2) begin //2!=3, 1!=2, 1!=3, 0=2 #case13
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB2[i];
        end
        else if (waw4_in_addr0 == waw4_in_addr1) begin //2!=3, 1!=2, 1!=3, 0=1 #case14
          w_enB0_waw4_int[i] = waw4_in_enB0[i] && !waw4_in_enB1[i];
        end
        else begin //4 all different #case15
          w_enB0_waw4_int[i] = waw4_in_enB0[i];
        end
      end
    end//end 2!=3 if
  end//end for
end//end always

//4. Combine vrf group and WAW check
always@(*) begin
  case (rob2rt_is_to_vrf)
    4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000 : begin //only 1 uop is to vrf, not need WAW
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0;
      w_enB1_mux = w_enB1;
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
    4'b0011 : begin //uop 0/1 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB0;
      waw2_in_addr0 = w_addr0;
      waw2_in_enB1 = w_enB1;
      waw2_in_addr1 = w_addr1;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB1_mux = w_enB1;
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b0101 : begin //uop 0/2 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB0;
      waw2_in_addr0 = w_addr0;
      waw2_in_enB1 = w_enB2;
      waw2_in_addr1 = w_addr2;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB1_mux = w_enB1; 
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b0110 : begin //uop 1/2 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB1;
      waw2_in_addr0 = w_addr1;
      waw2_in_enB1 = w_enB2;
      waw2_in_addr1 = w_addr2;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0;
      w_enB1_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b0111 : begin //uop 0/1/2 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = w_enB0;
      waw3_in_addr0 = w_addr0;
      waw3_in_enB1 = w_enB1;
      waw3_in_addr1 = w_addr1;
      waw3_in_enB2 = w_enB2;
      waw3_in_addr2 = w_addr2;
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw3_int; //0 marks for the lowest out of WAW3
      w_enB1_mux = w_enB1_waw3_int; //1 marks for the 2nd lowest out of WAW3 
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
    4'b1001 : begin //uop 0/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB0;
      waw2_in_addr0 = w_addr0;
      waw2_in_enB1 = w_enB3;
      waw2_in_addr1 = w_addr3;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB1_mux = w_enB1; 
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b1010 : begin //uop 1/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB1;
      waw2_in_addr0 = w_addr1;
      waw2_in_enB1 = w_enB3;
      waw2_in_addr1 = w_addr3;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0; 
      w_enB1_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b1011 : begin //uop 0/1/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = w_enB0;
      waw3_in_addr0 = w_addr0;
      waw3_in_enB1 = w_enB1;
      waw3_in_addr1 = w_addr1;
      waw3_in_enB2 = w_enB3;
      waw3_in_addr2 = w_addr3;
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw3_int; //0 marks for the lowest out of WAW3
      w_enB1_mux = w_enB1_waw3_int; //1 marks for the 2nd lowest out of WAW3
      w_enB2_mux = w_enB2; 
      w_enB3_mux = w_enB3;
    end
    4'b1100 : begin //uop 2/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = w_enB2;
      waw2_in_addr0 = w_addr2;
      waw2_in_enB1 = w_enB3;
      waw2_in_addr1 = w_addr3;
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0; 
      w_enB1_mux = w_enB1; 
      w_enB2_mux = w_enB0_waw2_int; //0 marks for the lower out of WAW2
      w_enB3_mux = w_enB3;
    end
    4'b1101 : begin //uop 0/2/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = w_enB0;
      waw3_in_addr0 = w_addr0;
      waw3_in_enB1 = w_enB2;
      waw3_in_addr1 = w_addr2;
      waw3_in_enB2 = w_enB3;
      waw3_in_addr2 = w_addr3;
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0_waw3_int; //0 marks for the lowest out of WAW3
      w_enB1_mux = w_enB1; 
      w_enB2_mux = w_enB1_waw3_int; //1 marks for the 2nd lowest out of WAW3
      w_enB3_mux = w_enB3;
    end
    4'b1110 : begin //uop 1/2/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = w_enB1;
      waw3_in_addr0 = w_addr1;
      waw3_in_enB1 = w_enB2;
      waw3_in_addr1 = w_addr2;
      waw3_in_enB2 = w_enB3;
      waw3_in_addr2 = w_addr3;
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0; 
      w_enB1_mux = w_enB0_waw3_int; //0 marks for the lowest out of WAW3
      w_enB2_mux = w_enB1_waw3_int; //1 marks for the 2nd lowest out of WAW3
      w_enB3_mux = w_enB3;
    end
    4'b1111 : begin //uop 0/1/2/3 are to vrf
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = w_enB0;
      waw4_in_addr0 = w_addr0;
      waw4_in_enB1 = w_enB1;
      waw4_in_addr1 = w_addr1;
      waw4_in_enB2 = w_enB2;
      waw4_in_addr2 = w_addr2;
      waw4_in_enB3 = w_enB3;
      waw4_in_addr3 = w_addr3;
      //Output mux
      w_enB0_mux = w_enB0_waw4_int;
      w_enB1_mux = w_enB1_waw4_int;
      w_enB2_mux = w_enB2_waw4_int;
      w_enB3_mux = w_enB3;
    end
    default : begin
      //Input mux
      //WAW2 part
      waw2_in_enB0 = {`VLENB{1'b0}};
      waw2_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw2_in_enB1 = {`VLENB{1'b0}};
      waw2_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW3 part
      waw3_in_enB0 = {`VLENB{1'b0}};
      waw3_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB1 = {`VLENB{1'b0}};
      waw3_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw3_in_enB2 = {`VLENB{1'b0}};
      waw3_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //WAW4 part
      waw4_in_enB0 = {`VLENB{1'b0}};
      waw4_in_addr0 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB1 = {`VLENB{1'b0}};
      waw4_in_addr1 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB2 = {`VLENB{1'b0}};
      waw4_in_addr2 = {`REGFILE_INDEX_WIDTH{1'b0}};
      waw4_in_enB3 = {`VLENB{1'b0}};
      waw4_in_addr3 = {`REGFILE_INDEX_WIDTH{1'b0}};
      //Output mux
      w_enB0_mux = w_enB0;
      w_enB1_mux = w_enB1;
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
  endcase
end

`ifdef TB_SUPPORT
`ifdef ASSERT_ON
  logic [`NUM_RT_UOP-1:0] [`NUM_RT_UOP-1:0] vidx_eq;
  logic [`NUM_RT_UOP-1:0] [`NUM_RT_UOP-1:0] vstrobe_conflict;

  genvar gv_i, gv_j;
  generate
    for(gv_i=0; gv_i<`NUM_RT_UOP; gv_i++) begin: gen_upper_uops
      for(gv_j=0; gv_j<`NUM_RT_UOP; gv_j++) begin: gen_lower_uops
        if(gv_i > gv_j) begin: gen_check
          assign vidx_eq[gv_i][gv_j] = (rt2vrf_write_valid[gv_i] && rt2vrf_write_valid[gv_j] &&
                                        rt2vrf_write_data[gv_i].rt_index === rt2vrf_write_data[gv_j].rt_index);
          assign vstrobe_conflict[gv_i][gv_j] = vidx_eq[gv_i][gv_j] && |(rt2vrf_write_data[gv_i].rt_strobe & rt2vrf_write_data[gv_j].rt_strobe);
          VRFWriteStrobeConflict: `rvv_forbid(vstrobe_conflict[gv_i][gv_j])
            else $error("Uop %0d write to vrf[%0d] with strobe = 0x%4h\nUop %0d write to vrf[%0d] with strobe = 0x%4h\n",
                        gv_i, $sampled(rt2vrf_write_data[gv_i].rt_index), $sampled(rt2vrf_write_data[gv_i].rt_strobe),
                        gv_j, $sampled(rt2vrf_write_data[gv_j].rt_index), $sampled(rt2vrf_write_data[gv_j].rt_strobe));
        end else begin: gen_ignore_check
          assign vidx_eq[gv_i][gv_j] = '0;
          assign vstrobe_conflict[gv_i][gv_j] = '0;
        end
      end
    end
  endgenerate 

`endif // ASSERT_ON
`endif // TB_SUPPORT

//5. OutValid generation & OutData pack
//  5.1. When trap, clean the latter valid
assign w_valid0_chkTrap = !trap_flag0 && w_valid0;
assign w_valid1_chkTrap = !trap_flag0 && w_valid1;
assign w_valid2_chkTrap = !(trap_flag0 || trap_flag1) && w_valid2;
assign w_valid3_chkTrap = !(trap_flag0 || trap_flag1 || trap_flag2) && w_valid3;

//  5.2. To VRF
assign rt2vrf_write_valid[0] = rob2rt_write_valid[0] && w_valid0_chkTrap && !w_type0;
assign rt2vrf_write_valid[1] = rob2rt_write_valid[1] && w_valid1_chkTrap && !w_type1;
assign rt2vrf_write_valid[2] = rob2rt_write_valid[2] && w_valid2_chkTrap && !w_type2;
assign rt2vrf_write_valid[3] = rob2rt_write_valid[3] && w_valid3_chkTrap && !w_type3;
//Data
assign rt2vrf_write_data[0].rt_data = w_data0;
assign rt2vrf_write_data[1].rt_data = w_data1;
assign rt2vrf_write_data[2].rt_data = w_data2;
assign rt2vrf_write_data[3].rt_data = w_data3;
//Addr
assign rt2vrf_write_data[0].rt_index = w_addr0;
assign rt2vrf_write_data[1].rt_index = w_addr1;
assign rt2vrf_write_data[2].rt_index = w_addr2;
assign rt2vrf_write_data[3].rt_index = w_addr3;
//Byte Mask
assign rt2vrf_write_data[0].rt_strobe = w_enB0_mux;
assign rt2vrf_write_data[1].rt_strobe = w_enB1_mux;
assign rt2vrf_write_data[2].rt_strobe = w_enB2_mux;
assign rt2vrf_write_data[3].rt_strobe = w_enB3_mux;
`ifdef TB_SUPPORT
//pc
assign rt2vrf_write_data[0].uop_pc = rob2rt_write_data[0].uop_pc;
assign rt2vrf_write_data[1].uop_pc = rob2rt_write_data[1].uop_pc;
assign rt2vrf_write_data[2].uop_pc = rob2rt_write_data[2].uop_pc;
assign rt2vrf_write_data[3].uop_pc = rob2rt_write_data[3].uop_pc;
`endif

//  5.3. To XRF
assign rt2xrf_write_valid[0] = rob2rt_write_valid[0] && w_valid0_chkTrap && w_type0;
assign rt2xrf_write_valid[1] = rob2rt_write_valid[1] && w_valid1_chkTrap && w_type1;
assign rt2xrf_write_valid[2] = rob2rt_write_valid[2] && w_valid2_chkTrap && w_type2;
assign rt2xrf_write_valid[3] = rob2rt_write_valid[3] && w_valid3_chkTrap && w_type3;
//Data
assign rt2xrf_write_data[0].rt_data = w_data0[`XLEN-1:0];
assign rt2xrf_write_data[1].rt_data = w_data1[`XLEN-1:0];
assign rt2xrf_write_data[2].rt_data = w_data2[`XLEN-1:0];
assign rt2xrf_write_data[3].rt_data = w_data3[`XLEN-1:0];
//Addr
assign rt2xrf_write_data[0].rt_index = w_addr0;
assign rt2xrf_write_data[1].rt_index = w_addr1;
assign rt2xrf_write_data[2].rt_index = w_addr2;
assign rt2xrf_write_data[3].rt_index = w_addr3;
`ifdef TB_SUPPORT
//pc
assign rt2xrf_write_data[0].uop_pc = rob2rt_write_data[0].uop_pc;
assign rt2xrf_write_data[1].uop_pc = rob2rt_write_data[1].uop_pc;
assign rt2xrf_write_data[2].uop_pc = rob2rt_write_data[2].uop_pc;
assign rt2xrf_write_data[3].uop_pc = rob2rt_write_data[3].uop_pc;
`endif
//  5.4. To VCSR
//In our current arch, only uop0 can contain a trap in each cycle
//Valid
assign retire_has_trap = trap_flag0;
assign rt2vcsr_write_valid = rob2rt_write_valid[0] && retire_has_trap;
//Data
assign rt2vcsr_write_data =  w_vcsr0;

//  5.5. To vxsat
assign retire_has_vxsat = (w_valid3_chkTrap && w_vxsat3) || (w_valid2_chkTrap && w_vxsat2) || (w_valid1_chkTrap && w_vxsat1) || (w_valid0_chkTrap && w_vxsat0);
assign rt2vxsat_write_valid = (rob2rt_write_valid[3] && w_valid3_chkTrap && w_vxsat3) || 
                              (rob2rt_write_valid[2] && w_valid2_chkTrap && w_vxsat2) || 
                              (rob2rt_write_valid[1] && w_valid1_chkTrap && w_vxsat1) || 
                              (rob2rt_write_valid[0] && w_valid0_chkTrap && w_vxsat0);
assign rt2vxsat_write_data = w_vxsat3 || w_vxsat2 || w_vxsat1 || w_vxsat0;

//6. Ready generation
//Rob can only issue two cases:
//  a. all uops are valid without trap
//  b. uop0 contains trap

//this int is 1 when: 
//  a. 4 uops have no vxsat update; 
//  b. has vxsat update while vxsat rdy == 1
assign vxsat2rt_ready_int = !retire_has_vxsat || vxsat2rt_write_ready; 

assign rt2rob_write_ready[0] = retire_has_trap ? vcsr2rt_write_ready :   //use vcrs rdy
                                       w_type0 ? xrf2rt_write_ready[0] : //xrf rdy but check vxsat
                                                 vxsat2rt_ready_int;                           //vrf rdy but check vxsat, equals to (1'b1 && vxsat2rt_ready_int)
assign rt2rob_write_ready[1] = w_type1 ? xrf2rt_write_ready[1] :         //xrf rdy but check vxsat
                                         vxsat2rt_ready_int;                                   //vrf rdy but check vxsat, equals to (1'b1 && vxsat2rt_ready_int)
assign rt2rob_write_ready[2] = w_type2 ? xrf2rt_write_ready[2] :
                                         vxsat2rt_ready_int;
assign rt2rob_write_ready[3] = w_type3 ? xrf2rt_write_ready[3] : 
                                         vxsat2rt_ready_int ;
/////////////////////////////////

endmodule
