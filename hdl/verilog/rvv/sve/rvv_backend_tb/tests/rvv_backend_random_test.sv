`ifndef RVV_BACKEND_RANDOM_TEST__SV
`define RVV_BACKEND_RANDOM_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"
//-----------------------------------------------------------
// Normal random test
//-----------------------------------------------------------
class alu_random_test extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_test

//-----------------------------------------------------------
// Large lmul random test
//-----------------------------------------------------------
class alu_random_large_lmul_test extends rvv_backend_test;

  alu_random_large_lmul_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_large_lmul_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_large_lmul_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_large_lmul_test

//-----------------------------------------------------------
// Small lmul random test
//-----------------------------------------------------------
class alu_random_small_lmul_test extends rvv_backend_test;

  alu_random_small_lmul_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_small_lmul_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_small_lmul_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_small_lmul_test

//-----------------------------------------------------------
// Bypass random test
//-----------------------------------------------------------
class alu_random_bypass_test extends rvv_backend_test;

  alu_random_bypass_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_bypass_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_bypass_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_bypass_test

//-----------------------------------------------------------
// WAW random test
//-----------------------------------------------------------
class alu_random_waw_test extends rvv_backend_test;

  alu_random_waw_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_waw_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_waw_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_waw_test

//-----------------------------------------------------------
// DUT-ALU random test
//-----------------------------------------------------------
/*
class alu_alu_random_test extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_inst_e inst_set[$] = '{
    VADD       ,
    VSUB       ,
    VRSUB      ,
    
    VADC       ,
    VSBC       ,

    VAND       ,
    VOR        ,
    VXOR       ,

    VSLL       ,
    VSRL       ,
    VSRA       ,
    VNSRL      ,
    VNSRA      ,

    VMSEQ      ,
    VMSNE      ,
    VMSLTU     ,
    VMSLT      ,
    VMSLEU     ,
    VMSLE      ,
    VMSGTU     ,
    VMSGT      ,

    VMINU      ,
    VMIN       ,
    VMAXU      ,
    VMAX       ,

    VMERGE_VMVV,

    VSADDU     ,
    VSADD      ,
    VSSUBU     ,
    VSSUB      ,

    VSMUL_VMVNR,

    VSSRL      ,
    VSSRA      ,

    VNCLIPU    ,
    VNCLIP     ,

    VWREDSUMU  ,
    VWREDSUM   ,

    VSLIDEUP_RG,
    VSLIDEDOWN ,
    VRGATHER   ,

    VWADDU     ,
    VWADD      ,
    VWADDU_W   ,
    VWADD_W    ,
    VWSUBU     ,
    VWSUB      ,
    VWSUBU_W   ,
    VWSUB_W    ,

    VXUNARY0   ,

    VMUL       ,
    VMULH      ,
    VMULHU     ,
    VMULHSU    ,

    VDIVU      ,
    VDIV       ,
    VREMU      ,
    VREM       ,

    VWMUL      ,
    VWMULU     ,
    VWMULSU    ,

    VMACC      ,
    VNMSAC     ,
    VMADD      ,
    VNMSUB     ,

    VWMACCU    ,
    VWMACC     ,
    VWMACCUS   ,
    VWMACCSU   ,

    VAADDU     ,
    VAADD      ,
    VASUBU     ,
    VASUB      ,

    VREDSUM    ,
    VREDAND    ,
    VREDOR     ,
    VREDXOR    ,
    VREDMINU   ,
    VREDMIN    ,
    VREDMAXU   ,
    VREDMAX    ,

    VMAND      ,
    VMOR       ,
    VMXOR      ,
    VMORN      ,
    VMNAND     ,
    VMNOR      ,
    VMANDN     ,
    VMXNOR     ,

    VMUNARY0   ,
    VSLIDE1UP  ,
    VSLIDE1DOWN,
    VCOMPRESS  ,

    VWXUNARY0  ,
      
  };

  `uvm_component_utils(alu_alu_random_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_alu_random_test
*/

//-----------------------------------------------------------
// DUT-MULMAC random test
//-----------------------------------------------------------
/*
class alu_mulmac_random_test extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_inst_e inst_set[$] = '{
    VSMUL_VMVNR,

    VMUL       ,
    VMULH      ,
    VMULHU     ,
    VMULHSU    ,

    VWMUL      ,
    VWMULU     ,
    VWMULSU    ,

    VMACC      ,
    VNMSAC     ,
    VMADD      ,
    VNMSUB     ,

    VWMACCU    ,
    VWMACC     ,
    VWMACCUS   ,
    VWMACCSU   
  };

  `uvm_component_utils(alu_mulmac_random_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_mulmac_random_test
*/

//-----------------------------------------------------------
// DUT-DIV random test
//-----------------------------------------------------------
/*
class alu_alu_random_test extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  alu_inst_e inst_set[$] = '{
    VADD       ,
    VSUB       ,
    VRSUB      ,
    
    VADC       ,
    VSBC       ,

    VAND       ,
    VOR        ,
    VXOR       ,

    VSLL       ,
    VSRL       ,
    VSRA       ,
    VNSRL      ,
    VNSRA      ,

    VMSEQ      ,
    VMSNE      ,
    VMSLTU     ,
    VMSLT      ,
    VMSLEU     ,
    VMSLE      ,
    VMSGTU     ,
    VMSGT      ,

    VMINU      ,
    VMIN       ,
    VMAXU      ,
    VMAX       ,

    VMERGE_VMVV,

    VSADDU     ,
    VSADD      ,
    VSSUBU     ,
    VSSUB      ,

    VSMUL_VMVNR,

    VSSRL      ,
    VSSRA      ,

    VNCLIPU    ,
    VNCLIP     ,

    VWREDSUMU  ,
    VWREDSUM   ,

    VSLIDEUP_RG,
    VSLIDEDOWN ,
    VRGATHER   ,

    VWADDU     ,
    VWADD      ,
    VWADDU_W   ,
    VWADD_W    ,
    VWSUBU     ,
    VWSUB      ,
    VWSUBU_W   ,
    VWSUB_W    ,

    VXUNARY0   ,

    VMUL       ,
    VMULH      ,
    VMULHU     ,
    VMULHSU    ,

    VDIVU      ,
    VDIV       ,
    VREMU      ,
    VREM       ,

    VWMUL      ,
    VWMULU     ,
    VWMULSU    ,

    VMACC      ,
    VNMSAC     ,
    VMADD      ,
    VNMSUB     ,

    VWMACCU    ,
    VWMACC     ,
    VWMACCUS   ,
    VWMACCSU   ,

    VAADDU     ,
    VAADD      ,
    VASUBU     ,
    VASUB      ,

    VREDSUM    ,
    VREDAND    ,
    VREDOR     ,
    VREDXOR    ,
    VREDMINU   ,
    VREDMIN    ,
    VREDMAXU   ,
    VREDMAX    ,

    VMAND      ,
    VMOR       ,
    VMXOR      ,
    VMORN      ,
    VMNAND     ,
    VMNOR      ,
    VMANDN     ,
    VMXNOR     ,

    VMUNARY0   ,
    VSLIDE1UP  ,
    VSLIDE1DOWN,
    VCOMPRESS  ,

    VWXUNARY0  ,
      
  };

  `uvm_component_utils(alu_alu_random_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_transaction::set_ill_rate(0);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_alu_random_test
*/
`endif // RVV_BACKEND_RANDOM_TEST__SV
