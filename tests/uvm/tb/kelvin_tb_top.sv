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
// Module: kelvin_tb_top
// Description: Top-level testbench module for the Kelvin DUT.
//              Instantiates DUT, interfaces, clock/reset generation,
//              and starts the UVM test.
//----------------------------------------------------------------------------
`timescale 1ns / 1ps

module kelvin_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // Import necessary packages
  import transaction_item_pkg::*;
  import kelvin_test_pkg::*;

  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------
  localparam int unsigned AXI_ADDR_WIDTH = 32;
  localparam int unsigned AXI_DATA_WIDTH = 128;
  localparam int unsigned AXI_ID_WIDTH   = 6;
  localparam time CLK_PERIOD = 10ns;

  //--------------------------------------------------------------------------
  // Clock and Reset Signals
  //--------------------------------------------------------------------------
  logic clk;
  logic resetn;

  //--------------------------------------------------------------------------
  // Interface Instantiation
  //--------------------------------------------------------------------------
  kelvin_axi_master_if #(
    .AWIDTH(AXI_ADDR_WIDTH),
    .DWIDTH(AXI_DATA_WIDTH),
    .IDWIDTH(AXI_ID_WIDTH)
  ) master_axi_if (
    .clk(clk),
    .resetn(resetn)
  );

  kelvin_axi_slave_if #(
    .AWIDTH(AXI_ADDR_WIDTH),
    .DWIDTH(AXI_DATA_WIDTH),
    .IDWIDTH(AXI_ID_WIDTH)
  ) slave_axi_if (
    .clk(clk),
    .resetn(resetn)
  );

  kelvin_irq_if irq_if (
    .clk(clk),
    .resetn(resetn)
  );

  //--------------------------------------------------------------------------
  // DUT Instantiation
  //--------------------------------------------------------------------------
  RvvCoreMiniAxi #(
    // Add DUT parameters if needed
  ) u_dut (
    .io_aclk                         (clk),
    .io_aresetn                      (resetn),

    // --- DUT Slave Port Connections (Connected to TB Master Interface) ---
    // Write Address Channel
    .io_axi_slave_write_addr_valid   (master_axi_if.awvalid),
    .io_axi_slave_write_addr_bits_addr(master_axi_if.awaddr),
    .io_axi_slave_write_addr_bits_prot(master_axi_if.awprot),
    .io_axi_slave_write_addr_bits_id (master_axi_if.awid),
    .io_axi_slave_write_addr_bits_len(master_axi_if.awlen),
    .io_axi_slave_write_addr_bits_size(master_axi_if.awsize),
    .io_axi_slave_write_addr_bits_burst(master_axi_if.awburst),
    .io_axi_slave_write_addr_bits_lock(master_axi_if.awlock),
    .io_axi_slave_write_addr_bits_cache(master_axi_if.awcache),
    .io_axi_slave_write_addr_bits_qos(master_axi_if.awqos),
    .io_axi_slave_write_addr_bits_region(master_axi_if.awregion),
    .io_axi_slave_write_addr_ready   (master_axi_if.awready), // DUT Output

    // Write Data Channel
    .io_axi_slave_write_data_valid   (master_axi_if.wvalid),
    .io_axi_slave_write_data_bits_data(master_axi_if.wdata),
    .io_axi_slave_write_data_bits_last(master_axi_if.wlast),
    .io_axi_slave_write_data_bits_strb(master_axi_if.wstrb),
    .io_axi_slave_write_data_ready   (master_axi_if.wready), // DUT Output

    // Write Response Channel
    .io_axi_slave_write_resp_valid   (master_axi_if.bvalid), // DUT Output
    .io_axi_slave_write_resp_bits_id (master_axi_if.bid),    // DUT Output
    .io_axi_slave_write_resp_bits_resp(master_axi_if.bresp),   // DUT Output
    .io_axi_slave_write_resp_ready   (master_axi_if.bready),

    // Read Address Channel
    .io_axi_slave_read_addr_valid    (master_axi_if.arvalid),
    .io_axi_slave_read_addr_bits_addr(master_axi_if.araddr),
    .io_axi_slave_read_addr_bits_prot(master_axi_if.arprot),
    .io_axi_slave_read_addr_bits_id  (master_axi_if.arid),
    .io_axi_slave_read_addr_bits_len (master_axi_if.arlen),
    .io_axi_slave_read_addr_bits_size(master_axi_if.arsize),
    .io_axi_slave_read_addr_bits_burst(master_axi_if.arburst),
    .io_axi_slave_read_addr_bits_lock(master_axi_if.arlock),
    .io_axi_slave_read_addr_bits_cache(master_axi_if.arcache),
    .io_axi_slave_read_addr_bits_qos (master_axi_if.arqos),
    .io_axi_slave_read_addr_bits_region(master_axi_if.arregion),
    .io_axi_slave_read_addr_ready    (master_axi_if.arready), // DUT Output

    // Read Data Channel
    .io_axi_slave_read_data_valid    (master_axi_if.rvalid), // DUT Output
    .io_axi_slave_read_data_bits_data(master_axi_if.rdata),  // DUT Output
    .io_axi_slave_read_data_bits_id  (master_axi_if.rid),    // DUT Output
    .io_axi_slave_read_data_bits_resp(master_axi_if.rresp),   // DUT Output
    .io_axi_slave_read_data_bits_last(master_axi_if.rlast),   // DUT Output
    .io_axi_slave_read_data_ready    (master_axi_if.rready),

    // --- DUT Master Port Connections (Connected to TB Slave Interface) ---
    // Write Address Channel
    .io_axi_master_write_addr_valid   (slave_axi_if.awvalid), // DUT Output
    .io_axi_master_write_addr_bits_addr(slave_axi_if.awaddr),  // DUT Output
    .io_axi_master_write_addr_bits_prot(slave_axi_if.awprot),  // DUT Output
    .io_axi_master_write_addr_bits_id (slave_axi_if.awid),    // DUT Output
    .io_axi_master_write_addr_bits_len(slave_axi_if.awlen),   // DUT Output
    .io_axi_master_write_addr_bits_size(slave_axi_if.awsize),  // DUT Output
    .io_axi_master_write_addr_bits_burst(slave_axi_if.awburst), // DUT Output
    .io_axi_master_write_addr_bits_lock(slave_axi_if.awlock),  // DUT Output
    .io_axi_master_write_addr_bits_cache(slave_axi_if.awcache), // DUT Output
    .io_axi_master_write_addr_bits_qos(slave_axi_if.awqos),   // DUT Output
    .io_axi_master_write_addr_bits_region(slave_axi_if.awregion), // DUT Output
    .io_axi_master_write_addr_ready   (slave_axi_if.awready),

    // Write Data Channel
    .io_axi_master_write_data_valid   (slave_axi_if.wvalid), // DUT Output
    .io_axi_master_write_data_bits_data(slave_axi_if.wdata),  // DUT Output
    .io_axi_master_write_data_bits_last(slave_axi_if.wlast),   // DUT Output
    .io_axi_master_write_data_bits_strb(slave_axi_if.wstrb),  // DUT Output
    .io_axi_master_write_data_ready   (slave_axi_if.wready),

    // Write Response Channel
    .io_axi_master_write_resp_valid   (slave_axi_if.bvalid),
    .io_axi_master_write_resp_bits_id (slave_axi_if.bid),
    .io_axi_master_write_resp_bits_resp(slave_axi_if.bresp),
    .io_axi_master_write_resp_ready   (slave_axi_if.bready), // DUT Output

    // Read Address Channel
    .io_axi_master_read_addr_valid    (slave_axi_if.arvalid), // DUT Output
    .io_axi_master_read_addr_bits_addr(slave_axi_if.araddr),  // DUT Output
    .io_axi_master_read_addr_bits_prot(slave_axi_if.arprot),  // DUT Output
    .io_axi_master_read_addr_bits_id  (slave_axi_if.arid),    // DUT Output
    .io_axi_master_read_addr_bits_len (slave_axi_if.arlen),   // DUT Output
    .io_axi_master_read_addr_bits_size(slave_axi_if.arsize),  // DUT Output
    .io_axi_master_read_addr_bits_burst(slave_axi_if.arburst), // DUT Output
    .io_axi_master_read_addr_bits_lock(slave_axi_if.arlock),  // DUT Output
    .io_axi_master_read_addr_bits_cache(slave_axi_if.arcache), // DUT Output
    .io_axi_master_read_addr_bits_qos (slave_axi_if.arqos),   // DUT Output
    .io_axi_master_read_addr_bits_region(slave_axi_if.arregion), // DUT Output
    .io_axi_master_read_addr_ready    (slave_axi_if.arready),

    // Read Data Channel
    .io_axi_master_read_data_valid    (slave_axi_if.rvalid),
    .io_axi_master_read_data_bits_data(slave_axi_if.rdata),
    .io_axi_master_read_data_bits_id  (slave_axi_if.rid),
    .io_axi_master_read_data_bits_resp(slave_axi_if.rresp),
    .io_axi_master_read_data_bits_last(slave_axi_if.rlast),
    .io_axi_master_read_data_ready    (slave_axi_if.rready), // DUT Output

    // --- IRQ/Control/Status Port ---
    .io_irq                          (irq_if.irq),
    .io_te                           (irq_if.te),
    .io_halted                       (irq_if.halted), // DUT Output
    .io_fault                        (irq_if.fault),  // DUT Output
    .io_wfi                          (irq_if.wfi),    // DUT Output

    // --- Debug Port ---
    .io_debug_en                     ( /* Connect if needed */ ),
    .io_debug_addr_0                 ( /* Connect if needed */ ),
    .io_debug_addr_1                 ( /* Connect if needed */ ),
    .io_debug_addr_2                 ( /* Connect if needed */ ),
    .io_debug_addr_3                 ( /* Connect if needed */ ),
    .io_debug_inst_0                 ( /* Connect if needed */ ),
    .io_debug_inst_1                 ( /* Connect if needed */ ),
    .io_debug_inst_2                 ( /* Connect if needed */ ),
    .io_debug_inst_3                 ( /* Connect if needed */ ),
    .io_debug_cycles                 ( /* Connect if needed */ ),

    // --- Logging Port ---
    .io_slog_valid                   ( /* Connect if needed */ ),
    .io_slog_addr                    ( /* Connect if needed */ ),
    .io_slog_data                    ( /* Connect if needed */ )
  );

  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  //--------------------------------------------------------------------------
  // Reset Generation
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals before reset if needed
    irq_if.irq = 1'b0; // Driving low before reset
    irq_if.te  = 1'b0; // Driving low before reset

    // Reset Sequence
    resetn = 1'b0; // Assert reset
    `uvm_info("TB_TOP", "Reset Asserted", UVM_LOW)
    repeat (5) @(posedge clk);
    resetn = 1'b1; // Deassert reset
    `uvm_info("TB_TOP", "Reset Deasserted", UVM_LOW)

  end

  //--------------------------------------------------------------------------
  // UVM Test Execution
  //--------------------------------------------------------------------------
  initial begin
    // Set virtual interface handles in the config DB for UVM components
    uvm_config_db#(virtual kelvin_axi_master_if.TB_MASTER_DRIVER)::set(null, "uvm_test_top.env.m_master_agent*", "vif", master_axi_if);
    uvm_config_db#(virtual kelvin_axi_slave_if.TB_SLAVE_MODEL)::set(null, "uvm_test_top.env.m_slave_agent*", "vif", slave_axi_if);
    uvm_config_db#(virtual kelvin_irq_if.TB_IRQ_DRIVER)::set(null, "uvm_test_top.env.m_irq_agent*", "vif", irq_if);
    // Pass IRQ VIF to the test using DUT modport for monitoring status
    uvm_config_db#(virtual kelvin_irq_if.DUT_IRQ_PORT)::set(null, "uvm_test_top", "irq_vif", irq_if);

    // Start the UVM test. The test name is usually specified via +UVM_TESTNAME=
    run_test();
  end

  //--------------------------------------------------------------------------
  // Waveform Dumping (Conditional)
  //--------------------------------------------------------------------------
`ifdef DUMP_WAVES
  initial begin
    string wave_file_path;
    if ($value$plusargs("fsdbfile+%s", wave_file_path)) begin
      $fsdbDumpfile(wave_file_path);
      $fsdbDumpvars(0, kelvin_tb_top);
      $fsdbDumpvars(0, master_axi_if);
      $fsdbDumpvars(0, slave_axi_if);
      $fsdbDumpvars(0, irq_if);
      `uvm_info("TB_TOP", $sformatf("FSDB Waveform Dumping Enabled to: %s", wave_file_path), UVM_LOW)
    end else begin
      $fsdbDumpfile("kelvin_tb_top.fsdb");
      $fsdbDumpvars(0, kelvin_tb_top);
      $fsdbDumpvars(0, master_axi_if);
      $fsdbDumpvars(0, slave_axi_if);
      $fsdbDumpvars(0, irq_if);
      `uvm_warning("TB_TOP", "FSDB Waveform Dumping Enabled to default kelvin_tb_top.fsdb (use +fsdbfile+<path> for specific name)")
    end
  end
`endif // DUMP_WAVES

endmodule : kelvin_tb_top
