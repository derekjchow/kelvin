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

typedef uint16_t uint16x4_t __attribute__((vector_size(8)));

// Enough space for m1.
uint16_t in_buf[16] __attribute__((section(".data")));  // 7 in use.
uint16_t out_buf[8] __attribute__((section(".data")));  // 4 in use.

__attribute__((used, retain)) void test_intrinsic(const uint16_t *x,
                                                  uint16_t *y) {
  vuint16mf2_t v = __riscv_vlse16_v_u16mf2(x, /*stride=*/4, /*vl=*/4);
  __riscv_vse16_v_u16mf2(y, v, 4);
}

__attribute__((used, retain)) void test_vector(const uint16_t *x, uint16_t *y) {
  uint16x4_t v = {x[0], x[2], x[4], x[6]};
  *reinterpret_cast<uint16x4_t *>(y) = v;
}

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
