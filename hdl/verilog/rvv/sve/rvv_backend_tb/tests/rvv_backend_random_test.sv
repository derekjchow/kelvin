`ifndef RVV_BACKEND_RANDOM_TEST__SV
`define RVV_BACKEND_RANDOM_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"
//-----------------------------------------------------------
// Normal random test
//-----------------------------------------------------------
class alu_random_test extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_random_test)

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();

    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_test

//-----------------------------------------------------------
// Large lmul random test
//-----------------------------------------------------------
class alu_random_large_lmul_test extends rvv_backend_test;

  alu_random_large_lmul_seq  rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_random_large_lmul_test)

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();

    rvs_seq = alu_random_large_lmul_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_large_lmul_test

//-----------------------------------------------------------
// Small lmul random test
//-----------------------------------------------------------
class alu_random_small_lmul_test extends rvv_backend_test;

  alu_random_small_lmul_seq  rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_random_small_lmul_test)

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();

    rvs_seq = alu_random_small_lmul_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_small_lmul_test

//-----------------------------------------------------------
// Bypass random test
//-----------------------------------------------------------
class alu_random_bypass_test extends rvv_backend_test;

  alu_random_bypass_seq  rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_random_bypass_test)

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();

    rvs_seq = alu_random_bypass_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_bypass_test

//-----------------------------------------------------------
// WAW random test
//-----------------------------------------------------------
class alu_random_waw_test extends rvv_backend_test;

  alu_random_waw_seq  rvs_seq;
  alu_smoke_vv_seq rvs_last_seq;

  `uvm_component_utils(alu_random_waw_test)

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();

    rvs_seq = alu_random_waw_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_waw_test
`endif // RVV_BACKEND_RANDOM_TEST__SV
