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
constexpr size_t buf_size = 64;
constexpr uint32_t vxrm = 2;  // TODO(davidgao): test remaining ones
}  // namespace

size_t vl __attribute__((section(".data"))) = 4;
size_t shift_scalar __attribute__((section(".data"))) = 1;
int32_t buf32[buf_size] __attribute__((section(".data")));
int16_t buf16[buf_size] __attribute__((section(".data")));
int8_t buf8[buf_size] __attribute__((section(".data")));
uint16_t buf_shift16[buf_size] __attribute__((section(".data")));
uint8_t buf_shift8[buf_size] __attribute__((section(".data")));

extern "C" {
// 32 to 16, vxv
__attribute__((used, retain)) void vnclip_wv_i16mf2() {
  const auto in_v = __riscv_vle32_v_i32m1(buf32, vl);
  const auto shift = __riscv_vle16_v_u16mf2(buf_shift16, vl);
  const auto out_v = __riscv_vnclip_wv_i16mf2(in_v, shift, vxrm, vl);
  __riscv_vse16_v_i16mf2(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i16m1() {
  const auto in_v = __riscv_vle32_v_i32m2(buf32, vl);
  const auto shift = __riscv_vle16_v_u16m1(buf_shift16, vl);
  const auto out_v = __riscv_vnclip_wv_i16m1(in_v, shift, vxrm, vl);
  __riscv_vse16_v_i16m1(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i16m2() {
  const auto in_v = __riscv_vle32_v_i32m4(buf32, vl);
  const auto shift = __riscv_vle16_v_u16m2(buf_shift16, vl);
  const auto out_v = __riscv_vnclip_wv_i16m2(in_v, shift, vxrm, vl);
  __riscv_vse16_v_i16m2(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i16m4() {
  const auto in_v = __riscv_vle32_v_i32m8(buf32, vl);
  const auto shift = __riscv_vle16_v_u16m4(buf_shift16, vl);
  const auto out_v = __riscv_vnclip_wv_i16m4(in_v, shift, vxrm, vl);
  __riscv_vse16_v_i16m4(buf16, out_v, vl);
}

// 32 to 16, vxs
__attribute__((used, retain)) void vnclip_wx_i16mf2() {
  const auto in_v = __riscv_vle32_v_i32m1(buf32, vl);
  const auto out_v = __riscv_vnclip_wx_i16mf2(in_v, shift_scalar, vxrm, vl);
  __riscv_vse16_v_i16mf2(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i16m1() {
  const auto in_v = __riscv_vle32_v_i32m2(buf32, vl);
  const auto out_v = __riscv_vnclip_wx_i16m1(in_v, shift_scalar, vxrm, vl);
  __riscv_vse16_v_i16m1(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i16m2() {
  const auto in_v = __riscv_vle32_v_i32m4(buf32, vl);
  const auto out_v = __riscv_vnclip_wx_i16m2(in_v, shift_scalar, vxrm, vl);
  __riscv_vse16_v_i16m2(buf16, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i16m4() {
  const auto in_v = __riscv_vle32_v_i32m8(buf32, vl);
  const auto out_v = __riscv_vnclip_wx_i16m4(in_v, shift_scalar, vxrm, vl);
  __riscv_vse16_v_i16m4(buf16, out_v, vl);
}

// 16 to 8, vxv
__attribute__((used, retain)) void vnclip_wv_i8mf4() {
  const auto in_v = __riscv_vle16_v_i16mf2(buf16, vl);
  const auto shift = __riscv_vle8_v_u8mf4(buf_shift8, vl);
  const auto out_v = __riscv_vnclip_wv_i8mf4(in_v, shift, vxrm, vl);
  __riscv_vse8_v_i8mf4(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i8mf2() {
  const auto in_v = __riscv_vle16_v_i16m1(buf16, vl);
  const auto shift = __riscv_vle8_v_u8mf2(buf_shift8, vl);
  const auto out_v = __riscv_vnclip_wv_i8mf2(in_v, shift, vxrm, vl);
  __riscv_vse8_v_i8mf2(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i8m1() {
  const auto in_v = __riscv_vle16_v_i16m2(buf16, vl);
  const auto shift = __riscv_vle8_v_u8m1(buf_shift8, vl);
  const auto out_v = __riscv_vnclip_wv_i8m1(in_v, shift, vxrm, vl);
  __riscv_vse8_v_i8m1(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i8m2() {
  const auto in_v = __riscv_vle16_v_i16m4(buf16, vl);
  const auto shift = __riscv_vle8_v_u8m2(buf_shift8, vl);
  const auto out_v = __riscv_vnclip_wv_i8m2(in_v, shift, vxrm, vl);
  __riscv_vse8_v_i8m2(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wv_i8m4() {
  const auto in_v = __riscv_vle16_v_i16m8(buf16, vl);
  const auto shift = __riscv_vle8_v_u8m4(buf_shift8, vl);
  const auto out_v = __riscv_vnclip_wv_i8m4(in_v, shift, vxrm, vl);
  __riscv_vse8_v_i8m4(buf8, out_v, vl);
}

// 16 to 8, vxs
__attribute__((used, retain)) void vnclip_wx_i8mf4() {
  const auto in_v = __riscv_vle16_v_i16mf2(buf16, vl);
  const auto out_v = __riscv_vnclip_wx_i8mf4(in_v, shift_scalar, vxrm, vl);
  __riscv_vse8_v_i8mf4(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i8mf2() {
  const auto in_v = __riscv_vle16_v_i16m1(buf16, vl);
  const auto out_v = __riscv_vnclip_wx_i8mf2(in_v, shift_scalar, vxrm, vl);
  __riscv_vse8_v_i8mf2(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i8m1() {
  const auto in_v = __riscv_vle16_v_i16m2(buf16, vl);
  const auto out_v = __riscv_vnclip_wx_i8m1(in_v, shift_scalar, vxrm, vl);
  __riscv_vse8_v_i8m1(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i8m2() {
  const auto in_v = __riscv_vle16_v_i16m4(buf16, vl);
  const auto out_v = __riscv_vnclip_wx_i8m2(in_v, shift_scalar, vxrm, vl);
  __riscv_vse8_v_i8m2(buf8, out_v, vl);
}

__attribute__((used, retain)) void vnclip_wx_i8m4() {
  const auto in_v = __riscv_vle16_v_i16m8(buf16, vl);
  const auto out_v = __riscv_vnclip_wx_i8m4(in_v, shift_scalar, vxrm, vl);
  __riscv_vse8_v_i8m4(buf8, out_v, vl);
}
}

void (*impl)() __attribute__((section(".data"))) = &vnclip_wv_i16m1;

int main(int argc, char** argv) {
  impl();
  return 0;
}
