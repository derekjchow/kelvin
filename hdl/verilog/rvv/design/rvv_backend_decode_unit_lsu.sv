
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_decode_unit_lsu
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
  input   logic                               inst_valid;
  input   RVVCmd                              inst;
  input   logic       [`UOP_INDEX_WIDTH-1:0]  uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]       uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]       uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`FUNCT6_WIDTH-1:0]                     inst_funct6;      // inst original encoding[31:26]           
  logic   [`NFIELD_WIDTH-1:0]                     inst_nf;          // inst original encoding[31:29]
  logic   [`VM_WIDTH-1:0]                         inst_vm;          // inst original encoding[25]      
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_vs2;         // inst original encoding[24:20]
  logic   [`UMOP_WIDTH-1:0]                       inst_umop;        // inst original encoding[24:20]
  logic   [`FUNCT3_WIDTH-1:0]                     inst_funct3;      // inst original encoding[14:12]
  logic   [`REGFILE_INDEX_WIDTH-1:0]              inst_vd;          // inst original encoding[11:7]
  RVVOpCode                                       inst_opcode;      // inst original encoding[6:0]

  RVVConfigState                                  vector_csr_lsu;
  logic   [`VSTART_WIDTH-1:0]                     csr_vstart;
  logic   [`VL_WIDTH-1:0]                         csr_vl;
  logic   [`VL_WIDTH-1:0]                         evl;
  RVVSEW                                          csr_sew;
  RVVLMUL                                         csr_lmul;
  EMUL_e                                          emul_vd;          
  EMUL_e                                          emul_vs2;          
  EMUL_e                                          emul_vd_nf; 
  EMUL_e                                          emul_max_vd_vs2; 
  EMUL_e                                          emul_max;          
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs2;          
  EEW_e                                           eew_max;         
  logic                                           valid_lsu;
  logic                                           valid_lsu_opcode;
  logic                                           valid_lsu_mop;
  logic                                           inst_encoding_correct;
  logic                                           check_special;
  logic                                           check_vd_overlap_v0;
  logic                                           check_vd_part_overlap_vs2;
  logic   [`REGFILE_INDEX_WIDTH:0]                vd_index_start;
  logic   [`REGFILE_INDEX_WIDTH:0]                vd_index_end;
  logic                                           check_vd_overlap_vs2;
  logic                                           check_vs2_part_overlap_vd_2_1;
  logic                                           check_vs2_part_overlap_vd_4_1;
  logic                                           check_common;
  logic                                           check_vd_align;
  logic                                           check_vs2_align;
  logic                                           check_vd_in_range;
  logic                                           check_sew;
  logic                                           check_lmul;
  logic                                           check_evl_not_0;
  logic                                           check_vstart_sle_evl;
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_base;         
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH:0]   uop_index_current;   
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_max;         
   
  // convert logic to enum/union
  FUNCT6_u                                        funct6_lsu;

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
  EEW_e   [`NUM_DE_UOP-1:0]                           vd_eew;  
  logic   [`NUM_DE_UOP-1:0]                           vd_valid;
  logic   [`NUM_DE_UOP-1:0]                           vs3_valid;          
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] vs1;              
  EEW_e   [`NUM_DE_UOP-1:0]                           vs1_eew;            
  logic   [`NUM_DE_UOP-1:0]                           vs1_index_valid;
  logic   [`NUM_DE_UOP-1:0]                           vs1_opcode_valid;
  logic   [`NUM_DE_UOP-1:0][`REGFILE_INDEX_WIDTH-1:0] vs2_index; 	        
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
  
  // local parameter for SEW in original endocing[14:12]
  localparam  SEW_8     = 3'b000;
  localparam  SEW_16    = 3'b101;
  localparam  SEW_32    = 3'b110;

//
// decode
//
  assign inst_funct6    = inst.bits[24:19];
  assign inst_nf        = inst.bits[24:22];
  assign inst_vm        = inst.bits[18];
  assign inst_vs2       = inst.bits[17:13];
  assign inst_umop      = inst.bits[17:13];
  assign inst_funct3    = inst.bits[7:5];
  assign inst_vd        = inst.bits[4:0];
  assign inst_opcode    = inst.opcode;
  assign vector_csr_lsu = inst.arch_state;
  assign csr_vstart     = inst.arch_state.vstart;
  assign csr_vl         = inst.arch_state.vl;
  assign csr_sew        = inst.arch_state.sew;
  assign csr_lmul       = inst.arch_state.lmul;
  
// decode funct6
  // valid signal
  assign valid_lsu = valid_lsu_opcode&valid_lsu_mop&inst_valid;

  // identify load or store
  always_comb begin
    funct6_lsu.lsu_funct6.lsu_is_store = IS_LOAD;
    valid_lsu_opcode                   = 'b0;

    case(inst_opcode)
      LOAD: begin
        funct6_lsu.lsu_funct6.lsu_is_store = IS_LOAD;
        valid_lsu_opcode                   = 1'b1;
      end
      STORE: begin
        funct6_lsu.lsu_funct6.lsu_is_store = IS_STORE;
        valid_lsu_opcode                   = 1'b1;
      end
    endcase

  // lsu_mop distinguishes unit-stride, constant-stride, unordered index, ordered index
  // lsu_umop identifies what unit-stride instruction belong to when lsu_mop=US
    // initial 
    funct6_lsu.lsu_funct6.lsu_mop    = US;
    funct6_lsu.lsu_funct6.lsu_umop   = US_US;
    funct6_lsu.lsu_funct6.lsu_is_seg = NONE;
    valid_lsu_mop                    = 'b0;
    
    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_REGULAR: begin          
            funct6_lsu.lsu_funct6.lsu_mop    = US;
            funct6_lsu.lsu_funct6.lsu_umop   = US_US;
            valid_lsu_mop                    = 1'b1;
            funct6_lsu.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
          end
          US_WHOLE_REGISTER: begin
            funct6_lsu.lsu_funct6.lsu_mop    = US;
            funct6_lsu.lsu_funct6.lsu_umop   = US_WR;
            valid_lsu_mop                    = 1'b1;
          end
          US_MASK: begin
            funct6_lsu.lsu_funct6.lsu_mop    = US;
            funct6_lsu.lsu_funct6.lsu_umop   = US_MK;
            valid_lsu_mop                    = 1'b1;
          end
          US_FAULT_FIRST: begin
            funct6_lsu.lsu_funct6.lsu_mop    = US;
            funct6_lsu.lsu_funct6.lsu_umop   = US_FF;
            valid_lsu_mop                    = 1'b1;
            funct6_lsu.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
          end
        endcase
      end
      UNORDERED_INDEX: begin
        funct6_lsu.lsu_funct6.lsu_mop    = IU;
        valid_lsu_mop                    = 1'b1;
        funct6_lsu.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
      end
      CONSTANT_STRIDE: begin
        funct6_lsu.lsu_funct6.lsu_mop    = CS;
        valid_lsu_mop                    = 1'b1;
        funct6_lsu.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
      end
      ORDERED_INDEX: begin
        funct6_lsu.lsu_funct6.lsu_mop    = IO;
        valid_lsu_mop                    = 1'b1;
        funct6_lsu.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
      end
    endcase
  end

// get EMUL
  always_comb begin
    // initial
    emul_vd         = EMUL_NONE;
    emul_vs2        = EMUL_NONE;
    emul_max_vd_vs2 = EMUL_NONE;
    emul_vd_nf      = EMUL_NONE;
    emul_max        = EMUL_NONE;

    if (valid_lsu) begin  
      case(funct6_lsu.lsu_funct6.lsu_mop)
        US: begin
          case(funct6_lsu.lsu_funct6.lsu_umop)
            US_US,
            US_FF: begin
              case(inst_nf)
                // EMUL_vd = ceil( inst_funct3/csr_sew*csr_lmul )
                // emul_max_vd_vs2 = EMUL_vd
                // emul_vd_nf = EMUL_vd*NF
                // EMUL_max = NF*emul_max_vd_vs2
                NF1: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL1;
                          emul_max        = EMUL1;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL8;
                          emul_max_vd_vs2 = EMUL8;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL1;
                          emul_max        = EMUL1;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL8;
                          emul_max_vd_vs2 = EMUL8;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL1;
                          emul_max        = EMUL1;
                        end
                        LMUL1_2: begin    
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL8;
                          emul_max_vd_vs2 = EMUL8;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL1;
                          emul_max        = EMUL1;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL1;
                          emul_max        = EMUL1;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                      endcase
                    end
                  endcase
                end
                NF2: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL1_2: begin    
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL4;
                          emul_max_vd_vs2 = EMUL4;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL2;
                          emul_max        = EMUL2;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                      endcase
                    end
                  endcase
                end
                NF3: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL3;
                          emul_max        = EMUL3;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL3;
                          emul_max        = EMUL3;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL3;
                          emul_max        = EMUL3;
                        end
                        LMUL1_2: begin    
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL3;
                          emul_max        = EMUL3;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL3;
                          emul_max        = EMUL3;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                  endcase
                end
                NF4: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL2: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL1: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL1_2: begin    
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL4: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL4;
                          emul_max        = EMUL4;
                        end
                        LMUL8: begin
                          emul_vd         = EMUL2;
                          emul_max_vd_vs2 = EMUL2;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                  endcase
                end
                NF5: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL5;
                          emul_max        = EMUL5;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL5;
                          emul_max        = EMUL5;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL5;
                          emul_max        = EMUL5;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL5;
                          emul_max        = EMUL5;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL5;
                          emul_max        = EMUL5;
                        end
                      endcase
                    end
                  endcase
                end
                NF6: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end                
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL6;
                          emul_max        = EMUL6;
                        end
                      endcase
                    end
                  endcase
                end
                NF7: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL7;
                          emul_max        = EMUL7;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL7;
                          emul_max        = EMUL7;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL7;
                          emul_max        = EMUL7;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL7;
                          emul_max        = EMUL7;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL7;
                          emul_max        = EMUL7;
                        end
                      endcase
                    end
                  endcase
                end
                NF8: begin
                  case({inst_funct3,csr_sew})
                    // 1:1
                    {SEW_8,SEW8},
                    {SEW_16,SEW16},
                    {SEW_32,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2,
                        LMUL1: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 2:1
                    {SEW_16,SEW8},
                    {SEW_32,SEW16}: begin            
                      case(csr_lmul)
                        LMUL1_4,
                        LMUL1_2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 4:1
                    {SEW_32,SEW8}: begin            
                      case(csr_lmul)
                        LMUL1_4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:2
                    {SEW_8,SEW16},
                    {SEW_16,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1_2,
                        LMUL1,
                        LMUL2: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                    // 1:4
                    {SEW_8,SEW32}: begin            
                      case(csr_lmul)
                        LMUL1,
                        LMUL2,
                        LMUL4: begin
                          emul_vd         = EMUL1;
                          emul_max_vd_vs2 = EMUL1;
                          emul_vd_nf      = EMUL8;
                          emul_max        = EMUL8;
                        end
                      endcase
                    end
                  endcase
                end
              endcase
            end
            US_WR: begin
              case(inst_nf)
                NF1: begin
                  emul_vd         = EMUL1;
                  emul_max_vd_vs2 = EMUL1;
                  emul_vd_nf      = EMUL1;
                  emul_max        = EMUL1;
                end
                NF2: begin
                  emul_vd         = EMUL2;
                  emul_max_vd_vs2 = EMUL2;
                  emul_vd_nf      = EMUL2;
                  emul_max        = EMUL2;
                end
                NF4: begin
                  emul_vd         = EMUL4;
                  emul_max_vd_vs2 = EMUL4;
                  emul_vd_nf      = EMUL4;
                  emul_max        = EMUL4;
                end
                NF8: begin
                  emul_vd         = EMUL8;
                  emul_max_vd_vs2 = EMUL8;
                  emul_vd_nf      = EMUL8;
                  emul_max        = EMUL8;
                end
              endcase
            end
            US_MK: begin
              case(csr_lmul)
                LMUL1_4,
                LMUL1_2,
                LMUL1,
                LMUL2,
                LMUL4,
                LMUL8: begin
                  emul_vd         = EMUL1;
                  emul_max_vd_vs2 = EMUL1;
                  emul_vd_nf      = EMUL1;
                  emul_max        = EMUL1;
                end
              endcase
            end
          endcase
        end

        CS: begin
          case(inst_nf)
            // EMUL_vd = ceil( inst_funct3/csr_sew*csr_lmul )
            // EMUL_max = NF*EMUL_vd
            NF1: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                  endcase
                end
              endcase
            end
            NF2: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                  endcase
                end
              endcase
            end
            NF3: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF4: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF5: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
              endcase
            end
            NF6: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end                
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF7: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
              endcase
            end
            NF8: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd         = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
              endcase
            end
          endcase
        end
        
        IU,
        IO: begin
          case(inst_nf)
            // EMUL_vd  = ceil( csr_lmul )
            // EMUL_vs2 = ceil( inst_funct3/csr_sew*csr_lmul )
            // emul_max_vd_vs2 = max(EMUL_vd,EMUL_vs2)
            // EMUL_max = NF*emul_max_vd_vs2
            NF1: begin
              case({inst_funct3,csr_sew})
                // 1:1
                // {vs2,vd}
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL8;
                      emul_vs2        = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL8;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL8;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL1;
                      emul_max        = EMUL1;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd         = EMUL8;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL8;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF2: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL4;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL2;
                      emul_max        = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd         = EMUL4;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL4;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF3: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL3;
                      emul_max        = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF4: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL1_2: begin    
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL2;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL4;
                      emul_max        = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd         = EMUL2;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL2;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF5: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL5;
                      emul_max        = EMUL5;
                    end
                  endcase
                end
              endcase
            end
            NF6: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end                
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL6;
                      emul_max        = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF7: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL7;
                      emul_max        = EMUL7;
                    end
                  endcase
                end
              endcase
            end
            NF8: begin
              case({inst_funct3,csr_sew})
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_lmul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_lmul)
                    LMUL1_4: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_lmul)
                    LMUL1: begin
                      emul_vd         = EMUL1;
                      emul_vs2        = EMUL1;
                      emul_max_vd_vs2 = EMUL1;
                      emul_vd_nf      = EMUL8;
                      emul_max        = EMUL8;
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

// get EEW 
  always_comb begin
    // initial
    eew_vd  = EEW_NONE;
    eew_vs2 = EEW_NONE;
    eew_max = EEW_NONE;  

    if (valid_lsu) begin  
      case(funct6_lsu.lsu_funct6.lsu_mop)
        US: begin
          case(funct6_lsu.lsu_funct6.lsu_umop)
            US_US,
            US_WR,
            US_FF: begin
              case(inst_funct3)
                SEW_8: begin
                  eew_vd          = EEW8;
                  eew_max         = EEW8;
                end
                SEW_16: begin
                  eew_vd          = EEW16;
                  eew_max         = EEW16;
                end
                SEW_32: begin
                  eew_vd          = EEW32;
                  eew_max         = EEW32;
                end
              endcase
            end
            US_MK: begin
              case(inst_funct3)
                SEW_8: begin
                  eew_vd          = EEW1;
                  eew_max         = EEW1;
                end
              endcase
            end
          endcase
        end
        CS: begin
          case(inst_funct3)
            SEW_8: begin
              eew_vd          = EEW8;
              eew_max         = EEW8;
            end
            SEW_16: begin
              eew_vd          = EEW16;
              eew_max         = EEW16;
            end
            SEW_32: begin
              eew_vd          = EEW32;
              eew_max         = EEW32;
            end
          endcase
        end
        IU,
        IO: begin
          case({inst_funct3,csr_sew})
            {SEW_8,SEW8}: begin
              eew_vd          = EEW8;
              eew_vs2         = EEW8;
              eew_max         = EEW8;
            end
            {SEW_8,SEW16}: begin
              eew_vd          = EEW16;
              eew_vs2         = EEW8;
              eew_max         = EEW16;
            end
            {SEW_8,SEW32}: begin
              eew_vd          = EEW32;
              eew_vs2         = EEW8;
              eew_max         = EEW32;
            end
            {SEW_16,SEW8}: begin
              eew_vd          = EEW8;
              eew_vs2         = EEW16;
              eew_max         = EEW16;
            end
            {SEW_16,SEW16}: begin
              eew_vd          = EEW16;
              eew_vs2         = EEW16;
              eew_max         = EEW16;
            end
            {SEW_16,SEW32}: begin
              eew_vd          = EEW32;
              eew_vs2         = EEW16;
              eew_max         = EEW32;
            end
            {SEW_32,SEW8}: begin
              eew_vd          = EEW8;
              eew_vs2         = EEW32;
              eew_max         = EEW32;
            end
            {SEW_32,SEW16}: begin
              eew_vd          = EEW16;
              eew_vs2         = EEW32;
              eew_max         = EEW32;
            end
            {SEW_32,SEW32}: begin
              eew_vd          = EEW32;
              eew_vs2         = EEW32;
              eew_max         = EEW32;
            end
          endcase
        end
      endcase
    end
  end

//  
// instruction encoding error check
//
  assign inst_encoding_correct = check_special&check_common;

  // check whether vd overlaps v0 when vm=0
  // check_vd_overlap_v0=1 means that vd does NOT overlap v0
  assign check_vd_overlap_v0 = (((inst_vm==1'b0)&(inst_vd!='b0)) | (inst_vm==1'b1));

  // check whether vd partially overlaps vs2 with EEW_vd<EEW_vs2
  // check_vd_part_overlap_vs2=1 means that vd group does NOT overlap vs2 group partially
  // used in regular index load/store
  always_comb begin
    check_vd_part_overlap_vs2     = 'b0;          
    
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

  // vd cannot overlap vs2
  // check_vd_overlap_vs2=1 means that vd group does NOT overlap vs2 group fully
  // used in segment index load/store
  assign vd_index_start = {1'b0,inst_vd};
  assign vd_index_end = {1'b0,inst_vd} + emul_vd_nf;

  always_comb begin                                                             
    check_vd_overlap_vs2 = 'b0;          
    
    case(emul_vs2)
      EMUL1: begin
        check_vd_overlap_vs2 = ({1'b0,inst_vs2}<vd_index_start) || 
                               ({1'b0,inst_vs2}>vd_index_end);          
      end
      EMUL2: begin
        check_vd_overlap_vs2 = ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:1]}<vd_index_start[`REGFILE_INDEX_WIDTH:1]) || 
                               ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:1]}>vd_index_end[`REGFILE_INDEX_WIDTH:1]);          
      end
      EMUL4: begin
        check_vd_overlap_vs2 = ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:2]}<vd_index_start[`REGFILE_INDEX_WIDTH:2]) || 
                               ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:2]}>vd_index_end[`REGFILE_INDEX_WIDTH:2]);          
      end
      EMUL8 : begin
        check_vd_overlap_vs2 = ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:3]}<vd_index_start[`REGFILE_INDEX_WIDTH:3]) || 
                               ({1'b0,inst_vs2[`REGFILE_INDEX_WIDTH-1:3]}>vd_index_end[`REGFILE_INDEX_WIDTH:3]);          
      end
    endcase
  end

  // check whether vs2 partially overlaps vd for EEW_vd:EEW_vs2=2:1
  // used in regular index load/store
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

  // check whether vs2 partially overlaps vd for EEW_vd:EEW_vs2=4:1
  // used in regular index load/store
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

    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_REGULAR: begin
            check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0 : 1'b1;
          end
          US_WHOLE_REGISTER: begin
            check_special = inst_vm&((inst_opcode==LOAD)||((inst_opcode==STORE)&(inst_funct3==SEW_8)));
          end
          US_MASK: begin
            check_special = inst_vm&(inst_funct3==SEW_8)&(inst_funct6[5:3]=='b0);
          end
          US_FAULT_FIRST: begin
            check_special = check_vd_overlap_v0&(inst_opcode==LOAD);
          end
        endcase
      end
      
      CONSTANT_STRIDE: begin
        check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0 : 1'b1;
      end
      
      UNORDERED_INDEX,
      ORDERED_INDEX: begin
        if (inst_nf==NF1) begin
          case({inst_funct3,csr_sew})
            // EEW_vs2:EEW_vd = 1:1
            {SEW_8,SEW8},
            {SEW_16,SEW16},
            {SEW_32,SEW32}: begin            
              check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0 : 1'b1;
            end
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16},            
            // 4:1
            {SEW_32,SEW8}: begin            
              check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0&check_vd_part_overlap_vs2 : 1'b1;
            end
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32}: begin            
              check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0&check_vs2_part_overlap_vd_2_1 : 1'b1;
            end
            // 1:4
            {SEW_8,SEW32}: begin            
              check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0&check_vs2_part_overlap_vd_4_1 : 1'b1;
            end
          endcase
        end
        else begin
          // segment indexed ld, vd group cannot overlap vs2 group fully
          check_special = (inst_opcode==LOAD) ? check_vd_overlap_v0&check_vd_overlap_vs2 : 1'b1;
        end        
      end
    endcase
  end

  //check common requirements for all instructions
  assign check_common = check_vd_align&check_vs2_align&check_vd_in_range&check_sew&check_lmul&check_evl_not_0&check_vstart_sle_evl;

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
  
  // check vd/vs3 is in 0-31 for segment load/store
  always_comb begin
    check_vd_in_range = 'b0;
    
    case(emul_vd_nf)
      EMUL1: check_vd_in_range = 'b1;  // Always in range
      EMUL2: check_vd_in_range = (inst_vd<=5'd30);
      EMUL3: check_vd_in_range = (inst_vd<=5'd29);
      EMUL4: check_vd_in_range = (inst_vd<=5'd28);
      EMUL5: check_vd_in_range = (inst_vd<=5'd27);
      EMUL6: check_vd_in_range = (inst_vd<=5'd26);
      EMUL7: check_vd_in_range = (inst_vd<=5'd25);
      EMUL8: check_vd_in_range = (inst_vd<=5'd24);
    endcase
  end

  // check the validation of EEW
  assign check_sew = (eew_max != EEW_NONE);
    
  // check the validation of EMUL
  assign check_lmul = (emul_max != EMUL_NONE);

  // get evl
  always_comb begin
    evl = csr_vl;
    
    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_WHOLE_REGISTER: begin
            // evl = NFIELD*VLEN/EEW
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
          US_MASK: begin       
            // evl = ceil(vl/8)
            evl = {3'b0,csr_vl[`VL_WIDTH-1:3]} + (csr_vl[2:0]!='b0);
          end
        endcase
      end
    endcase
  end
  
  // check evl is not 0
  assign check_evl_not_0 = evl!='b0;

  // check vstart < evl
  assign check_vstart_sle_evl = {1'b0,csr_vstart} < evl;

  `ifdef ASSERT_ON
    `ifdef TB_SUPPORT
      `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))
      else $warning("pc(0x%h) instruction will be discarded directly.\n",$sampled(inst.inst_pc));
    `else
      `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))
      else $warning("This instruction will be discarded directly.\n");
    `endif
  `endif
  
  // uop_index_remain as the base uop_index
  assign uop_index_base = uop_index_remain;

  // calculate the uop_index used in decoding uops 
  generate
    for(j=0;j<`NUM_DE_UOP;j++) begin: GET_UOP_INDEX
      assign uop_index_current[j] = j[`UOP_INDEX_WIDTH-1:0]+uop_index_base;
    end
  endgenerate

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
      EMUL3: begin
        uop_index_max = 'd2;
      end
      EMUL4: begin
        uop_index_max = 'd3;
      end
      EMUL5: begin
        uop_index_max = 'd4;
      end
      EMUL6: begin
        uop_index_max = 'd5;
      end
      EMUL7: begin
        uop_index_max = 'd6;
      end
      EMUL8: begin
        uop_index_max = 'd7;
      end
    endcase
  end

  // generate uop valid
  always_comb begin        
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_VALID
      if ((uop_index_current[i]<={1'b0,uop_index_max})&valid_lsu) 
        uop_valid[i]  = inst_encoding_correct;
      else
        uop_valid[i]  = 'b0;
    end
  end

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
      uop_funct6[i] = funct6_lsu;
    end
  end

  // allocate uop to execution unit
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_EXE_UNIT
      uop_exe_unit[i] = LSU;
    end
  end

  // update uop class
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_CLASS
      // initial 
      uop_class[i] = XXX;
      
      case(inst_opcode) 
        LOAD:begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop_class[i] = XXX;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop_class[i] = XVX;
            end
          endcase
        end

        STORE: begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop_class[i] = VXX;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop_class[i] = VVX;
            end
          endcase
        end
      endcase
    end
  end

  // update vector_csr and vstart
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_VCSR
      // initial 
      vector_csr[i] = vector_csr_lsu;

      // update vstart of every uop
      if(funct6_lsu.lsu_funct6.lsu_is_seg!=IS_SEGMENT) begin
        case(eew_max)
          EEW8: begin
            vector_csr[i].vstart  = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}};
          end
          EEW16: begin
            vector_csr[i].vstart  = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}};
          end
          EEW32: begin
            vector_csr[i].vstart  = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}};
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
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_IGNORE
      ignore_vma[i] = 'b0;
      ignore_vta[i] = 'b0;
    end
  end

  // update force_vma_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_FORCE_VMA
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
      force_vma_agnostic[i] = (check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE);
    end
  end

  // update force_vta_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_FORCE_VTA
      force_vta_agnostic[i] = (eew_vd==EEW1) |   // Mask destination tail elements are always treated as tail-agnostic
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
                                  ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE));
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
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_V0
      v0_valid[i] = 'b1;
    end
  end

  // update vd_index and eew 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VD
      // initial
      vd_index[i] = 'b0;
      vd_eew[i]   = eew_vd;

      case(inst_funct6[2:0])
        UNIT_STRIDE: begin
          case(inst_umop)
            US_REGULAR,          
            US_FAULT_FIRST,
            US_WHOLE_REGISTER: begin
              vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
            end
            US_MASK: begin
              vd_index[i] = inst_vd;
            end
          endcase
        end

        CONSTANT_STRIDE: begin
          vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
        end
        
        UNORDERED_INDEX,
        ORDERED_INDEX: begin
          case({inst_funct3,csr_sew})
            // EEW_vs2:EEW_vd=1:1
            {SEW_8,SEW8},
            {SEW_16,SEW16},
            {SEW_32,SEW32},            
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32},
            // 1:4
            {SEW_8,SEW32}: begin            
              vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
            end
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16},
            // 4:1
            {SEW_32,SEW8}: begin            
              case({emul_vs2,emul_vd})
                {EMUL1,EMUL1}: begin
                  vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                end
                {EMUL2,EMUL1},
                {EMUL4,EMUL2},
                {EMUL8,EMUL4}: begin
                  vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                end
                {EMUL4,EMUL1},
                {EMUL8,EMUL2}: begin
                  vd_index[i] = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:2];
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // update vd_valid and vs3_valid
  // some uop need vd as the vs3 vector operand
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VD_VS3_VALID
      // initial
      vs3_valid[i] = 'b0;
      vd_valid[i]  = 'b0;

      if(inst_opcode==STORE)
        vs3_valid[i] = 1'b1;
      else
        vd_valid[i]  = 1'b1;
    end
  end

  // update vs1 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS1
      vs1[i]             = 'b0;
      vs1_eew[i]         = EEW_NONE;
      vs1_index_valid[i] = 'b0;
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS1_OPCODE
      // initial
      vs1_opcode_valid[i] = 'b0;
    end
  end

  // update vs2 index, eew and valid  
  always_comb begin
    // initial
    vs2_index = 'b0; 
    vs2_eew   = EEW_NONE;
    vs2_valid = 'b0; 
    
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_VS2
      case(inst_funct6[2:0])
        UNORDERED_INDEX,
        ORDERED_INDEX: begin
          case({inst_funct3,csr_sew})
            // EEW_vs2:EEW_vd=1:1
            {SEW_8,SEW8},
            {SEW_16,SEW16},
            {SEW_32,SEW32},            
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16},            
            // 4:1
            {SEW_32,SEW8}: begin    
              case(emul_vs2)
                EMUL1: begin
                  vs2_index[i] = inst_vs2;
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL2: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][0];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL4: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][1:0];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL8: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][2:0];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
              endcase
            end
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32}: begin
              case(emul_vs2)
                EMUL1: begin
                  vs2_index[i] = inst_vs2;
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL2: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][1];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL4: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][2:1];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
              endcase
            end
            // 1:4
            {SEW_8,SEW32}: begin     
              case(emul_vs2)
                EMUL1: begin
                  vs2_index[i] = inst_vs2;
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
                end
                EMUL2: begin
                  vs2_index[i] = inst_vs2+uop_index_current[i][2];
                  vs2_eew[i]   = eew_vs2; 
                  vs2_valid[i] = 1'b1; 
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
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_RD
      rd_index[i]         = 'b0;
      rd_index_valid[i]   = 'b0;
    end
  end

  // update rs1_data and rs1_data_valid 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_RS1
      rs1_data[i]         = 'b0;
      rs1_data_valid[i]   = 'b0;
    end
  end

  // update uop index
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: ASSIGN_UOP_INDEX
      uop_index[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
    end
  end

  // update last_uop valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_UOP_LAST
      first_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == 'b0;
      last_uop_valid[i] = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
    end
  end

  // update segment_index valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i++) begin: GET_SEG_INDEX
      // initial 
      seg_field_index[i] = 'b0;

      if(funct6_lsu.lsu_funct6.lsu_is_seg==IS_SEGMENT) begin
        case(inst_nf)
          NF2: begin
            case(emul_max_vd_vs2)
              EMUL2: seg_field_index[i] = {1'b0,uop_index_current[i][0]};
              EMUL4: seg_field_index[i] = uop_index_current[i][1:0];
            endcase
          end
          NF3,
          NF4: begin
            if (emul_max_vd_vs2==EMUL2)
              seg_field_index[i] = {1'b0,uop_index_current[i][0]};
          end
        endcase
      end
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
