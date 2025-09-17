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
constexpr size_t buf_size = 256;
}  // namespace

size_t vl __attribute__((section(".data"))) = 16;
// These instructions don't differentiate signed/unsigned so we only need to
// test one. The types come from intrinsic level.
uint8_t in_buf[buf_size] __attribute__((section(".data")));
uint8_t out_buf[buf_size] __attribute__((section(".data")));

extern "C" {
// Segment 2
__attribute__((used, retain)) void vlseg2e8_v_u8mf4x2() {
  auto data = __riscv_vlseg2e8_v_u8mf4x2(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x2_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x2_u8mf4(data, 1), vl);
}

__attribute__((used, retain)) void vlseg2e8_v_u8mf2x2() {
  auto data = __riscv_vlseg2e8_v_u8mf2x2(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x2_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x2_u8mf2(data, 1), vl);
}

__attribute__((used, retain)) void vlseg2e8_v_u8m1x2() {
  auto data = __riscv_vlseg2e8_v_u8m1x2(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x2_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x2_u8m1(data, 1), vl);
}

__attribute__((used, retain)) void vlseg2e8_v_u8m2x2() {
  auto data = __riscv_vlseg2e8_v_u8m2x2(in_buf, vl);
  __riscv_vse8_v_u8m2(out_buf, __riscv_vget_v_u8m2x2_u8m2(data, 0), vl);
  __riscv_vse8_v_u8m2(out_buf + vl, __riscv_vget_v_u8m2x2_u8m2(data, 1), vl);
}

__attribute__((used, retain)) void vlseg2e8_v_u8m4x2() {
  auto data = __riscv_vlseg2e8_v_u8m4x2(in_buf, vl);
  __riscv_vse8_v_u8m4(out_buf, __riscv_vget_v_u8m4x2_u8m4(data, 0), vl);
  __riscv_vse8_v_u8m4(out_buf + vl, __riscv_vget_v_u8m4x2_u8m4(data, 1), vl);
}

// Segment 3
__attribute__((used, retain)) void vlseg3e8_v_u8mf4x3() {
  auto data = __riscv_vlseg3e8_v_u8mf4x3(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x3_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x3_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x3_u8mf4(data, 2),
                       vl);
}

__attribute__((used, retain)) void vlseg3e8_v_u8mf2x3() {
  auto data = __riscv_vlseg3e8_v_u8mf2x3(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x3_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x3_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x3_u8mf2(data, 2),
                       vl);
}

__attribute__((used, retain)) void vlseg3e8_v_u8m1x3() {
  auto data = __riscv_vlseg3e8_v_u8m1x3(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x3_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x3_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x3_u8m1(data, 2),
                      vl);
}

__attribute__((used, retain)) void vlseg3e8_v_u8m2x3() {
  auto data = __riscv_vlseg3e8_v_u8m2x3(in_buf, vl);
  __riscv_vse8_v_u8m2(out_buf, __riscv_vget_v_u8m2x3_u8m2(data, 0), vl);
  __riscv_vse8_v_u8m2(out_buf + vl, __riscv_vget_v_u8m2x3_u8m2(data, 1), vl);
  __riscv_vse8_v_u8m2(out_buf + vl * 2, __riscv_vget_v_u8m2x3_u8m2(data, 2),
                      vl);
}

// Segment 4
__attribute__((used, retain)) void vlseg4e8_v_u8mf4x4() {
  auto data = __riscv_vlseg4e8_v_u8mf4x4(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x4_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x4_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x4_u8mf4(data, 2),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 3, __riscv_vget_v_u8mf4x4_u8mf4(data, 3),
                       vl);
}

__attribute__((used, retain)) void vlseg4e8_v_u8mf2x4() {
  auto data = __riscv_vlseg4e8_v_u8mf2x4(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x4_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x4_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x4_u8mf2(data, 2),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 3, __riscv_vget_v_u8mf2x4_u8mf2(data, 3),
                       vl);
}

__attribute__((used, retain)) void vlseg4e8_v_u8m1x4() {
  auto data = __riscv_vlseg4e8_v_u8m1x4(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x4_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x4_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x4_u8m1(data, 2),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 3, __riscv_vget_v_u8m1x4_u8m1(data, 3),
                      vl);
}

__attribute__((used, retain)) void vlseg4e8_v_u8m2x4() {
  auto data = __riscv_vlseg4e8_v_u8m2x4(in_buf, vl);
  __riscv_vse8_v_u8m2(out_buf, __riscv_vget_v_u8m2x4_u8m2(data, 0), vl);
  __riscv_vse8_v_u8m2(out_buf + vl, __riscv_vget_v_u8m2x4_u8m2(data, 1), vl);
  __riscv_vse8_v_u8m2(out_buf + vl * 2, __riscv_vget_v_u8m2x4_u8m2(data, 2),
                      vl);
  __riscv_vse8_v_u8m2(out_buf + vl * 3, __riscv_vget_v_u8m2x4_u8m2(data, 3),
                      vl);
}

// Segment 5
__attribute__((used, retain)) void vlseg5e8_v_u8mf4x5() {
  auto data = __riscv_vlseg5e8_v_u8mf4x5(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x5_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x5_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x5_u8mf4(data, 2),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 3, __riscv_vget_v_u8mf4x5_u8mf4(data, 3),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 4, __riscv_vget_v_u8mf4x5_u8mf4(data, 4),
                       vl);
}

__attribute__((used, retain)) void vlseg5e8_v_u8mf2x5() {
  auto data = __riscv_vlseg5e8_v_u8mf2x5(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x5_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x5_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x5_u8mf2(data, 2),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 3, __riscv_vget_v_u8mf2x5_u8mf2(data, 3),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 4, __riscv_vget_v_u8mf2x5_u8mf2(data, 4),
                       vl);
}

__attribute__((used, retain)) void vlseg5e8_v_u8m1x5() {
  auto data = __riscv_vlseg5e8_v_u8m1x5(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x5_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x5_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x5_u8m1(data, 2),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 3, __riscv_vget_v_u8m1x5_u8m1(data, 3),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 4, __riscv_vget_v_u8m1x5_u8m1(data, 4),
                      vl);
}

// Segment 6
__attribute__((used, retain)) void vlseg6e8_v_u8mf4x6() {
  auto data = __riscv_vlseg6e8_v_u8mf4x6(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x6_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x6_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x6_u8mf4(data, 2),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 3, __riscv_vget_v_u8mf4x6_u8mf4(data, 3),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 4, __riscv_vget_v_u8mf4x6_u8mf4(data, 4),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 5, __riscv_vget_v_u8mf4x6_u8mf4(data, 5),
                       vl);
}

__attribute__((used, retain)) void vlseg6e8_v_u8mf2x6() {
  auto data = __riscv_vlseg6e8_v_u8mf2x6(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x6_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x6_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x6_u8mf2(data, 2),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 3, __riscv_vget_v_u8mf2x6_u8mf2(data, 3),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 4, __riscv_vget_v_u8mf2x6_u8mf2(data, 4),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 5, __riscv_vget_v_u8mf2x6_u8mf2(data, 5),
                       vl);
}

__attribute__((used, retain)) void vlseg6e8_v_u8m1x6() {
  auto data = __riscv_vlseg6e8_v_u8m1x6(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x6_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x6_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x6_u8m1(data, 2),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 3, __riscv_vget_v_u8m1x6_u8m1(data, 3),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 4, __riscv_vget_v_u8m1x6_u8m1(data, 4),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 5, __riscv_vget_v_u8m1x6_u8m1(data, 5),
                      vl);
}

// Segment 7
__attribute__((used, retain)) void vlseg7e8_v_u8mf4x7() {
  auto data = __riscv_vlseg7e8_v_u8mf4x7(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x7_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x7_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x7_u8mf4(data, 2),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 3, __riscv_vget_v_u8mf4x7_u8mf4(data, 3),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 4, __riscv_vget_v_u8mf4x7_u8mf4(data, 4),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 5, __riscv_vget_v_u8mf4x7_u8mf4(data, 5),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 6, __riscv_vget_v_u8mf4x7_u8mf4(data, 6),
                       vl);
}

__attribute__((used, retain)) void vlseg7e8_v_u8mf2x7() {
  auto data = __riscv_vlseg7e8_v_u8mf2x7(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x7_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x7_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x7_u8mf2(data, 2),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 3, __riscv_vget_v_u8mf2x7_u8mf2(data, 3),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 4, __riscv_vget_v_u8mf2x7_u8mf2(data, 4),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 5, __riscv_vget_v_u8mf2x7_u8mf2(data, 5),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 6, __riscv_vget_v_u8mf2x7_u8mf2(data, 6),
                       vl);
}

__attribute__((used, retain)) void vlseg7e8_v_u8m1x7() {
  auto data = __riscv_vlseg7e8_v_u8m1x7(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x7_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x7_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x7_u8m1(data, 2),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 3, __riscv_vget_v_u8m1x7_u8m1(data, 3),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 4, __riscv_vget_v_u8m1x7_u8m1(data, 4),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 5, __riscv_vget_v_u8m1x7_u8m1(data, 5),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 6, __riscv_vget_v_u8m1x7_u8m1(data, 6),
                      vl);
}

// Segment 8
__attribute__((used, retain)) void vlseg8e8_v_u8mf4x8() {
  auto data = __riscv_vlseg8e8_v_u8mf4x8(in_buf, vl);
  __riscv_vse8_v_u8mf4(out_buf, __riscv_vget_v_u8mf4x8_u8mf4(data, 0), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl, __riscv_vget_v_u8mf4x8_u8mf4(data, 1), vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 2, __riscv_vget_v_u8mf4x8_u8mf4(data, 2),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 3, __riscv_vget_v_u8mf4x8_u8mf4(data, 3),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 4, __riscv_vget_v_u8mf4x8_u8mf4(data, 4),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 5, __riscv_vget_v_u8mf4x8_u8mf4(data, 5),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 6, __riscv_vget_v_u8mf4x8_u8mf4(data, 6),
                       vl);
  __riscv_vse8_v_u8mf4(out_buf + vl * 7, __riscv_vget_v_u8mf4x8_u8mf4(data, 7),
                       vl);
}

__attribute__((used, retain)) void vlseg8e8_v_u8mf2x8() {
  auto data = __riscv_vlseg8e8_v_u8mf2x8(in_buf, vl);
  __riscv_vse8_v_u8mf2(out_buf, __riscv_vget_v_u8mf2x8_u8mf2(data, 0), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl, __riscv_vget_v_u8mf2x8_u8mf2(data, 1), vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 2, __riscv_vget_v_u8mf2x8_u8mf2(data, 2),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 3, __riscv_vget_v_u8mf2x8_u8mf2(data, 3),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 4, __riscv_vget_v_u8mf2x8_u8mf2(data, 4),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 5, __riscv_vget_v_u8mf2x8_u8mf2(data, 5),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 6, __riscv_vget_v_u8mf2x8_u8mf2(data, 6),
                       vl);
  __riscv_vse8_v_u8mf2(out_buf + vl * 7, __riscv_vget_v_u8mf2x8_u8mf2(data, 7),
                       vl);
}

__attribute__((used, retain)) void vlseg8e8_v_u8m1x8() {
  auto data = __riscv_vlseg8e8_v_u8m1x8(in_buf, vl);
  __riscv_vse8_v_u8m1(out_buf, __riscv_vget_v_u8m1x8_u8m1(data, 0), vl);
  __riscv_vse8_v_u8m1(out_buf + vl, __riscv_vget_v_u8m1x8_u8m1(data, 1), vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 2, __riscv_vget_v_u8m1x8_u8m1(data, 2),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 3, __riscv_vget_v_u8m1x8_u8m1(data, 3),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 4, __riscv_vget_v_u8m1x8_u8m1(data, 4),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 5, __riscv_vget_v_u8m1x8_u8m1(data, 5),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 6, __riscv_vget_v_u8m1x8_u8m1(data, 6),
                      vl);
  __riscv_vse8_v_u8m1(out_buf + vl * 7, __riscv_vget_v_u8m1x8_u8m1(data, 7),
                      vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vlseg2e8_v_u8m1x2;

int main(int argc, char** argv) {
  impl();
  return 0;
}
