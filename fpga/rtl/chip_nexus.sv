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
     output [1 : 0] uart_tx_o,
     input [1 : 0] uart_rx_i,
     output logic io_halted,
     output logic io_fault,
     output logic io_halted_n,
     output logic io_fault_n);

  logic clk;
  logic rst_n;
  logic clk_ibex;
  logic rst_ibex_n;
  logic clk_48MHz;
  logic clk_aon;

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
               .clk_ibex_o(clk_ibex),
               .rst_no(rst_n));

  // Reset synchronizer for Ibex reset.
  logic rst_n_sync;
  always_ff @(posedge clk_ibex or negedge rst_n) begin
    if (!rst_n) begin
      rst_n_sync <= 1'b0;
      rst_ibex_n <= 1'b0;
    end else begin
      rst_n_sync <= 1'b1;
      rst_ibex_n <= rst_n_sync;
    end
  end

  kelvin_soc #(.MemInitFile(MemInitFile),
               .ClockFrequencyMhz(ClockFrequencyMhz))
      i_kelvin_soc(.clk_i(clk),
                   .rst_ni(rst_n),
                   .ibex_clk_i(clk_ibex),
                   .ibex_rst_ni(rst_ibex_n),
                   .spi_clk_i(spi_clk_i),
                   .scanmode_i(prim_mubi_pkg::MuBi4False),
                   .uart_sideband_i(uart_sideband_i),
                   .uart_sideband_o(uart_sideband_o),
                   .io_halted(io_halted),
                   .io_fault(io_fault));
endmodule
