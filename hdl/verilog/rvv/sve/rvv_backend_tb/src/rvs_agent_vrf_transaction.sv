`ifndef VRF_TRANSACTION__SV
`define VRF_TRANSACTION__SV

class vrf_transaction extends uvm_sequence_item;

  logic [`VLEN-1:0] vreg [31:0];

// Auto Field ---------------------------------------------------------
  `uvm_object_utils_begin(vrf_transaction) 
    `uvm_field_sarray_int(vreg, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "Trans");
endclass: vrf_transaction


function vrf_transaction::new(string name = "Trans");
   super.new(name);
endfunction: new

`endif // VRF_TRANSACTION__SV
