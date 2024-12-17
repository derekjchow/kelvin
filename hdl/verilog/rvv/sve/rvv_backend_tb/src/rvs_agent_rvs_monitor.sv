`ifndef RVS_MONITOR__SV
`define RVS_MONITOR__SV

/*
  TODO lsit:
    move rvs instruction transaction from drv to here.
*/
`include "rvv_backend.svh"
typedef class rvs_transaction;
typedef class rvs_monitor;

class rvs_monitor extends uvm_monitor;

  // uvm_analysis_port #(rvs_transaction) inst_ap; 
  uvm_analysis_port #(rvs_transaction) wb_ap;   

  typedef virtual rvs_interface v_if;
  v_if rvs_if;

  `uvm_component_utils_begin(rvs_monitor)
  `uvm_component_utils_end

  extern function new(string name = "rvs_monitor",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task tx_monitor();
  extern protected virtual task rx_monitor();

endclass: rvs_monitor


function rvs_monitor::new(string name = "rvs_monitor",uvm_component parent);
  super.new(name, parent);
  // inst_ap = new ("inst_ap",this);
endfunction: new

function void rvs_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  wb_ap = new("wb_ap", this);
endfunction: build_phase

function void rvs_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if)::get(this, "", "rvs_if", rvs_if))
    `uvm_fatal(get_type_name(), "Fail to get rvs_if!")
endfunction: connect_phase

task rvs_monitor::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask: reset_phase

task rvs_monitor::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

task rvs_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
     rx_monitor();
  join
endtask: run_phase

task rvs_monitor::tx_monitor();
  forever begin
  end
endtask: tx_monitor

task rvs_monitor::rx_monitor();
  logic [`NUM_RT_UOP-1:0] wb_event;
  rvs_transaction tr;
  tr = new();
  forever begin
    @(posedge rvs_if.clk);
    if(rvs_if.rst_n) begin
      wb_event = rvs_if.wb_event;
      foreach(wb_event[wb_idx]) begin
        if(wb_event[wb_idx]) begin
          if(rvs_if.wb_xrf_valid_wb2rvs[0] && rvs_if.wb_xrf_ready_wb2rvs[0]) begin
            tr.wb_xrf        = rvs_if.wb_xrf_wb2rvs[0];
            tr.wb_xrf_valid  = '1;
          end
          wb_ap.write(tr); // write to scb
        end
      end
    end
  end
endtask: rx_monitor

`endif // RVS_MONITOR__SV
