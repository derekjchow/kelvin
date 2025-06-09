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
      req.len  = 0;
      req.size = $clog2(128/8);
      req.burst = AXI_BURST_INCR;
      req.id = 0;
      req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      req.data.push_back(128'h00000034_00000000); // PC value
      req.strb.push_back('1); // Write all bytes
      finish_item(req);
      `uvm_info(get_type_name(),
                $sformatf("Kickoff Write 1 (PC Data=0x%h) sent to addr 0x%h",
                          req.data[0], req.addr), UVM_LOW)

      // 2. Write Clock Gate Release
      req = axi_transaction::type_id::create("req_clk_gate");
      start_item(req);
      req.txn_type = AXI_WRITE;
      req.addr = 32'h00030000;
      req.len  = 0;
      req.size = $clog2(32/8);
      req.burst = AXI_BURST_INCR;
      req.id = 0;
      req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      req.data.push_back(128'h1);
      req.strb.push_back(16'h000F); // Strobe for lower 4 bytes
      finish_item(req);
      `uvm_info(get_type_name(),
                $sformatf("Kickoff Write 2 (ClkGate Data=0x%h) sent to addr 0x%h",
                          req.data[0], req.addr), UVM_LOW)

      // 3. Write Reset Release
      req = axi_transaction::type_id::create("req_reset");
      start_item(req);
      req.txn_type = AXI_WRITE;
      req.addr = 32'h00030000;
      req.len  = 0;
      req.size = $clog2(32/8);
      req.burst = AXI_BURST_INCR;
      req.id = 0;
      req.prot = 3'b000;
      req.data.delete();
      req.strb.delete();
      req.data.push_back(128'h0);
      req.strb.push_back(16'h000F); // Strobe for lower 4 bytes
      finish_item(req);
      `uvm_info(get_type_name(),
                $sformatf("Kickoff Write 3 (Reset Data=0x%h) sent to addr 0x%h",
                          req.data[0], req.addr), UVM_LOW)
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
    time   test_timeout = 20_000_000ns;
    logic [31:0] end_signature_addr = 32'h10000;
    string dut_mem_path_prefix = "kelvin_tb_top.u_dut.itcm.sram.sramModules_";

    protected bit test_passed = 1'b0;
    protected bit test_timed_out = 1'b0;
    protected bit dut_halted_flag = 1'b0;
    protected bit dut_faulted_flag = 1'b0;
    protected bit signature_written_flag = 1'b0;
    protected logic [127:0] final_signature_data;

    virtual kelvin_irq_if.DUT_IRQ_PORT irq_vif;
    uvm_event signature_written_event;

    function new(string name = "kelvin_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      string timeout_str, sig_addr_str;
      int timeout_int;
      uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase starting", UVM_MEDIUM)

      if (!clp.get_arg_value("+TEST_BINARY=", test_binary)) begin
        uvm_config_db#(string)::get(this, "", "test_binary", test_binary);
      end
      if (test_binary != "") `uvm_info(get_type_name(),
          $sformatf("Using Test Binary: %s", test_binary), UVM_MEDIUM)
      else `uvm_warning(get_type_name(), "No test binary specified!")

      if (clp.get_arg_value("+TEST_TIMEOUT=", timeout_str)) begin
        if ($sscanf(timeout_str, "%d", timeout_int) == 1 && timeout_int > 0)
        begin
           test_timeout = timeout_int * 1ns;
           `uvm_info(get_type_name(),
                     $sformatf("Using custom timeout: %t", test_timeout),
                     UVM_MEDIUM)
        end else `uvm_warning(get_type_name(),
                      $sformatf("Invalid +TEST_TIMEOUT value: %s", timeout_str))
      end

      if (clp.get_arg_value("+END_SIGNATURE_ADDR=", sig_addr_str)) begin
        if ($sscanf(sig_addr_str, "'h%h", end_signature_addr) == 1) begin
          `uvm_info(get_type_name(),
                    $sformatf("Using custom End Signature Addr: 0x%h",
                              end_signature_addr), UVM_MEDIUM)
        end else `uvm_warning(get_type_name(),
                      $sformatf("Invalid +END_SIGNATURE_ADDR: %s", sig_addr_str))
      end

      env = kelvin_env::type_id::create("env", this);

      signature_written_event = new("signature_written_event");
      uvm_config_db#(uvm_event)::set(this, "*.m_slave_agent.slave_model",
          "signature_written_event", signature_written_event);
      uvm_config_db#(logic [31:0])::set(this, "*.m_slave_agent.slave_model",
          "end_signature_addr", end_signature_addr);

      if (!uvm_config_db#(virtual kelvin_irq_if.DUT_IRQ_PORT)::get(this, "",
          "irq_vif", irq_vif))
        `uvm_fatal(get_type_name(), "IRQ VIF 'irq_vif' not found")
      if (irq_vif == null)
        `uvm_fatal(get_type_name(), "IRQ VIF 'irq_vif' is null")

      `uvm_info(get_type_name(), "Build phase finished", UVM_MEDIUM)
    endfunction

    virtual task run_phase(uvm_phase phase);
      kelvin_kickoff_write_seq kickoff_seq;
      phase.raise_objection(this, "Base test running");

      if (test_binary != "") load_binary_to_mem(test_binary);

      `uvm_info(get_type_name(), "Waiting for reset deassertion...", UVM_MEDIUM)
      @(posedge irq_vif.clk iff irq_vif.resetn == 1'b1);
      `uvm_info(get_type_name(), "Reset deasserted.", UVM_MEDIUM)

      kickoff_seq = kelvin_kickoff_write_seq::type_id::create("kickoff_seq");
      kickoff_seq.start(env.m_master_agent.sequencer);

      `uvm_info(get_type_name(), "Waiting for completion or timeout...",
                UVM_MEDIUM)
      fork
        begin
          signature_written_event.wait_trigger();
          signature_written_flag = 1'b1;
        end
        begin
          wait (irq_vif.halted == 1'b1 || irq_vif.fault == 1'b1);
          dut_halted_flag = irq_vif.halted;
          dut_faulted_flag = irq_vif.fault;
        end
        begin
          #(test_timeout);
          test_timed_out = 1'b1;
        end
      join_any
      disable fork;

      #100ns;

      `uvm_info(get_type_name(), "Run phase finishing", UVM_MEDIUM)
      phase.drop_objection(this, "Base test finished");
    endtask

    virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      if (signature_written_flag) begin
        if (uvm_config_db#(logic [127:0])::get(this, "",
            "final_signature_data", final_signature_data)) begin
          if (final_signature_data == 0) begin
            test_passed = 1'b1;
            `uvm_info(get_type_name(),
              $sformatf("Signature write detected with PASS status (0x%h).",
                        final_signature_data), UVM_LOW)
          end else begin
            test_passed = 1'b0;
            `uvm_error(get_type_name(),
              $sformatf("Signature write detected with FAIL status (0x%h).",
                        final_signature_data))
          end
        end else `uvm_error(get_type_name(),
                  "Signature event triggered, but final status not found!")
      end else if (dut_halted_flag && !dut_faulted_flag) begin
        `uvm_info(get_type_name(), "Halt without signature. Passing.", UVM_LOW)
        test_passed = 1'b1;
      end else if (dut_faulted_flag) begin
        `uvm_error(get_type_name(), "Test ended on DUT fault.")
        test_passed = 1'b0;
      end else if (test_timed_out) begin
        `uvm_error(get_type_name(),
                   $sformatf("Test timed out after %t", test_timeout))
        test_passed = 1'b0;
      end else begin
        `uvm_error(get_type_name(), "Test ended with no clear pass/fail.")
        test_passed = 1'b0;
      end

      if(test_passed) `uvm_info(get_type_name(), "** UVM TEST PASSED **",
                                UVM_NONE)
      else `uvm_error(get_type_name(), "** UVM TEST FAILED **")
    endfunction

    virtual task load_binary_to_mem(string binary_path);
      int unsigned file_handle;
      int unsigned byte_count = 0;
      logic [31:0] base_addr = 0;
      int unsigned num_sram_modules = 32;
      int unsigned sram_module_size_bytes = (2048 * 128) / 8;
      int unsigned total_mem_size_bytes = num_sram_modules *
                                          sram_module_size_bytes;
      int char_code;
      logic [7:0] byte_val;
      logic [31:0] current_byte_addr;
      int unsigned sram_module_idx;
      int unsigned addr_in_module;
      string element_path;
      int unsigned word_index;
      int unsigned byte_offset_in_word;
      int unsigned bit_offset_low;
      int unsigned bit_offset_high;

      `uvm_info(get_type_name(),
                $sformatf("Attempting to load binary '%s'", binary_path),
                UVM_MEDIUM)
      file_handle = $fopen(binary_path, "rb");
      if (file_handle == 0) begin
        `uvm_fatal(get_type_name(),
                   $sformatf("Failed to open binary file: %s", binary_path))
        return;
      end

      forever begin
        char_code = $fgetc(file_handle);
        if ($feof(file_handle)) break;
        if (byte_count >= total_mem_size_bytes) begin
          `uvm_error(get_type_name(),
            $sformatf("Binary file too large (%0d bytes). Truncating.",
                      total_mem_size_bytes));
          break;
        end

        byte_val = char_code;
        current_byte_addr = base_addr + byte_count;

        sram_module_idx = current_byte_addr / sram_module_size_bytes;
        addr_in_module = current_byte_addr % sram_module_size_bytes;

        word_index = addr_in_module / 16;
        byte_offset_in_word = addr_in_module % 16;
        bit_offset_low = byte_offset_in_word * 8;
        bit_offset_high = bit_offset_low + 7;
        element_path = $sformatf("%s%0d.mem[%0d][%0d:%0d]",
                                 dut_mem_path_prefix, sram_module_idx,
                                 word_index, bit_offset_high, bit_offset_low);

        if (!uvm_hdl_deposit(element_path, byte_val))
          `uvm_error(get_type_name(),
                     $sformatf("uvm_hdl_deposit failed for path: %s",
                               element_path))

        byte_count++;
      end

      $fclose(file_handle);
      if (byte_count > 0)
        `uvm_info(get_type_name(),
                  $sformatf("Finished loading %0d bytes.", byte_count),
                  UVM_MEDIUM)
      else
        `uvm_warning(get_type_name(), "Binary file was empty or not read.")
    endtask

  endclass

endpackage : kelvin_test_pkg
