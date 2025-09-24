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
      req.data.push_back(128'h00000000_00000000); // PC value
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
    time   test_timeout = 20_000_000ns;

    protected bit test_passed = 1'b0;
    protected bit test_timed_out = 1'b0;
    protected bit dut_halted_flag = 1'b0;
    protected bit dut_faulted_flag = 1'b0;
    protected bit tohost_written_flag = 1'b0;
    protected logic [127:0] final_tohost_data;

    virtual kelvin_irq_if.DUT_IRQ_PORT irq_vif;
    uvm_event tohost_written_event;

    function new(string name = "kelvin_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      string test_elf;
      string timeout_str;
      int timeout_int;
      uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

      super.build_phase(phase);
      `uvm_info(get_type_name(), "Build phase starting", UVM_MEDIUM)
      if (!clp.get_arg_value("+TEST_ELF=", test_elf)) begin
        `uvm_fatal(get_type_name(), "+TEST_ELF plusarg not specified.")
      end

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

      env = kelvin_env::type_id::create("env", this);

      uvm_config_db#(string)::set(this, "*.m_cosim_checker",
                                  "elf_file_for_iss", test_elf);

      // Get the event handle that was created and set by tb_top
      if (!uvm_config_db#(uvm_event)::get(this, "",
          "tohost_written_event", tohost_written_event)) begin
        `uvm_fatal(get_type_name(), "tohost_written_event handle not found!")
      end

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

      // Memory is loaded by $readmemh in tb_top before run phase starts.

      `uvm_info(get_type_name(), "Waiting for reset deassertion...", UVM_MEDIUM)
      @(posedge irq_vif.clk iff irq_vif.resetn == 1'b1);
      `uvm_info(get_type_name(), "Reset deasserted.", UVM_MEDIUM)

      kickoff_seq = kelvin_kickoff_write_seq::type_id::create("kickoff_seq");
      kickoff_seq.start(env.m_master_agent.sequencer);

      `uvm_info(get_type_name(), "Waiting for completion or timeout...",
                UVM_MEDIUM)
      fork
        begin // Wait for tohost write
          tohost_written_event.wait_trigger();
          tohost_written_flag = 1'b1;
        end
        begin // Wait for DUT halted/faulted (backup termination)
          wait (irq_vif.halted == 1'b1 || irq_vif.fault == 1'b1);
          dut_halted_flag = irq_vif.halted;
          dut_faulted_flag = irq_vif.fault;
        end
        begin // Timeout mechanism
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
      logic [31:1] status_code;
      super.report_phase(phase);
      if (tohost_written_flag) begin
        if (uvm_config_db#(logic [127:0])::get(this, "",
            "final_tohost_data", final_tohost_data)) begin
          status_code = final_tohost_data[31:1];
          if (status_code == 0) begin
            test_passed = 1'b1;
            `uvm_info(get_type_name(),
              "tohost write detected with PASS status (0).", UVM_LOW)
          end else begin
            test_passed = 1'b0;
            `uvm_error(get_type_name(),
              $sformatf("tohost write detected with FAIL status code: %0d",
                        status_code))
          end
        end else `uvm_error(get_type_name(),
                  "tohost event triggered, but final status not found!")
      end else if (dut_halted_flag && !dut_faulted_flag) begin
        `uvm_info(get_type_name(), "Test ended on DUT halt.", UVM_LOW)
        test_passed = 1'b1;
      end else if (dut_faulted_flag) begin
        `uvm_info(get_type_name(), "Test ended on DUT fault.", UVM_LOW)
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

  endclass

endpackage : kelvin_test_pkg
