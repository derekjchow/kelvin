`ifndef VRF_MONITOR__SV
`define VRF_MONITOR__SV

typedef class vrf_transaction;
typedef class vrf_monitor;

  `uvm_blocking_get_imp_decl(_vrf_state)
class vrf_monitor extends uvm_monitor;

  typedef virtual vrf_interface v_if;
  v_if vrf_if;

  uvm_analysis_port #(vrf_transaction) vrf_ap;   
  uvm_blocking_get_imp_vrf_state #(vrf_mon_pkg::vrf_state_e, vrf_monitor) vrf_state_imp;

  `uvm_component_utils_begin(vrf_monitor)
  `uvm_component_utils_end

  extern function new(string name = "vrf_mon",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern protected virtual task vrf_monitor();
  extern protected virtual task vrf_write_zero_monitor();
  extern protected virtual task vrf_all_zero_monitor();

  // imp task
  extern task get_vrf_state(output vrf_mon_pkg::vrf_state_e vrf_state);

endclass: vrf_monitor


function vrf_monitor::new(string name = "vrf_mon",uvm_component parent);
  super.new(name, parent);

endfunction: new

function void vrf_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  vrf_ap = new("vrf_ap", this);
  vrf_state_imp = new("vrf_state_imp", this);
endfunction: build_phase

function void vrf_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if)::get(this, "", "vrf_if", vrf_if))
    `uvm_fatal(get_type_name(), "Fail to get vrf_if!")
endfunction: connect_phase

task vrf_monitor::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

task vrf_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
     vrf_monitor();
     vrf_write_zero_monitor();
     vrf_all_zero_monitor();
  join
endtask: run_phase

task vrf_monitor::vrf_monitor();
  vrf_transaction tr;
  int last_uop_idx_max, uop_idx_max;
  tr = new();
  forever begin
    @(posedge vrf_if.clk);
    if(vrf_if.rst_n) begin
      last_uop_idx_max = -1;
      uop_idx_max = -1;
      for(int i=0; i<`NUM_RT_UOP; i++) begin
        if(vrf_if.rt_last_uop[i] === 1'b1) last_uop_idx_max = i;
        if(vrf_if.rt_uop[i] === 1'b1) uop_idx_max = i;
      end
      if(last_uop_idx_max>=0 && last_uop_idx_max>=uop_idx_max) begin
        for(int i=0; i<32; i++) begin
            tr.vreg[i] = vrf_if.vreg[i];
        end
        vrf_ap.write(tr);
      end
    end
  end
endtask: vrf_monitor

task vrf_monitor::vrf_write_zero_monitor();
  int write_zero_to_vrf [31:0];
  int max_write_times = 20;
  forever begin
    @(posedge vrf_if.clk);
    if(~vrf_if.rst_n) begin
      for(int i=0; i<32; i++) begin
        write_zero_to_vrf[i] = '0;
      end
    end else begin
      for(int i=0; i<32; i++) begin
        if(|vrf_if.vrf_wr_wenb_full[i])
          if((vrf_if.vrf_wr_wenb_full[i] & vrf_if.vrf_wr_data_full[i]) === 0) begin
            write_zero_to_vrf[i]++;
            if(write_zero_to_vrf[i] > max_write_times) begin
              // `uvm_fatal("TB_ISSUE", $sformatf("Write zero to vrf[%0d] %0d times. Please check the testbench.", i, write_zero_to_vrf[i]))
              `uvm_warning("TB_ISSUE", $sformatf("Write zero to vrf[%0d] %0d times. Please check the testbench.", i, write_zero_to_vrf[i]))
            end
          end else begin
            write_zero_to_vrf[i] = '0;
          end
      end
    end
  end
endtask: vrf_write_zero_monitor

task vrf_monitor::vrf_all_zero_monitor();
  int count = 0;
  int max_count = 500;
  forever begin
    @(posedge vrf_if.clk);
    if(~vrf_if.rst_n) begin
    end else begin
      if(|vrf_if.vreg === 1'b0) begin
        count++;
      end else begin
        count = 0;
      end
      if(count > max_count) begin
        `uvm_fatal("TB_ISSUE",$sformatf("VRF becomes all zeros for %0d cycles. Please check the testbench", count))
        // `uvm_warning("TB_ISSUE",$sformatf("VRF becomes all zeros for %0d cycles. Please check the testbench", count))
      end
    end
  end
endtask: vrf_all_zero_monitor

task vrf_monitor::get_vrf_state(output vrf_mon_pkg::vrf_state_e vrf_state);
  if(|vrf_if.vreg === 1'b0)
    vrf_state = vrf_mon_pkg::ALL_ZERO;
  else if(|vrf_if.vrf_wr_wenb_full === 1'b1)
    vrf_state = vrf_mon_pkg::BUSY; 
  else if(|vrf_if.vrf_wr_wenb_full === 1'b0)
    vrf_state = vrf_mon_pkg::IDLE; 
  else
    vrf_state = vrf_mon_pkg::UNKNOW;
  `uvm_info(get_type_name(),$sformatf("Request vrf status, respond: %s",vrf_state.name()),UVM_HIGH)
endtask: get_vrf_state
`endif // VRF_MONITOR__SV
