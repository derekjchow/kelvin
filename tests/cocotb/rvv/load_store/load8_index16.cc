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
constexpr size_t lut_size = 32000;  // DTCM is 32KB.
// Double sized so we can check trailing regions are not read/written.
constexpr size_t buf_size = 128;
}  // namespace

size_t vl __attribute__((section(".data"))) = 8;
// Indices are always unsigned.
uint16_t index_buf[buf_size] __attribute__((section(".data")));
// These instructions don't differentiate signed/unsigned so we only need to
// test one. The types come from intrinsic level.
uint8_t in_buf[lut_size] __attribute__((section(".data")));
uint8_t out_buf[buf_size] __attribute__((section(".data")));

extern "C" {
// Unordered
__attribute__((used, retain)) void vluxei16_v_u8mf4() {
  auto indices = __riscv_vle16_v_u16mf2(index_buf, vl);
  auto data = __riscv_vluxei16_v_u8mf4(in_buf, indices, vl);
  __riscv_vse8_v_u8mf4(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei16_v_u8mf2() {
  auto indices = __riscv_vle16_v_u16m1(index_buf, vl);
  auto data = __riscv_vluxei16_v_u8mf2(in_buf, indices, vl);
  __riscv_vse8_v_u8mf2(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei16_v_u8m1() {
  asm volatile("vsetvli zero, %0, e16, m2, ta, ma;"
               "vle16.v v2, (%1);"
               "vsetvli zero, %0, e8, m1, ta, ma;"
               "vluxei16.v v2, (%2), v2;"
               "vse8.v v2, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v2");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m2(index_buf, vl);
  // auto data = __riscv_vluxei16_v_u8m1(in_buf, indices, vl);
  // __riscv_vse8_v_u8m1(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei16_v_u8m2() {
  asm volatile("vsetvli zero, %0, e16, m4, ta, ma;"
               "vle16.v v4, (%1);"
               "vsetvli zero, %0, e8, m2, ta, ma;"
               "vluxei16.v v4, (%2), v4;"
               "vse8.v v4, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v4");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m4(index_buf, vl);
  // auto data = __riscv_vluxei16_v_u8m2(in_buf, indices, vl);
  // __riscv_vse8_v_u8m2(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei16_v_u8m4() {
  asm volatile("vsetvli zero, %0, e16, m8, ta, ma;"
               "vle16.v v8, (%1);"
               "vsetvli zero, %0, e8, m4, ta, ma;"
               "vluxei16.v v8, (%2), v8;"
               "vse8.v v8, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v8");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m8(index_buf, vl);
  // auto data = __riscv_vluxei16_v_u8m4(in_buf, indices, vl);
  // __riscv_vse8_v_u8m4(out_buf, data, vl);
}

// Ordered
__attribute__((used, retain)) void vloxei16_v_u8mf4() {
  auto indices = __riscv_vle16_v_u16mf2(index_buf, vl);
  auto data = __riscv_vloxei16_v_u8mf4(in_buf, indices, vl);
  __riscv_vse8_v_u8mf4(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei16_v_u8mf2() {
  auto indices = __riscv_vle16_v_u16m1(index_buf, vl);
  auto data = __riscv_vloxei16_v_u8mf2(in_buf, indices, vl);
  __riscv_vse8_v_u8mf2(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei16_v_u8m1() {
  asm volatile("vsetvli zero, %0, e16, m2, ta, ma;"
               "vle16.v v2, (%1);"
               "vsetvli zero, %0, e8, m1, ta, ma;"
               "vloxei16.v v2, (%2), v2;"
               "vse8.v v2, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v2");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m2(index_buf, vl);
  // auto data = __riscv_vloxei16_v_u8m1(in_buf, indices, vl);
  // __riscv_vse8_v_u8m1(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei16_v_u8m2() {
  asm volatile("vsetvli zero, %0, e16, m4, ta, ma;"
               "vle16.v v4, (%1);"
               "vsetvli zero, %0, e8, m2, ta, ma;"
               "vloxei16.v v4, (%2), v4;"
               "vse8.v v4, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v4");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m4(index_buf, vl);
  // auto data = __riscv_vloxei16_v_u8m2(in_buf, indices, vl);
  // __riscv_vse8_v_u8m2(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei16_v_u8m4() {
  asm volatile("vsetvli zero, %0, e16, m8, ta, ma;"
               "vle16.v v8, (%1);"
               "vsetvli zero, %0, e8, m4, ta, ma;"
               "vloxei16.v v8, (%2), v8;"
               "vse8.v v8, (%3);"
               :
               : "r" (vl), "r" (index_buf), "r" (in_buf), "r" (out_buf)
               : "v8");

  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle16_v_u16m8(index_buf, vl);
  // auto data = __riscv_vloxei16_v_u8m4(in_buf, indices, vl);
  // __riscv_vse8_v_u8m4(out_buf, data, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vluxei16_v_u8m1;

int main(int argc, char** argv) {
  impl();
  return 0;
}
