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
//              Instantiates the DUT, interfaces, and starts the UVM simulation.
//----------------------------------------------------------------------------
module kelvin_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import all necessary UVM packages
  import kelvin_test_pkg::*;
  import kelvin_env_pkg::*;
  import transaction_item_pkg::*;
  import kelvin_axi_master_agent_pkg::*;
  import kelvin_axi_slave_agent_pkg::*;
  import kelvin_irq_agent_pkg::*;
  import kelvin_rvvi_agent_pkg::*;
  import kelvin_cosim_checker_pkg::*;

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
  bit clk;
  bit resetn;

  //--------------------------------------------------------------------------
  // Interface Instantiations
  //--------------------------------------------------------------------------
  kelvin_axi_master_if #(
    .AWIDTH(AXI_ADDR_WIDTH),
    .DWIDTH(AXI_DATA_WIDTH),
    .IDWIDTH(AXI_ID_WIDTH)
  ) master_axi_if ( .clk(clk), .resetn(resetn) );

  kelvin_axi_slave_if #(
    .AWIDTH(AXI_ADDR_WIDTH),
    .DWIDTH(AXI_DATA_WIDTH),
    .IDWIDTH(AXI_ID_WIDTH)
  ) slave_axi_if ( .clk(clk), .resetn(resetn) );

  kelvin_irq_if irq_if ( .clk(clk), .resetn(resetn) );

  virtual rvviTrace #(
    .ILEN(32), .XLEN(32), .FLEN(32), .VLEN(128), .NHART(1), .RETIRE(8)
  ) rvvi_vif;


  //--------------------------------------------------------------------------
  // DUT Instantiation
  //--------------------------------------------------------------------------
  RvvCoreMiniVerificationAxi u_dut (
    .io_aclk(clk),
    .io_aresetn(resetn),

    // AXI Slave Port (Driven by TB Master)
    .io_axi_slave_write_addr_valid     (master_axi_if.awvalid),
    .io_axi_slave_write_addr_ready     (master_axi_if.awready),
    .io_axi_slave_write_addr_bits_addr (master_axi_if.awaddr),
    .io_axi_slave_write_addr_bits_prot (master_axi_if.awprot),
    .io_axi_slave_write_addr_bits_id   (master_axi_if.awid),
    .io_axi_slave_write_addr_bits_len  (master_axi_if.awlen),
    .io_axi_slave_write_addr_bits_size (master_axi_if.awsize),
    .io_axi_slave_write_addr_bits_burst(master_axi_if.awburst),
    .io_axi_slave_write_addr_bits_lock (master_axi_if.awlock),
    .io_axi_slave_write_addr_bits_cache(master_axi_if.awcache),
    .io_axi_slave_write_addr_bits_qos  (master_axi_if.awqos),
    .io_axi_slave_write_addr_bits_region(master_axi_if.awregion),

    .io_axi_slave_write_data_valid     (master_axi_if.wvalid),
    .io_axi_slave_write_data_ready     (master_axi_if.wready),
    .io_axi_slave_write_data_bits_data (master_axi_if.wdata),
    .io_axi_slave_write_data_bits_last (master_axi_if.wlast),
    .io_axi_slave_write_data_bits_strb (master_axi_if.wstrb),

    .io_axi_slave_write_resp_valid     (master_axi_if.bvalid),
    .io_axi_slave_write_resp_ready     (master_axi_if.bready),
    .io_axi_slave_write_resp_bits_id   (master_axi_if.bid),
    .io_axi_slave_write_resp_bits_resp (master_axi_if.bresp),

    .io_axi_slave_read_addr_valid      (master_axi_if.arvalid),
    .io_axi_slave_read_addr_ready      (master_axi_if.arready),
    .io_axi_slave_read_addr_bits_addr  (master_axi_if.araddr),
    .io_axi_slave_read_addr_bits_prot  (master_axi_if.arprot),
    .io_axi_slave_read_addr_bits_id    (master_axi_if.arid),
    .io_axi_slave_read_addr_bits_len   (master_axi_if.arlen),
    .io_axi_slave_read_addr_bits_size  (master_axi_if.arsize),
    .io_axi_slave_read_addr_bits_burst (master_axi_if.arburst),
    .io_axi_slave_read_addr_bits_lock  (master_axi_if.arlock),
    .io_axi_slave_read_addr_bits_cache (master_axi_if.arcache),
    .io_axi_slave_read_addr_bits_qos   (master_axi_if.arqos),
    .io_axi_slave_read_addr_bits_region(master_axi_if.arregion),

    .io_axi_slave_read_data_valid      (master_axi_if.rvalid),
    .io_axi_slave_read_data_ready      (master_axi_if.rready),
    .io_axi_slave_read_data_bits_data  (master_axi_if.rdata),
    .io_axi_slave_read_data_bits_id    (master_axi_if.rid),
    .io_axi_slave_read_data_bits_resp  (master_axi_if.rresp),
    .io_axi_slave_read_data_bits_last  (master_axi_if.rlast),


    // AXI Master Port (Drives TB Slave)
    .io_axi_master_write_addr_valid   (slave_axi_if.awvalid),
    .io_axi_master_write_addr_ready   (slave_axi_if.awready),
    .io_axi_master_write_addr_bits_addr(slave_axi_if.awaddr),
    .io_axi_master_write_addr_bits_prot(slave_axi_if.awprot),
    .io_axi_master_write_addr_bits_id (slave_axi_if.awid),
    .io_axi_master_write_addr_bits_len(slave_axi_if.awlen),
    .io_axi_master_write_addr_bits_size(slave_axi_if.awsize),
    .io_axi_master_write_addr_bits_burst(slave_axi_if.awburst),
    .io_axi_master_write_addr_bits_lock(slave_axi_if.awlock),
    .io_axi_master_write_addr_bits_cache(slave_axi_if.awcache),
    .io_axi_master_write_addr_bits_qos(slave_axi_if.awqos),
    .io_axi_master_write_addr_bits_region(slave_axi_if.awregion),

    .io_axi_master_write_data_valid   (slave_axi_if.wvalid),
    .io_axi_master_write_data_ready   (slave_axi_if.wready),
    .io_axi_master_write_data_bits_data(slave_axi_if.wdata),
    .io_axi_master_write_data_bits_last(slave_axi_if.wlast),
    .io_axi_master_write_data_bits_strb(slave_axi_if.wstrb),

    .io_axi_master_write_resp_valid   (slave_axi_if.bvalid),
    .io_axi_master_write_resp_ready   (slave_axi_if.bready),
    .io_axi_master_write_resp_bits_id (slave_axi_if.bid),
    .io_axi_master_write_resp_bits_resp(slave_axi_if.bresp),

    .io_axi_master_read_addr_valid    (slave_axi_if.arvalid),
    .io_axi_master_read_addr_ready    (slave_axi_if.arready),
    .io_axi_master_read_addr_bits_addr(slave_axi_if.araddr),
    .io_axi_master_read_addr_bits_prot(slave_axi_if.arprot),
    .io_axi_master_read_addr_bits_id  (slave_axi_if.arid),
    .io_axi_master_read_addr_bits_len (slave_axi_if.arlen),
    .io_axi_master_read_addr_bits_size(slave_axi_if.arsize),
    .io_axi_master_read_addr_bits_burst(slave_axi_if.arburst),
    .io_axi_master_read_addr_bits_lock (slave_axi_if.arlock),
    .io_axi_master_read_addr_bits_cache(slave_axi_if.arcache),
    .io_axi_master_read_addr_bits_qos  (slave_axi_if.arqos),
    .io_axi_master_read_addr_bits_region(slave_axi_if.arregion),

    .io_axi_master_read_data_valid    (slave_axi_if.rvalid),
    .io_axi_master_read_data_ready    (slave_axi_if.rready),
    .io_axi_master_read_data_bits_data(slave_axi_if.rdata),
    .io_axi_master_read_data_bits_id  (slave_axi_if.rid),
    .io_axi_master_read_data_bits_resp(slave_axi_if.rresp),
    .io_axi_master_read_data_bits_last(slave_axi_if.rlast),

    // IRQ, Control, and Status Signals
    .io_irq(irq_if.irq),
    .io_te(irq_if.te),
    .io_halted(irq_if.halted),
    .io_fault(irq_if.fault),
    .io_wfi(irq_if.wfi),

    // TODO: Connect Debug and Logging ports if needed by TB
    .io_debug_en(),
    .io_debug_addr_0(),
    .io_debug_addr_1(),
    .io_debug_addr_2(),
    .io_debug_addr_3(),
    .io_debug_inst_0(),
    .io_debug_inst_1(),
    .io_debug_inst_2(),
    .io_debug_inst_3(),
    .io_debug_cycles(),
    .io_slog_valid(),
    .io_slog_addr(),
    .io_slog_data()
  );


  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  //--------------------------------------------------------------------------
  // Reset Generation and Initial IRQ/TE Driving
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals before reset
    irq_if.irq = 1'b0;
    irq_if.te  = 1'b0;

    // Reset Sequence
    resetn = 1'b0; // Assert reset
    `uvm_info("TB_TOP", "Reset Asserted", UVM_LOW)
    repeat (5) @(posedge clk);
    resetn = 1'b1; // Deassert reset
    `uvm_info("TB_TOP", "Reset Deasserted", UVM_LOW)
  end

  //--------------------------------------------------------------------------
  // Waveform Dumping
  //--------------------------------------------------------------------------
  `ifdef DUMP_WAVES
  initial begin
    $fsdbDumpfile($sformatf("./sim_work/waves/%s.fsdb", "kelvin_base_test"));
    $fsdbDumpvars(0, kelvin_tb_top, "+mda");
    `uvm_info("TB_TOP",
              $sformatf("FSDB Waveform Dumping Enabled to: %s",
              $sformatf("./sim_work/waves/%s.fsdb", "kelvin_base_test")),
              UVM_LOW);
  end
  `endif

  //--------------------------------------------------------------------------
  // UVM Test Execution
  //--------------------------------------------------------------------------
  initial begin
    // Assign virtual interface handle procedurally
    rvvi_vif = u_dut.core.score.rvvi.rvviTraceBlackBox.rvvi;

    // Set virtual interfaces in the config_db for the agents/test
    uvm_config_db#(virtual kelvin_axi_master_if.TB_MASTER_DRIVER)::set(null,
        "*.env.m_master_agent*", "vif", master_axi_if);
    uvm_config_db#(virtual kelvin_axi_slave_if.TB_SLAVE_MODEL)::set(null,
        "*.env.m_slave_agent*", "vif", slave_axi_if);
    uvm_config_db#(virtual kelvin_irq_if.TB_IRQ_DRIVER)::set(null,
        "*.env.m_irq_agent*", "vif", irq_if);
    uvm_config_db#(virtual kelvin_irq_if.DUT_IRQ_PORT)::set(null,
        "*", "irq_vif", irq_if);

    uvm_config_db#(virtual rvviTrace #(.ILEN(32), .XLEN(32), .FLEN(32),
        .VLEN(128), .NHART(1), .RETIRE(8)))::set(null,
        "*.env.m_cosim_checker*", "rvvi_vif", rvvi_vif);
    uvm_config_db#(virtual rvviTrace #(.ILEN(32), .XLEN(32), .FLEN(32),
        .VLEN(128), .NHART(1), .RETIRE(8)))::set(null,
        "*.env.m_rvvi_agent*", "rvvi_vif", rvvi_vif);

    // Run the test
    run_test();
  end

endmodule : kelvin_tb_top
