`ifndef RVV_COV__SV
`define RVV_COV__SV

class rvv_cov extends uvm_component;
  event rx_cov_event, tx_cov_event;
  rvs_transaction tx_tr;
  rvs_transaction rx_tr;
  uvm_analysis_imp #(rvs_transaction, rvv_cov) cov_imp;
  `uvm_component_utils(rvv_cov)

  function new(string name, uvm_component parent);
    super.new(name,parent);
    cov_imp = new("Coverage Analysis",this);
    cg_tx_trans = new();
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
  virtual function write(rvs_transaction tr);
    if(tr.is_rt) begin
      this.rx_tr = rx_tr;
      -> rx_cov_event;
    end else begin
      this.tx_tr = tx_tr;
      -> tx_cov_event;
    end
  endfunction: write

  covergroup cg_tx_trans @(tx_cov_event);
  //   alu_inst:
  //     coverpoint {tx_tr.alu_inst};
  //   alu_type:
  //     coverpoint {tx_tr.alu_type};
  //   vm:
  //     coverpoint {tx_tr.vm};
  //   vlmul:
  //     coverpoint {tx_tr.vtype.vlmul};
  //   vsew:
  //     coverpoint {tx_tr.vtype.vsew};
  //   vl:
  //     coverpoint {tx_tr.vl};
  //   vstart:
  //     coverpoint {tx_tr.vstart};
  //   vxrm:
  //     coverpoint {tx_tr.vxrm};
  //   cross alu_inst, alu_type, vm, vlmul, vsew, vl, vstart, vxrm;
  endgroup: cg_tx_trans

  covergroup cg_rx_trans @(rx_cov_event);
    alu_inst:
      coverpoint {rx_tr.alu_inst};
    alu_type:
      coverpoint {rx_tr.alu_type};
    vm:
      coverpoint {rx_tr.vm};
    vlmul:
      coverpoint {rx_tr.vtype.vlmul};
    vsew:
      coverpoint {rx_tr.vtype.vsew};
    vl:
      coverpoint {rx_tr.vl};
    vstart:
      coverpoint {rx_tr.vstart};
    vxrm:
      coverpoint {rx_tr.vxrm};
    vxsat:
      coverpoint {rx_tr.vxsat};
    cross alu_inst, alu_type, vm, vlmul, vsew, vl, vstart, vxrm, vxsat;
  endgroup: cg_rx_trans
endclass: rvv_cov

`endif // RVV_COV__SV

