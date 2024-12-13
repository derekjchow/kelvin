//
// Template for UVM-compliant Coverage Class
//

`ifndef RVV_FIFO_COV__SV
`define RVV_FIFO_COV__SV

class rvv_fifo_cov extends uvm_component;
   event cov_event;
   check_transaction tr;
   uvm_analysis_imp #(check_transaction, rvv_fifo_cov) cov_export;
   `uvm_component_utils(rvv_fifo_cov)
 
   //covergroup cg_trans @(cov_event);
   //   coverpoint tr.kind;
   //   // ToDo: Add required coverpoints, coverbins
   //endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      //cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(check_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: rvv_fifo_cov

`endif // RVV_FIFO_COV__SV

