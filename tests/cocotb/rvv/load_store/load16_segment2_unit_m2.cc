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

// Enough space for m4.
uint16_t in_buf[64] __attribute__((section(".data")));
uint16_t out_buf[64] __attribute__((section(".data")));

__attribute__((used, retain)) void test_intrinsic(const uint16_t *x,
                                                  uint16_t *y) {
  vuint16m2x2_t v = __riscv_vlseg2e16_v_u16m2x2(in_buf, 32);

  vuint16m4_t vv = __riscv_vcreate_v_u16m2_u16m4(
      __riscv_vget_v_u16m2x2_u16m2(v, 0),
      __riscv_vget_v_u16m2x2_u16m2(v, 1));

  __riscv_vse16_v_u16m4(y, vv, /*vl=*/32);
}

int main(int argc, char **argv) {
  test_intrinsic(in_buf, out_buf);
  return 0;
}
