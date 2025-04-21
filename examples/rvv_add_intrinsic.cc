// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <riscv_vector.h>
#include <string.h>

int8_t input_1[1024];
int8_t input_2[1024];
int16_t output[1024];

int main() {

  memset(input_1, 1, 1024);
  memset(input_2, 6, 1024);
  const int8_t* input1_ptr = &input_1[0];
  const int8_t* input2_ptr = &input_2[0];
  int16_t* output_ptr = &output[0];

  for (int idx = 0; (idx + 31) < 1024; idx += 32) {
    vint8m4_t input_v2 = __riscv_vle8_v_i8m4(input2_ptr + idx, 32);
    vint8m4_t input_v1 = __riscv_vle8_v_i8m4(input1_ptr + idx, 32);

    vint16m8_t temp_sum = __riscv_vwadd_vv_i16m8(input_v1, input_v2, 32);
    // results are stored back into the output vector
    __riscv_vse16_v_i16m8(output_ptr + idx, temp_sum, 32);
  }

  return 0;
}
