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


// RVV operations
`define RVVOperationBits 6
typedef enum logic [`RVVOperationBits-1:0] {
  VADD=1,
  VSUB=2,
  VSETVLI=3,
  VSETIVLI=4,
  VSETVL=5
  // TODO: Add all the operations
} RVVOperation;


// Enum type for SEW. See Table 2 in:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#341-vector-selected-element-width-vsew20
typedef enum logic [2:0] {
  SEW8=0,
  SEW16=1,
  SEW32=2,
  SEW64=3
} RVVSEW;

// Enum type for LMUL. See:
// https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc#342-vector-register-grouping-vlmul20
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

// A decoded instruction forwarded to the RVVCore from the scalar core.
typedef struct packed {
  RVVOperation op;
  logic has_imm;
  // Largest set of immediates is for vsetivli at 16 bits, but the union of
  // all possible bits is 16 bits. These correspnd to the range of [30:15] in
  // the original instruction encoding.
  // See Section 5. Vector Instruction Formats
  logic [15:0] imm;
  // The following can represent vd or rd, etc based on op type.
  logic [4:0] xd;
  logic [4:0] vs1;
  logic [4:0] vs2;
} RVVInstruction;

// The architectural configuration state of the RVV core.
typedef struct packed {
  logic [7:0] vl;  // Max 128, need one extra bit
  logic ma;
  logic ta;
  RVVSEW sew;
  RVVLMUL lmul;
} RVVConfigState;

// An command internal to the RVVCore. The immediate value of this command has
// been read from the scalar register file if necessary. It also contains
// additional data to track configuration register state (ie: SEW, LMUL, etc).
typedef struct packed {
  RVVOperation op;
  logic has_imm;
  logic [31:0] imm;
  // The following can represent vd or rd, etc based on op type.
  logic [4:0] xd;
  logic [4:0] vs1;
  logic [4:0] vs2;

  // TODO(derekjchow): Add LMUL/remaining parameters here
  RVVConfigState arch_state;
} RVVCmd;