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
      parameter int ClockFrequencyMhz = 10)
    (input clk_i,
     input rst_ni,
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
  kelvin_tlul_pkg_128::tl_h2d_t tl_ibex_core_i_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_ibex_core_i_i_xbar;

  tlul_host_upsizer i_ibex_core_i_upsizer(.clk_i(clk_i),
                                          .rst_ni(rst_ni),
                                          .s_tl_i(tl_ibex_core_i_o_32),
                                          .s_tl_o(tl_ibex_core_i_i_32),
                                          .m_tl_o(tl_ibex_core_i_o_xbar),
                                          .m_tl_i(tl_ibex_core_i_i_xbar));

  kelvin_tlul_pkg_32::tl_h2d_t tl_rom_o_32;
  kelvin_tlul_pkg_32::tl_d2h_t tl_rom_i_32;
  kelvin_tlul_pkg_128::tl_h2d_t tl_rom_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_rom_i_xbar;
  tlul_device_downsizer i_rom_downsizer(.clk_i(clk_i),
                                        .rst_ni(rst_ni),
                                        .s_tl_i(tl_rom_o_xbar),
                                        .s_tl_o(tl_rom_i_xbar),
                                        .m_tl_o(tl_rom_o_32),
                                        .m_tl_i(tl_rom_i_32));

  kelvin_tlul_pkg_32::tl_h2d_t tl_ibex_core_d_o_32;
  kelvin_tlul_pkg_32::tl_d2h_t tl_ibex_core_d_i_32;

  kelvin_tlul_pkg_128::tl_h2d_t tl_ibex_core_d_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_ibex_core_d_i_xbar;
  tlul_host_upsizer i_ibex_core_d_upsizer(.clk_i(clk_i),
                                          .rst_ni(rst_ni),
                                          .s_tl_i(tl_ibex_core_d_o_32),
                                          .s_tl_o(tl_ibex_core_d_i_32),
                                          .m_tl_o(tl_ibex_core_d_o_xbar),
                                          .m_tl_i(tl_ibex_core_d_i_xbar));

  kelvin_tlul_pkg_128::tl_h2d_t tl_sram_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_sram_i_xbar;
  tl_h2d_t tl_sram_o;
  tl_d2h_t tl_sram_i;
  tlul_device_downsizer i_sram_downsizer(.clk_i(clk_i),
                                         .rst_ni(rst_ni),
                                         .s_tl_i(tl_sram_o_xbar),
                                         .s_tl_o(tl_sram_i_xbar),
                                         .m_tl_o(tl_sram_o),
                                         .m_tl_i(tl_sram_i));
  kelvin_tlul_pkg_128::tl_h2d_t tl_uart0_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_uart0_i_xbar;
  tl_h2d_t tl_uart0_o;
  tl_d2h_t tl_uart0_i;
  tlul_device_downsizer i_uart0_downsizer(.clk_i(clk_i),
                                          .rst_ni(rst_ni),
                                          .s_tl_i(tl_uart0_o_xbar),
                                          .s_tl_o(tl_uart0_i_xbar),
                                          .m_tl_o(tl_uart0_o),
                                          .m_tl_i(tl_uart0_i));
  kelvin_tlul_pkg_128::tl_h2d_t tl_uart1_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_uart1_i_xbar;
  tl_h2d_t tl_uart1_o;
  tl_d2h_t tl_uart1_i;
  tlul_device_downsizer i_uart1_downsizer(.clk_i(clk_i),
                                          .rst_ni(rst_ni),
                                          .s_tl_i(tl_uart1_o_xbar),
                                          .s_tl_o(tl_uart1_i_xbar),
                                          .m_tl_o(tl_uart1_o),
                                          .m_tl_i(tl_uart1_i));
  kelvin_tlul_pkg_128::tl_h2d_t tl_spi0_o_xbar;
  kelvin_tlul_pkg_128::tl_d2h_t tl_spi0_i_xbar;
  tl_h2d_t tl_spi0_o;
  tl_d2h_t tl_spi0_i;
  tlul_device_downsizer i_spi0_downsizer(.clk_i(clk_i),
                                         .rst_ni(rst_ni),
                                         .s_tl_i(tl_spi0_o_xbar),
                                         .s_tl_o(tl_spi0_i_xbar),
                                         .m_tl_o(tl_spi0_o),
                                         .m_tl_i(tl_spi0_i));

  xbar_kelvin_soc_xbar i_xbar(.clk_i(clk_i),
                              .rst_ni(rst_ni),
                              .spi_clk_i(spi_clk_i),
                              .scanmode_i(scanmode_i),
                              .tl_kelvin_core_i(tl_kelvin_core_i),
                              .tl_kelvin_core_o(tl_kelvin_core_o),
                              .tl_ibex_core_i_o(tl_ibex_core_i_i_xbar),
                              .tl_ibex_core_i_i(tl_ibex_core_i_o_xbar),
                              .tl_ibex_core_d_o(tl_ibex_core_d_i_xbar),
                              .tl_ibex_core_d_i(tl_ibex_core_d_o_xbar),
                              .tl_kelvin_device_o(tl_kelvin_device_o),
                              .tl_kelvin_device_i(tl_kelvin_device_i),
                              .tl_rom_o(tl_rom_o_xbar),
                              .tl_rom_i(tl_rom_i_xbar),
                              .tl_sram_o(tl_sram_o_xbar),
                              .tl_sram_i(tl_sram_i_xbar),
                              .tl_uart0_o(tl_uart0_o_xbar),
                              .tl_uart0_i(tl_uart0_i_xbar),
                              .tl_uart1_o(tl_uart1_o_xbar),
                              .tl_uart1_i(tl_uart1_i_xbar),
                              .tl_spi0_o(tl_spi0_o_xbar),
                              .tl_spi0_i(tl_spi0_i_xbar));

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
         .Depth(4096))
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

  // Data and Response integrity generation for Kelvin Device Port
  localparam int XbarSourceWidth = kelvin_tlul_pkg_128::TL_AIW;
  localparam int XbarSourceCount = 1 << XbarSourceWidth;
  logic [1 : 0] host_lane_reg[XbarSourceCount - 1 : 0];

  logic [38 : 0] dev_ecc_full_0, dev_ecc_full_1, dev_ecc_full_2, dev_ecc_full_3;
  logic [6 : 0] dev_ecc_0, dev_ecc_1, dev_ecc_2, dev_ecc_3;
  logic [6 : 0] dev_selected_ecc;
  tl_d2h_rsp_intg_t dev_rsp_metadata;
  logic [63 : 0] dev_rsp_ecc_full;
  logic [6 : 0] dev_rsp_ecc;

  assign dev_ecc_0 = dev_ecc_full_0[38 : 32];
  assign dev_ecc_1 = dev_ecc_full_1[38 : 32];
  assign dev_ecc_2 = dev_ecc_full_2[38 : 32];
  assign dev_ecc_3 = dev_ecc_full_3[38 : 32];
  assign dev_rsp_ecc = dev_rsp_ecc_full[63 : 57];

  prim_secded_inv_39_32_enc dev_enc0(.data_i(tl_kelvin_device_i.d_data[31 : 0]),
                                     .data_o(dev_ecc_full_0));
  prim_secded_inv_39_32_enc dev_enc1(.data_i(
                                         tl_kelvin_device_i.d_data[63 : 32]),
                                     .data_o(dev_ecc_full_1));
  prim_secded_inv_39_32_enc dev_enc2(.data_i(
                                         tl_kelvin_device_i.d_data[95 : 64]),
                                     .data_o(dev_ecc_full_2));
  prim_secded_inv_39_32_enc dev_enc3(.data_i(
                                         tl_kelvin_device_i.d_data[127 : 96]),
                                     .data_o(dev_ecc_full_3));

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int i = 0; i < XbarSourceCount; i++) begin
        host_lane_reg[i] <= 2'b0;
      end
    end else begin
      // Capture lane index from Ibex data core requests
      if (tl_ibex_core_d_o_xbar.a_valid && tl_ibex_core_d_i_xbar.a_ready) begin
        unique case (4'hF)
          tl_ibex_core_d_o_xbar.a_mask[3 : 0]:
            host_lane_reg[tl_ibex_core_d_o_xbar.a_source] <= 2'b00;
          tl_ibex_core_d_o_xbar.a_mask[7 : 4]:
            host_lane_reg[tl_ibex_core_d_o_xbar.a_source] <= 2'b01;
          tl_ibex_core_d_o_xbar.a_mask[11 : 8]:
            host_lane_reg[tl_ibex_core_d_o_xbar.a_source] <= 2'b10;
          tl_ibex_core_d_o_xbar.a_mask[15 : 12]:
            host_lane_reg[tl_ibex_core_d_o_xbar.a_source] <= 2'b11;
        endcase
      end

      // Capture lane index from Ibex instruction core requests
      if (tl_ibex_core_i_o_xbar.a_valid && tl_ibex_core_i_i_xbar.a_ready) begin
        unique case (4'hF)
          tl_ibex_core_i_o_xbar.a_mask[3 : 0]:
            host_lane_reg[tl_ibex_core_i_o_xbar.a_source] <= 2'b00;
          tl_ibex_core_i_o_xbar.a_mask[7 : 4]:
            host_lane_reg[tl_ibex_core_i_o_xbar.a_source] <= 2'b01;
          tl_ibex_core_i_o_xbar.a_mask[11 : 8]:
            host_lane_reg[tl_ibex_core_i_o_xbar.a_source] <= 2'b10;
          tl_ibex_core_i_o_xbar.a_mask[15 : 12]:
            host_lane_reg[tl_ibex_core_i_o_xbar.a_source] <= 2'b11;
        endcase
      end

      // Capture lane index from Kelvin core requests
      if (tl_kelvin_core_i.a_valid && tl_kelvin_core_o.a_ready) begin
        unique case (4'hF)
          tl_kelvin_core_i.a_mask[3 : 0]:
            host_lane_reg[tl_kelvin_core_i.a_source] <= 2'b00;
          tl_kelvin_core_i.a_mask[7 : 4]:
            host_lane_reg[tl_kelvin_core_i.a_source] <= 2'b01;
          tl_kelvin_core_i.a_mask[11 : 8]:
            host_lane_reg[tl_kelvin_core_i.a_source] <= 2'b10;
          tl_kelvin_core_i.a_mask[15 : 12]:
            host_lane_reg[tl_kelvin_core_i.a_source] <= 2'b11;
        endcase
      end
    end
  end

  always_comb begin
    logic [1 : 0] lane_idx;
    lane_idx = host_lane_reg[tl_from_kelvin_core.d_source];
    case (lane_idx)
      2'b00:
        dev_selected_ecc = dev_ecc_0;
      2'b01:
        dev_selected_ecc = dev_ecc_1;
      2'b10:
        dev_selected_ecc = dev_ecc_2;
      2'b11:
        dev_selected_ecc = dev_ecc_3;
      default:
        dev_selected_ecc = dev_ecc_0;
    endcase
  end

  assign dev_rsp_metadata = '{
    opcode: tl_from_kelvin_core.d_opcode,
    size: 2'b10,
    error: tl_from_kelvin_core.d_error
  };

  prim_secded_inv_64_57_enc dev_enc_rsp(.data_i(
                                            D2HRspMaxWidth'(dev_rsp_metadata)),
                                        .data_o(dev_rsp_ecc_full));

  // Kelvin Core Instantiation
  logic kelvin_halted, kelvin_fault, kelvin_wfi;
  kelvin_tlul_pkg_128::tl_d2h_t tl_from_kelvin_core;

  assign io_halted = kelvin_halted;
  assign io_fault = kelvin_fault;

  // Assign all fields for the device D-channel from the Kelvin core's output,
  // except for the user integrity bits, which we override with our generated
  // ECC.
  assign tl_kelvin_device_i.d_valid = tl_from_kelvin_core.d_valid;
  assign tl_kelvin_device_i.d_opcode = tl_from_kelvin_core.d_opcode;
  assign tl_kelvin_device_i.d_param = tl_from_kelvin_core.d_param;
  assign tl_kelvin_device_i.d_size = tl_from_kelvin_core.d_size;
  assign tl_kelvin_device_i.d_source = tl_from_kelvin_core.d_source;
  assign tl_kelvin_device_i.d_sink = tl_from_kelvin_core.d_sink;
  assign tl_kelvin_device_i.d_data = tl_from_kelvin_core.d_data;
  assign tl_kelvin_device_i.d_error = tl_from_kelvin_core.d_error;
  assign tl_kelvin_device_i.a_ready = tl_from_kelvin_core.a_ready;
  assign tl_kelvin_device_i.d_user.rsp_intg = dev_rsp_ecc;
  assign tl_kelvin_device_i.d_user.data_intg = dev_selected_ecc;

  // Command and Data integrity generation for Kelvin Host Port
  logic [38 : 0] host_a_data_ecc_full_0, host_a_data_ecc_full_1,
                 host_a_data_ecc_full_2, host_a_data_ecc_full_3;
  logic [6 : 0] host_a_data_ecc_0, host_a_data_ecc_1, host_a_data_ecc_2,
                host_a_data_ecc_3;
  logic [6 : 0] host_a_data_selected_ecc;
  tl_h2d_cmd_intg_t host_a_cmd_metadata;
  logic [63 : 0] host_a_cmd_ecc_full;
  logic [6 : 0] host_a_cmd_ecc;

  assign host_a_data_ecc_0 = host_a_data_ecc_full_0[38 : 32];
  assign host_a_data_ecc_1 = host_a_data_ecc_full_1[38 : 32];
  assign host_a_data_ecc_2 = host_a_data_ecc_full_2[38 : 32];
  assign host_a_data_ecc_3 = host_a_data_ecc_full_3[38 : 32];
  assign host_a_cmd_ecc = host_a_cmd_ecc_full[63 : 57];

  prim_secded_inv_39_32_enc host_a_data_enc0(
                                    .data_i(tl_kelvin_core_i.a_data[31 : 0]),
                                    .data_o(host_a_data_ecc_full_0));
  prim_secded_inv_39_32_enc host_a_data_enc1(
                                    .data_i(tl_kelvin_core_i.a_data[63 : 32]),
                                    .data_o(host_a_data_ecc_full_1));
  prim_secded_inv_39_32_enc host_a_data_enc2(
                                    .data_i(tl_kelvin_core_i.a_data[95 : 64]),
                                    .data_o(host_a_data_ecc_full_2));
  prim_secded_inv_39_32_enc host_a_data_enc3(
                                    .data_i(tl_kelvin_core_i.a_data[127 : 96]),
                                    .data_o(host_a_data_ecc_full_3));

  logic [top_pkg::TL_DBW - 1 : 0] host_a_cmd_mask;

  localparam logic [top_pkg::TL_AW - 1 : 0] Uart1BaseAddr = 32'h40010000;
  logic [15 : 0] computed_mask;
  logic [3 : 0] host_a_cmd_mask_4b;
  logic [1 : 0] host_a_cmd_lane;
  tl_h2d_cmd_intg_t host_a_cmd_payload;
  logic [15 : 0] kelvin_core_i_a_mask;

  always_comb begin
    if (tl_kelvin_core_i.a_opcode == tlul_pkg::Get) begin
      computed_mask = ((1 << (1 << tl_kelvin_core_i.a_size)) - 1)
                      << (tl_kelvin_core_i.a_address[3 : 0]);
    end else begin
      computed_mask = kelvin_core_i_a_mask;
    end
    host_a_data_selected_ecc = 7'b0;
    host_a_cmd_mask_4b = '0;
    host_a_cmd_lane = '0;
    // This is a priority mux, which is what we want.
    if (|computed_mask[3 : 0]) begin
      host_a_data_selected_ecc = host_a_data_ecc_0;
      host_a_cmd_mask_4b = computed_mask[3 : 0];
      host_a_cmd_lane = 2'b00;
    end else if (|computed_mask[7 : 4]) begin
      host_a_data_selected_ecc = host_a_data_ecc_1;
      host_a_cmd_mask_4b = computed_mask[7 : 4];
      host_a_cmd_lane = 2'b01;
    end else if (|computed_mask[11 : 8]) begin
      host_a_data_selected_ecc = host_a_data_ecc_2;
      host_a_cmd_mask_4b = computed_mask[11 : 8];
      host_a_cmd_lane = 2'b10;
    end else if (|computed_mask[15 : 12]) begin
      host_a_data_selected_ecc = host_a_data_ecc_3;
      host_a_cmd_mask_4b = computed_mask[15 : 12];
      host_a_cmd_lane = 2'b11;
    end
  end

  // Manually pack the command integrity payload to match the 32-bit
  // peripheral's view. The packing order is derived from the tl_h2d_cmd_intg_t
  // struct definition.
  assign host_a_cmd_payload = '{
    instr_type: prim_mubi_pkg::MuBi4False,  // instr_type (4 bits)
    addr: tl_kelvin_core_i.a_address,       // addr (32 bits)
    opcode: tl_kelvin_core_i.a_opcode,      // opcode (3 bits)
    mask: host_a_cmd_mask_4b                // mask (4 bits)
  };
  logic [31 : 0] dbg_uart1_addr = host_a_cmd_payload.addr;
  logic [2 : 0] dbg_uart1_opcode = host_a_cmd_payload.opcode;
  logic [3 : 0] dbg_uart1_mask = host_a_cmd_payload.mask;
  logic [3 : 0] dbg_uart1_instr_type = host_a_cmd_payload.instr_type;

  prim_secded_inv_64_57_enc host_a_cmd_enc(.data_i(H2DCmdMaxWidth'(
                                               host_a_cmd_payload)),
                                           .data_o(host_a_cmd_ecc_full));

  assign tl_kelvin_core_i.a_user.cmd_intg = host_a_cmd_ecc;
  assign tl_kelvin_core_i.a_user.data_intg = host_a_data_selected_ecc;
  assign tl_kelvin_core_i.a_user.instr_type = prim_mubi_pkg::MuBi4False;
  assign tl_kelvin_core_i.a_mask = computed_mask;

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
              .io_tl_host_a_bits_mask(kelvin_core_i_a_mask),
              .io_tl_host_a_bits_data(tl_kelvin_core_i.a_data),
              .io_tl_host_a_bits_user_rsvd(tl_kelvin_core_i.a_user.rsvd),
              .io_tl_host_a_bits_user_instr_type(),
              .io_tl_host_a_bits_user_cmd_intg(),
              .io_tl_host_a_bits_user_data_intg(),
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
              .io_tl_device_a_ready(tl_from_kelvin_core.a_ready),
              .io_tl_device_d_valid(tl_from_kelvin_core.d_valid),
              .io_tl_device_d_bits_opcode(tl_from_kelvin_core.d_opcode),
              .io_tl_device_d_bits_param(tl_from_kelvin_core.d_param),
              .io_tl_device_d_bits_size(tl_from_kelvin_core.d_size),
              .io_tl_device_d_bits_source(tl_from_kelvin_core.d_source),
              .io_tl_device_d_bits_sink(tl_from_kelvin_core.d_sink),
              .io_tl_device_d_bits_data(tl_from_kelvin_core.d_data),
              .io_tl_device_d_bits_error(tl_from_kelvin_core.d_error),
              .io_tl_device_d_bits_user_rsp_intg(),
              .io_tl_device_d_bits_user_data_intg(),
              .io_halted(kelvin_halted),
              .io_fault(kelvin_fault),
              .io_wfi(kelvin_wfi),
              .io_irq(1'b0),
              .io_te(1'b0));

  // Ibex Core Instantiation
  rv_core_ibex #(.PipeLine(1'b1),
                 .PMPEnable(1'b0))
      i_ibex_core(.clk_i(clk_i),
                  .rst_ni(rst_ni),
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
