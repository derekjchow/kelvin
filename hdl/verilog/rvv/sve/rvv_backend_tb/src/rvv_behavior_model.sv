`ifndef RVV_BEHAVIOR_MODEL
`define RVV_BEHAVIOR_MODEL

`include "rvv_backend.svh"
`include "inst_description.svh"

  `uvm_analysis_imp_decl(_inst)

  typedef logic [0:0]  sew1_t;
  typedef logic [7:0]  sew8_t;
  typedef logic [15:0] sew16_t;
  typedef logic [31:0] sew32_t;

typedef class alu_processor;
class rvv_behavior_model extends uvm_component;
  typedef virtual rvs_interface v_if1;
  v_if1 rvs_if;  
  typedef virtual vrf_interface v_if3;
  v_if3 vrf_if;  

  bit ill_inst_en = 0;
  bit all_one_for_agn = 0;

  uvm_analysis_imp_inst #(rvs_transaction,rvv_behavior_model) inst_imp; 
  uvm_analysis_port #(rvs_transaction) rt_ap; 
  uvm_analysis_port #(vrf_transaction) vrf_ap;

  vtype_t           vtype;
  logic [`XLEN-1:0] vl;
  logic [`XLEN-1:0] vstart;
  vxrm_e            vxrm;
  logic [`XLEN-1:0] vxsat;  
  xrf_t [31:0] xrf;
  vrf_t [31:0] vrf;
  vrf_t [31:0] vrf_temp;

  logic [`XLEN-1:0] vlmax;
  logic [`XLEN-1:0] imm_data;

  byte mem[int];
  rvs_transaction inst_queue [$];

      
  `uvm_component_utils(rvv_behavior_model)

  extern function new(string name = "rvv_behavior_model", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual function void final_phase(uvm_phase phase);

  extern virtual task rx_mdl();
  extern virtual task tx_mdl();
  extern virtual task vrf_mdl();

  extern function logic [31:0] elm_fetch(oprand_type_e reg_type, int reg_idx, int elm_idx, int eew);
  extern task elm_writeback(logic [31:0] result, oprand_type_e reg_type, int reg_idx, int elm_idx, int eew);

  // imp task
  extern virtual function void write_inst(rvs_transaction inst_tr);

endclass : rvv_behavior_model

  function rvv_behavior_model::new(string name = "rvv_behavior_model", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void rvv_behavior_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    inst_imp = new("inst_imp", this);
    rt_ap = new("rt_ap", this);
    vrf_ap = new("vrf_ap", this);
  endfunction : build_phase 

  function void rvv_behavior_model::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(v_if1)::get(this, "", "rvs_if", rvs_if)) begin
      `uvm_fatal("MDL/NOVIF", "No virtual interface specified for this agent instance")
    end
    if(!uvm_config_db#(v_if3)::get(this, "", "vrf_if", vrf_if)) begin
      `uvm_fatal("MDL/NOVIF", "No virtual interface specified for this agent instance")
    end
    if(uvm_config_db#(bit)::get(this, "", "ill_inst_en", ill_inst_en))begin
      if(ill_inst_en) `uvm_info(get_type_name(), "Enable operating illegal instruction in reference model!", UVM_LOW)
    end
    if(uvm_config_db#(bit)::get(this, "", "all_one_for_agn", all_one_for_agn))begin
      if(all_one_for_agn) `uvm_info(get_type_name(), "Enable overwriting agnostic emelements with 1s in reference model!", UVM_LOW)
    end
  endfunction:connect_phase

  task rvv_behavior_model::reset_phase(uvm_phase phase);
    phase.raise_objection( .obj( this ) );
    while(!rvs_if.rst_n) begin
      vtype   = '0;
      vl      = '0;
      vstart  = '0;
      vxrm    = RNU;
      vxsat   = '0;
      for(int i=0; i<32; i++) begin
        vrf[i] = vrf_if.vreg_init_data[i];
        xrf[i] = '0;
      end
      @(posedge rvs_if.clk);
    end
    phase.drop_objection( .obj( this ) );
  endtask: reset_phase

  task rvv_behavior_model::main_phase(uvm_phase phase);
    rvs_transaction inst_tr;
    rvs_transaction rt_tr;
    super.main_phase(phase);
    fork
      // rx_mdl();
      tx_mdl();
      vrf_mdl();
    join 
  endtask : main_phase 

  function void rvv_behavior_model::final_phase(uvm_phase phase);
    super.final_phase(phase);
    if(inst_queue.size()>0) begin
      `uvm_error("FINAL_CHECK", "inst_queue in MDL wasn't empty!")
      foreach(inst_queue[idx]) begin
        `uvm_error("FINAL_CHECK",inst_queue[idx].sprint())
      end
    end
  endfunction: final_phase 

  function void rvv_behavior_model::write_inst(rvs_transaction inst_tr);
    `uvm_info("DEBUG", "get a inst", UVM_HIGH)
    `uvm_info("DEBUG", inst_tr.sprint(), UVM_HIGH)
    inst_queue.push_back(inst_tr);
  endfunction

  task rvv_behavior_model::rx_mdl();
  endtask: rx_mdl

  task rvv_behavior_model::tx_mdl();
    bit fraction_lmul;
    int  eew;
    real emul;
    int elm_idx_max;
  
    int pc;

    bit is_mask_inst;
    bit is_widen_inst;
    bit is_widen_vs2_inst;
    bit is_narrow_inst;
    bit use_vm_to_cal;

    bit vm;

    int dest_reg_idx, dest_eew; real dest_emul;
    int src0_reg_idx, src0_eew; real src0_emul;
    int src1_reg_idx, src1_eew; real src1_emul;
    int src2_reg_idx, src2_eew; real src2_emul;
    int src3_reg_idx, src3_eew; real src3_emul;
    logic [31:0] dest;
    logic [31:0] src0;
    logic [31:0] src1;
    logic [31:0] src2;
    logic [31:0] src3;

    logic [`NUM_RT_UOP-1:0] rt_event;
    rvs_transaction inst_tr;

    inst_tr = new();
    forever begin
      @(posedge rvs_if.clk);
      if(rvs_if.rst_n) begin
      rt_event = rvs_if.rt_event;
      while(|rt_event) begin
      if(rt_event[0]) begin
        // --------------------------------------------------
        // 0. Get inst and update VCSR
        if(inst_queue.size()>0) begin
          inst_tr = inst_queue.pop_front();
          vtype  = inst_tr.vtype;
          vl     = inst_tr.vl;
          vstart = inst_tr.vstart;
          vxrm   = inst_tr.vxrm;
          vxsat  = '0;

          `uvm_info("DEBUG","Start calculation.",UVM_LOW)
          `uvm_info("DEBUG",inst_tr.sprint(),UVM_LOW)
        end else begin
          `uvm_error(get_type_name(), "Pop inst_queue while empty.")
          break;
        end
        // 0.2 Calculate & decode for this instr
        eew = 8 << vtype.vsew;
        fraction_lmul = vtype.vlmul[2];
        emul = 2.0 ** $signed(vtype.vlmul);
        // vlmax = inst_tr.vlmax;
        elm_idx_max = fraction_lmul ?        `VLEN / eew: 
                                      emul * `VLEN / eew;

        // --------------------------------------------------
        // 1. Decode - Get eew & emul
        pc = inst_tr.pc;
        is_mask_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VMAND});
        is_widen_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W, 
                                                                              VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCUS, VWMACCSU});
        is_widen_vs2_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VWADD_W, VWADDU_W, VWSUBU_W, VWSUB_W});
        is_narrow_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VNSRL, VNSRA});
        use_vm_to_cal = inst_tr.use_vm_to_cal;

        // 1.0 illegal inst check
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VRSUB && inst_tr.src2_type == VRF && inst_tr.src1_type == VRF) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vrsub.vv is ignored.",pc))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_type == OPIVI && (inst_tr.alu_inst inside {VSUB, VMSBC, VSBC, VMINU, VMIN, VMAXU, VMAX})) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: OPIVI of %0s is ignored.",pc,inst_tr.alu_type.name()))
          continue;
        end

        dest_eew = eew;
        src0_eew = EEW1;
        src1_eew = eew;
        src2_eew = eew;
        src3_eew = eew;

        dest_emul = emul;
        src0_emul = 1;
        src1_emul = emul;
        src2_emul = emul;
        src3_emul = emul;

        vm = inst_tr.vm; // <v0.t>

        case(inst_tr.inst_type)
          LD: begin
            // 1.1 unit-stride and constant-stride
            if(inst_tr.lsu_mop == LSU_E || inst_tr.lsu_mop == LSU_SE) begin
              dest_eew  = inst_tr.lsu_eew;
              dest_emul = inst_tr.lsu_eew * emul / eew;
              src1_eew  = EEW32; // rs1 as base address
              src1_emul = LMUL1;
            end
            // 1.2 vector indexed
            if(inst_tr.lsu_mop == LSU_UXEI || inst_tr.lsu_mop == LSU_OXEI) begin
              dest_eew  = eew;   
              dest_emul = emul;
              src1_eew  = EEW32;    // rs1 as base address
              src1_emul = LMUL1;
              src2_eew  = inst_tr.lsu_eew;  // vs2 as offset address
              src2_emul = inst_tr.lsu_eew * emul / eew;
            end
          end
          ST: begin
            // 1.1 unit-stride and constant-stride
            if(inst_tr.lsu_mop == LSU_E || inst_tr.lsu_mop == LSU_SE) begin
              src3_eew = inst_tr.lsu_eew;
              src3_emul = src3_eew * emul / eew;
              src1_eew = EEW32; // rs1 as base address
              src1_emul= LMUL1;
            end
            // 1.2 vector indexed
            if(inst_tr.lsu_mop == LSU_UXEI || inst_tr.lsu_mop == LSU_OXEI) begin
              src3_eew  = eew;   
              src3_emul = emul;
              src1_eew  = EEW32;    // rs1 as base address
              src1_emul = LMUL1;
              src2_eew  = inst_tr.lsu_eew;  // vs2 as offset address
              src2_emul = inst_tr.lsu_eew * emul / eew;
            end
          end
          ALU: begin
            // 1.1 Widen
            if(is_widen_inst) begin
              if(!(vtype.vsew inside {SEW8,SEW16})) begin
                `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal sew(%s) for widen instruction. Ignored.",pc,inst_tr.vtype.vsew.name()));
                continue;
              end else begin
                dest_eew = dest_eew * 2;
                dest_emul = dest_emul * 2;
              end
            end
            if(is_widen_vs2_inst) begin
              if(!(vtype.vsew inside {SEW8,SEW16})) begin
                `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal sew(%s) for widen instruction. Ignored.",pc,inst_tr.vtype.vsew.name()));
                continue;
              end else begin
                src2_eew = src2_eew * 2;
                src2_emul = src2_emul * 2;
              end
            end
            // 1.2 Narrow
            if(is_narrow_inst) begin
              if(!(vtype.vsew inside {SEW8,SEW16})) begin
                `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal sew(%s) for narrow instruction. Ignored.",pc,inst_tr.vtype.vsew.name()));
                continue;
              end else if(vtype.vlmul == LMUL8) begin
                `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal lmul(%s) for narrow instruction. Ignored.",pc,inst_tr.vtype.vlmul.name()));
                continue;
              end else begin
                src2_eew = src2_eew * 2;
                src2_emul = src2_emul * 2;
              end
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VXUNARY0) begin
              if(inst_tr.src1_idx inside {VSEXT_VF2, VZEXT_VF2}) begin
                if(!(vtype.vsew inside {SEW16,SEW32})) begin
                  `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal sew(%s) for vext instruction. Ignored.",pc,inst_tr.vtype.vsew.name()));
                  continue;
                end else if(!(vtype.vlmul inside {LMUL1_2,LMUL1,LMUL2,LMUL4,LMUL8})) begin
                  `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal lmul(%s) for vext instruction. Ignored.",pc,inst_tr.vtype.vlmul.name()));
                  continue;
                end else begin
                  src2_eew = src2_eew / 2;
                  src2_emul = src2_emul / 2;
                end
              end
              if(inst_tr.src1_idx inside {VSEXT_VF4, VZEXT_VF4}) begin
                if(!(vtype.vsew inside {SEW32})) begin
                  `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal sew(%s) for vext instruction. Ignored.",pc,inst_tr.vtype.vsew.name()));
                  continue;
                end else if(!(vtype.vlmul inside {LMUL1,LMUL2,LMUL4,LMUL8})) begin
                  `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal lmul(%s) for vext instruction. Ignored.",pc,inst_tr.vtype.vlmul.name()));
                  continue;
                end else begin
                  src2_eew = src2_eew / 4;
                  src2_emul = src2_emul / 4;
                end
              end
            end
            // 1.3 Mask inst
            if(is_mask_inst) begin
              dest_eew = EEW1;
              src1_eew = EEW1;
              src2_eew = EEW1;
              src3_eew = EEW1;
              dest_emul = dest_emul * dest_eew / eew;
              src1_emul = src1_emul * src1_eew / eew;
              src2_emul = src2_emul * src2_eew / eew;
              src3_emul = src3_emul * src3_eew / eew;
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VMADC, VMSBC, 
                VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT}) begin
              dest_eew = EEW1;
              dest_emul = dest_emul * dest_eew / eew;
            end
          end
          default: begin
            continue;
          end
        endcase

        // --------------------------------------------------
        // 2. Prepare oprand
        // 2.1 Update XRF & IMM values
        if(inst_tr.src1_type == XRF) xrf[inst_tr.src1_idx] = inst_tr.rs_data;
        if(inst_tr.src2_type == XRF) xrf[inst_tr.src2_idx] = inst_tr.rs_data;
        if(inst_tr.src1_type == IMM) begin 
          imm_data = $signed(inst_tr.src1_idx);
          `uvm_info("DEBUG", $sformatf("Got imm_data = 0x%8x(%0d) from rs1",imm_data, $signed(imm_data)), UVM_HIGH)
        end else if (inst_tr.src1_type == UIMM) begin
          imm_data = $unsigned(inst_tr.src1_idx);
          `uvm_info("DEBUG", $sformatf("Got uimm_data = 0x%8x(%0d) from rs1",imm_data, $unsigned(imm_data)), UVM_HIGH)
        end
        if(inst_tr.src2_type == IMM) begin 
          imm_data = $signed(inst_tr.src2_idx);
          `uvm_info("DEBUG", $sformatf("Got imm_data = 0x%8x(%0d) from rs2",imm_data, $signed(imm_data)), UVM_HIGH)
        end else if (inst_tr.src2_type == UIMM) begin
          imm_data = $unsigned(inst_tr.src2_idx);
          `uvm_info("DEBUG", $sformatf("Got uimm_data = 0x%8x(%0d) from rs2",imm_data, $unsigned(imm_data)), UVM_HIGH)
        end
          
        // 2.2 Check VRF index
        dest_reg_idx = inst_tr.dest_idx;
        src2_reg_idx = inst_tr.src2_idx;
        src1_reg_idx = inst_tr.src1_idx;

        // 2.2.1 Alignment Check
        if(inst_tr.dest_type == VRF) begin
          if(dest_reg_idx % int'(dest_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.3.4.2. Dest vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc , dest_reg_idx, dest_emul));
            continue;
          end
        end
        if(inst_tr.src2_type == VRF) begin
          if(src2_reg_idx % int'(src2_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.3. Src2 vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc, src2_reg_idx, src2_emul));
            continue;
          end
        end
        if(inst_tr.src1_type == VRF) begin
          if(src1_reg_idx % int'(src1_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.3.4.2. Src1 vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc, src1_reg_idx, src1_emul));
            continue;
          end
        end

        // 2.2.2 Overlap Check
        if(inst_tr.dest_type == VRF && inst_tr.src2_type == VRF && (dest_eew > src2_eew) && src2_reg_idx == dest_reg_idx && src2_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The lowest part of dest vrf(v%0d~v%0d) overlaps the src2 vrf(v%0d~v%0d) in a widen instruction. Ignored.",pc,
              dest_reg_idx, dest_reg_idx+dest_emul, src2_reg_idx, src2_reg_idx+src2_emul));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src2_type == VRF && (dest_eew < src2_eew) && (src2_reg_idx+dest_emul) == dest_reg_idx) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src2 vrf(v%0d~v%0d) in a narrow instruction. Ignored.",pc,
              dest_reg_idx, dest_reg_idx+dest_emul, src2_reg_idx, src2_reg_idx+src2_emul));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src1_type == VRF && (dest_eew > src1_eew) && src1_reg_idx == dest_reg_idx && src1_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The lower part of dest vrf(v%0d~v%0d) overlaps the src1 vrf(v%0d~v%0d) in a widen instruction. Ignored.",pc,
              dest_reg_idx, dest_reg_idx+dest_emul, src1_reg_idx, src1_reg_idx+src1_emul));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src1_type == VRF && (dest_eew < src1_eew) && (src1_reg_idx+dest_emul) == dest_reg_idx) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src1 vrf(v%0d~v%0d) in a narrow instruction. Ignored.",pc,
              dest_reg_idx, dest_reg_idx+dest_emul, src1_reg_idx, src1_reg_idx+src1_emul));
          continue;
        end
        if(inst_tr.dest_type == VRF && vm == 0 && dest_reg_idx == 0 && (dest_eew != EEW1 /*|| TODO scalar result of a reduction*/)) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.3. Dest vrf index(%0d) overlap source mask register v0. Ignored.",pc,dest_reg_idx));
          continue;
        end


        vrf_temp = vrf;
        `uvm_info("DEBUG",$sformatf("Prepare done!\nelm_idx_max=%0d\ndest_eew=%0d\nsrc2_eew=%0d\nsrc1_eew=%0d\ndest_emul=%2.4f\nsrc2_emul=%2.4f\nsrc1_emul=%2.4f\n",elm_idx_max,dest_eew,src2_eew,src1_eew,dest_emul,src2_emul,src1_emul),UVM_HIGH)
        // --------------------------------------------------
        // 3. Operate elements
        for(int elm_idx=0; elm_idx<elm_idx_max; elm_idx++) begin : op_element

          // 3.1 Fetch elements data 
          dest = elm_fetch(inst_tr.dest_type, dest_reg_idx, elm_idx, dest_eew); 
          src3 = elm_fetch(inst_tr.src3_type, src3_reg_idx, elm_idx, src3_eew); 
          src2 = elm_fetch(inst_tr.src2_type, src2_reg_idx, elm_idx, src2_eew); 
          src1 = elm_fetch(inst_tr.src1_type, src1_reg_idx, elm_idx, src1_eew); 
          if(vm == 0) begin
            src0 = elm_fetch(VRF, 0, elm_idx, src0_eew);
          end else begin
            if(inst_tr.alu_inst inside {VMERGE_VMVV})
              src0 = '1;
            if(inst_tr.alu_inst inside {VMADC, VMSBC})
              src0 = '0;
          end
          
          `uvm_info("DEBUG", $sformatf("Before - element[%2d]: dest=0x%8h, src2=0x%8h, src1=0x%8h, src0=0x%8h", elm_idx, dest, src2, src1, src0), UVM_LOW)

          // 3.2 Execute & Writeback 
          if(elm_idx < vstart) begin
            `uvm_info("DEBUG", $sformatf("element[%2d]: pre-start", elm_idx), UVM_LOW)
            // pre-start: do nothing
          end else if(elm_idx >= vl) begin
            // tail
            `uvm_info("DEBUG", $sformatf("element[%2d]: tail", elm_idx), UVM_LOW)
            if(vtype.vta == AGNOSTIC) begin
              if(all_one_for_agn) dest = '1;
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx, elm_idx, dest_eew);
            end else begin
            end
          end else if(!(vm || this.vrf[0][elm_idx] || use_vm_to_cal)) begin
            // body-inactive
            `uvm_info("DEBUG", $sformatf("element[%2d]: body-inactive", elm_idx), UVM_LOW)
            if(vtype.vma == AGNOSTIC) begin
              if(all_one_for_agn) dest = '1;
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx, elm_idx, dest_eew);
            end else begin
            end
          end else begin
            // body-active
            `uvm_info("DEBUG", $sformatf("element[%2d]: body-active", elm_idx), UVM_LOW)
            // EX
            case(inst_tr.inst_type)
              LD: 
              ST: `uvm_fatal(get_type_name(),"Store fucntion hasn't been defined.")
              ALU: begin 
                alu_processor#()::vxrm = vxrm;
                case({dest_eew, src2_eew, src1_eew})
                  { EEW8,  EEW8,  EEW8}: dest = alu_processor #( sew8_t,  sew8_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW16, EEW16, EEW16}: dest = alu_processor #(sew16_t, sew16_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32, EEW32, EEW32}: dest = alu_processor #(sew32_t, sew32_t, sew32_t)::exe(inst_tr, dest, src2, src1, src0);
                  // widen
                  {EEW16,  EEW8,  EEW8}: dest = alu_processor #(sew16_t,  sew8_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW16, EEW16,  EEW8}: dest = alu_processor #(sew16_t, sew16_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32, EEW16, EEW16}: dest = alu_processor #(sew32_t, sew16_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32, EEW32, EEW16}: dest = alu_processor #(sew32_t, sew32_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  //ext
                  {EEW16,  EEW8, EEW32}: dest = alu_processor #(sew16_t,  sew8_t, sew32_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW16,  EEW8, EEW16}: dest = alu_processor #(sew16_t,  sew8_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  //{EEW16,  EEW8,  EEW8}: dest = alu_processor #(sew32_t,  sew8_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32, EEW16, EEW32}: dest = alu_processor #(sew32_t, sew16_t, sew32_t)::exe(inst_tr, dest, src2, src1, src0);
                  //{EEW32, EEW16, EEW16}: dest = alu_processor #(sew32_t, sew16_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32, EEW16,  EEW8}: dest = alu_processor #(sew32_t, sew16_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32,  EEW8, EEW32}: dest = alu_processor #(sew32_t,  sew8_t, sew32_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32,  EEW8, EEW16}: dest = alu_processor #(sew32_t,  sew8_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW32,  EEW8,  EEW8}: dest = alu_processor #(sew32_t,  sew8_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  // narrow
                  { EEW8, EEW16,  EEW8}: dest = alu_processor #( sew8_t, sew16_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  {EEW16, EEW32, EEW16}: dest = alu_processor #(sew16_t, sew32_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  // mask logic
                  { EEW1,  EEW1,  EEW1}: dest = alu_processor #( sew1_t,  sew1_t,  sew1_t)::exe(inst_tr, dest, src2, src1, src0);
                  { EEW1,  EEW8,  EEW8}: dest = alu_processor #( sew1_t,  sew8_t,  sew8_t)::exe(inst_tr, dest, src2, src1, src0);
                  { EEW1, EEW16, EEW16}: dest = alu_processor #( sew1_t, sew16_t, sew16_t)::exe(inst_tr, dest, src2, src1, src0);
                  { EEW1, EEW32, EEW32}: dest = alu_processor #( sew1_t, sew32_t, sew32_t)::exe(inst_tr, dest, src2, src1, src0);
                  default: begin
                    `uvm_error("DEBUG", $sformatf("Unsupported EEW: dest_eew=%d, src2_eew=%d, src1_eew=%d", dest_eew, src2_eew, src1_eew))
                    continue;
                  end
                endcase
                vxsat = vxsat ? vxsat : (alu_processor#()::overflow || alu_processor#()::underflow);
                elm_writeback(dest, inst_tr.dest_type, dest_reg_idx, elm_idx, dest_eew);
              end
            endcase
            // Write back
          end

          `uvm_info("DEBUG", $sformatf("After  - element[%2d]: dest=0x%8h, src2=0x%8h, src1=0x%8h, src0=0x%8h\n", elm_idx, dest, src2, src1, src0), UVM_LOW)
        end : op_element

        // --------------------------------------------------
        // 4. WB transaction gen
        vrf = vrf_temp;
        inst_tr.rt_xrf.rt_index = inst_tr.dest_idx;
        inst_tr.rt_xrf.rt_data  = this.xrf[inst_tr.dest_idx];
        `uvm_info("DEBUG","Complete calculation.",UVM_LOW)
        `uvm_info("DEBUG",inst_tr.sprint(),UVM_LOW)
        rt_ap.write(inst_tr);
      end // if(rt_event[0])
        rt_event = rt_event >> 1;
      end // while(|rt_event)
      end // rst_n
    end // forever
    // `uvm_fatal("MDL/FATAL","Im here.")
  endtask

  function logic [31:0] rvv_behavior_model::elm_fetch(oprand_type_e reg_type, int reg_idx, int elm_idx, int eew);
    logic [31:0] result;
    int bit_count;
    bit_count = eew;
    result = '0;
    case(reg_type)
      VRF: begin
        reg_idx = elm_idx / (`VLEN / eew) + reg_idx;
        elm_idx = elm_idx % (`VLEN / eew);
        // `uvm_info("DEBUG", $sformatf("reg_type=%0d, reg_idx=%0d, elm_idx=%0d, eew=%0d", reg_type, reg_idx, elm_idx, eew), UVM_HIGH)
        for(int i=0; i<bit_count; i++) begin
          result[i] = this.vrf[reg_idx][elm_idx*bit_count + i];
          // `uvm_info("DEBUG", $sformatf("elm_idx*bit_count + i=%0d", elm_idx*bit_count + i), UVM_HIGH)
          // `uvm_info("DEBUG", $sformatf("result[%0d]=%0d", i, result[i]), UVM_HIGH)
        end
      end
      XRF: begin
        for(int i=0; i<bit_count; i++) begin
          result[i] = this.xrf[reg_idx][i]; 
        end
      end
      UIMM,IMM: begin
        for(int i=0; i<bit_count; i++) begin
          result[i] = this.imm_data[i]; 
        end
      end
      default: result = 'x;
    endcase
    elm_fetch = result;
    // `uvm_info("DEBUG", $sformatf("result=%0h", result), UVM_HIGH)
  endfunction: elm_fetch

  task rvv_behavior_model::elm_writeback(logic [31:0] result, oprand_type_e reg_type, int reg_idx, int elm_idx, int eew);
    int bit_count;
    bit_count = eew;
    case(reg_type)
      VRF: begin
        reg_idx = elm_idx / (`VLEN / eew) + reg_idx;
        elm_idx = elm_idx % (`VLEN / eew);
        for(int i=0; i<bit_count; i++) begin
          this.vrf_temp[reg_idx][elm_idx*bit_count + i] = result[i];
        end
      end
      XRF: begin
        for(int i=0; i<bit_count; i++) begin
          this.xrf[reg_idx][i] = result[i]; 
        end
      end
    endcase
  endtask: elm_writeback

  task rvv_behavior_model::vrf_mdl();
    vrf_transaction tr;
    tr = new();
    forever begin
      @(posedge rvs_if.clk);
      if(rvs_if.rst_n) begin
        if(|vrf_if.rt_event) begin
          for(int i=0; i<32; i++) begin
              tr.vreg[i] = vrf[i];
          end
          vrf_ap.write(tr);
        end
      end
    end
  endtask

// ALU inst part ------------------------------------------
virtual class alu_processor#(
  type TD = sew8_t,
  type T2 = sew8_t,
  type T1 = sew8_t,  
  type T0 = sew1_t);  
  
  parameter ALU_MAX_WIDTH = `VLEN;

  static bit overflow;
  static bit underflow;
  static vxrm_e vxrm;

  static function TD exe (rvs_transaction inst_tr, TD dest, T2 src2, T1 src1, T0 src0); //TODO ref ...
    // `uvm_info("DEBUG", $sformatf("sizeof(T1)=%0d, sizeof(T2)=%0d, sizeof(TD)=%0d", $size(T1), $size(T2), $size(TD)), UVM_HIGH)
    overflow  = 0;
    underflow = 0;
    case(inst_tr.alu_inst) 
    // OPI
      VADD: dest = _vadd(src2, src1); 
      VSUB: dest = _vsub(src2, src1); 
      VRSUB: dest = _vsub(src1, src2); 
  
      VADC : dest = _vadc(src2,src1,src0);
      VMADC: dest = _vmadc(src2,src1,src0);
      VSBC : dest = _vsbc(src2,src1,src0);
      VMSBC: dest = _vmsbc(src2,src1,src0);

      VAND : dest = _vmand(src2, src1); 
      VOR  : dest = _vmor(src2, src1); 
      VXOR : dest = _vmxor(src2, src1); 

      VMSEQ : dest = _vmseq(src2, src1); 
      VMSNE : dest = _vmsne(src2, src1); 
      VMSLTU: dest = _vmsltu(src2, src1); 
      VMSLT : dest = _vmslt(src2, src1); 
      VMSLEU: dest = _vmsleu(src2, src1); 
      VMSLE : dest = _vmsle(src2, src1); 
      VMSGTU: dest = _vmsgtu(src2, src1); 
      VMSGT : dest = _vmsgt(src2, src1); 

      VMINU: dest = _vminu(src2, src1); 
      VMIN : dest = _vmin(src2, src1); 
      VMAXU: dest = _vmaxu(src2, src1); 
      VMAX : dest = _vmax(src2, src1); 

      VMERGE_VMVV: dest = _vmerge(src2, src1, src0); 

      VSADDU: dest = _vsaddu(src2, src1);
      VSADD : dest = _vsadd(src2, src1);
      VSSUBU: dest = _vssubu(src2, src1);
      VSSUB : dest = _vssub(src2, src1);

      VSMUL_VMVNRR: dest = _vsmul(src2,src1);
    // OPM
      VWADD,
      VWADD_W:  dest = _vadd(src2, src1);
      VWADDU,
      VWADDU_W: dest = _vaddu(src2, src1); 
      VWSUB, 
      VWSUB_W:  dest = _vsub(src2, src1);
      VWSUBU, 
      VWSUBU_W: dest = _vsubu(src2, src1); 

      VXUNARY0: begin 
        if(inst_tr.src1_idx == VZEXT_VF4 || inst_tr.src1_idx == VZEXT_VF2) dest = _vzext(src2); 
        if(inst_tr.src1_idx == VSEXT_VF4 || inst_tr.src1_idx == VSEXT_VF2) dest = _vsext(src2); 
      end

      VSLL : dest = _vsll(src2, src1);
      VSRL : dest = _vsrl(src2, src1);
      VSRA : dest = _vsra(src2, src1);
      VNSRL: dest = _vsrl(src2, src1);
      VNSRA: dest = _vsra(src2, src1);
        
      VMUL    : dest = _vmul(src2, src1);
      VMULH   : dest = _vmulh(src2, src1);
      VMULHU  : dest = _vmulhu(src2, src1);
      VMULHSU : dest = _vmulhsu(src2, src1);
                
      VDIVU: dest = _vdivu(src2, src1);
      VDIV : dest = _vdiv(src2, src1);
      VREMU: dest = _vremu(src2, src1);
      VREM : dest = _vrem(src2, src1);        

      VWMUL  : dest = _vwmul(src2, src1);
      VWMULU : dest = _vwmulu(src2, src1);
      VWMULSU: dest = _vwmulsu(src2, src1);

      VMACC : dest = _vmacc(dest, src2, src1);
      VNMSAC: dest = _vnmsac(dest, src2, src1);
      VMADD : dest = _vmadd(dest, src2, src1);
      VNMSUB: dest = _vnmsub(dest, src2, src1);

      VWMACCU  : dest = _vwmaccu(dest, src2, src1);
      VWMACC   : dest = _vwmacc(dest, src2, src1);
      VWMACCUS : dest = _vwmaccus(dest, src2, src1);
      VWMACCSU : dest = _vwmaccsu(dest, src2, src1);

      VAADDU: dest = _vaaddu(src2, src1);
      VAADD : dest = _vaadd(src2, src1);
      VASUBU: dest = _vasubu(src2, src1);
      VASUB : dest = _vasub(src2, src1);

      VMAND : dest = _vmand(src2, src1); 
      VMOR  : dest = _vmor(src2, src1); 
      VMXOR : dest = _vmxor(src2, src1); 
      VMORN : dest = _vmorn(src2, src1); 
      VMNAND: dest = _vmnand(src2, src1); 
      VMNOR : dest = _vmnor(src2, src1); 
      VMANDN: dest = _vmandn(src2, src1); 
      VMXNOR: dest = _vmxnor(src2, src1); 
    endcase
    exe = dest;
    // `uvm_info("DEBUG", $sformatf("dest=%0d, src1=%0d, src2=%0d", exe, src1, src2), UVM_HIGH)
  endfunction : exe

  static function logic [ALU_MAX_WIDTH-1:0] _roundoff_unsigned(logic [ALU_MAX_WIDTH-1:0] v, int d);
    logic r;
    logic [ALU_MAX_WIDTH-1:0] v_ds1to0;
    logic [ALU_MAX_WIDTH-1:0] v_ds2to0;
    for(int i=0; i<ALU_MAX_WIDTH; i++) begin
      v_ds1to0[i] = (i>d-1) ? 1'b0 : v[i];
      v_ds2to0[i] = (i>d-2) ? 1'b0 : v[i];
    end
    case(vxrm)
    // TODO check d==0,1 condition
      RNU: r = (d == 0) ? 0 : v[d-1];
      RNE: r = (d == 0) ? 0 : ((d == 1) ? v[d-1] && v[d] : v[d-1] && (v_ds2to0 != 0 || v[d]));
      RDN: r = 0;
      ROD: r = (d == 0) ? 0 : !v[d] && (v_ds1to0 != 0);
    endcase
    _roundoff_unsigned = ($unsigned(v) >> d) + r;
  endfunction: _roundoff_unsigned
  static function logic [ALU_MAX_WIDTH-1:0] _roundoff_signed(logic [ALU_MAX_WIDTH-1:0] v, int d);
    logic r;
    logic [ALU_MAX_WIDTH-1:0] v_ds1to0;
    logic [ALU_MAX_WIDTH-1:0] v_ds2to0;
    for(int i=0; i<ALU_MAX_WIDTH; i++) begin
      v_ds1to0[i] = (i>d-1) ? 1'b0 : v[i];
      v_ds2to0[i] = (i>d-2) ? 1'b0 : v[i];
    end
    case(vxrm)
    // TODO check d==0,1 condition
      RNU: r = (d == 0) ? 0 : v[d-1];
      RNE: r = (d == 0) ? 0 : ((d == 1) ? v[d-1] && v[d] : v[d-1] && (v_ds2to0 != 0 || v[d]));
      RDN: r = 0;
      ROD: r = (d == 0) ? 0 : !v[d] && (v_ds1to0 != 0);
    endcase
    _roundoff_signed = ($signed(v) >>> d) + r;
  endfunction: _roundoff_signed

  static function TD _vadd(T2 src2, T1 src1);
    _vadd = $signed(src1) + $signed(src2);
  endfunction : _vadd
  static function TD _vaddu(T2 src2, T1 src1);
    _vaddu = $unsigned(src1) + $unsigned(src2);
  endfunction : _vaddu
  static function TD _vsub(T2 src2, T1 src1);
    _vsub = $signed(src2) - $signed(src1);
  endfunction : _vsub
  static function TD _vsubu(T2 src2, T1 src1);
    _vsubu = $unsigned(src2) - $unsigned(src1);
  endfunction : _vsubu

  static function TD _vadc(T2 src2, T1 src1, T0 src0);
    _vadc = $signed(src2) + $signed(src1) + src0;
  endfunction : _vadc
  static function TD _vmadc(T2 src2, T1 src1, T0 src0);
    logic [$bits(T2):0] dest;
    dest = $signed(src2) + $signed(src1) + src0;
    _vmadc = dest[$bits(T2)];
  endfunction : _vmadc
  // FIXME : need to confirm
  static function TD _vsbc(T2 src2, T1 src1, T0 src0);
    _vsbc = $signed(src2) - $signed(src1) - src0;
  endfunction : _vsbc
  static function TD _vmsbc(T2 src2, T1 src1, T0 src0);
    logic [$bits(T2):0] dest;
    dest = $signed(src2) - $signed(src1) - src0;
    _vmsbc = dest[$bits(T2)];
  endfunction : _vmsbc

  static function TD _vmseq(T2 src2, T1 src1);
    _vmseq = $signed(src2) === $signed(src1);
  endfunction : _vmseq
  static function TD _vmsne(T2 src2, T1 src1);
    _vmsne = $signed(src2) !== $signed(src1);
  endfunction : _vmsne
  static function TD _vmsltu(T2 src2, T1 src1);
    _vmsltu = $unsigned(src2) < $unsigned(src1);
  endfunction : _vmsltu
  static function TD _vmslt(T2 src2, T1 src1);
    _vmslt = $signed(src2) < $signed(src1);
  endfunction : _vmslt
  static function TD _vmsleu(T2 src2, T1 src1);
    _vmsleu = $unsigned(src2) <= $unsigned(src1);
  endfunction : _vmsleu
  static function TD _vmsle(T2 src2, T1 src1);
    _vmsle = $signed(src2) <= $signed(src1);
  endfunction : _vmsle
  static function TD _vmsgtu(T2 src2, T1 src1);
    _vmsgtu = $unsigned(src2) > $unsigned(src1);
  endfunction : _vmsgtu
  static function TD _vmsgt(T2 src2, T1 src1);
    _vmsgt = $signed(src2) > $signed(src1);
  endfunction : _vmsgt

  static function TD _vminu(T2 src2, T1 src1);
    _vminu = $unsigned(src2) > $unsigned(src1) ? $unsigned(src1) : $unsigned(src2);
  endfunction : _vminu
  static function TD _vmin(T2 src2, T1 src1);
    _vmin = $signed(src2) > $signed(src1) ? $signed(src1) : $signed(src2);
  endfunction : _vmin
  static function TD _vmaxu(T2 src2, T1 src1);
    _vmaxu = $unsigned(src2) > $unsigned(src1) ? $unsigned(src2) : $unsigned(src1);
  endfunction : _vmaxu
  static function TD _vmax(T2 src2, T1 src1);
    _vmax = $signed(src2) > $signed(src1) ? $signed(src2) : $signed(src1);
  endfunction : _vmax

  static function TD _vzext(T2 src2);
    _vzext = $unsigned(src2);
  endfunction : _vzext
  static function TD _vsext(T2 src2);
    _vsext = $signed(src2);
  endfunction : _vsext
  
  //---------------------------------------------------------------------- 
  // Ch32.11.6. Vector Single-Width Shift Instructions
  // Ch32.11.7. Vector Narrowing Integer Right Shift Instructions
  static function TD _vsll(T2 src2, T1 src1);
    logic [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsll = $unsigned(src2) << shift_amount;
  endfunction : _vsll
  static function TD _vsrl(T2 src2, T1 src1);
    logic [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsrl = $unsigned(src2) >> shift_amount;
  endfunction : _vsrl
  static function TD _vsra(T2 src2, T1 src1);
    logic [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsra = $signed(src2) >>> shift_amount;
  endfunction : _vsra

  //---------------------------------------------------------------------- 
  // Ch32.11.10. Vector Single-Width Integer Multiply Instructions
  static function TD _vmul(T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen * src1_widen;
    _vmul = dest_widen[$bits(TD)-1:0];
  endfunction : _vmul
  static function TD _vmulh(T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulh = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulh
  static function TD _vmulhu(T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulhu = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulhu
  static function TD _vmulhsu(T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulhsu = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulhsu

  //---------------------------------------------------------------------- 
  // Ch32.11.11. Vector Integer Divide Instructions
  static function TD _vdivu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) / $unsigned(src1);
    _vdivu = (src1 == 0) ? '1 : dest;
  endfunction : _vdivu
  static function TD _vdiv(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) / $signed(src1);
    _vdiv = (src1 == 0) ? '1 : dest;
  endfunction : _vdiv
  static function TD _vremu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) % $unsigned(src1);
    _vremu = (src1 == 0) ? src2 : dest;
  endfunction : _vremu
  static function TD _vrem(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) % $signed(src1);
    _vrem = (src1 == 0) ? src2 : dest;
  endfunction : _vrem

  //---------------------------------------------------------------------- 
  // Ch32.11.12. Vector Widening Integer Multiply Instructions
  static function TD _vwmul(T2 src2, T1 src1);
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    _vwmul = src2_widen * src1_widen;
  endfunction : _vwmul
  static function TD _vwmulu(T2 src2, T1 src1);
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    _vwmulu = src2_widen * src1_widen;
  endfunction : _vwmulu
  static function TD _vwmulsu(T2 src2, T1 src1);
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $unsigned(src1);
    _vwmulsu = src2_widen * src1_widen;
  endfunction : _vwmulsu

  //---------------------------------------------------------------------- 
  // Ch32.11.13. Vector Single-Width Integer Multiply-Add Instructions
  static function TD _vmacc(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vmacc = dest_widen;
  endfunction : _vmacc
  static function TD _vnmsac(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen - src2_widen * src1_widen;
    _vnmsac = dest_widen;
  endfunction : _vnmsac
  static function TD _vmadd(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen + dest_widen * src1_widen;
    _vmadd = dest_widen;
  endfunction : _vmadd
  static function TD _vnmsub(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest_widen;
    logic [$bits(TD)*2-1:0] src2_widen;
    logic [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen - dest_widen * src1_widen;
    _vnmsub = dest_widen;
  endfunction : _vnmsub

  //---------------------------------------------------------------------- 
  // Ch32.11.14. Vector Widening Integer Multiply-Add Instructions
  static function TD _vwmaccu(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)-1:0] dest_widen;
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    dest_widen = $unsigned(dest);
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    _vwmaccu = dest_widen + src2_widen * src1_widen;
  endfunction : _vwmaccu
  static function TD _vwmacc(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)-1:0] dest_widen;
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    _vwmacc = dest_widen + src2_widen * src1_widen;
  endfunction : _vwmacc
  static function TD _vwmaccus(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)-1:0] dest_widen;
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    dest_widen = $unsigned(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    _vwmaccus = dest_widen + src2_widen * src1_widen;
  endfunction : _vwmaccus
  static function TD _vwmaccsu(TD dest, T2 src2, T1 src1);
    logic [$bits(TD)-1:0] dest_widen;
    logic [$bits(TD)-1:0] src2_widen;
    logic [$bits(TD)-1:0] src1_widen;
    dest_widen = $unsigned(dest);
    src2_widen = $unsigned(src2);
    src1_widen = $signed(src1);
    _vwmaccsu = dest_widen + src2_widen * src1_widen;
  endfunction : _vwmaccsu

  //---------------------------------------------------------------------- 
  // Ch32.11.15. Vector Integer Merge Instructions
  // Ch32.11.16. Vector Integer Move Instructions
  static function TD _vmerge(T2 src2, T1 src1, T0 src0);
    _vmerge = src0 ? src1 : src2;
  endfunction : _vmerge

  //---------------------------------------------------------------------- 
  // Ch32.12.1. Vector Single-Width Saturating Add and Subtract
  static function TD _vsaddu(T2 src2, T1 src1);
    {overflow,_vsaddu} = $unsigned(src2) + $unsigned(src1);
    if(overflow) _vsaddu = '1;
  endfunction : _vsaddu
  static function TD _vsadd(T2 src2, T1 src1);
    logic [1:0] cout;
    {cout, _vsadd} = $signed(src2) + $signed(src1);
    overflow  = cout == 2'b01; 
    underflow = cout[1] == 1'b1; 
    if(overflow)  begin _vsadd = '1; _vsadd[$bits(TD)-1] = 1'b0; end
    if(underflow) begin _vsadd = '0; _vsadd[$bits(TD)-1] = 1'b1; end
  endfunction : _vsadd
  static function TD _vssubu(T2 src2, T1 src1);
    {underflow,_vssubu} = $unsigned(src2) - $unsigned(src1);
    if(underflow) _vssubu = '0;
  endfunction : _vssubu
  static function TD _vssub(T2 src2, T1 src1);
    logic [1:0] cout;
    {cout, _vssub} = $signed(src2) - $signed(src1);
    overflow  = cout == 2'b01; 
    underflow = cout[1] == 1'b1; 
    if(overflow)  begin _vssub = '1; _vssub[$bits(TD)-1] = 1'b0; end
    if(underflow) begin _vssub = '0; _vssub[$bits(TD)-1] = 1'b1; end
  endfunction : _vssub

  //---------------------------------------------------------------------- 
  // Ch32.12.2. Vector Single-Width Averaging Add and Subtract
  static function TD _vaaddu(T2 src2, T1 src1);
    _vaaddu = _roundoff_unsigned($unsigned(src2 + src1), 1);
  endfunction : _vaaddu
  static function TD _vaadd(T2 src2, T1 src1);
    _vaadd = _roundoff_signed($signed(src2 + src1), 1);
  endfunction : _vaadd
  // TODO check wraps around
  static function TD _vasubu(T2 src2, T1 src1);
    _vasubu = _roundoff_unsigned($unsigned(src2 - src1), 1);
  endfunction : _vasubu
  static function TD _vasub(T2 src2, T1 src1);
    _vasub = _roundoff_signed($signed(src2 - src1), 1);
  endfunction : _vasub

  //---------------------------------------------------------------------- 
  // Ch32.12.3. Vector Single-Width Fractional Multiply with Rounding and Saturation
  static function TD _vsmul(T2 src2, T1 src1);
    logic [$bits(TD)*2-1:0] dest;
    dest = $signed(src2) * $signed(src1);
    dest = _roundoff_signed($signed(dest), $bits(TD)-1);
    overflow = ^dest[$bits(TD):$bits(TD)-1];
    if(overflow) begin _vsmul = '1; _vsmul[$bits(TD)-1] = 1'b0; end
    else begin _vsmul = dest; end
  endfunction : _vsmul

  //---------------------------------------------------------------------- 
  // Ch32.15.1. Vector Mask-Register Logical Instructions
  static function TD _vmand(T2 src2, T1 src1);
    _vmand = src1 & src2;
  endfunction : _vmand
  static function TD _vmor(T2 src2, T1 src1);
    _vmor = src1 | src2;
  endfunction : _vmor
  static function TD _vmxor(T2 src2, T1 src1);
    _vmxor = src1 ^ src2;
  endfunction : _vmxor
  static function TD _vmorn(T2 src2, T1 src1);
    _vmorn = src1 | ~src2;
  endfunction : _vmorn
  static function TD _vmnand(T2 src2, T1 src1);
    _vmnand = ~(src1 & src2);
  endfunction : _vmnand
  static function TD _vmnor(T2 src2, T1 src1);
    _vmnor = ~(src1 | src2);
  endfunction : _vmnor
  static function TD _vmandn(T2 src2, T1 src1);
    _vmandn = src1 & ~src2;
  endfunction : _vmandn
  static function TD _vmxnor(T2 src2, T1 src1);
    _vmxnor = ~(src1 ^ src2);
  endfunction : _vmxnor
endclass: alu_processor

// LSU inst part ------------------------------------------
virtual class lsu_processor#(
  type TD = sew8_t,
  type T1 = sew8_t,
  type T2 = sew8_t);  

  static function TD exe (rvs_transaction inst_tr, T1 src1, T2 src2); //TODO ref ...
    TD dest;
    // `uvm_info("DEBUG", $sformatf("sizeof(T1)=%0d, sizeof(T2)=%0d, sizeof(TD)=%0d", $size(T1), $size(T2), $size(TD)), UVM_HIGH)
    case(inst_tr.lsu_mop) 
    endcase
    exe = dest;
    // `uvm_info("DEBUG", $sformatf("dest=%0d, src1=%0d, src2=%0d", exe, src1, src2), UVM_HIGH)
  endfunction : exe

endclass: lsu_processor
`endif // RVV_BEHAVIOR_MODEL
