// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef TESTS_VERILATOR_SIM_CORALNPU_CORALNPU_CFG_H_
#define TESTS_VERILATOR_SIM_CORALNPU_CORALNPU_CFG_H_

#ifndef CORALNPU_SIMD
#error CORALNPU_SIMD must be defined in Environment or Makefile.
#elif (CORALNPU_SIMD == 128) || (CORALNPU_SIMD == 256) || (CORALNPU_SIMD == 512)
constexpr int kVector = CORALNPU_SIMD;
#else
#error CORALNPU_SIMD unsupported configuration.
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

constexpr int kAlignedLsb = ctz(kVector / 8);

#endif  // TESTS_VERILATOR_SIM_CORALNPU_CORALNPU_CFG_H_
