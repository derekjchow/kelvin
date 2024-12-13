//
// Template for UVM-compliant sequence library
//


`ifndef PUSH_SEQUENCER_SEQUENCE_LIBRARY__SV
`define PUSH_SEQUENCER_SEQUENCE_LIBRARY__SV


typedef class push_transaction;

class push_sequencer_sequence_library extends uvm_sequence_library # (push_transaction);
  
  `uvm_object_utils(push_sequencer_sequence_library)
  `uvm_sequence_library_utils(push_sequencer_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(push_transaction);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
  endfunction:new

endclass

class sequence_0 extends base_sequence;
  `uvm_object_utils(sequence_0)
  `uvm_add_to_seq_lib(sequence_0,push_sequencer_sequence_library)

  function new(string name = "seq_0");
    super.new(name);
  endfunction:new

  virtual task body();
    repeat(1000) begin
      `uvm_do(req);
    end
  endtask
endclass

`endif // PUSH_SEQUENCER_SEQUENCE_LIBRARY__SV
