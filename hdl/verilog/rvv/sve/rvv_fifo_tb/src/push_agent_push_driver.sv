//
// Template for UVM-compliant physical-level transactor
//

`ifndef PUSH_DRIVER__SV
`define PUSH_DRIVER__SV

typedef class push_transaction;
typedef class push_driver;

class push_driver_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( push_driver xactor,
                        push_transaction tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( push_driver xactor,
                         push_transaction tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: push_driver_callbacks


class push_driver extends uvm_driver # (push_transaction);

   
   typedef virtual push_interface v_if; 
   v_if drv_if;
   `uvm_register_cb(push_driver,push_driver_callbacks); 

   logic abnormal_test = 0; //generate illegal stimulation
   
   extern function new(string name = "push_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(push_driver)
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

endclass: push_driver


function push_driver::new(string name = "push_driver",
                   uvm_component parent = null);
   super.new(name, parent);

   
endfunction: new


function void push_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here
   if(uvm_config_db#(integer)::get(this, "", "abnormal_test", abnormal_test)) begin
      `uvm_info("debug info", " abnormal test, disable full check from push driver...", UVM_LOW)
   end
endfunction: build_phase

function void push_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "mst_if", drv_if);
endfunction: connect_phase

function void push_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void push_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

 
task push_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Reset output signals
endtask: reset_phase

task push_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task push_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork 
      tx_driver();
   join
   // phase.drop_objection(this);
endtask: run_phase


task push_driver::tx_driver();
      push_transaction tr;
 forever begin
      @(posedge drv_if.clk);
      `uvm_info("rvv_fifo_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.try_next_item(tr);
	  //`uvm_do_callbacks(push_driver,push_driver_callbacks,
     //               pre_tx(this, tr))
      //check if fifo has enough entry
      if(tr != null) begin
         if(drv_if.full & !abnormal_test) begin
            `uvm_info("rvv_fifo_DRIVER", "fifo is full, invalid all push...", UVM_HIGH)
            tr.valid  = 1'b0;
            tr.valid1 = 1'b0;
            tr.valid2 = 1'b0;
            tr.valid3 = 1'b0;
         end
         if(drv_if.almost_full & !abnormal_test) begin
            `uvm_info("rvv_fifo_DRIVER1", "fifo is almost full, just leave first push...", UVM_HIGH)
            tr.valid1 = 0;
            tr.valid2 = 0;
            tr.valid3 = 0;
         end
         if(drv_if.almost_full2 & !abnormal_test) begin
            `uvm_info("rvv_fifo_DRIVER2", "fifo is almost full, just leave first push...", UVM_HIGH)
            tr.valid2 = 0;
            tr.valid3 = 0;
         end
         if(drv_if.almost_full3 & !abnormal_test) begin
            `uvm_info("rvv_fifo_DRIVER3", "fifo is almost full, just leave first push...", UVM_HIGH)
            tr.valid2 = 0;
            tr.valid3 = 0;
         end
         send(tr); 
         seq_item_port.item_done();
         `uvm_info("rvv_fifo_DRIVER4", "Completed transaction...",UVM_LOW)
         `uvm_info("rvv_fifo_DRIVER5", tr.sprint(),UVM_HIGH)
      end
      else begin
         tr = new("tr");
         tr.valid  = 1'b0;
         tr.valid1 = 1'b0;
         tr.valid2 = 1'b0;
         tr.valid3 = 1'b0;
         send(tr); 
      end
      //`uvm_do_callbacks(push_driver,push_driver_callbacks,
      //              post_tx(this, tr))

   end
endtask : tx_driver

task push_driver::send(push_transaction tr);
   // ToDo: Drive signal on interface
   `ifdef FIFO_2W2R
     drv_if.push0   = tr.valid;
     drv_if.push1   = tr.valid1;
     drv_if.push_data0 = tr.data;
     drv_if.push_data1 = tr.data1;
   `elsif FIFO_4W2R
     drv_if.push0   = tr.valid;
     drv_if.push1   = tr.valid1;
     drv_if.push2   = tr.valid2;
     drv_if.push3   = tr.valid3;
     drv_if.push_data0 = tr.data;
     drv_if.push_data1 = tr.data1;
     drv_if.push_data2 = tr.data2;
     drv_if.push_data3 = tr.data3;
   `else
      drv_if.push   = tr.valid;
      drv_if.push_data = tr.data;
   `endif
   //ToDo: update for 4W2R
endtask: send


`endif // PUSH_DRIVER__SV


