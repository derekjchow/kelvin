`ifndef LSU_SEQUENCER__SV
`define LSU_SEQUENCER__SV

typedef class lsu_transaction;
class lsu_sequencer extends uvm_sequencer # (lsu_transaction);

   `uvm_component_utils(lsu_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:lsu_sequencer

`endif // LSU_SEQUENCER__SV
