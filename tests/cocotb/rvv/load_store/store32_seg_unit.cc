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
__attribute__((used, retain)) void vsseg2e32_v_u32m1x2() {
  auto data = __riscv_vcreate_v_u32m1x2(__riscv_vle32_v_u32m1(in_buf, vl),
                                        __riscv_vle32_v_u32m1(in_buf + vl, vl));
  __riscv_vsseg2e32_v_u32m1x2(out_buf, data, vl);
}

__attribute__((used, retain)) void vsseg2e32_v_u32m2x2() {
  auto data = __riscv_vcreate_v_u32m2x2(__riscv_vle32_v_u32m2(in_buf, vl),
                                        __riscv_vle32_v_u32m2(in_buf + vl, vl));
  __riscv_vsseg2e32_v_u32m2x2(out_buf, data, vl);
}

__attribute__((used, retain)) void vsseg2e32_v_u32m4x2() {
  auto data = __riscv_vcreate_v_u32m4x2(__riscv_vle32_v_u32m4(in_buf, vl),
                                        __riscv_vle32_v_u32m4(in_buf + vl, vl));
  __riscv_vsseg2e32_v_u32m4x2(out_buf, data, vl);
}

// Segment 3
__attribute__((used, retain)) void vsseg3e32_v_u32m1x3() {
  auto data = __riscv_vcreate_v_u32m1x3(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl));
  __riscv_vsseg3e32_v_u32m1x3(out_buf, data, vl);
}

__attribute__((used, retain)) void vsseg3e32_v_u32m2x3() {
  auto data = __riscv_vcreate_v_u32m2x3(
      __riscv_vle32_v_u32m2(in_buf, vl), __riscv_vle32_v_u32m2(in_buf + vl, vl),
      __riscv_vle32_v_u32m2(in_buf + vl * 2, vl));
  __riscv_vsseg3e32_v_u32m2x3(out_buf, data, vl);
}

// Segment 4
__attribute__((used, retain)) void vsseg4e32_v_u32m1x4() {
  auto data = __riscv_vcreate_v_u32m1x4(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 3, vl));
  __riscv_vsseg4e32_v_u32m1x4(out_buf, data, vl);
}

__attribute__((used, retain)) void vsseg4e32_v_u32m2x4() {
  auto data = __riscv_vcreate_v_u32m2x4(
      __riscv_vle32_v_u32m2(in_buf, vl), __riscv_vle32_v_u32m2(in_buf + vl, vl),
      __riscv_vle32_v_u32m2(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m2(in_buf + vl * 3, vl));
  __riscv_vsseg4e32_v_u32m2x4(out_buf, data, vl);
}

// Segment 5
__attribute__((used, retain)) void vsseg5e32_v_u32m1x5() {
  auto data = __riscv_vcreate_v_u32m1x5(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 3, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 4, vl));
  __riscv_vsseg5e32_v_u32m1x5(out_buf, data, vl);
}

// Segment 6
__attribute__((used, retain)) void vsseg6e32_v_u32m1x6() {
  auto data = __riscv_vcreate_v_u32m1x6(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 3, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 4, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 5, vl));
  __riscv_vsseg6e32_v_u32m1x6(out_buf, data, vl);
}

// Segment 7
__attribute__((used, retain)) void vsseg7e32_v_u32m1x7() {
  auto data = __riscv_vcreate_v_u32m1x7(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 3, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 4, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 5, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 6, vl));
  __riscv_vsseg7e32_v_u32m1x7(out_buf, data, vl);
}

// Segment 8
__attribute__((used, retain)) void vsseg8e32_v_u32m1x8() {
  auto data = __riscv_vcreate_v_u32m1x8(
      __riscv_vle32_v_u32m1(in_buf, vl), __riscv_vle32_v_u32m1(in_buf + vl, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 2, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 3, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 4, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 5, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 6, vl),
      __riscv_vle32_v_u32m1(in_buf + vl * 7, vl));
  __riscv_vsseg8e32_v_u32m1x8(out_buf, data, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vsseg2e32_v_u32m1x2;

int main(int argc, char** argv) {
  impl();
  return 0;
}
