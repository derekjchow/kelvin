// #include "stdint.h"
typedef unsigned int uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;
typedef signed int int32_t;

#define AXI_ADDR 0x20000000

int main() {

  int32_t magic_number;

  magic_number = 0xdeadbeef;

  *(volatile uint32_t*)(AXI_ADDR) = magic_number;
  *(volatile uint32_t*)(AXI_ADDR+4) = magic_number;
  *(volatile uint32_t*)(AXI_ADDR+8) = magic_number;
  *(volatile uint32_t*)(AXI_ADDR+0xc) = magic_number;

  // Read a new magic number
  magic_number = *(volatile uint32_t*)(AXI_ADDR);

  *(volatile uint8_t*)(AXI_ADDR) = magic_number;
  *(volatile uint16_t*)(AXI_ADDR+2) = magic_number;
  *(volatile uint32_t*)(AXI_ADDR+30) = magic_number;

  //asm volatile(".word 0x08000073");
  asm volatile("ebreak");

}