`ifndef RVV_COV__SV
`define RVV_COV__SV

  `uvm_analysis_imp_decl(_inst_rx)
  `uvm_analysis_imp_decl(_inst_tx)
class rvv_cov extends uvm_component;
  event rx_cov_event, tx_cov_event;
  rvs_transaction tx_tr;
  rvs_transaction rx_tr;
  uvm_analysis_imp_inst_rx #(rvs_transaction, rvv_cov) inst_rx_cov_imp;
  uvm_analysis_imp_inst_tx #(rvs_transaction, rvv_cov) inst_tx_cov_imp;
  `uvm_component_utils(rvv_cov)

  function new(string name, uvm_component parent);
    super.new(name,parent);
    inst_rx_cov_imp = new("inst_rx_cov_imp ",this);
    inst_tx_cov_imp = new("inst_tx_cov_imp ",this);
    tx_tr = new();
    cg_rx_trans = new();
    rx_tr = new();
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
  endfunction: build_phase
  virtual function void connect_phase(uvm_phase phase);
  endfunction: connect_phase

  virtual task main_phase(uvm_phase phase);
  endtask: main_phase

// rvs_transaction cov -----------------------------------------------
  virtual function write_inst_rx(rvs_transaction tr);
    this.rx_tr = tr;
    -> rx_cov_event;
  endfunction: write_inst_rx
  virtual function write_inst_tx(rvs_transaction tr);
    this.tx_tr = tr;
    -> tx_cov_event;
  endfunction: write_inst_tx

  covergroup cg_rx_trans @(rx_cov_event);
    alu_inst:
      coverpoint rx_tr.alu_inst;
    vxsat:
      coverpoint rx_tr.vxsat[0];
    cross alu_inst, vxsat;
  endgroup: cg_rx_trans
endclass: rvv_cov

`endif // RVV_COV__SV

