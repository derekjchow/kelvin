//
// Template for UVM-compliant Program block

`ifndef RVV_FIFO_TB_MOD__SV
`define RVV_FIFO_TB_MOD__SV

`include "mstr_slv_intfs.incl"
module rvv_fifo_tb_mod;

import uvm_pkg::*;

`include "mstr_slv_src.incl"

`include "rvv_fifo_cfg.sv"


`include "data_check.sv"

`include "rvv_fifo_cov.sv"

`include "mon_2cov.sv"

`include "rvv_fifo_env.sv"
`include "rvv_fifo_test.sv"  //ToDo: Change this name to the testcase file-name

// ToDo: Include all other test list here
   typedef virtual push_interface v_if1;
   typedef virtual pop_interface v_if2;
   initial begin
      uvm_config_db #(v_if1)::set(null,"","mst_if",rvv_fifo_top.mst_if); 
      uvm_config_db #(v_if2)::set(null,"","slv_if",rvv_fifo_top.slv_if);
      run_test();
   end

endmodule: rvv_fifo_tb_mod

`endif // RVV_FIFO_TB_MOD__SV

