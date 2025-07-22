/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <riscv_vector.h>

{IN_DTYPE}_t in_buf_1[{NUM_TEST_VALUES}] __attribute__((section(".data")))
__attribute__((aligned(16)));
{IN_DTYPE}_t in_buf_2[{NUM_TEST_VALUES}] __attribute__((section(".data")))
__attribute__((aligned(16)));
{OUT_DTYPE}_t out_buf_widen[{NUM_TEST_VALUES}]
    __attribute__((section(".data"))) __attribute__((aligned(16)));

// Todo vx and double widens as well

void {MATH_OP}_widen_test(const {IN_DTYPE}_t* in_buf_1,
                          const {IN_DTYPE}_t* in_buf_2,
                          {OUT_DTYPE}_t* out_buf_widen) {
  uint8_t num_operands = 4 * {STEP_OPERANDS};

  for (int i = 0; i + num_operands <= {NUM_TEST_VALUES}; i += num_operands) {
    v{IN_DTYPE}m2_t vin_buf_1 =
        __riscv_vle{IN_SEW}_v_{SIGN}{IN_SEW}m2(in_buf_1 + i, num_operands);
    v{IN_DTYPE}m2_t vin_buf_2 =
        __riscv_vle{IN_SEW}_v_{SIGN}{IN_SEW}m2(in_buf_2 + i, num_operands);
    v{OUT_DTYPE}m4_t vresult_widen =
    __riscv_vw{MATH_OP}_vv_{SIGN}{OUT_SEW}m4(vin_buf_1, vin_buf_2, num_operands);

    __riscv_vse{OUT_SEW}_v_{SIGN}{OUT_SEW}m1(
        out_buf_widen + i + (0 * {STEP_OPERANDS}),
        __riscv_vget_v_{SIGN}{OUT_SEW}m4_{SIGN}{OUT_SEW}m1(vresult_widen,
                                                               0),
        {STEP_OPERANDS});
    __riscv_vse{OUT_SEW}_v_{SIGN}{OUT_SEW}m1(
        out_buf_widen + i + (1 * {STEP_OPERANDS}),
        __riscv_vget_v_{SIGN}{OUT_SEW}m4_{SIGN}{OUT_SEW}m1(vresult_widen,
                                                               1),
        {STEP_OPERANDS});
    __riscv_vse{OUT_SEW}_v_{SIGN}{OUT_SEW}m1(
        out_buf_widen + i + (2 * {STEP_OPERANDS}),
        __riscv_vget_v_{SIGN}{OUT_SEW}m4_{SIGN}{OUT_SEW}m1(vresult_widen,
                                                               2),
        {STEP_OPERANDS});
    __riscv_vse{OUT_SEW}_v_{SIGN}{OUT_SEW}m1(
        out_buf_widen + i + (3 * {STEP_OPERANDS}),
        __riscv_vget_v_{SIGN}{OUT_SEW}m4_{SIGN}{OUT_SEW}m1(vresult_widen,
                                                               3),
        {STEP_OPERANDS});
    asm volatile("fence");
  }
}

int main(int argc, char** argv) {
  {MATH_OP}_widen_test(in_buf_1, in_buf_2, out_buf_widen);
  return 0;
}
