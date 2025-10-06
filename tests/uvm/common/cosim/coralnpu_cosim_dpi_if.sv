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

//----------------------------------------------------------------------------
// Package: coralnpu_cosim_dpi_if
// Description: Defines the DPI-C import declarations for interacting with the
//              MPACT simulator. This acts as the SystemVerilog-side "header".
//----------------------------------------------------------------------------
package coralnpu_cosim_dpi_if;

  // Function to initialize the MPACT simulator.
  // Returns 0 on success.
  import "DPI-C" context function int mpact_init();

  // Function to load an ELF program.
  // Returns 0 on success.
  import "DPI-C" context function int mpact_load_program(input string elf_file);

  // Function to reset the MPACT simulator.
  // Returns 0 on success.
  import "DPI-C" context function int mpact_reset();

  // Function to execute one instruction in the MPACT simulator.
  // Returns 0 on success.
  import "DPI-C" context function int mpact_step(
    input logic [31:0] instruction
  );

  // Function to check if the MPACT simulator has halted.
  // Returns '1' (true) if halted.
  import "DPI-C" context function bit mpact_is_halted();

  // Function to get a register value (GPR, PC, CSR) by its string name.
  // The C pointer 'uint32_t* value' maps to an 'output' argument in SV.
  import "DPI-C" context function int mpact_get_register(
    input string name,
    output int unsigned value
  );

  // Function to finalize the MPACT simulator.
  // Returns 0 on success.
  import "DPI-C" context function int mpact_fini();

endpackage : coralnpu_cosim_dpi_if
