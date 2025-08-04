#include <stdint.h>

#include <cstring>

#include "fpga/add_uint32_m1_bin_header.h"

extern "C" int main() {
  // Copy the embedded binary to Kelvin's ITCM at 0x0.
  void *itcm_base = reinterpret_cast<void *>(static_cast<uintptr_t>(0x0));
  memcpy(itcm_base, add_uint32_m1_bin, add_uint32_m1_bin_len);

  // Kelvin run sequence
  volatile unsigned int *kelvin_reset_csr =
      reinterpret_cast<volatile unsigned int *>(
          static_cast<uintptr_t>(0x00030000));

  // Release clock gate
  *kelvin_reset_csr = 1;

  // Wait one cycle
  __asm__ volatile("nop");

  // Release reset
  *kelvin_reset_csr = 0;

  volatile unsigned int *kelvin_status_csr =
      reinterpret_cast<volatile unsigned int *>(
          static_cast<uintptr_t>(0x00030008));
  // Wait for Kelvin to halt
  while (!(*kelvin_status_csr & 1)) {
    for (int i = 0; i < 1000; ++i) {
      __asm__ volatile("nop");
    }
  }

  // Configure UART0.
  // The NCO is calculated as: (baud_rate * 2^20) / clock_frequency
  // In our case: (115200 * 2^20) / (CLOCK_FREQUENCY_MHZ * 1000000)
  volatile unsigned int *uart_ctrl =
      reinterpret_cast<volatile unsigned int *>(0x40000010);
  const uint64_t uart_ctrl_nco =
      ((uint64_t)115200 << 20) / (CLOCK_FREQUENCY_MHZ * 1000000);
  // Enable TX and RX, and set the NCO value.
  *uart_ctrl = (uart_ctrl_nco << 16) | 3;

  auto uart_print = [](const char *str) {
    volatile char *uart_wdata = reinterpret_cast<volatile char *>(0x4000001c);
    volatile unsigned int *uart_status =
        reinterpret_cast<volatile unsigned int *>(0x40000014);

    while (*str) {
      // Wait until TX FIFO is not full.
      while (*uart_status & 1) {
        asm volatile("nop");
      }
      *uart_wdata = *str++;
    }
  };

  uart_print("Kelvin halted, as expected.\n");

  volatile unsigned int *sram = (volatile unsigned int *)0x20000000;
  *sram = 0xdeadbeef;
  while (*sram != 0xdeadbeef) {
    asm volatile("nop");
  }

  return 0;
}