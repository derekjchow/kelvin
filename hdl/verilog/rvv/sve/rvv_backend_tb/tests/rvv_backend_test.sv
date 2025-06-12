`ifndef RVV_BACKEND_TEST__SV
`define RVV_BACKEND_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"
class rvv_backend_test extends uvm_test;

  `uvm_component_utils(rvv_backend_test)

  typedef virtual rvs_interface v_if1;
  typedef virtual vrf_interface v_if3;
  typedef virtual rvv_intern_interface v_if4;
  v_if1 rvs_if;
  v_if3 vrf_if;
  v_if4 rvv_intern_if;
  rvv_backend_env env;

  UVM_FILE tb_logs [string];
  int inst_tx_queue_depth = 4;
  int inst_tx_timeout_max = 1000;
  int direct_inst_num = 1000;
  int random_inst_num = 50000;

  int unsigned mem_base = 32'h0000_0000;
  int unsigned mem_size = 1024*1024;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = rvv_backend_env::type_id::create("env", this);
    if(!uvm_config_db#(v_if1)::get(this, "", "rvs_if", rvs_if)) begin
      `uvm_fatal("TEST/NOVIF", "No virtual interface specified for this agent instance")
    end
    if(!uvm_config_db#(v_if3)::get(this, "", "vrf_if", vrf_if)) begin
      `uvm_fatal("TEST/NOVIF", "No virtual interface specified for this agent instance")
    end
    if(!uvm_config_db#(v_if4)::get(this, "", "rvv_intern_if", rvv_intern_if)) begin
      `uvm_fatal("TEST/NOVIF", "No virtual interface specified for this agent instance")
    end

    if($test$plusargs("ill_inst_en"))
      uvm_config_db#(bit)::set(uvm_root::get(), "*", "ill_inst_en", 1'b1);
    if($test$plusargs("all_one_for_agn"))
      uvm_config_db#(bit)::set(uvm_root::get(), "*", "all_one_for_agn", 1'b1);
    if($value$plusargs("inst_tx_queue_depth=%d", inst_tx_queue_depth))
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_tx_queue_depth", inst_tx_queue_depth);
    else
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_tx_queue_depth", inst_tx_queue_depth);
    if($test$plusargs("single_inst_mode"))
      uvm_config_db#(int)::set(uvm_root::get(), "*", "single_inst_mode", 1'b1);
    if($test$plusargs("qualify")) begin
      direct_inst_num = 200;
      random_inst_num = 5000;
    end else begin
      direct_inst_num = 1000;
      random_inst_num = 100000;
    end

    if($test$plusargs("delay_mode_all_slow")) begin
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_rt_xrf", delay_mode_pkg::SLOW);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_wr_vxsat", delay_mode_pkg::SLOW);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_rvv2lsu", delay_mode_pkg::SLOW);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_lsu2rvv", delay_mode_pkg::SLOW);
      inst_tx_timeout_max = 5000;
    end
    if($test$plusargs("delay_mode_all_fast")) begin
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_rt_xrf", delay_mode_pkg::FAST);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_wr_vxsat", delay_mode_pkg::FAST);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_rvv2lsu", delay_mode_pkg::FAST);
      uvm_config_db#(delay_mode_pkg::delay_mode_e)::set(uvm_root::get(), "*", "delay_mode_lsu2rvv", delay_mode_pkg::FAST);
    end

    if($value$plusargs("inst_tx_timeout_max=%d", inst_tx_timeout_max))
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_tx_timeout_max", inst_tx_timeout_max);
    else
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_tx_timeout_max", inst_tx_timeout_max);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tb_logs["MDL"] = $fopen("tb_model.log", "w");
    this.set_report_id_file_hier("MDL", tb_logs["MDL"]);
    this.set_report_id_action_hier("MDL", UVM_LOG);
    this.set_report_id_file_hier("MDL/LSU", tb_logs["MDL"]);
    this.set_report_id_action_hier("MDL/LSU", UVM_LOG);
    tb_logs["ASM_DUMP"] = $fopen("tb_asm_dump.log", "w");
    this.env.rvs_agt.rvs_mon.set_report_id_file("ASM_DUMP", tb_logs["ASM_DUMP"]);
    this.env.rvs_agt.rvs_mon.set_report_id_action("ASM_DUMP", UVM_LOG);
    tb_logs["INST_TR"] = $fopen("tb_inst_tr.log", "w");
    this.env.rvs_agt.rvs_mon.set_report_id_file("INST_TR", tb_logs["INST_TR"]);
    this.env.rvs_agt.rvs_mon.set_report_id_action("INST_TR", UVM_LOG|UVM_DISPLAY);
    tb_logs["RECORDER_LOG"] = $fopen("tb_recorder.log", "w");
    this.env.scb.set_report_id_file("VRF_RECORDER", tb_logs["RECORDER_LOG"]);
    this.env.scb.set_report_id_action("VRF_RECORDER", UVM_LOG);
    this.env.scb.set_report_id_file("RT_RECORDER", tb_logs["RECORDER_LOG"]);
    this.env.scb.set_report_id_action("RT_RECORDER", UVM_LOG|UVM_DISPLAY);
    // tb_logs["LSU_DRV"] = $fopen("tb_lsu_driver.log", "w");
    // this.env.lsu_agt.lsu_drv.set_report_id_file("LSU_DRV", tb_logs["LSU_DRV"]);
    // this.env.lsu_agt.lsu_drv.set_report_id_action("LSU_DRV", UVM_LOG|UVM_DISPLAY);

  endfunction

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    foreach (tb_logs[log_name]) begin
      $fclose(tb_logs[log_name]);
    end
  endfunction

  virtual task set_mdl_vrf(int reg_idx, logic [`VLEN-1:0] value);
    env.mdl.vrf[reg_idx] = value;
  endtask: set_mdl_vrf

  virtual task set_vrf(int reg_idx, logic [`VLEN-1:0] value);
    vrf_if.set_dut_vrf(reg_idx, value);
    set_mdl_vrf(reg_idx, value);
  endtask: set_vrf

  virtual task rand_vrf();
    logic [`VLEN-1:0] value;
    for(int reg_idx=0; reg_idx<32; reg_idx++) begin
      for(int j=0; j<`VLENB; j++) begin
        value[j*8+:8] = $urandom_range(0, 8'hFF);
      end
      set_mdl_vrf(reg_idx, value);
      vrf_if.set_dut_vrf(reg_idx, value);
    end
  endtask: rand_vrf

  virtual task rand_mem(int unsigned mem_base, int unsigned mem_size);
    byte value;
    env.lsu_agt.lsu_drv.mem.set_mem_range(mem_base, mem_size);
    env.mdl.mem.set_mem_range(mem_base, mem_size);
    for(int byte_idx=mem_base; byte_idx<mem_size; byte_idx++) begin
      value = $urandom_range(0, 8'hFF);
      env.lsu_agt.lsu_drv.mem.set_mem(byte_idx, value);
      env.mdl.mem.set_mem(byte_idx, value);
    end
  endtask: rand_mem

endclass: rvv_backend_test


//===========================================================
// To debug testbench.
//===========================================================
class tb_debug_test extends rvv_backend_test;

  zero_seq rvs_seq;

  `uvm_component_utils(tb_debug_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "ill_inst_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "all_one_for_agn", 1'b1);
    uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_queue_depth", 'd8);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG | UVM_DISPLAY);
  endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting test ...", UVM_LOW)

    // rvs_seq = new("rvs_seq");
    rvs_seq = zero_seq::type_id::create("rvs_seq", this);
    rvs_seq.start(env.rvs_agt.rvs_sqr);


    `uvm_info(get_type_name(), "Complete test ...", UVM_LOW)
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: tb_debug_test


//===========================================================
// ALU direct instruction tests 
//===========================================================
//-----------------------------------------------------------
// Smoke test. Each inst will be run once.
//-----------------------------------------------------------
class alu_smoke_test extends rvv_backend_test;

  alu_smoke_vv_seq rvs_vv_seq;
  alu_smoke_ext_seq rvs_ext_seq;
  alu_smoke_vx_seq rvs_vx_seq;
  alu_smoke_vmunary0_seq rvs_vmunary0_seq;
  alu_smoke_vwxunary0_seq rvs_vwxunary0_seq;
  alu_smoke_vred_seq rvs_vred_seq;

  `uvm_component_utils(alu_smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_vv_seq = alu_smoke_vv_seq::type_id::create("alu_smoke_vv_seq", this);
    rvs_ext_seq = alu_smoke_ext_seq::type_id::create("alu_smoke_ext_seq", this);
    rvs_vx_seq = alu_smoke_vx_seq::type_id::create("alu_smoke_vx_seq", this);
    rvs_vmunary0_seq = alu_smoke_vmunary0_seq::type_id::create("rvs_vmunary0_seq", this);
    rvs_vwxunary0_seq = alu_smoke_vwxunary0_seq::type_id::create("rvs_vwxunary0_seq", this);
    rvs_vred_seq = alu_smoke_vred_seq::type_id::create("alu_smoke_vred_seq", this);

    if($test$plusargs("case01") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSUB, env.rvs_agt.rvs_sqr);
      rvs_vx_seq.run_inst(VRSUB,env.rvs_agt.rvs_sqr);

      rvs_vv_seq.run_inst(VWADD, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWADDU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWADDU_W, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWADD_W, env.rvs_agt.rvs_sqr);

      rvs_vv_seq.run_inst(VWSUB, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWSUBU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWSUBU_W, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWSUB_W, env.rvs_agt.rvs_sqr);

      rvs_ext_seq.run_inst(VXUNARY0, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case02_a") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VADC , env.rvs_agt.rvs_sqr, 0);
      rvs_vv_seq.run_inst(VSBC , env.rvs_agt.rvs_sqr, 0);
    end

    if($test$plusargs("case02_b") || $test$plusargs("all_case")) begin
      // RDT in RTL
      rvs_vv_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr, 0);
      rvs_vv_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr, 0);
      rvs_vv_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr, 1);
    end

    if($test$plusargs("case03") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VAND, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VOR, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VXOR, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case04") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VSLL , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSRL , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSRA , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VNSRL, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VNSRA, env.rvs_agt.rvs_sqr);
    end
 
    if($test$plusargs("case05") || $test$plusargs("all_case")) begin
      // RDT in RTL
      rvs_vv_seq.run_inst(VMSEQ , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSNE , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSLTU, env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSLT , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSLEU, env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMSLE , env.rvs_agt.rvs_sqr, 1);
      rvs_vx_seq.run_inst(VMSGTU, env.rvs_agt.rvs_sqr, 1);
      rvs_vx_seq.run_inst(VMSGT , env.rvs_agt.rvs_sqr, 1);
    end

    if($test$plusargs("case06") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VMINU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMIN , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMAXU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMIN, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case07") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VMUL, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMULH, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMULHU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMULHSU, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case08") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VDIVU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VDIV , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VREMU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VREM , env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case09") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VWMUL  , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWMULU , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWMULSU, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case10") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VMACC , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VNMSAC, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VMADD , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VNMSUB, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case11") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VWMACCU , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWMACC  , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWMACCUS, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VWMACCSU, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case12") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VMERGE_VMVV, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case13") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VSADDU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSADD , env.rvs_agt.rvs_sqr);
      rvs_vx_seq.run_inst(VSSUBU, env.rvs_agt.rvs_sqr);
      rvs_vx_seq.run_inst(VSSUB , env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case14") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VAADDU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VAADD , env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VASUBU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VASUB , env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case15") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case16") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VSSRL, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSSRA, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSSRL, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VSSRA, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case17") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VNCLIPU, env.rvs_agt.rvs_sqr);
      rvs_vv_seq.run_inst(VNCLIP , env.rvs_agt.rvs_sqr);
    end 

    if($test$plusargs("case18") || $test$plusargs("all_case")) begin
      rvs_vv_seq.run_inst(VMAND , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMOR  , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMXOR , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMORN , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMNAND, env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMNOR , env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMANDN, env.rvs_agt.rvs_sqr, 1);
      rvs_vv_seq.run_inst(VMXNOR, env.rvs_agt.rvs_sqr, 1);
    end

    if($test$plusargs("case19") || $test$plusargs("all_case")) begin
      rvs_vwxunary0_seq.run_inst(VWXUNARY0, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case20") || $test$plusargs("all_case")) begin
      rvs_vmunary0_seq.run_inst(VMUNARY0, env.rvs_agt.rvs_sqr);
    end
    
    if($test$plusargs("case21") || $test$plusargs("all_case")) begin
      rvs_vred_seq.run_inst(VREDSUM , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDAND , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDOR  , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDXOR , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDMINU, env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDMIN , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDMAXU, env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VREDMAX , env.rvs_agt.rvs_sqr);
    end
 
    if($test$plusargs("case22") || $test$plusargs("all_case")) begin
      rvs_vred_seq.run_inst(VWREDSUM , env.rvs_agt.rvs_sqr);
      rvs_vred_seq.run_inst(VWREDSUMU, env.rvs_agt.rvs_sqr);
    end

    // Last inst  
    rvs_vv_seq.run_inst(VAND, env.rvs_agt.rvs_sqr);


  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_smoke_test

//-----------------------------------------------------------
// 32.11.1. Vector Single-Width Integer Add and Subtract
//-----------------------------------------------------------
class alu_vaddsub_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq  rvs_vv_vx_vi_seq;
  alu_iterate_vv_vx_seq     rvs_vv_vx_seq;
  alu_iterate_vx_vi_seq     rvs_vx_vi_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VADD, VSUB, VRSUB};

  `uvm_component_utils(alu_vaddsub_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_vv_vx_vi_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_vv_vx_vi_seq", this);
    rvs_vv_vx_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_vv_vx_seq", this);
    rvs_vx_vi_seq = alu_iterate_vx_vi_seq::type_id::create("rvs_vx_vi_seq", this);
    rvs_vv_vx_vi_seq.run_inst_iter(VADD , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(VSUB , env.rvs_agt.rvs_sqr, 0);
    rvs_vx_vi_seq.run_inst_iter(VRSUB, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VADD , env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(VSUB , env.rvs_agt.rvs_sqr, 1);
    rvs_vx_vi_seq.run_inst_iter(VRSUB, env.rvs_agt.rvs_sqr, 1);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_vv_vx_vi_seq.run_inst_rand(VADD , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(VSUB , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_vi_seq.run_inst_rand(VRSUB, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vaddsub_test

//-----------------------------------------------------------
// 32.11.2. Vector Single-Width Integer Add and Subtract
//-----------------------------------------------------------
class alu_vwaddsub_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWADD, VWADDU, VWADDU_W, VWADD_W,
                             VWSUB, VWSUBU, VWSUBU_W, VWSUB_W};

  `uvm_component_utils(alu_vwaddsub_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VWADD   , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWADDU  , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWADDU_W, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWADD_W , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWADD   , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWADDU  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWADDU_W, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWADD_W , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_iter(VWSUB   , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWSUBU  , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWSUBU_W, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWSUB_W , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWSUB   , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWSUBU  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWSUBU_W, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWSUB_W , env.rvs_agt.rvs_sqr, 1);
    
    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_seq.run_inst_rand(VWADD   , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWADDU  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWADDU_W, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWADD_W , env.rvs_agt.rvs_sqr, direct_inst_num);

    rvs_seq.run_inst_rand(VWSUB   , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWSUBU  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWSUBU_W, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWSUB_W , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwaddsub_test

//-----------------------------------------------------------
// 32.11.3. Vector Integer Extension 
//-----------------------------------------------------------
class alu_vext_test extends rvv_backend_test;

  alu_iterate_ext_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VXUNARY0};

  `uvm_component_utils(alu_vext_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_seq = alu_iterate_ext_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VXUNARY0, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VXUNARY0, env.rvs_agt.rvs_sqr, 1);
    
    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_seq.run_inst_rand(VXUNARY0, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vext_test

//-----------------------------------------------------------
// 32.11.4. Vector Integer Add-with-Carry / Subtract-with-Borrow Instructions
//-----------------------------------------------------------
class alu_vadcsbc_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq rvs_vv_vx_vi_seq;
  alu_iterate_vv_vx_seq rvs_vv_vx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VADC, VSBC};

  `uvm_component_utils(alu_vadcsbc_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_vv_vx_vi_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_vv_vx_vi_seq", this);
    rvs_vv_vx_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_vv_vx_seq", this);
    rvs_vv_vx_vi_seq.run_inst_iter(VADC , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VSBC , env.rvs_agt.rvs_sqr, 0);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_vv_vx_vi_seq.run_inst_rand(VADC , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VSBC , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vadcsbc_test

// vmadc/vmsbc executed by PMTRDT in dut.
class alu_vmadcsbc_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq rvs_vv_vx_vi_seq;
  alu_iterate_vv_vx_seq rvs_vv_vx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMADC, VMSBC};

  `uvm_component_utils(alu_vmadcsbc_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_vv_vx_vi_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_vv_vx_vi_seq", this);
    rvs_vv_vx_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_vv_vx_seq", this);
    rvs_vv_vx_vi_seq.run_inst_iter(VMADC, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VMSBC, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VMADC, env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(   VMSBC, env.rvs_agt.rvs_sqr, 1);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_vv_vx_vi_seq.run_inst_rand(VMADC, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VMSBC, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmadcsbc_test

//-----------------------------------------------------------
// 32.11.5. Vector Bitwise Logical Instructions 
//-----------------------------------------------------------
class alu_bitlogic_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VAND, VOR, VXOR};

  `uvm_component_utils(alu_bitlogic_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VAND, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VOR , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VXOR, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VAND, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VOR , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VXOR, env.rvs_agt.rvs_sqr, 1);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_seq.run_inst_rand(VAND, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VOR , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VXOR, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_bitlogic_test

//-----------------------------------------------------------
// 32.11.6. Vector Single-Width Shift Instructions
// 32.11.7. Vector Narrowing Integer Right Shift Instructions
//-----------------------------------------------------------
class alu_shift_test extends rvv_backend_test;

  alu_iterate_vv_vx_vui_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSLL, VSRL, VSRA, VNSRL, VNSRA};

  `uvm_component_utils(alu_shift_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_seq = alu_iterate_vv_vx_vui_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VSLL , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSRL , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSRA , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNSRL, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNSRA, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSLL , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VSRL , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VSRA , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VNSRL, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VNSRA, env.rvs_agt.rvs_sqr, 1);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_seq.run_inst_rand(VSLL , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VSRL , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VSRA , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VNSRL, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VNSRA, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_shift_test

//-----------------------------------------------------------
// 32.11.8. Vector Integer Compare Instructions
//-----------------------------------------------------------
class alu_vcomp_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq rvs_vv_vx_vi_seq;
  alu_iterate_vv_vx_seq rvs_vv_vx_seq;
  alu_iterate_vx_vi_seq rvs_vx_vi_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{
    VMSEQ, VMSNE, VMSLTU, VMSLT, VMSLEU, VMSLE, VMSGTU, VMSGT
  };

  `uvm_component_utils(alu_vcomp_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    `uvm_info(get_type_name(), "Iterate part.", UVM_HIGH)
    rvs_vv_vx_vi_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_vv_vx_vi_seq", this);
    rvs_vv_vx_seq    = alu_iterate_vv_vx_seq::type_id::create("rvs_vv_vx_seq", this);
    rvs_vx_vi_seq    = alu_iterate_vx_vi_seq::type_id::create("rvs_vx_vi_seq", this);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSEQ , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSNE , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VMSLTU, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VMSLT , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSLEU, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSLE , env.rvs_agt.rvs_sqr, 0);
    rvs_vx_vi_seq.run_inst_iter(   VMSGTU, env.rvs_agt.rvs_sqr, 0);
    rvs_vx_vi_seq.run_inst_iter(   VMSGT , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSEQ , env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSNE , env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(   VMSLTU, env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(   VMSLT , env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSLEU, env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_vi_seq.run_inst_iter(VMSLE , env.rvs_agt.rvs_sqr, 1);
    rvs_vx_vi_seq.run_inst_iter(   VMSGTU, env.rvs_agt.rvs_sqr, 1);
    rvs_vx_vi_seq.run_inst_iter(   VMSGT , env.rvs_agt.rvs_sqr, 1);

    `uvm_info(get_type_name(), "Single inst random part.", UVM_HIGH)
    rvs_vv_vx_vi_seq.run_inst_rand(VMSEQ , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_vi_seq.run_inst_rand(VMSNE , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VMSLTU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VMSLT , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_vi_seq.run_inst_rand(VMSLEU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_vi_seq.run_inst_rand(VMSLE , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_vi_seq.run_inst_rand(   VMSGTU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_vi_seq.run_inst_rand(   VMSGT , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vcomp_test

//-----------------------------------------------------------
// 32.11.9. Vector Integer Min/Max Instructions
//-----------------------------------------------------------
class alu_vminmax_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMINU, VMIN, VMAXU, VMAX};

  `uvm_component_utils(alu_vminmax_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMINU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMIN , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMAXU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMIN , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMINU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMIN , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMAXU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMIN , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VMINU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMIN , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMAXU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMIN , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vminmax_test

//-----------------------------------------------------------
// 32.11.10. Vector Single-Width Integer Multiply Instructions 
//-----------------------------------------------------------
class alu_vmul_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMUL, VMULH, VMULHU, VMULHSU};

  `uvm_component_utils(alu_vmul_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMUL   , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMULH  , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMULHU , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMULHSU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMUL   , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMULH  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMULHU , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMULHSU, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VMUL   , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMULH  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMULHU , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMULHSU, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmul_test

//-----------------------------------------------------------
// 32.11.11. Vector Integer Divide Instructions
//-----------------------------------------------------------
class alu_vdiv_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VDIVU, VDIV, VREMU, VREM};

  `uvm_component_utils(alu_vdiv_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VDIVU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VDIV , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VREMU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VREM , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VDIVU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VDIV , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREMU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREM , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VDIVU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VDIV , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREMU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREM , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vdiv_test

//-----------------------------------------------------------
// 32.11.12. Vector Widening Integer Multiply Instructions
//-----------------------------------------------------------
class alu_vwmul_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWMUL, VWMULU, VWMULSU};

  `uvm_component_utils(alu_vwmul_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VWMUL  , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMULU , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMULSU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMUL  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWMULU , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWMULSU, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VWMUL  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWMULU , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWMULSU, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwmul_test

//-----------------------------------------------------------
// 32.11.13. Vector Single-Width Integer Multiply-Add Instructions
//-----------------------------------------------------------
class alu_vmac_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMACC, VNMSAC, VMADD, VNMSUB};

  `uvm_component_utils(alu_vmac_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMACC , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNMSAC, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMADD , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNMSUB, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMACC , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VNMSAC, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMADD , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VNMSUB, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VMACC , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VNMSAC, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMADD , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VNMSUB, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmac_test

//-----------------------------------------------------------
// 32.11.13. Vector Single-Width Integer Multiply-Add Instructions
//-----------------------------------------------------------
class alu_vwmac_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq rvs_seq;
  alu_iterate_vx_seq rvs_vx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWMACCU, VWMACC, VWMACCUS, VWMACCSU};

  `uvm_component_utils(alu_vwmac_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_vx_seq = alu_iterate_vx_seq::type_id::create("rvs_vx_seq", this);
    rvs_seq.run_inst_iter(VWMACCU , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMACC  , env.rvs_agt.rvs_sqr, 0);
    rvs_vx_seq.run_inst_iter(VWMACCUS, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMACCSU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWMACCU , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWMACC  , env.rvs_agt.rvs_sqr, 1);
    rvs_vx_seq.run_inst_iter(VWMACCUS, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWMACCSU, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VWMACCU , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWMACC  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_seq.run_inst_rand(VWMACCUS, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWMACCSU, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwmac_test

//-----------------------------------------------------------
// 32.11.15. Vector Integer Merge Instructions
// 32.11.16. Vector Integer Move Instructions
//-----------------------------------------------------------
class alu_vmerge_vmvv_test extends rvv_backend_test;

  alu_iterate_vmerge_vmvv_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMERGE_VMVV};

  `uvm_component_utils(alu_vmerge_vmvv_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vmerge_vmvv_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMERGE_VMVV, env.rvs_agt.rvs_sqr, 0); // vmerge
    rvs_seq.run_inst_iter(VMERGE_VMVV, env.rvs_agt.rvs_sqr, 1); // vmv.v

    rvs_seq.run_inst_rand(VMERGE_VMVV, env.rvs_agt.rvs_sqr, direct_inst_num); 

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmerge_vmvv_test

//-----------------------------------------------------------
// 32.12.1. Vector Single-Width Saturating Add and Subtract
//-----------------------------------------------------------
class alu_vsaddsub_test extends rvv_backend_test;

  alu_iterate_vv_vx_vi_seq rvs_vv_vx_vi_seq;
  alu_iterate_vv_vx_seq  rvs_vv_vx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSADDU, VSADD, VSSUBU, VSSUB};

  `uvm_component_utils(alu_vsaddsub_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_vv_vx_vi_seq = alu_iterate_vv_vx_vi_seq::type_id::create("rvs_vv_vx_vi_seq", this);
    rvs_vv_vx_seq  = alu_iterate_vv_vx_seq::type_id::create("rvs_vv_vx_seq", this);
    rvs_vv_vx_vi_seq.run_inst_iter(VSADDU, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VSADD , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VSSUBU, env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_seq.run_inst_iter(   VSSUB , env.rvs_agt.rvs_sqr, 0);
    rvs_vv_vx_vi_seq.run_inst_iter(VSADDU, env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_vi_seq.run_inst_iter(VSADD , env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(   VSSUBU, env.rvs_agt.rvs_sqr, 1);
    rvs_vv_vx_seq.run_inst_iter(   VSSUB , env.rvs_agt.rvs_sqr, 1);

    rvs_vv_vx_vi_seq.run_inst_rand(VSADDU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_vi_seq.run_inst_rand(VSADD , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VSSUBU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vv_vx_seq.run_inst_rand(   VSSUB , env.rvs_agt.rvs_sqr, direct_inst_num);


    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vsaddsub_test

//-----------------------------------------------------------
// 32.12.2. Vector Single-Width Averaging Add and Subtract
//-----------------------------------------------------------
class alu_vaaddsub_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VAADDU, VAADD, VASUBU, VASUB};

  `uvm_component_utils(alu_vaaddsub_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VAADDU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VAADD , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VASUBU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VASUB , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VAADDU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VAADD , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VASUBU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VASUB , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VAADDU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VAADD , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VASUBU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VASUB , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vaaddsub_test

//-----------------------------------------------------------
// 32.12.3. Vector Single-Width Fractional Multiply with Rounding and Saturation
//-----------------------------------------------------------
class alu_vsmul_test extends rvv_backend_test;

  alu_iterate_vv_vx_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSMUL_VMVNRR};

  `uvm_component_utils(alu_vsmul_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vv_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vsmul_test

//-----------------------------------------------------------
// 32.12.4. Vector Single-Width Fractional Multiply with Rounding and Saturation
//-----------------------------------------------------------
class alu_vssrlsra_test extends rvv_backend_test;

  alu_iterate_vv_vx_vui_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSSRL, VSSRA};

  `uvm_component_utils(alu_vssrlsra_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vv_vx_vui_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VSSRL, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSSRA, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSSRL, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VSSRA, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VSSRL, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VSSRA, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vssrlsra_test

//-----------------------------------------------------------
// 32.12.5 Vector Narrowing Fixed-Point Clip Instructions
//-----------------------------------------------------------
class alu_vnclip_test extends rvv_backend_test;

  alu_iterate_vv_vx_vui_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VNCLIPU, VNCLIP};

  `uvm_component_utils(alu_vnclip_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vv_vx_vui_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VNCLIPU, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNCLIP , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VNCLIPU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VNCLIP , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VNCLIPU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VNCLIP , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vnclip_test

//-----------------------------------------------------------
// 32.12.5 Vector Narrowing Fixed-Point Clip Instructions
//-----------------------------------------------------------
class alu_mask_logic_test extends rvv_backend_test;

  alu_iterate_vv_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{
    VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR
  };

  `uvm_component_utils(alu_mask_logic_test)

  function new(string name,  uvm_component parent);
    super.new(name,  parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vv_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMAND , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMOR  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMXOR , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMORN , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMNAND, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMNOR , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMANDN, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VMXNOR, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VMAND , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMOR  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMXOR , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMORN , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMNAND, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMNOR , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMANDN, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VMXNOR, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_mask_logic_test

//-----------------------------------------------------------
// 31.14.1. Vector Single-Width Integer Reduction Instructions
//-----------------------------------------------------------
class alu_vred_test extends rvv_backend_test;

  alu_iterate_vs_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{
    VREDSUM, VREDAND, VREDOR, VREDXOR, VREDMINU, VREDMIN, VREDMAXU, VREDMAX
  };

  `uvm_component_utils(alu_vred_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vs_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VREDSUM , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDAND , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDOR  , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDXOR , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDMINU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDMIN , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDMAXU, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VREDMAX , env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VREDSUM , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDAND , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDOR  , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDXOR , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDMINU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDMIN , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDMAXU, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VREDMAX , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vred_test

//-----------------------------------------------------------
// 31.14.2. Vector Widening Integer Reduction Instructions
//-----------------------------------------------------------
class alu_vwred_test extends rvv_backend_test;

  alu_iterate_vs_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWREDSUM, VWREDSUMU};

  `uvm_component_utils(alu_vwred_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vs_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VWREDSUM , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VWREDSUMU, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VWREDSUM , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VWREDSUMU, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwred_test

//-----------------------------------------------------------
// 32.15.2. Vector count population in mask vcpop.m
// 32.15.3. vfirst find-first-set mask bit
//-----------------------------------------------------------
class alu_vcpop_vfirst_test extends rvv_backend_test;

  alu_iterate_vwxunary0_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWXUNARY0};

  `uvm_component_utils(alu_vcpop_vfirst_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vwxunary0_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VWXUNARY0, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VWXUNARY0, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VWXUNARY0, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vcpop_vfirst_test

//-----------------------------------------------------------
// 32.15.4. vmsbf.m set-before-first mask bit
// 32.15.5. vmsif.m set-including-first mask bit
// 32.15.6. vmsof.m set-only-first mask bit
// 32.15.8. Vector Iota Instruction
// 32.15.9. Vector Element Index Instruction
//-----------------------------------------------------------
class alu_vmunary0_test extends rvv_backend_test;

  alu_iterate_vmunary0_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VMUNARY0};

  `uvm_component_utils(alu_vmunary0_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq  = alu_iterate_vmunary0_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VMUNARY0, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VMUNARY0, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VMUNARY0, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmunary0_test

//-----------------------------------------------------------
// 31.16.1. Integer Scalar Move  Instructions
//-----------------------------------------------------------
class alu_vmv_test extends rvv_backend_test;

  alu_iterate_vmv_xs_sx_seq rvs_xs_sx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VWXUNARY0};

  `uvm_component_utils(alu_vmv_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_xs_sx_seq = alu_iterate_vmv_xs_sx_seq::type_id::create("rvs_xs_sx_seq", this);
    rvs_xs_sx_seq.run_inst_iter(VWXUNARY0, env.rvs_agt.rvs_sqr, 1);

    rvs_xs_sx_seq.run_inst_rand(VWXUNARY0, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmv_test

//-----------------------------------------------------------
// 32.16.3. Vector Slide Instructions
//-----------------------------------------------------------
class alu_slide_test extends rvv_backend_test;

  alu_iterate_vx_vi_seq rvs_seq;
  alu_iterate_vx_seq rvs_vx_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSLIDEUP_RGATHEREI16, VSLIDEDOWN, VSLIDE1UP, VSLIDE1DOWN};

  `uvm_component_utils(alu_slide_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();
    rvs_seq = alu_iterate_vx_vi_seq::type_id::create("rvs_seq", this);
    rvs_vx_seq = alu_iterate_vx_seq::type_id::create("rvs_vx_seq", this);
    rvs_seq.run_inst_iter(VSLIDEUP_RGATHEREI16 , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSLIDEDOWN , env.rvs_agt.rvs_sqr, 0);
    rvs_vx_seq.run_inst_iter(VSLIDE1UP , env.rvs_agt.rvs_sqr, 0);
    rvs_vx_seq.run_inst_iter(VSLIDE1DOWN , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSLIDEUP_RGATHEREI16 , env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_iter(VSLIDEDOWN , env.rvs_agt.rvs_sqr, 1);
    rvs_vx_seq.run_inst_iter(VSLIDE1UP , env.rvs_agt.rvs_sqr, 1);
    rvs_vx_seq.run_inst_iter(VSLIDE1DOWN , env.rvs_agt.rvs_sqr, 1);


    rvs_seq.run_inst_rand(VSLIDEUP_RGATHEREI16 , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq.run_inst_rand(VSLIDEDOWN , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_seq.run_inst_rand(VSLIDE1UP , env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_vx_seq.run_inst_rand(VSLIDE1DOWN , env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_slide_test
//-----------------------------------------------------------
// 32.16.4. Vector Register Gather Instructions
//-----------------------------------------------------------
class alu_gather_test extends rvv_backend_test;

  alu_iterate_gather_vv_seq rvs_seq;
  alu_iterate_vv_vx_vui_seq rvs_seq1;// used for vrgather
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSLIDEUP_RGATHEREI16, VRGATHER};

  `uvm_component_utils(alu_gather_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_gather_vv_seq::type_id::create("rvs_seq", this);
    rvs_seq1 = alu_iterate_vv_vx_vui_seq::type_id::create("rvs_seq1", this);
    rvs_seq.run_inst_rand(VSLIDEUP_RGATHEREI16, env.rvs_agt.rvs_sqr, direct_inst_num);
    rvs_seq1.run_inst_rand(VRGATHER, env.rvs_agt.rvs_sqr, direct_inst_num);

    rvs_seq.run_inst_iter(VSLIDEUP_RGATHEREI16, env.rvs_agt.rvs_sqr, 0);
    rvs_seq1.run_inst_iter(VRGATHER, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst_iter(VSLIDEUP_RGATHEREI16, env.rvs_agt.rvs_sqr, 1);
    rvs_seq1.run_inst_iter(VRGATHER, env.rvs_agt.rvs_sqr, 1);


    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_gather_test
//-----------------------------------------------------------
// 32.16.5. Vector Compress Instructions
//-----------------------------------------------------------
class alu_vcompress_test extends rvv_backend_test;

  alu_iterate_vv_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VCOMPRESS};

  `uvm_component_utils(alu_vcompress_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vv_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VCOMPRESS, env.rvs_agt.rvs_sqr, 1);

    rvs_seq.run_inst_rand(VCOMPRESS, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vcompress_test
//-----------------------------------------------------------
// 32.16.6. Whole Vector Register Move Instructions
//-----------------------------------------------------------
class alu_vmvnr_test extends rvv_backend_test;

  alu_iterate_vmvnr_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_random_seq rvs_rand_seq;
  alu_inst_e inst_set[$] = '{VSMUL_VMVNRR};

  `uvm_component_utils(alu_vmvnr_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_iterate_vmvnr_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst_iter(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst_rand(VSMUL_VMVNRR, env.rvs_agt.rvs_sqr, direct_inst_num);

    `uvm_info(get_type_name(), "Inst set random part.", UVM_HIGH)
    rvs_rand_seq = alu_random_seq::type_id::create("rvs_rand_seq", this);
    rvs_rand_seq.run_rand_with_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmvnr_test

//===========================================================
// LSU direct instruction tests 
//===========================================================
//-----------------------------------------------------------
// 31.7.4. Vector Unit-Stride Instructions
//-----------------------------------------------------------
class lsu_unit_stride_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VL, VS};

  `uvm_component_utils(lsu_unit_stride_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_test


class lsu_unit_stride_mask_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLM, VSM};

  `uvm_component_utils(lsu_unit_stride_mask_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_mask_test

class lsu_whole_reg_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLR, VSR};

  `uvm_component_utils(lsu_whole_reg_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_whole_reg_test
//-----------------------------------------------------------
// 31.7.5. Vector Strided Instructions
//-----------------------------------------------------------
class lsu_const_stride_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLS, VSS};

  `uvm_component_utils(lsu_const_stride_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_const_stride_test

//-----------------------------------------------------------
// 31.7.6. Vector Indexed Instructions
//-----------------------------------------------------------
class lsu_indexed_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLUX, VLOX, VSUX, VSOX};

  `uvm_component_utils(lsu_indexed_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_indexed_test

//-----------------------------------------------------------
// 31.7.8. Vector Load/Store Segment Instructions
//-----------------------------------------------------------
class lsu_unit_stride_seg_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLSEG, VSSEG};

  `uvm_component_utils(lsu_unit_stride_seg_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_seg_test

class lsu_const_stride_seg_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLSSEG, VSSSEG};

  `uvm_component_utils(lsu_const_stride_seg_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_const_stride_seg_test

class lsu_indexed_seg_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLUXSEG, VLOXSEG, VSUXSEG, VSOXSEG};

  `uvm_component_utils(lsu_indexed_seg_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_indexed_seg_test


//-----------------------------------------------------------
// 31.7.7. & 31.7.8. Fault only first
//    For now this test will only test the decode.
//    It behaves like normal unit stride load if no trap comes.
//-----------------------------------------------------------
class lsu_fof_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{VLFF, VLSEGFF};

  `uvm_component_utils(lsu_fof_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);
    foreach(inst_set[idx]) begin
      rvs_seq.run_inst(inst_set[idx], env.rvs_agt.rvs_sqr, direct_inst_num);
    end

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, direct_inst_num * inst_set.size());

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_fof_test

//==========================================================
// Trap tests
//==========================================================
class lsu_unit_stride_test_trap_en extends lsu_unit_stride_test;
  `uvm_component_utils(lsu_unit_stride_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_test_trap_en

class lsu_const_stride_test_trap_en extends lsu_const_stride_test;
  `uvm_component_utils(lsu_const_stride_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_const_stride_test_trap_en

class lsu_indexed_test_trap_en extends lsu_indexed_test;
  `uvm_component_utils(lsu_indexed_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_indexed_test_trap_en

class lsu_unit_stride_seg_test_trap_en extends lsu_unit_stride_seg_test;
  `uvm_component_utils(lsu_unit_stride_seg_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_seg_test_trap_en

class lsu_const_stride_seg_test_trap_en extends lsu_const_stride_seg_test;
  `uvm_component_utils(lsu_const_stride_seg_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_const_stride_seg_test_trap_en

class lsu_indexed_seg_test_trap_en extends lsu_indexed_seg_test;
  `uvm_component_utils(lsu_indexed_seg_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_indexed_seg_test_trap_en

class lsu_unit_stride_mask_test_trap_en extends lsu_unit_stride_mask_test;
  `uvm_component_utils(lsu_unit_stride_mask_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_unit_stride_mask_test_trap_en

class lsu_whole_reg_test_trap_en extends lsu_whole_reg_test;
  `uvm_component_utils(lsu_whole_reg_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_whole_reg_test_trap_en

class lsu_fof_test_trap_en extends lsu_fof_test;
  `uvm_component_utils(lsu_fof_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_fof_test_trap_en
`endif // RVV_BACKEND_TEST__SV

