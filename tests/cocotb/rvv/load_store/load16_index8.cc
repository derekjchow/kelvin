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
constexpr size_t lut_size = 256;
// Double sized so we can check trailing regions are not read/written.
constexpr size_t buf_size = 128;
}  // namespace

size_t vl __attribute__((section(".data"))) = 8;
// Indices are always unsigned.
uint8_t index_buf[buf_size] __attribute__((section(".data")));
// These instructions don't differentiate signed/unsigned so we only need to
// test one. The types come from intrinsic level.
uint16_t in_buf[lut_size] __attribute__((section(".data")));
uint16_t out_buf[buf_size] __attribute__((section(".data")));

extern "C" {
// Unordered
__attribute__((used, retain)) void vluxei8_v_u16mf2() {
  vuint8mf4_t indices;
  asm("vsetvli zero, %[vl], e8, mf4, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8mf4(index_buf, vl);
  auto data = __riscv_vluxei8_v_u16mf2(in_buf, indices, vl);
  __riscv_vse16_v_u16mf2(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei8_v_u16m1() {
  vuint8mf2_t indices;
  asm("vsetvli zero, %[vl], e8, mf2, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8mf2(index_buf, vl);
  auto data = __riscv_vluxei8_v_u16m1(in_buf, indices, vl);
  __riscv_vse16_v_u16m1(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei8_v_u16m2() {
  vuint8m1_t indices;
  asm("vsetvli zero, %[vl], e8, m1, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m1(index_buf, vl);
  auto data = __riscv_vluxei8_v_u16m2(in_buf, indices, vl);
  __riscv_vse16_v_u16m2(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei8_v_u16m4() {
  vuint8m2_t indices;
  asm("vsetvli zero, %[vl], e8, m2, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m2(index_buf, vl);
  auto data = __riscv_vluxei8_v_u16m4(in_buf, indices, vl);
  __riscv_vse16_v_u16m4(out_buf, data, vl);
}

__attribute__((used, retain)) void vluxei8_v_u16m8() {
  vuint8m4_t indices;
  asm("vsetvli zero, %[vl], e8, m4, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m4(index_buf, vl);
  auto data = __riscv_vluxei8_v_u16m8(in_buf, indices, vl);
  __riscv_vse16_v_u16m8(out_buf, data, vl);
}

// Ordered
__attribute__((used, retain)) void vloxei8_v_u16mf2() {
  vuint8mf4_t indices;
  asm("vsetvli zero, %[vl], e8, mf4, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8mf4(index_buf, vl);
  auto data = __riscv_vloxei8_v_u16mf2(in_buf, indices, vl);
  __riscv_vse16_v_u16mf2(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei8_v_u16m1() {
  vuint8mf2_t indices;
  asm("vsetvli zero, %[vl], e8, mf2, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8mf2(index_buf, vl);
  auto data = __riscv_vloxei8_v_u16m1(in_buf, indices, vl);
  __riscv_vse16_v_u16m1(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei8_v_u16m2() {
  vuint8m1_t indices;
  asm("vsetvli zero, %[vl], e8, m1, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m1(index_buf, vl);
  auto data = __riscv_vloxei8_v_u16m2(in_buf, indices, vl);
  __riscv_vse16_v_u16m2(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei8_v_u16m4() {
  vuint8m2_t indices;
  asm("vsetvli zero, %[vl], e8, m2, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m2(index_buf, vl);
  auto data = __riscv_vloxei8_v_u16m4(in_buf, indices, vl);
  __riscv_vse16_v_u16m4(out_buf, data, vl);
}

__attribute__((used, retain)) void vloxei8_v_u16m8() {
  vuint8m4_t indices;
  asm("vsetvli zero, %[vl], e8, m4, ta, ma;"
      "vle8.v %[index], %[index_buf];"
      : [index] "=vr"(indices)
      : [vl] "r"(vl), [index_buf] "m"(index_buf));
  // TODO: Revert once compiler bug is eliminated
  // auto indices = __riscv_vle8_v_u8m4(index_buf, vl);
  auto data = __riscv_vloxei8_v_u16m8(in_buf, indices, vl);
  __riscv_vse16_v_u16m8(out_buf, data, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vluxei8_v_u16m1;

int main(int argc, char** argv) {
  impl();
  return 0;
}
