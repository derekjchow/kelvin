`ifndef RVS_TRANSACTION__SV
`define RVS_TRANSACTION__SV


class rvs_transaction extends uvm_sequence_item;

  /* Illegal control field*/
  static int unsigned illegal_rate = 0;
  static int unsigned legal_rate   = 100;
  rand bit illegal_inst_en;


  /* Memory config */
  static int unsigned mem_addr_lo = 32'h0000_0000;
  static int unsigned mem_addr_hi = 32'h0001_0000;

  /* Tr config field */
  rand bit use_vlmax;
       bit is_rt = 0;
       bit is_last_inst = 0;

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
  rand inst_type_e inst_type;// opcode
       int uop_idx;
       bit first_uop;
       bit last_uop;

  // Load/Store inst
  rand lsu_inst_e   lsu_inst;
  rand lsu_mop_e    lsu_mop;  // func6[28:26]
  rand lsu_umop_e   lsu_umop; // src2_idx
  rand lsu_nf_e     lsu_nf;   // func6[31:29]
  rand lsu_width_e  lsu_width;// func3
  rand eew_e        lsu_eew;  // func3
  rand lmul_e       lsu_emul;

  // Algoritm inst
  rand alu_type_e alu_type;  // func3
  rand alu_inst_e alu_inst;  // func6

  rand logic vm; // Mask bit. 0 - Use v0.t
       logic use_vm_to_cal;

  // Generate oprand
  rand oprand_type_e dest_type;
  rand oprand_type_e src1_type;
  rand oprand_type_e src2_type;
  rand oprand_type_e src3_type;
  rand logic [4:0] dest_idx;
  rand logic [4:0] src1_idx;
  rand logic [4:0] src2_idx;
  rand logic [4:0] src3_idx;
       int    dest_eew;
       int    src1_eew;
       int    src2_eew;
       int    src3_eew;
       real   dest_emul;
       real   src1_emul;
       real   src2_emul;
       real   src3_emul;
       vext_e src1_func_vext;
       vwxunary0_e src2_func_vwxunary0;
       vwxunary0_e src1_func_vwxunary0;
       vmunary0_e  src1_func_vmunary0;
   
  rand logic [`XLEN-1:0] rs2_data;
  rand logic [`XLEN-1:0] rs1_data;

  /* Real instruction */
  rand logic [31:0] pc;
       logic [31:0] bin_inst; 
       string asm_string;

  /* Write back info */
       reg_idx_t  rt_vrf_index  [$];
       vrf_byte_t rt_vrf_strobe [$];
       vrf_t      rt_vrf_data   [$];

       reg_idx_t  rt_xrf_index [$];
       xrf_t      rt_xrf_data  [$];

       logic [`XLEN-1:0] vxsat;  
       logic             vxsat_valid;  

  /* Trap field */
  // TODO
// Constrain ----------------------------------------------------------

  constraint c_solve_order {
    solve inst_type before src3_type;
    solve inst_type before alu_inst;
    solve lsu_inst before inst_type;

    // ALU insts solve order will be:
    //   inst_type -> alu_inst -> op_type/alu_type -> op_idx/vm 
    //   -> vtypes -> vl -> vstart
    // vl should be: 
    //   vlmax -> vl -> evl  
    
    solve alu_inst before alu_type;
    solve alu_inst before dest_type;
    solve alu_inst before src2_type;
    solve alu_inst before src1_type;    

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
    //   inst_type -> lsu_inst -> lsu_mop -> lsu_nf -> lsu_width -> op_idx/vm/lsu_umop 
    //   -> vtypes -> vl -> vstart
    // vl should be: 
    //   vlmax -> vl -> evl  
    // vtype should be:
    //   vsew -> vlmul
    
    solve lsu_inst  before lsu_mop;
    solve lsu_mop   before dest_type;
    solve lsu_mop   before src3_type;
    solve lsu_mop   before src2_type;
    solve lsu_mop   before src1_type; 
    solve lsu_nf    before dest_type;
    solve lsu_nf    before src3_type;
    solve lsu_nf    before src2_type;
    solve lsu_nf    before src1_type;    
    solve lsu_width before dest_type;
    solve lsu_width before src3_type;
    solve lsu_width before src2_type;
    solve lsu_width before src1_type;    

    solve dest_type before dest_idx;
    solve src3_type before src3_idx;
    solve src2_type before src2_idx;
    solve src1_type before src1_idx;

    solve dest_type before vm;
    solve src3_type before vm;
    solve src2_type before vm;
    solve src1_type before vm;

    solve dest_idx before vsew;
    solve src3_idx before vsew;
    solve src2_idx before vsew;
    solve src1_idx before vsew;
    solve dest_idx before vlmul;
    solve src3_idx before vlmul;
    solve src2_idx before vlmul;
    solve src1_idx before vlmul;

    solve lsu_nf before vsew;
    solve vsew   before vlmul;
    solve vsew   before vlmax;
    solve vlmul  before vlmax;
    solve vlmax  before vl;
    solve vl     before evl;
    solve evl    before vstart;

    solve src2_idx before rs2_data;
    solve src1_idx before rs1_data;
  }

  constraint c_ill_rate {
    illegal_inst_en dist {
      1 := illegal_rate,
      0 := legal_rate    
    }; 
  }

  constraint c_normal_set {
    vill == 0;
  }

  constraint c_vl {
    if(vlmul[2]) // fraction_lmul
      vlmax == ((`VLENB >> (~vlmul +3'b1)) >> vsew);
    else  
      vlmax == ((`VLENB << vlmul) >> vsew);

    vl <= vlmax_max;
    vstart <= vlmax_max-1;

    if(!illegal_inst_en) {
      // vl
      if(!(inst_type == ALU && alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR})) {
        vl <= vlmax;
      }

      // evl
      if(inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) {
        evl == ((src1_idx + 1) * `VLENB) >> vsew;
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_E && src2_type == FUNC && src2_idx == MASK) {
        if(vl%8 > 0) evl == int'(vl/8) + 1;
        else         evl == int'(vl/8);
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_E && src2_type == FUNC && src2_idx == WHOLE_REG) {
        evl == (lsu_nf+1) * `VLEN / lsu_eew;
      } else {
        evl == vl;
      }

      // vstart
      if(inst_type == ALU && alu_inst == VSMUL_VMVNRR && alu_type == OPIVI) {
        vstart < evl;
      } else if(inst_type == ALU && alu_inst inside {VWXUNARY0}) {
        // for vcpop, vfirst, vmv.x.s, vmv.s.x, vstart >= vl is allowed
        vstart dist { 
          [0:vl-1] :/ 99,
          [vl:vlmax_max-1] :/ 1
        };
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_E && src2_type == FUNC && src2_idx == MASK) {
        vstart < evl;
      } else if(inst_type inside {LD, ST} && lsu_mop == LSU_E && src2_type == FUNC && src2_idx == WHOLE_REG) {
        vstart < evl;
      } else {
        vstart < vl;
      }

      (inst_type == ALU && alu_inst inside {VWXUNARY0} && src1_idx inside {VCPOP, VFIRST}) 
      ->  (vstart == 0);

      (inst_type == ALU && alu_inst inside {VMUNARY0} && src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA}) 
      ->  (vstart == 0);

      (inst_type == ALU && alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU, VREDMIN, VREDMAXU, VREDMAX}) 
      ->  (vstart == 0);

      (inst_type == ALU && alu_inst inside {VWREDSUM, VWREDSUMU}) 
      ->  (vstart == 0);

      (inst_type == ALU && alu_inst inside {VCOMPRESS}) 
      ->  (vstart == 0);
    } else {
    //TODO  
    }
  }

  constraint c_oprand {

    (inst_type == ALU) -> (alu_type inside {OPIVV, OPIVX, OPIVI, OPMVV, OPMVX});
    // FIXME
    (inst_type inside {LD,ST}) -> (alu_type inside {OPIVV, OPIVX, OPIVI, OPMVV, OPMVX});
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

    (src2_type == XRF && src1_type == XRF) -> (src2_idx != src1_idx);

    if(!illegal_inst_en) {
      // OPI
      if(inst_type == ALU && alu_inst[7:6] == 2'b00) {
        (!(alu_inst inside {VSUB, VRSUB,
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
                            })) 
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM)
            );

        (alu_inst inside {VSUB, 
                          VMSBC, 
                          VMINU, VMIN, VMAXU, VMAX,
                          VMSLTU, VMSLT,
                          VSSUBU, VSSUB
                          })
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) 
            );

        (alu_inst inside {VADC})
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) ||
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0) 
            );

        (alu_inst inside {VSBC})
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0)
            );

        (alu_inst inside {VRSUB,
                          VMSGTU, VMSGT}) 
        ->  ((alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM) 
            );

        (alu_inst inside {VMERGE_VMVV}) 
        ->  (// vmerge
             (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 0) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF && vm == 0) || 
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM && vm == 0) ||
             //vmv
             (alu_type == OPIVV && dest_type == VRF && src2_type == UNUSE && src1_type == VRF && vm == 1 && src2_idx == 0) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == UNUSE && src1_type == XRF && vm == 1 && src2_idx == 0) || 
             (alu_type == OPIVI && dest_type == VRF && src2_type == UNUSE && src1_type == IMM && vm == 1 && src2_idx == 0) 
            );

        (alu_inst inside {VSLL, VSRL, VSRA, VNSRL, VNSRA,
                          VSSRL, VSSRA, VNCLIPU, VNCLIP}) 
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) || 
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM)
            );

        (alu_inst inside {VWREDSUMU, VWREDSUM}) 
        ->  ((alu_type == OPIVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR)
            );

        (alu_inst inside {VSLIDEDOWN}) 
        ->  ((alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == IMM) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF)
            );

        (alu_inst inside {VRGATHER}) 
        ->  ((alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == UIMM) || 
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||
             (alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF)
            );

        (alu_inst inside {VSMUL_VMVNRR})
        ->  ((alu_type == OPIVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) ||         // vsmul
             (alu_type == OPIVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) ||         // vsmul
             (alu_type == OPIVI && dest_type == VRF && src2_type == VRF && src1_type == FUNC && vm == 1 && src1_idx inside {0,1,3,7}) // vmv<nr>r
            );
      }

      // OPM
      if(inst_type == ALU && alu_inst[7:6] == 2'b01) {
        (!(alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
                            VXUNARY0, VMUNARY0, VWXUNARY0, 
                            VWMACCUS,
                            VREDSUM, VREDAND, VREDOR, VREDXOR, 
                            VREDMINU,VREDMIN,VREDMAXU,VREDMAX,
                            VSLIDE1UP, VSLIDE1DOWN,
                            VCOMPRESS})) 
        ->  ((alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF) || 
             (alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) 
            );

        (alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) 
        ->  ((alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) 
            );

        (alu_inst == VXUNARY0) 
        ->  ((alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2})
            );

        (alu_inst == VMUNARY0) 
        ->  ((alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VIOTA}) || 
             (alu_type == OPMVV && dest_type == VRF && src2_type == UNUSE && src1_type == FUNC && src2_idx == 0 && src1_idx inside {VID}) ||
             (alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == FUNC && src1_idx inside {VMSBF, VMSOF, VMSIF})
            );

        (alu_inst == VWXUNARY0)
        ->  ((alu_type == OPMVV && dest_type == XRF && src2_type == VRF && src1_type == FUNC && src1_idx inside { VCPOP, VFIRST}) ||
             (alu_type == OPMVV && dest_type == XRF && src2_type == VRF && src1_type == FUNC && vm ==1 && src1_idx inside {VMV_X_S}) ||  // vmv.x.s
             (alu_type == OPMVX && dest_type == VRF && src2_type == FUNC && src1_type == XRF && vm ==1 && src2_idx inside{VMV_X_S}) // vmv.s.x
            );

        (alu_inst inside {VWMACCUS}) 
        ->  ((alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) 
            );
        
        (alu_inst inside {VREDSUM, VREDAND, VREDOR, VREDXOR,
                          VREDMINU,VREDMIN,VREDMAXU,VREDMAX}) 
        ->  ((alu_type == OPMVV && dest_type == SCALAR && src2_type == VRF && src1_type == SCALAR)
            );

        (alu_inst inside {VSLIDE1UP, VSLIDE1DOWN}) 
        ->  ((alu_type == OPMVX && dest_type == VRF && src2_type == VRF && src1_type == XRF) 
            );
        
        (alu_inst inside {VCOMPRESS}) 
        ->  ((alu_type == OPMVV && dest_type == VRF && src2_type == VRF && src1_type == VRF && vm == 1) 
            );
      }

      // LSU
      // LD
      (lsu_inst == VLE)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLSEG)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VLM)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1);
      (lsu_inst == VLR)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf inside {NF1, NF2, NF4, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1);
      (lsu_inst == VLEFF)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf == NF1 && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);
      (lsu_inst == VLSEGFF)
      ->  (inst_type == LD && lsu_mop == LSU_E && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == FUNC && src2_idx == FOF && src1_type == XRF);

      (lsu_inst == VLSE)
      ->  (inst_type == LD && lsu_mop == LSU_SE && lsu_nf == NF1 && dest_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VLSSEG)
      ->  (inst_type == LD && lsu_mop == LSU_SE && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VLUXEI)
      ->  (inst_type == LD && lsu_mop == LSU_UXEI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLUXSEG)
      ->  (inst_type == LD && lsu_mop == LSU_UXEI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VLOXEI)
      ->  (inst_type == LD && lsu_mop == LSU_OXEI && lsu_nf == NF1 && dest_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VLOXSEG)
      ->  (inst_type == LD && lsu_mop == LSU_OXEI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && dest_type == VRF && src2_type == VRF && src1_type == XRF);


      // ST
      (lsu_inst == VSE)
      ->  (inst_type == ST && lsu_mop == LSU_E && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSSEG)
      ->  (inst_type == ST && lsu_mop == LSU_E && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == NORMAL && src1_type == XRF);
      (lsu_inst == VSM)
      ->  (inst_type == ST && lsu_mop == LSU_E && lsu_nf == NF1 && src3_type == VRF && src2_type == FUNC && src2_idx == MASK && src1_type == XRF && vm == 1);
      (lsu_inst == VSR)
      ->  (inst_type == ST && lsu_mop == LSU_E && lsu_nf inside {NF1, NF2, NF4, NF8} && src3_type == VRF && src2_type == FUNC && src2_idx == WHOLE_REG && src1_type == XRF && vm == 1);

      (lsu_inst == VSSE)
      ->  (inst_type == ST && lsu_mop == LSU_SE && lsu_nf == NF1 && src3_type == VRF && src2_type == XRF && src1_type == XRF);
      (lsu_inst == VSSSEG)
      ->  (inst_type == ST && lsu_mop == LSU_SE && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == XRF && src1_type == XRF);

      (lsu_inst == VSUXEI)
      ->  (inst_type == ST && lsu_mop == LSU_UXEI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSUXSEG)
      ->  (inst_type == ST && lsu_mop == LSU_UXEI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

      (lsu_inst == VSOXEI)
      ->  (inst_type == ST && lsu_mop == LSU_OXEI && lsu_nf == NF1 && src3_type == VRF && src2_type == VRF && src1_type == XRF);
      (lsu_inst == VSOXSEG)
      ->  (inst_type == ST && lsu_mop == LSU_OXEI && lsu_nf inside {NF2, NF3, NF4, NF5, NF6, NF7, NF8} && src3_type == VRF && src2_type == VRF && src1_type == XRF);

    } else {
      // TODO
      // OPI
      if(inst_type == ALU && alu_inst[7:6] == 2'b00) {
        (src3_type == VRF && src2_type == VRF && 
              ((alu_type == OPIVV && src1_type == VRF) || 
               (alu_type == OPIVX && src1_type == XRF) || 
               (alu_type == OPIVI && src1_type == IMM)
              )
            );
      }

      // OPM
      if(inst_type == ALU && alu_inst[7:6] == 2'b01) {
        (src3_type == VRF && src2_type == VRF && 
              ((alu_type == OPMVV && src1_type == VRF) || 
               (alu_type == OPMVX && src1_type == XRF) 
              )
            );
      }
      
    }// if(!illegal_inst_en)

  }

  constraint c_sewlmul {
    lsu_width inside {LSU_8BIT, LSU_16BIT, LSU_32BIT};  
    vsew inside {SEW8, SEW16, SEW32};
    vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
    
    (lsu_width == LSU_8BIT)  <-> (lsu_eew == EEW8);
    (lsu_width == LSU_16BIT) <-> (lsu_eew == EEW16);
    (lsu_width == LSU_32BIT) <-> (lsu_eew == EEW32);
    (lsu_width == LSU_64BIT) <-> (lsu_eew == EEW64);

    if(!illegal_inst_en) {
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

        // vrgather
        (alu_inst == VSLIDEUP_RGATHEREI16 && alu_type inside {OPIVV})
        ->  ((vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8} && vsew inside {SEW16,SEW32}) ||
            (vlmul inside {LMUL1_4,LMUL1_2,LMUL1,LMUL2,LMUL4} && vsew inside {SEW8,SEW16})
        );
        
      }
      
      if(inst_type inside {LD, ST}) {
        // lsu_eew:sew = 1:1
        if(lsu_width == LSU_8BIT  && vsew == SEW8  ||
           lsu_width == LSU_16BIT && vsew == SEW16 || 
           lsu_width == LSU_32BIT && vsew == SEW32) {
          (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
          //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
          (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
          (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
          (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
        }
        // lsu_eew:sew = 1:2
        if(lsu_width == LSU_8BIT  && vsew == SEW16 ||
           lsu_width == LSU_16BIT && vsew == SEW32) {
          (vlmul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8});
          //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
          (lsu_nf == NF1) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8});
          (lsu_nf == NF2) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2, LMUL4       });
          (lsu_nf == NF3) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF4) -> (vlmul inside {         LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF5) -> (vlmul inside {         LMUL1_2, LMUL1                     });
          (lsu_nf == NF6) -> (vlmul inside {         LMUL1_2, LMUL1                     });
          (lsu_nf == NF7) -> (vlmul inside {         LMUL1_2, LMUL1                     });
          (lsu_nf == NF8) -> (vlmul inside {         LMUL1_2, LMUL1                     });
        }
        // lsu_eew:sew = 1:4
        if(lsu_width ==  LSU_8BIT && vsew == SEW32) { 
          (vlmul inside {LMUL1,   LMUL2,   LMUL4, LMUL8});
          //emul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
          (lsu_nf == NF1) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4, LMUL8});
          (lsu_nf == NF2) -> (vlmul inside {                  LMUL1, LMUL2, LMUL4       });
          (lsu_nf == NF3) -> (vlmul inside {                  LMUL1, LMUL2              });
          (lsu_nf == NF4) -> (vlmul inside {                  LMUL1, LMUL2              });
          (lsu_nf == NF5) -> (vlmul inside {                  LMUL1                     });
          (lsu_nf == NF6) -> (vlmul inside {                  LMUL1                     });
          (lsu_nf == NF7) -> (vlmul inside {                  LMUL1                     });
          (lsu_nf == NF8) -> (vlmul inside {                  LMUL1                     });
        }

        // lsu_eew:sew = 2:1
        if(lsu_width == LSU_16BIT && vsew == SEW8 || 
           lsu_width == LSU_32BIT && vsew == SEW16) {
          (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4});
          //emul inside {LMUL1_2, LMUL1,   LMUL2, LMUL4, LMUL8};
          (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4       });
          (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF5) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
          (lsu_nf == NF6) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
          (lsu_nf == NF7) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
          (lsu_nf == NF8) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
        }

        // lsu_eew:sew = 4:1
        if(lsu_width == LSU_32BIT && vsew == SEW8 ) { 
          (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2});
          //emul inside {LMUL1,   LMUL2,   LMUL4, LMUL8};
          (lsu_nf == NF1) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2              });
          (lsu_nf == NF2) -> (vlmul inside {LMUL1_4, LMUL1_2, LMUL1                     });
          (lsu_nf == NF3) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
          (lsu_nf == NF4) -> (vlmul inside {LMUL1_4, LMUL1_2                            });
          (lsu_nf == NF5) -> (vlmul inside {LMUL1_4                                     });
          (lsu_nf == NF6) -> (vlmul inside {LMUL1_4                                     });
          (lsu_nf == NF7) -> (vlmul inside {LMUL1_4                                     });
          (lsu_nf == NF8) -> (vlmul inside {LMUL1_4                                     });
        }

        // For special inst
        // vlm/vsm
        (lsu_mop == LSU_E && src2_type == FUNC && src2_idx == MASK)
        -> (lsu_width == LSU_8BIT);
        // vsr
        (inst_type == ST && lsu_mop == LSU_E && src2_type == FUNC && src2_idx == WHOLE_REG)
        -> (lsu_width == LSU_8BIT);
      }
    } else {
      // TODO
    }// if(!illegal_inst_en)
  }

  constraint c_rs1_data {
  //slide
      (alu_inst inside {VSLIDEUP_RGATHEREI16, VSLIDEDOWN, VSLIDE1UP, VSLIDE1DOWN} && alu_type inside {OPIVX, OPMVX})
      -> (rs1_data >=0 && rs1_data <= 130);
  }
// Auto Field ---------------------------------------------------------
  `uvm_object_utils_begin(rvs_transaction) 
    `uvm_field_int(pc,UVM_ALL_ON)
    `uvm_field_int(bin_inst,UVM_ALL_ON)
    `uvm_field_int(bin_inst[31:7],UVM_ALL_ON)
    `uvm_field_string(asm_string,UVM_ALL_ON)

    `uvm_field_enum(sew_e,vsew,UVM_ALL_ON)
    `uvm_field_enum(lmul_e,vlmul,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vma,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vta,UVM_ALL_ON)

    `uvm_field_int(vlmax,UVM_ALL_ON)
    `uvm_field_int(use_vlmax,UVM_ALL_ON)
    `uvm_field_int(vl,UVM_ALL_ON)
    `uvm_field_int(vstart,UVM_ALL_ON)
    `uvm_field_enum(vxrm_e,vxrm,UVM_ALL_ON)
    `uvm_field_int(vm,UVM_ALL_ON)
    `uvm_field_int(use_vm_to_cal,UVM_ALL_ON)

    `uvm_field_enum(inst_type_e,inst_type,UVM_ALL_ON)
    if(inst_type == ALU) begin
      `uvm_field_enum(alu_type_e,alu_type,UVM_ALL_ON)
      `uvm_field_enum(alu_inst_e,alu_inst,UVM_ALL_ON)
    end
    if(inst_type == LD || inst_type == ST) begin
      `uvm_field_enum(lsu_mop_e,lsu_mop,UVM_ALL_ON)
      `uvm_field_enum(lsu_umop_e,lsu_umop,UVM_ALL_ON)
      `uvm_field_enum(lsu_nf_e,lsu_nf,UVM_ALL_ON)
      `uvm_field_enum(lsu_width_e,lsu_width,UVM_ALL_ON)
      `uvm_field_enum(eew_e,lsu_eew,UVM_ALL_ON)
    end

    // dest
    `uvm_field_enum(oprand_type_e,dest_type,UVM_ALL_ON)
    `uvm_field_int(dest_idx,UVM_ALL_ON)
    // src1
    if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) begin
      `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vext_e,src1_func_vext,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else if(src1_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
      `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vwxunary0_e,src1_func_vwxunary0,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else if(src1_type == FUNC && inst_type == ALU && alu_inst == VMUNARY0) begin
      `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_enum(vmunary0_e,src1_func_vmunary0,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end else begin
      `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end
    // src2
    if(src2_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) begin
      `uvm_field_enum(oprand_type_e,src2_type,UVM_ALL_ON)
      `uvm_field_enum(vwxunary0_e,src2_func_vwxunary0,UVM_ALL_ON)
      `uvm_field_int(src2_idx,UVM_ALL_ON)
    end else begin
      `uvm_field_enum(oprand_type_e,src2_type,UVM_ALL_ON)
      `uvm_field_int(src2_idx,UVM_ALL_ON)
    end
    // src3
    `uvm_field_enum(oprand_type_e,src3_type,UVM_ALL_ON)
    `uvm_field_int(src3_idx,UVM_ALL_ON)
    if(src2_type == XRF) begin
      `uvm_field_int(rs2_data,UVM_ALL_ON)
    end
    if(src1_type == XRF) begin
      `uvm_field_int(rs1_data,UVM_ALL_ON)
    end
    
    // retire info
    if(is_rt) begin
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
    `uvm_field_int(illegal_inst_en,UVM_ALL_ON)
    `uvm_field_int(is_last_inst,UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "Trans");
  extern static function void set_ill_rate(int unsigned rate);
  extern static function void set_mem_range(int unsigned mem_base, int unsigned mem_size);
  extern function void pre_randomize();
  extern function void post_randomize();
  extern protected function void legal_inst_gen();
  extern protected function void asm_string_gen();

endclass: rvs_transaction

static function void rvs_transaction::set_ill_rate(int unsigned rate);
  if(rate > 100) begin
    illegal_rate = 100;
    legal_rate   = 0;
  end else begin
    illegal_rate = rate;
    legal_rate   = 100 - rate;
  end
endfunction: set_ill_rate

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

  if(inst_type == ALU && (alu_inst inside {VADC, VSBC, VMADC, VMSBC, VMERGE_VMVV}))
    use_vm_to_cal = 1;
  else
    use_vm_to_cal = 0;

  if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) $cast(src1_func_vext,src1_idx);
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) $cast(src1_func_vwxunary0,src1_idx);
  if(src2_type == FUNC && inst_type == ALU && alu_inst == VWXUNARY0) $cast(src2_func_vwxunary0,src2_idx);
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VMUNARY0) $cast(src1_func_vmunary0,src1_idx);
  if(src2_type == FUNC && inst_type inside {LD,ST} && lsu_mop == LSU_E) $cast(lsu_umop,src2_idx);
  


  if(!illegal_inst_en) begin legal_inst_gen(); end
  
  // rs random data
  if(src2_type != XRF) rs2_data = 'x;
  if(src1_type != XRF) rs1_data = 'x;

  // constraint vl
  if(use_vlmax) begin 
    vl = vlmax;
    vstart = 0;
  end 

  // gen bin_inst
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

  asm_string_gen();
endfunction: post_randomize

function void rvs_transaction::legal_inst_gen();      

  int  eew;
  real emul;

  bit is_widen_inst;
  bit is_widen_vs2_inst;
  bit is_narrow_inst;
  bit is_mask_producing_inst;
  bit is_reduction_inst;

  int seg_num;

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

  // Calculate eew/emul
  eew      = 8 << vsew;
  dest_eew = eew;
  src3_eew = eew;
  src2_eew = eew;
  src1_eew = eew;

  emul      = 2.0 ** signed'(vlmul);
  dest_emul = emul;
  src3_emul = emul;
  src2_emul = emul;
  src1_emul = emul;

  case(inst_type)
    LD: begin
      case(lsu_mop) 
        LSU_E   : begin
          case(lsu_umop)
            MASK: begin
              dest_eew  = EEW8;
              dest_emul = EMUL1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = lsu_nf + 1;
            end
            WHOLE_REG: begin
              dest_eew  = lsu_eew;
              dest_emul = lsu_nf + 1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = 1;
            end
            default: begin
              dest_eew  = lsu_eew;
              dest_emul = dest_eew * emul / eew;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = lsu_nf + 1;
            end
          endcase
        end
        LSU_SE  : begin
          dest_eew  = lsu_eew;
          dest_emul = dest_eew * emul / eew;
          src2_eew  = EEW32;
          src2_emul = EMUL1;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          seg_num = lsu_nf + 1;
        end
        LSU_UXEI, 
        LSU_OXEI: begin
          dest_eew  = eew;
          dest_emul = emul;
          src2_eew  = lsu_eew;
          src2_emul = src2_eew * emul / eew;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          seg_num = lsu_nf + 1;
        end      
      endcase
    end
    ST: begin
      case(lsu_mop) 
        LSU_E   : begin
          case(lsu_umop)
            MASK: begin
              src3_eew  = EEW8;
              src3_emul = EMUL1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = lsu_nf + 1;
            end
            WHOLE_REG: begin
              src3_eew  = lsu_eew;
              src3_emul = lsu_nf + 1;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = 1;
            end
            default: begin
              src3_eew  = lsu_eew;
              src3_emul = src3_eew * emul / eew;
              src2_eew  = EEW_NONE;
              src2_emul = EMUL_NONE;
              src1_eew  = EEW32;
              src1_emul = EMUL1;
              seg_num = lsu_nf + 1;
            end
          endcase
        end
        LSU_SE  : begin
          src3_eew  = lsu_eew;
          src3_emul = src3_eew * emul / eew;
          src2_eew  = EEW32;
          src2_emul = EMUL1;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          seg_num = lsu_nf + 1;
        end
        LSU_UXEI, 
        LSU_OXEI: begin
          src3_eew  = eew;
          src3_emul = emul;
          src2_eew  = lsu_eew;
          src2_emul = src2_eew * emul / eew;
          src1_eew  = EEW32;
          src1_emul = EMUL1;
          seg_num = lsu_nf + 1;
        end      
      endcase
    end
    ALU: begin
      // 1.1 Widen
      if(is_widen_inst) begin
        if(!(vsew inside {SEW8,SEW16})) begin
          vsew = SEW8;
        end
        if(vlmul == LMUL8) begin
          vlmul = LMUL1;
        end
        dest_eew  = dest_eew  * 2;
        dest_emul = dest_emul * 2;
      end
      if(is_widen_vs2_inst) begin
        src2_eew  = src2_eew  * 2;
        src2_emul = src2_emul * 2;
      end
      // 1.2 Narrow
      if(is_narrow_inst) begin
        if(!(vsew inside {SEW8,SEW16})) begin
          vsew = SEW8;
        end
        if(vlmul == LMUL8) begin
          vlmul = LMUL1;
        end
        src2_eew  = src2_eew  * 2;
        src2_emul = src2_emul * 2;
      end
      // vxunary0
      if(alu_inst == VXUNARY0) begin
        if(src1_idx inside {VSEXT_VF2, VZEXT_VF2}) begin
          if(!(vsew inside {SEW16,SEW32})) begin
            vsew = SEW16;
          end
          if(!(vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8})) begin
            vlmul = LMUL1_2;
          end
          src2_eew  = src2_eew  / 2;
          src2_emul = src2_emul / 2;
        end
        if(src1_idx inside {VSEXT_VF4, VZEXT_VF4}) begin
          if(!(vsew inside {SEW32})) begin
            vsew = SEW32;
          end
          if(!(vlmul inside {LMUL1,LMUL2,LMUL4,LMUL8})) begin
            vlmul = LMUL1;
          end
          src2_eew  = src2_eew  / 4;
          src2_emul = src2_emul / 4;
        end
      end
      // 1.3 mask producing inst
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
      if(alu_inst inside {VMUNARY0} && src1_idx inside {VIOTA, VID} ||
         alu_inst inside {VWXUNARY0} && alu_type == OPMVV && src1_idx inside {VCPOP, VFIRST}) begin
        src2_eew = EEW1;
        src2_emul = src2_emul * src2_eew / eew;
        src1_eew = EEW1;
        src1_emul = src1_emul * src1_eew / eew;
      end
      // 1.4 Reduction inst
      if(is_reduction_inst) begin
        dest_emul = EMUL1;
        src1_emul = EMUL1;
      end
      if(alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) begin
        if(src1_idx inside {0,1,3,7}) begin
          dest_emul = src1_idx + 1;
          src2_emul = src1_idx + 1;
        end else begin
          dest_emul = EMUL1;
          src2_emul = EMUL1;
        end
     end 
    // 1.5 Permutation Instructions.
     if(alu_inst == VSLIDEUP_RGATHEREI16 && alu_type == OPIVV) begin
        src1_eew = EEW16;
        src1_emul = src1_emul * src1_eew / eew;
        if(src1_emul > EMUL8) begin
        
        end
     end
     if(alu_inst == VCOMPRESS && alu_type == OPMVV) begin
        src1_eew = EEW1;
        src1_emul = EMUL1;
     end

    end // ALU
  endcase
  // 1.4 dest is xrf
  if(dest_type == XRF) begin
    dest_eew = EEW32;
    dest_emul = EMUL1; 
  end
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_eew=%0d, src3_eew=%0d, src2_eew=%0d, src1_eew=%0d", pc, dest_eew, src3_eew, src2_eew, src1_eew), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_emul=%0d, src3_emul=%0d, src2_emul=%0d, src1_emul=%0d", pc, dest_emul, src3_emul, src2_emul, src1_emul), UVM_HIGH)

  // Alignment 
  if(inst_type inside {LD, ST}) begin
    // Over range of segment load/store
    if(dest_type == VRF && (dest_idx + (seg_num) * int'($ceil(dest_emul)) - 1 > 31) ) begin
      dest_idx = 32 - (seg_num) * int'($ceil(dest_emul));
    end
    if(src3_type == VRF && (src3_idx + (seg_num) * int'($ceil(src3_emul)) - 1 > 31) ) begin
      src3_idx = 32 - (seg_num) * int'($ceil(src3_emul));
    end
  end
  if(dest_type == VRF) dest_idx = dest_idx - dest_idx % int'($ceil(dest_emul));
  if(src3_type == VRF) src3_idx = src3_idx - src3_idx % int'($ceil(src3_emul));
  if(src2_type == VRF) src2_idx = src2_idx - src2_idx % int'($ceil(src2_emul));
  if(src1_type == VRF) src1_idx = src1_idx - src1_idx % int'($ceil(src1_emul));

  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)

  // Overlap
  // Special case
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
  // vd overlap v0.t
  if(dest_type == VRF && vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
    dest_idx = int'($ceil(dest_emul));
  end
  // vd overlap vs2
  if(dest_type == VRF && src2_type == VRF && (dest_eew > src2_eew) && 
     (src2_idx >= dest_idx) && (src2_idx+int'($ceil(src2_emul)) < dest_idx+int'($ceil(dest_emul))) && 
     (dest_emul > 1 || src2_emul > 1))  begin
    if(vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
      dest_idx = dest_idx + int'(dest_emul);
    end
    src2_idx = dest_idx + int'(dest_emul);
  end
  if(dest_type == VRF && src2_type == VRF && (dest_eew < src2_eew) && 
     (dest_idx > src2_idx) && (dest_idx+int'($ceil(dest_emul)) <= src2_idx+int'($ceil(src2_emul))) && 
     (dest_emul > 1 || src2_emul > 1)) begin
    if(vm == 0 && src2_idx == 0 && dest_eew != EEW1)
      dest_idx = src2_idx+int'(src2_emul);
    else
      dest_idx = src2_idx;
  end
  // vd overlap vs1
  if(dest_type == VRF && src1_type == VRF && (dest_eew > src1_eew) &&
     (src1_idx >= dest_idx) && (src1_idx+int'($ceil(src1_emul)) < dest_idx+int'($ceil(dest_emul))) && 
     (dest_emul > 1 || src1_emul > 1)) begin
    if(vm == 0 && dest_idx == 0 && dest_eew != EEW1) begin
      dest_idx = dest_idx + int'(dest_emul);
    end
    src1_idx = dest_idx + int'(dest_emul);
  end
  if(dest_type == VRF && src1_type == VRF && (dest_eew < src1_eew) &&
     (dest_idx > src1_idx) && (dest_idx+int'($ceil(dest_emul)) <= src1_idx+int'($ceil(src1_emul))) && 
     (dest_emul > 1 || src1_emul > 1)) begin
    if(vm == 0 && src1_idx == 0 && dest_eew != EEW1)
      dest_idx = src1_idx+int'(src1_emul);
    else
      dest_idx = src1_idx;
  end
  // Special cases
  // For indexed segment load, vd can't overlap vs2
  if(inst_type inside {LD} && lsu_mop inside {LSU_UXEI, LSU_OXEI} && 
     dest_type == VRF && src2_type == VRF && 
     ((src2_idx >= dest_idx) && (src2_idx < dest_idx+(seg_num)*int'($ceil(dest_emul))) || 
      (src2_idx+int'($ceil(src2_emul)-1) >= dest_idx) && (src2_idx+int'($ceil(src2_emul)-1) < dest_idx+(seg_num)*int'($ceil(dest_emul)))) ) begin
    int src2_idx_temp;
      src2_idx_temp = int'(dest_idx) - int'($ceil(src2_emul))-1;
    if(src2_idx_temp>=0) begin
      src2_idx_temp = src2_idx_temp - src2_idx_temp % int'($ceil(src2_emul));
      `uvm_info("TR_GEN", $sformatf("src2_idx_temp=%0d", src2_idx_temp), UVM_HIGH)
      src2_idx = src2_idx_temp;
    end else begin
      src2_idx_temp = int'(dest_idx) + (seg_num)*int'($ceil(dest_emul)); 
      src2_idx_temp = src2_idx_temp + int'($ceil(src2_emul)) - src2_idx_temp % int'($ceil(src2_emul));
      if(src2_idx_temp<32) begin
        `uvm_info("TR_GEN", $sformatf("src2_idx_temp=%0d", src2_idx_temp), UVM_HIGH)
        src2_idx = src2_idx_temp;
      end else begin
        `uvm_fatal("TR_GEN", "Calculating overlap of indexed segment load fatal.")
      end
    end
    `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d, corrected for indexed seg load overlap.", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
  end

  // FIXME: clean code
  // vd Overlap vs1 vs2 for 
  if(dest_type == VRF && src1_type == VRF && src2_type == VRF && inst_type == ALU && 
  alu_inst inside {VCOMPRESS,VSLIDEUP_RGATHEREI16,VRGATHER} && alu_type inside {OPIVV,OPMVV}) begin
      if(((dest_idx >= src1_idx) && (dest_idx < src1_idx+int'($ceil(src1_emul)))) ||
          ((dest_idx >= src2_idx) && (dest_idx < src2_idx+int'($ceil(src2_emul)))) ||
          ((dest_idx < src1_idx) && (dest_idx+int'($ceil(dest_emul)) > src1_idx)) ||
          ((dest_idx < src2_idx) && (dest_idx+int'($ceil(dest_emul)) > src2_idx))
      ) begin
        dest_idx = 24;
        src1_idx = 8;
        src2_idx = 16;
      end
  end
  // vd Overlap vs2 
  if(dest_type == VRF && src2_type == VRF && inst_type == ALU && 
  alu_inst inside {VSLIDEUP_RGATHEREI16,VSLIDE1UP,VRGATHER} && alu_type inside {OPMVX,OPIVX,OPIVI}) begin
    if(((dest_idx >= src2_idx) && (dest_idx < src2_idx+int'($ceil(src2_emul)))) ||
          ((dest_idx < src2_idx) && (dest_idx+int'($ceil(dest_emul)) > src2_idx))
      ) begin
        dest_idx = 24;
        src2_idx = 8;
    end
  end

  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_idx=%0d, src3_idx=%0d, src2_idx=%0d, src1_idx=%0d", pc, dest_idx, src3_idx, src2_idx, src1_idx), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_eew=%0d, src3_eew=%0d, src2_eew=%0d, src1_eew=%0d", pc, dest_eew, src3_eew, src2_eew, src1_eew), UVM_HIGH)
  `uvm_info("TR_GEN",$sformatf("pc=0x%8x, dest_emul=%0d, src3_emul=%0d, src2_emul=%0d, src1_emul=%0d", pc, dest_emul, src3_emul, src2_emul, src1_emul), UVM_HIGH)

endfunction: legal_inst_gen

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
  string oprands = "";
  string comm = "# an example";
  // Inst name
  case(inst_type)
    LD, ST: begin
      inst = this.lsu_inst.name();
      case(lsu_mop)
        LSU_E   : begin
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
                inst = $sformatf("%s%0d", inst, lsu_eew);
              end else begin
                inst = $sformatf("%s%0de%0d", inst, lsu_nf+1, lsu_eew);
              end
            end
          endcase
        end
        LSU_SE  : begin
          if(this.lsu_nf == NF1) begin
            inst = $sformatf("%s%0d", inst, lsu_eew);
          end else begin
            inst = $sformatf("%s%0de%0d", inst, lsu_nf+1, lsu_eew);
          end
        end
        LSU_UXEI, 
        LSU_OXEI: begin
          if(this.lsu_nf == NF1) begin
            inst = $sformatf("%s%0d", inst, lsu_eew);
          end else begin
            inst = $sformatf("%s%0de%0d", inst, lsu_nf+1, lsu_eew);
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
          if(src2_idx == VMV_X_S)
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
  if(inst_type inside {LD, ST} && lsu_mop == LSU_SE && src2_type == XRF) comm = $sformatf("%s, const_stride=%0d", comm, $signed(rs2_data));

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
