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

// Enough space for m2.
uint32_t in_buf[16] __attribute__((section(".data")));
uint32_t out_buf[16] __attribute__((section(".data")));

__attribute__((used, retain)) void test_intrinsic(const uint32_t *x,
                                                  uint32_t *y) {
  vuint32m2_t v = __riscv_vle32_v_u32m2(x, /*vl=*/8);
  __riscv_vse32_v_u32m2(y, v, /*vl=*/8);
}

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
