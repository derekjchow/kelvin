
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_alu_unit_mask
(
  alu_uop_valid,
  alu_uop,
  result_valid,
  result,
  result_2cycle
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic           alu_uop_valid;
  input   ALU_RS_t        alu_uop;

  // ALU send result signals to ROB
  output  logic           result_valid;
  output  PIPE_DATA_t     result;
  output  logic           result_2cycle;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]      rob_entry;
  FUNCT6_u                            uop_funct6;
  logic   [`FUNCT3_WIDTH-1:0]         uop_funct3;
  logic   [`VSTART_WIDTH-1:0]         vstart;
  logic   [`VLEN-1:0]                 vstart_onehot;
  logic   [`VLEN-1:0]                 vstart_onehot_sub1;
  logic   [`VL_WIDTH-1:0]             vl;       
  logic                               vm;
  logic   [`VLEN-1:0]                 v0_data;           
  logic                               v0_data_valid;
  logic   [`VLEN-1:0]                 vd_data;           
  logic                               vd_data_valid;
  EEW_e                               vd_eew;
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
  logic   [`VLEN-1:0]                 src2_data;
  logic   [`VLEN-1:0]                 src2_data_sub1;
  logic   [`VLEN-1:0]                 src2_data_viota;
  logic   [`VLEN-1:0]                 src1_data;
  logic   [`VLEN-1:0]                 tail_mask;
  ALU_SUB_OPCODE_e                    alu_sub_opcode; 
  logic   [`VLEN-1:0]                 result_data;
  logic   [`VLEN-1:0]                 result_data_andn;
  logic   [`VLEN-1:0]                 result_data_and; 
  logic   [`VLEN-1:0]                 result_data_or;  
  logic   [`VLEN-1:0]                 result_data_xor; 
  logic   [`VLEN-1:0]                 result_data_orn; 
  logic   [`VLEN-1:0]                 result_data_nand;
  logic   [`VLEN-1:0]                 result_data_nor; 
  logic   [`VLEN-1:0]                 result_data_xnor;
  logic   [`VLEN-1:0]                 result_data_vmsof;
  logic   [`VLEN-1:0]                 result_vmsif;
  logic   [`VLEN-1:0]                 result_data_vmsif;
  logic   [`VLEN-1:0]                 result_data_vmsbf;
  logic   [`VLEN-1:0]                 result_data_vfirst;
  logic   [`VLEN/32-1:0][31:0][$clog2(32):0]        data_viota_per32;
  logic   [`VLEN/64-1:0][63:0][$clog2(64):0]        data_viota_per64;
  logic   [`VLEN-1:0][$clog2(`VLEN):0]              result_data_viota;
  logic   [`VLENB-1:0][$clog2(`VLEN):0]             result_data_viota8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][$clog2(`VLEN):0] result_data_viota16;
  logic   [`VLEN/`WORD_WIDTH-1:0][$clog2(`VLEN):0]  result_data_viota32;
  logic   [`VLEN-1:0]                 result_data_vid8;
  logic   [`VLEN-1:0]                 result_data_vid16;
  logic   [`VLEN-1:0]                 result_data_vid32;

  // for-loop
  genvar                              j;
  genvar                              h;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
  assign  vstart         = alu_uop.vstart;
  assign  vl             = alu_uop.vl;
  assign  vm             = alu_uop.vm;
  assign  v0_data        = alu_uop.v0_data;
  assign  v0_data_valid  = alu_uop.v0_data_valid;
  assign  vd_data        = alu_uop.vd_data;
  assign  vd_data_valid  = alu_uop.vd_data_valid;
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
  // get tail mask
  generate
    for(j=0;j<`VLEN;j++) begin: GET_TAIL
      assign tail_mask[j] = j<vl;
    end
  endgenerate

  // prepare valid signal
  always_comb begin
    // initial the data
    result_valid = 'b0;
    alu_sub_opcode = OP_NONE;
    result_2cycle = 'b0;

    // prepare source data
    case(uop_funct3)
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            result_valid = alu_uop_valid&vs1_data_valid&vs2_data_valid;
            alu_sub_opcode = OP_OTHER;
          end
        endcase
      end
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            result_valid = alu_uop_valid&rs1_data_valid&vs2_data_valid;
            alu_sub_opcode = OP_OTHER;
          end
        endcase
      end
      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            result_valid = alu_uop_valid&vs1_data_valid&vs2_data_valid&vm&vd_data_valid;
            alu_sub_opcode = OP_OTHER;
          end
          VWXUNARY0: begin
            case(vs1_opcode)
              VCPOP: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&v0_data_valid));
                alu_sub_opcode = OP_VCPOP;
                result_2cycle = 1'b1;
              end
              VFIRST: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&v0_data_valid));
                alu_sub_opcode = OP_OTHER;
              end
            endcase
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF,
              VMSOF,
              VMSIF: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&vd_data_valid&v0_data_valid));
                alu_sub_opcode = OP_OTHER;
              end
              VIOTA: begin
                result_valid = alu_uop_valid&(vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&v0_data_valid));
                alu_sub_opcode = OP_VIOTA;
                // it can get the viota result in one cycle whose element index in vd belongs to 0-31.
                // Otherwise, it will get the result in the next cycle.
                case(vd_eew)
                  EEW8   : result_2cycle = uop_index >= (`UOP_INDEX_WIDTH)'(32/(`VLEN/8));
                  EEW16  : result_2cycle = uop_index >= (`UOP_INDEX_WIDTH)'(32/(`VLEN/16));
                  default: result_2cycle = uop_index >= (`UOP_INDEX_WIDTH)'(32/(`VLEN/32));  //EEW32
                endcase
              end
              VID: begin
                result_valid = alu_uop_valid;
                alu_sub_opcode = OP_OTHER;
              end
            endcase
          end
        endcase
      end
    endcase
  end

  // prepare source data
  always_comb begin
    // initial the data
    src2_data       = 'b0;
    src1_data       = 'b0;
    src2_data_viota = 'b0; 

    // prepare source data
    case(uop_funct3)
      OPIVV: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            src2_data = vs2_data;
            src1_data = vs1_data;
          end
        endcase
      end
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            src2_data = vs2_data;
            for(int i=0;i<`VLEN/`WORD_WIDTH;i++) begin
              case(vs2_eew) 
                EEW8: begin
                  src1_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {(`WORD_WIDTH/`BYTE_WIDTH){rs1_data[0 +: `BYTE_WIDTH]}};
                end
                EEW16: begin
                  src1_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {(`WORD_WIDTH/`HWORD_WIDTH){rs1_data[0 +: `HWORD_WIDTH]}};
                end
                EEW32: begin
                  src1_data[i*`WORD_WIDTH +: `WORD_WIDTH] = rs1_data;
                end
              endcase
            end
          end 
        endcase
      end
      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            src2_data  = vs2_data;
            src1_data  = vs1_data;
          end
          VWXUNARY0: begin
            case(vs1_opcode)
              VCPOP: begin
                if (vm==1'b1)
                  src2_data_viota = vs2_data&tail_mask;
                else
                  src2_data_viota = vs2_data&tail_mask&v0_data; 
              end
              VFIRST: begin
                if (vm==1'b1)
                  src2_data = vs2_data&tail_mask;
                else
                  src2_data = vs2_data&tail_mask&v0_data; 
              end
            endcase
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF,
              VMSOF,
              VMSIF: begin
                if (vm==1'b1)
                  src2_data = vs2_data;
                else
                  src2_data = vs2_data&v0_data; 
              end
              VIOTA: begin
                if (vm==1'b1)
                  src2_data_viota = {vs2_data[`VLEN-2:0],1'b0};
                else
                  src2_data_viota = {vs2_data[`VLEN-2:0]&v0_data[`VLEN-2:0],1'b0}; 
              end
              // no source operand for VID
            endcase
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  assign result_data_and   = src2_data & src1_data;  
  assign result_data_andn  = src2_data & (~src1_data);  
  assign result_data_or    = src2_data | src1_data;  
  assign result_data_xor   = src2_data ^ src1_data;  
  assign result_data_orn   = src2_data | (~src1_data);  
  assign result_data_nand  = ~(src2_data & src1_data);  
  assign result_data_nor   = ~(src2_data | src1_data);  
  assign result_data_xnor  = ~(src2_data ^ src1_data); 
  assign src2_data_sub1    = src2_data - 1'b1;
  assign result_data_vmsof = src2_data & (~src2_data_sub1);
  assign result_vmsif      = src2_data ^ src2_data_sub1;
  assign result_data_vmsif = (src2_data==0) ? {`VLEN{1'b1}} : result_vmsif;  
  assign result_data_vmsbf = (src2_data==0) ? {`VLEN{1'b1}} : {1'b0,result_vmsif[`VLEN-1:1]}; 
 
  // vfirst
  always_comb begin
    result_data_vfirst = 'b0;
    
    if (src2_data=='b0) 
      result_data_vfirst = {`VLEN{1'b1}};
    else begin
      for(int i=0;i<`VLEN;i++) begin
        if (result_data_vmsof[i]==1'b1)
          result_data_vfirst = (`VLEN)'(i);         // one-hot to 8421BCD. get the index of first 1
      end
    end
  end

  // viota and vcpop, still need process in next pipeline
  generate
    for(j=0; j<`VLEN/32;j++) begin: GET_VIOTA_PER32
      rvv_backend_alu_unit_mask_viota32
      u_viota32
      (
        .source         (src2_data_viota[32*j +: 32]),
        .result_viota32 (data_viota_per32[j])
      );
    end

    for(j=0; j<`VLENB;j++) begin: GET_VIOTA8
      if ((3)'($clog2(32/`VLENB)) <= 3'd3) // There may be up to 8 uops, so RHS in if-condition is $clog2(8)=3
        assign result_data_viota8[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[$clog2(32/`VLENB)-1:0],j[$clog2(`VLENB)-1:0]}]);
      else
        assign result_data_viota8[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[2:0],j[$clog2(`VLENB)-1:0]}]);
    end

    for(j=0; j<`VLEN/`HWORD_WIDTH;j++) begin: GET_VIOTA16
      if ((3)'($clog2(32/(`VLEN/`HWORD_WIDTH))) <= 3'd3)
        assign result_data_viota16[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[$clog2(32/(`VLEN/`HWORD_WIDTH))-1:0],j[$clog2(`VLEN/`HWORD_WIDTH)-1:0]}]);
      else
        assign result_data_viota16[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[2:0],j[$clog2(`VLEN/`HWORD_WIDTH)-1:0]}]);
    end

    for(j=0; j<`VLEN/`WORD_WIDTH;j++) begin: GET_VIOTA32
      if ((3)'($clog2(32/(`VLEN/`WORD_WIDTH))) <= 3'd3)
        assign result_data_viota32[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[$clog2(32/(`VLEN/`WORD_WIDTH))-1:0],j[$clog2(`VLEN/`WORD_WIDTH)-1:0]}]);
      else
        assign result_data_viota32[j] = ($clog2(`VLEN)+1)'(data_viota_per32[0][{alu_uop.uop_index[2:0],j[$clog2(`VLEN/`WORD_WIDTH)-1:0]}]);
    end

    for(j=0;j<`VLEN/64;j++) begin: GET_VIOTA_PER64_J
      for(h=0;h<32;h++) begin: GET_VIOTA_PER64_H
        assign data_viota_per64[j][h] = {1'b0,data_viota_per32[2*j][h]};
        assign data_viota_per64[j][h+32] = {1'b0,data_viota_per32[2*j+1][h]} + {1'b0,data_viota_per32[2*j][31]};
      end
    end
  endgenerate

  // vid
  generate
    for(j=0;j<`VLENB;j++) begin: GET_VID8
      assign result_data_vid8[j*`BYTE_WIDTH +: `BYTE_WIDTH] = (`BYTE_WIDTH)'({uop_index, j[$clog2(`VLENB)-1:0]});
    end
  endgenerate

  generate
    for(j=0;j<`VLEN/`HWORD_WIDTH;j++) begin: GET_VID16
      assign result_data_vid16[j*`HWORD_WIDTH +: `HWORD_WIDTH] = (`HWORD_WIDTH)'({uop_index, j[$clog2(`VLEN/`HWORD_WIDTH)-1:0]});
    end
  endgenerate

  generate
    for(j=0;j<`VLEN/`WORD_WIDTH;j++) begin: GET_VID32
      assign result_data_vid32[j*`WORD_WIDTH +: `WORD_WIDTH] = (`WORD_WIDTH)'({uop_index, j[$clog2(`VLEN/`WORD_WIDTH)-1:0]});
    end
  endgenerate

  // get result_data
  always_comb begin
    // initial the data
    result_data = 'b0; 
 
    // calculate result data
    case(uop_funct3)
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VAND: begin
            result_data = result_data_and;
          end
          VOR: begin
            result_data = result_data_or;
          end
          VXOR: begin
            result_data = result_data_xor;
          end
        endcase
      end
      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VMANDN: begin
            result_data = result_data_andn;
          end
          VMAND: begin
            result_data = result_data_and; 
          end
          VMOR: begin
            result_data = result_data_or; 
          end
          VMXOR: begin
            result_data = result_data_xor; 
          end
          VMORN: begin
            result_data = result_data_orn; 
          end
          VMNAND: begin
            result_data = result_data_nand; 
          end
          VMNOR: begin
            result_data = result_data_nor; 
          end
          VMXNOR: begin
            result_data = result_data_xnor; 
          end
          VWXUNARY0: begin
            case(vs1_opcode)
              VFIRST: begin
                result_data = result_data_vfirst;
              end
            endcase
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF: begin
                result_data = result_data_vmsbf;
              end
              VMSOF: begin
                result_data = result_data_vmsof;
              end
              VMSIF: begin
                result_data = result_data_vmsif;
              end
              VIOTA: begin
                case(vd_eew)
                  EEW8: begin
                    for(int i=0; i<`VLENB;i++) begin
                      result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = (`BYTE_WIDTH)'(result_data_viota8[i]);
                    end
                  end
                  EEW16: begin
                    for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                      result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = (`HWORD_WIDTH)'(result_data_viota16[i]);
                    end
                  end
                  EEW32: begin
                    for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                      result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = (`WORD_WIDTH)'(result_data_viota32[i]);
                    end
                  end
                endcase
              end
              VID: begin
                case(vd_eew)
                  EEW8: begin
                    result_data = result_data_vid8;
                  end
                  EEW16: begin
                    result_data = result_data_vid16;
                  end
                  EEW32: begin
                    result_data = result_data_vid32;
                  end
                endcase
              end
            endcase
          end
        endcase
      end
    endcase
  end

//
// submit result to ROB
//
  assign vstart_onehot = (`VLEN)'('b1)<<vstart;
  assign vstart_onehot_sub1 = vstart_onehot - 1'b1;

  always_comb begin
    // initial
    `ifdef TB_SUPPORT
    result.uop_pc           = alu_uop.uop_pc;
    `endif
    result.rob_entry        = rob_entry;
    result.vd_eew           = vd_eew;
    result.uop_index        = uop_index;
    result.alu_sub_opcode   = alu_sub_opcode;
    result.data_viota_per64 = data_viota_per64;
    result.vsaturate        = 'b0;
    result.result_data      = 'b0;

    case(uop_funct3)
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            result.result_data = result_data;
          end
        endcase
      end
      OPMVV: begin
        case(uop_funct6.ari_funct6)
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            result.result_data = result_data&(~vstart_onehot_sub1) | vd_data&vstart_onehot_sub1;
          end
          VWXUNARY0: begin
            case(vs1_opcode)
              VFIRST: begin
                result.result_data = result_data;
              end
            endcase
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF,
              VMSOF,
              VMSIF: begin
                if (vm==1'b1)
                  result.result_data = result_data;
                else 
                  result.result_data = result_data&v0_data | vd_data&(~v0_data);
              end
              VIOTA: begin
                result.result_data = result_data;
              end
              VID: begin
                result.result_data = result_data;
              end
            endcase
          end
        endcase
      end
    endcase
  end   

endmodule
