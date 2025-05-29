# Kelvin UVM Testbench

This document describes the structure and usage of the UVM testbench for verifying the `RvvCoreMiniVerificationAxi` DUT.

## Overview

This testbench provides a basic UVM environment to:
* Instantiate the `RvvCoreMiniVerificationAxi` DUT.
* Connect AXI Master, AXI Slave, and IRQ interfaces to the DUT.
* Provide basic stimulus generation via UVM sequences.
* Include a simple reactive AXI Slave model.
* Load a binary file into the DUT's memory using backdoor access.
* Kick off the DUT execution using initial AXI writes.
* Check for basic test completion via DUT status signals (`halted`, `fault`) or a timeout.

## Prerequisites

* **Synopsys VCS:** This testbench is configured to run with Synopsys VCS.
* **UVM:** VCS needs to be configured with UVM 1.2 support enabled.
* **Kelvin Hardware Repository:** Access to the repository containing the `RvvCoreMiniVerificationAxi` source code is required to generate the DUT Verilog and the test binary.
* **Bazel:** The build system used to generate the Verilog from the Chisel source in the Kelvin HW repository.
* **RISC-V Toolchain:** A RISC-V toolchain (specifically `llvm-objcopy-17` or similar) compatible with the Kelvin project is needed to generate the `.bin` file.

## Generating the DUT (RvvCoreMiniVerificationAxi.sv)

The Verilog file for the DUT needs to be generated from the Chisel source code located in the Kelvin hardware repository.

1.  Navigate to the root directory of your Kelvin HW repository clone:
    ```bash
    cd /path/to/your/kelvin/hw/repo
    ```
2.  Run the Bazel build command to emit the Verilog:
    ```bash
    bazel build //hdl/chisel/src/kelvin:rvv_core_mini_verification_axi_cc_library_emit_verilog
    ```
3.  The Verilog file will be generated at:
    `bazel-bin/hdl/chisel/src/kelvin/RvvCoreMiniVerificationAxi.sv`
4.  Copy this generated `RvvCoreMiniVerificationAxi.sv` file to the `rtl/` directory within this testbench structure.

## Generating the Test Binary (program.bin)

The test program run by the DUT needs to be compiled and converted to a flat binary format.

1.  Navigate to the Kelvin HW repository root:
    ```bash
    cd /path/to/your/kelvin/hw/repo
    ```
2.  Navigate to the example test directory:
    ```bash
    cd tests/cocotb/tutorial
    ```
    *(Note: Adapt this path if using a different test program)*
3.  Compile the test program (this typically generates `program.elf`):
    ```bash
    make
    ```
4.  Convert the ELF file to a binary file using `llvm-objcopy-17`, extracting only the `.text` section. **Note:** Ensure the path to `llvm-objcopy-17` is correct for your environment.
    ```bash
    llvm-objcopy-17 -O binary --only-section=.text -S program.elf program.bin
    ```
5.  The `program.bin` file is generated in the current directory (`tests/cocotb/tutorial`).
6.  Copy this `program.bin` file to the `bin/` directory of this UVM testbench structure (or update the `TEST_BINARY` path in the `Makefile` or run command).

## Directory Structure

The testbench follows a standard UVM directory structure:

```
.
├── common/                # Common components
│   ├── kelvin_axi_master/ # Files related to the TB acting as AXI Master
│   │   ├── kelvin_axi_master_if.sv
│   │   └── kelvin_axi_master_agent_pkg.sv
│   ├── kelvin_axi_slave/  # Files related to the TB acting as AXI Slave
│   │   ├── kelvin_axi_slave_if.sv
│   │   └── kelvin_axi_slave_agent_pkg.sv
│   ├── kelvin_irq/        # Files related to the IRQ/Control interface
│   │   ├── kelvin_irq_if.sv
│   │   └── kelvin_irq_agent_pkg.sv
│   └── transaction_item/  # Transaction item definitions
│       └── transaction_item_pkg.sv
├── env/                   # UVM Environment definition
│   └── kelvin_env_pkg.sv
├── rtl/                   # DUT RTL source file(s)
│   └── RvvCoreMiniVerificationAxi.sv     # (Needs to be generated and copied here)
├── tb/                    # Top-level testbench module
│   └── kelvin_tb_top.sv
├── tests/                 # UVM Tests and Sequences
│   └── kelvin_test_pkg.sv
├── Makefile               # Makefile for compilation and simulation
├── kelvin_dv.f            # File list for compilation
└── bin/                   # Directory for test binaries
    └── program.bin        # (Needs to be generated and copied here)
```

## Running the Testbench using the Makefile

The provided `Makefile` simplifies the compilation and simulation process.

**1. Compilation:**

* **Command:** `make compile`
* **Action:** Creates necessary directories (`sim_work`, `logs`, `waves`), and compiles the DUT and testbench using VCS based on `kelvin_dv.f`. Creates the `sim_work/simv` executable.
* **Expected Output:**
    ```
    --- Compiling with VCS ---
    Chronologic VCS simulator copyright 1991-202X
    Contains Synopsys proprietary information.
    Compiler version ...
    ... (VCS compilation messages) ...
    Top Level Modules:
            kelvin_tb_top
    TimeScale is 1ns / 1ps
    --- Compilation Finished ---
    ```
    Check `sim_work/logs/compile.log` for detailed messages and errors.

**2. Running the Simulation:**

* **Command (Default Test):** `make run`
    * Runs the default test (`kelvin_base_test`) defined in the Makefile.
    * Uses the default binary (`bin/program.bin`).
    * Uses `UVM_MEDIUM` verbosity.
* **Command (Specific Test & Binary):**
    ```bash
    make run UVM_TESTNAME=<your_specific_test> TEST_BINARY=/path/to/another.bin UVM_VERBOSITY=UVM_HIGH
    ```
    * Overrides the default test name, binary path, and verbosity level.
* **Action:** Executes the compiled `simv` executable with the specified UVM runtime options.
* **Expected Output:**
    ```
    --- Running Simulation ---
    Test:      kelvin_base_test
    Binary:    bin/program.bin
    Verbosity: UVM_MEDIUM
    Timeout:   20000 ns
    Plusargs:  +UVM_TESTNAME=kelvin_base_test +TEST_BINARY=bin/program.bin +UVM_VERBOSITY=UVM_MEDIUM +TEST_TIMEOUT=20000
    Log File:  sim_work/logs/kelvin_base_test.log
    Wave File: sim_work/waves/kelvin_base_test.fsdb
    Chronologic VCS simulator copyright 1991-202X
    Contains Synopsys proprietary information.
    Simulator version ... ; Runtime version ...
    UVM_INFO @ 0: reporter [RNTST] Running test kelvin_base_test...
    ... (UVM simulation messages based on verbosity) ...
    UVM_INFO tests/kelvin_test_pkg.sv(LINE#) @ TIME: uvm_test_top.env.m_master_agent.sequencer@@req_pc [kelvin_kickoff_write_seq] Kickoff Write 1 (PC=0x00000034) sent to addr 0x00030004
    ...
    UVM_INFO tests/kelvin_test_pkg.sv(LINE#) @ TIME: uvm_test_top [kelvin_base_test] DUT halted signal observed
    UVM_INFO tests/kelvin_test_pkg.sv(LINE#) @ TIME: uvm_test_top [kelvin_base_test] Run phase finishing
    --- UVM Report Summary ---
    ...
    UVM_INFO tests/kelvin_test_pkg.sv(LINE#) @ TIME: uvm_test_top [kelvin_base_test] ** UVM TEST PASSED **
    --- Simulation Finished ---
    ```
    * Look for the `** UVM TEST PASSED **` or `** UVM TEST FAILED **` message at the end of the simulation log (`sim_work/logs/<testname>.log`).
    * If enabled, a waveform file (`sim_work/waves/<testname>.fsdb`) will be generated.

**3. Cleaning:**

* **Command:** `make clean`
* **Action:** Removes the `sim_work` directory and other simulation-generated files (`simv`, `csrc`, logs, waveforms, etc.). `kelvin_dv.f` is *not* removed if it's checked in.
* **Expected Output:**
    ```
    --- Cleaning Simulation Files ---
    rm -rf sim_work simv* csrc* *.log* *.key *.vpd *.fsdb ucli.key DVEfiles/ verdiLog/ novas.*
    ```

This README should help you get started with compiling and running the basic test for the `RvvCoreMiniVerificationAxi` DUT. Remember to complete the remaining TODOs in the UVM code itself.

