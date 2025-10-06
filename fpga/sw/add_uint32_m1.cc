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

#include <riscv_vector.h>

uint32_t in_buf_1[16] __attribute__((aligned(16)));
uint32_t in_buf_2[16] __attribute__((aligned(16)));
uint32_t out_buf[16] __attribute__((aligned(16)));

void add_u32_m1(const uint32_t *in_buf_1, const uint32_t *in_buf_2,
                uint32_t *out_buf) {
  vuint32m1_t input_v1 = __riscv_vle32_v_u32m1(in_buf_1, 4);
  vuint32m1_t input_v2 = __riscv_vle32_v_u32m1(in_buf_2, 4);
  vuint32m1_t add_result = __riscv_vadd_vv_u32m1(input_v1, input_v2, 4);
  __riscv_vse32_v_u32m1(out_buf, add_result, 4);
}

int main(int argc, char **argv) {
  add_u32_m1(in_buf_1, in_buf_2, out_buf);

  // Configure UART1.
  // The NCO is calculated as: (baud_rate * 2^20) / clock_frequency
  // In our case: (115200 * 2^20) / (CLOCK_FREQUENCY_MHZ * 1000000)
  volatile unsigned int *uart_ctrl =
      reinterpret_cast<volatile unsigned int *>(0x40010010);
  const uint64_t uart_ctrl_nco =
      ((uint64_t)115200 << 20) / (CLOCK_FREQUENCY_MHZ * 1000000);
  // Enable TX and RX, and set the NCO value.
  *uart_ctrl = (uart_ctrl_nco << 16) | 3;

  auto uart_print = [](const char *str) {
    volatile char *uart_wdata = reinterpret_cast<volatile char *>(0x4001001c);
    volatile unsigned int *uart_status =
        reinterpret_cast<volatile unsigned int *>(0x40010014);

    while (*str) {
      // Wait until TX FIFO is not full.
      while (*uart_status & 1) {
        asm volatile("nop");
      }
      *uart_wdata = *str++;
    }
  };

  uart_print("Hello from CoralNPU!\n");

  return 0;
}
