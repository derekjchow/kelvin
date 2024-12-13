//
// Template for UVM-compliant generic master agent
//

`ifndef PUSH_AGENT__SV
`define PUSH_AGENT__SV


class push_agent extends uvm_agent;
   // ToDo: add uvm agent properties here
   protected uvm_active_passive_enum is_active = UVM_ACTIVE;
   push_sequencer mast_sqr;
   push_driver mast_drv;
   push_monitor mast_mon;
   typedef virtual push_interface vif;
   vif mast_agt_if; 

   `uvm_component_utils_begin(push_agent)
   //ToDo: add field utils macros here if required
	`uvm_component_utils_end

      // ToDo: Add required short hand override method

   function new(string name = "mast_agt", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mast_mon = push_monitor::type_id::create("mast_mon", this);
      if (is_active == UVM_ACTIVE) begin
         mast_sqr = push_sequencer::type_id::create("mast_sqr", this);
         mast_drv = push_driver::type_id::create("mast_drv", this);
      end
      if (!uvm_config_db#(vif)::get(this, "", "mst_if", mast_agt_if)) begin
         `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
      end
      uvm_config_db# (vif)::set(this,"mast_drv","mst_if",mast_drv.drv_if);
      uvm_config_db# (vif)::set(this,"mast_mon","mst_if",mast_mon.mon_if);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (is_active == UVM_ACTIVE) begin
   		  mast_drv.seq_item_port.connect(mast_sqr.seq_item_export);
      end
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      // phase.raise_objection(this,"slv_agt_run"); //Raise/drop objections in sequence file

      //ToDo :: Implement here

      // phase.drop_objection(this);
   endtask

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      //ToDo :: Implement here

   endfunction

endclass: push_agent
 
`endif // PUSH_AGENT__SV

