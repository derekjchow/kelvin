
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
  logic   [`VL_WIDTH-1:0]                         vs_evl;
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
  FUNCT6_u                                        uop_funct6;

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
    uop_funct6.lsu_funct6.lsu_is_store = IS_LOAD;
    valid_lsu_opcode                   = 'b0;

    case(inst_opcode)
      LOAD: begin
        uop_funct6.lsu_funct6.lsu_is_store = IS_LOAD;
        valid_lsu_opcode                   = 1'b1;
      end
      STORE: begin
        uop_funct6.lsu_funct6.lsu_is_store = IS_STORE;
        valid_lsu_opcode                   = 1'b1;
      end
    endcase
  end

  // lsu_mop distinguishes unit-stride, constant-stride, unordered index, ordered index
  // lsu_umop identifies what unit-stride instruction belong to when lsu_mop=US
  always_comb begin
    uop_funct6.lsu_funct6.lsu_mop    = US;
    uop_funct6.lsu_funct6.lsu_umop   = US_US;
    uop_funct6.lsu_funct6.lsu_is_seg = NONE;
    valid_lsu_mop                    = 'b0;
    
    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_REGULAR: begin          
            uop_funct6.lsu_funct6.lsu_mop    = US;
            uop_funct6.lsu_funct6.lsu_umop   = US_US;
            valid_lsu_mop                    = 1'b1;
            uop_funct6.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
          end
          US_WHOLE_REGISTER: begin
            uop_funct6.lsu_funct6.lsu_mop    = US;
            uop_funct6.lsu_funct6.lsu_umop   = US_WR;
            valid_lsu_mop                    = 1'b1;
          end
          US_MASK: begin
            uop_funct6.lsu_funct6.lsu_mop    = US;
            uop_funct6.lsu_funct6.lsu_umop   = US_MK;
            valid_lsu_mop                    = 1'b1;
          end
          US_FAULT_FIRST: begin
            uop_funct6.lsu_funct6.lsu_mop    = US;
            uop_funct6.lsu_funct6.lsu_umop   = US_FF;
            valid_lsu_mop                    = 1'b1;
            uop_funct6.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
          end
        endcase
      end
      UNORDERED_INDEX: begin
        uop_funct6.lsu_funct6.lsu_mop    = IU;
        valid_lsu_mop                    = 1'b1;
        uop_funct6.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
      end
      CONSTANT_STRIDE: begin
        uop_funct6.lsu_funct6.lsu_mop    = CS;
        valid_lsu_mop                    = 1'b1;
        uop_funct6.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
      end
      ORDERED_INDEX: begin
        uop_funct6.lsu_funct6.lsu_mop    = IO;
        valid_lsu_mop                    = 1'b1;
        uop_funct6.lsu_funct6.lsu_is_seg = (inst_nf!=NF1) ? IS_SEGMENT : NONE;
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
      case(uop_funct6.lsu_funct6.lsu_mop)
        US: begin
          case(uop_funct6.lsu_funct6.lsu_umop)
            US_US: begin
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
      case(uop_funct6.lsu_funct6.lsu_mop)
        US: begin
          case(uop_funct6.lsu_funct6.lsu_umop)
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
            check_special = inst_vm&(inst_funct3==SEW_8);
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
    vs_evl = csr_vl;
    
    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_WHOLE_REGISTER: begin
            // evl = NFIELD*VLEN/EEW
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
          US_MASK: begin       
            // evl = ceil(vl/8)
            vs_evl = {3'b0,csr_vl[`VL_WIDTH-1:3]} + (csr_vl[2:0]!='b0);
          end
        endcase
      end
    endcase
  end
  
  // check evl is not 0
  assign check_evl_not_0 = vs_evl!='b0;

  // check vstart < evl
  assign check_vstart_sle_evl = {1'b0,csr_vstart} < vs_evl;

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
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VALID
      if ((uop_index_current[i]<={1'b0,uop_index_max})&valid_lsu) 
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
      uop[i].uop_funct6 = uop_funct6;
    end
  end

  // allocate uop to execution unit
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      uop[i].uop_exe_unit = LSU;
    end
  end

  // update uop class
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_CLASS
      // initial 
      uop[i].uop_class = XXX;
      
      case(inst_opcode) 
        LOAD:begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop[i].uop_class = XXX;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop[i].uop_class = XVX;
            end
          endcase
        end

        STORE: begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop[i].uop_class = VXX;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop[i].uop_class = VVX;
            end
          endcase
        end
      endcase
    end
  end

  // update vector_csr and vstart
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VCSR
      uop[i].vector_csr = vector_csr_lsu;

      // update vstart of every uop
      if(uop_funct6.lsu_funct6.lsu_is_seg!=IS_SEGMENT) begin
        case(eew_max)
          EEW8: begin
            uop[i].vector_csr.vstart  = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLENB)){1'b0}}};
          end
          EEW16: begin
            uop[i].vector_csr.vstart  = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`HWORD_WIDTH)){1'b0}}};
          end
          EEW32: begin
            uop[i].vector_csr.vstart  = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}}<csr_vstart ? csr_vstart : 
                                        {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],{($clog2(`VLEN/`WORD_WIDTH)){1'b0}}};
          end
        endcase
      end
    end
  end
  
  // update vs_evl
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EVL
      uop[i].vs_evl = vs_evl;
    end
  end

  // update ignore_vma and ignore_vta
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_IGNORE
      uop[i].ignore_vma = 'b0;
      uop[i].ignore_vta = 'b0;
    end
  end

  // update force_vma_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_FORCE_VMA
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
      uop[i].force_vma_agnostic = (check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE);
    end
  end

  // update force_vta_agnostic
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_FORCE_VTA
      uop[i].force_vta_agnostic = (eew_vd==EEW1) |   // Mask destination tail elements are always treated as tail-agnostic
      //When source and destination registers overlap and have different EEW, the instruction is mask- and tail-agnostic.
                                  ((check_vd_overlap_vs2==1'b0)&(eew_vd!=eew_vs2)&(eew_vd!=EEW_NONE)&(eew_vs2!=EEW_NONE));
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
      uop[i].v0_valid = 'b1;
    end
  end

  // update vd_index and eew 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD
      // initial
      uop[i].vd_index = 'b0;
      uop[i].vd_eew   = eew_vd;

      case(inst_funct6[2:0])
        UNIT_STRIDE: begin
          case(inst_umop)
            US_REGULAR,          
            US_FAULT_FIRST,
            US_WHOLE_REGISTER: begin
              uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
            end
            US_MASK: begin
              uop[i].vd_index = inst_vd;
            end
          endcase
        end

        CONSTANT_STRIDE: begin
          uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
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
              uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
            end
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16},
            // 4:1
            {SEW_32,SEW8}: begin            
              case({emul_vs2,emul_vd})
                {EMUL1,EMUL1}: begin
                  uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
                end
                {EMUL2,EMUL1},
                {EMUL4,EMUL2},
                {EMUL8,EMUL4}: begin
                  uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:1];
                end
                {EMUL4,EMUL1},
                {EMUL8,EMUL2}: begin
                  uop[i].vd_index = inst_vd + uop_index_current[i][`UOP_INDEX_WIDTH-1:2];
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
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD_VS3_VALID
      // initial
      uop[i].vs3_valid = 'b0;
      uop[i].vd_valid  = 'b0;

      if(inst_opcode==STORE)
        uop[i].vs3_valid = 1'b1;
      else
        uop[i].vd_valid  = 1'b1;
    end
  end

  // update vs1 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1
      uop[i].vs1             = 'b0;
      uop[i].vs1_eew         = EEW_NONE;
      uop[i].vs1_index_valid = 'b0;
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1_OPCODE
      // initial
      uop[i].vs1_opcode_valid = 'b0;
    end
  end

  // update vs2 index, eew and valid  
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS2
      // initial
      uop[i].vs2_index        = 'b0; 
      uop[i].vs2_eew          = eew_vs2; 
      uop[i].vs2_valid        = 'b0; 
    
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
                  uop[i].vs2_index = inst_vs2;
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][0];
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL4: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][1:0];
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL8: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][2:0];
                  uop[i].vs2_valid = 1'b1; 
                end
              endcase
              //uop[i].vs2_index = inst_vs2+uop_index_current[i];
              //uop[i].vs2_valid = 1'b1; 
            end
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32}: begin
              case(emul_vs2)
                EMUL1: begin
                  uop[i].vs2_index = inst_vs2;
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][1];
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL4: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][2:1];
                  uop[i].vs2_valid = 1'b1; 
                end
              endcase
            end
            // 1:4
            {SEW_8,SEW32}: begin     
              case(emul_vs2)
                EMUL1: begin
                  uop[i].vs2_index = inst_vs2;
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+uop_index_current[i][2];
                  uop[i].vs2_valid = 1'b1; 
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
      uop[i].rd_index         = 'b0;
      uop[i].rd_index_valid   = 'b0;
    end
  end

  // update rs1_data and rs1_data_valid 
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1
      uop[i].rs1_data         = 'b0;
      uop[i].rs1_data_valid   = 'b0;
    end
  end

  // update uop index
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: ASSIGN_UOP_INDEX
      uop[i].uop_index = uop_index_current[i][`UOP_INDEX_WIDTH-1:0];
    end
  end

  // update last_uop valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_LAST
      uop[i].first_uop_valid = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == 'b0;
      uop[i].last_uop_valid = uop_index_current[i][`UOP_INDEX_WIDTH-1:0] == uop_index_max;
    end
  end

  // update segment_index valid
  always_comb begin
    for(int i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_SEG_INDEX
      uop[i].seg_field_index = 'b0;

      if(uop_funct6.lsu_funct6.lsu_is_seg==IS_SEGMENT) begin
        case(inst_nf)
          NF2: begin
            case(emul_max_vd_vs2)
              EMUL2: uop[i].seg_field_index = {2'b0,uop_index_current[i][0]};
              EMUL4: uop[i].seg_field_index = {1'b0,uop_index_current[i][1:0]};
            endcase
          end
          NF3,
          NF4: begin
            if (emul_max_vd_vs2==EMUL2)
              uop[i].seg_field_index = {2'b0,uop_index_current[i][0]};
          end
        endcase
      end
    end
  end

endmodule
