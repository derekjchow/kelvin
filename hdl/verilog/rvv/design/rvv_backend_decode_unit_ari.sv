
`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

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
   
  RVVConfigState                                  vector_csr_ari;
  logic   [`VSTART_WIDTH-1:0]                     csr_vstart;
  logic   [`VL_WIDTH-1:0]                         csr_vl;
  logic   [`VL_WIDTH-1:0]                         vs_evl;
  RVVSEW                                          csr_sew;
  RVVLMUL                                         csr_lmul;
  logic   [`XLEN-1:0] 	                          rs1_data;
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
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0] uop_index_current;   
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_max;         
  
  // enum/union
  FUNCT6_u                                        funct6_ari;

  // use for for-loop 
  genvar                                          j;

//
// decode
//
  assign inst_funct6          = inst.bits[24:19];
  assign inst_vm              = inst.bits[18];
  assign inst_vs2             = inst.bits[17:13];
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
  assign rs1_data             = inst.rs1;

  // decode arithmetic instruction funct6
  always_comb begin
    if (inst_valid)
      funct6_ari.ari_funct6 = inst_funct6;
    else
      funct6_ari.ari_funct6 = 'b0;
  end

  // make sure: funct6 and funct3 are not illegal opcode
  always_comb begin
    // initial the data
    valid_opi                 = 'b0;
    valid_opm                 = 'b0;
    
    case(inst_funct3)
      OPIVV,
      OPIVX,
      OPIVI: begin
        case(funct6_ari.ari_funct6)
          VADD,            
          VSUB,            
          VRSUB,           
          VMINU,           
          VMIN,            
          VMAXU,           
          VMAX,            
          VAND,            
          VOR,             
          VXOR,            
          VRGATHER,        
          VSLIDEUP_RGATHEREI16,
          VSLIDEDOWN,      
          VADC,            
          VMADC,           
          VSBC,            
          VMSBC,           
          VMERGE_VMV,      
          VMSEQ,           
          VMSNE,           
          VMSLTU,          
          VMSLT,           
          VMSLEU,          
          VMSLE,           
          VMSGTU,          
          VMSGT,           
          VSADDU,          
          VSADD,           
          VSSUBU,          
          VSSUB,           
          VSLL,            
          VSMUL_VMVNRR,    
          VSRL,            
          VSRA,            
          VSSRL,           
          VSSRA,           
          VNSRL,           
          VNSRA,           
          VNCLIPU,         
          VNCLIP,          
          VWREDSUMU,       
          VWREDSUM: begin
            valid_opi = inst_valid;
          end
        endcase
      end
      OPMVV,
      OPMVX: begin
        case(funct6_ari.ari_funct6)
          VREDSUM    ,   
          VREDAND    ,
          VREDOR     ,
          VREDXOR    ,
          VREDMINU   ,
          VREDMIN    ,
          VREDMAXU   ,
          VREDMAX    ,
          VAADDU     ,
          VAADD      ,
          VASUBU     ,
          VASUB      ,
          VSLIDE1UP  ,
          VSLIDE1DOWN,
          VWXUNARY0  ,  
          VXUNARY0   ,  
          VMUNARY0   ,  
          VCOMPRESS  ,
          VMANDN     ,
          VMAND      ,
          VMOR       ,
          VMXOR      ,
          VMORN      ,
          VMNAND     ,
          VMNOR      ,
          VMXNOR     ,
          VDIVU      ,
          VDIV       ,
          VREMU      ,
          VREM       ,
          VMULHU     ,
          VMUL       ,
          VMULHSU    ,
          VMULH      ,
          VMADD      ,
          VNMSUB     ,
          VMACC      ,
          VNMSAC     ,
          VWADDU     ,
          VWADD      ,
          VWSUBU     ,
          VWSUB      ,
          VWADDU_W   ,
          VWADD_W    ,
          VWSUBU_W   ,
          VWSUB_W    ,
          VWMULU     ,
          VWMULSU    ,
          VWMUL      ,
          VWMACCU    ,
          VWMACC     ,
          VWMACCUS   ,
          VWMACCSU: begin
            valid_opm = inst_valid;
          end
        endcase
      end
    endcase
  end 

  // get EMUL
  always_comb begin
    // initial
    emul_vd          = EMUL_NONE;
    emul_vs2         = EMUL_NONE;
    emul_vs1         = EMUL_NONE;
    emul_max         = EMUL_NONE;
    
    case(1'b1)
      valid_opi: begin
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
              OPIVX,
              OPIVI: begin
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
              OPIVX: begin
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

          VRSUB,
          VSLIDEDOWN: begin        
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
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

          // destination vector register is mask register
          VMADC,
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(inst_funct3)
              OPIVV: begin
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
              OPIVX,
              OPIVI: begin
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
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(inst_funct3)
              OPIVV: begin
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
              OPIVX: begin
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
            endcase
          end

          // narrowing instructions
          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP:begin
            case(inst_funct3)
              OPIVV: begin
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
              OPIVX,
              OPIVI: begin
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
            endcase
          end
          
          VMSGTU,
          VMSGT: begin
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
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
            endcase
          end

          VMERGE_VMV: begin
            case(inst_funct3)
              OPIVV: begin
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
              OPIVX,
              OPIVI: begin
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
            endcase
          end

          VSMUL_VMVNRR: begin
            case(inst_funct3)
              OPIVV: begin
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
              OPIVX: begin
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
              // vmv<nr>r.v instruction
              OPIVI: begin
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
            endcase
          end
          
          // widening instructions
          VWREDSUMU,
          VWREDSUM: begin
            case(inst_funct3)
              OPIVV: begin
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
            endcase
          end

          VSLIDEUP_RGATHEREI16: begin        
            case(inst_funct3)
              // VRGATHEREI16
              OPIVV: begin
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
              // VSLIDEUP 
              OPIVX,
              OPIVI: begin
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

      valid_opm: begin
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
              OPMVX: begin
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
            endcase
          end
          
          // widening instructions: 2SEW = 2SEW op SEW
          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(inst_funct3)
              OPMVV: begin
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
              OPMVX: begin
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
            endcase
          end

          VXUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
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
              OPIVX: begin
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

          VWMACCUS: begin
            case(inst_funct3)
              OPMVX: begin
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
                emul_vd     = EMUL1;
                emul_vs2    = EMUL1;
                emul_vs1    = EMUL1;
                emul_max    = EMUL1;
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
                    emul_vs2  = EMUL1;
                    emul_max  = EMUL1;
                  end
                endcase
              end
              OPMVX: begin
                emul_vd     = EMUL1;
                emul_max    = EMUL1;
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
            endcase
          end
          
          VSLIDE1UP,
          VSLIDE1DOWN: begin
            case(inst_funct3)
              OPMVX: begin
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

          VCOMPRESS: begin
            case(inst_funct3)
              OPMVV: begin
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

    case(1'b1)
      valid_opi: begin
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

      valid_opm: begin
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
              OPMVX: begin
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
                // vmv.s.x
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
    check_vd_part_overlap_vs2       = 'b0;          
    
    case(emul_vs2)
      EMUL1: begin
        check_vd_part_overlap_vs2   = 1'b1;          
      end
      EMUL2: begin
        if(!((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1]))))
          check_vd_part_overlap_vs2 = 1'b1;          
      end
      EMUL4: begin
        if(!((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2]))))
          check_vd_part_overlap_vs2 = 1'b1;          
      end
      EMUL8 : begin
        if(!((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3]))))
          check_vd_part_overlap_vs2 = 1'b1;          
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
        if(!((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
      EMUL4: begin
        if(!((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
      EMUL8 : begin
        if(!((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
    endcase
  end

  // vd cannot overlap vs2
  // check_vd_overlap_vs2=1 means that check pass (vd group does NOT overlap vs2 group fully)
  always_comb begin
    check_vd_overlap_vs2 = 'b0;
    
    case(emul_max)
      EMUL1: begin
        if(inst_vd!=inst_vs2)
          check_vd_overlap_vs2 = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])))
          check_vd_overlap_vs2 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])))
          check_vd_overlap_vs2 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])))
          check_vd_overlap_vs2 = 1'b1;
      end
    endcase
  end
  
  // vd cannot overlap vs1
  // check_vd_overlap_vs1=1 means that check pass (vd group does NOT overlap vs1 group fully)
  always_comb begin
    check_vd_overlap_vs1 = 'b0;
    
    case(emul_max)
      EMUL1: begin
        if(inst_vd!=inst_vs1)
          check_vd_overlap_vs1 = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])))
          check_vd_overlap_vs1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])))
          check_vd_overlap_vs1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])))
          check_vd_overlap_vs1 = 1'b1;
      end
    endcase
  end

  // check whether vs2 group partially overlaps vd group for EEW_vd:EEW_vs2=2:1
  always_comb begin
    check_vs2_part_overlap_vd_2_1       = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_2_1   = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b10)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b100)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
    endcase
  end
  
  // check whether vs1 group partially overlaps vd group for EEW_vd:EEW_vs1=2:1
  always_comb begin
    check_vs1_part_overlap_vd_2_1       = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs1_part_overlap_vd_2_1   = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs1[0]!=1'b1)))
          check_vs1_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs1[1:0]!=2'b10)))
          check_vs1_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs1[2:0]!=3'b100)))
          check_vs1_part_overlap_vd_2_1 = 1'b1;
      end
    endcase
  end

  // check whether vs2 group partially overlaps vd group for EEW_vd:EEW_vs2=4:1
  always_comb begin
    check_vs2_part_overlap_vd_4_1       = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_4_1   = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b11)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b110)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
    endcase
  end
 
  // start to check special requirements for every instructions
  always_comb begin 
    check_special = 'b0;
    
    case(1'b1)
      valid_opi: begin
        // OPI* instruction
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
            case(inst_funct3)
              OPIVV,
              OPIVX,
              OPIVI: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end
        
          VSUB,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            case(inst_funct3)
              OPIVV,
              OPIVX: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end

          VRSUB: begin
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end

          VADC: begin
            case(inst_funct3)
              OPIVV,
              OPIVX,
              OPIVI: begin
                if ((inst_vm==1'b0)&(inst_vd!='b0))
                  check_special          = 1'b1;          
                
                `ifdef ASSERT_ON
                  assert(inst_vm==1'b0)
                    else $error("Unsupported inst_vm=%d in %d instruction.\n",inst_vm,funct6_ari.ari_funct6);
                  
                  assert(inst_vd==1'b1)
                    else $warning("inst_vd(%d) cannot overlap v0 in %d instruction.\n",inst_vd,funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end

          VMADC: begin
            case(inst_funct3)
              OPIVV: begin
                check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
              end
              OPIVX,
              OPIVI: begin
                check_special = check_vd_part_overlap_vs2;
              end
            endcase
          end

          VSBC: begin
            case(inst_funct3)
              OPIVV,
              OPIVX: begin
                if ((inst_vm==1'b0)&(inst_vd!='b0))
                  check_special         = 1'b1;          
                
                `ifdef ASSERT_ON
                  assert(inst_vm==1'b0)
                    else $error("Unsupported inst_vm=%d in %d instruction.\n",inst_vm,funct6_ari.ari_funct6);
                  
                  assert(inst_vd==1'b1)
                    else $warning("inst_vd(%d) cannot overlap v0 in %d instruction.\n",inst_vd,funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end
      
          VMSBC: begin
            case(inst_funct3)
              OPIVV: begin
                check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
              end
              OPIVX: begin
                check_special = check_vd_part_overlap_vs2;
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
                check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2;
              end
            endcase
          end
          
          VMSEQ,
          VMSNE,
          VMSLEU,
          VMSLE: begin
            case(inst_funct3)
              OPIVV: begin
                check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
              end
              OPIVX,
              OPIVI: begin
                check_special = check_vd_part_overlap_vs2;
              end
            endcase
          end

          VMSLTU,
          VMSLT: begin
            case(inst_funct3)
              OPIVV: begin
                check_special = check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
              end
              OPIVX: begin
                check_special = check_vd_part_overlap_vs2;
              end
            endcase
          end
          
          VMSGTU,
          VMSGT: begin
            case(inst_funct3)
              OPIVX,
              OPIVI: begin
                check_special = check_vd_part_overlap_vs2;
              end
            endcase     
          end

          VMERGE_VMV: begin
            case(inst_funct3)
              OPIVV,
              OPIVX,
              OPIVI: begin
                // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
                if (((inst_vm=='b0)&(inst_vd!='b0)) | ((inst_vm==1'b1)&(inst_vs2=='b0)))   
                  check_special = 1'b1;          
                
                `ifdef ASSERT_ON
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                  
                  assert(!((inst_vm==1'b1)&(inst_vs2!=5'b0)))
                    else $error("inst_vs2(%d) should be 0 in %d instruction.\n",inst_vm,inst_vs2,funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end
               
          VSMUL_VMVNRR: begin
            case(inst_funct3)
              OPIVV,
              OPIVX: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                `endif
              end
              OPIVI: begin
                if ((inst_vm == 1'b1)&
                    (inst_vs1[4:3]==2'b0)&
                    ((inst_nr==NREG1)|(inst_nr==NREG2)|(inst_nr==NREG4)|(inst_nr==NREG8))
                   )
                  check_special          = 1'b1;

                `ifdef ASSERT_ON
                  assert(inst_vm==1'b1)
                    else $error("inst_vm(%d) should be 1 in vmv<nr>r instruction.\n",inst_vm,funct6_ari.ari_funct6);

                  assert(inst_vs1[4:3]==2'b0)
                    else $error("inst_vs1[4:3](%d) should be 0 in vmv<nr>r instruction.\n",inst_vs1[4:3]);
                
                  assert((inst_nr==NREG1)|(inst_nr==NREG2)|(inst_nr==NREG4)|(inst_nr==NREG8))
                    else $error("Unsupported inst_vs1[2:0]=%d in vmv<nr>r instruction.\n",inst_vs1[2:0]);
                `endif
              end
            endcase
          end

          VWREDSUMU,
          VWREDSUM: begin
            case(inst_funct3)
              OPIVV: begin
                if (csr_vstart=='b0) 
                  check_special = check_vs2_part_overlap_vd_2_1;        

                `ifdef ASSERT_ON
                  assert(csr_vstart=='b0)
                    else $error("csr_vstart(%d) should be 0 in %d instruction.\n",csr_vstart,funct6_ari.ari_funct6);
                  
                  assert(check_vd_overlap_v0==1'b1)
                    else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end

          VSLIDEUP_RGATHEREI16: begin
            case(inst_funct3)
              // VRGATHEREI16
              OPIVV: begin
                // destination register group cannot overlap the source register group
                case({emul_max,emul_vs2,emul_vs1})
                  {EMUL1,EMUL1,EMUL1},
                  {EMUL2,EMUL2,EMUL2},
                  {EMUL4,EMUL4,EMUL4},
                  {EMUL8,EMUL8,EMUL8}: begin
                    check_special   = check_vd_overlap_v0&check_vd_overlap_vs2&check_vd_overlap_vs1;                
                  end

                  {EMUL2,EMUL1,EMUL2},
                  {EMUL2,EMUL2,EMUL1}: begin
                    if(inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:1])
                      check_special = check_vd_overlap_v0&check_vd_overlap_vs2;          
                  end

                  {EMUL4,EMUL2,EMUL4},
                  {EMUL4,EMUL4,EMUL2}: begin
                    if(inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:2])
                      check_special = check_vd_overlap_v0&check_vd_overlap_vs2;          
                  end

                  {EMUL8,EMUL4,EMUL8},
                  {EMUL8,EMUL8,EMUL4}: begin
                    if(inst_vd[`REGFILE_INDEX_WIDTH-1:3]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:3])
                      check_special = check_vd_overlap_v0&check_vd_overlap_vs2;          
                  end
                endcase
              end
              // VSLIDEUP 
              OPIVX,
              OPIVI: begin
                // destination register group cannot overlap the source register group
                check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
              end
            endcase
          end
          
          VRGATHER: begin
            case(inst_funct3)
              OPIVV: begin
                // destination register group cannot overlap the source register group
                check_special = check_vd_overlap_v0&check_vd_overlap_vs2&check_vd_overlap_vs1;
              end
              OPIVX,
              OPIVI: begin
                // destination register group cannot overlap the source register group
                check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
              end
            endcase
          end
        endcase
      end

      valid_opm: begin
        // OPM* instruction
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
              OPMVV: begin
                // overlap constraint
                check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1&check_vs1_part_overlap_vd_2_1;                
              end
              OPMVX: begin
                // overlap constraint
                check_special = check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1;                
              end
            endcase
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(inst_funct3)
              OPMVV: begin
                // overlap constraint
                check_special = check_vd_overlap_v0&check_vs1_part_overlap_vd_2_1;                
              end
              OPMVX: begin
                check_special = check_vd_overlap_v0;                
              end
            endcase
          end
          
          VXUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
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
            case(inst_funct3)
              OPMVV,
              OPMVX: begin
                check_special = check_vd_overlap_v0;          
              end
            endcase
          end

          VWMACCUS,
          VSLIDE1DOWN: begin
            case(inst_funct3)
              OPMVX: begin
                check_special = check_vd_overlap_v0;          
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
                if(csr_vstart=='b0)
                  check_special = check_vd_part_overlap_vs2;
            
                `ifdef ASSERT_ON
                  assert(csr_vstart=='b0)
                    else $error("csr_vstart(%d) should be 0 in %d instruction.\n",csr_vstart,funct6_ari.ari_funct6);
                `endif
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
                if(inst_vm==1'b1)
                  check_special   = 1'b1;
            
                `ifdef ASSERT_ON
                  assert(inst_vm==1'b1)
                    else $error("inst_vm(%d) should be 1 in %d instruction.\n",inst_vm,funct6_ari.ari_funct6);
                `endif
              end
            endcase
          end
          
          VWXUNARY0: begin
            case(inst_funct3)
              OPMVV: begin
                case(vs1_opcode_vwxunary)
                  VCPOP,
                  VFIRST: begin
                    check_special   = 1'b1;
                  end
                  VMV_X_S: begin
                    if(inst_vm==1'b1)
                      check_special = 1'b1;
                  end
                endcase
              end
              OPMVX: begin
                if((inst_vm==1'b1)&(inst_vs2=='b0))
                  check_special = 1'b1;
                
                `ifdef ASSERT_ON
                  assert(inst_vm==1'b1)
                    else $error("inst_vm(%d) should be 1 in %d instruction.\n",inst_vm,funct6_ari.ari_funct6);
                
                  assert(inst_vs2=='b0)
                    else $error("inst_vs2(%d) should be 0 in %d instruction.\n",inst_vs2,funct6_ari.ari_funct6);
                `endif
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
                    check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
                  end
                  VID: begin
                    if(inst_vs2=='b0)
                      check_special = check_vd_overlap_v0;
                  end
                endcase
              end
            endcase
          end

          VSLIDE1UP: begin
            case(inst_funct3)
              OPMVX: begin
                // destination register group cannot overlap the source register group
                check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
              end
            endcase
          end

          VCOMPRESS: begin
            case(inst_funct3)
              OPMVX: begin
                if (csr_vstart=='b0) begin
                  // destination register group cannot overlap the source register group
                  check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
                
                  `ifdef ASSERT_ON
                    assert(csr_vstart=='b0)
                      else $error("csr_vstart(%d) should be 0 in %d instruction.\n",csr_vstart,funct6_ari.ari_funct6);
                  
                    assert(check_vd_overlap_v0==1'b1)
                      else $warning("vd is overlap v0 in %d instruction.\n",funct6_ari.ari_funct6);
                    
                    assert(check_vd_overlap_vs2==1'b1)
                      else $warning("vd is overlap vs2 in %d instruction.\n",funct6_ari.ari_funct6);
                  `endif
                end
              end
            endcase
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
        if (inst_vd[0]==1'b0)
          check_vd_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vd[0]==1'b0)
            else $warning("vd is not aligned to emul_vd=%s.\n",emul_vd.name());
        `endif
      end
      EMUL4: begin
        if (inst_vd[1:0]==2'b0)
          check_vd_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vd[1:0]==2'b0)
            else $warning("vd is not aligned to emul_vd=%s.\n",emul_vd.name());
        `endif
      end
      EMUL8: begin
        if (inst_vd[2:0]==3'b0)
          check_vd_align = 1'b1; 
       
        `ifdef ASSERT_ON
          assert(inst_vd[2:0]==3'b0)        
            else $warning("vd is not aligned to emul_vd=%s.\n",emul_vd.name());
        `endif
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
        if (inst_vs2[0]==1'b0)
          check_vs2_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vs2[0]==1'b0)
            else $warning("vs2 is not aligned to emul_vs2=%s.\n",emul_vs2.name());
        `endif
      end
      EMUL4: begin
        if (inst_vs2[1:0]==2'b0)
          check_vs2_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vs2[1:0]==2'b0)
            else $warning("vs2 is not aligned to emul_vs2=%s.\n",emul_vs2.name());
        `endif
      end
      EMUL8: begin
        if (inst_vs2[2:0]==3'b0)
          check_vs2_align = 1'b1; 
       
        `ifdef ASSERT_ON
          assert(inst_vs2[2:0]==3'b0)        
            else $warning("vs2 is not aligned to emul_vs2=%s.\n",emul_vs2.name());
        `endif
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
        if (inst_vs1[0]==1'b0)
          check_vs1_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vs1[0]==1'b0)
            else $warning("vs1 is not aligned to emul_vs1=%s.\n",emul_vs1.name());
        `endif
      end
      EMUL4: begin
        if (inst_vs1[1:0]==2'b0)
          check_vs1_align = 1'b1; 
        
        `ifdef ASSERT_ON
          assert(inst_vs1[1:0]==2'b0)
            else $warning("vs1 is not aligned to emul_vs1=%s.\n",emul_vs1.name());
        `endif
      end
      EMUL8: begin
        if (inst_vs1[2:0]==3'b0)
          check_vs1_align = 1'b1; 
       
        `ifdef ASSERT_ON
          assert(inst_vs1[2:0]==3'b0)        
            else $warning("vs1 is not aligned to emul_vs1=%s.\n",emul_vs1.name());
        `endif
      end
    endcase
  end
 
  // check the validation of EEW
  assign check_sew = (eew_max != EEW_NONE);
    
  // check the validation of EMUL
  assign check_lmul = (emul_max != EMUL_NONE); 
  
  // get evl
  always_comb begin
    vs_evl = csr_vl;
  
    case(1'b1)
      valid_opi: begin
        // OPI* instruction
        case(funct6_ari.ari_funct6)
          VSMUL_VMVNRR: begin
            case(inst_funct3)
              OPIVI: begin
              // vmv<nr>r.v
                case(emul_max)
                  EMUL1: begin
                    case(eew_max)
                      EEW8: begin
                        vs_evl = 1*`VLEN/8;
                      end
                      EEW16: begin
                        vs_evl = 1*`VLEN/16;
                      end
                      EEW32: begin
                        vs_evl = 1*`VLEN/32;
                      end
                    endcase
                  end
                  EMUL2: begin
                    case(eew_max)
                      EEW8: begin
                        vs_evl = 2*`VLEN/8;
                      end
                      EEW16: begin
                        vs_evl = 2*`VLEN/16;
                      end
                      EEW32: begin
                        vs_evl = 2*`VLEN/32;
                      end
                    endcase
                  end
                  EMUL4: begin
                    case(eew_max)
                      EEW8: begin
                        vs_evl = 4*`VLEN/8;
                      end
                      EEW16: begin
                        vs_evl = 4*`VLEN/16;
                      end
                      EEW32: begin
                        vs_evl = 4*`VLEN/32;
                      end
                    endcase
                  end
                  EMUL8: begin
                    case(eew_max)
                      EEW8: begin
                        vs_evl = 8*`VLEN/8;
                      end
                      EEW16: begin
                        vs_evl = 8*`VLEN/16;
                      end
                      EEW32: begin
                        vs_evl = 8*`VLEN/32;
                      end
                    endcase
                  end
                endcase
              end
            endcase
          end
        endcase
      end
      valid_opm: begin
        // OPM* instruction
        case(funct6_ari.ari_funct6)
          VWXUNARY0: begin
            case(inst_funct3)
              OPMVX: begin
              // vmv.s.x
              vs_evl = 'b1;
              end
            endcase
          end
        endcase
      end
    endcase
  end

  // check evl is not 0
  always_comb begin
    check_evl_not_0 = vs_evl!='b0;
    
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
              end
            endcase
          end
        endcase
      end
    endcase
  end

  // check vstart < evl
  always_comb begin
    check_vstart_sle_evl = {1'b0,csr_vstart} < vs_evl;
    
    // Instructions that write an x register or f register do so even when vstart >= vl, including when vl=0.
    case({valid_opm,funct6_ari.ari_funct6})
      {1'b1,VWXUNARY0}: begin
        case(inst_funct3)
          OPMVV: begin
            case(vs1_opcode_vwxunary)
              VCPOP,
              VFIRST,
              VMV_X_S: begin
                check_vstart_sle_evl = 'b1;
              end
            endcase
          end
        endcase
      end
    endcase
  end

  `ifdef ASSERT_ON
    `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))
      else $warning("This instruction will be discarded directly.\n");
  `endif

// get the start number of uop_index
  always_comb begin
    // initial
    uop_vstart      = 'b0;

    case(eew_max)
      EEW8: begin
        uop_vstart  = csr_vstart[4 +: `UOP_INDEX_WIDTH];
      end
      EEW16: begin
        uop_vstart  = csr_vstart[3 +: `UOP_INDEX_WIDTH];
      end
      EEW32: begin
        uop_vstart  = csr_vstart[2 +: `UOP_INDEX_WIDTH];
      end
    endcase
  end
  
  // select uop_vstart and uop_index_remain as the base uop_index
  assign uop_index_base  = (uop_index_remain=='b0) ? 
                            uop_vstart : 
                            uop_index_remain;

  // calculate the uop_index used in decoding uops 
  for(j=0;j<`NUM_DE_UOP;j=j+1) begin: GET_UOP_INDEX
    assign uop_index_current[j] = j[`UOP_INDEX_WIDTH-1:0]+uop_index_base;
  end

//
// split instruction to uops
//
  // get the max uop index 
  always_comb begin
    uop_index_max = 'b0;
    
    case(emul_max)
      EMUL1: begin
        uop_index_max = 'd0;
      end
      EMUL2: begin
        uop_index_max = 'd1;
      end
      EMUL4: begin
        uop_index_max = 'd3;
      end
      EMUL8: begin
        uop_index_max = 'd7;
      end
    endcase
  end

  // generate uop valid
  always_comb begin        
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VALID
      if ((uop_index_current[i]<=uop_index_max)&inst_valid) 
        uop_valid[i]  = inst_encoding_correct;
      else
        uop_valid[i]  = 'b0;
    end
  end

`ifdef TB_SUPPORT
  // assign uop pc
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_PC
      uop[i].uop_pc = inst.inst_pc;
    end
  end
`endif

  // update uop funct3
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT3
      uop[i].uop_funct3 = inst_funct3;
    end
  end

  // update uop funct6
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT6
      uop[i].uop_funct6 = funct6_ari;
    end
  end

  // allocate uop to execution unit
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      // initial
      uop[i].uop_exe_unit = ALU;
      
      case(1'b1)
        valid_opi: begin
          // allocate OPI* uop to execution unit
          case(funct6_ari.ari_funct6)
            VADD,
            VSUB,
            VRSUB,
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
              uop[i].uop_exe_unit     = ALU;
            end 
            
            // Although comparison instructions belong to ALU previously, 
            // they will be sent to RDT unit to execute for better performance. 
            // Because all uops of the comparison instructions have a single vector destination index, 
            // which is similar to reduction instructions.
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
              uop[i].uop_exe_unit = RDT;
            end

            VSLIDEUP_RGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              uop[i].uop_exe_unit = PMT;
            end

            VSMUL_VMVNRR: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  uop[i].uop_exe_unit = MUL;
                end
                OPIVI: begin 
                  uop[i].uop_exe_unit = ALU;
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
              uop[i].uop_exe_unit     = ALU;
            end

            VMUL,
            VMULH,
            VMULHU,
            VMULHSU,
            VWMUL,
            VWMULU,
            VWMULSU: begin
              uop[i].uop_exe_unit     = MUL;
            end

            VDIVU,
            VDIV,
            VREMU,
            VREM: begin
              uop[i].uop_exe_unit     = DIV;
            end
            
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU,
            VWMACCUS: begin
              uop[i].uop_exe_unit     = MAC;
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
              uop[i].uop_exe_unit     = RDT;
            end

            VSLIDE1UP,
            VSLIDE1DOWN,
            VCOMPRESS: begin
              uop[i].uop_exe_unit     = PMT;
            end
          endcase
        end
      endcase
    end
  end
 
  // update uop class
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_CLASS
      // initial 
      uop[i].uop_class = X;
      
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
                  uop[i].uop_class  = VV;
                end
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VX;
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
                  uop[i].uop_class  = VV;
                end
                OPIVX: begin
                  uop[i].uop_class  = VX;
                end 
              endcase
            end

            VRSUB,
            VSLIDEDOWN: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VX;
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
                  uop[i].uop_class  = VVV;
                end
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VV;
                end
              endcase
            end

            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].uop_class  = VVV;
                end
                OPIVX: begin
                  uop[i].uop_class  = VV;
                end
              endcase
            end

            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VV;
                end 
              endcase
            end
            
            VMERGE_VMV: begin
              case(inst_funct3)
                OPIVV: begin
                  if (inst_vm==1'b0)
                    uop[i].uop_class  = VV;
                  else
                    uop[i].uop_class  = VX;
                end
                OPIVX,
                OPIVI: begin
                  if (inst_vm==1'b0)
                    uop[i].uop_class  = VX;
                  else
                    uop[i].uop_class  = X;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].uop_class  = VV;
                end
              endcase
            end

            VSLIDEUP_RGATHEREI16: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].uop_class  = VV;
                end
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VX;
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
                  uop[i].uop_class  = VV;
                end
                OPMVX: begin
                  uop[i].uop_class  = VX;
                end
              endcase
            end 
            
            VXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].uop_class  = VX;
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
                  uop[i].uop_class  = VVV;
                end
                OPMVX: begin
                  uop[i].uop_class  = VV;
                end
              endcase
            end

            VWMACCUS,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  uop[i].uop_class  = VV;
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
            VREDXOR,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].uop_class  = VV;
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
                  uop[i].uop_class  = VVV;
                end
              endcase
            end
          
            VWXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].uop_class  = VX;
                end
                OPMVX: begin
                  uop[i].uop_class  = X;
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
                        uop[i].uop_class  = VV;
                      else
                        uop[i].uop_class  = VX;
                    end
                    VIOTA: begin
                      uop[i].uop_class  = VX;
                    end
                    VID: begin
                      uop[i].uop_class  = X;
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

  // update vector_csr and vstart
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VCSR
      uop[i].vector_csr               = vector_csr_ari;

      // update vstart of every uop
      if(uop_index_current[i]==uop_vstart)
        uop[i].vector_csr.vstart      = csr_vstart;
      else begin
        case(eew_max)
          EEW8: begin
            uop[i].vector_csr.vstart  = {uop_index_current[i],4'b0};
          end
          EEW16: begin
            uop[i].vector_csr.vstart  = {1'b0,uop_index_current[i],3'b0};
          end
          EEW32: begin
            uop[i].vector_csr.vstart  = {2'b0,uop_index_current[i],2'b0};
          end
        endcase
      end
    end
  end

  // update vs_ecl
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EVL
      uop[i].vs_evl = vs_evl;
    end
  end
  
  // update force_vma_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_FORCE_VMA
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
      uop[i].force_vma_agnostic = ((check_vd_overlap_v0==1'b0)&(eew_vd!=EEW1)) | 
                                  ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE)) |
                                  ((check_vd_overlap_vs1==1'b0)&(eew_vd!=eew_vs1)&(eew_vd!=EEW_NONE)&(eew_vs1!=EEW_NONE));
    end
  end

  // update force_vta_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_FORCE_VTA
      uop[i].force_vta_agnostic = (eew_vd==EEW1) |   // Mask destination tail elements are always treated as tail-agnostic
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
                                  ((check_vd_overlap_v0==1'b0)&(eew_vd!=EEW1)) | 
                                  ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE)) |
                                  ((check_vd_overlap_vs1==1'b0)&(eew_vd!=eew_vs1)&(eew_vd!=EEW_NONE)&(eew_vs1!=EEW_NONE));
    end
  end

  // update vm field
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VM
      uop[i].vm = inst_vm;
    end
  end
  
  // some uop need v0 as the vector operand
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_V0
      // initial 
      uop[i].v0_valid = 'b0;
       
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
                  uop[i].v0_valid   = !inst_vm;
                end
              endcase
            end 
            VSBC,
            VMSBC: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  uop[i].v0_valid   = !inst_vm;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end    
  
  // update vd_index, eew and valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD
      // initial
      uop[i].vd_index = 'b0;
      uop[i].vd_eew   = EEW_NONE;
      uop[i].vd_valid = 'b0;
      
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
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end 
              endcase
            end

            VRSUB,
            VSLIDEDOWN: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end
            
            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin  
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end
            
            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              if(inst_funct3==OPIVV) begin
                uop[i].vd_index   = inst_vd;
                uop[i].vd_eew     = eew_vd;
                uop[i].vd_valid   = 1'b1;
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
                      uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    end
                    {EMUL2,EMUL1},
                    {EMUL4,EMUL2},
                    {EMUL8,EMUL4}: begin
                      uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    end
                  endcase
                end
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end   

            VXUNARY0,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end

            VWMACCUS,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end
             
            VWXUNARY0: begin
              case(inst_funct3)
                OPMVX: begin
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
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
                      uop[i].vd_index = inst_vd;
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    end
                    VID: begin
                      uop[i].vd_index = inst_vd+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
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

  // some uop need vd as the vs3 vector operand
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS3_VALID
      // initial
      uop[i].vs3_valid = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VMADC,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  uop[i].vs3_valid = uop_index_current[i] == uop_index_max;
                end
              endcase
            end
            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(inst_funct3)
                OPIVV,
                OPIVX: begin
                  uop[i].vs3_valid = uop_index_current[i] == uop_index_max;
                end
              endcase
            end
            VMSGTU,
            VMSGT: begin
              case(inst_funct3)
                OPIVX,
                OPIVI: begin
                  uop[i].vs3_valid = uop_index_current[i] == uop_index_max;
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
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end

            VWMACCUS: begin
              case(inst_funct3)
                OPMVX: begin
                  uop[i].vs3_valid = 1'b1;
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
                  uop[i].vs3_valid = 1'b1;
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
                        uop[i].vs3_valid = 1'b1;
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
  
  // update vs1 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1
      // initial
      uop[i].vs1             = inst_vs1;
      uop[i].vs1_eew         = EEW_NONE;
      uop[i].vs1_index_valid = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
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
              case(inst_funct3)
                OPIVV: begin
                  uop[i].vs1              = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;   
                end
              endcase
            end
            
            VNSRL,
            VNSRA,
            VNCLIPU,
            VNCLIP: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].vs1              = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;
                end
              endcase
            end
            
            VWREDSUMU,
            VWREDSUM: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].vs1              = inst_vs1;
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;   
                end
              endcase
            end        
            
            VSLIDEUP_RGATHEREI16: begin
              if(inst_funct3==OPIVV) begin
                case({emul_max,emul_vs1})
                  {EMUL1,EMUL1},
                  {EMUL2,EMUL2},
                  {EMUL4,EMUL4},
                  {EMUL8,EMUL8}: begin
                    uop[i].vs1             = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                    uop[i].vs1_eew         = eew_vs1;
                    uop[i].vs1_index_valid = 1'b1;
                  end
                  {EMUL2,EMUL1},
                  {EMUL4,EMUL2},
                  {EMUL8,EMUL4}: begin
                    uop[i].vs1             = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                    uop[i].vs1_eew         = eew_vs1;
                    uop[i].vs1_index_valid = 1'b1;
                  end
                endcase
              end
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
            VWMUL,
            VWMULU,
            VWMULSU,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].vs1              = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;        
                end
              endcase
            end

            VXUNARY0,
            VWXUNARY0,
            VMUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].vs1              = inst_vs1; // vs1 is regarded as opcode
                  uop[i].vs1_eew          = EEW_NONE;
                  uop[i].vs1_index_valid  = 'b0;        
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
            VASUB,
            VCOMPRESS: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].vs1              = inst_vs1+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;        
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
            VREDXOR,
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
                  uop[i].vs1              = inst_vs1;
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1_OPCODE
      // initial
      uop[i].vs1_opcode_valid         = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VSMUL_VMVNRR: begin
              case(inst_funct3)
                OPIVI: begin
                  uop[i].vs1_opcode_valid = 1'b1;   // vmvnrr.v's vs1 opcode is 5'b0, which means vmv1r.v
                end
              endcase
            end
          endcase
        end
        
        valid_opm: begin
          // OPM*
          case(funct6_ari.ari_funct6)
            VXUNARY0: begin
              case(inst_funct3)
                OPMVV: begin
                  uop[i].vs1_opcode_valid = 1'b1;
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
                      uop[i].vs1_opcode_valid = 1'b1;
                    end
                  endcase
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
                      uop[i].vs1_opcode_valid = 1'b1;
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

  // update vs2 index, eew and valid  
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS2
      // initial
      uop[i].vs2_index        = 'b0; 
      uop[i].vs2_eew          = EEW_NONE; 
      uop[i].vs2_valid        = 'b0; 
      
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
                end
              endcase
            end
            
            VMERGE_VMV: begin
              case(inst_funct3)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  if(inst_vm==1'b0) begin
                    uop[i].vs2_index  = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                    uop[i].vs2_eew    = eew_vs2;
                    uop[i].vs2_valid  = 1'b1;
                  end
                end
              endcase
            end
           
            VWREDSUMU,
            VWREDSUM: begin
              case(inst_funct3)
                OPIVV: begin
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
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
                      uop[i].vs2_index  = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                      uop[i].vs2_eew    = eew_vs2;
                      uop[i].vs2_valid  = 1'b1;
                    end
                    {EMUL2,EMUL1},
                    {EMUL4,EMUL2},
                    {EMUL8,EMUL4}: begin
                      uop[i].vs2_index  = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                      uop[i].vs2_eew    = eew_vs2;
                      uop[i].vs2_valid  = 1'b1;
                    end
                  endcase
                end
                OPIVX,
                OPIVI: begin  
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew   = eew_vs2;
                  uop[i].vs2_valid = 1'b1;
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;        
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;        
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
                      uop[i].vs2_index    = inst_vs2;
                      uop[i].vs2_eew      = eew_vs2;
                      uop[i].vs2_valid    = 1'b1;
                    end
                    {EMUL8,EMUL4}: begin
                      uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:2];
                      uop[i].vs2_eew      = eew_vs2;
                      uop[i].vs2_valid    = 1'b1;
                    end
                  endcase
                end
              endcase
            end

            VWMACCUS,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(inst_funct3)
                OPMVX: begin
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;        
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
                  uop[i].vs2_index    = inst_vs2+uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;   
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
                  uop[i].vs2_index    = inst_vs2;
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;   
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
                      uop[i].vs2_index    = inst_vs2;
                      uop[i].vs2_eew      = eew_vs2;
                      uop[i].vs2_valid    = 1'b1;   
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

  // update rd_index and valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RD
      // initial
      uop[i].rd_index         = 'b0;
      uop[i].rd_index_valid   = 'b0;
     
      case(funct6_ari.ari_funct6)
        VWXUNARY0: begin
          case(inst_funct3)
            OPMVV: begin
              case(vs1_opcode_vwxunary)
                VCPOP,
                VFIRST,
                VMV_X_S: begin
                  uop[i].rd_index         = inst_rd;
                  uop[i].rd_index_valid   = 1'b1;
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
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1
      // initial
      uop[i].rs1_data         = 'b0;
      uop[i].rs1_data_valid   = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.ari_funct6)
            VADD,
            VRSUB,
            VADC,
            VMADC,
            VSBC,
            VAND,
            VOR,
            VXOR,
            VMSEQ,
            VMSNE,
            VMSLE,
            VMSGT,
            VMERGE_VMV,
            VSADD,
            VNCLIP: begin
              case(inst_funct3)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].rs1_data_valid = 1'b1;
                end
                OPIVI: begin
                  uop[i].rs1_data       = {{(`XLEN-`IMM_WIDTH){inst_imm[`IMM_WIDTH-1]}},inst_imm[`IMM_WIDTH-1:0]};
                  uop[i].rs1_data_valid = 1'b1;
                end
              endcase
            end
          
            VSUB,
            VMSBC,
            VMSLTU,
            VMSLT,
            VMIN,
            VMAX,
            VMINU,
            VMAXU,
            VSSUBU,
            VSSUB,
            VSMUL_VMVNRR: begin
              case(inst_funct3)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].rs1_data_valid = 1'b1;
                end
              endcase
            end  

            VSLL,
            VSRL,
            VSRA,
            VNSRL,
            VNSRA,
            VMSLEU,
            VMSGTU,
            VSADDU,
            VSSRL,
            VSSRA,
            VNCLIPU,
            VSLIDEUP_RGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              case(inst_funct3)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].rs1_data_valid = 1'b1;
                end
                OPIVI: begin
                  uop[i].rs1_data       = {{(`XLEN-`IMM_WIDTH){1'b0}},inst_imm[`IMM_WIDTH-1:0]};
                  uop[i].rs1_data_valid = 1'b1;
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
                  uop[i].rs1_data       = rs1_data;
                  uop[i].rs1_data_valid = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update uop index
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: ASSIGN_UOP_INDEX
      uop[i].uop_index = uop_index_current[i];
    end
  end

  // update last_uop valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_LAST
      uop[i].last_uop_valid = uop_index_current[i] == uop_index_max;
    end
  end

endmodule
