// description
// 1. the pmtrdt_unit module is responsible for one PMTRDT instruction.
//
// feature list:
// 1. Compare/Reduction/Compress instruction is optional based on parameters.
// 2. the latency of all instructions is 2-cycles.

`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"
`include "rvv_backend_pmtrdt.svh"

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

  uop_data
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

// ---internal signal definition--------------------------------------
  PMTRDT_CTRL_t             ctrl, ctrl_q; // control signals
  logic                     ctrl_reg_en, ctrl_reg_clr;

  // Reduction operation
  logic                     red_widen_sum_flag;
  logic [`VLEN-1:0]         widen_vs2;       // vs2 data after being widen if need
  BYTE_TYPE_t               widen_vs2_type;  // vs2 data btpe type after being widen if need
  logic [`VLENB/2-1:0][7:0] src1_bit, src2_bit;       // and/or /xor operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0][8:0] src1_1stage, src2_1stage; // max/min/sum operation: source value for reduction vs2[*]
  logic [`VLENB/2-1:0]      carry_in_1stage;
  logic [`VLENB/2-1:0][8:0] sum_1stage;
  logic [`VLENB/2-1:0][7:0] and_1stage, or_1stage, xor_1stage;
  logic [`VLENB/2-1:0]      less_than_1stage, great_than_1stage;
  logic [`VLENB/4-1:0][8:0] src1_2stage, src2_2stage; // max/min/sum operation: source value for reduction res_1stage[*]
  logic [`VLENB/4-1:0]      carry_in_2stage;
  logic [`VLENB/4-1:0][8:0] sum_2stage;
  logic [`VLENB/4-1:0][7:0] and_2stage, or_2stage, xor_2stage;
  logic [`VLENB/4-1:0]      less_than_2stage, great_than_2stage;
  logic                     sel_vs1; // operate vs1[0] if the last operation for reduction instruction
  logic [3:0][8:0]          src1_vd, src2_vs1;        // source value for reduction vs1[0] & vd[0]
  logic [3:0]               carry_in_vd;
  logic [3:0][8:0]          sum_vd;
  logic [3:0][7:0]          and_vd, or_vd, xor_vd;
  logic [3:0]               less_than_vd, great_than_vd;
  logic [`VLENB/4-1:0][8:0] src1_3stage, src2_3stage; // source value for reduction res_2stage[*] & res_vd[*]
  logic [`VLENB/4-1:0]      carry_in_3stage;
  logic [`VLENB/4-1:0][8:0] sum_3stage;
  logic [`VLENB/4-1:0][7:0] and_3stage, or_3stage, xor_3stage;
  logic [`VLENB/4-1:0]      less_than_3stage, great_than_3stage;
  logic [`VLENB/4-1:0][7:0] red_res_d, red_res_q;
  logic [7:0]               sum_8b,  max_8b,  min_8b,  and_8b,  or_8b,  xor_8b;
  logic [15:0]              sum_16b, max_16b, min_16b, and_16b, or_16b, xor_16b;
  logic [31:0]              sum_32b, max_32b, min_32b, and_32b, or_32b, xor_32b;
  logic [`VLEN-1:0]         pmtrdt_res_red; // pmtrdt result of reduction
  // Comparation operation
  logic [`VSTART_WIDTH-1:0] cmp_vstart_d, cmp_vstart_q;
  logic                     cmp_vstart_en;
  logic [`VLENB-1:0][8:0]   cmp_src1, cmp_src2; // source value for reduction/compare
  logic [`VLENB-1:0]        cmp_carry_in;
  logic [`VLENB-1:0][8:0]   cmp_sum;
  logic [`VLENB-1:0]        less_than, great_than_equal, equal, not_equal;
  logic [`VLENB-1:0]        cmp_res;
  logic [`VSTART_WIDTH-1:0] cmp_res_offset;
  logic [`VLEN-1:0]         cmp_res_d, cmp_res_q, cmp_res_en;
  logic [`VLEN-1:0]         pmtrdt_res_cmp; // pmtrdt result of compare
  // Permutation operation
  // slide+gather instruction
  logic [`VLENB-1:0][`XLEN-1:0] offset;
  logic [`VLENB-1:0]            sel_scalar;
  BYTE_TYPE_t                   vd_type;
  logic [`VLMAX-1:0][7:0]   pmt_vs2_data;
  logic [`XLEN-1:0]         pmt_rs1_data;
  logic [`VLENB-1:0][7:0]   pmt_res_d, pmt_res_q;
  logic [`VLEN-1:0]         pmtrdt_res_pmt; // pmtrdt result of permutation
  // compress instruction
  logic [`VLENB-1:0]        compress_enable;
  logic [`VLENB-1:0][VLENB_WIDTH:0] compress_offset;
  logic [`VLEN-1:0]         compress_mask_d, compress_mask_q; // register vs1_data for compress mask
  logic                     compress_mask_en;
  logic [VLENB_WIDTH:0]     compress_cnt_d, compress_cnt_q;   // compress counter
  logic                     compress_cnt_en;
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
      PMT: ctrl.uop_type = PERMUTATION;
      RDT: ctrl.uop_type = REDUCTION;
      default : ctrl.uop_type = COMPARE;
    endcase
  end

  // sign_opr: 0-unsigned, 1-signed
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VMSLTU,
      VMSLEU,
      VMSGTU,
      VREDMAXU,
      VREDMINU,
      VWREDSUMU: ctrl.sign_opr = 1'b0;
      default  : ctrl.sign_opr = 1'b1;
    endcase
  end

  // gt_lt_eq: great than / less than / equal
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VMSEQ: ctrl.gt_lt_eq = EQUAL;
      VMSNE: ctrl.gt_lt_eq = NOT_EQUAL;
      VMSLTU,
      VMSLT: ctrl.gt_lt_eq = LESS_THAN;
      VMSLEU,
      VMSLE: ctrl.gt_lt_eq = LESS_THAN_OR_EQUAL;
      VMSGTU,
      VMSGT: ctrl.gt_lt_eq = GREAT_THAN;
      default: ctrl.gt_lt_eq = NOT_EQUAL;
    endcase
  end

  // widen: vd EEW = 2*SEW
  assign ctrl.widen = (pmtrdt_uop.uop_funct6 == VWREDSUMU) ||
                       (pmtrdt_uop.uop_funct6 == VWREDSUM);

  // rdt_opr: reduction operation
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VREDSUM,
      VWREDSUMU,
      VWREDSUM: ctrl.rdt_opr = SUM;
      VREDMAXU,
      VREDMAX:  ctrl.rdt_opr = MAX;
      VREDMINU,
      VREDMIN:  ctrl.rdt_opr = MIN;
      VREDAND:  ctrl.rdt_opr = AND;
      VREDOR:   ctrl.rdt_opr = OR;
      VREDXOR:  ctrl.rdt_opr = XOR;
      default:  ctrl.rdt_opr = SUM;
    endcase
  end

  // pmt_opr: permutation operation
  always_comb begin
    case (pmtrdt_uop.uop_funct6)
      VSLIDE1UP,
      VSLIDEUP_RGATHEREI16: ctrl.pmt_opr = pmtrdt_uop.uop_funct3 == OPIVV ? GATHER : SLIDE_UP;
      VSLIDEDOWN,
      VSLIDE1DOWN:ctrl.pmt_opr = SLIDE_DOWN;
      VRGATHER:   ctrl.pmt_opr = GATHER;
      default:    ctrl.pmt_opr = GATHER;
    endcase
  end

  assign ctrl.compress = pmtrdt_uop.uop_exe_unit == PMT && pmtrdt_uop.uop_funct6 == VCOMPRESS;

  // uop infomation
`ifdef TB_SUPPORT
  assign ctrl.uop_pc = pmtrdt_uop.uop_pc;
`endif
  assign ctrl.rob_entry = pmtrdt_uop.rob_entry;
  assign ctrl.vl     = pmtrdt_uop.vl;
  assign ctrl.vm     = pmtrdt_uop.vm;
  assign ctrl.vs1_eew        = pmtrdt_uop.vs1_eew;
  assign ctrl.v0_data        = pmtrdt_uop.v0_data;
  assign ctrl.vs3_data       = pmtrdt_uop.vs3_data;
  assign ctrl.last_uop_valid = pmtrdt_uop.last_uop_valid;

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
      EEW32: ctrl.cmp_evl = pmtrdt_uop.uop_index * (`VLENB/4) + (`VLENB/4);
      EEW16: ctrl.cmp_evl = pmtrdt_uop.uop_index * (`VLENB/2) + (`VLENB/2);
      default:ctrl.cmp_evl = pmtrdt_uop.uop_index * `VLENB + `VLENB;
    endcase
  end

  // when to clear ctrl reg?
  // if ex0 stage has no uop to execute!
  assign ctrl_reg_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
  assign ctrl_reg_clr = !ctrl_reg_en & ctrl_q.last_uop_valid;
  cdffr #(.WIDTH($bits(PMTRDT_CTRL_t))) ctrl_reg (.q(ctrl_q), .d(ctrl), .c(ctrl_reg_clr), .e(ctrl_reg_en), .clk(clk), .rst_n(rst_n));
  
// Reduction unit
  generate
    if (GEN_RDT == 1'b1) begin
      // src1_bit/src2_bit data for bit manipulation: and/or/xor
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_src_bit_data
        // src2_bit data
        always_comb begin
          case (ctrl.rdt_opr)
            AND:begin
              src2_bit[4*i]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'hFF;
              src2_bit[4*i+1] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'hFF;
              src2_bit[4*i+2] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'hFF;
              src2_bit[4*i+3] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : 8'hFF;
            end
            default:begin
              src2_bit[4*i]   = pmtrdt_uop.vs2_type[8*i]   == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i)+:8]   : 8'h00;
              src2_bit[4*i+1] = pmtrdt_uop.vs2_type[8*i+1] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+1)+:8] : 8'h00;
              src2_bit[4*i+2] = pmtrdt_uop.vs2_type[8*i+2] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+2)+:8] : 8'h00;
              src2_bit[4*i+3] = pmtrdt_uop.vs2_type[8*i+3] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+3)+:8] : 8'h00;
            end
          endcase
        end

        // src1_bit data
        always_comb begin
          case (ctrl.rdt_opr)
            AND:begin
              src1_bit[4*i]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : 8'hFF;
              src1_bit[4*i+1] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : 8'hFF;
              src1_bit[4*i+2] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : 8'hFF;
              src1_bit[4*i+3] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : 8'hFF;
            end
            default:begin
              src1_bit[4*i]   = pmtrdt_uop.vs2_type[8*i+4] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+4)+:8] : 8'h00;
              src1_bit[4*i+1] = pmtrdt_uop.vs2_type[8*i+5] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+5)+:8] : 8'h00;
              src1_bit[4*i+2] = pmtrdt_uop.vs2_type[8*i+6] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+6)+:8] : 8'h00;
              src1_bit[4*i+3] = pmtrdt_uop.vs2_type[8*i+7] == BODY_ACTIVE ? pmtrdt_uop.vs2_data[8*(8*i+7)+:8] : 8'h00;
            end
          endcase
        end
      end

      // widen vs2 data & widen vs2 eew
      always_comb begin
        if (ctrl.widen) begin
          if (red_widen_sum_flag) begin // select high part of vs2_data
            case(pmtrdt_uop.vs2_eew)
              EEW16:begin
                for (int j=0; j<`VLENB/4; j++) begin
                  widen_vs2[16*(2*j)+:16]   = pmtrdt_uop.vs2_data[(`VLEN/2+16*j)+:16];
                  widen_vs2[16*(2*j+1)+:16] = ctrl.sign_opr ? {16{pmtrdt_uop.vs2_data[`VLEN/2+16*(j+1)-1]}}
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
                  widen_vs2[8*(2*j+1)+:8] = ctrl.sign_opr ? {8{pmtrdt_uop.vs2_data[`VLEN/2+8*(j+1)-1]}}
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
                  widen_vs2[16*(2*j+1)+:16] = ctrl.sign_opr ? {16{pmtrdt_uop.vs2_data[16*(j+1)-1]}}
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
                  widen_vs2[8*(2*j+1)+:8] = ctrl.sign_opr ? {8{pmtrdt_uop.vs2_data[8*(j+1)-1]}}
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
  // src1_1stage/src2_1stage/carry_in_1stage data
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_src_1stage_data
        // src2_1stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'h00;
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : 8'h00; 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'h00; 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                end
                EEW16:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'h00;
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'h00; 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                end
                default:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : (ctrl.sign_opr ? 8'h80 : 8'h00);
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'hFF;
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : 8'hFF; 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'hFF; 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h7F : 8'hFF); 
                end
                EEW16:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'hFF;
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : (ctrl.sign_opr ? 8'h7F : 8'hFF); 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'hFF; 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h7F : 8'hFF); 
                end
                default:begin
                  src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : (ctrl.sign_opr ? 8'h80 : 8'h00);
                  src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                  src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                  src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : (ctrl.sign_opr ? 8'h80 : 8'h00); 
                end
              endcase
            end
            default:begin
              src2_1stage[4*i][7:0]   = widen_vs2_type[8*i]   == BODY_ACTIVE ? widen_vs2[8*(8*i)+:8]   : 8'h00; 
              src2_1stage[4*i+1][7:0] = widen_vs2_type[8*i+1] == BODY_ACTIVE ? widen_vs2[8*(8*i+1)+:8] : 8'h00; 
              src2_1stage[4*i+2][7:0] = widen_vs2_type[8*i+2] == BODY_ACTIVE ? widen_vs2[8*(8*i+2)+:8] : 8'h00; 
              src2_1stage[4*i+3][7:0] = widen_vs2_type[8*i+3] == BODY_ACTIVE ? widen_vs2[8*(8*i+3)+:8] : 8'h00; 
            end
          endcase
          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              src2_1stage[4*i][8]   = 1'b0;
              src2_1stage[4*i+1][8] = 1'b0;
              src2_1stage[4*i+2][8] = 1'b0;
              src2_1stage[4*i+3][8] = ctrl.sign_opr ? src2_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              src2_1stage[4*i][8]   = 1'b0;
              src2_1stage[4*i+1][8] = ctrl.sign_opr ? src2_1stage[4*i+1][7] : 1'b0;
              src2_1stage[4*i+2][8] = 1'b0;
              src2_1stage[4*i+3][8] = ctrl.sign_opr ? src2_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              src2_1stage[4*i][8]   = ctrl.sign_opr ? src2_1stage[4*i][7] : 1'b0;
              src2_1stage[4*i+1][8] = ctrl.sign_opr ? src2_1stage[4*i+1][7] : 1'b0;
              src2_1stage[4*i+2][8] = ctrl.sign_opr ? src2_1stage[4*i+2][7] : 1'b0;
              src2_1stage[4*i+3][8] = ctrl.sign_opr ? src2_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        // src1_1stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : ~8'h00;
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : ~8'h00;
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : ~8'h00;
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                end
                EEW16:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : ~8'h00;
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : ~8'h00;
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                end
                default:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h80 : ~8'h00);
                end
              endcase
            end
            MIN:begin 
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : ~8'hFF;
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : ~8'hFF;
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : ~8'hFF;
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                end
                EEW16:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : ~8'hFF;
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : ~8'hFF;
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                end
                default:begin
                  src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+4)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                  src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+5)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                  src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+6)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                  src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? ~widen_vs2[8*(8*i+7)+:8] : (ctrl.sign_opr ? ~8'h7F : ~8'hFF);
                end
              endcase
            end
            default:begin
              src1_1stage[4*i][7:0]   = widen_vs2_type[8*i+4] == BODY_ACTIVE ? widen_vs2[8*(8*i+4)+:8] : 8'h00;
              src1_1stage[4*i+1][7:0] = widen_vs2_type[8*i+5] == BODY_ACTIVE ? widen_vs2[8*(8*i+5)+:8] : 8'h00;
              src1_1stage[4*i+2][7:0] = widen_vs2_type[8*i+6] == BODY_ACTIVE ? widen_vs2[8*(8*i+6)+:8] : 8'h00;
              src1_1stage[4*i+3][7:0] = widen_vs2_type[8*i+7] == BODY_ACTIVE ? widen_vs2[8*(8*i+7)+:8] : 8'h00;
            end
          endcase
          case (ctrl.rdt_opr)
            MAX,
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_1stage[4*i][8]   = 1'b0;
                  src1_1stage[4*i+1][8] = 1'b0;
                  src1_1stage[4*i+2][8] = 1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : ~1'b0;
                end
                EEW16:begin
                  src1_1stage[4*i][8]   = 1'b0;
                  src1_1stage[4*i+1][8] = ctrl.sign_opr ? src1_1stage[4*i+1][7] : ~1'b0;
                  src1_1stage[4*i+2][8] = 1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : ~1'b0;
                end
                default:begin
                  src1_1stage[4*i][8]   = ctrl.sign_opr ? src1_1stage[4*i][7]   : ~1'b0;
                  src1_1stage[4*i+1][8] = ctrl.sign_opr ? src1_1stage[4*i+1][7] : ~1'b0;
                  src1_1stage[4*i+2][8] = ctrl.sign_opr ? src1_1stage[4*i+2][7] : ~1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : ~1'b0;
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_1stage[4*i][8]   = 1'b0;
                  src1_1stage[4*i+1][8] = 1'b0;
                  src1_1stage[4*i+2][8] = 1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : 1'b0;
                end
                EEW16:begin
                  src1_1stage[4*i][8]   = 1'b0;
                  src1_1stage[4*i+1][8] = ctrl.sign_opr ? src1_1stage[4*i+1][7] : 1'b0;
                  src1_1stage[4*i+2][8] = 1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : 1'b0;
                end
                default:begin
                  src1_1stage[4*i][8]   = ctrl.sign_opr ? src1_1stage[4*i][7]   : 1'b0;
                  src1_1stage[4*i+1][8] = ctrl.sign_opr ? src1_1stage[4*i+1][7] : 1'b0;
                  src1_1stage[4*i+2][8] = ctrl.sign_opr ? src1_1stage[4*i+2][7] : 1'b0;
                  src1_1stage[4*i+3][8] = ctrl.sign_opr ? src1_1stage[4*i+3][7] : 1'b0;
                end
              endcase
            end
          endcase
        end

        // carry_in_1stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX,
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_1stage[4*i]   = 1'b1;
                  carry_in_1stage[4*i+1] = sum_1stage[4*i][8];
                  carry_in_1stage[4*i+2] = sum_1stage[4*i+1][8];
                  carry_in_1stage[4*i+3] = sum_1stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_1stage[4*i]   = 1'b1; 
                  carry_in_1stage[4*i+1] = sum_1stage[4*i][8]; 
                  carry_in_1stage[4*i+2] = 1'b1; 
                  carry_in_1stage[4*i+3] = sum_1stage[4*i+2][8]; 
                end
                default:begin
                  carry_in_1stage[4*i]   = 1'b1;
                  carry_in_1stage[4*i+1] = 1'b1;
                  carry_in_1stage[4*i+2] = 1'b1;
                  carry_in_1stage[4*i+3] = 1'b1;
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_1stage[4*i]   = 1'b0;
                  carry_in_1stage[4*i+1] = sum_1stage[4*i][8];
                  carry_in_1stage[4*i+2] = sum_1stage[4*i+1][8];
                  carry_in_1stage[4*i+3] = sum_1stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_1stage[4*i]   = 1'b0;
                  carry_in_1stage[4*i+1] = sum_1stage[4*i][8];
                  carry_in_1stage[4*i+2] = 1'b0;
                  carry_in_1stage[4*i+3] = sum_1stage[4*i+2][8];
                end
                default:begin
                  carry_in_1stage[4*i]   = 1'b0; 
                  carry_in_1stage[4*i+1] = 1'b0; 
                  carry_in_1stage[4*i+2] = 1'b0; 
                  carry_in_1stage[4*i+3] = 1'b0; 
                end
              endcase
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(2*4); i++) begin : gen_rdt_src_1stage_data

      // `VLENB/2 9-bit-adder/and/or/xor for 1stage
      for (i=0; i<`VLENB/2; i++) begin : gen_arithmetic_unit_1stage
        assign sum_1stage[i] = src2_1stage[i] + src1_1stage[i] + carry_in_1stage[i];
        assign and_1stage[i] = src2_bit[i] & src1_bit[i];
        assign or_1stage[i]  = src2_bit[i] | src1_bit[i];
        assign xor_1stage[i] = src2_bit[i] ^ src1_bit[i];
        assign less_than_1stage[i]  = sum_1stage[i][8];
        assign great_than_1stage[i] = ~sum_1stage[i][8];
      end

      // generate reduction result for reduction operation
      // src1_2stage/src2_2stage/carry_in_2stage data
      for (i=0; i<`VLENB/(4*4); i++) begin : gen_source_2stage_data
        // src2_2stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src2_2stage[4*i][7:0]   = great_than_1stage[4*i+3] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
                EEW16:begin
                  src2_2stage[4*i][7:0]   = great_than_1stage[4*i+1] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+1] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
                default:begin
                  src2_2stage[4*i][7:0]   = great_than_1stage[4*i+0] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = great_than_1stage[4*i+1] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = great_than_1stage[4*i+2] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = great_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src2_2stage[4*i][7:0]   = less_than_1stage[4*i+3] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
                EEW16:begin
                  src2_2stage[4*i][7:0]   = less_than_1stage[4*i+1] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+1] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
                default:begin
                  src2_2stage[4*i][7:0]   = less_than_1stage[4*i+0] ? src2_1stage[4*i][7:0]   : ~src1_1stage[4*i][7:0];
                  src2_2stage[4*i+1][7:0] = less_than_1stage[4*i+1] ? src2_1stage[4*i+1][7:0] : ~src1_1stage[4*i+1][7:0];
                  src2_2stage[4*i+2][7:0] = less_than_1stage[4*i+2] ? src2_1stage[4*i+2][7:0] : ~src1_1stage[4*i+2][7:0];
                  src2_2stage[4*i+3][7:0] = less_than_1stage[4*i+3] ? src2_1stage[4*i+3][7:0] : ~src1_1stage[4*i+3][7:0];
                end
              endcase
            end
            default:begin
              src2_2stage[4*i][7:0]   = sum_1stage[4*i][7:0];
              src2_2stage[4*i+1][7:0] = sum_1stage[4*i+1][7:0];
              src2_2stage[4*i+2][7:0] = sum_1stage[4*i+2][7:0];
              src2_2stage[4*i+3][7:0] = sum_1stage[4*i+3][7:0];
            end
          endcase

          case (pmtrdt_uop.vs1_eew) // Reduction instruction: widen_vs2_eew == vs1_eew
            EEW32:begin
              src2_2stage[4*i][8]   = 1'b0;
              src2_2stage[4*i+1][8] = 1'b0;
              src2_2stage[4*i+2][8] = 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? src2_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              src2_2stage[4*i][8]   = 1'b0;
              src2_2stage[4*i+1][8] = ctrl.sign_opr ? src2_2stage[4*i+1][7] : 1'b0;
              src2_2stage[4*i+2][8] = 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? src2_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              src2_2stage[4*i][8]   = ctrl.sign_opr ? src2_2stage[4*i][7] : 1'b0;
              src2_2stage[4*i+1][8] = ctrl.sign_opr ? src2_2stage[4*i+1][7] : 1'b0;
              src2_2stage[4*i+2][8] = ctrl.sign_opr ? src2_2stage[4*i+2][7] : 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? src2_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end
        
        //src1_2stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
                EEW16:begin
                  src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
                default:begin
                  src1_2stage[4*i][7:0]   = great_than_1stage[`VLENB/4+4*i+0] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = great_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = great_than_1stage[`VLENB/4+4*i+2] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = great_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
                EEW16:begin
                  src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
                default:begin
                  src1_2stage[4*i][7:0]   = less_than_1stage[`VLENB/4+4*i+0] ? ~src2_1stage[`VLENB/4+4*i][7:0]   : src1_1stage[`VLENB/4+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = less_than_1stage[`VLENB/4+4*i+1] ? ~src2_1stage[`VLENB/4+4*i+1][7:0] : src1_1stage[`VLENB/4+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = less_than_1stage[`VLENB/4+4*i+2] ? ~src2_1stage[`VLENB/4+4*i+2][7:0] : src1_1stage[`VLENB/4+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = less_than_1stage[`VLENB/4+4*i+3] ? ~src2_1stage[`VLENB/4+4*i+3][7:0] : src1_1stage[`VLENB/4+4*i+3][7:0];
                end
              endcase
            end
            default:begin
              src1_2stage[4*i][7:0]   = sum_1stage[`VLENB/4+4*i][7:0];
              src1_2stage[4*i+1][7:0] = sum_1stage[`VLENB/4+4*i+1][7:0];
              src1_2stage[4*i+2][7:0] = sum_1stage[`VLENB/4+4*i+2][7:0];
              src1_2stage[4*i+3][7:0] = sum_1stage[`VLENB/4+4*i+3][7:0];
            end
          endcase
          case (ctrl.rdt_opr)
            MAX,
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = 1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : ~1'b0;
                end
                EEW16:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? src1_2stage[4*i+1][7] : ~1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : ~1'b0;
                end
                default:begin
                  src1_2stage[4*i][8]   = ctrl.sign_opr ? src1_2stage[4*i][7] : ~1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? src1_2stage[4*i+1][7] : ~1'b0;
                  src1_2stage[4*i+2][8] = ctrl.sign_opr ? src1_2stage[4*i+2][7] : ~1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : ~1'b0;
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = 1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : 1'b0;
                end
                EEW16:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? src1_2stage[4*i+1][7] : 1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : 1'b0;
                end
                default:begin
                  src1_2stage[4*i][8]   = ctrl.sign_opr ? src1_2stage[4*i][7] : 1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? src1_2stage[4*i+1][7] : 1'b0;
                  src1_2stage[4*i+2][8] = ctrl.sign_opr ? src1_2stage[4*i+2][7] : 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? src1_2stage[4*i+3][7] : 1'b0;
                end
              endcase
            end
          endcase
        end
        
        //carry_in_2stage data
        always_comb begin
          case (ctrl.rdt_opr)
            MAX,
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_2stage[4*i]   = 1'b1;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = sum_2stage[4*i+1][8];
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_2stage[4*i]   = 1'b1;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = 1'b1;
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                default:begin
                  carry_in_2stage[4*i]   = 1'b1;
                  carry_in_2stage[4*i+1] = 1'b1;
                  carry_in_2stage[4*i+2] = 1'b1;
                  carry_in_2stage[4*i+3] = 1'b1;
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_2stage[4*i]   = 1'b0;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = sum_2stage[4*i+1][8];
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_2stage[4*i]   = 1'b0;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = 1'b0;
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                default:begin
                  carry_in_2stage[4*i]   = 1'b0;
                  carry_in_2stage[4*i+1] = 1'b0;
                  carry_in_2stage[4*i+2] = 1'b0;
                  carry_in_2stage[4*i+3] = 1'b0;
                end
              endcase
            end
          endcase
        end
      end //end for (i=0; i<`VLENB/(4*4); i++) begin : gen_source_2stage_data

      // `VLENB/4 9-bit-adder/and/or/xor for 2stage
      for (i=0; i<`VLENB/4; i++) begin : gen_arithmetic_unit_2stage
        assign sum_2stage[i]   = src2_2stage[i] + src1_2stage[i] + carry_in_2stage[i];
        assign less_than_2stage[i]  = sum_2stage[i][8];
        assign great_than_2stage[i] = ~sum_2stage[i][8];
      end
      for (i=0; i<`VLENB/(4*4); i++) begin: gen_logic_unit_2stage
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

      // VS1[0] & vd[0] operation for reduction
      // src1_vd/src2_vs1/carry_in_vs1vd data
      // src2_vs1
      assign sel_vs1 = ctrl.last_uop_valid && !ctrl.widen ||
                       ctrl.last_uop_valid && ctrl.widen && red_widen_sum_flag;
      always_comb begin
        if (sel_vs1) begin
          case (pmtrdt_uop.vs1_eew)
            EEW32: begin
              src2_vs1[0][7:0] = pmtrdt_uop.vs1_data[8*0+:8];
              src2_vs1[1][7:0] = pmtrdt_uop.vs1_data[8*1+:8];
              src2_vs1[2][7:0] = pmtrdt_uop.vs1_data[8*2+:8];
              src2_vs1[3][7:0] = pmtrdt_uop.vs1_data[8*3+:8];
              src2_vs1[0][8]   = 1'b0;
              src2_vs1[1][8]   = 1'b0;
              src2_vs1[2][8]   = 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
            EEW16: begin
              src2_vs1[0][7:0] = pmtrdt_uop.vs1_data[8*0+:8];
              src2_vs1[1][7:0] = pmtrdt_uop.vs1_data[8*1+:8];
              case (ctrl.rdt_opr)
                MAX:begin
                  src2_vs1[2][7:0] = 8'h00;
                  src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1[2][7:0] = 8'hFF;
                  src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1[2][7:0] = 8'hFF;
                  src2_vs1[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1[2][7:0] = 8'h00;
                  src2_vs1[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1[0][8]   = 1'b0;
              src2_vs1[1][8]   = ctrl.sign_opr ? src2_vs1[1][7] : 1'b0;
              src2_vs1[2][8]   = 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
            default: begin
              src2_vs1[0][7:0] = pmtrdt_uop.vs1_data[0+:8];
              case (ctrl.rdt_opr)
                MAX:begin
                  src2_vs1[1][7:0] = ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1[2][7:0] = ctrl.sign_opr ? 8'h80 : 8'h00;
                  src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h80 : 8'h00;
                end
                MIN:begin
                  src2_vs1[1][7:0] = ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1[2][7:0] = ctrl.sign_opr ? 8'h7F : 8'hFF;
                  src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h7F : 8'hFF;
                end
                AND:begin
                  src2_vs1[1][7:0] = 8'hFF;
                  src2_vs1[2][7:0] = 8'hFF;
                  src2_vs1[3][7:0] = 8'hFF;
                end
                default:begin
                  src2_vs1[1][7:0] = 8'h00;
                  src2_vs1[2][7:0] = 8'h00;
                  src2_vs1[3][7:0] = 8'h00;
                end
              endcase
              src2_vs1[0][8]   = ctrl.sign_opr ? src2_vs1[0][7] : 1'b0;
              src2_vs1[1][8]   = ctrl.sign_opr ? src2_vs1[1][7] : 1'b0;
              src2_vs1[2][8]   = ctrl.sign_opr ? src2_vs1[2][7] : 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
          endcase
        end else begin
          case (ctrl.rdt_opr)
            MAX:begin
              src2_vs1[0][7:0] = 8'h00;
              src2_vs1[1][7:0] = 8'h00;
              src2_vs1[2][7:0] = 8'h00;
              src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h80 : 8'h00;
            end
            MIN:begin
              src2_vs1[0][7:0] = 8'hFF;
              src2_vs1[1][7:0] = 8'hFF;
              src2_vs1[2][7:0] = 8'hFF;
              src2_vs1[3][7:0] = ctrl.sign_opr ? 8'h7F : 8'hFF;
            end
            AND:begin
              src2_vs1[0][7:0] = 8'hFF;
              src2_vs1[1][7:0] = 8'hFF;
              src2_vs1[2][7:0] = 8'hFF;
              src2_vs1[3][7:0] = 8'hFF;
            end
            default:begin
              src2_vs1[0][7:0] = 8'h00;
              src2_vs1[1][7:0] = 8'h00;
              src2_vs1[2][7:0] = 8'h00;
              src2_vs1[3][7:0] = 8'h00;
            end
          endcase
          case (pmtrdt_uop.vs1_eew)
            EEW32:begin
              src2_vs1[0][8]   = 1'b0;
              src2_vs1[1][8]   = 1'b0;
              src2_vs1[2][8]   = 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
            EEW16:begin
              src2_vs1[0][8]   = 1'b0;
              src2_vs1[1][8]   = ctrl.sign_opr ? src2_vs1[1][7] : 1'b0;
              src2_vs1[2][8]   = 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
            default:begin
              src2_vs1[0][8]   = ctrl.sign_opr ? src2_vs1[0][7] : 1'b0;
              src2_vs1[1][8]   = ctrl.sign_opr ? src2_vs1[1][7] : 1'b0;
              src2_vs1[2][8]   = ctrl.sign_opr ? src2_vs1[2][7] : 1'b0;
              src2_vs1[3][8]   = ctrl.sign_opr ? src2_vs1[3][7] : 1'b0;
            end
          endcase
        end
      end

      // src1_vd data
      always_comb begin
        if (pmtrdt_uop.uop_index == '0 && !red_widen_sum_flag) begin
          case (ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd[0][7:0] = ~8'h00;
                  src1_vd[1][7:0] = ~8'h00;
                  src1_vd[2][7:0] = ~8'h00;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
                EEW16:begin
                  src1_vd[0][7:0] = ~8'h00;
                  src1_vd[1][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd[2][7:0] = ~8'h00;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
                default:begin
                  src1_vd[0][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd[1][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd[2][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h80 : ~8'h00;
                end
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_vd[0][7:0] = ~8'hFF;
                  src1_vd[1][7:0] = ~8'hFF;
                  src1_vd[2][7:0] = ~8'hFF;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
                EEW16:begin
                  src1_vd[0][7:0] = ~8'hFF;
                  src1_vd[1][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd[2][7:0] = ~8'hFF;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
                default:begin
                  src1_vd[0][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd[1][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd[2][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                  src1_vd[3][7:0] = ctrl.sign_opr ? ~8'h7F : ~8'hFF;
                end
              endcase
            end
            AND:begin
              src1_vd[0][7:0] = 8'hFF;
              src1_vd[1][7:0] = 8'hFF;
              src1_vd[2][7:0] = 8'hFF;
              src1_vd[3][7:0] = 8'hFF;
            end
            default:begin
              src1_vd[0][7:0] = 8'h00;
              src1_vd[1][7:0] = 8'h00;
              src1_vd[2][7:0] = 8'h00;
              src1_vd[3][7:0] = 8'h00;
            end
          endcase
        end else begin
          case (ctrl.rdt_opr)
            MAX,
            MIN:begin
              src1_vd[0][7:0] = ~red_res_q[0][7:0];
              src1_vd[1][7:0] = ~red_res_q[1][7:0];
              src1_vd[2][7:0] = ~red_res_q[2][7:0];
              src1_vd[3][7:0] = ~red_res_q[3][7:0];
            end
            default:begin
              src1_vd[0][7:0] = red_res_q[0][7:0];
              src1_vd[1][7:0] = red_res_q[1][7:0];
              src1_vd[2][7:0] = red_res_q[2][7:0];
              src1_vd[3][7:0] = red_res_q[3][7:0];
            end
          endcase
        end
        case (ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_vd[0][8] = 1'b0;
                src1_vd[1][8] = 1'b0;
                src1_vd[2][8] = 1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : ~1'b0;
              end
              EEW16:begin
                src1_vd[0][8] = 1'b0;
                src1_vd[1][8] = ctrl.sign_opr ? src1_vd[1][7] : ~1'b0;
                src1_vd[2][8] = 1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : ~1'b0;
              end
              default:begin
                src1_vd[0][8] = ctrl.sign_opr ? src1_vd[0][7] : ~1'b0;
                src1_vd[1][8] = ctrl.sign_opr ? src1_vd[1][7] : ~1'b0;
                src1_vd[2][8] = ctrl.sign_opr ? src1_vd[2][7] : ~1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : ~1'b0;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_vd[0][8] = 1'b0;
                src1_vd[1][8] = 1'b0;
                src1_vd[2][8] = 1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : 1'b0;
              end
              EEW16:begin
                src1_vd[0][8] = 1'b0;
                src1_vd[1][8] = ctrl.sign_opr ? src1_vd[1][7] : 1'b0;
                src1_vd[2][8] = 1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : 1'b0;
              end
              default:begin
                src1_vd[0][8] = ctrl.sign_opr ? src1_vd[0][7] : 1'b0;
                src1_vd[1][8] = ctrl.sign_opr ? src1_vd[1][7] : 1'b0;
                src1_vd[2][8] = ctrl.sign_opr ? src1_vd[2][7] : 1'b0;
                src1_vd[3][8] = ctrl.sign_opr ? src1_vd[3][7] : 1'b0;
              end
            endcase
          end
        endcase
      end

      // carry_in_vd data
      always_comb begin
        case (ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_vd[0] = 1'b1;
                carry_in_vd[1] = sum_vd[0][8];
                carry_in_vd[2] = sum_vd[1][8];
                carry_in_vd[3] = sum_vd[2][8];
              end
              EEW16:begin
                carry_in_vd[0] = 1'b1;
                carry_in_vd[1] = sum_vd[0][8];
                carry_in_vd[2] = 1'b1;
                carry_in_vd[3] = sum_vd[2][8];
              end
              default:begin
                carry_in_vd[0] = 1'b1;
                carry_in_vd[1] = 1'b1;
                carry_in_vd[2] = 1'b1;
                carry_in_vd[3] = 1'b1;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_vd[0] = 1'b0;
                carry_in_vd[1] = sum_vd[0][8];
                carry_in_vd[2] = sum_vd[1][8];
                carry_in_vd[3] = sum_vd[2][8];
              end
              EEW16:begin
                carry_in_vd[0] = 1'b0;
                carry_in_vd[1] = sum_vd[0][8];
                carry_in_vd[2] = 1'b0;
                carry_in_vd[3] = sum_vd[2][8];
              end
              default:begin
                carry_in_vd[0] = 1'b0;
                carry_in_vd[1] = 1'b0;
                carry_in_vd[2] = 1'b0;
                carry_in_vd[3] = 1'b0;
              end
            endcase
          end
        endcase
      end

      // four 9-bit-adder/and/or/xor for vs1[0] & vd[0]
      for (i=0; i<4; i++) begin : gen_arithmetic_unit_vs1vd
        assign sum_vd[i] = src2_vs1[i] + src1_vd[i] + carry_in_vd[i];
        assign and_vd[i] = src2_vs1[i][7:0] & src1_vd[i][7:0];
        assign or_vd[i]  = src2_vs1[i][7:0] | src1_vd[i][7:0];
        assign xor_vd[i] = src2_vs1[i][7:0] ^ src1_vd[i][7:0];
        assign less_than_vd[i]  = sum_vd[i][8];
        assign great_than_vd[i] = ~sum_vd[i][8];
      end

      // src1_3stage/src2_3stage/carry_in_3stage data
      // src2_3stage[3:0] data
      always_comb begin
        case (ctrl.rdt_opr)
          MAX:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src2_3stage[0][7:0] = great_than_2stage[3] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = great_than_2stage[3] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = great_than_2stage[3] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = great_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
              EEW16:begin
                src2_3stage[0][7:0] = great_than_2stage[1] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = great_than_2stage[1] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = great_than_2stage[3] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = great_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
              default:begin
                src2_3stage[0][7:0] = great_than_2stage[0] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = great_than_2stage[1] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = great_than_2stage[2] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = great_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
            endcase
          end
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src2_3stage[0][7:0] = less_than_2stage[3] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = less_than_2stage[3] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = less_than_2stage[3] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = less_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
              EEW16:begin
                src2_3stage[0][7:0] = less_than_2stage[1] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = less_than_2stage[1] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = less_than_2stage[3] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = less_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
              default:begin
                src2_3stage[0][7:0] = less_than_2stage[0] ? src2_2stage[0][7:0] : ~src1_2stage[0][7:0];
                src2_3stage[1][7:0] = less_than_2stage[1] ? src2_2stage[1][7:0] : ~src1_2stage[1][7:0];
                src2_3stage[2][7:0] = less_than_2stage[2] ? src2_2stage[2][7:0] : ~src1_2stage[2][7:0];
                src2_3stage[3][7:0] = less_than_2stage[3] ? src2_2stage[3][7:0] : ~src1_2stage[3][7:0];
              end
            endcase
          end
          default:begin
            src2_3stage[0][7:0] = sum_2stage[0][7:0];
            src2_3stage[1][7:0] = sum_2stage[1][7:0];
            src2_3stage[2][7:0] = sum_2stage[2][7:0];
            src2_3stage[3][7:0] = sum_2stage[3][7:0];
          end
        endcase
        case (pmtrdt_uop.vs1_eew)
          EEW32:begin
            src2_3stage[0][8] = 1'b0;
            src2_3stage[1][8] = 1'b0;
            src2_3stage[2][8] = 1'b0;
            src2_3stage[3][8] = ctrl.sign_opr ? src2_3stage[3][7] : 1'b0;
          end
          EEW16:begin
            src2_3stage[0][8] = 1'b0;
            src2_3stage[1][8] = ctrl.sign_opr ? src2_3stage[1][7] : 1'b0;
            src2_3stage[2][8] = 1'b0;
            src2_3stage[3][8] = ctrl.sign_opr ? src2_3stage[3][7] : 1'b0;
          end
          default:begin
            src2_3stage[0][8] = ctrl.sign_opr ? src2_3stage[0][7] : 1'b0;
            src2_3stage[1][8] = ctrl.sign_opr ? src2_3stage[1][7] : 1'b0;
            src2_3stage[2][8] = ctrl.sign_opr ? src2_3stage[2][7] : 1'b0;
            src2_3stage[3][8] = ctrl.sign_opr ? src2_3stage[3][7] : 1'b0;
          end
        endcase
      end

      // src1_3stage[3:0] data
      always_comb begin
        case (ctrl.rdt_opr)
          MAX:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_3stage[0][7:0] = great_than_vd[3] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = great_than_vd[3] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = great_than_vd[3] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = great_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
              EEW16:begin
                src1_3stage[0][7:0] = great_than_vd[1] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = great_than_vd[1] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = great_than_vd[3] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = great_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
              default:begin
                src1_3stage[0][7:0] = great_than_vd[0] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = great_than_vd[1] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = great_than_vd[2] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = great_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
            endcase
          end
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_3stage[0][7:0] = less_than_vd[3] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = less_than_vd[3] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = less_than_vd[3] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = less_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
              EEW16:begin
                src1_3stage[0][7:0] = less_than_vd[1] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = less_than_vd[1] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = less_than_vd[3] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = less_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
              default:begin
                src1_3stage[0][7:0] = less_than_vd[0] ? ~src2_vs1[0][7:0] : src1_vd[0][7:0];
                src1_3stage[1][7:0] = less_than_vd[1] ? ~src2_vs1[1][7:0] : src1_vd[1][7:0];
                src1_3stage[2][7:0] = less_than_vd[2] ? ~src2_vs1[2][7:0] : src1_vd[2][7:0];
                src1_3stage[3][7:0] = less_than_vd[3] ? ~src2_vs1[3][7:0] : src1_vd[3][7:0];
              end
            endcase
          end
          default:begin
            src1_3stage[0][7:0] = sum_vd[0][7:0];
            src1_3stage[1][7:0] = sum_vd[1][7:0];
            src1_3stage[2][7:0] = sum_vd[2][7:0];
            src1_3stage[3][7:0] = sum_vd[3][7:0];
          end
        endcase
        case (ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_3stage[0][8] = 1'b0;
                src1_3stage[1][8] = 1'b0;
                src1_3stage[2][8] = 1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : ~1'b0;
              end
              EEW16:begin
                src1_3stage[0][8] = 1'b0;
                src1_3stage[1][8] = ctrl.sign_opr ? src1_3stage[1][7] : ~1'b0;
                src1_3stage[2][8] = 1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : ~1'b0;
              end
              default:begin
                src1_3stage[0][8] = ctrl.sign_opr ? src1_3stage[0][7] : ~1'b0;
                src1_3stage[1][8] = ctrl.sign_opr ? src1_3stage[1][7] : ~1'b0;
                src1_3stage[2][8] = ctrl.sign_opr ? src1_3stage[2][7] : ~1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : ~1'b0;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                src1_3stage[0][8] = 1'b0;
                src1_3stage[1][8] = 1'b0;
                src1_3stage[2][8] = 1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : 1'b0;
              end
              EEW16:begin
                src1_3stage[0][8] = 1'b0;
                src1_3stage[1][8] = ctrl.sign_opr ? src1_3stage[1][7] : 1'b0;
                src1_3stage[2][8] = 1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : 1'b0;
              end
              default:begin
                src1_3stage[0][8] = ctrl.sign_opr ? src1_3stage[0][7] : 1'b0;
                src1_3stage[1][8] = ctrl.sign_opr ? src1_3stage[1][7] : 1'b0;
                src1_3stage[2][8] = ctrl.sign_opr ? src1_3stage[2][7] : 1'b0;
                src1_3stage[3][8] = ctrl.sign_opr ? src1_3stage[3][7] : 1'b0;
              end
            endcase
          end
        endcase
      end

      // carry_in_3stage[3:0] data
      always_comb begin
        case (ctrl.rdt_opr)
          MAX,
          MIN:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_3stage[0] = 1'b1;
                carry_in_3stage[1] = sum_3stage[0][8];
                carry_in_3stage[2] = sum_3stage[1][8];
                carry_in_3stage[3] = sum_3stage[2][8];
              end
              EEW16:begin
                carry_in_3stage[0] = 1'b1;
                carry_in_3stage[1] = sum_3stage[0][8];
                carry_in_3stage[2] = 1'b1;
                carry_in_3stage[3] = sum_3stage[2][8];
              end
              default:begin
                carry_in_3stage[0] = 1'b1;
                carry_in_3stage[1] = 1'b1;
                carry_in_3stage[2] = 1'b1;
                carry_in_3stage[3] = 1'b1;
              end
            endcase
          end
          default:begin
            case (pmtrdt_uop.vs1_eew)
              EEW32:begin
                carry_in_3stage[0] = 1'b0;
                carry_in_3stage[1] = sum_3stage[0][8];
                carry_in_3stage[2] = sum_3stage[1][8];
                carry_in_3stage[3] = sum_3stage[2][8];
              end
              EEW16:begin
                carry_in_3stage[0] = 1'b0;
                carry_in_3stage[1] = sum_3stage[0][8];
                carry_in_3stage[2] = 1'b0;
                carry_in_3stage[3] = sum_3stage[2][8];
              end
              default:begin
                carry_in_3stage[0] = 1'b0;
                carry_in_3stage[1] = 1'b0;
                carry_in_3stage[2] = 1'b0;
                carry_in_3stage[3] = 1'b0;
              end
            endcase
          end
        endcase
      end

      // src1_3stage/src2_3stage/carry_in_3stage [`VLENB/4:4] data when `VLENB > 16
      // TODO

      // four 9-bit-adder/and/or/xor for 3stage
      for (i=0; i<4; i++) begin : gen_arithmetic_unit_3stage
        assign sum_3stage[i]   = src2_3stage[i] + src1_3stage[i] + carry_in_3stage[i];
        assign and_3stage[i]   = and_2stage[i] & and_vd[i];
        assign or_3stage[i]    = or_2stage[i]  | or_vd[i];
        assign xor_3stage[i]   = xor_2stage[i] ^ xor_vd[i];
        assign less_than_3stage[i]  = sum_3stage[i][8];
        assign great_than_3stage[i] = ~sum_3stage[i][8];
      end

      for (i=0; i<`VLENB/4; i++) begin : gen_reduction_result
        // select red_res_d based on reduction operation
        always_comb begin
          case(ctrl.rdt_opr)
            MAX:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:   red_res_d[i] = great_than_3stage[4*(i/4)+3] ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
                EEW16:   red_res_d[i] = great_than_3stage[2*(i/2)+1] ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
                default: red_res_d[i] = great_than_3stage[i]         ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
              endcase
            end
            MIN:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:   red_res_d[i] = less_than_3stage[4*(i/4)+3] ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
                EEW16:   red_res_d[i] = less_than_3stage[2*(i/2)+1] ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
                default: red_res_d[i] = less_than_3stage[i]         ? src2_3stage[i][7:0] : ~src1_3stage[i][7:0];
              endcase
            end
            AND: red_res_d[i] = and_3stage[i];
            OR:  red_res_d[i] = or_3stage[i];
            XOR: red_res_d[i] = xor_3stage[i];
            default: red_res_d[i] = sum_3stage[i][7:0]; //SUM
          endcase
        end

        cdffr #(.WIDTH(8)) red_res_reg (.q(red_res_q[i]), .d(red_res_d[i]), .c(1'b0), .e(ctrl.uop_type == REDUCTION), .clk(clk), .rst_n(rst_n));
      end

      // reduction result when vd_eew is 32b
      always_comb begin
        sum_32b = '0;
        if (ctrl_q.sign_opr) begin
          max_32b = 32'h8000_0000;
          min_32b = 32'h7FFF_FFFF;
        end else begin
          max_32b = 32'h0000_0000;
          min_32b = 32'hFFFF_FFFF;
        end
        and_32b = '1;
        or_32b  = '0;
        xor_32b = '0;
        for (int j=0; j<`VLENB/16; j++) begin
          sum_32b = sum_32b + {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          if (ctrl_q.sign_opr) begin
            max_32b = $signed(max_32b) > $signed({red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}) 
                      ? max_32b : {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}; 
            min_32b = $signed(min_32b) < $signed({red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}) 
                      ? min_32b : {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}; 
          end else begin
            max_32b = max_32b > {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]} 
                      ? max_32b : {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}; 
            min_32b = min_32b < {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}
                      ? min_32b : {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]}; 
          end
          and_32b = and_32b & {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          or_32b  = or_32b  | {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          xor_32b = xor_32b ^ {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
        end
      end

      // reduction result when vd_eew is 16b
      always_comb begin
        sum_16b = '0;
        if (ctrl_q.sign_opr) begin
          max_16b = 16'h8000;
          min_16b = 16'h7FFF;
        end else begin
          max_16b = 16'h0000;
          min_16b = 16'hFFFF;
        end
        and_16b = '1;
        or_16b  = '0;
        xor_16b = '0;
        for (int j=0; j<`VLENB/8; j++) begin
          sum_16b = sum_16b + {red_res_q[2*j+1],red_res_q[2*j]};
          if (ctrl_q.sign_opr) begin
            max_16b = $signed(max_16b) > $signed({red_res_q[2*j+1],red_res_q[2*j]}) 
                      ? max_16b : {red_res_q[2*j+1],red_res_q[2*j]}; 
            min_16b = $signed(min_16b) < $signed({red_res_q[2*j+1],red_res_q[2*j]}) 
                      ? min_16b : {red_res_q[2*j+1],red_res_q[2*j]}; 
          end else begin
            max_16b = max_16b > {red_res_q[2*j+1],red_res_q[2*j]} 
                      ? max_16b : {red_res_q[2*j+1],red_res_q[2*j]}; 
            min_16b = min_16b < {red_res_q[2*j+1],red_res_q[2*j]}
                      ? min_16b : {red_res_q[2*j+1],red_res_q[2*j]}; 
          end
          and_16b = and_16b & {red_res_q[2*j+1],red_res_q[2*j]};
          or_16b  = or_16b  | {red_res_q[2*j+1],red_res_q[2*j]};
          xor_16b = xor_16b ^ {red_res_q[2*j+1],red_res_q[2*j]};
        end
      end

      // reduction result when vd_eew is 8b
      always_comb begin
        sum_8b = '0;
        if (ctrl_q.sign_opr) begin
          max_8b = 8'h80;
          min_8b = 8'h7F;
        end else begin
          max_8b = 8'h00;
          min_8b = 8'hFF;
        end
        and_8b = '1;
        or_8b  = '0;
        xor_8b = '0;
        for (int j=0; j<`VLENB/4; j++) begin
          sum_8b = sum_8b + red_res_q[j];
          if (ctrl_q.sign_opr) begin
            max_8b = $signed(max_8b) > $signed(red_res_q[j]) 
                      ? max_8b : red_res_q[j]; 
            min_8b = $signed(min_8b) < $signed(red_res_q[j]) 
                      ? min_8b : red_res_q[j]; 
          end else begin
            max_8b = max_8b > red_res_q[j]
                      ? max_8b : red_res_q[j]; 
            min_8b = min_8b < red_res_q[j]
                      ? min_8b : red_res_q[j]; 
          end
          and_8b = and_8b & red_res_q[j];
          or_8b  = or_8b  | red_res_q[j];
          xor_8b = xor_8b ^ red_res_q[j];
        end
      end

      //pmtrdt_res_red data
      always_comb begin
        case (ctrl_q.vs1_eew)
          EEW32:begin
            case (ctrl_q.rdt_opr)
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
            case (ctrl_q.rdt_opr)
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
            case (ctrl_q.rdt_opr)
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
              cmp_src2[4*i+3][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
            end
            EEW16:begin
              cmp_src2[4*i][8]   = 1'b0;
              cmp_src2[4*i+1][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+1)+7] : 1'b0;
              cmp_src2[4*i+2][8] = 1'b0;
              cmp_src2[4*i+3][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
            end
            default:begin
              cmp_src2[4*i][8]   = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i)+7] : 1'b0;
              cmp_src2[4*i+1][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+1)+7] : 1'b0;
              cmp_src2[4*i+2][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+2)+7] : 1'b0;
              cmp_src2[4*i+3][8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(4*i+3)+7] : 1'b0;
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
                  cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[8*0+:8];
                  cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                  cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[8*2+:8];
                  cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[8*3+:8];
                  cmp_src1[4*i][8]     = 1'b0;
                  cmp_src1[4*i+1][8]   = 1'b0;
                  cmp_src1[4*i+2][8]   = 1'b0;
                  cmp_src1[4*i+3][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*3+7] : ~1'b0;
                end
                EEW16:begin
                  cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[8*0+:8];
                  cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                  cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[8*0+:8];
                  cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[8*1+:8];
                  cmp_src1[4*i][8]     = 1'b0;
                  cmp_src1[4*i+1][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*1+7] : ~1'b0;
                  cmp_src1[4*i+2][8]   = 1'b0;
                  cmp_src1[4*i+3][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[8*1+7] : ~1'b0;
                end
                default:begin
                  cmp_src1[4*i][7:0]   = ~pmtrdt_uop.rs1_data[0+:8];
                  cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                  cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                  cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                  cmp_src1[4*i][8]     = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                  cmp_src1[4*i+1][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                  cmp_src1[4*i+2][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                  cmp_src1[4*i+3][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7] : ~1'b0;
                end
              endcase
            end
            default:begin
              cmp_src1[4*i][7:0]   = ~pmtrdt_uop.vs1_data[8*(4*i)+:8];
              cmp_src1[4*i+1][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+1)+:8];
              cmp_src1[4*i+2][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+2)+:8];
              cmp_src1[4*i+3][7:0] = ~pmtrdt_uop.vs1_data[8*(4*i+3)+:8];
              case (pmtrdt_uop.vs2_eew) // compare instruction: vs1_eew == vs2_eew
                EEW32:begin
                  cmp_src1[4*i][8]   = 1'b0;
                  cmp_src1[4*i+1][8] = 1'b0;
                  cmp_src1[4*i+2][8] = 1'b0;
                  cmp_src1[4*i+3][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                end
                EEW16:begin
                  cmp_src1[4*i][8]   = 1'b0;
                  cmp_src1[4*i+1][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+1)+7] : ~1'b0;
                  cmp_src1[4*i+2][8] = 1'b0;
                  cmp_src1[4*i+3][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                end
                default:begin
                  cmp_src1[4*i][8]   = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i)+7] : ~1'b0;
                  cmp_src1[4*i+1][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+1)+7] : ~1'b0;
                  cmp_src1[4*i+2][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+2)+7] : ~1'b0;
                  cmp_src1[4*i+3][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(4*i+3)+7] : ~1'b0;
                end
              endcase
            end
          endcase
        end

        // cmp_carry_in data
        always_comb begin
          case (pmtrdt_uop.vs2_eew)
            EEW32:begin
              cmp_carry_in[4*i]   = 1'b1;
              cmp_carry_in[4*i+1] = cmp_sum[4*i][8];
              cmp_carry_in[4*i+2] = cmp_sum[4*i+1][8];
              cmp_carry_in[4*i+3] = cmp_sum[4*i+2][8];
            end
            EEW16:begin
              cmp_carry_in[4*i]   = 1'b1; 
              cmp_carry_in[4*i+1] = cmp_sum[4*i][8]; 
              cmp_carry_in[4*i+2] = 1'b1; 
              cmp_carry_in[4*i+3] = cmp_sum[4*i+2][8]; 
            end
            default:begin
              cmp_carry_in[4*i]   = 1'b1;
              cmp_carry_in[4*i+1] = 1'b1;
              cmp_carry_in[4*i+2] = 1'b1;
              cmp_carry_in[4*i+3] = 1'b1;
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/4; i++) begin : gen_cmp_src_data

      // generate compare result for compare operation
      for (i=0; i<`VLENB; i++) begin : gen_compare_value
        assign cmp_sum[i]    = cmp_src2[i] + cmp_src1[i] + cmp_carry_in[i];
        assign less_than[i]  = cmp_sum[i][8];
        assign great_than_equal[i] = ~cmp_sum[i][8]; 
        assign equal[i]      = cmp_sum[i][7:0] == '0;
        assign not_equal[i]  = cmp_sum[i][7:0] != '0;
      end

      // cmp_res data
      always_comb begin
        case (ctrl.gt_lt_eq)
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

      // cmp_res_offset
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/4;
          EEW16: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/2;
          default: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB;
        endcase
      end

      // cmp_res_d/cmp_res_q
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32: cmp_res_en = {'0, {(`VLENB/4){1'b1}}} << cmp_res_offset;
          EEW16: cmp_res_en = {'0, {(`VLENB/2){1'b1}}} << cmp_res_offset;
          default: cmp_res_en = {'0, {(`VLENB){1'b1}}} << cmp_res_offset;
        endcase
      end
      assign cmp_res_d = {'0, cmp_res} << cmp_res_offset;
      for (i=0; i<`VLEN; i++) begin
        cdffr #(.WIDTH(1)) cmp_res_reg (.q(cmp_res_q[i]), .d(cmp_res_d[i]), .c(1'b0), .e(cmp_res_en[i] & pmtrdt_uop_valid & pmtrdt_uop_ready), .clk(clk), .rst_n(rst_n));
      end

      // cmp_vstart value is from the first uop of compare instruction
      assign cmp_vstart_d = pmtrdt_uop.vstart;
      assign cmp_vstart_en = pmtrdt_uop.first_uop_valid & pmtrdt_uop_valid & pmtrdt_uop_ready;
      cdffr #(.WIDTH(`VSTART_WIDTH)) cmp_vstart_reg (.q(cmp_vstart_q), .d(cmp_vstart_d), .c(1'b0), .e(cmp_vstart_en), .clk(clk), .rst_n(rst_n));
      // pmtrdt_res_cmp
      for (i=0; i<`VLEN; i++) begin
        always_comb begin
          if (i < cmp_vstart_q)      pmtrdt_res_cmp[i] = ctrl_q.vs3_data[i];
          else if (i >= ctrl_q.cmp_evl) pmtrdt_res_cmp[i] = ctrl_q.vs3_data[i];
          else if (ctrl_q.vm)         pmtrdt_res_cmp[i] = cmp_res_q[i];
          else if (ctrl_q.v0_data[i]) pmtrdt_res_cmp[i] = cmp_res_q[i];
          else                        pmtrdt_res_cmp[i] = ctrl_q.vs3_data[i];
        end
      end
    end // end if (GEN_CMP == 1'b1)
  endgenerate
  
// Permutation unit 
  // offset: select element
  generate
    if (GEN_PMT == 1'b1) begin
      for (i=0; i<`VLENB; i++) begin
        always_comb begin
          case(ctrl.pmt_opr)
            SLIDE_UP:begin
              if (pmtrdt_uop.uop_funct3 == OPMVX)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = i-4;
                  EEW16:offset[i] = i-2;
                  default:offset[i] = i-1; 
                endcase
              else
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = i - (pmtrdt_uop.rs1_data << 2);
                  EEW16:offset[i] = i - (pmtrdt_uop.rs1_data << 1);
                  default:offset[i] = i - pmtrdt_uop.rs1_data; 
                endcase
            end
            SLIDE_DOWN:begin
              if (pmtrdt_uop.uop_funct3 == OPMVX)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = i+4;
                  EEW16:offset[i] = i+2;
                  default:offset[i] = i+1;
                endcase
              else
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:offset[i] = i + (pmtrdt_uop.rs1_data << 2);
                  EEW16:offset[i] = i + (pmtrdt_uop.rs1_data << 1);
                  default:offset[i] = i + pmtrdt_uop.rs1_data;
                endcase
            end
            GATHER:begin
              case (pmtrdt_uop.uop_funct3)
                OPIVX,
                OPIVI:begin
                  case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                    EEW32:offset[i] = i%4 + 4*pmtrdt_uop.rs1_data;
                    EEW16:offset[i] = i%2 + 2*pmtrdt_uop.rs1_data;
                    default:offset[i] = pmtrdt_uop.rs1_data;
                  endcase
                end
                default:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32: offset[i] = i%4 + 4*{{(`XLEN-32){1'b0}}, uop_data[i/(`VLENB/4)].vs1_data[i%(`VLENB/4)+:32]};
                    EEW16: begin
                      case (pmtrdt_uop.vs2_eew) // vrgatherei16
                        EEW32:offset[i] = i%4 + 4*{{(`XLEN-16){1'b0}}, uop_data[i/(`VLENB/2)].vs1_data[i%(`VLENB/2)+:16]};
                        EEW16:offset[i] = i%2 + 2*{{(`XLEN-16){1'b0}}, uop_data[i/(`VLENB/2)].vs1_data[i%(`VLENB/2)+:16]};
                        default:offset[i] = {{(`XLEN-16){1'b0}}, uop_data[i/(`VLENB/2)].vs1_data[i%(`VLENB/2)+:16]};
                      endcase
                    end
                    default: offset[i] = {{(`XLEN-8){1'b0}}, uop_data[i/(`VLENB)].vs1_data[i%(`VLENB)+:8]};
                  endcase
                end
              endcase
            end
            default: offset[i] = i;
          endcase
        end
      end

      //select scalar value
      //for vslide1up, vd[0] = x[rs1]
      //for vslide1down, vd[vl-1] = x[rs1]
      always_comb begin
        if (pmtrdt_uop.uop_funct3 == OPMVX) begin
          case (ctrl.pmt_opr)
            SLIDE_UP:begin
              if (pmtrdt_uop.uop_index == 0)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:sel_scalar = 'hF;
                  EEW16:sel_scalar = 'h3;
                  default:sel_scalar = 'h1;
                endcase
              else
                sel_scalar = '0;
            end
            SLIDE_DOWN:begin
              if (pmtrdt_uop.last_uop_valid)
                case (pmtrdt_uop.vs2_eew) // Permutation instruction: vd_eew == vs2_eew
                  EEW32:sel_scalar = 'hF << ((ctrl.vl-1)%(`VLENB/4))*4;
                  EEW16:sel_scalar = 'h3 << ((ctrl.vl-1)%(`VLENB/2))*2;
                  default:sel_scalar = 'h1 << ((ctrl.vl-1)%(`VLENB))*1;
                endcase
              else
                sel_scalar = '0;
            end
            default:sel_scalar = '0;
          endcase
        end else begin
          sel_scalar = '0;
        end
      end

      for (i=0; i<`VLMAX; i++) begin
        assign pmt_vs2_data[i] = uop_data[i/`VLENB].vs2_data[i%(`VLENB)+:8];
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
      for (i=0; i<`VLENB; i++) begin
        assign pmt_res_d[i] = sel_scalar[i] ? pmt_rs1_data[i%4]   : 
                                              offset[i] >= `VLMAX ? '0 : pmt_vs2_data[offset[i]];
        cdffr #(.WIDTH(8)) pmt_res_reg (.q(pmt_res_q[i]), .d(pmt_res_d[i]), .c(1'b0), .e(ctrl.uop_type == PERMUTATION), .clk(clk), .rst_n(rst_n));
        assign pmtrdt_res_pmt[i*8+:8] = pmt_res_q[i];
      end

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
      cdffr #(.WIDTH(`VLEN)) compress_mask_reg (.q(compress_mask_q), .d(compress_mask_d), .c(1'b0), .e(compress_mask_en), .clk(clk), .rst_n(rst_n));

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

      // compress_cnt indicates how much bytes have been compressed
      always_comb begin
        if (pmtrdt_uop.uop_index == '0) compress_cnt_d = f_sum(compress_enable);
        else                            compress_cnt_d = compress_cnt_q + f_sum(compress_enable);
      end
      assign compress_cnt_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
      cdffr #(.WIDTH(VLENB_WIDTH+1)) compress_cnt_reg (.q(compress_cnt_q), .d(compress_cnt_d), .c(1'b0), .e(compress_cnt_en), .clk(clk), .rst_n(rst_n));

      // compress_offset select elements of vs2_data and compress to compress_value
      assign compress_offset = f_compress_offset(compress_enable);
      for (i=0; i<`VLENB; i++) begin
        assign compress_value[i] = compress_offset[i] == '1 ? '0 : pmtrdt_uop.vs2_data[compress_offset[i]];
      end

      // compress_res is driven by compress_value and compress_cnt.
      always_comb begin
        if (pmtrdt_uop.uop_index == '0) compress_res_d = {'0, compress_value};
        else                            compress_res_d = f_circular_shift(compress_value, compress_cnt_q);
      end

      // compress_res_en
      always_comb begin
        if (pmtrdt_uop.uop_index == '0) compress_res_en = {'0, f_pack_1s(compress_enable)};
        else                            compress_res_en = f_circular_en(compress_enable,compress_cnt_q);
      end
      for (i=0; i<2*`VLENB; i++) cdffr #(.WIDTH(8)) compress_res_reg (.q(compress_res_q[i]), .d(compress_res_d[i]), .c(1'b0), .e(compress_res_en[i]), .clk(clk), .rst_n(rst_n));

      // pmtrdt_res_compress
      always_comb begin
        if (ctrl_q.last_uop_valid)
          if (compress_cnt_q[VLENB_WIDTH]) 
            pmtrdt_res_compress = f_res_compress_merge(ctrl_q.vs3_data, compress_res_q[`VLENB+:`VLENB], compress_cnt_q[VLENB_WIDTH-1:0]);
          else
            pmtrdt_res_compress = f_res_compress_merge(ctrl_q.vs3_data, compress_res_q[0+:`VLENB], compress_cnt_q[VLENB_WIDTH-1:0]);
        else
          if (compress_cnt_q[VLENB_WIDTH])
            pmtrdt_res_compress = compress_res_q[2*`VLENB-1:`VLENB];
          else
            pmtrdt_res_compress = compress_res_q[`VLENB-1:0];
      end

    end // if (GEN_PMT == 1'b1) 
  endgenerate

// output result
  assign pmtrdt_res_valid = ctrl_q.last_uop_valid;
`ifdef TB_SUPPORT
  assign pmtrdt_res.uop_pc = ctrl_q.uop_pc;
`endif
  assign pmtrdt_res.rob_entry = ctrl_q.rob_entry;
  assign pmtrdt_res.w_valid = ctrl_q.last_uop_valid;
  assign pmtrdt_res.vsaturate = '0;
  always_comb begin
    case (ctrl_q.uop_type)
      PERMUTATION: pmtrdt_res.w_data = ctrl_q.compress ? pmtrdt_res_compress : pmtrdt_res_pmt;
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
  cdffr #(.WIDTH(1)) wredsum_flag_reg (.q(red_widen_sum_flag), .d(~red_widen_sum_flag), .c(1'b0), .e(ctrl.widen & pmtrdt_uop_valid), .clk(clk), .rst_n(rst_n));
  always_comb begin
    case (ctrl.uop_type)
      PERMUTATION: pmtrdt_uop_ready = ctrl.last_uop_valid;
      REDUCTION:
        if (ctrl.widen) pmtrdt_uop_ready = red_widen_sum_flag;
        else            pmtrdt_uop_ready = 1'b1;
      default: pmtrdt_uop_ready = 1'b1;
    endcase
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
          results[j] = i;
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
      {buf2,buf1,buf0} = value_tmp << (shift*8);
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
      for (i=0; i<`VLENB; i++) begin
        if (value[i]) begin
          result[j] = 1'b1;
          j++;
        end
      end
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
      {en2,en1,en0} = value_pack_1s << shift;
      result = shift[VLENB_WIDTH] ? {en1, en2} : {en1, en0};
      f_circular_en = result;
    end
  endfunction

// f_res_compress_merge: merge raw data with copmress result
  function [`VLEN-1:0] f_res_compress_merge;
    input [`VLENB-1:0][7:0] raw_data;
    input [`VLENB-1:0][7:0] res_data;
    input [VLENB_WIDTH-1:0] valid_num;

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

endmodule
