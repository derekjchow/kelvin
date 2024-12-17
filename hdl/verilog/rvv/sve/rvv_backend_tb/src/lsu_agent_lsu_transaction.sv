`ifndef LSU_TRANSACTION__SV
`define LSU_TRANSACTION__SV

class lsu_transaction extends uvm_sequence_item;
  typedef enum {LOAD, STORE} kinds_e;
  kinds_e kind;
  int uop_id;
  int pc;
  int addr[$];
  int value[$];

  int emul;
  int eew;
  int cnt;
    
  `uvm_object_utils_begin(lsu_transaction) 
  `uvm_object_utils_end

  extern function new(string name = "Trans");
endclass: lsu_transaction


function lsu_transaction::new(string name = "Trans");
   super.new(name);
endfunction: new


`endif // LSU_TRANSACTION__SV
