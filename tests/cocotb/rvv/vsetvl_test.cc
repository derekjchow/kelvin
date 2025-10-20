// Copyright 2025 Google LLC
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

#include <riscv_vector.h>
#include <stdint.h>

// e0, m1, ma, ta
uint32_t vtype __attribute((section(".data"))) = 0xC0;
size_t avl __attribute((section(".data"))) = 16;
// One for vset*'s rd, the other one for csrr.
size_t vl_out1, vl_out2;
uint32_t vtype_out;

extern "C" {
__attribute__((used, retain)) void vsetvl_max() {
  asm("vsetvl %[vl_out1], zero, %[vtype];"
      "csrr %[vl_out2], vl;"
      "csrr %[vtype_out], vtype;"
      : [vl_out1] "=r"(vl_out1), [vl_out2] "=r"(vl_out2),
        [vtype_out] "=r"(vtype_out)
      : [vtype] "r"(vtype)
      : "vtype", "vl");
}

__attribute__((used, retain)) void vsetvl_keep() {
  asm("vsetvl %[vl_out1], %[avl], %[vtype];"
      "vsetvl zero, zero, %[vtype];"
      "csrr %[vl_out2], vl;"
      "csrr %[vtype_out], vtype;"
      : [vl_out1] "=r"(vl_out1), [vl_out2] "=r"(vl_out2),
        [vtype_out] "=r"(vtype_out)
      : [avl] "r"(avl), [vtype] "r"(vtype)
      : "vtype", "vl");
}

#define CREATE_VSETVLI_FN(name, sew, lmul)                  \
  __attribute__((used, retain)) void name() {               \
    asm("vsetvli %[vl_out1], zero, " #sew ", " #lmul        \
        ", ta, ma;"                                         \
        "csrr %[vl_out2], vl;"                              \
        "csrr %[vtype_out], vtype;"                         \
        : [vl_out1] "=r"(vl_out1), [vl_out2] "=r"(vl_out2), \
          [vtype_out] "=r"(vtype_out)                       \
        : [avl] "r"(avl), [vtype] "r"(vtype)                \
        : "vtype", "vl");                                   \
  }

CREATE_VSETVLI_FN(vsetvli_max_e8mf4, e8, mf4)
CREATE_VSETVLI_FN(vsetvli_max_e8mf2, e8, mf2)
CREATE_VSETVLI_FN(vsetvli_max_e8m1, e8, m1)
CREATE_VSETVLI_FN(vsetvli_max_e8m2, e8, m2)
CREATE_VSETVLI_FN(vsetvli_max_e8m4, e8, m4)
CREATE_VSETVLI_FN(vsetvli_max_e8m8, e8, m8)

CREATE_VSETVLI_FN(vsetvli_max_e16mf2, e16, mf2)
CREATE_VSETVLI_FN(vsetvli_max_e16m1, e16, m1)
CREATE_VSETVLI_FN(vsetvli_max_e16m2, e16, m2)
CREATE_VSETVLI_FN(vsetvli_max_e16m4, e16, m4)
CREATE_VSETVLI_FN(vsetvli_max_e16m8, e16, m8)

CREATE_VSETVLI_FN(vsetvli_max_e32m1, e32, m1)
CREATE_VSETVLI_FN(vsetvli_max_e32m2, e32, m2)
CREATE_VSETVLI_FN(vsetvli_max_e32m4, e32, m4)
CREATE_VSETVLI_FN(vsetvli_max_e32m8, e32, m8)

__attribute__((used, retain)) void vsetvli_keep() {
  asm("vsetvl %[vl_out1], %[avl], %[vtype];"
      // e8 m8 is able to keep any valid vl on any vtype
      "csrr %[vtype_out], vtype;"
      "vsetvli zero, zero, e8, m8, ta, ma;"
      "csrr %[vl_out2], vl;"
      : [vl_out1] "=r"(vl_out1), [vl_out2] "=r"(vl_out2),
        [vtype_out] "=r"(vtype_out)
      : [avl] "r"(avl), [vtype] "r"(vtype)
      : "vtype", "vl");
}
}

void (*impl)() __attribute__((section(".data"))) = vsetvl_max;

int main(int argc, char** argv) {
  impl();

  return 0;
}
