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
// Package: kelvin_test_pkg
// Description: Package for the Kelvin UVM tests and sequences.
//----------------------------------------------------------------------------
package kelvin_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import required packages
  import transaction_item_pkg::*;
  import kelvin_env_pkg::*;
  // Need access to agent sequencers, often via env handle
  import kelvin_axi_master_agent_pkg::*;
  import kelvin_irq_agent_pkg::*;

  //--------------------------------------------------------------------------
  // Sequence: kelvin_kickoff_write_seq
  //--------------------------------------------------------------------------
  class kelvin_kickoff_write_seq extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(kelvin_kickoff_write_seq)

    function new(string name = "kelvin_kickoff_write_seq");
        super.new(name);
    endfunction

    virtual task body();
      axi_transaction req;
      `uvm_info(get_type_name(), "Starting kickoff writes", UVM_MEDIUM)
      // 1. Write PC address to 0x00030004
      req = axi_transaction::type_id::create("req_pc");
      start_item(req);
      req.txn_type = AXI_WRITE;
      req.addr = 32'h00030004;
      req.len  = 0; req.size = $clog2(32/8); // Assuming 32-bit write for PC address itself
      req.burst = AXI_BURST_INCR;
      req.id = 0; req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      // Data value (128'h34 << 32) placed in lower bytes for 32-bit write size
      req.data.push_back(128'h00000034_00000000);
      req.strb.push_back(16'h000F); // Strobe for lower 4 bytes (assuming DUT handles alignment)
      finish_item(req);
      `uvm_info(get_type_name(), $sformatf("Kickoff Write 1 (PC Data=0x%h) sent to addr 0x%h", req.data[0], req.addr), UVM_LOW)

      // 2. Write Clock Gate Release
      req = axi_transaction::type_id::create("req_clk_gate");
      start_item(req);
      req.txn_type = AXI_WRITE;
      req.addr = 32'h00030000;
      req.len  = 0; req.size = $clog2(32/8); // Assuming 32-bit write
      req.burst = AXI_BURST_INCR;
      req.id = 0; req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      // ** UPDATED: Set data to 0x1 **
      req.data.push_back(128'h1);
      req.strb.push_back(16'h000F); // Strobe for lower 4 bytes
      finish_item(req);
      `uvm_info(get_type_name(), $sformatf("Kickoff Write 2 (ClkGate Data=0x%h) sent to addr 0x%h", req.data[0], req.addr), UVM_LOW)

      // 3. Write Reset Release
      req = axi_transaction::type_id::create("req_reset");
      start_item(req);
      req.txn_type = AXI_WRITE;
      req.addr = 32'h00030000;
      req.len  = 0; req.size = $clog2(32/8); // Assuming 32-bit write
      req.burst = AXI_BURST_INCR;
      req.id = 0; req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      req.data.push_back(128'h0); // Place 0 in correct byte lanes
      req.strb.push_back(16'h000F); // Strobe for lower 4 bytes
      finish_item(req);
      `uvm_info(get_type_name(), $sformatf("Kickoff Write 3 (Reset Data=0x%h) sent to addr 0x%h", req.data[0], req.addr), UVM_LOW)
      `uvm_info(get_type_name(), "Finished kickoff writes", UVM_MEDIUM)
    endtask
  endclass

  //--------------------------------------------------------------------------
  // Class: kelvin_base_test
  //--------------------------------------------------------------------------
  class kelvin_base_test extends uvm_test;
    `uvm_component_utils(kelvin_base_test)

    kelvin_env env;
    string test_binary = "";
    time   test_timeout = 10_000ns;
    string dut_mem_path = "kelvin_tb_top.u_dut.itcm.sram.sramModules_0.mem";
    protected bit test_passed = 1'b0;
    protected bit test_timed_out = 1'b0;
    protected bit dut_halted_flag = 1'b0;
    protected bit dut_faulted_flag = 1'b0;

    virtual kelvin_irq_if.DUT_IRQ_PORT irq_vif; // Keep for monitoring status

    function new(string name = "kelvin_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      string timeout_str;
      int    timeout_int;
      int    scan_count;
      uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase starting", UVM_MEDIUM)
      if (!clp.get_arg_value("+TEST_BINARY=", test_binary)) begin
         if (!uvm_config_db#(string)::get(this, "", "test_binary", test_binary)) begin
            `uvm_info(get_type_name(), "No +TEST_BINARY specified, using default.", UVM_LOW)
         end
      end
      if (test_binary != "") `uvm_info(get_type_name(), $sformatf("Using Test Binary: %s", test_binary), UVM_MEDIUM) else `uvm_warning(get_type_name(), "No test binary specified!")
      if (clp.get_arg_value("+TEST_TIMEOUT=", timeout_str)) begin
         scan_count = $sscanf(timeout_str, "%d", timeout_int);
         if (scan_count == 1 && timeout_int > 0) begin
             test_timeout = timeout_int * 1ns;
             `uvm_info(get_type_name(), $sformatf("Using custom timeout: %t", test_timeout), UVM_MEDIUM)
         end else begin
             `uvm_warning(get_type_name(), $sformatf("Invalid or non-positive +TEST_TIMEOUT value: %s", timeout_str))
         end
      end else begin
         `uvm_info(get_type_name(), $sformatf("Using default timeout: %t", test_timeout), UVM_MEDIUM)
      end
      env = kelvin_env::type_id::create("env", this);

      // Configure agents via config_db
      uvm_config_db#(uvm_active_passive_enum)::set(this, "env.m_master_agent*", "is_active", UVM_ACTIVE);
      uvm_config_db#(uvm_active_passive_enum)::set(this, "env.m_irq_agent*", "is_active", UVM_ACTIVE);

      // Get the IRQ/Status virtual interface handle (still needed for monitoring)
      if (!uvm_config_db#(virtual kelvin_irq_if.DUT_IRQ_PORT)::get(this, "", "irq_vif", irq_vif)) begin
          `uvm_fatal(get_type_name(), "IRQ virtual interface 'irq_vif' not found via config_db")
      end
      if (irq_vif == null) begin
          `uvm_fatal(get_type_name(), "IRQ virtual interface 'irq_vif' handle is null after get!")
      end

      `uvm_info(get_type_name(), "Build phase finished", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    // start_of_simulation_phase is a function in UVM 1.2
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Start of simulation phase", UVM_DEBUG)
    endfunction

    virtual task run_phase(uvm_phase phase);
      kelvin_kickoff_write_seq kickoff_seq;

      phase.raise_objection(this, "Base test running");
      `uvm_info(get_type_name(), "Run phase starting", UVM_MEDIUM)

      // Load memory at the beginning of run_phase
      if (test_binary != "") begin
          load_binary_to_mem(test_binary);
      end else begin
          `uvm_warning(get_type_name(), "Skipping memory load as no binary was specified.")
      end

      // 1. Wait for reset to finish
      `uvm_info(get_type_name(), "Waiting for reset deassertion...", UVM_MEDIUM)
      @(posedge irq_vif.clk iff irq_vif.resetn == 1'b1);
      `uvm_info(get_type_name(), "Reset deasserted.", UVM_MEDIUM)
      #100ns; // Delay after reset

      // 2. Start the kickoff sequence
      `uvm_info(get_type_name(), "Starting kickoff sequence", UVM_MEDIUM)
      kickoff_seq = kelvin_kickoff_write_seq::type_id::create("kickoff_seq");
      kickoff_seq.start(env.m_master_agent.sequencer);
      `uvm_info(get_type_name(), "Kickoff sequence finished", UVM_MEDIUM)

      // 3. Wait for DUT completion (halted/fault) or timeout
      `uvm_info(get_type_name(), "Waiting for DUT completion or timeout...", UVM_MEDIUM)
      fork
        begin // Wait for DUT completion
          wait (irq_vif.halted == 1'b1 || irq_vif.fault == 1'b1);
          dut_halted_flag = irq_vif.halted;
          dut_faulted_flag = irq_vif.fault;
          if (dut_halted_flag) `uvm_info(get_type_name(), "DUT halted signal observed", UVM_MEDIUM)
          if (dut_faulted_flag) `uvm_error(get_type_name(), "DUT fault signal observed")
          #10ns;
        end
        begin // Timeout mechanism
          #(test_timeout);
          if (!dut_halted_flag && !dut_faulted_flag) begin
              `uvm_error(get_type_name(), $sformatf("Test timed out after %t", test_timeout))
              test_timed_out = 1'b1;
          end
        end
      join_any
      disable fork;
      `uvm_info(get_type_name(), "Run phase finishing", UVM_MEDIUM)
      phase.drop_objection(this, "Base test finished");
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "Report phase starting", UVM_LOW)
        if (test_timed_out) test_passed = 1'b0; else if (dut_faulted_flag) test_passed = 1'b0; else if (dut_halted_flag) test_passed = 1'b1; else test_passed = 1'b0; // Default to fail if no clear pass condition
        if(test_passed) `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE) else `uvm_error(get_type_name(), "** UVM TEST FAILED **")
        `uvm_info(get_type_name(), "Report phase finished", UVM_LOW)
    endfunction

    virtual task load_binary_to_mem(string binary_path);
        int unsigned file_handle;
        int char_code; // Use int to check for EOF
        int unsigned byte_count = 0;
        logic [31:0] base_addr = 0; // Starting byte address for loading
        logic [7:0] byte_val;
        int unsigned mem_word_width_bytes = 128 / 8; // Memory width in bytes

        logic [31:0] current_byte_addr;
        int unsigned word_index;
        int unsigned byte_offset_in_word;
        int unsigned bit_offset_low;
        int unsigned bit_offset_high;
        string element_path;

        `uvm_info(get_type_name(), $sformatf("Attempting to load binary '%s' to memory path '%s'", binary_path, dut_mem_path), UVM_MEDIUM)

        file_handle = $fopen(binary_path, "rb");
        if (file_handle == 0) begin
            `uvm_fatal(get_type_name(), $sformatf("Failed to open binary file: %s", binary_path))
            return;
        end

        // Loop reading byte by byte until EOF
        forever begin
            char_code = $fgetc(file_handle);
            if ($feof(file_handle)) begin
                break; // Exit loop on End-Of-File
            end

            byte_val = char_code; // Convert read character code to byte

            // Calculate target address and path
            current_byte_addr = base_addr + byte_count;
            word_index = current_byte_addr / mem_word_width_bytes;
            byte_offset_in_word = current_byte_addr % mem_word_width_bytes;
            bit_offset_low = byte_offset_in_word * 8;
            bit_offset_high = bit_offset_low + 7;
            element_path = $sformatf("%s[%0d][%0d:%0d]", dut_mem_path, word_index, bit_offset_high, bit_offset_low);

            // Deposit the byte
            if (!uvm_hdl_deposit(element_path, byte_val)) begin
                `uvm_error(get_type_name(), $sformatf("uvm_hdl_deposit failed for path: %s", element_path))
            end
            byte_count++;
        end // forever loop

        $fclose(file_handle);

        if (byte_count > 0) begin
             `uvm_info(get_type_name(), $sformatf("Finished loading %0d bytes to memory starting at byte address 0x%h.", byte_count, base_addr), UVM_MEDIUM)
        end else begin
            `uvm_warning(get_type_name(), "Binary file was empty or could not be read, no memory loaded.")
        end

    endtask : load_binary_to_mem

  endclass

endpackage : kelvin_test_pkg
