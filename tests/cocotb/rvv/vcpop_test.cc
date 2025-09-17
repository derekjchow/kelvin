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
constexpr size_t buf_size = 16;
}

size_t vl __attribute__((section(".data"))) = 16;
uint8_t in_buf[buf_size] __attribute__((section(".data")));
uint32_t result __attribute__((section(".data")));

extern "C" {
__attribute__((used, retain)) void vcpop_m_b1() {
  auto data =
      __riscv_vreinterpret_v_u8m1_b1(__riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b1(data, vl);
}

__attribute__((used, retain)) void vcpop_m_b2() {
  auto data =
      __riscv_vreinterpret_v_u8m1_b2(__riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b2(data, vl);
}

__attribute__((used, retain)) void vcpop_m_b4() {
  auto data =
      __riscv_vreinterpret_v_u8m1_b4(__riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b4(data, vl);
}

__attribute__((used, retain)) void vcpop_m_b8() {
  auto data =
      __riscv_vreinterpret_v_u8m1_b8(__riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b8(data, vl);
}

__attribute__((used, retain)) void vcpop_m_b16() {
  auto data = __riscv_vreinterpret_v_u8m1_b16(
      __riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b16(data, vl);
}

__attribute__((used, retain)) void vcpop_m_b32() {
  auto data = __riscv_vreinterpret_v_u8m1_b32(
      __riscv_vle8_v_u8m1(in_buf, (vl + 7) / 8));
  result = __riscv_vcpop_m_b32(data, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = vcpop_m_b8;

int main(int argc, char** argv) {
  impl();

  return 0;
}
