# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Makefile for Kelvin UVM Testbench

# --- User Configuration ---
# Tool Configuration
VCS = vcs

# Directories
RTL_DIR = ./rtl
COMMON_DIR = ./common
TB_DIR = ./tb
ENV_DIR = ./env
TESTS_DIR = ./tests
BIN_DIR = ./bin
SIM_DIR = ./sim_work
LOG_DIR = $(SIM_DIR)/logs
WAVE_DIR = $(SIM_DIR)/waves

# Source Files
DUT_RTL = $(RTL_DIR)/RvvCoreMiniVerificationAxi.sv
IF_FILES = $(COMMON_DIR)/kelvin_axi_master/kelvin_axi_master_if.sv \
           $(COMMON_DIR)/kelvin_axi_slave/kelvin_axi_slave_if.sv \
           $(COMMON_DIR)/kelvin_irq/kelvin_irq_if.sv
TRANS_PKG_FILE = $(COMMON_DIR)/transaction_item/transaction_item_pkg.sv
AXI_MASTER_AGENT_PKG = $(COMMON_DIR)/kelvin_axi_master/kelvin_axi_master_agent_pkg.sv
AXI_SLAVE_AGENT_PKG = $(COMMON_DIR)/kelvin_axi_slave/kelvin_axi_slave_agent_pkg.sv
IRQ_AGENT_PKG = $(COMMON_DIR)/kelvin_irq/kelvin_irq_agent_pkg.sv
ENV_PKG = $(ENV_DIR)/kelvin_env_pkg.sv
TEST_PKG = $(TESTS_DIR)/kelvin_test_pkg.sv
TB_TOP_FILE = $(TB_DIR)/kelvin_tb_top.sv

# File List for VCS -f option (Assumed to exist and be checked in)
FILE_LIST = ./kelvin_dv.f

# Simulation Settings
SIM_EXEC = $(SIM_DIR)/simv
UVM_TESTNAME ?= kelvin_base_test
TEST_BINARY ?= $(BIN_DIR)/program.bin
UVM_VERBOSITY ?= UVM_MEDIUM
TEST_TIMEOUT_NS ?= 20000
PLUSARGS = +UVM_TESTNAME=$(UVM_TESTNAME) +TEST_BINARY=$(TEST_BINARY) +UVM_VERBOSITY=$(UVM_VERBOSITY) +TEST_TIMEOUT=$(TEST_TIMEOUT_NS)

# Waveform Dumping
DUMP_WAVES = 1
WAVE_FILE = $(WAVE_DIR)/$(UVM_TESTNAME).fsdb

# --- VCS Options ---
# Base compile options
VCS_COMPILE_OPTS = \
	-full64 \
	-sverilog \
	+define+UVM_NO_DEPRECATED \
	-ntb_opts uvm-1.2 \
	-debug_access+all \
	-kdb \
	-timescale=1ns/1ps \
	-o $(SIM_EXEC)

# Base run options
VCS_RUN_OPTS = \
	$(PLUSARGS)

# Add define to COMPILE options for waveform dumping
ifeq ($(DUMP_WAVES),1)
VCS_COMPILE_OPTS += +define+DUMP_WAVES
VCS_RUN_OPTS += +fsdb+all \
                +fsdbfile+$(WAVE_FILE)
endif

# --- Targets ---

.PHONY: all compile run clean dirs help

# Default target
all: run

# Create necessary directories
dirs:
	@mkdir -p $(SIM_DIR) $(LOG_DIR) $(WAVE_DIR) $(BIN_DIR)

# Compile the design
compile: dirs
	@echo "--- Compiling with VCS ---"
	$(VCS) $(VCS_COMPILE_OPTS) -l $(LOG_DIR)/compile.log -f $(FILE_LIST)
	@echo "--- Compilation Finished ---"

# Run the simulation
run: compile
	@echo "--- Running Simulation ---"
	@echo "Test:      $(UVM_TESTNAME)"
	@echo "Binary:    $(TEST_BINARY)"
	@echo "Verbosity: $(UVM_VERBOSITY)"
	@echo "Timeout:   $(TEST_TIMEOUT_NS) ns"
	@echo "Plusargs:  $(PLUSARGS)"
	@echo "Log File:  $(LOG_DIR)/$(UVM_TESTNAME).log"
ifeq ($(DUMP_WAVES),1)
	@echo "Wave File: $(WAVE_FILE)"
endif
	./$(SIM_EXEC) $(VCS_RUN_OPTS) -l $(LOG_DIR)/$(UVM_TESTNAME).log
	@echo "--- Simulation Finished ---"

# Clean up simulation files
clean:
	@echo "--- Cleaning Simulation Files ---"
	rm -rf $(SIM_DIR) simv* csrc* *.log* *.key *.vpd *.fsdb ucli.key DVEfiles/ verdiLog/ novas.*

# --- Help ---
help:
	@echo "Makefile Targets:"
	@echo "  make compile       : Compiles the DUT and testbench (using $(FILE_LIST))"
	@echo "  make run           : Compiles (if needed) and runs the simulation"
	@echo "                     :   Override defaults: make run UVM_TESTNAME=<test> TEST_BINARY=<path> UVM_VERBOSITY=<level>"
	@echo "  make clean         : Removes generated simulation files"
	@echo "  make dirs          : Creates simulation directories"
	@echo "  make help          : Shows this help message"
