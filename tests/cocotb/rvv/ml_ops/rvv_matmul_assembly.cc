#include <riscv_vector.h>
#include <stdint.h>

constexpr size_t kLhsRows = 16;
constexpr size_t kRhsCols = 16;
constexpr size_t kInner = 24;

int8_t lhs_input[kLhsRows*kInner] __attribute__((section(".data"))) __attribute__((aligned(16)));
int8_t rhs_input[kInner*kRhsCols] __attribute__((section(".data"))) __attribute__((aligned(16)));
int32_t result_output[kLhsRows*kRhsCols] __attribute__((section(".data"))) __attribute__((aligned(16)));

// Assume rhs is column major.
void MatMul(size_t lhs_rows, size_t inner, size_t rhs_cols,
            const int8_t* lhs, const int8_t* rhs, int32_t* result) {
  const size_t vlenb = __riscv_vlenb();

  // Create zero register for vredsum
  asm("vsetvli zero, %0, e32, m4, ta, ma;"
      "vmv.v.i v0, 0;" : : "r" (vlenb));

  for (size_t r = 0; r < lhs_rows; r++) {
    const int8_t* lhs_data = lhs + (r * inner);
    int32_t* result_row = result + (r * rhs_cols);
    for (size_t c = 0; c < rhs_cols; c++) {
      const int8_t* rhs_data = rhs + (c * inner);

      // Reset accumulators
      asm("vsetvli zero, %0, e32, m4, ta, ma" : : "r" (vlenb));
      asm("vmv.v.i v8, 0");

      // Inner dot product loop
      size_t k = 0;
      size_t vl = vlenb;
      while (k < inner) {
        if (inner - k < vl) {
          vl = inner - k;
        }
        // Load weights/activations
        asm("vsetvli zero, %0, e8, m1, ta, ma" : : "r" (vl));
        asm("vle8.v  v14, (%0)" : : "r" (lhs_data + k));
        asm("vle8.v  v15, (%0)" : : "r" (rhs_data + k));

        // Multiply-accumulate
        asm("vsetvli zero, %0, e8, m1, ta, ma;"
            "vwmul.vv v12, v14, v15;"
            "vsetvli zero, %0, e16, m2, ta, ma;"
            "vwadd.wv v8, v8, v12;" : : "r" (vl));

        k += vl;
      }

      // Reduction
      asm("vsetvli zero, %0, e32, m4, ta, ma;"
          "vredsum.vs v8, v8, v0;" : : "r" (vlenb));

      // Store
      asm("vsetivli zero, 1, e32, m1, ta, ma;"
          "vse32.v v8, (%0);" : : "r" (result_row + c));
    }
  }
}

int main() {
  MatMul(kLhsRows, kInner, kRhsCols, lhs_input, rhs_input, result_output);
  return 0;
}