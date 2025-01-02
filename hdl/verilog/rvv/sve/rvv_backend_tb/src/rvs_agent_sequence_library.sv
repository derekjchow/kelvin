`ifndef RVS_SEQUENCER_SEQUENCE_LIBRARY__SV
`define RVS_SEQUENCER_SEQUENCE_LIBRARY__SV

`include "inst_description.svh"
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

        vtype.vill ==  'b0;
        vtype.rsv  ==  'b0;  
        vtype.vma  ==  'b0;
        vtype.vta  ==  'b0;
        vtype.vsew ==  SEW8;
        vtype.vlmul == LMUL1;

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

        vtype.vill ==  'b0;
        vtype.rsv  ==  'b0;  
        vtype.vma  ==  'b0;
        vtype.vta  ==  'b1;
        vtype.vsew ==  SEW8;
        vtype.vlmul == LMUL1;

        inst_type == ALU;
        alu_inst == VADD;
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

//===========================================================
// ALU direct test sequences
//===========================================================
//-----------------------------------------------------------
// Single instruction sequence
//-----------------------------------------------------------
class alu_smoke_seq extends base_sequence;
  `uvm_object_utils(alu_smoke_seq)
  `uvm_add_to_seq_lib(alu_smoke_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
  oprand_type_e src1_type;
  function new(string name = "alu_smoke_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    if(alu_inst inside {VRSUB}) src1_type = XRF;
    else src1_type = VRF;
    assert(req.randomize() with {
      use_vlmax == 1;
      pc == inst_cnt;

      vtype.vsew ==  SEW16;
      vtype.vlmul inside {LMUL1_2, LMUL2};

      inst_type == ALU;
      alu_inst == local::alu_inst;
      dest_type == VRF; dest_idx == 16;
      src2_type == VRF; src2_idx == 8;
      src1_type == local::src1_type; src1_idx == 2;
      vm == 0; 
    });
    finish_item(req);
    inst_cnt++;
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_smoke_seq

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
    for(vext_e vext_func = vext_func.first();vext_func != vext_func.last(); vext_func = vext_func.next()) begin
      req = new("req");
      start_item(req);
      assert(req.randomize() with {
        use_vlmax == 1;
        pc == inst_cnt;

        vtype.vsew == SEW8;
        vtype.vlmul inside {LMUL1_2, LMUL2};

        inst_type == ALU;
        alu_inst == local::alu_inst;
        dest_type == VRF; 
        src1_type == FUNC; src1_idx == local::vext_func;
        src2_type == VRF;
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
//-----------------------------------------------------------
// Iterate each vm/lmul/sew/red_idx for .vv/.vx/.vi
// Total: 1,179,648 + 36,864 + 1,179,648 = 2,396,160
//-----------------------------------------------------------
class alu_iterate_vxi_seq extends base_sequence;
  `uvm_object_utils(alu_iterate_vxi_seq)
  `uvm_add_to_seq_lib(alu_iterate_vxi_seq,rvs_sequencer_sequence_library)
    
  bit iterate_all_reg;
  sew_e sew;
  lmul_e lmul;
  alu_inst_e alu_inst;
  oprand_type_e src1_type;

  function new(string name = "alu_iterate_vxi_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    if(iterate_all_reg) begin
      for(int vm=0; vm<=1; vm++) begin
        for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
          for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
            for(int dest_idx=0; dest_idx<32; dest_idx++) begin
              for(int src2_idx=0; src2_idx<32; src2_idx++) begin
                for(int src1_idx=0; src1_idx<32; src1_idx++) begin
                  req = new("req");
                  start_item(req);
                  assert(req.randomize() with {
                    use_vlmax == 1;
                    pc == inst_cnt;

                    vtype.vsew ==  local::sew;
                    vtype.vlmul == local::lmul;

                    inst_type == ALU;
                    alu_inst == local::alu_inst;

                    dest_type == VRF; dest_idx == local::dest_idx; 
                    src2_type == VRF; src2_idx == local::src2_idx;
                    src1_type == VRF; src1_idx == local::src1_idx;
                    vm == local::vm;
                  });
                  finish_item(req);
                  inst_cnt++;
                end // src1_idx
              end // src2_idx
            end // dest_idx
          end // sew
        end // lmul
        for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
          for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
            for(int dest_idx=0; dest_idx<32; dest_idx++) begin
              for(int src2_idx=0; src2_idx<32; src2_idx++) begin
                  req = new("req");
                  start_item(req);
                  assert(req.randomize() with {
                    use_vlmax == 1;
                    pc == local::inst_cnt;

                    vtype.vsew ==  local::sew;
                    vtype.vlmul == local::lmul;

                    inst_type == ALU;
                    alu_inst == local::alu_inst;

                    dest_type == VRF; dest_idx == local::dest_idx;
                    src2_type == VRF; src2_idx == local::src2_idx;
                    src1_type == XRF;
                    vm == local::vm;
                  });
                  finish_item(req);
                  inst_cnt++;
              end // src2_idx
            end // dest_idx
          end // sew
        end // lmul
        for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
          for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
            for(int dest_idx=0; dest_idx<32; dest_idx++) begin
              for(int src2_idx=0; src2_idx<32; src2_idx++) begin
                for(int src1_idx=0; src1_idx<32; src1_idx++) begin
                  req = new("req");
                  start_item(req);
                  assert(req.randomize() with {
                    use_vlmax == 1;
                    pc == inst_cnt;

                    vtype.vsew ==  local::sew;
                    vtype.vlmul == local::lmul;

                    inst_type == ALU;
                    alu_inst == local::alu_inst;

                    dest_type == VRF; dest_idx == local::dest_idx; 
                    src2_type == VRF; src2_idx == local::src2_idx;
                    src1_type == IMM; src1_idx == local::src1_idx;
                    vm == local::vm;
                  });
                  finish_item(req);
                  inst_cnt++;
                end // src1_idx
              end // src2_idx
            end // dest_idx
          end // sew
        end // lmul
      end // vm
    end else begin
      for(int vm=0; vm<=1; vm++) begin
        for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
          for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
            req = new("req");
            start_item(req);
            assert(req.randomize() with {
              use_vlmax == 1;
              pc == inst_cnt;

              vtype.vsew ==  local::sew;
              vtype.vlmul == local::lmul;

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
              pc == local::inst_cnt;

              vtype.vsew ==  local::sew;
              vtype.vlmul == local::lmul;

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

              vtype.vsew ==  local::sew;
              vtype.vlmul == local::lmul;

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
      end // vm
    end // iterate_all_reg
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr, bit ite_all = 0);
    this.alu_inst = inst;
    this.start(sqr);
    this.iterate_all_reg = ite_all;
  endtask: run_inst
endclass: alu_iterate_vxi_seq

class alu_iterate_ext_seq extends base_sequence;
  `uvm_object_utils(alu_iterate_ext_seq)
  `uvm_add_to_seq_lib(alu_iterate_ext_seq,rvs_sequencer_sequence_library)
    
  alu_inst_e alu_inst;
  function new(string name = "alu_iterate_ext_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(int vm=0; vm<=1; vm++) begin
      for(lmul_e lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew_e sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          for(vext_e vext_func = vext_func.first();vext_func != vext_func.last(); vext_func = vext_func.next()) begin
            if((vext_func == VZEXT_VF4 || vext_func == VSEXT_VF4) && sew != SEW32) continue;
            if((vext_func == VZEXT_VF2 || vext_func == VZEXT_VF2) && (sew == SEW8)) continue;
            req = new("req");
            start_item(req);
            assert(req.randomize() with {
              use_vlmax == 1;
              pc == inst_cnt;

              vtype.vsew ==  local::sew;
              vtype.vlmul == local::lmul;

              inst_type == ALU;
              alu_inst == local::alu_inst;

              dest_type == VRF; 
              src1_type == FUNC; src1_idx == local::vext_func;
              src2_type == VRF;
              vm == local::vm;
            });
            finish_item(req);
            inst_cnt++;
          end
        end
      end
    end
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_iterate_ext_seq

class alu_iterate_vmerge_seq extends base_sequence;
  `uvm_object_utils(alu_iterate_vmerge_seq)
  `uvm_add_to_seq_lib(alu_iterate_vmerge_seq,rvs_sequencer_sequence_library)
    
  sew_e sew;
  lmul_e lmul;
  alu_inst_e alu_inst;
  oprand_type_e src1_type;

  function new(string name = "alu_iterate_vcomp_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(int vm=0; vm<=1; vm++) begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VMSGTU, VMSGT} ) continue;
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == VRF; src1_idx == 8;
            src2_type == local::vm ? UNUSE : VRF; 
            src2_idx == local::vm ? 0 : 16;
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

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == XRF; src1_idx == 8;
            src2_type == local::vm ? UNUSE : VRF; 
            src2_idx == local::vm ? 0 : 16;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VMSLTU, VMSLT} ) continue;
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == IMM; 
            src2_type == local::vm ? UNUSE : VRF; 
            src2_idx == local::vm ? 0 : 16;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
    end
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_iterate_vmerge_seq

class alu_iterate_vcomp_seq extends base_sequence;
  `uvm_object_utils(alu_iterate_vcomp_seq)
  `uvm_add_to_seq_lib(alu_iterate_vcomp_seq,rvs_sequencer_sequence_library)
    
  sew_e sew;
  lmul_e lmul;
  alu_inst_e alu_inst;
  oprand_type_e src1_type;

  function new(string name = "alu_iterate_vcomp_seq");
    super.new(name);
	  `ifdef UVM_POST_VERSION_1_1
      set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    for(int vm=0; vm<=1; vm++) begin
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VMSGTU, VMSGT} ) continue;
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == inst_cnt;

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == VRF; src1_idx == 8;
            src2_type == VRF; src2_idx == 16;
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

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == XRF; src1_idx == 8;
            src2_type == VRF; src2_idx == 16;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
      for(lmul = lmul.first(); lmul != lmul.last(); lmul =lmul.next()) begin
        for(sew = sew.first(); sew != sew.last(); sew =sew.next()) begin
          if(alu_inst inside {VMSLTU, VMSLT} ) continue;
          req = new("req");
          start_item(req);
          assert(req.randomize() with {
            use_vlmax == 1;
            pc == local::inst_cnt;

            vtype.vsew ==  local::sew;
            vtype.vlmul == local::lmul;

            inst_type == ALU;
            alu_inst == local::alu_inst;

            dest_type == VRF; dest_idx == 24;
            src1_type == IMM; 
            src2_type == VRF; src2_idx == 16;
            vm == local::vm;
          });
          finish_item(req);
          inst_cnt++;
        end
      end
    end
  endtask

  task run_inst(alu_inst_e inst, uvm_sequencer_base sqr);
    this.alu_inst = inst;
    this.start(sqr);
  endtask: run_inst
endclass: alu_iterate_vcomp_seq
//=================================================
// LDST direct test sequence
//=================================================
class lsu_unit_stride_seq extends base_sequence;
  `uvm_object_utils(lsu_unit_stride_seq)
  `uvm_add_to_seq_lib(lsu_unit_stride_seq,rvs_sequencer_sequence_library)

  alu_inst_e alu_inst;
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
