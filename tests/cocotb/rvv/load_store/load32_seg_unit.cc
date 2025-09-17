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

namespace {
// Double sized so we can check trailing regions are not read/written.
constexpr size_t buf_size = 64;
}  // namespace

size_t vl __attribute__((section(".data"))) = 4;
// These instructions don't differentiate signed/unsigned so we only need to
// test one. The types come from intrinsic level.
uint32_t in_buf[buf_size] __attribute__((section(".data")));
uint32_t out_buf[buf_size] __attribute__((section(".data")));

extern "C" {
// Segment 2
__attribute__((used, retain)) void vlseg2e32_v_u32m1x2() {
  auto data = __riscv_vlseg2e32_v_u32m1x2(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x2_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x2_u32m1(data, 1),
                        vl);
}

__attribute__((used, retain)) void vlseg2e32_v_u32m2x2() {
  auto data = __riscv_vlseg2e32_v_u32m2x2(in_buf, vl);
  __riscv_vse32_v_u32m2(out_buf, __riscv_vget_v_u32m2x2_u32m2(data, 0), vl);
  __riscv_vse32_v_u32m2(out_buf + vl, __riscv_vget_v_u32m2x2_u32m2(data, 1),
                        vl);
}

__attribute__((used, retain)) void vlseg2e32_v_u32m4x2() {
  auto data = __riscv_vlseg2e32_v_u32m4x2(in_buf, vl);
  __riscv_vse32_v_u32m4(out_buf, __riscv_vget_v_u32m4x2_u32m4(data, 0), vl);
  __riscv_vse32_v_u32m4(out_buf + vl, __riscv_vget_v_u32m4x2_u32m4(data, 1),
                        vl);
}

// Segment 3
__attribute__((used, retain)) void vlseg3e32_v_u32m1x3() {
  auto data = __riscv_vlseg3e32_v_u32m1x3(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x3_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x3_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x3_u32m1(data, 2),
                        vl);
}

__attribute__((used, retain)) void vlseg3e32_v_u32m2x3() {
  auto data = __riscv_vlseg3e32_v_u32m2x3(in_buf, vl);
  __riscv_vse32_v_u32m2(out_buf, __riscv_vget_v_u32m2x3_u32m2(data, 0), vl);
  __riscv_vse32_v_u32m2(out_buf + vl, __riscv_vget_v_u32m2x3_u32m2(data, 1),
                        vl);
  __riscv_vse32_v_u32m2(out_buf + vl * 2, __riscv_vget_v_u32m2x3_u32m2(data, 2),
                        vl);
}

// Segment 4
__attribute__((used, retain)) void vlseg4e32_v_u32m1x4() {
  auto data = __riscv_vlseg4e32_v_u32m1x4(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x4_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x4_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x4_u32m1(data, 2),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 3, __riscv_vget_v_u32m1x4_u32m1(data, 3),
                        vl);
}

__attribute__((used, retain)) void vlseg4e32_v_u32m2x4() {
  auto data = __riscv_vlseg4e32_v_u32m2x4(in_buf, vl);
  __riscv_vse32_v_u32m2(out_buf, __riscv_vget_v_u32m2x4_u32m2(data, 0), vl);
  __riscv_vse32_v_u32m2(out_buf + vl, __riscv_vget_v_u32m2x4_u32m2(data, 1),
                        vl);
  __riscv_vse32_v_u32m2(out_buf + vl * 2, __riscv_vget_v_u32m2x4_u32m2(data, 2),
                        vl);
  __riscv_vse32_v_u32m2(out_buf + vl * 3, __riscv_vget_v_u32m2x4_u32m2(data, 3),
                        vl);
}

// Segment 5
__attribute__((used, retain)) void vlseg5e32_v_u32m1x5() {
  auto data = __riscv_vlseg5e32_v_u32m1x5(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x5_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x5_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x5_u32m1(data, 2),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 3, __riscv_vget_v_u32m1x5_u32m1(data, 3),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 4, __riscv_vget_v_u32m1x5_u32m1(data, 4),
                        vl);
}

// Segment 6
__attribute__((used, retain)) void vlseg6e32_v_u32m1x6() {
  auto data = __riscv_vlseg6e32_v_u32m1x6(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x6_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x6_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x6_u32m1(data, 2),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 3, __riscv_vget_v_u32m1x6_u32m1(data, 3),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 4, __riscv_vget_v_u32m1x6_u32m1(data, 4),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 5, __riscv_vget_v_u32m1x6_u32m1(data, 5),
                        vl);
}

// Segment 7
__attribute__((used, retain)) void vlseg7e32_v_u32m1x7() {
  auto data = __riscv_vlseg7e32_v_u32m1x7(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x7_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x7_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x7_u32m1(data, 2),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 3, __riscv_vget_v_u32m1x7_u32m1(data, 3),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 4, __riscv_vget_v_u32m1x7_u32m1(data, 4),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 5, __riscv_vget_v_u32m1x7_u32m1(data, 5),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 6, __riscv_vget_v_u32m1x7_u32m1(data, 6),
                        vl);
}

// Segment 8
__attribute__((used, retain)) void vlseg8e32_v_u32m1x8() {
  auto data = __riscv_vlseg8e32_v_u32m1x8(in_buf, vl);
  __riscv_vse32_v_u32m1(out_buf, __riscv_vget_v_u32m1x8_u32m1(data, 0), vl);
  __riscv_vse32_v_u32m1(out_buf + vl, __riscv_vget_v_u32m1x8_u32m1(data, 1),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 2, __riscv_vget_v_u32m1x8_u32m1(data, 2),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 3, __riscv_vget_v_u32m1x8_u32m1(data, 3),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 4, __riscv_vget_v_u32m1x8_u32m1(data, 4),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 5, __riscv_vget_v_u32m1x8_u32m1(data, 5),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 6, __riscv_vget_v_u32m1x8_u32m1(data, 6),
                        vl);
  __riscv_vse32_v_u32m1(out_buf + vl * 7, __riscv_vget_v_u32m1x8_u32m1(data, 7),
                        vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vlseg2e32_v_u32m1x2;

int main(int argc, char** argv) {
  impl();
  return 0;
}
