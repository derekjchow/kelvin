`ifndef RVS_SEQUENCER_SEQUENCE_LIBRARY__SV
`define RVS_SEQUENCER_SEQUENCE_LIBRARY__SV

typedef class rvs_transaction;

class rvs_sequencer_sequence_library extends uvm_sequence_library # (rvs_transaction);
  
  `uvm_object_utils(rvs_sequencer_sequence_library)
  `uvm_sequence_library_utils(rvs_sequencer_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(rvs_transaction);
  int inst_cnt = 0;
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask:pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask:post_body
  `endif
  
  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting");
  endtask:pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending");
  endtask:post_start
  `endif
endclass

//=================================================
// To debug testbench.
//=================================================
class zero_seq extends base_sequence;
  `uvm_object_utils(zero_seq)
  `uvm_add_to_seq_lib(zero_seq,rvs_sequencer_sequence_library)

  function new(string name = "zero_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(int i=0; i<10; i++) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vtype.vill ==  'b0;
        vtype.rsv  ==  'b0;  
        vtype.vma  ==  'b0;
        vtype.vta  ==  'b0;
        vtype.vsew ==  SEW8;
        vtype.vlmul == LMUL1;

        inst_type == ALU;
        alu_type == OPI;
        opi_type == VADD;
        dest_type == VRF; dest_idx == 2;
        src1_type == VRF; src1_idx == 1;
        src2_type == VRF; src2_idx == 2;
        vm == 1; 
      });
      finish_item(req);
      inst_cnt++;
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vtype.vill ==  'b0;
        vtype.rsv  ==  'b0;  
        vtype.vma  ==  'b0;
        vtype.vta  ==  'b1;
        vtype.vsew ==  SEW8;
        vtype.vlmul == LMUL1;

        inst_type == ALU;
        alu_type == OPI;
        opi_type == VADD;
        dest_type == VRF; dest_idx == 16;
        src1_type == VRF; src1_idx == 1;
        src2_type == VRF; src2_idx == 16;
        rs_data == 123;
        vm == 1; 
      });
      finish_item(req);
      inst_cnt++;
    end

  endtask
endclass: zero_seq

class lsu_unit_stride_seq extends base_sequence;
  `uvm_object_utils(lsu_unit_stride_seq)
  `uvm_add_to_seq_lib(lsu_unit_stride_seq,rvs_sequencer_sequence_library)

  function new(string name = "lsu_unit_stride_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(int i=0; i<10; i++) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == inst_cnt;

        vtype.vma  ==  UNDISTURB;
        vtype.vta  ==  UNDISTURB;
        vtype.vsew ==  SEW8;
        vtype.vlmul == LMUL1;

        use_vlmax == 1;
        // vl == 10;

        inst_type == LD;
        lsu_mop   == LSU_E;
        lsu_umop  == NORMAL;
        lsu_nf    == NF1;
        lsu_eew   == EEW8;

        dest_type == VRF; dest_idx == 2;
        src1_type == VRF; src1_idx == 12;
        src2_type == VRF; src2_idx == 2;

        vm == 0; 
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask
endclass: lsu_unit_stride_seq

`endif // RVS_SEQUENCER_SEQUENCE_LIBRARY__SV
