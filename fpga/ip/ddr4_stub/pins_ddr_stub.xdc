# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
