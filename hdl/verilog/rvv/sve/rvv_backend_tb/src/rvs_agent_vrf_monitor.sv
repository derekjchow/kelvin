`ifndef VRF_MONITOR__SV
`define VRF_MONITOR__SV

typedef class vrf_transaction;
typedef class vrf_monitor;

class vrf_monitor extends uvm_monitor;

  typedef virtual vrf_interface v_if;
  v_if vrf_if;

  uvm_analysis_port #(vrf_transaction) vrf_ap;   

  `uvm_component_utils_begin(vrf_monitor)
  `uvm_component_utils_end

  extern function new(string name = "vrf_mon",uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern protected virtual task vrf_monitor();

endclass: vrf_monitor


function vrf_monitor::new(string name = "vrf_mon",uvm_component parent);
  super.new(name, parent);
endfunction: new

function void vrf_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  vrf_ap = new("vrf_ap", this);
endfunction: build_phase

function void vrf_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(!uvm_config_db#(v_if)::get(this, "", "vrf_if", vrf_if))
    `uvm_fatal(get_type_name(), "Fail to get vrf_if!")
endfunction: connect_phase

task vrf_monitor::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask:configure_phase

task vrf_monitor::main_phase(uvm_phase phase);
  super.main_phase(phase);
  fork
     vrf_monitor();
  join
endtask: main_phase

task vrf_monitor::vrf_monitor();
  vrf_transaction tr;
  tr = new();
  forever begin
    @(posedge vrf_if.clk);
    if(vrf_if.rst_n) begin
      if(|vrf_if.rt_event) begin
        for(int i=0; i<32; i++) begin
            tr.vreg[i] = vrf_if.vreg[i];
        end
        vrf_ap.write(tr);
      end
    end
  end
endtask: vrf_monitor

`endif // VRF_MONITOR__SV
