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

// Enough space for m2.
uint8_t buffer[4096] __attribute__((section(".data")));
uint8_t* in_ptr = &(buffer[0]);
uint8_t* out_ptr = &(buffer[0]);
size_t vl = 16;

int main(int argc, char **argv) {
  vuint8m2_t v = __riscv_vle8_v_u8m2(in_ptr, vl);
  __riscv_vse8_v_u8m2(out_ptr, v, vl);

  return 0;
}
