#include <cstddef>
#include <cstdint>

volatile int8_t* extmem = reinterpret_cast<volatile int8_t*>(0x20000000L);

int main() {
  reinterpret_cast<volatile int32_t*>(extmem)[0] = 0xDEADBEEF;
  int32_t x = *reinterpret_cast<volatile int32_t*>(extmem);
  reinterpret_cast<volatile int32_t*>(extmem)[1] = x;

  asm("wfi");
  return 0;
}
