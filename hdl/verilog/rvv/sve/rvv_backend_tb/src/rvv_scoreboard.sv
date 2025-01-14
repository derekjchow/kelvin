`ifndef RVV_SCOREBOARD__SV
`define RVV_SCOREBOARD__SV

`include "rvv_backend.svh"
`include "rvv_backend_define.svh"

  `uvm_analysis_imp_decl(_rvs)
  `uvm_analysis_imp_decl(_mdl) 
  `uvm_analysis_imp_decl(_rvs_vrf)
  `uvm_analysis_imp_decl(_mdl_vrf) 

class rvv_scoreboard extends uvm_scoreboard;

  typedef virtual rvs_interface v_if1;
  v_if1 rvs_if;  

  uvm_analysis_imp_rvs #(rvs_transaction,rvv_scoreboard) rvs_imp;
  uvm_analysis_imp_mdl #(rvs_transaction,rvv_scoreboard) mdl_imp;
  uvm_analysis_imp_rvs_vrf #(vrf_transaction,rvv_scoreboard) rvs_vrf_imp;
  uvm_analysis_imp_mdl_vrf #(vrf_transaction,rvv_scoreboard) mdl_vrf_imp;
  // uvm_analysis_imp_mdl #(lsu_transaction,rvv_scoreboard) lsu_imp;
  
  rvs_transaction rt_queue_rvs[$];
  rvs_transaction rt_queue_mdl[$];
  vrf_transaction vrf_queue_rvs[$];
  vrf_transaction vrf_queue_mdl[$];

  `uvm_component_utils(rvv_scoreboard)
	extern function new(string name = "rvv_scoreboard", uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
	extern virtual function void final_phase(uvm_phase phase);
 	extern function void write_rvs(rvs_transaction tr);
	extern function void write_mdl(rvs_transaction tr);
  extern function void write_rvs_vrf(vrf_transaction tr);
  extern function void write_mdl_vrf(vrf_transaction tr);
	extern virtual task rt_checker();
	extern virtual task vrf_checker();

endclass: rvv_scoreboard


function rvv_scoreboard::new(string name = "rvv_scoreboard", uvm_component parent);
  super.new(name,parent);
endfunction: new

function void rvv_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  rvs_imp = new("rvs_imp", this);
  mdl_imp = new("mdl_imp", this);
  rvs_vrf_imp = new("rvs_vrf_imp", this);
  mdl_vrf_imp = new("mdl_vrf_imp", this);
endfunction:build_phase

function void rvv_scoreboard::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if1)::get(this, "", "rvs_if", rvs_if)) begin
    `uvm_fatal("SCB/NOVIF", "No virtual interface specified for this agent instance")
  end
endfunction:connect_phase

task rvv_scoreboard::main_phase(uvm_phase phase);
  super.main_phase(phase);
  fork
    rt_checker();
    vrf_checker();
  join
endtask: main_phase 

function void rvv_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction:report_phase

function void rvv_scoreboard::write_rvs(rvs_transaction tr);
  `uvm_info("DEBUG", "get a wb inst from dut", UVM_HIGH)
  `uvm_info("DEBUG", tr.sprint(), UVM_HIGH)
  rt_queue_rvs.push_back(tr);
endfunction

function void rvv_scoreboard::write_mdl(rvs_transaction tr);
  `uvm_info("DEBUG", "get a wb inst from mdl", UVM_HIGH)
  `uvm_info("DEBUG", tr.sprint(), UVM_HIGH)
  rt_queue_mdl.push_back(tr);
endfunction

function void rvv_scoreboard::write_rvs_vrf(vrf_transaction tr);
  `uvm_info("DEBUG", "get a vrf check request from dut", UVM_HIGH)
  `uvm_info("DEBUG", tr.sprint(), UVM_HIGH)
  vrf_queue_rvs.push_back(tr);
endfunction

function void rvv_scoreboard::write_mdl_vrf(vrf_transaction tr);
  `uvm_info("DEBUG", "get a vrf check request from mdl", UVM_HIGH)
  `uvm_info("DEBUG", tr.sprint(), UVM_HIGH)
  vrf_queue_mdl.push_back(tr);
endfunction

task rvv_scoreboard::rt_checker();
  rvs_transaction mdl_tr;
  rvs_transaction rvs_tr;

  int        rt_vrf_num;
  reg_idx_t  rvs_rt_vrf_index , mdl_rt_vrf_index ;
  vrf_t      rvs_rt_vrf_strobe, mdl_rt_vrf_strobe;
  vrf_t      rvs_rt_vrf_data  , mdl_rt_vrf_data  ;

  string vreg_dut_val;
  string vreg_mdl_val;

  int        rt_xrf_num;
  reg_idx_t  rvs_rt_xrf_index, mdl_rt_xrf_index;
  xrf_t      rvs_rt_xrf_data , mdl_rt_xrf_data ;
  forever begin
    @(posedge rvs_if.clk);
    if(rt_queue_mdl.size() != rt_queue_rvs.size()) begin
      `uvm_fatal("RT_CHECKER","Retire number mismatch between DUT & MDL.");
    end
    while(rt_queue_rvs.size()>0) begin 
      rvs_tr = rt_queue_rvs.pop_front();
      mdl_tr = rt_queue_mdl.pop_front();
      `uvm_info("RT_RECORDER", "Got retire transaction from RVV:",UVM_LOW)
      `uvm_info("RT_RECORDER", rvs_tr.sprint(),UVM_LOW)
      `uvm_info("RT_RECORDER", "Got retire transaction from MDL:",UVM_LOW)
      `uvm_info("RT_RECORDER", mdl_tr.sprint(),UVM_LOW)

      // VRF check
      if(rvs_tr.rt_vrf_index.size() != mdl_tr.rt_vrf_index.size()) begin
        `uvm_error("RT_CHECKER", $sformatf("Retire VRF quantity mismatch:\nDUT retired %0d vregs, \nMDL retired %0d vregs.", 
                                            rvs_tr.rt_vrf_index.size(),
                                            mdl_tr.rt_vrf_index.size()))
      end else begin
        rt_vrf_num = rvs_tr.rt_vrf_index.size();
        for(int i=0; i<rt_vrf_num; i++) begin
          rvs_rt_vrf_index  = rvs_tr.rt_vrf_index.pop_front();
          rvs_rt_vrf_strobe = rvs_tr.rt_vrf_strobe.pop_front();
          rvs_rt_vrf_data   = rvs_tr.rt_vrf_data.pop_front();
          mdl_rt_vrf_index  = mdl_tr.rt_vrf_index.pop_front();
          mdl_rt_vrf_strobe = mdl_tr.rt_vrf_strobe.pop_front();
          mdl_rt_vrf_data   = mdl_tr.rt_vrf_data.pop_front();
          if(rvs_rt_vrf_index != mdl_rt_vrf_index) begin
            `uvm_error("RT_CHECKER", $sformatf("Retire VRF index mismatch:\nDUT retired vrf[%0d],\nMDL retired vrf[%0d].", 
                                                rvs_rt_vrf_index, 
                                                mdl_rt_vrf_index));
          end else if(rvs_rt_vrf_strobe != mdl_rt_vrf_strobe) begin
            vreg_dut_val = "0x";
            vreg_mdl_val = "0x";
            for(int i=`VLEN-1;i>=0;i-=16) begin
              vreg_dut_val = $sformatf("%s%4h_",vreg_dut_val,rvs_rt_vrf_strobe[i-:16]);
              vreg_mdl_val = $sformatf("%s%4h_",vreg_mdl_val,mdl_rt_vrf_strobe[i-:16]);
            end
            vreg_dut_val = vreg_dut_val.substr(0,vreg_dut_val.len()-2);
            vreg_mdl_val = vreg_mdl_val.substr(0,vreg_mdl_val.len()-2);
            `uvm_error("RT_CHECKER", $sformatf("Retire VRF strobe(bit) mismatch:\nDUT retired vrf_strobe[%0d] = %s,\nMDL retired vrf_strobe[%0d] = %s.", 
                                               rvs_rt_vrf_index, vreg_dut_val,
                                               mdl_rt_vrf_index, vreg_mdl_val));
          end else if((rvs_rt_vrf_strobe & rvs_rt_vrf_data) != (mdl_rt_vrf_strobe & mdl_rt_vrf_data)) begin
            vreg_dut_val = "0x";
            vreg_mdl_val = "0x";
            for(int i=`VLEN-1;i>=0;i-=16) begin
              vreg_dut_val = $sformatf("%s%4h_",vreg_dut_val,{rvs_rt_vrf_strobe & rvs_rt_vrf_data}[i-:16]);
              vreg_mdl_val = $sformatf("%s%4h_",vreg_mdl_val,{mdl_rt_vrf_strobe & mdl_rt_vrf_data}[i-:16]);
            end
            vreg_dut_val = vreg_dut_val.substr(0,vreg_dut_val.len()-2);
            vreg_mdl_val = vreg_mdl_val.substr(0,vreg_mdl_val.len()-2);
            // `uvm_error("RT_CHECKER", $sformatf("Retire VRF mismatch:\nDUT retired vrf[%0d] = 0x%0x,\nMDL retired vrf[%0d] = 0x%0x.", 
            //                                     rvs_rt_vrf_index, (rvs_rt_vrf_strobe & rvs_rt_vrf_data),
            //                                     mdl_rt_vrf_index, (mdl_rt_vrf_strobe & mdl_rt_vrf_data)));
            `uvm_error("RT_CHECKER", $sformatf("Retire VRF mismatch:\nDUT retired vrf[%0d] = %s,\nMDL retired vrf[%0d] = %s.", 
                                                rvs_rt_vrf_index, vreg_dut_val,
                                                mdl_rt_vrf_index, vreg_mdl_val));
          end else begin
            `uvm_info("RT_CHECKER", $sformatf("Retire vrf[%0d] check pass.",rvs_rt_vrf_index), UVM_LOW)
          end
        end
      end

      // XRF check
      if(rvs_tr.rt_xrf_index.size() != mdl_tr.rt_xrf_index.size()) begin
        `uvm_error("RT_CHECKER", $sformatf("Retire XRF quantity mismatch:\nDUT retired %0d xregs,\nMDL retired %0d xregs.", 
                                            rvs_tr.rt_xrf_index.size(),
                                            mdl_tr.rt_xrf_index.size()))
      end else begin
        rt_xrf_num = rvs_tr.rt_xrf_index.size();
        for(int i=0; i<rt_xrf_num; i++) begin
          rvs_rt_xrf_index  = rvs_tr.rt_xrf_index.pop_front();
          rvs_rt_xrf_data   = rvs_tr.rt_xrf_data.pop_front();
          mdl_rt_xrf_index  = mdl_tr.rt_xrf_index.pop_front();
          mdl_rt_xrf_data   = mdl_tr.rt_xrf_data.pop_front();
          if(rvs_rt_xrf_index != mdl_rt_xrf_index) begin
            `uvm_error("RT_CHECKER", $sformatf("Retire XRF index mismatch:\nDUT retired xrf[%0d],\nMDL retired xrf[%0d].", 
                                                rvs_rt_xrf_index, 
                                                mdl_rt_xrf_index));
          end else if(rvs_rt_xrf_data != mdl_rt_xrf_data) begin
            `uvm_error("RT_CHECKER", $sformatf("Retire XRF mismatch:\nDUT retired xrf[%0d] = 0x%8x,\nMDL retired xrf[%0d] = 0x%8x.", 
                                                rvs_rt_xrf_index, rvs_rt_xrf_data,
                                                mdl_rt_xrf_index, mdl_rt_xrf_data));
          end else begin
            `uvm_info("RT_CHECKER", $sformatf("Retire xrf[%0d] check pass.",rvs_rt_xrf_index), UVM_LOW)
          end
        end
      end

      // VXSAT check
      if(rvs_tr.vxsat_valid != mdl_tr.vxsat_valid) begin
        `uvm_error("RT_CHECKER","RVV vxsat_valid mismatch with reference model.");
      end else if(rvs_tr.vxsat_valid === 1 && mdl_tr.vxsat_valid === 1) begin
        if(rvs_tr.vxsat != mdl_tr.vxsat) begin
          `uvm_error("RT_CHECKER", $sformatf("Retire vxsat mismatch:\nDUT vxsat = %0d\nMDL vxsat = %0d",
                                              rvs_tr.vxsat,
                                              mdl_tr.vxsat));
        end else begin
          `uvm_info("RT_CHECKER", "Writeback vxsat check pass.", UVM_LOW)
        end
      end
    end
  end 
endtask: rt_checker 

task rvv_scoreboard::vrf_checker();
  vrf_transaction mdl_tr;
  vrf_transaction rvs_tr;
  int err;
  string vreg_dut_val;
  string vreg_mdl_val;
  forever begin
    @(posedge rvs_if.clk); 
    err = 0;
    if(vrf_queue_rvs.size()>1 || vrf_queue_mdl.size()>1) begin
      `uvm_error("TB_ISSUE", "Got more than 1 vrf check request, please check the TB.");
    end
    if(vrf_queue_rvs.size()>0 && vrf_queue_mdl.size()>0) begin
      rvs_tr = vrf_queue_rvs.pop_front();
      mdl_tr = vrf_queue_mdl.pop_front();
      `uvm_info("VRF_RECORDER", "\n==============================HEAD================================", UVM_HIGH)
      for(int idx=0; idx<32; idx++) begin
        vreg_dut_val = "0x";
        vreg_mdl_val = "0x";
        if(rvs_tr.vreg[idx] !== mdl_tr.vreg[idx]) begin
          for(int i=`VLEN-1;i>=0;i-=16) begin
            vreg_dut_val = $sformatf("%s%4h_",vreg_dut_val,rvs_tr.vreg[idx][i-:16]);
            vreg_mdl_val = $sformatf("%s%4h_",vreg_mdl_val,mdl_tr.vreg[idx][i-:16]);
          end
          vreg_dut_val = vreg_dut_val.substr(0,vreg_dut_val.len()-2);
          vreg_mdl_val = vreg_mdl_val.substr(0,vreg_mdl_val.len()-2);
          //`uvm_warning("VRF_RECORDER", $sformatf("VRF[%0d] value mismatch: \ndut = 0x%0h \nmdl = 0x%0h", idx, rvs_tr.vreg[idx], mdl_tr.vreg[idx]))
          //`uvm_error("VRF_CHECKER", $sformatf("VRF[%0d] value mismatch: \ndut = 0x%0h \nmdl = 0x%0h", idx, rvs_tr.vreg[idx], mdl_tr.vreg[idx]))
          `uvm_warning("VRF_RECORDER", $sformatf("VRF[%0d] value mismatch: \ndut = %s \nmdl = %s", idx, vreg_dut_val, vreg_mdl_val))
          `uvm_error("VRF_CHECKER", $sformatf("VRF[%0d] value mismatch: \ndut = %s \nmdl = %s", idx, vreg_dut_val, vreg_mdl_val))
          err++;
        end
        `uvm_info("VRF_RECORDER", $sformatf("VRF[%0d] value: \ndut = 0x%0h \nmdl = 0x%0h", idx, rvs_tr.vreg[idx], mdl_tr.vreg[idx]), UVM_HIGH)
      end
      if(!err) begin
        `uvm_info("VRF_CHECKER", "VRF check pass", UVM_LOW)
      end
      `uvm_info("VRF_RECORDER", "\n==============================TAIL================================", UVM_HIGH)
    end
  end
endtask: vrf_checker 

function void rvv_scoreboard::final_phase(uvm_phase phase);
  super.final_phase(phase);
  if(rt_queue_rvs.size()>0) begin
    `uvm_error("FINAL_CHECK", "rt_queue_rvs wasn't empty!")
    foreach(rt_queue_rvs[idx]) begin
      `uvm_error("FINAL_CHECK",rt_queue_rvs[idx].sprint())
    end
  end
  if(rt_queue_mdl.size()>0) begin
    `uvm_error("FINAL_CHECK", "rt_queue_mdl wasn't empty!")
    foreach(rt_queue_mdl[idx]) begin
      `uvm_error("FINAL_CHECK",rt_queue_mdl[idx].sprint())
    end
  end
  if(vrf_queue_rvs.size()>0) begin
    `uvm_error("FINAL_CHECK", "vrf_queue_rvs wasn't empty!")
    foreach(vrf_queue_rvs[idx]) begin
      `uvm_error("FINAL_CHECK",vrf_queue_rvs[idx].sprint())
    end
  end
  if(vrf_queue_mdl.size()>0) begin
    `uvm_error("FINAL_CHECK", "vrf_queue_mdl wasn't empty!")
    foreach(vrf_queue_mdl[idx]) begin
      `uvm_error("FINAL_CHECK",vrf_queue_mdl[idx].sprint())
    end
  end
  `uvm_info(get_type_name(),"Exit final_phase...", UVM_HIGH)
endfunction: final_phase
`endif // RVV_SCOREBOARD__SV
