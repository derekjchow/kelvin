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
// Package: coralnpu_cosim_checker_pkg
// Description: Package for the UVM component that manages co-simulation.
//----------------------------------------------------------------------------
package coralnpu_cosim_checker_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import coralnpu_cosim_dpi_if::*;

  //----------------------------------------------------------------------------
  // Struct: retired_instr_info_s
  // Description: A struct to hold information about a single retired
  //              instruction, captured from the RVVI trace.
  //----------------------------------------------------------------------------
  typedef struct {
    logic [31:0] pc;
    logic [31:0] insn;
    logic [31:0] x_wb;
    int          retire_index; // Original index from the RVVI bus
  } retired_instr_info_s;

  //----------------------------------------------------------------------------
  // Class: coralnpu_cosim_checker
  // Description: Manages the MPACT simulator via DPI-C. It receives retired
  //              instruction info from the DUT (via RVVI) and sends that
  //              same instruction to the MPACT simulator to execute, enabling
  //              a trace-and-execute co-simulation flow.
  //----------------------------------------------------------------------------
  class coralnpu_cosim_checker extends uvm_component;
    `uvm_component_utils(coralnpu_cosim_checker)

    // Use fully parameterized virtual interface type
    virtual rvviTrace #(
      .ILEN(32), .XLEN(32), .FLEN(32), .VLEN(128), .NHART(1), .RETIRE(8)
    ) rvvi_vif;

    // Event to wait on, which will be triggered by the RVVI monitor
    uvm_event instruction_retired_event;
    string test_elf;

    // Constructor
    function new(string name = "coralnpu_cosim_checker",
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

      // Get the ELF file path
      if (!uvm_config_db#(string)::get(this, "", "elf_file_for_iss", test_elf)) begin
        `uvm_fatal(get_type_name(), "TEST_ELF file path not found!")
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
      retired_instr_info_s retired_instr_q[$];
      int unsigned num_retired_this_cycle;
      int unsigned mpact_pc;
      logic [31:0] rtl_instr;

      if (mpact_init() != 0)
        `uvm_fatal(get_type_name(), "MPACT simulator DPI init failed.")
      if (mpact_load_program(test_elf) != 0)
        `uvm_fatal(get_type_name(), "MPACT simulator DPI init failed.")

      // Main co-simulation loop
      forever begin
        // Wait for the RVVI monitor to signal an instruction retirement
        instruction_retired_event.wait_trigger();
        retired_instr_q.delete();

        // Collect all retired instructions and their state from the RVVI trace
        for (int i = 0; i < rvvi_vif.RETIRE; i++) begin
          if (rvvi_vif.valid[0][i]) begin
            retired_instr_info_s info;
            info.pc = rvvi_vif.pc_rdata[0][i];
            info.insn = rvvi_vif.insn[0][i];
            info.x_wb = rvvi_vif.x_wb[0][i];
            info.retire_index = i; // Store the original channel index
            retired_instr_q.push_back(info);
            `uvm_info(get_type_name(),
              $sformatf("RTL Retired: PC=0x%h, Insn=0x%h", info.pc, info.insn),
              UVM_HIGH)
          end
        end
        num_retired_this_cycle = retired_instr_q.size();

        for (int i = 0; i < num_retired_this_cycle; i++) begin
          bit pc_match_found = 0;
          int match_index = -1;

          if (mpact_get_register("pc", mpact_pc) != 0) begin
            `uvm_error("COSIM_API_FAIL", "Failed to get PC from MPACT simulator.")
          end

          foreach (retired_instr_q[j]) begin
            if (retired_instr_q[j].pc == mpact_pc) begin
              pc_match_found = 1;
              match_index = j;
              break;
            end
          end

          if (!pc_match_found) begin
            string rtl_pcs_str = "[ ";
            foreach (retired_instr_q[j]) begin
              rtl_pcs_str = $sformatf("%s0x%h ", rtl_pcs_str,
                                      retired_instr_q[j].pc);
            end
            rtl_pcs_str = {rtl_pcs_str, "]"};
            `uvm_error("COSIM_PC_MISMATCH",
              $sformatf("MPACT PC 0x%h mismatches retired RTL PCs: %s",
                        mpact_pc, rtl_pcs_str))
            phase.drop_objection(this, "Terminating on PC mismatch.");
            return;
          end

          rtl_instr = retired_instr_q[match_index].insn;
          `uvm_info(get_type_name(),
                    $sformatf("PC match (0x%h). Stepping MPACT with 0x%h",
                              mpact_pc, rtl_instr), UVM_HIGH)

          if (mpact_step(rtl_instr) != 0) begin
            `uvm_error("COSIM_STEP_FAIL", "mpact_step() DPI call failed.")
            phase.drop_objection(this, "Terminating on MPACT step fail.");
            return;
          end

          // Check return status and terminate on failure
          if (!step_and_compare(retired_instr_q[match_index])) begin
            phase.drop_objection(this, "Terminating on GPR mismatch.");
            return;
          end

          retired_instr_q.delete(match_index);
        end
      end
    endtask

    virtual function bit step_and_compare(retired_instr_info_s rtl_info);
      int unsigned mpact_gpr_val;
      int unsigned rd_index;
      logic [31:0] rtl_wdata;
      string reg_name;

      `uvm_info(get_type_name(), "Comparing GPR writeback state...", UVM_HIGH)

      if (!$onehot0(rtl_info.x_wb)) begin
        `uvm_error("COSIM_GPR_MISMATCH",
          $sformatf("Invalid GPR writeback flag at PC 0x%h. x_wb is not one-hot: 0x%h",
                    rtl_info.pc, rtl_info.x_wb))
        return 0; // FAIL
      end

      if (rtl_info.x_wb == 1) begin
        `uvm_error("COSIM_GPR_MISMATCH",
          $sformatf("Illegal write to x0 detected at PC 0x%h.", rtl_info.pc))
        return 0; // FAIL
      end
      else if (rtl_info.x_wb != 0) begin
        rd_index = $clog2(rtl_info.x_wb);
        reg_name = $sformatf("x%0d", rd_index);
        if (mpact_get_register(reg_name, mpact_gpr_val) != 0) begin
          `uvm_error("COSIM_API_FAIL", $sformatf("Failed to get GPR '%s'", reg_name))
        end

        // Get the specific write data from the correct retire channel and register index
        rtl_wdata = rvvi_vif.x_wdata[0][rtl_info.retire_index][rd_index];

        if (mpact_gpr_val != rtl_wdata) begin
          `uvm_error("COSIM_GPR_MISMATCH",
            $sformatf("GPR[x%0d] mismatch at PC 0x%h. RTL: 0x%h, MPACT: 0x%h",
                      rd_index, rtl_info.pc,
                      rtl_wdata, mpact_gpr_val))
          return 0; // FAIL
        end
      end
      // If we reach here, all checks passed for this instruction.
      return 1; // PASS
    endfunction

  endclass : coralnpu_cosim_checker

endpackage : coralnpu_cosim_checker_pkg
