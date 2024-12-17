`ifndef RVS_MONITOR_2COV_CONNECT
`define RVS_MONITOR_2COV_CONNECT
class rvs_monitor_2cov_connect extends uvm_component;
   rvv_cov cov;
   uvm_analysis_export # (rvs_transaction) an_exp;
   `uvm_component_utils(rvs_monitor_2cov_connect)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(rvs_transaction tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: rvs_monitor_2cov_connect

`endif // RVS_MONITOR_2COV_CONNECT
