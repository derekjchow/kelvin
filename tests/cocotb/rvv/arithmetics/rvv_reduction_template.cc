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

#define __ATTRIBUTE_IN_DTCM__ \
    __attribute__((section(".data"))) __attribute__((aligned(16)))

{DTYPE}_t in_buf_1[{IN_DATA_SIZE}] __ATTRIBUTE_IN_DTCM__;
{DTYPE}_t scalar_input __ATTRIBUTE_IN_DTCM__;
{DTYPE}_t out_buf __ATTRIBUTE_IN_DTCM__;
uint32_t vstart __ATTRIBUTE_IN_DTCM__ = 0;
uint32_t vl __ATTRIBUTE_IN_DTCM__ = {NUM_OPERANDS};
uint32_t faulted __ATTRIBUTE_IN_DTCM__ = 0;
uint32_t mcause __ATTRIBUTE_IN_DTCM__ = 0;

// Fault handler to log fault
extern "C" {
void coralnpu_exception_handler() {
  faulted = 1;
  uint32_t local_mcause;
  asm volatile("csrr %0, mcause" : "=r"(local_mcause));
  mcause = local_mcause;

  asm volatile("ebreak");
  while (1) {}
}
}

void {REDUCTION_OP}_{SIGN}{SEW}_m1(const {DTYPE}_t* in_buf_1, const {DTYPE}_t scalar_input, {DTYPE}_t* out_buf){

    v{DTYPE}m1_t input_v1 = __riscv_vle{SEW}_v_{SIGN}{SEW}m1(in_buf_1, vl);
    v{DTYPE}m1_t input_s1 = __riscv_vmv_v_x_{SIGN}{SEW}m1(scalar_input, vl);
    asm("csrw vstart, %0" : : "r"(vstart));
    v{DTYPE}m1_t {REDUCTION_OP}_result = __riscv_v{REDUCTION_OP}_vs_{SIGN}{SEW}m1_{SIGN}{SEW}m1(input_v1, input_s1, vl);
    *out_buf = __riscv_vmv_x_s_{SIGN}{SEW}m1_{SIGN}{SEW}({REDUCTION_OP}_result);
}


int main(int argc, char **argv) {
  {REDUCTION_OP}_{SIGN}{SEW}_m1(in_buf_1, scalar_input, &out_buf);
  return 0;
}