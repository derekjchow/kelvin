//
// Template for UVM-compliant transaction descriptor


`ifndef CHECK_TRANSACTION__SV
`define CHECK_TRANSACTION__SV


class check_transaction extends uvm_sequence_item;

   logic  valid = 0;
   logic [DWIDTH-1:0] data = 0;
   `uvm_object_utils_begin(check_transaction) 
      `uvm_field_int(valid,UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
   `uvm_object_utils_end
 
   extern function new(string name = "Trans");
endclass: check_transaction


function check_transaction::new(string name = "Trans");
   super.new(name);
endfunction: new


`endif // PUSH_TRANSACTION__SV
