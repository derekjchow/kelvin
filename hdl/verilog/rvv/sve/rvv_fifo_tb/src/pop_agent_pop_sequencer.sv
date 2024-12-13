//
// Template for UVM-compliant sequencer class
//


`ifndef POP_SEQUENCER__SV
`define POP_SEQUENCER__SV


typedef class push_transaction;
class pop_sequencer extends uvm_sequencer # (push_transaction);

   `uvm_component_utils(pop_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:pop_sequencer

`endif // POP_SEQUENCER__SV
