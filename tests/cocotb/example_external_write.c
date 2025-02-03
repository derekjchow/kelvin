/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// A Simple kelvin program to check writes from Kelvin over AXI.

#include <stdint.h>

int main(int argc, char *argv[]) {
  // CSR lives in [0x30000-0x31FFF]
  volatile uint32_t* output_data = (uint32_t*)0x00040000;

  {
    for (int i = 0; i < 4; i++) {
      output_data[i] = i+7000;
    }
  }

  asm volatile("wfi");

  return 0;
}
