
`include 'rvv.svh'

module rvv_decode_unit_ari
(
  insts_valid,
  insts,
  uop_index_remain,
  uop_valid,
  uop
)
//
// interface signals
//
  input   logic                                   insts_valid;
  input   INST_t                                  insts;
  input   logic [`UOP_INDEX_WIDTH-1:0]            uop_index_remain;
  
  output  logic       [`NUM_DE_UOP-1:0]           uop_valid;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]           uop;

//
// internal signals
//
  // split INST_t struct signals
  logic   [`PC_WIDTH-1:0]                         insts_pc;
  logic   [`FUNCT6_WIDTH-1:0]                     insts_funct6;     // inst original encoding[31:26]           
  logic   [`VM_WIDTH-1:0]                         insts_vm;         // inst original encoding[25]      
  logic   [`VS2_WIDTH-1:0]                        insts_vs2;        // inst original encoding[24:20]
  logic   [`VS1_WIDTH-1:0]                        insts_vs1;        // inst original encoding[19:15]
  logic   [`IMM_WIDTH-1:0]                        insts_imm;        // inst original encoding[19:15]
  logic   [`FUNCT3_WIDTH-1:0]                     insts_funct3;     // inst original encoding[14:12]
  logic   [`VD_WIDTH-1:0]                         insts_vd;         // inst original encoding[11:7]
  logic   [`RD_WIDTH-1:0]                         insts_rd;         // inst original encoding[11:7]
  VECTOR_CSR_t                                    vector_csr_ari;
  logic   [`VTYPE_VILL_WIDTH-1:0]                 vill;             // 0:not illegal, 1:illegal
  logic   [`VTYPE_VSEW_WIDTH-1:0]                 vsew;             // support: 000:SEW8, 001:SEW16, 010:SEW32
  logic   [`VTYPE_VLMUL_WIDTH-1:0]                vlmul;            // support: 110:LMUL1/4, 111:LMUL1/2, 000:LMUL1, 001:LMUL2, 010:LMUL4, 011:LMUL8  
  logic   [`VSTART_WIDTH-1:0]                     vstart;
  logic   [`XLEN-1:0] 	                          rs1_data;
  
  logic   [`VTYPE_VLMUL_WIDTH:0]                  emul_max;         // 0000:emul=0, 0001:emul=1, 0010:emul=2,...  
  EEW_e                                           eew_vd;          
  EEW_e                                           eew_vs1;          
  EEW_e                                           eew_vs2;
  EEW_e                                           eew_max;          
  logic                                           insts_encoding_correct;
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
  assign insts_pc             = insts.insts_pc;
  assign insts_funct6         = insts.insts[26:21];
  assign insts_vm             = insts.insts[20];
  assign insts_vs2            = insts.insts[19:15];
  assign insts_vs1            = insts.insts[14:10];
  assign insts_imm            = insts.insts[14:10];
  assign insts_funct3         = insts.insts[9:7];
  assign insts_vd             = insts.insts[6:2];
  assign insts_rd             = insts.insts[6:2];
  assign vector_csr_ari       = insts.vector_csr;
  assign vill                 = vector_csr_ari.vtype.vill;
  assign vsew                 = vector_csr_ari.vtype.vsew;
  assign vlmul                = vector_csr_ari.vtype.vlmul;
  assign vstart               = vector_csr_ari.vstart;
  assign rs1_data             = insts.rs1_data;
 
  // decode funct3
  assign funct3_ari = ((insts_valid==1'b1)&(vill==1'b0)) ? 
                      insts_funct3 :
                      'b0;
  `ifdef ASSERT_ON
    `rvv_forbid((insts_valid==1'b1)&(vill==1'b1))
    else $error("Unsupported vtype.vill=%d.\n",vill);
  `endif

  // decode arithmetic instruction funct6
  always_comb begin
    // initial the data
    funct6_ari                = 'b0;
    
    case(funct3_ari)
      OPIVV,
      OPIVX,
      OPIVI: begin
        funct6_ari.opi_funct6 = insts_funct6;
      end

      OPMVV,
      OPMVX: begin
        funct6_ari.opm_funct6 = insts_funct6;
      end

      default: begin
        `ifdef ASSERT_ON
          `rvv_forbid((funct3_ari==OPFVV)|(funct3_ari==OPFVF)|(funct3_ari==OPCFG))
          else $error("Unsupported funct3_ari=%s.\n",funct3_ari.name());
        `endif
      end
    endcase
  end

  // get EMUL
  always_comb begin
    // initial
    emul_max         = 'b0;

    case(funct3_ari)
      OPIVV: begin

      end
      OPIVX: begin

      end
      OPIVI: begin
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
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEUP,
          VSLIDEDOWN,
          VRGATHER,
          VMADC,
          VMERGE_VMV: begin
            case(vlmul)
              `LMUL1_4,
              `LMUL1_2,
              `LMUL1: begin
                emul_max    = 4'd1;
              end
              `LMUL2: begin
                emul_max    = 4'd2;
              end
              `LMUL4: begin
                emul_max    = 4'd4;
              end
              `LMUL8: begin
                emul_max    = 4'd8;
              end
            endcase
          end
        endcase
      end
      OPMVV: begin

      end
      OPMVX: begin
        
      end
  end

  `ifdef ASSERT_ON
    `rvv_expect();
    $error("Unsupported vtype.vlmul=%d.\n",vlmul);
  `endif

// get EEW 
  always_comb begin
    // initial
    eew_vd          = 'b0;
    eew_vs1         = 'b0;
    eew_vs2         = 'b0;
    eew_max         = 'b0;

    case(funct3_ari)
      OPIVV: begin

      end
      OPIVX: begin

      end
      OPIVI: begin
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
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEUP,
          VSLIDEDOWN,
          VRGATHER: begin
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

          VMADC: begin
            case(vsew)
              `VSEW8: begin
                eew_vd      = EEW1;
                eew_vs2     = EEW8;
                eew_max     = EEW8;
              end
              `VSEW16: begin
                eew_vd      = EEW1;
                eew_vs2     = EEW16;
                eew_max     = EEW16;
              end
              `VSEW32: begin
                eew_vd      = EEW1;
                eew_vs2     = EEW32;
                eew_max     = EEW32;
              end
            endcase
          end

          VMERGE_VMV: begin
            if (insts_vm==1'b1) begin
              // when vm=1, it's vmv.v.i
              case(vsew)
                `VSEW8: begin
                  eew_vd      = EEW1;
                  eew_max     = EEW8;
                end
                `VSEW16: begin
                  eew_vd      = EEW1;
                  eew_max     = EEW16;
                end
                `VSEW32: begin
                  eew_vd      = EEW1;
                  eew_max     = EEW32;
                end
              endcase
            end
            else begin
              // when vm=0, it's vmerge
              case(vsew)
                `VSEW8: begin
                  eew_vd      = EEW1;
                  eew_vs2     = EEW8;
                  eew_max     = EEW8;
                end
                `VSEW16: begin
                  eew_vd      = EEW1;
                  eew_vs2     = EEW16;
                  eew_max     = EEW16;
                end
                `VSEW32: begin
                  eew_vd      = EEW1;
                  eew_vs2     = EEW32;
                  eew_max     = EEW32;
                end
              endcase
            end
          end
        endcase
      end
      OPMVV: begin

      end
      OPMVX: begin
        
      end
  end

  // opcode error check
  always_comb 
    insts_encoding_correct                = 'b0;
    
    case(funct3_ari)
      OPMVV,
      OPMVX: begin
        // OPM* instruction

      end

      OPIVV,
      OPIVX,
      OPIVI: begin
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
          VSADDU,
          VSADD,
          VSSRL,
          VSSRA,
          VSLIDEUP,
          VSLIDEDOWN,
          VRGATHER: begin
            insts_encoding_correct            = 1'b1;
          end
    
          VADC: begin
            if (insts_vm == 1'b0)
              insts_encoding_correct          = 1'b1;          
            `ifdef ASSERT_ON
              `rvv_expect(insts_vm==1'b0)
              else $error("Unsupported insts_vm=%d in %s instruction.\n",insts_vm,funct6_ari.opi_funct6.name());
            `endif
          end
    
          VMERGE_VMV: begin
            // when vm=1, it is vmv instruction and vs2_index must be 5'b0.
            if ((insts_vm==1'b0)|((insts_vm==1'b1)&(insts_vs2==5'b0)))
              insts_encoding_correct          = 1'b1;          
            `ifdef ASSERT_ON
              `rvv_forbid((insts_vm==1'b0)|((insts_vm==1'b1)&(insts_vs2==5'b0)))
              else $error("Unsupported insts_vm=%d and vs2=%d in %s instruction.\n",insts_vm,insts_vs2,funct6_ari.opi_funct6.name());
            `endif
          end
        endcase
      end
    endcase

    // check whether vd is aligned to emul_max
    case(emul_max)
      4'd2: begin
        if (insts_vd[0]!=1'b0)
          insts_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vd[0]!=1'b0)
          else $error("vd is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
      4'd4: begin
        if (insts_vd[1:0]!=2'b0)
          insts_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vd[1:0]!=2'b0)
          else $error("vd is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
      4'd8: begin
        if (insts_vd[2:0]!=3'b0)
          insts_encoding_correct          = 'b0;
       
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vd[2:0]!=3'b0)        
          else $error("vd is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
    endcase
    
    // check whether vs2 is aligned to emul_max
    case(emul_max)
      4'd2: begin
        if (insts_vs2[0]!=1'b0)
          insts_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vs2[0]!=1'b0)
          else $error("vs2 is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
      4'd4: begin
        if (insts_vs2[1:0]!=2'b0)
          insts_encoding_correct          = 'b0;
        
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vs2[1:0]!=2'b0)
          else $error("vs2 is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
      4'd8: begin
        if (insts_vs2[2:0]!=3'b0)
          insts_encoding_correct          = 'b0;
       
        `ifdef ASSERT_ON
          `rvv_forbid(insts_vs2[2:0]!=3'b0)        
          else $error("vs2 is not aligned to emul_max(%d).\n",emul_max);
        `endif
      end
    endcase
    
    // check whether vs1 is aligned to emul_max
 

  end

  // get the start number of uop_index
  always_comb begin
    // initial
    uop_vstart      = 'b0;

    case(eew_mul)
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
    // initial 
    uop_valid[i]    = 'b0;

    if (uop_index_current[i]<emul_max) 
      uop_valid[i]  = insts_encoding_correct;
  end

  // assign uop pc
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_PC
      uop[i].uop_pc = insts_pc;
    end
  end

  // allocate uop to execution unit
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_EXE_UNIT
      // initial
      uop[i].uop_exe_unit     = NONE;
      
      case(funct3_ari)
        OPMVV,
        OPMVX: begin
          // allocate OPM* uop to execution unit

        end

        OPIVV,
        OPIVX,
        OPIVI: begin
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
            VMERGE_VMV,
            VSADDU,
            VSADD,
            VSSRL,
            VSSRA: begin
              uop[i].uop_exe_unit = ALU;
            end 
            
            VSLIDEUP,
            VSLIDEDOWN,
            VRGATHER: begin
              uop[i].uop_exe_unit = PMTRDT;
            end
          endcase
          
        default: begin
          `ifdef ASSERT_ON
            `rvv_forbid((funct3_ari==OPFVV)|(funct3_ari==OPFVF)|(funct3_ari==OPCFG))
            else $error("Unsupported funct3_ari=%s.\n",funct3_ari.name());
          `endif
        end
      endcase

      `ifdef ASSERT_ON
        `rvv_forbid(uop[i].uop_exe_unit==NONE)
        else $error("Wrong execution unit: %s.\n",uop[i].uop_exe_unit.name());
      `endif
    end
  end
 
  // update uop funct3
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT3
      uop[i].uop_funct3  = funct3_ari;
    end
  end

  // update uop funct6
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_FUNCT6
      // initial
      uop[i].uop_funct6.opi_funct6    = 'b0;

      case(funct3_ari)
        OPIVV,
        OPIVX,
        OPIVI: begin
          uop[i].uop_funct6.opi_funct6  = insts_funct6;
        end
  
        OPMVV,
        OPMVX: begin
          uop[i].uop_funct6.opm_funct6  = insts_funct6;
        end
      endcase
    end
  end

  // update uop class
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_CLASS
      // initial 
      uop[i].uop_class      = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
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
            VRGATHER: begin
              uop[i].uop_class  = VX;
            end 
            
            VMADC: begin
              uop[i].uop_class  = VV;
            end
          endcase
        end
        OPMVV: begin
        
        end
        OPMVX: begin
        
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
      else if (vsew==`VSEW8)
        uop[i].vector_csr.vstart    = {uop_index_current[i][`UOP_INDEX_WIDTH-1:0],4'b0};
      else if (vsew==`VSEW16)
        uop[i].vector_csr.vstart    = {1'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],3'b0};
      else if (vsew==`VSEW32)
        uop[i].vector_csr.vstart    = {2'b0,uop_index_current[i][`UOP_INDEX_WIDTH-1:0],2'b0};
    end
  end

  // update vm field
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_VM
      uop[i].vm = insts_vm;
    end
  end
  
  // some uop need v0 as the vector operand
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_V0
      // initial 
      uop[i].v0_valid           = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
          case(funct6_ari.opi_funct6)
            VADC,
            VMADC: begin
              uop[i].v0_valid   = !insts_vm;
            end
        end
        OPMVV: begin
        
        end
        OPMVX: begin
        
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
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin   
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
            VRGATHER: begin
              uop[i].vd_index = insts_vd+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
              uop[i].vd_eew   = eew_vd;
              uop[i].vd_valid = 1'b1;
            end 
            
            VMADC: begin
              uop[i].vd_index = insts_vd;
              uop[i].vd_eew   = eew_vd;
          u   op[i].vd_valid = 1'b1;
            end
          endcase
        end
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // some uop need vd as the vs3 vector operand
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS3_VALID
      // initial
      uop[i].vs3_valid = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
          case(funct6_ari.opi_funct6)
            VMADC: begin
              uop[i].vs3_valid = 1'b1;
            end
        end
        OPMVV: begin
        
        end
        OPMVX: begin

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
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin

        end
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // some uop will use vs1 field as an opcode to decode  
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_VS1_OPCODE
      // initial
      uop[i].vs1_opcode_valid       = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin

        end
        OPMVV: begin
        
        end
        OPMVX: begin

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
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
          uop[i].vs2_index    = insts_vs2+{'b0,uop_index_current[`UOP_INDEX_WIDTH-1:0]};
          uop[i].vs2_eew      = eew_vs2;
          uop[i].vs2_valid    = 1'b1;
        end
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // update rd_index and valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RD
      // initial
      uop[i].rd_index               = 'b0;
      uop[i].rd_index_valid         = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
        
        end
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
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
          // immediate is zero-extended or sign-extended based on funct6
          case(funct6_ari.opi_funct6)
            VADD,
            VRSUB,
            VADC,
            VMADC,
            VAND,
            VOR,
            VXOR,
            VMERGE_VMV,
            VSADDU,
            VSADD: begin
              // sign-extended
              uop[i].rs1_data           = {{(`XLEN-`IMM_WIDTH){insts_imm[`IMM_WIDTH-1]}},insts_imm};
            end
            
            VSLL,
            VSRL,
            VSRA,
            VSSRL,
            VSSRA: begin
              // zero-extended 
              if (vsew==`VSEW8)
                uop[i].rs1_data         = {29'b0,insts_imm[2:0]};
              else if (vsew==`VSEW16)
                uop[i].rs1_data         = {28'b0,insts_imm[3:0]};
              else if (vsew==`VSEW32)
                uop[i].rs1_data         = {27'b0,insts_imm[4:0]};
            end
            
            VSLIDEUP,
            VSLIDEDOWN,
            VRGATHER: begin
                uop[i].rs1_data         = {'b0,insts_imm};
            end
          endcase
        end
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // update rs1_valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_RS1_VALID
      // initial
        uop[i].rs1_data_valid   = 'b0;
      
      case(funct3_ari)
        OPIVV: begin

        end
        OPIVX: begin

        end
        OPIVI: begin
          uop[i].rs1_data_valid = 1'b1;
        end
        OPMVV: begin
        
        end
        OPMVX: begin

        end
      endcase
    end
  end

  // update uop index
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_INDEX
      uop[i].uop_index = uop_index_current;
    end
  end

  // update last_uop valid
  always_comb
    for(i=0;i<`NUM_DE_UOP;i=i+1) begin: GET_UOP_LAST
      uop[i].last_uop_valid = (uop_index_current == (emul_max-`VTYPE_VLMUL_WIDTH'd1));
    end
  end


endmodule
