
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

  // execute 
  // mask logic instructions
  logic   [`VLEN-1:0]             src2_data_mask_logic;
  logic   [`VLEN-1:0]             src1_data_mask_logic;
  logic                           result_valid_mask_logic;
  logic   [`VLEN-1:0]             result_data_mask_logic;

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
  
//  
// prepare source data 
//
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_valid_mask_logic   = 'b0;
    src2_data_mask_logic     = 'b0;
    src1_data_mask_logic     = 'b0;

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
            if(vs1_data_valid&vs2_data_valid&vm&vd_data_valid) begin
              result_valid_mask_logic = 1'b1;
              src2_data_mask_logic    = vs2_data;
              src1_data_mask_logic    = vs1_data;
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
  // for mask logic instructions
  always_comb begin
    // initial the data
    result_data_mask_logic   = 'b0; 
 
    // calculate result data
    case({alu_uop_valid,uop_funct3}) 
      {1'b1,OPMVV}: begin
        case(uop_funct6.ari_funct6)
          
          VMANDN: begin
            result_data_mask_logic   = f_vmandn(src2_data_mask_logic,src1_data_mask_logic);  
          end
          
          VMAND: begin
            result_data_mask_logic   = f_vmand(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMOR: begin
            result_data_mask_logic   = f_vmor(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMXOR: begin
            result_data_mask_logic   = f_vmxor(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMORN: begin
            result_data_mask_logic   = f_vmorn(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMNAND: begin
            result_data_mask_logic   = f_vmnand(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMNOR: begin
            result_data_mask_logic   = f_vmnor(src2_data_mask_logic,src1_data_mask_logic);  
          end
 
          VMXNOR: begin
            result_data_mask_logic   = f_vmxnor(src2_data_mask_logic,src1_data_mask_logic);  
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
  assign result_valid = result_valid_mask_logic;

  // result data
  generate 
    for (j=0;j<`VLEN;j++) begin: GET_W_DATA
      always_comb begin
        // initial
        w_data[j] = 'b0;

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
                if (j<vstart)
                  w_data[j] = vd_data[j];
                else
                  w_data[j] = result_data_mask_logic[j];
              end
            endcase
          end
        endcase
      end   
    end
  endgenerate

  // result valid signal
  always_comb begin
  // initial
    w_valid = 'b0;
    
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
            w_valid = 1'b1;
          end
        endcase
      end
    endcase
  end

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
