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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_VALU_H_
#define TESTS_VERILATOR_SIM_CORALNPU_VALU_H_

#include "tests/verilator_sim/coralnpu/alu_ref.h"
#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/coralnpu/vencodeop.h"

constexpr int kLanes = kVector / 32;
constexpr int kReadPorts = 7;
constexpr int kWritePorts = 4;

struct valu_t {
  uint8_t op : 7;
  uint8_t f2 : 3;
  uint8_t sz : 3;
  struct {
    uint32_t data[kLanes];
  } in[kReadPorts];
  struct {
    uint32_t data[kLanes];
  } out[kWritePorts];
  struct {
    uint32_t data;
  } sv;
  // Tracking the read/write/scalar controls.
  struct {
    bool valid;
    uint8_t addr : 6;
    uint8_t tag : 1;
  } r[kReadPorts];
  struct {
    bool valid;
    uint8_t addr : 6;
  } w[kWritePorts];
  struct {
    bool valid;
  } scalar;

  bool operator!=(const valu_t& rhs) const {
    if (w[0].valid != rhs.w[0].valid) return true;
    if (w[1].valid != rhs.w[1].valid) return true;
    if (w[0].valid && w[0].addr != rhs.w[0].addr) return true;
    if (w[1].valid && w[1].addr != rhs.w[1].addr) return true;
    for (int i = 0; i < kLanes; ++i) {
      if (w[0].valid && out[0].data[i] != rhs.out[0].data[i]) return true;
      if (w[1].valid && out[1].data[i] != rhs.out[1].data[i]) return true;
    }
    return false;
  }

  void print(const char* name, const bool inputs = false) {
    printf("[%s] op=%d f2=%d sz=%d valid=[%d,%d]  waddr=%d", name, op, f2, sz,
           w[0].valid, w[1].valid, w[0].valid ? w[0].addr : 0);
    if (w[1].valid) {
      printf(" {%d}", w[1].addr);
    }
    printf("  wdata =");
    for (int i = 0; i < kLanes; ++i) {
      printf(" %08x", w[0].valid ? out[0].data[i] : 0);
    }
    if (w[1].valid) {
      printf(" : {");
      for (int i = 0; i < kLanes; ++i) {
        printf(" %08x", out[1].data[i]);
      }
      printf(" }");
    }
    printf("\n");
    if (inputs) {
      printf("\n");
      for (int i = 0; i < kReadPorts; ++i) {
        printf("                                               read%d =", i);
        for (int j = 0; j < kLanes; ++j) {
          printf(" %08x", in[i].data[j]);
        }
        printf("\n");
      }
    }
  }
};

#define VOP1U(func)                                                  \
  if (sz == 1) {                                                     \
    v = 1;                                                           \
    x = func(uint8_t(a)) | func(uint8_t(a >> 8)) << 8 |              \
        func(uint8_t(a >> 16)) << 16 | func(uint8_t(a >> 24)) << 24; \
  }                                                                  \
  if (sz == 2) {                                                     \
    v = 1;                                                           \
    x = func(uint16_t(a)) | func(uint16_t(a >> 16)) << 16;           \
  }                                                                  \
  if (sz == 4) {                                                     \
    v = 1;                                                           \
    x = func(uint32_t(a));                                           \
  }

#define VOP1PU(func)                                                 \
  if (sz == 1) {                                                     \
    v = 1;                                                           \
    w = 1;                                                           \
    x = func(uint8_t(a)) | func(uint8_t(a >> 8)) << 8 |              \
        func(uint8_t(a >> 16)) << 16 | func(uint8_t(a >> 24)) << 24; \
    y = func(uint8_t(c)) | func(uint8_t(c >> 8)) << 8 |              \
        func(uint8_t(c >> 16)) << 16 | func(uint8_t(c >> 24)) << 24; \
  }                                                                  \
  if (sz == 2) {                                                     \
    v = 1;                                                           \
    w = 1;                                                           \
    x = func(uint16_t(a)) | func(uint16_t(a >> 16)) << 16;           \
    y = func(uint16_t(c)) | func(uint16_t(c >> 16)) << 16;           \
  }                                                                  \
  if (sz == 4) {                                                     \
    v = 1;                                                           \
    w = 1;                                                           \
    x = func(uint32_t(a));                                           \
    y = func(uint32_t(c));                                           \
  }

#define VOPXU(func)                                                  \
  if (sz == 1) {                                                     \
    v = 1;                                                           \
    x = func(uint8_t(b)) | func(uint8_t(b >> 8)) << 8 |              \
        func(uint8_t(b >> 16)) << 16 | func(uint8_t(b >> 24)) << 24; \
  }                                                                  \
  if (sz == 2) {                                                     \
    v = 1;                                                           \
    x = func(uint16_t(b)) | func(uint16_t(b >> 16)) << 16;           \
  }                                                                  \
  if (sz == 4) {                                                     \
    v = 1;                                                           \
    x = func(uint32_t(b));                                           \
  }

#define VOP2S(func)                                               \
  if (sz == 1) {                                                  \
    v = 1;                                                        \
    x = uint8_t(func(int8_t(a), int8_t(b))) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8))) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16))) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24))) << 24;    \
  } else if (sz == 2) {                                           \
    v = 1;                                                        \
    x = uint16_t(func(int16_t(a), int16_t(b))) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16))) << 16; \
  } else if (sz == 4) {                                           \
    v = 1;                                                        \
    x = uint32_t(func(int32_t(a), int32_t(b)));                   \
  }

#define VOP2U(func)                                       \
  if (sz == 1) {                                          \
    v = 1;                                                \
    x = func(uint8_t(a), uint8_t(b)) |                    \
        func(uint8_t(a >> 8), uint8_t(b >> 8)) << 8 |     \
        func(uint8_t(a >> 16), uint8_t(b >> 16)) << 16 |  \
        func(uint8_t(a >> 24), uint8_t(b >> 24)) << 24;   \
  } else if (sz == 2) {                                   \
    v = 1;                                                \
    x = func(uint16_t(a), uint16_t(b)) |                  \
        func(uint16_t(a >> 16), uint16_t(b >> 16)) << 16; \
  } else if (sz == 4) {                                   \
    v = 1;                                                \
    x = func(uint32_t(a), uint32_t(b));                   \
  }

#define VOP2(func) \
  if (f2_signed) { \
    VOP2S(func)    \
  } else {         \
    VOP2U(func)    \
  }

#define VOP2S_R(func, r)                                             \
  if (sz == 1) {                                                     \
    v = 1;                                                           \
    x = uint8_t(func(int8_t(a), int8_t(b), r)) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24), r)) << 24;    \
  } else if (sz == 2) {                                              \
    v = 1;                                                           \
    x = uint16_t(func(int16_t(a), int16_t(b), r)) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16), r)) << 16; \
  } else if (sz == 4) {                                              \
    v = 1;                                                           \
    x = uint32_t(func(int32_t(a), int32_t(b), r));                   \
  }

#define VOP2U_R(func, r)                                               \
  if (sz == 1) {                                                       \
    v = 1;                                                             \
    x = uint8_t(func(uint8_t(a), uint8_t(b), r)) |                     \
        uint8_t(func(uint8_t(a >> 8), uint8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(uint8_t(a >> 16), uint8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(uint8_t(a >> 24), uint8_t(b >> 24), r)) << 24;    \
  } else if (sz == 2) {                                                \
    v = 1;                                                             \
    x = uint16_t(func(uint16_t(a), uint16_t(b), r)) |                  \
        uint16_t(func(uint16_t(a >> 16), uint16_t(b >> 16), r)) << 16; \
  } else if (sz == 4) {                                                \
    v = 1;                                                             \
    x = uint32_t(func(uint32_t(a), uint32_t(b), r));                   \
  }

#define VOP2_R(func, r) \
  if (f2_signed) {      \
    VOP2S_R(func, r)    \
  } else {              \
    VOP2U_R(func, r)    \
  }

#define VOP2PS(func)                                               \
  if (sz == 1) {                                                  \
    v = 1;                                                        \
    w = 1;                                                        \
    x = uint8_t(func(int8_t(a), int8_t(b))) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8))) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16))) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24))) << 24;    \
    y = uint8_t(func(int8_t(c), int8_t(b))) |                     \
        uint8_t(func(int8_t(c >> 8), int8_t(b >> 8))) << 8 |      \
        uint8_t(func(int8_t(c >> 16), int8_t(b >> 16))) << 16 |   \
        uint8_t(func(int8_t(c >> 24), int8_t(b >> 24))) << 24;    \
  } else if (sz == 2) {                                           \
    v = 1;                                                        \
    w = 1;                                                        \
    x = uint16_t(func(int16_t(a), int16_t(b))) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16))) << 16; \
    y = uint16_t(func(int16_t(c), int16_t(b))) |                  \
        uint16_t(func(int16_t(c >> 16), int16_t(b >> 16))) << 16; \
  } else if (sz == 4) {                                           \
    v = 1;                                                        \
    w = 1;                                                        \
    x = uint32_t(func(int32_t(a), int32_t(b)));                   \
    y = uint32_t(func(int32_t(c), int32_t(b)));                   \
  }

#define VOP2PU(func)                                      \
  if (sz == 1) {                                          \
    v = 1;                                                \
    w = 1;                                                \
    x = func(uint8_t(a), uint8_t(b)) |                    \
        func(uint8_t(a >> 8), uint8_t(b >> 8)) << 8 |     \
        func(uint8_t(a >> 16), uint8_t(b >> 16)) << 16 |  \
        func(uint8_t(a >> 24), uint8_t(b >> 24)) << 24;   \
    y = func(uint8_t(c), uint8_t(b)) |                    \
        func(uint8_t(c >> 8), uint8_t(b >> 8)) << 8 |     \
        func(uint8_t(c >> 16), uint8_t(b >> 16)) << 16 |  \
        func(uint8_t(c >> 24), uint8_t(b >> 24)) << 24;   \
  } else if (sz == 2) {                                   \
    v = 1;                                                \
    w = 1;                                                \
    x = func(uint16_t(a), uint16_t(b)) |                  \
        func(uint16_t(a >> 16), uint16_t(b >> 16)) << 16; \
    y = func(uint16_t(c), uint16_t(b)) |                  \
        func(uint16_t(c >> 16), uint16_t(b >> 16)) << 16; \
  } else if (sz == 4) {                                   \
    v = 1;                                                \
    w = 1;                                                \
    x = func(uint32_t(a), uint32_t(b));                   \
    y = func(uint32_t(c), uint32_t(b));                   \
  }

#define VOP2P(func) \
  if (f2_signed) { \
    VOP2PS(func)    \
  } else {         \
    VOP2PU(func)    \
  }

#define VOP2PS_R(func, r)                                            \
  if (sz == 1) {                                                     \
    v = 1;                                                           \
    w = 1;                                                           \
    x = uint8_t(func(int8_t(a), int8_t(b), r)) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24), r)) << 24;    \
    y = uint8_t(func(int8_t(c), int8_t(b), r)) |                     \
        uint8_t(func(int8_t(c >> 8), int8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(int8_t(c >> 16), int8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(int8_t(c >> 24), int8_t(b >> 24), r)) << 24;    \
  } else if (sz == 2) {                                              \
    v = 1;                                                           \
    w = 1;                                                           \
    x = uint16_t(func(int16_t(a), int16_t(b), r)) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16), r)) << 16; \
    y = uint16_t(func(int16_t(c), int16_t(b), r)) |                  \
        uint16_t(func(int16_t(c >> 16), int16_t(b >> 16), r)) << 16; \
  } else if (sz == 4) {                                              \
    v = 1;                                                           \
    w = 1;                                                           \
    x = uint32_t(func(int32_t(a), int32_t(b), r));                   \
    y = uint32_t(func(int32_t(c), int32_t(b), r));                   \
  }

#define VOP2PU_R(func, r)                                              \
  if (sz == 1) {                                                       \
    v = 1;                                                             \
    w = 1;                                                             \
    x = uint8_t(func(uint8_t(a), uint8_t(b), r)) |                     \
        uint8_t(func(uint8_t(a >> 8), uint8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(uint8_t(a >> 16), uint8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(uint8_t(a >> 24), uint8_t(b >> 24), r)) << 24;    \
    y = uint8_t(func(uint8_t(c), uint8_t(b), r)) |                     \
        uint8_t(func(uint8_t(c >> 8), uint8_t(b >> 8), r)) << 8 |      \
        uint8_t(func(uint8_t(c >> 16), uint8_t(b >> 16), r)) << 16 |   \
        uint8_t(func(uint8_t(c >> 24), uint8_t(b >> 24), r)) << 24;    \
  } else if (sz == 2) {                                                \
    v = 1;                                                             \
    w = 1;                                                             \
    x = uint16_t(func(uint16_t(a), uint16_t(b), r)) |                  \
        uint16_t(func(uint16_t(a >> 16), uint16_t(b >> 16), r)) << 16; \
    y = uint16_t(func(uint16_t(c), uint16_t(b), r)) |                  \
        uint16_t(func(uint16_t(c >> 16), uint16_t(b >> 16), r)) << 16; \
  } else if (sz == 4) {                                                \
    v = 1;                                                             \
    w = 1;                                                             \
    x = uint32_t(func(uint32_t(a), uint32_t(b), r));                   \
    y = uint32_t(func(uint32_t(c), uint32_t(b), r));                   \
  }

#define VOP2P_R(func, r) \
  if (f2_signed) {      \
    VOP2PS_R(func, r)    \
  } else {              \
    VOP2PU_R(func, r)    \
  }

#define VOP2S_R_X(func, r, s)                                           \
  if (sz == 1) {                                                        \
    v = 1;                                                              \
    x = uint8_t(func(int8_t(a), int8_t(b), r, s)) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24), r, s)) << 24;    \
  } else if (sz == 2) {                                                 \
    v = 1;                                                              \
    x = uint16_t(func(int16_t(a), int16_t(b), r, s)) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16), r, s)) << 16; \
  } else if (sz == 4) {                                                 \
    v = 1;                                                              \
    x = uint32_t(func(int32_t(a), int32_t(b), r, s));                   \
  }

#define VOP2U_R_X(func, r, s)                                             \
  if (sz == 1) {                                                          \
    v = 1;                                                                \
    x = uint8_t(func(uint8_t(a), uint8_t(b), r, s)) |                     \
        uint8_t(func(uint8_t(a >> 8), uint8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(uint8_t(a >> 16), uint8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(uint8_t(a >> 24), uint8_t(b >> 24), r, s)) << 24;    \
  } else if (sz == 2) {                                                   \
    v = 1;                                                                \
    x = uint16_t(func(uint16_t(a), uint16_t(b), r, s)) |                  \
        uint16_t(func(uint16_t(a >> 16), uint16_t(b >> 16), r, s)) << 16; \
  } else if (sz == 4) {                                                   \
    v = 1;                                                                \
    x = uint32_t(func(uint32_t(a), uint32_t(b), r, s));                   \
  }

#define VOP2_R_X(func, r, s) \
  if (f2_signed) {           \
    VOP2S_R_X(func, r, s)    \
  } else {                   \
    VOP2U_R_X(func, r, s)    \
  }

#define VOP2PS_R_X(func, r, s)                                          \
  if (sz == 1) {                                                        \
    v = 1;                                                              \
    w = 1;                                                              \
    x = uint8_t(func(int8_t(a), int8_t(b), r, s)) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24), r, s)) << 24;    \
    y = uint8_t(func(int8_t(c), int8_t(b), r, s)) |                     \
        uint8_t(func(int8_t(c >> 8), int8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(int8_t(c >> 16), int8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(int8_t(c >> 24), int8_t(b >> 24), r, s)) << 24;    \
  } else if (sz == 2) {                                                 \
    v = 1;                                                              \
    w = 1;                                                              \
    x = uint16_t(func(int16_t(a), int16_t(b), r, s)) |                  \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16), r, s)) << 16; \
    y = uint16_t(func(int16_t(c), int16_t(b), r, s)) |                  \
        uint16_t(func(int16_t(c >> 16), int16_t(b >> 16), r, s)) << 16; \
  } else if (sz == 4) {                                                 \
    v = 1;                                                              \
    w = 1;                                                              \
    x = uint32_t(func(int32_t(a), int32_t(b), r, s));                   \
    y = uint32_t(func(int32_t(c), int32_t(b), r, s));                   \
  }

#define VOP2PU_R_X(func, r, s)                                            \
  if (sz == 1) {                                                          \
    v = 1;                                                                \
    w = 1;                                                                \
    x = uint8_t(func(uint8_t(a), uint8_t(b), r, s)) |                     \
        uint8_t(func(uint8_t(a >> 8), uint8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(uint8_t(a >> 16), uint8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(uint8_t(a >> 24), uint8_t(b >> 24), r, s)) << 24;    \
    y = uint8_t(func(uint8_t(c), uint8_t(b), r, s)) |                     \
        uint8_t(func(uint8_t(c >> 8), uint8_t(b >> 8), r, s)) << 8 |      \
        uint8_t(func(uint8_t(c >> 16), uint8_t(b >> 16), r, s)) << 16 |   \
        uint8_t(func(uint8_t(c >> 24), uint8_t(b >> 24), r, s)) << 24;    \
  } else if (sz == 2) {                                                   \
    v = 1;                                                                \
    w = 1;                                                                \
    x = uint16_t(func(uint16_t(a), uint16_t(b), r, s)) |                  \
        uint16_t(func(uint16_t(a >> 16), uint16_t(b >> 16), r, s)) << 16; \
    y = uint16_t(func(uint16_t(c), uint16_t(b), r, s)) |                  \
        uint16_t(func(uint16_t(c >> 16), uint16_t(b >> 16), r, s)) << 16; \
  } else if (sz == 4) {                                                   \
    v = 1;                                                                \
    w = 1;                                                                \
    x = uint32_t(func(uint32_t(a), uint32_t(b), r, s));                   \
    y = uint32_t(func(uint32_t(c), uint32_t(b), r, s));                   \
  }

#define VOP2P_R_X(func, r, s) \
  if (f2_signed) {            \
    VOP2PS_R_X(func, r, s)    \
  } else {                    \
    VOP2PU_R_X(func, r, s)    \
  }

#define VOP2W(func)                     \
  if (sz == 1) {                        \
    v = 1;                              \
    x = 0;                              \
  } else if (sz == 2) {                 \
    v = 1;                              \
    x = 0;                              \
  } else if (sz == 4) {                 \
    v = 1;                              \
    x = func(uint32_t(a), uint32_t(b)); \
  }

#define VOP3S(func)                                                          \
  if (sz == 1) {                                                             \
    v = 1;                                                                   \
    x = uint8_t(func(int8_t(a), int8_t(b), int8_t(c))) |                     \
        uint8_t(func(int8_t(a >> 8), int8_t(b >> 8), int8_t(c >> 8))) << 8 | \
        uint8_t(func(int8_t(a >> 16), int8_t(b >> 16), int8_t(c >> 16)))     \
            << 16 |                                                          \
        uint8_t(func(int8_t(a >> 24), int8_t(b >> 24), int8_t(c >> 24)))     \
            << 24;                                                           \
  } else if (sz == 2) {                                                      \
    v = 1;                                                                   \
    x = uint16_t(func(int16_t(a), int16_t(b), int16_t(c))) |                 \
        uint16_t(func(int16_t(a >> 16), int16_t(b >> 16), int16_t(c >> 16))) \
            << 16;                                                           \
  } else if (sz == 4) {                                                      \
    v = 1;                                                                   \
    x = uint32_t(func(int32_t(a), int32_t(b), int32_t(c)));                  \
  }

#define VOP3(func) \
  if (f2_signed) { \
    VOP3S(func)    \
  } else {         \
    VOP3U(func)    \
  }

#define VOP3U(func)                                                         \
  if (sz == 1) {                                                            \
    v = 1;                                                                  \
    x = uint8_t(func(uint8_t(a), uint8_t(b), uint8_t(c))) |                 \
        uint8_t(func(uint8_t(a >> 8), uint8_t(b >> 8), uint8_t(c >> 8)))    \
            << 8 |                                                          \
        uint8_t(func(uint8_t(a >> 16), uint8_t(b >> 16), uint8_t(c >> 16))) \
            << 16 |                                                         \
        uint8_t(func(uint8_t(a >> 24), uint8_t(b >> 24), uint8_t(c >> 24))) \
            << 24;                                                          \
  } else if (sz == 2) {                                                     \
    v = 1;                                                                  \
    x = uint16_t(func(uint16_t(a), uint16_t(b), uint16_t(c))) |             \
        uint16_t(                                                           \
            func(uint16_t(a >> 16), uint16_t(b >> 16), uint16_t(c >> 16)))  \
            << 16;                                                          \
  } else if (sz == 4) {                                                     \
    v = 1;                                                                  \
    x = uint32_t(func(uint32_t(a), uint32_t(b), uint32_t(c)));              \
  }

#define VOP3NS_R_U(func, r, u)                                         \
  if (sz == 1) {                                                       \
    v = 1;                                                             \
    x = uint8_t(func(int16_t(a), int8_t(b), r, u)) |                   \
        uint8_t(func(int16_t(c), int8_t(b >> 8), r, u)) << 8 |         \
        uint8_t(func(int16_t(a >> 16), int8_t(b >> 16), r, u)) << 16 | \
        uint8_t(func(int16_t(c >> 16), int8_t(b >> 24), r, u)) << 24;  \
  } else if (sz == 2) {                                                \
    v = 1;                                                             \
    x = uint16_t(func(int32_t(a), int16_t(b), r, u)) |                 \
        uint16_t(func(int32_t(c), int16_t(b >> 16), r, u)) << 16;      \
  } else if (sz == 4) {                                                \
    v = 1;                                                             \
    x = 0;                                                             \
  }

#define VOP3QS_R_U(func, r, u)                                   \
  if (sz == 1) {                                                 \
    v = 1;                                                       \
    x = uint8_t(func(int32_t(a), int8_t(b), r, u)) |             \
        uint8_t(func(int32_t(d), int8_t(b >> 8), r, u)) << 8 |   \
        uint8_t(func(int32_t(c), int8_t(b >> 16), r, u)) << 16 | \
        uint8_t(func(int32_t(f), int8_t(b >> 24), r, u)) << 24;  \
  } else if (sz == 2) {                                          \
    v = 1;                                                       \
    x = 0;                                                       \
  } else if (sz == 4) {                                          \
    v = 1;                                                       \
    x = 0;                                                       \
  }

#define VOP2M(func)                                                           \
  if (sz == 1) {                                                              \
    v = 1;                                                                    \
    w = 1;                                                                    \
    auto p0 = func(uint8_t(a), uint8_t(b));                                   \
    auto p1 = func(uint8_t(a >> 8), uint8_t(b >> 8));                         \
    auto p2 = func(uint8_t(a >> 16), uint8_t(b >> 16));                       \
    auto p3 = func(uint8_t(a >> 24), uint8_t(b >> 24));                       \
    x = p0.first | (p1.first << 8) | (p2.first << 16) | (p3.first << 24);     \
    y = p0.second | (p1.second << 8) | (p2.second << 16) | (p3.second << 24); \
  } else if (sz == 2) {                                                       \
    v = 1;                                                                    \
    w = 1;                                                                    \
    auto p0 = func(uint16_t(a), uint16_t(b));                                 \
    auto p1 = func(uint16_t(a >> 16), uint16_t(b >> 16));                     \
    x = p0.first | (p1.first << 16);                                          \
    y = p0.second | (p1.second << 16);                                        \
  } else if (sz == 4) {                                                       \
    v = 1;                                                                    \
    w = 1;                                                                    \
    auto p = func(uint32_t(a), uint32_t(b));                                  \
    x = p.first;                                                              \
    y = p.second;                                                             \
  }

#define VOPPS(func)                                             \
  if (sz == 1) {                                                \
    v = 1;                                                      \
    x = 0;                                                      \
  } else if (sz == 2) {                                         \
    v = 1;                                                      \
    x = uint16_t(func(int8_t(a), int8_t(a >> 8))) |             \
        uint16_t(func(int8_t(a >> 16), int8_t(a >> 24))) << 16; \
  } else if (sz == 4) {                                         \
    v = 1;                                                      \
    x = uint32_t(func(int16_t(a), int16_t(a >> 16)));           \
  }

#define VOPPU(func)                                               \
  if (sz == 1) {                                                  \
    v = 1;                                                        \
    x = 0;                                                        \
  } else if (sz == 2) {                                           \
    v = 1;                                                        \
    x = uint16_t(func(uint8_t(a), uint8_t(a >> 8))) |             \
        uint16_t(func(uint8_t(a >> 16), uint8_t(a >> 24))) << 16; \
  } else if (sz == 4) {                                           \
    v = 1;                                                        \
    x = uint32_t(func(uint16_t(a), uint16_t(a >> 16)));           \
  }

#define VOPP(func) \
  if (f2_signed) { \
    VOPPS(func)    \
  } else {         \
    VOPPU(func)    \
  }

#define WOP2U(func)                                           \
  if (sz == 1) {                                              \
    v = 1;                                                    \
    w = 1;                                                    \
    x = 0;                                                    \
    y = 0;                                                    \
  } else if (sz == 2) {                                       \
    v = 1;                                                    \
    w = 1;                                                    \
    uint16_t p0 = func(uint8_t(a), uint8_t(b));               \
    uint16_t p1 = func(uint8_t(a >> 8), uint8_t(b >> 8));     \
    uint16_t p2 = func(uint8_t(a >> 16), uint8_t(b >> 16));   \
    uint16_t p3 = func(uint8_t(a >> 24), uint8_t(b >> 24));   \
    x = p0 | (p2 << 16);                                      \
    y = p1 | (p3 << 16);                                      \
  } else if (sz == 4) {                                       \
    v = 1;                                                    \
    w = 1;                                                    \
    uint32_t p0 = func(uint16_t(a), uint16_t(b));             \
    uint32_t p1 = func(uint16_t(a >> 16), uint16_t(b >> 16)); \
    x = p0;                                                   \
    y = p1;                                                   \
  }

#define WOP2S(func)                                         \
  if (sz == 1) {                                            \
    v = 1;                                                  \
    w = 1;                                                  \
    x = 0;                                                  \
    y = 0;                                                  \
  } else if (sz == 2) {                                     \
    v = 1;                                                  \
    w = 1;                                                  \
    uint16_t p0 = func(int8_t(a), int8_t(b));               \
    uint16_t p1 = func(int8_t(a >> 8), int8_t(b >> 8));     \
    uint16_t p2 = func(int8_t(a >> 16), int8_t(b >> 16));   \
    uint16_t p3 = func(int8_t(a >> 24), int8_t(b >> 24));   \
    x = p0 | (p2 << 16);                                    \
    y = p1 | (p3 << 16);                                    \
  } else if (sz == 4) {                                     \
    v = 1;                                                  \
    w = 1;                                                  \
    uint32_t p0 = func(int16_t(a), int16_t(b));             \
    uint32_t p1 = func(int16_t(a >> 16), int16_t(b >> 16)); \
    x = p0;                                                 \
    y = p1;                                                 \
  }

#define WOP2(func) \
  if (f2_signed) { \
    WOP2S(func)    \
  } else {         \
    WOP2U(func)    \
  }

#define WOPAU(func)                                          \
  if (sz == 1) {                                             \
    v = 1;                                                   \
    w = 1;                                                   \
    x = 0;                                                   \
    y = 0;                                                   \
  } else if (sz == 2) {                                      \
    v = 1;                                                   \
    w = 1;                                                   \
    uint16_t p0 = func(uint16_t(a), uint8_t(b));             \
    uint16_t p1 = func(uint16_t(c), uint8_t(b >> 8));        \
    uint16_t p2 = func(uint16_t(a >> 16), uint8_t(b >> 16)); \
    uint16_t p3 = func(uint16_t(c >> 16), uint8_t(b >> 24)); \
    x = p0 | (p2 << 16);                                     \
    y = p1 | (p3 << 16);                                     \
  } else if (sz == 4) {                                      \
    v = 1;                                                   \
    w = 1;                                                   \
    uint32_t p0 = func(uint32_t(a), uint16_t(b));            \
    uint32_t p1 = func(uint32_t(c), uint16_t(b >> 16));      \
    x = p0;                                                  \
    y = p1;                                                  \
  }

#define WOPAS(func)                                        \
  if (sz == 1) {                                           \
    v = 1;                                                 \
    w = 1;                                                 \
    x = 0;                                                 \
    y = 0;                                                 \
  } else if (sz == 2) {                                    \
    v = 1;                                                 \
    w = 1;                                                 \
    uint16_t p0 = func(int16_t(a), int8_t(b));             \
    uint16_t p1 = func(int16_t(c), int8_t(b >> 8));        \
    uint16_t p2 = func(int16_t(a >> 16), int8_t(b >> 16)); \
    uint16_t p3 = func(int16_t(c >> 16), int8_t(b >> 24)); \
    x = p0 | (p2 << 16);                                   \
    y = p1 | (p3 << 16);                                   \
  } else if (sz == 4) {                                    \
    v = 1;                                                 \
    w = 1;                                                 \
    uint32_t p0 = func(int32_t(a), int16_t(b));            \
    uint32_t p1 = func(int32_t(c), int16_t(b >> 16));      \
    x = p0;                                                \
    y = p1;                                                \
  }

#define WOPA(func) \
  if (f2_signed) { \
    WOPAS(func)    \
  } else {         \
    WOPAU(func)    \
  }

template <typename T>
void VSlidevn(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const int shfamt = (op.f2 & 3) + 1;
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  T* out = reinterpret_cast<T*>(op.out[0].data);
  for (int i = 0; i < n; ++i) {
    out[i] = i + shfamt < n ? in0[i + shfamt] : in1[i + shfamt - n];
  }
  op.w[0].valid = true;
}

template <typename T>
void VSlidevp(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const int shfamt = (op.f2 & 3) + 1;
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  T* out = reinterpret_cast<T*>(op.out[0].data);
  for (int i = 0; i < n; ++i) {
    out[i] = i - shfamt < 0 ? in0[n - shfamt + i] : in1[i - shfamt];
  }
  op.w[0].valid = true;
}

template <typename T>
void VSlidehn2(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const int shfamt = (op.f2 & 3) + 1;
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  const T* in2 = reinterpret_cast<const T*>(op.in[2].data);
  T* out0 = reinterpret_cast<T*>(op.out[0].data);
  T* out1 = reinterpret_cast<T*>(op.out[1].data);
  for (int i = 0; i < n; ++i) {
    out0[i] = i + shfamt < n ? in0[i + shfamt] : in1[i + shfamt - n];
  }
  for (int i = 0; i < n; ++i) {
    out1[i] = i + shfamt < n ? in1[i + shfamt] : in2[i + shfamt - n];
  }
  op.w[0].valid = true;
  op.w[1].valid = true;
}

template <typename T>
void VSlidehp2(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const int shfamt = (op.f2 & 3) + 1;
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  const T* in2 = reinterpret_cast<const T*>(op.in[2].data);
  T* out0 = reinterpret_cast<T*>(op.out[0].data);
  T* out1 = reinterpret_cast<T*>(op.out[1].data);
  for (int i = 0; i < n; ++i) {
    out0[i] = i - shfamt < 0 ? in0[n - shfamt + i] : in1[i - shfamt];
  }
  for (int i = 0; i < n; ++i) {
    out1[i] = i - shfamt < 0 ? in1[n - shfamt + i] : in2[i - shfamt];
  }
  op.w[0].valid = true;
  op.w[1].valid = true;
}

static void VSlidevn(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VSlidevn<uint8_t>(op); break;
    case 2: VSlidevn<uint16_t>(op); break;
    case 4: VSlidevn<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VSlidevp(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VSlidevp<uint8_t>(op); break;
    case 2: VSlidevp<uint16_t>(op); break;
    case 4: VSlidevp<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VSlidehn2(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VSlidehn2<uint8_t>(op); break;
    case 2: VSlidehn2<uint16_t>(op); break;
    case 4: VSlidehn2<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VSlidehp2(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VSlidehp2<uint8_t>(op); break;
    case 2: VSlidehp2<uint16_t>(op); break;
    case 4: VSlidehp2<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

template <typename T>
void VSel(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  const T* in2 = reinterpret_cast<const T*>(op.in[2].data);
  T* out = reinterpret_cast<T*>(op.out[0].data);
  for (int i = 0; i < n; ++i) {
    out[i] = in0[i] & 1 ? in2[i] : in1[i];
  }
  op.w[0].valid = true;
}

static void VSel(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VSel<uint8_t>(op); break;
    case 2: VSel<uint16_t>(op); break;
    case 4: VSel<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

template <typename T>
void VEvn(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  T* out0 = reinterpret_cast<T*>(op.out[0].data);
  for (int i = 0; i < n; ++i) {
    out0[i] = i < n / 2 ? in0[2 * i + 0] : in1[2 * (i - n / 2) + 0];
  }
  op.w[0].valid = true;
}

template <typename T>
void VOdd(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  T* out1 = reinterpret_cast<T*>(op.out[1].data);
  for (int i = 0; i < n; ++i) {
    out1[i] = i < n / 2 ? in0[2 * i + 1] : in1[2 * (i - n / 2) + 1];
  }
  op.w[1].valid = true;
}

template <typename T>
void VEvnOdd(valu_t& op) {
  VEvn<T>(op);
  VOdd<T>(op);
}

static void VEvn(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VEvn<uint8_t>(op); break;
    case 2: VEvn<uint16_t>(op); break;
    case 4: VEvn<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VOdd(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VOdd<uint8_t>(op); break;
    case 2: VOdd<uint16_t>(op); break;
    case 4: VOdd<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VEvnOdd(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VEvnOdd<uint8_t>(op); break;
    case 2: VEvnOdd<uint16_t>(op); break;
    case 4: VEvnOdd<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

template <typename T>
void VZip(valu_t& op) {
  constexpr int n = kLanes * 4 / sizeof(T);
  constexpr int h = n / 2;
  const T* in0 = reinterpret_cast<const T*>(op.in[0].data);
  const T* in1 = reinterpret_cast<const T*>(op.in[1].data);
  T* out0 = reinterpret_cast<T*>(op.out[0].data);
  T* out1 = reinterpret_cast<T*>(op.out[1].data);
  for (int i = 0; i < n; ++i) {
    const int j = i / 2;
    out0[i] = i & 1 ? in1[j + 0] : in0[j + 0];
    out1[i] = i & 1 ? in1[j + h] : in0[j + h];
  }
  op.w[0].valid = true;
  op.w[1].valid = true;
}

static void VZip(valu_t& op) {
  // clang-format off
  switch (op.sz) {
    case 1: VZip<uint8_t>(op); break;
    case 2: VZip<uint16_t>(op); break;
    case 4: VZip<uint32_t>(op); break;
    default: assert(false); break;
  }
  // clang-format on
}

static void VDwconv(const uint32_t adata[6], const uint32_t bdata[6],
                    const uint32_t abias, const uint32_t bbias,
                    const bool asign, const bool bsign, uint32_t out[4]) {
  int32_t s_abias = int32_t(abias << 23) >> 23;
  int32_t s_bbias = int32_t(bbias << 23) >> 23;
  for (int i = 0; i < 4; ++i) {
    uint32_t accum = 0;
    for (int j = 0; j < 3; ++j) {
      int32_t s_adata = int32_t(uint8_t(adata[j] >> (8 * i)));
      int32_t s_bdata = int32_t(uint8_t(bdata[j] >> (8 * i)));
      if (asign) {
        s_adata = int8_t(s_adata);
      }
      if (bsign) {
        s_bdata = int8_t(s_bdata);
      }
      accum += (s_adata + s_abias) * (s_bdata + s_bbias);
    }

    out[i] = accum;
  }
}

static void VDwconv(valu_t& op) {
  const uint32_t* in0 = reinterpret_cast<const uint32_t*>(op.in[0].data);
  const uint32_t* in1 = reinterpret_cast<const uint32_t*>(op.in[1].data);
  const uint32_t* in2 = reinterpret_cast<const uint32_t*>(op.in[2].data);
  const uint32_t* in3 = reinterpret_cast<const uint32_t*>(op.in[3].data);
  const uint32_t* in4 = reinterpret_cast<const uint32_t*>(op.in[4].data);
  const uint32_t* in5 = reinterpret_cast<const uint32_t*>(op.in[5].data);
  uint32_t* out0 = reinterpret_cast<uint32_t*>(op.out[0].data);
  uint32_t* out1 = reinterpret_cast<uint32_t*>(op.out[1].data);
  uint32_t* out2 = reinterpret_cast<uint32_t*>(op.out[2].data);
  uint32_t* out3 = reinterpret_cast<uint32_t*>(op.out[3].data);

  struct vdwconv_u8_t {
    uint32_t mode : 2;      // 31:30
    uint32_t sparsity : 2;  // 29:28
    uint32_t regbase : 4;   // 27:24
    uint32_t rsvd : 4;      // 23:20
    uint32_t abias : 9;     // 19:11
    uint32_t asign : 1;     // 10
    uint32_t bbias : 9;     // 9:1
    uint32_t bsign : 1;     // 0
  } cmd;

  uint32_t* p_cmd = reinterpret_cast<uint32_t*>(&cmd);
  *p_cmd = op.sv.data;
  assert(cmd.mode == 0);
  assert(cmd.rsvd == 0);
  assert(cmd.sparsity < 3);
  const uint32_t abias = cmd.abias;
  const uint32_t bbias = cmd.bbias;
  const bool asign = cmd.asign;
  const bool bsign = cmd.bsign;

  constexpr int n = kVector / 32;
  constexpr int kSparseSize = n + 2;
  uint32_t sparse[kSparseSize];
  if (cmd.sparsity == 1) {
    sparse[0] = in0[n - 1];
    for (int i = 0; i < kVector / 32; ++i) {
      sparse[i + 1] = in1[i];
    }
    sparse[n + 1] = in2[0];
  } else if (cmd.sparsity == 2) {
    for (int i = 0; i < kVector / 32; ++i) {
      sparse[i] = in0[i];
    }
    sparse[n + 0] = in1[0];
    sparse[n + 1] = in1[1];
  }

  for (int i = 0; i < kVector / 32; ++i) {
    uint32_t adata[3];
    adata[0] = !cmd.sparsity ? in0[i] : sparse[i + 0];
    adata[1] = !cmd.sparsity ? in1[i] : sparse[i + 1];
    adata[2] = !cmd.sparsity ? in2[i] : sparse[i + 2];
    uint32_t bdata[3] = {in3[i], in4[i], in5[i]};
    uint32_t out[4];
    VDwconv(adata, bdata, abias, bbias, asign, bsign, out);
    // Note the output interleaving.
    out0[i] = out[0];
    out2[i] = out[1];
    out1[i] = out[2];
    out3[i] = out[3];
  }

  op.w[0].valid = true;
  op.w[1].valid = true;
  op.w[2].valid = true;
  op.w[3].valid = true;
}

static void VAlu(valu_t& op) {
  // clang-format off
  switch (op.op) {
    case encode::vslidevn: VSlidevn(op); return;
    case encode::vslidevp: VSlidevp(op); return;
    case encode::vslidehn: VSlidevn(op); return;
    case encode::vslidehp: VSlidevp(op); return;
    case encode::vslidehn2: VSlidehn2(op); return;
    case encode::vslidehp2: VSlidehp2(op); return;
    case encode::vsel: VSel(op); return;
    case encode::vevn: VEvn(op); return;
    case encode::vodd: VOdd(op); return;
    case encode::vevnodd: VEvnOdd(op); return;
    case encode::vzip: VZip(op); return;
    case encode::vdwconv: VDwconv(op); return;
  }
  // clang-format on

  for (int i = 0; i < kLanes; ++i) {
    const uint8_t f2 = op.f2;
    const uint8_t sz = op.sz;
    const uint32_t a = op.in[0].data[i];
    const uint32_t b = op.in[1].data[i];
    const uint32_t c = op.in[2].data[i];
    const uint32_t d = op.in[3].data[i];
    const uint32_t f = op.in[5].data[i];
    bool v = false;
    bool w = false;
    uint32_t x = 0;
    uint32_t y = 0;

    const bool f2_negative = ((f2 >> 0) & 1) && (op.op == encode::vdmulh ||
                                                 op.op == encode::vdmulh2);
    const bool f2_round = (f2 >> 1) & 1;
    const bool f2_signed =
        !((f2 >> 0) & 1) || op.op == encode::vdmulh || op.op == encode::vdmulh2;

    // clang-format off
    switch (op.op) {
      case encode::vdup:    VOPXU(dup); break;
      case encode::vadd:    VOP2U(add); break;
      case encode::vsub:    VOP2U(sub); break;
      case encode::vrsub:   VOP2U(rsub); break;
      case encode::veq:     VOP2U(cmp_eq); break;
      case encode::vne:     VOP2U(cmp_ne); break;
      case encode::vlt:     VOP2(cmp_lt); break;
      case encode::vle:     VOP2(cmp_le); break;
      case encode::vgt:     VOP2(cmp_gt); break;
      case encode::vge:     VOP2(cmp_ge); break;
      case encode::vabsd:   VOP2(absd); break;
      case encode::vmax:    VOP2(max); break;
      case encode::vmin:    VOP2(min); break;
      case encode::vadd3:   VOP3U(add3); break;
      case encode::vand:    VOP2U(log_and); break;
      case encode::vor:     VOP2U(log_or); break;
      case encode::vxor:    VOP2U(log_xor); break;
      case encode::vnot:    VOP1U(log_not); break;
      case encode::vrev:    VOP2U(log_rev); break;
      case encode::vror:    VOP2U(log_ror); break;
      case encode::vclb:    VOP1U(log_clb); break;
      case encode::vclz:    VOP1U(log_clz); break;
      case encode::vcpop:   VOP1U(log_cpop); break;
      case encode::vmv:     VOP1U(mv); break;
      case encode::vmv2:    VOP1PU(mv); break;
      case encode::vmvp:    VOP2M(mvp); break;
      case encode::vshl:    VOP2U(shl); break;
      case encode::vshr:    VOP2(shr); break;
      case encode::vshf:    VOP2_R(shf, f2_round); break;
      case encode::vsrans:  VOP3NS_R_U(srans, f2_round, !f2_signed); break;
      case encode::vsraqs:  VOP3QS_R_U(srans, f2_round, !f2_signed); break;
      case encode::vmul:    VOP2S(mul); break;
      case encode::vmul2:   VOP2PS(mul); break;
      case encode::vmuls:   VOP2(muls); break;
      case encode::vmuls2:  VOP2P(muls); break;
      case encode::vmulw:   WOP2(mulw); break;
      case encode::vmulh:   VOP2_R(mulh, f2_round); break;
      case encode::vmulh2:  VOP2P_R(mulh, f2_round); break;
      case encode::vdmulh:  VOP2_R_X(dmulh, f2_round, f2_negative); break;
      case encode::vdmulh2: VOP2P_R_X(dmulh, f2_round, f2_negative); break;
      case encode::vmadd:   VOP3(madd); break;
      case encode::vadds:   VOP2(adds); break;
      case encode::vsubs:   VOP2(subs); break;
      case encode::vaddw:   WOP2(addw); break;
      case encode::vsubw:   WOP2(subw); break;
      case encode::vacc:    WOPA(acc); break;
      case encode::vpadd:   VOPP(padd); break;
      case encode::vpsub:   VOPP(psub); break;
      case encode::vhadd:   VOP2_R(hadd, f2_round); break;
      case encode::vhsub:   VOP2_R(hsub, f2_round); break;
    }
    // clang-format on

    op.w[0].valid = v;
    op.w[1].valid = w;
    op.out[0].data[i] = x;
    op.out[1].data[i] = y;
  }
}

#endif  // TESTS_VERILATOR_SIM_CORALNPU_VALU_H_
