`ifndef RVV_BACKEND_ENV__SV
`define RVV_BACKEND_ENV__SV

`include "rvv_backend_tb.sv"

class rvv_backend_env extends uvm_env;
  rvv_scoreboard scb;
  rvs_agent rvs_agt;
  lsu_agent lsu_agt;
  rvv_cov cov;
  
  rvv_behavior_model mdl;

  `uvm_component_utils(rvv_backend_env)

  extern function new(string name="rvv_backend_env", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);

endclass: rvv_backend_env

function rvv_backend_env::new(string name= "rvv_backend_env",uvm_component parent=null);
  super.new(name,parent);
endfunction:new

function void rvv_backend_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  rvs_agt = rvs_agent::type_id::create("rvs_agt",this); 
  lsu_agt = lsu_agent::type_id::create("lsu_agt",this);
 
  cov = rvv_cov::type_id::create("cov",this); //Instantiating the coverage class

  scb = rvv_scoreboard::type_id::create("scb",this);

  mdl = rvv_behavior_model::type_id::create("mdl",this);
endfunction: build_phase

function void rvv_backend_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // ref_mdl ap
  rvs_agt.rvs_mon.inst_ap.connect(mdl.inst_imp);
  rvs_agt.rvs_mon.inst_ap.connect(lsu_agt.lsu_drv.inst_imp);
  // rvs_agt.rvs_drv.inst_ap.connect(mdl.inst_imp);
  rvs_agt.rvs_drv.vrf_state_port.connect(rvs_agt.vrf_mon.vrf_state_imp);
  rvs_agt.rvs_drv.rvv_state_port.connect(rvs_agt.rvs_mon.rvv_state_imp);
  // lsu_agt.lsu_mon.mon_analysis_port.connect(scb.lsu_imp);

  // ctrl ap
  rvs_agt.rvs_mon.ctrl_ap.connect(scb.ctrl_imp);

  // retire check ap
  rvs_agt.rvs_mon.rt_ap.connect(scb.rvs_imp);
  mdl.rt_ap.connect(scb.mdl_imp);

  // trap info ap
  lsu_agt.lsu_drv.trap_ap.connect(rvs_agt.rvs_drv.trap_imp);
  lsu_agt.lsu_drv.trap_ap.connect(mdl.trap_imp);

  // vrf check ap
  rvs_agt.vrf_mon.vrf_ap.connect(scb.rvs_vrf_imp);
  mdl.vrf_ap.connect(scb.mdl_vrf_imp);

  // memory access check ap
  lsu_agt.lsu_drv.mem.mem_ap.connect(scb.lsu_mem_imp);
  mdl.mem.mem_ap.connect(scb.mdl_mem_imp);

  // cov ap
  rvs_agt.rvs_mon.inst_ap.connect(cov.inst_tx_cov_imp);
  rvs_agt.rvs_mon.rt_ap.connect(cov.inst_rx_cov_imp);
endfunction: connect_phase

function void rvv_backend_env::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  `ifdef UVM_VERSION_1_0
  uvm_top.print_topology();  
  factory.print();          
  `endif
  
  `ifdef UVM_VERSION_1_1
   uvm_root::get().print_topology(); 
   uvm_factory::get().print();      
  `endif

  `ifdef UVM_POST_VERSION_1_1
   uvm_root::get().print_topology(); 
   uvm_factory::get().print();      
  `endif

endfunction: start_of_simulation_phase

task rvv_backend_env::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask:reset_phase

task rvv_backend_env::configure_phase (uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

task rvv_backend_env::run_phase(uvm_phase phase);
  super.run_phase(phase);
endtask:run_phase

function void rvv_backend_env::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction:report_phase

task rvv_backend_env::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);
endtask:shutdown_phase
`endif // RVV_BACKEND_ENV__SV

