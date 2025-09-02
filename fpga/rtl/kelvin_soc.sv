// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module kelvin_soc
    #(parameter MemInitFile = "",
      parameter int ClockFrequencyMhz = 80)
    (input clk_i,
     input rst_ni,
     input ibex_clk_i,
     input ibex_rst_ni,
     input spi_clk_i,
     input prim_mubi_pkg::mubi4_t scanmode_i,
     input top_pkg::uart_sideband_i_t[1 : 0] uart_sideband_i,
     output top_pkg::uart_sideband_o_t[1 : 0] uart_sideband_o,
     output logic io_halted,
     output logic io_fault);

  import tlul_pkg::*;
  import top_pkg::*;

  kelvin_tlul_pkg_128::tl_h2d_t tl_kelvin_core_i;
  kelvin_tlul_pkg_128::tl_d2h_t tl_kelvin_core_o;
  kelvin_tlul_pkg_128::tl_h2d_t tl_kelvin_device_o;
  kelvin_tlul_pkg_128::tl_d2h_t tl_kelvin_device_i;

  kelvin_tlul_pkg_32::tl_h2d_t tl_ibex_core_i_o_32;
  kelvin_tlul_pkg_32::tl_d2h_t tl_ibex_core_i_i_32;

  kelvin_tlul_pkg_32::tl_h2d_t tl_rom_o_32;
  kelvin_tlul_pkg_32::tl_d2h_t tl_rom_i_32;

  kelvin_tlul_pkg_32::tl_h2d_t tl_ibex_core_d_o_32;
  kelvin_tlul_pkg_32::tl_d2h_t tl_ibex_core_d_i_32;

  tl_h2d_t tl_sram_o;
  tl_d2h_t tl_sram_i;

  tl_h2d_t tl_uart0_o;
  tl_d2h_t tl_uart0_i;

  tl_h2d_t tl_uart1_o;
  tl_d2h_t tl_uart1_i;

  tl_h2d_t tl_spi0_o;
  tl_d2h_t tl_spi0_i;

  KelvinXbar i_xbar(
    .io_clk_i(clk_i),
    .io_rst_ni(rst_ni),

    // Host connections
    .io_hosts_0_a_valid(tl_kelvin_core_i.a_valid),
    .io_hosts_0_a_bits_opcode(tl_kelvin_core_i.a_opcode),
    .io_hosts_0_a_bits_param(tl_kelvin_core_i.a_param),
    .io_hosts_0_a_bits_size(tl_kelvin_core_i.a_size),
    .io_hosts_0_a_bits_source(tl_kelvin_core_i.a_source),
    .io_hosts_0_a_bits_address(tl_kelvin_core_i.a_address),
    .io_hosts_0_a_bits_mask(tl_kelvin_core_i.a_mask),
    .io_hosts_0_a_bits_data(tl_kelvin_core_i.a_data),
    .io_hosts_0_a_bits_user_rsvd(tl_kelvin_core_i.a_user.rsvd),
    .io_hosts_0_a_bits_user_instr_type(tl_kelvin_core_i.a_user.instr_type),
    .io_hosts_0_a_bits_user_cmd_intg(tl_kelvin_core_i.a_user.cmd_intg),
    .io_hosts_0_a_bits_user_data_intg(tl_kelvin_core_i.a_user.data_intg),
    .io_hosts_0_d_ready(tl_kelvin_core_i.d_ready),
    .io_hosts_1_a_valid(1'b0),

    // Host response connections
    .io_hosts_0_a_ready(tl_kelvin_core_o.a_ready),
    .io_hosts_0_d_valid(tl_kelvin_core_o.d_valid),
    .io_hosts_0_d_bits_opcode(tl_kelvin_core_o.d_opcode),
    .io_hosts_0_d_bits_param(tl_kelvin_core_o.d_param),
    .io_hosts_0_d_bits_size(tl_kelvin_core_o.d_size),
    .io_hosts_0_d_bits_source(tl_kelvin_core_o.d_source),
    .io_hosts_0_d_bits_sink(tl_kelvin_core_o.d_sink),
    .io_hosts_0_d_bits_data(tl_kelvin_core_o.d_data),
    .io_hosts_0_d_bits_error(tl_kelvin_core_o.d_error),
    .io_hosts_0_d_bits_user_rsp_intg(tl_kelvin_core_o.d_user.rsp_intg),
    .io_hosts_0_d_bits_user_data_intg(tl_kelvin_core_o.d_user.data_intg),
    .io_hosts_1_d_ready(1'b0),

    // Device connections
    .io_devices_0_a_ready(tl_kelvin_device_i.a_ready),
    .io_devices_0_d_valid(tl_kelvin_device_i.d_valid),
    .io_devices_0_d_bits_opcode(tl_kelvin_device_i.d_opcode),
    .io_devices_0_d_bits_param(tl_kelvin_device_i.d_param),
    .io_devices_0_d_bits_size(tl_kelvin_device_i.d_size),
    .io_devices_0_d_bits_source(tl_kelvin_device_i.d_source),
    .io_devices_0_d_bits_sink(tl_kelvin_device_i.d_sink),
    .io_devices_0_d_bits_data(tl_kelvin_device_i.d_data),
    .io_devices_0_d_bits_error(tl_kelvin_device_i.d_error),
    .io_devices_0_d_bits_user_rsp_intg(tl_kelvin_device_i.d_user.rsp_intg),
    .io_devices_0_d_bits_user_data_intg(tl_kelvin_device_i.d_user.data_intg),
    .io_devices_1_a_ready(tl_rom_i_32.a_ready),
    .io_devices_1_d_valid(tl_rom_i_32.d_valid),
    .io_devices_1_d_bits_opcode(tl_rom_i_32.d_opcode),
    .io_devices_1_d_bits_param(tl_rom_i_32.d_param),
    .io_devices_1_d_bits_size(tl_rom_i_32.d_size),
    .io_devices_1_d_bits_source(tl_rom_i_32.d_source),
    .io_devices_1_d_bits_sink(tl_rom_i_32.d_sink),
    .io_devices_1_d_bits_data(tl_rom_i_32.d_data),
    .io_devices_1_d_bits_error(tl_rom_i_32.d_error),
    .io_devices_1_d_bits_user_rsp_intg(tl_rom_i_32.d_user.rsp_intg),
    .io_devices_1_d_bits_user_data_intg(tl_rom_i_32.d_user.data_intg),
    .io_devices_2_a_ready(tl_sram_i.a_ready),
    .io_devices_2_d_valid(tl_sram_i.d_valid),
    .io_devices_2_d_bits_opcode(tl_sram_i.d_opcode),
    .io_devices_2_d_bits_param(tl_sram_i.d_param),
    .io_devices_2_d_bits_size(tl_sram_i.d_size),
    .io_devices_2_d_bits_source(tl_sram_i.d_source),
    .io_devices_2_d_bits_sink(tl_sram_i.d_sink),
    .io_devices_2_d_bits_data(tl_sram_i.d_data),
    .io_devices_2_d_bits_error(tl_sram_i.d_error),
    .io_devices_2_d_bits_user_rsp_intg(tl_sram_i.d_user.rsp_intg),
    .io_devices_2_d_bits_user_data_intg(tl_sram_i.d_user.data_intg),
    .io_devices_3_a_ready(tl_uart0_i.a_ready),
    .io_devices_3_d_valid(tl_uart0_i.d_valid),
    .io_devices_3_d_bits_opcode(tl_uart0_i.d_opcode),
    .io_devices_3_d_bits_param(tl_uart0_i.d_param),
    .io_devices_3_d_bits_size(tl_uart0_i.d_size),
    .io_devices_3_d_bits_source(tl_uart0_i.d_source),
    .io_devices_3_d_bits_sink(tl_uart0_i.d_sink),
    .io_devices_3_d_bits_data(tl_uart0_i.d_data),
    .io_devices_3_d_bits_error(tl_uart0_i.d_error),
    .io_devices_3_d_bits_user_rsp_intg(tl_uart0_i.d_user.rsp_intg),
    .io_devices_3_d_bits_user_data_intg(tl_uart0_i.d_user.data_intg),
    .io_devices_4_a_ready(tl_uart1_i.a_ready),
    .io_devices_4_d_valid(tl_uart1_i.d_valid),
    .io_devices_4_d_bits_opcode(tl_uart1_i.d_opcode),
    .io_devices_4_d_bits_param(tl_uart1_i.d_param),
    .io_devices_4_d_bits_size(tl_uart1_i.d_size),
    .io_devices_4_d_bits_source(tl_uart1_i.d_source),
    .io_devices_4_d_bits_sink(tl_uart1_i.d_sink),
    .io_devices_4_d_bits_data(tl_uart1_i.d_data),
    .io_devices_4_d_bits_error(tl_uart1_i.d_error),
    .io_devices_4_d_bits_user_rsp_intg(tl_uart1_i.d_user.rsp_intg),
    .io_devices_4_d_bits_user_data_intg(tl_uart1_i.d_user.data_intg),

    // Device response connections
    .io_devices_0_a_valid(tl_kelvin_device_o.a_valid),
    .io_devices_0_a_bits_opcode(tl_kelvin_device_o.a_opcode),
    .io_devices_0_a_bits_param(tl_kelvin_device_o.a_param),
    .io_devices_0_a_bits_size(tl_kelvin_device_o.a_size),
    .io_devices_0_a_bits_source(tl_kelvin_device_o.a_source),
    .io_devices_0_a_bits_address(tl_kelvin_device_o.a_address),
    .io_devices_0_a_bits_mask(tl_kelvin_device_o.a_mask),
    .io_devices_0_a_bits_data(tl_kelvin_device_o.a_data),
    .io_devices_0_a_bits_user_rsvd(tl_kelvin_device_o.a_user.rsvd),
    .io_devices_0_a_bits_user_instr_type(tl_kelvin_device_o.a_user.instr_type),
    .io_devices_0_a_bits_user_cmd_intg(tl_kelvin_device_o.a_user.cmd_intg),
    .io_devices_0_a_bits_user_data_intg(tl_kelvin_device_o.a_user.data_intg),
    .io_devices_0_d_ready(tl_kelvin_device_o.d_ready),
    .io_devices_1_a_valid(tl_rom_o_32.a_valid),
    .io_devices_1_a_bits_opcode(tl_rom_o_32.a_opcode),
    .io_devices_1_a_bits_param(tl_rom_o_32.a_param),
    .io_devices_1_a_bits_size(tl_rom_o_32.a_size),
    .io_devices_1_a_bits_source(tl_rom_o_32.a_source),
    .io_devices_1_a_bits_address(tl_rom_o_32.a_address),
    .io_devices_1_a_bits_mask(tl_rom_o_32.a_mask),
    .io_devices_1_a_bits_data(tl_rom_o_32.a_data),
    .io_devices_1_a_bits_user_rsvd(tl_rom_o_32.a_user.rsvd),
    .io_devices_1_a_bits_user_instr_type(tl_rom_o_32.a_user.instr_type),
    .io_devices_1_a_bits_user_cmd_intg(tl_rom_o_32.a_user.cmd_intg),
    .io_devices_1_a_bits_user_data_intg(tl_rom_o_32.a_user.data_intg),
    .io_devices_1_d_ready(tl_rom_o_32.d_ready),
    .io_devices_2_a_valid(tl_sram_o.a_valid),
    .io_devices_2_a_bits_opcode(tl_sram_o.a_opcode),
    .io_devices_2_a_bits_param(tl_sram_o.a_param),
    .io_devices_2_a_bits_size(tl_sram_o.a_size),
    .io_devices_2_a_bits_source(tl_sram_o.a_source),
    .io_devices_2_a_bits_address(tl_sram_o.a_address),
    .io_devices_2_a_bits_mask(tl_sram_o.a_mask),
    .io_devices_2_a_bits_data(tl_sram_o.a_data),
    .io_devices_2_a_bits_user_rsvd(tl_sram_o.a_user.rsvd),
    .io_devices_2_a_bits_user_instr_type(tl_sram_o.a_user.instr_type),
    .io_devices_2_a_bits_user_cmd_intg(tl_sram_o.a_user.cmd_intg),
    .io_devices_2_a_bits_user_data_intg(tl_sram_o.a_user.data_intg),
    .io_devices_2_d_ready(tl_sram_o.d_ready),
    .io_devices_3_a_valid(tl_uart0_o.a_valid),
    .io_devices_3_a_bits_opcode(tl_uart0_o.a_opcode),
    .io_devices_3_a_bits_param(tl_uart0_o.a_param),
    .io_devices_3_a_bits_size(tl_uart0_o.a_size),
    .io_devices_3_a_bits_source(tl_uart0_o.a_source),
    .io_devices_3_a_bits_address(tl_uart0_o.a_address),
    .io_devices_3_a_bits_mask(tl_uart0_o.a_mask),
    .io_devices_3_a_bits_data(tl_uart0_o.a_data),
    .io_devices_3_a_bits_user_rsvd(tl_uart0_o.a_user.rsvd),
    .io_devices_3_a_bits_user_instr_type(tl_uart0_o.a_user.instr_type),
    .io_devices_3_a_bits_user_cmd_intg(tl_uart0_o.a_user.cmd_intg),
    .io_devices_3_a_bits_user_data_intg(tl_uart0_o.a_user.data_intg),
    .io_devices_3_d_ready(tl_uart0_o.d_ready),
    .io_devices_4_a_valid(tl_uart1_o.a_valid),
    .io_devices_4_a_bits_opcode(tl_uart1_o.a_opcode),
    .io_devices_4_a_bits_param(tl_uart1_o.a_param),
    .io_devices_4_a_bits_size(tl_uart1_o.a_size),
    .io_devices_4_a_bits_source(tl_uart1_o.a_source),
    .io_devices_4_a_bits_address(tl_uart1_o.a_address),
    .io_devices_4_a_bits_mask(tl_uart1_o.a_mask),
    .io_devices_4_a_bits_data(tl_uart1_o.a_data),
    .io_devices_4_a_bits_user_rsvd(tl_uart1_o.a_user.rsvd),
    .io_devices_4_a_bits_user_instr_type(tl_uart1_o.a_user.instr_type),
    .io_devices_4_a_bits_user_cmd_intg(tl_uart1_o.a_user.cmd_intg),
    .io_devices_4_a_bits_user_data_intg(tl_uart1_o.a_user.data_intg),
    .io_devices_4_d_ready(tl_uart1_o.d_ready)
  );

  uart i_uart0(.clk_i(clk_i),
               .rst_ni(rst_ni),
               .tl_i(tl_uart0_o),
               .tl_o(tl_uart0_i),
               .alert_rx_i(1'b0),
               .alert_tx_o(),
               .racl_policies_i(1'b0),
               .racl_error_o(),
               .cio_rx_i(uart_sideband_i[0].cio_rx),
               .cio_tx_o(uart_sideband_o[0].cio_tx),
               .cio_tx_en_o(uart_sideband_o[0].cio_tx_en),
               .intr_tx_watermark_o(uart_sideband_o[0].intr_tx_watermark),
               .intr_tx_empty_o(uart_sideband_o[0].intr_tx_empty),
               .intr_rx_watermark_o(uart_sideband_o[0].intr_rx_watermark),
               .intr_tx_done_o(uart_sideband_o[0].intr_tx_done),
               .intr_rx_overflow_o(uart_sideband_o[0].intr_rx_overflow),
               .intr_rx_frame_err_o(uart_sideband_o[0].intr_rx_frame_err),
               .intr_rx_break_err_o(uart_sideband_o[0].intr_rx_break_err),
               .intr_rx_timeout_o(uart_sideband_o[0].intr_rx_timeout),
               .intr_rx_parity_err_o(uart_sideband_o[0].intr_rx_parity_err),
               .lsio_trigger_o(uart_sideband_o[0].lsio_trigger));

  uart i_uart1(.clk_i(clk_i),
               .rst_ni(rst_ni),
               .tl_i(tl_uart1_o),
               .tl_o(tl_uart1_i),
               .alert_rx_i(1'b0),
               .alert_tx_o(),
               .racl_policies_i(1'b0),
               .racl_error_o(),
               .cio_rx_i(uart_sideband_i[1].cio_rx),
               .cio_tx_o(uart_sideband_o[1].cio_tx),
               .cio_tx_en_o(uart_sideband_o[1].cio_tx_en),
               .intr_tx_watermark_o(uart_sideband_o[1].intr_tx_watermark),
               .intr_tx_empty_o(uart_sideband_o[1].intr_tx_empty),
               .intr_rx_watermark_o(uart_sideband_o[1].intr_rx_watermark),
               .intr_tx_done_o(uart_sideband_o[1].intr_tx_done),
               .intr_rx_overflow_o(uart_sideband_o[1].intr_rx_overflow),
               .intr_rx_frame_err_o(uart_sideband_o[1].intr_rx_frame_err),
               .intr_rx_break_err_o(uart_sideband_o[1].intr_rx_break_err),
               .intr_rx_timeout_o(uart_sideband_o[1].intr_rx_timeout),
               .intr_rx_parity_err_o(uart_sideband_o[1].intr_rx_parity_err),
               .lsio_trigger_o(uart_sideband_o[1].lsio_trigger));

  logic rom_req;
  logic [10 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic rom_we;
  logic [31 : 0] rom_wdata;
  logic [3 : 0] rom_wmask;
  logic rom_rvalid;

  tlul_adapter_sram #(.SramAw(11),
                      .SramDw(32),
                      .ErrOnWrite(1),
                      .CmdIntgCheck(1'b1),
                      .EnableRspIntgGen(1'b1),
                      .EnableDataIntgGen(1'b1))
      i_rom_adapter(.clk_i(clk_i),
                    .rst_ni(rst_ni),
                    .tl_i(tl_rom_o_32),
                    .tl_o(tl_rom_i_32),
                    .req_o(rom_req),
                    .we_o(rom_we),
                    .addr_o(rom_addr),
                    .wdata_o(rom_wdata),
                    .wmask_o(rom_wmask),
                    .rdata_i(rom_rdata),
                    .gnt_i(1'b1),
                    .rvalid_i(rom_rvalid),
                    .en_ifetch_i(prim_mubi_pkg::MuBi4True),
                    .req_type_o(),
                    .intg_error_o(),
                    .user_rsvd_o(),
                    .rerror_i(2'b0),
                    .compound_txn_in_progress_o(),
                    .readback_en_i(4'b0),
                    .readback_error_o(),
                    .wr_collision_i(1'b0),
                    .write_pending_i(1'b0));

  prim_rom_adv #(.Width(32),
                 .Depth(2048),
                 .MemInitFile(MemInitFile))
      i_rom(.clk_i(clk_i),
            .rst_ni(rst_ni),
            .req_i(rom_req),
            .addr_i(rom_addr),
            .rvalid_o(rom_rvalid),
            .rdata_o(rom_rdata),
            .cfg_i('0));

  logic sram_req;
  logic sram_we;
  logic [11 : 0] sram_addr;
  logic [31 : 0] sram_wdata;
  logic [3 : 0] sram_wmask;
  logic [31 : 0] sram_rdata;
  logic sram_rvalid;

  tlul_adapter_sram #(.SramAw(12),
                      .SramDw(32),
                      .CmdIntgCheck(1'b1),
                      .EnableRspIntgGen(1'b1),
                      .EnableDataIntgGen(1'b1))
      i_sram_adapter(.clk_i(clk_i),
                     .rst_ni(rst_ni),
                     .tl_i(tl_sram_o),
                     .tl_o(tl_sram_i),
                     .req_o(sram_req),
                     .we_o(sram_we),
                     .addr_o(sram_addr),
                     .wdata_o(sram_wdata),
                     .wmask_o(sram_wmask),
                     .rdata_i(sram_rdata),
                     .gnt_i(1'b1),
                     .rvalid_i(sram_rvalid),
                     .en_ifetch_i(prim_mubi_pkg::MuBi4True),
                     .req_type_o(),
                     .intg_error_o(),
                     .user_rsvd_o(),
                     .rerror_i(2'b0),
                     .compound_txn_in_progress_o(),
                     .readback_en_i(4'b0),
                     .readback_error_o(),
                     .wr_collision_i(1'b0),
                     .write_pending_i(1'b0));

  Sram #(.Width(32),
         .Depth(1048576))
      i_sram(.clk_i(clk_i),
             .req_i(sram_req),
             .we_i(sram_we),
             .addr_i(sram_addr),
             .wdata_i(sram_wdata),
             .wmask_i(sram_wmask),
             .rdata_o(sram_rdata),
             .rvalid_o(sram_rvalid));

  // SPI Device Instantiation
  spi_device i_spi_device(.clk_i(clk_i),
                          .rst_ni(rst_ni),
                          .tl_i(tl_spi0_o),
                          .tl_o(tl_spi0_i),
                          .cio_sck_i(spi_clk_i),
                          .cio_csb_i(1'b1),
                          .cio_sd_o(),
                          .cio_sd_en_o(),
                          .cio_sd_i(4'b0),
                          // Tie off unused ports
                          .alert_rx_i('{default: '0}),
                          .alert_tx_o(),
                          .racl_policies_i('0),
                          .racl_error_o(),
                          .cio_tpm_csb_i(1'b1),
                          .passthrough_o(),
                          .passthrough_i('0),
                          .intr_upload_cmdfifo_not_empty_o(),
                          .intr_upload_payload_not_empty_o(),
                          .intr_upload_payload_overflow_o(),
                          .intr_readbuf_watermark_o(),
                          .intr_readbuf_flip_o(),
                          .intr_tpm_header_not_empty_o(),
                          .intr_tpm_rdfifo_cmd_end_o(),
                          .intr_tpm_rdfifo_drop_o(),
                          .ram_cfg_sys2spi_i('0),
                          .ram_cfg_rsp_sys2spi_o(),
                          .ram_cfg_spi2sys_i('0),
                          .ram_cfg_rsp_spi2sys_o(),
                          .sck_monitor_o(),
                          .mbist_en_i(1'b0),
                          .scan_clk_i(1'b0),
                          .scan_rst_ni(1'b1),
                          .scanmode_i(4'b0));

  logic rst_cpu_n;

  // Kelvin Core Instantiation
  logic kelvin_halted, kelvin_fault, kelvin_wfi;
  assign io_halted = kelvin_halted;
  assign io_fault = kelvin_fault;

  RvvCoreMiniTlul
      i_kelvin_core(
              .io_clk(clk_i),
              .io_rst_ni(rst_ni),
              .io_tl_host_a_ready(tl_kelvin_core_o.a_ready),
              .io_tl_host_a_valid(tl_kelvin_core_i.a_valid),
              .io_tl_host_a_bits_opcode(tl_kelvin_core_i.a_opcode),
              .io_tl_host_a_bits_param(tl_kelvin_core_i.a_param),
              .io_tl_host_a_bits_size(tl_kelvin_core_i.a_size),
              .io_tl_host_a_bits_source(tl_kelvin_core_i.a_source),
              .io_tl_host_a_bits_address(tl_kelvin_core_i.a_address),
              .io_tl_host_a_bits_mask(tl_kelvin_core_i.a_mask),
              .io_tl_host_a_bits_data(tl_kelvin_core_i.a_data),
              .io_tl_host_a_bits_user_rsvd(tl_kelvin_core_i.a_user.rsvd),
              .io_tl_host_a_bits_user_instr_type(tl_kelvin_core_i.a_user.instr_type),
              .io_tl_host_a_bits_user_cmd_intg(tl_kelvin_core_i.a_user.cmd_intg),
              .io_tl_host_a_bits_user_data_intg(tl_kelvin_core_i.a_user.data_intg),
              .io_tl_host_d_ready(tl_kelvin_core_i.d_ready),
              .io_tl_host_d_valid(tl_kelvin_core_o.d_valid),
              .io_tl_host_d_bits_opcode(tl_kelvin_core_o.d_opcode),
              .io_tl_host_d_bits_param(tl_kelvin_core_o.d_param),
              .io_tl_host_d_bits_size(tl_kelvin_core_o.d_size),
              .io_tl_host_d_bits_source(tl_kelvin_core_o.d_source),
              .io_tl_host_d_bits_sink(tl_kelvin_core_o.d_sink),
              .io_tl_host_d_bits_data(tl_kelvin_core_o.d_data),
              .io_tl_host_d_bits_error(tl_kelvin_core_o.d_error),
              .io_tl_host_d_bits_user_rsp_intg(
                  tl_kelvin_core_o.d_user.rsp_intg),
              .io_tl_host_d_bits_user_data_intg(
                  tl_kelvin_core_o.d_user.data_intg),
              .io_tl_device_a_valid(tl_kelvin_device_o.a_valid),
              .io_tl_device_a_bits_opcode(tl_kelvin_device_o.a_opcode),
              .io_tl_device_a_bits_param(tl_kelvin_device_o.a_param),
              .io_tl_device_a_bits_size(tl_kelvin_device_o.a_size),
              .io_tl_device_a_bits_source(tl_kelvin_device_o.a_source),
              .io_tl_device_a_bits_address(tl_kelvin_device_o.a_address),
              .io_tl_device_a_bits_mask(tl_kelvin_device_o.a_mask),
              .io_tl_device_a_bits_data(tl_kelvin_device_o.a_data),
              .io_tl_device_a_bits_user_rsvd(tl_kelvin_device_o.a_user.rsvd),
              .io_tl_device_a_bits_user_instr_type(
                  tl_kelvin_device_o.a_user.instr_type),
              .io_tl_device_a_bits_user_cmd_intg(
                  tl_kelvin_device_o.a_user.cmd_intg),
              .io_tl_device_a_bits_user_data_intg(
                  tl_kelvin_device_o.a_user.data_intg),
              .io_tl_device_d_ready(tl_kelvin_device_o.d_ready),
              .io_tl_device_a_ready(tl_kelvin_device_i.a_ready),
              .io_tl_device_d_valid(tl_kelvin_device_i.d_valid),
              .io_tl_device_d_bits_opcode(tl_kelvin_device_i.d_opcode),
              .io_tl_device_d_bits_param(tl_kelvin_device_i.d_param),
              .io_tl_device_d_bits_size(tl_kelvin_device_i.d_size),
              .io_tl_device_d_bits_source(tl_kelvin_device_i.d_source),
              .io_tl_device_d_bits_sink(tl_kelvin_device_i.d_sink),
              .io_tl_device_d_bits_data(tl_kelvin_device_i.d_data),
              .io_tl_device_d_bits_error(tl_kelvin_device_i.d_error),
              .io_tl_device_d_bits_user_rsp_intg(tl_kelvin_device_i.d_user.rsp_intg),
              .io_tl_device_d_bits_user_data_intg(tl_kelvin_device_i.d_user.data_intg),
              .io_halted(kelvin_halted),
              .io_fault(kelvin_fault),
              .io_wfi(kelvin_wfi),
              .io_irq(1'b0),
              .io_te(1'b0));

  // Ibex Core Instantiation
  rv_core_ibex #(.PipeLine(1'b1),
                 .PMPEnable(1'b0))
      i_ibex_core(.clk_i(ibex_clk_i),
                  .rst_ni(ibex_rst_ni),
                  .corei_tl_h_o(tl_ibex_core_i_o_32),
                  .corei_tl_h_i(tl_ibex_core_i_i_32),
                  .cored_tl_h_o(tl_ibex_core_d_o_32),
                  .cored_tl_h_i(tl_ibex_core_d_i_32),
                  // Tie off unused ports
                  .clk_edn_i(1'b0),
                  .rst_edn_ni(1'b1),
                  .clk_esc_i(1'b0),
                  .rst_esc_ni(1'b1),
                  .rst_cpu_n_o(rst_cpu_n),
                  .ram_cfg_icache_tag_i('0),
                  .ram_cfg_rsp_icache_tag_o(),
                  .ram_cfg_icache_data_i('0),
                  .ram_cfg_rsp_icache_data_o(),
                  .hart_id_i(32'b0),
                  .boot_addr_i(32'h10000000),
                  .irq_software_i(1'b0),
                  .irq_timer_i(1'b0),
                  .irq_external_i(1'b0),
                  .esc_tx_i('0),
                  .esc_rx_o(),
                  .nmi_wdog_i(1'b0),
                  .debug_req_i(1'b0),
                  .crash_dump_o(),
                  .lc_cpu_en_i(lc_ctrl_pkg::On),
                  .pwrmgr_cpu_en_i(lc_ctrl_pkg::On),
                  .pwrmgr_o(),
                  .scan_rst_ni(1'b1),
                  .scanmode_i(4'b0),
                  .cfg_tl_d_i('0),
                  .cfg_tl_d_o(),
                  .edn_o(),
                  .edn_i('0),
                  .clk_otp_i(1'b0),
                  .rst_otp_ni(1'b1),
                  .icache_otp_key_o(),
                  .icache_otp_key_i('0),
                  .fpga_info_i(32'b0),
                  .alert_rx_i('{default: '0}),
                  .alert_tx_o());
endmodule
