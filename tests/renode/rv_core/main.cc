/*
 * Copyright 2024 Google LLC
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

#include <cstdint>

#include "kelvin_hello_world_cc.h"

volatile uint32_t* uart0 = (uint32_t*)0x54000000L;
void putc(char ch) {
    *uart0 = ch;
}

char hex[] = {
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
};
void print_uint32(uint32_t val) {
  putc('0');
  putc('x');
  for (int i = 7; i >= 0; --i) {
    putc(hex[(val >> (i * 4)) & 0xF]);
  }
  putc('\n');
}

void print_string(const char* s) {
  while (*s) {
    putc(*s++);
  }
}

void main(void) {
  volatile uint8_t* kelvin_itcm = (uint8_t*)0x70000000L;
  for (int i = 0; i < kelvin_hello_world_cc_bin_len; ++i) {
      kelvin_itcm[i] = kelvin_hello_world_cc_bin[i];
  }
  volatile uint32_t* kelvin_reset_csr = (uint32_t*)0x70002000L;
  // Disable clock gate
  *kelvin_reset_csr = 1;

  // Tick a few cycles to allow Kelvin to reset.
  for (volatile int i = 0; i < 10; ++i) {
    asm volatile("nop");
  }

  // Release reset
  *kelvin_reset_csr = 0;

  // Spin a while to let Kelvin execute.
  for (volatile int i = 0; i < 2; ++i) {
      for (int i = 0; i < 100; i++) {
          asm volatile ("nop");
      }
  }

  volatile uint32_t* kelvin_status_csr = (uint32_t*)0x70002008L;
  while (true) {
    uint32_t status = *kelvin_status_csr;
    if (status) break;
  }

  volatile uint32_t* kelvin_csrs = (uint32_t*)0x70002100L;
  for (int i = 0; i < 8; ++i) {
    print_uint32(*(kelvin_csrs + i));
  }

  uint32_t status = *kelvin_status_csr;
  if ((status & 3) == 3) {
    print_string("FAIL\n");
  } else if ((status & 1) == 1) {
    print_string("PASS\n");
  }

  *kelvin_reset_csr = 3;
  while (true) {
    asm volatile("wfi");
  }
}
