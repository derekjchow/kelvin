/*
description: 
1. It will get uops from ALU Reservation station and execute this uop.

feature list:
1. All alu uop is executed and submit to ROB in 1 cycle.
2. Reuse arithmetic logic as much as possible.
3. Low-power design.
*/

`include 'rvv.svh'

module rvv_alu_unit
(
    clk,
    rstn,
    
    alu_uop_valid,
    alu_uop,
    result_alu2rob_valid,
    result_alu2rob
);
//
// interface signals
//
    // global signals
    input   logic                   clk;
    input   logic                   rstn;

    // ALU RS handshake signals
    input   logic                   alu_uop_valid;
    input   ALU_RS_t                alu_uop;

    // ALU send result signals to ROB
    output  logic                   result_alu2rob_valid;
    output  ALU2ROB_t               result_alu2rob;

//
// internal signals
//
    // ALU_RS_t struct signals
    logic   [`ROB_DEPTH_WIDTH-1:0]  rob_entry;
    FUNCT_u                         uop_funct;
    EXE_OPCODE_e                    uop_opcode;
    logic   [`VSTART_WIDTH-1:0]     vstart;
    logic                           vm;       
    logic   [`VCSR_VXRM-1:0]        vxrm;              
    logic   [`VLENB-1:0]            v0_data;           
    logic   [`VLEN-1:0]             vd_data;           
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
    logic                           ignore_vta_vma;
    
    //
    integer                         i;
//
// execute uop
//
    // split ALU_RS_t struct
    assign  rob_entry       = alu_uop.rob_entry;
    assign  uop_funct       = alu_uop.uop_funct;
    assign  uop_opcode      = alu_uop.uop_opcode;
    assign  vstart          = alu_uop.vstart;
    assign  vm              = alu_uop.vm;
    assign  vxrm            = alu_uop.vxrm;
    assign  v0_data         = alu_uop.vs3_data.v0_data;
    assign  vd_data         = alu_uop.vs3_data.vd_data;
    assign  vs1             = alu_uop.vs1;
    assign  vs1_data        = alu_uop.vs1_data;
    assign  vs1_eew         = alu_uop.vs1_eew;
    assign  vs1_data_valid  = alu_uop.vs1_data_valid;
    assign  vs1_type        = alu_uop.vs1_type;
    assign  vs2_data        = alu_uop.vs2_data;
    assign  vs2_eew         = alu_uop.vs2_eew;
    assign  vs2_data_valid  = alu_uop.vs2_data_valid;
    assign  vs2_type        = alu_uop.vs2_type;
    assign  rs1_data        = alu_uop.rs1_data;
    assign  rs1_data_valid  = alu_uop.rs1_data_valid;
    
    // prepare source data to calculate    
    always_comb begin
      // initial the data
      src2_vdata_mask_logic     = 'b0;
      src1_vdata_mask_logic     = 'b0;
      result_valid_mask_logic   = 'b0;

      // prepare source data
      case({alu_uop_valid,uop_opcode}) 
        
        {1'b1,OPIVV},
        {1'b1,OPIVX},
        {1'b1,OPIVI}: begin
          case(uop_funct.opi_funct)
            
            default: begin
              `ifdef ASSERT_ON
              // ("unsupported uop_funct.opi_funct. uop_opcode=%s, uop_funct=%s, rob_entry=%d.\n",uop_opcode,uop_funct.opi_funct,rob_entry);
              `endif
            end
          endcase
        end

        {1'b1,OPMVV}, 
        {1'b1,OPMVX}: begin
          case(uop_funct.opm_funct)
              
            VMANDN: begin
              if((vs1_data_valid&vs2_data_valid)&(vm==1'b1)) begin
                src2_vdata_mask_logic     = vs2_data;
                src1_vdata_vmask_logic    = vs1_data;
                result_valid_vmask_logic  = 1'b1;
              end else begin
                src2_vdata_mask_logic     = 'b0;
                src1_vdata_mask_logic     = 'b0;
                result_valid_mask_logic   = 'b0;
                `ifdef ASSERT_ON
                // assertion("%s uop: rob_entry=%d, vs1_data_valid(should be 1)=%d, vs2_data_valid(should be 1)=%d, vm(should be 1)=%d.\n",uop_funct.opm_funct,rob_entry,vs1_data_valid,vs2_data_valid,vm);
                `endif
              end
            end

            default: begin
            `ifdef ASSERT_ON
            // ("unsupported uop_funct.opi_funct. uop_opcode=%s, uop_funct=%s, rob_entry=%d.\n",uop_opcode,uop_funct.opm_funct,rob_entry);
            `endif
            end
          endcase
        end
        
        default: begin
          `ifdef ASSERT_ON
          // when alu_uop_valid=1, ("unsupported uop_opcode. uop_opcode=%s, rob_entry=%d.\n",uop_opcode,rob_entry);
          `endif
        end
      endcase
    end
    
    // calculate the result
    always_comb begin
      // initial the data
      result_vdata_mask_logic   = 'b0; 

      // calculate result data
      case({alu_uop_valid,uop_opcode}) 
        
        {1'b1,OPIVV},
        {1'b1,OPIVX},
        {1'b1,OPIVI}: begin
          case(uop_funct.opi_funct)
            
          endcase
        end

        {1'b1,OPMVV}, 
        {1'b1,OPMVX}: begin
          case(uop_funct.opm_funct)
            
            VMANDN: begin
              result_vdata_mask_logic   = f_vmandn(src2_vdata_mask_logic,src1_vdata_maska_logic);  
            end

          endcase
        end

      endcase
    end

//
// submit resutl to ROB
//
    // assign ALU2ROB_t struct signals
    assign  result_alu2rob.rob_entry      = rob_entry;
    assign  result_alu2rob.w_data         = w_data;
    assign  result_alu2rob.w_type         = w_type;
    assign  result_alu2rob.w_valid        = w_valid;
    assign  result_alu2rob.vxsat          = vxsat;
    assign  result_alu2rob.ignore_vta_vma = ignore_vta_vma;

    // combine the signals to result_alu2rob struct and submit
    always_comb begin
    // initial
      result_alu2rob_valid  = 'b0;
      w_data                = 'b0;
      w_tpye                = 'b0;
      w_valid               = 'b0;
      vxsat                 = 'b0;
      ignore_vta_vma        = 'b0;
    // submit
      case({alu_uop_valid,uop_opcode}) 
       
        {1'b1,OPIVV},
        {1'b1,OPIVX},
        {1'b1,OPIVI}: begin
          case(uop_funct.opi_funct)
            
          endcase
        end

        {1'b1,OPMVV}, 
        {1'b1,OPMVX}: begin
          case(uop_funct.opm_funct)
            
            VMANDN: begin
              for (i=0;i<`VLEN;i=i+1) 
              begin
                if (i<vstart)
                  w_data[i]         = vd_data[i];
                else
                  w_data[i]         = result_vdata_mask_logic[i];
              end
              result_alu2rob_valid  = result_valid_mask_logic;
              w_type                = VRF;
              w_valid               = 1'b1;
              vxsat                 = 1'b0;
              ignore_vta_vma        = 1'b1;
            end

          endcase
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



endmodule
