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
// Package: coralnpu_env_pkg
// Description: Package for the CoralNPU UVM Environment.
//----------------------------------------------------------------------------
package coralnpu_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import agent packages
  import coralnpu_axi_master_agent_pkg::*;
  import coralnpu_axi_slave_agent_pkg::*;
  import coralnpu_irq_agent_pkg::*;
  import coralnpu_rvvi_agent_pkg::*;
  import coralnpu_cosim_checker_pkg::*;

  //--------------------------------------------------------------------------
  // Class: coralnpu_env
  //--------------------------------------------------------------------------
  class coralnpu_env extends uvm_env;
    `uvm_component_utils(coralnpu_env)

    // Agent and Checker Handles
    coralnpu_axi_master_agent m_master_agent; // Drives DUT Slave Port
    coralnpu_axi_slave_agent  m_slave_agent;  // Responds to DUT Master Port
    coralnpu_irq_agent        m_irq_agent;    // Drives IRQ/Control Signals
    coralnpu_rvvi_agent       m_rvvi_agent;   // Passive agent for RVVI
    coralnpu_cosim_checker    m_cosim_checker; // Manages co-simulation against MPACT simulator

    // Constructor
    function new(string name = "coralnpu_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    // Build phase: Create agent instances
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase starting", UVM_MEDIUM)

      // Create the components
      m_master_agent = coralnpu_axi_master_agent::type_id::create("m_master_agent", this);
      m_slave_agent  = coralnpu_axi_slave_agent::type_id::create("m_slave_agent", this);
      m_irq_agent    = coralnpu_irq_agent::type_id::create("m_irq_agent", this);
      m_rvvi_agent   = coralnpu_rvvi_agent::type_id::create("m_rvvi_agent", this);
      m_cosim_checker = coralnpu_cosim_checker::type_id::create("m_cosim_checker", this);

      `uvm_info(get_type_name(), "Build phase finished", UVM_MEDIUM)
    endfunction : build_phase

    // Connect phase: Connect components if needed (e.g., monitors later)
    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    endfunction : connect_phase

  endclass : coralnpu_env

endpackage : coralnpu_env_pkg
