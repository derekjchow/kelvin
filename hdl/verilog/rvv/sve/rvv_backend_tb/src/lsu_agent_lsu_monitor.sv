`ifndef LSU_MONITOR__SV
`define LSU_MONITOR__SV


typedef class lsu_transaction;
typedef class lsu_monitor;
class lsu_monitor extends uvm_monitor;

  uvm_analysis_port #(lsu_transaction) mon_analysis_port;  //TLM analysis port
  typedef virtual lsu_interface v_if;
  v_if mon_if;
  extern function new(string name = "lsu_monitor",uvm_component parent);
  `uvm_component_utils_begin(lsu_monitor)
  `uvm_component_utils_end


  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task tx_monitor();

endclass: lsu_monitor


function lsu_monitor::new(string name = "lsu_monitor",uvm_component parent);
   super.new(name, parent);
   mon_analysis_port = new ("mon_analysis_port",this);
endfunction: new

function void lsu_monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction: build_phase

function void lsu_monitor::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if(!uvm_config_db#(v_if)::get(this, "", "mon_if", mon_if))
     `uvm_fatal(get_type_name(), "mon_if not set")
endfunction: connect_phase

task lsu_monitor::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
endtask: reset_phase

task lsu_monitor::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
endtask:configure_phase

task lsu_monitor::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork
      tx_monitor();
   join
endtask: run_phase


task lsu_monitor::tx_monitor();
   forever begin
      lsu_transaction tr;
      tr = new();
      @(posedge mon_if.clk);
   end
endtask: tx_monitor

`endif // LSU_MONITOR__SV
