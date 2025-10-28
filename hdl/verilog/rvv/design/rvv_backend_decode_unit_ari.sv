`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_decode_unit_ari
(
  inst_valid,
  inst,
  uop_index_remain,
  uop_valid,
  uop
);
//
// interface signals
//
  input   logic                                   inst_valid;
  input   RVVCmd                                  inst;
  input   logic       [`UOP_INDEX_WIDTH-1:0]      uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]           uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]           uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`FUNCT6_WIDTH-1:0]                     inst_funct6;      // inst original encoding[31:26]           
  logic   [`VM_WIDTH-1:0]                         inst_vm;          // inst original encoding[25]      
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_vs2;         // inst original encoding[24:20]
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_vs1;         // inst original encoding[19:15]
  logic   [`IMM_WIDTH-1:0]                        inst_imm;         // inst original encoding[19:15]
  logic   [`FUNCT3_WIDTH-1:0]                     inst_funct3;      // inst original encoding[14:12]
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_vd;          // inst original encoding[11:7]
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_rd;          // inst original encoding[11:7]
  logic   [`NREG_WIDTH-1:0]                       inst_nr;          // inst original encoding[17:15]
  
  // use vs1 as opcode
  logic   [`REGFILE_INDEX_WIDTH-1:0]              vs1_opcode_vwxunary;
  logic   [`REGFILE_INDEX_WIDTH-1:0]              vs1_opcode_vxunary;
  logic   [`REGFILE_INDEX_WIDTH-1:0]              vs1_opcode_vmunary;
  logic   [`REGFILE_INDEX_WIDTH-1:0]              vs2_opcode_vrxunary;
   
  RVVConfigState                                  vector_csr_ari;
  logic   [`VSTART_WIDTH-1:0]                     csr_vstart;
  logic   [`VL_WIDTH-1:0]                         csr_vl;
  logic   [`VL_WIDTH-1:0]                         evl;
  RVVSEW                                          csr_sew;
  RVVLMUL                                         csr_lmul;
  logic   [`XLEN-1:0] 	                          rs1;
  EMUL_e                                          emul_vd;          
  EMUL_e                                          emul_vs2;          
  EMUL_e                                          emul_vs1;          
  EMUL_e                                          emul_max;          
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs2;          
  EEW_e                                           eew_vs1;
  EEW_e                                           eew_max;          
  logic                                           valid_opi;
  logic                                           valid_opm;
  logic                                           inst_encoding_correct;
  logic                                           check_special;
  logic                                           check_vd_overlap_v0;
  logic                                           check_vd_part_overlap_vs2;
  logic                                           check_vd_part_overlap_vs1;
  logic                                           check_vd_overlap_vs2;
  logic                                           check_vd_overlap_vs1;
  logic                                           check_vs2_part_overlap_vd_2_1;
  logic                                           check_vs1_part_overlap_vd_2_1;
  logic                                           check_vs2_part_overlap_vd_4_1;
  logic                                           check_common;
  logic                                           check_vd_align;
  logic                                           check_vs2_align;
  logic                                           check_vs1_align;
  logic                                           check_sew;
  logic                                           check_lmul;
  logic                                           check_evl_not_0;
  logic                                           check_vstart_sle_evl;
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_vstart;         
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_base;         
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH:0]   uop_index_current;   
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_max;         
  
  // enum/union
  FUNCT6_u                                        funct6_ari;

  // result
`ifdef TB_SUPPORT
  logic   [`NUM_DE_UOP-1:0][`PC_WIDTH-1:0]            uop_pc;
`endif
  logic   [`NUM_DE_UOP-1:0][`FUNCT3_WIDTH-1:0]        uop_funct3;
  FUNCT6_u        [`NUM_DE_UOP-1:0]                   uop_funct6;
  EXE_UNIT_e      [`NUM_DE_UOP-1:0]                   uop_exe_unit; 
  UOP_CLASS_e     [`NUM_DE_UOP-1:0]                   uop_class;   
  RVVConfigState  [`NUM_DE_UOP-1:0]                   vector_csr;  
  logic   [`NUM_DE_UOP-1:0][`VL_WIDTH-1:0]            vs_evl;             
  logic   [`NUM_DE_UOP-1:0]                           ignore_vma;
  logic   [`NUM_DE_UOP-1:0]                           ignore_vta;
  logic   [`NUM_DE_UOP-1:0]                           force_vma_agnostic; 
  logic   [`NUM_DE_UOP-1:0]                           force_vta_agnostic; 
  logic   [`NUM_DE_UOP-1:0]                           vm;                 
  logic   [`NUM_DE_UOP-1:0]                           v0_valid;           
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] vd_index;
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0]     vd_offset;
  EEW_e   [`NUM_DE_UOP-1:0]                           vd_eew;  
  logic   [`NUM_DE_UOP-1:0]                           vd_valid;
  logic   [`NUM_DE_UOP-1:0]                           vs3_valid;          
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] vs1;
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0]     vs1_offset;
  EEW_e   [`NUM_DE_UOP-1:0]                           vs1_eew;            
  logic   [`NUM_DE_UOP-1:0]                           vs1_index_valid;
  logic   [`NUM_DE_UOP-1:0]                           vs1_opcode_valid;
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] vs2_index;
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0]     vs2_offset;
  EEW_e   [`NUM_DE_UOP-1:0]                           vs2_eew;
  logic   [`NUM_DE_UOP-1:0]                           vs2_valid;
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_index; 	        
  logic   [`NUM_DE_UOP-1:0]                           rd_index_valid; 
  logic   [`NUM_DE_UOP-1:0][`XLEN-1:0] 	              rs1_data;           
  logic   [`NUM_DE_UOP-1:0]     	                    rs1_data_valid;     
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0]     uop_index;          
  logic   [`NUM_DE_UOP-1:0]                           first_uop_valid;    
  logic   [`NUM_DE_UOP-1:0]                           last_uop_valid;     
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-2:0]     seg_field_index;    

  // use for for-loop 
  genvar                                          j;

//
// decode
//
  assign inst_funct6          = inst.bits[24:19];
  assign inst_vm              = inst.bits[18];
  assign inst_vs2             = inst.bits[17:13];
  assign vs2_opcode_vrxunary  = inst.bits[17:13];
  assign inst_vs1             = inst.bits[12:8];
  assign vs1_opcode_vwxunary  = inst.bits[12:8];
  assign vs1_opcode_vxunary   = inst.bits[12:8];
  assign vs1_opcode_vmunary   = inst.bits[12:8];
  assign inst_imm             = inst.bits[12:8];
  assign inst_funct3          = inst.bits[7:5];
  assign inst_vd              = inst.bits[4:0];
  assign inst_rd              = inst.bits[4:0];
  assign inst_nr              = inst_vs1[`NREG_WIDTH-1:0];
  assign vector_csr_ari       = inst.arch_state;
  assign csr_vstart           = inst.arch_state.vstart;
  assign csr_vl               = inst.arch_state.vl;
  assign csr_sew              = inst.arch_state.sew;
  assign csr_lmul             = inst.arch_state.lmul;
  assign rs1                  = inst.rs1;

  // decode arithmetic instruction funct6
  assign funct6_ari.ari_funct6 = inst_valid ? inst_funct6 : 'b0;

  always_comb begin
    // initial the data
    valid_opi = 'b0;
    valid_opm = 'b0;
    
    case(inst_funct3)
      OPIVV,
      OPIVX,
      OPIVI: begin
        valid_opi = inst_valid;
      end
      OPMVV,
      OPMVX: begin
        valid_opm = inst_valid;
      end
    endcase
  end 

  // get EMUL
  always_comb begin
    // initial
    emul_vd  = EMUL_NONE;
    emul_vs2 = EMUL_NONE;
    emul_vs1 = EMUL_NONE;
    emul_max = EMUL_NONE;
    
    case(inst_funct3)
      OPIVV: begin
        // OPI* instruction
        case(funct6_ari.ari_funct6)
          VADD,
          VADC,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VRGATHER: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSUB,
          VSBC,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // destination vector register is mask register
          VMADC,
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // narrowing instructions
          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP:begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL2;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL4;
                emul_max    = EMUL8;
              end
            endcase 
          end
          
          VMERGE_VMV: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          // widening instructions
          VWREDSUMU,
          VWREDSUM: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL1;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL1;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSLIDEUP_RGATHEREI16: begin        
            // VRGATHEREI16
            case(csr_lmul)
              LMUL1_4: begin
                case(csr_sew)
                  SEW8,
                  SEW16: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_vs1    = EMUL1;
                    emul_max    = EMUL1;
                  end
                endcase
              end
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                case(csr_sew)
                  SEW8: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_vs1    = EMUL2;
                    emul_max    = EMUL2;                  
                  end
                  SEW16,
                  SEW32: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_vs1    = EMUL1;
                    emul_max    = EMUL1;
                  end
                endcase
              end
              LMUL2: begin                  
                case(csr_sew)
                  SEW8: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL2;
                    emul_vs1    = EMUL4;
                    emul_max    = EMUL4;
                  end
                  SEW16: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL2;
                    emul_vs1    = EMUL2;
                    emul_max    = EMUL2;
                  end
                  SEW32: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL2;
                    emul_vs1    = EMUL1;
                    emul_max    = EMUL2;
                  end
                endcase
              end
              LMUL4: begin
                case(csr_sew)
                  SEW8: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL4;
                    emul_vs1    = EMUL8;
                    emul_max    = EMUL8;
                  end
                  SEW16: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL4;
                    emul_vs1    = EMUL4;
                    emul_max    = EMUL4;
                  end
                  SEW32: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL4;
                    emul_vs1    = EMUL2;
                    emul_max    = EMUL4;
                  end
                endcase
              end
              LMUL8: begin
                case(csr_sew)
                  SEW16: begin
                    emul_vd     = EMUL8;
                    emul_vs2    = EMUL8;
                    emul_vs1    = EMUL8;
                    emul_max    = EMUL8;
                  end
                  SEW32: begin
                    emul_vd     = EMUL8;
                    emul_vs2    = EMUL8;
                    emul_vs1    = EMUL4;
                    emul_max    = EMUL8;
                  end
                endcase
              end
            endcase
          end
        endcase
      end
      
      OPIVX: begin
        // OPI* instruction
        case(funct6_ari.ari_funct6)
          VADD,
          VADC,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VRGATHER: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSUB,
          VSBC,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VRSUB,
          VSLIDEDOWN: begin        
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // destination vector register is mask register
          VMADC,
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // narrowing instructions
          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP:begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          VMSGTU,
          VMSGT: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VMERGE_VMV: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          VSLIDEUP_RGATHEREI16: begin        
            // VSLIDEUP 
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
        endcase
      end
      OPIVI: begin
        // OPI* instruction
        case(funct6_ari.ari_funct6)
          VADD,
          VADC,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VRGATHER: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VRSUB,
          VSLIDEDOWN: begin        
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // destination vector register is mask register
          VMADC,
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // narrowing instructions
          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP:begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          VMSGTU,
          VMSGT: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VMERGE_VMV: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                if (inst_vm=='b0)
                  emul_vs2  = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            // vmv<nr>r.v instruction
            case(inst_nr)
              NREG1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              NREG2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              NREG4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              NREG8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          VSLIDEUP_RGATHEREI16: begin        
            // VSLIDEUP 
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
        endcase
      end

      OPMVV: begin
        // OPM* instruction
        case(funct6_ari.ari_funct6)
          // widening instructions: 2SEW = SEW op SEW
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB,
          VWMUL,
          VWMULU,
          VWMULSU,
          VWMACCU,
          VWMACC,
          VWMACCSU: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          // widening instructions: 2SEW = 2SEW op SEW
          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL2;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL4;
                emul_max    = EMUL8;
              end
            endcase
          end

          VXUNARY0: begin
            case(vs1_opcode_vxunary) 
              VZEXT_VF2,
              VSEXT_VF2: begin
                case(csr_lmul)
                  LMUL1_2,
                  LMUL1: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL1;
                  end
                  LMUL2: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL2;
                  end
                  LMUL4: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL2;
                    emul_max    = EMUL4;
                  end
                  LMUL8: begin
                    emul_vd     = EMUL8;
                    emul_vs2    = EMUL4;
                    emul_max    = EMUL8;
                  end
                endcase
              end
              VZEXT_VF4,
              VSEXT_VF4: begin
                case(csr_lmul)
                  LMUL1: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL1;
                  end
                  LMUL2: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL2;
                  end
                  LMUL4: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL4;
                  end
                  LMUL8: begin
                    emul_vd     = EMUL8;
                    emul_vs2    = EMUL2;
                    emul_max    = EMUL8;
                  end
                endcase
              end
            endcase
          end
 
          // SEW = SEW op SEW
          VMUL,
          VMULH,
          VMULHU,
          VMULHSU,
          VDIVU,
          VDIV,
          VREMU,
          VREM,
          VMACC,
          VNMSAC,
          VMADD,
          VNMSUB,
          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
         
          // reduction
          VREDSUM,
          VREDMAXU,
          VREDMAX,
          VREDMINU,
          VREDMIN,
          VREDAND,
          VREDOR,
          VREDXOR: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL1;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL1;
                emul_max    = EMUL8;
              end
            endcase
          end

          // mask 
          VMAND,
          VMNAND,
          VMANDN,
          VMXOR,
          VMOR,
          VMNOR,
          VMORN,
          VMXNOR: begin
            emul_vd     = EMUL1;
            emul_vs2    = EMUL1;
            emul_vs1    = EMUL1;
            emul_max    = EMUL1;
          end

          VWXUNARY0: begin
            case(vs1_opcode_vwxunary)
              VCPOP,
              VFIRST,
              VMV_X_S: begin
                emul_vs2  = EMUL1;
                emul_max  = EMUL1;
              end
            endcase
          end

          VMUNARY0: begin
            case(vs1_opcode_vmunary)
              VMSBF,
              VMSIF,
              VMSOF: begin
                emul_vd         = EMUL1;
                emul_vs2        = EMUL1;
                emul_max        = EMUL1;
              end
              VIOTA: begin
                case(csr_lmul)
                  LMUL1_4,
                  LMUL1_2,
                  LMUL1: begin
                    emul_vd     = EMUL1;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL1;
                  end
                  LMUL2: begin
                    emul_vd     = EMUL2;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL2;
                  end
                  LMUL4: begin
                    emul_vd     = EMUL4;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL4;
                  end
                  LMUL8: begin
                    emul_vd     = EMUL8;
                    emul_vs2    = EMUL1;
                    emul_max    = EMUL8;
                  end
                endcase
              end
              VID: begin
                case(csr_lmul)
                  LMUL1_4,
                  LMUL1_2,
                  LMUL1: begin
                    emul_vd     = EMUL1;
                    emul_max    = EMUL1;
                  end
                  LMUL2: begin
                    emul_vd     = EMUL2;
                    emul_max    = EMUL2;
                  end
                  LMUL4: begin
                    emul_vd     = EMUL4;
                    emul_max    = EMUL4;
                  end
                  LMUL8: begin
                    emul_vd     = EMUL8;
                    emul_max    = EMUL8;
                  end
                endcase
              end
            endcase
          end

          VCOMPRESS: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL1;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL1;
                emul_max    = EMUL8;
              end
            endcase
          end
        endcase
      end
      OPMVX: begin
        // OPM* instruction
        case(funct6_ari.ari_funct6)
          // widening instructions: 2SEW = SEW op SEW
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB,
          VWMUL,
          VWMULU,
          VWMULSU,
          VWMACCU,
          VWMACC,
          VWMACCSU: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL2;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL4;
                emul_max    = EMUL8;
              end
            endcase
          end
          
          // widening instructions: 2SEW = 2SEW op SEW
          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          // SEW = SEW op SEW
          VMUL,
          VMULH,
          VMULHU,
          VMULHSU,
          VDIVU,
          VDIV,
          VREMU,
          VREM,
          VMACC,
          VNMSAC,
          VMADD,
          VNMSUB,
          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end

          VWMACCUS: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL1: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL2: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL2;
                emul_max    = EMUL4;
              end
              LMUL4: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL4;
                emul_max    = EMUL8;
              end
            endcase
          end
         
          // reduction
          VREDSUM,
          VREDMAXU,
          VREDMAX,
          VREDMINU,
          VREDMIN,
          VREDAND,
          VREDOR,
          VREDXOR: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL2;
                emul_vs1    = EMUL1;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL4;
                emul_vs1    = EMUL1;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL8;
                emul_vs1    = EMUL1;
                emul_max    = EMUL8;
              end
            endcase
          end

          VWXUNARY0: begin
            if(vs2_opcode_vrxunary==VMV_S_X) begin
              emul_vd     = EMUL1;
              emul_max    = EMUL1;
            end
          end

          VSLIDE1UP,
          VSLIDE1DOWN: begin
            case(csr_lmul)
              LMUL1_4,
              LMUL1_2,
              LMUL1: begin
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_max    = EMUL1;
              end
              LMUL2: begin
                emul_vd     = EMUL2;
                emul_vs2    = EMUL2;
                emul_max    = EMUL2;
              end
              LMUL4: begin
                emul_vd     = EMUL4;
                emul_vs2    = EMUL4;
                emul_max    = EMUL4;
              end
              LMUL8: begin
                emul_vd     = EMUL8;
                emul_vs2    = EMUL8;
                emul_max    = EMUL8;
              end
            endcase
          end
        endcase
      end
    endcase
  end
  
// get EEW 
  always_comb begin
    // initial
    eew_vd          = EEW_NONE;
    eew_vs2         = EEW_NONE;
    eew_vs1         = EEW_NONE;
    eew_max         = EEW_NONE;

    case(inst_funct3)
      OPIVV,
      OPIVX,
      OPIVI: begin
        // OPI* instruction
        case(funct6_ari.ari_funct6)
          VADD,
          VADC,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VRGATHER: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
          
          VSUB,
          VSBC,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VRSUB,
          VSLIDEDOWN: begin       
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMADC,
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMSGTU,
          VMSGT: begin
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMERGE_VMV: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VWREDSUMU,
          VWREDSUM: begin
            case(inst_funct3)
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
          
          VSLIDEUP_RGATHEREI16: begin
            case(inst_funct3)
              // VRGATHEREI16
              OPIVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              // VSLIDEUP
              OPIVX,
              OPIVI: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
        endcase
      end

      OPMVV,
      OPMVX: begin
        // OPM* instruction
        case(funct6_ari.ari_funct6)
          // widening instructions: 2SEW = SEW op SEW
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB,
          VWMUL,
          VWMULU,
          VWMULSU,
          VWMACCU,
          VWMACC,
          VWMACCSU: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
         
          // widening instructions: 2SEW = 2SEW op SEW
          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          // SEW = extend 1/2SEW or 1/4SEW
          VXUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
                case(vs1_opcode_vxunary) 
                  VZEXT_VF2,
                  VSEXT_VF2: begin
                    case(csr_sew)
                      SEW16: begin
                        eew_vd      = EEW16;
                        eew_vs2     = EEW8;
                        eew_max     = EEW16;
                      end
                      SEW32: begin
                        eew_vd      = EEW32;
                        eew_vs2     = EEW16;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                  VZEXT_VF4,
                  VSEXT_VF4: begin
                    case(csr_sew)
                      SEW32: begin
                        eew_vd      = EEW32;
                        eew_vs2     = EEW8;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                endcase
              end
            endcase
          end

          // SEW = SEW op SEW
          VMUL,
          VMULH,
          VMULHU,
          VMULHSU,
          VDIVU,
          VDIV,
          VREMU,
          VREM,
          VMACC,
          VNMSAC,
          VMADD,
          VNMSUB,
          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
          
          VWMACCUS: begin
            case(inst_funct3)
              OPMVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_max     = EEW16;
                  end
                  SEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          // reduction
          VREDSUM,
          VREDMAXU,
          VREDMAX,
          VREDMINU,
          VREDMIN,
          VREDAND,
          VREDOR,
          VREDXOR: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          // mask 
          VMAND,
          VMNAND,
          VMANDN,
          VMXOR,
          VMOR,
          VMNOR,
          VMORN,
          VMXNOR: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8,
                  SEW16,
                  SEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW1;
                    eew_vs1     = EEW1;
                    eew_max     = EEW1;
                  end
                endcase
              end
            endcase
          end

          VWXUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
                case(vs1_opcode_vwxunary)
                  VCPOP,
                  VFIRST,
                  VMV_X_S: begin
                    case(csr_sew)
                      SEW8: begin
                        eew_vs2     = EEW8;
                        eew_max     = EEW8;
                      end
                      SEW16: begin
                        eew_vs2     = EEW16;
                        eew_max     = EEW16;
                      end
                      SEW32: begin
                        eew_vs2     = EEW32;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                endcase
              end
              OPMVX: begin
                if(vs2_opcode_vrxunary==VMV_S_X) begin
                  case(csr_sew)
                    SEW8: begin
                      eew_vd      = EEW8;
                      eew_max     = EEW8;
                    end
                    SEW16: begin
                      eew_vd      = EEW16;
                      eew_max     = EEW16;
                    end
                    SEW32: begin
                      eew_vd      = EEW32;
                      eew_max     = EEW32;
                    end
                  endcase
                end
              end
            endcase
          end

          VMUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
                case(vs1_opcode_vmunary)
                  VMSBF,
                  VMSIF,
                  VMSOF: begin
                    case(csr_sew)
                      SEW8,
                      SEW16,
                      SEW32: begin
                        eew_vd      = EEW1;
                        eew_vs2     = EEW1;
                        eew_max     = EEW1;
                      end
                    endcase
                  end
                  VIOTA:begin
                    case(csr_sew)
                      SEW8: begin
                        eew_vd      = EEW8;
                        eew_vs2     = EEW1;
                        eew_max     = EEW8;
                      end
                      SEW16: begin
                        eew_vd      = EEW16;
                        eew_vs2     = EEW1;
                        eew_max     = EEW16;
                      end
                      SEW32: begin
                        eew_vd      = EEW32;
                        eew_vs2     = EEW1;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                  VID: begin
                    case(csr_sew)
                      SEW8: begin
                        eew_vd      = EEW8;
                        eew_max     = EEW8;
                      end
                      SEW16: begin
                        eew_vd      = EEW16;
                        eew_max     = EEW16;
                      end
                      SEW32: begin
                        eew_vd      = EEW32;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                endcase
              end
            endcase
          end

          VSLIDE1UP,
          VSLIDE1DOWN: begin
            case(inst_funct3)
              OPMVX: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VCOMPRESS: begin
            case(inst_funct3)
              OPMVV: begin
                case(csr_sew)
                  SEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW1;
                    eew_max     = EEW8;
                  end
                  SEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW1;
                    eew_max     = EEW16;
                  end
                  SEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW1;
                    eew_max     = EEW32;
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
// instruction encoding error check
//
  assign inst_encoding_correct = check_special&check_common;

  // check whether vd overlaps v0 when vm=0
  // check_vd_overlap_v0=1 means check pass (vd does NOT overlap v0)
  assign check_vd_overlap_v0 = (((inst_vm==1'b0)&(inst_vd!='b0)) | (inst_vm==1'b1));

  // check whether vd partially overlaps vs2 with EEW_vd<EEW_vs2
  // check_vd_part_overlap_vs2=1 means that check pass (vd group does NOT overlap vs2 group partially)
  always_comb begin
    check_vd_part_overlap_vs2 = 'b0;          
    
    case(emul_vs2)
      EMUL1: begin
        check_vd_part_overlap_vs2 = 1'b1;          
      end
      EMUL2: begin
        check_vd_part_overlap_vs2 = !((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])));
      end
      EMUL4: begin
        check_vd_part_overlap_vs2 = !((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])));
      end
      EMUL8 : begin
        check_vd_part_overlap_vs2 = !((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])));
      end
    endcase
  end

  // check whether vd partially overlaps vs1 with EEW_vd<EEW_vs1
  // check_vd_part_overlap_vs1=1 means that check pass (vd group does NOT overlap vs1 group partially)
  always_comb begin
    check_vd_part_overlap_vs1     = 'b0;          
    
    case(emul_vs1)
      EMUL1: begin
        check_vd_part_overlap_vs1 = 1'b1;          
      end
      EMUL2: begin
        check_vd_part_overlap_vs1 = !((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])));
      end
      EMUL4: begin
        check_vd_part_overlap_vs1 = !((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])));
      end
      EMUL8 : begin
        check_vd_part_overlap_vs1 = !((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])));
      end
    endcase
  end

  // vd cannot overlap vs2
  // check_vd_overlap_vs2=1 means that check pass (vd group does NOT overlap vs2 group fully)
  always_comb begin
    if((emul_vd==EMUL8)|(emul_vs2==EMUL8)) 
      check_vd_overlap_vs2 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3]);
    else if((emul_vd==EMUL4)|(emul_vs2==EMUL4)) 
      check_vd_overlap_vs2 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2]);
    else if((emul_vd==EMUL2)|(emul_vs2==EMUL2)) 
      check_vd_overlap_vs2 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1]);
    else if((emul_vd==EMUL1)|(emul_vs2==EMUL1)) 
      check_vd_overlap_vs2 = (inst_vd!=inst_vs2);
    else 
      check_vd_overlap_vs2 = 'b0;
  end
  
  // vd cannot overlap vs1
  // check_vd_overlap_vs1=1 means that check pass (vd group does NOT overlap vs1 group fully)
  always_comb begin
    if((emul_vd==EMUL8)|(emul_vs1==EMUL8)) 
      check_vd_overlap_vs1 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3]);
    else if((emul_vd==EMUL4)|(emul_vs1==EMUL4)) 
      check_vd_overlap_vs1 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2]);
    else if((emul_vd==EMUL2)|(emul_vs1==EMUL2)) 
      check_vd_overlap_vs1 = !(inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1]);
    else if((emul_vd==EMUL1)|(emul_vs1==EMUL1)) 
      check_vd_overlap_vs1 = (inst_vd!=inst_vs1);
    else 
      check_vd_overlap_vs1 = 'b0;
  end

  // check whether vs2 group partially overlaps vd group for EEW_vd:EEW_vs2=2:1
  always_comb begin
    check_vs2_part_overlap_vd_2_1 = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL2: begin
        check_vs2_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1));
      end
      EMUL4: begin
        check_vs2_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b10));
      end
      EMUL8: begin
        check_vs2_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b100));
      end
    endcase
  end
  
  // check whether vs1 group partially overlaps vd group for EEW_vd:EEW_vs1=2:1
  always_comb begin
    check_vs1_part_overlap_vd_2_1 = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs1_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL2: begin
        check_vs1_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs1[0]!=1'b1));
      end
      EMUL4: begin
        check_vs1_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs1[1:0]!=2'b10));
      end
      EMUL8: begin
        check_vs1_part_overlap_vd_2_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs1[2:0]!=3'b100));
      end
    endcase
  end

  // check whether vs2 group partially overlaps vd group for EEW_vd:EEW_vs2=4:1
  always_comb begin
    check_vs2_part_overlap_vd_4_1 = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
      EMUL2: begin
        check_vs2_part_overlap_vd_4_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1));
      end
      EMUL4: begin
        check_vs2_part_overlap_vd_4_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b11));
      end
      EMUL8: begin
        check_vs2_part_overlap_vd_4_1 = !((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b110));
      end
    endcase
  end
 
  // start to check special requirements for every instructions
  always_comb begin 
    check_special = 'b0;
    
    case(inst_funct3)
      OPIVV: begin
        case(funct6_ari.ari_funct6)
          VADD,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEDOWN: begin
            check_special = check_vd_overlap_v0;
          end
        
          VSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            check_special = check_vd_overlap_v0;
          end

          VADC: begin
            check_special = (inst_vm==1'b0)&(inst_vd!='b0);
          end

          VMADC: begin
            check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
          end

          VSBC: begin
            check_special = (inst_vm==1'b0)&(inst_vd!='b0);
          end
      
          VMSBC: begin
            check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2;
          end
          
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
          end

          VMSLTU,
          VMSLT: begin
            check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
          end

          VMERGE_VMV: begin
            // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
            check_special = ((inst_vm=='b0)&(inst_vd!='b0)) | ((inst_vm==1'b1)&(inst_vs2=='b0));
          end
               
          VSMUL_VMVNRR: begin
            check_special = check_vd_overlap_v0;
          end

          VWREDSUMU,
          VWREDSUM: begin
            check_special = (csr_vstart=='b0);
          end

          VSLIDEUP_RGATHEREI16: begin
            // VRGATHEREI16
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2&check_vd_overlap_vs1;                
          end
          
          VRGATHER: begin
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2&check_vd_overlap_vs1;
          end
        endcase
      end
      OPIVX: begin
        case(funct6_ari.ari_funct6)
          VADD,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEDOWN: begin
            check_special = check_vd_overlap_v0;
          end
        
          VSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            check_special = check_vd_overlap_v0;
          end

          VRSUB: begin
            check_special = check_vd_overlap_v0;
          end

          VADC: begin
            check_special = (inst_vm==1'b0)&(inst_vd!='b0);
          end

          VMADC: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VSBC: begin
            check_special = (inst_vm==1'b0)&(inst_vd!='b0);
          end
      
          VMSBC: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2;
          end
          
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VMSLTU,
          VMSLT: begin
            check_special = check_vd_part_overlap_vs2;
          end
          
          VMSGTU,
          VMSGT: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VMERGE_VMV: begin
            // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
            check_special = ((inst_vm=='b0)&(inst_vd!='b0)) | ((inst_vm==1'b1)&(inst_vs2=='b0));
          end
               
          VSMUL_VMVNRR: begin
            check_special = check_vd_overlap_v0;
          end

          VSLIDEUP_RGATHEREI16: begin
            // VSLIDEUP 
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
          end
          
          VRGATHER: begin
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
          end
        endcase
      end
      OPIVI: begin
        case(funct6_ari.ari_funct6)
          VADD,
          VAND,
          VOR,
          VXOR,
          VSLL,
          VSRL,
          VSRA,
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEDOWN: begin
            check_special = check_vd_overlap_v0;
          end

          VRSUB: begin
            check_special = check_vd_overlap_v0;
          end

          VADC: begin
            check_special = (inst_vm==1'b0)&(inst_vd!='b0);
          end

          VMADC: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2;
          end
          
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            check_special = check_vd_part_overlap_vs2;
          end
          
          VMSGTU,
          VMSGT: begin
            check_special = check_vd_part_overlap_vs2;
          end

          VMERGE_VMV: begin
            // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
            check_special = ((inst_vm=='b0)&(inst_vd!='b0)) | ((inst_vm==1'b1)&(inst_vs2=='b0));
          end
               
          VSMUL_VMVNRR: begin
            check_special = (inst_vm == 1'b1)&(inst_vs1[4:3]==2'b0)&
                            ((inst_nr==NREG1)|(inst_nr==NREG2)|(inst_nr==NREG4)|(inst_nr==NREG8));
          end

          VSLIDEUP_RGATHEREI16: begin
            // VSLIDEUP 
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
          end
          
          VRGATHER: begin
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
          end
        endcase
      end

      OPMVV: begin
        case(funct6_ari.ari_funct6)
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB,
          VWMUL,
          VWMULU,
          VWMULSU,
          VWMACCU,
          VWMACC,
          VWMACCSU: begin
            // overlap constraint
            check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1&check_vs1_part_overlap_vd_2_1;                
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            // overlap constraint
            check_special = check_vd_overlap_v0&check_vs1_part_overlap_vd_2_1;                
          end
          
          VXUNARY0: begin
            case(vs1_opcode_vxunary) 
              VZEXT_VF2,
              VSEXT_VF2: begin
                // overlap constraint
                check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1;                
              end
              VZEXT_VF4,
              VSEXT_VF4: begin
                // overlap constraint
                check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_4_1;                
              end
            endcase
          end

          VMUL,
          VMULH,
          VMULHU,
          VMULHSU,
          VDIVU,
          VDIV,
          VREMU,
          VREM,
          VMACC,
          VNMSAC,
          VMADD,
          VNMSUB,
          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            check_special = check_vd_overlap_v0;          
          end

          // reduction
          VREDSUM,
          VREDMAXU,
          VREDMAX,
          VREDMINU,
          VREDMIN,
          VREDAND,
          VREDOR,
          VREDXOR: begin
            check_special = (csr_vstart=='b0);
          end

          // mask 
          VMAND,
          VMNAND,
          VMANDN,
          VMXOR,
          VMOR,
          VMNOR,
          VMORN,
          VMXNOR: begin
            check_special = inst_vm;
          end
          
          VWXUNARY0: begin
            case(vs1_opcode_vwxunary)
              VCPOP,
              VFIRST: begin
                check_special = (csr_vstart=='b0);
              end
              VMV_X_S: begin
                check_special = (inst_vm==1'b1);
              end
            endcase
          end

          VMUNARY0: begin
            case(vs1_opcode_vmunary)
              VMSBF,
              VMSIF,
              VMSOF,
              VIOTA: begin
                check_special = (csr_vstart=='b0)&check_vd_overlap_v0&check_vd_overlap_vs2;
              end
              VID: begin
                check_special = (inst_vs2=='b0)&check_vd_overlap_v0;
              end
            endcase
          end

          VCOMPRESS: begin
            // destination register group cannot overlap the source register group
            check_special = (csr_vstart=='b0)&inst_vm&check_vd_overlap_vs2&check_vd_overlap_vs1;
          end
        endcase
      end
      OPMVX: begin
        case(funct6_ari.ari_funct6)
          VWADDU,
          VWSUBU,
          VWADD,
          VWSUB,
          VWMUL,
          VWMULU,
          VWMULSU,
          VWMACCU,
          VWMACC,
          VWMACCSU: begin
            // overlap constraint
            check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1;                
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            check_special = check_vd_overlap_v0;                
          end

          VMUL,
          VMULH,
          VMULHU,
          VMULHSU,
          VDIVU,
          VDIV,
          VREMU,
          VREM,
          VMACC,
          VNMSAC,
          VMADD,
          VNMSUB,
          VAADDU,
          VAADD,
          VASUBU,
          VASUB: begin
            check_special = check_vd_overlap_v0;          
          end

          VWMACCUS: begin
            check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1;                
          end

          VSLIDE1DOWN: begin
            check_special = check_vd_overlap_v0;          
          end
          
          VWXUNARY0: begin
            check_special = (vs2_opcode_vrxunary==VMV_S_X)&(inst_vm==1'b1)&(inst_vs2=='b0);
          end

          VSLIDE1UP: begin
            // destination register group cannot overlap the source register group
            check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
          end
        endcase
      end
    endcase
  end

  //check common requirements for all instructions
  assign check_common = check_vd_align&check_vs2_align&check_vs1_align&check_sew&check_lmul&check_evl_not_0&check_vstart_sle_evl;

  // check whether vd is aligned to emul_vd
  always_comb begin
    check_vd_align = 'b0; 

    case(emul_vd)
      EMUL_NONE,
      EMUL1: begin
        check_vd_align = 1'b1; 
      end
      EMUL2: begin
        check_vd_align = (inst_vd[0]==1'b0); 
      end
      EMUL4: begin
        check_vd_align = (inst_vd[1:0]==2'b0); 
      end
      EMUL8: begin
        check_vd_align = (inst_vd[2:0]==3'b0); 
      end
    endcase
  end

  // check whether vs2 is aligned to emul_vs2
  always_comb begin
    check_vs2_align = 'b0; 

    case(emul_vs2)
      EMUL_NONE,
      EMUL1: begin
        check_vs2_align = 1'b1; 
      end
      EMUL2: begin
        check_vs2_align = (inst_vs2[0]==1'b0); 
      end
      EMUL4: begin
        check_vs2_align = (inst_vs2[1:0]==2'b0); 
      end
      EMUL8: begin
        check_vs2_align = (inst_vs2[2:0]==3'b0); 
      end
    endcase
  end
    
  // check whether vs1 is aligned to emul_vs1
  always_comb begin
    check_vs1_align = 'b0; 
    
    case(emul_vs1)
      EMUL_NONE,
      EMUL1: begin
        check_vs1_align = 1'b1; 
      end
      EMUL2: begin
        check_vs1_align = (inst_vs1[0]==1'b0); 
      end
      EMUL4: begin
        check_vs1_align = (inst_vs1[1:0]==2'b0); 
      end
      EMUL8: begin
        check_vs1_align = (inst_vs1[2:0]==3'b0); 
      end
    endcase
  end
 
  // check the validation of EEW
  assign check_sew = (eew_max != EEW_NONE);
    
  // check the validation of EMUL
  assign check_lmul = (emul_max != EMUL_NONE); 
  
  // get evl
  always_comb begin
    evl = csr_vl;
  
    case(inst_funct3)
      OPIVI: begin
        case(funct6_ari.ari_funct6)
          VSMUL_VMVNRR: begin
            // vmv<nr>r.v
            case(emul_max)
              EMUL1: begin
                case(eew_max)
                  EEW8: begin
                    evl = 1*`VLEN/8;
                  end
                  EEW16: begin
                    evl = 1*`VLEN/16;
                  end
                  EEW32: begin
                    evl = 1*`VLEN/32;
                  end
                endcase
              end
              EMUL2: begin
                case(eew_max)
                  EEW8: begin
                    evl = 2*`VLEN/8;
                  end
                  EEW16: begin
                    evl = 2*`VLEN/16;
                  end
                  EEW32: begin
                    evl = 2*`VLEN/32;
                  end
                endcase
              end
              EMUL4: begin
                case(eew_max)
                  EEW8: begin
                    evl = 4*`VLEN/8;
                  end
                  EEW16: begin
                    evl = 4*`VLEN/16;
                  end
                  EEW32: begin
                    evl = 4*`VLEN/32;
                  end
                endcase
              end
              EMUL8: begin
                case(eew_max)
                  EEW8: begin
                    evl = 8*`VLEN/8;
                  end
                  EEW16: begin
                    evl = 8*`VLEN/16;
                  end
                  EEW32: begin
                    evl = 8*`VLEN/32;
                  end
                endcase
              end
            endcase
          end
        endcase
      end

      OPMVX: begin
        case(funct6_ari.ari_funct6)
          VWXUNARY0: begin
            if(vs2_opcode_vrxunary==VMV_S_X) begin
              evl = 'b1;
            end
          end
        endcase
      end
    endcase
  end

  // check evl is not 0
  // check vstart < evl
  always_comb begin
    check_evl_not_0 = evl!='b0;
    check_vstart_sle_evl = {1'b0,csr_vstart} < evl;
    
    // Instructions that write an x register or f register do so even when vstart >= vl, including when vl=0.
    case({valid_opm,funct6_ari.ari_funct6})
      {1'b1,VWXUNARY0}: begin
        case(inst_funct3)
          OPMVV: begin
            case(vs1_opcode_vwxunary)
              VCPOP,
              VFIRST,
              VMV_X_S: begin
                check_evl_not_0 = 'b1;
                check_vstart_sle_evl = 'b1;
              end
            endcase
          end
          OPMVX: begin
            if(vs2_opcode_vrxunary==VMV_S_X) begin
              check_evl_not_0 = csr_vl!='b0;
              check_evl_not_0 = {1'b0,csr_vstart} < csr_vl;
            end
          end
        endcase
      end
    endcase
  end

  `ifdef ASSERT_ON
    `ifdef TB_SUPPORT
      `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))
      else $warning("pc(0x%h) instruction will be discarded directly.\n",$sampled(inst.inst_pc));
    `else
      `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))
      else $warning("This instruction will be discarded directly.\n");
    `endif
  `endif

//
// split instruction to uops
//
`ifdef TB_SUPPORT
  // assign uop pc
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_PC
      uop_pc[i] = inst.inst_pc;
    end
  end
`endif

  // update uop funct3
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_FUNCT3
      uop_funct3[i] = inst_funct3;
    end
  end

  // update uop funct6
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_FUNCT6
      uop_funct6[i] = funct6_ari;
    end
  end

  // allocate uop to execution unit
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_EXE_UNIT
      // initial
      uop_exe_unit[i] = ALU;
      
      case(1'b1)
        valid_opi: begin
          // allocate OPI* uop to execution unit
          case(funct6_ari.ari_funct6)
            VADD,
            VSUB,
            VRSUB,
            VADC,
            VSBC,
            VAND,
            VOR,
            VXOR,
            VSLL,
            VSRL,
            VSRA,
            VNSRL,
            VNSRA,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VMERGE_VMV,
            VSADDU,
            VSADD,
            VSSUBU,
            VSSUB,
            VSSRL,
            VSSRA,
            VNCLIPU,
            VNCLIP: begin
              uop_exe_unit[i]     = ALU;
            end 
            
            // Although comparison instructions belong to ALU previously, 
            // they will be sent to RDT unit to execute for better performance. 
            // Because all uops of the comparison instructions have a single vector destination index, 
            // which is similar to reduction instructions.
            VMADC,
            VMSBC,
            VMSEQ,
            VMSNE,
            VMSLTU,
            VMSLT,
            VMSLEU,
            VMSLE,
            VMSGTU,
            VMSGT:begin
              uop_exe_unit[i] = CMP;
            end
            VWREDSUMU,
            VWREDSUM: begin
              uop_exe_unit[i] = RDT;
            end

            VSLIDEUP_RGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              uop_exe_unit[i] = PMT;
            end

            VSMUL_VMVNRR: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  uop_exe_unit[i] = MUL;
                end
                OPIVI: begin 
                  uop_exe_unit[i] = ALU;
                end
              endcase
            end
          endcase
        end

        valid_opm: begin
          // allocate OPM* uop to execution unit
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VXUNARY0,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB,
            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR,
            VWXUNARY0,
            VMUNARY0: begin
              uop_exe_unit[i] = ALU;
            end

            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VWMUL,
            VWMULU,
            VWMULSU: begin
              uop_exe_unit[i] = MUL;
            end

            VDIVU,
            VDIV,
            VREMU,
            VREM: begin
              uop_exe_unit[i] = DIV;
            end
            
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU,
            VWMACCUS: begin
              uop_exe_unit[i] = MAC;
            end

            // reduction
            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR: begin
              uop_exe_unit[i] = RDT;
            end

            VSLIDE1UP,
            VSLIDE1DOWN,
            VCOMPRESS: begin
              uop_exe_unit[i] = PMT;
            end
          endcase
        end
      endcase
    end
  end

// get the start number of uop_index
  always_comb begin
    if((funct6_ari.ari_funct6==VWXUNARY0)&(inst_funct3==OPMVV)&(vs1_opcode_vwxunary==VMV_X_S)) begin
      uop_vstart = 'b0;
    end
    else begin
      case(eew_max)
        EEW8: begin
          uop_vstart = csr_vstart[4 +: `UOP_INDEX_WIDTH_ARI];
        end
        EEW16: begin
          uop_vstart = csr_vstart[3 +: `UOP_INDEX_WIDTH_ARI];
        end
        EEW32: begin
          uop_vstart = csr_vstart[2 +: `UOP_INDEX_WIDTH_ARI];
        end
        default: begin
          uop_vstart = 'b0;
        end
      endcase
    end
  end
  
  // select uop_vstart and uop_index_remain as the base uop_index
  always_comb begin
    // initial
    uop_index_base = (uop_index_remain=='b0) ? uop_vstart : uop_index_remain;

    case(1'b1)
      valid_opi: begin
        case(funct6_ari.ari_funct6)
          VSLIDEUP_RGATHEREI16,
          VRGATHER: begin
            uop_index_base = uop_index_remain;
          end
        endcase
      end

      valid_opm: begin
        case(funct6_ari.ari_funct6)
          VSLIDE1UP: begin
            uop_index_base = uop_index_remain;
          end
        endcase
      end
    endcase
  end

  // calculate the uop_index used in decoding uops 
  generate
    for(j=0;j<`NUM_DE_UOP;j++) begin: GET_UOP_INDEX
      assign uop_index_current[j] = j[`UOP_INDEX_WIDTH:0]+uop_index_base;
    end
  endgenerate

  // get the max uop index 
  always_comb begin
    uop_index_max = 'b0;
    
    case(emul_max)
      EMUL2: begin
        uop_index_max = (`UOP_INDEX_WIDTH)'('d1);
      end
      EMUL4: begin
        uop_index_max = (`UOP_INDEX_WIDTH)'('d3);
      end
      EMUL8: begin
        uop_index_max = (`UOP_INDEX_WIDTH)'('d7);
      end
    endcase
  end

  // generate uop valid
  always_comb begin        
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_VALID
      if ((uop_index_current[i]<={1'b0,uop_index_max})&inst_valid) 
        uop_valid[i]  = inst_encoding_correct;
      else
        uop_valid[i]  = 'b0;
    end
  end

  // update uop class
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_CLASS
      // initial 
      uop_class[i] = XXX;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VADD,
            VADC,
            VAND,
            VOR,
            VXOR,
            VSLL,
            VSRL,
            VSRA,
            VNSRL,
            VNSRA,
            VSADDU,
            VSADD,
            VSMUL_VMVNRR,
            VSSRL,
            VSSRA,
            VNCLIPU,
            VNCLIP,
            VRGATHER: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = XVV;
                end
                OPIVX,
                OPIVI: begin
                  uop_class[i]  = XVX;
                end 
              endcase
            end

            VSUB,
            VSBC,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VSSUBU,
            VSSUB: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = XVV;
                end
                OPIVX: begin
                  uop_class[i]  = XVX;
                end 
              endcase
            end

            VRSUB,
            VSLIDEDOWN: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  uop_class[i]  = XVX;
                end 
              endcase
            end

            VMADC,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = VVV;
                end
                OPIVX,
                OPIVI: begin
                  uop_class[i]  = VVX;
                end
              endcase
            end

            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = VVV;
                end
                OPIVX: begin
                  uop_class[i]  = VVX;
                end
              endcase
            end

            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  uop_class[i]  = VVX;
                end 
              endcase
            end
            
            VMERGE_VMV: begin
              case(inst_funct3)
                OPIVV: begin
                  if (inst_vm==1'b0)
                    uop_class[i]  = XVV;
                  else
                    uop_class[i]  = XXV;
                end
                OPIVX,
                OPIVI: begin
                  if (inst_vm==1'b0)
                    uop_class[i]  = XVX;
                  else
                    uop_class[i]  = XXX;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = XVV;
                end
              endcase
            end

            VSLIDEUP_RGATHEREI16: begin
              case(inst_funct3)
                OPIVV: begin
                  uop_class[i]  = XVV;
                end
                OPIVX,
                OPIVI: begin
                  uop_class[i]  = VVX;
                end
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VDIVU,
            VDIV,
            VREMU,
            VREM,
            VWMUL,
            VWMULU,
            VWMULSU,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = XVV;
                end
                OPMVX: begin
                  uop_class[i]  = XVX;
                end
              endcase
            end 
            
            VXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = XVX;
                end
              endcase
            end

            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = VVV;
                end
                OPMVX: begin
                  uop_class[i]  = VVX;
                end
              endcase
            end

            VWMACCUS: begin
              case(inst_funct3)
                OPMVX: begin
                  uop_class[i]  = VVX;
                end
              endcase
            end 

            // reduction
            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = XVV;
                end
              endcase
            end

            // permutation
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  if (uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_vstart) 
                    uop_class[i]  = VVV;
                  else
                    uop_class[i]  = VVX;
                end
              endcase
            end

            // mask
            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = VVV;
                end
              endcase
            end

            VWXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop_class[i]  = XVX;
                end
                OPMVX: begin
                  uop_class[i]  = XXX;
                end
              endcase
            end

            VMUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF: begin
                      if (inst_vm==1'b0)
                        // need vd as vs3
                        uop_class[i]  = VVX;
                      else
                        uop_class[i]  = XVX;
                    end
                    VIOTA: begin
                      uop_class[i]  = XVX;
                    end
                    VID: begin
                      uop_class[i]  = XXX;
                    end
                  endcase
                end
              endcase
            end

            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  uop_class[i]  = XVX;
                end
              endcase
            end 
          endcase
        end
      endcase
    end
  end

  // update vector_csr and vstart
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_VCSR
      vector_csr[i] = vector_csr_ari;

      // update vstart of every uop
      if(uop_index_current[i]>{1'b0,uop_vstart}) begin
        case(1'b1)
          valid_opi: begin
            // OPI*
            case(funct6_ari.ari_funct6)
              VMADC,
              VMSBC,
              VMSEQ,
              VMSNE,
              VMSLTU,
              VMSLT,
              VMSLEU,
              VMSLE,
              VMSGTU,
              VMSGT,
              VWREDSUMU,
              VWREDSUM: begin
                vector_csr[i].vstart = vector_csr_ari.vstart;
              end
              default: begin 
                case(eew_max)
                  EEW8: begin
                    vector_csr[i].vstart  = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}};
                  end
                  EEW16: begin
                    vector_csr[i].vstart  = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}};
                  end
                  EEW32: begin
                    vector_csr[i].vstart  = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}};
                  end
                endcase
              end
            endcase
          end
          valid_opm: begin
            // OPM*
            case(funct6_ari.ari_funct6)
              VREDSUM,
              VREDMAXU,
              VREDMAX,
              VREDMINU,
              VREDMIN,
              VREDAND,
              VREDOR,
              VREDXOR,
              VCOMPRESS: begin
                vector_csr[i].vstart = vector_csr_ari.vstart;
              end
              default: begin 
                case(eew_max)
                  EEW8: begin
                    vector_csr[i].vstart  = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}};
                  end
                  EEW16: begin
                    vector_csr[i].vstart  = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}};
                  end
                  EEW32: begin
                    vector_csr[i].vstart  = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}};
                  end
                endcase
              end
            endcase
          end
        endcase
      end
    end
  end

  // update vs_evl
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_EVL
      vs_evl[i] = evl;
    end
  end
 
  // update ignore_vma and ignore_vta
  // some instructions use vm as an extra opcode, so it needs ignore vma policy.
  // the instructions whose EEW_vd=1b can write the result to TAIL elements, so it needs ignore vta policy.
  always_comb begin
    // initial 
    ignore_vma = 'b0;
    ignore_vta = 'b0;
      
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_IGNORE
      case(inst_funct3) 
        OPIVV,
        OPIVX,
        OPIVI: begin
          case(funct6_ari.ari_funct6)
            VADC,
            VSBC: begin
              ignore_vma[i] = 1'b1;
              ignore_vta[i] = 1'b0;
            end
            VMADC,
            VMSBC,
            VMSEQ,
            VMSNE,
            VMSLTU,
            VMSLT,
            VMSLEU,
            VMSLE,
            VMSGTU,
            VMSGT: begin
              ignore_vma[i] = 1'b1;
              ignore_vta[i] = 1'b1;
            end
            VMERGE_VMV: begin
              if (inst_vm=='b0) begin
                ignore_vma[i] = 1'b1;
              end
            end
          endcase
        end

        OPMVV: begin
          case(funct6_ari.ari_funct6)
            VMANDN,
            VMAND,
            VMOR,
            VMXOR,
            VMORN,
            VMNAND,
            VMNOR,
            VMXNOR: begin
              ignore_vma[i] = 1'b1;
              ignore_vta[i] = 1'b1;
            end
            VMUNARY0: begin
              case(vs1_opcode_vmunary)
                VMSBF,
                VMSOF,
                VMSIF: begin
                  ignore_vma[i] = 1'b1;
                  ignore_vta[i] = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end
  
  // update force_vma_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_FORCE_VMA
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
      force_vma_agnostic[i] = ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE)) |
                              ((check_vd_overlap_vs1==1'b0)&(eew_vd!=eew_vs1)&(eew_vd!=EEW_NONE)&(eew_vs1!=EEW_NONE));
    end
  end

  // update force_vta_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_FORCE_VTA
      force_vta_agnostic[i] = (eew_vd==EEW1) |   // Mask destination tail elements are always treated as tail-agnostic
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
                              ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE)) |
                              ((check_vd_overlap_vs1==1'b0)&(eew_vd!=eew_vs1)&(eew_vd!=EEW_NONE)&(eew_vs1!=EEW_NONE));
    end
  end

  // update vm field
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_VM
      vm[i] = inst_vm;
    end
  end
  
  // some uop need v0 as the vector operand
  always_comb begin
    // initial 
    v0_valid = 'b0;
       
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_V0
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VADC,
            VMADC,
            VMERGE_VMV: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  v0_valid[i] = !inst_vm;
                end
              endcase
            end 
            VSBC,
            VMSBC: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  v0_valid[i] = !inst_vm;
                end
              endcase
            end
          endcase
        end
        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VWXUNARY0: begin
              case(vs1_opcode_vwxunary)
                VCPOP,
                VFIRST: begin
                  v0_valid[i] = !inst_vm;
                end
              endcase
            end
            VMUNARY0: begin
              case(vs1_opcode_vmunary)
                VMSBF,
                VMSOF,
                VMSIF,
                VIOTA: begin
                  v0_valid[i] = !inst_vm;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end    
  
  // update vd_offset and valid
  always_comb begin
    vd_offset = 'b0;
    vd_valid  = 'b0;

    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VD_OFFSET
      case(1'b1)
        valid_opi: begin
          case(funct6_ari.ari_funct6)
            VADD,
            VADC,
            VAND,
            VOR,
            VXOR,
            VSLL,
            VSRL,
            VSRA,
            VMERGE_VMV,
            VSADDU,
            VSADD,
            VSMUL_VMVNRR,
            VSSRL,
            VSSRA,
            VRGATHER: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin  
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end 
              endcase
            end

            VSUB,
            VSBC,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VSSUBU,
            VSSUB: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin  
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end 
              endcase
            end

            VRSUB: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end

            VSLIDEDOWN: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin  
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end 
              endcase
            end

            VMADC,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin  
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
            
            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin  
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
            
            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin  
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end

            VNSRL,
            VNSRA,
            VNCLIPU,
            VNCLIP: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  vd_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              if(inst_funct3==OPIVV) begin
                vd_offset[i] = 'b0;
                vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
              end
            end

            VSLIDEUP_RGATHEREI16: begin
              case(inst_funct3)
                OPIVV: begin
                  case({emul_max,emul_vd})
                    {EMUL1,EMUL1},
                    {EMUL2,EMUL2},
                    {EMUL4,EMUL4},
                    {EMUL8,EMUL8}: begin
                      vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      vd_valid[i]  = 1'b1;
                    end
                    {EMUL2,EMUL1},
                    {EMUL4,EMUL2},
                    {EMUL8,EMUL4}: begin
                      vd_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                      vd_valid[i]  = 1'b1;
                    end
                  endcase
                end
                OPIVX,
                OPIVI: begin  
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end 
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VDIVU,
            VDIV,
            VREMU,
            VREM,
            VWMUL,
            VWMULU,
            VWMULSU,
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB: begin
              case(inst_funct3)
                OPMVV,
                OPMVX: begin
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end   

            VXUNARY0,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end

            VWMACCUS,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end 
            
            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR: begin
              case(inst_funct3)
                OPMVV: begin
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
             
            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR: begin
              case(inst_funct3)
                OPMVV: begin
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end

            VWXUNARY0: begin
              case(inst_funct3)
                OPMVX: begin
                  vd_offset[i] = 'b0;
                  vd_valid[i]  = 1'b1;
                end
              endcase
            end
         
            VMUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF: begin
                      vd_offset[i] = 'b0;
                      vd_valid[i]  = 1'b1;
                    end
                    VIOTA,
                    VID: begin
                      vd_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      vd_valid[i]  = 1'b1;
                    end
                  endcase
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update vd_index and eew 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VD_OFFSET
      vd_index[i] = inst_vd + {2'b0, vd_offset[i]};
      vd_eew[i]   = eew_vd;
    end
  end

  // some uop need vd as the vs3 vector operand
  always_comb begin
    // initial
    vs3_valid = 'b0;

    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS3_VALID
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VMADC: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
            VMSBC: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  vs3_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  vs3_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  vs3_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
                end
              endcase
            end
            VSLIDEUP_RGATHEREI16: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(inst_funct3)
                OPMVV,
                OPMVX: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
            VWMACCUS: begin
              case(inst_funct3)
                OPMVX: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  vs3_valid[i] = 1'b1;
                end
              endcase
            end
            VMUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF: begin
                      if (inst_vm==1'b0)
                        vs3_valid[i] = 1'b1;
                    end
                  endcase
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end
  
  // update vs1_offset and valid
  always_comb begin
    vs1_offset      = 'b0;
    vs1_index_valid = 'b0;
      
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS1_OFFSET
      case(inst_funct3)
        OPIVV: begin
          case(funct6_ari.ari_funct6)
            VADD,
            VSUB,
            VADC,
            VMADC,
            VSBC,
            VMSBC,
            VAND,
            VOR,
            VXOR,
            VSLL,
            VSRL,
            VSRA,
            VMSEQ,
            VMSNE,
            VMSLTU,
            VMSLT,
            VMSLEU,
            VMSLE,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VMERGE_VMV,
            VSADDU,
            VSADD,
            VSSUBU,
            VSSUB,
            VSMUL_VMVNRR,
            VSSRL,
            VSSRA,
            VRGATHER: begin
              vs1_offset[i]      = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
              vs1_index_valid[i] = 1'b1;
            end
            
            VNSRL,
            VNSRA,
            VNCLIPU,
            VNCLIP: begin
              vs1_offset[i]      = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
              vs1_index_valid[i] = 1'b1;
            end
            
            VWREDSUMU,
            VWREDSUM: begin
              vs1_offset[i]      = 'b0;
              vs1_index_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
            end        
            
            VSLIDEUP_RGATHEREI16: begin
              case({emul_max,emul_vs1})
                {EMUL1,EMUL1},
                {EMUL2,EMUL2},
                {EMUL4,EMUL4},
                {EMUL8,EMUL8}: begin
                  vs1_offset[i]      = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs1_index_valid[i] = 1'b1;
                end
                {EMUL2,EMUL1},
                {EMUL4,EMUL2},
                {EMUL8,EMUL4}: begin
                  vs1_offset[i]      = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                  vs1_index_valid[i] = 1'b1;
                end
              endcase
            end
          endcase
        end

        OPMVV: begin
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VWMUL,
            VWMULU,
            VWMULSU,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              vs1_offset[i]      = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
              vs1_index_valid[i] = 1'b1;
            end

            VXUNARY0,
            VWXUNARY0,
            VMUNARY0: begin
              vs1_offset[i]      = 'b0; // vs1 is regarded as opcode
              vs1_index_valid[i] = 'b0;
            end

            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VDIVU,
            VDIV,
            VREMU,
            VREM,
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB: begin
              vs1_offset[i]      = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
              vs1_index_valid[i] = 1'b1;
            end

            // reduction
            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR: begin
              vs1_offset[i]      = 'b0;
              vs1_index_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
            end

            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR: begin
              vs1_offset[i]      = 'b0;
              vs1_index_valid[i] = 1'b1;
            end

            VCOMPRESS: begin
              if (uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_vstart) begin
                vs1_offset[i]      = 'b0;
                vs1_index_valid[i] = 1'b1;
              end
            end
          endcase
        end
      endcase
    end
  end

  // update vs1(index or opcode) and eew
  always_comb begin 
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS1
      vs1[i]     = inst_vs1 + {2'b0, vs1_offset[i]}; 
      vs1_eew[i] = eew_vs1; 
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb begin
    // initial
    vs1_opcode_valid = 'b0;
    
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS1_OPCODE
      case(inst_funct3)
        OPIVI: begin
          case(funct6_ari.ari_funct6)
            VSMUL_VMVNRR: begin
              vs1_opcode_valid[i] = 1'b1;   // vmvnrr.v's vs1 opcode is 5'b0, which means vmv1r.v
            end
          endcase
        end
        
        OPMVV: begin
          case(funct6_ari.ari_funct6)
            VXUNARY0: begin
              vs1_opcode_valid[i] = 1'b1;
            end
            VWXUNARY0: begin
              case(vs1_opcode_vwxunary)
                VCPOP,
                VFIRST,
                VMV_X_S: begin
                  vs1_opcode_valid[i] = 1'b1;
                end
              endcase
            end
            VMUNARY0: begin
              case(vs1_opcode_vmunary)
                VMSBF,
                VMSIF,
                VMSOF,
                VIOTA: begin
                  vs1_opcode_valid[i] = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update vs2 offset and valid  
  always_comb begin
    // initial
    vs2_offset = 'b0;
    vs2_valid = 'b0; 
      
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS2_OFFSET
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VADD,
            VADC,
            VMADC,
            VAND,
            VOR,
            VXOR,
            VSLL,
            VSRL,
            VSRA,
            VNSRL,
            VNSRA,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE,
            VSADDU,
            VSADD,
            VSMUL_VMVNRR,
            VSSRL,
            VSSRA,
            VNCLIPU,
            VNCLIP,
            VRGATHER: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end
            
            VSUB,
            VSBC,
            VMSBC,
            VMSLTU,
            VMSLT,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VSSUBU,
            VSSUB: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VRSUB,
            VMSGTU,
            VMSGT,
            VSLIDEDOWN: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end
            
            VMERGE_VMV: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  if(inst_vm==1'b0) begin
                    vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                    vs2_valid[i]  = 1'b1;
                  end
                end
              endcase
            end
           
            VWREDSUMU,
            VWREDSUM: begin
              case(inst_funct3)
                OPIVV: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VSLIDEUP_RGATHEREI16: begin
              case(inst_funct3)
                OPIVV: begin
                  case({emul_max,emul_vs2})
                    {EMUL1,EMUL1},
                    {EMUL2,EMUL2},
                    {EMUL4,EMUL4},
                    {EMUL8,EMUL8}: begin
                      vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      vs2_valid[i]  = 1'b1;
                    end
                    {EMUL2,EMUL1},
                    {EMUL4,EMUL2},
                    {EMUL8,EMUL4}: begin
                      vs2_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                      vs2_valid[i]  = 1'b1;
                    end
                  endcase
                end
                OPIVX,
                OPIVI: begin  
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end 
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM* 
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWMUL,
            VWMULU,
            VWMULSU,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(inst_funct3)
                OPMVV,
                OPMVX: begin
                  vs2_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end
            
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VDIVU,
            VDIV,
            VREMU,
            VREM,
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB: begin
              case(inst_funct3)
                OPMVV,
                OPMVX: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  case({emul_max,emul_vs2})
                    {EMUL1,EMUL1},
                    {EMUL2,EMUL1},
                    {EMUL4,EMUL1}: begin
                      vs2_offset[i] = 'b0;
                      vs2_valid[i]  = 1'b1;
                    end
                    {EMUL4,EMUL2},
                    {EMUL8,EMUL4}: begin
                      vs2_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                      vs2_valid[i]  = 1'b1;
                    end
                    {EMUL8,EMUL2}: begin
                      vs2_offset[i] = {2'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:2]};
                      vs2_valid[i]  = 1'b1;
                    end
                  endcase
                end
              endcase
            end

            VWMACCUS: begin
              case(inst_funct3)
                OPMVX: begin
                  vs2_offset[i] = {1'b0, uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VREDSUM,
            VREDMAXU,
            VREDMAX,
            VREDMINU,
            VREDMIN,
            VREDAND,
            VREDOR,
            VREDXOR,
            VWXUNARY0,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VMAND,
            VMNAND,
            VMANDN,
            VMXOR,
            VMOR,
            VMNOR,
            VMORN,
            VMXNOR: begin
              case(inst_funct3)
                OPMVV: begin
                  vs2_offset[i] = 'b0;
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end

            VMUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF,
                    VIOTA: begin
                      vs2_offset[i] = 'b0;
                      vs2_valid[i]  = 1'b1;
                    end
                  endcase
                end
              endcase
            end

            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  vs2_offset[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  vs2_valid[i]  = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update vs2 index and eew
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS2
      vs2_index[i] = inst_vs2 + {2'b0, vs2_offset[i]};
      vs2_eew[i]   = eew_vs2;
    end
  end

  // update rd_index and valid
  always_comb begin
    // initial
    rd_index       = 'b0;
    rd_index_valid = 'b0;
     
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_RD
      case(funct6_ari.ari_funct6)
        VWXUNARY0: begin
          case(inst_funct3)
            OPMVV: begin
              case(vs1_opcode_vwxunary)
                VCPOP,
                VFIRST,
                VMV_X_S: begin
                  rd_index[i]         = inst_rd;
                  rd_index_valid[i]   = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update rs1_data and rs1_data_valid 
  always_comb begin
    // initial
    rs1_data       = 'b0;
    rs1_data_valid = 'b0;
      
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_RS1
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VADD,
            VRSUB,
            VADC,
            VMADC,
            VAND,
            VOR,
            VXOR,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE,
            VMSGTU,
            VMSGT,
            VMERGE_VMV,
            VSADDU,
            VSADD: begin
              case(inst_funct3)
                OPIVX: begin
                  rs1_data[i]       = rs1;
                  rs1_data_valid[i] = 1'b1;
                end
                OPIVI: begin
                  rs1_data[i]       = {{(`XLEN-`IMM_WIDTH){inst_imm[`IMM_WIDTH-1]}},inst_imm[`IMM_WIDTH-1:0]};
                  rs1_data_valid[i] = 1'b1;
                end
              endcase
            end
          
            VSUB,
            VSBC,
            VMSBC,
            VMSLTU,
            VMSLT,
            VMINU,
            VMIN,
            VMAXU,
            VMAX,
            VSSUBU,
            VSSUB,
            VSMUL_VMVNRR: begin
              case(inst_funct3)
                OPIVX: begin
                  rs1_data[i]       = rs1;
                  rs1_data_valid[i] = 1'b1;
                end
              endcase
            end  

            VSLL,
            VSRL,
            VSRA,
            VNSRL,
            VNSRA,
            VSSRL,
            VSSRA,
            VNCLIPU,
            VNCLIP,
            VSLIDEUP_RGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              case(inst_funct3)
                OPIVX: begin
                  rs1_data[i]       = rs1;
                  rs1_data_valid[i] = 1'b1;
                end
                OPIVI: begin
                  rs1_data[i]       = {{(`XLEN-`IMM_WIDTH){1'b0}},inst_imm[`IMM_WIDTH-1:0]};
                  rs1_data_valid[i] = 1'b1;
                end
              endcase
            end
          endcase
        end
        
        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWADDU_W,
            VWSUBU_W,
            VWADD_W,
            VWSUB_W,
            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VDIVU,
            VDIV,
            VREMU,
            VREM,
            VWMUL,
            VWMULU,
            VWMULSU,
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU,
            VWMACCUS,
            VAADDU,
            VAADD,
            VASUBU,
            VASUB,
            VWXUNARY0,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  rs1_data[i]       = rs1;
                  rs1_data_valid[i] = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update first_uop valid
  always_comb begin
    // initial 
    first_uop_valid = 'b0;
    
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_FIRST
      first_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_vstart;

      case(1'b1)
        valid_opi: begin
          case(funct6_ari.ari_funct6)
            VSLIDEUP_RGATHEREI16,
            VRGATHER: begin
              first_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == 'b0;
            end
          endcase
        end
        valid_opm: begin
          case(funct6_ari.ari_funct6)
            VSLIDE1UP: begin
              first_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == 'b0;
            end
          endcase
        end
      endcase
    end
  end

  // update last_uop valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_LAST
      last_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
    end
  end

  // update uop index
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: ASSIGN_UOP_INDEX
      uop_index[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
    end
  end
  
  // update segment_index
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: ASSIGN_SEG_INDEX
      seg_field_index[i] = 'b0;
    end
  end

  // assign result to output
  generate
    for(j=0;j<`NUM_DE_UOP;j++) begin: ASSIGN_RES
    `ifdef TB_SUPPORT
      assign uop[j].uop_pc              = uop_pc[j];
    `endif  
      assign uop[j].uop_funct3          = uop_funct3[j];
      assign uop[j].uop_funct6          = uop_funct6[j];
      assign uop[j].uop_exe_unit        = uop_exe_unit[j]; 
      assign uop[j].uop_class           = uop_class[j];   
      assign uop[j].vector_csr          = vector_csr[j];  
      assign uop[j].vs_evl              = vs_evl[j];            
      assign uop[j].ignore_vma          = ignore_vma[j];
      assign uop[j].ignore_vta          = ignore_vta[j];
      assign uop[j].force_vma_agnostic  = force_vma_agnostic[j];
      assign uop[j].force_vta_agnostic  = force_vta_agnostic[j];
      assign uop[j].vm                  = vm[j];                
      assign uop[j].v0_valid            = v0_valid[j];          
      assign uop[j].vd_index            = vd_index[j];          
      assign uop[j].vd_eew              = vd_eew[j];  
      assign uop[j].vd_valid            = vd_valid[j];
      assign uop[j].vs3_valid           = vs3_valid[j];         
      assign uop[j].vs1                 = vs1[j];              
      assign uop[j].vs1_eew             = vs1_eew[j];           
      assign uop[j].vs1_index_valid     = vs1_index_valid[j];
      assign uop[j].vs1_opcode_valid    = vs1_opcode_valid[j];
      assign uop[j].vs2_index 	        = vs2_index[j]; 	       
      assign uop[j].vs2_eew             = vs2_eew[j];
      assign uop[j].vs2_valid           = vs2_valid[j];
      assign uop[j].rd_index 	          = rd_index[j]; 	       
      assign uop[j].rd_index_valid      = rd_index_valid[j]; 
      assign uop[j].rs1_data            = rs1_data[j];           
      assign uop[j].rs1_data_valid      = rs1_data_valid[j];    
      assign uop[j].uop_index           = uop_index[j];         
      assign uop[j].first_uop_valid     = first_uop_valid[j];   
      assign uop[j].last_uop_valid      = last_uop_valid[j];    
      assign uop[j].seg_field_index     = seg_field_index[j];   
    end
  endgenerate

endmodule
