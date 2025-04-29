`ifndef RVV_SEQUENCE_LIBRARY__SV
`define RVV_SEQUENCE_LIBRARY__SV

typedef class rvs_transaction;

// -----------------------------------------------------------------------------
//  Process Unit Sequence Library
// -----------------------------------------------------------------------------
class rvv_inst_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_inst_sequence_library)
  `uvm_sequence_library_utils(rvv_inst_sequence_library)

  function new(string name = "rvv_inst_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class rvv_alu_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_alu_sequence_library)
  `uvm_sequence_library_utils(rvv_alu_sequence_library)

  function new(string name = "rvv_alu_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class rvv_div_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_div_sequence_library)
  `uvm_sequence_library_utils(rvv_div_sequence_library)

  function new(string name = "rvv_div_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class rvv_mulmac_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_mulmac_sequence_library)
  `uvm_sequence_library_utils(rvv_mulmac_sequence_library)

  function new(string name = "rvv_mulmac_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class rvv_pmtrdt_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_pmtrdt_sequence_library)
  `uvm_sequence_library_utils(rvv_pmtrdt_sequence_library)

  function new(string name = "rvv_pmtrdt_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass 

class rvv_lsu_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvv_lsu_sequence_library)
  `uvm_sequence_library_utils(rvv_lsu_sequence_library)

  function new(string name = "rvv_lsu_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  
`endif // RVV_SEQUENCE_LIBRARY__SV
