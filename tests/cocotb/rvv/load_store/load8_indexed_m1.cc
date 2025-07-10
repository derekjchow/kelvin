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

uint8_t input_indices[128] __attribute__((section(".data")));
uint8_t input_data[4096] __attribute__((section(".data")));
uint8_t output_data[128] __attribute__((section(".data")));

int main(int argc, char **argv) {
  vuint8m1_t indices = __riscv_vle8_v_u8m1(input_indices, /*vl=*/16);
  vuint8m1_t data = __riscv_vloxei8_v_u8m1(input_data, indices, /*vl=*/16);
  __riscv_vse8_v_u8m1(output_data, data, /*vl=*/16);

  return 0;
}
