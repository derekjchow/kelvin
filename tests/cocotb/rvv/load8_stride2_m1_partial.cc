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

// typedef uint8_t uint8x16_t __attribute__((vector_size(16)));

// Enough space for full m1.
uint8_t in_buf[32] __attribute__((section(".data")));   // 29 in use.
uint8_t out_buf[16] __attribute__((section(".data")));  // 15 in use.

__attribute__((used, retain)) void test_intrinsic(const uint8_t *x,
                                                  uint8_t *y) {
  vuint8m1_t v = __riscv_vlse8_v_u8m1(x, /*stride=*/2, /*vl=*/15);
  __riscv_vse8_v_u8m1(y, v, 15);
}

// __attribute__((used, retain)) void test_vector(const uint8_t *x, uint8_t *y)
// {
// }

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
