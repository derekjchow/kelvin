// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//----------------------------------------------------------------------------
// Package: coralnpu_rvvi_agent_pkg
// Description: Package for the CoralNPU RVVI Agent and its components.
//              This is a passive agent that only contains a monitor.
//----------------------------------------------------------------------------
package coralnpu_rvvi_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Define parameters locally, matching the DUT's RVVI instantiation
  localparam int ILEN   = 32;
  localparam int XLEN   = 32;
  localparam int FLEN   = 32;
  localparam int VLEN   = 128;
  localparam int NHART  = 1;
  localparam int RETIRE = 8;

  //--------------------------------------------------------------------------
  // Class: coralnpu_rvvi_monitor
  // Description: Monitors the rvviTrace interface and triggers an event upon
  //              instruction retirement.
  //--------------------------------------------------------------------------
  class coralnpu_rvvi_monitor extends uvm_monitor;
    `uvm_component_utils(coralnpu_rvvi_monitor)

    // Use fully parameterized virtual interface type
    virtual rvviTrace #(
      .ILEN(ILEN), .XLEN(XLEN), .FLEN(FLEN), .VLEN(VLEN), .NHART(NHART),
      .RETIRE(RETIRE)
    ) rvvi_vif;

    uvm_event instruction_retired_event;

    function new(string name = "coralnpu_rvvi_monitor",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(
          virtual rvviTrace #(.ILEN(ILEN), .XLEN(XLEN), .FLEN(FLEN),
                              .VLEN(VLEN), .NHART(NHART), .RETIRE(RETIRE))
          )::get(this, "", "rvvi_vif", rvvi_vif)) begin
         `uvm_fatal(get_type_name(), "RVVI virtual interface not found!")
      end
      if (!uvm_config_db#(uvm_event)::get(this, "",
          "instruction_retired_event", instruction_retired_event)) begin
         `uvm_fatal(get_type_name(),
                    "Instruction retired event handle not found!")
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      `uvm_info(get_type_name(), "RVVI Monitor run phase starting.",
                UVM_MEDIUM);
      forever begin
        bit any_instruction_retired = 1'b0;

        @(posedge rvvi_vif.clk);

        for (int i = 0; i < RETIRE; i++) begin
          if (rvvi_vif.valid[0][i]) begin // Assuming NHART=1
            `uvm_info(get_type_name(),
                      $sformatf("Instruction retired on channel %0d, PC: 0x%h",
                                i, rvvi_vif.pc_rdata[0][i]), UVM_HIGH)
            any_instruction_retired = 1'b1;
          end
        end

        if (any_instruction_retired) begin
          instruction_retired_event.trigger();
        end
      end
    endtask

  endclass : coralnpu_rvvi_monitor


  //--------------------------------------------------------------------------
  // Class: coralnpu_rvvi_agent
  //--------------------------------------------------------------------------
  class coralnpu_rvvi_agent extends uvm_agent;
    `uvm_component_utils(coralnpu_rvvi_agent)
    coralnpu_rvvi_monitor monitor;

    virtual rvviTrace #(
      .ILEN(ILEN), .XLEN(XLEN), .FLEN(FLEN), .VLEN(VLEN), .NHART(NHART),
      .RETIRE(RETIRE)
    ) rvvi_vif;

    function new(string name = "coralnpu_rvvi_agent",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      is_active = UVM_PASSIVE;

      if (!uvm_config_db#(
          virtual rvviTrace #(.ILEN(ILEN), .XLEN(XLEN), .FLEN(FLEN),
                              .VLEN(VLEN), .NHART(NHART), .RETIRE(RETIRE))
          )::get(this, "", "rvvi_vif", rvvi_vif)) begin
         `uvm_fatal(get_type_name(), "RVVI virtual interface not found!")
      end

      monitor = coralnpu_rvvi_monitor::type_id::create("monitor", this);

      uvm_config_db#(
        virtual rvviTrace #(.ILEN(ILEN), .XLEN(XLEN), .FLEN(FLEN),
                            .VLEN(VLEN), .NHART(NHART), .RETIRE(RETIRE))
        )::set(this, "monitor*", "rvvi_vif", rvvi_vif);

    endfunction
  endclass : coralnpu_rvvi_agent

endpackage : coralnpu_rvvi_agent_pkg
