/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef OPT_RVV_OPT_H
#define OPT_RVV_OPT_H

#include <riscv_vector.h>

namespace coralnpu_v2::opt {
inline void* Memcpy(void* dst, const void* src, size_t n) {
  const uint8_t* s = reinterpret_cast<const uint8_t*>(src);
  uint8_t* d = reinterpret_cast<uint8_t*>(dst);
  size_t vl = 0;

  while (n > 64) {
    vl = __riscv_vsetvl_e8m8(n);
    vuint8m8_t vload_data = __riscv_vle8_v_u8m8(s, vl);
    __riscv_vse8_v_u8m8(d, vload_data, vl);
    s += vl;
    d += vl;
    n -= vl;
  }

  switch ((n + 15) / 16) {
    case 4:
    case 3: {
      // 64 - 30
      vl = __riscv_vsetvl_e8m4(n);
      vuint8m4_t vload_data = __riscv_vle8_v_u8m4(s, vl);
      __riscv_vse8_v_u8m4(d, vload_data, vl);
      break;
    }
    case 2: {
      // 16 - 31
      vl = __riscv_vsetvl_e8m2(n);
      vuint8m2_t vload_data = __riscv_vle8_v_u8m2(s, vl);
      __riscv_vse8_v_u8m2(d, vload_data, vl);
      break;
    }
    case 1: {
      vl = __riscv_vsetvl_e8m1(n);
      vuint8m1_t vload_data = __riscv_vle8_v_u8m1(s, vl);
      __riscv_vse8_v_u8m1(d, vload_data, vl);
      break;
    }
  }

  return dst;
}

}  // namespace coralnpu_v2::opt

#endif  // OPT_RVV_OPT_H