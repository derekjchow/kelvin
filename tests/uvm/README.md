# CoralNPU UVM Testbench

This document describes the structure and usage of the UVM testbench for
verifying the `RvvCoreMiniVerificationAxi` DUT.

## Overview

This testbench provides a basic UVM environment to:
* Instantiate the `RvvCoreMiniVerificationAxi` DUT.
* Connect AXI Master, AXI Slave, and IRQ interfaces to the DUT.
* Provide basic stimulus generation via UVM sequences.
* Include a simple reactive AXI Slave model.
* Load a binary file into the DUT's memory using backdoor access.
* Kick off the DUT execution using initial AXI writes.
* Check for basic test completion via DUT status signals (`halted`, `fault`) or
  a timeout.

## Prerequisites

* **Synopsys VCS:** This testbench is configured to run with Synopsys VCS.
* **UVM:** VCS needs to be configured with UVM 1.2 support enabled.
* **CoralNPU Hardware Repository:** Access to the repository containing the
  `RvvCoreMiniVerificationAxi` source code is required to generate the DUT
  Verilog and the test binary.
* **Bazel:** The build system used to generate the Verilog from the Chisel
  source in the CoralNPU HW repository.
* **RISC-V Toolchain:** A RISC-V toolchain compatible with the CoralNPU
  project is needed to generate the `.elf` file.
* **CoralNPU MPACT Repository:** Set the `CORALNPU_MPACT` environment
  variable to the absolute path of the `coralnpu-mpact` repository. This
  is required for co-simulation.

## Generating the Test Binary (program.elf)

The test program run by the DUT needs to be compiled to an elf format.

1.  Navigate to the CoralNPU HW repository root:
    ```bash
    cd /path/to/your/coralnpu/hw/repo
    ```
2.  Run the Bazel build command to compile the test program:
    ```bash
    bazel build //tests/cocotb/tutorial:coralnpu_v2_program
    ```
3.  The `coralnpu_v2_program.elf` file is generated in the bazel output
    directory.
4.  Copy this `coralnpu_v2_program.elf` file to the `bin/` directory of this
    UVM testbench structure (or update the `TEST_ELF` path in the `Makefile` or
    run command).

## Directory Structure

The testbench follows a standard UVM directory structure:

```
.
├── common/                  # Common components
│   ├── coralnpu_axi_master/ # Files related to the TB acting as AXI Master
│   │   ├── coralnpu_axi_master_if.sv
│   │   └── coralnpu_axi_master_agent_pkg.sv
│   ├── coralnpu_axi_slave/  # Files related to the TB acting as AXI Slave
│   │   ├── coralnpu_axi_slave_if.sv
│   │   └── coralnpu_axi_slave_agent_pkg.sv
│   ├── coralnpu_irq/        # Files related to the IRQ/Control interface
│   │   ├── coralnpu_irq_if.sv
│   │   └── coralnpu_irq_agent_pkg.sv
│   └── transaction_item/    # Transaction item definitions
│       └── transaction_item_pkg.sv
├── env/                     # UVM Environment definition
│   └── coralnpu_env_pkg.sv
├── tb/                      # Top-level testbench module
│   └── coralnpu_tb_top.sv
├── tests/                   # UVM Tests and Sequences
│   └── coralnpu_test_pkg.sv
├── Makefile                 # Makefile for compilation and simulation
├── coralnpu_dv.f            # File list for compilation
└── bin/                     # Directory for test binaries
    └── program.elf          # (Needs to be generated and copied here)
```

## Running the Testbench using the Makefile

The provided `Makefile` simplifies the compilation and simulation process.

**1. Compiling the Simulator Executable:**

* **Command:** `make compile`
* **Action:**
    * Creates necessary directories (`sim_work`, `logs`, `waves`).
    * Generates the DUT Verilog from Chisel sources.
    * Builds the MPACT co-simulation C++ library.
    * Compiles the DUT and testbench SystemVerilog files using VCS based on `coralnpu_dv.f`.
    * Creates the `sim_work/simv` executable.
*   Users should run `make compile` whenever modifying SystemVerilog (`.sv`),
    Chisel (`.scala`), or C++ (`.cpp`) source files that are part of the
    DUT or testbench.
* **Expected Output:**
    ```
    --- Checking MPACT-Sim Co-sim Library dependencies ---
    --- Checking RTL source dependencies ---
    --- Compiling with VCS ---
    Chronologic VCS simulator copyright 1991-202X
    Contains Synopsys proprietary information.
    Compiler version ...
    ... (VCS compilation messages) ...
    Top Level Modules:
            coralnpu_tb_top
    TimeScale is 1ns / 1ps
    --- Compilation Finished ---
    ```
    Check `sim_work/logs/compile.log` for detailed messages and errors.

**2. Running the Simulation:**

* **Command (Default Test):** `make run`
    * Runs the default test (`coralnpu_base_test`) defined in the Makefile.
    * Uses the default program (`bin/program.elf`).
    * Uses `UVM_MEDIUM` verbosity.
* **Command (Specific Test & Binary):**
    ```bash
    make run UVM_TESTNAME=<your_specific_test> \
             TEST_ELF=/path/to/another.elf \
             UVM_VERBOSITY=UVM_HIGH
    ```
    * Overrides the default test name, binary path, and verbosity level.
* **Action:**
  * Generates memory initialization files (`.mem`) and runtime options
    (`elf_run_opts.f`) from the specified `TEST_ELF` (this always runs).
  * Executes the *already compiled* `simv` executable with the specified UVM runtime options.
  * Users should run `make run` after `make compile` has successfully
    finished, or when only the `TEST_ELF` file changes and recompilation
    is not needed.
* **Expected Output:**
    ```
    --- Running Simulation ---
    Test:      coralnpu_base_test
    ELF File:  ./bin/program.elf
    Verbosity: UVM_MEDIUM
    Timeout:   20000 ns
    Plusargs:  +UVM_TESTNAME=coralnpu_base_test +UVM_VERBOSITY=UVM_MEDIUM \
               +TEST_TIMEOUT=20000 +TEST_ELF=./bin/program.elf
    Log File:  ./sim_work/logs/coralnpu_base_test.log
    Wave File: ./sim_work/waves/coralnpu_base_test.fsdb
    Chronologic VCS simulator copyright 1991-202X
    Contains Synopsys proprietary information.
    Simulator version ... ; Runtime version ...
    UVM_INFO @ 0: reporter [RNTST] Running test coralnpu_base_test...
    ... (UVM simulation messages based on verbosity) ...
    UVM_INFO ./tests/coralnpu_test_pkg.sv(LINE#) @ TIME: uvm_test_top \
        [coralnpu_base_test] Run phase finishing
    UVM_INFO ./tests/coralnpu_test_pkg.sv(LINE#) @ TIME: uvm_test_top \
        [coralnpu_base_test] Test ended on DUT halt.
    --- UVM Report Summary ---
    ...
    UVM_INFO ./tests/coralnpu_test_pkg.sv(241) @ TIME: uvm_test_top \
        [coralnpu_base_test] ** UVM TEST PASSED **
    --- Simulation Finished ---
    ```
    * Look for the `** UVM TEST PASSED **` or `** UVM TEST FAILED **` message
      at the end of the simulation log (`sim_work/logs/<testname>.log`).
    * If enabled, a waveform file (`sim_work/waves/<testname>.fsdb`) will be
      generated.

**3. Combined Compile and Run:**

* **Command:** `make all` (or simply `make`)
* **Action:** This command first runs `make compile` to ensure the simulator
  executable is up-to-date, then runs `make run`. This is a convenient
  way to perform a full build and run.

**4. Cleaning:**

* **Command:** `make clean`
* **Action:** Removes the `sim_work` directory and other simulation-generated
  files (`simv`, `csrc`, logs, waveforms, etc.). It also cleans Bazel
  caches for the MPACT library and generated RTL.
* **Expected Output:**
    ```
    --- Cleaning Simulation Files ---
    rm -rf sim_work simv* csrc* *.log* *.key *.vpd *.fsdb ucli.key DVEfiles/ \
           verdiLog/ novas.*
    --- Cleaning MPACT-Sim Bazel cache ---
    ... (Bazel clean messages) ...
    ```

This README should help you get started with compiling and running the basic
test for the `RvvCoreMiniVerificationAxi` DUT.