#include <stdint.h>
#include <riscv_vector.h>

int main() {
  unsigned vlen = __riscv_vlenb();
  vuint8m1_t zeros = __riscv_vmv_v_x_u8m1(0, 16);
  vuint8m1_t ones = __riscv_vmv_v_x_u8m1(1, 16);
  vuint8m1_t indices = __riscv_vid_v_u8m1(16);
  vuint8m1_t add = __riscv_vadd_vv_u8m1(ones, indices, 16);

  vuint8m1_t reduce_sum = __riscv_vredsum_vs_u8m1_u8m1(
      add, zeros, 16);

  return __riscv_vmv_x_s_u8m1_u8(reduce_sum);
}
