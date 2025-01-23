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
typedef class alu_base;
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
  logic             vxsat_valid;
  xrf_t [31:0] xrf;
  vrf_t [31:0] vrf;
  vrf_t [31:0] vrf_delay;
  vrf_t [31:0] vrf_temp;
  vrf_t [31:0] vrf_bit_strobe_temp;
  vrf_byte_t [31:0] vrf_byte_strobe_temp;

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
      vtype       = '0;
      vl          = '0;
      vstart      = '0;
      vxrm        = RNU;
      vxsat       = '0;
      vxsat_valid = '0;
      for(int i=0; i<32; i++) begin
        vrf[i] = vrf_if.vreg_init_data[i];
        xrf[i] = '0;
      end
      @(posedge rvs_if.clk);
    end
    phase.drop_objection( .obj( this ) );
  endtask: reset_phase

  task rvv_behavior_model::main_phase(uvm_phase phase);
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
    `uvm_info("MDL", "get a inst", UVM_HIGH)
    `uvm_info("MDL", inst_tr.sprint(), UVM_HIGH)
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

    bit is_widen_inst;
    bit is_widen_vs2_inst;
    bit is_narrow_inst;
    bit is_mask_producing_inst;
    bit use_vm_to_cal;

    bit vm;

    int dest_eew; real dest_emul;
    int src0_eew; real src0_emul;
    int src1_eew; real src1_emul;
    int src2_eew; real src2_emul;
    int src3_eew; real src3_emul;
    int dest_reg_idx_base, dest_reg_idx, dest_reg_elm_idx;
    int src0_reg_idx_base, src0_reg_idx, src0_reg_elm_idx;
    int src1_reg_idx_base, src1_reg_idx, src1_reg_elm_idx;
    int src2_reg_idx_base, src2_reg_idx, src2_reg_elm_idx;
    int src3_reg_idx_base, src3_reg_idx, src3_reg_elm_idx;

    logic [31:0] dest;
    logic [31:0] src0;
    logic [31:0] src1;
    logic [31:0] src2;
    logic [31:0] src3;

    logic [`NUM_RT_UOP-1:0] rt_uop;
    logic [`NUM_RT_UOP-1:0] rt_last_uop;
    rvs_transaction inst_tr;
    rvs_transaction rt_tr;

    alu_base alu_handler;
    alu_processor #( sew8_t,  sew8_t,  sew8_t) alu_08_08_08 = new();
    alu_processor #(sew16_t, sew16_t, sew16_t) alu_16_16_16 = new();
    alu_processor #(sew32_t, sew32_t, sew32_t) alu_32_32_32 = new();
    // widen                                                  
    alu_processor #(sew16_t,  sew8_t,  sew8_t) alu_16_08_08 = new();
    alu_processor #(sew16_t, sew16_t,  sew8_t) alu_16_16_08 = new();
    alu_processor #(sew32_t, sew16_t, sew16_t) alu_32_16_16 = new();
    alu_processor #(sew32_t, sew32_t, sew16_t) alu_32_32_16 = new();
    // ext                                                     
    alu_processor #(sew16_t,  sew8_t, sew32_t) alu_16_08_32 = new();
    alu_processor #(sew16_t,  sew8_t, sew16_t) alu_16_08_16 = new();
    alu_processor #(sew32_t, sew16_t, sew32_t) alu_32_16_32 = new();
    alu_processor #(sew32_t, sew16_t,  sew8_t) alu_32_16_08 = new();
    alu_processor #(sew32_t,  sew8_t, sew32_t) alu_32_08_32 = new();
    alu_processor #(sew32_t,  sew8_t, sew16_t) alu_32_08_16 = new();
    alu_processor #(sew32_t,  sew8_t,  sew8_t) alu_32_08_08 = new();
    // narrow                                               
    alu_processor #( sew8_t, sew16_t,  sew8_t) alu_08_16_08 = new();
    alu_processor #(sew16_t, sew32_t, sew16_t) alu_16_32_16 = new();
    // massk logic                                          
    alu_processor #( sew1_t,  sew1_t,  sew1_t) alu_01_01_01 = new();
    alu_processor #( sew1_t,  sew8_t,  sew8_t) alu_01_08_08 = new();
    alu_processor #( sew1_t, sew16_t, sew16_t) alu_01_16_16 = new();
    alu_processor #( sew1_t, sew32_t, sew32_t) alu_01_32_32 = new();
    // viota
    alu_processor #( sew8_t,  sew1_t,  sew1_t) alu_08_01_01 = new();
    alu_processor #(sew16_t,  sew1_t,  sew1_t) alu_16_01_01 = new();
    alu_processor #(sew32_t,  sew1_t,  sew1_t) alu_32_01_01 = new();

    forever begin
      @(posedge rvs_if.clk);
      if(rvs_if.rst_n) begin
      rt_uop = rvs_if.rt_uop;
      rt_last_uop = rvs_if.rt_last_uop;
      while(|rt_last_uop) begin
      if(rt_last_uop[0]) begin
        // --------------------------------------------------
        // 0. Get inst and update VCSR
        if(inst_queue.size()>0) begin
          inst_tr = new("inst_tr");
          inst_tr     = inst_queue.pop_front();
          vtype       = inst_tr.vtype;
          vl          = inst_tr.vl;
          vstart      = inst_tr.vstart;
          vxrm        = inst_tr.vxrm;
          vxsat       = '0;
          vxsat_valid = '0;

          `uvm_info("MDL",$sformatf("Start calculation:\n%s",inst_tr.sprint()),UVM_LOW)
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
        is_widen_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W, 
                                                                              VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCUS, VWMACCSU});
        is_widen_vs2_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VWADD_W, VWADDU_W, VWSUBU_W, VWSUB_W});
        is_narrow_inst = inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP});
        is_mask_producing_inst = inst_tr.inst_type == ALU && ((inst_tr.alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR,
                                                                                       VMADC, VMSBC, 
                                                                                       VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT
                                                                                       }) ||
                                                              (inst_tr.alu_inst inside {VMUNARY0} && inst_tr.src1_idx inside {VMSBF, VMSOF, VMSIF}));
        use_vm_to_cal = inst_tr.use_vm_to_cal;

        // 1.0 illegal inst check
        if(inst_tr.vstart >= inst_tr.vl) begin
          if(inst_tr.dest_type == XRF && inst_tr.vl == 0) begin
          end else begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: ignored since vstart(%0d) >= vl(%0d).", pc, inst_tr.vstart, inst_tr.vl))
            continue;
          end
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_type == OPIVV && inst_tr.alu_inst == VRSUB) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vrsub.vv is ignored.",pc))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_type == OPIVI && (inst_tr.alu_inst inside {VSUB, VMSBC, VSBC, VMINU, VMIN, VMAXU, VMAX})) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: OPIVI of %0s is ignored.",pc,inst_tr.alu_inst.name()))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMERGE_VMVV && inst_tr.vm == 1 && inst_tr.src2_idx != 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: src2_idx != 0 of vmv.v is ignored.",pc))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_type == OPMVV && (inst_tr.alu_inst inside {VWMACCUS})) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: OPMVV of %0s is ignored.",pc,inst_tr.alu_inst.name()))
          continue;
        end
        if(inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VADC, VSBC}) && inst_tr.vm == 1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vm == 1 of %0s is ignored.",pc,inst_tr.alu_inst.name()))
          continue;
        end
        if(inst_tr.inst_type == ALU && (inst_tr.alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) && inst_tr.vm == 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vm == 0 of %0s is ignored.",pc,inst_tr.alu_inst.name()))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VWXUNARY0 && inst_tr.src1_idx inside {VCPOP, VFIRST} && inst_tr.vstart !== 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vstart = %0d of vcpop/vfirst is ignored.", pc, inst_tr.vstart))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMUNARY0 && inst_tr.src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA} && inst_tr.vstart !== 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vstart = %0d of vmsf/vmsof/vmsif/viota is ignored.", pc, inst_tr.vstart))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMUNARY0 && inst_tr.src1_idx inside {VID} && inst_tr.src2_idx !== 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: vs2 = v%0d of vid is ignored.", pc, inst_tr.src2_idx))
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
              end else if(vtype.vlmul == LMUL8) begin
                `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Illegal lmul(%s) for widen instruction. Ignored.",pc,inst_tr.vtype.vlmul.name()));
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
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR}) begin
              dest_eew = EEW1;
              dest_emul = dest_emul * dest_eew / eew;
              src2_eew = EEW1;
              src2_emul = src2_emul * src2_eew / eew;
              src1_eew = EEW1;
              src1_emul = src1_emul * src1_eew / eew;
              // Special case: In this case, DUT will writeback all bits in dest.
              elm_idx_max = `VLEN;
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VMADC, VMSBC, 
                VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT}) begin
              dest_eew = EEW1;
              dest_emul = dest_emul * dest_eew / eew;
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VMUNARY0} && inst_tr.src1_idx inside {VMSBF, VMSOF, VMSIF}) begin
              dest_eew = EEW1;
              dest_emul = dest_emul * dest_eew / eew;
              src2_eew = EEW1;
              src2_emul = src2_emul * src2_eew / eew;
              src1_eew = EEW1;
              src1_emul = src1_emul * src1_eew / eew;
              // Special case: In this case, DUT will writeback all bits in dest.
              elm_idx_max = `VLEN;
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VMUNARY0} && inst_tr.src1_idx inside {VIOTA, VID}) begin
              src2_eew = EEW1;
              src2_emul = src2_emul * src2_eew / eew;
              src1_eew = EEW1;
              src1_emul = src1_emul * src1_eew / eew;
            end
            if(inst_tr.inst_type == ALU && inst_tr.alu_inst inside {VWXUNARY0} && inst_tr.src1_idx inside {VCPOP, VFIRST}) begin
              src2_eew = EEW1;
              src2_emul = src2_emul * src2_eew / eew;
              src1_eew = EEW1;
              src1_emul = src1_emul * src1_eew / eew;
            end
          end
          default: begin
            continue;
          end
        endcase
        // 1.4 dest is xrf
        if(inst_tr.dest_type == XRF) begin
          dest_eew = EEW32;
          dest_emul = dest_emul * dest_eew / eew; // FIXME
        end

        // --------------------------------------------------
        // 2. Prepare oprand
        // 2.1 Update XRF & IMM values
        if(inst_tr.src1_type == XRF) xrf[inst_tr.src1_idx] = inst_tr.rs_data;
        if(inst_tr.src2_type == XRF) xrf[inst_tr.src2_idx] = inst_tr.rs_data;
        if(inst_tr.src1_type == IMM) begin 
          imm_data = $signed(inst_tr.src1_idx);
          `uvm_info("MDL", $sformatf("Got imm_data = 0x%8x(%0d) from rs1",imm_data, $signed(imm_data)), UVM_HIGH)
        end else if (inst_tr.src1_type == UIMM) begin
          imm_data = $unsigned(inst_tr.src1_idx);
          `uvm_info("MDL", $sformatf("Got uimm_data = 0x%8x(%0d) from rs1",imm_data, $unsigned(imm_data)), UVM_HIGH)
        end
        if(inst_tr.src2_type == IMM) begin 
          imm_data = $signed(inst_tr.src2_idx);
          `uvm_info("MDL", $sformatf("Got imm_data = 0x%8x(%0d) from rs2",imm_data, $signed(imm_data)), UVM_HIGH)
        end else if (inst_tr.src2_type == UIMM) begin
          imm_data = $unsigned(inst_tr.src2_idx);
          `uvm_info("MDL", $sformatf("Got uimm_data = 0x%8x(%0d) from rs2",imm_data, $unsigned(imm_data)), UVM_HIGH)
        end
          
        // 2.2 Check VRF index
        dest_reg_idx_base = inst_tr.dest_idx;
        src2_reg_idx_base = inst_tr.src2_idx;
        src1_reg_idx_base = inst_tr.src1_idx;

        // 2.2.1 Alignment Check
        if(inst_tr.dest_type == VRF) begin
          if(dest_reg_idx_base % int'(dest_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.3.4.2. Dest vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc , dest_reg_idx_base, dest_emul));
            continue;
          end
        end
        if(inst_tr.src2_type == VRF) begin
          if(src2_reg_idx_base % int'(src2_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.3. Src2 vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc, src2_reg_idx_base, src2_emul));
            continue;
          end
        end
        if(inst_tr.src1_type == VRF) begin
          if(src1_reg_idx_base % int'(src1_emul)) begin
            `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.3.4.2. Src1 vrf index(%0d) is unaligned to emul(%0d). Ignored.",pc, src1_reg_idx_base, src1_emul));
            continue;
          end
        end

        // 2.2.2 Overlap Check
        if(inst_tr.dest_type == VRF && inst_tr.src2_type == VRF && (dest_eew > src2_eew) && (src2_reg_idx_base >= dest_reg_idx_base) && (src2_reg_idx_base+int'(src2_emul) < dest_reg_idx_base+int'(dest_emul)) && src2_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The lowest part of dest vrf(v%0d~v%0d) overlaps the src2 vrf(v%0d~v%0d) in a widen instruction. Ignored.",pc,
              dest_reg_idx_base, dest_reg_idx_base+int'($floor(dest_emul))-1, src2_reg_idx_base, src2_reg_idx_base+int'($floor(src2_emul))-1));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src2_type == VRF && inst_tr.alu_inst == VXUNARY0 && (src2_reg_idx_base == dest_reg_idx_base) && src2_emul == 0.5 && dest_emul == 2 ) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. vext.vf4 with LMUL2 will spit to 2 uops. The lowest part of dest vrf(v%0d~v%0d) overlaps the src2 vrf(v%0d~v%0d) in a widen instruction. Ignored.",pc,
              dest_reg_idx_base, dest_reg_idx_base+int'($floor(dest_emul))-1, src2_reg_idx_base, src2_reg_idx_base+int'($floor(src2_emul))-1));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src2_type == VRF && (dest_eew < src2_eew) && (dest_reg_idx_base > src2_reg_idx_base) && (dest_reg_idx_base+int'(dest_emul) <= src2_reg_idx_base+int'(src2_emul)) && dest_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src2 vrf(v%0d~v%0d) in a narrow instruction. Ignored.",pc,
              dest_reg_idx_base, dest_reg_idx_base+int'($floor(dest_emul))-1, src2_reg_idx_base, src2_reg_idx_base+int'($floor(src2_emul))-1));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src1_type == VRF && (dest_eew > src1_eew) && (src1_reg_idx_base >= dest_reg_idx_base) && (src1_reg_idx_base+int'(src1_emul) < dest_reg_idx_base+int'(dest_emul)) && src1_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The lower part of dest vrf(v%0d~v%0d) overlaps the src1 vrf(v%0d~v%0d) in a widen instruction. Ignored.",pc,
              dest_reg_idx_base, dest_reg_idx_base+int'($floor(dest_emul))-1, src1_reg_idx_base, src1_reg_idx_base+int'($floor(src1_emul))-1));
          continue;
        end
        if(inst_tr.dest_type == VRF && inst_tr.src1_type == VRF && (dest_eew < src1_eew) && (dest_reg_idx_base > src1_reg_idx_base) && (dest_reg_idx_base+int'(dest_emul) <= src1_reg_idx_base+int'(src1_emul)) && dest_emul>=1) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.2. The dest vrf(v%0d~v%0d) overlaps the highest part of src1 vrf(v%0d~v%0d) in a narrow instruction. Ignored.",pc,
              dest_reg_idx_base, dest_reg_idx_base+int'($floor(dest_emul))-1, src1_reg_idx_base, src1_reg_idx_base+int'($floor(src1_emul))-1));
          continue;
        end
        if(inst_tr.dest_type == VRF && vm == 0 && dest_reg_idx_base == 0 && (dest_eew != EEW1 /*|| TODO scalar result of a reduction*/)) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Ch32.5.3. Dest vrf index(%0d) overlap source mask register v0. Ignored.",pc,dest_reg_idx_base));
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMUNARY0 && inst_tr.src1_idx inside {VMSBF, VMSOF, VMSIF} && dest_reg_idx_base == src2_reg_idx_base) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: In vmsf/vmsof/vmsif, dest vrf(v%0d) can't overlap src2 vrf(v%0d). Ignored.", pc, dest_reg_idx_base, src2_reg_idx_base, inst_tr.vstart))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMUNARY0 && inst_tr.src1_idx inside {VIOTA} && src2_reg_idx_base inside {[dest_reg_idx_base:dest_reg_idx_base+int'($ceil(dest_emul))-1]}) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: In viota, dest vrf(%0d~%0d) can't overlap src2 vrf(%0d). Ignored.", pc, dest_reg_idx_base, dest_reg_idx_base+int'($ceil(dest_emul))-1, src2_reg_idx_base))
          continue;
        end
        if(inst_tr.inst_type == ALU && inst_tr.alu_inst == VMUNARY0 && inst_tr.src1_idx inside {VMSBF, VMSOF, VMSIF, VIOTA} && dest_reg_idx_base == 0 && vm == 0) begin
          `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: In vmsf/vmsof/vmsif/viota, dest vrf(v%0d) can't overlap v0 while vm == 0. Ignored.", pc, dest_reg_idx_base, inst_tr.vstart))
          continue;
        end

        vrf_temp = vrf;
        vrf_bit_strobe_temp = '0;
        `uvm_info("MDL",$sformatf("Prepare done!\nelm_idx_max=%0d\ndest_eew=%0d\nsrc2_eew=%0d\nsrc1_eew=%0d\ndest_emul=%2.4f\nsrc2_emul=%2.4f\nsrc1_emul=%2.4f\n",elm_idx_max,dest_eew,src2_eew,src1_eew,dest_emul,src2_emul,src1_emul),UVM_LOW)
        // --------------------------------------------------
        // 3. Operate elements
        for(int elm_idx=0; elm_idx<elm_idx_max; elm_idx++) begin : op_element

          // 3.0 Update elements index
          if(inst_tr.dest_type == VRF) begin 
            dest_reg_idx = elm_idx / (`VLEN / dest_eew) + dest_reg_idx_base;
            dest_reg_elm_idx = elm_idx % (`VLEN / dest_eew);
          end
          if(inst_tr.src3_type == VRF) begin 
            src3_reg_idx = elm_idx / (`VLEN / src3_eew) + src3_reg_idx_base;
            src3_reg_elm_idx = elm_idx % (`VLEN / src3_eew);
          end
          if(inst_tr.src2_type == VRF) begin 
            src2_reg_idx = elm_idx / (`VLEN / src2_eew) + src2_reg_idx_base;
            src2_reg_elm_idx = elm_idx % (`VLEN / src2_eew);
          end
          if(inst_tr.src1_type == VRF) begin 
            src1_reg_idx = elm_idx / (`VLEN / src1_eew) + src1_reg_idx_base;
            src1_reg_elm_idx = elm_idx % (`VLEN / src1_eew);
          end
            src0_reg_idx = 0;
            src0_reg_elm_idx = elm_idx % (`VLEN / src0_eew);

          // 3.1 Fetch elements data 
          dest = elm_fetch(inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
          src3 = elm_fetch(inst_tr.src3_type, src3_reg_idx_base, elm_idx, src3_eew); 
          src2 = elm_fetch(inst_tr.src2_type, src2_reg_idx_base, elm_idx, src2_eew); 
          src1 = elm_fetch(inst_tr.src1_type, src1_reg_idx_base, elm_idx, src1_eew); 
          if(vm == 0) begin
            src0 = elm_fetch(VRF, 0, elm_idx, src0_eew);
          end else begin
            if(inst_tr.alu_inst inside {VMERGE_VMVV})
              src0 = '1;
            if(inst_tr.alu_inst inside {VMADC, VMSBC})
              src0 = '0;
          end
          
          `uvm_info("MDL", "\n---------------------------------------------------------------------------------------------------------------------------------\n", UVM_LOW)
          `uvm_info("MDL", $sformatf("Before - element[%2d]:\n  dest(v[%2d][%2d])=0x%8h\n  src2(v[%2d][%2d])=0x%8h\n  src1(v[%2d][%2d])=0x%8h\n  src0(v[%2d][%2d])=0x%8h",
                                      elm_idx, 
                                      dest_reg_idx, dest_reg_elm_idx, dest, 
                                      src2_reg_idx, src2_reg_elm_idx, src2, 
                                      src1_reg_idx, src1_reg_elm_idx, src1, 
                                      src0_reg_idx, src0_reg_elm_idx, src0), UVM_LOW)

          // 3.2 Execute & Writeback 
          // Prepare processor handler
          case(inst_tr.inst_type)
            LD: begin 
              `uvm_fatal(get_type_name(),"Load fucntion hasn't been defined.")
            end

            ST: begin 
              `uvm_fatal(get_type_name(),"Store fucntion hasn't been defined.")
            end
            ALU: begin 
              case({dest_eew, src2_eew, src1_eew})
                { EEW8,  EEW8,  EEW8}: alu_handler = alu_08_08_08;
                {EEW16, EEW16, EEW16}: alu_handler = alu_16_16_16;
                {EEW32, EEW32, EEW32}: alu_handler = alu_32_32_32;
                // widen
                {EEW16,  EEW8,  EEW8}: alu_handler = alu_16_08_08;
                {EEW16, EEW16,  EEW8}: alu_handler = alu_16_16_08;
                {EEW32, EEW16, EEW16}: alu_handler = alu_32_16_16;
                {EEW32, EEW32, EEW16}: alu_handler = alu_32_32_16;
                //ext
                {EEW16,  EEW8, EEW32}: alu_handler = alu_16_08_32;
                {EEW16,  EEW8, EEW16}: alu_handler = alu_16_08_16;
                {EEW32, EEW16, EEW32}: alu_handler = alu_32_16_32;
                {EEW32, EEW16,  EEW8}: alu_handler = alu_32_16_08;
                {EEW32,  EEW8, EEW32}: alu_handler = alu_32_08_32;
                {EEW32,  EEW8, EEW16}: alu_handler = alu_32_08_16;
                {EEW32,  EEW8,  EEW8}: alu_handler = alu_32_08_08;
                // narrow
                { EEW8, EEW16,  EEW8}: alu_handler = alu_08_16_08;
                {EEW16, EEW32, EEW16}: alu_handler = alu_16_32_16;
                // mask logic
                { EEW1,  EEW1,  EEW1}: alu_handler = alu_01_01_01;
                { EEW1,  EEW8,  EEW8}: alu_handler = alu_01_08_08;
                { EEW1, EEW16, EEW16}: alu_handler = alu_01_16_16;
                { EEW1, EEW32, EEW32}: alu_handler = alu_01_32_32;
                // viot/vfirst/...
                { EEW8,  EEW1,  EEW1}: alu_handler = alu_08_01_01;
                {EEW16,  EEW1,  EEW1}: alu_handler = alu_16_01_01;
                {EEW32,  EEW1,  EEW1}: alu_handler = alu_32_01_01;
                default: begin
                  `uvm_error(get_type_name(), $sformatf("Unsupported EEW: dest_eew=%d, src2_eew=%d, src1_eew=%d", dest_eew, src2_eew, src1_eew))
                  continue;
                end
              endcase
              if(elm_idx == 0) begin
                alu_handler.reset();
              end
              alu_handler.set_vxrm(vxrm);
              alu_handler.set_elm_idx(elm_idx);
            end
          endcase

          if(elm_idx < vstart) begin
            // pre-start: do nothing
            if(is_mask_producing_inst) begin
              //  If is mask producing operation, it will keep original values.
              `uvm_info("MDL", $sformatf("element[%2d]: pre-start, mask producing operation", elm_idx), UVM_LOW)
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
            end else begin 
              `uvm_info("MDL", $sformatf("element[%2d]: pre-start", elm_idx), UVM_LOW)
            end
          end else if(elm_idx >= vl) begin
            // tail 
            if(is_mask_producing_inst) begin
              //  If is mask producing operation, it will write with calculation results.
              `uvm_info("MDL", $sformatf("element[%2d]: tail, mask producing operation", elm_idx), UVM_LOW)
              if((!vm && this.vrf[0][elm_idx]) || vm) begin
                dest = alu_handler.exe(inst_tr, dest, src2, src1, src0);
              end
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
            end else begin 
              `uvm_info("MDL", $sformatf("element[%2d]: tail", elm_idx), UVM_LOW)
              if(vtype.vta == AGNOSTIC) begin
                if(all_one_for_agn) begin 
                  dest = '1;
                  elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
                end
              end else begin
              end
            end
          end else if(!(vm || this.vrf[0][elm_idx] || use_vm_to_cal)) begin
            // body-inactive
            if(is_mask_producing_inst) begin
              `uvm_info("MDL", $sformatf("element[%2d]: body-inactive, mask producing operation", elm_idx), UVM_LOW)
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
            end else begin
              `uvm_info("MDL", $sformatf("element[%2d]: body-inactive", elm_idx), UVM_LOW)
              if(vtype.vma == AGNOSTIC) begin
                if(all_one_for_agn) begin 
                  dest = '1;
                  elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
                end
              end else begin
              end
            end
          end else begin
            // body-active
            `uvm_info("MDL", $sformatf("element[%2d]: body-active", elm_idx), UVM_LOW)
            // EX
            case(inst_tr.inst_type)
              LD: begin `uvm_fatal(get_type_name(),"Load fucntion hasn't been defined.") end
              ST: begin `uvm_fatal(get_type_name(),"Store fucntion hasn't been defined.") end
              ALU: begin 
                dest = alu_handler.exe(inst_tr, dest, src2, src1, src0);
                vxsat = vxsat ? vxsat : alu_handler.get_saturate();

                elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
              end
            endcase
            // Write back
          end

          // Special case : Get the final value to wireback to XRF, avoiding all inactive situation. 
          if(elm_idx == vl) begin
            if(inst_tr.dest_type == XRF) begin
              $display("Im here...");
              dest = alu_handler.get_xrf_wb_value(inst_tr);
              elm_writeback(dest, inst_tr.dest_type, dest_reg_idx_base, elm_idx, dest_eew);
            end
          end

          `uvm_info("MDL", $sformatf("After - element[%2d]:\n  dest(v[%2d][%2d])=0x%8h\n  src2(v[%2d][%2d])=0x%8h\n  src1(v[%2d][%2d])=0x%8h\n  src0(v[%2d][%2d])=0x%8h",
                                      elm_idx, 
                                      dest_reg_idx, dest_reg_elm_idx, dest, 
                                      src2_reg_idx, src2_reg_elm_idx, src2, 
                                      src1_reg_idx, src1_reg_elm_idx, src1, 
                                      src0_reg_idx, src0_reg_elm_idx, src0), UVM_LOW)
          `uvm_info("MDL", "\n---------------------------------------------------------------------------------------------------------------------------------\n", UVM_LOW)
        end : op_element

        // Writeback whole vrf
        vrf = vrf_temp;
        for(int i=0; i<32; i++) begin
          for(int j=0; j<`VLENB; j++) begin
            vrf_byte_strobe_temp[i][j] = |vrf_bit_strobe_temp[i][j*8 +: 8];
          end
        end
        // --------------------------------------------------
        // 4. Retire transaction gen
        rt_tr   = new("rt_tr");
        rt_tr.copy(inst_tr);
        rt_tr.is_rt = 1;
        // VRF
        // if(rt_tr.dest_type == VRF && !(|vrf_bit_strobe_temp)) begin
        //   `uvm_warning("MDL/INST_CHECKER", $sformatf("pc=0x%8x: Instruction with no valid vrf wirte strobe will be ignored.",pc));
        //   continue;
        // end
        if(rt_tr.dest_type == VRF) begin
          for(int reg_idx=dest_reg_idx_base; reg_idx<dest_reg_idx_base+int'($ceil(dest_emul)); reg_idx++) begin
            // FIXME: All 0s in vrf wirte strobe will not be executed in DUT.
            // if(|vrf_byte_strobe_temp[reg_idx]) begin
            // All pre-start vreg will not be retired
            if((reg_idx - dest_reg_idx_base) >= (vstart / (`VLEN / dest_eew))) begin
              rt_tr.rt_vrf_index.push_back(reg_idx);
              rt_tr.rt_vrf_strobe.push_back(vrf_byte_strobe_temp[reg_idx]);
              rt_tr.rt_vrf_data.push_back(vrf_temp[reg_idx]);
            end
          end
        end
        // XRF
        if(rt_tr.dest_type == XRF) begin
          rt_tr.rt_xrf_index.push_back(rt_tr.dest_idx);
          rt_tr.rt_xrf_data.push_back(this.xrf[rt_tr.dest_idx]);
        end
        // VXSAT
        vxsat_valid = vxsat;
        rt_tr.vxsat = vxsat;
        rt_tr.vxsat_valid = vxsat_valid;

        `uvm_info("MDL",$sformatf("Complete calculation:\n%s",rt_tr.sprint()),UVM_LOW)
        rt_ap.write(rt_tr);
      end // if(rt_last_uop[0])
        rt_last_uop = rt_last_uop >> 1;
      end // while(|rt_last_uop)
      end // rst_n
    end // forever
    // `uvm_fatal(get_type_name()),"Im here.")
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
        // `uvm_info("MDL", $sformatf("reg_type=%0d, reg_idx=%0d, elm_idx=%0d, eew=%0d", reg_type, reg_idx, elm_idx, eew), UVM_HIGH)
        for(int i=0; i<bit_count; i++) begin
          result[i] = this.vrf[reg_idx][elm_idx*bit_count + i];
          // `uvm_info("MDL", $sformatf("elm_idx*bit_count + i=%0d", elm_idx*bit_count + i), UVM_HIGH)
          // `uvm_info("MDL", $sformatf("result[%0d]=%0d", i, result[i]), UVM_HIGH)
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
    // `uvm_info("MDL", $sformatf("result=%0h", result), UVM_HIGH)
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
          this.vrf_bit_strobe_temp[reg_idx][elm_idx*bit_count + i] = 1'b1;
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
      @(posedge vrf_if.clk);
      if(vrf_if.rst_n) begin
        if(|vrf_if.rt_last_uop && ((vrf_if.rt_last_uop ^ vrf_if.rt_uop) inside {4'b0000,4'b0001,4'b0011,4'b0111,4'b1111})) begin
          for(int i=0; i<32; i++) begin
              tr.vreg[i] = vrf_delay[i];
          end
          vrf_ap.write(tr);
        end
      end
      vrf_delay <= vrf;
    end
  endtask

// ALU inst part ------------------------------------------
virtual class alu_base; 
  parameter ALU_MAX_WIDTH = `VLEN;

  typedef logic unsigned [ALU_MAX_WIDTH-1:0] alu_unsigned_t;
  typedef logic signed   [ALU_MAX_WIDTH-1:0] alu_signed_t;
  
  // Config signals.
  vxrm_e vxrm;
  int elm_idx;

  // Status signals.
  bit overflow;
  bit underflow;
  int mask_count;
  bit found_first_mask;
  int first_mask_idx;
  pure virtual function alu_unsigned_t exe (rvs_transaction inst_tr, alu_unsigned_t dest, alu_unsigned_t src2, alu_unsigned_t src1, alu_unsigned_t src0);
  pure virtual function alu_unsigned_t _roundoff_unsigned(alu_unsigned_t v, int unsigned d);
  pure virtual function alu_signed_t   _roundoff_signed(  alu_signed_t   v, int unsigned d);
  virtual function void reset();
    this.overflow = 1'b0;
    this.underflow = 1'b0;
    this.mask_count = 'b0;
    this.found_first_mask = 1'b0;
    this.first_mask_idx =  -'d1;
  endfunction: reset
  virtual function void set_vxrm(vxrm_e val);
    this.vxrm = val;
  endfunction: set_vxrm
  virtual function void set_elm_idx(int val);
    this.elm_idx = val;
  endfunction: set_elm_idx
  virtual function bit get_saturate();
    get_saturate = this.overflow || this.underflow;
  endfunction: get_saturate
  virtual function int get_xrf_wb_value(rvs_transaction inst_tr);
  endfunction: get_xrf_wb_value

endclass: alu_base

class alu_processor#(
  type TD = sew8_t,
  type T2 = sew8_t,
  type T1 = sew8_t,  
  type T0 = sew1_t
  ) extends alu_base;  
  
//   virtual void function reset();
//     super.reset();
//   endfunction: reset
//   virtual function void set_vxrm(vxrm_e val);
//     super.set_vxrm(vxrm_e val);
//   endfunction: set_vxrm
//   virtual function void set_elm_idx(int val);
//     super.set_elm_idx(int val);
//   endfunction: set_elm_idx
//   virtual function bit get_saturate();
//     super.get_saturate();
//   endfunction: get_saturate

  virtual function int get_xrf_wb_value(rvs_transaction inst_tr);
    super.get_xrf_wb_value(inst_tr);
    case(inst_tr.alu_inst)
      VWXUNARY0: begin
        case(inst_tr.src1_idx)
          VMV_X_S: begin
            `uvm_fatal("TB_ISSUE", "VMV_X_S should be executed in permutation processor.")
          end
          VCPOP : get_xrf_wb_value = mask_count;
          VFIRST: get_xrf_wb_value = first_mask_idx;
        endcase
      end
    endcase
  endfunction: get_xrf_wb_value

  virtual function alu_unsigned_t exe (rvs_transaction inst_tr, alu_unsigned_t dest, alu_unsigned_t src2, alu_unsigned_t src1, alu_unsigned_t src0);
    `uvm_info("MDL", $sformatf("sizeof(T1)=%0d, sizeof(T2)=%0d, sizeof(TD)=%0d", $size(T1), $size(T2), $size(TD)), UVM_HIGH)
    overflow  = 0;
    underflow = 0;
    case(inst_tr.alu_inst) 
    // OPI
      VADD : dest = _vadd(src2, src1); 
      VSUB : dest = _vsub(src2, src1); 
      VRSUB: dest = _vrsub(src2, src1); 
  
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

      VSMUL_VMVNRR: begin
        // if(inst_tr.alu_type == OPIVI) dest = _vvmnrr(src2,src1);
        if(inst_tr.alu_type != OPIVI) dest = _vsmul(src2,src1);
      end
      
      VSSRL: dest = _vssrl(src2, src1);
      VSSRA: dest = _vssra(src2, src1);

      VNCLIPU: dest = _vnclipu(src2, src1);
      VNCLIP : dest = _vnclip(src2, src1);
    // OPM
      VWADD,
      VWADD_W:  dest = _vwadd(src2, src1);
      VWADDU,
      VWADDU_W: dest = _vwaddu(src2, src1); 
      VWSUB, 
      VWSUB_W:  dest = _vwsub(src2, src1);
      VWSUBU, 
      VWSUBU_W: dest = _vwsubu(src2, src1); 

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

      VMUNARY0: begin
        case(inst_tr.src1_idx)
          VMSBF: dest = _vmsbf(src2);
          VMSOF: dest = _vmsof(src2);
          VMSIF: dest = _vmsif(src2);
          VIOTA: dest = _viota(src2);
          VID:   dest = _vid();
        endcase
      end

      VWXUNARY0: begin
        case(inst_tr.src1_idx)
          VMV_X_S: begin
            `uvm_fatal("TB_ISSUE", "VMV_X_S should be executed in permutation processor.")
          end
          VCPOP: dest = _vcpop(src2);
          VFIRST: dest = _vfirst(src2);
        endcase
      end
    endcase
    exe = dest;
    // `uvm_info("MDL", $sformatf("dest=%0d, src1=%0d, src2=%0d", exe, src1, src2), UVM_HIGH)
  endfunction : exe

  virtual function alu_unsigned_t _roundoff_unsigned(alu_unsigned_t v, int unsigned d);
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
    `uvm_info("MDL",$sformatf("_roundoff_unsigned: dest=0x%0x,v=0x%0x,d=0x%0x,r=0x%0x",_roundoff_unsigned,v,d,r),UVM_HIGH)
  endfunction: _roundoff_unsigned

  virtual function alu_signed_t   _roundoff_signed(  alu_signed_t   v, int unsigned d);
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
    `uvm_info("MDL",$sformatf("_roundoff_signed: dest=0x%0x,v=0x%0x,d=0x%0x,r=0x%0x",_roundoff_signed,v,d,r),UVM_HIGH)
  endfunction: _roundoff_signed

  //---------------------------------------------------------------------- 
  // 31.11.1. Vector Single-Width Integer Add and Subtract
  function TD _vadd(T2 src2, T1 src1);
    _vadd = src2 + src1;
  endfunction : _vadd
  function TD _vsub(T2 src2, T1 src1);
    _vsub = src2 - src1;
  endfunction : _vsub
  function TD _vrsub(T2 src2, T1 src1);
    _vrsub = src1 - src2;
  endfunction : _vrsub

  //---------------------------------------------------------------------- 
  // 31.11.2. Vector Widening Integer Add/Subtract
  function TD _vwadd(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) + $signed(src1);
    _vwadd = dest;
  endfunction : _vwadd
  function TD _vwaddu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) + $unsigned(src1);
    _vwaddu = dest;
  endfunction : _vwaddu
  function TD _vwsub(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) - $signed(src1);
    _vwsub = dest;
  endfunction : _vwsub
  function TD _vwsubu(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) - $unsigned(src1);
    _vwsubu = dest;
  endfunction : _vwsubu

  //---------------------------------------------------------------------- 
  // 31.11.3. Vector Integer Extension
  function TD _vzext(T2 src2);
    logic signed [$bits(TD)-1:0] dest;
    dest = $unsigned(src2);
    _vzext = dest;
  endfunction : _vzext
  function TD _vsext(T2 src2);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $signed(src2);
    _vsext = dest;
  endfunction : _vsext

  //---------------------------------------------------------------------- 
  // 31.11.4. Vector Integer Add-with-Carry / Subtract-with-Borrow Instructions
  function TD _vadc(T2 src2, T1 src1, T0 src0);
    _vadc = src2 + src1 + src0;
  endfunction : _vadc
  function TD _vmadc(T2 src2, T1 src1, T0 src0);
    logic [$bits(TD):0] dest;
    dest = src2 + src1 + src0;
    _vmadc = dest[$bits(TD)];
  endfunction : _vmadc
  function TD _vsbc(T2 src2, T1 src1, T0 src0);
    _vsbc = src2 - src1 - src0;
  endfunction : _vsbc
  function TD _vmsbc(T2 src2, T1 src1, T0 src0);
    logic [$bits(TD):0] dest;
    dest = src2 - src1 - src0;
    _vmsbc = dest[$bits(TD)];
  endfunction : _vmsbc

  //---------------------------------------------------------------------- 
  // 31.11.5. Vector Bitwise Logical Instructions
  // Reuse mask bit logic part.


  function TD _vminu(T2 src2, T1 src1);
    _vminu = $unsigned(src2) > $unsigned(src1) ? $unsigned(src1) : $unsigned(src2);
  endfunction : _vminu
  function TD _vmin(T2 src2, T1 src1);
    _vmin = $signed(src2) > $signed(src1) ? $signed(src1) : $signed(src2);
  endfunction : _vmin
  function TD _vmaxu(T2 src2, T1 src1);
    _vmaxu = $unsigned(src2) > $unsigned(src1) ? $unsigned(src2) : $unsigned(src1);
  endfunction : _vmaxu
  function TD _vmax(T2 src2, T1 src1);
    _vmax = $signed(src2) > $signed(src1) ? $signed(src2) : $signed(src1);
  endfunction : _vmax

  //---------------------------------------------------------------------- 
  // 31.11.6. Vector Single-Width Shift Instructions
  // 31.11.7. Vector Narrowing Integer Right Shift Instructions
  function TD _vsll(T2 src2, T1 src1);
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsll = $unsigned(src2) << shift_amount;
  endfunction : _vsll
  function TD _vsrl(T2 src2, T1 src1);
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsrl = $unsigned(src2) >> shift_amount;
  endfunction : _vsrl
  function TD _vsra(T2 src2, T1 src1);
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = src1;
    _vsra = $signed(src2) >>> shift_amount;
  endfunction : _vsra

  //---------------------------------------------------------------------- 
  // 31.11.8. Vector Integer Compare Instructions
  function TD _vmseq(T2 src2, T1 src1);
    _vmseq = (src2 === src1);
  endfunction : _vmseq
  function TD _vmsne(T2 src2, T1 src1);
    _vmsne = (src2 !== src1);
  endfunction : _vmsne
  function TD _vmsltu(T2 src2, T1 src1);
    _vmsltu = $unsigned(src2) < $unsigned(src1);
  endfunction : _vmsltu
  function TD _vmslt(T2 src2, T1 src1);
    _vmslt = $signed(src2) < $signed(src1);
  endfunction : _vmslt
  function TD _vmsleu(T2 src2, T1 src1);
    _vmsleu = $unsigned(src2) <= $unsigned(src1);
  endfunction : _vmsleu
  function TD _vmsle(T2 src2, T1 src1);
    _vmsle = $signed(src2) <= $signed(src1);
  endfunction : _vmsle
  function TD _vmsgtu(T2 src2, T1 src1);
    _vmsgtu = $unsigned(src2) > $unsigned(src1);
  endfunction : _vmsgtu
  function TD _vmsgt(T2 src2, T1 src1);
    _vmsgt = $signed(src2) > $signed(src1);
  endfunction : _vmsgt

  //---------------------------------------------------------------------- 
  // Ch31.11.10. Vector Single-Width Integer Multiply Instructions
  function TD _vmul(T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen * src1_widen;
    _vmul = dest_widen[$bits(TD)-1:0];
  endfunction : _vmul
  function TD _vmulh(T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulh = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulh
  function TD _vmulhu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)*2-1:0] dest_widen;
    logic unsigned [$bits(TD)*2-1:0] src2_widen;
    logic unsigned [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulhu = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulhu
  function TD _vmulhsu(T2 src2, T1 src1);
    logic signed   [$bits(TD)*2-1:0] dest_widen;
    logic signed   [$bits(TD)*2-1:0] src2_widen;
    logic unsigned [$bits(TD)*2-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vmulhsu = dest_widen[$bits(TD)*2-1:$bits(TD)];
  endfunction : _vmulhsu

  //---------------------------------------------------------------------- 
  // Ch31.11.11. Vector Integer Divide Instructions
  function TD _vdivu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) / $unsigned(src1);
    _vdivu = (src1 == 0) ? '1 : dest;
  endfunction : _vdivu
  function TD _vdiv(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) / $signed(src1);
    _vdiv = (src1 == 0) ? '1 : dest;
  endfunction : _vdiv
  function TD _vremu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest;
    dest = $unsigned(src2) % $unsigned(src1);
    _vremu = (src1 == 0) ? src2 : dest;
  endfunction : _vremu
  function TD _vrem(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest;
    dest = $signed(src2) % $signed(src1);
    _vrem = (src1 == 0) ? src2 : dest;
  endfunction : _vrem

  //---------------------------------------------------------------------- 
  // Ch32.11.12. Vector Widening Integer Multiply Instructions
  function TD _vwmul(T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest_widen;
    logic signed [$bits(TD)-1:0] src2_widen;
    logic signed [$bits(TD)-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen * src1_widen;
    _vwmul = dest_widen;
  endfunction : _vwmul
  function TD _vwmulu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest_widen;
    logic unsigned [$bits(TD)-1:0] src2_widen;
    logic unsigned [$bits(TD)-1:0] src1_widen;
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vwmulu = dest_widen;
  endfunction : _vwmulu
  function TD _vwmulsu(T2 src2, T1 src1);
    logic signed   [$bits(TD)-1:0] dest_widen;
    logic signed   [$bits(TD)-1:0] src2_widen;
    logic unsigned [$bits(TD)-1:0] src1_widen;
    src2_widen = $signed(src2);
    src1_widen = $unsigned(src1);
    dest_widen = src2_widen * src1_widen;
    _vwmulsu = dest_widen;
  endfunction : _vwmulsu

  //---------------------------------------------------------------------- 
  // Ch31.11.13. Vector Single-Width Integer Multiply-Add Instructions
  function TD _vmacc(TD dest, T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vmacc = dest_widen;
  endfunction : _vmacc
  function TD _vnmsac(TD dest, T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen - src2_widen * src1_widen;
    _vnmsac = dest_widen;
  endfunction : _vnmsac
  function TD _vmadd(TD dest, T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen + dest_widen * src1_widen;
    _vmadd = dest_widen;
  endfunction : _vmadd
  function TD _vnmsub(TD dest, T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest_widen;
    logic signed [$bits(TD)*2-1:0] src2_widen;
    logic signed [$bits(TD)*2-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = src2_widen - dest_widen * src1_widen;
    _vnmsub = dest_widen;
  endfunction : _vnmsub

  //---------------------------------------------------------------------- 
  // Ch31.11.14. Vector Widening Integer Multiply-Add Instructions
  function TD _vwmaccu(TD dest, T2 src2, T1 src1);
    logic unsigned [$bits(TD)-1:0] dest_widen;
    logic unsigned [$bits(TD)-1:0] src2_widen;
    logic unsigned [$bits(TD)-1:0] src1_widen;
    dest_widen = $unsigned(dest);
    src2_widen = $unsigned(src2);
    src1_widen = $unsigned(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vwmaccu = dest_widen;
  endfunction : _vwmaccu
  function TD _vwmacc(TD dest, T2 src2, T1 src1);
    logic signed [$bits(TD)-1:0] dest_widen;
    logic signed [$bits(TD)-1:0] src2_widen;
    logic signed [$bits(TD)-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vwmacc = dest_widen;
  endfunction : _vwmacc
  function TD _vwmaccus(TD dest, T2 src2, T1 src1);
    logic signed   [$bits(TD)-1:0] dest_widen;
    logic signed   [$bits(TD)-1:0] src2_widen;
    logic unsigned [$bits(TD)-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $signed(src2);
    src1_widen = $unsigned(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vwmaccus = dest_widen;
  endfunction : _vwmaccus
  function TD _vwmaccsu(TD dest, T2 src2, T1 src1);
    logic signed   [$bits(TD)-1:0] dest_widen;
    logic unsigned [$bits(TD)-1:0] src2_widen;
    logic signed   [$bits(TD)-1:0] src1_widen;
    dest_widen = $signed(dest);
    src2_widen = $unsigned(src2);
    src1_widen = $signed(src1);
    dest_widen = dest_widen + src2_widen * src1_widen;
    _vwmaccsu = dest_widen;
  endfunction : _vwmaccsu

  //---------------------------------------------------------------------- 
  // Ch31.11.15. Vector Integer Merge Instructions
  // Ch31.11.16. Vector Integer Move Instructions
  function TD _vmerge(T2 src2, T1 src1, T0 src0);
    _vmerge = src0 ? src1 : src2;
  endfunction : _vmerge

  //---------------------------------------------------------------------- 
  // Ch31.12.1. Vector Single-Width Saturating Add and Subtract
  function TD _vsaddu(T2 src2, T1 src1);
    {overflow,_vsaddu} = $unsigned(src2) + $unsigned(src1);
    if(overflow) _vsaddu = '1;
  endfunction : _vsaddu
  function TD _vsadd(T2 src2, T1 src1);
    logic signed [$bits(TD):0] dest;
    dest = $signed(src2) + $signed(src1);
    // overflow  = dest[$bits(TD)-1] & ~src2[$bits(T2)-1] & ~src1[$bits(T1)-1]; 
    // underflow = ~dest[$bits(TD)-1] & src2[$bits(T2)-1] & src1[$bits(T1)-1]; 
    overflow  = dest[$bits(TD):$bits(TD)-1] == 2'b01;
    underflow = dest[$bits(TD):$bits(TD)-1] == 2'b10;
    if(overflow)  begin _vsadd = '1; _vsadd[$bits(TD)-1] = 1'b0; end
    else if(underflow) begin _vsadd = '0; _vsadd[$bits(TD)-1] = 1'b1; end
    else begin _vsadd = dest; end
  endfunction : _vsadd
  function TD _vssubu(T2 src2, T1 src1);
    {underflow,_vssubu} = $unsigned(src2) - $unsigned(src1);
    if(underflow) _vssubu = '0;
  endfunction : _vssubu
  function TD _vssub(T2 src2, T1 src1);
    logic signed [$bits(TD):0] dest;
    dest = $signed(src2) - $signed(src1);
    // overflow = dest[$bits(TD)-1] & ~src2[$bits(T2)-1] & src1[$bits(T1)-1]; 
    // underflow  = ~dest[$bits(TD)-1] & src2[$bits(T2)-1] & ~src1[$bits(T1)-1]; 
    overflow  = dest[$bits(TD):$bits(TD)-1] == 2'b01;
    underflow = dest[$bits(TD):$bits(TD)-1] == 2'b10;
    if(overflow)  begin _vssub = '1; _vssub[$bits(TD)-1] = 1'b0; end
    else if(underflow) begin _vssub = '0; _vssub[$bits(TD)-1] = 1'b1; end
    else begin _vssub = dest; end
  endfunction : _vssub

  //---------------------------------------------------------------------- 
  // Ch31.12.2. Vector Single-Width Averaging Add and Subtract
  function TD _vaaddu(T2 src2, T1 src1);
    logic unsigned [$bits(TD):0] dest;
    dest = $unsigned(src2) + $unsigned(src1);
    _vaaddu = _roundoff_unsigned(dest, 1);
  endfunction : _vaaddu
  function TD _vaadd(T2 src2, T1 src1);
    logic signed [$bits(TD):0] dest;
    dest = $signed(src2) + $signed(src1);
    _vaadd = _roundoff_signed(dest, 1);
  endfunction : _vaadd
  function TD _vasubu(T2 src2, T1 src1);
    logic unsigned [$bits(TD):0] dest;
    dest = $unsigned(src2) - $unsigned(src1);
    _vasubu = _roundoff_unsigned(dest, 1);
  endfunction : _vasubu
  function TD _vasub(T2 src2, T1 src1);
    logic signed [$bits(TD):0] dest;
    dest = $signed(src2) - $signed(src1);
    _vasub = _roundoff_signed(dest, 1);
  endfunction : _vasub

  //---------------------------------------------------------------------- 
  // Ch31.12.3. Vector Single-Width Fractional Multiply with Rounding and Saturation
  function TD _vsmul(T2 src2, T1 src1);
    logic signed [$bits(TD)*2-1:0] dest;
    dest = $signed(src2) * $signed(src1);
    dest = _roundoff_signed(dest, $bits(TD)-1);
    overflow  = dest[$bits(TD):$bits(TD)-1] == 2'b01;
    underflow = dest[$bits(TD):$bits(TD)-1] == 2'b10;
    if(overflow) begin _vsmul = '1; _vsmul[$bits(TD)-1] = 1'b0; end
    else if(underflow) begin _vsmul = '0; _vsmul[$bits(TD)-1] = 1'b1; end
    else begin _vsmul = dest; end
  endfunction : _vsmul

  //---------------------------------------------------------------------- 
  // Ch31.12.4. Vector Single-Width Scaling Shift Instructions
  function TD _vssrl(T2 src2, T1 src1);
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = $unsigned(src1);
    _vssrl = _roundoff_unsigned($unsigned(src2), shift_amount);
  endfunction : _vssrl
  function TD _vssra(T2 src2, T1 src1);
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = $unsigned(src1);
    _vssra = _roundoff_signed($signed(src2), shift_amount);
  endfunction : _vssra

  //---------------------------------------------------------------------- 
  // Ch31.12.5 Vector Narrowing Fixed-Point Clip Instructions
  function TD _vnclipu(T2 src2, T1 src1);
    logic unsigned [$bits(TD)*2-1:0] dest_widen;
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = $unsigned(src1);
    dest_widen = _roundoff_unsigned($unsigned(src2), shift_amount);
    `uvm_info("MDL",$sformatf("dest_widen(%0dbits) = 0x%x",$bits(dest_widen),dest_widen),UVM_HIGH)
    overflow = |dest_widen[$bits(TD)*2-1:$bits(TD)];
    `uvm_info("MDL",$sformatf("overflow = %0d",overflow),UVM_HIGH)
    if(overflow) begin _vnclipu = '1; end
    else begin _vnclipu = dest_widen; end
  endfunction
  function TD _vnclip(T2 src2, T1 src1);
    logic signed [$bits(TD)*2:0] dest_widen;
    logic unsigned [$clog2($bits(T2))-1:0] shift_amount;
    shift_amount = $unsigned(src1);
    dest_widen = _roundoff_signed($signed(src2), shift_amount);
    `uvm_info("MDL",$sformatf("dest_widen(%0dbits) = 0x%x",$bits(dest_widen),dest_widen),UVM_HIGH)
    underflow =  dest_widen[$bits(TD)*2] && (~(&dest_widen[$bits(_vnclip)*2-1:$bits(TD)]));
    overflow  = ~dest_widen[$bits(TD)*2] && |dest_widen[$bits(_vnclip)*2-1:$bits(TD)];
    if(overflow)  begin _vnclip = '1; _vnclip[$bits(TD)-1] = 1'b0; end
    else if(underflow) begin _vnclip = '0; _vnclip[$bits(TD)-1] = 1'b1; end
    else begin _vnclip = dest_widen; end
  endfunction

  //---------------------------------------------------------------------- 
  // Ch31.15.1. Vector Mask-Register Logical Instructions
  function TD _vmand(T2 src2, T1 src1);
    _vmand = src2 & src1;
  endfunction : _vmand
  function TD _vmor(T2 src2, T1 src1);
    _vmor = src2 | src1;
  endfunction : _vmor
  function TD _vmxor(T2 src2, T1 src1);
    _vmxor = src2 ^ src1;
  endfunction : _vmxor
  function TD _vmorn(T2 src2, T1 src1);
    _vmorn = src2 | ~src1;
  endfunction : _vmorn
  function TD _vmnand(T2 src2, T1 src1);
    _vmnand = ~(src2 & src1);
  endfunction : _vmnand
  function TD _vmnor(T2 src2, T1 src1);
    _vmnor = ~(src2 | src1);
  endfunction : _vmnor
  function TD _vmandn(T2 src2, T1 src1);
    _vmandn = src2 & ~src1;
  endfunction : _vmandn
  function TD _vmxnor(T2 src2, T1 src1);
    _vmxnor = ~(src2 ^ src1);
  endfunction : _vmxnor

  //---------------------------------------------------------------------- 
  // 31.15.2. Vector count population in mask vcpop.m
  function TD _vcpop(T2 src2);
    this.mask_count += src2;
    _vcpop = this.mask_count;
  endfunction: _vcpop

  //---------------------------------------------------------------------- 
  // 32.15.3. vfirst find-first-set mask bit
  function TD _vfirst(T2 src2);
    if(src2 && !this.found_first_mask) begin
      this.found_first_mask = 1'b1;
      this.first_mask_idx = this.elm_idx;
    end else begin
      this.first_mask_idx = this.first_mask_idx;
    end
    _vfirst = this.first_mask_idx;
    `uvm_info("MDL", $sformatf("found_first_mask=%0d, first_mask_idx=%0d, elm_idx=%0d", 
                                found_first_mask, first_mask_idx, elm_idx),UVM_HIGH)
  endfunction: _vfirst

  //---------------------------------------------------------------------- 
  // 32.15.4. vmsbf.m set-before-first mask bit
  function TD _vmsbf(T2 src2);
    if(src2 & ~found_first_mask) begin
      found_first_mask = 1'b1; 
    end
    if(~found_first_mask) begin
      _vmsbf = 1'b1;
    end else begin
      _vmsbf = 1'b0;
    end
  endfunction: _vmsbf

  //---------------------------------------------------------------------- 
  // 32.15.5. vmsif.m set-including-first mask bit
  function TD _vmsif(T2 src2);
    if(!found_first_mask) begin
      _vmsif = 1'b1;
    end else begin
      _vmsif = 1'b0;
    end
    if(src2 & ~found_first_mask) begin 
      found_first_mask = 1'b1; 
    end
  endfunction: _vmsif

  //---------------------------------------------------------------------- 
  // 32.15.6. vmsof.m set-only-first mask bit
  function TD _vmsof(T2 src2);
    if(src2 & ~found_first_mask) begin 
      found_first_mask = 1'b1; 
      _vmsof = 1'b1;
    end else begin
      _vmsof = 1'b0;
    end
  endfunction: _vmsof

  //---------------------------------------------------------------------- 
  // 31.15.8. Vector Iota Instruction
  function TD _viota(T2 src2);
    if(this.elm_idx == 0) begin
      this.mask_count = 0;
    end
    _viota = this.mask_count;
    this.mask_count += src2;
  endfunction: _viota

  //---------------------------------------------------------------------- 
  // 31.15.9. Vector Element Index Instruction
  function TD _vid();
    _vid = elm_idx;
  endfunction: _vid

endclass: alu_processor

// LSU inst part ------------------------------------------
virtual class lsu_processor#(
  type TD = sew8_t,
  type T1 = sew8_t,
  type T2 = sew8_t);  

  static function TD exe (rvs_transaction inst_tr, T1 src1, T2 src2); //TODO ref ...
    TD dest;
    // `uvm_info("MDL", $sformatf("sizeof(T1)=%0d, sizeof(T2)=%0d, sizeof(TD)=%0d", $size(T1), $size(T2), $size(TD)), UVM_HIGH)
    case(inst_tr.lsu_mop) 
    endcase
    exe = dest;
    // `uvm_info("MDL", $sformatf("dest=%0d, src1=%0d, src2=%0d", exe, src1, src2), UVM_HIGH)
  endfunction : exe

endclass: lsu_processor
`endif // RVV_BEHAVIOR_MODEL
