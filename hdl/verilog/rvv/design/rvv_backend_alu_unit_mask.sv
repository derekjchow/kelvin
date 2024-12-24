
`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_alu_unit_mask
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
  logic   [`VL_WIDTH-1:0]             vl;       
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
  logic   [`VLEN-1:0]                     src2_data;
  logic   [`VLEN-1:0]                     src2_data_viota;
  logic   [`VLEN-1:0]                     src1_data;
  logic   [`VLEN-1:0]                     tail_data;
  logic   [`VLEN-1:0]                     result_data;
  logic   [`VLEN-1:0]                     result_data_andn;
  logic   [`VLEN-1:0]                     result_data_and; 
  logic   [`VLEN-1:0]                     result_data_or;  
  logic   [`VLEN-1:0]                     result_data_xor; 
  logic   [`VLEN-1:0]                     result_data_orn; 
  logic   [`VLEN-1:0]                     result_data_nand;
  logic   [`VLEN-1:0]                     result_data_nor; 
  logic   [`VLEN-1:0]                     result_data_xnor;
  logic   [`VLEN-1:0]                     result_first1;      // find first 1 from LSB
  logic   [`VLEN-1:0]                     result_data_vmsof;
  logic   [`VLEN-1:0]                     result_data_vmsif;
  logic   [`VLEN-1:0]                     result_data_vmsbf;
  logic   [`VLEN-1:0]                     result_data_vfirst;
  logic   [`VLEN/16-1:0][4:0]             result_data_vcpop;
  logic   [`VLEN-1:0][$clog2(`VLEN)-1:0]  result_data_viota;
  logic   [`VLEN-1:0]                     result_data_vid8;
  logic   [`VLEN-1:0]                     result_data_vid16;
  logic   [`VLEN-1:0]                     result_data_vid32;

  // PU2ROB_t  struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  logic                           w_valid; 
  logic   [`VCSR_VXSAT_WIDTH-1:0] vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  // for-loop
  genvar                          j;

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
      assign tail_data[j] = j<vl;
    end
  endgenerate

  // for mask logic instructions
  always_comb begin
    // initial the data
    result_valid    = 'b0;
    src2_data       = 'b0;
    src2_data_viota = 'b0;
    src1_data       = 'b0;

    // prepare source data
    case({alu_uop_valid,uop_funct3})
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            if(vs1_data_valid&vs2_data_valid) begin
              result_valid = 1'b1;
              
              src2_data = vs2_data;
              src1_data = vs1_data;
            end 

            `ifdef ASSERT_ON
              assert(vs1_data_valid==1'b1) 
                else $error("vs1_data_valid(%d) should be 1'b1.\n",vs1_data_valid);

              assert(vs2_data_valid==1'b1) 
                else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);
            `endif
          end
        endcase
      end
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            if(rs1_data_valid&vs2_data_valid) begin
              result_valid = 1'b1;
              
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

            `ifdef ASSERT_ON
              assert(vs1_data_valid==1'b1) 
                else $error("vs1_data_valid(%d) should be 1'b1.\n",vs1_data_valid);

              assert(vs2_data_valid==1'b1) 
                else $error("vs2_data_valid(%d) should be 1'b1.\n",vs2_data_valid);
            `endif
          end
        endcase
      end
      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            if(vs1_data_valid&vs2_data_valid&vm&vd_data_valid) begin
              result_valid = 1'b1;
              
              src2_data  = vs2_data;
              src1_data  = vs1_data;
            end 

            `ifdef ASSERT_ON
              assert(vs1_data_valid==1'b1) 
                else $error("vs1_data_valid(%d) should be 1.\n",vs1_data_valid);
  
              assert(vs2_data_valid==1'b1) 
                else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);
  
              assert(vd_data_valid==1'b1) 
                else $error("vd_data_valid(%d) should be 1.\n",vd_data_valid);
  
              assert(vm==1'b1) 
                else $error("vm(%d) should be 1.\n",vm);
            `endif
          end
          VWXUNARY0: begin
            case(vs1_opcode)
              VCPOP,
              VFIRST: begin
                if((vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&v0_data_valid))) begin
                  result_valid = 1'b1;
                  
                  if (vm==1'b1)
                    src2_data = vs2_data&tail_data;
                  else
                    src2_data = vs2_data&tail_data&v0_data; 
                end 

                `ifdef ASSERT_ON
                  assert(vs1_data_valid==1'b0) 
                    else $error("vs1_data_valid(%d) should be 0.\n",vs1_data_valid);
  
                  assert(vs2_data_valid==1'b1) 
                    else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);
                `endif
              end
            endcase
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF,
              VMSOF,
              VMSIF: begin
                if((vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&vd_data_valid&v0_data_valid))) begin
                  result_valid = 1'b1;
                  
                  if (vm==1'b1)
                    src2_data = vs2_data&tail_data;
                  else
                    src2_data = vs2_data&tail_data&v0_data; 
                end 

                `ifdef ASSERT_ON
                  assert(vs1_data_valid==1'b0) 
                    else $error("vs1_data_valid(%d) should be 0.\n",vs1_data_valid);
  
                  assert(vs2_data_valid==1'b1) 
                    else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);

                  assert(!((vm==1'b0)&(!vd_data_valid))) 
                    else $error("vd_data_valid(%d) should be 1 when vm=0.\n",vd_data_valid);
                `endif
              end
              VIOTA: begin
                if((vs1_data_valid==1'b0)&vs2_data_valid&((vm==1'b1)||((vm==1'b0)&v0_data_valid))) begin
                  result_valid = 1'b1;
                  
                  if (vm==1'b1)
                    src2_data_viota = vs2_data;
                  else
                    src2_data_viota = vs2_data&v0_data; 
                end 

                `ifdef ASSERT_ON
                  assert(vs1_data_valid==1'b0) 
                    else $error("vs1_data_valid(%d) should be 0.\n",vs1_data_valid);
  
                  assert(vs2_data_valid==1'b1) 
                    else $error("vs2_data_valid(%d) should be 1.\n",vs2_data_valid);
                `endif
              end
              VID: begin
                result_valid = 1'b1;
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
  assign result_data_andn  = f_and (src2_data,src1_data);  
  assign result_data_and   = f_andn(src2_data,src1_data);  
  assign result_data_or    = f_or  (src2_data,src1_data);  
  assign result_data_xor   = f_xor (src2_data,src1_data);  
  assign result_data_orn   = f_orn (src2_data,src1_data);  
  assign result_data_nand  = f_nand(src2_data,src1_data);  
  assign result_data_nor   = f_nor (src2_data,src1_data);  
  assign result_data_xnor  = f_xnor(src2_data,src1_data); 
  assign result_first1     = f_first1(src2_data);
  assign result_data_vmsof = (src2_data==0) ? {`VLEN{1'b1}} : result_first1;
  assign result_data_vmsif = (src2_data==0) ? {`VLEN{1'b1}} : f_vmsif(result_first1);  
  assign result_data_vmsbf = (src2_data==0) ? {`VLEN{1'b1}} : f_vmsbf(result_first1); 
 
  // vfirst
  always_comb begin
    result_data_vfirst = 'b0;
    
    if (src2_data=='b0) 
      result_data_vfirst = {`VLEN{1'b1}};
    else begin
      for(int i=0;i<`VLEN;i++) begin
        if (result_data_vmsof[i]==1'b1)
          result_data_vfirst = i;         // one-hot to 8421BCD. get the index of first 1
      end
    end
  end

  // vcpop
  generate
    for(j=0;j<`VLEN/16;j++) begin: GET_PARTIAL_SUM_VCPOP
      assign result_data_vcpop[j] = (((src2_data[16*j+0] +src2_data[16*j+1] ) + (src2_data[16*j+2] +src2_data[16*j+3] )) +
                                     ((src2_data[16*j+4] +src2_data[16*j+5] ) + (src2_data[16*j+6] +src2_data[16*j+7] ))) + 
                                    (((src2_data[16*j+8] +src2_data[16*j+9] ) + (src2_data[16*j+10]+src2_data[16*j+11])) +
                                     ((src2_data[16*j+12]+src2_data[16*j+13]) + (src2_data[16*j+14]+src2_data[16*j+15])));
    end
  endgenerate

  // viota and vid
  assign result_data_viota[0] = 'b0;
  generate 
    for(j=1;j<`VLEN;j++) begin: GET_VIOTA
      assign result_data_viota[j] = src2_data_viota[j-1] + result_data_viota[j-1]; 
    end
  endgenerate
  
  // vid
  generate
    for(j=0;j<`VLENB;j++) begin: GET_VID8
      assign result_data_vid8[j*`BYTE_WIDTH +: `BYTE_WIDTH] = {uop_index, j[$clog2(`VLENB)-1:0]};
    end
  endgenerate

  generate
    for(j=0;j<`VLEN/`HWORD_WIDTH;j++) begin: GET_VID16
      assign result_data_vid16[j*`HWORD_WIDTH +: `HWORD_WIDTH] = {uop_index, j[$clog2(`VLEN/`HWORD_WIDTH)-1:0]};
    end
  endgenerate

  generate
    for(j=0;j<`VLEN/`WORD_WIDTH;j++) begin: GET_VID32
      assign result_data_vid32[j*`WORD_WIDTH +: `WORD_WIDTH] = {uop_index, j[$clog2(`VLEN/`WORD_WIDTH)-1:0]};
    end
  endgenerate

  // get results
  always_comb begin
    // initial the data
    result_data   = 'b0; 
 
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
              VCPOP: begin
                result_data = 'b0;
                for(int i=0;i<`VLEN/16;i++) begin
                  result_data = result_data + result_data_vcpop[i];
                end
              end
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
                    case(uop_index)
                      3'd0: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[i];
                        end
                      end
                      3'd1: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[1*`VLENB+i];
                        end
                      end
                      3'd2: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[2*`VLENB+i];
                        end
                      end
                      3'd3: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[3*`VLENB+i];
                        end
                      end
                      3'd4: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[4*`VLENB+i];
                        end
                      end
                      3'd5: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[5*`VLENB+i];
                        end
                      end
                      3'd6: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[6*`VLENB+i];
                        end
                      end
                      3'd7: begin
                        for(int i=0; i<`VLENB;i++) begin
                          result_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = result_data_viota[7*`VLENB+i];
                        end
                      end
                    endcase
                  end
                  EEW16: begin
                    case(uop_index)
                      3'd0: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[i];
                        end
                      end
                      3'd1: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[1*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd2: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[2*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd3: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[3*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd4: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[4*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd5: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[5*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd6: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[6*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                      3'd7: begin
                        for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
                          result_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = result_data_viota[7*`VLEN/`HWORD_WIDTH+i];
                        end
                      end
                    endcase
                  end
                  EEW32: begin
                    case(uop_index)
                      3'd0: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[i];
                        end
                      end
                      3'd1: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[1*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd2: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[2*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd3: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[3*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd4: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[4*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd5: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[5*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd6: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[6*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                      3'd7: begin
                        for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
                          result_data[i*`WORD_WIDTH +: `WORD_WIDTH] = result_data_viota[7*`VLEN/`WORD_WIDTH+i];
                        end
                      end
                    endcase
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
  assign  result.rob_entry  = rob_entry;
  assign  result.w_data     = w_data;
  assign  result.w_valid    = w_valid;
  assign  result.vxsat      = vxsat;
  assign  result.ignore_vta = ignore_vta;
  assign  result.ignore_vma = ignore_vma;

  // result data
  generate 
    for (j=0;j<`VLEN;j++) begin: GET_W_DATA
      always_comb begin
        // initial
        w_data[j] = 'b0;

        case(uop_funct3)
          OPIVV,
          OPIVX,
          OPIVI: begin
            case(uop_funct6.ari_funct6)
              VAND,
              VOR,
              VXOR: begin
                w_data[j] = result_data[j];
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
                if (j<vstart)
                  w_data[j] = vd_data[j];
                else
                  w_data[j] = result_data[j];
              end
              VWXUNARY0: begin
                case(vs1_opcode)
                  VCPOP: begin
                    w_data[j] = result_data[j];
                  end
                  VFIRST: begin
                    w_data[j] = result_data[j];
                  end
                endcase
              end
              VMUNARY0: begin
                case(vs1_opcode)
                  VMSBF,
                  VMSOF,
                  VMSIF: begin
                    if (vm==1'b1)
                      w_data[j] = result_data[j];
                    else 
                      w_data[j] = (tail_data[j]==1'b1)&(v0_data[j]==1'b0) ? vd_data[j] : result_data[j]; 
                  end
                  VIOTA,
                  VID: begin
                    w_data[j] = result_data[j];
                  end
                endcase
              end
            endcase
          end
        endcase
      end   
    end
  endgenerate

  // result valid signal
  assign w_valid = result_valid;

  // saturate signal
  assign vxsat = 'b0;

  // ignore vta an vma signal
  always_comb begin
    ignore_vta = 'b0;
    ignore_vma = 'b0;
    
    case(uop_funct3) 
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
            ignore_vta = 'b1;
            ignore_vma = 'b0;
          end
          VMUNARY0: begin
            case(vs1_opcode)
              VMSBF,
              VMSOF,
              VMSIF: begin
                ignore_vta = 'b1;
                ignore_vma = 'b1;
              end
            endcase
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // OPMVV-vmandn function
  function [`VLEN-1:0] f_andn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_andn = vs2_data & (~vs1_data);
  endfunction

  // OPMVV-vmand function 
  function [`VLEN-1:0] f_and;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_and = vs2_data & vs1_data;
  endfunction

  // OPMVV-vmor function 
  function [`VLEN-1:0] f_or;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_or = vs2_data | vs1_data;
  endfunction

  // OPMVV-vmxor function 
  function [`VLEN-1:0] f_xor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_xor = vs2_data ^ vs1_data;
  endfunction

  // OPMVV-vmorn function 
  function [`VLEN-1:0] f_orn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_orn = vs2_data | (~vs1_data);
  endfunction

  // OPMVV-vmnand function
  function [`VLEN-1:0] f_nand;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_nand = ~(vs2_data & vs1_data);
  endfunction

  // OPMVV-vmnor function 
  function [`VLEN-1:0] f_nor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_nor = ~(vs2_data | vs1_data);
  endfunction
  
  // OPMVV-vmxnor function 
  function [`VLEN-1:0] f_xnor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_xnor = ~(vs2_data ^ vs1_data);
  endfunction

  // find first 1 from LSB
  function [`VLEN-1:0] f_first1;
    input logic [`VLEN-1:0] src2;

    f_first1 = (~(src2-1)) & src2;
  endfunction

  // set from [0] to [first_1_index]
  function [`VLEN-1:0] f_vmsif;
    input logic [`VLEN-1:0] src2;

    f_vmsif = (src2-1) & src2;
  endfunction

  // set from [0] to [first_1_index-1]
  function [`VLEN-1:0] f_vmsbf;
    input logic [`VLEN-1:0] src2;

    f_vmsbf = {1'b0, (src2[`VLEN-1:1]-1) & src2[`VLEN-1:1]};
  endfunction

endmodule
