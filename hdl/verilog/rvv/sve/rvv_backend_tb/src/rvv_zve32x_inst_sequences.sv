`ifndef RVV_ZVE32X_INST_SEQUENCE_LIBRARY__SV
`define RVV_ZVE32X_INST_SEQUENCE_LIBRARY__SV
// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadd_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadd_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadd_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADD;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadd_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadd_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadd_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadd_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADD;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadd_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadd_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadd_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadd_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadd_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADD;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadd_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsub_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsub_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsub_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsub_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsub_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSUB;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsub_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsub_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSUB;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrsub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrsub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrsub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrsub_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrsub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VRSUB;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrsub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrsub_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrsub_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrsub_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrsub_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrsub_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VRSUB;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrsub_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwaddu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwaddu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwaddu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADDU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwaddu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwaddu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwaddu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwaddu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADDU;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwaddu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsubu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsubu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsubu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUBU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsubu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsubu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsubu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsubu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUBU;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsubu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwadd_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwadd_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwadd_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADD;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwadd_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwadd_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwadd_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwadd_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADD;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwadd_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsub_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsub_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsub_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUB;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsub_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUB;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwaddu_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwaddu_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwaddu_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADDU_W;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwaddu_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwaddu_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwaddu_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwaddu_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwaddu_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADDU_W;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwaddu_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsubu_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsubu_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsubu_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUBU_W;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsubu_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsubu_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsubu_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsubu_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsubu_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUBU_W;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsubu_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwadd_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwadd_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwadd_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADD_W;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwadd_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwadd_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwadd_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwadd_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwadd_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWADD_W;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwadd_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsub_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsub_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsub_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUB_W;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsub_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwsub_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwsub_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwsub_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwsub_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWSUB_W;
      alu_type == OPMVX ;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwsub_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vzext_vf2_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vzext_vf2_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vzext_vf2_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vzext_vf2_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vzext_vf2_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW16, SEW32};
      vlmul inside {LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00110;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vzext_vf2_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsext_vf2_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsext_vf2_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsext_vf2_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsext_vf2_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsext_vf2_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW16, SEW32};
      vlmul inside {LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00111;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsext_vf2_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vzext_vf4_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vzext_vf4_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vzext_vf4_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vzext_vf4_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vzext_vf4_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW32};
      vlmul inside {LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00100;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vzext_vf4_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsext_vf4_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsext_vf4_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsext_vf4_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsext_vf4_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsext_vf4_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW32};
      vlmul inside {LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00101;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsext_vf4_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadc_vvm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadc_vvm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vvm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vvm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadc_vvm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadc_vvm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadc_vxm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadc_vxm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vxm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vxm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadc_vxm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadc_vxm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vadc_vim_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vadc_vim_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vim_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vadc_vim_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vadc_vim_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VADC;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vadc_vim_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vvm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vvm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vvm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vvm_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vvm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vvm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vxm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vxm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vxm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vxm_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vxm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vxm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vim_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vim_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vim_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vim_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vim_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vim_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadc_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadc_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadc_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadc_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADC;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadc_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsbc_vvm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsbc_vvm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsbc_vvm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsbc_vvm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsbc_vvm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSBC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsbc_vvm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsbc_vxm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsbc_vxm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsbc_vxm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsbc_vxm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsbc_vxm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSBC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsbc_vxm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsbc_vvm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsbc_vvm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vvm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vvm_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsbc_vvm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSBC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsbc_vvm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsbc_vxm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsbc_vxm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vxm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vxm_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsbc_vxm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSBC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsbc_vxm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsbc_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsbc_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsbc_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSBC;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsbc_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsbc_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsbc_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbc_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsbc_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSBC;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsbc_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vand_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vand_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vand_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAND;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vand_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vand_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vand_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vand_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAND;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vand_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vand_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vand_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vand_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vand_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAND;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vand_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vor_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vor_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vor_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VOR;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vor_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vor_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vor_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vor_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VOR;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vor_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vor_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vor_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vor_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vor_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VOR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vor_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vxor_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vxor_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vxor_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXOR;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vxor_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vxor_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vxor_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vxor_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXOR;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vxor_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vxor_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vxor_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vxor_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vxor_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VXOR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vxor_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsll_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsll_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsll_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLL;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsll_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsll_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsll_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsll_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLL;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsll_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsll_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsll_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsll_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsll_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLL;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsll_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsrl_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsrl_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsrl_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRL;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsrl_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsrl_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsrl_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsrl_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRL;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsrl_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsrl_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsrl_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsrl_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsrl_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRL;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsrl_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsra_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsra_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsra_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRA;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsra_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsra_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsra_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsra_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRA;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsra_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsra_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsra_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsra_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsra_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSRA;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsra_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsrl_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsrl_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsrl_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRL;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsrl_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsrl_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsrl_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsrl_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRL;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsrl_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsrl_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsrl_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsrl_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsrl_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRL;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsrl_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsra_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsra_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsra_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRA;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsra_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsra_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsra_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsra_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRA;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsra_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnsra_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnsra_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnsra_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnsra_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNSRA;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnsra_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmseq_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmseq_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmseq_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSEQ;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmseq_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmseq_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmseq_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmseq_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSEQ;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmseq_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmseq_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmseq_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmseq_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmseq_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSEQ;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmseq_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsne_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsne_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsne_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSNE;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsne_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsne_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsne_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsne_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSNE;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsne_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsne_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsne_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsne_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsne_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSNE;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsne_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsltu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsltu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsltu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsltu_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsltu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLTU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsltu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsltu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsltu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsltu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsltu_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsltu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLTU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsltu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmslt_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmslt_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmslt_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmslt_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmslt_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLT;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmslt_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmslt_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmslt_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmslt_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmslt_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmslt_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLT;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmslt_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsleu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsleu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsleu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLEU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsleu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsleu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsleu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsleu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLEU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsleu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsleu_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsleu_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsleu_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsleu_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLEU;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsleu_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsle_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsle_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsle_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLE;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsle_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsle_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsle_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsle_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLE;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsle_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsle_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsle_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsle_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsle_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSLE;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsle_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsgtu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsgtu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgtu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgtu_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsgtu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSGTU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsgtu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsgtu_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsgtu_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgtu_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgtu_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsgtu_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSGTU;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsgtu_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsgt_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsgt_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgt_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgt_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsgt_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSGT;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsgt_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsgt_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsgt_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgt_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsgt_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsgt_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMSGT;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsgt_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vminu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vminu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vminu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vminu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vminu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMINU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vminu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vminu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vminu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vminu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vminu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vminu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMINU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vminu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmin_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmin_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmin_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmin_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmin_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMIN;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmin_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmin_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmin_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmin_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmin_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmin_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMIN;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmin_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmaxu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmaxu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmaxu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmaxu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmaxu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMAXU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmaxu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmaxu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmaxu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmaxu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmaxu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmaxu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMAXU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmaxu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmax_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmax_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmax_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmax_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmax_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMAX;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmax_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmax_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmax_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmax_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmax_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmax_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMAX;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmax_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmul_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmul_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmul_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmul_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmul_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUL;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmul_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmul_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmul_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmul_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmul_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmul_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUL;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmul_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulh_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulh_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulh_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulh_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulh_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULH;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulh_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulh_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulh_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulh_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulh_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulh_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULH;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulh_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulhu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulhu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulhu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULHU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulhu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulhu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulhu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulhu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULHU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulhu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulhsu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulhsu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhsu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhsu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulhsu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULHSU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulhsu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmulhsu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmulhsu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhsu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmulhsu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmulhsu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMULHSU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmulhsu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmul_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmul_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmul_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmul_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmul_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMUL;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmul_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmul_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmul_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmul_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmul_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmul_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMUL;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmul_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmulu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmulu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmulu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMULU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmulu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmulu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmulu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmulu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMULU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmulu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmulsu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmulsu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulsu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulsu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmulsu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMULSU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmulsu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmulsu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmulsu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulsu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmulsu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmulsu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMULSU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmulsu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmacc_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmacc_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmacc_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmacc_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmacc_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMACC;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmacc_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmacc_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmacc_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmacc_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmacc_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmacc_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMACC;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmacc_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnmsac_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnmsac_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsac_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsac_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnmsac_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VNMSAC;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnmsac_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnmsac_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnmsac_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsac_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsac_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnmsac_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VNMSAC;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnmsac_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadd_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadd_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadd_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadd_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadd_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADD;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadd_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmadd_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmadd_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadd_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmadd_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmadd_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMADD;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmadd_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnmsub_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnmsub_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsub_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsub_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnmsub_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VNMSUB;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnmsub_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnmsub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnmsub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnmsub_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnmsub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VNMSUB;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnmsub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmaccu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmaccu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmaccu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACCU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmaccu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmaccu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmaccu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmaccu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACCU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmaccu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmacc_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmacc_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmacc_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmacc_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmacc_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACC;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmacc_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmacc_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmacc_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmacc_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmacc_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmacc_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACC;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmacc_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmaccsu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmaccsu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccsu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccsu_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmaccsu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACCSU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmaccsu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmaccsu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmaccsu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccsu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccsu_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmaccsu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACCSU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmaccsu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwmaccus_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwmaccus_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccus_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwmaccus_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwmaccus_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VWMACCUS;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwmaccus_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vdivu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vdivu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdivu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdivu_vv_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vdivu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VDIVU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vdivu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vdivu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vdivu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdivu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdivu_vx_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vdivu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VDIVU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vdivu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vdiv_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vdiv_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdiv_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdiv_vv_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vdiv_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VDIV;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vdiv_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vdiv_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vdiv_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdiv_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vdiv_vx_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vdiv_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VDIV;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vdiv_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vremu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vremu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vremu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vremu_vv_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vremu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREMU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vremu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vremu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vremu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vremu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vremu_vx_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vremu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREMU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vremu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrem_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrem_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrem_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrem_vv_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrem_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREM;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrem_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrem_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrem_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrem_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrem_vx_seq,rvv_div_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrem_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREM;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrem_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmerge_vvm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmerge_vvm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vvm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vvm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmerge_vvm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmerge_vvm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmerge_vxm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmerge_vxm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vxm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vxm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmerge_vxm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmerge_vxm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmerge_vim_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmerge_vim_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vim_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmerge_vim_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmerge_vim_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmerge_vim_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv_v_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv_v_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv_v_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==  UNUSE; src2_idx == 5'b00000;
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv_v_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv_v_x_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv_v_x_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_x_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_x_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv_v_x_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==  UNUSE; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv_v_x_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv_v_i_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv_v_i_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_i_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_v_i_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv_v_i_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMERGE_VMVV;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==  UNUSE; src2_idx == 5'b00000;
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv_v_i_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsaddu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsaddu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsaddu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADDU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsaddu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsaddu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsaddu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsaddu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADDU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsaddu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsaddu_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsaddu_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsaddu_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsaddu_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADDU;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsaddu_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsadd_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsadd_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsadd_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADD;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsadd_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsadd_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsadd_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsadd_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADD;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsadd_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsadd_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsadd_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsadd_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsadd_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSADD;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsadd_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssubu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssubu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssubu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssubu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssubu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSUBU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssubu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssubu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssubu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssubu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssubu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssubu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSUBU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssubu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssub_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssub_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssub_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssub_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssub_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSUB;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssub_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssub_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSUB;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vaaddu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vaaddu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaaddu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaaddu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vaaddu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAADDU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vaaddu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vaaddu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vaaddu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaaddu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaaddu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vaaddu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAADDU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vaaddu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vaadd_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vaadd_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaadd_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaadd_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vaadd_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAADD;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vaadd_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vaadd_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vaadd_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaadd_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vaadd_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vaadd_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VAADD;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vaadd_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vasubu_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vasubu_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasubu_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasubu_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vasubu_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VASUBU;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vasubu_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vasubu_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vasubu_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasubu_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasubu_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vasubu_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VASUBU;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vasubu_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vasub_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vasub_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasub_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasub_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vasub_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VASUB;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vasub_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vasub_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vasub_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasub_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vasub_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vasub_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VASUB;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vasub_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsmul_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsmul_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsmul_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsmul_vv_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsmul_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsmul_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsmul_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsmul_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsmul_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsmul_vx_seq,rvv_mulmac_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsmul_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsmul_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssrl_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssrl_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssrl_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRL;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssrl_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssrl_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssrl_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssrl_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRL;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssrl_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssrl_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssrl_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssrl_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssrl_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRL;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssrl_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssra_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssra_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssra_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRA;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssra_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssra_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssra_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssra_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRA;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssra_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssra_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssra_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssra_vi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssra_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSSRA;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssra_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclipu_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclipu_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclipu_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIPU;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclipu_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclipu_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclipu_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclipu_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIPU;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclipu_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclipu_wi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclipu_wi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclipu_wi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclipu_wi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIPU;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclipu_wi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclip_wv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclip_wv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wv_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclip_wv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIP;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclip_wv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclip_wx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclip_wx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wx_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclip_wx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIP;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclip_wx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vnclip_wi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vnclip_wi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vnclip_wi_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vnclip_wi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ALU;
      alu_inst == VNCLIP;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vnclip_wi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredsum_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredsum_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredsum_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredsum_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredsum_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDSUM;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredsum_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredmaxu_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredmaxu_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmaxu_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmaxu_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredmaxu_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDMAXU;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredmaxu_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredmax_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredmax_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmax_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmax_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredmax_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDMAX;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredmax_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredminu_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredminu_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredminu_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredminu_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredminu_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDMINU;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredminu_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredmin_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredmin_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmin_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredmin_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredmin_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDMIN;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredmin_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredand_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredand_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredand_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredand_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredand_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDAND;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredand_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredor_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredor_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredor_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredor_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredor_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredor_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vredxor_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vredxor_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredxor_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vredxor_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vredxor_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VREDXOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vredxor_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwredsumu_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwredsumu_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwredsumu_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwredsumu_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwredsumu_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWREDSUMU;
      alu_type == OPIVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwredsumu_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vwredsum_vs_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vwredsum_vs_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwredsum_vs_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vwredsum_vs_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vwredsum_vs_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWREDSUM;
      alu_type == OPIVV;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type == SCALAR; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vwredsum_vs_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmand_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmand_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmand_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmand_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmand_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMAND;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmand_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmnand_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmnand_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmnand_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmnand_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmnand_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMNAND;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmnand_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmandn_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmandn_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmandn_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmandn_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmandn_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMANDN;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmandn_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmxor_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmxor_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmxor_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmxor_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmxor_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMXOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmxor_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmor_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmor_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmor_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmor_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmor_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmor_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmnor_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmnor_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmnor_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmnor_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmnor_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMNOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmnor_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmorn_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmorn_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmorn_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmorn_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmorn_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMORN;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmorn_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmxnor_mm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmxnor_mm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmxnor_mm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmxnor_mm_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmxnor_mm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMXNOR;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmxnor_mm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vcpop_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vcpop_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcpop_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcpop_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vcpop_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    XRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b10000;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vcpop_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vfirst_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vfirst_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vfirst_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vfirst_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vfirst_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    XRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b10001;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vfirst_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsbf_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsbf_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbf_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsbf_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsbf_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00001;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsbf_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsif_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsif_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsif_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsif_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsif_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00011;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsif_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmsof_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmsof_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsof_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmsof_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmsof_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00010;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmsof_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_viota_m_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_viota_m_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_viota_m_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_viota_m_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_viota_m_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b10000;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_viota_m_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vid_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vid_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vid_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vid_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vid_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==  UNUSE; src2_idx == 5'b00000;
      src1_type ==   FUNC; src1_idx == 5'b10001;
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vid_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv_x_s_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv_x_s_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_x_s_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_x_s_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv_x_s_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    XRF; dest_idx inside {[0:31]};
      src2_type == SCALAR; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00000;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv_x_s_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv_s_x_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv_s_x_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_s_x_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv_s_x_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv_s_x_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWXUNARY0;
      alu_type == OPMVX;
      /* oprand */
      dest_type == SCALAR; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv_s_x_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslideup_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslideup_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslideup_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslideup_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslideup_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDEUP_RGATHEREI16;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslideup_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslideup_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslideup_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslideup_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslideup_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslideup_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDEUP_RGATHEREI16;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslideup_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslidedown_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslidedown_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslidedown_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslidedown_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslidedown_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDEDOWN;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslidedown_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslidedown_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslidedown_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslidedown_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslidedown_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslidedown_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDEDOWN;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    IMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslidedown_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslide1up_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslide1up_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslide1up_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslide1up_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslide1up_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDE1UP;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslide1up_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vslide1down_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vslide1down_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslide1down_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vslide1down_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vslide1down_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDE1DOWN;
      alu_type == OPMVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vslide1down_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrgather_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrgather_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrgather_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VRGATHER;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrgather_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrgatherei16_vv_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrgatherei16_vv_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgatherei16_vv_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgatherei16_vv_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrgatherei16_vv_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSLIDEUP_RGATHEREI16;
      alu_type == OPIVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrgatherei16_vv_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrgather_vx_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrgather_vx_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vx_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vx_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrgather_vx_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VRGATHER;
      alu_type == OPIVX;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrgather_vx_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vrgather_vi_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vrgather_vi_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vi_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vrgather_vi_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vrgather_vi_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VRGATHER;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   UIMM; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vrgather_vi_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vcompress_vm_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vcompress_vm_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcompress_vm_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcompress_vm_seq,rvv_pmtrdt_sequence_library)

  function new(string name = "inst_rvv_zve32x_vcompress_vm_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VCOMPRESS;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    VRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vcompress_vm_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv1r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv1r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv1r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv1r_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv1r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00000;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv1r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv2r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv2r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv2r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv2r_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv2r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00001;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv2r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv4r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv4r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv4r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv4r_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv4r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00011;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv4r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vmv8r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vmv8r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv8r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vmv8r_v_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vmv8r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VSMUL_VMVNRR;
      alu_type == OPIVI;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b00111;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vmv8r_v_seq


// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VL;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VL;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VL;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vse8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vse8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vse8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VS;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vse8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vse16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vse16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vse16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VS;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vse16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vse32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vse32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vse32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vse32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VS;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vse32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlm_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlm_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlm_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlm_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlm_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLM;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01011;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlm_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsm_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsm_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsm_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsm_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsm_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSM;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01011;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsm_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlse8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlse8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlse8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlse8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlse16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlse16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlse16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlse16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlse32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlse32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlse32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlse32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlse32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsse8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsse8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsse8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsse8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsse16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsse16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsse16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsse16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsse32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsse32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsse32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsse32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSS;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsse32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUX;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOX;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vle32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vle32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vle32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vle32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vle32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg2e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg2e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg2e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg2e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg3e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg3e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg3e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg3e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg4e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg4e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg4e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg4e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg5e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg5e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg5e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg5e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg6e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg6e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg6e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg6e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg7e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg7e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg7e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg7e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg8e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg8e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg8e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg8e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg2e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg2e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg2e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg2e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg3e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg3e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg3e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg3e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg4e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg4e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg4e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg4e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg5e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg5e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg5e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg5e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg6e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg6e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg6e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg6e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg7e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg7e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg7e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg7e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg8e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg8e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg8e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg8e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg2e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg2e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg2e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg2e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg2e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg3e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg3e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg3e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg3e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg3e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg4e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg4e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg4e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg4e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg4e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg5e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg5e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg5e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg5e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg5e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg6e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg6e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg6e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg6e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg6e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg7e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg7e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg7e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg7e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg7e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsseg8e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsseg8e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsseg8e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsseg8e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSEG;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b00000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsseg8e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e8ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e8ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e8ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e8ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e8ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e8ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e16ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e16ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e16ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e16ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e16ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e16ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg2e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg2e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg2e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg2e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg2e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg3e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg3e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg3e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg3e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg3e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg4e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg4e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg4e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg4e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg4e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg5e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg5e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg5e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg5e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg5e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg6e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg6e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg6e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg6e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg6e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg7e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg7e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg7e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg7e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg7e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlseg8e32ff_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlseg8e32ff_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e32ff_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlseg8e32ff_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlseg8e32ff_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSEGFF;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b10000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlseg8e32ff_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg2e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg2e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg2e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg2e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg3e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg3e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg3e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg3e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg4e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg4e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg4e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg4e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg5e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg5e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg5e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg5e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg6e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg6e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg6e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg6e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg7e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg7e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg7e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg7e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg8e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg8e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg8e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg8e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg2e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg2e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg2e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg2e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg3e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg3e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg3e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg3e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg4e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg4e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg4e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg4e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg5e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg5e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg5e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg5e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg6e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg6e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg6e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg6e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg7e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg7e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg7e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg7e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg8e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg8e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg8e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg8e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg2e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg2e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg2e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg2e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg2e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg3e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg3e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg3e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg3e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg3e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg4e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg4e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg4e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg4e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg4e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg5e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg5e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg5e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg5e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg5e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg6e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg6e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg6e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg6e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg6e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg7e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg7e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg7e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg7e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg7e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vlsseg8e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vlsseg8e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vlsseg8e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vlsseg8e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vlsseg8e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg2e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg2e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg2e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg2e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg3e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg3e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg3e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg3e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg4e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg4e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg4e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg4e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg5e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg5e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg5e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg5e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg6e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg6e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg6e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg6e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg7e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg7e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg7e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg7e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg8e8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg8e8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg8e8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg8e8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg2e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg2e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg2e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg2e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg3e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg3e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg3e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg3e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg4e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg4e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg4e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg4e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg5e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg5e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg5e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg5e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg6e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg6e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg6e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg6e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg7e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg7e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg7e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg7e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg8e16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg8e16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg8e16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg8e16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg2e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg2e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg2e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg2e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg2e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg3e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg3e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg3e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg3e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg3e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg4e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg4e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg4e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg4e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg4e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg5e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg5e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg5e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg5e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg5e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg6e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg6e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg6e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg6e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg6e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg7e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg7e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg7e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg7e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg7e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vssseg8e32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vssseg8e32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vssseg8e32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vssseg8e32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSSSEG;
      lsu_mop == LSU_CS;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    XRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vssseg8e32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg2ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg2ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg2ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg2ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg3ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg3ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg3ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg3ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg4ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg4ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg4ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg4ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg5ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg5ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg5ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg5ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg6ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg6ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg6ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg6ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg7ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg7ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg7ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg7ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg8ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg8ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg8ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg8ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg2ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg2ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg2ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg2ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg3ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg3ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg3ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg3ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg4ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg4ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg4ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg4ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg5ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg5ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg5ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg5ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg6ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg6ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg6ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg6ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg7ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg7ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg7ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg7ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg8ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg8ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg8ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg8ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg2ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg2ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg2ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg2ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg2ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg3ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg3ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg3ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg3ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg3ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg4ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg4ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg4ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg4ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg4ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg5ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg5ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg5ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg5ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg5ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg6ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg6ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg6ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg6ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg6ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg7ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg7ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg7ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg7ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg7ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vluxseg8ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vluxseg8ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vluxseg8ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vluxseg8ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vluxseg8ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg2ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg2ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg2ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg2ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg3ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg3ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg3ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg3ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg4ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg4ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg4ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg4ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg5ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg5ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg5ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg5ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg6ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg6ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg6ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg6ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg7ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg7ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg7ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg7ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg8ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg8ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg8ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg8ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg2ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg2ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg2ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg2ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg3ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg3ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg3ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg3ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg4ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg4ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg4ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg4ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg5ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg5ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg5ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg5ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg6ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg6ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg6ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg6ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg7ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg7ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg7ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg7ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg8ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg8ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg8ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg8ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg2ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg2ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg2ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg2ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg2ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg3ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg3ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg3ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg3ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg3ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg4ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg4ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg4ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg4ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg4ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg5ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg5ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg5ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg5ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg5ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg6ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg6ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg6ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg6ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg6ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg7ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg7ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg7ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg7ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg7ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vloxseg8ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vloxseg8ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vloxseg8ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vloxseg8ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vloxseg8ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg2ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg2ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg2ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg2ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg3ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg3ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg3ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg3ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg4ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg4ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg4ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg4ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg5ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg5ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg5ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg5ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg6ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg6ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg6ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg6ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg7ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg7ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg7ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg7ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg8ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg8ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg8ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg8ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg2ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg2ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg2ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg2ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg3ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg3ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg3ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg3ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg4ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg4ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg4ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg4ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg5ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg5ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg5ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg5ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg6ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg6ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg6ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg6ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg7ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg7ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg7ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg7ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg8ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg8ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg8ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg8ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg2ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg2ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg2ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg2ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg2ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg3ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg3ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg3ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg3ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg3ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg4ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg4ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg4ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg4ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg4ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg5ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg5ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg5ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg5ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg5ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg6ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg6ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg6ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg6ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg6ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg7ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg7ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg7ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg7ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg7ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsuxseg8ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsuxseg8ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsuxseg8ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsuxseg8ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSUXSEG;
      lsu_mop == LSU_UI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsuxseg8ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg2ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg2ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg2ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg2ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg3ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg3ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg3ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg3ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg4ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg4ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg4ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg4ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg5ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg5ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg5ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg5ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg6ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg6ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg6ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg6ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg7ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg7ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg7ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg7ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg8ei8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg8ei8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg8ei8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg8ei8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg2ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg2ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg2ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg2ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg3ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg3ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg3ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg3ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg4ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg4ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg4ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg4ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg5ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg5ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg5ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg5ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg6ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg6ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg6ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg6ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg7ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg7ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg7ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg7ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg8ei16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg8ei16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg8ei16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW16;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg8ei16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg2ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg2ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg2ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg2ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg2ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg3ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg3ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg3ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg3ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg3ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg4ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg4ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg4ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg4ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg4ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg5ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg5ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg5ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg5ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg5ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg6ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg6ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg6ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg6ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg6ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg7ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg7ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg7ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg7ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg7ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vsoxseg8ei32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vsoxseg8ei32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vsoxseg8ei32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vsoxseg8ei32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSOXSEG;
      lsu_mop == LSU_OI;
      lsu_eew == EEW32;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {0, 1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vsoxseg8ei32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl1re8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl1re8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl1re8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl1re8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl2re8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl2re8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl2re8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl2re8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl4re8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl4re8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl4re8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl4re8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl8re8_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl8re8_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re8_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re8_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl8re8_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl8re8_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl1re16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl1re16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl1re16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl1re16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl2re16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl2re16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl2re16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl2re16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl4re16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl4re16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl4re16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl4re16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl8re16_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl8re16_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re16_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re16_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl8re16_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW16;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl8re16_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl1re32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl1re32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl1re32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl1re32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl1re32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl2re32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl2re32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl2re32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl2re32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl2re32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl4re32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl4re32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl4re32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl4re32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl4re32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vl8re32_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vl8re32_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re32_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vl8re32_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vl8re32_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == LD;
      lsu_inst == VLR;
      lsu_mop == LSU_US;
      lsu_eew == EEW32;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vl8re32_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vs1r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vs1r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs1r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs1r_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vs1r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4, LMUL8};
      /* inst */
      inst_type == ST;
      lsu_inst == VSR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vs1r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vs2r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vs2r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs2r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs2r_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vs2r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2, LMUL4};
      /* inst */
      inst_type == ST;
      lsu_inst == VSR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vs2r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vs4r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vs4r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs4r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs4r_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vs4r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1, LMUL2};
      /* inst */
      inst_type == ST;
      lsu_inst == VSR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vs4r_v_seq

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_vs8r_v_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vs8r_v_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs8r_v_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vs8r_v_seq,rvv_lsu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vs8r_v_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      /* vtype */
      vsew  inside {SEW8, SEW16, SEW32};
      vlmul inside {LMUL1_4, LMUL1_2, LMUL1};
      /* inst */
      inst_type == ST;
      lsu_inst == VSR;
      lsu_mop == LSU_US;
      lsu_eew == EEW8;
      /* oprand */
      src3_type ==    VRF; src3_idx inside {[0:31]};
      src2_type ==   FUNC; src2_idx == 5'b01000;
      src1_type ==    XRF; src1_idx inside {[0:31]};
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vs8r_v_seq
`endif // RVV_ZVE32X_INST_SEQUENCE_LIBRARY__SV
