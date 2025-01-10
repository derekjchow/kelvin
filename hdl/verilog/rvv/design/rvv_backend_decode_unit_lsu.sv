
`include "rvv_backend.svh"

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
  input   RVVcmd                              inst;
  input   logic       [`UOP_INDEX_WIDTH-1:0]  uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]       uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]       uop;

//
// internal signals
//
  // split INST_t struct signals
  logic     [`PC_WIDTH-1:0]                         inst_pc;
  logic     [`FUNCT6_WIDTH-1:0]                     inst_funct6;      // inst original encoding[31:26]           
  NFILED_e  [`NFIELD_WIDTH-1:0]                     inst_nr;          // inst original encoding[17:15]
  logic     [`VM_WIDTH-1:0]                         inst_vm;          // inst original encoding[25]      
  logic     [`VS2_WIDTH-1:0]                        inst_vs2;         // inst original encoding[24:20]
  logic     [`UMOP_WIDTH-1:0]                       inst_umop;        // inst original encoding[24:20]
  logic     [`IMM_WIDTH-1:0]                        inst_imm;         // inst original encoding[19:15]
  logic     [`FUNCT3_WIDTH-1:0]                     inst_funct3;      // inst original encoding[14:12]
  logic     [`VD_WIDTH-1:0]                         inst_vd;          // inst original encoding[11:7]
  RVVOpCode                                         inst_opcode;      // inst original encoding[6:0]
  RVVConfigState                                    vector_csr_lsu;
  logic     [`VSTART_WIDTH-1:0]                     csr_vstart;
  RVVSEW                                            csr_sew;
  RVVLMUL                                           csr_lmul;
  EMUL_t                                            emul_vd;          
  EMUL_t                                            emul_vs2;          
  EMUL_t                                            emul_max;          
  EEW_e                                             eew_vd;          
  EEW_e                                             eew_vs2;          
  EEW_e                                             eew_rs2;
  EEW_e                                             eew_max;          
  logic                                             inst_encoding_correct;
  logic                                             check_special;
  logic                                             check_vd_overlap_v0;
  logic                                             check_vd_part_overlap_vs2;
  logic                                             check_vd_overlap_vs2;
  logic                                             check_vs2_part_overlap_vd_2_1;
  logic                                             check_vs2_part_overlap_vd_4_1;
  logic                                             check_common;
  logic                                             check_vd_align;
  logic                                             check_vs2_align;
  logic                                             check_sew;
  logic     [`UOP_INDEX_WIDTH-1:0]                  uop_vstart;         
  logic     [`UOP_INDEX_WIDTH-1:0]                  uop_index_base;         
  logic     [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0] uop_index_current;   
  logic     [`UOP_INDEX_WIDTH-1:0]                  uop_index_max;         
   
  // convert logic to enum/union
  FUNCT6_u                                          funct6_ari;

  // use for for-loop 
  integer                                           i;
  
  // local parameter
  localparam  UNIT_STRIDE       = 3'b000;
  localparam  UNORDERED_INDEX   = 3'b001;
  localparam  CONSTANT_STRIDE   = 3'b010;
  localparam  ORDERED_INDEX     = 3'b011;

  localparam  US_REGULAR        = 5'b00000;
  localparam  US_WHOLE_REGISTER = 5'b01000;
  localparam  US_MASK           = 5'b01011;
  localparam  US_FAULT_FIRST    = 5'b10000;
  
  localparam  SEW_8             = 3'b000;
  localparam  SEW_16            = 3'b101;
  localparam  SEW_32            = 3'b110;

//
// decode
//
  assign inst_pc        = inst.inst_pc;
  assign inst_funct6    = inst.bits[24:19];
  assign inst_nf        = inst_funct6[3+:`NFIELD_WIDTH];
  assign inst_vm        = inst.bits[18];
  assign inst_vs2       = inst.bits[17:13];
  assign inst_umop      = inst.bits[17:13];
  assign inst_imm       = inst.bits[12:8];
  assign inst_funct3    = inst.bits[7:5];
  assign inst_vd        = inst.bits[4:0];
  assign inst_opcode    = inst.opcode;
  assign vector_csr_lsu = inst.arch_state;
  assign csr_vstart     = inst.arch_state.vstart;
  assign csr_sew        = inst.arch_state.sew;
  assign csr_lmul       = inst.arch_state.lmul;
  
// decode funct6
  // identify load or store
  always_comb begin
    funct6_ari.lsu_funct6.lsu_is_store = 'b0;

    case(inst_opcode)
      LOAD: begin
        funct6_ari.lsu_funct6.lsu_is_store = IS_LOAD;
      end
      STORE: begin
        funct6_ari.lsu_funct6.lsu_is_store = IS_STORE;
      end
    endcase
  end

  // lsu_mop distinguishes unit-stride, constant-stride, unordered index, ordered index
  // lsu_umop identifies what unit-stride instruction belong to when lsu_mop=US
  always_comb begin
    funct6_ari.lsu_funct6.lsu_mop  = 'b0;
    funct6_ari.lsu_funct6.lsu_umop = 'b0;
    
    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_REGULAR: begin          
            if (inst_nf==NF1) begin
              funct6_ari.lsu_funct6.lsu_mop  = US;
              funct6_ari.lsu_funct6.lsu_umop = US_US;
            end
            else begin
              // segment unit-stride instruction is implemented by constant-stride instruction
              funct6_ari.lsu_funct6.lsu_mop  = CS;
            end
          end
          US_WHOLE_REGISTER: begin
            funct6_ari.lsu_funct6.lsu_mop  = US;
            funct6_ari.lsu_funct6.lsu_umop = US_WR;
          end
          US_MASK: begin
            funct6_ari.lsu_funct6.lsu_mop  = US;
            funct6_ari.lsu_funct6.lsu_umop = US_MK;
          end
          US_FAULT_FIRST: begin
            // fault-only-first load will be regarded as regular unit-stride load.
            if (inst_opcode==LOAD) begin
              if (inst_nf==NF1) begin
                funct6_ari.lsu_funct6.lsu_mop  = US;
                funct6_ari.lsu_funct6.lsu_umop = US_US;
              end
              else begin
                // segment unit-stride instruction is implemented by constant-stride instruction
                funct6_ari.lsu_funct6.lsu_mop  = CS;
              end
            end
          end
        endcase
      end
      UNORDERED_INDEX: begin
        funct6_ari.lsu_funct6.lsu_mop = IU;
      end
      CONSTANT_STRIDE: begin
        funct6_ari.lsu_funct6.lsu_mop = CS;
      end
      ORDERED_INDEX: begin
        funct6_ari.lsu_funct6.lsu_mop = IO;
      end
    endcase
  end

  // reserved
  assign funct6_ari.lsu_funct6.reserved = 'b0;
  
// get EMUL
  always_comb begin
    // initial
    emul_vd          = 'b0;
    emul_vs2         = 'b0;
    emul_max         = 'b0;

    if (inst_valid==1'b1) begin  
      case(funct6_ari.lsu_funct6.lsu_mop)
        US: begin
          case(funct6_ari.lsu_funct6.lsu_umop)
            US_US: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
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
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL8;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL8;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                  endcase
                end
              endcase
            end
            US_WR: begin
              case(inst_nf)
                NF1: begin
                  emul_vd     = EMUL1;
                  emul_max    = EMUL1;
                end
                NF2: begin
                  emul_vd     = EMUL2;
                  emul_max    = EMUL2;
                end
                NF4: begin
                  emul_vd     = EMUL4;
                  emul_max    = EMUL4;
                end
                NF8: begin
                  emul_vd     = EMUL8;
                  emul_max    = EMUL8;
                end
              endcase
            end
            US_MK: begin
              case(csr_mul)
                LMUL1_4,
                LMUL1_2,
                LMUL1,
                LMUL2,
                LMUL4,
                LMUL8: begin
                  emul_vd     = EMUL1;
                  emul_max    = EMUL1;
                end
              endcase
            end
          endcase
        end

        CS: begin
          case(inst_nf)
            NF1: begin
              case(inst_funct3,csr_sew)
                // EMUL_vd  = ceil( inst_funct3/csr_sew*csr_mul )
                // EMUL_max = EMUL_vd*inst_nf
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
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
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL8;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL8;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL4;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL2;
                    end
                  endcase
                end
              endcase
            end
            NF2: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL4;
                    end
                  endcase
                end
              endcase
            end
            NF3: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF4: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL8: begin
                      emul_vd     = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF5: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
              endcase
            end
            NF6: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end                
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF7: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
              endcase
            end
            NF8: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1,
                    LMUL2: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1,
                    LMUL2,
                    LMUL4: begin
                      emul_vd     = EMUL1;
                      emul_max    = EMUL8;
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
            NF1: begin
              case(inst_funct3,csr_sew)
                // EMUL_vd  = ceil( csr_mul )
                // EMUL_vs2 = ceil( inst_funct3/csr_sew*csr_mul )
                // EMUL_max = max(EMUL_vd,EMUL_vs2)*inst_nf
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
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
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
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
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL1;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL4;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL8;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
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
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
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
            NF2: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL4;
                      emul_vs2    = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL4;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL4;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL2;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL4: begin
                      emul_vd     = EMUL4;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF3: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL3;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF4: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL2;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL4;
                    end
                    LMUL2: begin
                      emul_vd     = EMUL2;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
              endcase
            end
            NF5: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL5;
                    end
                  endcase
                end
              endcase
            end
            NF6: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end                
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL6;
                    end
                  endcase
                end
              endcase
            end
            NF7: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL7;
                    end
                  endcase
                end
              endcase
            end
            NF8: begin
              case(inst_funct3,csr_sew)
                // 1:1
                {SEW_8,SEW8},
                {SEW_16,SEW16},
                {SEW_32,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 2:1
                {SEW_16,SEW8},
                {SEW_32,SEW16}: begin            
                  case(csr_mul)
                    LMUL1_4,
                    LMUL1_2: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 4:1
                {SEW_32,SEW8}: begin            
                  case(csr_mul)
                    LMUL1_4: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:2
                {SEW_8,SEW16},
                {SEW_16,SEW32}: begin            
                  case(csr_mul)
                    LMUL1_2,
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
                      emul_max    = EMUL8;
                    end
                  endcase
                end
                // 1:4
                {SEW_8,SEW32}: begin            
                  case(csr_mul)
                    LMUL1: begin
                      emul_vd     = EMUL1;
                      emul_vs2    = EMUL1;
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
  end

// get EEW 
  always_comb begin
    // initial
    eew_vd          = 'b0;
    eew_vs2         = 'b0;
    eew_rs2         = 'b0;
    eew_max         = 'b0;  

    if (inst_valid==1'b1) begin  
      case(funct6_ari.lsu_funct6.lsu_mop)
        US: begin
          case(funct6_ari.lsu_funct6.lsu_umop)
            US_US,
            US_WR: begin
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
          case(inst_funct3,csr_sew)
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
  // check_vd_part_overlap_vs2=1 means that vd does NOT partially overlap vs2
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

  // vd cannot overlap vs2
  // check_vd_overlap_vs2=1 means that vd does NOT overlap vs2
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

  // check whether vs2 partially overlaps vd for EEW_vd:EEW_vs2=2:1
  always_comb begin
    check_vs2_part_overlap_vd_2_1       = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_2_1   = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b10)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b100)))
          check_vs2_part_overlap_vd_2_1 = 1'b1;
      end
    endcase
  end

  // check whether vs2 partially overlaps vd for EEW_vd:EEW_vs2=4:1
  always_comb begin
    check_vs2_part_overlap_vd_4_1       = 'b0;

    case(emul_vd)
      EMUL1: begin
        check_vs2_part_overlap_vd_4_1   = 1'b1;
      end
      EMUL2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
      EMUL4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b11)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
      EMUL8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b110)))
          check_vs2_part_overlap_vd_4_1 = 1'b1;
      end
    endcase
  end

  // start to check special requirements for every instructions
  always_comb 
    check_special = 'b0;

    case(inst_funct6[2:0])
      UNIT_STRIDE: begin
        case(inst_umop)
          US_REGULAR,
            if (inst_nf==NF1) begin
              check_special = check_vd_overlap_v0;
            end
          end
          US_WHOLE_REGISTER: begin
            if (inst_vm==1'b1) begin
              case(inst_nf)
                NF1,
                NF2,
                NF4,
                NF8: begin
                  if ((inst_opcode==LOAD)|((inst_opcode==STORE)&(inst_funct3==SEW_8)))
                    check_special = 1'b1;
                end
              endcase
            end
          end
          US_MASK: begin
            if ((inst_vm==1'b1)&(inst_funct3==SEW_8)) begin
              check_special = 1'b1;
            end
          end
          US_FAULT_FIRST: begin
            if (inst_opcode==LOAD)
              check_special = check_vd_overlap_v0;
          end
        endcase
      end
      
      CONSTANT_STRIDE: begin
         if (inst_nf==NF1) begin
          check_special = check_vd_overlap_v0;
        end
      end
      
      UNORDERED_INDEX,
      ORDERED_INDEX: begin
        if (inst_nf==NF1) begin
          case(inst_funct3,csr_sew)
            // EEW_vs2:EEW_vd = 1:1
            {SEW_8,SEW8},
            {SEW_16,SEW16},
            {SEW_32,SEW32}: begin            
              check_special = check_vd_overlap_v0;
            end
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16},            
            // 4:1
            {SEW_32,SEW8}: begin            
              check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2;
            end
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32}: begin            
              check_special = check_vd_overlap_v0&check_vs2_part_overlap_vsd_2_1;
            end
            // 1:4
            {SEW_8,SEW32}: begin            
              check_special = check_vd_overlap_v0&check_vs2_part_overlap_vsd_4_1;
            end
          endcase
        end
        else begin
          // segment indexed ld/st, vd cannot overlap vs2
          check_special = check_vd_overlap_v0&check_vd_overlap_vs2;
        end        
      end
    endcase
  end

  //check common requirements for all instructions
  assign check_common = check_vd_align&check_vs2_align&check_sew;

  // check whether vd is aligned to emul_vd
  always_comb begin
    check_vd_align = 'b0; 

    case(emul_vd)
      EMUL1: begin
        check_vd_align = 1'b1; 
      end
      EMUL2: begin
        if (inst_vd[0]==1'b0)
          check_vd_align = 1'b1; 
        
        `ifdef ASSERT_ON
          `rvv_expect(inst_vd[0]==1'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      EMUL4: begin
        if (inst_vd[1:0]==2'b0)
          check_vd_align = 1'b1; 
        
        `ifdef ASSERT_ON
          `rvv_expect(inst_vd[1:0]==2'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      EMUL8: begin
        if (inst_vd[2:0]==3'b0)
          check_vd_align = 1'b1; 
       
        `ifdef ASSERT_ON
          `rvv_expect(inst_vd[2:0]==3'b0)        
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
    endcase
  end

  // check whether vs2 is aligned to emul_vs2
  always_comb begin
    check_vs2_align = 'b0; 

    case(emul_vs2)
      EMUL1: begin
        check_vs2_align = 1'b1; 
      end
      EMUL2: begin
        if (inst_vs2[0]==1'b0)
          check_vs2_align = 1'b1; 
        
        `ifdef ASSERT_ON
          `rvv_expect(inst_vs2[0]==1'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      EMUL4: begin
        if (inst_vs2[1:0]==2'b0)
          check_vs2_align = 1'b1; 
        
        `ifdef ASSERT_ON
          `rvv_expect(inst_vs2[1:0]==2'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      EMUL8: begin
        if (inst_vs2[2:0]==3'b0)
          check_vs2_align = 1'b1; 
       
        `ifdef ASSERT_ON
          `rvv_expect(inst_vs2[2:0]==3'b0)        
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
    endcase
  end

  // check the validation of inst_funct3 for SEW
  always_comb begin
    check_sew = 'b0;
    
    case(inst_funct3)
      SEW_8,
      SEW_16,
      SEW_32: begin
        check_sew = 1'b1;
      end
      default: begin
        `ifdef ASSERT_ON
          $error("inst_funct3(%b) is not valid SEW.\n",inst_funct3);
        `endif
      end
    endcase
  end

  `ifdef ASSERT_ON
    `rvv_forbid((inst_valid==1'b1)&(inst_encoding_correct==1'b0))        
    else $error("check_special(%d) and check_common(%d) both should be 1.\n",check_special,check_common);
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
  for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_INDEX
    assign  uop_index_current[i]  = i[`UOP_INDEX_WIDTH-1:0]+uop_index_base;
  end

//
// split instruction to uops
//
  // get the max uop index 
  always_comb begin
    uop_index_max = 'b0;
    
    case(emul_max)
      EMUL1: begin
        uop_index_max = `UOP_INDEX_WIDTH'd0;
      end
      EMUL2: begin
        uop_index_max = `UOP_INDEX_WIDTH'd1;
      end
      EMUL4: begin
        uop_index_max = `UOP_INDEX_WIDTH'd3;
      end
      EMUL8: begin
        uop_index_max = `UOP_INDEX_WIDTH'd7;
      end
    endcase
  end

  // generate uop valid
  always_comb begin        
  for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VALID
    if (({1'b0,uop_index_current[i]}<=emul_max)&inst_valid) 
      uop_valid[i]  = inst_encoding_correct;
    else
      uop_valid[i]  = 'b0;
  end

  // assign uop pc
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_PC
      uop[i].uop_pc = inst_pc;
    end
  end

  // update uop funct3
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT3
      uop[i].uop_funct3           = inst_funct3;
    end
  end

  // update uop funct6
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT6
      uop[i].uop_funct6           = funct6_ari;
    end
  end

  // allocate uop to execution unit
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      uop[i].uop_exe_unit = LSU;
    end
  end

  // update uop class
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_CLASS
      // initial 
      uop[i].uop_class      = 'b0;
      
      case(inst_opcode) 
        LOAD:begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop[i].uop_class = X;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop[i].uop_class = VX;
            end
          endcase
        end

        STORE: begin
          case(inst_funct6[2:0])
            UNIT_STRIDE,
            CONSTANT_STRIDE: begin
              uop[i].uop_class = VX;
            end
            UNORDERED_INDEX,
            ORDERED_INDEX: begin
              uop[i].uop_class = VV;
            end
          endcase
        end
      endcase
    end
  end

  // update vector_csr and vstart
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VCSR
      uop[i].vector_csr               = vector_csr_lsu;

      // update vstart of every uop
      if((uop_index_remain=='b0)&(i=='b0))    // or: if(uop_index_current[i]==uop_vstart)
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

  // update vm field
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VM
      uop[i].vm = inst_vm;
    end
  end
  
  // some uop need v0 as the vector operand
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_V0
      uop[i].v0_valid           = 'b0;
    end
  end

  // update vd_index and eew 
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD
      // initial
      uop[i].vd_index = 'b0;
      uop[i].vd_eew   = eew_vd;

      case(inst_funct6[2:0])
        UNIT_STRIDE: begin
          case(inst_umop)
            US_REGULAR,          
            US_FAULT_FIRST,
            US_WHOLE_REGISTER: begin
              uop[i].vd_index = inst_vd + {'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0]};
            end
            US_MASK: begin
              uop[i].vd_index = inst_vd;
            end
          endcase
        end

        CONSTANT_STRIDE: begin
          uop[i].vd_index = inst_vd + {'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0]};
        end
        
        UNORDERED_INDEX,
        ORDERED_INDEX: begin
          case(inst_funct3,csr_sew)
            // EEW_vs2:EEW_vd=1:1
            {SEW_8,SEW8},
            {SEW_16,SEW16},
            {SEW_32,SEW32},            
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32},
            // 1:4
            {SEW_8,SEW32}: begin            
              uop[i].vd_index = inst_vd + {'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0]};
            end
            // 2:1
            {SEW_16,SEW8},
            {SEW_32,SEW16}: begin            
              uop[i].vd_index = inst_vd + {'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:1]};
            end
            // 4:1
            {SEW_32,SEW8}: begin            
              uop[i].vd_index = inst_vd + {'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1]};
            end
          endcase
        end
      endcase
    end
  end

  // update vd_valid and vs3_valid
  // some uop need vd as the vs3 vector operand
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD_VS3_VALID
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1
      uop[i].vs1             = 'b0;
      uop[i].vs1_eew         = 'b0;
      uop[i].vs1_index_valid = 'b0;
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1_OPCODE
      // initial
      uop[i].vs1_opcode_valid         = 'b0;
    end
  end

  // update vs2 index, eew and valid  
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS2
      // initial
      uop[i].vs2_index        = 'b0; 
      uop[i].vs2_eew          = 'b0; 
      uop[i].vs2_valid        = 'b0; 
    
      case(inst_funct6[2:0])
        UNORDERED_INDEX,
        ORDERED_INDEX: begin
          case(inst_funct3,csr_sew)
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
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[0]};
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL4: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[1:0]};
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL8: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[2:0]};
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
              endcase
            end
            // 1:2
            {SEW_8,SEW16},
            {SEW_16,SEW32}: begin
              case(emul_vs2)
                EMUL1: begin
                  uop[i].vs2_index = inst_vs2;
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[1]};
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL4: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[2:1]};
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
              endcase
            end
            // 1:4
            {SEW_8,SEW32}: begin     
              case(emul_vs2)
                EMUL1: begin
                  uop[i].vs2_index = inst_vs2;
                  uop[i].vs2_eew   = eew_vs2; 
                  uop[i].vs2_valid = 1'b1; 
                end
                EMUL2: begin
                  uop[i].vs2_index = inst_vs2+{'b0,uop_index_current[2]};
                  uop[i].vs2_eew   = eew_vs2; 
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RD
      uop[i].rd_index         = 'b0;
      uop[i].rd_index_valid   = 'b0;
    end
  end

  // update rs1_data and rs1_data_valid 
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1
      uop[i].rs1_data         = 'b0;
      uop[i].scalar_eew       = 'b0;
      uop[i].rs1_data_valid   = 'b0;
    end
  end

  // update uop index
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_INDEX
      uop[i].uop_index = uop_index_current[i];
    end
  end

  // update last_uop valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_LAST
      uop[i].last_uop_valid = uop_index_current[i] == uop_index_max;
    end
  end

endmodule
