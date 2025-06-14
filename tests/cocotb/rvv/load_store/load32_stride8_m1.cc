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

typedef uint32_t uint32x4_t __attribute__((vector_size(16)));

// On zve32x ELEN is 32 so there should be no mf* support for 4-byte types.
// As a result we don't need to worry nearly as much about over-reads and
// over-writes.
uint32_t in_buf[8] __attribute__((section(".data")));   // 7 in use.
uint32_t out_buf[4] __attribute__((section(".data")));  // 4 in use.

__attribute__((used, retain)) void test_intrinsic(const uint32_t *x,
                                                  uint32_t *y) {
  vuint32m1_t v = __riscv_vlse32_v_u32m1(x, /*stride=*/8, /*vl=*/4);
  __riscv_vse32_v_u32m1(y, v, 4);
}

__attribute__((used, retain)) void test_vector(const uint32_t *x, uint32_t *y) {
  uint32x4_t v = {x[0], x[2], x[4], x[6]};
  *reinterpret_cast<uint32x4_t *>(y) = v;
}

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
