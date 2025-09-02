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

module chip_nexus
    #(parameter MemInitFile = "",
      parameter int ClockFrequencyMhz = 80)
    (input clk_p_i,
     input clk_n_i,
     input rst_ni,
     input spi_clk_i,
     input spi_csb_i,
     input spi_mosi_i,
     output logic spi_miso_o,
     output [1 : 0] uart_tx_o,
     input [1 : 0] uart_rx_i,
     output logic io_halted,
     output logic io_fault,
     output logic io_halted_n,
     output logic io_fault_n,
     output logic spi_clk_probe_o,
     output logic spi_csb_probe_o,
     output logic spi_mosi_probe_o,
     output logic spi_miso_probe_o);

  logic clk;
  logic rst_n;
  logic clk_48MHz;
  logic clk_aon;

  assign spi_clk_probe_o = spi_clk_i;
  assign spi_csb_probe_o = spi_csb_i;
  assign spi_mosi_probe_o = spi_mosi_i;
  assign spi_miso_probe_o = spi_miso_o;

  top_pkg::uart_sideband_i_t[1 : 0] uart_sideband_i;
  top_pkg::uart_sideband_o_t[1 : 0] uart_sideband_o;

  assign uart_sideband_i[0].cio_rx = uart_rx_i[0];
  assign uart_sideband_i[1].cio_rx = uart_rx_i[1];
  assign uart_tx_o[0] = uart_sideband_o[0].cio_tx;
  assign uart_tx_o[1] = uart_sideband_o[1].cio_tx;

  assign io_halted_n = ~io_halted;
  assign io_fault_n = ~io_fault;

  clkgen_wrapper #(.ClockFrequencyMhz(ClockFrequencyMhz))
      i_clkgen(.clk_p_i(clk_p_i),
               .clk_n_i(clk_n_i),
               .rst_ni(rst_ni),
               .srst_ni(rst_ni),
               .clk_main_o(clk),
               .clk_48MHz_o(clk_48MHz),
               .clk_aon_o(clk_aon),
               .rst_no(rst_n));

  kelvin_soc i_kelvin_soc (
    .clk_i(clk),
    .rst_ni(rst_n),
    .spi_clk_i(spi_clk_i),
    .spi_csb_i(spi_csb_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_miso_o(spi_miso_o),
    .scanmode_i('0),
    .uart_sideband_i(uart_sideband_i),
    .uart_sideband_o(uart_sideband_o),
    .io_halted(io_halted),
    .io_fault(io_fault)
  );

endmodule
