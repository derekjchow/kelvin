`ifndef RVV_COV__SV
`define RVV_COV__SV

class rvv_cov extends uvm_component;
  event rx_cov_event, tx_cov_event;
  rvs_transaction tx_tr;
  rvs_transaction rx_tr;
  int vlmax_max = 8 * `VLEN / 8;
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
      this.rx_tr = tr;
      -> rx_cov_event;
    end else begin
      this.tx_tr = tr;
      -> tx_cov_event;
    end
  endfunction: write

  covergroup cg_tx_trans @(tx_cov_event);
    alu_inst:
      coverpoint tx_tr.alu_inst;
    alu_type:
      coverpoint tx_tr.alu_type {
        bins OPIVV = {rvv_tb_pkg::OPIVV};
        bins OPIVI = {rvv_tb_pkg::OPIVI};
        bins OPIVX = {rvv_tb_pkg::OPIVX};

        bins OPMVV = {rvv_tb_pkg::OPMVV};
        bins OPMVX = {rvv_tb_pkg::OPMVX};
        
        illegal_bins OPFVV = {rvv_tb_pkg::OPFVV};
        illegal_bins OPFVF = {rvv_tb_pkg::OPFVF};
        illegal_bins OPCFG = {rvv_tb_pkg::OPCFG};

        illegal_bins misc = default;
      }
    vm:
      coverpoint tx_tr.vm;
    vlmul:
      coverpoint tx_tr.vlmul {
        bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
        bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
        bins LMUL1   = {rvv_tb_pkg::LMUL1  };
        bins LMUL2   = {rvv_tb_pkg::LMUL2  };
        bins LMUL4   = {rvv_tb_pkg::LMUL4  };
        bins LMUL8   = {rvv_tb_pkg::LMUL8  };

        illegal_bins misc = default;
      }
    vsew:
      coverpoint tx_tr.vsew {
        bins SEW8  = {rvv_tb_pkg::SEW8 }; 
        bins SEW16 = {rvv_tb_pkg::SEW16};
        bins SEW32 = {rvv_tb_pkg::SEW32};

        illegal_bins misc = default;
      }
    vl:
      coverpoint tx_tr.vl {
        bins valid[] = {[0:vlmax_max]};
        illegal_bins misc = default;
      }
    vstart:
      coverpoint tx_tr.vstart {
        bins valid[] = {[0:vlmax_max-1]};
        illegal_bins misc = default;
      }
    vxrm:
      coverpoint tx_tr.vxrm {
        bins RNU = {rvv_tb_pkg::RNU};
        bins RNE = {rvv_tb_pkg::RNE};
        bins RDN = {rvv_tb_pkg::RDN};
        bins ROD = {rvv_tb_pkg::ROD};
        
        illegal_bins misc = default;
      }
  endgroup: cg_tx_trans

  covergroup cg_rx_trans @(rx_cov_event);
    alu_inst:
      coverpoint rx_tr.alu_inst;
    alu_type:
      coverpoint {rx_tr.inst_type, rx_tr.alu_type} {
        bins OPIVV = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPIVV};
        bins OPIVI = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPIVI};
        bins OPIVX = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPIVX};

        bins OPMVV = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPMVV};
        bins OPMVX = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPMVX};
        
        illegal_bins OPFVV = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPFVV};
        illegal_bins OPFVF = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPFVF};
        illegal_bins OPCFG = {rvv_tb_pkg::ALU, rvv_tb_pkg::OPCFG};
      }                                        
    vm:
      coverpoint rx_tr.vm;
    vlmul:
      coverpoint rx_tr.vlmul {
        bins LMUL1_4 = {rvv_tb_pkg::LMUL1_4};
        bins LMUL1_2 = {rvv_tb_pkg::LMUL1_2};
        bins LMUL1   = {rvv_tb_pkg::LMUL1  };
        bins LMUL2   = {rvv_tb_pkg::LMUL2  };
        bins LMUL4   = {rvv_tb_pkg::LMUL4  };
        bins LMUL8   = {rvv_tb_pkg::LMUL8  };

        illegal_bins misc = default;
      }
    vsew:
      coverpoint rx_tr.vsew {
        bins SEW8  = {rvv_tb_pkg::SEW8 }; 
        bins SEW16 = {rvv_tb_pkg::SEW16};
        bins SEW32 = {rvv_tb_pkg::SEW32};

        illegal_bins misc = default;
      }
    vl:
      coverpoint rx_tr.vl {
        bins valid[] = {[0:vlmax_max]};
        illegal_bins misc = default;
      }
    vstart:
      coverpoint rx_tr.vstart {
        bins valid[] = {[0:vlmax_max-1]};
        illegal_bins misc = default;
      }
    vxrm:
      coverpoint rx_tr.vxrm {
        bins RNU = {rvv_tb_pkg::RNU};
        bins RNE = {rvv_tb_pkg::RNE};
        bins RDN = {rvv_tb_pkg::RDN};
        bins ROD = {rvv_tb_pkg::ROD};
        
        illegal_bins misc = default;
      }
    vxsat:
      coverpoint rx_tr.vxsat[0];
    cross alu_inst, alu_type, vm, vlmul, vsew, vxrm, vxsat;
    cross alu_inst, alu_type, vm;
  endgroup: cg_rx_trans
endclass: rvv_cov

`endif // RVV_COV__SV

