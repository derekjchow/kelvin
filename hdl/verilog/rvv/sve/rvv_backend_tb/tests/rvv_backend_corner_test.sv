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

        vtype.vlmul inside {LMUL1_2, LMUL1, LMUL2};

        inst_type == ALU;
        alu_inst inside {VDIVU, VDIV, VREMU, VREM};

        dest_type == VRF; dest_idx inside {[3:31]};
        src2_type == VRF; src2_idx inside {[3:31]};
        src1_type dist {VRF:=50, XRF:=50};
        (src1_type == VRF) -> (src1_idx dist{ 2:=95, [3:31]:/5});
        (src1_type == XRF) -> (rs_data dist {0:=95, [1:$]:/5});
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
  alu_smoke_vv_seq rvs_last_seq;

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
    phase.raise_objection( .obj( this ) );

    rand_vrf();
    set_vrf(2,'0);

    rvs_seq = alu_div_zero_seq::type_id::create("rvs_seq", this);
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 1000);

    rvs_last_seq = alu_smoke_vv_seq::type_id::create("rvs_last_seq", this);
    rvs_last_seq.run_inst(VADD,env.rvs_agt.rvs_sqr);
    phase.phase_done.set_drain_time(this, 5000ns);
    phase.drop_objection( .obj( this ) );
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction

endclass: alu_div_zero_test

`endif // RVV_BACKEND_CORNER_TEST__SV
