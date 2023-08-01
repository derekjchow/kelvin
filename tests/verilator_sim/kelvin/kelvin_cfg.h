#ifndef TESTS_VERILATOR_SIM_KELVIN_KELVIN_CFG_H_
#define TESTS_VERILATOR_SIM_KELVIN_KELVIN_CFG_H_

#ifndef KELVIN_SIMD
#error KELVIN_SIMD must be defined in Environment or Makefile.
#elif KELVIN_SIMD == 128
constexpr int kVector = 128;
#elif KELVIN_SIMD == 256
constexpr int kVector = 256;
#elif KELVIN_SIMD == 512
constexpr int kVector = 512;
#else
#error KELVIN_SIMD unsupported configuration.
#endif

constexpr int ctz(int a) {
  if (a == 1) return 0;
  if (a == 2) return 1;
  if (a == 4) return 2;
  if (a == 8) return 3;
  if (a == 16) return 4;
  if (a == 32) return 5;
  if (a == 64) return 6;
  if (a == 128) return 7;
  if (a == 256) return 8;
  return -1;
}

// ISS defines.
constexpr uint32_t VLENB = kVector / 8;
constexpr uint32_t VLENH = kVector / 16;
constexpr uint32_t VLENW = kVector / 32;
constexpr uint32_t SM = 4;

constexpr int kDbusBits = ctz(kVector / 8) + 1;
constexpr int kVlenBits = ctz(kVector / 8) + 1 + 2;

// [External] System AXI.
constexpr int kAxiBits = 256;
constexpr int kAxiStrb = kAxiBits / 8;
constexpr int kAxiId = 7;

// [Internal] L1I AXI.
constexpr int kL1IAxiBits = 256;
constexpr int kL1IAxiStrb = kL1IAxiBits / 8;
constexpr int kL1IAxiId = 4;

// [Internal] L1D AXI.
constexpr int kL1DAxiBits = 256;
constexpr int kL1DAxiStrb = kL1DAxiBits / 8;
constexpr int kL1DAxiId = 4;

// [Internal] Uncached AXI[Vector,Scalar].
constexpr int kUncBits = kVector;
constexpr int kUncStrb = kVector / 8;
constexpr int kUncId = 6;

// Transaction is uncached (and bus width aligned).
static uint8_t is_uncached(const uint32_t addr) {
  // bit31==1 (0x80000000)
  return (addr & (1u << 31)) != 0;
}

constexpr int kAlignedLsb = ctz(kVector / 8);

#endif  // TESTS_VERILATOR_SIM_KELVIN_KELVIN_CFG_H_
