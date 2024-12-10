
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
  input   INST_t                                  inst;
  input   logic       [`UOP_INDEX_WIDTH-1:0]      uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]           uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]           uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`PC_WIDTH-1:0]                         inst_pc;
  logic   [`FUNCT6_WIDTH-1:0]                     inst_funct6;      // inst original encoding[31:26]           
  logic   [`VM_WIDTH-1:0]                         inst_vm;          // inst original encoding[25]      
  logic   [`VS2_WIDTH-1:0]                        inst_vs2;         // inst original encoding[24:20]
  logic   [`VS1_WIDTH-1:0]                        inst_vs1;         // inst original encoding[19:15]
  logic   [`IMM_WIDTH-1:0]                        inst_imm;         // inst original encoding[19:15]
  logic   [`FUNCT3_WIDTH-1:0]                     inst_funct3;      // inst original encoding[14:12]
  logic   [`VD_WIDTH-1:0]                         inst_vd;          // inst original encoding[11:7]
  logic   [`RD_WIDTH-1:0]                         inst_rd;          // inst original encoding[11:7]
  VECTOR_CSR_t                                    vector_csr_ari;
  logic   [`VTYPE_VILL_WIDTH-1:0]                 vill;             // 0:not illegal, 1:illegal
  logic   [`VTYPE_VSEW_WIDTH-1:0]                 vsew;             // support: 000:SEW8, 001:SEW16, 010:SEW32
  logic   [`VTYPE_VLMUL_WIDTH-1:0]                vlmul;            // support: 110:LMUL1/4, 111:LMUL1/2, 000:LMUL1, 001:LMUL2, 010:LMUL4, 011:LMUL8  
  logic   [`VSTART_WIDTH-1:0]                     vstart;
  logic   [`XLEN-1:0] 	                          rs1_data;

  logic                                           valid_opi;
  logic                                           valid_opm;
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vd;          // 0000:emul=0, 0001:emul=1, 0010:emul=2,...  
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vs2;
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vs1;
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_max;
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs2;          
  EEW_e                                           eew_vs1;
  EEW_e                                           eew_scalar;
  EEW_e                                           eew_max;          
  logic                                           inst_encoding_correct;
  logic                                           check_special;
  logic                                           check_vd_overlap_v0;
  logic                                           check_vd_part_overlap_vs2;
  logic                                           check_vd_part_overlap_vs1;
  logic                                           check_vd_full_overlap_vs2;
  logic                                           check_vd_full_overlap_vs1;
  logic                                           check_vs2_part_overlap_vd;
  logic                                           check_vs1_part_overlap_vd;
  logic                                           check_common;
  logic                                           check_vd_align;
  logic                                           check_vs2_align;
  logic                                           check_vs1_align;
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_vstart;         
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_base;         
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH-1:0] uop_index_current;   
   
  // convert logic to enum/union
  EXE_FUNCT3_e                                    funct3_ari;
  FUNCT6_u                                        funct6_ari;
  OPM_VWXUNARY0_e                                 vs1_opcode_vwxunary;
  OPM_VXUNARY0_e                                  vs1_opcode_vxunary;
  OPM_VMUNARY0_e                                  vs1_opcode_vmunary;

  // use for for-loop 
  integer                                         i;

//
// decode
//
  assign inst_pc              = inst.inst_pc;
  assign inst_funct6          = inst.inst[26:21];
  assign inst_vm              = inst.inst[20];
  assign inst_vs2             = inst.inst[19:15];
  assign inst_vs1             = inst.inst[14:10];
  assign vs1_opcode_vwxunary  = inst.inst[14:10];
  assign vs1_opcode_vxunary   = inst.inst[14:10];
  assign vs1_opcode_vmunary   = inst.inst[14:10];
  assign inst_imm             = inst.inst[14:10];
  assign inst_funct3          = inst.inst[9:7];
  assign inst_vd              = inst.inst[6:2];
  assign inst_rd              = inst.inst[6:2];
  assign vector_csr_ari       = inst.vector_csr;
  assign vill                 = vector_csr_ari.vtype.vill;
  assign vsew                 = vector_csr_ari.vtype.vsew;
  assign vlmul                = vector_csr_ari.vtype.vlmul;
  assign vstart               = vector_csr_ari.vstart;
  assign rs1_data             = inst.rs1_data;
  
  // decode funct3
  assign funct3_ari           = inst_funct3;
  
  // decode arithmetic instruction funct6
  always_comb begin
    // initial the data
    funct6_ari                = 'b0;
    valid_opi                 = 'b0;
    valid_opm                 = 'b0;
    
    case(funct3_ari)
      OPIVV,
      OPIVX,
      OPIVI: begin
        funct6_ari.opi_funct6 = inst_funct6;
        valid_opi             = 1'b1;
      end

      OPMVV,
      OPMVX: begin
        funct6_ari.opm_funct6 = inst_funct6;
        valid_opm             = 1'b1;
      end
    endcase
  end

    ``ifdef ASSERT_ON
      `rvv_forbid((inst_valid=1'b1)&(funct3_ari==OPFVV)|(funct3_ari==OPFVF)|(funct3_ari==OPCFG))
      else $error("Unsupported funct3_ari=%s.\n",funct3_ari.name());
    `endif

  // get EMUL
  always_comb begin
    // initial
    emul_vd          = 'b0;
    emul_vs2         = 'b0;
    emul_vs1         = 'b0;
    emul_max         = 'b0;
    
    case(1'b1)
      valid_opi: begin
        // OPI* instruction
        case(funct6_ari.opi_funct6)
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
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VRSUB,
          VSLIDEDOWN: begin        
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPIVV: begin
                  case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(funct3_ari)
              OPIVV: begin
                  case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd4;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd8;
                  end
                endcase 
              end
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end
          
          VMSGTU,
          VMSGT: begin
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VMERGE_VMV: begin
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    if (inst_vm=='b0)
                      emul_vs2  = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              // vmv<nr>r.v instruction
              OPIVI: begin
                case(inst_vs1[2:0])
                  `NREG1: begin
                      emul_vd     = 4'd1;
                      emul_vs2    = 4'd1;
                      emul_max    = 4'd1;
                  end
                  `NREG2: begin
                      emul_vd     = 4'd2;
                      emul_vs2    = 4'd2;
                      emul_max    = 4'd2;
                  end
                  `NREG4: begin
                      emul_vd     = 4'd4;
                      emul_vs2    = 4'd4;
                      emul_max    = 4'd4;
                  end
                  `NREG8: begin
                      emul_vd     = 4'd8;
                      emul_vs2    = 4'd8;
                      emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end
          
          // widening instructions
          VWREDSUMU,
          VWREDSUM: begin
            case(funct3_ari)
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VSLIDEUP_RGATHEREI16: begin        
            case(funct3_ari)
              // VRGATHEREI16
              OPIVV: begin
                case(vlmul)
                  `LMUL1_4: begin
                    case(vsew)
                      `VSEW8,
                      `VSEW16: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_vs1    = 4'd1;
                        emul_max    = 4'd1;
                      end
                    endcase
                  end
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    case(vsew)
                      `VSEW8: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_vs1    = 4'd2;
                        emul_max    = 4'd2;                  
                      end
                      `VSEW16,
                      `VSEW32: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_vs1    = 4'd1;
                        emul_max    = 4'd1;
                      end
                    endcase
                  end
                  `LMUL2: begin                  
                    case(vsew)
                      `VSEW8: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd2;
                        emul_vs1    = 4'd4;
                        emul_max    = 4'd4;
                      end
                      `VSEW16: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd2;
                        emul_vs1    = 4'd2;
                        emul_max    = 4'd2;
                      end
                      `VSEW32: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd2;
                        emul_vs1    = 4'd1;
                        emul_max    = 4'd2;
                      end
                    endcase
                  end
                  `LMUL4: begin
                    case(vsew)
                      `VSEW8: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd4;
                        emul_vs1    = 4'd8;
                        emul_max    = 4'd8;
                      end
                      `VSEW16: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd4;
                        emul_vs1    = 4'd4;
                        emul_max    = 4'd4;
                      end
                      `VSEW32: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd4;
                        emul_vs1    = 4'd2;
                        emul_max    = 4'd4;
                      end
                    endcase
                  end
                  `LMUL8: begin
                    case(vsew)
                      `VSEW16: begin
                        emul_vd     = 4'd8;
                        emul_vs2    = 4'd8;
                        emul_vs1    = 4'd8;
                        emul_max    = 4'd8;
                      end
                      `VSEW32: begin
                        emul_vd     = 4'd8;
                        emul_vs2    = 4'd8;
                        emul_vs1    = 4'd4;
                        emul_max    = 4'd8;
                      end
                    endcase
                  end
                endcase
              end
              // VSLIDEUP 
              OPIVX,
              OPIVI: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end
        endcase
      end

      valid_opm: begin
        // OPM* instruction
        case(funct6_ari.opm_funct6)
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
            case(funct3_ari)
              OPMVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd4;
                  `LMUL4: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPMVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd4;
                  `LMUL4: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPMVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd4;
                  `LMUL4: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPMVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  `LMUL4: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VXUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vxunary) 
                  VZEXT_VF2,
                  VSEXT_VF2: begin
                    case(vlmul)
                      `LMUL1_2,
                      `LMUL1: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd1;
                      end
                      `LMUL2: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd2;
                      end
                      `LMUL4: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd2;
                        emul_max    = 4'd4;
                      `LMUL8: begin
                        emul_vd     = 4'd8;
                        emul_vs2    = 4'd4;
                        emul_max    = 4'd8;
                      end
                    endcase
                  end
                  VZEXT_VF4,
                  VSEXT_VF4: begin
                    case(vlmul)
                      `LMUL1: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd1;
                      end
                      `LMUL2: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd2;
                      end
                      `LMUL4: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd4;
                      `LMUL8: begin
                        emul_vd     = 4'd8;
                        emul_vs2    = 4'd2;
                        emul_max    = 4'd8;
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
            case(funct3_ari)
              OPMVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
              OPIVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  end
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  end
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VWMACCUS: begin
            case(funct3_ari)
              OPMVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL1: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd2;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd4;
                  `LMUL4: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPMVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  `LMUL4: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd4;
                  `LMUL8: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd8;
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
            case(funct3_ari)
              OPMVV: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd1;
                emul_vs1    = 4'd1;
                emul_max    = 4'd1;
              end
            endcase
          end

          VWXUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vwxunary)
                  VCPOP,
                  VFIRST,
                  VMV_X_S: begin
                    emul_vs2  = 4'd1;
                    emul_max  = 4'd1;
                  end
                endcase
              end
              OPMVX: begin
                emul_vd     = 4'd1;
                emul_max    = 4'd1;
              end
            endcase
          end

          VMUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vmunary)
                  VMSBF,
                  VMSIF,
                  VMSOF: begin
                    emul_vd         = 4'd1;
                    emul_vs2        = 4'd1;
                    emul_max        = 4'd1;
                  end
                  VIOTA: begin
                    case(vlmul)
                      `LMUL1_4,
                      `LMUL1_2,
                      `LMUL1: begin
                        emul_vd     = 4'd1;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd1;
                      end
                      `LMUL2: begin
                        emul_vd     = 4'd2;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd2;
                      `LMUL4: begin
                        emul_vd     = 4'd4;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd4;
                      end
                      `LMUL8: begin
                        emul_vd     = 4'd8;
                        emul_vs2    = 4'd1;
                        emul_max    = 4'd8;
                      end
                    endcase
                  end
                  VID: begin
                    case(vlmul)
                      `LMUL1_4,
                      `LMUL1_2,
                      `LMUL1: begin
                        emul_vd     = 4'd1;
                        emul_max    = 4'd1;
                      end
                      `LMUL2: begin
                        emul_vd     = 4'd2;
                        emul_max    = 4'd2;
                      `LMUL4: begin
                        emul_vd     = 4'd4;
                        emul_max    = 4'd4;
                      end
                      `LMUL8: begin
                        emul_vd     = 4'd8;
                        emul_max    = 4'd8;
                      end
                    endcase
                  end
                endcase
              end
            endcase
          end
          
          VSLIDE1UP,
          VSLIDE1DOWN: begin
            case(funct3_ari)
              OPMVX: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_max    = 4'd2;
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_max    = 4'd4;
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_max    = 4'd8;
                  end
                endcase
              end
            endcase
          end

          VCOMPRESS: begin
            case(funct3_ari)
              OPMVV: begin
                case(vlmul)
                  `LMUL1_4,
                  `LMUL1_2,
                  `LMUL1: begin
                    emul_vd     = 4'd1;
                    emul_vs2    = 4'd1;
                    emul_max    = 4'd1;
                  end
                  `LMUL2: begin
                    emul_vd     = 4'd2;
                    emul_vs2    = 4'd2;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd2;
                  `LMUL4: begin
                    emul_vd     = 4'd4;
                    emul_vs2    = 4'd4;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd4;
                  `LMUL8: begin
                    emul_vd     = 4'd8;
                    emul_vs2    = 4'd8;
                    emul_vs1    = 4'd1;
                    emul_max    = 4'd8;
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
    eew_vd          = 'b0;
    eew_vs2         = 'b0;
    eew_vs1         = 'b0;
    eew_scalar      = 'b0;
    eew_max         = 'b0;

    case(1'b1)
      valid_opi: begin
        // OPI* instruction
        case(funct6_ari.opi_funct6)
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
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
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
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VRSUB,
          VSLIDEDOWN: begin       
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
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
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMSBC,
          VMSLTU,
          VMSLT: begin
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMSGTU,
          VMSGT: begin
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW1;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
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
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX,
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMERGE_VMV: begin
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
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
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    if (inst_vm=='b0)
                      eew_vs2   = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VSMUL_VMVNRR: begin
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPIVI: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
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
            case(funct3_ari)
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
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
            case(funct3_ari)
              // VRGATHEREI16
              OPIVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
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
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
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
        case(funct6_ari.opm_funct6)
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
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
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
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW16;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          // SEW = extend 1/2SEW or 1/4SEW
          VXUNARY0: begin
            case(funct3_ari)
              OPMVX: begin
                case(vs1_opcode_vxunary) 
                  VZEXT_VF2,
                  VSEXT_VF2: begin
                    case(vsew)
                      `VSEW16: begin
                        eew_vd      = EEW16;
                        eew_vs2     = EEW8;
                        eew_max     = EEW16;
                      end
                      `VSEW32: begin
                        eew_vd      = EEW32;
                        eew_vs2     = EEW16;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                  VZEXT_VF4,
                  VSEXT_VF4: begin
                    case(vsew)
                      `VSEW32: begin
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
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_vs1     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
              OPMVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_scalar  = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end
          
          VWMACCUS: begin
            case(funct3_ari)
              OPMVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW8;
                    eew_scalar  = EEW8;
                    eew_max     = EEW16;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW16;
                    eew_scalar  = EEW16;
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
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
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
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8,
                  `VSEW16,
                  `VSEW32: begin
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
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vwxunary)
                  VCPOP,
                  VFIRST,
                  VMV_X_S: begin
                    case(vsew)
                      `VSEW8: begin
                        eew_vs2     = EEW8;
                        eew_max     = EEW8;
                      end
                      `VSEW16: begin
                        eew_vs2     = EEW16;
                        eew_max     = EEW16;
                      end
                      `VSEW32: begin
                        eew_vs2     = EEW32;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                endcase
              end
              OPMVX: begin
                // vmv.s.x
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VMUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vmunary)
                  VMSBF,
                  VMSIF,
                  VMSOF: begin
                    case(vsew)
                      `VSEW8,
                      `VSEW16,
                      `VSEW32: begin
                        eew_vd      = EEW1;
                        eew_vs2     = EEW1;
                        eew_max     = EEW1;
                      end
                    endcase
                  end
                  VIOTA:begin
                    case(vsew)
                      `VSEW8: begin
                        eew_vd      = EEW8;
                        eew_vs2     = EEW1;
                        eew_max     = EEW8;
                      end
                      `VSEW16: begin
                        eew_vd      = EEW16;
                        eew_vs2     = EEW1;
                        eew_max     = EEW16;
                      end
                      `VSEW32: begin
                        eew_vd      = EEW32;
                        eew_vs2     = EEW1;
                        eew_max     = EEW32;
                      end
                    endcase
                  end
                  VID: begin
                    case(vsew)
                      `VSEW8: begin
                        eew_vd      = EEW8;
                        eew_max     = EEW8;
                      end
                      `VSEW16: begin
                        eew_vd      = EEW16;
                        eew_max     = EEW16;
                      end
                      `VSEW32: begin
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
            case(funct3_ari)
              OPMVX: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
                    eew_vd      = EEW32;
                    eew_vs2     = EEW32;
                    eew_max     = EEW32;
                  end
                endcase
              end
            endcase
          end

          VCOMPRESS: begin
            case(funct3_ari)
              OPMVV: begin
                case(vsew)
                  `VSEW8: begin
                    eew_vd      = EEW8;
                    eew_vs2     = EEW8;
                    eew_vs1     = EEW1;
                    eew_max     = EEW8;
                  end
                  `VSEW16: begin
                    eew_vd      = EEW16;
                    eew_vs2     = EEW16;
                    eew_vs1     = EEW1;
                    eew_max     = EEW16;
                  end
                  `VSEW32: begin
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
  // check_vd_overlap_v0=1 means that vd does NOT overlap v0
  assign check_vd_overlap_v0 = (((inst_vm==1'b0)&(inst_vd!='b0)) | (inst_vm==1'b1));

  // check whether vd partially overlaps vs2 for narrowing instructions
  // check_vd_part_overlap_vs2=1 means that vd does NOT partially overlap vs2
  always_comb begin
    check_vd_part_overlap_vs2       = 'b0;          
    
    case(emul_max)
      4'd1: begin
        check_vd_part_overlap_vs2   = 1'b1;          
      end
      4'd2: begin
        if(!((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1]))))
          check_vd_part_overlap_vs2 = 1'b1;          
      end
      4'd4: begin
        if(!((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2]))))
          check_vd_part_overlap_vs2 = 1'b1;          
      end
      4'd8 : begin
        if(!((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3]))))
          check_vd_part_overlap_vs2 = 1'b1;          
      end
    endcase
  end

  // check whether vd partially overlaps vs1 for narrowing instructions
  // check_vd_part_overlap_vs1=1 means that vd does NOT partially overlap vs1
  always_comb begin
    check_vd_part_overlap_vs1     = 'b0;          
    
    case(emul_max)
      4'd1: begin
        check_vd_part_overlap_vs1 = 1'b1;          
      end
      4'd2: begin
        if(!((inst_vd[0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
      4'd4: begin
        if(!((inst_vd[1:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
      4'd8 : begin
        if(!((inst_vd[2:0]!='b0) & ((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3]))))
          check_vd_part_overlap_vs1 = 1'b1;          
      end
    endcase
  end

  // check whether vd fully overlaps vs2 for narrowing instructions
  // check_vd_full_overlap_vs2=1 means that vd does NOT fully overlap vs2
  always_comb begin
    check_vd_full_overlap_vs2       = 'b0;          
    
    case(emul_max)
      4'd1: begin
        if(inst_vd!=inst_vs2)
          check_vd_full_overlap_vs2 = 1'b1;          
      end
      4'd2: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:1])
          check_vd_full_overlap_vs2 = 1'b1;          
      end
      4'd4: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:2])
          check_vd_full_overlap_vs2 = 1'b1;          
      end
      4'd8: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:3]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:3])
          check_vd_full_overlap_vs2 = 1'b1;          
      end
    endcase
  end
  
  // check whether vd fully overlaps vs1 for narrowing instructions
  // check_vd_full_overlap_vs1=1 means that vd does NOT fully overlap vs1
  always_comb begin
    check_vd_full_overlap_vs1       = 'b0;          
    
    case(emul_max)
      4'd1: begin
        if(inst_vd!=inst_vs1)
          check_vd_full_overlap_vs1 = 1'b1;          
      end
      4'd2: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:1])
          check_vd_full_overlap_vs1 = 1'b1;          
      end
      4'd4: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:2])
          check_vd_full_overlap_vs1 = 1'b1;          
      end
      4'd8: begin
        if(inst_vd[`REGFILE_INDEX_WIDTH-1:3]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:3])
          check_vd_full_overlap_vs1 = 1'b1;          
      end
    endcase
  end

  // check whether vs2 partially overlaps vd for widening instructions
  always_comb begin
    check_vs2_part_overlap_vd       = 'b0;

    case(emul_max)
      4'd1: begin
        check_vs2_part_overlap_vd   = 1'b1;
      end
      4'd2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
          check_vs2_part_overlap_vd = 1'b1;
      end
      4'd4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b10)))
          check_vs2_part_overlap_vd = 1'b1;
      end
      4'd8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b100)))
          check_vs2_part_overlap_vd = 1'b1;
      end
    endcase
  end
  
  // check whether vs1 partially overlaps vd for widening instructions
  always_comb begin
    check_vs1_part_overlap_vd       = 'b0;

    case(emul_max)
      4'd1: begin
        check_vs1_part_overlap_vd   = 1'b1;
      end
      4'd2: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs1[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs1[0]!=1'b1)))
          check_vs1_part_overlap_vd = 1'b1;
      end
      4'd4: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs1[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs1[1:0]!=2'b10)))
          check_vs1_part_overlap_vd = 1'b1;
      4'd8: begin
        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs1[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs1[2:0]!=3'b100)))
          check_vs1_part_overlap_vd = 1'b1;
      end
    endcase
  end

  // start to check special requirements for every instructions
  always_comb 
    check_special = 'b0;
    
    case(1'b1)
      valid_opi: begin
        // OPI* instruction
        case(funct6_ari.opi_funct6)
          VADD,
          VMADC,
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
            case(funct3_ari)
              OPIVV,
              OPIVX,
              OPIVI: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end
        
          VSUB,
          VMSBC,
          VMINU,
          VMIN,
          VMAXU,
          VMAX,
          VSSUBU,
          VSSUB: begin
            case(funct3_ari)
              OPIVV,
              OPIVX: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end

          VRSUB: begin
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end

          VADC: begin
            case(funct3_ari)
              OPIVV,
              OPIVX,
              OPIVI: begin
                if ((inst_vm==1'b0)&(inst_vd!='b0))
                  check_special          = 1'b1;          
                
                `ifdef ASSERT_ON
                  `rvv_expect(inst_vm==1'b0)
                  else $error("Unsupported inst_vm=%d in %s instruction.\n",inst_vm,funct6_ari.opi_funct6.name());
                  
                  `rvv_forbit(inst_vd=='b0)
                  else $error("inst_vd(%d) cannot overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end

          VSBC: begin
            case(funct3_ari)
              OPIVV,
              OPIVX: begin
                if ((inst_vm==1'b0)&(inst_vd!='b0))
                  check_special         = 1'b1;          
                
                `ifdef ASSERT_ON
                  `rvv_expect(inst_vm==1'b0)
                  else $error("Unsupported inst_vm=%d in %s instruction.\n",inst_vm,funct6_ari.opi_funct6.name());
                  
                  `rvv_forbit(inst_vd=='b0)
                  else $error("inst_vd(%d) cannot overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end
        
          VNSRL,
          VNSRA,
          VNCLIPU,
          VNCLIP: begin
            case(funct3_ari)
              OPIVV: begin
                check_special = check_vd_overlap_v0&check_vd_part_overlap_vs2&check_vd_part_overlap_vs1;
              end
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
            case(funct3_ari)
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
            case(funct3_ari)
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
            case(funct3_ari)
              OPIVX,
              OPIVI: begin
                check_special = check_vd_part_overlap_vs2;
              end
            endcase     
          end

          VMERGE_VMV: begin
            case(funct3_ari)
              OPIVV,
              OPIVX,
              OPIVI: begin
                // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
                if (((inst_vm=='b0)&(inst_vd!='b0)) | ((inst_vm==1'b1)&(inst_vs2=='b0)))   
                  check_special = 1'b1;          
                
                `ifdef ASSERT_ON
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                  
                  `rvv_forbid((inst_vm==1'b1)&(inst_vs2!=5'b0))
                  else $error("inst_vs2(%d) should be 0 in %s instruction.\n",inst_vm,inst_vs2,funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end
               
          VSMUL_VMVNRR: begin
            case(funct3_ari)
              OPIVV,
              OPIVX: begin
                check_special = check_vd_overlap_v0;
                
                `ifdef ASSERT_ON
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
              OPIVI: begin
                if ((inst_vm == 1'b1)&
                    (inst_vs1[4:3]==2'b0)&
                    ((inst_vs1[2:0]==`NREG1)|(inst_vs1[2:0]==`NREG2)|(inst_vs1[2:0]==`NREG4)|(inst_vs1[2:0]==`NREG8))
                   )
                  check_special          = 1'b1;

                `ifdef ASSERT_ON
                  `rvv_expect(inst_vm==1'b1)
                  else $error("inst_vm(%d) should be 1 in vmv<nr>r instruction.\n",inst_vm,funct6_ari.opi_funct6.name());

                  `rvv_expect(inst_vs1[4:3]==2'b0)
                  else $error("inst_vs1[4:3](%d) should be 0 in vmv<nr>r instruction.\n",inst_vs1[4:3]);
                
                  `rvv_expect((inst_vs1[2:0]==`NREG1)|(inst_vs1[2:0]==`NREG2)|(inst_vs1[2:0]==`NREG4)|(inst_vs1[2:0]==`NREG8))
                  else $error("Unsupported inst_vs1[2:0]=%d in vmv<nr>r instruction.\n",inst_vs1[2:0]);
                `endif
              end
            endcase
          end

          VWREDSUMU,
          VWREDSUM: begin
            case(funct3_ari)
              OPIVV: begin
                if (vstart=='b0) 
                  check_special = check_vd_overlap_v0;          

                `ifdef ASSERT_ON
                  `rvv_expect(vstart=='b0)
                  else $error("vstart(%d) should be 0 in %s instruction.\n",vstart,funct6_ari.opi_funct6.name());
                  
                  `rvv_expect(check_vd_overlap_v0==1'b1)
                  else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                `endif
              end
            endcase
          end

          VSLIDEUP_RGATHEREI16: begin
            case(funct3_ari)
              // VRGATHEREI16
              OPIVV: begin
                // destination register group cannot overlap the source register group
                case(emul_max,emul_vs2,emul_vs1)
                  {4'd1,4'd1,4'd1}: begin
                    check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2&check_vd_full_overlap_vs1;                
                  end

                  {4'd2,4'd1,4'd2}: begin
                    if((inst_vd!=inst_vs2)&(inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:1]))
                      check_special = check_vd_overlap_v0;          
                  end

                  {4'd2,4'd2,4'd1},
                  {4'd2,4'd2,4'd2}: begin
                    check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2&check_vd_full_overlap_vs1;                
                  end

                  {4'd4,4'd2,4'd4}: begin
                    if((inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:2]))
                      check_special = check_vd_overlap_v0;          
                  end

                  {4'd4,4'd4,4'd2},
                  {4'd4,4'd4,4'd4}: begin
                    check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2&check_vd_full_overlap_vs1;                
                  end
                  end

                  {4'd8,4'd4,4'd8}: begin
                    if((inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vd[`REGFILE_INDEX_WIDTH-1:3]!=inst_vs1[`REGFILE_INDEX_WIDTH-1:3]))
                      check_special     = check_vd_overlap_v0;          
                  end

                  {4'd8,4'd8,4'd4},
                  {4'd8,4'd8,4'd8}: begin
                    check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2&check_vd_full_overlap_vs1;                
                  end
                endcase
              end
              // VSLIDEUP 
              OPIVX,
              OPIVI: begin
                // destination register group cannot overlap the source register group
                check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2;
              end
            endcase
          end
          
          VRGATHER: begin
            case(funct3_ari)
              OPIVV: begin
                // destination register group cannot overlap the source register group
                check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2&check_vd_full_overlap_vs1;
              end
              OPIVX,
              OPIVI: begin
                // destination register group cannot overlap the source register group
                check_special   = check_vd_overlap_v0&check_vd_full_overlap_vs2;
              end
            endcase
          end
        endcase
      end

      valid_opm: begin
        // OPM* instruction
        case(funct6_ari.opm_funct6)
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
            case(funct3_ari)
              OPMVV: begin
                // overlap constraint
                check_special   = check_vd_overlap_v0&check_vs2_part_overlap_vd&check_vs1_part_overlap_vd;                
              end
              OPMVX: begin
                // overlap constraint
                check_special   = check_vd_overlap_v0&check_vs2_part_overlap_vd;                
              end
            endcase
          end

          VWADDU_W,
          VWSUBU_W,
          VWADD_W,
          VWSUB_W: begin
            case(funct3_ari)
              OPMVV: begin
                // overlap constraint
                check_special   = check_vd_overlap_v0&check_vs2_part_overlap_vd;                
              end
              OPMVX: begin
                check_special   = check_vd_overlap_v0;                
            endcase
          end
          
          VXUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vxunary) 
                  VZEXT_VF2,
                  VSEXT_VF2: begin
                    // overlap constraint
                    check_special   = check_vd_overlap_v0&check_vs2_part_overlap_vd;                
                  end
                  VZEXT_VF4,
                  VSEXT_VF4: begin
                    // overlap constraint
                    case(emul_max)
                      4'd1: begin
                        check_special       = check_vd_overlap_v0;          
                      end
                      4'd2: begin
                        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:1]==inst_vs2[`REGFILE_INDEX_WIDTH-1:1])&(inst_vs2[0]!=1'b1)))
                          check_special     = check_vd_overlap_v0;          
                      end
                      4'd4: begin
                        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:2]==inst_vs2[`REGFILE_INDEX_WIDTH-1:2])&(inst_vs2[1:0]!=2'b11)))
                          check_special     = check_vd_overlap_v0;          
                      end
                      4'd8: begin
                        if(!((inst_vd[`REGFILE_INDEX_WIDTH-1:3]==inst_vs2[`REGFILE_INDEX_WIDTH-1:3])&(inst_vs2[2:0]!=3'b110)))
                          check_special     = check_vd_overlap_v0;          
                      end
                    endcase
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
            case(funct3_ari)
              OPMVV,
              OPMVX: begin
                check_special = check_vd_overlap_v0;          
              end
            endcase
          end

          VWMACCUS,
          VSLIDE1DOWN: begin
            case(funct3_ari)
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
            case(funct3_ari)
              OPMVV: begin
                if(vstart=='b0)
                  check_special     = 1'b1;
            
                `ifdef ASSERT_ON
                  `rvv_expect(vstart=='b0)
                  else $error("vstart(%d) should be 0 in %s instruction.\n",vstart,funct6_ari.opm_funct6.name());
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
            case(funct3_ari)  
              OPMVV: begin
                if(inst_vm==1'b1)
                  check_special   = 1'b1;
            
                `ifdef ASSERT_ON
                  `rvv_expect(inst_vm==1'b1)
                  else $error("inst_vm(%d) should be 1 in %s instruction.\n",inst_vm,funct6_ari.opm_funct6.name());
                `endif
              end
            endcase
          end
          
          VWXUNARY0: begin
            case(funct3_ari)
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
                  `rvv_expect(inst_vm==1'b1)
                  else $error("inst_vm(%d) should be 1 in %s instruction.\n",inst_vm,funct6_ari.opm_funct6.name());
                
                  `rvv_expect(inst_vs2=='b0)
                  else $error("inst_vs2(%d) should be 0 in %s instruction.\n",inst_vs2,funct6_ari.opm_funct6.name());
                `endif
              end
            endcase
          end

          VMUNARY0: begin
            case(funct3_ari)
              OPMVV: begin
                case(vs1_opcode_vmunary)
                  VMSBF,
                  VMSIF,
                  VMSOF,
                  VIOTA: begin
                    check_special = check_vd_overlap_v0&check_vd_full_overlap_vs2;
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
            case(funct3_ari)
              OPMVX: begin
                // destination register group cannot overlap the source register group
                check_special = check_vd_overlap_v0&check_vd_full_overlap_vs2;
              end
            endcase
          end

          VCOMPRESS: begin
            case(funct3_ari)
              OPMVX: begin
                if (vstart=='b0) begin
                  // destination register group cannot overlap the source register group
                  check_special = check_vd_overlap_v0&check_vd_full_overlap_vs2;
                
                  `ifdef ASSERT_ON
                    `rvv_expect(vstart=='b0)
                    else $error("vstart(%d) should be 0 in %s instruction.\n",vstart,funct6_ari.opi_funct6.name());
                  
                    `rvv_expect(check_vd_overlap_v0==1'b1)
                    else $error("vd is overlap v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
                    
                    `rvv_expect(check_vd_overlap_vs2==1'b1)
                    else $error("vd is overlap vs2 in %s instruction.\n",funct6_ari.opi_funct6.name());
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
  assign check_common = check_vd_align&check_vs2_align&check_vs1_align;

  // check whether vd is aligned to emul_vd
  always_comb begin
    check_vd_align = 1'b1; 

    case(emul_vd)
      4'd2: begin
        if (inst_vd[0]!=1'b0)
          check_vd_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[0]!=1'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      4'd4: begin
        if (inst_vd[1:0]!=2'b0)
          check_vd_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[1:0]!=2'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      4'd8: begin
        if (inst_vd[2:0]!=3'b0)
          check_vd_align = 'b0; 
       
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[2:0]!=3'b0)        
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
    endcase
  end

  // check whether vs2 is aligned to emul_vs2
  always_comb begin
    check_vs2_align = 1'b1; 

    case(emul_vs2)
      4'd2: begin
        if (inst_vs2[0]!=1'b0)
          check_vs2_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[0]!=1'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      4'd4: begin
        if (inst_vs2[1:0]!=2'b0)
          check_vs2_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[1:0]!=2'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      4'd8: begin
        if (inst_vs2[2:0]!=3'b0)
          check_vs2_align = 'b0; 
       
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[2:0]!=3'b0)        
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
    endcase
  end
    
  // check whether vs1 is aligned to emul_vs1
  always_comb begin
    check_vs1_align = 1'b1; 
    
    case(emul_vs1)
      4'd2: begin
        if (inst_vs1[0]!=1'b0)
          check_vs1_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs1[0]!=1'b0)
          else $error("vs1 is not aligned to emul_vs1(%d).\n",emul_vs1);
        `endif
      end
      4'd4: begin
        if (inst_vs1[1:0]!=2'b0)
          check_vs1_align = 'b0; 
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs1[1:0]!=2'b0)
          else $error("vs1 is not aligned to emul_vs1(%d).\n",emul_vs1);
        `endif
      end
      4'd8: begin
        if (inst_vs1[2:0]!=3'b0)
          check_vs1_align = 'b0; 
       
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs1[2:0]!=3'b0)        
          else $error("vs1 is not aligned to emul_vs1(%d).\n",emul_vs1);
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
        uop_vstart  = vstart[4 +: `UOP_INDEX_WIDTH];
      end
      EEW16: begin
        uop_vstart  = vstart[3 +: `UOP_INDEX_WIDTH];
      end
      EEW32: begin
        uop_vstart  = vstart[2 +: `UOP_INDEX_WIDTH];
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
  // generate uop valid
  always_comb begin        
  for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VALID
    if (({1'b0,uop_index_current[i]}<emul_max)&inst_valid) 
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
      uop[i].uop_funct3           = funct3_ari;
    end
  end

  // update uop funct6
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT6
      uop[i].uop_funct6           = inst_funct6;
    end
  end

  // allocate uop to execution unit
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      // initial
      uop[i].uop_exe_unit     = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // allocate OPI* uop to execution unit
          case(funct6_ari.opi_funct6)
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
            VMSEQ,
            VMSNE,
            VMSLTU,
            VMSLT,
            VMSLEU,
            VMSLE,
            VMSGTU,
            VMSGT,
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
            
            VSMUL_VMVNRR: begin
              case(funct3_ari)
                OPIVV,
                OPIVX: begin
                  uop[i].uop_exe_unit = MUL;
                end
                OPIVI: begin 
                  uop[i].uop_exe_unit = ALU;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM,
            VSLIDEUP_RGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              uop[i].uop_exe_unit     = PMTRDT;
            end
          endcase
        end

        valid_opm: begin
          // allocate OPM* uop to execution unit
          case(funct6_ari.opm_funct6)
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
            VREDXOR,
            VSLIDE1UP,
            VSLIDE1DOWN,
            VCOMPRESS: begin
              uop[i].uop_exe_unit     = PMTRDT;
            end
          endcase
        end
      endcase
    end
  end
 
  // update uop class
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_CLASS
      // initial 
      uop[i].uop_class      = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
                OPIVX,
                OPIVI: begin
                  uop[i].uop_class  = VV;
                end 
              endcase
            end
            
            VMERGE_VMV: begin
              case(funct3_ari)
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
                    uop[i].uop_class  = XX;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              case(funct3_ari)
                OPIVV: begin
                  uop[i].uop_class  = VV;
                end
              endcase
            end

            VSLIDEUP_VRGATHEREI16: begin
              case(funct3_ari)
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
          case(funct6_ari.opm_funct6)
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].uop_class  = VV;
                end
                OPMVX: begin
                  uop[i].uop_class  = VX;
                end
              endcase
            end 
            
            VXUNARY0: begin
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].uop_class  = VVV;
                end
              endcase
            end
          
            VWXUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  uop[i].uop_class  = VX;
                end
                OPMVX: begin
                  uop[i].uop_class  = X;
                end
              endcase
            end

            VMUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF,
                    VIOTA: begin
                      uop[i].uop_class  = VV;
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VCSR
      uop[i].vector_csr               = vector_csr_ari;

      // update vstart of every uop
      if((uop_index_remain=='b0)&(i=='b0))    // or: if(uop_index_current[i]==uop_vstart)
        uop[i].vector_csr.vstart      = vstart;
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
      // initial 
      uop[i].v0_valid           = 'b0;
       
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
            VADC,
            VMADC,
            VMERGE_VMV: begin
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  uop[i].v0_valid   = !inst_vm;
                end
              endcase
            end 
            VSBC,
            VMSBC: begin
              case(funct3_ari)
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VD
      // initial
      uop[i].vd_index = 'b0;
      uop[i].vd_eew   = 'b0;
      uop[i].vd_valid = 'b0;
      
      case(1'b1)
        valid_opi: begin
          case(funct6_ari.opi_funct6)
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
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
              case(funct3_ari)
                OPIVV,
                OPIVX: begin  
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end 
              endcase
            end

            VRSUB,
            VSLIDEDOWN: begin
              case(funct3_ari)
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
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
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end

            VWREDSUMU,
            VWREDSUM: begin
              if(funct3_ari==OPIVV) begin
                uop[i].vd_index   = inst_vd;
                uop[i].vd_eew     = eew_vd;
                uop[i].vd_valid   = 1'b1;
              end
            end

            VSLIDEUP_VRGATHEREI16: begin
              case(funct3_ari)
                OPIVV: begin
                  case({emul_max,emul_vd})
                    {4'd1,4'd1},
                    {4'd2,4'd2},
                    {4'd4,4'd4},
                    {4'd8,4'd8}: begin
                      uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    end
                    {4'd2,4'd1},
                    {4'd4,4'd2},
                    {4'd8,4'd4}: begin
                      uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    end
                  endcase
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end 
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.opm_funct6)
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
              case(funct3_ari)
                OPMVV,
                OPMVX: begin
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end   

            VXUNARY0,
            VCOMPRESS: begin
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end

            VWMACCUS,
            VSLIDE1UP,
            VSLIDE1DOWN: begin
              case(funct3_ari)
                OPMVX: begin
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end
             
            VWXUNARY0: begin
              case(funct3_ari)
                OPMVX: begin
                  uop[i].vd_index = inst_vd;
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end
              endcase
            end
         
            VMUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF,
                    VIOTA: begin
                      uop[i].vd_index = inst_vd;
                      uop[i].vd_eew   = eew_vd;
                      uop[i].vd_valid = 1'b1;
                    VID: begin
                      uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS3_VALID
      // initial
      uop[i].vs3_valid = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
            VMADC,
            VMSEQ,
            VMSNE,
            VMSLEU,
            VMSLE: begin
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end
            VMSBC,
            VMSLTU,
            VMSLT: begin
              case(funct3_ari)
                OPIVV,
                OPIVX: begin
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end
            VMSGTU,
            VMSGT: begin
              case(funct3_ari)
                OPIVX,
                OPIVI: begin
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.opi_funct6)
            VMACC,
            VNMSAC,
            VMADD,
            VNMSUB,
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(funct3_ari)
                OPMVV,
                OPMVX: begin
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end

            VWMACCUS: begin
              case(funct3_ari)
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs3_valid = 1'b1;
                end
              endcase
            end

            VMUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  case(vs1_opcode_vmunary)
                    VMSBF,
                    VMSIF,
                    VMSOF,
                    VIOTA: begin
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1
      // initial
      uop[i].vs1             = inst_vs1;
      uop[i].vs1_eew         = 'b0;
      uop[i].vs1_index_valid = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
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
              case(funct3_ari)
                OPIVV: begin
                  uop[i].vs1              = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 'b1;   
                end
              endcase
            end
            
            VNSRL,
            VNSRA,
            VNCLIPU,
            VNCLIP: begin
              case(funct3_ari)
                OPIVV: begin
                  uop[i].vs1_index        = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_valid        = 1'b1;
                end
              endcase
            end
            
            VWREDSUMU,
            VWREDSUM: begin
              case(funct3_ari)
                OPIVV: begin
                  uop[i].vs1              = inst_vs1;
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_index_valid  = 'b1;   
                end
              endcase
            end        
            
            VSLIDE_VRGATHEREI16: begin
              if(funct3_ari==OPIVV) begin
                case({emul_max,emul_vs1})
                  {4'd1,4'd1},
                  {4'd2,4'd2},
                  {4'd4,4'd4},
                  {4'd8,4'd8}: begin
                    uop[i].vs1_index      = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                    uop[i].vs1_eew        = eew_vs1;
                    uop[i].vs1_valid      = 1'b1;
                  end
                  {4'd2,4'd1},
                  {4'd4,4'd2},
                  {4'd8,4'd4}: begin
                    uop[i].vs1_index      = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                    uop[i].vs1_eew        = eew_vs1;
                    uop[i].vs1_valid      = 1'b1;
                  end
                endcase
              end
            end
          endcase
        end

        valid_opm: begin
          // OPM*
          case(funct6_ari.opm_funct6)
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs1_index        = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_valid        = 1'b1;        
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs1_index        = inst_vs1+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_valid        = 1'b1;        
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs1_index        = inst_vs1;
                  uop[i].vs1_eew          = eew_vs1;
                  uop[i].vs1_valid        = 1'b1;
                end
              endcase
            end
          endcase
        end
      endcase
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1_OPCODE
      // initial
      uop[i].vs1_opcode_valid         = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
            VSMUL_VMVNRR: begin
              case(funct3_ari)
                OPIVI: begin
                  uop[i].vs1_opcode_valid = 1'b1;
                end
              endcase
            end
          endcase
        end
        
        valid_opm: begin
          // OPM*
          case(funct6_ari.opm_funct6)
            VXUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs1_opcode_valid = 1'b1;
                end
              endcase
            end
             VWXUNARY0: begin
              case(funct3_ari)
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
              case(funct3_ari)
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS2
      // initial
      uop[i].vs2_index        = 'b0; 
      uop[i].vs2_eew          = 'b0; 
      uop[i].vs2_valid        = 'b0; 
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
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
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
              case(funct3_ari)
                OPIVV,
                OPIVX: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
                end
              endcase
            end

            VRSUB,
            VMSGTU,
            VMSGT,
            VSLIDEDOWN: begin
              case(funct3_ari)
                OPIVX,
                OPIVI: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
                end
              endcase
            end
            
            VMERGE_VMV: begin
              case(funct3_ari)
                OPIVV,
                OPIVX,
                OPIVI: begin
                  if(inst_vm==1'b0) begin
                    uop[i].vs2_index  = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                    uop[i].vs2_eew    = eew_vs2;
                    uop[i].vs2_valid  = 1'b1;
                  end
                end
              endcase
            end
           
            VWREDSUMU,
            VWREDSUM: begin
              case(funct3_ari)
                OPIVV: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;
                end
              endcase
            end

            VSLIDE_VRGATHEREI16: begin
              case(funct3_ari)
                OPIVV: begin
                  case({emul_max,emul_vs2})
                    {4'd1,4'd1},
                    {4'd2,4'd2},
                    {4'd4,4'd4},
                    {4'd8,4'd8}: begin
                      uop[i].vs2_index  = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                      uop[i].vs2_eew    = eew_vs2;
                      uop[i].vs2_valid  = 1'b1;
                    end
                    {4'd2,4'd1},
                    {4'd4,4'd2},
                    {4'd8,4'd4}: begin
                      uop[i].vs2_index  = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
                      uop[i].vs2_eew    = eew_vs2;
                      uop[i].vs2_valid  = 1'b1;
                    end
                  endcase
                end
                OPIVX,
                OPIVI: begin  
                  uop[i].vd_index = inst_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vd_eew   = eew_vd;
                  uop[i].vd_valid = 1'b1;
                end 
              endcase
            end
          endcase
        end

        valid_opm: begin
          // OPM* 
          case(funct6_ari.opm_funct6)
            VWADDU,
            VWSUBU,
            VWADD,
            VWSUB,
            VWMUL,
            VWMULU,
            VWMULSU
            VWMACCU,
            VWMACC,
            VWMACCSU: begin
              case(funct3_ari)
                OPMVV,
                OPMVX: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
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
              case(funct3_ari)
                OPMVV,
                OPMVX: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;        
                end
              endcase
            end

            VXUNARY0: begin
              case(funct3_ari)
                OPMVV: begin
                  case({emul_max,emul_vs2})
                    {4'd1,4'd1},
                    {4'd2,4'd1},
                    {4'd4,4'd1}: begin
                      uop[i].vs2_index    = inst_vs2;
                      uop[i].vs2_eew      = eew_vs2;
                      uop[i].vs2_valid    = 1'b1;
                    end
                    {4'd8,4'd4}: begin
                      uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:2]};
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
              case(funct3_ari)
                OPMVX: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:1]};
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
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
              case(funct3_ari)
                OPMVV: begin
                  uop[i].vs2_index    = inst_vs2;
                  uop[i].vs2_eew      = eew_vs2;
                  uop[i].vs2_valid    = 1'b1;   
                end
              endcase
            end

            VMUNARY0: begin
              case(funct3_ari)
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RD
      // initial
      uop[i].rd_index         = 'b0;
      uop[i].rd_index_valid   = 'b0;
     
      case(funct6_ari.opm_funct6)
        VWXUNARY0: begin
          case(funct3_ari)
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1
      // initial
      uop[i].rs1_data         = 'b0;
      uop[i].scalar_eew       = 'b0;
      uop[i].rs1_data_valid   = 'b0;
      
      case(1'b1)
        valid_opi: begin
          // OPI*
          case(funct6_ari.opi_funct6)
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
              case(funct3_ari)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].scalar_eew     = eew_scalar;
                  uop[i].rs1_data_valid = 1'b1;
                end
                OPIVI: begin
                  uop[i].rs1_data       = {{27{inst_imm[4]}},inst_imm[4:0]};
                  uop[i].scalar_eew     = eew_scalar;
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
              case(funct3_ari)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].scalar_eew     = eew_scalar;
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
            VRGATHER,
            VNCLIPU,
            VSLIDEUP_VRGATHEREI16,
            VSLIDEDOWN,
            VRGATHER: begin
              case(funct3_ari)
                OPIVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].scalar_eew     = eew_scalar;
                  uop[i].rs1_data_valid = 1'b1;
                end
                OPIVI: begin
                  uop[i].rs1_data       = {'b0,inst_imm[4:0]};
                  uop[i].scalar_eew     = eew_scalar;
                  uop[i].rs1_data_valid = 1'b1;
                end
              endcase
            end
          endcase
        end
        
        valid_opm: begin
          // OPM*
          case(funct6_ari.opm_funct6)
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
              case(funct3_ari)
                OPMVX: begin
                  uop[i].rs1_data       = rs1_data;
                  uop[i].scalar_eew     = eew_scalar;
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
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_INDEX
      uop[i].uop_index = uop_index_current[i];
    end
  end

  // update last_uop valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_LAST
      uop[i].last_uop_valid = ({1'b0,uop_index_current[i]} == (emul_max-`VTYPE_VLMUL_WIDTH'd1));
    end
  end

endmodule
