# Clock Signal
create_clock -period 10.00 -name sys_clk_pin -waveform {0 5} [get_ports clk_p_i]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD DIFF_SSTL18_I } [get_ports { clk_p_i }];
set_property -dict { PACKAGE_PIN T13 IOSTANDARD DIFF_SSTL18_I } [get_ports { clk_n_i }];

# Generated Clocks
create_generated_clock -name clk_main [get_pin i_clkgen/i_clkgen/pll/CLKOUT0]
create_generated_clock -name clk_48MHz [get_pin i_clkgen/i_clkgen/pll/CLKOUT1]
create_generated_clock -name clk_aon [get_pin i_clkgen/i_clkgen/pll/CLKOUT4]

# Reset
set_property -dict { PACKAGE_PIN AR19 IOSTANDARD LVCMOS18 } [get_ports { rst_ni }];

# SPI
create_clock -period 83.333 -name spi_clk_i -waveform {0 41.667} [get_ports spi_clk_i]
set_property -dict { PACKAGE_PIN AV19 IOSTANDARD LVCMOS18 } [get_ports { spi_clk_i }];
set_property -dict { PACKAGE_PIN AW20 IOSTANDARD LVCMOS18 } [get_ports { spi_csb_i }];
set_property -dict { PACKAGE_PIN AV20 IOSTANDARD LVCMOS18 } [get_ports { spi_mosi_i }];
set_property -dict { PACKAGE_PIN AV18 IOSTANDARD LVCMOS18 } [get_ports { spi_miso_o }];

# UART0
set_property -dict { PACKAGE_PIN BF20 IOSTANDARD LVCMOS18 } [get_ports { uart_tx_o[0] }];
set_property -dict { PACKAGE_PIN BD20 IOSTANDARD LVCMOS18 } [get_ports { uart_rx_i[0] }];

# UART1
set_property -dict { PACKAGE_PIN R23 IOSTANDARD LVCMOS18 } [get_ports { uart_tx_o[1] }];
set_property -dict { PACKAGE_PIN T23 IOSTANDARD LVCMOS18 } [get_ports { uart_rx_i[1] }];

# LEDs
set_property -dict { PACKAGE_PIN T31 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_halted }];
set_property -dict { PACKAGE_PIN P31 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_fault }];
set_property -dict { PACKAGE_PIN N37 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_halted_n }];
set_property -dict { PACKAGE_PIN M38 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_fault_n }];

# Asynchronous Clock Groups
set_clock_groups -asynchronous \
  -group {clk_main clk_48MHz clk_aon} \
  -group {spi_clk_i}

# SPI Probe Outputs (PMOD3)
set_property -dict { PACKAGE_PIN AU40 IOSTANDARD LVCMOS18 } [get_ports { spi_clk_probe_o }];
set_property -dict { PACKAGE_PIN AV40 IOSTANDARD LVCMOS18 } [get_ports { spi_csb_probe_o }];
set_property -dict { PACKAGE_PIN AW40 IOSTANDARD LVCMOS18 } [get_ports { spi_mosi_probe_o }];
set_property -dict { PACKAGE_PIN AY39 IOSTANDARD LVCMOS18 } [get_ports { spi_miso_probe_o }];
