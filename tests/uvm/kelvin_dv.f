// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// File list for Kelvin UVM Testbench compilation

// Defines
+define+USE_GENERIC

// --- Include Directories ---
+incdir+./common
+incdir+./common/kelvin_axi_master
+incdir+./common/kelvin_axi_slave
+incdir+./common/kelvin_irq
+incdir+./common/transaction_item
+incdir+./common/rvvi
+incdir+./common/cosim
+incdir+./env
+incdir+./tests
+incdir+./tb
+incdir+./rtl

// --- Source Files ---

// DUT RTL
./rtl/RvvCoreMiniAxi.sv

// Interfaces
./common/kelvin_axi_master/kelvin_axi_master_if.sv
./common/kelvin_axi_slave/kelvin_axi_slave_if.sv
./common/kelvin_irq/kelvin_irq_if.sv

// UVM Packages
./common/transaction_item/transaction_item_pkg.sv
./common/kelvin_axi_master/kelvin_axi_master_agent_pkg.sv
./common/kelvin_axi_slave/kelvin_axi_slave_agent_pkg.sv
./common/kelvin_irq/kelvin_irq_agent_pkg.sv
./common/cosim/kelvin_rvvi_agent_pkg.sv
./common/cosim/kelvin_cosim_checker_pkg.sv
./env/kelvin_env_pkg.sv
./tests/kelvin_test_pkg.sv

// Top-Level Testbench
./tb/kelvin_tb_top.sv
