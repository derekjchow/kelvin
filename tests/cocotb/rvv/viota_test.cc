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

#include <riscv_vector.h>
#include <stdint.h>

uint32_t vma __attribute__((section(".data"))) = 0;
uint32_t vta __attribute__((section(".data"))) = 0;
uint32_t sew __attribute__((section(".data"))) = 0;
uint32_t lmul __attribute__((section(".data"))) = 0;
uint32_t vl __attribute__((section(".data"))) = 16;
uint32_t vstart __attribute__((section(".data"))) = 0;

uint8_t mask_data[16] __attribute__((section(".data")));
uint8_t result[16*8] __attribute__((section(".data")));

uint32_t faulted __attribute__((section(".data"))) = 0;
uint32_t mcause __attribute__((section(".data"))) = 0;

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

int main(int argc, char **argv) {
  // Load mask data
  asm volatile("vsetivli x0, 16, e8, m1, ta, ma");
  asm volatile("vle8.v v0, (%0)" : : "r"(mask_data));

  // Set configuration state
  uint32_t vtype_to_write = (vma << 7) | (vta << 6) | (sew << 3) | lmul;
  asm volatile("vsetvl x0, %0, %1": : "r"(vl), "r"(vtype_to_write));
  uint32_t local_vstart = vstart;
  asm volatile("csrw vstart, %0" : : "r"(local_vstart));

  // Run viota
  asm volatile("viota.m v8, v0");

  // Store result
  asm volatile("vse8.v v8, (%0)" : : "r"(result));

  return 0;
}