`ifndef RVV_BACKEND_CORNER_TEST__SV
`define RVV_BACKEND_CORNER_TEST__SV

//-----------------------------------------------------------
// Divided by zero test.
//-----------------------------------------------------------
class alu_div_zero_seq extends base_sequence;
  `uvm_object_utils(alu_div_zero_seq)

  int inst_num = 1;
  function new(string name = "alu_div_zero_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == inst_cnt;

        vlmul inside {LMUL1_2, LMUL1, LMUL2};

        inst_type == ALU;
        alu_inst inside {VDIVU, VDIV, VREMU, VREM};

        dest_type == VRF; dest_idx inside {[3:31]};
        src2_type == VRF; src2_idx inside {[3:31]};
        (src1_type == VRF) -> (src1_idx dist{ 2:=95, [3:31]:/5});
        (src1_type == XRF) -> (rs1_data dist {0:=95, [1:$]:/5});
        vm dist {1:=80, 0:=20}; // to do more calcualtion
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask

  task run_inst(uvm_sequencer_base sqr, int inst_num);
    this.inst_num = inst_num;
    this.start(sqr);
  endtask: run_inst
endclass: alu_div_zero_seq

class alu_div_zero_test extends rvv_backend_test;
  
  alu_div_zero_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_div_zero_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();
    set_vrf(2,'0);

    rvs_seq = alu_div_zero_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 1000);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction

endclass: alu_div_zero_test

//-----------------------------------------------------------
// Cov Test: large vstart/vl 
//-----------------------------------------------------------
class alu_large_vstart_seq extends base_sequence;
  `uvm_object_utils(alu_large_vstart_seq)

  int inst_num = 1;
  function new(string name = "alu_large_vstart_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      req.c_vl.constraint_mode(0);
      assert(req.randomize() with {
        pc == inst_cnt;

        inst_type == ALU;
        alu_inst inside {VMAND, VMOR, VMXOR, VMORN, VMNAND, VMNOR, VMANDN, VMXNOR};
        
        if(vlmul[2]) // fraction_lmul
          vlmax == ((`VLENB >> (~vlmul +3'b1)) >> vsew);
        else  
          vlmax == ((`VLENB << vlmul) >> vsew);

        vl == vlmax_max;
        vstart <= vlmax_max-1;

      });
      finish_item(req);
      inst_cnt++;
    end
  endtask

  task run_inst(uvm_sequencer_base sqr, int inst_num);
    this.inst_num = inst_num;
    this.start(sqr);
  endtask: run_inst
endclass: alu_large_vstart_seq

class alu_large_vstart_test extends rvv_backend_test;
  
  alu_large_vstart_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_large_vstart_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rand_vrf();

    rvs_seq = alu_large_vstart_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 1000);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction

endclass: alu_large_vstart_test

`endif // RVV_BACKEND_CORNER_TEST__SV
