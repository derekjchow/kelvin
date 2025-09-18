// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clkgen_wrapper
    #(parameter int ClockFrequencyMhz = 80)
    (input clk_p_i,
     input clk_n_i,
     input rst_ni,
     input srst_ni,
     output clk_main_o,
     output clk_48MHz_o,
     output clk_aon_o,
     output rst_no,
     output locked_o);

  clkgen_xilultrascaleplus #(.ClockFrequencyMhz(ClockFrequencyMhz))
      i_clkgen(.clk_i(clk_p_i),
               .clk_n_i(clk_n_i),
               .rst_ni(rst_ni),
               .srst_ni(srst_ni),
               .clk_main_o(clk_main_o),
               .clk_48MHz_o(clk_48MHz_o),
               .clk_aon_o(clk_aon_o),
               .rst_no(rst_no),
               .locked_o(locked_o));
endmodule