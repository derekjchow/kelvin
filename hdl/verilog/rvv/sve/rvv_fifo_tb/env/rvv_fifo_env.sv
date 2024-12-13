//
// Template for UVM-compliant verification environment
//

`ifndef RVV_FIFO_ENV__SV
`define RVV_FIFO_ENV__SV
`include "rvv_fifo.sv"
//ToDo: Include required files here
//Including all the required component files here
class rvv_fifo_env extends uvm_env;
   data_check sb;
   push_agent master_agent;
   pop_agent slave_agent;
   rvv_fifo_cov cov;
   
   push_monitor_2cov_connect mon2cov;


    `uvm_component_utils(rvv_fifo_env)

   extern function new(string name="rvv_fifo_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: rvv_fifo_env

function rvv_fifo_env::new(string name= "rvv_fifo_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void rvv_fifo_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   master_agent = push_agent::type_id::create("master_agent",this); 
   slave_agent = pop_agent::type_id::create("slave_agent",this);
 
   //ToDo: Register other components,callbacks and TLM ports if added by user  

   cov = rvv_fifo_cov::type_id::create("cov",this); //Instantiating the coverage class

   mon2cov  = push_monitor_2cov_connect::type_id::create("mon2cov", this);
   mon2cov.cov = cov;
   sb = data_check::type_id::create("sb",this);
   // ToDo: To enable backdoor access specify the HDL path
   // ToDo: Register any required callbacks
endfunction: build_phase

function void rvv_fifo_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //Connecting the monitor's analysis ports with data_check's expected analysis exports.
   master_agent.mast_mon.mon_analysis_port.connect(sb.before_export);
   slave_agent.slv_mon.mon_analysis_port.connect(sb.after_export);
   //Other monitor element will be connected to the after export of the scoreboard
   master_agent.mast_mon.mon_analysis_port.connect(cov.cov_export);
   
   //set checher's VERBOSITY to UVM_HIGH
   sb.set_report_verbosity_level(UVM_HIGH);

endfunction: connect_phase

function void rvv_fifo_env::start_of_simulation_phase(uvm_phase phase);
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

   //ToDo : Implement this phase here 
endfunction: start_of_simulation_phase


task rvv_fifo_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   //ToDo: Reset DUT
endtask:reset_phase

task rvv_fifo_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure components here
endtask:configure_phase

task rvv_fifo_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
   //ToDo: Run your simulation here
endtask:run_phase

function void rvv_fifo_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
   //ToDo: Implement this phase here
endfunction:report_phase

task rvv_fifo_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
   //ToDo: Implement this phase here
endtask:shutdown_phase
`endif // RVV_FIFO_ENV__SV

