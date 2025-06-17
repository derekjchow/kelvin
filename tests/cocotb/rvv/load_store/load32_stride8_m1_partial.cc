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

// vector size needs to be power of 2, and it's currently not possible to
// express a partial store. A fully portable impl of this test case is not
// possible.

// Enough space for full m1.
uint32_t in_buf[8] __attribute__((section(".data")));   // 5 in use.
uint32_t out_buf[4] __attribute__((section(".data")));  // 3 in use.

__attribute__((used, retain)) void test_intrinsic(const uint32_t *x,
                                                  uint32_t *y) {
  vuint32m1_t v = __riscv_vlse32_v_u32m1(x, /*stride=*/8, /*vl=*/3);
  __riscv_vse32_v_u32m1(y, v, 3);
}

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
