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


{DTYPE}_t in_buf_1[{IN_DATA_SIZE}] __attribute__((section(".data"))) __attribute__((aligned(16)));
{DTYPE}_t in_buf_2[{IN_DATA_SIZE}] __attribute__((section(".data"))) __attribute__((aligned(16)));
{DTYPE}_t out_buf[{OUT_DATA_SIZE}] __attribute__((section(".data"))) __attribute__((aligned(16)));

void {MATH_OP}_{SIGN}{SEW}_m1(const {DTYPE}_t* in_buf_1, const {DTYPE}_t* in_buf_2, {DTYPE}_t* out_buf){

    v{DTYPE}m1_t input_v1 = __riscv_vle{SEW}_v_{SIGN}{SEW}m1(in_buf_1, {NUM_OPERANDS});
    v{DTYPE}m1_t input_v2 = __riscv_vle{SEW}_v_{SIGN}{SEW}m1(in_buf_2, {NUM_OPERANDS});
    v{DTYPE}m1_t {MATH_OP}_result = __riscv_v{MATH_OP}_vv_{SIGN}{SEW}m1(input_v1, input_v2, {NUM_OPERANDS});
    __riscv_vse{SEW}_v_{SIGN}{SEW}m1(out_buf, {MATH_OP}_result, {NUM_OPERANDS});
}


int main(int argc, char **argv) {
  {MATH_OP}_{SIGN}{SEW}_m1(in_buf_1, in_buf_2, out_buf);
  return 0;
}

