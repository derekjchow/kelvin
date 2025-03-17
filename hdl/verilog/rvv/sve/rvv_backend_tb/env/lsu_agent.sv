`ifndef LSU_AGENT__SV
`define LSU_AGENT__SV

class lsu_agent extends uvm_agent;
  lsu_driver lsu_drv;
  lsu_monitor lsu_mon;
  typedef virtual lsu_interface vif;
  vif lsu_agt_if;

  `uvm_component_utils_begin(lsu_agent)
  `uvm_component_utils_end

  function new(string name = "lsu_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    lsu_mon = lsu_monitor::type_id::create("lsu_mon", this);
    lsu_drv = lsu_driver::type_id::create("lsu_drv", this);
    if (!uvm_config_db#(vif)::get(this, "", "lsu_if", lsu_agt_if)) begin
      `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
    end
    uvm_config_db# (vif)::set(this,"lsu_drv","lsu_if",lsu_agt_if);
    uvm_config_db# (vif)::set(this,"lsu_mon","mon_if",lsu_agt_if);
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction

endclass: lsu_agent

`endif // LSU_AGENT__SV
