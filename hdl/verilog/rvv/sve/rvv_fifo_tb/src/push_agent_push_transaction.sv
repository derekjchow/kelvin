//
// Template for UVM-compliant transaction descriptor


`ifndef PUSH_TRANSACTION__SV
`define PUSH_TRANSACTION__SV


class push_transaction extends uvm_sequence_item;

   rand logic  valid;
   rand logic [DWIDTH-1:0] data;
   //`ifdef FIFO_2W2R
   rand logic  valid1;
   rand logic [DWIDTH-1:0] data1;
   //`endif
   //`ifdef FIFO_4W2R
   rand logic  valid3;
   rand logic  valid2;
   rand logic [DWIDTH-1:0] data2;
   rand logic [DWIDTH-1:0] data3;
   //`endif
   constraint valid_push_pop{
      soft valid3 == 1 -> valid2 & valid1 & valid == 1;
      soft valid2 == 1 -> valid1 & valid == 1;
      soft valid1 == 1 -> valid == 1;
      solve valid3 before valid2;
      solve valid2 before valid1;
      solve valid1 before valid;
   };
   `uvm_object_utils_begin(push_transaction) 

      // ToDo: add properties using macros here
   
      `uvm_field_int(valid,UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
   //`ifdef FIFO_2W2R
      `uvm_field_int(valid1,UVM_ALL_ON)
      `uvm_field_int(data1, UVM_ALL_ON)
   //`endif
   //`ifdef FIFO_4W2R
      `uvm_field_int(valid2,UVM_ALL_ON)
      `uvm_field_int(data2, UVM_ALL_ON)
      `uvm_field_int(valid3,UVM_ALL_ON)
      `uvm_field_int(data3, UVM_ALL_ON)
   //`endif
   `uvm_object_utils_end
 
   extern function new(string name = "Trans");
endclass: push_transaction


function push_transaction::new(string name = "Trans");
   super.new(name);
endfunction: new


`endif // PUSH_TRANSACTION__SV
