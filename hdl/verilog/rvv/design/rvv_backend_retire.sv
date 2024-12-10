/*
description:
1. It will get retired uops from ROB, and write the results back to VRF/XRF 

feature list:
1. This module is all combinational logic!!!
2. Input has 4 entries. The 4 entries have their dependency. 0(oldest) > 1 > 2 > 3(latest)
3. This module decodes the uop info from ROB
4. Write back to VRF
  4.1. Generate mask(strobe) based on vma/vta policy
    4.1.1 When ignore_vta && ignore_vma, need to retire entire 128 bit of this entry
		      Otherwise need to generate Byte-enable locally
  4.2. Check vector write-after-write (WAW), and update mask to one-hot type
  4.3. Pack data to VRF struct
5. Write back to XRF
  5.1. Pack data to XRF struct
6. Check trap flag, clean the latter valid after trap uop
7. Write VCSR when trap occurs
8. There are 4 write ports for VRF, 4 write ports for XRF. RVS arbitrates write ports of XRF by itself
*/

`include "rvv_backend.svh"

module rvv_backend_retire(/*AUTOARG*/
   // Outputs
   rob2rt_write_ready, rt2xrf_write_data, 
   rt2vrf_write_data, rt2vcsr_write_valid, 
   rt2vcsr_write_data, rt2vsat_write_valid, 
   rt2vsat_write_data,
   // Inputs
   rob2rt_write_valid, rob2rt_write_data,
   rt2xrf_write_ready
   );
// global signal
// Pure combinational logic, thus no clk no rst_n

// ROB dataout
    input   logic    [`NUM_RT_UOP-1:0]  rob2rt_write_valid;
    input   ROB2RT_t [`NUM_RT_UOP-1:0]  rob2rt_write_data;
    output  logic    [`NUM_RT_UOP-1:0]  rob2rt_write_ready;

// write back to XRF
    output  RT2XRF_t                    rt2xrf_write_data;//entry valid is packed inside
    input   logic    [`NUM_RT_UOP-1:0]  rt2xrf_write_ready;

// write back to VRF
    output  RT2VRF_t                    rt2vrf_write_data;//update vrf has no ready @output

// write to update vcsr
    output  logic                       rt2vcsr_write_valid;
    output  RVVConfigState              rt2vcsr_write_data;

// vxsat
    output  logic                       rt2vsat_write_valid;
    output  logic   [`VCSR_VXSAT_WIDTH-1:0]   rt2vsat_write_data;

////////////Wires & Regs  ///////////////
wire                            w_type0;
wire                            w_type1;
wire                            w_type2;
wire                            w_type3;

reg [`VLENB-1:0]                w_enB0_tmp;
reg [`VLENB-1:0]                w_enB1_tmp;
reg [`VLENB-1:0]                w_enB2_tmp;
reg [`VLENB-1:0]                w_enB3_tmp;

wire [`VLENB-1:0]               w_enB0;
wire [`VLENB-1:0]               w_enB1;
wire [`VLENB-1:0]               w_enB2;
wire [`VLENB-1:0]               w_enB3;

wire [`REGFILE_INDEX_WIDTH-1:0] w_addr0;
wire [`REGFILE_INDEX_WIDTH-1:0] w_addr1;
wire [`REGFILE_INDEX_WIDTH-1:0] w_addr2;
wire [`REGFILE_INDEX_WIDTH-1:0] w_addr3;

wire                            w_valid0;
wire                            w_valid1;
wire                            w_valid2;
wire                            w_valid3;

wire [`VLEN-1:0]                w_data0;
wire [`VLEN-1:0]                w_data1;
wire [`VLEN-1:0]                w_data2;
wire [`VLEN-1:0]                w_data3;

wire                            trap_flag0;
wire                            trap_flag1;
wire                            trap_flag2;
wire                            trap_flag3;

RVVConfigState                  w_vcsr0;
RVVConfigState                  w_vcsr1;
RVVConfigState                  w_vcsr2;
RVVConfigState                  w_vcsr3;

wire [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat0;
wire [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat1;
wire [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat2;
wire [`VCSR_VXSAT_WIDTH-1:0]    w_vxsat3;

wire                            ignore_vta0;
wire                            ignore_vta1;
wire                            ignore_vta2;
wire                            ignore_vta3;

wire                            ignore_vma0;
wire                            ignore_vma1;
wire                            ignore_vma2;
wire                            ignore_vma3;

wire dst1_eq_dst0, dst2_eq_dst1, dst3_eq_dst2;
reg [1:0]                       group_req;

reg [`VLENB-1:0]                w_enB0_waw01_int;
reg [`VLENB-1:0]                w_enB0_waw012_int;
reg [`VLENB-1:0]                w_enB1_waw012_int;
reg [`VLENB-1:0]                w_enB0_waw0123_int;
reg [`VLENB-1:0]                w_enB1_waw0123_int;
reg [`VLENB-1:0]                w_enB2_waw0123_int;

reg [`VLENB-1:0]                w_enB0_mux;
reg [`VLENB-1:0]                w_enB1_mux;
reg [`VLENB-1:0]                w_enB2_mux;
reg [`VLENB-1:0]                w_enB3_mux;

wire                            w_valid0_chkTrap;
wire                            w_valid1_chkTrap;
wire                            w_valid2_chkTrap;
wire                            w_valid3_chkTrap;

/////////////////////////////////
////////////Decode///////////////
/////////////////////////////////
assign w_type0 = rob2rt_write_data[0].w_type; //0:vrf 1:xrf
assign w_type1 = rob2rt_write_data[1].w_type;
assign w_type2 = rob2rt_write_data[2].w_type;
assign w_type3 = rob2rt_write_data[3].w_type;

integer i;
always@(*) begin
  for (i=0; i<`VLENB; i=i+1) begin
    w_enB0_tmp[i] = (rob2rt_write_data[0].vd_type[i] == 2'b11);
    w_enB1_tmp[i] = (rob2rt_write_data[1].vd_type[i] == 2'b11);
    w_enB2_tmp[i] = (rob2rt_write_data[2].vd_type[i] == 2'b11);
    w_enB3_tmp[i] = (rob2rt_write_data[3].vd_type[i] == 2'b11);
  end
end

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

assign w_vxsat0 = rob2rt_write_data[0].vxsat;
assign w_vxsat1 = rob2rt_write_data[1].vxsat;
assign w_vxsat2 = rob2rt_write_data[2].vxsat;
assign w_vxsat3 = rob2rt_write_data[3].vxsat;

assign ignore_vta0 = rob2rt_write_data[0].ignore_vta;
assign ignore_vta1 = rob2rt_write_data[1].ignore_vta;
assign ignore_vta2 = rob2rt_write_data[2].ignore_vta;
assign ignore_vta3 = rob2rt_write_data[3].ignore_vta;

assign ignore_vma0 = rob2rt_write_data[0].ignore_vma;
assign ignore_vma1 = rob2rt_write_data[1].ignore_vma;
assign ignore_vma2 = rob2rt_write_data[2].ignore_vma;
assign ignore_vma3 = rob2rt_write_data[3].ignore_vma;

/////////////////////////////////
////////////Main  ///////////////
/////////////////////////////////
//1. Group VRF/XRF req
assign dst1_eq_dst0 = ({rob2rt_write_valid[1],w_type1} == {rob2rt_write_valid[0],w_type0});
assign dst2_eq_dst1 = ({rob2rt_write_valid[2],w_type2} == {rob2rt_write_valid[1],w_type1});
assign dst3_eq_dst2 = ({rob2rt_write_valid[3],w_type3} == {rob2rt_write_valid[2],w_type2});

always@(*) begin
  if (dst1_eq_dst0) begin
    if (dst2_eq_dst1) begin
      if (dst3_eq_dst2) begin
        group_req = 2'd3;
      end
      else begin
        group_req = 2'd2;
      end
    end
    else begin
      group_req = 2'd1;
    end
  end
  else begin
    group_req = 2'd0;
  end
end

//2. Mask update if ignore vta/vma
assign w_enB0 = (ignore_vta0 && ignore_vma0) ? `VLENB'b1 : w_enB0_tmp;
assign w_enB1 = (ignore_vta1 && ignore_vma1) ? `VLENB'b1 : w_enB1_tmp;
assign w_enB2 = (ignore_vta2 && ignore_vma2) ? `VLENB'b1 : w_enB2_tmp;
assign w_enB3 = (ignore_vta3 && ignore_vma3) ? `VLENB'b1 : w_enB3_tmp;

//3. Write-After-Write (WAW) check
//  3.1. WAW among entry0 entry1, for group_req=1
always@(*) begin
  for (i=0; i<`VLENB; i=i+1) begin
    //when enB1[i]=enB0[i]=1, update enB0 to 0
    w_enB0_waw01_int[i] = w_enB0[i] && !w_enB1[i];
  end //end for
end

//  3.2. WAW among entry0 entry1 entry2, for group_req=2
always@(*) begin
  for (i=0; i<`VLENB; i=i+1) begin
    if (w_addr1 == w_addr2) begin //check waw12 first
      w_enB1_waw012_int[i] = w_enB1[i] && !w_enB2[i];
      if (w_addr0 == w_addr1) begin //waw012 all happens
        w_enB0_waw012_int[i] = w_enB0[i] && !w_enB1_waw012_int[i];
      end
      else begin //only waw12
        w_enB0_waw012_int[i] = w_enB0[i];
      end
    end //end addr1==addr2
    else if (w_addr0 == w_addr2) begin //check waw02
      w_enB0_waw012_int[i] = w_enB0[i] && !w_enB2[i];
      w_enB1_waw012_int[i] = w_enB1[i];
    end
    else if (w_addr0 == w_addr1) begin //check waw01
      w_enB0_waw012_int[i] = w_enB0[i] && !w_enB1[i];
      w_enB1_waw012_int[i] = w_enB1[i];
    end
    else begin
      w_enB0_waw012_int[i] = w_enB0[i];
      w_enB1_waw012_int[i] = w_enB1[i];
    end
  end//end for
end//end always

//  3.3. WAW among entry0 entry1 entry2 entry3, for group_req=3
always@(*) begin
  for (i=0; i<`VLENB; i=i+1) begin
    if (w_addr2 == w_addr3) begin//check waw23 first
      w_enB2_waw0123_int[i] = w_enB2[i] && !w_enB3[i];
      if (w_addr1 == w_addr2) begin //2=3, 1=2
        w_enB1_waw0123_int[i] = w_enB1[i] && !w_enB2_waw0123_int[i];
        if (w_addr0 == w_addr1) begin //2=3, 1=2, 0=1 #case1
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB1_waw0123_int[i];
        end
        else begin//2=3, 1=2, 0!=1 #case2
          w_enB0_waw0123_int[i] = w_enB0[i];
        end
      end
      else if (w_addr0 == w_addr2) begin //2=3, 1!=2, 0=2 #case3
        w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB2_waw0123_int[i];
        w_enB1_waw0123_int[i] = w_enB1[i];
      end
      else if (w_addr0 == w_addr1) begin //2=3, 1!=2, 0=1 #case4
        w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB1[i];
        w_enB1_waw0123_int[i] = w_enB1[i];
      end
      else begin //2=3, 0!=1!=2 #case5
        w_enB0_waw0123_int[i] = w_enB0[i];
        w_enB1_waw0123_int[i] = w_enB1[i];
      end
    end//end 2=3 if
    else begin //2!=3
      w_enB2_waw0123_int[i] = w_enB2[i];
      if (w_addr1 == w_addr2) begin //2!=3, 1=2
        w_enB1_waw0123_int[i] = w_enB1[i] && !w_enB2[i];
        if (w_addr0 == w_addr1) begin //2!=3, 1=2, 0=1 #case6
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB1_waw0123_int[i];
        end
        else if (w_addr0 == w_addr3) begin //2!=3, 1=2, 0=3 #case7
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB3[i];
        end
        else begin //2!=3, 1=2, 0!=1 && 0!=3 # case8
          w_enB0_waw0123_int[i] = w_enB0[i];
        end
      end
      else if (w_addr1 == w_addr3) begin //2!=3, 1!=2, 1=3
        w_enB1_waw0123_int[i] = w_enB1[i] && !w_enB3[i];
        if (w_addr0 == w_addr2) begin //2!=3, 1!=2, 1=3, 0=1 #case9
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB2_waw0123_int[i];
        end
        else if (w_addr0 == w_addr1) begin //2!=3, 1!=2, 1=3, 0=1 #case10
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB1_waw0123_int[i];
        end
        else begin //2!=3, 1!=2, 1=3, 0!=1 #case11
          w_enB0_waw0123_int[i] = w_enB0[i];
        end
      end
      else begin //2!=3, 1!=2, 1!=3
        w_enB1_waw0123_int[i] = w_enB1[i];
        if (w_addr0 == w_addr3) begin //2!=3, 1!=2, 1!=3, 0=3 #case12
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB3[i];
        end
        else if (w_addr0 == w_addr2) begin //2!=3, 1!=2, 1!=3, 0=2 #case13
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB2_waw0123_int[i];
        end
        else if (w_addr0 == w_addr1) begin //2!=3, 1!=2, 1!=3, 0=1 #case14
          w_enB0_waw0123_int[i] = w_enB0[i] && !w_enB1_waw0123_int[i];
        end
        else begin //4 all different #case15
          w_enB0_waw0123_int[i] = w_enB0[i];
        end
      end
    end//end 2!=3 if
  end//end for
end//end always

//4. Combine group_req and WAW check
always@(*) begin
  case (group_req)
    2'd3 : begin //0123 all to same dst
      w_enB0_mux = w_enB0_waw0123_int;
      w_enB1_mux = w_enB1_waw0123_int;
      w_enB2_mux = w_enB2_waw0123_int;
      w_enB3_mux = w_enB3;
    end
    2'd2 : begin //012 to same dst
      w_enB0_mux = w_enB0_waw012_int;
      w_enB1_mux = w_enB1_waw012_int;
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
    2'd1 : begin //01 to same dst
      w_enB0_mux = w_enB0_waw01_int;
      w_enB1_mux = w_enB1;
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
    default : begin //cant group
      w_enB0_mux = w_enB0;
      w_enB1_mux = w_enB1;
      w_enB2_mux = w_enB2;
      w_enB3_mux = w_enB3;
    end
  endcase
end

//5. OutValid generation & OutData pack
//  5.1. When trap, clean the latter valid
assign w_valid0_chkTrap = w_valid0;
assign w_valid1_chkTrap = !trap_flag0 && w_valid1;
assign w_valid2_chkTrap = !(trap_flag0 || trap_flag1) && w_valid2;
assign w_valid3_chkTrap = !(trap_flag0 || trap_flag1 || trap_flag2) && w_valid3;

//  5.2. To VRF
assign rt2vrf_write_data.rt2vrf_wr_valid[0] = w_valid0_chkTrap && !w_type0;
assign rt2vrf_write_data.rt2vrf_wr_valid[1] = w_valid1_chkTrap && !w_type1;
assign rt2vrf_write_data.rt2vrf_wr_valid[2] = w_valid2_chkTrap && !w_type2;
assign rt2vrf_write_data.rt2vrf_wr_valid[3] = w_valid3_chkTrap && !w_type3;
//Data
assign rt2vrf_write_data.rt2vrf_wr_data[0].rt_data = w_data0;
assign rt2vrf_write_data.rt2vrf_wr_data[1].rt_data = w_data1;
assign rt2vrf_write_data.rt2vrf_wr_data[2].rt_data = w_data2;
assign rt2vrf_write_data.rt2vrf_wr_data[3].rt_data = w_data3;
//Addr
assign rt2vrf_write_data.rt2vrf_wr_data[0].rt_index = w_addr0;
assign rt2vrf_write_data.rt2vrf_wr_data[1].rt_index = w_addr1;
assign rt2vrf_write_data.rt2vrf_wr_data[2].rt_index = w_addr2;
assign rt2vrf_write_data.rt2vrf_wr_data[3].rt_index = w_addr3;
//Byte Mask
assign rt2vrf_write_data.rt2vrf_wr_data[0].rt_strobe = w_enB0_mux;
assign rt2vrf_write_data.rt2vrf_wr_data[1].rt_strobe = w_enB1_mux;
assign rt2vrf_write_data.rt2vrf_wr_data[2].rt_strobe = w_enB2_mux;
assign rt2vrf_write_data.rt2vrf_wr_data[3].rt_strobe = w_enB3_mux;

//  5.3. To XRF
assign rt2xrf_write_data.rt2xrf_wr_valid[0] = w_valid0_chkTrap && w_type0;
assign rt2xrf_write_data.rt2xrf_wr_valid[1] = w_valid1_chkTrap && w_type1;
assign rt2xrf_write_data.rt2xrf_wr_valid[2] = w_valid2_chkTrap && w_type2;
assign rt2xrf_write_data.rt2xrf_wr_valid[3] = w_valid3_chkTrap && w_type3;
//Data
assign rt2xrf_write_data.rt2xrf_wr_data[0].rt_data = w_data0[`XLEN-1:0];
assign rt2xrf_write_data.rt2xrf_wr_data[1].rt_data = w_data1[`XLEN-1:0];
assign rt2xrf_write_data.rt2xrf_wr_data[2].rt_data = w_data2[`XLEN-1:0];
assign rt2xrf_write_data.rt2xrf_wr_data[3].rt_data = w_data3[`XLEN-1:0];
//Addr
assign rt2xrf_write_data.rt2xrf_wr_data[0].rt_index = w_addr0;
assign rt2xrf_write_data.rt2xrf_wr_data[1].rt_index = w_addr1;
assign rt2xrf_write_data.rt2xrf_wr_data[2].rt_index = w_addr2;
assign rt2xrf_write_data.rt2xrf_wr_data[3].rt_index = w_addr3;

//  5.4. To VCSR
//Valid
assign rt2vcsr_write_valid = (w_valid0 && trap_flag0) ? w_valid0 : 
                             (w_valid1 && trap_flag1) ? w_valid1 :
                             (w_valid2 && trap_flag2) ? w_valid2 :
                             (w_valid3 && trap_flag3) ? w_valid3 : 1'b0;
//Data
assign rt2vcsr_write_data =  (w_valid0 && trap_flag0) ? w_vcsr0 : 
                             (w_valid1 && trap_flag1) ? w_vcsr1 :
                             (w_valid2 && trap_flag2) ? w_vcsr2 :
                             (w_valid3 && trap_flag3) ? w_vcsr3 : 'b0;

//  5.5. To vsat
assign rt2vsat_write_valid = (w_valid3 && w_vxsat3) || (w_valid2 && w_vxsat2) || (w_valid1 && w_vxsat1) || (w_valid0 && w_vxsat0);
assign rt2vsat_write_data = w_vxsat3 || w_vxsat2 || w_vxsat1 || w_vxsat0;

//6. Ready generation
assign rob2rt_write_ready[0] = rt2xrf_write_data.rt2xrf_wr_valid[0] ? rt2xrf_write_ready[0] : 1'b1; //to XRF use ready, otherwise ready is tied to 1
assign rob2rt_write_ready[1] = rt2xrf_write_data.rt2xrf_wr_valid[1] ? rt2xrf_write_ready[1] : 1'b1; 
assign rob2rt_write_ready[2] = rt2xrf_write_data.rt2xrf_wr_valid[2] ? rt2xrf_write_ready[2] : 1'b1;
assign rob2rt_write_ready[3] = rt2xrf_write_data.rt2xrf_wr_valid[3] ? rt2xrf_write_ready[3] : 1'b1;
/////////////////////////////////

endmodule
