`ifndef RVV_BACKEND_TEST__SV
`define RVV_BACKEND_TEST__SV

typedef class rvv_backend_env;

class rvv_backend_test extends uvm_test;

  `uvm_component_utils(rvv_backend_test)

  rvv_backend_env env;

  UVM_FILE tb_logs [string];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = rvv_backend_env::type_id::create("env", this);
    uvm_top.set_timeout(5000ns,1);
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
`endif // RVV_BACKEND_TEST__SV

