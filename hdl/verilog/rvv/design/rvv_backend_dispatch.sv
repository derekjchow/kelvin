// description:
// 1. Dispatch unit receives uop instructions from uop queue
// 2. Dispatch unit check rules to determine if the uops are sent to reservation stations(RS). 
//    There are two ways to solve: 
//     a. stall pipeline
//     b. foreward data from ROB
// 3. Dispatch unit read vector data from VRF for uops.
// 
// feature list:
// 1. Dispatch module can issue 2 uops at most.
//     a. Uop sequence must be in-order.
//     b. Issuing uop(s) use valid-ready handshake mechanism.
// 2. Dispatch rules
//     a. RAW data hazard: 
//         I. uop0 Vs rob_entry(s). if rob_entry.vd_valid is 'b0, then stall pipeline (do not issue uop0)
//         II.uop1 Vs rob_entry(s). if rob_entry.vd_valid is 'b0, then do not issue uop1
//         II.uop1 Vs uop0. if uop0.vd_valid is the src of uop1, then do not issue uop0
//     b. Structure hazard:
//         I. the src-operand number of uops is more than 4, then only issue uop0

`include "rvv_backend.svh"
`include "rvv_backend_dispatch.svh"

module rvv_backend_dispatch
(
    clk,
    rst_n,
    uop_valid_uop2dp,
    uop_uop2dp,
    uop_ready_dp2uop,
    rs_valid_dp2alu,
    rs_dp2alu,
    rs_ready_alu2dp,
    rs_valid_dp2pmtrdt,
    rs_dp2pmtrdt,
    rs_ready_pmtrdt2dp,
    rs_valid_dp2mul,
    rs_dp2mul,
    rs_ready_mul2dp,
    rs_valid_dp2div,
    rs_dp2div,
    rs_ready_div2dp,
    rs_valid_dp2lsu,
    rs_dp2lsu,
    rs_ready_lsu2dp,
    uop_valid_dp2rob,
    uop_dp2rob,
    uop_ready_rob2dp,
    uop_index_rob2dp,
    rd_index_dp2vrf,        
    rd_data_vrf2dp,
    v0_mask_vrf2dp,
    rob_entry
);  
// ---port definition-------------------------------------------------
// global signal
    input  logic           clk;
    input  logic           rst_n;

// Uops Queue to Dispatch unit
    input  logic        [`NUM_DP_UOP-1:0] uop_valid_uop2dp;
    input  UOP_QUEUE_t  [`NUM_DP_UOP-1:0] uop_uop2dp;
    output logic        [`NUM_DP_UOP-1:0] uop_ready_dp2uop;

// Dispatch unit sends oprations to reservation stations
// Dispatch unit to ALU reservation station
// rs_*: reservation station
    output logic        [`NUM_DP_UOP-1:0] rs_valid_dp2alu;
    output ALU_RS_t     [`NUM_DP_UOP-1:0] rs_dp2alu;
    input  logic        [`NUM_DP_UOP-1:0] rs_ready_alu2dp;

// Dispatch unit to PMT+RDT reservation station
    output logic        [`NUM_DP_UOP-1:0] rs_valid_dp2pmtrdt;
    output PMT_RDT_RS_t [`NUM_DP_UOP-1:0] rs_dp2pmtrdt;
    input  logic        [`NUM_DP_UOP-1:0] rs_ready_pmtrdt2dp;

// Dispatch unit to MUL reservation station
    output logic        [`NUM_DP_UOP-1:0] rs_valid_dp2mul;
    output MUL_RS_t     [`NUM_DP_UOP-1:0] rs_dp2mul;
    input  logic        [`NUM_DP_UOP-1:0] rs_ready_mul2dp;

// Dispatch unit to DIV reservation station
    output logic        [`NUM_DP_UOP-1:0] rs_valid_dp2div;
    output DIV_RS_t     [`NUM_DP_UOP-1:0] rs_dp2div;
    input  logic        [`NUM_DP_UOP-1:0] rs_ready_div2dp;

// Dispatch unit to LSU reservation station
    output logic        [`NUM_DP_UOP-1:0] rs_valid_dp2lsu;
    output LSU_RS_t     [`NUM_DP_UOP-1:0] rs_dp2lsu;
    input  logic        [`NUM_DP_UOP-1:0] rs_ready_lsu2dp;

// Dispatch unit pushes operations to ROB unit
    output logic        [`NUM_DP_UOP-1:0] uop_valid_dp2rob;
    output DP2ROB_t     [`NUM_DP_UOP-1:0] uop_dp2rob;
    input  logic        [`NUM_DP_UOP-1:0] uop_ready_rob2dp;
    input  logic        [`ROB_DEPTH_WIDTH-1:0] uop_index_rob2dp;

// Dispatch unit sends read request to VRF for vector data.
// Dispatch unit to VRF unit
// rd_data would be return from VRF at the current cycle.
    output logic [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_index_dp2vrf;          
    input  logic [`NUM_DP_VRF-1:0][`VLEN-1:0]                rd_data_vrf2dp;
    input  logic [`VLEN-1:0]                                 v0_mask_vrf2dp;

// Dispatch unit accept all ROB entry to determine if vs_data of RS is from ROB or not
// ROB unit to Dispatch unit
    input  ROB2DP_t [`ROB_DEPTH-1:0]    rob_entry;

// ---internal signal definition--------------------------------------
    SUC_UOP_RAW_t [`NUM_DP_UOP-1:0]   suc_uop;
    PRE_UOP_RAW_t [`ROB_DEPTH-1:0]    pre_uop_rob;
    PRE_UOP_RAW_t [`NUM_DP_UOP-2:0]   pre_uop_uop;
    RAW_UOP_ROB_t [`NUM_DP_UOP-1:0]   raw_uop_rob; 
    // uop0 is the first uop so no need raw check between uops for it
    RAW_UOP_UOP_t [`NUM_DP_UOP-1:1]   raw_uop_uop; 

    STRCT_UOP_t   [`NUM_DP_UOP-1:0]   strct_uop;
    ARCH_HAZARD_t                     arch_hazard;

    UOP_OPN_t     [`NUM_DP_UOP-1:0]   uop_operand;
    UOP_OPN_t     [`NUM_DP_UOP-1:0]   vrf_byp;
    ROB_BYP_t     [`ROB_DEPTH-1:0]    rob_byp;

    UOP_CTRL_t    [`NUM_DP_UOP-1:0]   uop_ctrl;

    UOP_INFO_t    [`NUM_DP_UOP-1:0]   uop_info;
    UOP_OPN_BYTE_TYPE_t [`NUM_DP_UOP-1:0] uop_operand_byte_type;

// ---code start------------------------------------------------------
    genvar i;
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_suc_uop
            assign suc_uop[i].vs1_index = uop_uop2dp[i].vs1;
            assign suc_uop[i].vs1_valid = uop_uop2dp[i].vs1_index_valid;
            assign suc_uop[i].vs2_index = uop_uop2dp[i].vs2_index;
            assign suc_uop[i].vs2_valid = uop_uop2dp[i].vs2_valid;
            assign suc_uop[i].vd_index  = uop_uop2dp[i].vd_index;
            assign suc_uop[i].vs3_valid = uop_uop2dp[i].vs3_valid;
            assign suc_uop[i].vm        = uop_uop2dp[i].vm;
        end
    endgenerate
// RAW data hazard check between uop[*] and ROB
    generate
        for (i=0; i<`ROB_DEPTH; i++) begin : gen_pre_uop_rob
            assign pre_uop_rob[i].w_index = rob_entry[i].w_index;
            assign pre_uop_rob[i].w_type  = rob_entry[i].w_type;
            assign pre_uop_rob[i].w_valid = rob_entry[i].w_valid;
            assign pre_uop_rob[i].valid   = rob_entry[i].valid;
        end
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_raw_uop_rob
            rvv_backend_dispatch_raw_uop_rob #(
            ) u_raw_uop_rob (
                .raw_uop_rob  (raw_uop_rob[i]),
                .suc_uop      (suc_uop[i]),
                .pre_uop      (pre_uop_rob)
            );
        end
    endgenerate

// RAW data hazard check between uop(s)
    generate
        for (i=0; i<`NUM_DP_UOP-1; i++) begin : gen_pre_uop_uop
            assign pre_uop_uop[i].w_index = uop_uop2dp[i].vd_index;
            assign pre_uop_uop[i].w_valid = 1'b0;
            assign pre_uop_uop[i].w_type  = uop_uop2dp[i].rd_index_valid ? XRF : VRF;
            assign pre_uop_uop[i].valid   = uop_uop2dp[i].vd_valid & uop_valid_uop2dp[i];
        end
        for (i=1; i<`NUM_DP_UOP; i++) begin : gen_raw_uop_uop
            rvv_backend_dispatch_raw_uop_uop #(
                .PREUOP_NUM (i)
            ) u_raw_uop_uop (
                .raw_uop_uop  (raw_uop_uop[i]),
                .suc_uop      (suc_uop[i]),
                .pre_uop      (pre_uop_uop[i-1:0])
            );
        end
    endgenerate

// Structure hazard check and set read index for VRF
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_strct_uop
            assign strct_uop[i].vs1_index = uop_uop2dp[i].vs1;
            assign strct_uop[i].vs1_valid = uop_uop2dp[i].vs1_index_valid;
            assign strct_uop[i].vs2_index = uop_uop2dp[i].vs2_index;
            assign strct_uop[i].vs2_valid = uop_uop2dp[i].vs2_valid;
            assign strct_uop[i].vd_index  = uop_uop2dp[i].vd_index;
            assign strct_uop[i].vs3_valid = uop_uop2dp[i].vs3_valid;
            assign strct_uop[i].uop_exe_unit = uop_uop2dp[i].uop_exe_unit;
            assign strct_uop[i].uop_class = uop_uop2dp[i].uop_class;
        end
    endgenerate

    rvv_backend_dispatch_structure_hazard #(
    ) u_structure_hazard (
        .rd_index     (rd_index_dp2vrf),
        .arch_hazard  (arch_hazard),
        .strct_uop    (strct_uop)
    );

// Bypass data for source operand of uop(s)
    generate
      for (i=0; i<`ROB_DEPTH; i++) begin : gen_rob_byp
        assign rob_byp[i].w_data    = rob_entry[i].w_data;
        assign rob_byp[i].byte_type = rob_entry[i].byte_type;

        `ifdef AGNOSTIC_ONE
          assign rob_byp[i].tail_one  = rob_entry[i].vector_csr.vtype.vta;
          assign rob_byp[i].inactive_one = rob_entry[i].vector_csr.vtype.vma;
        `else
          assign rob_byp[i].tail_one  = 1'b0;
          assign rob_byp[i].inactive_one = 1'b0;
        `endif
      end
`ifdef DISPATCH_ISSUE2
      if (`NUM_DP_VRF==6) begin
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
      end
      else if(`NUM_DP_VRF==4) begin
        always_comb begin
          vrf_byp[0].v0  = v0_mask_vrf2dp;
          vrf_byp[0].vs1 = 'x;
          vrf_byp[0].vs2 = 'x;
          vrf_byp[0].vd  = 'x;
          vrf_byp[1].v0  = v0_mask_vrf2dp;
          vrf_byp[1].vs1 = 'x;
          vrf_byp[1].vs2 = 'x;
          vrf_byp[1].vd  = 'x;

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
      end
`endif
      
      for (i=0;i<`NUM_DP_UOP;i++) begin: gen_bypass_data
        rvv_backend_dispatch_bypass 
        #(
        ) 
        u_bypass (
          .uop_operand  (uop_operand[i]),
          .rob_byp      (rob_byp),
          .vrf_byp      (vrf_byp[i]),
          .raw_uop_rob  (raw_uop_rob[i])
        );
      end
    endgenerate

// Control handshae mechanism for uop_queue <-> dispath, dispatch <-> rs and dispatch <-> rob
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_uop_ctrl
            assign uop_ctrl[i].uop_exe_unit   = uop_uop2dp[i].uop_exe_unit;
            assign uop_ctrl[i].last_uop_valid = uop_uop2dp[i].last_uop_valid;
        end
    endgenerate

    rvv_backend_dispatch_ctrl #(
    ) u_ctrl (
      // ctrl input signal
        .raw_uop_rob  (raw_uop_rob),
        .raw_uop_uop  (raw_uop_uop),
        .arch_hazard  (arch_hazard),
        .uop_ctrl     (uop_ctrl),
      // handshake signals
        .uop_valid_uop2dp   (uop_valid_uop2dp),
        .uop_ready_dp2uop   (uop_ready_dp2uop),
        .rs_valid_dp2alu    (rs_valid_dp2alu),
        .rs_ready_alu2dp    (rs_ready_alu2dp),
        .rs_valid_dp2pmtrdt (rs_valid_dp2pmtrdt),
        .rs_ready_pmtrdt2dp (rs_ready_pmtrdt2dp),
        .rs_valid_dp2mul    (rs_valid_dp2mul),
        .rs_ready_mul2dp    (rs_ready_mul2dp),
        .rs_valid_dp2div    (rs_valid_dp2div),
        .rs_ready_div2dp    (rs_ready_div2dp),
        .rs_valid_dp2lsu    (rs_valid_dp2lsu),
        .rs_ready_lsu2dp    (rs_ready_lsu2dp),
        .uop_valid_dp2rob   (uop_valid_dp2rob),
        .uop_ready_rob2dp   (uop_ready_rob2dp)
    );

// determine the type for each byte in uop's vector operands 
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_opr_bype_type
            assign uop_info[i].uop_index  = uop_uop2dp[i].uop_index;
            assign uop_info[i].uop_exe_unit = uop_uop2dp[i].uop_exe_unit;
            assign uop_info[i].vd_eew     = uop_uop2dp[i].vd_eew;
            assign uop_info[i].vs1_eew    = uop_uop2dp[i].vs1_eew;
            assign uop_info[i].vs2_eew    = uop_uop2dp[i].vs2_eew;
            assign uop_info[i].vstart     = uop_uop2dp[i].vector_csr.vstart;
            assign uop_info[i].vl         = uop_uop2dp[i].vs_evl;
            assign uop_info[i].vm         = uop_uop2dp[i].vm;
            assign uop_info[i].ignore_vma = uop_uop2dp[i].ignore_vma;
            assign uop_info[i].ignore_vta = uop_uop2dp[i].ignore_vta;

            rvv_backend_dispatch_opr_byte_type #(
            ) u_opr_byte_type (
                .operand_byte_type  (uop_operand_byte_type[i]),
                .uop_info           (uop_info[i]),
                .v0_enable          (uop_operand[i].v0)
            );
        end
    endgenerate

// output signals for RS+ROB
    generate
        for (i=0; i<`NUM_DP_UOP; i++) begin : gen_output_sig
          // ALU RS
`ifdef TB_SUPPORT
            assign rs_dp2alu[i].uop_pc        = uop_uop2dp[i].uop_pc; 
`endif
            assign rs_dp2alu[i].rob_entry     = uop_index_rob2dp + i; 
            assign rs_dp2alu[i].uop_funct6    = uop_uop2dp[i].uop_funct6;
            assign rs_dp2alu[i].uop_funct3    = uop_uop2dp[i].uop_funct3;
            assign rs_dp2alu[i].vstart        = uop_uop2dp[i].vector_csr.vstart;
            assign rs_dp2alu[i].vl            = uop_uop2dp[i].vs_evl;
            assign rs_dp2alu[i].vm            = uop_uop2dp[i].vm;
            assign rs_dp2alu[i].vxrm          = uop_uop2dp[i].vector_csr.xrm;
            assign rs_dp2alu[i].v0_data       = uop_operand[i].v0;
            assign rs_dp2alu[i].v0_data_valid = uop_uop2dp[i].v0_valid;
            assign rs_dp2alu[i].vd_data       = uop_operand[i].vd;
            assign rs_dp2alu[i].vd_data_valid = uop_uop2dp[i].vs3_valid;
            assign rs_dp2alu[i].vd_eew        = uop_uop2dp[i].vd_eew;
            assign rs_dp2alu[i].vs1           = uop_uop2dp[i].vs1;
            assign rs_dp2alu[i].vs1_data      = uop_operand[i].vs1;
            assign rs_dp2alu[i].vs1_data_valid= uop_uop2dp[i].vs1_index_valid;
            assign rs_dp2alu[i].vs2_data      = uop_operand[i].vs2;
            assign rs_dp2alu[i].vs2_data_valid= uop_uop2dp[i].vs2_valid;
            assign rs_dp2alu[i].vs2_eew       = uop_uop2dp[i].vs2_eew;
            assign rs_dp2alu[i].rs1_data      = uop_uop2dp[i].rs1_data;
            assign rs_dp2alu[i].rs1_data_valid= uop_uop2dp[i].rs1_data_valid;
            assign rs_dp2alu[i].uop_index     = uop_uop2dp[i].uop_index;

          // PMTRDT RS
`ifdef TB_SUPPORT
            assign rs_dp2pmtrdt[i].uop_pc        = uop_uop2dp[i].uop_pc; 
`endif
            always_comb begin
              case (uop_uop2dp[i].uop_exe_unit)
              CMP,
              RDT:rs_dp2pmtrdt[i].rob_entry      = uop_uop2dp[i].first_uop_valid ? (uop_index_rob2dp + i) : uop_index_rob2dp;
              default:rs_dp2pmtrdt[i].rob_entry  = uop_index_rob2dp + i; 
              endcase
            end
            assign rs_dp2pmtrdt[i].uop_exe_unit  = uop_uop2dp[i].uop_exe_unit; 
            assign rs_dp2pmtrdt[i].uop_funct6    = uop_uop2dp[i].uop_funct6;
            assign rs_dp2pmtrdt[i].uop_funct3    = uop_uop2dp[i].uop_funct3;
            assign rs_dp2pmtrdt[i].vstart        = uop_uop2dp[i].vector_csr.vstart;
            assign rs_dp2pmtrdt[i].vl            = uop_uop2dp[i].vs_evl;
            assign rs_dp2pmtrdt[i].vm            = uop_uop2dp[i].vm;
            assign rs_dp2pmtrdt[i].v0_data       = uop_operand[i].v0;
            assign rs_dp2pmtrdt[i].v0_data_valid = uop_uop2dp[i].v0_valid;
            assign rs_dp2pmtrdt[i].vs1_data      = uop_operand[i].vs1;
            assign rs_dp2pmtrdt[i].vs1_eew       = uop_uop2dp[i].vs1_eew;
            assign rs_dp2pmtrdt[i].vs1_data_valid= uop_uop2dp[i].vs1_index_valid;
            assign rs_dp2pmtrdt[i].vs2_data      = uop_operand[i].vs2;
            assign rs_dp2pmtrdt[i].vs2_eew       = uop_uop2dp[i].vs2_eew;
            assign rs_dp2pmtrdt[i].vs2_type      = uop_operand_byte_type[i].vs2;
            assign rs_dp2pmtrdt[i].vs2_data_valid= uop_uop2dp[i].vs2_valid;
            assign rs_dp2pmtrdt[i].vs3_data      = uop_operand[i].vd;
            assign rs_dp2pmtrdt[i].vs3_data_valid= uop_uop2dp[i].vs3_valid;
            assign rs_dp2pmtrdt[i].rs1_data      = uop_uop2dp[i].rs1_data;
            assign rs_dp2pmtrdt[i].rs1_data_valid= uop_uop2dp[i].rs1_data_valid;
            assign rs_dp2pmtrdt[i].first_uop_valid = uop_uop2dp[i].first_uop_valid;
            assign rs_dp2pmtrdt[i].last_uop_valid  = uop_uop2dp[i].last_uop_valid;
            assign rs_dp2pmtrdt[i].uop_index     = uop_uop2dp[i].uop_index;
            
          // MUL/MAC RS
`ifdef TB_SUPPORT
            assign rs_dp2mul[i].uop_pc         = uop_uop2dp[i].uop_pc; 
`endif
            assign rs_dp2mul[i].rob_entry      = uop_index_rob2dp + i; 
            assign rs_dp2mul[i].uop_funct6     = uop_uop2dp[i].uop_funct6;
            assign rs_dp2mul[i].uop_funct3     = uop_uop2dp[i].uop_funct3;
            assign rs_dp2mul[i].vxrm           = uop_uop2dp[i].vector_csr.xrm;
            assign rs_dp2mul[i].vs1_data       = uop_operand[i].vs1;
            assign rs_dp2mul[i].vs1_data_valid = uop_uop2dp[i].vs1_index_valid;
            assign rs_dp2mul[i].vs2_data       = uop_operand[i].vs2;
            assign rs_dp2mul[i].vs2_data_valid = uop_uop2dp[i].vs2_valid;
            assign rs_dp2mul[i].vs2_eew        = uop_uop2dp[i].vs2_eew;
            assign rs_dp2mul[i].vs3_data       = uop_operand[i].vd;
            assign rs_dp2mul[i].vs3_data_valid = uop_uop2dp[i].vs3_valid;
            assign rs_dp2mul[i].rs1_data       = uop_uop2dp[i].rs1_data;
            assign rs_dp2mul[i].rs1_data_valid = uop_uop2dp[i].rs1_data_valid;
            assign rs_dp2mul[i].uop_index      = uop_uop2dp[i].uop_index;

          // DIV RS
`ifdef TB_SUPPORT
            assign rs_dp2div[i].uop_pc        = uop_uop2dp[i].uop_pc; 
`endif
            assign rs_dp2div[i].rob_entry     = uop_index_rob2dp + i; 
            assign rs_dp2div[i].uop_funct6    = uop_uop2dp[i].uop_funct6;
            assign rs_dp2div[i].uop_funct3    = uop_uop2dp[i].uop_funct3;
            assign rs_dp2div[i].vs1_data      = uop_operand[i].vs1;
            assign rs_dp2div[i].vs1_data_valid= uop_uop2dp[i].vs1_index_valid;
            assign rs_dp2div[i].vs2_data      = uop_operand[i].vs2;
            assign rs_dp2div[i].vs2_eew       = uop_uop2dp[i].vs2_eew;
            assign rs_dp2div[i].vs2_data_valid= uop_uop2dp[i].vs2_valid;
            assign rs_dp2div[i].rs1_data      = uop_uop2dp[i].rs1_data;
            assign rs_dp2div[i].rs1_data_valid= uop_uop2dp[i].rs1_data_valid;

          // LSU RS
`ifdef TB_SUPPORT
            assign rs_dp2lsu[i].uop_pc        = uop_uop2dp[i].uop_pc; 
`endif
            assign rs_dp2lsu[i].rob_entry     = uop_index_rob2dp + i; 
            assign rs_dp2lsu[i].uop_funct6    = uop_uop2dp[i].uop_funct6;
            assign rs_dp2lsu[i].vidx_valid    = uop_uop2dp[i].vs2_valid;
            assign rs_dp2lsu[i].vidx_addr     = uop_uop2dp[i].vs2_index;
            assign rs_dp2lsu[i].vidx_data     = uop_operand[i].vs2;
            assign rs_dp2lsu[i].vregfile_read_valid = uop_uop2dp[i].vs3_valid;
            assign rs_dp2lsu[i].vregfile_read_addr  = uop_uop2dp[i].vd_index;
            assign rs_dp2lsu[i].vregfile_read_data  = uop_operand[i].vd;

          // ROB
`ifdef TB_SUPPORT
            assign uop_dp2rob[i].uop_pc       = uop_uop2dp[i].uop_pc; 
`endif
            assign uop_dp2rob[i].w_index      = uop_uop2dp[i].rd_index_valid ? uop_uop2dp[i].rd_index : uop_uop2dp[i].vd_index;
            assign uop_dp2rob[i].w_type       = uop_uop2dp[i].rd_index_valid ? XRF : VRF;
            assign uop_dp2rob[i].byte_type    = uop_operand_byte_type[i].vd;
            assign uop_dp2rob[i].vector_csr   = uop_uop2dp[i].vector_csr;
            assign uop_dp2rob[i].last_uop_valid = uop_uop2dp[i].last_uop_valid;
        end
    endgenerate

endmodule
