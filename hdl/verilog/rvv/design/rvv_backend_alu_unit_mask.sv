
`include "rvv_backend.svh"

module rvv_backend_alu_unit_mask
(
  alu_uop_valid,
  alu_uop,
  result_valid_ex2rob,
  result_ex2rob
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic                   alu_uop_valid;
  input   ALU_RS_t                alu_uop;

  // ALU send result signals to ROB
  output  logic                   result_valid_ex2rob;
  output  ALU2ROB_t               result_ex2rob;

//
// internal signals
//
  // ALU_RS_t struct signals
  logic   [`ROB_DEPTH_WIDTH-1:0]  rob_entry;
  FUNCT6_u                        uop_funct6
  logic   [`FUNCT3_WIDTH-1:0]     uop_funct3;
  logic   [`VSTART_WIDTH-1:0]     vstart;
  logic   [`VCSR_VXRM-1:0]        vxrm;              
  logic   [`VLENB-1:0]            v0_data;
  logic                           v0_data_valid;
  logic   [`VLEN-1:0]             vd_data;           
  logic                           vd_data_valid;
  logic   [`VLEN-1:0]             vs1_data;           
  EEW_e                           vs1_eew;
  logic                           vs1_data_valid; 
  BYTE_TYPE_t                     vs1_type; 
  logic   [`VLEN-1:0]             vs2_data;	        
  EEW_e                           vs2_eew;
  logic                           vs2_data_valid;  
  BYTE_TYPE_t                     vs2_type; 
  logic   [`XLEN-1:0] 	          rs1_data;        
  EEW_e                           scalar_eew;
  logic        	                  rs1_data_valid;
  logic   [`UOP_INDEX_WIDTH-1:0]  uop_index;          

  // execute 
  // mask logic instructions
  logic   [`VLEN-1:0]             src2_vdata_mask_logic;
  logic   [`VLEN-1:0]             src1_vdata_mask_logic;
  logic                           result_valid_mask_logic;
  logic   [`VLEN-1:0]             result_vdata_mask_logic;

  // ALU2ROB_t struct signals
  logic   [`VLEN-1:0]             w_data;             // when w_type=XRF, w_data[`XLEN-1:0] will store the scalar result
  W_DATA_TYPE_t                   w_type;
  logic                           w_valid; 
  logic   [`VCSR_VXSAT-1:0]       vxsat;     
  logic                           ignore_vta;
  logic                           ignore_vma;
  
  //
  integer                         i;

//
// prepare source data to calculate    
//
  // split ALU_RS_t struct
  assign  rob_entry           = alu_uop.rob_entry;
  assign  uop_funct6          = alu_uop.uop_funct6;
  assign  uop_funct3          = alu_uop.uop_funct3;
  assign  vstart              = alu_uop.vstart;
  assign  vm                  = alu_uop.vm;
  assign  vxrm                = alu_uop.vxrm;
  assign  v0_data             = alu_uop.v0_data;
  assign  v0_data_valid       = alu_uop.v0_data_valid;
  assign  vd_data             = alu_uop.vd_data;
  assign  vd_data_valid       = alu_uop.vd_data_valid;
  assign  vs1                 = alu_uop.vs1;
  assign  vs1_data            = alu_uop.vs1_data;
  assign  vs1_eew             = alu_uop.vs1_eew;
  assign  vs1_data_valid      = alu_uop.vs1_data_valid;
  assign  vs1_type            = alu_uop.vs1_type;
  assign  vs2_data            = alu_uop.vs2_data;
  assign  vs2_eew             = alu_uop.vs2_eew;
  assign  vs2_data_valid      = alu_uop.vs2_data_valid;
  assign  vs2_type            = alu_uop.vs2_type;
  assign  rs1_data            = alu_uop.rs1_data;
  assign  rs1_data_valid      = alu_uop.rs1_data_valid;
  assign  scalar_eew          = alu_uop.scalar_eew;
  assign  uop_index           = alu_uop.uop_index;
  
//  
// prepare source data 
//
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_valid_mask_logic   = 'b0;
    src2_vdata_mask_logic     = 'b0;
    src1_vdata_mask_logic     = 'b0;

    // prepare source data
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
            if((vs1_data_valid&vs2_data_valid&vm&vd_data_valid)==1'b1) begin
              result_valid_vmask_logic  = 1'b1;
              src2_vdata_mask_logic     = vs2_data;
              src1_vdata_vmask_logic    = vs1_data;
            end 

            `ifdef ASSERT_ON
            `rvv_expect((vs1_data_valid&vs2_data_valid&vm&vd_data_valid)==1'b1) 
              else $error("rob_entry=%d. vs1_data_valid(%d)&vs2_data_valid(%d)&vm(%d)&vd_data_valid(%d) should be 1'b1.\n",rob_entry,vs1_data_valid,vs2_data_valid,vm,vd_data_valid);
            `endif
          end
        endcase
      end
    endcase
  end

//    
// calculate the result
//
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_vdata_mask_logic   = 'b0; 
 
    // calculate result data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          
          VMANDN: begin
            result_vdata_mask_logic   = f_vmandn(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
          
          VMAND: begin
            result_vdata_mask_logic   = f_vmand(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMOR: begin
            result_vdata_mask_logic   = f_vmor(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMXOR: begin
            result_vdata_mask_logic   = f_vmxor(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMORN: begin
            result_vdata_mask_logic   = f_vmorn(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMNAND: begin
            result_vdata_mask_logic   = f_vmnand(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMNOR: begin
            result_vdata_mask_logic   = f_vmnor(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
 
          VMXNOR: begin
            result_vdata_mask_logic   = f_vmxnor(src2_vdata_mask_logic,src1_vdata_maska_logic);  
          end
        endcase
      end
    endcase
  end

//
// submit result to ROB
//
  assign  result_ex2rob.rob_entry      = rob_entry;
  assign  result_ex2rob.w_data         = w_data;
  assign  result_ex2rob.w_type         = w_type;
  assign  result_ex2rob.w_valid        = w_valid;
  assign  result_ex2rob.vxsat          = vxsat;
  assign  result_ex2rob.ignore_vta     = ignore_vta;
  assign  result_ex2rob.ignore_vma     = ignore_vma;

  // valid signal
  always_comb begin
  // initial
    result_valid_ex2rob   = 'b0;
  
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
            result_valid_ex2rob   = result_valid_mask_logic;
          end
        endcase
      end
    endcase
  end

  // result data 
  always_comb begin
  // initial
    w_data                = 'b0;

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
            for (i=0;i<`VLEN;i=i+1) begin: EXE_MASK_LOGIC
              if (i<vstart)
                w_data[i]         = vd_data[i];
              else
                w_data[i]         = result_vdata_mask_logic[i];
            end
          end

        endcase
      end
    endcase
  end

  // result type and valid signal
  always_comb begin
  // initial
    w_tpye                = 'b0;
    w_valid               = 'b0;
    
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
            w_type                = VRF;
            w_valid               = 1'b1;
          end
        endcase
      end
    endcase
  end

  // saturate signal
  always_comb begin
    vxsat                 = 'b0;
  end

  // ignore vta an vma signal
  always_comb begin
    ignore_vta            = 'b0;
    ignore_vta            = 'b0;
    
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
            ignore_vta            = 1'b1;
            ignore_vma            = 1'b0;
          end
        endcase
      end
    endcase
  end

//
// function unit
//
  // OPMVV-vmandn function
  function [`VLEN-1:0] f_vmandn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmandn = vs2_data & (~vs1_data);
  endfunction

  // OPMVV-vmand function 
  function [`VLEN-1:0] f_vmand;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmand = vs2_data & vs1_data;
  endfunction

  // OPMVV-vmor function 
  function [`VLEN-1:0] f_vmor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmor = vs2_data | vs1_data;
  endfunction

  // OPMVV-vmxor function 
  function [`VLEN-1:0] f_vmxor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmxor = vs2_data ^ vs1_data;
  endfunction

  // OPMVV-vmorn function 
  function [`VLEN-1:0] f_vmorn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmorn = vs2_data | (~vs1_data);
  endfunction

  // OPMVV-vmnand function
  function [`VLEN-1:0] f_vmnand;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmnand = ~(vs2_data & vs1_data);
  endfunction

  // OPMVV-vmnor function 
  function [`VLEN-1:0] f_vmnor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmnor = ~(vs2_data | vs1_data);
  endfunction
  
  // OPMVV-vmxnor function 
  function [`VLEN-1:0] f_vmxnor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmxnor = ~(vs2_data ^ vs1_data);
  endfunction



endmodule
