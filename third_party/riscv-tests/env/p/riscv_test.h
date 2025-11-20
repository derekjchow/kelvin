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

 #ifndef TESTS_RISCV_TESTS_RISCV_TEST_H_
 #define TESTS_RISCV_TESTS_RISCV_TEST_H_
 
 #define RVTEST_RV32U \
   .macro init;       \
   .endm
 #define RVTEST_RV32M \
   .macro init;       \
   .endm
#define RVTEST_RV32UF \
    .macro init;      \
    .endm
 #define RVTEST_CODE_BEGIN \
   .option norelax;        \
   .globl _start;          \
   _start:


 #define RVTEST_CODE_END
 #define TESTNUM gp
 #define RVTEST_PASS .word 0x08000073
 #define RVTEST_FAIL ebreak
 #define EXTRA_DATA
 // clang-format off
 #define RVTEST_DATA_BEGIN                                           \
   EXTRA_DATA                                                        \
   .pushsection .tohost, "aw", @progbits;                            \
   .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;      \
   .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
   .popsection;                                                      \
   .align 4;                                                         \
   .global begin_signature;                                          \
   begin_signature:
 // clang-format on
 #define RVTEST_DATA_END  \
   .align 4;              \
   .global end_signature; \
   end_signature:
 
 #define MSTATUS_FS (0x00006000)
 #define MSTATUS_MPP (0x00001800)
 #define CAUSE_USER_ECALL (0x8)
 #define CAUSE_ILLEGAL_INSTRUCTION (0x2)
 
 #endif  // TESTS_RISCV_TESTS_RISCV_TEST_H_
