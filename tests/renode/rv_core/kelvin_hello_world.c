/*
 * Copyright 2024 Google LLC
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

// A Simple kelvin program.

#include <stddef.h>
#include <stdint.h>

volatile uint32_t* uart0 = (uint32_t*)0x54000000L;
void putc(char ch) {
  *uart0 = ch;
}

char hex[] = {
  '0', '1', '2', '3',
  '4', '5', '6', '7',
  '8', '9', 'a', 'b',
  'c', 'd', 'e', 'f',
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
    putc(*s);
    s++;
  }
}

int main(int argc, char *argv[]) {
  uint32_t* rv_core_memory = (uint32_t*)0x20000000L;
  print_uint32(*rv_core_memory);
  print_string("beefb0ba\n");
  print_uint32(0xb0bacafeL);
  asm volatile(".word 0x26000077");  // flushall
  return 0;
}
