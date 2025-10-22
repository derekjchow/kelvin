#include <riscv_vector.h>
#include <stdint.h>

constexpr size_t kLhsRows = 16;
constexpr size_t kRhsCols = 16;
constexpr size_t kInner = 48;

// mcontext0 val used in test for power period extraction
// mcontext0 is io_coralnpu_csr_value_8 in waveform
uint32_t mcontext0_write_value;

int8_t lhs_input[kLhsRows * kInner] __attribute__((section(".data")))
__attribute__((aligned(16)));
int8_t rhs_input[kInner * kRhsCols] __attribute__((section(".data")))
__attribute__((aligned(16)));
int32_t result_output[kLhsRows * kRhsCols] __attribute__((section(".data")))
__attribute__((aligned(16)));

// Assume rhs is column major.
void MatMul(size_t lhs_rows, size_t inner, size_t rhs_cols, const int8_t* lhs,
            const int8_t* rhs, int32_t* result) {
  const size_t vlenb = __riscv_vlenb();

  for (size_t r = 0; r < lhs_rows; r++) {
    const int8_t* lhs_data = lhs + (r * inner);
    int32_t* result_row = result + (r * rhs_cols);
    for (size_t c = 0; c < rhs_cols; c++) {
      const int8_t* rhs_data = rhs + (c * inner);
      // Reset accumulators
      vint32m1_t vacc = __riscv_vmv_v_x_i32m1(0, 1);

      // Inner dot product loop
      size_t k = 0;
      size_t vl = vlenb;
      while (k < inner) {
        if (inner - k < vl) {
          vl = inner - k;
        }
        // Load weights/activations
        vint8m1_t vlhs_data = __riscv_vle8_v_i8m1(lhs_data + k, vl);
        vint8m1_t vrhs_data =
            __riscv_vle8_v_i8m1(rhs_data + k, vl);  // input rhs is transposed
        vint16m2_t vmul_16 = __riscv_vwmul_vv_i16m2(vlhs_data, vrhs_data, vl);
        vacc = __riscv_vwredsum_vs_i16m2_i32m1(vmul_16, vacc, vlenb);
        k += vl;
      }
      __riscv_vse32_v_i32m1(result_row + c, vacc, 1);
    }
  }
}

int main() {
  mcontext0_write_value = 0x01;
  asm volatile("csrw 0x7C0, %0" : : "r"(mcontext0_write_value));
  MatMul(kLhsRows, kInner, kRhsCols, lhs_input, rhs_input, result_output);
  mcontext0_write_value = 0x00;
  asm volatile("csrw 0x7C0, %0" : : "r"(mcontext0_write_value));
  return 0;
}
