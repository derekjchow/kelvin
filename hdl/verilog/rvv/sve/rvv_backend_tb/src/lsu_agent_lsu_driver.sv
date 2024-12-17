`ifndef LSU_DRIVER__SV
`define LSU_DRIVER__SV

typedef class lsu_transaction;
typedef class lsu_driver;

  //`uvm_analysis_imp_decl(_lsu_inst)

class lsu_driver extends uvm_driver # (lsu_transaction);

  //uvm_analysis_imp_lsu_inst #(rvs_transaction,rvv_behavior_model) inst_imp; 

  typedef virtual lsu_interface v_if; 
  v_if lsu_if;
  
  int max_delay = 10;
  int min_delay = 0;
  

  rvs_transaction inst_queue[$];

  `uvm_component_utils_begin(lsu_driver)
  `uvm_component_utils_end

  extern function new(string name = "lsu_driver", uvm_component parent = null); 
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task tx_driver();
  // extern function void write_lsu_inst(rvs_transaction inst_tr);

endclass: lsu_driver

function lsu_driver::new(string name = "lsu_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void lsu_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

function void lsu_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  uvm_config_db#(v_if)::get(this, "", "lsu_if", lsu_if);
endfunction: connect_phase

function void lsu_driver::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  if(lsu_if == null)
    `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void lsu_driver::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

task lsu_driver::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
  // ToDo: Reset output signals
endtask: reset_phase

task lsu_driver::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
  //ToDo: Configure your component here
endtask:configure_phase

task lsu_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork 
    tx_driver();
  join
endtask: run_phase

// function void lsu_driver::write_lsu_inst(rvs_transaction inst_tr);
//  inst_queue.push_back(inst_tr);
// endfunction

task lsu_driver::tx_driver();
  lsu_transaction lsu_tr;
  rvs_transaction inst_tr;
  int pc;
  int delay;
  lsu_tr = new("lsu_tr");
  inst_tr = new("inst_tr");
  forever begin
    @(posedge lsu_if.clk);
    /*
    if(lsu_if.rst_n) begin
      for(int i=0; i<`NUM_DP_UOP; i++) begin
        if(lsu_if.uop_valid[i]) begin
          if(pc == lsu_if.uop_lsu_rvv2rvs[i].uop_pc) begin
            if(inst_tr.inst_type == LD) begin
              lsu_tr.kind = LOAD;
              lsu_tr.value = $random();
              lsu_tr.byte_mask = lsu_if.uop_lsu_rvv2rvs[i]
            end
            if(inst_tr.inst_type == ST) begin
              store queue push;
            end
          end else begin
            inst_tr = inst_queue.pop_front();
            pc = inst_tr.pc;
            if(inst_tr.inst_type == LD) begin
              write to mdl;
            end
            if(inst_tr.inst_type == ST) begin
              write store to mdl;
              write to scb;
            end
          end
        end
      end
      begin
        if(delay == 0) begin
          dela
        end
      end
    end
    */

  end
endtask : tx_driver

`endif // LSU_DRIVER__SV


