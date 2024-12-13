//
// Template for UVM Scoreboard

`ifndef DATA_CHECK__SV
`define DATA_CHECK__SV


class data_check extends uvm_scoreboard;

   uvm_analysis_export #(check_transaction) before_export, after_export;
   uvm_in_order_class_comparator #(check_transaction) comparator;

   `uvm_component_utils(data_check)
	extern function new(string name = "data_check",
                    uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);

endclass: data_check


function data_check::new(string name = "data_check",
                 uvm_component parent);
   super.new(name,parent);
endfunction: new

function void data_check::build_phase(uvm_phase phase);
    super.build_phase(phase);
    before_export = new("before_export", this);
    after_export  = new("after_export", this);
    comparator    = new("comparator", this);
endfunction:build_phase

function void data_check::connect_phase(uvm_phase phase);
    before_export.connect(comparator.before_export);
    after_export.connect(comparator.after_export);
endfunction:connect_phase

task data_check::main_phase(uvm_phase phase);
   `uvm_info("debug info", "This is data checker's main phase, please update me...", UVM_LOW)
    super.main_phase(phase);
	 comparator.run();
endtask: main_phase 

function void data_check::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SBRPT", $psprintf("Matches = %0d, Mismatches = %0d",
               comparator.m_matches, comparator.m_mismatches),
               UVM_MEDIUM);
endfunction:report_phase

`endif // DATA_CHECK__SV
