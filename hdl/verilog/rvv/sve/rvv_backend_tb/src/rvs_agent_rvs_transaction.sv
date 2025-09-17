`ifndef RVS_TRANSACTION__SV
`define RVS_TRANSACTION__SV

class rvs_transaction extends uvm_sequence_item;
// Members ---------------------------------------------------------------------
// configs -------------------------------------------------
  /* Illegal control field*/
  static bit reserve_vl_vstart_en = 0;
  static bit reserve_inst_en      = 0;
  static bit reserve_vtype_en     = 0;
  static bit overlap_unalign_en   = 0;

  /* VCSR sets */
  static sew_e  vsew_set[]   = '{SEW8, SEW16, SEW32};
  static lmul_e vlmul_set[]  = '{LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
  static vxrm_e vxrm_set[]   = '{RNU, RNE, RDN, ROD};
  static int    vl_min       = 0;
  static int    vl_max       = 128;
  static int    vstart_min   = 0;
  static int    vstart_max   = 127;
  static bit    vm_set[]     = '{0, 1};

  /* Memory access range */
  static int unsigned mem_addr_lo = 32'h0000_0000;
  static int unsigned mem_addr_hi = 32'h0001_0000;

  /* Tr control field */
  rand bit use_vlmax;
       bit is_rt = 0;
       bit is_last_inst = 0;

// inst descriptions ---------------------------------------
  /* VCSR field */
  // vtype
  rand bit               vill;
  rand agnostic_e        vma;
  rand agnostic_e        vta;
  rand sew_e             vsew; 
  rand lmul_e            vlmul;
  rand logic [`XLEN-1:0] vl;
  rand logic [`XLEN-1:0] vlmax;
       logic [`XLEN-1:0] vlmax_max;
  rand int               evl;
  rand logic [`XLEN-1:0] vstart;
  rand vxrm_e            vxrm;

  /* Instruction description field */
  rand inst_type_e  inst_type;// opcode

  // Load/Store inst
  rand lsu_inst_e   lsu_inst;
  rand lsu_mop_e    lsu_mop;  // func6[28:26]
  rand lsu_umop_e   lsu_umop; // src2_idx
  rand lsu_nf_e     lsu_nf;   // func6[31:29]
  rand lsu_width_e  lsu_width;// func3
  rand eew_e        lsu_eew;  // func3 - decoded
  rand lmul_e       lsu_emul;

  // Algoritm inst
  rand alu_type_e alu_type;  // func3
  rand alu_inst_e alu_inst;  // func6
  rand int        alu_nreg;  // vmv<nr>r.v

  rand logic vm; // Mask bit. 0 - Use v0.t

  // Generate operand
  rand operand_type_e dest_type;
  rand operand_type_e src1_type;
  rand operand_type_e src2_type;
  rand operand_type_e src3_type;
  rand logic [4:0] dest_idx;
  rand logic [4:0] src1_idx;
  rand logic [4:0] src2_idx;
  rand logic [4:0] src3_idx;
       vxunary0_e  src1_func_vext;
       vwxunary0_e src2_func_vwxunary0;
       vwxunary0_e src1_func_vwxunary0;
       vmunary0_e  src1_func_vmunary0;
   
  rand logic [`XLEN-1:0] rs2_data;
  rand logic [`XLEN-1:0] rs1_data;

  /* Real instruction */
  rand logic [31:0] pc;
       logic [31:0] bin_inst; 
       string asm_string;

// decode info ---------------------------------------------
       int    eew;
       real   emul;

       int    eew_max;
       real   emul_max;
       int    elm_idx_max;

       int    dest_eew;
       int    src3_eew;
       int    src2_eew;
       int    src1_eew;
       real   dest_emul;
       real   src3_emul;
       real   src2_emul;
       real   src1_emul;

       int    dest_idx_base;
       int    src1_idx_base;
       int    src2_idx_base;
       int    src3_idx_base;
       int    dest_idx_last;
       int    src1_idx_last;
       int    src2_idx_last;
       int    src3_idx_last;

       int    seg_num;

       bit    use_vm_to_cal;

       bit    is_widen_inst;
       bit    is_widen_vs2_inst;
       bit    is_narrow_inst;
       bit    is_mask_producing_inst;
       bit    is_reduction_inst;
       bit    is_permutation_inst;

// writeback info records ----------------------------------
  /* Write back info */
       reg_idx_t  rt_vrf_index  [$];
       vrf_byte_t rt_vrf_strobe [$];
       vrf_t      rt_vrf_data   [$];

       reg_idx_t  rt_xrf_index [$];
       xrf_t      rt_xrf_data  [$];

       logic [`XLEN-1:0] vxsat;  
       logic             vxsat_valid;  

  /* Trap info */
       bit          trap_occured;
       agnostic_e   trap_vma;
       agnostic_e   trap_vta;
       sew_e        trap_vsew; 
       lmul_e       trap_vlmul;
       int          trap_vl;
       int          trap_vstart;
       vxrm_e       trap_vxrm;

// Constrain -------------------------------------------------------------------
  constraint c_solve_order {
    solve inst_type before src3_type;
    solve inst_type before alu_inst;
    // solve lsu_inst before inst_type;
    solve inst_type before lsu_inst;

    // ALU insts solve order will be:
    //   inst_type -> alu_inst -> alu_type/alu_nreg -> op_type -> op_idx/vm 
    //   -> vtypes -> vl -> vstart
    // vl should be: 
    //   vlmax -> vl -> evl  
    
    solve alu_inst before alu_type;
    solve alu_inst before alu_nreg;

    solve alu_type before dest_type;
    solve alu_type before src2_type;
    solve alu_type before src1_type;    
    solve alu_nreg before dest_type;
    solve alu_nreg before src2_type;
    solve alu_nreg before src1_type;    

    solve dest_type before dest_idx;
    solve src2_type before src2_idx;
    solve src1_type before src1_idx;

    solve dest_type before vm;
    solve src2_type before vm;
    solve src1_type before vm;

    solve dest_idx before vma;
    solve src2_idx before vma;
    solve src1_idx before vma;
    solve dest_idx before vta;
    solve src2_idx before vta;
    solve src1_idx before vta;
    solve dest_idx before vsew;
    solve src2_idx before vsew;
    solve src1_idx before vsew;
    solve dest_idx before vlmul;
    solve src2_idx before vlmul;
    solve src1_idx before vlmul;

    solve vma   before vlmax;
    solve vta   before vlmax;
    solve vsew  before vlmax;
    solve vlmul before vlmax;
    solve vlmax before vl;
    solve vl    before evl;
    solve evl   before vstart;

    // LSU insts solve order will be:
    //   inst_type -> lsu_mop -> op_idx/vm/lsu_umop -> lsu_nf/lsu_width
    //   -> vtypes -> vl -> vstart
    // vl should be: 
    //   vlmax -> vl -> evl  
    // vtype should be:
    //   vsew -> vlmul
    // lsu_inst is only an inst description. 
    //   It will be mapped to specific lsu_mop/lsu_eew/lsu_nf.
    
    solve inst_type before lsu_mop;
    solve lsu_mop   before dest_type;
    solve lsu_mop   before src3_type;
    solve lsu_mop   before src2_type;
    solve lsu_mop   before src1_type; 

    solve dest_type before dest_idx;
    solve src3_type before src3_idx;
    solve src2_type before src2_idx;
    solve src1_type before src1_idx;

    solve dest_type before vm;
    solve src3_type before vm;
    solve src2_type before vm;
    solve src1_type before vm;

    solve dest_idx before lsu_nf;
    solve src3_idx before lsu_nf;
    solve src2_idx before lsu_nf;
    solve src1_idx before lsu_nf;

    solve dest_idx before lsu_width;
    solve src3_idx before lsu_width;
    solve src2_idx before lsu_width;
    solve src1_idx before lsu_width;

    solve lsu_nf before vsew;
    solve lsu_nf before lsu_eew;
    solve vsew   before vlmul;
    solve vsew   before vlmax;
    solve vlmul  before vlmax;
    solve vlmax  before vl;
    solve vl     before evl;
    solve evl    before vstart;

    solve src2_idx before rs2_data;
    solve src1_idx before rs1_data;
  }

  constraint c_vcsr_normal_set {
    vill == 0;
    vsew   inside {vsew_set};
    vlmul  inside {vlmul_set};
    vxrm   inside {vxrm_set};
    vl     inside {[vl_min:vl_max]};
    vstart inside {[vstart_min:vstart_max]};
    vm     inside {vm_set};
  }

  constraint c_vl_vstart {
    if(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}){
      // Special case: For mask logic inst, DUT will tread any elements > vl as tail and calculate result.
      vlmax == vlmax_max;  
    } else if(inst_type == ALU && alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF}) {
      // Special case: For mask set inst, DUT will tread any elements > vl as tail and calculate result.
      vlmax == vlmax_max;  
    } else if(inst_type == ALU && alu_inst inside {VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT, VMADC, VMSBC}) {
      // Special case: For mask compare & carry produce inst, DUT will use vlmax==`VLEN/sew will vlmax, and calculate the result.
      if(vlmul[2]) // fraction_lmul
        vlmax == (`VLENB >> vsew);
      else  
        vlmax == ((`VLENB << vlmul) >> vsew);
    } else {
      if(vlmul[2]) // fraction_lmul
        vlmax == ((`VLENB >> (~vlmul +3'b1)) >> vsew);
      else  
        vlmax == ((`VLENB << vlmul) >> vsew);
    }

    vl <= vlmax_max;
    vstart <= vlmax_max-1;

    // Since vl is set by frontend, vl sent to backend should always be leagal value. 
    // vl
    vl <= vlmax;

    // evl
    if(inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) {
      // vmv<nr>r
      evl == ((alu_nreg + 1) * `VLENB) >> vsew;
    } else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK) {
      // vlm/vsm
      if(vl%8 > 0) evl == int'(vl/8) + 1;
      else         evl == int'(vl/8);
    } else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG) {
      // vl<nf> / vs<nf>
      evl == (lsu_nf+1) * `VLEN / lsu_eew;
    } else {
      evl == vl;
    }
    if(!reserve_vl_vstart_en) {
      // vl
      if(inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVX && src2_idx inside {VMV_S_X}) {
        // for vmv.s.x, vl == 0 will be discarded in backend
        vl > 0;
      }

      // vstart
      if(inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) {
        // vmv<nr>r
        vstart < evl;
      } else if(inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VCPOP, VFIRST}) {
        // for vcpop, vfirst, vstart > 0 will raise an ill-inst exception
        // for vcpop, vfirst, vstart >= vl is allowed and will not be discarded
        vstart == 0;
      } else if(inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VMV_X_S}) {
        // for vmv.x.s, vstart >= vl is allowed and will not be discarded
        vstart inside {[0:vlmax_max-1]};
      } else if(inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVX && src2_idx inside {VMV_S_X}) {
        // for vmv.s.x, vstart >= vl & vstart != 0 will be discarded in backend
        vstart == 0;
        vstart < vl;
      } else if(inst_type == ALU && alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA}) {
        vstart == 0;
        vstart < vl;
      } else if(inst_type == ALU && alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU, VREDMIN, VREDMAXU, VREDMAX}) {
        vstart == 0;
        vstart < vl;
      } else if(inst_type == ALU && alu_inst inside {VWREDSUM, VWREDSUMU}) {
        vstart == 0;
        vstart < vl;
      } else if(inst_type == ALU && alu_inst inside {VCOMPRESS}) {
        vstart == 0;
        vstart < vl;
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK) {
        vstart < evl;
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG) {
        vstart < evl;
      } else {
        vstart < vl;
      }
    } else {
    }
  }

  constraint c_operand {
    alu_type inside {OPIVV, OPIVX, OPIVI, OPMVV, OPMVX};

    vm inside {0, 1};
    (inst_type == ALU) -> (src3_type == UNUSE);
    (inst_type == LD)  -> (src3_type == UNUSE);
    (inst_type == ST)  -> (dest_type == UNUSE);
    (inst_type == ALU) -> (lsu_inst  == LSU_UNUSE_INST);
    (inst_type == LD)  -> (alu_inst  == ALU_UNUSE_INST);
    (inst_type == ST)  -> (alu_inst  == ALU_UNUSE_INST);

    dest_idx inside {[0:31]};
    src3_idx inside {[0:31]};
    src2_idx inside {[0:31]};
    src1_idx inside {[0:31]};
    
    if(!reserve_inst_en) {
      // OPI
      if(inst_type == ALU && alu_inst[7:6] == 2'b00) {
        if(!(alu_inst inside {
          VSUB, VRSUB,
          VADC, VSBC, VMSBC, 
          VMINU, VMIN, VMAXU, VMAX,
          VMSLTU, VMSLT, VMSGTU, VMSGT, 
          VMERGE_VMVV, 
          VSLL, VSRL, VSRA, VNSRL, VNSRA,
          VSSRL, VSSRA, VNCLIPU, VNCLIP,
          VWREDSUMU, VWREDSUM, VRGATHER,
          VSMUL_VMVNRR,
          VSLIDEDOWN,
          VSSUBU, VSSUB
          })) { 
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);
        }

        if(alu_inst inside {
          VSUB, 
          VMSBC, 
          VMINU, VMIN, VMAXU, VMAX,
          VMSLTU, VMSLT,
          VSSUBU, VSSUB
          }) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }

        if(alu_inst inside {VADC}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0);
        }

        if(alu_inst inside {VSBC}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0);
        }

        if(alu_inst inside {
          VRSUB,
          VMSGTU, VMSGT
          }) {
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);
        }

        if(alu_inst inside {VMERGE_VMVV}) {
          // vmerge
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0) ||
          // vmv.v
          (alu_type == OPIVV && dest_type == VRF && src2_type == UNUSE && src1_type == VRF && vm == 1 && src2_idx == 0) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == UNUSE && src1_type == XRF && vm == 1 && src2_idx == 0) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == UNUSE && src1_type == IMM && vm == 1 && src2_idx == 0);
        }

        if(alu_inst inside {
          VSLL, VSRL, VSRA, VNSRL, VNSRA,
          VSSRL, VSSRA, VNCLIPU, VNCLIP
          }) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM);
        }

        if(alu_inst inside {VWREDSUMU, VWREDSUM}) {
          (alu_type == OPIVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR);
        }

        if(alu_inst inside {VSLIDEDOWN}) {
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM); 
        }

        if(alu_inst inside {VRGATHER}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM); 
        }

        if(alu_inst inside {VSMUL_VMVNRR}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) ||         // vsmul
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||         // vsmul
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == FUNC && vm == 1 && alu_nreg inside {0, 1, 3, 7} && src1_idx == alu_nreg); // vmv<nr>r
        }
      }

      // OPM
      if(inst_type == ALU && alu_inst[7:6] == 2'b01) {
        if(!(alu_inst inside {
          VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
          VXUNARY0, VMUNARY0, VWXUNARY0, 
          VWMACCUS,
          VREDSUM, VREDAND, VREDOR, VREDXOR, 
          VREDMINU,VREDMIN,VREDMAXU,VREDMAX,
          VSLIDE1UP, VSLIDE1DOWN,
          VCOMPRESS
          })) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ;
        }

        if(alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1);
        }

        if(alu_inst == VXUNARY0) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2});
        }

        if(alu_inst == VMUNARY0) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VIOTA}) || 
          (alu_type == OPMVV && dest_type == VRF && src2_type == UNUSE && src1_type == FUNC && src2_idx == 0 && src1_idx inside {VID}) ||
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VMSBF, VMSOF, VMSIF});
        }

        if(alu_inst == VWXUNARY0) {
          (alu_type == OPMVV && dest_type == XRF    && src2_type == VRF    && src1_type == FUNC && src1_idx inside { VCPOP, VFIRST}) ||
          (alu_type == OPMVV && dest_type == XRF    && src2_type == SCALAR && src1_type == FUNC && vm ==1 && src1_idx inside {VMV_X_S}) ||  // vmv.x.s
          (alu_type == OPMVX && dest_type == SCALAR && src2_type == FUNC   && src1_type == XRF  && vm ==1 && src2_idx inside {VMV_S_X}); // vmv.s.x
        }

        if(alu_inst inside {VWMACCUS}) {
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }
        
        if(alu_inst inside {
          VREDSUM, VREDAND, VREDOR, VREDXOR,
          VREDMINU,VREDMIN,VREDMAXU,VREDMAX
          }) {
          (alu_type == OPMVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR);
        }

        if(alu_inst inside {VSLIDE1UP, VSLIDE1DOWN}) {
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }
        
        if(alu_inst inside {VCOMPRESS}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1);
        }
      }

      // LSU
      // LD
      (lsu_inst == VL)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLSEG)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLM)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1);
      (lsu_inst == VLR)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF1, NF2, NF4, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1);
      (lsu_inst == VLFF)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);
      (lsu_inst == VLSEGFF)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);

      (lsu_inst == VLS)
      <->  (inst_type == LD && lsu_mop == LSU_CS && lsu_nf == NF1 && dest_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VLSSEG)
      <->  (inst_type == LD && lsu_mop == LSU_CS && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VLUX)
      <->  (inst_type == LD && lsu_mop == LSU_UI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLUXSEG)
      <->  (inst_type == LD && lsu_mop == LSU_UI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VLOX)
      <->  (inst_type == LD && lsu_mop == LSU_OI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLOXSEG)
      <->  (inst_type == LD && lsu_mop == LSU_OI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);


      // ST
      (lsu_inst == VS)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSSEG)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSM)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1);
      (lsu_inst == VSR)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {NF1, NF2, NF4, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1);

      (lsu_inst == VSS)
      <->  (inst_type == ST && lsu_mop == LSU_CS && lsu_nf == NF1 && src3_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VSSSEG)
      <->  (inst_type == ST && lsu_mop == LSU_CS && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VSUX)
      <->  (inst_type == ST && lsu_mop == LSU_UI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSUXSEG)
      <->  (inst_type == ST && lsu_mop == LSU_UI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VSOX)
      <->  (inst_type == ST && lsu_mop == LSU_OI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSOXSEG)
      <->  (inst_type == ST && lsu_mop == LSU_OI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

    } else {
      // OPI
      if(inst_type == ALU && alu_inst[7:6] == 2'b00) {
        if(!(alu_inst inside {
          VSUB, VRSUB,
          VADC, VSBC, VMSBC, 
          VMINU, VMIN, VMAXU, VMAX,
          VMSLTU, VMSLT, VMSGTU, VMSGT, 
          VMERGE_VMVV, 
          VSLL, VSRL, VSRA, VNSRL, VNSRA,
          VSSRL, VSSRA, VNCLIPU, VNCLIP,
          VWREDSUMU, VWREDSUM, VRGATHER,
          VSMUL_VMVNRR,
          VSLIDEDOWN,
          VSSUBU, VSSUB
          })) { 
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);
        }

        if(alu_inst inside {
          VSUB, 
          VMSBC, 
          VMINU, VMIN, VMAXU, VMAX,
          VMSLTU, VMSLT,
          VSSUBU, VSSUB
          }) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM); // rsv
        }

        if(alu_inst inside {VADC}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0) || 
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) || // rsv
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 1) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 1);   // rsv
        }

        if(alu_inst inside {VSBC}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) ||
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) || // rsv
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 1) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);              // rsv
        }

        if(alu_inst inside {
          VRSUB,
          VMSGTU, VMSGT
          }) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || // rsv
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);
        }

        if(alu_inst inside {VMERGE_VMVV}) {
          // vmerge
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0) ||
          // vmv.v
          (alu_type == OPIVV && dest_type == VRF && src2_type == UNUSE && src1_type == VRF && vm == 1 && src2_idx == 0) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == UNUSE && src1_type == XRF && vm == 1 && src2_idx == 0) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == UNUSE && src1_type == IMM && vm == 1 && src2_idx == 0) ||
          (alu_type == OPIVV && dest_type == VRF && src2_type == UNUSE && src1_type == VRF && vm == 1 && src2_idx inside {[1:31]}) || // rsv
          (alu_type == OPIVX && dest_type == VRF && src2_type == UNUSE && src1_type == XRF && vm == 1 && src2_idx inside {[1:31]}) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == UNUSE && src1_type == IMM && vm == 1 && src2_idx inside {[1:31]});   // rsv
        }

        if(alu_inst inside {
          VSLL, VSRL, VSRA, VNSRL, VNSRA,
          VSSRL, VSSRA, VNCLIPU, VNCLIP
          }) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM);
        }

        if(alu_inst inside {VWREDSUMU, VWREDSUM}) {
          (alu_type == OPIVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR) || 
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM);  // rsv
        }

        if(alu_inst inside {VSLIDEDOWN}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || // rsv
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM); 
        }

        if(alu_inst inside {VRGATHER}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) ||
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM); 
        }

        if(alu_inst inside {VSMUL_VMVNRR}) {
          (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) ||         // vsmul
          (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||         // vsmul
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == FUNC && vm == 1 && alu_nreg inside {0, 1, 3, 7} && src1_idx == alu_nreg) || // vmv<nr>r
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == FUNC && vm == 1 && alu_nreg inside {2, 4, 5, 6} && src1_idx == alu_nreg) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == FUNC && vm == 1 && alu_nreg inside {[8:31]}     && src1_idx == alu_nreg) || // rsv
          (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0); // rsv
        }
      } // OPI

      // OPM
      if(inst_type == ALU && alu_inst[7:6] == 2'b01) {
        if(!(alu_inst inside {
          VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
          VXUNARY0, VMUNARY0, VWXUNARY0, 
          VWMACCUS,
          VREDSUM, VREDAND, VREDOR, VREDXOR, 
          VREDMINU,VREDMIN,VREDMAXU,VREDMAX,
          VSLIDE1UP, VSLIDE1DOWN,
          VCOMPRESS
          })) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ;
        }

        if(alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) ||
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ; // rsv
        }

        if(alu_inst == VXUNARY0) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2}) || 
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {[0:3], [8:31]}) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ; // rsv
        }

        if(alu_inst == VMUNARY0) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VIOTA}) || 
          (alu_type == OPMVV && dest_type == VRF && src2_type == UNUSE && src1_type == FUNC && src2_idx == 0 && src1_idx inside {VID}) ||
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VMSBF, VMSOF, VMSIF}) ||
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {[0:31]} && !(src1_idx inside {VIOTA, VID})) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ; // rsv
        }

        if(alu_inst == VWXUNARY0) {
          (alu_type == OPMVV && dest_type == XRF    && src2_type == VRF    && src1_type == FUNC && src1_idx inside { VCPOP, VFIRST}) ||
          (alu_type == OPMVV && dest_type == XRF    && src2_type == SCALAR && src1_type == FUNC && vm ==1 && src1_idx inside {VMV_X_S}) || // vmv.x.s
          (alu_type == OPMVX && dest_type == SCALAR && src2_type == FUNC   && src1_type == XRF  && vm ==1 && src2_idx inside {VMV_S_X}) || // vmv.s.x
          (alu_type == OPMVV && dest_type == XRF    && src2_type == SCALAR && src1_type == FUNC && vm ==0 && src1_idx inside {VMV_X_S}) || // rsv
          (alu_type == OPMVV && dest_type == XRF    && src2_type == VRF    && src1_type == FUNC && !(src1_idx inside { VCPOP, VFIRST, VMV_X_S})) || // rsv
          (alu_type == OPMVX && dest_type == SCALAR && src2_type == FUNC   && src1_type == XRF  && vm ==0 && src2_idx inside {VMV_S_X}) || // rsv
          (alu_type == OPMVX && dest_type == SCALAR && src2_type == FUNC   && src1_type == XRF  && !(src2_idx inside {VMV_X_S})); // rsv
        }

        if(alu_inst inside {VWMACCUS}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }
        
        if(alu_inst inside {
          VREDSUM, VREDAND, VREDOR, VREDXOR,
          VREDMINU,VREDMIN,VREDMAXU,VREDMAX
          }) {
          (alu_type == OPMVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }

        if(alu_inst inside {VSLIDE1UP, VSLIDE1DOWN}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }
        
        if(alu_inst inside {VCOMPRESS}) {
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) || 
          (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || // rsv
          (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF);
        }
      } // OPM

      // LSU
      // LD
      (lsu_inst == VL)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLSEG)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLM)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1) ||
           (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 0) || // rsv
           (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {[1:7]} && dest_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF);   // rsv
      (lsu_inst == VLR)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF1, NF2, NF4, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1) ||
           (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {[0:7]} && dest_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm inside {0, 1}); // rsv
      (lsu_inst == VLFF)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);
      (lsu_inst == VLSEGFF)
      <->  (inst_type == LD && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);

      (lsu_inst == VLS)
      <->  (inst_type == LD && lsu_mop == LSU_CS && lsu_nf == NF1 && dest_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VLSSEG)
      <->  (inst_type == LD && lsu_mop == LSU_CS && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VLUX)
      <->  (inst_type == LD && lsu_mop == LSU_UI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLUXSEG)
      <->  (inst_type == LD && lsu_mop == LSU_UI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VLOX)
      <->  (inst_type == LD && lsu_mop == LSU_OI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLOXSEG)
      <->  (inst_type == LD && lsu_mop == LSU_OI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);


      // ST
      (lsu_inst == VS)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSSEG)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSM)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1) ||
           (inst_type == ST && lsu_mop == LSU_US && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 0) || // rsv
           (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {[1:7]} && src3_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF); // rsv
      (lsu_inst == VSR)
      <->  (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {NF1, NF2, NF4, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1) ||
           (inst_type == ST && lsu_mop == LSU_US && lsu_nf inside {[0:7]} && src3_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm inside {0, 1}); // rsv

      (lsu_inst == VSS)
      <->  (inst_type == ST && lsu_mop == LSU_CS && lsu_nf == NF1 && src3_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VSSSEG)
      <->  (inst_type == ST && lsu_mop == LSU_CS && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VSUX)
      <->  (inst_type == ST && lsu_mop == LSU_UI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSUXSEG)
      <->  (inst_type == ST && lsu_mop == LSU_UI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VSOX)
      <->  (inst_type == ST && lsu_mop == LSU_OI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSOXSEG)
      <->  (inst_type == ST && lsu_mop == LSU_OI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

    }// if(!reserve_inst_en)
  }

  constraint c_sewlmul {
    lsu_width inside {LSU_8BIT, LSU_16BIT, LSU_32BIT};  
    vsew inside {SEW8, SEW16, SEW32};
    vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
    
    (lsu_width == LSU_8BIT)  <-> (lsu_eew == EEW8);
    (lsu_width == LSU_16BIT) <-> (lsu_eew == EEW16);
    (lsu_width == LSU_32BIT) <-> (lsu_eew == EEW32);
    (lsu_width == LSU_64BIT) <-> (lsu_eew == EEW64);

    if(!reserve_vtype_en) {
      if(inst_type == ALU) {
        // widen
        (alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W, 
                          VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCUS, VWMACCSU})
        ->  (vsew inside {SEW8,SEW16} && vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4});

        (alu_inst inside {VWREDSUMU, VWREDSUM})
        ->  (vsew inside {SEW8,SEW16});

        // narrow
        (alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP})
        ->  (vsew inside {SEW8,SEW16} && vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4});

        // vxunary0
        (alu_inst == VXUNARY0 && src1_idx inside {VSEXT_VF2, VZEXT_VF2})
        ->  (vsew inside {SEW16,SEW32} && vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8});

        (alu_inst == VXUNARY0 && src1_idx inside {VSEXT_VF4, VZEXT_VF4})
        ->  (vsew inside {SEW32} && vlmul inside {LMUL1,LMUL2,LMUL4,LMUL8});

        // vrgatherei16.vv
        (alu_inst == VSLIDEUP_RGATHEREI16 && alu_type inside {OPIVV})
        ->  ((vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8} && vsew inside {SEW16,SEW32}) ||
             (vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4} && vsew inside {SEW8,SEW16})
        );
        
      } // ALU
      
      if(inst_type inside {LD, ST}) {
        if(!(lsu_mop == LSU_US && src2_idx inside {MASK, WHOLE_REG})) {
          // lsu_eew:sew = 1:1
          if(lsu_width == LSU_8BIT  && vsew == SEW8  ||
             lsu_width == LSU_16BIT && vsew == SEW16 || 
             lsu_width == LSU_32BIT && vsew == SEW32) {
            (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
            //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
            if(lsu_mop inside {LSU_OI, LSU_UI}) {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
            } else {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
            }
          }
          // lsu_eew:sew = 1:2
          if(lsu_width == LSU_8BIT  && vsew == SEW16 ||
             lsu_width == LSU_16BIT && vsew == SEW32) {
            (vlmul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8});
            //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
            if(lsu_mop inside {LSU_OI, LSU_UI}) {
              (lsu_nf == NF1) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF3) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF4) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF5) -> (vlmul inside {         LMUL1_2, LMUL1                     });
              (lsu_nf == NF6) -> (vlmul inside {         LMUL1_2, LMUL1                     });
              (lsu_nf == NF7) -> (vlmul inside {         LMUL1_2, LMUL1                     });
              (lsu_nf == NF8) -> (vlmul inside {         LMUL1_2, LMUL1                     });
            } else {
              (lsu_nf == NF1) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF3) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF4) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF5) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF6) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF7) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF8) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
            }
          }
          // lsu_eew:sew = 1:4
          if(lsu_width ==  LSU_8BIT && vsew == SEW32) { 
            (vlmul inside {LMUL1,   LMUL2,   LMUL4, LMUL8});
            //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
            if(lsu_mop inside {LSU_OI, LSU_UI}) {
              (lsu_nf == NF1) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF3) -> (vlmul inside {                  LMUL1, LMUL2              });
              (lsu_nf == NF4) -> (vlmul inside {                  LMUL1, LMUL2              });
              (lsu_nf == NF5) -> (vlmul inside {                  LMUL1                     });
              (lsu_nf == NF6) -> (vlmul inside {                  LMUL1                     });
              (lsu_nf == NF7) -> (vlmul inside {                  LMUL1                     });
              (lsu_nf == NF8) -> (vlmul inside {                  LMUL1                     });
            } else {
              (lsu_nf == NF1) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF2) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF3) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF4) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
              (lsu_nf == NF5) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF6) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF7) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF8) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
            }
          }

          // lsu_eew:sew = 2:1
          if(lsu_width == LSU_16BIT && vsew == SEW8 || 
             lsu_width == LSU_32BIT && vsew == SEW16) {
            (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4});
            //emul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8};
            if(lsu_mop inside {LSU_OI, LSU_UI}) {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
            } else {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
            }
          }

          // lsu_eew:sew = 4:1
          if(lsu_width == LSU_32BIT && vsew == SEW8 ) { 
            (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2});
            //emul inside {LMUL1,   LMUL2,   LMUL4, LMUL8};
            if(lsu_mop inside {LSU_OI, LSU_UI}) {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4                                     });
            } else {
              (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
              (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
              (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
              (lsu_nf == NF5) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF6) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF7) -> (vlmul inside {LMUL1_4                                     });
              (lsu_nf == NF8) -> (vlmul inside {LMUL1_4                                     });
            }
          } 
        } else {
          // For special inst
          // vlm/vsm
          (lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK)
          -> (lsu_width == LSU_8BIT);
          // vsr
          (inst_type == ST && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG)
          -> (lsu_width == LSU_8BIT);
          // vlr
          (inst_type == ST && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG)
          -> (lsu_width inside {LSU_8BIT, LSU_16BIT, LSU_32BIT});
        }
      } // LD/ST
    } else {
    }// if(!reserve_vtype_en)
  }

  constraint c_rs_data {
    (src2_type == XRF) -> rs2_data inside {[0:{`XLEN{1'b1}}]};
    (src1_type == XRF) -> rs1_data inside {[0:{`XLEN{1'b1}}]};

    (src2_type == XRF && src1_type == XRF && src2_idx == src1_idx) -> rs1_data == rs2_data;

    //slide
    (alu_inst inside {VSLIDEUP_RGATHEREI16, VSLIDEDOWN, VSLIDE1UP, VSLIDE1DOWN} && alu_type inside {OPIVX, OPMVX})
    -> (rs1_data dist {[0:49] :/ 80, [50:200] :/ 20});
  }

// UVM Marocs ------------------------------------------------------------------
  string __t_config    = "-- CONFIG ----------";
  string __t_inst      = "-- INST ------------";
  string __t_vcsr      = "-- VCSR ------------";
  string __t_vl_vstart = "-- VL_VSTART -------";
  string __t_inst_desc = "-- INST_DESC -------";
  string __t_dest      = "-- DEST ------------";
  string __t_src3      = "-- SRC3 ------------";
  string __t_src2      = "-- SRC2 ------------";
  string __t_src1      = "-- SRC1 ------------";
  string __t_vm        = "-- VM --------------";
  string __t_dec_info  = "-- DECODE_INFO -----";
  string __t_ret_info  = "-- RETIRE_INFO -----";
  string __t_trap_info = "-- TRAP_INFO -------";
  string __t_misc      = "-- MISC ------------";
  `uvm_object_utils_begin(rvs_transaction) 
    `uvm_field_string(__t_config, UVM_ALL_ON)
    `uvm_field_int(reserve_vl_vstart_en,UVM_ALL_ON)
    `uvm_field_int(reserve_inst_en     ,UVM_ALL_ON)
    `uvm_field_int(reserve_vtype_en    ,UVM_ALL_ON)
    `uvm_field_int(overlap_unalign_en,UVM_ALL_ON)

    `uvm_field_string(__t_inst, UVM_ALL_ON)
    `uvm_field_int(pc,UVM_ALL_ON)
    `uvm_field_int(bin_inst,UVM_ALL_ON)
    `uvm_field_int(bin_inst[31:7],UVM_ALL_ON)
    `uvm_field_string(asm_string,UVM_ALL_ON)

    `uvm_field_string(__t_vcsr, UVM_ALL_ON)
    `uvm_field_enum(sew_e,vsew,UVM_ALL_ON)
    `uvm_field_enum(lmul_e,vlmul,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vma,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vta,UVM_ALL_ON)
    `uvm_field_enum(vxrm_e,vxrm,UVM_ALL_ON)

    `uvm_field_string(__t_vl_vstart, UVM_ALL_ON)
    `uvm_field_int(vlmax,UVM_ALL_ON)
    `uvm_field_int(use_vlmax,UVM_ALL_ON)
    `uvm_field_int(vl,UVM_ALL_ON)
    `uvm_field_int(evl,UVM_ALL_ON)
    `uvm_field_int(vstart,UVM_ALL_ON)

    `uvm_field_string(__t_inst_desc, UVM_ALL_ON)
    `uvm_field_enum(inst_type_e,inst_type,UVM_ALL_ON)
    if(inst_type == ALU) begin
      `uvm_field_enum(alu_type_e,alu_type,UVM_ALL_ON)
      `uvm_field_enum(alu_inst_e,alu_inst,UVM_ALL_ON)
    end
    if(inst_type == LD || inst_type == ST) begin
      `uvm_field_enum(lsu_inst_e,lsu_inst,UVM_ALL_ON)
      `uvm_field_enum(lsu_mop_e,lsu_mop,UVM_ALL_ON)
      if(lsu_mop == LSU_US) begin
        `uvm_field_enum(lsu_umop_e,lsu_umop,UVM_ALL_ON)
      end
      `uvm_field_enum(lsu_nf_e,lsu_nf,UVM_ALL_ON)
      `uvm_field_enum(lsu_width_e,lsu_width,UVM_ALL_ON)
      `uvm_field_enum(eew_e,lsu_eew,UVM_ALL_ON)
    end

    `uvm_field_string(__t_vm, UVM_ALL_ON)
    `uvm_field_int(vm,UVM_ALL_ON)

    // dest
    `uvm_field_string(__t_dest, UVM_ALL_ON)
    `uvm_field_enum(operand_type_e,dest_type,UVM_ALL_ON)
    `uvm_field_int(dest_idx,UVM_ALL_ON)
    // src3
    if(src3_type != UNUSE) begin
      `uvm_field_string(__t_src3, UVM_ALL_ON)
      `uvm_field_enum(operand_type_e,src3_type,UVM_ALL_ON)
      `uvm_field_int(src3_idx,UVM_ALL_ON)
    end
    // src2
    `uvm_field_string(__t_src2, UVM_ALL_ON)
    if(src2_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
      `uvm_field_enum(operand_type_e,src2_type,UVM_ALL_ON)
      `uvm_field_enum(vwxunary0_e,src2_func_vwxunary0,UVM_ALL_ON)
      `uvm_field_int(src2_idx,UVM_ALL_ON)
    end else begin
      `uvm_field_enum(operand_type_e,src2_type,UVM_ALL_ON)
      `uvm_field_int(src2_idx,UVM_ALL_ON)
    end
    if(src2_type == XRF) begin
      `uvm_field_int(rs2_data,UVM_ALL_ON)
    end
    // src1
    `uvm_field_string(__t_src1, UVM_ALL_ON)
    if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) begin
      `uvm_field_enum(operand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vxunary0_e,src1_func_vext,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else if(src1_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
      `uvm_field_enum(operand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vwxunary0_e,src1_func_vwxunary0,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else if(src1_type == FUNC && inst_type == ALU && alu_inst == VMUNARY0) begin
      `uvm_field_enum(operand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vmunary0_e,src1_func_vmunary0,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else begin
      `uvm_field_enum(operand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end
    if(src1_type == XRF) begin
      `uvm_field_int(rs1_data,UVM_ALL_ON)
    end
    
    // decode info
    `uvm_field_string(__t_dec_info, UVM_ALL_ON)
    `uvm_field_int(eew, UVM_ALL_ON)
    `uvm_field_real(emul, UVM_ALL_ON)

    `uvm_field_int(eew_max, UVM_ALL_ON)
    `uvm_field_real(emul_max, UVM_ALL_ON)
    `uvm_field_int(elm_idx_max, UVM_ALL_ON)

    `uvm_field_int(dest_eew, UVM_ALL_ON)
    `uvm_field_int(src3_eew, UVM_ALL_ON)
    `uvm_field_int(src2_eew, UVM_ALL_ON)
    `uvm_field_int(src1_eew, UVM_ALL_ON)
    `uvm_field_real(dest_emul, UVM_ALL_ON)
    `uvm_field_real(src3_emul, UVM_ALL_ON)
    `uvm_field_real(src2_emul, UVM_ALL_ON)
    `uvm_field_real(src1_emul, UVM_ALL_ON)

    `uvm_field_int(seg_num, UVM_ALL_ON)

    `uvm_field_int(use_vm_to_cal,UVM_ALL_ON)
    `uvm_field_int(is_widen_inst, UVM_ALL_ON)
    `uvm_field_int(is_widen_vs2_inst, UVM_ALL_ON)
    `uvm_field_int(is_narrow_inst, UVM_ALL_ON)
    `uvm_field_int(is_mask_producing_inst, UVM_ALL_ON)
    `uvm_field_int(is_reduction_inst, UVM_ALL_ON)
    `uvm_field_int(is_permutation_inst, UVM_ALL_ON)

    // retire info
    if(is_rt) begin
    `uvm_field_string(__t_ret_info, UVM_ALL_ON)
      foreach(rt_vrf_index[idx]) begin
        `uvm_field_int(rt_vrf_index[idx] ,UVM_ALL_ON)
        `uvm_field_int(rt_vrf_strobe[idx],UVM_ALL_ON)
        `uvm_field_int(rt_vrf_data[idx]  ,UVM_ALL_ON)
      end
      foreach(rt_xrf_index[idx]) begin
        `uvm_field_int(rt_xrf_index[idx],UVM_ALL_ON)
        `uvm_field_int(rt_xrf_data[idx] ,UVM_ALL_ON)
      end
      `uvm_field_int(vxsat_valid,UVM_ALL_ON)
      `uvm_field_int(vxsat,UVM_ALL_ON)
    end
    if(trap_occured) begin
    `uvm_field_string(__t_trap_info, UVM_ALL_ON)
      `uvm_field_int(trap_occured, UVM_ALL_ON)
      `uvm_field_enum(agnostic_e, trap_vma, UVM_ALL_ON)
      `uvm_field_enum(agnostic_e,trap_vta, UVM_ALL_ON)
      `uvm_field_enum(sew_e, trap_vsew, UVM_ALL_ON) 
      `uvm_field_enum(lmul_e, trap_vlmul, UVM_ALL_ON)
      `uvm_field_int(trap_vl, UVM_ALL_ON)
      `uvm_field_int(trap_vstart, UVM_ALL_ON)
      `uvm_field_enum(vxrm_e, trap_vxrm, UVM_ALL_ON)
    end
    `uvm_field_string(__t_misc, UVM_ALL_ON)
    `uvm_field_int(is_last_inst,UVM_ALL_ON)
  `uvm_object_utils_end

// Methods ---------------------------------------------------------------------
  extern function new(string name = "Trans");
  extern static function void set_mem_range(int unsigned mem_base, int unsigned mem_size);
  extern function void pre_randomize();
  extern function void post_randomize();
  extern function void tr2bin();
  extern function bit bin2tr(logic [31:0] inst_in, logic [`XLEN-1:0] rs_data);
  extern function void set_config_state(logic [`XLEN-1:0] vma, logic [`XLEN-1:0] vta, logic [`XLEN-1:0] vsew, logic [`XLEN-1:0] vlmul, logic [`XLEN-1:0] vl, logic [`XLEN-1:0] vstart, logic [`XLEN-1:0] vxrm);
  extern function void decode_vtype(bit dec_evl = 0, bit dec_vlmax = 0);
  extern function void get_vec_group_range();
  extern protected function void overlap_unalign_correct();
  extern function bit reserve_inst_check();
  extern protected function void asm_string_gen();

endclass: rvs_transaction

static function void rvs_transaction::set_mem_range(int unsigned mem_base, int unsigned mem_size);
  mem_addr_lo = mem_base;
  mem_addr_hi = mem_base + mem_size -1;
endfunction: set_mem_range

function rvs_transaction::new(string name = "Trans");
  super.new(name);
  is_last_inst = 0;
endfunction: new

function void rvs_transaction::pre_randomize();
  super.pre_randomize();
  vlmax_max = 8 * `VLEN / 8;
endfunction: pre_randomize

function void rvs_transaction::post_randomize();
  super.post_randomize();

  if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) begin
    if(!$cast(src1_func_vext,src1_idx))
      src1_func_vext = VXUNARY0_NONE;
  end
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
    if(!$cast(src1_func_vwxunary0,src1_idx))
      src1_func_vwxunary0 = VWXUNARY0_NONE;
  end
  if(src2_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
    if(!$cast(src2_func_vwxunary0,src2_idx))
      src2_func_vwxunary0 = VWXUNARY0_NONE;
  end
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VMUNARY0) begin
    if(!$cast(src1_func_vmunary0,src1_idx))
      src1_func_vmunary0 = VMUNARY0_NONE;
  end
  if(src2_type == FUNC && inst_type inside {LD,ST} && lsu_mop == LSU_US) begin
    if(!$cast(lsu_umop,src2_idx))
      lsu_umop = LSU_UMOP_NONE;
  end
    
  // rs random data
  if(src2_type != XRF) rs2_data = 'x;
  if(src1_type != XRF) rs1_data = 'x;

  // constraint vl
  if(use_vlmax) begin
    if(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
      vl   = vlmax_max;
    end else begin
      vl   = vlmax;
    end
    if(inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) begin
      // NO CHANGE
      // vmv<nr>r
      // evl = ((alu_nreg + 1) * `VLENB) >> vsew;
    end else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK) begin
      // vlm/vsm
      if(vl%8 > 0) evl = int'(vl/8) + 1;
      else         evl = int'(vl/8);
    end else if(inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG) begin
      // NO CHANGE
      // vl<nf> / vs<nf>
      // evl = (lsu_nf+1) * `VLEN / lsu_eew;
    end else begin
      evl = vl;
    end

    vstart = 0;
  end

  decode_vtype(0, 0);
  get_vec_group_range();

  // check overlap
  if(!overlap_unalign_en) begin overlap_unalign_correct(); end
  get_vec_group_range();

  // gen bin_inst
  tr2bin();

  asm_string_gen();
endfunction: post_randomize

function void rvs_transaction::tr2bin();
  /* func6 */
  case(inst_type)
    LD, ST: begin
      bin_inst[31:29] = lsu_nf;
      bin_inst[28]    = 1'b0;
      bin_inst[27:26] = lsu_mop;
    end 
    ALU:bin_inst[31:26] = alu_inst[5:0];
  endcase
  /* vm */
  bin_inst[25]    = vm;
  bin_inst[24:20] = src2_idx;
  bin_inst[19:15] = src1_idx;
  case(inst_type)
    LD, ST: begin
      bin_inst[14:12] = lsu_width;
    end 
    ALU: bin_inst[14:12] = alu_type;
  endcase
  case(inst_type)
    ST:      bin_inst[11:7] = src3_idx; 
    ALU, LD: bin_inst[11:7] = dest_idx;
  endcase
  bin_inst[6:0]   = inst_type;
endfunction: tr2bin

function bit rvs_transaction::bin2tr(logic [31:0] inst_in, logic [`XLEN-1:0] rs_data);
  bin_inst = inst_in;

  // decode bin field
  inst_type = bin_inst[6:0];
  /* func6 */
  case(inst_type)
    LD, ST: begin
      lsu_nf        = bin_inst[31:29];
      lsu_mop       = bin_inst[27:26];
    end
    ALU: begin
      alu_inst[5:0] = bin_inst[31:26];
    end 
  endcase
  /* vm */
  vm            = bin_inst[25];
  src2_idx      = bin_inst[24:20];
  src1_idx      = bin_inst[19:15];
  case(inst_type)
    LD, ST: begin
      lsu_width = bin_inst[14:12];
      if(lsu_width == LSU_8BIT)  lsu_eew = EEW8;
      if(lsu_width == LSU_16BIT) lsu_eew = EEW16;
      if(lsu_width == LSU_32BIT) lsu_eew = EEW32;
      if(lsu_width == LSU_64BIT) lsu_eew = EEW64;
    end 
    ALU: alu_type = bin_inst[14:12];
  endcase
  case(inst_type)
    ST:      src3_idx = bin_inst[11:7]; 
    ALU, LD: dest_idx = bin_inst[11:7];
  endcase

  if(inst_type == ALU) begin
    src3_type = UNUSE;
    // OPI
    if(alu_type inside {OPIVV, OPIVX, OPIVI}) begin
      alu_inst[7:6] = 2'b00;
      if(alu_type == OPIVV) begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = VRF;
        if(alu_inst inside {VMERGE_VMVV} && vm == 1) begin
          src2_type = UNUSE;
        end
        if(alu_inst inside {VWREDSUMU, VWREDSUM}) begin
          dest_type = SCALAR;
          src1_type = SCALAR;
        end
      end
      if(alu_type == OPIVX) begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = XRF;
        if(alu_inst inside {VMERGE_VMVV} && vm == 1) begin
          src2_type = UNUSE;
        end
      end
      if(alu_type == OPIVI) begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = IMM;
        if(alu_inst inside {VMERGE_VMVV} && vm == 1) begin
          src2_type = UNUSE;
        end
        if(alu_inst inside {
          VSLL, VSRL, VSRA, VNSRL, VNSRA,
          VSSRL, VSSRA, VNCLIPU, VNCLIP
        }) begin
          src1_type = UIMM;
        end
        if(alu_inst inside {VRGATHER}) begin
          src1_type = UIMM;
        end
        if(alu_inst inside {VSMUL_VMVNRR}) begin
          src1_type = FUNC;
        end
      end
    end

    // OPM
    if(alu_type inside {OPMVV, OPMVX}) begin
      alu_inst[7:6] = 2'b01;      
      if(alu_type == OPMVV) begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = VRF;
        if(alu_inst == VXUNARY0) begin
          src1_type = FUNC;
        end
        if(alu_inst == VMUNARY0) begin
          src1_type = FUNC;
          if(src1_idx == VID) begin
            src2_type = UNUSE;
          end
        end
        if(alu_inst == VWXUNARY0) begin
          dest_type = XRF;
          src1_type = FUNC;
          if(src1_idx == VMV_X_S) begin
            src2_type = SCALAR;
          end
        end
        if(alu_inst inside {
          VREDSUM, VREDAND, VREDOR, VREDXOR,
          VREDMINU,VREDMIN,VREDMAXU,VREDMAX
        }) begin
          dest_type = SCALAR;
          src2_type = VRF;
          src1_type = SCALAR;
        end
      end
      if(alu_type == OPMVX) begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = XRF;
        if(alu_inst == VWXUNARY0) begin
          dest_type = SCALAR;
          src2_type = FUNC;
          src1_type = XRF;
        end
      end
    end
  end // ALU

  if(inst_type == LD) begin
    src3_type = UNUSE;
    case(lsu_mop)
      LSU_US: begin
        dest_type = VRF;
        src2_type = FUNC;
        src1_type = XRF;
      end
      LSU_CS: begin
        dest_type = VRF;
        src2_type = XRF;
        src1_type = XRF;
      end
      LSU_UI, 
      LSU_OI: begin
        dest_type = VRF;
        src2_type = VRF;
        src1_type = XRF;
      end
    endcase
  end // LD

  if(inst_type == ST) begin
    dest_type = UNUSE;
    case(lsu_mop)
      LSU_US: begin
        src3_type = VRF;
        src2_type = FUNC;
        src1_type = XRF;
      end
      LSU_CS: begin
        src3_type = VRF;
        src2_type = XRF;
        src1_type = XRF;
      end
      LSU_UI, 
      LSU_OI: begin
        src3_type = VRF;
        src2_type = VRF;
        src1_type = XRF;
      end
    endcase
  end // ST

  // misc
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) begin
    if(!$cast(src1_func_vext,src1_idx))
      src1_func_vext = VXUNARY0_NONE;
  end
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
    if(!$cast(src1_func_vwxunary0,src1_idx))
      src1_func_vwxunary0 = VWXUNARY0_NONE;
  end
  if(src2_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
    if(!$cast(src2_func_vwxunary0,src2_idx))
      src2_func_vwxunary0 = VWXUNARY0_NONE;
  end
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VMUNARY0) begin
    if(!$cast(src1_func_vmunary0,src1_idx))
      src1_func_vmunary0 = VMUNARY0_NONE;
  end
  if(src2_type == FUNC && inst_type inside {LD,ST} && lsu_mop == LSU_US) begin
    if(!$cast(lsu_umop,src2_idx))
      lsu_umop = LSU_UMOP_NONE;
  end
    
  if(src2_type == XRF) rs2_data = rs_data; else rs2_data = 'x;
  if(src1_type == XRF) rs1_data = rs_data; else rs1_data = 'x;

  decode_vtype(1, 1);
  get_vec_group_range();
  asm_string_gen();

  return 0;
endfunction: bin2tr

function void rvs_transaction::set_config_state(
  logic [`XLEN-1:0] vma,
  logic [`XLEN-1:0] vta,
  logic [`XLEN-1:0] vsew, 
  logic [`XLEN-1:0] vlmul,
  logic [`XLEN-1:0] vl,
  logic [`XLEN-1:0] vstart,
  logic [`XLEN-1:0] vxrm
);      
  this.vma    = vma;
  this.vta    = vta;
  this.vsew   = vsew; 
  this.vlmul  = vlmul;
  this.vl     = vl;
  this.vstart = vstart;
  this.vxrm   = vxrm;
endfunction: set_config_state

function void rvs_transaction::decode_vtype(bit dec_evl, bit dec_vlmax);      
  // Calculate eew/emul
  if(inst_type == ALU && (alu_inst inside {VADC, VSBC, VMADC, VMSBC, VMERGE_VMVV}))
    use_vm_to_cal = 1;
  else
    use_vm_to_cal = 0;

  is_widen_inst           = inst_type == ALU &&  (alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W, 
                                                                   VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCUS, VWMACCSU});
  is_widen_vs2_inst       = inst_type == ALU &&  (alu_inst inside {VWADD_W, VWADDU_W, VWSUBU_W, VWSUB_W});
  is_narrow_inst          = inst_type == ALU &&  (alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP});
  is_mask_producing_inst  = inst_type == ALU && ((alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
                                                                   VMADC, VMSBC, 
                                                                   VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT}) ||
                                                 (alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF}));
  is_reduction_inst       = inst_type == ALU &&  (alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR, 
                                                                   VREDMINU,VREDMIN,VREDMAXU,VREDMAX,
                                                                   VWREDSUMU, VWREDSUM});
  is_permutation_inst     = inst_type == ALU && ((alu_inst inside {VSMUL_VMVNRR} && alu_type == OPIVI && vm == 1) ||
                                                 (alu_inst inside {VCOMPRESS}) ||
                                                 (alu_inst inside {VSLIDEUP_RGATHEREI16, VSLIDE1UP, VSLIDE1DOWN, VSLIDEDOWN, VRGATHER}) ||
                                                 (alu_inst inside {VWXUNARY0} && src1_type == FUNC && src1_idx inside {VMV_X_S}) ||
                                                 (alu_inst inside {VWXUNARY0} && src2_type == FUNC && src2_idx inside {VMV_X_S}));
  eew       = 8 << vsew;
  dest_eew  = eew;
  src3_eew  = eew;
  src2_eew  = eew;
  src1_eew  = eew;

  emul      = 2.0 ** signed'(vlmul);
  dest_emul = emul;
  src3_emul = emul;
  src2_emul = emul;
  src1_emul = emul;

  eew_max   = eew;
  emul_max  = emul;

  case(inst_type)
    LD: begin
      case(lsu_mop) 
        LSU_US   : begin
          case(lsu_umop)
            MASK: begin
              dest_eew  = EEW8;
              dest_emul = EMUL1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = dest_eew;
              emul_max  = dest_emul;
              seg_num   = lsu_nf + 1;
              evl       = dec_evl ? int'($ceil(vl / 8.0)) : evl;
            end
            WHOLE_REG: begin
              dest_eew  = lsu_eew;
              dest_emul = lsu_nf + 1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = dest_eew;
              emul_max  = dest_emul;
              seg_num   = 1;
              evl       = dec_evl ? dest_emul * `VLEN / dest_eew : evl;
            end
            default: begin
              dest_eew  = lsu_eew;
              dest_emul = dest_eew * emul / eew;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = dest_eew;
              emul_max  = dest_emul;
              seg_num   = lsu_nf + 1;
              evl       = dec_evl ? vl : evl;
            end
          endcase
        end
        LSU_CS  : begin
          dest_eew  = lsu_eew;
          dest_emul = dest_eew * emul / eew;
          src2_eew  = EEW32;
          src2_emul = EMUL1;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          eew_max   = dest_eew;
          emul_max  = dest_emul;
          seg_num   = lsu_nf + 1;
          evl       = dec_evl ? vl : evl;
        end
        LSU_UI, 
        LSU_OI: begin
          dest_eew  = eew;
          dest_emul = emul;
          src2_eew  = lsu_eew;
          src2_emul = src2_eew * emul / eew;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          eew_max   = (dest_eew > src2_eew) ? dest_eew : src2_eew;
          emul_max  = (dest_eew > src2_eew) ? dest_emul: src2_emul;
          seg_num   = lsu_nf + 1;
          evl       = dec_evl ? vl : evl;
        end      
      endcase
    end
    ST: begin
      case(lsu_mop) 
        LSU_US   : begin
          case(lsu_umop)
            MASK: begin
              src3_eew  = EEW8;
              src3_emul = EMUL1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = src3_eew;
              emul_max  = src3_emul;
              seg_num   = lsu_nf + 1;
              evl       = dec_evl ? int'($ceil(vl / 8.0)) : evl;
            end
            WHOLE_REG: begin
              src3_eew  = lsu_eew;
              src3_emul = lsu_nf + 1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = src3_eew;
              emul_max  = src3_emul;
              seg_num   = 1;
              evl       = dec_evl ? src3_emul * `VLEN / src3_eew : evl;
            end
            default: begin
              src3_eew  = lsu_eew;
              src3_emul = src3_eew * emul / eew;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              eew_max   = src3_eew;
              emul_max  = src3_emul;
              seg_num   = lsu_nf + 1;
              evl       = dec_evl ? vl : evl;
            end
          endcase
        end
        LSU_CS  : begin
          src3_eew  = lsu_eew;
          src3_emul = src3_eew * emul / eew;
          src2_eew  = EEW32;
          src2_emul = EMUL1;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          eew_max   = src3_eew;
          emul_max  = src3_emul;
          seg_num   = lsu_nf + 1;
          evl       = dec_evl ? vl : evl;
        end
        LSU_UI, 
        LSU_OI: begin
          src3_eew  = eew;
          src3_emul = emul;
          src2_eew  = lsu_eew;
          src2_emul = src2_eew * emul / eew;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          eew_max   = (src3_eew > src2_eew) ? src3_eew : src2_eew;
          emul_max  = (src3_eew > src2_eew) ? src3_emul: src2_emul;
          seg_num   = lsu_nf + 1;
          evl       = dec_evl ? vl : evl;
        end      
      endcase
    end
    ALU: begin
      // Widen
      if(is_widen_inst) begin
        dest_eew  = dest_eew  * 2;
        dest_emul = dest_emul * 2;
      end
      if(is_widen_vs2_inst) begin
        src2_eew  = src2_eew  * 2;
        src2_emul = src2_emul * 2;
      end
      // Narrow
      if(is_narrow_inst) begin
        src2_eew  = src2_eew  * 2;
        src2_emul = src2_emul * 2;
      end
      // vxunary0
      if(alu_inst == VXUNARY0) begin
        if(src1_idx inside {VSEXT_VF2, VZEXT_VF2}) begin
          src2_eew  = src2_eew  / 2;
          src2_emul = src2_emul / 2;
        end
        if(src1_idx inside {VSEXT_VF4, VZEXT_VF4}) begin
          src2_eew  = src2_eew  / 4;
          src2_emul = src2_emul / 4;
        end
      end
      // mask producing inst
      if(alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
        dest_eew = EEW1;
        dest_emul = dest_emul * dest_eew / eew;
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst inside {VMADC, VMSBC, VMSEQ, VMSNE, VMSLTU, 
                          VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT}) begin
        dest_eew = EEW1;
        dest_emul = dest_emul * dest_eew / eew;
      end
      if(alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF}) begin
        dest_eew = EEW1;
        dest_emul = dest_emul * dest_eew / eew;
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst inside {VMUNARY0} && src1_idx inside {VIOTA, VID}) begin
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VCPOP, VFIRST}) begin
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VMV_X_S} && vm == 1) begin
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst inside {VWXUNARY0} && alu_type == OPMVX && src2_idx inside {VMV_S_X} && vm ==1) begin
        dest_eew = EEW1;
        dest_emul = dest_emul * dest_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      // Reduction inst
      if(is_reduction_inst) begin
        dest_emul = EMUL1;
        src1_emul = EMUL1;
        if(alu_inst inside {VWREDSUM, VWREDSUMU}) begin
          dest_eew = dest_eew * 2;
          src1_eew = src1_eew * 2;
        end
      end
      if(alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) begin
        // vmv<nr>r
        if(src1_idx inside {0,1,3,7}) begin
          dest_emul = src1_idx + 1;
          src2_emul = src1_idx + 1;
          evl       = dec_evl ? dest_emul * `VLEN / dest_eew : evl;
        end
      end 
      // Permutation Instructions.
      if(alu_inst == VSLIDEUP_RGATHEREI16 && alu_type == OPIVV) begin
        src1_eew = EEW16;
        src1_emul = src1_emul * src1_eew / eew;
      end
      if(alu_inst == VCOMPRESS && alu_type == OPMVV) begin
        src1_eew = EEW1;
        src1_emul = EMUL1;
      end

    end // ALU
  endcase

  // dest is xrf
  if(dest_type == XRF) begin
    dest_eew = EEW32;
    dest_emul = EMUL1; 
  end

  if(is_mask_producing_inst) begin
    elm_idx_max = `VLEN;
  end else begin
    elm_idx_max = int'($ceil(emul_max)) * `VLEN / eew_max;
  end

  // decode vlmax
  if(dec_vlmax) begin
    vlmax_max = 8 * `VLEN / 8;
    if(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
      vlmax = vlmax_max;  
    end else if(inst_type == ALU && alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF}) begin
      vlmax = vlmax_max;  
    end else if(inst_type == ALU && alu_inst inside {VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT, VMADC, VMSBC}) begin
      if(vlmul[2]) // fraction_lmul
        vlmax = (`VLENB >> vsew);
      else  
        vlmax = ((`VLENB << vlmul) >> vsew);
    end else begin
      if(vlmul[2]) // fraction_lmul
        vlmax = ((`VLENB >> (~vlmul +3'b1)) >> vsew);
      else  
        vlmax = ((`VLENB << vlmul) >> vsew);
    end
  end

endfunction: decode_vtype

function void rvs_transaction::get_vec_group_range();    
  dest_idx_base = dest_idx;
  src3_idx_base = src3_idx;
  src2_idx_base = src2_idx;
  src1_idx_base = src1_idx;
  dest_idx_last = dest_idx + int'($ceil(dest_emul)) - 1;
  src3_idx_last = src3_idx + int'($ceil(src3_emul)) - 1;
  src2_idx_last = src2_idx + int'($ceil(src2_emul)) - 1;
  src1_idx_last = src1_idx + int'($ceil(src1_emul)) - 1;
  if(inst_type == LD) begin
    dest_idx_last = dest_idx + seg_num * int'($ceil(dest_emul)) - 1;
  end
  if(inst_type == ST) begin
    src3_idx_last = src3_idx + seg_num * int'($ceil(src3_emul)) - 1;
  end  
endfunction: get_vec_group_range

function void rvs_transaction::overlap_unalign_correct();      

  `uvm_info("TR_GEN", "Origin.", UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_eew=%0d, src3_eew=%0d, src2_eew=%0d, src1_eew=%0d", pc, dest_eew, src3_eew, src2_eew, src1_eew), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_emul=%0d, src3_emul=%0d, src2_emul=%0d, src1_emul=%0d", pc, dest_emul, src3_emul, src2_emul, src1_emul), UVM_HIGH)

  // Alignment 
  if(inst_type inside {LD, ST}) begin
    // Over range of segment load/store
    if(dest_type == VRF && (dest_idx + (seg_num) * int'($ceil(dest_emul)) - 1 > 31)) begin
      dest_idx = 32 - (seg_num) * int'($ceil(dest_emul));
    end
    if(src3_type == VRF && (src3_idx + (seg_num) * int'($ceil(src3_emul)) - 1 > 31)) begin
      src3_idx = 32 - (seg_num) * int'($ceil(src3_emul));
    end
  end
  if(dest_type == VRF) dest_idx = dest_idx - dest_idx % int'($ceil(dest_emul));
  if(src3_type == VRF) src3_idx = src3_idx - src3_idx % int'($ceil(src3_emul));
  if(src2_type == VRF) src2_idx = src2_idx - src2_idx % int'($ceil(src2_emul));
  if(src1_type == VRF) src1_idx = src1_idx - src1_idx % int'($ceil(src1_emul));

  `uvm_info("TR_GEN", "After alignment correction.", UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)

  // Overlap
  // Common check
  // vd overlap v0.t
  if(dest_type == VRF && vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
    dest_idx = int'($ceil(dest_emul));
  end
  // vd overlap vs2
  if(dest_type == VRF && src2_type == VRF && (dest_eew > src2_eew) && (dest_emul > 1 || src2_emul > 1) &&
     (src2_idx >= dest_idx) && (src2_idx+int'($ceil(src2_emul)) < dest_idx+int'($ceil(dest_emul)))
  )  begin
    if(vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
      dest_idx = dest_idx + int'($ceil(dest_emul));
    end
    src2_idx = dest_idx + int'($ceil(dest_emul));
  end
  if(dest_type == VRF && src2_type == VRF && (dest_eew < src2_eew) && (dest_emul > 1 || src2_emul > 1) &&
     (dest_idx > src2_idx) && (dest_idx+int'($ceil(dest_emul)) <= src2_idx+int'($ceil(src2_emul)))
  ) begin
    if(vm == 0 && src2_idx == 0 && dest_eew != EEW1)
      dest_idx = src2_idx+int'($ceil(src2_emul));
    else
      dest_idx = src2_idx;
  end
  // vd overlap vs1
  if(dest_type == VRF && src1_type == VRF && (dest_eew > src1_eew) && (dest_emul > 1 || src1_emul > 1) &&
     (src1_idx >= dest_idx) && (src1_idx+int'($ceil(src1_emul)) < dest_idx+int'($ceil(dest_emul)))
  ) begin
    if(vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
      dest_idx = dest_idx + int'($ceil(dest_emul));
    end
    src1_idx = dest_idx + int'($ceil(dest_emul));
  end
  if(dest_type == VRF && src1_type == VRF && (dest_eew < src1_eew) && (dest_emul > 1 || src1_emul > 1) && 
     (dest_idx > src1_idx) && (dest_idx+int'($ceil(dest_emul)) <= src1_idx+int'($ceil(src1_emul)))
  ) begin
    if(vm == 0 && src1_idx == 0 && dest_eew != EEW1)
      dest_idx = src1_idx+int'($ceil(src1_emul));
    else
      dest_idx = src1_idx;
  end

  `uvm_info("TR_GEN", "After common overlap correction.", UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)

  // Special check
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA} && dest_idx == 0 && vm == 0) begin
    dest_idx = int'($ceil(dest_emul));
  end
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx inside {VMSBF, VMSOF, VMSIF} && dest_idx == src2_idx) begin
    if(dest_idx === 31) begin 
      if(vm === 0) dest_idx = 1;
      else dest_idx = 0;
    end else begin
      dest_idx++; 
    end
  end
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx inside {VIOTA} && src2_idx inside {[dest_idx:dest_idx+int'($ceil(dest_emul))-1]}) begin
    src2_idx = dest_idx+int'($ceil(dest_emul));
  end
  // For indexed segment load, vd can't overlap vs2
  // When nf>1, vd cannot overlap any part of vs2.
  // When nf=1, overlap rule follows with normal check(Ch 31.5.1).
  if(inst_type inside {LD} && lsu_mop inside {LSU_UI, LSU_OI} && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8}) begin
    if(dest_type == VRF && src2_type == VRF && 
      ((src2_idx >= dest_idx) && (src2_idx <= dest_idx+(seg_num)*int'($ceil(dest_emul))-1) || 
       (dest_idx >= src2_idx) && (dest_idx <= src2_idx+int'($ceil(src2_emul))-1))
    ) begin
      int src2_idx_temp;
      src2_idx_temp = int'(dest_idx) - int'($ceil(src2_emul))-1;
      if(src2_idx_temp>=0) begin
        src2_idx_temp = src2_idx_temp - src2_idx_temp % int'($ceil(src2_emul));
        src2_idx = src2_idx_temp;
      end else begin
        src2_idx_temp = int'(dest_idx) + (seg_num)*int'($ceil(dest_emul)); 
        src2_idx_temp = src2_idx_temp + int'($ceil(src2_emul)) - src2_idx_temp % int'($ceil(src2_emul));
        if(src2_idx_temp<32) begin
          src2_idx = src2_idx_temp;
        end else begin
          `uvm_fatal("TR_GEN", "Calculating overlap of indexed segment load fatal.")
        end
      end
      `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d, corrected for indexed seg load overlap.", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
    end
  end
  // For vcompress/vrgather/vslideup, vd cannot overlap vector source reg-group 
  if(inst_type == ALU && alu_inst inside {VCOMPRESS,VSLIDEUP_RGATHEREI16,VRGATHER,VSLIDE1UP}) begin
    // vd overlap vs2
    if(dest_type == VRF && src2_type == VRF && 
      ((dest_idx >= src2_idx) && (dest_idx <= src2_idx+int'($ceil(src2_emul))-1) ||
       (src2_idx >= dest_idx) && (src2_idx <= dest_idx+int'($ceil(dest_emul))-1)
      )) begin 
      int src2_idx_temp;
      src2_idx_temp = int'(dest_idx) - int'($ceil(src2_emul))-1;
      if(src2_idx_temp>=0) begin
        src2_idx_temp = src2_idx_temp - src2_idx_temp % int'($ceil(src2_emul));
        src2_idx = src2_idx_temp;
      end else begin
        src2_idx_temp = int'(dest_idx) + int'($ceil(dest_emul)); 
        src2_idx_temp = src2_idx_temp + int'($ceil(src2_emul)) - src2_idx_temp % int'($ceil(src2_emul));
        if(src2_idx_temp<32) begin
          src2_idx = src2_idx_temp;
        end else begin
          `uvm_fatal("TR_GEN", "Calculating overlap of indexed segment load fatal.")
        end
      end
    end
    // vd overlap vs1
    if(dest_type == VRF && src1_type == VRF && 
      ((dest_idx >= src1_idx) && (dest_idx <= src1_idx+int'($ceil(src1_emul))-1) ||
       (src1_idx >= dest_idx) && (src1_idx <= dest_idx+int'($ceil(dest_emul))-1)
      )) begin 
      int src1_idx_temp;
      src1_idx_temp = int'(dest_idx) - int'($ceil(src1_emul)) - 1;
      if(src1_idx_temp>=0) begin
        src1_idx_temp = src1_idx_temp - src1_idx_temp % int'($ceil(src1_emul));
        src1_idx = src1_idx_temp;
      end else begin
        src1_idx_temp = int'(dest_idx) + int'($ceil(dest_emul)); 
        src1_idx_temp = src1_idx_temp + int'($ceil(src1_emul)) - src1_idx_temp % int'($ceil(src1_emul));
        if(src1_idx_temp<32) begin
          src1_idx = src1_idx_temp;
        end else begin
          `uvm_fatal("TR_GEN", "Calculating overlap of indexed segment load fatal.")
        end
      end
    end
  end

  `uvm_info("TR_GEN", "After special overlap correction.", UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)

  `uvm_info("TR_GEN", "Correction.", UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_eew=%0d, src3_eew=%0d, src2_eew=%0d, src1_eew=%0d", pc, dest_eew, src3_eew, src2_eew, src1_eew), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_emul=%0d, src3_emul=%0d, src2_emul=%0d, src1_emul=%0d", pc, dest_emul, src3_emul, src2_emul, src1_emul), UVM_HIGH)

endfunction: overlap_unalign_correct

function bit rvs_transaction::reserve_inst_check();
  enum bit {FAIL = 0, PASS = 1} __sta;

// vl/evl/vstart check -------------------------------------
  if((vl > vlmax_max)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vl(%0d) >= vlmax_max(%0d).", pc, vl, vlmax_max));
    return FAIL;
  end
  if((vstart > vlmax_max-1)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) >= vlmax_max(%0d).", pc, vstart, vlmax_max));
    return FAIL;
  end
  if((vl > vlmax) && !(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR})) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vl(%0d) >= vlmax(%0d).", pc, vl, vlmax));
    return FAIL;
  end

  if((vl == 0) && (inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVX && src2_idx inside {VMV_S_X})) begin
    // for vmv.s.x, vl == 0 will be discarded in backend
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vl(%0d) >= vlmax(%0d).", pc, vl, vlmax));
    return FAIL;
  end

  if((inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) || 
     (inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK) ||
     (inst_type inside {LD, ST} && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG)
  ) begin
    if(vstart >= evl) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) >= evl(%0d).", pc, vstart, evl));
      return FAIL;
    end
  end else if(
     (inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVX && src2_idx inside {VMV_S_X}) ||
     (inst_type == ALU && alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA}) ||
     (inst_type == ALU && alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU, VREDMIN, VREDMAXU, VREDMAX}) || 
     (inst_type == ALU && alu_inst inside {VWREDSUM, VWREDSUMU}) ||
     (inst_type == ALU && alu_inst inside {VCOMPRESS})
  ) begin
    if(vstart != 0) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) != 0.", pc, vstart));
      return FAIL;
    end
    if(vstart >= vl) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) >= vl(%0d).", pc, vstart, vl));
      return FAIL;
    end
  end else if(
     (inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VCPOP, VFIRST})
  ) begin
    if(vstart != 0) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) != 0.", pc, vstart));
      return FAIL;
    end
    // for vcpop, vfirst, vstart >= vl is allowed and will not be discarded
  end else if(
     (inst_type == ALU && alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VMV_X_S})
  ) begin
    // for vmv.x.s, vstart >= vl is allowed and will not be discarded
  end else begin
    if(vstart >= vl) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vstart(%0d) >= evl(%0d).", pc, vl, evl));
      return FAIL;
    end
  end

// operand check -------------------------------------------
  // OPI
  if(inst_type == ALU && alu_inst[7:6] == 2'b00) begin
    if(alu_inst inside {
      VSUB, 
      VMSBC, 
      VMINU, VMIN, VMAXU, VMAX,
      VMSLTU, VMSLT,
      VSSUBU, VSSUB
    }) begin
      if(!(alu_type inside {OPIVV, OPIVX})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end 

    if(alu_inst inside {VADC}) begin
      if(vm == 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 1 of %s is reserved.", pc, alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VSBC}) begin
      if(!(alu_type inside {OPIVV, OPIVX})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
      if(vm == 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 1 of %s is reserved.", pc, alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {
      VRSUB,
      VMSGTU, VMSGT
    }) begin
      if(!(alu_type inside {OPIVX, OPIVI})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VMERGE_VMVV}) begin
      if(vm == 1 && src2_idx != 0) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src2_idx(%0d) != 0 of vmv.v is reserved.", pc, src2_idx));
        return FAIL;
      end
    end

    if(alu_inst inside {VWREDSUMU, VWREDSUM}) begin
      if(!(alu_type inside {OPIVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VSLIDEDOWN}) begin
      if(!(alu_type inside {OPIVX, OPIVI})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: OPIVV of %s is reserved.", pc, alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VSMUL_VMVNRR}) begin
      if(alu_type == OPIVI && vm == 0) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 0 of vmv<nr>r is reserved.", pc));
        return FAIL;
      end
      if(alu_type == OPIVI && !(src1_idx inside {0, 1, 3, 7})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: nr == %0d of vmv<nr>r is reserved.", pc, src1_idx));
        return FAIL;
      end
    end
  end

  // OPM
  if(inst_type == ALU && alu_inst[7:6] == 2'b01) begin
    if(alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
      if(!(alu_type inside {OPMVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: OPMVX of %s is reserved.", pc, alu_inst.name()));
        return FAIL;
      end
      if(vm == 0) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 0 of %0s is reserved.", pc, alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VXUNARY0}) begin
      if(!(alu_type inside {OPMVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVV && !(src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src1_idx == %0d of %s is reserved.", pc, src1_idx, alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VMUNARY0}) begin
      if(!(alu_type inside {OPMVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVV && !(src1_idx inside {VIOTA, VID, VMSBF, VMSOF, VMSIF})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src1_idx == %0d of %s is reserved.", pc, src1_idx, alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVV && (src1_idx == VID && src2_idx != 0)) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src2_idx(%0d) != 0 of vid is reserved.", pc, src2_idx));
        return FAIL;
      end
    end

    if(alu_inst inside {VWXUNARY0}) begin
      if(alu_type == OPMVV && !(src1_idx inside {VCPOP, VFIRST, VMV_X_S})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src1_idx == %0d of %s is reserved.", pc, src1_idx, alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVX && !(src2_idx inside {VMV_S_X})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src2_idx == %0d of %s is reserved.", pc, src2_idx, alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVV && src1_idx inside {VMV_X_S} && vm != 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 0 of vmv.x.s is reserved.", pc));
        return FAIL;
      end
      if(alu_type == OPMVX && src2_idx inside {VMV_S_X} && vm != 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 0 of vmv.s.x is reserved.", pc));
        return FAIL;
      end
    end

    if(alu_inst inside {VWMACCUS}) begin
      if(!(alu_type inside {OPMVX})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU,VREDMIN,VREDMAXU,VREDMAX}) begin
      if(!(alu_type inside {OPMVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VSLIDE1UP, VSLIDE1DOWN}) begin
      if(!(alu_type inside {OPMVX})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst inside {VCOMPRESS}) begin
      if(!(alu_type inside {OPMVV})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: alu_type == %s of %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
      if(alu_type == OPMVV && vm == 0) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm == 0 of alu_type == %s, %s is reserved.", pc, alu_type.name(), alu_inst.name()));
        return FAIL;
      end
    end
  end

  // LD/ST
  if(inst_type inside {LD, ST}) begin
    if(lsu_mop == LSU_US) begin
      if(src2_idx == NORMAL && !(lsu_nf inside {NF1, NF2, NF3, NF4, NF5, NF6, NF7, NF8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_nf == %s of unit-stride load/store is reserved.", pc, lsu_nf.name()));
        return FAIL;
      end
      if(src2_idx == MASK && !(lsu_nf inside {NF1})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_nf == %s of unit-stride mask load/store is reserved.", pc, lsu_nf.name()));
        return FAIL;
      end
      if(src2_idx == MASK && vm != 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm != 1 of unit-stride mask load/store is reserved.", pc));
        return FAIL;
      end
      if(src2_idx == WHOLE_REG && !(lsu_nf inside {NF1, NF2, NF4, NF8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_nf == %s of unit-stride load/store is reserved.", pc, lsu_nf.name()));
        return FAIL;
      end
      if(src2_idx == WHOLE_REG && vm != 1) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vm != 1 of whole-reg load/store is reserved.", pc));
        return FAIL;
      end
      if(src2_idx == FOF && !(lsu_nf inside {NF1, NF2, NF3, NF4, NF5, NF6, NF7, NF8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_nf == %s of unit-stride load/store is reserved.", pc, lsu_nf.name()));
        return FAIL;
      end
    end

    if(lsu_mop == LSU_CS) begin
    end

    if(lsu_mop == LSU_UI) begin
    end

    if(lsu_mop == LSU_OI) begin
    end
  end

// sew/lmul check ------------------------------------------
  if(inst_type == ALU) begin
    if(alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W, 
                        VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCUS, VWMACCSU}
    ) begin
      if(!(vsew inside {SEW8,SEW16})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vsew == %s of %s is reserved.", pc, vsew.name(), alu_inst.name()));
        return FAIL;
      end
      if(!(vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s of %s is reserved.", pc, vlmul.name(), alu_inst.name()));
        return FAIL;
      end
    end
    
    if(alu_inst inside {VWREDSUMU, VWREDSUM}) begin
      if(!(vsew inside {SEW8,SEW16})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vsew == %s of %s is reserved.", pc, vsew.name(), alu_inst.name()));
        return FAIL;
      end
    end
    
    if(alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP}) begin
      if(!(vsew inside {SEW8,SEW16})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vsew == %s of %s is reserved.", pc, vsew.name(), alu_inst.name()));
        return FAIL;
      end
      if(!(vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s of %s is reserved.", pc, vlmul.name(), alu_inst.name()));
        return FAIL;
      end
    end

    if(alu_inst == VXUNARY0) begin
      if(src1_idx inside {VSEXT_VF2, VZEXT_VF2}) begin
        if(!(vsew inside {SEW16,SEW32})) begin
          `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vsew == %s of %s VF2 is reserved.", pc, vsew.name(), alu_inst.name()));
          return FAIL;
        end
        if(!(vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8})) begin
          `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s of %s VF2 is reserved.", pc, vlmul.name(), alu_inst.name()));
          return FAIL;
        end
      end
      if(src1_idx inside {VSEXT_VF4, VZEXT_VF4}) begin
        if(!(vsew inside {SEW32})) begin
          `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vsew == %s of %s VF4 is reserved.", pc, vsew.name(), alu_inst.name()));
          return FAIL;
        end
        if(!(vlmul inside {LMUL1,LMUL2,LMUL4,LMUL8})) begin
          `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s of %s VF4 is reserved.", pc, vlmul.name(), alu_inst.name()));
          return FAIL;
        end
      end
    end

    if(alu_inst == VSLIDEUP_RGATHEREI16 && alu_type inside {OPIVV}) begin
      if(vsew inside {SEW32} && !(vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s of vrgatherei16.vv is reserved.", pc, vlmul.name(), vsew.name()));
        return FAIL;
      end
      if(vsew inside {SEW8} && !(vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s of vrgatherei16.vv is reserved.", pc, vlmul.name(), vsew.name()));
        return FAIL;
      end
    end
  end

  if(inst_type inside {LD, ST} && !(lsu_mop == LSU_US && src2_idx inside {MASK, WHOLE_REG})) begin
    // lsu_eew:sew = 1:1
    if(lsu_width == LSU_8BIT  && vsew == SEW8  ||
       lsu_width == LSU_16BIT && vsew == SEW16 || 
       lsu_width == LSU_32BIT && vsew == SEW32
    ) begin
      if(!(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s, lsu_width == %s is reserved.", pc, vlmul.name(), vsew.name(), lsu_width.name()));
        return FAIL;
      end
      //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      if(lsu_mop inside {LSU_OI, LSU_UI}) begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end else begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end
    end
    // lsu_eew:sew = 1:2
    if(lsu_width == LSU_8BIT  && vsew == SEW16 ||
       lsu_width == LSU_16BIT && vsew == SEW32) begin
      if(!(vlmul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s, lsu_width == %s is reserved.", pc, vlmul.name(), vsew.name(), lsu_width.name()));
        return FAIL;
      end
      //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      if(lsu_mop inside {LSU_OI, LSU_UI}) begin
        if((lsu_nf == NF1) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF3) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF4) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF5) && !(vlmul inside {         LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {         LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {         LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {         LMUL1_2, LMUL1                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end else begin
        if((lsu_nf == NF1) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF3) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF4) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF5) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF6) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF7) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF8) && !(vlmul inside {         LMUL1_2, LMUL1, LMUL2              }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end
    end
    // lsu_eew:sew = 1:4
    if(lsu_width ==  LSU_8BIT && vsew == SEW32) begin
      if(!(vlmul inside {LMUL1,   LMUL2,   LMUL4, LMUL8})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s, lsu_width == %s is reserved.", pc, vlmul.name(), vsew.name(), lsu_width.name()));
        return FAIL;
      end
      //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      if(lsu_mop inside {LSU_OI, LSU_UI}) begin
        if((lsu_nf == NF1) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF3) && !(vlmul inside {                  LMUL1, LMUL2              }) ||
           (lsu_nf == NF4) && !(vlmul inside {                  LMUL1, LMUL2              }) ||
           (lsu_nf == NF5) && !(vlmul inside {                  LMUL1                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {                  LMUL1                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {                  LMUL1                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {                  LMUL1                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end else begin
        if((lsu_nf == NF1) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF2) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF3) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF4) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8}) ||
           (lsu_nf == NF5) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF6) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF7) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF8) && !(vlmul inside {                  LMUL1, LMUL2, LMUL4       }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end
    end
    // lsu_eew:sew = 2:1
    if(lsu_width == LSU_16BIT && vsew == SEW8 || 
       lsu_width == LSU_32BIT && vsew == SEW16) begin
      if(!(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s, lsu_width == %s is reserved.", pc, vlmul.name(), vsew.name(), lsu_width.name()));
        return FAIL;
      end
      //emul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8};
      if(lsu_mop inside {LSU_OI, LSU_UI}) begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end else begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       }) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end
    end
    // lsu_eew:sew = 4:1
    if(lsu_width == LSU_32BIT && vsew == SEW8 ) begin
      if(!(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2})) begin
        `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: vlmul == %s, vsew == %s, lsu_width == %s is reserved.", pc, vlmul.name(), vsew.name(), lsu_width.name()));
        return FAIL;
      end
      //emul inside {LMUL1,   LMUL2,   LMUL4, LMUL8};
      if(lsu_mop inside {LSU_OI, LSU_UI}) begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4                                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end else begin
        if((lsu_nf == NF1) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              }) ||
           (lsu_nf == NF2) && !(vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     }) ||
           (lsu_nf == NF3) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF4) && !(vlmul inside {LMUL1_4, LMUL1_2                            }) ||
           (lsu_nf == NF5) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF6) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF7) && !(vlmul inside {LMUL1_4                                     }) ||
           (lsu_nf == NF8) && !(vlmul inside {LMUL1_4                                     }) 
        ) begin
          `uvm_warning("TR/INST_CHECK", 
                       $sformatf("pc=0x%8x: lsu_nf == %s, vlmul == %s, vsew == %s, lsu_width == %s is reserved.", 
                       pc, lsu_nf.name(), vlmul.name(), vsew.name(), lsu_width.name()));
          return FAIL;
        end
      end
    end
  end
  if(lsu_mop == LSU_US && src2_type == FUNC && src2_idx == MASK && !(lsu_width == LSU_8BIT)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_width == %s of unit-stride mask load/store is reserved.", pc, lsu_width.name()));
    return FAIL;
  end
  if(inst_type == ST && lsu_mop == LSU_US && src2_type == FUNC && src2_idx == WHOLE_REG && !(lsu_width == LSU_8BIT)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: lsu_width == %s of whole-reg store is reserved.", pc, lsu_width.name()));
    return FAIL;
  end

// unalignment check -------------------------------------------
  if(inst_type inside {LD, ST}) begin
    // Over range of segment load/store
    if(dest_type == VRF && dest_idx_last > 31) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: dest_idx(v%0d~v%0d) of load out of range.", pc, dest_idx_base, dest_idx_last));
      return FAIL;
    end
    if(src3_type == VRF && src3_idx_last > 31) begin
      `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src3_idx(v%0d~v%0d) of store out of range.", pc, src3_idx_base, src3_idx_last));
      return FAIL;
    end
  end
  if(dest_type == VRF && (dest_idx_base % int'($ceil(dest_emul)) != 0)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: dest_idx(v%0d) is unaligned to dest_emul(%0d).", pc, dest_idx_base, int'($ceil(dest_emul))));
    return FAIL;
  end
  if(src3_type == VRF && (src3_idx_base % int'($ceil(src3_emul)) != 0)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src3_idx(v%0d) is unaligned to src3_emul(%0d).", pc, src3_idx_base, int'($ceil(src3_emul))));
    return FAIL;
  end
  if(src2_type == VRF && (src2_idx_base % int'($ceil(src2_emul)) != 0)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src2_idx(v%0d) is unaligned to src2_emul(%0d).", pc, src2_idx_base, int'($ceil(src2_emul))));
    return FAIL;
  end
  if(src1_type == VRF && (src1_idx_base % int'($ceil(src1_emul)) != 0)) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: src1_idx(v%0d) is unaligned to src1_emul(%0d).", pc, src1_idx, int'($ceil(src1_emul))));
    return FAIL;
  end

// overlap check -------------------------------------------
  // Common check
  // vd overlap v0.t
  if(dest_type == VRF && vm == 0 && dest_idx_base == 0 && dest_eew != EEW1) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: THe dest vrf(v%0d) overlaps source mask register v0.", pc, dest_idx_base));
    return FAIL;
  end
  // vd overlap vs2
  if(dest_type == VRF && src2_type == VRF && (dest_eew > src2_eew) && (dest_emul > 1 || src2_emul > 1) &&
     (src2_idx_base >= dest_idx_base) && (src2_idx_last < dest_idx_last)
  ) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: Ch31.5.2. The lowest part of dest vrf(v%0d~v%0d) overlaps the src2 vrf(v%0d~v%0d) in a widen instruction.", 
                 pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last));
    return FAIL;
  end
  if(dest_type == VRF && src2_type == VRF && (dest_eew < src2_eew) && (dest_emul > 1 || src2_emul > 1) &&
     (dest_idx_base > src2_idx_base) && (dest_idx_last <= src2_idx_last)
  ) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: Ch31.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src2 vrf(v%0d~v%0d) in a widen instruction.", 
                 pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last));
    return FAIL;
  end
  // vd overlap vs1
  if(dest_type == VRF && src1_type == VRF && (dest_eew > src1_eew) && (dest_emul > 1 || src1_emul > 1) &&
     (src1_idx_base >= dest_idx_base) && (src1_idx_last < dest_idx_last)
  ) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: Ch31.5.2. The lowest part of dest vrf(v%0d~v%0d) overlaps the src1 vrf(v%0d~v%0d) in a widen instruction.", 
                 pc, dest_idx_base, dest_idx_last, src1_idx_base, src1_idx_last));
    return FAIL;
  end
  if(dest_type == VRF && src1_type == VRF && (dest_eew < src1_eew) && (dest_emul > 1 || src1_emul > 1) &&
     (dest_idx_base > src1_idx_base) && (dest_idx_last <= src1_idx_last)
  ) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: Ch31.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src1 vrf(v%0d~v%0d) in a widen instruction.", 
                 pc, dest_idx_base, dest_idx_last, src1_idx_base, src1_idx_last));
    return FAIL;
  end
  // Special check
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx_base inside {VMSBF, VMSOF, VMSIF, VIOTA} && dest_idx_base == 0 && vm == 0) begin
    `uvm_warning("TR/INST_CHECK", $sformatf("pc=0x%8x: In vmsf/vmsof/vmsif/viota, dest vrf(v%0d) can't overlap v0 while vm == 0.", pc, dest_idx_base))
    return FAIL;
  end
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx_base inside {VMSBF, VMSOF, VMSIF} && dest_idx_base == src2_idx_base) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: In vmsf/vmsof/vmsif, dest vrf(v%0d~v%0d) can't overlap src2 vrf(v%0d~v%0d).", 
                 pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last));
    return FAIL;
  end
  if(inst_type == ALU && alu_inst == VMUNARY0 && src1_idx_base inside {VIOTA} && src2_idx_base inside {[dest_idx_base:dest_idx_last]}) begin
    `uvm_warning("TR/INST_CHECK", 
                 $sformatf("pc=0x%8x: In viota, dest vrf(v%0d~v%0d) can't overlap src2 vrf(v%0d~v%0d).", 
                 pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last));
    return FAIL;
  end
  // For indexed segment load, vd can't overlap vs2
  // When nf>1, vd cannot overlap any part of vs2.
  // When nf=1, overlap rule follows with normal check(Ch 31.5.1).
  if(inst_type inside {LD} && lsu_mop inside {LSU_UI, LSU_OI} && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8}) begin
    if(dest_type == VRF && src2_type == VRF && 
      ((src2_idx_base inside {[dest_idx_base:dest_idx_last]}) || 
       (dest_idx_base inside {[src2_idx_base:src2_idx_last]}))
    ) begin
      `uvm_warning("TR/INST_CHECK", 
                   $sformatf("pc=0x%8x: The dest vrf(v%0d~v%0d) overlaps src2 vrf(v%0d~v%0d) in indexed load/store.",
                   pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last));
      return FAIL;
    end
    if(dest_type == VRF && src1_type == VRF && 
      ((src1_idx_base inside {[dest_idx_base:dest_idx_last]}) || 
       (dest_idx_base inside {[src1_idx_base:src1_idx_last]}))
    ) begin
      `uvm_warning("TR/INST_CHECK", 
                   $sformatf("pc=0x%8x: The dest vrf(v%0d~v%0d) overlaps src1 vrf(v%0d~v%0d) in indexed load/store.",
                   pc, dest_idx_base, dest_idx_last, src1_idx_base, src1_idx_last));
      return FAIL;
    end
  end
  // For vcompress/vrgather/vslideup, vd cannot overlap vector source reg-group 
  if(inst_type == ALU && alu_inst inside {VCOMPRESS,VSLIDEUP_RGATHEREI16,VRGATHER,VSLIDE1UP}) begin
    if(dest_type == VRF && src2_type == VRF && 
      ((src2_idx_base inside {[dest_idx_base:dest_idx_last]}) || 
       (dest_idx_base inside {[src2_idx_base:src2_idx_last]}))
    ) begin 
      `uvm_warning("TR/INST_CHECK", 
                   $sformatf("pc=0x%8x: The dest vrf(v%0d~v%0d) overlaps src2 vrf(v%0d~v%0d) in %s.",
                   pc, dest_idx_base, dest_idx_last, src2_idx_base, src2_idx_last, alu_inst.name()));
      return FAIL;
    end
    if(dest_type == VRF && src1_type == VRF && 
      ((src1_idx_base inside {[dest_idx_base:dest_idx_last]}) || 
       (dest_idx_base inside {[src1_idx_base:src1_idx_last]}))
    ) begin 
      `uvm_warning("TR/INST_CHECK", 
                   $sformatf("pc=0x%8x: The dest vrf(v%0d~v%0d) overlaps src1 vrf(v%0d~v%0d) in %s.",
                   pc, dest_idx_base, dest_idx_last, src1_idx_base, src1_idx_last, alu_inst.name()));
      return FAIL;
    end
  end

  `uvm_info("TR/ISNT_CHECK", $sformatf("Check pass:\n%s", this.sprint()), UVM_HIGH)
  return PASS;
endfunction: reserve_inst_check

function void rvs_transaction::asm_string_gen();
  string inst = "nop";
  string suff = "";
  string suf0 = "";
  string src0 = "";
  string suf1 = "";
  string src1 = "";
  string suf2 = "";
  string src2 = "";
  string suf3 = "";
  string src3 = "";
  string dest = "";
  string sufd = "";
  string operands = "";
  string comm = "# an example";
  // Inst name
  case(inst_type)
    LD, ST: begin
      inst = this.lsu_inst.name();
      case(lsu_mop)
        LSU_US   : begin
          case(lsu_umop)
            MASK: begin
              inst = this.lsu_inst.name();
            end
            WHOLE_REG: begin
              if(inst_type == LD) begin
                inst = $sformatf("vl%0dre%0d", lsu_nf+1, lsu_eew);
              end
              if(inst_type == ST) begin
                inst = $sformatf("vs%0dre%0d", lsu_nf+1, lsu_eew);
              end
            end
            default: begin
              if(this.lsu_nf == NF1) begin
                inst = $sformatf("%se%0d", inst, lsu_eew);
              end else begin
                inst = $sformatf("%sseg%0de%0d", inst, lsu_nf+1, lsu_eew);
              end
            end
          endcase
        end
        LSU_CS  : begin
          if(this.lsu_nf == NF1) begin
            inst = $sformatf("%se%0d", inst, lsu_eew);
          end else begin
            inst = $sformatf("%sseg%0de%0d", inst, lsu_nf+1, lsu_eew);
          end
        end
        LSU_UI, 
        LSU_OI: begin
          if(this.lsu_nf == NF1) begin
            inst = $sformatf("%sei%0d", inst, lsu_eew);
          end else begin
            inst = $sformatf("%sseg%0dei%0d", inst, lsu_nf+1, lsu_eew);
          end
        end      
      endcase
    end 
    ALU: begin 
      if(alu_inst inside {VWADDU_W, VWADD_W, VWSUBU_W, VWSUB_W}) begin
        inst = this.alu_inst.name();
        inst = inst.substr(0,inst.len()-3);
      end else if(alu_inst inside {VXUNARY0}) begin
        if(src1_idx inside {VZEXT_VF4, VZEXT_VF2}) inst = "vzext";
        if(src1_idx inside {VSEXT_VF4, VSEXT_VF2}) inst = "vsext";
      end else if(alu_inst inside {VMERGE_VMVV}) begin
        if(vm == 1)
          inst = "vmv.v";
        else
          inst = "vmerge";
      end else if(alu_inst inside {VWXUNARY0}) begin
        if(src1_type == FUNC) begin
          if(src1_idx == VMV_X_S)
            inst = "vmv.x";
          else
            inst = src1_func_vwxunary0.name();
        end
        if(src2_type == FUNC) begin
          if(src2_idx == VMV_S_X)
            inst = "vmv.s";
          else
            inst = src2_func_vwxunary0.name();
        end
      end else if(alu_inst inside {VMUNARY0}) begin
        inst = src1_func_vmunary0.name();
      end else if(alu_inst inside {VSMUL_VMVNRR}) begin
        if(alu_type inside {OPIVI}) begin
          if(src1_idx inside{0,1,3,7})
            inst = $sformatf("vmv%0dr.v",src1_idx+1);
          else
            inst = "vmv?r.v";
        end else if(alu_type inside {OPIVV, OPIVX}) begin
          inst = "vsmul";
        end
      end else if(alu_inst inside {VSLIDEUP_RGATHEREI16}) begin
        if(alu_type inside {OPIVX,OPIVI})
          inst = "vslideup";
        else if(alu_type inside {OPIVV})
          inst = "vrgatheri16";
        else
          inst = "?";
      end else begin
        inst = this.alu_inst.name();
      end
    end
  endcase
  inst = inst.tolower();

  // src1
  case(inst_type)
    LD, ST: begin
      suf1 = ""; src1 = $sformatf("(x%0d)",this.src1_idx); 
    end
    ALU: begin
      case(this.src1_type)
        VRF: begin 
          if(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
            suf1 = "m"; src1 = $sformatf("v%0d",this.src1_idx); 
          end else begin
            suf1 = "v"; src1 = $sformatf("v%0d",this.src1_idx); 
          end
        end
        SCALAR: begin suf1 = "s"; src1 = $sformatf("v%0d",this.src1_idx); end
        XRF: begin suf1 = "x"; src1 = $sformatf("x%0d",this.src1_idx); end
        IMM: begin suf1 = "i"; src1 = $sformatf("%0d",$signed(this.src1_idx)); end
        UIMM: begin suf1 = "i"; src1 = $sformatf("%0d",$unsigned(this.src1_idx)); end
        FUNC: begin
          if(inst_type == ALU && alu_inst == VXUNARY0 && src1_idx inside{VSEXT_VF4, VZEXT_VF4}) begin
            suf1 = "f4"; src1 = "";
          end else if(inst_type == ALU && alu_inst == VXUNARY0 && src1_idx inside{VSEXT_VF2, VZEXT_VF2}) begin
            suf1 = "f2"; src1 = "";
          end
        end
        UNUSE: begin
        end
        default: begin suf1 = "?"; src1 = "?"; end
      endcase
    end
  endcase

  // src2
  case(inst_type)
    LD, ST: begin
      case(this.src2_type)
        VRF: begin suf2 = ""; src2 = $sformatf("v%0d",this.src2_idx); end
        XRF: begin suf2 = ""; src2 = $sformatf("x%0d",this.src2_idx); end
        FUNC: begin suf2 = ""; src2 = ""; end
        UNUSE: begin suf2 = ""; src2 = ""; end 
        default: begin suf2 = "?"; src2 = "?"; end
      endcase
    end
    ALU: begin
      case(this.src2_type)
        VRF: begin 
          if(inst_type == ALU && alu_inst inside {VWADDU_W, VWADD_W, VWSUBU_W, VWSUB_W}) begin
            suf2 = "w"; src2 = $sformatf("v%0d",this.src2_idx); 
          end else if(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
                                                           VMUNARY0}) begin
            suf2 = "m"; src2 = $sformatf("v%0d",this.src2_idx); 
          end else if(inst_type == ALU && alu_inst inside {VWXUNARY0}) begin
            if(src1_type == FUNC && src1_idx inside {VCPOP, VFIRST}) begin
              suf2 = "m"; src2 = $sformatf("v%0d",this.src2_idx); 
            end else if(src1_type == FUNC && src1_idx inside {VMV_X_S}) begin // vmv.x.s
              suf2 = "s"; src2 = $sformatf("v%0d",this.src2_idx); 
            end else begin
              suf2 = "v"; src2 = $sformatf("v%0d",this.src2_idx); 
            end
          end else begin
            suf2 = "v"; src2 = $sformatf("v%0d",this.src2_idx); 
          end
        end
        SCALAR: begin suf2 = "s"; src2 = $sformatf("v%0d",this.src2_idx); end
        XRF: begin suf2 = "x"; src2 = $sformatf("x%0d",this.src2_idx); end
        IMM: begin suf2 = "i"; src2 = $sformatf("%0d",$signed(this.src2_idx)); end
        UNUSE: begin 
            if(this.src1_idx ==  VID) begin suf2 = ""; src2 = ""; end 
        end
        FUNC: begin
          suf2 = ""; src2 = "";
        end
        default: begin suf2 = "?"; src2 = "?"; end
      endcase
    end
  endcase

  // vm
  if(vm == 0) begin
    if(inst_type == ALU && use_vm_to_cal == 1) begin
      suf0 = "m"; src0 = "v0";
    end else begin
      suf0 = "";  src0 = "v0.t";
    end
  end else begin
    suf0 = "";  src0 = "";
  end

  // dest/src3
  case(inst_type)
    LD: begin
      sufd = "v";
      case(this.dest_type)
        VRF: dest = $sformatf("v%0d",this.dest_idx);
        XRF: dest = $sformatf("x%0d",this.dest_idx);
        SCALAR: dest = $sformatf("v%0d",this.dest_idx);
        default: dest = "?";
      endcase
      suf3 = "";
      src3 = "";
    end
    ST: begin
      sufd = "";
      dest = "";
      suf3 = "v";
      case(this.src3_type)
        VRF: src3 = $sformatf("v%0d",this.src3_idx);
        XRF: src3 = $sformatf("x%0d",this.src3_idx);
        SCALAR: src3 = $sformatf("v%0d",this.src3_idx);
        default: src3 = "?";
      endcase
    end
    ALU: begin
      sufd = "";
      case(this.dest_type)
        VRF: dest = $sformatf("v%0d",this.dest_idx);
        XRF: dest = $sformatf("x%0d",this.dest_idx);
        SCALAR: dest = $sformatf("v%0d",this.dest_idx);
        default: dest = "?";
      endcase
      suf3 = "";
      src3 = "";
    end
  endcase

  suff = $sformatf("%s%s%s%s%s",sufd,suf3,suf2,suf1,suf0);

  // Comments
  comm = $sformatf("# vlmul=%0s, vsew=%0s, vstart=%0d, vl=%0d", vlmul.name(), vsew.name(), vstart, vl);
  if(inst_type inside {LD, ST} && src1_type == XRF) comm = $sformatf("%s, base=0x%8x", comm, rs1_data);
  if(inst_type inside {LD, ST} && lsu_mop == LSU_CS && src2_type == XRF) comm = $sformatf("%s, const_stride=%0d", comm, $signed(rs2_data));

  // asm string
  if(inst_type == ST) dest = src3;
  if(this.vm) 
    if(src1_type == FUNC) 
      this.asm_string = $sformatf("%s.%s %s, %s %s",inst, suff, dest, src2,  comm);
    else
      this.asm_string = $sformatf("%s.%s %s, %s, %s %s",inst, suff, dest, src2, src1, comm);
  else
    if(src1_type == FUNC) 
      this.asm_string = $sformatf("%s.%s %s, %s, %s %s",inst, suff, dest, src2, src0, comm);
    else
      this.asm_string = $sformatf("%s.%s %s, %s, %s, %s %s",inst, suff, dest, src2, src1, src0, comm);
endfunction: asm_string_gen
`endif // RVS_TRANSACTION__SV
