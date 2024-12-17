`ifndef RVS_SEQUENCER__SV
`define RVS_SEQUENCER__SV

typedef class rvs_transaction;
class rvs_sequencer extends uvm_sequencer # (rvs_transaction);

  `uvm_component_utils(rvs_sequencer)
  function new (string name,
                uvm_component parent);
  super.new(name,parent);
  endfunction:new 
endclass:rvs_sequencer

`endif // RVS_SEQUENCER__SV
