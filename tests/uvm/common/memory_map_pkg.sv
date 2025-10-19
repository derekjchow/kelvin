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
// Package: memory_map_pkg
// Description: Defines the memory map for the CoralNPU system.
//----------------------------------------------------------------------------
package memory_map_pkg;

  // Instruction Tightly Coupled Memory (ITCM)
  localparam logic [31:0] ITCM_START_ADDR = 32'h0000_0000;
  localparam logic [31:0] ITCM_LENGTH     = 32'h0000_2000;

  // Data Tightly Coupled Memory (DTCM)
  localparam logic [31:0] DTCM_START_ADDR = 32'h0001_0000;
  localparam logic [31:0] DTCM_LENGTH     = 32'h0000_8000;

  // Control and Status Registers (CSR)
  localparam logic [31:0] CSR_START_ADDR  = 32'h0003_0000;
  localparam logic [31:0] CSR_LENGTH      = 32'h0001_0000;

endpackage : memory_map_pkg
