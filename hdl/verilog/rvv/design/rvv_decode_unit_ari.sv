
`include "rvv.svh"

module rvv_decode_unit_ari
(
  inst_valid,
  inst,
  uop_index_remain,
  uop_valid,
  uop
)
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
  
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vd;          // 0000:emul=0, 0001:emul=1, 0010:emul=2,...  
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vs2;
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_vs1;
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_max;
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs2;          
  EEW_e                                           eew_vs1;
  EEW_e                                           eew_max;          
  logic                                           inst_encoding_correct;
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_vstart;         
  logic   [`UOP_INDEX_WIDTH-1:0]                  uop_index_start;         
  logic   [`NUM_DE_UOP-1:0][`UOP_INDEX_WIDTH:0]   uop_index_current;         
   
  // convert logic to enum/union
  EXE_FUNCT3_e                                    funct3_ari;
  FUNCT6_u                                        funct6_ari;

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
    
    case(funct3_ari)
      OPIVV,
      OPIVX,
      OPIVI: begin
        funct6_ari.opi_funct6 = inst_funct6;
      end

      OPMVV,
      OPMVX: begin
        funct6_ari.opm_funct6 = inst_funct6;
      end
    endcase
  end

  // get EMUL
  always_comb begin
    // initial
    emul_vd          = 'b0;
    emul_vs2         = 'b0;
    emul_vs1         = 'b0;
    emul_max         = 'b0;

    // OPI* instruction
    case(funct6_ari.opi_funct6)
      VADD,
      VRSUB,
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
      VSSRL,
      VSSRA,
      VSLIDEUP,
      VSLIDEDOWN,
      VRGATHER,
      VMADC: begin
        case(funct3_ari)
          OPIVV: begin
  
          end
          OPIVX: begin

          end 
          OPIVI: begin
            case(vlmul)
              `LMUL1_4,
              `LMUL1_2,
              `LMUL1: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd1;
                emul_vs1    = 'b0;
                emul_max    = 4'd1;
              end
              `LMUL2: begin
                emul_vd     = 4'd2;
                emul_vs2    = 4'd2;
                emul_vs1    = 'b0;
                emul_max    = 4'd2;
              end
              `LMUL4: begin
                emul_vd     = 4'd4;
                emul_vs2    = 4'd4;
                emul_vs1    = 'b0;
                emul_max    = 4'd4;
              end
              `LMUL8: begin
                emul_vd     = 4'd8;
                emul_vs2    = 4'd8;
                emul_vs1    = 'b0;
                emul_max    = 4'd8;
              end
            endcase
          end
        endcase
      end
      // some vector register is mask register
      VMADC,
      VMSEQ,
      VMSNE,
      VMSLEU,
      VMSLE,
      VMSGTU,
      VMSGT: begin
        case(funct3_ari)
          OPIVV: begin
  
          end
          OPIVX: begin

          end 
          OPIVI: begin
            case(vlmul)
              `LMUL1_4,
              `LMUL1_2,
              `LMUL1: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd1;
                emul_vs1    = 'b0;
                emul_max    = 4'd1;
              end
              `LMUL2: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd2;
                emul_vs1    = 'b0;
                emul_max    = 4'd2;
              end
              `LMUL4: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd4;
                emul_vs1    = 'b0;
                emul_max    = 4'd4;
              end
              `LMUL8: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd8;
                emul_vs1    = 'b0;
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
  
          end
          OPIVX: begin

          end 
          OPIVI: begin
            case(vlmul)
              `LMUL1_4,
              `LMUL1_2: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd1;
                emul_vs1    = 'b0;
                emul_max    = 4'd1;
              end
              `LMUL1: begin
                emul_vd     = 4'd1;
                emul_vs2    = 4'd2;
                emul_vs1    = 'b0;
                emul_max    = 4'd2;
              end
              `LMUL2: begin
                emul_vd     = 4'd2;
                emul_vs2    = 4'd4;
                emul_vs1    = 'b0;
                emul_max    = 4'd4;
              end
              `LMUL4: begin
                emul_vd     = 4'd4;
                emul_vs2    = 4'd8;
                emul_vs1    = 'b0;
                emul_max    = 4'd8;
              end
            endcase
          end
        endcase
      end
      // vmv<nr>r.v instruction
      VSMUL_VMVNRR: begin
        case(funct3_ari)
          OPIVV: begin
  
          end
          OPIVX: begin

          end 
          OPIVI: begin
            case(inst_vs1[2:0])
              `NREG1: begin
                  emul_vd     = 4'd1;
                  emul_vs2    = 4'd1;
                  emul_vs1    = 'b0;
                  emul_max    = 4'd1;
              end
              `NREG2: begin
                  emul_vd     = 4'd2;
                  emul_vs2    = 4'd2;
                  emul_vs1    = 'b0;
                  emul_max    = 4'd2;
              end
              `NREG4: begin
                  emul_vd     = 4'd4;
                  emul_vs2    = 4'd4;
                  emul_vs1    = 'b0;
                  emul_max    = 4'd4;
              end
              `NREG8: begin
                  emul_vd     = 4'd8;
                  emul_vs2    = 4'd8;
                  emul_vs1    = 'b0;
                  emul_max    = 4'd8;
              end
            endcase
          end
        endcase
      end
    endcase

    // OPM* instruction
    case(funct6_ari.opm_funct6)
      VREDSUM: begin
        case(funct3_ari)
          OPMVV: begin
  
          end
          OPMVX: begin

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
    eew_max         = 'b0;

    // OPI* instruction
    case(funct6_ari.opi_funct6)
      VADD,
      VRSUB,
      VADC,
      VAND,
      VOR,
      VXOR,
      VSLL,
      VSRL,
      VSRA,
      VSMUL_VMVNRR,
      VMERGE_VMV,
      VSADDU,
      VSADD,
      VSSRL,
      VSSRA,
      VSLIDEUP,
      VSLIDEDOWN,
      VRGATHER: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
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

      VMADC,
      VMSEQ,
      VMSNE,
      VMSLEU,
      VMSLE,
      VMSGTU,
      VMSGT: begin
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
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
      endcase

      VNSRL,
      VNSRA,
      VNCLIPU,
      VNCLIP: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
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
        endcase
      end
    endcase

    // OPM* instruction
    case(funct6_ari.opm_funct6)
      VREDSUM: begin
        case(funct3_ari)
          OPMVV: begin
  
          end
          OPMVX: begin

          end
        endcase
      end
    endcase
  end
  
  // opcode error check
  always_comb 
    inst_encoding_correct                = 'b0;
    
    //
    // check special requirements for every instructions
    //
    // OPI* instruction
    case(funct6_ari.opi_funct6)
      VADD,
      VRSUB,
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
      VMSGTU,
      VMSGT,
      VSADDU,
      VSADD,
      VSSRL,
      VSSRA,
      VNCLIPU,
      VNCLIP,
      VSLIDEDOWN: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
            inst_encoding_correct        = 1'b1;
          end
        endcase
      end
    
      VADC: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
            if ((inst_vm==1'b0)&(inst_vd!='b0))
              inst_encoding_correct          = 1'b1;          
            
            `ifdef ASSERT_ON
              `rvv_expect(inst_vm==1'b0)
              else $error("Unsupported inst_vm=%d in %s instruction.\n",inst_vm,funct6_ari.opi_funct6.name());
              
              `rvv_forbit(inst_vd=='b0)
              else $error("inst_vd(%d) cannot be v0 in %s instruction.\n",funct6_ari.opi_funct6.name());
            `endif
          end
        endcase
      end
    
      VMERGE_VMV: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
            // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
            if ((inst_vm==1'b0)|((inst_vm==1'b1)&(inst_vs2==5'b0)))
              inst_encoding_correct         = 1'b1;          
            `ifdef ASSERT_ON
              `rvv_forbid((inst_vm==1'b1)&(inst_vs2!=5'b0))
              else $error("when inst_vm=%d, inst_vs2(%d) should be 0 in instruction.\n",inst_vm,inst_vs2,funct6_ari.opi_funct6.name());
            `endif
          end
        endcase
      end
      
      VSLIDEUP,
      VRGATHER: begin
        case(funct3_ari)
          OPIVX: begin

          end
          OPIVI: begin
            case(emul_max,emul_vs2)
              {4'd1,4'd1}: begin
                if(inst_vd!=inst_vs2)
                  inst_encoding_correct     = 1'b1;          
              end
              {4'd2,4'd2}: begin
                if(inst_vd[`REGFILE_INDEX_WIDTH-1:1]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:1])
                  inst_encoding_correct     = 1'b1;          
              end
              {4'd4,4'd4}: begin
                if(inst_vd[`REGFILE_INDEX_WIDTH-1:2]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:2])
                  inst_encoding_correct     = 1'b1;          
              end
              {4'd8,4'd8}: begin
                if(inst_vd[`REGFILE_INDEX_WIDTH-1:3]!=inst_vs2[`REGFILE_INDEX_WIDTH-1:3])
                  inst_encoding_correct     = 1'b1;          
              end

            endcase
          end
        endcase
      end

      VSMUL_VMVNRR: begin
        case(funct3_ari)
          OPIVV: begin

          end
          OPIVX: begin

          end
          OPIVI: begin
            if ((inst_vm == 1'b1)&(inst_vs1[4:3]==2'b0)&((inst_vs1[2:0]==`NREG1)|(inst_vs1[2:0]==`NREG2)|(inst_vs1[2:0]==`NREG4)|(inst_vs1[2:0]==`NREG8)))
              inst_encoding_correct          = 1'b1;          
            `ifdef ASSERT_ON
              `rvv_expect(inst_vm==1'b1)
              else $error("Unsupported inst_vm=%d in vmv<nr>r instruction.\n",inst_vm,funct6_ari.opi_funct6.name());

              `rvv_expect(inst_vs1[4:3]==2'b0)
              else $error("inst_vs1[4:3]=%d should be 0 in vmv<nr>r instruction.\n",inst_vs1[4:3]);
            
              `rvv_expect((inst_vs1[2:0]==`NREG1)|(inst_vs1[2:0]==`NREG2)|(inst_vs1[2:0]==`NREG4)|(inst_vs1[2:0]==`NREG8))
              else $error("Unsupported inst_vs1[2:0]=%d in vmv<nr>r instruction.\n",inst_vs1[2:0]);
            `endif
          end
        endcase
      end

      default: begin
        ``ifdef ASSERT_ON
          $error("Unsupported funct6_opi=%d.\n",funct6_ari.opi_funct6);
        `endif
      end
    endcase

    // OPM* instruction
    case(funct6_ari.opm_funct6)
      VREDSUM: begin
        case(funct3_ari)
          OPMVV: begin
  
          end
          OPMVX: begin

          end
        endcase
      end
      
      default: begin
        ``ifdef ASSERT_ON
          $error("Unsupported funct6_opm=%d.\n",funct6_ari.opm_funct6);
        `endif
      end
    endcase

    ``ifdef ASSERT_ON
      `rvv_forbid((inst_encoding_correct=1'b1)&(funct3_ari==OPFVV)|(funct3_ari==OPFVF)|(funct3_ari==OPCFG))
      else $error("Unsupported funct3_ari=%s.\n",funct3_ari.name());
    `endif

    //
    // check common requirements for all instructions
    //
    // check whether vd is aligned to emul_vd
    case(emul_vd)
      4'd2: begin
        if (inst_vd[0]!=1'b0)
          inst_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[0]!=1'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      4'd4: begin
        if (inst_vd[1:0]!=2'b0)
          inst_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[1:0]!=2'b0)
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
      4'd8: begin
        if (inst_vd[2:0]!=3'b0)
          inst_encoding_correct          = 'b0;
       
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vd[2:0]!=3'b0)        
          else $error("vd is not aligned to emul_vd(%d).\n",emul_vd);
        `endif
      end
    endcase
    
    // check whether vs2 is aligned to emul_vs2
    case(emul_vs2)
      4'd2: begin
        if (inst_vs2[0]!=1'b0)
          inst_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[0]!=1'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      4'd4: begin
        if (inst_vs2[1:0]!=2'b0)
          inst_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[1:0]!=2'b0)
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
      4'd8: begin
        if (inst_vs2[2:0]!=3'b0)
          inst_encoding_correct          = 'b0;
       
        `ifdef ASSERT_ON
          `rvv_forbid(inst_vs2[2:0]!=3'b0)        
          else $error("vs2 is not aligned to emul_vs2(%d).\n",emul_vs2);
        `endif
      end
    endcase
    
    // check whether vs1 is aligned to emul_vs1
 

  end

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
  assign uop_index_start = (uop_vstart>=uop_index_remain) ? 
                            uop_vstart : 
                            uop_index_remain; 

  // calculate the uop_index used in decoding uops 
  for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_INDEX
    assign  uop_index_current[i]  = i[`UOP_INDEX_WIDTH:0]+{1'b0,uop_index_start};
  end

//
// split instruction to uops
//
  // generate uop valid
  always_comb begin        
  for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VALID
    if ((uop_index_current[i]<emul_max)&inst_valid) 
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
      // initial 
      uop[i].uop_funct3           = funct3_ari;

      case(funct6_ari.opi_funct6)
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVI: begin
              // it will be split to NREG vmv.v.v uops
              uop[i].uop_funct3 = OPIVV; 
            end
          endcase 
        end
      endcase

      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

            end
          endcase
        end
      endcase
    end
  end

  // update uop funct6
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT6
      // initial
      uop[i].uop_funct6.opi_funct6            = inst_funct6;
      
      case(funct6_ari.opi_funct6)
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVI: begin
                uop[i].uop_funct6.opi_funct6  = VMERGE_VMV; 
            end
          endcase 
        end
      endcase

      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

            end
          endcase
        end
      endcase
    end
  end

  // allocate uop to execution unit
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      // initial
      uop[i].uop_exe_unit     = 'b0;
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VADD,
        VRSUB,
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
        VMSGTU,
        VMSGT,
        VMERGE_VMV,
        VSADDU,
        VSADD,
        VSSRL,
        VSSRA,
        VNCLIPU,
        VNCLIP: begin
          uop[i].uop_exe_unit = ALU;
        end 
        
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVI: begin 
              uop[i].uop_exe_unit = ALU;
            end
          endcase
        end

        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER: begin
          uop[i].uop_exe_unit = PMTRDT;
        end
      endcase

      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

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
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VADD,
        VRSUB,
        VADC,
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
        VMSGTU,
        VMSGT,
        VMERGE_VMV,
        VSADDU,
        VSADD,
        VSSRL,
        VSSRA,
        VNCLIPU,
        VNCLIP,
        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER: begin
          case(funct3_ari)
            OPIVV: begin
    
            end
            OPIVX: begin
    
            end
            OPIVI: begin
              uop[i].uop_class  = VX;
            end 
          endcase
        end

        VMADC: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].uop_class  = VV;
            end
          endcase
        end

        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVI: begin 
              uop[i].uop_class  = VX;
            end
          endcase
        end
      endcase

      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

            end
          endcase
        end 
      endcase
    end
  end

  // update vector_csr and vstart
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VCSR
      uop[i].vector_csr             = vector_csr_ari;

      // update vstart of every uop
      if(uop_index_current[i]=={1'b0,uop_vstart})
        uop[i].vector_csr.vstart    = vstart;
      else if (eew_max==EEW8)
        uop[i].vector_csr.vstart    = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],4'b0};
      else if (eew_max==EEW16)
        uop[i].vector_csr.vstart    = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],3'b0};
      else if (eew_max==EEW32)
        uop[i].vector_csr.vstart    = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],2'b0};
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
      
      case(funct6_ari.opi_funct6)
        VADC,
        VMADC,
        VMERGE_VMV: begin
          case(funct3_ari)
            OPIVI: begin
              uop[i].v0_valid   = !inst_vm;
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
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VADD,
        VRSUB,
        VADC,
        VAND,
        VOR,
        VXOR,
        VSLL,
        VSMUL_VMVNRR,
        VSRL,
        VSRA,
        VMERGE_VMV,
        VSADDU,
        VSADD,
        VSSRL,
        VSSRA,
        VNCLIPU,
        VNCLIP,
        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
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
        VMSLE,
        VMSGTU,
        VMSGT: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin  
              uop[i].vd_index = inst_vd;
              uop[i].vd_eew   = eew_vd;
              op[i].vd_valid  = 1'b1;
            end
          endcase
        end
      endcase
      
      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

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
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VMADC,
        VMSEQ,
        VMSNE,
        VMSLEU,
        VMSLE,
        VMSGTU,
        VMSGT: begin
          case(funct3_ari)
            OPIVI: begin
              uop[i].vs3_valid = 1'b1;
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
      uop[i].vs1             = 'b0;
      uop[i].vs1_eew         = 'b0;
      uop[i].vs1_index_valid = 'b0;
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].vs1             = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
              uop[i].vs1_eew         = eew_vs2;
              uop[i].vs1_index_valid = 'b1;
            end
          endcase
        end
      endcase
       
      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
        
            end
            OPMVX: begin

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
      uop[i].vs1_opcode_valid       = 'b0;
    end
  end

  // update vs2 index, eew and valid  
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS2
      // initial
      uop[i].vs2_index        = 'b0; 
      uop[i].vs2_eew          = 'b0; 
      uop[i].vs2_valid        = 'b0; 
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VADD,
        VRSUB,
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
        VSSRL,
        VSSRA,
        VNCLIPU,
        VNCLIP,
        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER,
        VMADC,
        VMSEQ,
        VMSNE,
        VMSLEU,
        VMSLE,
        VMSGTU,
        VMSGT: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].vs2_index    = inst_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
              uop[i].vs2_eew      = eew_vs2;
              uop[i].vs2_valid    = 1'b1;
            end
          endcase
        end
        
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].vs2             = 'b0;
              uop[i].vs2_eew         = 'b0;
              uop[i].vs2_index_valid = 'b0;
            end
          endcase
        end
      endcase
       
      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
        
            end
            OPMVX: begin

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
      
      case(funct3_ari)
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // update rs1_data 
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1_DATA
      // initial
      uop[i].rs1_data = 'b0;
      
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
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
          case(funct3_ari)
            OPIVX: begin

            end
            OPIVI: begin
              // sign-extended
              uop[i].rs1_data           = {{(`XLEN-`IMM_WIDTH){inst_imm[`IMM_WIDTH-1]}},inst_imm};
            end
          endcase
        end
       
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVX: begin

            end
            OPIVI: begin
              // no imm
              uop[i].rs1_data           = 'b0;
            end
          endcase

        end

        VSLL,
        VSRL,
        VSRA,
        VSSRL,
        VSSRA: begin
          case(funct3_ari)
            OPIVX: begin

            end
            OPIVI: begin
              // zero-extended 
              if (eew_vs1==EEW8)
                uop[i].rs1_data         = {29'b0,inst_imm[2:0]};
              else if (eew_vs1==EEW16)
                uop[i].rs1_data         = {28'b0,inst_imm[3:0]};
              else if (eew_vs1==EEW32)
                uop[i].rs1_data         = {27'b0,inst_imm[4:0]};
            end
          endcase
        end
        
        VNCLIPU,
        VNCLIP: begin
          case(funct3_ari)
            OPIVX: begin

            end
            OPIVI: begin
              // they will zero-extend log2(2*EEW)-width inst_imm to XLEN-width
              if (eew_vs1==EEW8)
                uop[i].rs1_data         = {28'b0,inst_imm[3:0]};
              else if (eew_vs1==EEW16)
                uop[i].rs1_data         = {27'b0,inst_imm[4:0]};
              else if (eew_vs1==EEW32)
                uop[i].rs1_data         = {26'b0,inst_imm[5:0]};
            end
          endcase
        end
        
        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER: begin
          case(funct3_ari)
            OPIVX: begin

            end
            OPIVI: begin
              // they will zero-extend to XLEN-width directly
              uop[i].rs1_data         = {'b0,inst_imm};
            end
          endcase
        end
      endcase
      
      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
  
            end
            OPMVX: begin

            end
          endcase
        end
      endcase
    end
  end

  // update rs1_valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1_VALID
      // initial
      uop[i].rs1_data_valid   = 'b0;
     
      // allocate OPI* uop to execution unit
      case(funct6_ari.opi_funct6)
        VADD,
        VRSUB,
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
        VSSRL,
        VSSRA,
        VNCLIPU,
        VNCLIP,
        VSLIDEUP,
        VSLIDEDOWN,
        VRGATHER,
        VMADC,
        VMSEQ,
        VMSNE,
        VMSLEU,
        VMSLE,
        VMSGTU,
        VMSGT: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].rs1_data_valid   = 1'b1;
            end
          endcase
        end
        
        VSMUL_VMVNRR: begin
          case(funct3_ari)
            OPIVV: begin

            end
            OPIVX: begin

            end
            OPIVI: begin
              uop[i].rs1_data_valid   = 'b0;
            end
          endcase
        end
      endcase
       
      // allocate OPM* uop to execution unit
      case(funct6_ari.opm_funct6)
        VREDSUM: begin
          case(funct3_ari)
            OPMVV: begin
        
            end
            OPMVX: begin

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
      uop[i].last_uop_valid = (uop_index_current[i] == (emul_max-`VTYPE_VLMUL_WIDTH'd1));
    end
  end


endmodule
