#include <cstddef>
#include <cstdint>

// Writes incrementing integers to an array, reads them back and returns the
// the accumulated sum.
template <typename T, int N>
int WriteReadAccumulateArray(volatile T* data) {
  for (int i = 0; i < N; i++) {
    data[i] = static_cast<T>(i);
  }
  int acc = 0;
  for (int i = 0; i < N; i++) {
    acc += data[i];
  }
  return acc;
}

volatile int8_t* extmem = reinterpret_cast<volatile int8_t*>(0x20000000L);

int main() {
  for (size_t i = 0; i < sizeof(int32_t); i++) {
    if (WriteReadAccumulateArray<int32_t, 4>(
            reinterpret_cast<volatile int32_t*>(extmem+i)) != 6) {
      return -1;
    }
  }

  for (size_t i = 0; i < sizeof(int16_t); i++) {
    if (WriteReadAccumulateArray<int16_t, 4>(
            reinterpret_cast<volatile int16_t*>(extmem+i)) != 6) {
      return -1;
    }
  }

  for (size_t i = 0; i < sizeof(int8_t); i++) {
    if (WriteReadAccumulateArray<int8_t, 4>(
            reinterpret_cast<volatile int8_t*>(extmem+i)) != 6) {
      return -1;
    }
  }

  volatile int32_t* extmem_boundary = reinterpret_cast<volatile int32_t*>(0x20000ffe);
  *extmem_boundary = 0xdeadbeef;

  if (*extmem_boundary != static_cast<int32_t>(0xdeadbeef)) {
    return -1;
  }
  return 0;
}