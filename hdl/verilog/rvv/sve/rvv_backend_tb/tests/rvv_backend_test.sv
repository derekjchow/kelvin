`ifndef RVV_BACKEND_TEST__SV
`define RVV_BACKEND_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"
`include "inst_description.svh"
class rvv_backend_test extends uvm_test;

  `uvm_component_utils(rvv_backend_test)

  rvv_backend_env env;

  UVM_FILE tb_logs [string];
  int inst_queue_depth = 'd8;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = rvv_backend_env::type_id::create("env", this);
    uvm_top.set_timeout(5000ns,1);
    if($test$plusargs("all_zero_vrf")) begin
      vrf_if.vreg_init_data = '0;
    end else if($test$plusargs("all_one_vrf")) begin
      vrf_if.vreg_init_data = '1;
    end else if($test$plusargs("given_vrf")) begin
      vrf_if.vreg_init_data[0] = '1;
      for(int i=1; i<32; i++) begin
        vrf_if.vreg_init_data[i] = 128'hffff_0001_ffff_0002_ffff_0003_ffff_0000 + i;
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
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tb_logs["DEBUG"] = $fopen("tb_debug.log", "w");
    this.set_report_id_file_hier("DEBUG", tb_logs["DEBUG"]);
    this.set_report_id_action_hier("DEBUG", UVM_LOG);
    tb_logs["VRF_RECORDER"] = $fopen("tb_vrf_recorder.log", "w");
    this.env.scb.set_report_id_file("VRF_RECORDER", tb_logs["VRF_RECORDER"]);
    this.env.scb.set_report_id_action("VRF_RECORDER", UVM_LOG);
    tb_logs["ASM_DUMP"] = $fopen("tb_asm_dump.log", "w");
    this.env.rvs_agt.rvs_drv.set_report_id_file("ASM_DUMP", tb_logs["ASM_DUMP"]);
    this.env.rvs_agt.rvs_drv.set_report_id_action("ASM_DUMP", UVM_LOG);
  endfunction

  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    foreach (tb_logs[log_name]) begin
      $fclose(tb_logs[log_name]);
    end
  endfunction
endclass: rvv_backend_test


//=================================================
// To debug testbench.
//=================================================
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


//=================================================
// ALU direct instruction tests 
//=================================================
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vaddsub_test extends rvv_backend_test;

  alu_iterate_seq rvs_seq;

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

    rvs_seq = alu_iterate_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VADD, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSUB, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VRSUB, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vaddsub_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vwaddsub_test extends rvv_backend_test;

  alu_iterate_w_seq rvs_seq;

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

    rvs_seq = alu_iterate_w_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VWADD, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADDU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWADD_W, env.rvs_agt.rvs_sqr);

    rvs_seq.run_inst(VWSUB, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUBU_W, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VWSUB_W, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vwaddsub_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vadcsbc_test extends rvv_backend_test;

  alu_iterate_seq rvs_seq;

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

    rvs_seq = alu_iterate_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VADC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMADC, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSBC , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMSBC, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vadcsbc_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vext_test extends rvv_backend_test;

  alu_iterate_ext_seq rvs_seq;

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
    rvs_seq.run_inst(VEXT, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vext_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_bitlogic_test extends rvv_backend_test;

  alu_iterate_seq rvs_seq;

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

    rvs_seq = alu_iterate_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VAND, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VOR, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VXOR, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_bitlogic_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_shift_test extends rvv_backend_test;

  alu_iterate_seq rvs_seq;

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

    rvs_seq = alu_iterate_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VSLL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRL , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VSRA , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRL, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VNSRA, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_shift_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vcomp_test extends rvv_backend_test;

  alu_iterate_vcomp_seq rvs_seq;

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

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vcomp_test
//-------------------------------------------------
// 
//-------------------------------------------------
class alu_vminmax_test extends rvv_backend_test;

  alu_iterate_seq rvs_seq;

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

    rvs_seq = alu_iterate_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(VMINU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN , env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMAXU, env.rvs_agt.rvs_sqr);
    rvs_seq.run_inst(VMIN, env.rvs_agt.rvs_sqr);

    phase.phase_done.set_drain_time(this, 1000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_vminmax_test
`endif // RVV_BACKEND_TEST__SV

