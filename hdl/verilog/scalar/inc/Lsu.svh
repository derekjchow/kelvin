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

`ifndef HDL_VERILOG_SCALAR_INC_LSU_SVH
`define HDL_VERILOG_SCALAR_INC_LSU_SVH

typedef enum logic [4:0] {
  LB  = 0
  LH  = 1
  LW  = 2
  LBU = 3
  LHU = 4
  SB  = 5
  SH  = 6
  SW  = 7
  FENCEI = 8
  FLUSHAT = 9
  FLUSHALL = 10
  VLDST = 11
  FLOAT = 12

  // Vector instructions.
  VLOAD_UNIT = 13,
  VLOAD_STRIDED = 14,
  VLOAD_OINDEXED = 15,
  VLOAD_UINDEXED = 16,
  VSTORE_UNIT = 17,
  VSTORE_STRIDED = 18,
  VSTORE_OINDEXED = 19,
  VSTORE_UINDEXED = 20,
} LsuOp;

typedef struct packed {
  logic store;
  logic [4:0] addr;
  LsuOp op;
  logic [31:0] pc;
  logic [2:0] elemWidth;
  logic [2:0] nfields;
} LsuCmd;

`endif // HDL_VERILOG_SCALAR_INC_LSU_SVH