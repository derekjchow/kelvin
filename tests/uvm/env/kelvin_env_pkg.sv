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
// Package: kelvin_env_pkg
// Description: Package for the Kelvin UVM Environment.
//----------------------------------------------------------------------------
package kelvin_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import agent packages
  import kelvin_axi_master_agent_pkg::*;
  import kelvin_axi_slave_agent_pkg::*;
  import kelvin_irq_agent_pkg::*;

  //--------------------------------------------------------------------------
  // Class: kelvin_env
  //--------------------------------------------------------------------------
  class kelvin_env extends uvm_env;
    `uvm_component_utils(kelvin_env)

    // Agent Handles
    kelvin_axi_master_agent m_master_agent; // Drives DUT Slave Port
    kelvin_axi_slave_agent  m_slave_agent;  // Responds to DUT Master Port
    kelvin_irq_agent        m_irq_agent;    // Drives IRQ/Control Signals

    // Add configuration handle if needed: kelvin_env_config cfg;

    // Constructor
    function new(string name = "kelvin_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    // Build phase: Create agent instances
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase starting", UVM_MEDIUM)

      // Create the agents
      m_master_agent = kelvin_axi_master_agent::type_id::create("m_master_agent", this);
      m_slave_agent  = kelvin_axi_slave_agent::type_id::create("m_slave_agent", this);
      m_irq_agent    = kelvin_irq_agent::type_id::create("m_irq_agent", this);

      `uvm_info(get_type_name(), "Build phase finished", UVM_MEDIUM)
    endfunction : build_phase

    // Connect phase: Connect components if needed (e.g., monitors later)
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    endfunction : connect_phase

  endclass : kelvin_env

endpackage : kelvin_env_pkg
