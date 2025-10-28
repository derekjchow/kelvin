# Clock Signal
create_clock -period 10.00 -name sys_clk_pin -waveform {0 5} [get_ports clk_p_i]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD DIFF_SSTL18_I } [get_ports { clk_p_i }];
set_property -dict { PACKAGE_PIN T13 IOSTANDARD DIFF_SSTL18_I } [get_ports { clk_n_i }];
create_clock -period 6.4 -name c0_sys_clk_p [get_ports c0_sys_clk_p]

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
set_property -dict { PACKAGE_PIN N37 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { ddr_cal_complete_o }];
set_property -dict { PACKAGE_PIN M38 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_ddr_mem_axi_aw_ready }];
set_property -dict { PACKAGE_PIN L38 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { io_ddr_mem_axi_ar_ready }];
set_property -dict { PACKAGE_PIN L36 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { ddr_ui_clk }];
set_property -dict { PACKAGE_PIN K36 DRIVE 8 IOSTANDARD LVCMOS12 } [get_ports { ddr_ui_clk_sync_rst }];

# Asynchronous Clock Groups
# Define all primary, asynchronous clocks
set_clock_groups -asynchronous \
  -group [get_clocks -include_generated_clocks sys_clk_pin] \
  -group [get_clocks -include_generated_clocks c0_sys_clk_p] \
  -group [get_clocks spi_clk_i]

# SPI Probe Outputs (PMOD3)
set_property -dict { PACKAGE_PIN AU40 IOSTANDARD LVCMOS18 } [get_ports { spi_clk_probe_o }];
set_property -dict { PACKAGE_PIN AV40 IOSTANDARD LVCMOS18 } [get_ports { spi_csb_probe_o }];
set_property -dict { PACKAGE_PIN AW40 IOSTANDARD LVCMOS18 } [get_ports { spi_mosi_probe_o }];
set_property -dict { PACKAGE_PIN AY39 IOSTANDARD LVCMOS18 } [get_ports { spi_miso_probe_o }];

# Definitions for ddr4_stub
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_adr[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_ba[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_bg[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_ck_c[0]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_ck_t[0]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_cke[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_cs_n[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_odt[*]"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_act_n"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_parity"]
set_property IOSTANDARD SSTL12_DCI [get_ports "c0_ddr4_reset_n"]

set_property PACKAGE_PIN R24                [get_ports {c0_ddr4_adr[0]}]
set_property PACKAGE_PIN M28                [get_ports {c0_ddr4_adr[13]}]
set_property PACKAGE_PIN L26                [get_ports {c0_ddr4_adr[14]}]
set_property PACKAGE_PIN L28                [get_ports {c0_ddr4_adr[15]}]
set_property PACKAGE_PIN K28                [get_ports {c0_ddr4_adr[1]}]
set_property PACKAGE_PIN K26                [get_ports {c0_ddr4_adr[16]}]
set_property PACKAGE_PIN J27                [get_ports {c0_ddr4_adr[10]}]
set_property PACKAGE_PIN F28                [get_ports {c0_ddr4_adr[2]}]
set_property PACKAGE_PIN E28                [get_ports {c0_ddr4_adr[3]}]
set_property PACKAGE_PIN E26                [get_ports {c0_ddr4_adr[12]}]
set_property PACKAGE_PIN E27                [get_ports {c0_ddr4_adr[4]}]
set_property PACKAGE_PIN D27                [get_ports {c0_ddr4_adr[6]}]
set_property PACKAGE_PIN C28                [get_ports {c0_ddr4_adr[5]}]
set_property PACKAGE_PIN B28                [get_ports {c0_ddr4_adr[8]}]
set_property PACKAGE_PIN A28                [get_ports {c0_ddr4_adr[7]}]
set_property PACKAGE_PIN C27                [get_ports {c0_ddr4_adr[11]}]
set_property PACKAGE_PIN B27                [get_ports {c0_ddr4_adr[9]}]
set_property PACKAGE_PIN J26                [get_ports {c0_ddr4_ba[0]}]
set_property PACKAGE_PIN T24                [get_ports {c0_ddr4_ba[1]}]
set_property PACKAGE_PIN B26                [get_ports {c0_ddr4_bg[1]}]
set_property PACKAGE_PIN A26                [get_ports {c0_ddr4_bg[0]}]
set_property PACKAGE_PIN G28                [get_ports {c0_ddr4_ck_c[0]}]
set_property PACKAGE_PIN H28                [get_ports {c0_ddr4_ck_t[0]}]
set_property PACKAGE_PIN F25                [get_ports {c0_ddr4_cke[1]}]
set_property PACKAGE_PIN B25                [get_ports {c0_ddr4_cke[0]}]
set_property PACKAGE_PIN L25                [get_ports {c0_ddr4_cs_n[0]}]
set_property PACKAGE_PIN P27                [get_ports {c0_ddr4_cs_n[1]}]
set_property PACKAGE_PIN M25                [get_ports {c0_ddr4_odt[0]}]
set_property PACKAGE_PIN T26                [get_ports {c0_ddr4_odt[1]}]
set_property PACKAGE_PIN C25                [get_ports c0_ddr4_act_n]
set_property PACKAGE_PIN L24                [get_ports {c0_ddr4_parity}]
set_property PACKAGE_PIN G25                [get_ports c0_ddr4_reset_n]
