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
      req.c_vl_vstart.constraint_mode(0);
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

//-----------------------------------------------------------
// signed div overflow test
// to test -2^(width-1)/-1 == -2^(width-1)
//         -2^(width-1)%-1 == 0
//-----------------------------------------------------------
class alu_div_overflow_seq extends base_sequence;
  `uvm_object_utils(alu_div_overflow_seq)

  int inst_num = 1;
  sew_e vsew = SEW8;
  function new(string name = "alu_div_overflow_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VDIV};

      dest_type == VRF; dest_idx == 3;
      src2_type == VRF; src2_idx == 2;
      src1_type == VRF; src1_idx == 1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VREM};

      dest_type == VRF; dest_idx == 4;
      src2_type == VRF; src2_idx == 2;
      src1_type == VRF; src1_idx == 1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VDIV};

      dest_type == VRF; dest_idx == 5;
      src2_type == VRF; src2_idx == 2;
      src1_type == XRF; rs1_data == -1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VREM};

      dest_type == VRF; dest_idx == 6;
      src2_type == VRF; src2_idx == 2;
      src1_type == XRF; rs1_data == -1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;

    // to cover unsigned condition
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VDIVU};

      dest_type == VRF; dest_idx == 7;
      src2_type == VRF; src2_idx == 2;
      src1_type == VRF; src1_idx == 1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      pc == inst_cnt;
      use_vlmax == 1;

      vlmul == LMUL1;
      vsew == local::vsew;

      inst_type == ALU;
      alu_inst inside {VREMU};

      dest_type == VRF; dest_idx == 8;
      src2_type == VRF; src2_idx == 2;
      src1_type == VRF; src1_idx == 1;
      vm == 1;
    });
    finish_item(req);
    inst_cnt++;
  endtask

endclass: alu_div_overflow_seq

class alu_div_overflow_test extends rvv_backend_test;
  
  alu_div_overflow_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_div_overflow_test)

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
    logic [`VLEN-1:0] act;
    logic [`VLEN-1:0] exp;

    rand_vrf();

    rvs_seq = alu_div_overflow_seq::type_id::create("rvs_seq", this);

    // vsew == SEW8
    rvs_seq.vsew = SEW8;
    set_vrf(2,128'h8080_8080_8080_8080_8080_8080_8080_8080);
    set_vrf(1,'1);
    set_vrf(3,128'hface_face_face_face_face_face_face_face);
    set_vrf(4,128'hface_face_face_face_face_face_face_face);
    set_vrf(5,128'hface_face_face_face_face_face_face_face);
    set_vrf(6,128'hface_face_face_face_face_face_face_face);
    set_vrf(7,128'hface_face_face_face_face_face_face_face);
    set_vrf(8,128'hface_face_face_face_face_face_face_face);

    rvs_seq.start(env.rvs_agt.rvs_sqr);
    while(rvv_intern_if.rvv_is_idle()) begin
      // wait to accept inst
      @(posedge rvs_if.clk);
    end
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    // quotient
    exp = 128'h8080_8080_8080_8080_8080_8080_8080_8080;
    act = vrf_if.get_dut_vrf(3);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(5);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    // remainder 
    exp = 128'h0;
    act = vrf_if.get_dut_vrf(4);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(6);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    repeat(10) @(posedge rvs_if.clk);

    // vsew == SEW16
    rvs_seq.vsew = SEW16;
    set_vrf(2,128'h8000_8000_8000_8000_8000_8000_8000_8000);
    set_vrf(1,'1);
    set_vrf(3,128'hface_face_face_face_face_face_face_face);
    set_vrf(4,128'hface_face_face_face_face_face_face_face);
    set_vrf(5,128'hface_face_face_face_face_face_face_face);
    set_vrf(6,128'hface_face_face_face_face_face_face_face);
    set_vrf(7,128'hface_face_face_face_face_face_face_face);
    set_vrf(8,128'hface_face_face_face_face_face_face_face);

    rvs_seq.start(env.rvs_agt.rvs_sqr);
    while(rvv_intern_if.rvv_is_idle()) begin
      // wait to accept inst
      @(posedge rvs_if.clk);
    end
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    // quotient
    exp = 128'h8000_8000_8000_8000_8000_8000_8000_8000;
    act = vrf_if.get_dut_vrf(3);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(5);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    // remainder 
    exp = 128'h0;
    act = vrf_if.get_dut_vrf(4);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(6);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    repeat(10) @(posedge rvs_if.clk);

    // vsew == SEW32
    rvs_seq.vsew = SEW32;
    set_vrf(2,128'h8000_0000_8000_0000_8000_0000_8000_0000);
    set_vrf(1,'1);
    set_vrf(3,128'hface_face_face_face_face_face_face_face);
    set_vrf(4,128'hface_face_face_face_face_face_face_face);
    set_vrf(5,128'hface_face_face_face_face_face_face_face);
    set_vrf(6,128'hface_face_face_face_face_face_face_face);
    set_vrf(7,128'hface_face_face_face_face_face_face_face);
    set_vrf(8,128'hface_face_face_face_face_face_face_face);

    rvs_seq.start(env.rvs_agt.rvs_sqr);
    while(rvv_intern_if.rvv_is_idle()) begin
      // wait to accept inst
      @(posedge rvs_if.clk);
    end
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    // quotient
    exp = 128'h8000_0000_8000_0000_8000_0000_8000_0000;
    act = vrf_if.get_dut_vrf(3);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(5);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    // remainder 
    exp = 128'h0;
    act = vrf_if.get_dut_vrf(4);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)
    act = vrf_if.get_dut_vrf(6);
    if(act !== exp)
      `uvm_error(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp))
    else 
      `uvm_info(get_type_name(), $sformatf("vrf[2]: act == 0x%16x, exp == 0x%16x.", act, exp), UVM_LOW)

    repeat(10) @(posedge rvs_if.clk);
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction

endclass: alu_div_overflow_test
//-----------------------------------------------------------
// Continuous divding
//-----------------------------------------------------------
class alu_cont_div_seq extends base_sequence;
  `uvm_object_utils(alu_cont_div_seq)

  int inst_num = 1;
  alu_inst_e inst_set[];
  sew_e vsew_set[];
  function new(string name = "alu_cont_div_seq");
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
        vsew inside {vsew_set};

        inst_type == ALU;
        alu_inst inside {inst_set};

        dest_type == VRF; dest_idx inside {[2:11]};
        src2_type == VRF; src2_idx inside {[12:21]};
        src1_type == VRF; src1_idx inside {[22:31]};
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
endclass: alu_cont_div_seq

class alu_cont_div_test extends rvv_backend_test;
  
  alu_cont_div_seq rvs_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(alu_cont_div_test)

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

    logic [`VLEN-1:0] value;
    logic [31:0] temp;
    rand_vrf();
    rvs_seq = alu_cont_div_seq::type_id::create("rvs_seq", this);
    set_vrf(0,128'ha5a5_5a5a_a5a5_5a5a_a5a5_5a5a_a5a5_5a5a);

    //-------------------------------------------------- 
    // Unsigned test - sew8
    // vs2
    temp = $urandom_range(0, 8'hFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 8'hFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW8});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Unsigned test - sew16
    // vs2
    temp = $urandom_range(0, 16'hFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 16'hFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW16});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Unsigned test - sew32
    // vs2
    temp = $urandom_range(0, 32'hFFFFFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 32'hFFFFFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW32});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Signed test - sew8
    // vs2
    temp = $urandom_range(0, 8'hFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 8'hFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIV,VREM});
    rvs_seq.vsew_set = new[1]('{SEW8});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Signed test - sew16
    // vs2
    temp = $urandom_range(0, 16'hFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 16'hFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIV,VREM});
    rvs_seq.vsew_set = new[1]('{SEW16});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Signed test - sew32
    // vs2
    temp = $urandom_range(0, 32'hFFFFFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 32'hFFFFFFFF);
    for(int j=0; j<`VLENB; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq.inst_set = new[2]('{VDIV,VREM});
    rvs_seq.vsew_set = new[1]('{SEW32});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);

    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.vsew_set.delete();

    //-------------------------------------------------- 
    // Signed & unsigned mix test - sew8
    // vs2
    temp = $urandom_range(0, 8'h7F);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 8'h7F);
    for(int j=0; j<`VLENB; j++) begin
      value[j*8+:8] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq = alu_cont_div_seq::type_id::create("rvs_seq", this);
    rvs_seq.inst_set = new[4]('{VDIV,VREM,VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW8});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.inst_set.delete();

    //-------------------------------------------------- 
    // Signed & unsigned mix test - sew16
    // vs2
    temp = $urandom_range(0, 16'h7FFF);
    for(int j=0; j<`VLENB/2; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 16'h7FFF);
    for(int j=0; j<`VLENB/2; j++) begin
      value[j*16+:16] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq = alu_cont_div_seq::type_id::create("rvs_seq", this);
    rvs_seq.inst_set = new[4]('{VDIV,VREM,VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW16});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.inst_set.delete();

    //-------------------------------------------------- 
    // Signed & unsigned mix test - sew32
    // vs2
    temp = $urandom_range(0, 32'h7FFF_FFFF);
    for(int j=0; j<`VLENB/4; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=12; i<22; i++) begin
      set_vrf(i,value);
    end
    // vs1
    temp = $urandom_range(0, 32'h7FFF_FFFF);
    for(int j=0; j<`VLENB/4; j++) begin
      value[j*32+:32] = temp;
    end
    for(int i=22; i<32; i++) begin
      set_vrf(i,value);
    end

    rvs_seq = alu_cont_div_seq::type_id::create("rvs_seq", this);
    rvs_seq.inst_set = new[4]('{VDIV,VREM,VDIVU,VREMU});
    rvs_seq.vsew_set = new[1]('{SEW32});
    rvs_seq.run_inst(env.rvs_agt.rvs_sqr, 100);
    while(!rvv_intern_if.rvv_is_idle()) begin
      // wait for done
      @(posedge rvs_if.clk);
    end
    rvs_seq.inst_set.delete();
    rvs_seq.inst_set.delete();

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction

endclass: alu_cont_div_test

class rvv_reset_test extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  alu_random_seq rvs_alu_seq;
  lsu_base_seq   rvs_lsu_seq;
  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(rvv_reset_test)

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

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = 100;
    rvs_seq_lib.add_typewide_sequence(rvs_alu_seq.get_type());
    // FIXME: For now, tb didn't support getting a reset while a store inst 
    //    having sent the data to lsu but not retire yet.
    // rvs_seq_lib.add_typewide_sequence(rvs_lsu_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    fork
      rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
      begin
        repeat(50) @(posedge rvs_if.clk);
        rvs_if.rst_n = 0;
        repeat(10) @(posedge rvs_if.clk);
        rvs_if.rst_n = 1;
      end
    join
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rvv_reset_test

// -----------------------------------------------------------------------------
class inst_rvv_zve32x_viota_m_vm1_large_vl_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_viota_m_vm1_large_vl_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_viota_m_vm1_large_vl_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_viota_m_vm1_large_vl_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_viota_m_vm1_large_vl_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      use_vlmax == 1;
      /* vtype */
      vsew  inside {SEW8};
      vlmul inside {LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VMUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    VRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b10000;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_viota_m_vm1_large_vl_seq

class inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq extends base_sequence;
  `uvm_object_utils(inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq,rvv_inst_sequence_library)
  `uvm_add_to_seq_lib(inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq,rvv_alu_sequence_library)

  function new(string name = "inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq");
    super.new(name);
  endfunction: new
  virtual task body();
    req = new("req");
    start_item(req);
    assert(req.randomize() with {
      // normal set
      pc == inst_cnt;
      
      // special set
      use_vlmax == 1;
      /* vtype */
      vsew  inside {SEW8};
      vlmul inside {LMUL8};
      /* inst */
      inst_type == ALU;
      alu_inst == VWXUNARY0;
      alu_type == OPMVV;
      /* oprand */
      dest_type ==    XRF; dest_idx inside {[0:31]};
      src2_type ==    VRF; src2_idx inside {[0:31]};
      src1_type ==   FUNC; src1_idx == 5'b10000;
      vm inside {1};
    });
    finish_item(req);
    inst_cnt++;
  endtask: body

endclass: inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq

class vcpop_viota_vm1_test extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  inst_rvv_zve32x_vcpop_m_vm1_large_vl_seq vcpop_m_vm1_seq;
  inst_rvv_zve32x_viota_m_vm1_large_vl_seq viota_m_vm1_seq;
  inst_rvv_zve32x_vadd_vx_seq              vadd_vx_seq;
  rvs_last_sequence rvs_last_seq;
  `uvm_component_utils(vcpop_viota_vm1_test)

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
    super.main_phase(phase);

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = direct_inst_num;
    rvs_seq_lib.add_typewide_sequence(vcpop_m_vm1_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(viota_m_vm1_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vadd_vx_seq.get_type());
    rvs_seq_lib.init_sequence_library();
    
    `uvm_info(get_type_name(),"Start randomize mem & vrf.", UVM_LOW)
    rand_mem(mem_base, mem_size);
    rand_vrf();
    `uvm_info(get_type_name(), "Randomize done.", UVM_LOW)

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);
    
    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: vcpop_viota_vm1_test


//-----------------------------------------------------------
// small evl test
//-----------------------------------------------------------
class small_evl_test extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;

  inst_rvv_zve32x_vmv_s_x_seq rvs_seq_5;
  inst_rvv_zve32x_vadd_vv_seq rvs_seq_6;  

  rvs_last_sequence rvs_last_seq;

  `uvm_component_utils(small_evl_test)

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

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = direct_inst_num;
    rvs_seq_lib.add_typewide_sequence(rvs_seq_5.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_seq_5.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_seq_5.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_seq_5.get_type());
    rvs_seq_lib.add_typewide_sequence(rvs_seq_6.get_type());
    rvs_seq_lib.init_sequence_library();

    rand_vrf();

    rvs_transaction::reserve_vl_vstart_en = 1;
    rvs_transaction::vl_min = 0;
    rvs_transaction::vl_max = 0;

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: small_evl_test


//-----------------------------------------------------------
// rob_entry_trap_test
//-----------------------------------------------------------
class rob_entry_trap_test extends rvv_backend_test;

  rvs_random_sequence_library rvs_seq_lib;
  inst_rvv_zve32x_vcpop_m_seq   vcpop_m_seq;
  inst_rvv_zve32x_viota_m_seq   viota_m_seq;
  inst_rvv_zve32x_vmv_x_s_seq   vmv_x_s_seq;
  inst_rvv_zve32x_vadd_vx_seq   vadd_vx_seq;
  inst_rvv_zve32x_vse8_v_seq    vse8_v_seq;
  rvs_last_sequence             rvs_last_seq;

  `uvm_component_utils(rob_entry_trap_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "trap_en", 1'b1);
    uvm_config_db#(bit)::set(uvm_root::get(), "*", "always_trap", 1'b1);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.set_report_id_action_hier("MDL", UVM_LOG);
  endfunction

  task main_phase(uvm_phase phase);

    rvs_seq_lib = rvs_random_sequence_library::type_id::create("rvs_seq_lib");
    rvs_seq_lib.selection_mode = UVM_SEQ_LIB_RAND;
    rvs_seq_lib.sequence_count = random_inst_num;
    rvs_seq_lib.add_typewide_sequence(vcpop_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vcpop_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vcpop_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(viota_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(viota_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(viota_m_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vmv_x_s_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vmv_x_s_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vmv_x_s_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vadd_vx_seq.get_type());
    rvs_seq_lib.add_typewide_sequence(vse8_v_seq.get_type());
    rvs_seq_lib.init_sequence_library();

    rand_vrf();

    rvs_seq_lib.start(env.rvs_agt.rvs_sqr);

    rvs_last_seq = rvs_last_sequence::type_id::create("rvs_last_seq", this);
    rvs_last_seq.start(env.rvs_agt.rvs_sqr);
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction
endclass: rob_entry_trap_test
`endif // RVV_BACKEND_CORNER_TEST__SV
