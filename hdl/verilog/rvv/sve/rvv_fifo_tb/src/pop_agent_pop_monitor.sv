//
// Template for UVM-compliant physical-level monitor
//

`ifndef POP_MONITOR__SV
`define POP_MONITOR__SV


typedef class check_transaction;
typedef class pop_monitor;

class pop_monitor_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use a task if callbacks can be blocking


   // Called at start of observed transaction
   virtual function void pre_trans(pop_monitor xactor,
                                   check_transaction tr);
   endfunction: pre_trans


   // Called before acknowledging a transaction
   virtual function pre_ack(pop_monitor xactor,
                            check_transaction tr);
   endfunction: pre_ack
   

   // Called at end of observed transaction
   virtual function void post_trans(pop_monitor xactor,
                                    check_transaction tr);
   endfunction: post_trans

   
   // Callback method post_cb_trans can be used for coverage
   virtual task post_cb_trans(pop_monitor xactor,
                              check_transaction tr);
   endtask: post_cb_trans

endclass: pop_monitor_callbacks

   

class pop_monitor extends uvm_monitor;

   uvm_analysis_port #(check_transaction) mon_analysis_port;  //TLM analysis port
   typedef virtual pop_interface v_if;
   v_if mon_if;
   // ToDo: Add another class property if required
   extern function new(string name = "pop_monitor",uvm_component parent);
   `uvm_register_cb(pop_monitor,pop_monitor_callbacks);
   `uvm_component_utils_begin(pop_monitor)
      // ToDo: Add uvm monitor member if any class property added later through field macros

   `uvm_component_utils_end
      // ToDo: Add required short hand override method


   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task tx_monitor();

endclass: pop_monitor


function pop_monitor::new(string name = "pop_monitor",uvm_component parent);
   super.new(name, parent);
   mon_analysis_port = new ("mon_analysis_port",this);
endfunction: new

function void pop_monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void pop_monitor::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "slv_if", mon_if);
endfunction: connect_phase

function void pop_monitor::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase); 
   //ToDo: Implement this phase here

endfunction: end_of_elaboration_phase


function void pop_monitor::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here

endfunction: start_of_simulation_phase


task pop_monitor::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Implement reset here

endtask: reset_phase


task pop_monitor::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task pop_monitor::run_phase(uvm_phase phase);
   super.run_phase(phase);
  // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork
      tx_monitor();
   join
  // phase.drop_objection(this);

endtask: run_phase


task pop_monitor::tx_monitor();
      check_transaction tr;
   `uvm_info("rvv_fifo_MONITOR", "Starting transaction...",UVM_LOW)
   forever begin
      @(negedge mon_if.clk);
      `ifdef FIFO_2W2R
         if(mon_if.pop0) begin
            tr = new("tr");
            tr.valid = 1;
            tr.data = mon_if.pop_data0;
            `uvm_info("rvv_fifo_MONITOR", tr.sprint(),UVM_HIGH)
            mon_analysis_port.write(tr);
         end
         if(mon_if.pop1) begin
            tr = new("tr");
            tr.valid = 1;
            tr.data = mon_if.pop_data1;
            `uvm_info("rvv_fifo_MONITOR1", tr.sprint(),UVM_HIGH)
            mon_analysis_port.write(tr);
         end
      `elsif FIFO_4W2R
         if(mon_if.pop0) begin
            tr = new("tr");
            tr.valid = 1;
            tr.data = mon_if.pop_data0;
            `uvm_info("rvv_fifo_MONITOR", tr.sprint(),UVM_HIGH)
            mon_analysis_port.write(tr);
         end
         if(mon_if.pop1) begin
            tr = new("tr");
            tr.valid = 1;
            tr.data = mon_if.pop_data1;
            `uvm_info("rvv_fifo_MONITOR1", tr.sprint(),UVM_HIGH)
            mon_analysis_port.write(tr);
         end
      `else
         if(mon_if.pop) begin
            tr = new("tr");
            tr.valid = 1;
            tr.data = mon_if.pop_data;
            `uvm_info("rvv_fifo_MONITOR", tr.sprint(),UVM_HIGH)
            mon_analysis_port.write(tr);
         end
      `endif
   end
endtask: tx_monitor

`endif // POP_MONITOR__SV
