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
//
// Reference alu ops implementation
#ifndef TESTS_VERILATOR_SIM_CORALNPU_ALU_REF_H_
#define TESTS_VERILATOR_SIM_CORALNPU_ALU_REF_H_

#include <stdint.h>

#include <algorithm>
#include <limits>
#include <type_traits>
#include <utility>

// -----------------------------------------------------------------------------
// ALU.

template <typename T>
typename std::make_unsigned<T>::type absd(T a, T b) {
  using UT = typename std::make_unsigned<T>::type;
  UT ua = static_cast<UT>(a);
  UT ub = static_cast<UT>(b);
  return a > b ? ua - ub : ub - ua;
}

template <typename Td, typename Ts>
Td acc(Td a, Ts b) {
  assert(sizeof(Td) > sizeof(Ts));
  using UTd = typename std::make_unsigned<Td>::type;
  return static_cast<Td>(static_cast<UTd>(a) + static_cast<UTd>(b));
}

template <typename T>
T add(T a, T b) {
  using UT = typename std::make_unsigned<T>::type;
  return static_cast<T>(static_cast<UT>(a) + static_cast<UT>(b));
}

template <typename T>
T add3(T a, T b, T c) {
  using UT = typename std::make_unsigned<T>::type;
  return static_cast<T>(static_cast<UT>(a) + static_cast<UT>(b) +
                        static_cast<UT>(c));
}

// Saturated addition.
template <typename T>
T adds(T a, T b) {
  if (std::is_signed<T>::value) {
    int64_t m = static_cast<int64_t>(a) + static_cast<int64_t>(b);
    m = std::min<int64_t>(std::max<int64_t>(std::numeric_limits<T>::min(), m),
                          std::numeric_limits<T>::max());
    return m;
  }
  uint64_t m = static_cast<uint64_t>(a) + static_cast<uint64_t>(b);
  m = std::min<uint64_t>(std::numeric_limits<T>::max(), m);
  return m;
}

// Widening add.
template <typename T>
uint32_t addw(T a, T b) {
  if (std::is_signed<T>::value) {
    return int64_t(a) + int64_t(b);
  }
  return uint64_t(a) + uint64_t(b);
}

template <typename T>
T cmp_eq(T a, T b) {
  return a == b;
}

template <typename T>
T cmp_ne(T a, T b) {
  return a != b;
}

template <typename T>
T cmp_lt(T a, T b) {
  return a < b;
}

template <typename T>
T cmp_le(T a, T b) {
  return a <= b;
}

template <typename T>
T cmp_gt(T a, T b) {
  return a > b;
}

template <typename T>
T cmp_ge(T a, T b) {
  return a >= b;
}

template <typename T>
T dup(T b) {
  return b;
}

template <typename T>
T log_and(T a, T b) {
  return a & b;
}

template <typename T>
int log_clb(T x) {
  constexpr int n = sizeof(T) * 8;
  if (x & (1u << (n - 1))) {
    x = ~x;
  }
  for (int count = 0; count < n; count++) {
    if ((x << count) >> (n - 1)) {
      return count;
    }
  }
  return n;
}

template <typename T>
int log_clz(const T x) {
  constexpr int n = sizeof(T) * 8;
  for (int count = 0; count < n; count++) {
    if ((x << count) >> (n - 1)) {
      return count;
    }
  }
  return n;
}

template <typename T>
int log_cpop(T a) {
  constexpr int n = sizeof(T) * 8;
  int count = 0;
  for (int i = 0; i < n; i++) {
    if (a & (1 << i)) {
      count++;
    }
  }
  return count;
}

template <typename T>
T log_not(T a) {
  return ~a;
}

template <typename T>
T log_or(T a, T b) {
  return a | b;
}

template <typename T>
T log_rev(T a, T b) {
  T count = b & 0b11111;
  if (count & 1) a = ((a & 0x55555555) << 1) | ((a & 0xAAAAAAAA) >> 1);
  if (count & 2) a = ((a & 0x33333333) << 2) | ((a & 0xCCCCCCCC) >> 2);
  if (count & 4) a = ((a & 0x0F0F0F0F) << 4) | ((a & 0xF0F0F0F0) >> 4);
  if (sizeof(T) == 1) return a;
  if (count & 8) a = ((a & 0x00FF00FF) << 8) | ((a & 0xFF00FF00) >> 8);
  if (sizeof(T) == 2) return a;
  if (count & 16) a = ((a & 0x0000FFFF) << 16) | ((a & 0xFFFF0000) >> 16);
  return a;
}

template <typename T>
T log_ror(T a, T b) {
  if (sizeof(T) == 4) {
    if (b & 1) a = (a >> 1) | (a << 31);
    if (b & 2) a = (a >> 2) | (a << 30);
    if (b & 4) a = (a >> 4) | (a << 28);
    if (b & 8) a = (a >> 8) | (a << 24);
    if (b & 16) a = (a >> 16) | (a << 16);
  } else if (sizeof(T) == 2) {
    if (b & 1) a = (a >> 1) | (a << 15);
    if (b & 2) a = (a >> 2) | (a << 14);
    if (b & 4) a = (a >> 4) | (a << 12);
    if (b & 8) a = (a >> 8) | (a << 8);
  } else if (sizeof(T) == 1) {
    if (b & 1) a = (a >> 1) | (a << 7);
    if (b & 2) a = (a >> 2) | (a << 6);
    if (b & 4) a = (a >> 4) | (a << 4);
  } else {
    assert(false);
  }
  return a;
}

template <typename T>
T log_xor(T a, T b) {
  return a ^ b;
}

template <typename T>
T hadd(T a, T b, int r) {
  if (std::is_signed<T>::value) {
    return (static_cast<int64_t>(a) + static_cast<int64_t>(b) + r) >> 1;
  }
  return (static_cast<uint64_t>(a) + static_cast<uint64_t>(b) + r) >> 1;
}

template <typename T>
T hsub(T a, T b, int r) {
  if (std::is_signed<T>::value) {
    return (static_cast<int64_t>(a) - static_cast<int64_t>(b) + r) >> 1;
  }
  return (static_cast<uint64_t>(a) - static_cast<uint64_t>(b) + r) >> 1;
}

template <typename T>
T madd(T a, T b, T c) {
  if (std::is_signed<T>::value) {
    return static_cast<int64_t>(a) * static_cast<int64_t>(b) +
           static_cast<int64_t>(c);
  }
  return static_cast<uint64_t>(a) * static_cast<uint64_t>(b) +
         static_cast<uint64_t>(c);
}

template <typename T>
T max(T a, T b) {
  return a > b ? a : b;
}

template <typename T>
T min(T a, T b) {
  return a < b ? a : b;
}

template <typename T>
T mul(T a, T b) {
  return a * b;
}

template <typename T>
T muls(T a, T b) {
  if (std::is_signed<T>::value) {
    int64_t m = static_cast<int64_t>(a) * static_cast<int64_t>(b);
    m = std::max(
        static_cast<int64_t>(std::numeric_limits<T>::min()),
        std::min(static_cast<int64_t>(std::numeric_limits<T>::max()), m));
    return m;
  }
  uint64_t m = uint64_t(a) * uint64_t(b);
  m = std::min(static_cast<uint64_t>(std::numeric_limits<T>::max()), m);
  return m;
}

// Widening multiplication.
template <typename T>
uint32_t mulw(T a, T b) {
  if (std::is_signed<T>::value) {
    return static_cast<int64_t>(a) * static_cast<int64_t>(b);
  }
  return static_cast<uint64_t>(a) * static_cast<uint64_t>(b);
}

template <typename T>
T mv(T a) {
  return a;
}

template <typename T>
std::pair<T, T> mvp(T a, T b) {
  return {a, b};
}

template <typename T>
T dmulh(T a, T b, bool r, bool neg) {
  constexpr int n = sizeof(T) * 8;
  constexpr T maxNeg = 0x80000000 >> (32 - n);
  int64_t m = static_cast<int64_t>(a) * static_cast<int64_t>(b);
  if (r) {
    int64_t rnd = 0x40000000ll >> (32 - n);
    if (m < 0 && neg) {
      rnd = (-0x40000000ll) >> (32 - n);
    }
    m += rnd;
  }
  m >>= (n - 1);

  if (a == maxNeg && b == maxNeg) {
    m = 0x7fffffff >> (32 - n);
  }

  return m;
}

template <typename T>
T mulh(T a, T b, bool r) {
  constexpr int n = sizeof(T) * 8;
  if (std::is_signed<T>::value) {
    int64_t m = static_cast<int64_t>(a) * static_cast<int64_t>(b);
    m += r ? 1ll << (n - 1) : 0;
    return static_cast<uint64_t>(m) >> n;
  }
  uint64_t m = static_cast<uint64_t>(a) * static_cast<uint64_t>(b);
  m += r ? 1ull << (n - 1) : 0;
  return m >> n;
}

template <typename T>
int32_t padd(T a, T b) {
  if (std::is_signed<T>::value) {
    return int64_t(a) + int64_t(b);
  }
  return uint64_t(a) + uint64_t(b);
}

template <typename T>
uint32_t psub(T a, T b) {
  if (std::is_signed<T>::value) {
    return int64_t(a) - int64_t(b);
  }
  return uint64_t(a) - uint64_t(b);
}

template <typename T>
T rsub(T a, T b) {
  using UT = typename std::make_unsigned<T>::type;
  return static_cast<T>(static_cast<UT>(b) - static_cast<UT>(a));
}

template <typename T>
T shl(T a, T b) {
  constexpr int n = sizeof(T) * 8;
  b &= (n - 1);
  return a << b;
}

template <typename T>
T shr(T a, T b) {
  constexpr int n = sizeof(T) * 8;
  b &= (n - 1);
  return a >> b;
}

template <typename T1, typename T2>
T1 srans(T2 a, T1 b, bool r, bool u) {
  static_assert(2 * sizeof(T1) == sizeof(T2) || 4 * sizeof(T1) == sizeof(T2));
  assert(std::is_signed<T1>::value == true);
  assert(std::is_signed<T2>::value == true);
  constexpr int n = sizeof(T2) * 8;
  constexpr int m = sizeof(T1) * 8;
  b &= (n - 1);
  int64_t pad_a = u ? (int64_t(a) & ((1ll << n) - 1)) : int64_t(a);
  int64_t s = (pad_a + (b && r ? (1ll << (b - 1)) : 0)) >> b;
  int64_t neg_max = !u ? -1ll << (m - 1) : 0;
  int64_t pos_max = !u ? (1ll << (m - 1)) - 1 : (1ull << m) - 1;
  bool neg_sat = s < neg_max;
  bool pos_sat = s > pos_max;
  bool zero = !a;
  if (neg_sat) return neg_max;
  if (pos_sat) return pos_max;
  if (zero) return 0;
  return s;
}

template <typename T>
T shf(T a, T b, bool r) {
  if (std::is_signed<T>::value == true) {
    constexpr int n = sizeof(T) * 8;
    int shamt = b;
    int64_t s = a;
    if (!a) {
      return 0;
    } else if (a < 0 && shamt >= n) {
      s = -1 + r;
    } else if (a > 0 && shamt >= n) {
      s = 0;
    } else if (shamt > 0) {
      s = (static_cast<int64_t>(a) + (r ? (1ll << (shamt - 1)) : 0)) >> shamt;
    } else {  // shmat < 0
      using UT = typename std::make_unsigned<T>::type;
      UT ushamt = static_cast<UT>(-shamt <= n ? -shamt : n);
      s = static_cast<int64_t>(static_cast<uint64_t>(a) << ushamt);
    }

    int64_t neg_max = -1ll << (n - 1);
    int64_t pos_max = (1ll << (n - 1)) - 1;
    bool neg_sat = a < 0 && (shamt <= -n || s < neg_max);
    bool pos_sat = a > 0 && (shamt <= -n || s > pos_max);
    if (neg_sat) return neg_max;
    if (pos_sat) return pos_max;

    return s;
  }
  constexpr int n = sizeof(T) * 8;
  int shamt = static_cast<typename std::make_signed<T>::type>(b);
  uint64_t s = a;
  if (!a) {
    return 0;
  } else if (shamt > n) {
    s = 0;
  } else if (shamt > 0) {
    s = (static_cast<uint64_t>(a) + (r ? (1ull << (shamt - 1)) : 0)) >> shamt;
  } else {  // shamt < 0
    T ushamt = static_cast<T>(-shamt <= n ? -shamt : n);
    s = static_cast<uint64_t>(a) << (ushamt);
  }

  uint64_t pos_max = (1ull << n) - 1;
  bool pos_sat = a && (shamt < -n || s >= (1ull << n));
  if (pos_sat) return pos_max;

  return s;
}

template <typename T>
T sub(T a, T b) {
  using UT = typename std::make_unsigned<T>::type;
  return static_cast<T>(static_cast<UT>(a) - static_cast<UT>(b));
}

// Saturated subtraction.
template <typename T>
T subs(T a, T b) {
  if (std::is_signed<T>::value) {
    int64_t m = static_cast<int64_t>(a) - static_cast<int64_t>(b);
    m = std::min<int64_t>(std::max<int64_t>(std::numeric_limits<T>::min(), m),
                          std::numeric_limits<T>::max());
    return m;
  }
  return a < b ? 0 : a - b;
}

template <typename T>
uint32_t subw(T a, T b) {
  if (std::is_signed<T>::value) {
    return static_cast<int64_t>(a) - static_cast<int64_t>(b);
  }
  return static_cast<uint64_t>(a) - static_cast<uint64_t>(b);
}

#endif  // TESTS_VERILATOR_SIM_CORALNPU_ALU_REF_H_
