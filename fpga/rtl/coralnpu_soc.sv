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

module coralnpu_soc
    #(parameter MemInitFile = "",
      parameter int ClockFrequencyMhz = 80)
    (input clk_i,
     input rst_ni,
     input spi_clk_i,
     input spi_csb_i,
     input spi_mosi_i,
     output logic spi_miso_o,
     input prim_mubi_pkg::mubi4_t scanmode_i,
     input top_pkg::uart_sideband_i_t[1 : 0] uart_sideband_i,
     output top_pkg::uart_sideband_o_t[1 : 0] uart_sideband_o,
     output logic io_halted,
     output logic io_fault,
     input ddr_clk_i,
     input ddr_rst,
     output        io_ddr_ctrl_axi_aw_valid,
     input         io_ddr_ctrl_axi_aw_ready,
     output [31:0] io_ddr_ctrl_axi_aw_bits_addr,
     output [2:0]  io_ddr_ctrl_axi_aw_bits_prot,
     output [5:0]  io_ddr_ctrl_axi_aw_bits_id,
     output [7:0]  io_ddr_ctrl_axi_aw_bits_len,
     output [2:0]  io_ddr_ctrl_axi_aw_bits_size,
     output [1:0]  io_ddr_ctrl_axi_aw_bits_burst,
     output        io_ddr_ctrl_axi_aw_bits_lock,
     output [3:0]  io_ddr_ctrl_axi_aw_bits_cache,
                   io_ddr_ctrl_axi_aw_bits_qos,
                   io_ddr_ctrl_axi_aw_bits_region,
     output        io_ddr_ctrl_axi_w_valid,
     input         io_ddr_ctrl_axi_w_ready,
     output [31:0] io_ddr_ctrl_axi_w_bits_data,
     output        io_ddr_ctrl_axi_w_bits_last,
     output [3:0]  io_ddr_ctrl_axi_w_bits_strb,
     input         io_ddr_ctrl_axi_b_valid,
     output        io_ddr_ctrl_axi_b_ready,
     input  [5:0]  io_ddr_ctrl_axi_b_bits_id,
     input  [1:0]  io_ddr_ctrl_axi_b_bits_resp,
     output        io_ddr_ctrl_axi_ar_valid,
     input         io_ddr_ctrl_axi_ar_ready,
     output [31:0] io_ddr_ctrl_axi_ar_bits_addr,
     output [2:0]  io_ddr_ctrl_axi_ar_bits_prot,
     output [5:0]  io_ddr_ctrl_axi_ar_bits_id,
     output [7:0]  io_ddr_ctrl_axi_ar_bits_len,
     output [2:0]  io_ddr_ctrl_axi_ar_bits_size,
     output [1:0]  io_ddr_ctrl_axi_ar_bits_burst,
     output        io_ddr_ctrl_axi_ar_bits_lock,
     output [3:0]  io_ddr_ctrl_axi_ar_bits_cache,
                   io_ddr_ctrl_axi_ar_bits_qos,
                   io_ddr_ctrl_axi_ar_bits_region,
     input         io_ddr_ctrl_axi_r_valid,
     output        io_ddr_ctrl_axi_r_ready,
     input  [31:0] io_ddr_ctrl_axi_r_bits_data,
     input  [5:0]  io_ddr_ctrl_axi_r_bits_id,
     input  [1:0]  io_ddr_ctrl_axi_r_bits_resp,
     input         io_ddr_ctrl_axi_r_bits_last,
     output        io_ddr_mem_axi_aw_valid,
     input         io_ddr_mem_axi_aw_ready,
     output [31:0] io_ddr_mem_axi_aw_bits_addr,
     output [2:0]  io_ddr_mem_axi_aw_bits_prot,
     output [0:0]  io_ddr_mem_axi_aw_bits_id,
     output [7:0]  io_ddr_mem_axi_aw_bits_len,
     output [2:0]  io_ddr_mem_axi_aw_bits_size,
     output [1:0]  io_ddr_mem_axi_aw_bits_burst,
     output        io_ddr_mem_axi_aw_bits_lock,
     output [3:0]  io_ddr_mem_axi_aw_bits_cache,
                   io_ddr_mem_axi_aw_bits_qos,
                   io_ddr_mem_axi_aw_bits_region,
     output        io_ddr_mem_axi_w_valid,
     input         io_ddr_mem_axi_w_ready,
     output [255:0] io_ddr_mem_axi_w_bits_data,
     output        io_ddr_mem_axi_w_bits_last,
     output [31:0]  io_ddr_mem_axi_w_bits_strb,
     input         io_ddr_mem_axi_b_valid,
     output        io_ddr_mem_axi_b_ready,
     input  [0:0]  io_ddr_mem_axi_b_bits_id,
     input  [1:0]  io_ddr_mem_axi_b_bits_resp,
     output        io_ddr_mem_axi_ar_valid,
     input         io_ddr_mem_axi_ar_ready,
     output [31:0] io_ddr_mem_axi_ar_bits_addr,
     output [2:0]  io_ddr_mem_axi_ar_bits_prot,
     output [0:0]  io_ddr_mem_axi_ar_bits_id,
     output [7:0]  io_ddr_mem_axi_ar_bits_len,
     output [2:0]  io_ddr_mem_axi_ar_bits_size,
     output [1:0]  io_ddr_mem_axi_ar_bits_burst,
     output        io_ddr_mem_axi_ar_bits_lock,
     output [3:0]  io_ddr_mem_axi_ar_bits_cache,
                   io_ddr_mem_axi_ar_bits_qos,
                   io_ddr_mem_axi_ar_bits_region,
     input         io_ddr_mem_axi_r_valid,
     output        io_ddr_mem_axi_r_ready,
     input  [255:0] io_ddr_mem_axi_r_bits_data,
     input  [0:0]  io_ddr_mem_axi_r_bits_id,
     input  [1:0]  io_ddr_mem_axi_r_bits_resp,
     input         io_ddr_mem_axi_r_bits_last);

  import tlul_pkg::*;
  import top_pkg::*;

  coralnpu_tlul_pkg_128::tl_h2d_t tl_coralnpu_core_i;
  coralnpu_tlul_pkg_128::tl_d2h_t tl_coralnpu_core_o;
  coralnpu_tlul_pkg_128::tl_h2d_t tl_coralnpu_device_o;
  coralnpu_tlul_pkg_128::tl_d2h_t tl_coralnpu_device_i;

  coralnpu_tlul_pkg_32::tl_h2d_t tl_rom_o_32;
  coralnpu_tlul_pkg_32::tl_d2h_t tl_rom_i_32;

  tl_h2d_t tl_sram_o;
  tl_d2h_t tl_sram_i;

  tl_h2d_t tl_uart0_o;
  tl_d2h_t tl_uart0_i;

  tl_h2d_t tl_uart1_o;
  tl_d2h_t tl_uart1_i;

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
  logic [21 : 0] sram_addr;
  logic [31 : 0] sram_wdata;
  logic [3 : 0] sram_wmask;
  logic [31 : 0] sram_rdata;
  logic sram_rvalid;

  tlul_adapter_sram #(.SramAw(22),
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

  CoralNPUChiselSubsystem i_chisel_subsystem (
    .io_clk_i(clk_i),
    .io_rst_ni(rst_ni),

    // External Device Port 0: rom
    .io_external_devices_ports_0_a_valid(tl_rom_o_32.a_valid),
    .io_external_devices_ports_0_a_bits_opcode(tl_rom_o_32.a_opcode),
    .io_external_devices_ports_0_a_bits_param(tl_rom_o_32.a_param),
    .io_external_devices_ports_0_a_bits_size(tl_rom_o_32.a_size),
    .io_external_devices_ports_0_a_bits_source(tl_rom_o_32.a_source),
    .io_external_devices_ports_0_a_bits_address(tl_rom_o_32.a_address),
    .io_external_devices_ports_0_a_bits_mask(tl_rom_o_32.a_mask),
    .io_external_devices_ports_0_a_bits_data(tl_rom_o_32.a_data),
    .io_external_devices_ports_0_a_bits_user_rsvd(tl_rom_o_32.a_user.rsvd),
    .io_external_devices_ports_0_a_bits_user_instr_type(tl_rom_o_32.a_user.instr_type),
    .io_external_devices_ports_0_a_bits_user_cmd_intg(tl_rom_o_32.a_user.cmd_intg),
    .io_external_devices_ports_0_a_bits_user_data_intg(tl_rom_o_32.a_user.data_intg),
    .io_external_devices_ports_0_d_ready(tl_rom_o_32.d_ready),
    .io_external_devices_ports_0_a_ready(tl_rom_i_32.a_ready),
    .io_external_devices_ports_0_d_valid(tl_rom_i_32.d_valid),
    .io_external_devices_ports_0_d_bits_opcode(tl_rom_i_32.d_opcode),
    .io_external_devices_ports_0_d_bits_param(tl_rom_i_32.d_param),
    .io_external_devices_ports_0_d_bits_size(tl_rom_i_32.d_size),
    .io_external_devices_ports_0_d_bits_source(tl_rom_i_32.d_source),
    .io_external_devices_ports_0_d_bits_sink(tl_rom_i_32.d_sink),
    .io_external_devices_ports_0_d_bits_data(tl_rom_i_32.d_data),
    .io_external_devices_ports_0_d_bits_error(tl_rom_i_32.d_error),
    .io_external_devices_ports_0_d_bits_user_rsp_intg(tl_rom_i_32.d_user.rsp_intg),
    .io_external_devices_ports_0_d_bits_user_data_intg(tl_rom_i_32.d_user.data_intg),

    // External Device Port 1: sram
    .io_external_devices_ports_1_a_valid(tl_sram_o.a_valid),
    .io_external_devices_ports_1_a_bits_opcode(tl_sram_o.a_opcode),
    .io_external_devices_ports_1_a_bits_param(tl_sram_o.a_param),
    .io_external_devices_ports_1_a_bits_size(tl_sram_o.a_size),
    .io_external_devices_ports_1_a_bits_source(tl_sram_o.a_source),
    .io_external_devices_ports_1_a_bits_address(tl_sram_o.a_address),
    .io_external_devices_ports_1_a_bits_mask(tl_sram_o.a_mask),
    .io_external_devices_ports_1_a_bits_data(tl_sram_o.a_data),
    .io_external_devices_ports_1_a_bits_user_rsvd(tl_sram_o.a_user.rsvd),
    .io_external_devices_ports_1_a_bits_user_instr_type(tl_sram_o.a_user.instr_type),
    .io_external_devices_ports_1_a_bits_user_cmd_intg(tl_sram_o.a_user.cmd_intg),
    .io_external_devices_ports_1_a_bits_user_data_intg(tl_sram_o.a_user.data_intg),
    .io_external_devices_ports_1_d_ready(tl_sram_o.d_ready),
    .io_external_devices_ports_1_a_ready(tl_sram_i.a_ready),
    .io_external_devices_ports_1_d_valid(tl_sram_i.d_valid),
    .io_external_devices_ports_1_d_bits_opcode(tl_sram_i.d_opcode),
    .io_external_devices_ports_1_d_bits_param(tl_sram_i.d_param),
    .io_external_devices_ports_1_d_bits_size(tl_sram_i.d_size),
    .io_external_devices_ports_1_d_bits_source(tl_sram_i.d_source),
    .io_external_devices_ports_1_d_bits_sink(tl_sram_i.d_sink),
    .io_external_devices_ports_1_d_bits_data(tl_sram_i.d_data),
    .io_external_devices_ports_1_d_bits_error(tl_sram_i.d_error),
    .io_external_devices_ports_1_d_bits_user_rsp_intg(tl_sram_i.d_user.rsp_intg),
    .io_external_devices_ports_1_d_bits_user_data_intg(tl_sram_i.d_user.data_intg),

    // External Device Port 2: uart0
    .io_external_devices_ports_2_a_valid(tl_uart0_o.a_valid),
    .io_external_devices_ports_2_a_bits_opcode(tl_uart0_o.a_opcode),
    .io_external_devices_ports_2_a_bits_param(tl_uart0_o.a_param),
    .io_external_devices_ports_2_a_bits_size(tl_uart0_o.a_size),
    .io_external_devices_ports_2_a_bits_source(tl_uart0_o.a_source),
    .io_external_devices_ports_2_a_bits_address(tl_uart0_o.a_address),
    .io_external_devices_ports_2_a_bits_mask(tl_uart0_o.a_mask),
    .io_external_devices_ports_2_a_bits_data(tl_uart0_o.a_data),
    .io_external_devices_ports_2_a_bits_user_rsvd(tl_uart0_o.a_user.rsvd),
    .io_external_devices_ports_2_a_bits_user_instr_type(tl_uart0_o.a_user.instr_type),
    .io_external_devices_ports_2_a_bits_user_cmd_intg(tl_uart0_o.a_user.cmd_intg),
    .io_external_devices_ports_2_a_bits_user_data_intg(tl_uart0_o.a_user.data_intg),
    .io_external_devices_ports_2_d_ready(tl_uart0_o.d_ready),
    .io_external_devices_ports_2_a_ready(tl_uart0_i.a_ready),
    .io_external_devices_ports_2_d_valid(tl_uart0_i.d_valid),
    .io_external_devices_ports_2_d_bits_opcode(tl_uart0_i.d_opcode),
    .io_external_devices_ports_2_d_bits_param(tl_uart0_i.d_param),
    .io_external_devices_ports_2_d_bits_size(tl_uart0_i.d_size),
    .io_external_devices_ports_2_d_bits_source(tl_uart0_i.d_source),
    .io_external_devices_ports_2_d_bits_sink(tl_uart0_i.d_sink),
    .io_external_devices_ports_2_d_bits_data(tl_uart0_i.d_data),
    .io_external_devices_ports_2_d_bits_error(tl_uart0_i.d_error),
    .io_external_devices_ports_2_d_bits_user_rsp_intg(tl_uart0_i.d_user.rsp_intg),
    .io_external_devices_ports_2_d_bits_user_data_intg(tl_uart0_i.d_user.data_intg),

    // External Device Port 3: uart1
    .io_external_devices_ports_3_a_valid(tl_uart1_o.a_valid),
    .io_external_devices_ports_3_a_bits_opcode(tl_uart1_o.a_opcode),
    .io_external_devices_ports_3_a_bits_param(tl_uart1_o.a_param),
    .io_external_devices_ports_3_a_bits_size(tl_uart1_o.a_size),
    .io_external_devices_ports_3_a_bits_source(tl_uart1_o.a_source),
    .io_external_devices_ports_3_a_bits_address(tl_uart1_o.a_address),
    .io_external_devices_ports_3_a_bits_mask(tl_uart1_o.a_mask),
    .io_external_devices_ports_3_a_bits_data(tl_uart1_o.a_data),
    .io_external_devices_ports_3_a_bits_user_rsvd(tl_uart1_o.a_user.rsvd),
    .io_external_devices_ports_3_a_bits_user_instr_type(tl_uart1_o.a_user.instr_type),
    .io_external_devices_ports_3_a_bits_user_cmd_intg(tl_uart1_o.a_user.cmd_intg),
    .io_external_devices_ports_3_a_bits_user_data_intg(tl_uart1_o.a_user.data_intg),
    .io_external_devices_ports_3_d_ready(tl_uart1_o.d_ready),
    .io_external_devices_ports_3_a_ready(tl_uart1_i.a_ready),
    .io_external_devices_ports_3_d_valid(tl_uart1_i.d_valid),
    .io_external_devices_ports_3_d_bits_opcode(tl_uart1_i.d_opcode),
    .io_external_devices_ports_3_d_bits_param(tl_uart1_i.d_param),
    .io_external_devices_ports_3_d_bits_size(tl_uart1_i.d_size),
    .io_external_devices_ports_3_d_bits_source(tl_uart1_i.d_source),
    .io_external_devices_ports_3_d_bits_sink(tl_uart1_i.d_sink),
    .io_external_devices_ports_3_d_bits_data(tl_uart1_i.d_data),
    .io_external_devices_ports_3_d_bits_error(tl_uart1_i.d_error),
    .io_external_devices_ports_3_d_bits_user_rsp_intg(tl_uart1_i.d_user.rsp_intg),
    .io_external_devices_ports_3_d_bits_user_data_intg(tl_uart1_i.d_user.data_intg),

    // Peripheral Ports (indexed based on SoCChiselConfig order)
    .io_external_ports_0(io_halted),      // halted
    .io_external_ports_1(io_fault),       // fault
    .io_external_ports_2(),               // wfi (unused)
    .io_external_ports_3(1'b0),           // irq (tied off)
    .io_external_ports_4(1'b0),           // te (tied off)
    .io_external_ports_5(spi_clk_i),      // spi_clk
    .io_external_ports_6(spi_csb_i),      // spi_csb
    .io_external_ports_7(spi_mosi_i),     // spi_mosi
    .io_external_ports_8(spi_miso_o),      // spi_miso

    .io_async_ports_devices_clocks_0(ddr_clk_i),
    .io_async_ports_devices_resets_0(ddr_rst),

    .io_ddr_ctrl_axi_write_addr_valid(io_ddr_ctrl_axi_aw_valid),
    .io_ddr_ctrl_axi_write_addr_ready(io_ddr_ctrl_axi_aw_ready),
    .io_ddr_ctrl_axi_write_addr_bits_addr(io_ddr_ctrl_axi_aw_bits_addr),
    .io_ddr_ctrl_axi_write_addr_bits_prot(io_ddr_ctrl_axi_aw_bits_prot),
    .io_ddr_ctrl_axi_write_addr_bits_id(io_ddr_ctrl_axi_aw_bits_id),
    .io_ddr_ctrl_axi_write_addr_bits_len(io_ddr_ctrl_axi_aw_bits_len),
    .io_ddr_ctrl_axi_write_addr_bits_size(io_ddr_ctrl_axi_aw_bits_size),
    .io_ddr_ctrl_axi_write_addr_bits_burst(io_ddr_ctrl_axi_aw_bits_burst),
    .io_ddr_ctrl_axi_write_addr_bits_lock(io_ddr_ctrl_axi_aw_bits_lock),
    .io_ddr_ctrl_axi_write_addr_bits_cache(io_ddr_ctrl_axi_aw_bits_cache),
    .io_ddr_ctrl_axi_write_addr_bits_qos(io_ddr_ctrl_axi_aw_bits_qos),
    .io_ddr_ctrl_axi_write_addr_bits_region(io_ddr_ctrl_axi_aw_bits_region),
    .io_ddr_ctrl_axi_write_data_valid(io_ddr_ctrl_axi_w_valid),
    .io_ddr_ctrl_axi_write_data_ready(io_ddr_ctrl_axi_w_ready),
    .io_ddr_ctrl_axi_write_data_bits_data(io_ddr_ctrl_axi_w_bits_data),
    .io_ddr_ctrl_axi_write_data_bits_last(io_ddr_ctrl_axi_w_bits_last),
    .io_ddr_ctrl_axi_write_data_bits_strb(io_ddr_ctrl_axi_w_bits_strb),
    .io_ddr_ctrl_axi_write_resp_valid(io_ddr_ctrl_axi_b_valid),
    .io_ddr_ctrl_axi_write_resp_ready(io_ddr_ctrl_axi_b_ready),
    .io_ddr_ctrl_axi_write_resp_bits_id(io_ddr_ctrl_axi_b_bits_id),
    .io_ddr_ctrl_axi_write_resp_bits_resp(io_ddr_ctrl_axi_b_bits_resp),
    .io_ddr_ctrl_axi_read_addr_valid(io_ddr_ctrl_axi_ar_valid),
    .io_ddr_ctrl_axi_read_addr_ready(io_ddr_ctrl_axi_ar_ready),
    .io_ddr_ctrl_axi_read_addr_bits_addr(io_ddr_ctrl_axi_ar_bits_addr),
    .io_ddr_ctrl_axi_read_addr_bits_prot(io_ddr_ctrl_axi_ar_bits_prot),
    .io_ddr_ctrl_axi_read_addr_bits_id(io_ddr_ctrl_axi_ar_bits_id),
    .io_ddr_ctrl_axi_read_addr_bits_len(io_ddr_ctrl_axi_ar_bits_len),
    .io_ddr_ctrl_axi_read_addr_bits_size(io_ddr_ctrl_axi_ar_bits_size),
    .io_ddr_ctrl_axi_read_addr_bits_burst(io_ddr_ctrl_axi_ar_bits_burst),
    .io_ddr_ctrl_axi_read_addr_bits_lock(io_ddr_ctrl_axi_ar_bits_lock),
    .io_ddr_ctrl_axi_read_addr_bits_cache(io_ddr_ctrl_axi_ar_bits_cache),
    .io_ddr_ctrl_axi_read_addr_bits_qos(io_ddr_ctrl_axi_ar_bits_qos),
    .io_ddr_ctrl_axi_read_addr_bits_region(io_ddr_ctrl_axi_ar_bits_region),
    .io_ddr_ctrl_axi_read_data_valid(io_ddr_ctrl_axi_r_valid),
    .io_ddr_ctrl_axi_read_data_ready(io_ddr_ctrl_axi_r_ready),
    .io_ddr_ctrl_axi_read_data_bits_data(io_ddr_ctrl_axi_r_bits_data),
    .io_ddr_ctrl_axi_read_data_bits_id(io_ddr_ctrl_axi_r_bits_id),
    .io_ddr_ctrl_axi_read_data_bits_resp(io_ddr_ctrl_axi_r_bits_resp),
    .io_ddr_ctrl_axi_read_data_bits_last(io_ddr_ctrl_axi_r_bits_last),
    .io_ddr_mem_axi_write_addr_valid(io_ddr_mem_axi_aw_valid),
    .io_ddr_mem_axi_write_addr_ready(io_ddr_mem_axi_aw_ready),
    .io_ddr_mem_axi_write_addr_bits_addr(io_ddr_mem_axi_aw_bits_addr),
    .io_ddr_mem_axi_write_addr_bits_prot(io_ddr_mem_axi_aw_bits_prot),
    .io_ddr_mem_axi_write_addr_bits_id(io_ddr_mem_axi_aw_bits_id),
    .io_ddr_mem_axi_write_addr_bits_len(io_ddr_mem_axi_aw_bits_len),
    .io_ddr_mem_axi_write_addr_bits_size(io_ddr_mem_axi_aw_bits_size),
    .io_ddr_mem_axi_write_addr_bits_burst(io_ddr_mem_axi_aw_bits_burst),
    .io_ddr_mem_axi_write_addr_bits_lock(io_ddr_mem_axi_aw_bits_lock),
    .io_ddr_mem_axi_write_addr_bits_cache(io_ddr_mem_axi_aw_bits_cache),
    .io_ddr_mem_axi_write_addr_bits_qos(io_ddr_mem_axi_aw_bits_qos),
    .io_ddr_mem_axi_write_addr_bits_region(io_ddr_mem_axi_aw_bits_region),
    .io_ddr_mem_axi_write_data_valid(io_ddr_mem_axi_w_valid),
    .io_ddr_mem_axi_write_data_ready(io_ddr_mem_axi_w_ready),
    .io_ddr_mem_axi_write_data_bits_data(io_ddr_mem_axi_w_bits_data),
    .io_ddr_mem_axi_write_data_bits_last(io_ddr_mem_axi_w_bits_last),
    .io_ddr_mem_axi_write_data_bits_strb(io_ddr_mem_axi_w_bits_strb),
    .io_ddr_mem_axi_write_resp_valid(io_ddr_mem_axi_b_valid),
    .io_ddr_mem_axi_write_resp_ready(io_ddr_mem_axi_b_ready),
    .io_ddr_mem_axi_write_resp_bits_id(io_ddr_mem_axi_b_bits_id),
    .io_ddr_mem_axi_write_resp_bits_resp(io_ddr_mem_axi_b_bits_resp),
    .io_ddr_mem_axi_read_addr_valid(io_ddr_mem_axi_ar_valid),
    .io_ddr_mem_axi_read_addr_ready(io_ddr_mem_axi_ar_ready),
    .io_ddr_mem_axi_read_addr_bits_addr(io_ddr_mem_axi_ar_bits_addr),
    .io_ddr_mem_axi_read_addr_bits_prot(io_ddr_mem_axi_ar_bits_prot),
    .io_ddr_mem_axi_read_addr_bits_id(io_ddr_mem_axi_ar_bits_id),
    .io_ddr_mem_axi_read_addr_bits_len(io_ddr_mem_axi_ar_bits_len),
    .io_ddr_mem_axi_read_addr_bits_size(io_ddr_mem_axi_ar_bits_size),
    .io_ddr_mem_axi_read_addr_bits_burst(io_ddr_mem_axi_ar_bits_burst),
    .io_ddr_mem_axi_read_addr_bits_lock(io_ddr_mem_axi_ar_bits_lock),
    .io_ddr_mem_axi_read_addr_bits_cache(io_ddr_mem_axi_ar_bits_cache),
    .io_ddr_mem_axi_read_addr_bits_qos(io_ddr_mem_axi_ar_bits_qos),
    .io_ddr_mem_axi_read_addr_bits_region(io_ddr_mem_axi_ar_bits_region),
    .io_ddr_mem_axi_read_data_valid(io_ddr_mem_axi_r_valid),
    .io_ddr_mem_axi_read_data_ready(io_ddr_mem_axi_r_ready),
    .io_ddr_mem_axi_read_data_bits_data(io_ddr_mem_axi_r_bits_data),
    .io_ddr_mem_axi_read_data_bits_id(io_ddr_mem_axi_r_bits_id),
    .io_ddr_mem_axi_read_data_bits_resp(io_ddr_mem_axi_r_bits_resp),
    .io_ddr_mem_axi_read_data_bits_last(io_ddr_mem_axi_r_bits_last)
  );
endmodule
