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
  parameter RDT_CMP   = 1'b0; // by default, NO Reduction/Comparation
  parameter COMPRESS  = 1'b0; // by default, NO Compress
// ---port definition-------------------------------------------------
// global signal
  input logic       clk;
  input logic       rst_n;

// the uop from PMTRDT RS
  input               pmtrdt_uop_valid;
  input PMT_RDT_RS_t  pmtrdt_uop;
  output              pmtrdt_uop_ready;

// the result to PMTRDT PU
  output              pmtrdt_res_valid;
  output PU2ROB_t     pmtrdt_res;
  input               pmtrdt_res_ready;

// all uop from PMTRDT RS for permuation
  input PMT_RDT_RS_t [`PMTRDT_RS_DEPTH-1:0] uop_data;

// ---internal signal definition--------------------------------------
  PMTRDT_CTRL_t             ctrl, ctrl_q; // control signals
  logic                     ctrl_reg_en;

  // Reduction/Comparation operation
  logic [`VLEN-1:0]         widen_vs2;  // vs2 data after being widen if need
  EEW_e                     widen_vs2_eew; // vs2 eew after being widen if need
  logic [`VLENB-1:0][8:0]   src1_1stage, src2_1stage; // source value for reduction/compare
  logic [`VLENB-1:0]        carry_in_1stage;
  logic [`VLENB-1:0][8:0]   sum_1stage;
  logic [`VLENB-1:0][7:0]   and_1stage, or_1stage, xor_1stage;
  // Reduction operation
  logic [`VLENB/2-1:0][8:0] src1_2stage, src2_2stage; // source value for reduction
  logic [`VLENB/2-1:0]      carry_in_2stage;
  logic [`VLENB/2-1:0][8:0] sum_2stage;
  logic [`VLENB/4-1:0][8:0] src1_3stage, src2_3stage; // source value for reduction
  logic [`VLENB/4-1:0]      carry_in_3stage;
  logic [`VLENB/4-1:0][8:0] sum_3stage;
  logic [`VLENB/2-1:0][7:0] and_2stage, or_2stage, xor_2stage;
  logic [`VLENB/4-1:0][7:0] and_3stage, or_3stage, xor_3stage;
  logic [`VLENB/4-1:0][7:0] red_res_d, red_res_q;
  logic [7:0]               sum_8b,  and_8b,  or_8b,  xor_8b;
  logic [15:0]              sum_16b, and_16b, or_16b, xor_16b;
  logic [31:0]              sum_32b, and_32b, or_32b, xor_32b;
  logic [`VLEN-1:0]         pmtrdt_res_red; // pmtrdt result of reduction
  // Comparation operation
  logic [`VLENB-1:0]        less_than, great_than, equal, not_equal;
  logic [`VLENB-1:0]        cmp_res;
  logic [`VSTART_WIDTH-1:0] cmp_res_offset;
  logic [`VLEN-1:0]         cmp_res_d, cmp_res_q;
  logic [`VLEN-1:0]         pmtrdt_res_cmp; // pmtrdt result of compare
  // Permutation operation
  logic [`VLENB-1:0][`XLEN-1:0] offset;
  BYTE_TYPE_t                   vd_type;
  logic [`VLMAX-1:0][7:0]   pmt_vs2_data;
  logic [`VLENB-1:0][7:0]   pmt_res_d, pmt_res_q;
  logic [`VLEN-1:0]         pmtrdt_res_pmt; // pmtrdt result of permutation

  genvar i;
// ---code start------------------------------------------------------
// control signals based on uop
  generate
    if (RDT_CMP == 1'b1) begin
      // uop_type: permutation, reduction or compare
      always_comb begin
        if (pmtrdt_uop.uop_exe_unit == RDT)
          case (pmtrdt_uop.uop_funct6)
            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR,
            VWREDSUMU,
            VWREDSUM: ctrl.uop_type = REDUCTION;
            default : ctrl.uop_type = COMPARE;
          endcase
        else
          ctrl.uop_type = PERMUTATION;
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
    end else begin
      assign ctrl.uop_type = PERMUTATION;
      assign ctrl.sign_opr = 1'b1;
      assign ctrl.gt_lt_eq = NOT_EQUAL;
      assign ctrl.widen   = 1'b0;
      assign ctrl.rdt_opr  = SUM;
    end
  endgenerate

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

  generate
    if (COMPRESS == 1'b1)
      // compress instruction
      assign ctrl.compress = pmtrdt_uop.uop_funct6 == VCOMPRESS;
    else
      assign ctrl.compress = 1'b0;
  endgenerate

  // uop infomation
`ifdef TB_SUPPORT
  assign ctrl.uop_pc = pmtrdt_uop.uop_pc;
`endif
  assign ctrl.rob_entry = pmtrdt_uop.rob_entry;
  assign ctrl.vstart = pmtrdt_uop.vstart;
  assign ctrl.vl     = pmtrdt_uop.vl;
  assign ctrl.vm     = pmtrdt_uop.vm;
  assign ctrl.vs1_eew        = pmtrdt_uop.vs1_eew;
  assign ctrl.v0_data        = pmtrdt_uop.v0_data;
  assign ctrl.vs3_data       = pmtrdt_uop.vs3_data;
  assign ctrl.last_uop_valid = pmtrdt_uop.last_uop_valid;

  assign ctrl_reg_en = pmtrdt_uop_valid & pmtrdt_uop_ready;
  cdffr #(.WIDTH($bits(PMTRDT_CTRL_t))) ctrl_reg (.q(ctrl_q), .d(ctrl), .c(1'b0), .e(ctrl_reg_en), .clk(clk), .rst_n(rst_n));
  
// Reduction & Comparation instruction
  generate
    if (RDT_CMP == 1'b1) begin
      // widen vs2 data & widen vs2 eew
      always_comb begin
        if (ctrl.widen) begin
          if (pmtrdt_uop.uop_index[0]) begin // uop index is odd
            case(pmtrdt_uop.vs2_eew)
              EEW16:begin
                for (int j=0; j<`VLENB/4; j++) begin
                  widen_vs2[16*(2*j)+:16]   = pmtrdt_uop.vs2_data[(`VLEN/2+16*j)+:16];
                  widen_vs2[16*(2*j+1)+:16] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[`VLEN/2+16*(j+1)-1]
                                                          : '0;
                end
              end
              default:begin
                for (int j=0; j<`VLENB/2; j++) begin
                  widen_vs2[8*(2*j)+:8]   = pmtrdt_uop.vs2_data[(`VLEN/2+8*j)+:8];
                  widen_vs2[8*(2*j+1)+:8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[`VLEN/2+8*(j+1)-1]
                                                        : '0;
                end
              end
            endcase
          end else begin                         // uop index is even
            case(pmtrdt_uop.vs2_eew)
              EEW16:begin
                for (int j=0; j<`VLENB/4; j++) begin
                  widen_vs2[16*(2*j)+:16]   = pmtrdt_uop.vs2_data[(16*j)+:16];
                  widen_vs2[16*(2*j+1)+:16] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[16*(j+1)-1]
                                                          : '0;
                end
              end
              default:begin
                for (int j=0; j<`VLENB/2; j++) begin
                  widen_vs2[8*(2*j)+:8]   = pmtrdt_uop.vs2_data[(8*j)+:8];
                  widen_vs2[8*(2*j+1)+:8] = ctrl.sign_opr ? pmtrdt_uop.vs2_data[8*(j+1)-1]
                                                        : '0;
                end
              end
            endcase
          end

          case (pmtrdt_uop.vs2_eew)
            EEW16:  widen_vs2_eew = EEW32;
            default:widen_vs2_eew = EEW16; 
          endcase
        end else begin
          widen_vs2     = pmtrdt_uop.vs2_data;
          widen_vs2_eew = pmtrdt_uop.vs2_eew;
        end
      end

      // src1_1stage/src2_1stage/carry_in_1stage data
      for (i=0; i<`VLENB; i++) begin : gen_source_1stage_data
        // src2_1stage data
        always_comb begin
          src2_1stage[i][7:0] = widen_vs2[8*i+:8]; 
          case (widen_vs2_eew)
            EEW32:   src2_1stage[i][8] = ctrl.sign_opr && i%4 == 2'd3 ? widen_vs2[8*(i+1)-1]
                                                                      : 1'b0;
            EEW16:   src2_1stage[i][8] = ctrl.sign_opr && i%2 == 2'd1 ? widen_vs2[8*(i+1)-1]
                                                                      : 1'b0;
            default: src2_1stage[i][8] = ctrl.sign_opr ? widen_vs2[8*(i+1)-1]
                                                       : 1'b0;
          endcase
        end

        // src1_1stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin 
                  src1_1stage[i][7:0] = ~pmtrdt_uop.vs1_data[8*i+:8];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:   src1_1stage[i][8] = ctrl.sign_opr && i%4 == 2'd3 ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : ~1'b0;
                    EEW16:   src1_1stage[i][8] = ctrl.sign_opr && i%2 == 2'd1 ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : ~1'b0;
                    default: src1_1stage[i][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                               : ~1'b0;
                  endcase
                end
                default:begin
                  src1_1stage[i][7:0] = pmtrdt_uop.vs1_data[8*i+:8];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:   src1_1stage[i][8] = ctrl.sign_opr && i%4 == 2'd3 ? pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : 1'b0;
                    EEW16:   src1_1stage[i][8] = ctrl.sign_opr && i%2 == 2'd1 ? pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : 1'b0;
                    default: src1_1stage[i][8] = ctrl.sign_opr ? pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                               : 1'b0;
                  endcase
                end
              endcase
            end
            COMPARE:begin
              case (pmtrdt_uop.uop_funct3)
                OPIVX,
                OPIVI:begin
                  case (pmtrdt_uop.vs2_eew)
                    EEW32:begin
                      src1_1stage[i][7:0] = ~pmtrdt_uop.rs1_data[8*(i%4)+:8];
                      src1_1stage[i][8]   = ctrl.sign_opr && i%4 == 2'd3 ? ~pmtrdt_uop.rs1_data[8*(i%4+1)-1]
                                                                         : ~1'b0;
                    end
                    EEW16:begin
                      src1_1stage[i][7:0] = ~pmtrdt_uop.rs1_data[8*(i%2)+:8];
                      src1_1stage[i][8]   = ctrl.sign_opr && i%2 == 2'd1 ? ~pmtrdt_uop.rs1_data[8*(i%2+1)-1]
                                                                         : ~1'b0;
                    end
                    default:begin
                      src1_1stage[i][7:0] = ~pmtrdt_uop.rs1_data[0+:8];
                      src1_1stage[i][8]   = ctrl.sign_opr ? ~pmtrdt_uop.rs1_data[7]
                                                          : ~1'b0;
                    end
                  endcase
                end
                default:begin
                  src1_1stage[i][7:0] = ~pmtrdt_uop.vs1_data[8*i+:8];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:   src1_1stage[i][8] = ctrl.sign_opr && i%4 == 2'd3 ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : ~1'b0;
                    EEW16:   src1_1stage[i][8] = ctrl.sign_opr && i%2 == 2'd1 ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                                              : ~1'b0;
                    default: src1_1stage[i][8] = ctrl.sign_opr ? ~pmtrdt_uop.vs1_data[8*(i+1)-1]
                                                               : ~1'b0;
                  endcase
                end
              endcase
            end
            default:begin 
              src1_1stage[i][7:0] = 8'h0;
              src1_1stage[i][8]   = 1'h0;
            end
          endcase
        end

        // carry_in_1stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:   carry_in_1stage[i] = i%4 == 2'd0 ? 1'b1 : sum_1stage[i-1][8];
                    EEW16:   carry_in_1stage[i] = i%2 == 2'd0 ? 1'b1 : sum_1stage[i-1][8]; 
                    default: carry_in_1stage[i] = 1'b1;
                  endcase
                end
                default:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:  carry_in_1stage[i] = i%4 == 2'd0 ? 1'b0 : sum_1stage[i-1][8];
                    EEW16:  carry_in_1stage[i] = i%2 == 2'd0 ? 1'b0 : sum_1stage[i-1][8];
                    default:carry_in_1stage[i] = 1'b0; 
                  endcase
                end
              endcase
            end
            COMPARE:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32:   carry_in_1stage[i] = i%4 == 2'd0 ? 1'b1 : 1'b0;
                EEW16:   carry_in_1stage[i] = i%2 == 2'd0 ? 1'b1 : 1'b0; 
                default: carry_in_1stage[i] = 1'b1;
              endcase
            end
            default: carry_in_1stage[i] = 1'b0;
          endcase
        end
      end // end for statement

      // `VLENB 9-bit-adder/and/or/xor for 1stage
      for (i=0; i<`VLENB; i++) begin : gen_arithmetic_unit_1stage
        assign sum_1stage[i]   = src2_1stage[i] + src1_1stage[i] + carry_in_1stage[i];
        assign and_1stage[i]   = src2_1stage[i][7:0] & src1_1stage[i][7:0];
        assign or_1stage[i]    = src2_1stage[i][7:0] | src1_1stage[i][7:0];
        assign xor_1stage[i]   = src2_1stage[i][7:0] ^ src1_1stage[i][7:0];
      end

      // generate reduction result for reduction operation
      // src1_2stage/src2_2stage/carry_in_2stage data
      for (i=0; i<`VLENB/(2*4); i++) begin : gen_source_2stage_data
        // src2_2stage data
        always_comb begin
          src2_2stage[4*i][7:0]   = sum_1stage[4*i][7:0];
          src2_2stage[4*i+1][7:0] = sum_1stage[4*i+1][7:0];
          src2_2stage[4*i+2][7:0] = sum_1stage[4*i+2][7:0];
          src2_2stage[4*i+3][7:0] = sum_1stage[4*i+3][7:0];
          case (widen_vs2_eew)
            EEW32:begin
              src2_2stage[4*i][8]   = 1'b0;
              src2_2stage[4*i+1][8] = 1'b0;
              src2_2stage[4*i+2][8] = 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              src2_2stage[4*i][8]   = 1'b0;
              src2_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[4*i+1][7] : 1'b0;
              src2_2stage[4*i+2][8] = 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[4*i+3][7] : 1'b0;
            end
            default:begin
              src2_2stage[4*i][8]   = ctrl.sign_opr ? sum_1stage[4*i][7] : 1'b0;
              src2_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[4*i+1][7] : 1'b0;
              src2_2stage[4*i+2][8] = ctrl.sign_opr ? sum_1stage[4*i+2][7] : 1'b0;
              src2_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[4*i+3][7] : 1'b0;
            end
          endcase
        end
        
        //src1_2stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin
                  src1_2stage[4*i][7:0]   = ~sum_1stage[`VLENB/2+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = ~sum_1stage[`VLENB/2+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = ~sum_1stage[`VLENB/2+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = ~sum_1stage[`VLENB/2+4*i+3][7:0];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      src1_2stage[4*i][8]   = 1'b0;
                      src1_2stage[4*i+1][8] = 1'b0;
                      src1_2stage[4*i+2][8] = 1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+3][7] : ~1'b0;
                    end
                    EEW16:begin
                      src1_2stage[4*i][8]   = 1'b0;
                      src1_2stage[4*i+1][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+1][7] : ~1'b0;
                      src1_2stage[4*i+2][8] = 1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+3][7] : ~1'b0;
                    end
                    default:begin
                      src1_2stage[4*i][8]   = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i][7] : ~1'b0;
                      src1_2stage[4*i+1][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+1][7] : ~1'b0;
                      src1_2stage[4*i+2][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+2][7] : ~1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? ~sum_1stage[`VLENB/2+4*i+3][7] : ~1'b0;
                    end
                  endcase
                end
                default:begin
                  src1_2stage[4*i][7:0]   = sum_1stage[`VLENB/2+4*i][7:0];
                  src1_2stage[4*i+1][7:0] = sum_1stage[`VLENB/2+4*i+1][7:0];
                  src1_2stage[4*i+2][7:0] = sum_1stage[`VLENB/2+4*i+2][7:0];
                  src1_2stage[4*i+3][7:0] = sum_1stage[`VLENB/2+4*i+3][7:0];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      src1_2stage[4*i][8]   = 1'b0;
                      src1_2stage[4*i+1][8] = 1'b0;
                      src1_2stage[4*i+2][8] = 1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                    end
                    EEW16:begin
                      src1_2stage[4*i][8]   = 1'b0;
                      src1_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+1][7] : 1'b0;
                      src1_2stage[4*i+2][8] = 1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                    end
                    default:begin
                      src1_2stage[4*i][8]   = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i][7] : 1'b0;
                      src1_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+1][7] : 1'b0;
                      src1_2stage[4*i+2][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+2][7] : 1'b0;
                      src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                    end
                  endcase
                end
              endcase
            end
            default:begin
              src1_2stage[4*i][7:0]   = sum_1stage[`VLENB/2+4*i][7:0];
              src1_2stage[4*i+1][7:0] = sum_1stage[`VLENB/2+4*i+1][7:0];
              src1_2stage[4*i+2][7:0] = sum_1stage[`VLENB/2+4*i+2][7:0];
              src1_2stage[4*i+3][7:0] = sum_1stage[`VLENB/2+4*i+3][7:0];
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = 1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                end
                EEW16:begin
                  src1_2stage[4*i][8]   = 1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+1][7] : 1'b0;
                  src1_2stage[4*i+2][8] = 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                end
                default:begin
                  src1_2stage[4*i][8]   = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i][7] : 1'b0;
                  src1_2stage[4*i+1][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+1][7] : 1'b0;
                  src1_2stage[4*i+2][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+2][7] : 1'b0;
                  src1_2stage[4*i+3][8] = ctrl.sign_opr ? sum_1stage[`VLENB/2+4*i+3][7] : 1'b0;
                end
              endcase
            end
          endcase
        end
        
        //carry_in_2stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      carry_in_2stage[4*i] = 1'b1;
                      carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                      carry_in_2stage[4*i+2] = sum_2stage[4*i+1][8];
                      carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                    end
                    EEW16:begin
                      carry_in_2stage[4*i] = 1'b1;
                      carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                      carry_in_2stage[4*i+2] = 1'b1;
                      carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                    end
                    default:begin
                      carry_in_2stage[4*i] = 1'b1;
                      carry_in_2stage[4*i+1] = 1'b1;
                      carry_in_2stage[4*i+2] = 1'b1;
                      carry_in_2stage[4*i+3] = 1'b1;
                    end
                  endcase
                end
                default:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      carry_in_2stage[4*i] = 1'b0;
                      carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                      carry_in_2stage[4*i+2] = sum_2stage[4*i+1][8];
                      carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                    end
                    EEW16:begin
                      carry_in_2stage[4*i] = 1'b0;
                      carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                      carry_in_2stage[4*i+2] = 1'b0;
                      carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                    end
                    default:begin
                      carry_in_2stage[4*i] = 1'b0;
                      carry_in_2stage[4*i+1] = 1'b0;
                      carry_in_2stage[4*i+2] = 1'b0;
                      carry_in_2stage[4*i+3] = 1'b0;
                    end
                  endcase
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_2stage[4*i] = 1'b0;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = sum_2stage[4*i+1][8];
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_2stage[4*i] = 1'b0;
                  carry_in_2stage[4*i+1] = sum_2stage[4*i][8];
                  carry_in_2stage[4*i+2] = 1'b0;
                  carry_in_2stage[4*i+3] = sum_2stage[4*i+2][8];
                end
                default:begin
                  carry_in_2stage[4*i] = 1'b0;
                  carry_in_2stage[4*i+1] = 1'b0;
                  carry_in_2stage[4*i+2] = 1'b0;
                  carry_in_2stage[4*i+3] = 1'b0;
                end
              endcase
            end
          endcase
        end
      end //end for (i=0; i<`VLENB/(2*4); i=i+4)

      // `VLENB/2 9-bit-adder/and/or/xor for 2stage
      for (i=0; i<`VLENB/2; i++) begin : gen_arithmetic_unit_2stage
        assign sum_2stage[i]   = src2_2stage[i] + src1_2stage[i] + carry_in_2stage[i];
        assign and_2stage[i]   = src2_2stage[i][7:0] & src1_2stage[i][7:0];
        assign or_2stage[i]    = src2_2stage[i][7:0] | src1_2stage[i][7:0];
        assign xor_2stage[i]   = src2_2stage[i][7:0] ^ src1_2stage[i][7:0];
      end

      // src1_3stage/src2_3stage/carry_in_3stage data
      for (i=0; i<`VLENB/(4*4); i++) begin : gen_source_3stage_data
        // src2_3stage data
        always_comb begin
          src2_3stage[4*i][7:0]   = sum_2stage[4*i][7:0];
          src2_3stage[4*i+1][7:0] = sum_2stage[4*i+1][7:0];
          src2_3stage[4*i+2][7:0] = sum_2stage[4*i+2][7:0];
          src2_3stage[4*i+3][7:0] = sum_2stage[4*i+3][7:0];
          case (widen_vs2_eew)
            EEW32:begin
              src2_3stage[4*i][8]   = 1'b0;
              src2_3stage[4*i+1][8] = 1'b0;
              src2_3stage[4*i+2][8] = 1'b0;
              src2_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[4*i+3][7] : 1'b0;
            end
            EEW16:begin
              src2_3stage[4*i][8]   = 1'b0;
              src2_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[4*i+1][7] : 1'b0;
              src2_3stage[4*i+2][8] = 1'b0;
              src2_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[4*i+3][7] : 1'b0;
            end
            default:begin
              src2_3stage[4*i][8]   = ctrl.sign_opr ? sum_2stage[4*i][7] : 1'b0;
              src2_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[4*i+1][7] : 1'b0;
              src2_3stage[4*i+2][8] = ctrl.sign_opr ? sum_2stage[4*i+2][7] : 1'b0;
              src2_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[4*i+3][7] : 1'b0;
            end
          endcase
        end

        //src1_3stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin
                  src1_3stage[4*i][7:0]   = ~sum_2stage[`VLENB/4+4*i][7:0];
                  src1_3stage[4*i+1][7:0] = ~sum_2stage[`VLENB/4+4*i+1][7:0];
                  src1_3stage[4*i+2][7:0] = ~sum_2stage[`VLENB/4+4*i+2][7:0];
                  src1_3stage[4*i+3][7:0] = ~sum_2stage[`VLENB/4+4*i+3][7:0];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      src1_3stage[4*i][8]   = 1'b0;
                      src1_3stage[4*i+1][8] = 1'b0;
                      src1_3stage[4*i+2][8] = 1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+3][7] : ~1'b0;
                    end
                    EEW16:begin
                      src1_3stage[4*i][8]   = 1'b0;
                      src1_3stage[4*i+1][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+1][7] : ~1'b0;
                      src1_3stage[4*i+2][8] = 1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+3][7] : ~1'b0;
                    end
                    default:begin
                      src1_3stage[4*i][8]   = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i][7] : ~1'b0;
                      src1_3stage[4*i+1][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+1][7] : ~1'b0;
                      src1_3stage[4*i+2][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+2][7] : ~1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? ~sum_2stage[`VLENB/4+4*i+3][7] : ~1'b0;
                    end
                  endcase
                end
                default:begin
                  src1_3stage[4*i][7:0]   = sum_2stage[`VLENB/4+4*i][7:0];
                  src1_3stage[4*i+1][7:0] = sum_2stage[`VLENB/4+4*i+1][7:0];
                  src1_3stage[4*i+2][7:0] = sum_2stage[`VLENB/4+4*i+2][7:0];
                  src1_3stage[4*i+3][7:0] = sum_2stage[`VLENB/4+4*i+3][7:0];
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      src1_3stage[4*i][8]   = 1'b0;
                      src1_3stage[4*i+1][8] = 1'b0;
                      src1_3stage[4*i+2][8] = 1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                    end
                    EEW16:begin
                      src1_3stage[4*i][8]   = 1'b0;
                      src1_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+1][7] : 1'b0;
                      src1_3stage[4*i+2][8] = 1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                    end
                    default:begin
                      src1_3stage[4*i][8]   = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i][7] : 1'b0;
                      src1_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+1][7] : 1'b0;
                      src1_3stage[4*i+2][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+2][7] : 1'b0;
                      src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                    end
                  endcase
                end
              endcase
            end
            default:begin
              src1_3stage[4*i][7:0]   = sum_2stage[`VLENB/4+4*i][7:0];
              src1_3stage[4*i+1][7:0] = sum_2stage[`VLENB/4+4*i+1][7:0];
              src1_3stage[4*i+2][7:0] = sum_2stage[`VLENB/4+4*i+2][7:0];
              src1_3stage[4*i+3][7:0] = sum_2stage[`VLENB/4+4*i+3][7:0];
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  src1_3stage[4*i][8]   = 1'b0;
                  src1_3stage[4*i+1][8] = 1'b0;
                  src1_3stage[4*i+2][8] = 1'b0;
                  src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                end
                EEW16:begin
                  src1_3stage[4*i][8]   = 1'b0;
                  src1_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+1][7] : 1'b0;
                  src1_3stage[4*i+2][8] = 1'b0;
                  src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                end
                default:begin
                  src1_3stage[4*i][8]   = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i][7] : 1'b0;
                  src1_3stage[4*i+1][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+1][7] : 1'b0;
                  src1_3stage[4*i+2][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+2][7] : 1'b0;
                  src1_3stage[4*i+3][8] = ctrl.sign_opr ? sum_2stage[`VLENB/4+4*i+3][7] : 1'b0;
                end
              endcase
            end
          endcase
        end

        //carry_in_3stage data
        always_comb begin
          case (ctrl.uop_type)
            REDUCTION:begin
              case (ctrl.rdt_opr)
                MAX,
                MIN:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      carry_in_3stage[4*i] = 1'b1;
                      carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                      carry_in_3stage[4*i+2] = sum_3stage[4*i+1][8];
                      carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                    end
                    EEW16:begin
                      carry_in_3stage[4*i] = 1'b1;
                      carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                      carry_in_3stage[4*i+2] = 1'b1;
                      carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                    end
                    default:begin
                      carry_in_3stage[4*i] = 1'b1;
                      carry_in_3stage[4*i+1] = 1'b1;
                      carry_in_3stage[4*i+2] = 1'b1;
                      carry_in_3stage[4*i+3] = 1'b1;
                    end
                  endcase
                end
                default:begin
                  case (pmtrdt_uop.vs1_eew)
                    EEW32:begin
                      carry_in_3stage[4*i] = 1'b0;
                      carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                      carry_in_3stage[4*i+2] = sum_3stage[4*i+1][8];
                      carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                    end
                    EEW16:begin
                      carry_in_3stage[4*i] = 1'b0;
                      carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                      carry_in_3stage[4*i+2] = 1'b0;
                      carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                    end
                    default:begin
                      carry_in_3stage[4*i] = 1'b0;
                      carry_in_3stage[4*i+1] = 1'b0;
                      carry_in_3stage[4*i+2] = 1'b0;
                      carry_in_3stage[4*i+3] = 1'b0;
                    end
                  endcase
                end
              endcase
            end
            default:begin
              case (pmtrdt_uop.vs1_eew)
                EEW32:begin
                  carry_in_3stage[4*i] = 1'b0;
                  carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                  carry_in_3stage[4*i+2] = sum_3stage[4*i+1][8];
                  carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                end
                EEW16:begin
                  carry_in_3stage[4*i] = 1'b0;
                  carry_in_3stage[4*i+1] = sum_3stage[4*i][8];
                  carry_in_3stage[4*i+2] = 1'b0;
                  carry_in_3stage[4*i+3] = sum_3stage[4*i+2][8];
                end
                default:begin
                  carry_in_3stage[4*i] = 1'b0;
                  carry_in_3stage[4*i+1] = 1'b0;
                  carry_in_3stage[4*i+2] = 1'b0;
                  carry_in_3stage[4*i+3] = 1'b0;
                end
              endcase
            end
          endcase
        end
      end // end for (i=0; i<`VLENB/(4*4); i=i+4)

      // `VLENB/4 9-bit-adder/and/or/xor for 3stage
      for (i=0; i<`VLENB/4; i++) begin : gen_arithmetic_unit_3stage
        assign sum_3stage[i]   = src2_3stage[i] + src1_3stage[i] + carry_in_3stage[i];
        assign and_3stage[i]   = src2_3stage[i][7:0] & src1_3stage[i][7:0];
        assign or_3stage[i]    = src2_3stage[i][7:0] | src1_3stage[i][7:0];
        assign xor_3stage[i]   = src2_3stage[i][7:0] ^ src1_3stage[i][7:0];
      end

      for (i=0; i<`VLENB/4; i++) begin : gen_reduction_result
        // select red_res_d based on reduction operation
        always_comb begin
          case(ctrl.rdt_opr)
            SUM: red_res_d[i] = sum_3stage[i][7:0];
            MAX: red_res_d[i] = sum_3stage[i][7:0];
            MIN: red_res_d[i] = sum_3stage[i][7:0];
            AND: red_res_d[i] = and_3stage[i];
            OR:  red_res_d[i] = or_3stage[i];
            XOR: red_res_d[i] = xor_3stage[i];
            default: red_res_d[i] = '0;
          endcase
        end

        cdffr #(.WIDTH(8)) red_res_reg (.q(red_res_q[i]), .d(red_res_d[i]), .c(ctrl_q.last_uop_valid), .e(ctrl.uop_type == REDUCTION), .clk(clk), .rst_n(rst_n));
      end

      // reduction result when vd_eew is 32b
      always_comb begin
        sum_32b = '0;
        and_32b = '1;
        or_32b  = '0;
        xor_32b = '0;
        for (int j=0; j<`VLENB/16; j++) begin
          sum_32b = sum_32b + {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          and_32b = and_32b & {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          or_32b  = or_32b  | {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
          xor_32b = xor_32b ^ {red_res_q[4*j+3],red_res_q[4*j+2],red_res_q[4*j+1],red_res_q[4*j]};
        end
      end

      // reduction result when vd_eew is 16b
      always_comb begin
        sum_16b = '0;
        and_16b = '1;
        or_16b  = '0;
        xor_16b = '0;
        for (int j=0; j<`VLENB/8; j++) begin
          sum_16b = sum_16b + {red_res_q[2*j+1],red_res_q[2*j]};
          and_16b = and_16b & {red_res_q[2*j+1],red_res_q[2*j]};
          or_16b  = or_16b  | {red_res_q[2*j+1],red_res_q[2*j]};
          xor_16b = xor_16b ^ {red_res_q[2*j+1],red_res_q[2*j]};
        end
      end

      // reduction result when vd_eew is 8b
      always_comb begin
        sum_8b = '0;
        and_8b = '1;
        or_8b  = '0;
        xor_8b = '0;
        for (int j=0; j<`VLENB/4; j++) begin
          sum_8b = sum_8b + red_res_q[j];
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
              MAX: pmtrdt_res_red = {{(`VLEN-32){1'b0}},sum_32b};
              MIN: pmtrdt_res_red = {{(`VLEN-32){1'b0}},sum_32b};
              AND: pmtrdt_res_red = {{(`VLEN-32){1'b0}},and_32b};
              OR:  pmtrdt_res_red = {{(`VLEN-32){1'b0}},or_32b};
              XOR: pmtrdt_res_red = {{(`VLEN-32){1'b0}},xor_32b};
              default: pmtrdt_res_red = '0;
            endcase
          end
          EEW16:begin
            case (ctrl_q.rdt_opr)
              SUM: pmtrdt_res_red = {{(`VLEN-16){1'b0}},sum_16b};
              MAX: pmtrdt_res_red = {{(`VLEN-16){1'b0}},sum_16b};
              MIN: pmtrdt_res_red = {{(`VLEN-16){1'b0}},sum_16b};
              AND: pmtrdt_res_red = {{(`VLEN-16){1'b0}},and_16b};
              OR:  pmtrdt_res_red = {{(`VLEN-16){1'b0}},or_16b};
              XOR: pmtrdt_res_red = {{(`VLEN-16){1'b0}},xor_16b};
              default: pmtrdt_res_red = '0;
            endcase
          end
          default:begin
            case (ctrl_q.rdt_opr)
              SUM: pmtrdt_res_red = {{(`VLEN-8){1'b0}},sum_8b};
              MAX: pmtrdt_res_red = {{(`VLEN-8){1'b0}},sum_8b};
              MIN: pmtrdt_res_red = {{(`VLEN-8){1'b0}},sum_8b};
              AND: pmtrdt_res_red = {{(`VLEN-8){1'b0}},and_8b};
              OR:  pmtrdt_res_red = {{(`VLEN-8){1'b0}},or_8b};
              XOR: pmtrdt_res_red = {{(`VLEN-8){1'b0}},xor_8b};
              default: pmtrdt_res_red = '0;
            endcase
          end
        endcase
      end

      // generate compare result for compare operation
      for (i=0; i<`VLENB; i++) begin : gen_compare_result
        assign less_than[i]  = sum_1stage[i][8];
        assign great_than[i] = ~sum_1stage[i][8]; 
        assign equal[i]      = xor_1stage[i] == '0;
        assign not_equal[i]  = xor_1stage[i] != '0;

        // cmp_res data
        always_comb begin
          cmp_res[i]    = 1'b0;
          case (ctrl.gt_lt_eq)
            NOT_EQUAL:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32: if (i < `VLENB/4) cmp_res[i] = |not_equal[4*i+:4]; 
                EEW16: if (i < `VLENB/2) cmp_res[i] = |not_equal[2*i+:2];
                default: cmp_res[i] = not_equal[i];
              endcase
            end
            EQUAL:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32: if (i < `VLENB/4) cmp_res[i] = &equal[4*i+:4];
                EEW16: if (i < `VLENB/2) cmp_res[i] = &equal[2*i+:2];
                default: cmp_res[i] = equal[i];
              endcase
            end
            LESS_THAN:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32: if (i < `VLENB/4) cmp_res[i] = less_than[4*(i+1)-1];
                EEW16: if (i < `VLENB/2) cmp_res[i] = less_than[2*(i+1)-1];
                default: cmp_res[i] = less_than[i];
              endcase
            end
            LESS_THAN_OR_EQUAL:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32: if (i < `VLENB/4) cmp_res[i] = less_than[4*(i+1)-1] | (&equal[4*i+:4]);
                EEW16: if (i < `VLENB/2) cmp_res[i] = less_than[2*(i+1)-1] | (&equal[2*i+:2]);
                default: cmp_res[i] = less_than[i] | equal[i];
              endcase
            end
            GREAT_THAN:begin
              case (pmtrdt_uop.vs2_eew)
                EEW32: if (i < `VLENB/4) cmp_res[i] = great_than[4*(i+1)-1];
                EEW16: if (i < `VLENB/2) cmp_res[i] = great_than[2*(i+1)-1];
                default: cmp_res[i] = great_than[i];
              endcase
            end
            default:begin
                cmp_res[i] = 1'b0;
            end
          endcase
        end
      end //end for () begin : gen_compare_result

      // cmp_res_offset
      always_comb begin
        case (pmtrdt_uop.vs2_eew)
          EEW32: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/4;
          EEW16: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB/2;
          default: cmp_res_offset = pmtrdt_uop.uop_index * `VLENB;
        endcase
      end

      // cmp_res_d/cmp_res_q
      assign cmp_res_d = {'0, cmp_res} << cmp_res_offset;
      for (i=0; i<`VLEN; i++) begin
        cdffr cmp_res_reg (.q(cmp_res_q[i]), .d(cmp_res_d[i]), .c(ctrl_q.last_uop_valid), .e(cmp_res_d[i]), .clk(clk), .rst_n(rst_n));
      end

      // pmtrdt_res_cmp
      for (i=0; i<`VLEN; i++) begin
        always_comb begin
          if (i < ctrl_q.vstart) pmtrdt_res_cmp[i] = ctrl_q.vs3_data[i];
          else if (ctrl_q.vm)    pmtrdt_res_cmp[i] = cmp_res_q[i];
          else if (ctrl_q.v0_data[i]) pmtrdt_res_cmp[i] = cmp_res_q[i];
          else                        pmtrdt_res_cmp[i] = ctrl_q.vs3_data[i];
        end
      end

    end else begin // end if (RDT_CMP == 1'b1)
      assign pmtrdt_res_red = '0;
      assign pmtrdt_res_cmp = '0;
    end
  endgenerate
  
// Permutation instructions
  // offset: select element
  generate
    for (i=0; i<`VLENB; i++) begin
      always_comb begin
        case(ctrl.pmt_opr)
          SLIDE_UP:  offset[i] = pmtrdt_uop.uop_funct3 == OPMVX ? i-1 : i - pmtrdt_uop.rs1_data; 
          SLIDE_DOWN:offset[i] = pmtrdt_uop.uop_funct3 == OPMVX ? i+1 : i + pmtrdt_uop.rs1_data;
          GATHER:begin
            case (pmtrdt_uop.uop_funct3)
              OPIVX,
              OPIVI: offset[i] = pmtrdt_uop.rs1_data;
              default:begin
                case(pmtrdt_uop.vs1_eew)
                  EEW32: offset[i] = {{(`XLEN-32){1'b0}}, uop_data[i/(`VLENB/4)].vs1_data[i%(`VLENB/4)+:32]};
                  EEW16: offset[i] = {{(`XLEN-16){1'b0}}, uop_data[i/(`VLENB/2)].vs1_data[i%(`VLENB/2)+:16]};
                  default: offset[i] = {{(`XLEN-8){1'b0}}, uop_data[i/(`VLENB)].vs1_data[i%(`VLENB)+:8]};
                endcase
              end
            endcase
          end
          default: offset[i] = i;
        endcase
      end
    end

    for (i=0; i<`VLMAX; i++) begin
      assign pmt_vs2_data[i] = uop_data[i/`VLENB].vs2_data[i%(`VLENB)+:8];
    end

    // pmt_res_d/pmt_res_q
    for (i=0; i<`VLENB; i++) begin
      assign pmt_res_d[i] = pmt_vs2_data[offset[i]];
      cdffr #(.WIDTH(8)) pmt_res_reg (.q(pmt_res_q[i]), .d(pmt_res_d[i]), .c(1'b0), .e(ctrl.uop_type == PERMUTATION), .clk(clk), .rst_n(rst_n));
      assign pmtrdt_res_pmt[i*8+:8] = pmt_res_q[i];
    end
  endgenerate

// Compress instruction
  generate
    if (COMPRESS == 1'b1) begin
    end // end if (COMPRESS == 1'b1)
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
      PERMUTATION: pmtrdt_res.w_data = pmtrdt_res_pmt;
      REDUCTION:   pmtrdt_res.w_data = pmtrdt_res_red;
      COMPARE:     pmtrdt_res.w_data = pmtrdt_res_cmp;
      default:     pmtrdt_res.w_data = pmtrdt_res_cmp;
    endcase
  end

  assign pmtrdt_uop_ready = ctrl.last_uop_valid;

endmodule
