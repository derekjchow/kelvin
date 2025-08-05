// description
// 1. the pmtrdt_unit module is responsible for one PMTRDT instruction.
//
// feature list:
// 1. Compare/Reduction/Compress instruction is optional based on parameters.
// 2. the latency of all instructions is 2-cycles.

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif
`ifndef PMTRDT_DEFINE_SVH
`include "rvv_backend_pmtrdt.svh"
`endif

module rvv_backend_pmtrdt_unit
(
  clk,
  rst_n,

  pmtrdt_uop_valid,
  pmtrdt_uop,
  pmtrdt_uop_ready,

  pmtrdt_res_valid,
  pmtrdt_res,
  pmtrdt_res_ready,

  uop_data,
  uop_cnt,
  trap_flush_rvv
);
// ---parameter definition--------------------------------------------
  parameter GEN_RDT = 1'b0; // by default, NO Reduction unit
  parameter GEN_CMP = 1'b0; // by default, NO COMPARE unit
  parameter GEN_PMT = 1'b0; // by default, NO PERMUTATION unit

  localparam VLENB_WIDTH = $clog2(`VLENB);
// ---port definition-------------------------------------------------
// global signal
  input logic       clk;
  input logic       rst_n;

// the uop from PMTRDT RS
  input               pmtrdt_uop_valid;
  input PMT_RDT_RS_t  pmtrdt_uop;
  output logic        pmtrdt_uop_ready;

// the result to PMTRDT PU
  output logic        pmtrdt_res_valid;
  output PU2ROB_t     pmtrdt_res;
  input               pmtrdt_res_ready;

// all uop from PMTRDT RS for permuation
  input PMT_RDT_RS_t [`PMTRDT_RS_DEPTH-1:0] uop_data;
  input [$clog2(`PMTRDT_RS_DEPTH):0]        uop_cnt;

// trap-flush
  input               trap_flush_rvv;

// ---internal signal definition--------------------------------------
  // control signal
  PMTRDT_UOP_TYPE_t         uop_type, uop_type_q;

  RDT_CTRL_t                rdt_ctrl, rdt_ctrl_q; // RDT+CMP control signals
  logic                     rdt_ctrl_reg_en, rdt_ctrl_reg_clr;

  PMT_CTRL_t                pmt_ctrl, pmt_ctrl_q; // PMT control signals
  logic                     pmt_ctrl_reg_en, pmt_ctrl_reg_clr;

  COMPRESS_CTRL_t           compress_ctrl_ex0, compress_ctrl_ex1;
  logic                     compress_ctrl_push, compress_ctrl_pop;
  logic                     compress_ctrl_empty;

  // Reduction operation
  logic                     red_widen_sum_flag;
  logic [`VLEN-1:0]         widen_vs2;       // vs2 data after being widen if need
  BYTE_TYPE_t               widen_vs2_type;  // vs2 data btpe type after being widen if need
  logic [`VLENB/2-1:0][7:0] logic_src1_1stage, logic_src2_1stage; // and/or/xor operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0][8:0] sum_src1_1stage, sum_src2_1stage; // sum operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0]      sum_cin_1stage;
  logic [`VLENB/2-1:0][8:0] max_src1_1stage, max_src2_1stage; // max operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0]      max_cin_1stage;
  logic [`VLENB/2-1:0][8:0] min_src1_1stage, min_src2_1stage; // min operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0]      min_cin_1stage;
  logic [`VLENB/2-1:0][8:0] sum_res_1stage, max_res_1stage, min_res_1stage;
  logic [`VLENB/2-1:0][7:0] and_1stage, or_1stage, xor_1stage;
  logic [`VLENB/2-1:0]      less_than_1stage, great_than_1stage;
  logic [`VLENB/4-1:0][8:0] sum_src1_2stage, sum_src2_2stage; // sum operation: source value for reduction sum_res_1stage[*]
  logic [`VLENB/4-1:0]      sum_cin_2stage;
  logic [`VLENB/4-1:0][8:0] max_src1_2stage, max_src2_2stage; // max/min operation: source value for reduction max_res_1stage[*]
  logic [`VLENB/4-1:0]      max_cin_2stage;
  logic [`VLENB/4-1:0][8:0] min_src1_2stage, min_src2_2stage; // max/min operation: source value for reduction min_res_1stage[*]
  logic [`VLENB/4-1:0]      min_cin_2stage;
  logic [`VLENB/4-1:0][8:0] sum_res_2stage, max_res_2stage, min_res_2stage;
  logic [`VLENB/4-1:0][7:0] and_2stage, or_2stage, xor_2stage;
  logic [`VLENB/4-1:0]      less_than_2stage, great_than_2stage;
  logic                     sel_vs1; // operate vs1[0] if the last operation for reduction instruction
  logic [3:0][8:0]          src1_vd_1stage, src2_vs1_1stage;        // source value for reduction vs1[0] & vd[0]
  logic [3:0]               carry_in_vd_1stage;
  logic [3:0][8:0]          sum_vd_1stage;
  logic [3:0][7:0]          and_vd_1stage, or_vd_1stage, xor_vd_1stage;
  logic [3:0]               less_than_vd_1stage, great_than_vd_1stage;
  logic [3:0][8:0]          src1_vd_2stage, src2_vs1_2stage;        // source value for reduction vs1[0] & vd[0]
  logic [3:0]               carry_in_vd_2stage;
  logic [3:0][8:0]          sum_vd_2stage;
  logic [3:0][7:0]          and_vd_2stage, or_vd_2stage, xor_vd_2stage;
  logic [3:0]               less_than_vd_2stage, great_than_vd_2stage;
  logic [`VLENB/4-1:0][7:0] max_res_ex0, min_res_ex0;
  logic [`VLENB/4-1:0][7:0] sum_res_ex1, max_res_ex1, min_res_ex1, and_res_ex1, or_res_ex1, xor_res_ex1;
  logic [3:0][7:0]          max_vs1_ex0, min_vs1_ex0;
  logic [3:0][7:0]          sum_vs1_ex1, max_vs1_ex1, min_vs1_ex1, and_vs1_ex1, or_vs1_ex1, xor_vs1_ex1;
  logic                     red_res_en;
  logic [7:0]               sum_8b,  max_8b,  min_8b,  and_8b,  or_8b,  xor_8b;
  logic [15:0]              sum_16b, max_16b, min_16b, and_16b, or_16b, xor_16b;
  logic [31:0]              sum_32b, max_32b, min_32b, and_32b, or_32b, xor_32b;
  logic [1:0][15:0]         max_16b_1stage, min_16b_1stage;
  logic [3:0][7:0]          max_8b_1stage,  min_8b_1stage;
  logic [`VLEN-1:0]         pmtrdt_res_red; // pmtrdt result of reduction
  // Comparation operation
  logic [`VSTART_WIDTH-1:0] cmp_vstart_d, cmp_vstart_q;
  logic                     cmp_vstart_en;
  logic [`VLENB-1:0][8:0]   cmp_src1, cmp_src2; // source value for reduction/compare
  logic [`VLENB-1:0]        in_data, cin_data, bin_data; // vmadc/vmsbc mask data
  logic [`VLENB-1:0]        cmp_carry_in;
  logic [`VLENB-1:0][8:0]   cmp_sum;
  logic [`VLENB-1:0]        less_than, great_than_equal, equal, not_equal, out_data;
  logic [`VLENB-1:0]        cmp_res;
  logic [`VSTART_WIDTH-1:0] cmp_res_offset, cmp_res_en_offset;
  logic [`VLEN-1:0]         cmp_res_d, cmp_res_q;
  logic [2*`VLENB-1:0]      cmp_res_en;
  logic [`VLEN-1:0]         pmtrdt_res_cmp; // pmtrdt result of compare
  // Permutation operation
  // slide+gather instruction
  logic [`PMTRDT_RS_DEPTH-1:0]  rs_entry_valid;
  logic                         pmt_go, pmt_go_q; // start to execute pmt inst when all uop(s) are in RS
  logic [`UOP_INDEX_WIDTH-1:0]  pmt_uop_done_cnt_d, pmt_uop_done_cnt_q;
  logic [`VLENB-1:0][`XLEN+1:0] offset;
  logic [`VLENB-1:0][`XLEN+1:0] slide_down_offset;
  logic [`VLENB-1:0]            sel_scalar;
  BYTE_TYPE_t                   vd_type;
  logic [`VLMAX_MAX-1:0][7:0]   pmt_vs2_data, pmt_vs3_data;
  logic [`XLEN-1:0]         pmt_rs1_data;
  logic [`VLENB-1:0][7:0]   pmt_res_d, pmt_res_q;
  logic                     pmt_res_en;
  logic [`VLEN-1:0]         pmtrdt_res_pmt; // pmtrdt result of permutation
  // compress instruction
  logic [`VLENB-1:0]        compress_enable, compress_body;
  logic [`VLENB-1:0][VLENB_WIDTH:0] compress_offset;
  logic [`VLEN-1:0]         compress_mask_d, compress_mask_q; // register vs1_data for compress mask
  logic                     compress_mask_en;
  logic [VLENB_WIDTH:0]     compress_cnt_d, compress_cnt_q, compress_cnt_qq;   // compress counter
  logic [1:0][VLENB_WIDTH:0] valid_num;
  logic                     compress_cnt_ge_vlenb, compress_cnt_gt_vlenb;
  logic                     compress_cnt_en, compress_cnt_clr;
  logic [`VLENB-1:0][7:0]   compress_value;
  logic [2*`VLENB-1:0][7:0] compress_res_d, compress_res_q;
  logic [2*`VLENB-1:0]      compress_res_en;
  logic [`VLEN-1:0]         pmtrdt_res_compress; // pmtrdt result of vcompress instruction

  genvar i;
// ---code start------------------------------------------------------
// control signals based on uop
  // uop_type: permutation, reduction or compare
  always_comb begin
    case (pmtrdt_uop.uop_exe_unit)
      PMT: uop_type = PERMUTATION;
      RDT: uop_type = REDUCTION;
      default: uop_type = COMPARE;
    endcase
  end
  logic uop_type_reg_en, uop_type_reg_clr;
  assign uop_type_reg_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
  assign uop_type_reg_clr = rdt_ctrl_q.compress ? !rdt_ctrl_reg_en & rdt_ctrl_q.last_uop_valid & compress_ctrl_ex1.last_uop_valid
                                                : !rdt_ctrl_reg_en & rdt_ctrl_q.last_uop_valid;
  cdffr #(.T(PMTRDT_UOP_TYPE_t)) uop_type_reg (.q(uop_type_q), .d(uop_type), .c(uop_type_reg_clr | trap_flush_rvv), .e(uop_type_reg_en), .clk(clk), .rst_n(rst_n));

  // rdt control signals
  // sign_opr: 0-unsigned, 1-signed
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VMADC,
      VMSBC,
      VMSLTU,
      VMSLEU,
      VMSGTU,
      VREDMAXU,
      VREDMINU,
      VWREDSUMU: rdt_ctrl.sign_opr = 1'b0;
      default  : rdt_ctrl.sign_opr = 1'b1;
    endcase
  end

  // cmp_opr: great than / less than / equal / carry_out / borrow_out
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VMSEQ: rdt_ctrl.cmp_opr = EQUAL;
      VMSNE: rdt_ctrl.cmp_opr = NOT_EQUAL;
      VMSLTU,
      VMSLT: rdt_ctrl.cmp_opr = LESS_THAN;
      VMSLEU,
      VMSLE: rdt_ctrl.cmp_opr = LESS_THAN_OR_EQUAL;
      VMSGTU,
      VMSGT: rdt_ctrl.cmp_opr = GREAT_THAN;
      VMADC: rdt_ctrl.cmp_opr = COUT;
      VMSBC: rdt_ctrl.cmp_opr = BOUT;
      default: rdt_ctrl.cmp_opr = NOT_EQUAL;
    endcase
  end

  // widen: vd EEW = 2*SEW
  assign rdt_ctrl.widen = (pmtrdt_uop.uop_funct6 == VWREDSUMU) ||
                          (pmtrdt_uop.uop_funct6 == VWREDSUM);

  // rdt_opr: reduction operation
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VREDSUM,
      VWREDSUMU,
      VWREDSUM: rdt_ctrl.rdt_opr = SUM;
      VREDMAXU,
      VREDMAX:  rdt_ctrl.rdt_opr = MAX;
      VREDMINU,
      VREDMIN:  rdt_ctrl.rdt_opr = MIN;
      VREDAND:  rdt_ctrl.rdt_opr = AND;
      VREDOR:   rdt_ctrl.rdt_opr = OR;
      VREDXOR:  rdt_ctrl.rdt_opr = XOR;
      default:  rdt_ctrl.rdt_opr = SUM;
    endcase
  end

  assign rdt_ctrl.compress = pmtrdt_uop.uop_exe_unit == PMT && pmtrdt_uop.uop_funct6 == VCOMPRESS;

  // uop infomation
`ifdef TB_SUPPORT
  assign rdt_ctrl.uop_pc = pmtrdt_uop.uop_pc;
`endif
  assign rdt_ctrl.rob_entry = pmtrdt_uop.rob_entry;
  assign rdt_ctrl.vl     = pmtrdt_uop.vl;
  assign rdt_ctrl.vm     = pmtrdt_uop.vm;
  assign rdt_ctrl.vs1_eew        = pmtrdt_uop.vs1_eew;
  assign rdt_ctrl.v0_data        = pmtrdt_uop.v0_data;
  assign rdt_ctrl.vs3_data       = pmtrdt_uop.vs3_data;
  assign rdt_ctrl.last_uop_valid = pmtrdt_uop.last_uop_valid;

  // cmp_evl
  // prestart element: undisturbed
  // body element:
  //   active element: updated
  //   inactive element: undisturbed
  // tail element:
  //   tail element in CMP-unit: updated
  //   tail element not in CMP-unit: disturbed
  always_comb begin
    case (pmtrdt_uop.vs2_eew)
      EEW32: rdt_ctrl.cmp_evl = pmtrdt_uop.uop_index * (`VLENB/4) + (`VLENB/4);
      EEW16: rdt_ctrl.cmp_evl = pmtrdt_uop.uop_index * (`VLENB/2) + (`VLENB/2);
      default:rdt_ctrl.cmp_evl = pmtrdt_uop.uop_index * `VLENB + `VLENB;
    endcase
  end

  // when to clear rdt_ctrl reg?
  // if ex0 stage has no uop to execute!
  assign rdt_ctrl_reg_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
  assign rdt_ctrl_reg_clr = rdt_ctrl_q.compress ? !rdt_ctrl_reg_en & rdt_ctrl_q.last_uop_valid & compress_ctrl_ex1.last_uop_valid
                                                : !rdt_ctrl_reg_en & rdt_ctrl_q.last_uop_valid;
  cdffr #(.T(RDT_CTRL_t)) rdt_ctrl_reg (.q(rdt_ctrl_q), .d(rdt_ctrl), .c(rdt_ctrl_reg_clr | trap_flush_rvv), .e(rdt_ctrl_reg_en), .clk(clk), .rst_n(rst_n));

  // pmt_opr: permutation operation
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      // VSLIDE1UP == VSLIDEUP_RGATHEREI16
      VSLIDE1UP: pmt_ctrl.pmt_opr = pmtrdt_uop.uop_funct3 == OPIVV ? GATHER : SLIDE_UP;
      //VSLIDEDOWN == VSLIDE1DOWN
      VSLIDE1DOWN:pmt_ctrl.pmt_opr = SLIDE_DOWN;
      VRGATHER:   pmt_ctrl.pmt_opr = GATHER;
      default:    pmt_ctrl.pmt_opr = GATHER;
    endcase
  end

  // uop infomation
`ifdef TB_SUPPORT
  assign pmt_ctrl.uop_pc    = uop_data[pmt_uop_done_cnt_q].uop_pc;
`endif
  assign pmt_ctrl.rob_entry = uop_data[pmt_uop_done_cnt_q].rob_entry;
  assign pmt_ctrl.vs3_data  = uop_data[pmt_uop_done_cnt_q].vs3_data;

  assign pmt_ctrl_reg_en    = pmt_go;
  assign pmt_ctrl_reg_clr   = !pmt_ctrl_reg_en;
  cdffr #(.T(PMT_CTRL_t)) pmt_ctrl_reg (.q(pmt_ctrl_q), .d(pmt_ctrl), .c(pmt_ctrl_reg_clr | trap_flush_rvv), .e(pmt_ctrl_reg_en), .clk(clk), .rst_n(rst_n));
  
// Reduction unit
  generate
    if (GEN_RDT == 1'b1) begin
      // logic_src1_1stage/logic_src2_1stage data for bit manipulation: and/or/xor
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_logic_src_bit_data
        // logic_src2_1stage data
        always_comb begin
          case (rdt_ctrl.rdt_opr)
            AND:begin
              logic_src2_1stage[4*i]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'hFF;
              logic_src2_1stage[4*i+1] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'hFF;
              logic_src2_1stage[4*i+2] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'hFF;
              logic_src2_1stage[4*i+3] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : 8'hFF;
            end
            default:begin
              logic_src2_1stage[4*i]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'h00;
              logic_src2_1stage[4*i+1] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'h00;
              logic_src2_1stage[4*i+2] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'h00;
              logic_src2_1stage[4*i+3] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : 8'h00;
            end
          endcase
        end

        // logic_src1_1stage data
        always_comb begin
          case (rdt_ctrl.rdt_opr)
            AND:begin
              logic_src1_1stage[4*i]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : 8'hFF;
              logic_src1_1stage[4*i+1] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : 8'hFF;
              logic_src1_1stage[4*i+2] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : 8'hFF;
              logic_src1_1stage[4*i+3] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : 8'hFF;
            end
            default:begin
              logic_src1_1stage[4*i]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : 8'h00;
              logic_src1_1stage[4*i+1] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : 8'h00;
              logic_src1_1stage[4*i+2] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : 8'h00;
              logic_src1_1stage[4*i+3] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : 8'h00;
            end
          endcase
        end
      end //for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_logic_src_bit_data

      // widen vs2 data & widen vs2 eew
      always_comb begin
        if (rdt_ctrl.widen) begin
          if (red_widen_sum_flag) begin // select high part of vs2_data
            case(pmtrdt_uop.vs2_eew)
              EEW16:begin
                for (int j=0; j<`VLENB/4; j++) begin
                  widen_vs2[16*(2*j)+:16]   = pmtrdt_uop.vs2_data[(`VLEN/2+16*j)+:16];
                  widen_vs2[16*(2*j+1)+:16] = rdt_ctrl.sign_opr ? {16{pmtrdt_uop.vs2_data[`VLEN/2+16*(j+1)-1]}}
                                                          : '0;
                  widen_vs2_type[4*j]   = pmtrdt_uop.vs2_type[`VLENB/2+2*j];
                  widen_vs2_type[4*j+1] = pmtrdt_uop.vs2_type[`VLENB/2+2*j+1];
                  widen_vs2_type[4*j+2] = pmtrdt_uop.vs2_type[`VLENB/2+2*j];
                  widen_vs2_type[4*j+3] = pmtrdt_uop.vs2_type[`VLENB/2+2*j+1];
                end
              end
              default:begin
                for (int j=0; j<`VLENB/2; j++) begin
                  widen_vs2[8*(2*j)+:8]   = pmtrdt_uop.vs2_data[(`VLEN/2+8*j)+:8];
                  widen_vs2[8*(2*j+1)+:8] = rdt_ctrl.sign_opr ? {8{pmtrdt_uop.vs2_data[`VLEN/2+8*(j+1)-1]}}
                                                        : '0;
                  widen_vs2_type[2*j]   = pmtrdt_uop.vs2_type[`VLENB/2+j];
                  widen_vs2_type[2*j+1] = pmtrdt_uop.vs2_type[`VLENB/2+j];
                end
              end
            endcase
          end else begin                // select low part of vs2_data
            case(pmtrdt_uop.vs2_eew)
              EEW16:begin
                for (int j=0; j<`VLENB/4; j++) begin
                  widen_vs2[16*(2*j)+:16]   = pmtrdt_uop.vs2_data[(16*j)+:16];
                  widen_vs2[16*(2*j+1)+:16] = rdt_ctrl.sign_opr ? {16{pmtrdt_uop.vs2_data[16*(j+1)-1]}}
                                                          : '0;
                  widen_vs2_type[4*j]   = pmtrdt_uop.vs2_type[2*j];
                  widen_vs2_type[4*j+1] = pmtrdt_uop.vs2_type[2*j+1];
                  widen_vs2_type[4*j+2] = pmtrdt_uop.vs2_type[2*j];
                  widen_vs2_type[4*j+3] = pmtrdt_uop.vs2_type[2*j+1];
                end
              end
              default:begin
                for (int j=0; j<`VLENB/2; j++) begin
                  widen_vs2[8*(2*j)+:8]   = pmtrdt_uop.vs2_data[(8*j)+:8];
                  widen_vs2[8*(2*j+1)+:8] = rdt_ctrl.sign_opr ? {8{pmtrdt_uop.vs2_data[8*(j+1)-1]}}
                                                        : '0;
                  widen_vs2_type[2*j]   = pmtrdt_uop.vs2_type[j];
                  widen_vs2_type[2*j+1] = pmtrdt_uop.vs2_type[j];
                end
              end
            endcase
          end
        end else begin
          widen_vs2      = pmtrdt_uop.vs2_data;
          widen_vs2_type = pmtrdt_uop.vs2_type;
        end
      end
  // sum_src1_1stage/sum_src2_1stage/sum_cin_1stage data
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_sum_src_1stage_data
        // sum_src2_1stage data
        always_comb begin
          sum_src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'h00; 
          sum_src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : 8'h00; 
          sum_src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'h00; 
          sum_src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : 8'h00; 
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              sum_src2_1stage[4*i][8]   = 1'b0;
              sum_src2_1stage[4*i+1][8] = 1'b0;
              sum_src2_1stage[4*i+2][8] = 1'b0;
              sum_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              sum_src2_1stage[4*i][8]   = 1'b0;
              sum_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+1][7] : 1'b0;
              sum_src2_1stage[4*i+2][8] = 1'b0;
              sum_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              sum_src2_1stage[4*i][8]   = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i][7] : 1'b0;
              sum_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+1][7] : 1'b0;
              sum_src2_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+2][7] : 1'b0;
              sum_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // sum_src1_1stage data
        always_comb begin
          sum_src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? widen_vs2[8*(8*i+4)+:8] : 8'h00;
          sum_src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? widen_vs2[8*(8*i+5)+:8] : 8'h00;
          sum_src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? widen_vs2[8*(8*i+6)+:8] : 8'h00;
          sum_src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? widen_vs2[8*(8*i+7)+:8] : 8'h00;
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              sum_src1_1stage[4*i][8]   = 1'b0;
              sum_src1_1stage[4*i+1][8] = 1'b0;
              sum_src1_1stage[4*i+2][8] = 1'b0;
              sum_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              sum_src1_1stage[4*i][8]   = 1'b0;
              sum_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+1][7] : 1'b0;
              sum_src1_1stage[4*i+2][8] = 1'b0;
              sum_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              sum_src1_1stage[4*i][8]   = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i][7]   : 1'b0;
              sum_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+1][7] : 1'b0;
              sum_src1_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+2][7] : 1'b0;
              sum_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // sum_cin_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              sum_cin_1stage[4*i]   = 1'b0;
              sum_cin_1stage[4*i+1] = sum_res_1stage[4*i][8];
              sum_cin_1stage[4*i+2] = sum_res_1stage[4*i+1][8];
              sum_cin_1stage[4*i+3] = sum_res_1stage[4*i+2][8];
            end
            EEW16:begin
              sum_cin_1stage[4*i]   = 1'b0;
              sum_cin_1stage[4*i+1] = sum_res_1stage[4*i][8];
              sum_cin_1stage[4*i+2] = 1'b0;
              sum_cin_1stage[4*i+3] = sum_res_1stage[4*i+2][8];
            end
            default:begin
              sum_cin_1stage[4*i]   = 1'b0; 
              sum_cin_1stage[4*i+1] = 1'b0; 
              sum_cin_1stage[4*i+2] = 1'b0; 
              sum_cin_1stage[4*i+3] = 1'b0; 
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_sum_src_1stage_data

  // max_src1_1stage/max_src2_1stage data
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_max_src_1stage_data
        // max_src2_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32: begin
              max_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'h00;
              max_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'h00; 
              max_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'h00; 
              max_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
            end
            EEW16: begin
              max_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'h00;
              max_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
              max_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'h00; 
              max_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
            end
            default: begin
              max_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00);
              max_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
              max_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
              max_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h80 : 8'h00); 
            end
          endcase
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              max_src2_1stage[4*i][8]   = 1'b0;
              max_src2_1stage[4*i+1][8] = 1'b0;
              max_src2_1stage[4*i+2][8] = 1'b0;
              max_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              max_src2_1stage[4*i][8]   = 1'b0;
              max_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+1][7] : 1'b0;
              max_src2_1stage[4*i+2][8] = 1'b0;
              max_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              max_src2_1stage[4*i][8]   = rdt_ctrl.sign_opr ? max_src2_1stage[4*i][7] : 1'b0;
              max_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+1][7] : 1'b0;
              max_src2_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+2][7] : 1'b0;
              max_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end
        
        // max_src1_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : ~8'h00;
              max_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : ~8'h00;
              max_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : ~8'h00;
              max_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
            end
            EEW16:begin
              max_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : ~8'h00;
              max_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
              max_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : ~8'h00;
              max_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
            end
            default:begin
              max_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
              max_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
              max_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
              max_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00);
            end
          endcase
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_src1_1stage[4*i][8]   = 1'b0;
              max_src1_1stage[4*i+1][8] = 1'b0;
              max_src1_1stage[4*i+2][8] = 1'b0;
              max_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+3][7] : ~1'b0;
            end
            EEW16:begin
              max_src1_1stage[4*i][8]   = 1'b0;
              max_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+1][7] : ~1'b0;
              max_src1_1stage[4*i+2][8] = 1'b0;
              max_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+3][7] : ~1'b0;
            end
            default:begin
              max_src1_1stage[4*i][8]   = rdt_ctrl.sign_opr ? max_src1_1stage[4*i][7]   : ~1'b0;
              max_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+1][7] : ~1'b0;
              max_src1_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+2][7] : ~1'b0;
              max_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_1stage[4*i+3][7] : ~1'b0;
            end
          endcase
        end

        // max_cin_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_cin_1stage[4*i]   = 1'b1;
              max_cin_1stage[4*i+1] = max_res_1stage[4*i][8];
              max_cin_1stage[4*i+2] = max_res_1stage[4*i+1][8];
              max_cin_1stage[4*i+3] = max_res_1stage[4*i+2][8];
            end
            EEW16:begin
              max_cin_1stage[4*i]   = 1'b1; 
              max_cin_1stage[4*i+1] = max_res_1stage[4*i][8]; 
              max_cin_1stage[4*i+2] = 1'b1; 
              max_cin_1stage[4*i+3] = max_res_1stage[4*i+2][8]; 
            end
            default:begin
              max_cin_1stage[4*i]   = 1'b1;
              max_cin_1stage[4*i+1] = 1'b1;
              max_cin_1stage[4*i+2] = 1'b1;
              max_cin_1stage[4*i+3] = 1'b1;
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_max_src_1stage_data

  // min_src1_1stage/min_src2_1stage data
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_min_src_1stage_data
        // min_src2_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32: begin
              min_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'hFF;
              min_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'hFF; 
              min_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'hFF; 
              min_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
            end
            EEW16: begin
              min_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'hFF;
              min_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
              min_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'hFF; 
              min_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
            end
            default: begin
              min_src2_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF);
              min_src2_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
              min_src2_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
              min_src2_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : (rdt_ctrl.sign_opr ? 8'h7F : 8'hFF); 
            end
          endcase
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              min_src2_1stage[4*i][8]   = 1'b0;
              min_src2_1stage[4*i+1][8] = 1'b0;
              min_src2_1stage[4*i+2][8] = 1'b0;
              min_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              min_src2_1stage[4*i][8]   = 1'b0;
              min_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+1][7] : 1'b0;
              min_src2_1stage[4*i+2][8] = 1'b0;
              min_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              min_src2_1stage[4*i][8]   = rdt_ctrl.sign_opr ? min_src2_1stage[4*i][7] : 1'b0;
              min_src2_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+1][7] : 1'b0;
              min_src2_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+2][7] : 1'b0;
              min_src2_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // min_src1_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : ~8'hFF;
              min_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : ~8'hFF;
              min_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : ~8'hFF;
              min_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
            end
            EEW16:begin
              min_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : ~8'hFF;
              min_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
              min_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : ~8'hFF;
              min_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
            end
            default:begin
              min_src1_1stage[4*i][7:0]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
              min_src1_1stage[4*i+1][7:0] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
              min_src1_1stage[4*i+2][7:0] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
              min_src1_1stage[4*i+3][7:0] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? ~pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : (rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF);
            end
          endcase
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_src1_1stage[4*i][8]   = 1'b0;
              min_src1_1stage[4*i+1][8] = 1'b0;
              min_src1_1stage[4*i+2][8] = 1'b0;
              min_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+3][7] : ~1'b0;
            end
            EEW16:begin
              min_src1_1stage[4*i][8]   = 1'b0;
              min_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+1][7] : ~1'b0;
              min_src1_1stage[4*i+2][8] = 1'b0;
              min_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+3][7] : ~1'b0;
            end
            default:begin
              min_src1_1stage[4*i][8]   = rdt_ctrl.sign_opr ? min_src1_1stage[4*i][7]   : ~1'b0;
              min_src1_1stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+1][7] : ~1'b0;
              min_src1_1stage[4*i+2][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+2][7] : ~1'b0;
              min_src1_1stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_1stage[4*i+3][7] : ~1'b0;
            end
          endcase
        end

        // min_cin_1stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_cin_1stage[4*i]   = 1'b1;
              min_cin_1stage[4*i+1] = min_res_1stage[4*i][8];
              min_cin_1stage[4*i+2] = min_res_1stage[4*i+1][8];
              min_cin_1stage[4*i+3] = min_res_1stage[4*i+2][8];
            end
            EEW16:begin
              min_cin_1stage[4*i]   = 1'b1; 
              min_cin_1stage[4*i+1] = min_res_1stage[4*i][8]; 
              min_cin_1stage[4*i+2] = 1'b1; 
              min_cin_1stage[4*i+3] = min_res_1stage[4*i+2][8]; 
            end
            default:begin
              min_cin_1stage[4*i]   = 1'b1;
              min_cin_1stage[4*i+1] = 1'b1;
              min_cin_1stage[4*i+2] = 1'b1;
              min_cin_1stage[4*i+3] = 1'b1;
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_min_src_1stage_data

      // `VLENB/2 9-bit-adder/and/or/xor for 1stage
      for (i=0; i<`VLENB/2; i++) begin : gen_rdt_arithmetic_unit_1stage
        assign sum_res_1stage[i] = sum_src2_1stage[i] + sum_src1_1stage[i] + sum_cin_1stage[i];
        assign max_res_1stage[i] = max_src2_1stage[i] + max_src1_1stage[i] + max_cin_1stage[i];
        assign min_res_1stage[i] = min_src2_1stage[i] + min_src1_1stage[i] + min_cin_1stage[i];
        assign and_1stage[i] = logic_src2_1stage[i] & logic_src1_1stage[i];
        assign or_1stage[i]  = logic_src2_1stage[i] | logic_src1_1stage[i];
        assign xor_1stage[i] = logic_src2_1stage[i] ^ logic_src1_1stage[i];
        assign less_than_1stage[i]  = min_res_1stage[i][8];
        assign great_than_1stage[i] = ~max_res_1stage[i][8];
      end

    // sum_src1_2stage/sum_src2_2stage/sum_cin_2stage data
      for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_sum_src_2stage_data
        // sum_src2_2stage data
        always_comb begin
          sum_src2_2stage[4*i][7:0]   = sum_res_1stage[4*i][7:0];
          sum_src2_2stage[4*i+1][7:0] = sum_res_1stage[4*i+1][7:0];
          sum_src2_2stage[4*i+2][7:0] = sum_res_1stage[4*i+2][7:0];
          sum_src2_2stage[4*i+3][7:0] = sum_res_1stage[4*i+3][7:0];
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              sum_src2_2stage[4*i][8]   = 1'b0;
              sum_src2_2stage[4*i+1][8] = 1'b0;
              sum_src2_2stage[4*i+2][8] = 1'b0;
              sum_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              sum_src2_2stage[4*i][8]   = 1'b0;
              sum_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+1][7] : 1'b0;
              sum_src2_2stage[4*i+2][8] = 1'b0;
              sum_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              sum_src2_2stage[4*i][8]   = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i][7] : 1'b0;
              sum_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+1][7] : 1'b0;
              sum_src2_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+2][7] : 1'b0;
              sum_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src2_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end
        
        //sum_src1_2stage data
        always_comb begin
          sum_src1_2stage[4*i][7:0]   = sum_res_1stage[`VLENB/4+4*i][7:0];
          sum_src1_2stage[4*i+1][7:0] = sum_res_1stage[`VLENB/4+4*i+1][7:0];
          sum_src1_2stage[4*i+2][7:0] = sum_res_1stage[`VLENB/4+4*i+2][7:0];
          sum_src1_2stage[4*i+3][7:0] = sum_res_1stage[`VLENB/4+4*i+3][7:0];
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              sum_src1_2stage[4*i][8]   = 1'b0;
              sum_src1_2stage[4*i+1][8] = 1'b0;
              sum_src1_2stage[4*i+2][8] = 1'b0;
              sum_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              sum_src1_2stage[4*i][8]   = 1'b0;
              sum_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+1][7] : 1'b0;
              sum_src1_2stage[4*i+2][8] = 1'b0;
              sum_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              sum_src1_2stage[4*i][8]   = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i][7] : 1'b0;
              sum_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+1][7] : 1'b0;
              sum_src1_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+2][7] : 1'b0;
              sum_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? sum_src1_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end
        
        //sum_cin_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              sum_cin_2stage[4*i]   = 1'b0;
              sum_cin_2stage[4*i+1] = sum_res_2stage[4*i][8];
              sum_cin_2stage[4*i+2] = sum_res_2stage[4*i+1][8];
              sum_cin_2stage[4*i+3] = sum_res_2stage[4*i+2][8];
            end
            EEW16:begin
              sum_cin_2stage[4*i]   = 1'b0;
              sum_cin_2stage[4*i+1] = sum_res_2stage[4*i][8];
              sum_cin_2stage[4*i+2] = 1'b0;
              sum_cin_2stage[4*i+3] = sum_res_2stage[4*i+2][8];
            end
            default:begin
              sum_cin_2stage[4*i]   = 1'b0;
              sum_cin_2stage[4*i+1] = 1'b0;
              sum_cin_2stage[4*i+2] = 1'b0;
              sum_cin_2stage[4*i+3] = 1'b0;
            end
          endcase
        end
      end //end for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_sum_src_2stage_data

    // max_src1_2stage/max_src2_2stage/max_cin_2stage data 
      for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_max_src_2stage_data
        // max_src2_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_src2_2stage[4*i][7:0]   = great_than_1stage[4*i+3] ? max_src2_1stage[4*i][7:0]   : ~max_src1_1stage[4*i][7:0];
              max_src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+1][7:0] : ~max_src1_1stage[4*i+1][7:0];
              max_src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+2][7:0] : ~max_src1_1stage[4*i+2][7:0];
              max_src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+3][7:0] : ~max_src1_1stage[4*i+3][7:0];
            end
            EEW16:begin
              max_src2_2stage[4*i][7:0]   = great_than_1stage[4*i+1] ? max_src2_1stage[4*i][7:0]   : ~max_src1_1stage[4*i][7:0];
              max_src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+1] ? max_src2_1stage[4*i+1][7:0] : ~max_src1_1stage[4*i+1][7:0];
              max_src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+2][7:0] : ~max_src1_1stage[4*i+2][7:0];
              max_src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+3][7:0] : ~max_src1_1stage[4*i+3][7:0];
            end
            default:begin
              max_src2_2stage[4*i][7:0]   = great_than_1stage[4*i+0] ? max_src2_1stage[4*i][7:0]   : ~max_src1_1stage[4*i][7:0];
              max_src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+1] ? max_src2_1stage[4*i+1][7:0] : ~max_src1_1stage[4*i+1][7:0];
              max_src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+2] ? max_src2_1stage[4*i+2][7:0] : ~max_src1_1stage[4*i+2][7:0];
              max_src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? max_src2_1stage[4*i+3][7:0] : ~max_src1_1stage[4*i+3][7:0];
            end
          endcase
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              max_src2_2stage[4*i][8]   = 1'b0;
              max_src2_2stage[4*i+1][8] = 1'b0;
              max_src2_2stage[4*i+2][8] = 1'b0;
              max_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              max_src2_2stage[4*i][8]   = 1'b0;
              max_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+1][7] : 1'b0;
              max_src2_2stage[4*i+2][8] = 1'b0;
              max_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              max_src2_2stage[4*i][8]   = rdt_ctrl.sign_opr ? max_src2_2stage[4*i][7] : 1'b0;
              max_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+1][7] : 1'b0;
              max_src2_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+2][7] : 1'b0;
              max_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src2_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // max_src1_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i][7:0]   : max_src1_1stage[`VLENB/4+4*i][7:0];
              max_src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+1][7:0] : max_src1_1stage[`VLENB/4+4*i+1][7:0];
              max_src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+2][7:0] : max_src1_1stage[`VLENB/4+4*i+2][7:0];
              max_src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+3][7:0] : max_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
            EEW16:begin
              max_src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+1] ? ~max_src2_1stage[`VLENB/4+4*i][7:0]   : max_src1_1stage[`VLENB/4+4*i][7:0];
              max_src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+1] ? ~max_src2_1stage[`VLENB/4+4*i+1][7:0] : max_src1_1stage[`VLENB/4+4*i+1][7:0];
              max_src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+2][7:0] : max_src1_1stage[`VLENB/4+4*i+2][7:0];
              max_src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+3][7:0] : max_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
            default:begin
              max_src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+0] ? ~max_src2_1stage[`VLENB/4+4*i][7:0]   : max_src1_1stage[`VLENB/4+4*i][7:0];
              max_src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+1] ? ~max_src2_1stage[`VLENB/4+4*i+1][7:0] : max_src1_1stage[`VLENB/4+4*i+1][7:0];
              max_src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+2] ? ~max_src2_1stage[`VLENB/4+4*i+2][7:0] : max_src1_1stage[`VLENB/4+4*i+2][7:0];
              max_src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~max_src2_1stage[`VLENB/4+4*i+3][7:0] : max_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
          endcase
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_src1_2stage[4*i][8]   = 1'b0;
              max_src1_2stage[4*i+1][8] = 1'b0;
              max_src1_2stage[4*i+2][8] = 1'b0;
              max_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+3][7] : ~1'b0;
            end
            EEW16:begin
              max_src1_2stage[4*i][8]   = 1'b0;
              max_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+1][7] : ~1'b0;
              max_src1_2stage[4*i+2][8] = 1'b0;
              max_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+3][7] : ~1'b0;
            end
            default:begin
              max_src1_2stage[4*i][8]   = rdt_ctrl.sign_opr ? max_src1_2stage[4*i][7] : ~1'b0;
              max_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+1][7] : ~1'b0;
              max_src1_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+2][7] : ~1'b0;
              max_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? max_src1_2stage[4*i+3][7] : ~1'b0;
            end
          endcase
        end

        // max_cin_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              max_cin_2stage[4*i]   = 1'b1;
              max_cin_2stage[4*i+1] = max_res_2stage[4*i][8];
              max_cin_2stage[4*i+2] = max_res_2stage[4*i+1][8];
              max_cin_2stage[4*i+3] = max_res_2stage[4*i+2][8];
            end
            EEW16:begin
              max_cin_2stage[4*i]   = 1'b1;
              max_cin_2stage[4*i+1] = max_res_2stage[4*i][8];
              max_cin_2stage[4*i+2] = 1'b1;
              max_cin_2stage[4*i+3] = max_res_2stage[4*i+2][8];
            end
            default:begin
              max_cin_2stage[4*i]   = 1'b1;
              max_cin_2stage[4*i+1] = 1'b1;
              max_cin_2stage[4*i+2] = 1'b1;
              max_cin_2stage[4*i+3] = 1'b1;
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_max_src_2stage_data

    // min_src1_2stage/min_src2_2stage/min_cin_2stage data
      for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_min_src_2stage_data
        // min_src2_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_src2_2stage[4*i][7:0]   = less_than_1stage[4*i+3] ? min_src2_1stage[4*i][7:0]   : ~min_src1_1stage[4*i][7:0];
              min_src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+1][7:0] : ~min_src1_1stage[4*i+1][7:0];
              min_src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+2][7:0] : ~min_src1_1stage[4*i+2][7:0];
              min_src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+3][7:0] : ~min_src1_1stage[4*i+3][7:0];
            end
            EEW16:begin
              min_src2_2stage[4*i][7:0]   = less_than_1stage[4*i+1] ? min_src2_1stage[4*i][7:0]   : ~min_src1_1stage[4*i][7:0];
              min_src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+1] ? min_src2_1stage[4*i+1][7:0] : ~min_src1_1stage[4*i+1][7:0];
              min_src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+2][7:0] : ~min_src1_1stage[4*i+2][7:0];
              min_src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+3][7:0] : ~min_src1_1stage[4*i+3][7:0];
            end
            default:begin
              min_src2_2stage[4*i][7:0]   = less_than_1stage[4*i+0] ? min_src2_1stage[4*i][7:0]   : ~min_src1_1stage[4*i][7:0];
              min_src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+1] ? min_src2_1stage[4*i+1][7:0] : ~min_src1_1stage[4*i+1][7:0];
              min_src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+2] ? min_src2_1stage[4*i+2][7:0] : ~min_src1_1stage[4*i+2][7:0];
              min_src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? min_src2_1stage[4*i+3][7:0] : ~min_src1_1stage[4*i+3][7:0];
            end
          endcase
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              min_src2_2stage[4*i][8]   = 1'b0;
              min_src2_2stage[4*i+1][8] = 1'b0;
              min_src2_2stage[4*i+2][8] = 1'b0;
              min_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              min_src2_2stage[4*i][8]   = 1'b0;
              min_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+1][7] : 1'b0;
              min_src2_2stage[4*i+2][8] = 1'b0;
              min_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              min_src2_2stage[4*i][8]   = rdt_ctrl.sign_opr ? min_src2_2stage[4*i][7] : 1'b0;
              min_src2_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+1][7] : 1'b0;
              min_src2_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+2][7] : 1'b0;
              min_src2_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src2_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // min_src1_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i][7:0]   : min_src1_1stage[`VLENB/4+4*i][7:0];
              min_src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+1][7:0] : min_src1_1stage[`VLENB/4+4*i+1][7:0];
              min_src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+2][7:0] : min_src1_1stage[`VLENB/4+4*i+2][7:0];
              min_src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+3][7:0] : min_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
            EEW16:begin
              min_src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+1] ? ~min_src2_1stage[`VLENB/4+4*i][7:0]   : min_src1_1stage[`VLENB/4+4*i][7:0];
              min_src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+1] ? ~min_src2_1stage[`VLENB/4+4*i+1][7:0] : min_src1_1stage[`VLENB/4+4*i+1][7:0];
              min_src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+2][7:0] : min_src1_1stage[`VLENB/4+4*i+2][7:0];
              min_src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+3][7:0] : min_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
            default:begin
              min_src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+0] ? ~min_src2_1stage[`VLENB/4+4*i][7:0]   : min_src1_1stage[`VLENB/4+4*i][7:0];
              min_src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+1] ? ~min_src2_1stage[`VLENB/4+4*i+1][7:0] : min_src1_1stage[`VLENB/4+4*i+1][7:0];
              min_src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+2] ? ~min_src2_1stage[`VLENB/4+4*i+2][7:0] : min_src1_1stage[`VLENB/4+4*i+2][7:0];
              min_src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~min_src2_1stage[`VLENB/4+4*i+3][7:0] : min_src1_1stage[`VLENB/4+4*i+3][7:0];
            end
          endcase
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_src1_2stage[4*i][8]   = 1'b0;
              min_src1_2stage[4*i+1][8] = 1'b0;
              min_src1_2stage[4*i+2][8] = 1'b0;
              min_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+3][7] : ~1'b0;
            end
            EEW16:begin
              min_src1_2stage[4*i][8]   = 1'b0;
              min_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+1][7] : ~1'b0;
              min_src1_2stage[4*i+2][8] = 1'b0;
              min_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+3][7] : ~1'b0;
            end
            default:begin
              min_src1_2stage[4*i][8]   = rdt_ctrl.sign_opr ? min_src1_2stage[4*i][7] : ~1'b0;
              min_src1_2stage[4*i+1][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+1][7] : ~1'b0;
              min_src1_2stage[4*i+2][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+2][7] : ~1'b0;
              min_src1_2stage[4*i+3][8] = rdt_ctrl.sign_opr ? min_src1_2stage[4*i+3][7] : ~1'b0;
            end
          endcase
        end

        // min_cin_2stage data
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              min_cin_2stage[4*i]   = 1'b1;
              min_cin_2stage[4*i+1] = min_res_2stage[4*i][8];
              min_cin_2stage[4*i+2] = min_res_2stage[4*i+1][8];
              min_cin_2stage[4*i+3] = min_res_2stage[4*i+2][8];
            end
            EEW16:begin
              min_cin_2stage[4*i]   = 1'b1;
              min_cin_2stage[4*i+1] = min_res_2stage[4*i][8];
              min_cin_2stage[4*i+2] = 1'b1;
              min_cin_2stage[4*i+3] = min_res_2stage[4*i+2][8];
            end
            default:begin
              min_cin_2stage[4*i]   = 1'b1;
              min_cin_2stage[4*i+1] = 1'b1;
              min_cin_2stage[4*i+2] = 1'b1;
              min_cin_2stage[4*i+3] = 1'b1;
            end
          endcase
        end
      end  // end for (i=0; i<`VLENB/(4*4); i++) begin : gen_rdt_min_src_2stage_data

      // `VLENB/4 9-bit-adder/and/or/xor for 2stage
      for (i=0; i<`VLENB/4; i++) begin : gen_rdt_arithmetic_unit_2stage
        assign sum_res_2stage[i] = sum_src2_2stage[i] + sum_src1_2stage[i] + sum_cin_2stage[i];
        assign max_res_2stage[i] = max_src2_2stage[i] + max_src1_2stage[i] + max_cin_2stage[i];
        assign min_res_2stage[i] = min_src2_2stage[i] + min_src1_2stage[i] + min_cin_2stage[i];
        assign less_than_2stage[i]  = min_res_2stage[i][8];
        assign great_than_2stage[i] = ~max_res_2stage[i][8];
      end
      for (i=0; i<`VLENB/(4*4); i++) begin: gen_rdt_logic_unit_2stage
        assign and_2stage[4*i]   = and_1stage[8*i]   & and_1stage[8*i+4];
        assign and_2stage[4*i+1] = and_1stage[8*i+1] & and_1stage[8*i+5];
        assign and_2stage[4*i+2] = and_1stage[8*i+2] & and_1stage[8*i+6];
        assign and_2stage[4*i+3] = and_1stage[8*i+3] & and_1stage[8*i+7];
        assign or_2stage[4*i]    = or_1stage[8*i]    | or_1stage[8*i+4];
        assign or_2stage[4*i+1]  = or_1stage[8*i+1]  | or_1stage[8*i+5];
        assign or_2stage[4*i+2]  = or_1stage[8*i+2]  | or_1stage[8*i+6];
        assign or_2stage[4*i+3]  = or_1stage[8*i+3]  | or_1stage[8*i+7];
        assign xor_2stage[4*i]   = xor_1stage[8*i]   ^ xor_1stage[8*i+4];
        assign xor_2stage[4*i+1] = xor_1stage[8*i+1] ^ xor_1stage[8*i+5];
        assign xor_2stage[4*i+2] = xor_1stage[8*i+2] ^ xor_1stage[8*i+6];
        assign xor_2stage[4*i+3] = xor_1stage[8*i+3] ^ xor_1stage[8*i+7];
      end

      // red_res_ex1 & red_vs1_ex1 operation for reduction
      // src1_vd_1stage/src2_vs1_1stage/carry_in_vd_1stage data
      // src2_vs1_1stage
      always_comb begin
        case (rdt_ctrl_q.rdt_opr)
          MAX:begin
            src2_vs1_1stage[0][7:0] = max_vs1_ex1[0][7:0];
            src2_vs1_1stage[1][7:0] = max_vs1_ex1[1][7:0];
            src2_vs1_1stage[2][7:0] = max_vs1_ex1[2][7:0];
            src2_vs1_1stage[3][7:0] = max_vs1_ex1[3][7:0];
          end
          MIN:begin
            src2_vs1_1stage[0][7:0] = min_vs1_ex1[0][7:0];
            src2_vs1_1stage[1][7:0] = min_vs1_ex1[1][7:0];
            src2_vs1_1stage[2][7:0] = min_vs1_ex1[2][7:0];
            src2_vs1_1stage[3][7:0] = min_vs1_ex1[3][7:0];
          end
          default:begin
            src2_vs1_1stage[0][7:0] = sum_vs1_ex1[0][7:0];
            src2_vs1_1stage[1][7:0] = sum_vs1_ex1[1][7:0];
            src2_vs1_1stage[2][7:0] = sum_vs1_ex1[2][7:0];
            src2_vs1_1stage[3][7:0] = sum_vs1_ex1[3][7:0];
          end
        endcase
        case (rdt_ctrl_q.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
          EEW32:begin
            src2_vs1_1stage[0][8] = 1'b0;
            src2_vs1_1stage[1][8] = 1'b0;
            src2_vs1_1stage[2][8] = 1'b0;
            src2_vs1_1stage[3][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[3][7] : 1'b0;
          end
          EEW16:begin
            src2_vs1_1stage[0][8] = 1'b0;
            src2_vs1_1stage[1][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[1][7] : 1'b0;
            src2_vs1_1stage[2][8] = 1'b0;
            src2_vs1_1stage[3][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[3][7] : 1'b0;
          end
          default:begin
            src2_vs1_1stage[0][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[0][7] : 1'b0;
            src2_vs1_1stage[1][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[1][7] : 1'b0;
            src2_vs1_1stage[2][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[2][7] : 1'b0;
            src2_vs1_1stage[3][8] = rdt_ctrl_q.sign_opr ? src2_vs1_1stage[3][7] : 1'b0;
          end
        endcase
      end

      // src1_vd_1stage data
      always_comb begin
        case (rdt_ctrl_q.rdt_opr)
          MAX:begin
            src1_vd_1stage[0][7:0] = ~max_res_ex1[0][7:0];
            src1_vd_1stage[1][7:0] = ~max_res_ex1[1][7:0];
            src1_vd_1stage[2][7:0] = ~max_res_ex1[2][7:0];
            src1_vd_1stage[3][7:0] = ~max_res_ex1[3][7:0];
          end
          MIN:begin
            src1_vd_1stage[0][7:0] = ~min_res_ex1[0][7:0];
            src1_vd_1stage[1][7:0] = ~min_res_ex1[1][7:0];
            src1_vd_1stage[2][7:0] = ~min_res_ex1[2][7:0];
            src1_vd_1stage[3][7:0] = ~min_res_ex1[3][7:0];
          end
          default:begin
            src1_vd_1stage[0][7:0] = sum_res_ex1[0][7:0];
            src1_vd_1stage[1][7:0] = sum_res_ex1[1][7:0];
            src1_vd_1stage[2][7:0] = sum_res_ex1[2][7:0];
            src1_vd_1stage[3][7:0] = sum_res_ex1[3][7:0];
          end
        endcase
        case (rdt_ctrl_q.rdt_opr)
          MAX,
          MIN:begin
            case (rdt_ctrl_q.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
              EEW32:begin
                src1_vd_1stage[0][8] = 1'b0;
                src1_vd_1stage[1][8] = 1'b0;
                src1_vd_1stage[2][8] = 1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : ~1'b0;
              end
              EEW16:begin
                src1_vd_1stage[0][8] = 1'b0;
                src1_vd_1stage[1][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[1][7] : ~1'b0;
                src1_vd_1stage[2][8] = 1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : ~1'b0;
              end
              default:begin
                src1_vd_1stage[0][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[0][7] : ~1'b0;
                src1_vd_1stage[1][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[1][7] : ~1'b0;
                src1_vd_1stage[2][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[2][7] : ~1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : ~1'b0;
              end
            endcase
          end
          default:begin
            case (rdt_ctrl_q.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
              EEW32:begin
                src1_vd_1stage[0][8] = 1'b0;
                src1_vd_1stage[1][8] = 1'b0;
                src1_vd_1stage[2][8] = 1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : 1'b0;
              end
              EEW16:begin
                src1_vd_1stage[0][8] = 1'b0;
                src1_vd_1stage[1][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[1][7] : 1'b0;
                src1_vd_1stage[2][8] = 1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : 1'b0;
              end
              default:begin
                src1_vd_1stage[0][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[0][7] : 1'b0;
                src1_vd_1stage[1][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[1][7] : 1'b0;
                src1_vd_1stage[2][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[2][7] : 1'b0;
                src1_vd_1stage[3][8] = rdt_ctrl_q.sign_opr ? src1_vd_1stage[3][7] : 1'b0;
              end
            endcase
          end
        endcase
      end

      // carry_in_vd_1stage data
      always_comb begin
        case (rdt_ctrl_q.rdt_opr)
          MAX,
          MIN:begin
            case (rdt_ctrl_q.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
              EEW32:begin
                carry_in_vd_1stage[0] = 1'b1;
                carry_in_vd_1stage[1] = sum_vd_1stage[0][8];
                carry_in_vd_1stage[2] = sum_vd_1stage[1][8];
                carry_in_vd_1stage[3] = sum_vd_1stage[2][8];
              end
              EEW16:begin
                carry_in_vd_1stage[0] = 1'b1;
                carry_in_vd_1stage[1] = sum_vd_1stage[0][8];
                carry_in_vd_1stage[2] = 1'b1;
                carry_in_vd_1stage[3] = sum_vd_1stage[2][8];
              end
              default:begin
                carry_in_vd_1stage[0] = 1'b1;
                carry_in_vd_1stage[1] = 1'b1;
                carry_in_vd_1stage[2] = 1'b1;
                carry_in_vd_1stage[3] = 1'b1;
              end
            endcase
          end
          default:begin
            case (rdt_ctrl_q.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
              EEW32:begin
                carry_in_vd_1stage[0] = 1'b0;
                carry_in_vd_1stage[1] = sum_vd_1stage[0][8];
                carry_in_vd_1stage[2] = sum_vd_1stage[1][8];
                carry_in_vd_1stage[3] = sum_vd_1stage[2][8];
              end
              EEW16:begin
                carry_in_vd_1stage[0] = 1'b0;
                carry_in_vd_1stage[1] = sum_vd_1stage[0][8];
                carry_in_vd_1stage[2] = 1'b0;
                carry_in_vd_1stage[3] = sum_vd_1stage[2][8];
              end
              default:begin
                carry_in_vd_1stage[0] = 1'b0;
                carry_in_vd_1stage[1] = 1'b0;
                carry_in_vd_1stage[2] = 1'b0;
                carry_in_vd_1stage[3] = 1'b0;
              end
            endcase
          end
        endcase
      end

      // four 9-bit adder/and/or/xor for red_res_q & red_vs1_q
      for (i=0; i<4; i++) begin : gen_rdt_arithmetic_unit_vs1vd_1stage
        assign sum_vd_1stage[i] = src2_vs1_1stage[i] + src1_vd_1stage[i] + carry_in_vd_1stage[i];
        assign and_vd_1stage[i] = and_vs1_ex1[i] & and_res_ex1[i];
        assign or_vd_1stage[i]  = or_vs1_ex1[i]  | or_res_ex1[i];
        assign xor_vd_1stage[i] = xor_vs1_ex1[i] ^ xor_res_ex1[i];
        assign less_than_vd_1stage[i]  = sum_vd_1stage[i][8];
        assign great_than_vd_1stage[i] = ~sum_vd_1stage[i][8];
      end

      // VS1[0] & res_vd_1stage[0] operation for reduction
      // src1_vd_2stage/src2_vs1_2stage/carry_in_vd_2stage data
      // src2_vs1_2stage
      assign sel_vs1 = rdt_ctrl.last_uop_valid && !rdt_ctrl.widen ||
                       rdt_ctrl.last_uop_valid && rdt_ctrl.widen && red_widen_sum_flag;
      always_comb begin
        if (sel_vs1) begin
          case (pmtrdt_uop.vs1_eew)
            EEW32: begin
              src2_vs1_2stage[0][7:0] = pmtrdt_uop.vs1_data[8*0+:8];
              src2_vs1_2stage[1][7:0] = pmtrdt_uop.vs1_data[8*1+:8];
              src2_vs1_2stage[2][7:0] = pmtrdt_uop.vs1_data[8*2+:8];
              src2_vs1_2stage[3][7:0] = pmtrdt_uop.vs1_data[8*3+:8];
              src2_vs1_2stage[0][8]   = 1'b0;
              src2_vs1_2stage[1][8]   = 1'b0;
              src2_vs1_2stage[2][8]   = 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
            EEW16: begin
              src2_vs1_2stage[0][7:0] = pmtrdt_uop.vs1_data[8*0+:8];
              src2_vs1_2stage[1][7:0] = pmtrdt_uop.vs1_data[8*1+:8];
              case (rdt_ctrl.rdt_opr)
                MAX:begin
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1_2stage[0][8]   = 1'b0;
              src2_vs1_2stage[1][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[1][7] : 1'b0;
              src2_vs1_2stage[2][8]   = 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
            default: begin
              src2_vs1_2stage[0][7:0] = pmtrdt_uop.vs1_data[0+:8];
              case (rdt_ctrl.rdt_opr)
                MAX:begin
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[2][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[2][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1_2stage[1][7:0] = 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1_2stage[1][7:0] = 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1_2stage[0][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[0][7] : 1'b0;
              src2_vs1_2stage[1][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[1][7] : 1'b0;
              src2_vs1_2stage[2][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[2][7] : 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
          endcase
        end else begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              case (rdt_ctrl.rdt_opr)
                MAX:begin
                  src2_vs1_2stage[0][7:0] = 8'h00;
                  src2_vs1_2stage[1][7:0] = 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1_2stage[0][7:0] = 8'hFF;
                  src2_vs1_2stage[1][7:0] = 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1_2stage[0][7:0] = 8'hFF;
                  src2_vs1_2stage[1][7:0] = 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1_2stage[0][7:0] = 8'h00;
                  src2_vs1_2stage[1][7:0] = 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1_2stage[0][8]   = 1'b0;
              src2_vs1_2stage[1][8]   = 1'b0;
              src2_vs1_2stage[2][8]   = 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
            EEW16:begin
              case (rdt_ctrl.rdt_opr)
                MAX:begin
                  src2_vs1_2stage[0][7:0] = 8'h00;
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1_2stage[0][7:0] = 8'hFF;
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1_2stage[0][7:0] = 8'hFF;
                  src2_vs1_2stage[1][7:0] = 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1_2stage[0][7:0] = 8'h00;
                  src2_vs1_2stage[1][7:0] = 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1_2stage[0][8]   = 1'b0;
              src2_vs1_2stage[1][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[1][7] : 1'b0;
              src2_vs1_2stage[2][8]   = 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
            default:begin
              case (rdt_ctrl.rdt_opr)
                MAX:begin
                  src2_vs1_2stage[0][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[2][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1_2stage[0][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[1][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[2][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1_2stage[3][7:0] = rdt_ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1_2stage[0][7:0] = 8'hFF;
                  src2_vs1_2stage[1][7:0] = 8'hFF;
                  src2_vs1_2stage[2][7:0] = 8'hFF;
                  src2_vs1_2stage[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1_2stage[0][7:0] = 8'h00;
                  src2_vs1_2stage[1][7:0] = 8'h00;
                  src2_vs1_2stage[2][7:0] = 8'h00;
                  src2_vs1_2stage[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1_2stage[0][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[0][7] : 1'b0;
              src2_vs1_2stage[1][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[1][7] : 1'b0;
              src2_vs1_2stage[2][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[2][7] : 1'b0;
              src2_vs1_2stage[3][8]   = rdt_ctrl.sign_opr ? src2_vs1_2stage[3][7] : 1'b0;
            end
          endcase
        end
      end

      // src1_vd_2stage data
      always_comb begin
        if (pmtrdt_uop.first_uop_valid && !red_widen_sum_flag) begin
          case (rdt_ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd_2stage[0][7:0] = ~8'h00;
                  src1_vd_2stage[1][7:0] = ~8'h00;
                  src1_vd_2stage[2][7:0] = ~8'h00;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
                EEW16:begin
                  src1_vd_2stage[0][7:0] = ~8'h00;
                  src1_vd_2stage[1][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd_2stage[2][7:0] = ~8'h00;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
                default:begin
                  src1_vd_2stage[0][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd_2stage[1][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd_2stage[2][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd_2stage[0][7:0] = ~8'hFF;
                  src1_vd_2stage[1][7:0] = ~8'hFF;
                  src1_vd_2stage[2][7:0] = ~8'hFF;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
                EEW16:begin
                  src1_vd_2stage[0][7:0] = ~8'hFF;
                  src1_vd_2stage[1][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd_2stage[2][7:0] = ~8'hFF;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
                default:begin
                  src1_vd_2stage[0][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd_2stage[1][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd_2stage[2][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd_2stage[3][7:0] = rdt_ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
              endcase
            end
            AND:begin
              src1_vd_2stage[0][7:0] = 8'hFF;
              src1_vd_2stage[1][7:0] = 8'hFF;
              src1_vd_2stage[2][7:0] = 8'hFF;
              src1_vd_2stage[3][7:0] = 8'hFF;
            end
            default:begin
              src1_vd_2stage[0][7:0] = 8'h00;
              src1_vd_2stage[1][7:0] = 8'h00;
              src1_vd_2stage[2][7:0] = 8'h00;
              src1_vd_2stage[3][7:0] = 8'h00;
            end
          endcase
        end else begin
          case (rdt_ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd_2stage[0][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
                EEW16:begin
                  src1_vd_2stage[0][7:0] = great_than_vd_1stage[1] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = great_than_vd_1stage[1] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
                default:begin
                  src1_vd_2stage[0][7:0] = great_than_vd_1stage[0] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = great_than_vd_1stage[1] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = great_than_vd_1stage[2] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = great_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd_2stage[0][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
                EEW16:begin
                  src1_vd_2stage[0][7:0] = less_than_vd_1stage[1] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = less_than_vd_1stage[1] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
                default:begin
                  src1_vd_2stage[0][7:0] = less_than_vd_1stage[0] ? ~src2_vs1_1stage[0][7:0] : src1_vd_1stage[0][7:0];
                  src1_vd_2stage[1][7:0] = less_than_vd_1stage[1] ? ~src2_vs1_1stage[1][7:0] : src1_vd_1stage[1][7:0];
                  src1_vd_2stage[2][7:0] = less_than_vd_1stage[2] ? ~src2_vs1_1stage[2][7:0] : src1_vd_1stage[2][7:0];
                  src1_vd_2stage[3][7:0] = less_than_vd_1stage[3] ? ~src2_vs1_1stage[3][7:0] : src1_vd_1stage[3][7:0];
                end
              endcase
            end
            AND:begin
              src1_vd_2stage[0][7:0] = and_vd_1stage[0][7:0];
              src1_vd_2stage[1][7:0] = and_vd_1stage[1][7:0];
              src1_vd_2stage[2][7:0] = and_vd_1stage[2][7:0];
              src1_vd_2stage[3][7:0] = and_vd_1stage[3][7:0];
            end
            OR:begin
              src1_vd_2stage[0][7:0] = or_vd_1stage[0][7:0];
              src1_vd_2stage[1][7:0] = or_vd_1stage[1][7:0];
              src1_vd_2stage[2][7:0] = or_vd_1stage[2][7:0];
              src1_vd_2stage[3][7:0] = or_vd_1stage[3][7:0];
            end
            XOR:begin
              src1_vd_2stage[0][7:0] = xor_vd_1stage[0][7:0];
              src1_vd_2stage[1][7:0] = xor_vd_1stage[1][7:0];
              src1_vd_2stage[2][7:0] = xor_vd_1stage[2][7:0];
              src1_vd_2stage[3][7:0] = xor_vd_1stage[3][7:0];
            end
            default:begin
              src1_vd_2stage[0][7:0] = sum_vd_1stage[0][7:0];
              src1_vd_2stage[1][7:0] = sum_vd_1stage[1][7:0];
              src1_vd_2stage[2][7:0] = sum_vd_1stage[2][7:0];
              src1_vd_2stage[3][7:0] = sum_vd_1stage[3][7:0];
            end
          endcase
        end
        case (rdt_ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_vd_2stage[0][8] = 1'b0;
                src1_vd_2stage[1][8] = 1'b0;
                src1_vd_2stage[2][8] = 1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : ~1'b0;
              end
              EEW16:begin
                src1_vd_2stage[0][8] = 1'b0;
                src1_vd_2stage[1][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[1][7] : ~1'b0;
                src1_vd_2stage[2][8] = 1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : ~1'b0;
              end
              default:begin
                src1_vd_2stage[0][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[0][7] : ~1'b0;
                src1_vd_2stage[1][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[1][7] : ~1'b0;
                src1_vd_2stage[2][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[2][7] : ~1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : ~1'b0;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_vd_2stage[0][8] = 1'b0;
                src1_vd_2stage[1][8] = 1'b0;
                src1_vd_2stage[2][8] = 1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : 1'b0;
              end
              EEW16:begin
                src1_vd_2stage[0][8] = 1'b0;
                src1_vd_2stage[1][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[1][7] : 1'b0;
                src1_vd_2stage[2][8] = 1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : 1'b0;
              end
              default:begin
                src1_vd_2stage[0][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[0][7] : 1'b0;
                src1_vd_2stage[1][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[1][7] : 1'b0;
                src1_vd_2stage[2][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[2][7] : 1'b0;
                src1_vd_2stage[3][8] = rdt_ctrl.sign_opr ? src1_vd_2stage[3][7] : 1'b0;
              end
            endcase
          end
        endcase
      end

      // carry_in_vd_2stage data
      always_comb begin
        case (rdt_ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_vd_2stage[0] = 1'b1;
                carry_in_vd_2stage[1] = sum_vd_2stage[0][8];
                carry_in_vd_2stage[2] = sum_vd_2stage[1][8];
                carry_in_vd_2stage[3] = sum_vd_2stage[2][8];
              end
              EEW16:begin
                carry_in_vd_2stage[0] = 1'b1;
                carry_in_vd_2stage[1] = sum_vd_2stage[0][8];
                carry_in_vd_2stage[2] = 1'b1;
                carry_in_vd_2stage[3] = sum_vd_2stage[2][8];
              end
              default:begin
                carry_in_vd_2stage[0] = 1'b1;
                carry_in_vd_2stage[1] = 1'b1;
                carry_in_vd_2stage[2] = 1'b1;
                carry_in_vd_2stage[3] = 1'b1;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_vd_2stage[0] = 1'b0;
                carry_in_vd_2stage[1] = sum_vd_2stage[0][8];
                carry_in_vd_2stage[2] = sum_vd_2stage[1][8];
                carry_in_vd_2stage[3] = sum_vd_2stage[2][8];
              end
              EEW16:begin
                carry_in_vd_2stage[0] = 1'b0;
                carry_in_vd_2stage[1] = sum_vd_2stage[0][8];
                carry_in_vd_2stage[2] = 1'b0;
                carry_in_vd_2stage[3] = sum_vd_2stage[2][8];
              end
              default:begin
                carry_in_vd_2stage[0] = 1'b0;
                carry_in_vd_2stage[1] = 1'b0;
                carry_in_vd_2stage[2] = 1'b0;
                carry_in_vd_2stage[3] = 1'b0;
              end
            endcase
          end
        endcase
      end

      // four 9-bit-adder/and/or/xor for vs1[0] & vd[0]
      for (i=0; i<4; i++) begin : gen_rdt_arithmetic_unit_vs1vd_2stage
        assign sum_vd_2stage[i] = src2_vs1_2stage[i] + src1_vd_2stage[i] + carry_in_vd_2stage[i];
        assign and_vd_2stage[i] = src2_vs1_2stage[i][7:0] & src1_vd_2stage[i][7:0];
        assign or_vd_2stage[i]  = src2_vs1_2stage[i][7:0] | src1_vd_2stage[i][7:0];
        assign xor_vd_2stage[i] = src2_vs1_2stage[i][7:0] ^ src1_vd_2stage[i][7:0];
        assign less_than_vd_2stage[i]  = sum_vd_2stage[i][8];
        assign great_than_vd_2stage[i] = ~sum_vd_2stage[i][8];
      end
      assign red_res_en = pmtrdt_uop_valid & (pmtrdt_uop_ready | !red_widen_sum_flag);

      for (i=0; i<`VLENB/4; i++) begin : gen_reduction_result
        // max_res_ex0/min_res_ex0 based on vs1_eew
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:   max_res_ex0[i] = great_than_2stage[4*(i/4)+3] ? max_src2_2stage[i][7:0] : ~max_src1_2stage[i][7:0];
            EEW16:   max_res_ex0[i] = great_than_2stage[2*(i/2)+1] ? max_src2_2stage[i][7:0] : ~max_src1_2stage[i][7:0];
            default: max_res_ex0[i] = great_than_2stage[i]         ? max_src2_2stage[i][7:0] : ~max_src1_2stage[i][7:0];
          endcase
        end
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:   min_res_ex0[i] = less_than_2stage[4*(i/4)+3] ? min_src2_2stage[i][7:0] : ~min_src1_2stage[i][7:0];
            EEW16:   min_res_ex0[i] = less_than_2stage[2*(i/2)+1] ? min_src2_2stage[i][7:0] : ~min_src1_2stage[i][7:0];
            default: min_res_ex0[i] = less_than_2stage[i]         ? min_src2_2stage[i][7:0] : ~min_src1_2stage[i][7:0];
          endcase
        end

        edff #(.T(logic[7:0])) sum_res_reg (.q(sum_res_ex1[i]), .d(sum_res_2stage[i][7:0]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) max_res_reg (.q(max_res_ex1[i]), .d(max_res_ex0[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) min_res_reg (.q(min_res_ex1[i]), .d(min_res_ex0[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) and_res_reg (.q(and_res_ex1[i]), .d(and_2stage[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) or_res_reg  (.q(or_res_ex1[i]),  .d(or_2stage[i]),  .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) xor_res_reg (.q(xor_res_ex1[i]), .d(xor_2stage[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));

        // max_vs1_ex0/min_vs1_ex0 based on vs1_eew
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:   max_vs1_ex0[i] = great_than_vd_2stage[4*(i/4)+3] ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
            EEW16:   max_vs1_ex0[i] = great_than_vd_2stage[2*(i/2)+1] ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
            default: max_vs1_ex0[i] = great_than_vd_2stage[i]         ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
          endcase
        end
        always_comb begin
          case (pmtrdt_uop.vs1_eew)
            EEW32:   min_vs1_ex0[i] = less_than_vd_2stage[4*(i/4)+3] ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
            EEW16:   min_vs1_ex0[i] = less_than_vd_2stage[2*(i/2)+1] ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
            default: min_vs1_ex0[i] = less_than_vd_2stage[i]         ? src2_vs1_2stage[i][7:0] : ~src1_vd_2stage[i][7:0];
          endcase
        end

        edff #(.T(logic[7:0])) sum_vs1_reg (.q(sum_vs1_ex1[i]), .d(sum_vd_2stage[i][7:0]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) max_vs1_reg (.q(max_vs1_ex1[i]), .d(max_vs1_ex0[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) min_vs1_reg (.q(min_vs1_ex1[i]), .d(min_vs1_ex0[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) and_vs1_reg (.q(and_vs1_ex1[i]), .d(and_vd_2stage[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) or_vs1_reg  (.q(or_vs1_ex1[i]),  .d(or_vd_2stage[i]),  .e(red_res_en), .clk(clk), .rst_n(rst_n));
        edff #(.T(logic[7:0])) xor_vs1_reg (.q(xor_vs1_ex1[i]), .d(xor_vd_2stage[i]), .e(red_res_en), .clk(clk), .rst_n(rst_n));
      end

      // reduction result when vd_eew is 32b
      for (i=0; i<4; i++) begin
        assign sum_32b[8*i+:8] = sum_vd_1stage[i][7:0];
        assign max_32b[8*i+:8] = great_than_vd_1stage[3] ? src2_vs1_1stage[i][7:0] : ~src1_vd_1stage[i][7:0];
        assign min_32b[8*i+:8] = less_than_vd_1stage[3] ? src2_vs1_1stage[i][7:0] : ~src1_vd_1stage[i][7:0];
        assign and_32b[8*i+:8] = and_vd_1stage[i];
        assign or_32b[8*i+:8]  = or_vd_1stage[i];
        assign xor_32b[8*i+:8] = xor_vd_1stage[i];
      end
     
      // reduction result when vd_eew is 16b
      assign sum_16b = sum_32b[31:16] + sum_32b[15:0];
      for (i=0; i<2; i++) begin
        assign max_16b_1stage[i][7:0]  = great_than_vd_1stage[2*i+1] ? src2_vs1_1stage[2*i][7:0] : ~src1_vd_1stage[2*i][7:0];
        assign max_16b_1stage[i][15:8] = great_than_vd_1stage[2*i+1] ? src2_vs1_1stage[2*i+1][7:0] : ~src1_vd_1stage[2*i+1][7:0];
        assign min_16b_1stage[i][7:0]  = less_than_vd_1stage[2*i+1] ? src2_vs1_1stage[2*i][7:0] : ~src1_vd_1stage[2*i][7:0];
        assign min_16b_1stage[i][15:8] = less_than_vd_1stage[2*i+1] ? src2_vs1_1stage[2*i+1][7:0] : ~src1_vd_1stage[2*i+1][7:0];
      end
      assign and_16b = and_32b[31:16] & and_32b[15:0];
      assign or_16b  = or_32b[31:16]  | or_32b[15:0]; 
      assign xor_16b = xor_32b[31:16] ^ xor_32b[15:0];
      always_comb begin
        if (rdt_ctrl_q.sign_opr) begin
          max_16b = $signed(max_16b_1stage[0]) > $signed(max_16b_1stage[1]) 
                    ? max_16b_1stage[0] : max_16b_1stage[1]; 
          min_16b = $signed(min_16b_1stage[0]) < $signed(min_16b_1stage[1]) 
                    ? min_16b_1stage[0] : min_16b_1stage[1]; 
        end else begin
          max_16b = max_16b_1stage[0] > max_16b_1stage[1]
                    ? max_16b_1stage[0] : max_16b_1stage[1]; 
          min_16b = min_16b_1stage[0] < min_16b_1stage[1]
                    ? min_16b_1stage[0] : min_16b_1stage[1]; 
        end
      end

      // reduction result when vd_eew is 8b
      assign sum_8b = sum_32b[31:24] + sum_32b[23:16] + sum_32b[15:8] + sum_32b[7:0];
      for (i=0; i<4; i++) begin
        assign max_8b_1stage[i] = great_than_vd_1stage[i] ? src2_vs1_1stage[i][7:0] : ~src1_vd_1stage[i][7:0];
        assign min_8b_1stage[i] = less_than_vd_1stage[i] ? src2_vs1_1stage[i][7:0] : ~src1_vd_1stage[i][7:0];
      end
      assign and_8b = and_16b[15:8] & and_16b[7:0];
      assign or_8b  = or_16b[15:8]  | or_16b[7:0]; 
      assign xor_8b = xor_16b[15:8] ^ xor_16b[7:0];
      always_comb begin
        if (rdt_ctrl_q.sign_opr) begin
          max_8b = 8'h80;
          min_8b = 8'h7F;
        end else begin
          max_8b = 8'h00;
          min_8b = 8'hFF;
        end
        for (int j=0; j<4; j++) begin
          if (rdt_ctrl_q.sign_opr) begin
            max_8b = $signed(max_8b) > $signed(max_8b_1stage[j]) 
                      ? max_8b : max_8b_1stage[j]; 
            min_8b = $signed(min_8b) < $signed(min_8b_1stage[j]) 
                      ? min_8b : min_8b_1stage[j]; 
          end else begin
            max_8b = max_8b > max_8b_1stage[j]
                      ? max_8b : max_8b_1stage[j]; 
            min_8b = min_8b < min_8b_1stage[j]
                      ? min_8b : min_8b_1stage[j]; 
          end
        end
      end

      //pmtrdt_res_red data
      always_comb begin
        case (rdt_ctrl_q.vs1_eew)
          EEW32:begin
            case (rdt_ctrl_q.rdt_opr)
              SUM: pmtrdt_res_red = {{(`VLEN-32){1'b0}},sum_32b};
              MAX: pmtrdt_res_red = {{(`VLEN-32){1'b0}},max_32b};
              MIN: pmtrdt_res_red = {{(`VLEN-32){1'b0}},min_32b};
              AND: pmtrdt_res_red = {{(`VLEN-32){1'b0}},and_32b};
              OR:  pmtrdt_res_red = {{(`VLEN-32){1'b0}},or_32b};
              XOR: pmtrdt_res_red = {{(`VLEN-32){1'b0}},xor_32b};
              default: pmtrdt_res_red = '0;
            endcase
          end
          EEW16:begin
            case (rdt_ctrl_q.rdt_opr)
              SUM: pmtrdt_res_red = {{(`VLEN-16){1'b0}},sum_16b};
              MAX: pmtrdt_res_red = {{(`VLEN-16){1'b0}},max_16b};
              MIN: pmtrdt_res_red = {{(`VLEN-16){1'b0}},min_16b};
              AND: pmtrdt_res_red = {{(`VLEN-16){1'b0}},and_16b};
              OR:  pmtrdt_res_red = {{(`VLEN-16){1'b0}},or_16b};
              XOR: pmtrdt_res_red = {{(`VLEN-16){1'b0}},xor_16b};
              default: pmtrdt_res_red = '0;
            endcase
          end
          default:begin
            case (rdt_ctrl_q.rdt_opr)
              SUM: pmtrdt_res_red = {{(`VLEN-8){1'b0}},sum_8b};
              MAX: pmtrdt_res_red = {{(`VLEN-8){1'b0}},max_8b};
              MIN: pmtrdt_res_red = {{(`VLEN-8){1'b0}},min_8b};
              AND: pmtrdt_res_red = {{(`VLEN-8){1'b0}},and_8b};
              OR:  pmtrdt_res_red = {{(`VLEN-8){1'b0}},or_8b};
              XOR: pmtrdt_res_red = {{(`VLEN-8){1'b0}},xor_8b};
              default: pmtrdt_res_red = '0;
            endcase
          end
        endcase
      end
    end // end if (GEN_RDT == 1'b1)
  endgenerate

  // Compare unit
  generate
    if (GEN_CMP == 1'b1) begin
      // cin_data/bin_data
      always_comb begin
        case (pmtrdt_uop.vs2_eew) // vmadc/vmsbc inst: vd_eew == vs2_eew
          EEW32: in_data = {pmtrdt_uop.v0_data >> (pmtrdt_uop.uop_index*`VLENB/4)}; 
          EEW16: in_data = {pmtrdt_uop.v0_data >> (pmtrdt_uop.uop_index*`VLENB/2)};
          default: in_data = {pmtrdt_uop.v0_data >> (pmtrdt_uop.uop_index*`VLENB)};
        endcase
      end

      for (i=0; i<`VLENB/4; i++) begin
        always_comb begin
          case (pmtrdt_uop.vs2_eew) // vmadc/vmsbc inst: vd_eew == vs2_eew
            EEW32:begin
              cin_data[4*i]   = in_data[i]; 
              cin_data[4*i+1] = in_data[i]; 
              cin_data[4*i+2] = in_data[i]; 
              cin_data[4*i+3] = in_data[i]; 
            end
            EEW16:begin
              cin_data[4*i]   = in_data[2*i]; 
              cin_data[4*i+1] = in_data[2*i]; 
              cin_data[4*i+2] = in_data[2*i+1]; 
              cin_data[4*i+3] = in_data[2*i+1]; 
            end
            default:begin
              cin_data[4*i]   = in_data[4*i]; 
              cin_data[4*i+1] = in_data[4*i+1]; 
              cin_data[4*i+2] = in_data[4*i+2]; 
              cin_data[4*i+3] = in_data[4*i+3]; 
            end
          endcase
        end
      end
      assign bin_data = ~cin_data;

      // cmp_src1/cmp_src2/cmp_carry_in data
      for (i=0; i<`VLENB/4; i++) begin : gen_cmp_src_data
        // cmp_src2 data
        always_comb begin
          cmp_src2[4*i][7:0]   = pmtrdt_uop.vs2_data[8*(4*i)+:8]; 
          cmp_src2[4*i+1][7:0] = pmtrdt_uop.vs2_data[8*(4*i+1)+:8]; 
          cmp_src2[4*i+2][7:0] = pmtrdt_uop.vs2_data[8*(4*i+2)+:8]; 
          cmp_src2[4*i+3][7:0] = pmtrdt_uop.vs2_data[8*(4*i+3)+:8]; 
          case (pmtrdt_uop.vs2_eew)
            EEW32:begin
              cmp_src2[4*i][8]   = 1'b0;
              cmp_src2[4*i+1][8] = 1'b0;
              cmp_src2[4*i+2][8] = 1'b0;
              cmp_src2[4*i+3][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
            end
            EEW16:begin
              cmp_src2[4*i][8]   = 1'b0;
              cmp_src2[4*i+1][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+1)+7] : 1'b0;
              cmp_src2[4*i+2][8] = 1'b0;
              cmp_src2[4*i+3][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
            end
            default:begin
              cmp_src2[4*i][8]   = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i)+7] : 1'b0;
              cmp_src2[4*i+1][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+1)+7] : 1'b0;
              cmp_src2[4*i+2][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+2)+7] : 1'b0;
              cmp_src2[4*i+3][8] = rdt_ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
            end
          endcase
        end

        // cmp_src1 data
        always_comb begin
          case (pmtrdt_uop.uop_funct3)
            OPIVX,
            OPIVI:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][7:0]   = pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+1][7:0] = pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i+2][7:0] = pmtrdt_uop.rs1_data[8*2+:8];
                      cmp_src1[4*i+3][7:0] = pmtrdt_uop.rs1_data[8*3+:8];
                      cmp_src1[4*i][8]     = 1'b0;
                      cmp_src1[4*i+1][8]   = 1'b0;
                      cmp_src1[4*i+2][8]   = 1'b0;
                      cmp_src1[4*i+3][8]   = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[8*2+:8];
                      cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[8*3+:8];
                      cmp_src1[4*i][8]     = 1'b0;
                      cmp_src1[4*i+1][8]   = 1'b0;
                      cmp_src1[4*i+2][8]   = 1'b0;
                      cmp_src1[4*i+3][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*3+7] : ~1'b0;
                    end
                  endcase
                end
                EEW16:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][7:0]   = pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+1][7:0] = pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i+2][7:0] = pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+3][7:0] = pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i][8]     = 1'b0;
                      cmp_src1[4*i+1][8]   = 1'b0;
                      cmp_src1[4*i+2][8]   = 1'b0;
                      cmp_src1[4*i+3][8]   = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[8*0+:8];
                      cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                      cmp_src1[4*i][8]     = 1'b0;
                      cmp_src1[4*i+1][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*1+7] : ~1'b0;
                      cmp_src1[4*i+2][8]   = 1'b0;
                      cmp_src1[4*i+3][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*1+7] : ~1'b0;
                    end
                  endcase
                end
                default:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][7:0]   = pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+1][7:0] = pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+2][7:0] = pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+3][7:0] = pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i][8]     = 1'b0;
                      cmp_src1[4*i+1][8]   = 1'b0;
                      cmp_src1[4*i+2][8]   = 1'b0;
                      cmp_src1[4*i+3][8]   = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                      cmp_src1[4*i][8]     = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                      cmp_src1[4*i+1][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                      cmp_src1[4*i+2][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                      cmp_src1[4*i+3][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                    end
                  endcase
                end
              endcase
            end
            default:begin
              case (rdt_ctrl.cmp_opr)
                COUT:begin
                  cmp_src1[4*i][7:0]   = pmtrdt_uop.vs1_data[8*(4*i)+:8];
                  cmp_src1[4*i+1][7:0] = pmtrdt_uop.vs1_data[8*(4*i+1)+:8];
                  cmp_src1[4*i+2][7:0] = pmtrdt_uop.vs1_data[8*(4*i+2)+:8];
                  cmp_src1[4*i+3][7:0] = pmtrdt_uop.vs1_data[8*(4*i+3)+:8];
                end
                default: begin
                  cmp_src1[4*i][7:0]   = ~pmtrdt_uop.vs1_data[8*(4*i)+:8];
                  cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+1)+:8];
                  cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+2)+:8];
                  cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+3)+:8];
                end
              endcase
              case (pmtrdt_uop.vs2_eew) // compare instruction: vs1_eew == vs2_eew
                EEW32:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][8]   = 1'b0;
                      cmp_src1[4*i+1][8] = 1'b0;
                      cmp_src1[4*i+2][8] = 1'b0;
                      cmp_src1[4*i+3][8] = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][8]   = 1'b0;
                      cmp_src1[4*i+1][8] = 1'b0;
                      cmp_src1[4*i+2][8] = 1'b0;
                      cmp_src1[4*i+3][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                    end
                  endcase
                end
                EEW16:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][8]   = 1'b0;
                      cmp_src1[4*i+1][8] = 1'b0;
                      cmp_src1[4*i+2][8] = 1'b0;
                      cmp_src1[4*i+3][8] = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][8]   = 1'b0;
                      cmp_src1[4*i+1][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+1)+7] : ~1'b0;
                      cmp_src1[4*i+2][8] = 1'b0;
                      cmp_src1[4*i+3][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                    end
                  endcase
                end
                default:begin
                  case (rdt_ctrl.cmp_opr)
                    COUT:begin
                      cmp_src1[4*i][8]   = 1'b0;
                      cmp_src1[4*i+1][8] = 1'b0;
                      cmp_src1[4*i+2][8] = 1'b0;
                      cmp_src1[4*i+3][8] = 1'b0;
                    end
                    default:begin
                      cmp_src1[4*i][8]   = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i)+7] : ~1'b0;
                      cmp_src1[4*i+1][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+1)+7] : ~1'b0;
                      cmp_src1[4*i+2][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+2)+7] : ~1'b0;
                      cmp_src1[4*i+3][8] = rdt_ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                    end
                  endcase
                end
              endcase
            end
          endcase
        end

        // cmp_carry_in data
        always_comb begin
          case (pmtrdt_uop.vs2_eew)
            EEW32:begin
              case (rdt_ctrl.cmp_opr)
                COUT: cmp_carry_in[4*i] = rdt_ctrl.vm ? 1'b0 : cin_data[4*i];
                BOUT: cmp_carry_in[4*i] = rdt_ctrl.vm ? 1'b1 : bin_data[4*i];
                default: cmp_carry_in[4*i]   = 1'b1;
              endcase
              cmp_carry_in[4*i+1] = cmp_sum[4*i][8];
              cmp_carry_in[4*i+2] = cmp_sum[4*i+1][8];
              cmp_carry_in[4*i+3] = cmp_sum[4*i+2][8];
            end
            EEW16:begin
              case (rdt_ctrl.cmp_opr)
                COUT:begin
                  cmp_carry_in[4*i]   = rdt_ctrl.vm ? 1'b0 : cin_data[4*i]; 
                  cmp_carry_in[4*i+2] = rdt_ctrl.vm ? 1'b0 : cin_data[4*i+2]; 
                end
                BOUT:begin
                  cmp_carry_in[4*i]   = rdt_ctrl.vm ? 1'b1 : bin_data[4*i]; 
                  cmp_carry_in[4*i+2] = rdt_ctrl.vm ? 1'b1 : bin_data[4*i+2]; 
                end
                default:begin
                  cmp_carry_in[4*i]   = 1'b1; 
                  cmp_carry_in[4*i+2] = 1'b1; 
                end
              endcase
              cmp_carry_in[4*i+1] = cmp_sum[4*i][8]; 
              cmp_carry_in[4*i+3] = cmp_sum[4*i+2][8]; 
            end
            default:begin
              case (rdt_ctrl.cmp_opr)
                COUT:begin
                  cmp_carry_in[4*i]   = rdt_ctrl.vm ? 1'b0 : cin_data[4*i];
                  cmp_carry_in[4*i+1] = rdt_ctrl.vm ? 1'b0 : cin_data[4*i+1];
                  cmp_carry_in[4*i+2] = rdt_ctrl.vm ? 1'b0 : cin_data[4*i+2];
                  cmp_carry_in[4*i+3] = rdt_ctrl.vm ? 1'b0 : cin_data[4*i+3];
                end
                BOUT:begin
                  cmp_carry_in[4*i]   = rdt_ctrl.vm ? 1'b1 : bin_data[4*i];
                  cmp_carry_in[4*i+1] = rdt_ctrl.vm ? 1'b1 : bin_data[4*i+1];
                  cmp_carry_in[4*i+2] = rdt_ctrl.vm ? 1'b1 : bin_data[4*i+2];
                  cmp_carry_in[4*i+3] = rdt_ctrl.vm ? 1'b1 : bin_data[4*i+3];
                end
                default:begin
                  cmp_carry_in[4*i]   = 1'b1;
                  cmp_carry_in[4*i+1] = 1'b1;
                  cmp_carry_in[4*i+2] = 1'b1;
                  cmp_carry_in[4*i+3] = 1'b1;
                end
              endcase
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/4; i++) begin : gen_cmp_src_data

      // generate compare result for compare operation
      for (i=0; i<`VLENB; i++) begin : gen_compare_value
        assign cmp_sum[i]    = cmp_src2[i] + cmp_src1[i] + cmp_carry_in[i];
        assign less_than[i]  = cmp_sum[i][8];
        assign out_data[i]   = cmp_sum[i][8];
        assign great_than_equal[i] = ~cmp_sum[i][8]; 
        assign equal[i]      = cmp_sum[i][7:0] == '0;
        assign not_equal[i]  = cmp_sum[i][7:0] != '0;
      end

      // cmp_res data
      always_comb begin
        case (rdt_ctrl.cmp_opr)
          COUT,
          BOUT:begin
            case (pmtrdt_uop.vs2_eew)
              EEW32:begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = out_data[4*j+3]; 
                  cmp_res[j+`VLENB/4]   = out_data[4*j+3]; 
                  cmp_res[j+2*`VLENB/4] = out_data[4*j+3]; 
                  cmp_res[j+3*`VLENB/4] = out_data[4*j+3]; 
                end
              end
              EEW16:begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = out_data[2*j+1];
                  cmp_res[j+`VLENB/2] = out_data[2*j+1];
                end
              end
              default:begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = out_data[j];
                end
              end
            endcase
          end
          NOT_EQUAL:begin
            case (pmtrdt_uop.vs2_eew)
              EEW32: begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = |not_equal[4*j+:4]; 
                  cmp_res[j+`VLENB/4]   = |not_equal[4*j+:4]; 
                  cmp_res[j+2*`VLENB/4] = |not_equal[4*j+:4]; 
                  cmp_res[j+3*`VLENB/4] = |not_equal[4*j+:4]; 
                end
              end
              EEW16: begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = |not_equal[2*j+:2];
                  cmp_res[j+`VLENB/2] = |not_equal[2*j+:2];
                end
              end
              default: begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = not_equal[j];
                end
              end
            endcase
          end
          EQUAL:begin
            case (pmtrdt_uop.vs2_eew)
              EEW32: begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = &equal[4*j+:4];
                  cmp_res[j+`VLENB/4]   = &equal[4*j+:4];
                  cmp_res[j+2*`VLENB/4] = &equal[4*j+:4];
                  cmp_res[j+3*`VLENB/4] = &equal[4*j+:4];
                end
              end
              EEW16: begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = &equal[2*j+:2];
                  cmp_res[j+`VLENB/2] = &equal[2*j+:2];
                end
              end
              default: begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = equal[j];
                end
              end
            endcase
          end
          LESS_THAN:begin
            case (pmtrdt_uop.vs2_eew)
              EEW32: begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = less_than[4*j+3];
                  cmp_res[j+`VLENB/4]   = less_than[4*j+3];
                  cmp_res[j+2*`VLENB/4] = less_than[4*j+3];
                  cmp_res[j+3*`VLENB/4] = less_than[4*j+3];
                end
              end
              EEW16: begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = less_than[2*j+1];
                  cmp_res[j+`VLENB/2] = less_than[2*j+1];
                end
              end
              default: begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = less_than[j];
                end
              end
            endcase
          end
          LESS_THAN_OR_EQUAL:begin
            case (pmtrdt_uop.vs2_eew)
              EEW32: begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = less_than[4*j+3] | (&equal[4*j+:4]);
                  cmp_res[j+`VLENB/4]   = less_than[4*j+3] | (&equal[4*j+:4]);
                  cmp_res[j+2*`VLENB/4] = less_than[4*j+3] | (&equal[4*j+:4]);
                  cmp_res[j+3*`VLENB/4] = less_than[4*j+3] | (&equal[4*j+:4]);
                end
              end
              EEW16: begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = less_than[2*j+1] | (&equal[2*j+:2]);
                  cmp_res[j+`VLENB/2] = less_than[2*j+1] | (&equal[2*j+:2]);
                end
              end
              default: begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = less_than[j] | equal[j];
                end
              end
            endcase
          end
          default:begin //GREAT_THAN
            case (pmtrdt_uop.vs2_eew)
              EEW32: begin
                for (int j=0; j<`VLENB/4; j++) begin 
                  cmp_res[j]            = great_than_equal[4*j+3] & (|not_equal[4*j+:4]);
                  cmp_res[j+`VLENB/4]   = great_than_equal[4*j+3] & (|not_equal[4*j+:4]);
                  cmp_res[j+2*`VLENB/4] = great_than_equal[4*j+3] & (|not_equal[4*j+:4]);
                  cmp_res[j+3*`VLENB/4] = great_than_equal[4*j+3] & (|not_equal[4*j+:4]);
                end
              end
              EEW16: begin
                for (int j=0; j<`VLENB/2; j++) begin 
                  cmp_res[j]          = great_than_equal[2*j+1] & (|not_equal[2*j+:2]);
                  cmp_res[j+`VLENB/2] = great_than_equal[2*j+1] & (|not_equal[2*j+:2]);
                end
              end
              default: begin
                for (int j=0; j<`VLENB; j++) begin 
                  cmp_res[j] = great_than_equal[j] & not_equal[j];
                end
              end
            endcase
          end
        endcase
      end

      // cmp_res_offset/cmp_res_en_offset
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/4;
          EEW16: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/2;
          default: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB;
        endcase
      end
      assign cmp_res_en_offset = cmp_res_offset >> 2; // max eew is 32b or 4B, then VLEN/EEW_max = 4.

      // cmp_res_d/cmp_res_q
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32: cmp_res_en = (2*`VLENB)'('b1)  << cmp_res_en_offset;
          EEW16: cmp_res_en = (2*`VLENB)'('b11) << cmp_res_en_offset;
          default: cmp_res_en = (2*`VLENB)'('b1111) << cmp_res_en_offset;
        endcase
      end
      assign cmp_res_d = (`VLEN)'(cmp_res) << cmp_res_offset;
      for (i=0; i<(2*`VLENB); i++) begin
        edff #(.T(logic[`VLEN/32-1:0])) cmp_res_reg (.q(cmp_res_q[`VLEN/32*i+:`VLEN/32]), .d(cmp_res_d[`VLEN/32*i+:`VLEN/32]), .e(cmp_res_en[i] & pmtrdt_uop_valid & pmtrdt_uop_ready), .clk(clk), .rst_n(rst_n));
      end

      // cmp_vstart value is from the first uop of compare instruction
      assign cmp_vstart_d = pmtrdt_uop.vstart;
      assign cmp_vstart_en = pmtrdt_uop.first_uop_valid & pmtrdt_uop_valid & pmtrdt_uop_ready;
      edff #(.T(logic[`VSTART_WIDTH-1:0])) cmp_vstart_reg (.q(cmp_vstart_q), .d(cmp_vstart_d), .e(cmp_vstart_en), .clk(clk), .rst_n(rst_n));
      // pmtrdt_res_cmp
      for (i=0; i<`VLEN; i++) begin
        always_comb begin
          if (i < cmp_vstart_q)      pmtrdt_res_cmp[i] = rdt_ctrl_q.vs3_data[i];
          else if (i >= rdt_ctrl_q.cmp_evl) pmtrdt_res_cmp[i] = rdt_ctrl_q.vs3_data[i];
          else begin
            case (rdt_ctrl_q.cmp_opr)
              COUT,
              BOUT: pmtrdt_res_cmp[i] = cmp_res_q[i];
              default:
                if (rdt_ctrl_q.vm)         pmtrdt_res_cmp[i] = cmp_res_q[i];
                else if (rdt_ctrl_q.v0_data[i]) pmtrdt_res_cmp[i] = cmp_res_q[i];
                else                        pmtrdt_res_cmp[i] = rdt_ctrl_q.vs3_data[i];
            endcase
          end
        end
      end
    end // end if (GEN_CMP == 1'b1)
  endgenerate
  
// Permutation unit 
  // offset: select element
  generate
    if (GEN_PMT == 1'b1) begin
      // slide/gather instruction
      // vd data can be driven from all vs2 datas,
      // so PMT can not start to execute slide/gather uop
      // unless all uop(s) has been put in RS.
      assign rs_entry_valid = f_rs_decoder(uop_cnt);
      always_comb begin
        pmt_go = 1'b0;
        for (int j=0; j<`PMTRDT_RS_DEPTH; j++) begin
          pmt_go = pmt_go | (uop_data[j].last_uop_valid & rs_entry_valid[j]);
        end
        pmt_go = ~rdt_ctrl.compress & compress_ctrl_empty & (uop_type==PERMUTATION) & uop_data[0].first_uop_valid & pmt_go;
      end
      cdffr #(.T(logic)) pmt_go_reg (.q(pmt_go_q), .d(pmt_go), .c(trap_flush_rvv), .e(1'b1), .clk(clk), .rst_n(rst_n));

      for (i=0; i<`VLENB; i++) begin
        always_comb begin
          case(pmt_ctrl.pmt_opr)
            SLIDE_UP:begin
              if (pmtrdt_uop.uop_funct3 == OPMVX)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i-4);
                  EEW16:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i-2);
                  default:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i-1);
                endcase
              else
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB + i - (4*pmtrdt_uop.rs1_data));
                  EEW16:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB + i - (2*pmtrdt_uop.rs1_data));
                  default:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+ i - pmtrdt_uop.rs1_data);
                endcase
            end
            SLIDE_DOWN:begin
              if (pmtrdt_uop.uop_funct3 == OPMVX)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i+4);
                  EEW16:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i+2);
                  default:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB+i+1);
                endcase
              else
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB + i + (4*pmtrdt_uop.rs1_data));
                  EEW16:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB + i + (2*pmtrdt_uop.rs1_data));
                  default:offset[i] = (`XLEN+2)'(uop_data[pmt_uop_done_cnt_q].uop_index*`VLENB + i + pmtrdt_uop.rs1_data);
                endcase
            end
            GATHER:begin
              case (pmtrdt_uop.uop_funct3)
                OPIVX,
                OPIVI:begin
                  case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                    EEW32:offset[i] = (`XLEN+2)'(i%4 + {pmtrdt_uop.rs1_data,2'b0});
                    EEW16:offset[i] = (`XLEN+2)'(i%2 + {pmtrdt_uop.rs1_data,1'b0});
                    default:offset[i] = (`XLEN+2)'(pmtrdt_uop.rs1_data);
                  endcase
                end
                default:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32: offset[i] = (`XLEN+2)'(i%4 + (4*{{(`XLEN-32){1'b0}}, uop_data[(pmt_uop_done_cnt_q*`VLENB/4+i/4)/(`VLENB/4)].vs1_data[32*((i/4)%(`VLENB/4))+:32]}));
                    EEW16: begin
                      case (pmtrdt_uop.vs2_eew) // vrgatherei16
                        EEW32:offset[i] = (`XLEN+2)'(i%4 + (4*{{(`XLEN-16){1'b0}}, uop_data[(pmt_uop_done_cnt_q*`VLENB/4+i/4)/(`VLENB/4)].vs1_data[16*((pmt_uop_done_cnt_q*`VLENB/4+i/4)%(`VLENB/2))+:16]}));
                        EEW16:offset[i] = (`XLEN+2)'(i%2 + (2*{{(`XLEN-16){1'b0}}, uop_data[(pmt_uop_done_cnt_q*`VLENB/2+i/2)/(`VLENB/2)].vs1_data[16*((i/2)%(`VLENB/2))+:16]}));
                        default:offset[i] = (`XLEN+2)'({{(`XLEN-16){1'b0}}, uop_data[(pmt_uop_done_cnt_q*`VLENB+i)/(`VLENB)].vs1_data[16*(i%(`VLENB/2))+:16]});
                      endcase
                    end
                    default: offset[i] = (`XLEN+2)'({{(`XLEN-8){1'b0}}, uop_data[(pmt_uop_done_cnt_q*`VLENB+i)/(`VLENB)].vs1_data[8*(i%(`VLENB))+:8]});
                  endcase
                end
              endcase
            end
            default: offset[i] = (`XLEN+2)'(i);
          endcase
        end
      end

      //select scalar value
      //for vslide1up, vd[0] = x[rs1]
      //for vslide1down, vd[vl-1] = x[rs1]
      always_comb begin
        if (pmtrdt_uop.uop_funct3 == OPMVX) begin
          case (pmt_ctrl.pmt_opr)
            SLIDE_UP:begin
              if (pmt_uop_done_cnt_q == 0)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:sel_scalar = (`VLENB)'('hF);
                  EEW16:sel_scalar = (`VLENB)'('h3);
                  default:sel_scalar = (`VLENB)'('h1);
                endcase
              else
                sel_scalar = '0;
            end
            SLIDE_DOWN:begin
              case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                EEW32:sel_scalar = (uop_data[pmt_uop_done_cnt_q].uop_index+1'b1)*(`VLENB/4) >= rdt_ctrl.vl ?
                                    (`VLENB)'('hF) << ((rdt_ctrl.vl-1)%(`VLENB/4))*4 : '0;
                EEW16:sel_scalar = (uop_data[pmt_uop_done_cnt_q].uop_index+1'b1)*(`VLENB/2) >= rdt_ctrl.vl ?
                                    (`VLENB)'('h3) << ((rdt_ctrl.vl-1)%(`VLENB/2))*2 : '0;
                default:sel_scalar = (uop_data[pmt_uop_done_cnt_q].uop_index+1'b1)*`VLENB >= rdt_ctrl.vl ?
                                    (`VLENB)'('h1) << ((rdt_ctrl.vl-1)%(`VLENB))*1 : '0;
              endcase
            end
            default:sel_scalar = '0;
          endcase
        end else begin
          sel_scalar = '0;
        end
      end

      always_comb begin
        if (pmtrdt_uop.vs2_eew == EEW8 && pmtrdt_uop.vs1_eew == EEW16)
          for (int j=0; j<`VLMAX_MAX/2; j++) begin
            pmt_vs2_data[j] = uop_data[j/(`VLENB/2)].vs2_data[8*(j%(`VLENB))+:8];
            pmt_vs2_data[j+`VLMAX_MAX/2] = '0;
          end
        else
          for (int j=0; j<`VLMAX_MAX; j++)
            pmt_vs2_data[j] = uop_data[j/(`VLENB)].vs2_data[8*(j%(`VLENB))+:8];
      end

      for (i=0; i<`VLMAX_MAX; i++) begin
        assign pmt_vs3_data[i] = uop_data[i/(`VLENB)].vs3_data[8*(i%(`VLENB))+:8];
      end

      // permutation instruction (vslide1up/vslide1down): rs1_eew == vs2_eew
      always_comb begin
        case (pmtrdt_uop.vs2_eew) 
          EEW32:pmt_rs1_data = {(`XLEN/32){pmtrdt_uop.rs1_data[31:0]}};
          EEW16:pmt_rs1_data = {(`XLEN/16){pmtrdt_uop.rs1_data[15:0]}};
          default:pmt_rs1_data = {(`XLEN/8){pmtrdt_uop.rs1_data[7:0]}};
        endcase
      end

      // pmt_res_d/pmt_res_q
      assign pmt_res_en = pmt_go;
      for (i=0; i<`VLENB; i++) begin
        always_comb begin
          slide_down_offset[i] = offset[i]-(pmtrdt_uop.uop_index*`VLENB);
          if (sel_scalar[i]) pmt_res_d[i] = pmt_rs1_data[8*(i%4)+:8];
          else
            case (pmt_ctrl.pmt_opr)
              SLIDE_UP:begin
                case (pmtrdt_uop.vs2_eew) // permutation instruction
                  EEW32: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(4*pmtrdt_uop.vlmax) ? pmt_vs3_data[pmt_uop_done_cnt_q*`VLENB+i] : pmt_vs2_data[offset[i][7:0]];
                  EEW16: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(2*pmtrdt_uop.vlmax) ? pmt_vs3_data[pmt_uop_done_cnt_q*`VLENB+i] : pmt_vs2_data[offset[i][7:0]];
                  default: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(pmtrdt_uop.vlmax) ? pmt_vs3_data[pmt_uop_done_cnt_q*`VLENB+i] : pmt_vs2_data[offset[i][7:0]];
                endcase
              end
              SLIDE_DOWN:begin
                case (pmtrdt_uop.vs2_eew)
                  EEW32: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(4*pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[slide_down_offset[i][7:0]];
                  EEW16: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(2*pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[slide_down_offset[i][7:0]];
                  default: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[slide_down_offset[i][7:0]];
                endcase
              end
              default: begin
                case (pmtrdt_uop.vs2_eew)
                  EEW32: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(4*pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[offset[i][7:0]];
                  EEW16: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(2*pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[offset[i][7:0]];
                  default: pmt_res_d[i] = offset[i] >= (`XLEN+2)'(pmtrdt_uop.vlmax) ? '0 : pmt_vs2_data[offset[i][7:0]];
                endcase
              end
            endcase
        end
        edff #(.T(logic[7:0])) pmt_res_reg (.q(pmt_res_q[i]), .d(pmt_res_d[i]), .e(pmt_res_en), .clk(clk), .rst_n(rst_n));
        assign pmtrdt_res_pmt[i*8+:8] = pmt_res_q[i];
      end

      // pmt_uop_done_cnt_d/pmt_uop_done_cnt_q
      assign pmt_uop_done_cnt_d = pmt_uop_done_cnt_q + 1'b1;
      cdffr #(.T(logic[`UOP_INDEX_WIDTH-1:0])) pmt_uop_done_cnt_reg (.q(pmt_uop_done_cnt_q), .d(pmt_uop_done_cnt_d), .c(uop_data[pmt_uop_done_cnt_q].last_uop_valid | trap_flush_rvv), .e(pmt_go), .clk(clk), .rst_n(rst_n));

  // Compress instruction
    // compress instruction is a specified instruction in PMT.
    // the vl of vd in compress can not be acknowledged untill decode vs1 value.
      // compress_mask_d is driven from shifted vs1_data based on vs2_eew
      always_comb begin
        case (pmtrdt_uop.vs2_eew) // vcompress instruction: vd_eew == vs2_eew
          EEW32:compress_mask_d = pmtrdt_uop.uop_index == '0 ? pmtrdt_uop.vs1_data >> (`VLENB/4) : compress_mask_q >> (`VLENB/4);
          EEW16:compress_mask_d = pmtrdt_uop.uop_index == '0 ? pmtrdt_uop.vs1_data >> (`VLENB/2) : compress_mask_q >> (`VLENB/2);
          default:compress_mask_d = pmtrdt_uop.uop_index == '0 ? pmtrdt_uop.vs1_data >> `VLENB : compress_mask_q >> `VLENB;
        endcase
      end
      assign compress_mask_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
      edff #(.T(logic[`VLEN-1:0])) compress_mask_reg (.q(compress_mask_q), .d(compress_mask_d), .e(compress_mask_en), .clk(clk), .rst_n(rst_n));

      // compress_enable is from vs1_data[0+:N] based on vs2_eew
      // and then be extended to `VLENB bits.
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32:begin
            for (int j=0; j<`VLENB/4; j++) begin
              compress_enable[4*j+:4] = pmtrdt_uop.uop_index == '0 ? {4{pmtrdt_uop.vs1_data[j]}} : {4{compress_mask_q[j]}};
            end
          end
          EEW16:begin
            for (int j=0; j<`VLENB/2; j++) begin
              compress_enable[2*j+:2] = pmtrdt_uop.uop_index == '0 ? {2{pmtrdt_uop.vs1_data[j]}} : {2{compress_mask_q[j]}};
            end
          end
          default:compress_enable = pmtrdt_uop.uop_index == '0 ? pmtrdt_uop.vs1_data[`VLENB-1:0] : compress_mask_q[`VLENB-1:0];
        endcase
      end

      // compress_body is driven from vl & uop_index
      // 0: tail element; 1: body element
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32:compress_body = (pmtrdt_uop.vl > pmtrdt_uop.uop_index*`VLENB/4) ? ~({`VLENB{1'b1}} << (4*(pmtrdt_uop.vl - pmtrdt_uop.uop_index*`VLENB/4))) : '0;
          EEW16:compress_body = (pmtrdt_uop.vl > pmtrdt_uop.uop_index*`VLENB/2) ? ~({`VLENB{1'b1}} << (2*(pmtrdt_uop.vl - pmtrdt_uop.uop_index*`VLENB/2))) : '0;
          default:compress_body = (pmtrdt_uop.vl > pmtrdt_uop.uop_index*`VLENB) ? ~({`VLENB{1'b1}} << (pmtrdt_uop.vl - pmtrdt_uop.uop_index*`VLENB)) : '0;
        endcase
      end

      // compress_cnt indicates how much bytes have been compressed
      always_comb begin
        if (pmtrdt_uop.uop_index == '0) compress_cnt_d = f_sum(compress_enable & compress_body);
        else                            compress_cnt_d = compress_cnt_q + f_sum(compress_enable & compress_body);
      end
      assign compress_cnt_en = pmtrdt_uop_valid & pmtrdt_uop_ready & rdt_ctrl.compress;
      assign compress_cnt_clr =  ~compress_cnt_gt_vlenb & rdt_ctrl_q.last_uop_valid; 
      cdffr #(.T(logic[VLENB_WIDTH:0])) compress_cnt_reg (.q(compress_cnt_q), .d(compress_cnt_d), .c(~compress_cnt_en & compress_cnt_clr | trap_flush_rvv), .e(compress_cnt_en), .clk(clk), .rst_n(rst_n));
      cdffr #(.T(logic[VLENB_WIDTH:0])) compress_cnt_reg_reg (.q(compress_cnt_qq), .d(compress_cnt_q), .c(compress_cnt_clr | trap_flush_rvv), .e(1'b1), .clk(clk), .rst_n(rst_n));
      
      // set if compress more than or equal 16 byte and then write the result to ROB
      assign compress_cnt_ge_vlenb = compress_cnt_qq[VLENB_WIDTH] ^ compress_cnt_q[VLENB_WIDTH];
      assign compress_cnt_gt_vlenb = compress_cnt_ge_vlenb & (|compress_cnt_q[VLENB_WIDTH-1:0]);

      // compress_offset select elements of vs2_data and compress to compress_value
      assign compress_offset = f_compress_offset(compress_enable);
      for (i=0; i<`VLENB; i++) begin
        assign compress_value[i] = compress_offset[i] == '1 ? '0 : pmtrdt_uop.vs2_data[8*compress_offset[i]+:8];
      end

      // compress_res is driven by compress_value and compress_cnt.
      always_comb begin
        if (pmtrdt_uop.first_uop_valid) compress_res_d = (2*`VLENB*8)'(compress_value);
        else                            compress_res_d = f_circular_shift(compress_value, compress_cnt_q);
      end

      // compress_res_en
      always_comb begin
        if (compress_ctrl_push)
          if (pmtrdt_uop.first_uop_valid) compress_res_en = (2*`VLENB)'(f_pack_1s(compress_enable));
          else                            compress_res_en = f_circular_en(compress_enable,compress_cnt_q);
        else 
          compress_res_en = '0;
      end
      for (i=0; i<2*`VLENB; i++) edff #(.T(logic[7:0])) compress_res_reg (.q(compress_res_q[i]), .d(compress_res_d[i]), .e(compress_res_en[i]), .clk(clk), .rst_n(rst_n));

      // pmtrdt_res_compress
      assign valid_num[1] = compress_cnt_q[VLENB_WIDTH:0] - `VLENB;
      assign valid_num[0] = compress_cnt_q[VLENB_WIDTH:0];
      always_comb begin
        if (rdt_ctrl_q.last_uop_valid) begin
          if (compress_cnt_qq[VLENB_WIDTH]) 
            pmtrdt_res_compress = f_res_compress_merge(compress_ctrl_ex1.vs3_data, compress_res_q[`VLENB+:`VLENB], valid_num[1]);
          else
            pmtrdt_res_compress = f_res_compress_merge(compress_ctrl_ex1.vs3_data, compress_res_q[0+:`VLENB], valid_num[0]);
        end else begin
          if (compress_cnt_qq[VLENB_WIDTH])
            pmtrdt_res_compress = compress_res_q[2*`VLENB-1:`VLENB];
          else
            pmtrdt_res_compress = compress_res_q[`VLENB-1:0];
        end
      end

      // compress control fifo
      // based on the value of vs1, one or multiple uop(s) writes one vd.
      // the remaining elements of vd are treated as tail elements.
    `ifdef TB_SUPPORT
      assign compress_ctrl_ex0.uop_pc = pmtrdt_uop.uop_pc;
    `endif
      assign compress_ctrl_ex0.rob_entry      = pmtrdt_uop.rob_entry;
      assign compress_ctrl_ex0.vs3_data       = pmtrdt_uop.vs3_data;
      assign compress_ctrl_ex0.last_uop_valid = pmtrdt_uop.last_uop_valid;

      assign compress_ctrl_push = pmtrdt_uop_valid & pmtrdt_uop_ready & rdt_ctrl.compress;
      assign compress_ctrl_pop  = (compress_cnt_ge_vlenb | rdt_ctrl_q.last_uop_valid & rdt_ctrl_q.compress);

      multi_fifo #(
        .T            (COMPRESS_CTRL_t),
        .M            (1),
        .N            (1),
        .DEPTH        (`EMUL_MAX),
        .ASYNC_RSTN   (1)
      ) compress_ctrl_fifo (
        // global
          .clk          (clk),
          .rst_n        (rst_n),
        // write
          .push         (compress_ctrl_push),
          .datain       (compress_ctrl_ex0),
        // read
          .pop          (compress_ctrl_pop),
          .dataout      (compress_ctrl_ex1),
        // fifo status
          .full         (),
          .almost_full  (),
          .empty        (compress_ctrl_empty),
          .almost_empty (),
          .clear        (trap_flush_rvv),
          .fifo_data    (),
          .wptr         (),
          .rptr         (),
          .entry_count  ()
      );

    end // if (GEN_PMT == 1'b1) 
  endgenerate

// output result
  always_comb begin
    case (uop_type_q)
      PERMUTATION: pmtrdt_res_valid = rdt_ctrl_q.compress ? compress_ctrl_pop
                                                          : pmt_go_q;
      default: pmtrdt_res_valid = rdt_ctrl_q.last_uop_valid;
    endcase
  end

  always_comb begin
    `ifdef TB_SUPPORT
    // uop_pc
    case (uop_type_q)
      PERMUTATION: pmtrdt_res.uop_pc = rdt_ctrl_q.compress ? compress_ctrl_ex1.uop_pc : pmt_ctrl_q.uop_pc;
      default:     pmtrdt_res.uop_pc = rdt_ctrl_q.uop_pc; 
    endcase
    `endif
    
    // rob_entry
    case (uop_type_q)
      PERMUTATION:pmtrdt_res.rob_entry = rdt_ctrl_q.compress ? compress_ctrl_ex1.rob_entry : pmt_ctrl_q.rob_entry;
      default:    pmtrdt_res.rob_entry = rdt_ctrl_q.rob_entry;
    endcase

    // write valid
    pmtrdt_res.w_valid = 1'b1;

    // saturate
    pmtrdt_res.vsaturate = '0;

    // data
    case (uop_type_q)
      PERMUTATION: pmtrdt_res.w_data = rdt_ctrl_q.compress ? pmtrdt_res_compress : pmtrdt_res_pmt;
      REDUCTION:   pmtrdt_res.w_data = pmtrdt_res_red;
      COMPARE:     pmtrdt_res.w_data = pmtrdt_res_cmp;
      default:     pmtrdt_res.w_data = pmtrdt_res_cmp;
    endcase
  end

  // pmtrdt_uop_ready:
  // 1. CMP instruction - always 1
  // 2. RDT instruction
  //    VWREDSUMU&VWREDSUM - set 1 only if red_widen_sum_flag toggle to 1.
  //    the others         - clear 0
  // 3. PMT instruction - set 1 only if last_uop_valid is asserted.
  cdffr #(.T(logic)) wredsum_flag_reg (.q(red_widen_sum_flag), .d(~red_widen_sum_flag), .c(trap_flush_rvv), .e(rdt_ctrl.widen & pmtrdt_uop_valid), .clk(clk), .rst_n(rst_n));
  always_comb begin
    if (compress_ctrl_empty)
      case (uop_type)
        PERMUTATION: pmtrdt_uop_ready = rdt_ctrl.compress ? (compress_ctrl_ex1.last_uop_valid | ~rdt_ctrl_q.last_uop_valid)
                                                          : uop_data[pmt_uop_done_cnt_q].last_uop_valid || ~uop_data[0].first_uop_valid;
        REDUCTION:
          if (rdt_ctrl.widen) pmtrdt_uop_ready = red_widen_sum_flag;
          else                pmtrdt_uop_ready = 1'b1;
        default: pmtrdt_uop_ready = 1'b1;
      endcase
    else pmtrdt_uop_ready = rdt_ctrl.compress ? (compress_ctrl_ex1.last_uop_valid | ~rdt_ctrl_q.last_uop_valid)
                                              : pmt_go & uop_data[pmt_uop_done_cnt_q].last_uop_valid | ~uop_data[0].first_uop_valid;
  end

// ---function--------------------------------------------------------
// f_sum: sum how many bits are asserted.
  function [VLENB_WIDTH:0] f_sum;
    input [`VLENB-1:0] vector_bits;

    int                i;
    logic [VLENB_WIDTH:0] sum_val;
    begin
      sum_val = '0;
      for (i=0; i<`VLENB; i++) begin
        sum_val = sum_val + vector_bits[i];
      end
      f_sum = sum_val;
    end
  endfunction

// f_compress_offset: extract valid bit and put its index to offset 
  function [`VLENB-1:0][VLENB_WIDTH:0] f_compress_offset;
    input [`VLENB-1:0] enables;

    int                i,j;
    logic [`VLENB-1:0][VLENB_WIDTH:0] results;
    begin
      j = 0;
      for (i=0; i<`VLENB; i++) results[i] = '1;
      for (i=0; i<`VLENB; i++) begin
        if (enables[i]) begin
          results[j] = (VLENB_WIDTH+1)'(i);
          j++;
        end
      end
      f_compress_offset = results;
    end
  endfunction

// f_circular_shift: circular shift result to proper site 
  function [2*`VLENB-1:0][7:0] f_circular_shift;
    input [`VLENB-1:0][7:0] value; 
    input [VLENB_WIDTH:0]   shift;

    logic [`VLEN-1:0]       value_tmp;
    logic [`VLEN-1:0]       buf2,buf1,buf0;
    logic [1:0][`VLEN-1:0]  result;
    begin
      value_tmp = value;
      {buf2,buf1,buf0} = (3*`VLEN)'(value_tmp) << (shift*8);
      result = shift[VLENB_WIDTH] ? {buf1, buf2} : {buf1,buf0};
      f_circular_shift = result;
    end
  endfunction

// f_pack_1s: collect all 1s and pack themsigned(dest) < $signed(src2)
  function [`VLENB-1:0] f_pack_1s;
    input [`VLENB-1:0] value;
    
    int                i,j;
    logic [`VLENB-1:0] result;
    begin
      j = 0;
      result = '0;
      for (i=0; i<`VLENB; i++)
        if (value[i]) begin
          result[j] = 1'b1;
          j++;
        end
      f_pack_1s = result;
    end
  endfunction

// f_circular_en: circular shift enable signals
  function [2*`VLENB-1:0] f_circular_en;
    input [`VLENB-1:0]    value;
    input [VLENB_WIDTH:0] shift;

    logic [`VLENB-1:0]    value_pack_1s;
    logic [`VLENB-1:0]    en2,en1,en0;
    logic [1:0][`VLENB-1:0] result;
    begin
      value_pack_1s = f_pack_1s(value);
      {en2,en1,en0} = (3*`VLENB)'(value_pack_1s) << shift;
      result = shift[VLENB_WIDTH] ? {en1, en2} : {en1, en0};
      f_circular_en = result;
    end
  endfunction

// f_res_compress_merge: merge raw data with copmress result
  function [`VLEN-1:0] f_res_compress_merge;
    input [`VLENB-1:0][7:0] raw_data;
    input [`VLENB-1:0][7:0] res_data;
    input [VLENB_WIDTH:0] valid_num;

    int                     i;
    logic [`VLENB-1:0]      valid;
    logic [`VLENB-1:0][7:0] result;
    begin
      for (i=0; i<`VLENB; i++) begin
        if (i < valid_num) valid[i] = 1'b1;
        else               valid[i] = 1'b0;
        result[i] = valid[i] ? res_data[i] : raw_data[i];
      end
      f_res_compress_merge = result;
    end
  endfunction

// f_rs_decoder: decoder for reservation station
  function [`PMTRDT_RS_DEPTH-1:0] f_rs_decoder;
    input [$clog2(`PMTRDT_RS_DEPTH):0] cnt;

    logic [`PMTRDT_RS_DEPTH-1:0]       result;
    begin
      result = '1 << cnt;
      result = ~result;
      f_rs_decoder = result;
    end
  endfunction

endmodule
