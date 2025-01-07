// description: 
// 1. It will get uops from ALU Reservation station and execute this uop.
//
// feature list:
// 1. All are combinatorial logic.
// 2. All alu uop is executed and submit to ROB in 1 cycle.
// 3. Reuse arithmetic logic as much as possible.
// 4. Low-power design.

`include 'rvv.svh'

module rvv_alu_unit
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
  EXE_FUNCT3_e                    uop_funct3;
  logic   [`VSTART_WIDTH-1:0]     vstart;
  logic                           vm;       
  logic   [`VCSR_VXRM-1:0]        vxrm;              
  logic   [`VLENB-1:0]            v0_data;
  logic                           v0_data_valid;
  logic   [`VLEN-1:0]             vd_data;           
  logic                           vd_data_valid;
  logic   [`VLEN-1:0]             vs1_data;           
  EEW_e                           vs1_eew;
  logic                           vs1_data_valid; 
  ELE_TYPE_t                      vs1_type; 
  logic   [`VLEN-1:0]             vs2_data;	        
  EEW_e                           vs2_eew;
  logic                           vs2_data_valid;  
  ELE_TYPE_t                      vs2_type; 
  logic   [`XLEN-1:0] 	          rs1_data;        
  logic        	                  rs1_data_valid;

  // execute 
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
  
  // prepare source data  
  always_comb begin
    // initial the data
    src2_vdata_mask_logic     = 'b0;
    src1_vdata_mask_logic     = 'b0;
    result_valid_mask_logic   = 'b0;

    // prepare source data
    case({alu_uop_valid,uop_funct3}) 
      
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.opi_funct)
          
          default: begin
            `ifdef ASSERT_ON
            $error("rob_entry=%d. Unsupported uop_funct6.opi_funct=%d.\n",rob_entr,yuop_funct6.opi_funct);
            `endif
          end
        endcase
      end

      {1'b1,OPMVV}, 
      {1'b1,OPMVX}: begin
        case(uop_funct6.opm_funct)
            
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            if((vs1_data_valid&vs2_data_valid&vm&vd_data_valid)==1'b1) begin
              src2_vdata_mask_logic     = vs2_data;
              src1_vdata_vmask_logic    = vs1_data;
              result_valid_vmask_logic  = 1'b1;
            end 

            `ifdef ASSERT_ON
            `rvv_expect((vs1_data_valid&vs2_data_valid&vm&vd_data_valid)==1'b1) 
              else $error("%s uop: rob_entry=%d. vs1_data_valid(%d)&vs2_data_valid(%d)&vm(%d)&vd_data_valid(%d) should be 1'b1.\n",uop_funct6.opm_funct.name(),rob_entry,vs1_data_valid,vs2_data_valid,vm,vd_data_valid);
            `endif
          end

          default: begin
            `ifdef ASSERT_ON
            $error("rob_entry=%d. Unsupported uop_funct6.opm_funct=%d.\n",rob_entry,uop_funct6.opm_funct);
            `endif
          end
        endcase
      end
      
      default: begin
        `ifdef ASSERT_ON
        `rvv_expect(alu_uop_valid==1'b0)
          else $error("rob_entry=%d. Unsupported uop_funct3=%s.\n",rob_entry,uop_funct3.name());
        `endif
      end
    endcase
  end

//    
// calculate the result
//
  always_comb begin
    // initial the data
    result_vdata_mask_logic   = 'b0; 
 
    // calculate result data
    case({alu_uop_valid,uop_funct3}) 
      
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.opi_funct)
          
        endcase
      end
 
      {1'b1,OPMVV}, 
      {1'b1,OPMVX}: begin
        case(uop_funct6.opm_funct)
          
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

      default: begin

      end
    endcase
  end

//
// submit result to ROB
//
  // assign ALU2ROB_t struct signals
  assign  result_ex2rob.rob_entry      = rob_entry;
  assign  result_ex2rob.w_data         = w_data;
  assign  result_ex2rob.w_type         = w_type;
  assign  result_ex2rob.w_valid        = w_valid;
  assign  result_ex2rob.vxsat          = vxsat;
  assign  result_ex2rob.ignore_vta     = ignore_vta;
  assign  result_ex2rob.ignore_vma     = ignore_vma;

  // combine the signals to result_ex2rob struct and submit
  always_comb begin
  // initial
    result_valid_ex2rob   = 'b0;
    w_data                = 'b0;
    w_tpye                = 'b0;
    w_valid               = 'b0;
    vxsat                 = 'b0;
    ignore_vta            = 'b0;
    ignore_vta            = 'b0;
  // submit
    case({alu_uop_valid,uop_funct3}) 
     
      {1'b1,OPIVV},
      {1'b1,OPIVX},
      {1'b1,OPIVI}: begin
        case(uop_funct6.opi_funct)
          
        endcase
      end

      {1'b1,OPMVV}, 
      {1'b1,OPMVX}: begin
        case(uop_funct6.opm_funct)
          
          VMANDN,
          VMAND,
          VMOR,
          VMXOR,
          VMORN,
          VMNAND,
          VMNOR,
          VMXNOR: begin
            for (i=0;i<`VLEN;i=i+1) begin
              if (i<vstart)
                w_data[i]         = vd_data[i];
              else
                w_data[i]         = result_vdata_mask_logic[i];
            end
            result_valid_ex2rob   = result_valid_mask_logic;
            w_type                = VRF;
            w_valid               = 1'b1;
            vxsat                 = 1'b0;
            ignore_vta            = 1'b1;
            ignore_vma            = 1'b1;
          end

        endcase
      end
      
      default: begin

      end
    endcase
  end

//
// function unit
//
  // OPMVV-vmandn function unit
  function [`VLEN-1:0] f_vmandn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmandn = vs2_data & (~vs1_data);
  endfunction

  // OPMVV-vmand function unit
  function [`VLEN-1:0] f_vmand;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmand = vs2_data & vs1_data;
  endfunction

  // OPMVV-vmor function unit
  function [`VLEN-1:0] f_vmor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmor = vs2_data | vs1_data;
  endfunction

  // OPMVV-vmxor function unit
  function [`VLEN-1:0] f_vmxor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmxor = vs2_data ^ vs1_data;
  endfunction

  // OPMVV-vmorn function unit
  function [`VLEN-1:0] f_vmorn;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmorn = vs2_data | (~vs1_data);
  endfunction

  // OPMVV-vmnand function unit
  function [`VLEN-1:0] f_vmnand;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmnand = ~(vs2_data & vs1_data);
  endfunction

  // OPMVV-vmnor function unit
  function [`VLEN-1:0] f_vmnor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmnor = ~(vs2_data | vs1_data);
  endfunction
  
  // OPMVV-vmxnor function unit
  function [`VLEN-1:0] f_vmxnor;
    input logic [`VLEN-1:0] vs2_data;
    input logic [`VLEN-1:0] vs1_data;

    f_vmxnor = ~(vs2_data ^ vs1_data);
  endfunction



endmodule
