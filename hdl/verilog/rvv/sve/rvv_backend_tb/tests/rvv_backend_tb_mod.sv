`ifndef RVV_BACKEND_TB_MOD__SV
`define RVV_BACKEND_TB_MOD__SV

`include "mstr_slv_intfs.incl"
`include "inst_description.svh"

module rvv_backend_tb_mod;

import uvm_pkg::*;
import rvv_tb_pkg::*;

`include "rvv_backend_env.sv"
`include "rvv_backend_test.sv"  
`include "rvv_backend_random_test.sv"  
`include "rvv_backend_corner_test.sv"  

  typedef virtual rvs_interface v_if1;
  typedef virtual lsu_interface v_if2;
  typedef virtual vrf_interface v_if3;
  typedef virtual rvv_intern_interface v_if4;
  initial begin
    uvm_config_db #(v_if1)::set(null,"","rvs_if",rvv_backend_top.rvs_if); 
    uvm_config_db #(v_if2)::set(null,"","lsu_if",rvv_backend_top.lsu_if);
    uvm_config_db #(v_if3)::set(null,"","vrf_if",rvv_backend_top.vrf_if);
    uvm_config_db #(v_if4)::set(null,"","rvv_intern_if",rvv_backend_top.rvv_intern_if);
    run_test();
  end


endmodule: rvv_backend_tb_mod

`endif // RVV_BACKEND_TB_MOD__SV

