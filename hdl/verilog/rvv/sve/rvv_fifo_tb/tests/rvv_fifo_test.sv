//
// Template for UVM-compliant testcase

`ifndef TEST__SV
`define TEST__SV

typedef class rvv_fifo_env;

class rvv_fifo_base_test extends uvm_test;

  `uvm_component_utils(rvv_fifo_base_test)

  rvv_fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = rvv_fifo_env::type_id::create("env", this);
    //uvm_config_db #(uvm_object_wrapper)::set(this, "env.master_agent.mast_sqr.main_phase",
    //                "default_sequence", push_sequencer_sequence_library::get_type()); 
  endfunction

endclass : rvv_fifo_base_test
class rvv_fifo_bringup_test extends rvv_fifo_base_test;
  pop_sequence pop_seq;
  sequence_0   push_seq;
   `uvm_component_utils(rvv_fifo_bringup_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting main_phase ,,", UVM_LOW)
    phase.raise_objection( .obj( this ) );

    push_seq = new("push_seq");
    pop_seq = new("pop_seq");
    fork 
       pop_seq.start(env.slave_agent.slv_seqr);
    join_none
    push_seq.start(env.master_agent.mast_sqr);

    phase.phase_done.set_drain_time(this, 10000);
    phase.drop_objection( .obj( this ) );
    `uvm_info(get_type_name(), "main_phase ending,,", UVM_LOW)
  endtask
endclass

`endif //TEST__SV

