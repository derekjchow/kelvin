
`include "rvv_backend.svh"

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
  logic   [`VSTART_WIDTH-1:0]         vstart;
  logic   [`VLEN-1:0]                 vd_data;           
  logic                               vd_data_valid;
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
  logic   [`VLEN-1:0]                                 src2_data;
  logic   [`VLENB-1:0][`BYTE_WIDTH:0]                 src2_minmax8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH:0]    src2_minmax16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH:0]      src2_minmax32;
  logic   [`VLEN-1:0]                                 src1_data;
  logic   [`VLENB-1:0][`BYTE_WIDTH:0]                 src1_minmax8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH:0]    src1_minmax16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH:0]      src1_minmax32;
  logic                                               result_valid;
  logic   [`VLEN-1:0]                                 result_data;
  logic   [`VLENB-1:0][`BYTE_WIDTH-1:0]               result_data_minmax8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][`HWORD_WIDTH-1:0]  result_data_minmax16;
  logic   [`VLEN/`WORD_WIDTH-1:0][`WORD_WIDTH-1:0]    result_data_minmax32;
  logic   [`VLEN-1:0]                                 result_data_extend;  
  logic   [`VLEN-1:0]             result_data_xor; 
  logic   [`VLEN-1:0]             result_data_orn; 
  logic   [`VLEN-1:0]             result_data_nand;
  logic   [`VLEN-1:0]             result_data_nor; 
  logic   [`VLEN-1:0]             result_data_xnor;
  GET_MIN_MAX_e                                       opcode;

  // PU2ROB_t  struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  logic                           w_valid; 
  logic   [`VCSR_VXSAT_WIDTH-1:0] vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  // for-loop
  integer                         i;
  genvar                          j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry      = alu_uop.rob_entry;
  assign  uop_funct6     = alu_uop.uop_funct6;
  assign  uop_funct3     = alu_uop.uop_funct3;
  assign  vstart         = alu_uop.vstart;
  assign  vm             = alu_uop.vm;
  assign  vd_data        = alu_uop.vd_data;
  assign  vd_data_valid  = alu_uop.vd_data_valid;
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
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_valid = 'b0;
    src2_data    = 'b0;
    src1_data    = 'b0;

    // prepare source data
    case({alu_uop_valid,uop_funct3})
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            if(vs1_data_valid&vs2_data_valid) begin
              result_valid = 1'b1;
              
              src2_data = vs2_data;
              src1_data = vs1_data;
            end

            `ifdef ASSERT_ON
              `rvv_expect(vs1_data_valid==1'b1) 
                else $error("vs1_data_valid(%d) should be 1'b1.\n",vs1_data_valid);

              `rvv_expect(vs2_data_valid==1'b1) 
                else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);
            `endif
          end
        endcase
      end
      {1'b1,OPIVX}: begin
        case(uop_funct6.ari_funct6)
          VMINU,
          VMIN,
          VMAXU,
          VMAX: begin
            if(rs1_data_valid&vs2_data_valid) begin
              result_valid = 1'b1;

              src2_data = vs2_data;
              for (i=0;i<`VLEN/`WORD_WIDTH;i=i+1) begin
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

            `ifdef ASSERT_ON
              `rvv_expect(rs1_data_valid==1'b1) 
                else $error("rs1_data_valid(%d) should be 1'b1.\n",rs1_data_valid);

              `rvv_expect(vs2_data_valid==1'b1) 
                else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);
            `endif
          end
        endcase
      end
      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          VXUNARY0: begin
            case(vs1_opcode) 
              VZEXT_VF2,
              VSEXT_VF2: begin
                if((vs1_data_valid==1'b0)&vs2_data_valid&((vs2_eew==EEW8)|(vs2_eew==EEW16))) begin
                  result_valid = 1'b1;

                  if (uop_index[0]==1'b0)
                    src2_data = {2{vs2_data[`VLEN/2-1 : 0]}};
                  else
                    src2_data = {2{vs2_data[`VLEN-1 : `VLEN/2]}};
                end

                `ifdef ASSERT_ON
                  `rvv_expect(vs1_data_valid==1'b0) 
                    else $error("vs1_data_valid(%d) should be 1'b0.\n",vs1_data_valid);

                  `rvv_expect(vs2_data_valid==1'b1) 
                    else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);

                  `rvv_forbid(vs2_eew==EEW32) 
                    else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
                `endif
              end
              VZEXT_VF4,
              VSEXT_VF4: begin
                if((vs1_data_valid==1'b0)&vs2_data_valid&(vs2_eew==EEW8)) begin
                  result_valid = 1'b1;

                  if (uop_index[1:0]==2'b0)
                    src2_data = {4{vs2_data[0 +: `VLEN/4]}};
                  else if (uop_index[1:0]==2'b01)
                    src2_data = {4{vs2_data[1*`VLEN/4 +: `VLEN/4]}};
                  else if (uop_index[1:0]==2'b10)
                    src2_data = {4{vs2_data[2*`VLEN/4 +: `VLEN/4]}};
                  else
                    src2_data = {4{vs2_data[3*`VLEN/4 +: `VLEN/4]}};
                end

                `ifdef ASSERT_ON
                  `rvv_expect(vs1_data_valid==1'b0) 
                    else $error("vs1_data_valid(%d) should be 1'b0.\n",vs1_data_valid);

                  `rvv_expect(vs2_data_valid==1'b1) 
                    else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);

                  `rvv_expect(vs2_eew==EEW8) 
                    else $error("vs2_eew(%s) is not supported.\n",vs2_eew.name());
                `endif
              end
            endcase
          end
        endcase
      end
    endcase
  end

  // get opcode for f_get_min_max
  always_comb begin
    // initial the data
    opcode = GET_MIN;

    // prepare source data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)    
          VMINU,
          VMIN: begin
            opcode = GET_MIN;
          end
          VMAXU,
          VMAX: begin
            opcode = GET_MAX;
          end
        endcase
      end
    endcase
  end

  // source operand of VMIN/VMAX instructions
  generate
    for (j=0;j<`VLENB;j=j+1) begin: MINMAX8
      always_comb begin
        // initial the data
        src2_minmax8[j] = 'b0; 
        src1_minmax8[j] = 'b0; 
        
        // prepare source data
        case(uop_funct6.ari_funct6)    
          VMINU,
          VMAXU: begin
            src2_minmax8[j] = {1'b0, src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]}; 
            src1_minmax8[j] = {1'b0, src1_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]}; 
          end
          VMIN,
          VMAX: begin
            src2_minmax8[j] = {src2_data[(j+1)*`BYTE_WIDTH-1], src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]}; 
            src1_minmax8[j] = {src1_data[(j+1)*`BYTE_WIDTH-1], src1_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]}; 
          end
        endcase
      end
    end
  endgenerate
  
  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j=j+1) begin: MINMAX16
      always_comb begin
        // initial the data
        src2_minmax16[j] = 'b0; 
        src1_minmax16[j] = 'b0; 
        
        // prepare source data
        case(uop_funct6.ari_funct6)    
          VMINU,
          VMAXU: begin
            src2_minmax16[j] = {1'b0, src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]}; 
            src1_minmax16[j] = {1'b0, src1_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]}; 
          end
          VMIN,
          VMAX: begin
            src2_minmax16[j] = {src2_data[(j+1)*`HWORD_WIDTH-1], src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]}; 
            src1_minmax16[j] = {src1_data[(j+1)*`HWORD_WIDTH-1], src1_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]}; 
          end
        endcase
      end
    end
  endgenerate 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: MINMAX32
      always_comb begin
        // initial the data
        src2_minmax32[j] = 'b0; 
        src1_minmax32[j] = 'b0; 
        
        // prepare source data
        case(uop_funct6.ari_funct6)    
          VMINU,
          VMAXU: begin
            src2_minmax32[j] = {1'b0, src2_data[j*`WORD_WIDTH +: `WORD_WIDTH]}; 
            src1_minmax32[j] = {1'b0, src1_data[j*`WORD_WIDTH +: `WORD_WIDTH]}; 
          end
          VMIN,
          VMAX: begin
            src2_minmax32[j] = {src2_data[(j+1)*`WORD_WIDTH-1], src2_data[j*`WORD_WIDTH +: `WORD_WIDTH]}; 
            src1_minmax32[j] = {src1_data[(j+1)*`WORD_WIDTH-1], src1_data[j*`WORD_WIDTH +: `WORD_WIDTH]}; 
          end
        endcase
      end
    end
  endgenerate 

//    
// calculate the result
//
  // VMIN/VMAX instructions
  generate
    for (j=0;j<`VLENB;j=j+1) begin: EXE_MINMAX8
      assign result_data_minmax8[j] = f_get_min_max8(opcode, src2_minmax8[j], src1_minmax8[j]);
    end
  endgenerate
  
  generate
    for (j=0;j<`VLEN/`HWORD_WIDTH;j=j+1) begin: EXE_MINMAX16
      assign result_data_minmax16[j] = f_get_min_max16(opcode, src2_minmax16[j], src1_minmax16[j]);
    end
  endgenerate 

  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_MINMAX32
      assign result_data_minmax32[j] = f_get_min_max32(opcode, src2_minmax32[j], src1_minmax32[j]);
    end
  endgenerate 
  
  // VXUNARY0
  generate
    for (j=0;j<`VLEN/`WORD_WIDTH;j=j+1) begin: EXE_EXTEND
      always_comb begin
        result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = 'b0;
        
        case(vs1_opcode) 
          VZEXT_VF2: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] = {{`BYTE_WIDTH{1'b0}}, src2_data[(2*j  )*`BYTE_WIDTH +: `BYTE_WIDTH]};
                result_data_extend[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = {{`BYTE_WIDTH{1'b0}}, src2_data[(2*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
              EEW16: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{`HWORD_WIDTH{1'b0}}, src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]};
              end
            endcase
          end
          VSEXT_VF2: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[(2*j  )*`HWORD_WIDTH +: `HWORD_WIDTH] = {{`BYTE_WIDTH{src2_data[(2*j+1)*`BYTE_WIDTH-1]}}, src2_data[(2*j  )*`BYTE_WIDTH +: `BYTE_WIDTH]};
                result_data_extend[(2*j+1)*`HWORD_WIDTH +: `HWORD_WIDTH] = {{`BYTE_WIDTH{src2_data[(2*j+2)*`BYTE_WIDTH-1]}}, src2_data[(2*j+1)*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
              EEW16: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{`BYTE_WIDTH{src2_data[(j+1)*`HWORD_WIDTH-1]}}, src2_data[j*`HWORD_WIDTH +: `HWORD_WIDTH]};
              end
            endcase
          end
          VZEXT_VF4: begin
            case(vs2_eew)
              EEW8: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{(`WORD_WIDTH-`BYTE_WIDTH){1'b0}}, src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
            endcase
          end
          VSEXT_VF4: begin       
            case(vs2_eew)
              EEW8: begin
                result_data_extend[j*`WORD_WIDTH +: `WORD_WIDTH] = {{(`WORD_WIDTH-`BYTE_WIDTH){src2_data[(j+1)*`BYTE_WIDTH-1]}}, src2_data[j*`BYTE_WIDTH +: `BYTE_WIDTH]};
              end
            endcase
          end
        endcase
      end
    end
  endgenerate

  // get results
  always_comb begin
    // initial the data
    result_data = 'b0; 

    for (i=0;i<`VLEN/`WORD_WIDTH;i++) begin
      case(uop_funct3) 
        OPIVV,
        OPIVX,
        OPIVI: begin
          case(uop_funct6.ari_funct6)
            VMINU,
            VMIN,
            VMAXU,
            VMAX: begin
              case(vs2_eew)
                EEW8: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {result_data_minmax8[4*i+3],result_data_minmax8[4*i+2],result_data_minmax8[4*i+1],result_data_minmax8[4*i]};
                end
                EEW16: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = {result_data_minmax16[2*i+1],result_data_minmax16[2*i]};
                end
                EEW32: begin
                  result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_minmax32[i];
                end
              endcase
            end
          endcase
        end
        OPMVV: begin
          case(uop_funct6.ari_funct6)
            VXUNARY0: begin
              result_data = result_data_extend;
            end
          endcase
        end
      endcase
    end
  end

//
// submit result to ROB
//
  assign  result.rob_entry  = rob_entry;
  assign  result.w_data     = w_data;
  assign  result.w_valid    = w_valid;
  assign  result.vxsat      = vxsat;
  assign  result.ignore_vta = ignore_vta;
  assign  result.ignore_vma = ignore_vma;

  // result data
  assign w_data = result_data;

  // result valid signal
  assign w_valid = result_valid;

  // saturate signal
  assign vxsat = 'b0;

  // ignore vta an vma signal
  always_comb begin
    ignore_vta = 'b0;
    ignore_vma = 'b0;
    
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          VMXNOR: begin
            ignore_vta = 'b1;
            ignore_vma = 'b0;
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // use for vminu, vmin, vmaxu, vmax
  function [`BYTE_WIDTH-1:0] f_get_min_max8;
    input GET_MIN_MAX_e                opcode;
    input logic signed [`BYTE_WIDTH:0] src2;
    input logic signed [`BYTE_WIDTH:0] src1;
    
    logic comp_slt = src2<src1;

    if (opcode==GET_MIN) begin
      if (comp_slt)
        f_get_min_max8 = src2[`BYTE_WIDTH-1:0];
      else
        f_get_min_max8 = src1[`BYTE_WIDTH-1:0];
    end
    else if (opcode==GET_MAX) begin
      if (comp_slt)
        f_get_min_max8 = src1[`BYTE_WIDTH-1:0];
      else
        f_get_min_max8 = src2[`BYTE_WIDTH-1:0];
    end
    else
      f_get_min_max8 = 'b0;
  endfunction

  function [`HWORD_WIDTH-1:0] f_get_min_max16;
    input GET_MIN_MAX_e                 opcode;
    input logic signed [`HWORD_WIDTH:0] src2;
    input logic signed [`HWORD_WIDTH:0] src1;
    
    logic comp_slt = src2<src1;

    if (opcode==GET_MIN) begin
      if (comp_slt)
        f_get_min_max16 = src2[`HWORD_WIDTH-1:0];
      else
        f_get_min_max16 = src1[`HWORD_WIDTH-1:0];
    end
    else if (opcode==GET_MAX) begin
      if (comp_slt)
        f_get_min_max16 = src1[`HWORD_WIDTH-1:0];
      else
        f_get_min_max16 = src2[`HWORD_WIDTH-1:0];
    end
    else
      f_get_min_max16 = 'b0;
  endfunction

  function [`WORD_WIDTH-1:0] f_get_min_max32;
    input GET_MIN_MAX_e                opcode;
    input logic signed [`WORD_WIDTH:0] src2;
    input logic signed [`WORD_WIDTH:0] src1;
    
    logic comp_slt = src2<src1;

    if (opcode==GET_MIN) begin
      if (comp_slt)
        f_get_min_max32 = src2[`WORD_WIDTH-1:0];
      else
        f_get_min_max32 = src1[`WORD_WIDTH-1:0];
    end
    else if (opcode==GET_MAX) begin
      if (comp_slt)
        f_get_min_max32 = src1[`WORD_WIDTH-1:0];
      else
        f_get_min_max32 = src2[`WORD_WIDTH-1:0];
    end
    else
      f_get_min_max32 = 'b0;
  endfunction


endmodule
