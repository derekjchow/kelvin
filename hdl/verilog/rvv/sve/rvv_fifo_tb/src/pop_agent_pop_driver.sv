//
// Template for UVM-compliant physical-level transactor
//

`ifndef POP_DRICER__SV
`define POP_DRICER__SV

typedef class push_transaction;
typedef class pop_driver;

class pop_driver_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( pop_driver xactor,
                        push_transaction tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( pop_driver xactor,
                         push_transaction tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: pop_driver_callbacks


class pop_driver extends uvm_driver # (push_transaction);

   
   typedef virtual pop_interface v_if; 
   v_if drv_if;
   push_transaction tr;
   logic abnormal_test = 0; //generate illegal stimulation
   `uvm_register_cb(pop_driver,pop_driver_callbacks); 
   
   extern function new(string name = "pop_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(pop_driver)
      // ToDo: Add uvm driver member
      `uvm_component_utils_end
   // ToDo: Add required short hand override method


   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(push_transaction tr); 
   extern protected virtual task tx_driver();

endclass: pop_driver


function pop_driver::new(string name = "pop_driver",
                   uvm_component parent = null);
   super.new(name, parent);

   
endfunction: new


function void pop_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here
   if(uvm_config_db#(integer)::get(this, "", "abnormal_test", abnormal_test)) begin
      `uvm_info("debug info", " abnormal test, disable empty check from pop driver...", UVM_LOW)
   end
endfunction: build_phase

function void pop_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "slv_if", drv_if);
endfunction: connect_phase

function void pop_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void pop_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

 
task pop_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Reset output signals
endtask: reset_phase

task pop_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task pop_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork 
      tx_driver();
   join
   // phase.drop_objection(this);
endtask: run_phase


task pop_driver::tx_driver();
      push_transaction tr;
 forever begin
      @(posedge drv_if.clk);
      // ToDo: Set output signals to their idle state
      //this.drv_if.master.async_en      <= 0;
      `uvm_info("rvv_fifo_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
      //ToDO: update this logic to support pop_empty for illegal case
      if(drv_if.empty & !abnormal_test) begin
         `uvm_info("rvv_fifo_DRIVER", "fifo is empty, invalid all pop...", UVM_HIGH)
         tr.valid  = 1'b0;
         tr.valid1 = 1'b0;
         tr.valid2 = 1'b0;
         tr.valid3 = 1'b0;
      end
      //almost empty on;y allow pop0 to pop
      if(drv_if.almost_empty & !abnormal_test) begin
         `uvm_info("rvv_fifo_DRIVER", "fifo is almost empty, just leave first push...", UVM_HIGH)
         tr.valid1 = 0;
         tr.valid2 = 0;
         tr.valid3 = 0;
      end
	  `uvm_do_callbacks(pop_driver,pop_driver_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      `uvm_info("rvv_fifo_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("rvv_fifo_DRIVER", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(pop_driver,pop_driver_callbacks,
                    post_tx(this, tr))
      seq_item_port.item_done();

   end
endtask : tx_driver

task pop_driver::send(push_transaction tr);
   // ToDo: Drive signal on interface
   `ifdef FIFO_4W2R
      drv_if.pop3 = tr.valid3;
      drv_if.pop2 = tr.valid2;
      drv_if.pop1 = tr.valid1;
      drv_if.pop0 = tr.valid;
   `elsif FIFO_2W2R
      drv_if.pop1 = tr.valid1;
      drv_if.pop0 = tr.valid;
   `else
      drv_if.pop = tr.valid;
   `endif
   fork
      //ignore outdata in driver
      //@(posedge drv_if.clk);
      //tr.data = drv_if.outData;
   join_none
endtask: send


`endif // POP_DRICER__SV


