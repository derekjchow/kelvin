//
// Template for UVM-compliant sequencer class
//


`ifndef PUSH_SEQUENCER__SV
`define PUSH_SEQUENCER__SV


typedef class push_transaction;
class push_sequencer extends uvm_sequencer # (push_transaction);

   `uvm_component_utils(push_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:push_sequencer

`endif // PUSH_SEQUENCER__SV
