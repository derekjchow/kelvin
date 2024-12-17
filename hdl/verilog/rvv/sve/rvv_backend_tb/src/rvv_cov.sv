`ifndef RVV_COV__SV
`define RVV_COV__SV

class rvv_cov extends uvm_component;
   event cov_event;
   rvs_transaction tr;
   uvm_analysis_imp #(rvs_transaction, rvv_cov) cov_export;
   `uvm_component_utils(rvv_cov)
 
   covergroup cg_trans @(cov_event);
      // coverpoint tr.kind;
      // ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(rvs_transaction tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: rvv_cov

`endif // RVV_COV__SV

