// Copyright 2024 Google LLC
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


// Enum type for SEW. See Table 2 in:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#341-vector-selected-element-width-vsew20
typedef enum logic [2:0] {
  SEW8=0,
  SEW16=1,
  SEW32=2,
  SEW64=3
} RVVSEW;

// Enum type for LMUL. See:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#vector-instruction-formats
typedef enum logic [2:0] {
  LMUL1=0,
  LMUL2=1,
  LMUL4=2,
  LMUL8=3,
  LMULRESERVED=4,
  LMUL1_8=5, // 1/8
  LMUL1_4=6, // 1/4
  LMUL1_2=7  // 1/2
} RVVLMUL;

// The architectural configuration state of the RVV core.
typedef struct packed {
  logic [7:0] vl;  // Max 128, need one extra bit
  logic ma;
  logic ta;
  RVVSEW sew;
  RVVLMUL lmul;
} RVVConfigState;

// Enum to encode the major opcode of the instruction. See "Section 5. Vector
// Instruction Formats" of the RVV 1.0 spec.
typedef enum logic [1:0] {
  LOAD=0,
  STORE=1,
  RVV=2
} RVVOpCode;

// A decoded instruction forwarded to the RVVCore from the scalar core.
typedef struct packed {
  RVVOpCode opcode; // effectively bits [6:0] from instruction
  logic [24:0] bits;   // bits [31:7] from instruction
} RVVInstruction;

// An command internal to the RVVCore. The immediate value of this command has
// been read from the scalar register file if necessary. It also contains
// additional data to track configuration register state (ie: SEW, LMUL, etc).
typedef struct packed {
  RVVOpCode opcode;
  logic [24:0] bits;
  logic [31:0] rs1;
  RVVConfigState arch_state;
} RVVCmd;