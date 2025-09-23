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
constexpr size_t scatter_count = 32;
constexpr size_t buf_size = 4000;
}  // namespace

size_t vl __attribute__((section(".data"))) = 4;
// Indices are always unsigned.
uint16_t index_buf[scatter_count] __attribute__((section(".data")));
// These instructions don't differentiate signed/unsigned so we only need to
// test one. The types come from intrinsic level.
uint32_t in_buf[scatter_count] __attribute__((section(".data")));
uint32_t out_buf[buf_size] __attribute__((section(".data")));

extern "C" {
// Unordered
__attribute__((used, retain)) void vsuxei16_v_u32m1() {
  vuint16mf2_t indices;
  asm("vsetvli zero, %[vl], e16, mf2, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16mf2(index_buf, vl);
  auto data = __riscv_vle32_v_u32m1(in_buf, vl);
  __riscv_vsuxei16_v_u32m1(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsuxei16_v_u32m2() {
  vuint16m1_t indices;
  asm("vsetvli zero, %[vl], e16, m1, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m1(index_buf, vl);
  auto data = __riscv_vle32_v_u32m2(in_buf, vl);
  __riscv_vsuxei16_v_u32m2(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsuxei16_v_u32m4() {
  vuint16m2_t indices;
  asm("vsetvli zero, %[vl], e16, m2, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m1(index_buf, vl);
  auto data = __riscv_vle32_v_u32m4(in_buf, vl);
  __riscv_vsuxei16_v_u32m4(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsuxei16_v_u32m8() {
  vuint16m4_t indices;
  asm("vsetvli zero, %[vl], e16, m4, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m2(index_buf, vl);
  auto data = __riscv_vle32_v_u32m8(in_buf, vl);
  __riscv_vsuxei16_v_u32m8(out_buf, indices, data, vl);
}

// Ordered
__attribute__((used, retain)) void vsoxei16_v_u32m1() {
  vuint16mf2_t indices;
  asm("vsetvli zero, %[vl], e16, mf2, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16mf2(index_buf, vl);
  auto data = __riscv_vle32_v_u32m1(in_buf, vl);
  __riscv_vsoxei16_v_u32m1(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsoxei16_v_u32m2() {
  vuint16m1_t indices;
  asm("vsetvli zero, %[vl], e16, m1, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u8mf2(index_buf, vl);
  auto data = __riscv_vle32_v_u32m2(in_buf, vl);
  __riscv_vsoxei16_v_u32m2(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsoxei16_v_u32m4() {
  vuint16m2_t indices;
  asm("vsetvli zero, %[vl], e16, m2, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u8m1(index_buf, vl);
  auto data = __riscv_vle32_v_u32m4(in_buf, vl);
  __riscv_vsoxei16_v_u32m4(out_buf, indices, data, vl);
}

__attribute__((used, retain)) void vsoxei16_v_u32m8() {
  vuint16m4_t indices;
  asm("vsetvli zero, %[vl], e16, m4, ta, ma;"
      "vle16.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u8m2(index_buf, vl);
  auto data = __riscv_vle32_v_u32m8(in_buf, vl);
  __riscv_vsoxei16_v_u32m8(out_buf, indices, data, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vsuxei16_v_u32m1;

int main(int argc, char** argv) {
  impl();
  return 0;
}
