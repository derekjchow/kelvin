`ifndef RVV_BACKEND_TEST__SV
`define RVV_BACKEND_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"
`include "inst_description.svh"
class rvv_backend_test extends uvm_test;

  `uvm_component_utils(rvv_backend_test)

  typedef virtual rvs_interface v_if1;
  typedef virtual vrf_interface v_if3;
  v_if1 rvs_if;
  v_if3 vrf_if;
  rvv_backend_env env;

  UVM_FILE tb_logs [string];
  int inst_queue_depth = 'd1;

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
    if($test$plusargs("all_zero_vrf")) begin
      vrf_if.vreg_init_data = '0;
    end else if($test$plusargs("all_one_vrf")) begin
      vrf_if.vreg_init_data = '1;
    end else if($test$plusargs("given_vrf")) begin
      vrf_if.vreg_init_data[0] = 128'h5555_5555_5555_5555_5555_5555_5555_5555;
      // vrf_if.vreg_init_data[0] = '1;
      for(int i=1; i<32; i++) begin
        vrf_if.vreg_init_data[i] = 128'hffff_ffff_5a5a_a5a5_ffff_ffff_0000_0000 + i;
      end
    end else begin
      for(int i=0; i<32; i++) begin
        for(int j=0; j<`VLENB; j++) begin
          vrf_if.vreg_init_data[i][j*8+:8] = $urandom_range(0, 8'hFF);
        end
      end
    end
    if($test$plusargs("ill_inst_en"))
      uvm_config_db#(bit)::set(uvm_root::get(), "*", "ill_inst_en", 1'b1);
    if($test$plusargs("all_one_for_agn"))
      uvm_config_db#(bit)::set(uvm_root::get(), "*", "all_one_for_agn", 1'b1);
    if($value$plusargs("inst_queue_depth=%d", inst_queue_depth))
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_queue_depth", inst_queue_depth);
    else
      // give default value
      uvm_config_db#(int)::set(uvm_root::get(), "*", "inst_queue_depth", inst_queue_depth);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tb_logs["DEBUG"] = $fopen("tb_debug.log", "w");
    this.set_report_id_file_hier("DEBUG", tb_logs["DEBUG"]);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
    tb_logs["ASM_DUMP"] = $fopen("tb_asm_dump.log", "w");
    this.env.rvs_agt.rvs_drv.set_report_id_file("ASM_DUMP", tb_logs["ASM_DUMP"]);
    this.env.rvs_agt.rvs_drv.set_report_id_action("ASM_DUMP", UVM_LOG);
    tb_logs["INST_TR"] = $fopen("tb_inst_tr.log", "w");
    this.env.rvs_agt.rvs_drv.set_report_id_file("INST_TR", tb_logs["INST_TR"]);
    this.env.rvs_agt.rvs_drv.set_report_id_action("INST_TR", UVM_LOG);
    tb_logs["RECORDER_LOG"] = $fopen("tb_recorder.log", "w");
    this.env.scb.set_report_id_file("VRF_RECORDER", tb_logs["RECORDER_LOG"]);
    this.env.scb.set_report_id_action("VRF_RECORDER", UVM_LOG);
    this.env.scb.set_report_id_file("RT_RECORDER", tb_logs["RECORDER_LOG"]);
    this.env.scb.set_report_id_action("RT_RECORDER", UVM_LOG|UVM_DISPLAY);
  endfunction

  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    foreach (tb_logs[log_name]) begin
      $fclose(tb_logs[log_name]);
    end
  endfunction
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
    this.set_report_id_action_hier("DEBUG", UVM_LOG | UVM_DISPLAY);
  endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting test ...", UVM_LOW)
    phase.raise_objection( .obj( this ) );

    // rvs_seq = new("rvs_seq");
    rvs_seq = zero_seq::type_id::create("rvs_seq", this);
    rvs_seq.start(env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );

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

  alu_smoke_vv_seq rvs_seq;
  alu_smoke_ext_seq rvs_ext_seq;
  alu_smoke_vx_seq rvs_vx_seq;

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_smoke_vv_seq::type_id::create("alu_smoke_vv_seq", this);
    rvs_ext_seq = alu_smoke_ext_seq::type_id::create("alu_smoke_ext_seq", this);
    rvs_vx_seq = alu_smoke_vx_seq::type_id::create("alu_smoke_vx_seq", this);

    if($test$plusargs("case01") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSUB, env.rvs_agt.rvs_sqr);
    rvs_vx_seq.run_inst(VRSUB,env.rvs_agt.rvs_sqr);

    rvs_seq.run_inst(VWADD, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADD_W, env.rvs_agt.rvs_sqr);

    rvs_seq.run_inst(VWSUB, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUB_W, env.rvs_agt.rvs_sqr);

    rvs_ext_seq.run_inst(VXUNARY0, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case02") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VADC , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr, 1);
    rvs_seq.run_inst(VSBC , env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr, 0);
    rvs_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr, 1);
    end

    if($test$plusargs("case03") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VAND, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VOR, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VXOR, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case04") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VSLL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRA , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRL, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRA, env.rvs_agt.rvs_sqr);
    end
 
    if($test$plusargs("case05") || $test$plusargs("all_case")) begin
     rvs_seq.run_inst(VMSEQ , env.rvs_agt.rvs_sqr, 1);
     rvs_seq.run_inst(VMSNE , env.rvs_agt.rvs_sqr, 1);
     rvs_seq.run_inst(VMSLTU, env.rvs_agt.rvs_sqr, 1);
     rvs_seq.run_inst(VMSLT , env.rvs_agt.rvs_sqr, 1);
     rvs_seq.run_inst(VMSLEU, env.rvs_agt.rvs_sqr, 1);
     rvs_seq.run_inst(VMSLE , env.rvs_agt.rvs_sqr, 1);
     rvs_vx_seq.run_inst(VMSGTU, env.rvs_agt.rvs_sqr, 1);
     rvs_vx_seq.run_inst(VMSGT , env.rvs_agt.rvs_sqr, 1);
    end

    if($test$plusargs("case06") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VMINU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMAXU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case07") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VMUL, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULH, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULHU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULHSU, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case08") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VDIVU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VDIV , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VREMU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VREM , env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case09") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VWMUL  , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMULU , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMULSU, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case10") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VMACC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNMSAC, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMADD , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNMSUB, env.rvs_agt.rvs_sqr);
    end

    if($test$plusargs("case11") || $test$plusargs("all_case")) begin
    rvs_seq.run_inst(VWMACCU , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACC  , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACCUS, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACCSU, env.rvs_agt.rvs_sqr);
    end

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );

  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_smoke_test

//-----------------------------------------------------------
// 32.11.1. Vector Single-Width Integer Add and Subtract
//-----------------------------------------------------------
class alu_vaddsub_test extends rvv_backend_test;

  alu_iterate_vxi_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vaddsub_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vxi_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VADD, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSUB, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VRSUB,env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vaddsub_test

//-----------------------------------------------------------
// 32.11.2. Vector Single-Width Integer Add and Subtract
//-----------------------------------------------------------
class alu_vwaddsub_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vwaddsub_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VWADD, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADD_W, env.rvs_agt.rvs_sqr);

    rvs_seq.run_inst(VWSUB, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUB_W, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
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
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vext_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_ext_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VXUNARY0, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vext_test

//-----------------------------------------------------------
// 32.11.4. Vector Integer Add-with-Carry / Subtract-with-Borrow Instructions
//-----------------------------------------------------------
class alu_vadcsbc_test extends rvv_backend_test;

  alu_iterate_vadcsbc_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vadcsbc_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vadcsbc_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VADC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSBC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vadcsbc_test

//-----------------------------------------------------------
// 32.11.5. Vector Bitwise Logical Instructions 
//-----------------------------------------------------------
class alu_bitlogic_test extends rvv_backend_test;

  alu_iterate_vxi_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_bitlogic_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vxi_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VAND, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VOR, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VXOR, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
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

  alu_iterate_vxi_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_shift_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vxi_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VSLL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRA , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRL, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRA, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_shift_test

//-----------------------------------------------------------
// 32.11.8. Vector Integer Compare Instructions
//-----------------------------------------------------------
class alu_vcomp_test extends rvv_backend_test;

  alu_iterate_vcomp_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vcomp_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vcomp_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMSEQ , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSNE , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSLTU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSLT , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSLEU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSLE , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSGTU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSGT , env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vcomp_test

//-----------------------------------------------------------
// 32.11.9. Vector Integer Min/Max Instructions
//-----------------------------------------------------------
class alu_vminmax_test extends rvv_backend_test;

  alu_iterate_vxi_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vminmax_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vxi_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMINU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMAXU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vminmax_test

//-----------------------------------------------------------
// 32.11.10. Vector Single-Width Integer Multiply Instructions 
//-----------------------------------------------------------
class alu_vmul_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vmul_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMUL, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULH, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULHU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMULHSU, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmul_test

//-----------------------------------------------------------
// 32.11.11. Vector Integer Divide Instructions
//-----------------------------------------------------------
class alu_vdiv_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vdiv_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VDIVU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VDIV , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VREMU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VREM , env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vdiv_test

//-----------------------------------------------------------
// 32.11.12. Vector Widening Integer Multiply Instructions
//-----------------------------------------------------------
class alu_vwmul_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vwmul_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VWMUL  , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMULU , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMULSU, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwmul_test

//-----------------------------------------------------------
// 32.11.13. Vector Single-Width Integer Multiply-Add Instructions
//-----------------------------------------------------------
class alu_vmac_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vmac_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMACC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNMSAC, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMADD , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNMSUB, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmac_test

//-----------------------------------------------------------
// 32.11.13. Vector Single-Width Integer Multiply-Add Instructions
//-----------------------------------------------------------
class alu_vwmac_test extends rvv_backend_test;

  alu_iterate_vx_seq rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_vwmac_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vx_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VWMACCU , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACC  , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACCUS, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWMACCSU, env.rvs_agt.rvs_sqr);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwmac_test

//-----------------------------------------------------------
// 32.11.15. Vector Integer Merge Instructions
// 32.11.16. Vector Integer Move Instructions
//-----------------------------------------------------------
class alu_vmerge_test extends rvv_backend_test;

  alu_iterate_vmerge_seq rvs_seq;

  `uvm_component_utils(alu_vmerge_test)

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
    phase.raise_objection( .obj( this ) );

    rvs_seq = alu_iterate_vmerge_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMERGE_VMVV, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vmerge_test

`endif // RVV_BACKEND_TEST__SV

