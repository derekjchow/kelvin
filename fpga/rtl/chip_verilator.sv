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

module chip_verilator
    #(parameter MemInitFile = "",
      parameter int ClockFrequencyMhz = 80)
    (input clk_i,
     input rst_ni,
     input spi_clk_i,
     input prim_mubi_pkg::mubi4_t scanmode_i,
     input top_pkg::uart_sideband_i_t[1 : 0] uart_sideband_i,
     output top_pkg::uart_sideband_o_t[1 : 0] uart_sideband_o);

  logic uart0_rx;
  logic uart0_tx;

  uartdpi #(.BAUD(115200),
            .FREQ(ClockFrequencyMhz * 1_000_000),
            .NAME("uart0"),
            .EXIT_STRING("EXIT"))
      i_uartdpi0(.clk_i(clk_i),
                 .rst_ni(rst_ni),
                 .active(1'b1),
                 .tx_o(uart0_rx),
                 .rx_i(uart0_tx));

  logic uart1_rx;
  logic uart1_tx;

  uartdpi #(.BAUD(115200),
            .FREQ(ClockFrequencyMhz * 1_000_000),
            .NAME("uart1"),
            .EXIT_STRING("EXIT"))
      i_uartdpi1(.clk_i(clk_i),
                 .rst_ni(rst_ni),
                 .active(1'b1),
                 .tx_o(uart1_rx),
                 .rx_i(uart1_tx));

  kelvin_soc #(.MemInitFile(MemInitFile),
               .ClockFrequencyMhz(ClockFrequencyMhz))
      i_kelvin_soc(.clk_i(clk_i),
                   .rst_ni(rst_ni),
                   .ibex_clk_i(ibex_clk_i),
                   .ibex_rst_ni(ibex_rst_ni),
                   .spi_clk_i(spi_clk_i),
                   .scanmode_i(scanmode_i),
                   .uart_sideband_i(
                       '{'{cio_rx: uart0_rx}, '{cio_rx: uart1_rx}}),
                   .uart_sideband_o(uart_sideband_o),
                   .io_halted(),
                   .io_fault());

  assign uart0_tx = uart_sideband_o[0].cio_tx;
  assign uart1_tx = uart_sideband_o[1].cio_tx;

  // Clock divider for Ibex clock.
  logic [1:0] clk_divider;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      clk_divider <= 2'b0;
    end else begin
      clk_divider <= clk_divider + 1;
    end
  end
  logic ibex_clk_i;
  assign ibex_clk_i = clk_divider[1];

  // Reset synchronizer for Ibex reset.
  logic ibex_rst_ni;
  logic rst_n_sync;
  always_ff @(posedge ibex_clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rst_n_sync <= 1'b0;
      ibex_rst_ni <= 1'b0;
    end else begin
      rst_n_sync <= 1'b1;
      ibex_rst_ni <= rst_n_sync;
    end
  end
endmodule
