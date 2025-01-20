`ifndef RVS_TRANSACTION__SV
`define RVS_TRANSACTION__SV

`include "inst_description.svh"

class rvs_transaction extends uvm_sequence_item;
  /* Tr config field */
  rand bit use_vlmax = 0;
       bit is_rt = 0;

  /* VCSR field */
  rand vtype_t           vtype;
  rand logic [`XLEN-1:0] vl;
       logic [`XLEN-1:0] vlmax;
  rand logic [`XLEN-1:0] vstart;
  rand vxrm_e            vxrm;

  /* Instruction description field */
  rand inst_type_e inst_type;// opcode

  // Load/Store inst
  rand lsu_inst_e lsu_inst;
  rand lsu_mop_e lsu_mop;
  rand lsu_umop_e lsu_umop;
  rand lsu_nf_e lsu_nf;
  rand eew_e lsu_eew;

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
       eew_e  dest_eew;
       eew_e  src1_eew;
       eew_e  src2_eew;
       eew_e  src3_eew;
       lmul_e dest_emul;
       lmul_e src1_emul;
       lmul_e src2_emul;
       lmul_e src3_emul;
       vext_e src1_func_vext;
   
  rand logic [`XLEN-1:0] rs_data;

  /* Real instruction */
  rand logic [31:0] pc;
       logic [31:0] bin_inst; 
       string asm_string;

  /* Write back info */
       reg_idx_t  rt_vrf_index  [$];
       vrf_t      rt_vrf_strobe [$];
       vrf_t      rt_vrf_data   [$];

       reg_idx_t  rt_xrf_index [$];
       xrf_t      rt_xrf_data  [$];

       logic [`XLEN-1:0] vxsat;  
       logic             vxsat_valid;  


  /* Trap field */
  // TODO
// Constrain ----------------------------------------------------------

  constraint c_normal_set {
    vtype.vill == 1'b0;
    vtype.rsv  ==  'b0;  
  }

  constraint c_vl {
    if(vtype.vlmul[2]) // fraction_lmul
      vl <= (`VLENB >> (~vtype.vlmul +3'b1)) >> vtype.vsew;
    else  
      vl <= (`VLENB << vtype.vlmul) >> vtype.vsew;
    vstart <= vl;
  }

  constraint c_vm {
    vm inside {0, 1};
    // (inst_type == ALU && alu_inst inside {VADC, VSBC})
    //   -> vm == 0;
    // (inst_type == ALU && alu_inst inside {
    //   VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR, 
    //   VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT})
    //   -> vm == 1;
  }

  constraint c_oprand {
    // OPI
    (inst_type == ALU && alu_inst[7:6] == 2'b00 && !(alu_inst inside {VSBC, VMSBC, VMSLTU, VMSLT, VMSGTU, VMSGT, VMERGE_VMVV, 
        VSLL, VSRL, VSRA, VNSRL, VNSRA,
        VSSRL, VSSRA, VNCLIPU, VNCLIP})) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPIVV && src1_type == VRF) || 
            (alu_type == OPIVX && src1_type == XRF) || 
            (alu_type == OPIVI && src1_type == IMM)
           )
      );

    (inst_type == ALU && alu_inst[7:6] == 2'b00 && (alu_inst inside {VSLL, VSRL, VSRA, VNSRL, VNSRA,
                                                                     VSSRL, VSSRA, VNCLIPU, VNCLIP})) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPIVV && src1_type == VRF) || 
            (alu_type == OPIVX && src1_type == XRF) || 
            (alu_type == OPIVI && src1_type == UIMM)
           )
      );

    (inst_type == ALU && alu_inst inside {VSBC, VMSBC, VMSLTU, VMSLT}) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPIVV && src1_type == VRF) || 
            (alu_type == OPIVX && src1_type == XRF) 
           )
      );

    (inst_type == ALU && alu_inst inside {VMSGTU, VMSGT}) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPIVI && src1_type == IMM) || 
            (alu_type == OPIVX && src1_type == XRF) 
           )
      );

    // check for constraint conflict 
    (inst_type == ALU && alu_inst inside {VMERGE_VMVV}) 
      -> (dest_type == VRF && 
           ((src2_type == VRF && vm == 0) ||
            (src2_type == UNUSE && vm == 1 && src2_idx == 0)
           ) &&
           ((alu_type == OPIVV && src1_type == VRF) || 
            (alu_type == OPIVX && src1_type == XRF) || 
            (alu_type == OPIVI && src1_type == IMM)
           )
      );

    // OPM
    (inst_type == ALU && alu_inst[7:6] == 2'b01 && !(alu_inst inside {VXUNARY0, VMUNARY0, VWXUNARY0/*, VWMACCUS*/})) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPMVV && src1_type == VRF) || 
            (alu_type == OPMVX && src1_type == XRF) 
           )
      );
    (inst_type == ALU && alu_inst[7:6] == 2'b01  && alu_inst == VWXUNARY0)
      -> (dest_type == XRF && src2_type == VRF && 
           ((alu_type == OPMVV && src1_type == FUNC && src1_idx inside {/*TODO*/VCPOP, VFIRST}))
      );

    (inst_type == ALU && alu_inst[7:6] == 2'b01 && alu_inst == VXUNARY0) 
      -> (dest_type == VRF && src2_type == VRF && 
           ((alu_type == OPMVV && src1_type == FUNC && src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2}))
      );

    (inst_type == ALU && alu_inst[7:6] == 2'b01 && alu_inst == VMUNARY0) 
      -> ((dest_type == XRF && src2_type == VRF && 
           alu_type == OPMVV && src1_type == FUNC && src1_idx inside {VIOTA, VID}) || 
          (dest_type == VRF && src2_type == VRF &&
           alu_type == OPMVV && src1_type == FUNC && src1_idx inside {VMSBF, VMSOF, VMSIF})
      );
    // FIXME
    //(inst_type == ALU && alu_inst[7:6] == 2'b01 && (alu_inst inside {VWMACCUS})) 
    //  -> (dest_type == VRF && src2_type == VRF && 
    //       ((alu_type == OPMVX && src1_type == XRF) 
    //       )
    //  );

    (inst_type == ALU) -> (src3_type == UNUSE);

    solve inst_type before src3_type;
  }

  constraint c_sewlmul {
    vtype.vsew != SEW_LAST;
    vtype.vlmul != LMUL_LAST;
    // widen
    // (inst_type == ALU && (alu_inst inside {VWADDU, VWADD, VWADD_W, VWSUBU, VWSUB, VWADDU_W, 
    //                                       VWMUL, VWMULU, VWMULSU}))
    //   -> (sew != SEW32);

    // narrow
    //(inst_type == ALU && (alu_inst inside {VNSRL, VNSRA})
    //  -> (sew != SEW8);
    
    // TODO
    // (dest_type == VRF && (vm == 0 || alu_inst inside {VMADC,VMSBC,
    //     VMSEQ,VMSNE,VMSLTU,VMSLT,VMSLEU,VMSLE,VMSGTU,VMSGT}))
    //   ->(dest_idx != 0);
    // constraint vrf idex for overlaping
    // widen: dest_idx != src_idx
    // narrow: dest_idx + dest_emul != src_idx
    // constraint vrf idex for alignment 
    // (dest_type == VRF) -> (dest_idx % dest_emul == 0);
    // (src3_type == VRF) -> (src3_idx % src3_emul == 0);
    // (src2_type == VRF) -> (src2_idx % src2_emul == 0);
    // (src1_type == VRF) -> (src1_idx % src1_emul == 0);
  }


// Auto Field ---------------------------------------------------------
  `uvm_object_utils_begin(rvs_transaction) 
    `uvm_field_int(pc,UVM_ALL_ON)
    `uvm_field_int(bin_inst,UVM_ALL_ON)
    `uvm_field_int(bin_inst[31:7],UVM_ALL_ON)
    `uvm_field_string(asm_string,UVM_ALL_ON)

    `uvm_field_enum(sew_e,vtype.vsew,UVM_ALL_ON)
    `uvm_field_enum(lmul_e,vtype.vlmul,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vtype.vma,UVM_ALL_ON)
    `uvm_field_enum(agnostic_e,vtype.vta,UVM_ALL_ON)

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
      `uvm_field_enum(eew_e,lsu_eew,UVM_ALL_ON)
    end

    `uvm_field_enum(oprand_type_e,dest_type,UVM_ALL_ON)
    `uvm_field_int(dest_idx,UVM_ALL_ON)
    `uvm_field_enum(oprand_type_e,src1_type,UVM_ALL_ON)
    if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) begin
      `uvm_field_enum(vext_e,src1_func_vext,UVM_ALL_ON)
    end else begin
      `uvm_field_int(src1_idx,UVM_ALL_ON)
    end
    `uvm_field_enum(oprand_type_e,src2_type,UVM_ALL_ON)
    `uvm_field_int(src2_idx,UVM_ALL_ON)
    `uvm_field_enum(oprand_type_e,src3_type,UVM_ALL_ON)
    `uvm_field_int(src3_idx,UVM_ALL_ON)
    `uvm_field_int(rs_data,UVM_ALL_ON)


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
  `uvm_object_utils_end

  extern function new(string name = "Trans");
  extern function void post_randomize();
  extern function void asm_string_gen();

endclass: rvs_transaction


function rvs_transaction::new(string name = "Trans");
  super.new(name);
endfunction: new

function void rvs_transaction::post_randomize();
  if(inst_type == ALU && (alu_inst inside {VADC, VSBC, VMADC, VMSBC, VMERGE_VMVV}))
    use_vm_to_cal = 1;
  else
    use_vm_to_cal = 0;
  
  if(src1_type == FUNC && inst_type == ALU && alu_inst == VXUNARY0) $cast(src1_func_vext,src1_idx);
  
  // rs random data
  if(src1_type != XRF && src2_type != XRF) rs_data = 'x;

  // constraint vl
  if(vtype.vlmul[2]) begin
    logic [2:0] vlmul = ~vtype.vlmul +3'b1;
    vlmax = (`VLENB >> vlmul) >> vtype.vsew; 
  end else begin
    logic [2:0] vlmul = vtype.vlmul;
    vlmax = (`VLENB << vlmul) >> vtype.vsew;
  end
  if(use_vlmax) begin 
    vl = vlmax;
    vstart = 0;
  end else begin
    vl = vl > vlmax ? vlmax : vl;
  end

  // gen bin_inst
  /* func6 */
  case(inst_type)
    LD: bin_inst[31:26] = '0; //FIXME
    ST: bin_inst[31:26] = '0; //FIXME
    ALU:bin_inst[31:26] = alu_inst[5:0];
  endcase
  /* vm */
  bin_inst[25]    = vm;
  bin_inst[24:20] = src2_idx;
  bin_inst[19:15] = src1_idx;
  case(inst_type)
    LD: bin_inst[14:12] = '0; // FIXME
    ST: bin_inst[14:12] = '0; // FIXME
    ALU: bin_inst[14:12] = alu_type;
  endcase
  bin_inst[11:7]  = dest_idx;
  bin_inst[6:0]   = inst_type;

  asm_string_gen();
endfunction: post_randomize

function void rvs_transaction::asm_string_gen();
  string inst = "nop";
  string suff = "";
  string suf0 = "";
  string src0 = "";
  string suf1 = "";
  string src1 = "";
  string suf2 = "";
  string src2 = "";
  string dest = "";
  string comm = "# an example";
  case(inst_type)
    LD: ; 
    ST: ; 
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
      end else begin
        inst = this.alu_inst.name();
      end
    end
  endcase
  inst = inst.tolower();
  case(this.src1_type)
    VRF: begin suf1 = "v"; src1 = $sformatf("v%0d",this.src1_idx); end
    XRF: begin suf1 = "x"; src1 = $sformatf("x%0d",this.src1_idx); end
    IMM: begin suf1 = "i"; src1 = $sformatf("%0d",$signed(this.src1_idx)); end
    UIMM: begin suf1 = "i"; src1 = $sformatf("%0d",$unsigned(this.src1_idx)); end
    FUNC: begin
      if(inst_type == ALU && alu_inst == VXUNARY0 && src1_idx inside{VSEXT_VF4, VSEXT_VF4}) begin
        suf1 = "f4"; src1 = "";
      end
      if(inst_type == ALU && alu_inst == VXUNARY0 && src1_idx inside{VSEXT_VF2, VSEXT_VF2}) begin
        suf1 = "f2"; src1 = "";
      end
    end
    default: begin suf1 = "?"; src1 = "?"; end
  endcase
  case(this.src2_type)
    VRF: begin 
      if(inst_type == ALU && alu_inst inside {VWADDU_W, VWADD_W, VWSUBU_W, VWSUB_W}) begin
        suf2 = "w"; src2 = $sformatf("v%0d",this.src2_idx); 
      end else begin
        suf2 = "v"; src2 = $sformatf("v%0d",this.src2_idx); 
      end
    end
    XRF: begin suf2 = "x"; src2 = $sformatf("x%0d",this.src2_idx); end
    IMM: begin suf2 = "i"; src2 = $sformatf("%0d",$signed(this.src2_idx)); end
  endcase
  if(vm == 0) begin
    if(inst_type == ALU && use_vm_to_cal == 1) begin
      suf0 = "m"; src0 = "v0";
    end else begin
      suf0 = "";  src0 = "v0.t";
    end
  end else begin
    suf0 = "";  src0 = "";
  end

  suff = $sformatf("%s%s%s",suf2,suf1,suf0);

  case(this.dest_type)
    VRF: dest = $sformatf("v%0d",this.dest_idx);
    XRF: dest = $sformatf("x%0d",this.dest_idx);
  endcase
  comm = $sformatf("# vlmul=%0s, vsew=%0s, vstart=%0d, vl=%0d", vtype.vlmul.name(), vtype.vsew.name(), vstart, vl);

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
