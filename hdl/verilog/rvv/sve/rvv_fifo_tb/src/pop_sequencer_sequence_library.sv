//
// Template for UVM-compliant sequence library
//


`ifndef POP_SEQUENCER_SEQUENCE_LIBRARY__SV
`define POP_SEQUENCER_SEQUENCE_LIBRARY__SV


typedef class push_transaction;

class pop_sequencer_sequence_library extends uvm_sequence_library # (push_transaction);
  
  `uvm_object_utils(pop_sequencer_sequence_library)
  `uvm_sequence_library_utils(pop_sequencer_sequence_library)

  function new(string name = "simple_pop_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_pop_sequence extends uvm_sequence #(push_transaction);
  `uvm_object_utils(base_pop_sequence)

  function new(string name = "base_seq");
    super.new(name);
  endfunction:new

endclass

class pop_sequence extends base_pop_sequence;
  `uvm_object_utils(sequence_0)
  `uvm_add_to_seq_lib(sequence_0,pop_sequencer_sequence_library)

  function new(string name = "seq_0");
    super.new(name);
  endfunction:new

  virtual task body();
    forever begin
      `uvm_do(req);
    end
  endtask
endclass

`endif // POP_SEQUENCER_SEQUENCE_LIBRARY__SV
