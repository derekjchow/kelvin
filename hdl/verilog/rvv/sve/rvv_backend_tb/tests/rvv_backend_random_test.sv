`ifndef RVV_BACKEND_RANDOM_TEST__SV
`define RVV_BACKEND_RANDOM_TEST__SV

typedef class rvv_backend_env;
`include "rvv_backend_define.svh"

class rvs_random_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvs_random_sequence_library)
  `uvm_sequence_library_utils(rvs_random_sequence_library)

  function new(string name = "random_seq_lib");
    super.new(name);
  endfunction

endclass  

//-----------------------------------------------------------
// ALU: Normal random test
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
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_test

class alu_random_test_trap_en extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  alu_random_seq  rvs_alu_seq;
  lsu_base_seq   rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_test_trap_en
//-----------------------------------------------------------
// ALU: Large lmul random test
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
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_large_lmul_test

//-----------------------------------------------------------
// ALU: Small lmul random test
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
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_small_lmul_test

//-----------------------------------------------------------
// ALU: Bypass random test
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
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_bypass_test

//-----------------------------------------------------------
// ALU: WAW random test
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
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_waw_test

//-----------------------------------------------------------
// DIV random test
//-----------------------------------------------------------
class div_random_test extends rvv_backend_test;

  div_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(div_random_test)

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

    rvs_seq = div_random_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: div_random_test

class div_random_test_trap_en extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  div_random_seq rvs_div_seq;
  lsu_base_seq   rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(div_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_div_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: div_random_test_trap_en
//-----------------------------------------------------------
// LSU: normal random test
//-----------------------------------------------------------
class lsu_random_test extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{
    VL, VS,
    VLM, VSM,
    VLS, VSS, 
    VLUX, VLOX, VSUX, VSOX,
    VLFF,
    VLSEG, VSSEG, 
    VLSSEG, VSSSEG, 
    VLUXSEG, VLOXSEG, VSUXSEG, VSOXSEG,
    VLSEGFF,
    VLR, VSR
  };

  `uvm_component_utils(lsu_random_test)

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

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_random_test

class lsu_random_test_trap_en extends lsu_random_test;

  `uvm_component_utils(lsu_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_random_test_trap_en

//-----------------------------------------------------------
// Normal random test
//-----------------------------------------------------------
class rvv_random_test extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  alu_random_seq rvs_alu_seq;
  lsu_base_seq   rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(rvv_random_test)

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

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rvv_random_test

class rvv_random_test_trap_en extends rvv_random_test;

  `uvm_component_utils(rvv_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rvv_random_test_trap_en

// -----------------------------------------------------------------------------
// PU random test
// -----------------------------------------------------------------------------
class pu_alu_random_test extends rvv_backend_test;

  rvv_alu_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_alu_random_test)

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
    rvs_seq_lib = rvv_alu_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_alu_random_test

class pu_alu_random_test_trap_en extends pu_alu_random_test;

  rvv_alu_sequence_library rvs_seq_lib;
  lsu_base_seq      rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_alu_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_seq_lib = rvv_alu_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_alu_random_test_trap_en

// ---------------------------------------------------------
class pu_pmtrdt_random_test extends rvv_backend_test;

  rvv_pmtrdt_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_pmtrdt_random_test)

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
    rvs_seq_lib = rvv_pmtrdt_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_pmtrdt_random_test

class pu_pmtrdt_random_test_trap_en extends pu_pmtrdt_random_test;

  rvv_pmtrdt_sequence_library rvs_seq_lib;
  lsu_base_seq      rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_pmtrdt_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_seq_lib = rvv_pmtrdt_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_pmtrdt_random_test_trap_en

// ---------------------------------------------------------
class pu_div_random_test extends rvv_backend_test;

  rvv_div_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_div_random_test)

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
    rvs_seq_lib = rvv_div_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_div_random_test

class pu_div_random_test_trap_en extends pu_div_random_test;

  rvv_div_sequence_library rvs_seq_lib;
  lsu_base_seq      rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_div_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_seq_lib = rvv_div_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_div_random_test_trap_en

// ---------------------------------------------------------
class pu_mulmac_random_test extends rvv_backend_test;

  rvv_mulmac_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_mulmac_random_test)

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
    rvs_seq_lib = rvv_mulmac_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_mulmac_random_test

class pu_mulmac_random_test_trap_en extends pu_mulmac_random_test;

  rvv_mulmac_sequence_library rvs_seq_lib;
  lsu_base_seq      rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_mulmac_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_seq_lib = rvv_mulmac_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_mulmac_random_test_trap_en

// ---------------------------------------------------------
class pu_lsu_random_test extends rvv_backend_test;

  rvv_lsu_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_lsu_random_test)

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
    rvs_seq_lib = rvv_lsu_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_lsu_random_test

class pu_lsu_random_test_trap_en extends rvv_backend_test;

  rvv_lsu_sequence_library rvs_seq_lib;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(pu_lsu_random_test_trap_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_seq_lib = rvv_lsu_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: pu_lsu_random_test_trap_en

// -----------------------------------------------------------------------------
//  Reserve inst test
// -----------------------------------------------------------------------------
class alu_random_test_rsv_en extends rvv_backend_test;

  alu_random_seq  rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_random_test_rsv_en)

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

    rvs_transaction::reserve_vl_vstart_en = 1;
    rvs_transaction::reserve_inst_en      = 1;
    rvs_transaction::reserve_vtype_en     = 1;
    rvs_transaction::overlap_unalign_en   = 1;
    rvs_seq = alu_random_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: alu_random_test_rsv_en

class lsu_random_test_rsv_en extends rvv_backend_test;

  lsu_base_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  lsu_inst_e inst_set[$] = '{
    VL, VS,
    VLM, VSM,
    VLS, VSS, 
    VLUX, VLOX, VSUX, VSOX,
    VLFF,
    VLSEG, VSSEG, 
    VLSSEG, VSSSEG, 
    VLUXSEG, VLOXSEG, VSUXSEG, VSOXSEG,
    VLSEGFF,
    VLR, VSR
  };

  `uvm_component_utils(lsu_random_test_rsv_en)

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

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_transaction::reserve_vl_vstart_en = 1;
    rvs_transaction::reserve_inst_en      = 1;
    rvs_transaction::reserve_vtype_en     = 1;
    rvs_transaction::overlap_unalign_en   = 1;

    rvs_seq = lsu_base_seq::type_id::create("lsu_base_seq", this);

    rvs_seq.run_inst_set(inst_set, env.rvs_agt.rvs_sqr, random_inst_num);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: lsu_random_test_rsv_en

class rvv_random_test_rsv_en extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  alu_random_seq rvs_alu_seq;
  lsu_base_seq   rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(rvv_random_test_rsv_en)

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

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)


    rvs_transaction::reserve_vl_vstart_en = 1;
    rvs_transaction::reserve_inst_en      = 1;
    rvs_transaction::reserve_vtype_en     = 1;
    rvs_transaction::overlap_unalign_en   = 1;

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rvv_random_test_rsv_en


class rvv_random_test_trap_en_rsv_en extends rvv_random_test;

  `uvm_component_utils(rvv_random_test_trap_en_rsv_en)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    rvs_transaction::reserve_vl_vstart_en = 1;
    rvs_transaction::reserve_inst_en      = 1;
    rvs_transaction::reserve_vtype_en     = 1;
    rvs_transaction::overlap_unalign_en   = 1;
    super.main_phase(phase);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rvv_random_test_trap_en_rsv_en
`endif // RVV_BACKEND_RANDOM_TEST__SV
