`ifndef LSU_AGENT__SV
`define LSU_AGENT__SV

class lsu_agent extends uvm_agent;
   // ToDo: add sub environment properties here
   protected uvm_active_passive_enum is_active = UVM_ACTIVE;
   lsu_driver lsu_drv;
   lsu_monitor lsu_mon;
   lsu_sequencer lsu_seqr;
   typedef virtual lsu_interface vif;
   vif lsu_agt_if;

   `uvm_component_utils_begin(lsu_agent)
    //ToDo: add field utils macros here if required
   `uvm_component_utils_end

      // ToDo: Add required short hand override method

   function new(string name = "lsu_agt", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      lsu_mon = lsu_monitor::type_id::create("lsu_mon", this);
      if (is_active == UVM_ACTIVE) begin
         lsu_drv = lsu_driver::type_id::create("drv", this);
         lsu_seqr = lsu_sequencer::type_id::create("lsu_seqr",this);
      end
      if (!uvm_config_db#(vif)::get(this, "", "lsu_if", lsu_agt_if)) begin
         `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
      end
      uvm_config_db# (vif)::set(this,"lsu_drv","lsu_if",lsu_agt_if);
      // uvm_config_db# (vif)::set(this,"mast_mon","lsu_if",lsu_mon.mon_if);
      uvm_config_db# (vif)::set(this,"lsu_mon","mon_if",lsu_agt_if);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (is_active == UVM_ACTIVE) begin
		  
	   	  lsu_drv.seq_item_port.connect(lsu_seqr.seq_item_export);
      end
   endfunction

   virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);

      //ToDo :: Implement here

   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
     // phase.raise_objection(this,"lsu_agt_main"); //Raise/drop objections in sequence file

      //ToDo :: Implement here

      // phase.drop_objection(this);
   endtask

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      //ToDo :: Implement here

   endfunction

endclass: lsu_agent

`endif // LSU_AGENT__SV
