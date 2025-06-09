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
// Package: kelvin_cosim_checker_pkg
// Description: Package for the UVM component that manages co-simulation.
//----------------------------------------------------------------------------
package kelvin_cosim_checker_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //----------------------------------------------------------------------------
  // Class: kelvin_cosim_checker
  // Description: Manages the MPACT simulator via DPI-C. It receives retired
  //              instruction info from the DUT (via RVVI) and sends that
  //              same instruction to the MPACT simulator to execute, enabling
  //              a trace-and-execute co-simulation flow.
  //----------------------------------------------------------------------------
  class kelvin_cosim_checker extends uvm_component;
    `uvm_component_utils(kelvin_cosim_checker)

    // Use fully parameterized virtual interface type
    virtual rvviTrace #(
      .ILEN(32), .XLEN(32), .FLEN(32), .VLEN(128), .NHART(1), .RETIRE(8)
    ) rvvi_vif;

    // Event to wait on, which will be triggered by the RVVI monitor
    uvm_event instruction_retired_event;

    // Constructor
    function new(string name = "kelvin_cosim_checker",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    // Build phase: Get VIF handle, create and share event
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // Get the RVVI virtual interface from the config_db (set by tb_top)
      if (!uvm_config_db#(
          virtual rvviTrace #(.ILEN(32), .XLEN(32), .FLEN(32), .VLEN(128),
                              .NHART(1), .RETIRE(8))
          )::get(this, "", "rvvi_vif", rvvi_vif)) begin
         `uvm_fatal(get_type_name(), "RVVI virtual interface not found!")
      end

      // Create the event that this component will wait on.
      instruction_retired_event = new("instruction_retired_event");
      // Pass the event to the monitor using an absolute path
      uvm_config_db#(uvm_event)::set(null, "*.m_rvvi_agent.monitor",
                                     "instruction_retired_event",
                                     instruction_retired_event);
    endfunction

    // Run phase: Contains the main co-simulation loop
    virtual task run_phase(uvm_phase phase);
      // TODO: Initialize the MPACT simulator.
      `uvm_info("COSIM_STUB", "MPACT simulator would be initialized now.",
                UVM_MEDIUM);


      // Main co-simulation loop
      forever begin
        // Wait for the RVVI monitor to signal an instruction retirement
        instruction_retired_event.wait_trigger();

        // This is a simplified example for one retirement channel (channel 0).
        // A full implementation would loop through all NRET channels.
        if (rvvi_vif.valid[0][0]) begin // Assuming NHART=1, check hart 0
            // Get the retired instruction from the DUT's trace
            logic [31:0] retired_instruction = rvvi_vif.insn[0][0];

            `uvm_info("COSIM_STUB",
                      $sformatf("DUT retired instruction 0x%h",
                                retired_instruction), UVM_HIGH);

            // TODO: Send this specific instruction to the MPACT simulator to
            //       execute, then call comparison task.
            step_and_compare();
        end
      end
    endtask

    // Task to get state from DUT and MPACT simulator and compare them
    virtual task step_and_compare();
      // TODO: Implement the full state comparison.
      //       1. Make DPI calls to get post-execution state (PC, GPRs, CSRs)
      //          from MPACT simulator.
      //       2. Get the same post-execution state from the DUT via the RVVI
      //          virtual interface.
      //       3. Compare the RTL state against the MPACT simulator state and
      //          report any mismatches.
    endtask

  endclass : kelvin_cosim_checker

endpackage : kelvin_cosim_checker_pkg
