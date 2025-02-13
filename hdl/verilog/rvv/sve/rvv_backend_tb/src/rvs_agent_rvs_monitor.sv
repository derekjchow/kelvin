`ifndef RVS_MONITOR__SV
`define RVS_MONITOR__SV

`include "rvv_backend.svh"
typedef class rvs_transaction;
typedef class rvs_monitor;

  `uvm_analysis_imp_decl(_rvs_mon_inst)
class rvs_monitor extends uvm_monitor;

  uvm_analysis_imp_rvs_mon_inst #(rvs_transaction,rvs_monitor) inst_imp; 

  uvm_analysis_port #(rvs_transaction) inst_ap; 
  uvm_analysis_port #(rvs_transaction) rt_ap;   

  typedef virtual rvs_interface v_if;
  v_if rvs_if;

  rvs_transaction inst_tx_queue[$];
  rvs_transaction inst_rx_queue[$];

  int total_inst = 0;
  int executed_inst = 0;

  int inst_tx_timeout_max = 500;
  int inst_tx_timeout_cnt = 0;

  `uvm_component_utils_begin(rvs_monitor)
  `uvm_component_utils_end

  extern function new(string name = "rvs_monitor",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void final_phase(uvm_phase phase);
  extern protected virtual task tx_monitor();
  extern protected virtual task rx_monitor();
  extern protected virtual task rx_timeout_monitor();

  // imp task
  extern virtual function void write_rvs_mon_inst(rvs_transaction inst_tr);

endclass: rvs_monitor


function rvs_monitor::new(string name = "rvs_monitor",uvm_component parent);
  super.new(name, parent);
endfunction: new

function void rvs_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  inst_imp = new("inst_imp", this);
  inst_ap = new ("inst_ap",this);
  rt_ap = new ("rt_ap",this);
endfunction: build_phase

function void rvs_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if)::get(this, "", "rvs_if", rvs_if))
    `uvm_fatal(get_type_name(), "Fail to get rvs_if!")
endfunction: connect_phase

task rvs_monitor::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask: reset_phase

task rvs_monitor::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

function void rvs_monitor::final_phase(uvm_phase phase);
  super.final_phase(phase);
  if(inst_rx_queue.size()>0) begin
    `uvm_error("FINAL_CHECK", "inst_rx_queue in RVS_MON wasn't empty!")
    foreach(inst_rx_queue[idx]) begin
      `uvm_error("FINAL_CHECK",inst_rx_queue[idx].sprint())
    end
  end
  uvm_config_db#(int)::set(uvm_root::get(), "", "rvv_total_inst", this.total_inst);
  uvm_config_db#(int)::set(uvm_root::get(), "", "rvv_excuted_inst", this.executed_inst);
  `uvm_info("FINAL_CHECK", $sformatf("RVV total accepted inst: %0d, executed inst: %0d, discarded %.2f%%", 
                                      this.total_inst, this.executed_inst, real'(this.total_inst - this.executed_inst)*100.0/real'(this.total_inst)), UVM_LOW)
endfunction: final_phase 

task rvs_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
     tx_monitor();
     rx_monitor();
     rx_timeout_monitor();
  join
endtask: run_phase

task rvs_monitor::tx_monitor();
  rvs_transaction inst_tr;
  rvs_transaction rt_tr;
  forever begin
    @(posedge rvs_if.clk);
    if(rvs_if.rst_n) begin
      for(int i=0; i<`ISSUE_LANE; i++) begin
        if(rvs_if.insts_valid_rvs2cq[i] && rvs_if.insts_ready_cq2rvs[i]) begin
          inst_tr = new("inst_tr");
          inst_tr = inst_tx_queue.pop_front();
          `uvm_info(get_type_name(), $sformatf("Send transaction to mdl"),UVM_HIGH)
          `uvm_info(get_type_name(), inst_tr.sprint(),UVM_HIGH)
          `uvm_info("INST_TR", inst_tr.sprint(),UVM_LOW)
          `uvm_info("ASM_DUMP",$sformatf("0x%8x\t%s", inst_tr.pc, inst_tr.asm_string),UVM_LOW)
          inst_ap.write(inst_tr); // write to mdl
          rt_tr = new("rt_tr");
          rt_tr.copy(inst_tr);
          // rt_tr.is_rt = 1;
          inst_rx_queue.push_back(rt_tr);
          this.total_inst++;
        end
      end
    end
  end
endtask: tx_monitor

task rvs_monitor::rx_monitor();
  rvs_transaction tr;
  logic [`VLENB-1:0] rt_vrf_byte_strobe;
  logic [`VLEN-1:0] rt_vrf_bit_strobe;
  bit vrf_overlap;
  tr = new("tr");
  forever begin
    @(posedge rvs_if.clk);
    if(rvs_if.rst_n) begin
      // `uvm_info(get_type_name(),$sformatf("rt_uop=0x%1x, rt_last_uop=0x%1x",rvs_if.rt_uop, rvs_if.rt_last_uop), UVM_HIGH)
      for(int rt_idx=0; rt_idx<`NUM_RT_UOP; rt_idx++) begin
        if(rvs_if.rt_uop[rt_idx]) begin
          while(!(rvs_if.rt_vrf_valid_rob2rt[rt_idx] && (rvs_if.rt_vrf_data_rob2rt[rt_idx].uop_pc === tr.pc)) && 
                !(rvs_if.rt_xrf_valid_rvv2rvs[rt_idx] && rvs_if.rt_xrf_ready_rvs2rvv[rt_idx] && (rvs_if.rt_xrf_rvv2rvs[rt_idx].uop_pc === tr.pc))) begin
              `uvm_info(get_type_name(), $sformatf("Monitor rx_queue pc(0x%8x) mismatch with DUT pc(0x%8x), discarded.", tr.pc, rvs_if.rt_vrf_data_rob2rt[rt_idx].uop_pc), UVM_HIGH)
              `uvm_info(get_type_name(), tr.sprint(),UVM_HIGH)
              tr = inst_rx_queue.pop_front();
          end
          // VRF
          if(rvs_if.rt_vrf_valid_rob2rt[rt_idx]) begin
            vrf_overlap = 0;
            rt_vrf_byte_strobe = rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_strobe;
            for(int i=0; i<`VLENB; i++) begin
              rt_vrf_bit_strobe[i*8 +: 8] = {8{rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_strobe[i]}}; 
            end 
            foreach(tr.rt_vrf_index[i]) begin
              if(tr.rt_vrf_index[i] == rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_index) begin
                tr.rt_vrf_strobe[i] |= rt_vrf_byte_strobe;
                tr.rt_vrf_data[i]   = rt_vrf_bit_strobe & rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_data | ~rt_vrf_bit_strobe & tr.rt_vrf_data[i];
                vrf_overlap = 1;
                `uvm_info(get_type_name(), $sformatf("Uops %0d also write vrf[%0d].", rt_idx, rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_index), UVM_HIGH)
              end
            end
            if(!vrf_overlap) begin
              tr.rt_vrf_index.push_back(rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_index);
              tr.rt_vrf_strobe.push_back(rt_vrf_byte_strobe);
              tr.rt_vrf_data.push_back(rvs_if.rt_vrf_data_rob2rt[rt_idx].rt_data);
            end
          end

          // XRF
          if(rvs_if.rt_xrf_valid_rvv2rvs[rt_idx] && rvs_if.rt_xrf_ready_rvs2rvv[rt_idx]) begin
            tr.rt_xrf_index.push_back(rvs_if.rt_xrf_rvv2rvs[rt_idx].rt_index);
            tr.rt_xrf_data.push_back(rvs_if.rt_xrf_rvv2rvs[rt_idx].rt_data);
          end

          // VXSAT
          if((tr.vxsat !== 1) && rvs_if.wr_vxsat_valid[rt_idx]) begin
            tr.vxsat        = rvs_if.wr_vxsat[rt_idx];
            tr.vxsat_valid  = rvs_if.wr_vxsat_valid[rt_idx];
          end else begin
            tr.vxsat        = tr.vxsat;
            tr.vxsat_valid  = tr.vxsat_valid;
          end

          // LAST_UOP
          if(rvs_if.rt_last_uop[rt_idx]) begin
            tr.is_rt = 1;
            // Avoid x-state
            if(tr.vxsat !== 1) tr.vxsat = '0;
            if(tr.vxsat_valid !== 1) tr.vxsat_valid = '0;
            `uvm_info(get_type_name(), $sformatf("Send rt transaction to scb"),UVM_HIGH)
            `uvm_info(get_type_name(), tr.sprint(),UVM_HIGH)
            rt_ap.write(tr); // write to scb
            this.executed_inst++;
            tr = new("tr");
          end
        end
      end
    end
  end
endtask: rx_monitor

task rvs_monitor::rx_timeout_monitor();
  // Timeout of inst port handshake check.
  if(|rvs_if.insts_valid_rvs2cq) begin
    inst_tx_timeout_cnt++;
  end
  if(|(rvs_if.insts_valid_rvs2cq & rvs_if.insts_ready_cq2rvs)) begin
    inst_tx_timeout_cnt = 0;
  end
  if(inst_tx_timeout_cnt >= inst_tx_timeout_max) begin
    `uvm_fatal(get_type_name(), $sformatf("Insts haven't been accepted by rvv for %0d cycles. Shut down!",inst_tx_timeout_cnt))
  end
endtask: rx_timeout_monitor

function void rvs_monitor::write_rvs_mon_inst(rvs_transaction inst_tr);
  `uvm_info(get_type_name(), "get a inst", UVM_HIGH)
  `uvm_info(get_type_name(), inst_tr.sprint(), UVM_HIGH)
  inst_tx_queue.push_back(inst_tr);
endfunction
`endif // RVS_MONITOR__SV
