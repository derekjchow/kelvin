//
// Template for UVM-compliant Monitor to Coverage Connector Callbacks
//

`ifndef PUSH_MONITOR_2COV_CONNECT
`define PUSH_MONITOR_2COV_CONNECT
class push_monitor_2cov_connect extends uvm_component;
   rvv_fifo_cov cov;
   uvm_analysis_export # (check_transaction) an_exp;
   `uvm_component_utils(push_monitor_2cov_connect)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(check_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: push_monitor_2cov_connect

`endif // PUSH_MONITOR_2COV_CONNECT
