
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_alu_unit_other
(
  alu_uop_valid,
  alu_uop,
  result_valid,
  result
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic                   alu_uop_valid;
  input   ALU_RS_t                alu_uop;

  // ALU send result signals to ROB
  output  logic                   result_valid;
  output  PU2ROB_t                result;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
  FUNCT6_u                            uop_funct6;
  logic   [`FUNCT3_WIDTH-1:0]         uop_funct3;
  logic                               vm;
  EEW_e                               vd_eew;
  logic   [`VLEN-1:0]                 v0_data;
  logic                               v0_data_valid;
  logic   [`REGFILE_INDEX_WIDTH-1:0]  vs1_opcode;              
  logic   [`VLEN-1:0]                 vs1_data;           
  logic                               vs1_data_valid; 
  logic   [`VLEN-1:0]                 vs2_data;	        
  logic                               vs2_data_valid;  
  EEW_e                               vs2_eew;
  logic   [`XLEN-1:0] 	              rs1_data;        
  logic        	                      rs1_data_valid;
  logic   [`UOP_INDEX_WIDTH-1:0]      uop_index;          

  // execute 
  // mask logic instructions
  logic   [`VLENB-1:0]                                v0_data_in_use;
  logic   [`VLEN-1:0]                                 src2_data;
  logic   [`VLEN-1:0]                                 src1_data;
  logic   [`VLEN-1:0]                                 result_data;
  logic   [`VLEN-1:0]                                 result_data_extend;  
  logic   [`VLEN-1:0]                                 result_data_vmerge; 
  
  // for-loop
  genvar                                              j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
  assign  vm             = alu_uop.vm;
  assign  v0_data        = alu_uop.v0_data;
  assign  v0_data_valid  = alu_uop.v0_data_valid;
  assign  vd_eew         = alu_uop.vd_eew;
  assign  vs1_opcode     = alu_uop.vs1;
  assign  vs1_data       = alu_uop.vs1_data;
  assign  vs1_data_valid = alu_uop.vs1_data_valid;
  assign  vs2_data       = alu_uop.vs2_data;
  assign  vs2_data_valid = alu_uop.vs2_data_valid;
  assign  vs2_eew        = alu_uop.vs2_eew;
  assign  rs1_data       = alu_uop.rs1_data;
  assign  rs1_data_valid = alu_uop.rs1_data_valid;
  assign  uop_index      = alu_uop.uop_index;

//  
// prepare source data 
//
  // get valid signal
  always_comb begin
    result_valid = 'b0;

    // prepare source data
    case(uop_funct3)
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            //                                          vmv.v           vmerge.v
            result_valid = alu_uop_valid&vs1_data_valid&(vm||vs2_data_valid&v0_data_valid);
          end
        endcase
      end

      OPIVX: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            //                                          vmv.v           vmerge.v
            result_valid = alu_uop_valid&rs1_data_valid&(vm||vs2_data_valid&v0_data_valid);
          end
        endcase
      end

      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            //                                          vmv.v           vmerge.v
            result_valid = alu_uop_valid&rs1_data_valid&(vm||vs2_data_valid&v0_data_valid);
          end
          VSMUL_VMVNRR: begin
            result_valid = alu_uop_valid&vm&vs2_data_valid;
          end
        endcase
      end

      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VXUNARY0: begin
            case(vs1_opcode) 
              VZEXT_VF2,
              VSEXT_VF2: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16));
              end
              VZEXT_VF4,
              VSEXT_VF4: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&(vs2_eew==EEW8);
              end
            endcase
          end
          VWXUNARY0: begin
            // vmv.x.s
            result_valid = alu_uop_valid&vm&vs2_data_valid&(vs1_opcode==VMV_X_S);
          end
        endcase
      end

      OPMVX: begin
        case(uop_funct6.ari_funct6)
          VWXUNARY0: begin
            // vmv.s.x
            result_valid = alu_uop_valid&vm&rs1_data_valid;
          end
        endcase
      end
    endcase
  end

  // prepare source data
  always_comb begin
    // initial the data
    src2_data    = 'b0;
    src1_data    = 'b0;

    // prepare source data
    case(uop_funct3)
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            // vmv.v
            if(vm) begin
              src1_data = vs1_data;
            end
            // vmerge.v
            else begin
              src2_data = vs2_data;
              src1_data = vs1_data;
            end
          end
        endcase
      end

      OPIVX: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            // vmv.v
            if(vm==1'b1) begin
              for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vd_eew)
                  EEW8: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                  EEW32: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
            // vmerge.v
            else begin
              src2_data = vs2_data;
              for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                  EEW32: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
          end
        endcase
      end

      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            // vmv.v
            if(vm==1'b1) begin
              for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vd_eew)
                  EEW8: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                  EEW32: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
            // vmerge.v
            else begin
              src2_data = vs2_data;
              for(int i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
                case(vs2_eew)
                  EEW8: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
                  end
                  EEW16: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                  EEW32: begin
                    src1_data[(4*i  )*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[0             +: `BYTE_WIDTH];
                    src1_data[(4*i+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[1*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[2*`BYTE_WIDTH +: `BYTE_WIDTH];
                    src1_data[(4*i+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = rs1_data[3*`BYTE_WIDTH +: `BYTE_WIDTH];
                  end
                endcase
              end
            end
          end
          VSMUL_VMVNRR: begin
            if(vm) begin
              src2_data = vs2_data;
            end
          end
        endcase
      end

      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VXUNARY0: begin
            case(vs1_opcode) 
              VZEXT_VF2,
              VSEXT_VF2: begin
                if (uop_index[0]==1'b0)
                  src2_data = {2{vs2_data[0 +: `VLEN/2]}};
                else
                  src2_data = {2{vs2_data[`VLEN/2 +: `VLEN/2]}};
              end
              VZEXT_VF4,
              VSEXT_VF4: begin
                if (uop_index[1:0]==2'b0)
                  src2_data = {4{vs2_data[0 +: `VLEN/4]}};
                else if (uop_index[1:0]==2'b01)
                  src2_data = {4{vs2_data[1*`VLEN/4 +: `VLEN/4]}};
                else if (uop_index[1:0]==2'b10)
                  src2_data = {4{vs2_data[2*`VLEN/4 +: `VLEN/4]}};
                else
                  src2_data = {4{vs2_data[3*`VLEN/4 +: `VLEN/4]}};
              end
            endcase
          end
          VWXUNARY0: begin
            // vmv.x.s
            if(vs1_opcode==VMV_X_S) begin
              case(vs2_eew)
                EEW8: begin
                  src2_data[0 +: `BYTE_WIDTH] = vs2_data[0 +: `BYTE_WIDTH];
                end
                EEW16: begin
                  src2_data[0 +: `HWORD_WIDTH] = vs2_data[0 +: `HWORD_WIDTH];
                end
                EEW32: begin
                  src2_data[0 +: `WORD_WIDTH] = vs2_data[0 +: `WORD_WIDTH];
                end
              endcase
            end
          end
        endcase
      end

      OPMVX: begin
        case(uop_funct6.ari_funct6)
          VWXUNARY0: begin
            // vmv.s.x
            case(vd_eew)
              EEW8: begin
                src1_data[0 +: `BYTE_WIDTH] = rs1_data[0 +: `BYTE_WIDTH];
              end
              EEW16: begin
                src1_data[0 +: `HWORD_WIDTH] = rs1_data[0 +: `HWORD_WIDTH];
              end
              EEW32: begin
                src1_data[0 +: `WORD_WIDTH] = rs1_data[0 +: `WORD_WIDTH];
              end
            endcase
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  // VXUNARY0
  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_EXTEND
      always_comb begin
        result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = 'b0;
        
        case(vs1_opcode) 
          VZEXT_VF2: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] = {8'b0, src2_data[(2*j  )*`BYTE_WIDTH +: `BYTE_WIDTH]};
                result_data_extend[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = {8'b0, src2_data[(2*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
              EEW16: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {16'b0, src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]};
              end
            endcase
          end
          VSEXT_VF2: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] = {{8{src2_data[(2*j+1)*`BYTE_WIDTH-1]}}, src2_data[(2*j  )*`BYTE_WIDTH +: `BYTE_WIDTH]};
                result_data_extend[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = {{8{src2_data[(2*j+2)*`BYTE_WIDTH-1]}}, src2_data[(2*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
              EEW16: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{16{src2_data[(j+1)*`HWORD_WIDTH-1]}},src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]};
              end
            endcase
          end
          VZEXT_VF4: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {24'b0, src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
            endcase
          end
          VSEXT_VF4: begin       
            case(vs2_eew)
              EEW8: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{24{src2_data[(j+1)*`BYTE_WIDTH-1]}}, src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
            endcase
          end
        endcase
      end
    end
  endgenerate
 
  // vmerge
  always_comb begin
    v0_data_in_use = 'b0;

    case(vs2_eew)
      EEW8: begin
        v0_data_in_use = v0_data[{uop_index,{($clog2(`VLENB)){1'b0}}} +: `VLENB];
      end
      EEW16: begin
        v0_data_in_use = {{(`VLENB/2){1'b0}}, v0_data[{uop_index,{($clog2(`VLENB/2)){1'b0}}} +: `VLENB/2]};
      end
      EEW32: begin
        v0_data_in_use = {{(`VLENB*3/4){1'b0}}, v0_data[{uop_index,{($clog2(`VLENB/4)){1'b0}}} +: `VLENB/4]};
      end
    endcase
  end 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_VMERGE
      always_comb begin
        result_data_vmerge[j*`WORD_WIDTH +: `WORD_WIDTH] = 'b0;
        
        case(vs2_eew)
          EEW8: begin
            result_data_vmerge[(4*j  )*`BYTE_WIDTH +: `BYTE_WIDTH] = v0_data_in_use[4*j] ?
                                                                     src1_data[(4*j  )*`BYTE_WIDTH +: `BYTE_WIDTH] :
                                                                     src2_data[(4*j  )*`BYTE_WIDTH +: `BYTE_WIDTH] ;
            result_data_vmerge[(4*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH] = v0_data_in_use[4*j+1] ?
                                                                     src1_data[(4*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH] :
                                                                     src2_data[(4*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH] ;
            result_data_vmerge[(4*j+2)*`BYTE_WIDTH +: `BYTE_WIDTH] = v0_data_in_use[4*j+2] ?
                                                                     src1_data[(4*j+2)*`BYTE_WIDTH +: `BYTE_WIDTH] :
                                                                     src2_data[(4*j+2)*`BYTE_WIDTH +: `BYTE_WIDTH] ;
            result_data_vmerge[(4*j+3)*`BYTE_WIDTH +: `BYTE_WIDTH] = v0_data_in_use[4*j+3] ?
                                                                     src1_data[(4*j+3)*`BYTE_WIDTH +: `BYTE_WIDTH] :
                                                                     src2_data[(4*j+3)*`BYTE_WIDTH +: `BYTE_WIDTH] ;
          end
          EEW16: begin
            result_data_vmerge[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] = v0_data_in_use[2*j] ?
                                                                     src1_data[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] :
                                                                     src2_data[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] ;
            result_data_vmerge[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = v0_data_in_use[2*j+1] ?
                                                                     src1_data[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] :
                                                                     src2_data[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] ;
          end
          EEW32: begin
            result_data_vmerge[j*`WORD_WIDTH +: `WORD_WIDTH] = v0_data_in_use[j] ?
                                                               src1_data[j*`WORD_WIDTH +: `WORD_WIDTH] :
                                                               src2_data[j*`WORD_WIDTH +: `WORD_WIDTH] ;
          end
        endcase
      end
    end
  endgenerate

  // get results
  always_comb begin
    // initial the data
    result_data = 'b0; 

    case(uop_funct3) 
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VMERGE_VMV: begin
            if(vm==1'b0)
              result_data = result_data_vmerge;
            else
              result_data = src1_data;
          end
          VSMUL_VMVNRR: begin
            result_data = src2_data;
          end
        endcase
      end
      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VXUNARY0: begin
            result_data = result_data_extend;
          end
          VWXUNARY0: begin
            result_data = src2_data;
          end
        endcase
      end
      OPMVX: begin
        case(uop_funct6.ari_funct6)
          VWXUNARY0: begin
            result_data = src1_data;
          end
        endcase
      end
    endcase
  end

//
// submit result to ROB
//
`ifdef TB_SUPPORT
  assign result.uop_pc = alu_uop.uop_pc;
`endif

  assign result.rob_entry = rob_entry;

  assign result.w_data = result_data;

  assign result.w_valid = result_valid;

  assign result.vsaturate = 'b0;

endmodule
