#include "coralnpu_test_utils/rvv_cpp_util.h"

#include <type_traits>

size_t vl __attribute__((section(".data"))) = 16;
uint8_t vs1[128] __attribute__((section(".data")));
size_t xs2 __attribute__((section(".data")));
uint8_t vd[128] __attribute__((section(".data")));

#ifndef VX_FUNCTION
#define VX_FUNCTION Vadd
#endif

template<typename T, Lmul lmul>
inline void test_binary_vx_op() {
  const auto v1 = Vle<T, lmul>(reinterpret_cast<const T*>(vs1), vl);
#ifdef FORCE_X_UNSIGNED
  const auto result = VX_FUNCTION<T, lmul>(
      v1, static_cast<std::make_unsigned_t<T>>(xs2), vl);
#else
  const auto result = VX_FUNCTION<T, lmul>(v1, static_cast<T>(xs2), vl);
#endif
  Vse<T, lmul>(reinterpret_cast<T*>(vd), result, vl);
}

extern "C" {
#define FN_ATTR __attribute__((used, retain))
#ifndef UNSIGNED_ONLY
FN_ATTR void test_i8_mf4()  { test_binary_vx_op<int8_t,   Lmul::MF4>(); }
FN_ATTR void test_i8_mf2()  { test_binary_vx_op<int8_t,   Lmul::MF2>(); }
FN_ATTR void test_i8_m1()   { test_binary_vx_op<int8_t,   Lmul::M1>(); }
FN_ATTR void test_i8_m2()   { test_binary_vx_op<int8_t,   Lmul::M2>(); }
FN_ATTR void test_i8_m4()   { test_binary_vx_op<int8_t,   Lmul::M4>(); }
FN_ATTR void test_i8_m8()   { test_binary_vx_op<int8_t,   Lmul::M8>(); }
FN_ATTR void test_i16_mf2() { test_binary_vx_op<int16_t,  Lmul::MF2>(); }
FN_ATTR void test_i16_m1()  { test_binary_vx_op<int16_t,  Lmul::M1>(); }
FN_ATTR void test_i16_m2()  { test_binary_vx_op<int16_t,  Lmul::M2>(); }
FN_ATTR void test_i16_m4()  { test_binary_vx_op<int16_t,  Lmul::M4>(); }
FN_ATTR void test_i16_m8()  { test_binary_vx_op<int16_t,  Lmul::M8>(); }
FN_ATTR void test_i32_m1()  { test_binary_vx_op<int32_t,  Lmul::M1>(); }
FN_ATTR void test_i32_m2()  { test_binary_vx_op<int32_t,  Lmul::M2>(); }
FN_ATTR void test_i32_m4()  { test_binary_vx_op<int32_t,  Lmul::M4>(); }
FN_ATTR void test_i32_m8()  { test_binary_vx_op<int32_t,  Lmul::M8>(); }
#endif

#ifndef SIGNED_ONLY
FN_ATTR void test_u8_mf4()  { test_binary_vx_op<uint8_t,  Lmul::MF4>(); }
FN_ATTR void test_u8_mf2()  { test_binary_vx_op<uint8_t,  Lmul::MF2>(); }
FN_ATTR void test_u8_m1()   { test_binary_vx_op<uint8_t,  Lmul::M1>(); }
FN_ATTR void test_u8_m2()   { test_binary_vx_op<uint8_t,  Lmul::M2>(); }
FN_ATTR void test_u8_m4()   { test_binary_vx_op<uint8_t,  Lmul::M4>(); }
FN_ATTR void test_u8_m8()   { test_binary_vx_op<uint8_t,  Lmul::M8>(); }
FN_ATTR void test_u16_mf2() { test_binary_vx_op<uint16_t, Lmul::MF2>(); }
FN_ATTR void test_u16_m1()  { test_binary_vx_op<uint16_t, Lmul::M1>(); }
FN_ATTR void test_u16_m2()  { test_binary_vx_op<uint16_t, Lmul::M2>(); }
FN_ATTR void test_u16_m4()  { test_binary_vx_op<uint16_t, Lmul::M4>(); }
FN_ATTR void test_u16_m8()  { test_binary_vx_op<uint16_t, Lmul::M8>(); }
FN_ATTR void test_u32_m1()  { test_binary_vx_op<uint32_t, Lmul::M1>(); }
FN_ATTR void test_u32_m2()  { test_binary_vx_op<uint32_t, Lmul::M2>(); }
FN_ATTR void test_u32_m4()  { test_binary_vx_op<uint32_t, Lmul::M4>(); }
FN_ATTR void test_u32_m8()  { test_binary_vx_op<uint32_t, Lmul::M8>(); }
#endif
}

#ifdef UNSIGNED_ONLY
void (*impl)() __attribute__((section(".data"))) = &test_u8_m1;
#else
void (*impl)() __attribute__((section(".data"))) = &test_i8_m1;
#endif

int main() {
  impl();
  return 0;
}