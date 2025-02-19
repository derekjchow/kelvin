`ifndef RVV_COV__SV
`define RVV_COV__SV

class rvv_cov extends uvm_component;
  event cov_event;
  rvs_transaction tr;
  uvm_analysis_imp #(rvs_transaction, rvv_cov) cov_export;
  `uvm_component_utils(rvv_cov)

  function new(string name, uvm_component parent);
    super.new(name,parent);
    cov_export = new("Coverage Analysis",this);
    cg_trans = new();
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
  endfunction: build_phase
  virtual function void connect_phase(uvm_phase phase);
  endfunction: connect_phase

  virtual task main_phase(uvm_phase phase);
  endtask: main_phase

// rvs_transaction cov -----------------------------------------------
  virtual function write(rvs_transaction tr);
     this.tr = tr;
     -> cov_event;
  endfunction: write

  covergroup cg_trans @(cov_event);
     // coverpoint tr.kind;
     // ToDo: Add required coverpoints, coverbins
  endgroup: cg_trans

endclass: rvv_cov

`endif // RVV_COV__SV

