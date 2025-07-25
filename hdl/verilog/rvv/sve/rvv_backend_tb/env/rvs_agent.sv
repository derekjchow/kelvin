`ifndef RVS_AGENT__SV
`define RVS_AGENT__SV

class rvs_agent extends uvm_agent;
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  rvs_sequencer rvs_sqr;
  rvs_driver rvs_drv;
  rvs_monitor rvs_mon;
  vrf_monitor vrf_mon;
  typedef virtual rvs_interface v_if1;
  typedef virtual vrf_interface v_if3;
  v_if1 rvs_agt_if; 
  v_if3 vrf_agt_if; 

  `uvm_component_utils_begin(rvs_agent)
	`uvm_component_utils_end

  function new(string name = "rvs_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rvs_mon = rvs_monitor::type_id::create("rvs_mon", this);
    vrf_mon = vrf_monitor::type_id::create("vrf_mon", this);
    if(is_active == UVM_ACTIVE) begin
      rvs_sqr = rvs_sequencer::type_id::create("rvs_sqr", this);
      rvs_drv = rvs_driver::type_id::create("rvs_drv", this);
      rvs_mon.is_active = UVM_ACTIVE;
    end else begin
      rvs_mon.is_active = UVM_PASSIVE;
    end
    if(!uvm_config_db#(v_if1)::get(this, "", "rvs_if", rvs_agt_if)) begin
      `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
    end
    if(!uvm_config_db#(v_if3)::get(this, "", "vrf_if", vrf_agt_if)) begin
      `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
    end
    uvm_config_db# (v_if1)::set(this,"rvs_drv","rvs_if",rvs_agt_if);
    uvm_config_db# (v_if1)::set(this,"rvs_mon","rvs_if",rvs_agt_if);
    uvm_config_db# (v_if3)::set(this,"rvs_drv","vrf_if",vrf_agt_if);
    uvm_config_db# (v_if3)::set(this,"vrf_mon","vrf_if",vrf_agt_if);
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
  	  rvs_drv.seq_item_port.connect(rvs_sqr.seq_item_export);
    end
    rvs_drv.inst_ap.connect(rvs_mon.inst_imp);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction

endclass: rvs_agent
 
`endif // RVS_AGENT__SV

