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
  static int inst_cnt = 0;
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

//===========================================================
// To debug testbench.
//===========================================================
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

        vill ==  'b0;
        vma  ==  'b0;
        vta  ==  'b0;
        vsew ==  SEW8;
        vlmul == LMUL1;

        inst_type == ALU;
        alu_inst == VADD;
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

        vill ==  'b0;
        vma  ==  'b0;
        vta  ==  'b1;
        vsew ==  SEW8;
        vlmul == LMUL1;

        inst_type == ALU;
        alu_inst == VADD;
        dest_type == VRF; dest_idx == 16;
        src1_type == VRF; src1_idx == 1;
        src2_type == VRF; src2_idx == 16;
        rs1_data == 123;
        vm == 1; 
      });
      finish_item(req);
      inst_cnt++;
    end

  endtask
endclass: zero_seq

//===========================================================
// ALU direct test sequences
//===========================================================
//-----------------------------------------------------------
// Single instruction sequence
//-----------------------------------------------------------
class alu_smoke_vv_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vv_seq)
  `uvm_add_to_seq_lib(alu_smoke_vv_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vv_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == VRF; src1_idx == 2;
      vm == local::vm; 
    });
    `uvm_info("sequence_lib","Has generate transaction.",UVM_LOW)
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    `uvm_info("sequence_lib",$sformatf("the inst value is %s",inst),UVM_LOW)
    this.vm = vm;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vv_seq

class alu_smoke_ext_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_ext_seq)
  `uvm_add_to_seq_lib(alu_smoke_ext_seq,rvs_sequencer_sequence_library)
    
  alu_inst_e alu_inst;
  function new(string name = "alu_smoke_ext_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(vxunary0_e vext_func = vext_func.first();vext_func != vext_func.last(); vext_func = vext_func.next()) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vsew == SEW32;
        vlmul inside {LMUL1_2, LMUL2};

        inst_type == ALU;
        alu_inst == local::alu_inst;
        dest_type == VRF; dest_idx == 16;
        src2_type == VRF; src2_idx == 8;
        src1_type == FUNC; src1_idx == local::vext_func;
        vm == 0;
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask
  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_ext_seq

class alu_smoke_vx_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vx_seq)
  `uvm_add_to_seq_lib(alu_smoke_vx_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vx_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == XRF; src1_idx == 2;
      vm == local::vm; 
    });
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    this.vm = vm;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vx_seq

class alu_smoke_vmerge_vmvv_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vmerge_vmvv_seq)
  `uvm_add_to_seq_lib(alu_smoke_vmerge_vmvv_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vmerge_vmvv_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    // vmerge
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == VRF; src1_idx == 2;
      vm == 0; 
    });
    finish_item(req);
    inst_cnt++;
    
    // vmv.v
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 0;
      src1_type == VRF; src1_idx == 2;
      vm == 1; 
    });
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vmerge_vmvv_seq

class alu_smoke_vmunary0_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vmunary0_seq)
  `uvm_add_to_seq_lib(alu_smoke_vmunary0_seq,rvs_sequencer_sequence_library)
    
  alu_inst_e alu_inst;
  function new(string name = "alu_smoke_vmunary0_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(vmunary0_e vmunary0_func = vmunary0_func.first();vmunary0_func != vmunary0_func.last(); vmunary0_func = vmunary0_func.next()) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vsew == SEW16;
        vlmul inside {LMUL1_2, LMUL2};

        inst_type == ALU;
        alu_inst == local::alu_inst;
        (src1_idx inside {VIOTA}) -> 
          (dest_type == XRF);
        (src1_idx inside {VMSBF, VMSOF, VMSIF, VID}) -> 
          (dest_type == VRF && dest_idx == 16);
        (src1_idx == VID) -> (src2_type == UNUSE);
        (src1_idx == VID) -> (src2_idx dist{0 := 9, 1 := 1});
        (src1_idx != VID) -> (src2_type == VRF && src2_idx == 8);
        src1_type == FUNC; src1_idx == local::vmunary0_func;
        vm == 0;
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask
  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vmunary0_seq

class alu_smoke_vwxunary0_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vwxunary0_seq)
  `uvm_add_to_seq_lib(alu_smoke_vwxunary0_seq,rvs_sequencer_sequence_library)
    
  alu_inst_e alu_inst;
  function new(string name = "alu_smoke_vwxunary0_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(vwxunary0_e vwxunary0_func = vwxunary0_func.first();vwxunary0_func != vwxunary0_func.last(); vwxunary0_func = vwxunary0_func.next()) begin
      if(!(vwxunary0_func inside {VCPOP, VFIRST})) continue;
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vsew == SEW16;
        vlmul inside {LMUL1_2, LMUL2};

        inst_type == ALU;
        alu_inst == local::alu_inst;
        dest_type == XRF; dest_idx == 16;
        src2_type == VRF; src2_idx == 8;
        src1_type == FUNC; src1_idx == local::vwxunary0_func;
        vm == 0;
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask
  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vwxunary0_seq

class alu_smoke_vred_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vred_seq)
  `uvm_add_to_seq_lib(alu_smoke_vred_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vred_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == SCALAR; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == SCALAR; src1_idx == 2;
      vm == local::vm; 
    });
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    this.vm = vm;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vred_seq

class alu_smoke_vmv_xs_sx_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vmv_xs_sx_seq)
  `uvm_add_to_seq_lib(alu_smoke_vmv_xs_sx_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vmv_xs_sx_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1};//{LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == XRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == FUNC; src1_idx == 0;
      vm == local::vm; 
    });
    `uvm_info("sequence_lib","Has generate transaction.",UVM_LOW)
    finish_item(req);
    inst_cnt++;


    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1};//{LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == FUNC; src2_idx == 0;
      src1_type == XRF; src1_idx == 8;
      vm == local::vm; 
    });
    `uvm_info("sequence_lib","Has generate transaction.",UVM_LOW)
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    `uvm_info("sequence_lib",$sformatf("the inst value is %s",inst),UVM_LOW)
    this.vm = vm;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vmv_xs_sx_seq



class alu_smoke_vmvnr_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_vmvnr_seq)
  `uvm_add_to_seq_lib(alu_smoke_vmvnr_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  bit vm;
  function new(string name = "alu_smoke_vmvnr_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      use_vlmax == 0;
      pc == inst_cnt;

      vsew ==  SEW16;
      vlmul inside {LMUL1};//{LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == FUNC; src1_idx == 7;
      vm == local::vm; 
    });
    `uvm_info("sequence_lib","Has generate transaction.",UVM_LOW)
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    `uvm_info("sequence_lib",$sformatf("the inst value is %s",inst),UVM_LOW)
    this.vm = vm;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_vmvnr_seq


//-----------------------------------------------------------
// Iterate base
//-----------------------------------------------------------
class alu_iterate_base_sequence extends base_sequence;
  `uvm_object_utils(alu_iterate_base_sequence)
  `uvm_add_to_seq_lib(alu_iterate_base_sequence,rvs_sequencer_sequence_library)
   
  bit vm;
  sew_e sew;
  lmul_e lmul;
  alu_inst_e alu_inst;
  operand_type_e src1_type;

  test_rand_type_e rand_type = ITER;
  int inst_num = 1;

  function new(string name = "alu_iterate_base_sequence");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  task run_inst_iter(alu_inst_e inst, uvm_sequencer_base sqr, bit vm = 0);
    this.alu_inst = inst;
    this.vm = vm;
    this.rand_type = ITER;
    this.start(sqr);
  endtask: run_inst_iter
  
  task run_inst_rand(alu_inst_e inst, uvm_sequencer_base sqr, int inst_num = 50);
    this.alu_inst = inst;
    this.rand_type = RAND;
    this.inst_num = inst_num;
    this.start(sqr);
  endtask: run_inst_rand

endclass: alu_iterate_base_sequence

//-----------------------------------------------------------
// Iterate each lmul/sew for .vv/.vx/.vi
//-----------------------------------------------------------
class alu_iterate_vv_vx_vi_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vv_vx_vi_seq)
  `uvm_add_to_seq_lib(alu_iterate_vv_vx_vi_seq,rvs_sequencer_sequence_library)

  function new(string name = "alu_iterate_vv_vx_vi_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {VRF, XRF, IMM};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == IMM;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask: body
endclass: alu_iterate_vv_vx_vi_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vv/.vx/.vui
//-----------------------------------------------------------
class alu_iterate_vv_vx_vui_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vv_vx_vui_seq)
  `uvm_add_to_seq_lib(alu_iterate_vv_vx_vui_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vv_vx_vui_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {VRF, XRF, UIMM};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VNSRL, VNSRA, VNCLIPU, VNCLIP}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == UIMM;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask: body

endclass: alu_iterate_vv_vx_vui_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vv/.vx
//-----------------------------------------------------------
class alu_iterate_vv_vx_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vv_vx_seq)
  `uvm_add_to_seq_lib(alu_iterate_vv_vx_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vv_vx_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {VRF, XRF};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W,
              VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCSU}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VWADDU, VWADD, VWADDU_W, VWADD_W, VWSUBU, VWSUB, VWSUBU_W, VWSUB_W,
              VWMUL, VWMULU, VWMULSU, VWMACCU, VWMACC, VWMACCSU}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vv_vx_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vx/.vi
//-----------------------------------------------------------
class alu_iterate_vx_vi_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vx_vi_seq)
  `uvm_add_to_seq_lib(alu_iterate_vx_vi_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vx_vi_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {XRF, IMM};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == IMM;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vx_vi_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vv
//-----------------------------------------------------------
class alu_iterate_vv_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vv_seq)
  `uvm_add_to_seq_lib(alu_iterate_vv_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vv_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {VRF};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vv_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vx
//-----------------------------------------------------------
class alu_iterate_vx_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vx_seq)
  `uvm_add_to_seq_lib(alu_iterate_vx_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vx_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {XRF};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VWMACCUS}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vx_seq

//-----------------------------------------------------------
// Iterate vzext/vsext
//-----------------------------------------------------------
class alu_iterate_ext_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_ext_seq)
  `uvm_add_to_seq_lib(alu_iterate_ext_seq,rvs_sequencer_sequence_library)

  function new(string name = "alu_iterate_ext_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();;
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          src1_idx inside {VZEXT_VF4, VSEXT_VF4} -> vsew inside {SEW32};
          src1_idx inside {VZEXT_VF2, VSEXT_VF2} -> vsew inside {SEW16, SEW32};
          vlmul dist {
            LMUL1_4 :=  5,
            LMUL1_2 := 10,
            LMUL1   := 30,
            LMUL2   := 40,
            LMUL4   :=  5,
            LMUL8   := 10 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type == FUNC; src1_idx inside {VZEXT_VF4, VSEXT_VF4, VZEXT_VF2, VSEXT_VF2};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul_e lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew_e sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          for(vxunary0_e vext_func = vext_func.first();vext_func != vext_func.last(); vext_func = vext_func.next()) begin
            if(vext_func inside {VZEXT_VF4, VSEXT_VF4}) begin 
              if(!(sew inside {SEW32})) continue;
              if(lmul inside {LMUL1_4, LMUL1_2}) continue;
            end
            if(vext_func inside {VZEXT_VF2, VSEXT_VF2}) begin
              if(!(sew inside {SEW16, SEW32})) continue;
              if(lmul inside {LMUL1_4}) continue;
            end
            req = new("req");
            start_item(req);
            assert(req.randomize() with {
              use_vlmax == 1;
              pc == inst_cnt;

              vsew ==  local::sew;
              vlmul == local::lmul;

              inst_type == ALU;
              alu_inst == local::alu_inst;

              dest_type == VRF; 
              src2_type == VRF;
              src1_type == FUNC; src1_idx == local::vext_func;
              vm == local::vm;
            });
            finish_item(req);
            inst_cnt++;
          end
        end
      end
    end
  endtask

endclass: alu_iterate_ext_seq

//-----------------------------------------------------------
// Iterate vmerge/vmv.v
//-----------------------------------------------------------
class alu_iterate_vmerge_vmvv_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vmerge_vmvv_seq)
  `uvm_add_to_seq_lib(alu_iterate_vmerge_vmvv_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vmerge_vmvv_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          (local::vm == 1) -> (src2_type == UNUSE);
          (local::vm == 1) -> (src2_idx  == 0);
          (local::vm == 0) -> (src2_type == VRF);
          src1_type inside {VRF, XRF, IMM};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            (local::vm == 1) -> (src2_type == UNUSE);
            (local::vm == 1) -> (src2_idx  == 0);
            (local::vm == 0) -> (src2_type == VRF);
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            (local::vm == 1) -> (src2_type == UNUSE);
            (local::vm == 1) -> (src2_idx  == 0);
            (local::vm == 0) -> (src2_type == VRF);
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            (local::vm == 1) -> (src2_type == UNUSE);
            (local::vm == 1) -> (src2_idx  == 0);
            (local::vm == 0) -> (src2_type == VRF);
            src1_type == IMM; 
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
    end
  endtask

endclass: alu_iterate_vmerge_vmvv_seq

//-----------------------------------------------------------
// Iterate gathervv
//-----------------------------------------------------------
class alu_iterate_gather_vv_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_gather_vv_seq)
  `uvm_add_to_seq_lib(alu_iterate_gather_vv_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_gather_vv_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   := 15,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type inside {VRF};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
 //           vlmul == local::lmul;
            vlmul dist {
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   := 15,
            LMUL8   := 15 
          };

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == VRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_gather_vv_seq

//-----------------------------------------------------------
// Iterate vcpop/vfirst
//-----------------------------------------------------------
class alu_iterate_vwxunary0_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vwxunary0_seq)
  `uvm_add_to_seq_lib(alu_iterate_vwxunary0_seq,rvs_sequencer_sequence_library)

  function new(string name = "alu_iterate_vwxunary0_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 :=  5,
            LMUL1_2 := 10,
            LMUL1   := 30,
            LMUL2   := 40,
            LMUL4   :=  5,
            LMUL8   := 10 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == XRF;
          src2_type == VRF;
          src1_type == FUNC; src1_idx inside {VCPOP, VFIRST};
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul_e lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew_e sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          for(vwxunary0_e vwxunary0_func = vwxunary0_func.first();vwxunary0_func != vwxunary0_func.last(); vwxunary0_func = vwxunary0_func.next()) begin
            if(!(vwxunary0_func inside {VCPOP, VFIRST})) continue;
            req = new("req");
            start_item(req);
            assert(req.randomize() with {
              use_vlmax == 1;
              pc == inst_cnt;

              vsew ==  local::sew;
              vlmul == local::lmul;

              inst_type == ALU;
              alu_inst == local::alu_inst;

              dest_type == XRF; 
              src2_type == VRF;
              src1_type == FUNC; src1_idx == local::vwxunary0_func;
              vm == local::vm;
            });
            finish_item(req);
            inst_cnt++;
          end
        end
      end
    end
  endtask

endclass: alu_iterate_vwxunary0_seq

//-----------------------------------------------------------
// Iterate vmunary0
//-----------------------------------------------------------
class alu_iterate_vmunary0_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vmunary0_seq)
  `uvm_add_to_seq_lib(alu_iterate_vmunary0_seq,rvs_sequencer_sequence_library)

  function new(string name = "alu_iterate_vmunary0_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();;
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 :=  5,
            LMUL1_2 := 10,
            LMUL1   := 30,
            LMUL2   := 40,
            LMUL4   :=  5,
            LMUL8   := 10 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          (src1_idx != VID) -> (src2_type == VRF);
          (src1_idx == VID) -> (src2_type == UNUSE);
          (src1_idx == VID) -> (src2_idx dist{0 := 9, 1 := 1});
          src1_type == FUNC; src1_idx != VMUNARY0_NONE;
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul_e lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew_e sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          for(vmunary0_e vmunary0_func = vmunary0_func.first();vmunary0_func != vmunary0_func.last(); vmunary0_func = vmunary0_func.next()) begin
            req = new("req");
            start_item(req);
            assert(req.randomize() with {
              use_vlmax == 1;
              pc == inst_cnt;

              vsew ==  local::sew;
              vlmul == local::lmul;

              inst_type == ALU;
              alu_inst == local::alu_inst;

              dest_type == VRF; 
              (src1_idx != VID) -> (src2_type == VRF);
              (src1_idx == VID) -> (src2_type == UNUSE);
              (src1_idx == VID) -> (src2_idx dist{0 := 9, 1 := 1});
              src1_type == FUNC; src1_idx == local::vmunary0_func;
              vm == local::vm;
            });
            finish_item(req);
            inst_cnt++;
          end
        end
      end
    end
  endtask

endclass: alu_iterate_vmunary0_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for .vs
//-----------------------------------------------------------
class alu_iterate_vs_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vs_seq)
  `uvm_add_to_seq_lib(alu_iterate_vs_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vs_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          // use_vlmax == 1;
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == SCALAR;
          src2_type == VRF;
          src1_type == SCALAR;
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VWREDSUM, VWREDSUMU}) begin
            if(sew == SEW32) continue;
            if(lmul == LMUL8) continue;
          end
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == SCALAR;
            src2_type == VRF;
            src1_type == SCALAR;

            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vs_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for vmv.x.s / vmv.s.x
//-----------------------------------------------------------
class alu_iterate_vmv_xs_sx_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vmv_xs_sx_seq)
  `uvm_add_to_seq_lib(alu_iterate_vmv_xs_sx_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vmv_xs_sx_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          pc == local::inst_cnt;

          vlmul dist {
            LMUL1_4 := 10,
            LMUL1_2 := 20,
            LMUL1   := 20,
            LMUL2   := 30,
            LMUL4   :=  5,
            LMUL8   := 15 
          };

          inst_type == ALU;
          alu_inst == local::alu_inst;
          alu_type inside {OPMVV, OPMVX};
          (alu_type == OPMVV) -> (dest_type == XRF    && src2_type == SCALAR && src1_type == FUNC && src1_idx inside {VMV_X_S});
          (alu_type == OPMVX) -> (dest_type == SCALAR && src2_type == FUNC   && src1_type == XRF  && src2_idx inside {VMV_S_X});
          vm == 1;
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == SCALAR;
            src2_type == FUNC; src2_idx inside {VMV_S_X};
            src1_type == XRF;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == XRF;
            src2_type == SCALAR;
            src1_type == FUNC; src1_idx inside {VMV_X_S};
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vmv_xs_sx_seq

//-----------------------------------------------------------
// Iterate each lmul/sew for vmvnr
//-----------------------------------------------------------
class alu_iterate_vmvnr_seq extends alu_iterate_base_sequence;
  `uvm_object_utils(alu_iterate_vmvnr_seq)
  `uvm_add_to_seq_lib(alu_iterate_vmvnr_seq,rvs_sequencer_sequence_library)
    
  function new(string name = "alu_iterate_vmvnr_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(rand_type == RAND) begin
      repeat(inst_num) begin
        req = new("req");
        start_item(req);
        assert(req.randomize() with {
          //use_vlmax == 1;
          pc == local::inst_cnt;

          inst_type == ALU;
          alu_inst == local::alu_inst;

          dest_type == VRF;
          src2_type == VRF;
          src1_type == FUNC;
          vm == 1;
        });
        finish_item(req);
        inst_cnt++;
      end // repeat(inst_num)
    end else begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vsew ==  local::sew;
            vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF;
            src2_type == VRF;
            src1_type == FUNC;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end // sew
      end // lmul
    end
  endtask

endclass: alu_iterate_vmvnr_seq

//-----------------------------------------------------------
// ALU random sequence
//-----------------------------------------------------------
class alu_random_base_sequence extends base_sequence;
  `uvm_object_utils(alu_random_base_sequence)
  `uvm_add_to_seq_lib(alu_random_base_sequence,rvs_sequencer_sequence_library)
   
  int inst_num = 1;
  alu_inst_e alu_inst_set [$];

  function new(string name = "alu_random_base_sequence");
    alu_inst_e inst;
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
    inst = inst.first();
    while(inst != inst.last()) begin
      alu_inst_set.push_back(inst);
      inst = inst.next();
    end
  endfunction:new
  
  virtual task run_inst(uvm_sequencer_base sqr, int inst_num = 50);
    this.inst_num = inst_num;
    for(alu_inst_e inst = inst.first(); inst != inst.last(); inst = inst.next()) begin
      // inst.last() == UNUSE_INST
      // if(inst inside {}) continue; // unwanted inst
      alu_inst_set.push_back(inst);
    end
    this.start(sqr);
  endtask: run_inst
  
  virtual task run_rand_with_set(alu_inst_e inst_set[$], uvm_sequencer_base sqr, int inst_num = 50);
    this.alu_inst_set = inst_set;
    this.inst_num = inst_num;
    this.start(sqr);
  endtask: run_rand_with_set

endclass: alu_random_base_sequence

class alu_random_seq extends alu_random_base_sequence;
  `uvm_object_utils(alu_random_seq)
  `uvm_add_to_seq_lib(alu_random_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        inst_type == ALU;
        alu_inst inside {alu_inst_set};

      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: alu_random_seq

class alu_random_small_lmul_seq extends alu_random_base_sequence;
  `uvm_object_utils(alu_random_small_lmul_seq)
  `uvm_add_to_seq_lib(alu_random_small_lmul_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        vlmul dist {
          LMUL1_4 := 30,
          LMUL1_2 := 30,
          LMUL1   := 35,
          LMUL2   :=  5
        };

        inst_type == ALU;
        alu_inst inside {alu_inst_set};
        (alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) -> (src1_idx inside {0,1}); // constraint vmv<nr>r

      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: alu_random_small_lmul_seq

class alu_random_large_lmul_seq extends alu_random_base_sequence;
  `uvm_object_utils(alu_random_large_lmul_seq)
  `uvm_add_to_seq_lib(alu_random_large_lmul_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        vlmul dist {
          LMUL2   :=  5,
          LMUL4   := 35,
          LMUL8   := 60 
        };

        inst_type == ALU;
        alu_inst inside {alu_inst_set};
        (alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) -> (src1_idx inside {3,7}); // constraint vmv<nr>r

      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: alu_random_large_lmul_seq

class alu_random_bypass_seq extends alu_random_base_sequence;
  `uvm_object_utils(alu_random_bypass_seq)
  `uvm_add_to_seq_lib(alu_random_bypass_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        vlmul dist {
          LMUL1_4 := 20,
          LMUL1_2 := 40,
          LMUL1   := 40
        };

        inst_type == ALU;
        alu_inst inside {alu_inst_set};
        (alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) -> (src1_idx inside {0}); // only use vmv1r

        (dest_type == VRF) -> (dest_idx inside {[0:3]});
        (src2_type == VRF) -> (src2_idx inside {[0:3]});
        (src1_type == VRF) -> (src1_idx inside {[0:3]});
      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: alu_random_bypass_seq

class alu_random_waw_seq extends alu_random_base_sequence;
  `uvm_object_utils(alu_random_waw_seq)
  `uvm_add_to_seq_lib(alu_random_waw_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        vlmul dist {
          LMUL1_4 := 20,
          LMUL1_2 := 40,
          LMUL1   := 40
        };

        inst_type == ALU;
        alu_inst inside {alu_inst_set};
        (alu_inst == VSMUL_VMVNRR && alu_type == OPIVI && src1_type == FUNC) -> (src1_idx inside {0}); // only use vmv1r

        dest_type == VRF;
        (dest_type == VRF) -> (dest_idx inside {[0:3]});
      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: alu_random_waw_seq

class div_random_seq extends alu_random_base_sequence;
  `uvm_object_utils(div_random_seq)
  `uvm_add_to_seq_lib(div_random_seq,rvs_sequencer_sequence_library)

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == local::inst_cnt;

        inst_type == ALU;
        alu_inst inside {VDIVU, VDIV, VREMU, VREM};

      });
      finish_item(req);
      inst_cnt++;
    end // repeat(inst_num)
  endtask

endclass: div_random_seq
//===========================================================
// LSU sequence
//===========================================================
class lsu_base_seq extends base_sequence;
  `uvm_object_utils(lsu_base_seq)
  `uvm_add_to_seq_lib(lsu_base_seq,rvs_sequencer_sequence_library)

  lsu_inst_e inst_set [$];
  int inst_num = 1;

  function new(string name = "lsu_base_seq");
    lsu_inst_e inst;
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
    inst = inst.first();
    while(inst != inst.last()) begin
      inst_set.push_back(inst);
      inst = inst.next();
    end
  endfunction:new
  
  virtual task run_inst(lsu_inst_e inst, uvm_sequencer_base sqr, int inst_num = 50);
    this.inst_set.delete();
    this.inst_set.push_back(inst);
    this.inst_num = inst_num;

    this.start(sqr);
  endtask: run_inst
  
  virtual task run_inst_set(lsu_inst_e inst_set[$], uvm_sequencer_base sqr, int inst_num = 50);
    if(inst_set.size() ==0 ) begin
      for(lsu_inst_e inst = inst.first(); inst != inst.last(); inst = inst.next()) begin
        this.inst_set.delete();
        inst_set.push_back(inst);
      end
    end else begin
      this.inst_set.delete();
      this.inst_set = inst_set;
    end
    this.inst_num = inst_num;
    this.start(sqr);
  endtask: run_inst_set

  virtual task body();
    repeat(inst_num) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        pc == inst_cnt;
        inst_type inside {LD, ST};
        lsu_inst inside {inst_set};
      });
      finish_item(req);
      inst_cnt++;
    end
  endtask
endclass: lsu_base_seq 

//===========================================================
// Special usage sequences
//===========================================================
// Last sequence: to control objection & clean all queues
class rvs_last_sequence extends base_sequence;
  `uvm_object_utils(rvs_last_sequence)

  function new(string name = "rvs_last_sequence");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new
  
  virtual task body();
      req = new("req");
      start_item(req);
      req.is_last_inst = 1;
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vill ==  'b0;
        vma  ==  'b0;
        vta  ==  'b0;
        vsew ==  SEW8;
        vlmul == LMUL1;

        inst_type == ALU;
        alu_inst  == VADD;
        dest_type == VRF; dest_idx == 0;
        src1_type == VRF; src1_idx == 0;
        src2_type == VRF; src2_idx == 0;
        vm == 1; 
      });
      finish_item(req);
      inst_cnt++;
  endtask
endclass: rvs_last_sequence 



`endif // RVS_SEQUENCER_SEQUENCE_LIBRARY__SV
