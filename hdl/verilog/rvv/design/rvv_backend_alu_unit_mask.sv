
`include "rvv_backend.svh"

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
  output  ALU2ROB_t               result;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]  rob_entry;
  FUNCT6_u                        uop_funct6;
  logic   [`FUNCT3_WIDTH-1:0]     uop_funct3;
  logic   [`VSTART_WIDTH-1:0]     vstart;
  logic   [`VLEN-1:0]             vd_data;           
  logic                           vd_data_valid;
  logic   [`VLEN-1:0]             vs1_data;           
  logic                           vs1_data_valid; 
  logic   [`VLEN-1:0]             vs2_data;	        
  logic                           vs2_data_valid;  
  EEW_e                           vs2_eew;
  logic   [`XLEN-1:0] 	          rs1_data;        
  logic        	                  rs1_data_valid;

  // execute 
  // mask logic instructions
  logic   [`VLEN-1:0]             src2_data;
  logic   [`VLEN-1:0]             src1_data;
  logic                           result_valid_mask;
  logic   [`VLEN-1:0]             result_data;
  logic   [`VLEN-1:0]             result_data_andn;
  logic   [`VLEN-1:0]             result_data_and; 
  logic   [`VLEN-1:0]             result_data_or;  
  logic   [`VLEN-1:0]             result_data_xor; 
  logic   [`VLEN-1:0]             result_data_orn; 
  logic   [`VLEN-1:0]             result_data_nand;
  logic   [`VLEN-1:0]             result_data_nor; 
  logic   [`VLEN-1:0]             result_data_xnor;

  // ALU2ROB_t struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  logic                           w_valid; 
  logic   [`VCSR_VXSAT_WIDTH-1:0] vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  //
  integer                         i;
  genvar                          j;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry           = alu_uop.rob_entry;
  assign  uop_funct6          = alu_uop.uop_funct6;
  assign  uop_funct3          = alu_uop.uop_funct3;
  assign  vstart              = alu_uop.vstart;
  assign  vm                  = alu_uop.vm;
  assign  vd_data             = alu_uop.vd_data;
  assign  vd_data_valid       = alu_uop.vd_data_valid;
  assign  vs1_data            = alu_uop.vs1_data;
  assign  vs1_data_valid      = alu_uop.vs1_data_valid;
  assign  vs2_data            = alu_uop.vs2_data;
  assign  vs2_data_valid      = alu_uop.vs2_data_valid;
  assign  vs2_eew             = alu_uop.vs2_eew;
  assign  rs1_data            = alu_uop.rs1_data;
  assign  rs1_data_valid      = alu_uop.rs1_data_valid;
  
//  
// prepare source data 
//
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_valid_mask = 'b0;
    src2_data         = 'b0;
    src1_data         = 'b0;

    // prepare source data
    case({alu_uop_valid,uop_funct3})
      {1'b1,OPIVV}: begin
        case(uop_funct6.ari_funct6)
          VAND,
          VOR,
          VXOR: begin
            if(vs1_data_valid&vs2_data_valid) begin
              result_valid_mask = 1'b1;
              
              src2_data = vs2_data;
              src1_data = vs1_data;
            end 

            `ifdef ASSERT_ON
            `rvv_expect(vs1_data_valid==1'b1) 
              else $error("rob_entry=%d. vs1_data_valid(%d) should be 1'b1.\n",rob_entry,vs1_data_valid);

            `rvv_expect(vs2_data_valid==1'b1) 
              else $error("rob_entry=%d. vs2_data_valid(%d) should be 1'b1.\n",rob_entry,vs2_data_valid);
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
              result_valid_mask = 1'b1;
              
              src2_data = vs2_data;
              
              for (i=0;i<`VLEN/`WORD_WIDTH;i++) begin
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
            `rvv_expect(vs1_data_valid==1'b1) 
              else $error("rob_entry=%d. vs1_data_valid(%d) should be 1'b1.\n",rob_entry,vs1_data_valid);

            `rvv_expect(vs2_data_valid==1'b1) 
              else $error("rob_entry=%d. vs2_data_valid(%d) should be 1'b1.\n",rob_entry,vs2_data_valid);
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
              result_valid_mask = 1'b1;
              
              src2_data  = vs2_data;
              src1_data  = vs1_data;
            end 

            `ifdef ASSERT_ON
            `rvv_expect(vs1_data_valid==1'b1) 
              else $error("rob_entry=%d. vs1_data_valid(%d) should be 1'b1.\n",rob_entry,vs1_data_valid);

            `rvv_expect(vs2_data_valid==1'b1) 
              else $error("rob_entry=%d. vs2_data_valid(%d) should be 1'b1.\n",rob_entry,vs2_data_valid);

            `rvv_expect(vd_data_valid==1'b1) 
              else $error("rob_entry=%d. vd_data_valid(%d) should be 1'b1.\n",rob_entry,vd_data_valid);

            `rvv_expect(vm==1'b1) 
              else $error("rob_entry=%d. vm(%d) should be 1'b1.\n",rob_entry,vm);
            `endif
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  assign result_data_andn = f_and (src2_data,src1_data);  
  assign result_data_and  = f_andn(src2_data,src1_data);  
  assign result_data_or   = f_or  (src2_data,src1_data);  
  assign result_data_xor  = f_xor (src2_data,src1_data);  
  assign result_data_orn  = f_orn (src2_data,src1_data);  
  assign result_data_nand = f_nand(src2_data,src1_data);  
  assign result_data_nor  = f_nor (src2_data,src1_data);  
  assign result_data_xnor = f_xnor(src2_data,src1_data);  

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
            result_data   = result_data_andn;
          end
          VMAND: begin
            result_data   = result_data_and; 
          end
          VMOR: begin
            result_data   = result_data_or; 
          end
          VMXOR: begin
            result_data   = result_data_xor; 
          end
          VMORN: begin
            result_data   = result_data_orn; 
          end
          VMNAND: begin
            result_data   = result_data_nand; 
          end
          VMNOR: begin
            result_data   = result_data_nor; 
          end
          VMXNOR: begin
            result_data   = result_data_xnor; 
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

  // valid signal
  assign result_valid = result_valid_mask;

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
            endcase
          end
        endcase
      end   
    end
  endgenerate

  // result valid signal
  assign w_valid = result_valid_mask;

  // saturate signal
  assign vxsat = 'b0;

  // ignore vta an vma signal
  always_comb begin
    ignore_vta = 'b0;
    ignore_vma = 'b0;
    
    case({alu_uop_valid,uop_funct3}) 
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



endmodule
