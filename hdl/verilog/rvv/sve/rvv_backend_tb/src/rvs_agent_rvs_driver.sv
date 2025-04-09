`ifndef RVS_DRIVER__SV
`define RVS_DRIVER__SV

`include "rvv_backend_define.svh"
`include "rvv_backend.svh"
typedef class rvs_transaction;
typedef class rvs_driver;
typedef class rvv_backend_test;
typedef class trap_info_transaction;

  `uvm_analysis_imp_decl(_trap_rvs)
class rvs_driver extends uvm_driver # (rvs_transaction);

  uvm_analysis_port #(rvs_transaction) inst_ap; 
  uvm_blocking_get_port #(vrf_mon_pkg::vrf_state_e) vrf_state_port;
  uvm_blocking_get_port #(rvv_state_pkg::rvv_state_e) rvv_state_port;
  uvm_analysis_imp_trap_rvs #(trap_info_transaction,rvs_driver) trap_imp; 

  rvv_backend_test test_top;
  
  typedef virtual rvs_interface v_if1; 
  typedef virtual vrf_interface v_if3; 
  v_if1 rvs_if;
  v_if3 vrf_if;
  
  int             inst_tx_queue_depth = 4;
  rvs_transaction inst_tx_queue[$];
  RVVCmd          inst     [`ISSUE_LANE-1:0];
  logic           inst_vld [`ISSUE_LANE-1:0];
  bit             stall_tx;

  bit             single_inst_mode = 0; 
  int             inst_tx_delay_max = 8;
  int             inst_tx_delay = 0;

  delay_mode_pkg::delay_mode_e       delay_mode_rt_xrf;
  delay_mode_pkg::delay_mode_e       delay_mode_wr_vxsat;
  delay_mode_pkg::delay_mode_e       delay_mode_vcsr_ready;

  trap_info_transaction trap_queue [$];
  int unsigned    vcsr_ready_delay;
  int unsigned    gen_inst_after_trap;

  extern function new(string name = "rvs_driver", uvm_component parent = null); 
 
  `uvm_component_utils_begin(rvs_driver)
  `uvm_component_utils_end

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

  extern protected virtual task tx_driver();
  extern protected virtual task inst_manage();
  extern protected virtual task rx_driver();
  extern protected virtual task vrf_driver();

  extern virtual function void write_trap_rvs(trap_info_transaction trap_tr);

endclass: rvs_driver

function rvs_driver::new(string name = "rvs_driver", uvm_component parent = null);
  super.new(name, parent);
  inst_ap = new("inst_ap", this);
  vrf_state_port = new("vrf_state_port", this);
  rvv_state_port = new("rvv_state_port", this);
  trap_imp = new("trap_imp", this);
endfunction: new

function void rvs_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(uvm_config_db#(int)::get(this, "", "inst_tx_queue_depth", inst_tx_queue_depth)) begin
    `uvm_info(get_type_name(), $sformatf("Depth of instruction queue in rvs_driver is set to %0d.", inst_tx_queue_depth), UVM_LOW)
  end
  if(uvm_config_db#(int)::get(this, "", "single_inst_mode", single_inst_mode)) begin
    `uvm_info(get_type_name(), $sformatf("single_inst_mode of rvs_driver is set to %0d.",single_inst_mode), UVM_LOW)
  end
  if(!$cast(test_top, uvm_root::get().find("uvm_test_top")))
    `uvm_fatal(get_type_name(),"Get uvm_test_top fail")

  if(uvm_config_db#(delay_mode_pkg::delay_mode_e)::get(this, "", "delay_mode_rt_xrf", delay_mode_rt_xrf)) begin
    `uvm_info(get_type_name(), $sformatf("delay_mode_rt_xrf of rvs_driver is set to %s.", delay_mode_rt_xrf.name()), UVM_LOW)
  end else begin
    delay_mode_rt_xrf = delay_mode_pkg::NORMAL;
    `uvm_info(get_type_name(), $sformatf("delay_mode_rt_xrf of rvs_driver is set to %s.", delay_mode_rt_xrf.name()), UVM_LOW)
  end
  if(uvm_config_db#(delay_mode_pkg::delay_mode_e)::get(this, "", "delay_mode_wr_vxsat", delay_mode_wr_vxsat)) begin
    `uvm_info(get_type_name(), $sformatf("delay_mode_wr_vxsat of rvs_driver is set to %s.", delay_mode_wr_vxsat.name()), UVM_LOW)
  end else begin
    delay_mode_wr_vxsat = delay_mode_pkg::NORMAL;
    `uvm_info(get_type_name(), $sformatf("delay_mode_wr_vxsat of rvs_driver is set to %s.", delay_mode_wr_vxsat.name()), UVM_LOW)
  end
endfunction: build_phase

function void rvs_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if1)::get(this, "", "rvs_if", rvs_if))
    `uvm_fatal(get_type_name(), "Fail to get rvs_if!")
  if(!uvm_config_db#(v_if3)::get(this, "", "vrf_if", vrf_if))
    `uvm_fatal(get_type_name(), "Fail to get vrf_if!")
endfunction: connect_phase

task rvs_driver::reset_phase(uvm_phase phase);
  phase.raise_objection( .obj( this ) );
  while(!rvs_if.rst_n) begin
    for(int i=0; i<`ISSUE_LANE; i++) begin
      inst[i] = '0;
      inst_vld[i] = '0;
    end
    stall_tx = 0;
    //Reset DUT
    for(int i=0; i<`ISSUE_LANE; i++) begin
      rvs_if.insts_rvs2cq[i]         <= '0;
      rvs_if.insts_valid_rvs2cq[i]   <= '0;
    end
    for(int i=0; i<`NUM_RT_UOP; i++) begin
      rvs_if.rt_xrf_ready_rvs2rvv[i] <= '0;
    end
    rvs_if.wr_vxsat_ready <= '0;
    @(posedge rvs_if.clk);
  end
  phase.drop_objection( .obj( this ) );

endtask: reset_phase

task rvs_driver::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

task rvs_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork 
    tx_driver();
    rx_driver();
    vrf_driver();
  join
endtask: run_phase

task rvs_driver::inst_manage();
  rvs_transaction tr;
  tr = new();
  
  for(int i=0; i<`ISSUE_LANE; i++) begin
    if((rvs_if.insts_ready_cq2rvs[i]===1'b1) && (rvs_if.insts_valid_rvs2cq[i]===1'b1)) begin
      tr = inst_tx_queue.pop_front();
    end
  end

  while (inst_tx_queue.size() < inst_tx_queue_depth) begin
    if(inst_tx_delay != 0) begin 
      inst_tx_delay--;
      break;
    end
    //seq_item_port.get_next_item(tr);
    seq_item_port.try_next_item(tr);
    if(tr != null) begin
      `uvm_info(get_type_name(), $sformatf("Get item from rvs_sqr:\n%s",tr.sprint()),UVM_HIGH)
      inst_tx_queue.push_back(tr);
      `uvm_info(get_type_name(), $sformatf("Send transaction to rvs_mon:\n%s",tr.sprint()),UVM_HIGH)
      inst_ap.write(tr);
      seq_item_port.item_done(); 
      if(single_inst_mode) begin
        inst_tx_delay = inst_tx_delay_max;
      end else begin
        assert(std::randomize(inst_tx_delay) with {inst_tx_delay dist {0 := 94, [1:2] := 5, inst_tx_delay_max := 1};});
        // inst_tx_delay = 0;
      end
    end else begin
      break;
    end
  end

  for(int i=0; i<`ISSUE_LANE; i++) begin
    if(i < inst_tx_queue.size()) begin
      // `uvm_info(get_type_name(), $sformatf("Assign to port inst[%d]",i),UVM_HIGH)
`ifdef TB_SUPPORT
      inst[i].inst_pc               = inst_tx_queue[i].pc;
`endif
      assert($cast(inst[i].opcode, inst_tx_queue[i].bin_inst[6:5]));
      inst[i].bits                  = inst_tx_queue[i].bin_inst[31:7];
      inst[i].rs1                   = inst_tx_queue[i].rs1_data;
      inst[i].arch_state.vl         = inst_tx_queue[i].vl;
      inst[i].arch_state.vstart     = inst_tx_queue[i].vstart;
      assert($cast(inst[i].arch_state.xrm, inst_tx_queue[i].vxrm));
      inst[i].arch_state.ma         = inst_tx_queue[i].vma;
      inst[i].arch_state.ta         = inst_tx_queue[i].vta;
      assert($cast(inst[i].arch_state.sew,  inst_tx_queue[i].vsew));
      assert($cast(inst[i].arch_state.lmul, inst_tx_queue[i].vlmul));
      inst_vld[i] = 1'b1;
    end else begin
      inst[i] = inst[i];
      inst_vld[i] = 1'b0;
    end 
  end

endtask: inst_manage

task rvs_driver::tx_driver();
  rvs_transaction tr;
  tr = new();
  forever begin
    @(posedge rvs_if.clk);
    if(~rvs_if.rst_n) begin
      inst_tx_queue.delete();
      for(int i=0; i<`ISSUE_LANE; i++) begin
       inst[i] = 0;
       inst_vld[i] = 0;
      end
      stall_tx = 1;
      //Reset DUT
      for(int i=0; i<`ISSUE_LANE; i++) begin
        rvs_if.insts_rvs2cq[i]         <= '0;
        rvs_if.insts_valid_rvs2cq[i]   <= '0;
      end
    end else begin
      inst_manage();
      if(stall_tx) begin
        for(int i=0; i<`ISSUE_LANE; i++) begin
          rvs_if.insts_rvs2cq[i]         <= inst[i];
          rvs_if.insts_valid_rvs2cq[i]   <= 1'b0;
        end
      end else begin
        for(int i=0; i<`ISSUE_LANE; i++) begin
          rvs_if.insts_rvs2cq[i]         <= inst[i];
          rvs_if.insts_valid_rvs2cq[i]   <= inst_vld[i];
        end
      end
    end
  end
endtask: tx_driver

task rvs_driver::rx_driver();
  logic rt_xrf_ready [`NUM_RT_UOP-1:0] ;
  logic wr_vxsat_ready;
  forever begin
    @(posedge rvs_if.clk);
    if(~rvs_if.rst_n) begin
      for(int i=0; i<`NUM_RT_UOP; i++) begin
        rvs_if.rt_xrf_ready_rvs2rvv[i] <= '0;
      end
      rvs_if.wr_vxsat_ready <= '0;
      rvs_if.vcsr_ready <= 1'b0;
    end
    // trap handler
    if(rvs_if.vcsr_ready) begin
      if(rvs_if.vcsr_valid) begin
        stall_tx = 0;
        trap_queue.pop_front();
      end else begin
        `uvm_info(get_type_name(), "Stall rvs_driver tx to wait for vcsr_valid", UVM_LOW)
        stall_tx = 1;
      end
    end

    // rt_xrf_ready response
    for(int i=0; i<`NUM_RT_UOP; i++) begin
      case(delay_mode_rt_xrf)
        delay_mode_pkg::SLOW: 
          assert(std::randomize(rt_xrf_ready[i]) with {rt_xrf_ready[i] dist {0 := 90, 1 := 10};});
        delay_mode_pkg::NORMAL: 
          assert(std::randomize(rt_xrf_ready[i]) with {rt_xrf_ready[i] dist {0 := 20, 1 := 80};});
        delay_mode_pkg::FAST: 
          assert(std::randomize(rt_xrf_ready[i]) with {rt_xrf_ready[i] dist {0 := 0, 1 := 100};});
      endcase
      rvs_if.rt_xrf_ready_rvs2rvv[i] <= rt_xrf_ready[i];
    end

    // wr_vxsat_ready response
    case(delay_mode_wr_vxsat)
      delay_mode_pkg::SLOW: 
        assert(std::randomize(wr_vxsat_ready) with {wr_vxsat_ready dist {0 := 90, 1 := 10};});
      delay_mode_pkg::NORMAL: 
        assert(std::randomize(wr_vxsat_ready) with {wr_vxsat_ready dist {0 := 20, 1 := 80};});
      delay_mode_pkg::FAST: 
        assert(std::randomize(wr_vxsat_ready) with {wr_vxsat_ready dist {0 := 0, 1 := 100};});
    endcase
    rvs_if.wr_vxsat_ready <= wr_vxsat_ready;

    // vector_csr response
    if(trap_queue.size() > 0) begin
      if(trap_queue[0].vcsr_ready_delay == 0) begin
        rvs_if.vcsr_ready <= 1'b1;
      end else begin
        trap_queue[0].vcsr_ready_delay--;
        rvs_if.vcsr_ready <= 1'b0;
      end
    end else begin
      rvs_if.vcsr_ready <= 1'b0;
    end
  end
endtask: rx_driver

task rvs_driver::vrf_driver();
  logic [`VLEN-1:0] value;
  vrf_mon_pkg::vrf_state_e vrf_state;
  rvv_state_pkg::rvv_state_e rvv_state;
  forever begin
    @(posedge rvs_if.clk);
    if(~rvs_if.rst_n) begin
    end else begin
      rvv_state_port.get(rvv_state);
      vrf_state_port.get(vrf_state);
      if(vrf_state == vrf_mon_pkg::ALL_ZERO) begin
        `uvm_info(get_type_name(),$sformatf("Got vrf status %s",vrf_state.name()),UVM_HIGH)
        stall_tx = 1;
        if(rvv_state == rvv_state_pkg::IDLE) begin
          `uvm_info(get_type_name(),$sformatf("Got rvv status %s",rvv_state.name()),UVM_HIGH)
          `uvm_info(get_type_name(), "Start to randomize vrf", UVM_HIGH)
          for(int reg_idx=0; reg_idx<32; reg_idx++) begin
            for(int j=0; j<`VLENB; j++) begin
              value[j*8+:8] = $urandom_range(0, 8'hFF);
            end
            test_top.set_mdl_vrf(reg_idx, value);
            vrf_if.set_dut_vrf(reg_idx, value);
          end
          `uvm_info(get_type_name(), "Randomize vrf done", UVM_HIGH)
        end
      end else begin
        stall_tx = 0;
      end
    end
  end

endtask: vrf_driver

  function void rvs_driver::write_trap_rvs(trap_info_transaction trap_tr);
    `uvm_info(get_type_name(), "get a trap", UVM_HIGH)
    `uvm_info(get_type_name(), trap_tr.sprint(), UVM_HIGH)
    assert(trap_tr.randomize(vcsr_ready_delay) with {
      vcsr_ready_delay dist { 
        [0:10] := 100
      };
    });
    trap_queue.push_back(trap_tr);
  endfunction
`endif // RVS_DRIVER__SV


