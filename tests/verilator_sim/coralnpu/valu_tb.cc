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

#include "VVAlu.h"
#include "hdl/chisel/src/coralnpu/VCore_parameters.h"
#include "tests/verilator_sim/coralnpu/valu.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

struct VAlu_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_in<bool> io_read_0_valid;
  sc_in<bool> io_read_1_valid;
  sc_in<bool> io_read_2_valid;
  sc_in<bool> io_read_3_valid;
  sc_in<bool> io_read_4_valid;
  sc_in<bool> io_read_5_valid;
  sc_in<bool> io_read_6_valid;
  sc_in<bool> io_read_0_ready;
  sc_in<bool> io_read_1_ready;
  sc_in<bool> io_read_2_ready;
  sc_in<bool> io_read_3_ready;
  sc_in<bool> io_read_4_ready;
  sc_in<bool> io_read_5_ready;
  sc_in<bool> io_read_6_ready;
  sc_in<bool> io_write_0_valid;
  sc_in<bool> io_write_1_valid;
  sc_in<bool> io_write_2_valid;
  sc_in<bool> io_write_3_valid;
  sc_in<bool> io_whint_0_valid;
  sc_in<bool> io_whint_1_valid;
  sc_in<bool> io_whint_2_valid;
  sc_in<bool> io_whint_3_valid;
  sc_in<bool> io_scalar_0_valid;
  sc_in<bool> io_scalar_1_valid;
  sc_in<sc_bv<64> > io_active;
  sc_out<sc_bv<128> > io_vrfsb;
  sc_in<sc_bv<6> > io_read_0_addr;
  sc_in<bool> io_read_0_tag;
  sc_out<sc_bv<kVector> > io_read_0_data;
  sc_in<sc_bv<6> > io_read_1_addr;
  sc_in<bool> io_read_1_tag;
  sc_out<sc_bv<kVector> > io_read_1_data;
  sc_in<sc_bv<6> > io_read_2_addr;
  sc_in<bool> io_read_2_tag;
  sc_out<sc_bv<kVector> > io_read_2_data;
  sc_in<sc_bv<6> > io_read_3_addr;
  sc_in<bool> io_read_3_tag;
  sc_out<sc_bv<kVector> > io_read_3_data;
  sc_in<sc_bv<6> > io_read_4_addr;
  sc_in<bool> io_read_4_tag;
  sc_out<sc_bv<kVector> > io_read_4_data;
  sc_in<sc_bv<6> > io_read_5_addr;
  sc_in<bool> io_read_5_tag;
  sc_out<sc_bv<kVector> > io_read_5_data;
  sc_in<sc_bv<6> > io_read_6_addr;
  sc_in<bool> io_read_6_tag;
  sc_out<sc_bv<kVector> > io_read_6_data;
  sc_in<sc_bv<6> > io_write_0_addr;
  sc_in<sc_bv<kVector> > io_write_0_data;
  sc_in<sc_bv<6> > io_write_1_addr;
  sc_in<sc_bv<kVector> > io_write_1_data;
  sc_in<sc_bv<6> > io_write_2_addr;
  sc_in<sc_bv<kVector> > io_write_2_data;
  sc_in<sc_bv<6> > io_write_3_addr;
  sc_in<sc_bv<kVector> > io_write_3_data;
  sc_in<sc_bv<6> > io_whint_0_addr;
  sc_in<sc_bv<6> > io_whint_1_addr;
  sc_in<sc_bv<6> > io_whint_2_addr;
  sc_in<sc_bv<6> > io_whint_3_addr;
  sc_in<sc_bv<32> > io_scalar_0_data;
  sc_in<sc_bv<32> > io_scalar_1_data;
#define IO_BITS(x)                                  \
  sc_out<bool> io_in_bits_##x##_valid;              \
  sc_out<bool> io_in_bits_##x##_bits_m;             \
  sc_out<bool> io_in_bits_##x##_bits_vd_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_ve_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vf_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vg_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vs_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vt_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vu_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vx_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vy_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_vz_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_sv_valid;      \
  sc_out<bool> io_in_bits_##x##_bits_cmdsync;       \
  sc_out<sc_bv<7> > io_in_bits_##x##_bits_op;       \
  sc_out<sc_bv<3> > io_in_bits_##x##_bits_f2;       \
  sc_out<sc_bv<3> > io_in_bits_##x##_bits_sz;       \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vd_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_ve_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vf_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vg_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vs_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vt_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vu_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vx_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vy_addr;  \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vz_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vs_tag;   \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vt_tag;   \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vu_tag;   \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vx_tag;   \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vy_tag;   \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vz_tag;   \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_sv_addr; \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_sv_data;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  using Sysc_tb::Sysc_tb;

  void init() {
    // Initialize registers to fixed values.
    // This testbench is not for checking ALU arithmetic,
    // it is for checking command queues and integration.
    for (int i = 0; i < 60; ++i) {
      for (int j = 0; j < kLanes; ++j) {
        regs_[i][j] = rand_uint32();
      }
    }
    for (int i = 60; i < 64; ++i) {
      for (int j = 0; j < kLanes; ++j) {
        regs_[i][j] = kLanes * (i - 60) + j;
      }
    }
    for (int j = 0; j < kLanes; ++j) {
      scalar_[j] = rand_uint32();
    }
#if 0
    for (int i = 0; i < 64; ++i) {
      for (int j = 0; j < kLanes; ++j) {
        regs_[i][j] = i;
      }
    }
#endif
  }

  void posedge() {
    //-------------------------------------------------------------------------
    // Active.
    const uint64_t active = io_active.read().get_word(0) |
                            (uint64_t(io_active.read().get_word(1)) << 32);
    // Tracking reads.
    check(active == Ractive(), "io.active[1]");
    // Tracking writes. Reads can retires 2-10cc before write.
    check((active & ~Wactive()) == 0, "io.active[2]");

    //-------------------------------------------------------------------------
    // Inputs.
    for (int i = 0; i < KP_instructionLanes; ++i) {
      ProcessInputs(i);
    }

#if 0
    printf("wactive ");
    for (int i = 0; i < 64; ++i) {
      printf("%d", write_[63 - i].valid);
    }
    printf("\n");
#endif
    // -------------------------------------------------------------------------
    // Outputs.
    for (int i = 0; i < 4; ++i) {
      ProcessOutputs(i);
    }

    // -------------------------------------------------------------------------
    // Scoreboard.
    sc_bv<128> vrfsb = 0;
    //  Set upto four entries.
    for (int i = 0; i < 4; ++i) {
      vrfsb.set_bit(rand_int(0, 127), sc_dt::Log_1);
    }
    io_vrfsb = vrfsb;

    // -------------------------------------------------------------------------
    // Inputs.
    io_in_valid = rand_bool();

    // Speculatively set wactive in cycle. Will be updated above in write cycle.
    uint64_t wactive = wactive_;
    for (int i = 0; i < KP_instructionLanes; ++i) {
      PrepareInputs(i, wactive);
    }

    // -----------------------------------------------------------------------------
    // Register reads.
    ReadData(0);
    ReadData(1);
    ReadData(2);
    ReadData(3);
    ReadData(4);
    ReadData(5);
    ReadData(6);
  }

 private:
  fifo_t<valu_t> cmdq_[KP_instructionLanes];

  uint32_t regs_[64][kLanes];  // read-only
  uint32_t scalar_[kLanes];    // read-only

  int read_[64] = {0};

  struct write_t {
    bool valid;
    // write
    uint32_t data[kLanes];
    // read
    struct {
      bool valid;
      int addr;
    } r[kReadPorts];
    // tracking fields
    uint8_t op : 7;
    uint8_t f2 : 3;
    uint8_t sz : 3;
  } write_[64] = {0};

  struct inputs_t {
    uint8_t op : 7;
    uint8_t f2 : 3;
    uint8_t sz : 3;
    bool m;
    bool cmdsync;
    struct {
      bool valid;
      int addr;
      int data;
    } sv;
    struct {
      bool valid;
      int addr;
      int tag;
    } r[kReadPorts];
    struct {
      bool valid;
      int addr;
    } w[kWritePorts];
  };

  uint64_t wactive_ = 0;

  uint64_t Ractive() {
    uint64_t active = 0;
    for (int i = 0; i < 64; ++i) {
      if (read_[i] != 0) {
        active |= 1ull << i;
      }
    }
    return active;
  }

  uint64_t Wactive() {
    uint64_t active = 0;
    for (int i = 0; i < 64; ++i) {
      if (!write_[i].valid) continue;
      for (int j = 0; j < kReadPorts; ++j) {
        if (!write_[i].r[j].valid) continue;
        active |= 1ull << write_[i].r[j].addr;
      }
    }
    return active;
  }

  bool FindInactiveWriteAddr(const bool m, uint64_t& wactive, int& addr) {
    for (int retry = 0; retry < 16; ++retry) {
      addr = rand_int(0, 63);
      if (m) addr &= ~3;
      uint64_t mask = (m ? 15ull : 1ull) << addr;
      if (wactive & mask) continue;
      wactive |= mask;
      return true;
    }
    return false;
  }

  bool FindInactiveWriteAddr2(const bool m, uint64_t& wactive, int& addr) {
    for (int retry = 0; retry < 16; ++retry) {
      addr = rand_int(0, m ? 56 : 62);
      if (m) addr &= ~3;
      uint64_t mask = (m ? 255ull : 3ull) << addr;
      if (wactive & mask) continue;
      wactive |= mask;
      return true;
    }
    return false;
  }

  void ReadData(const int idx) {
#define READ_DATA(idx)                                       \
  {                                                          \
    uint32_t addr = io_read_##idx##_addr.read().get_word(0); \
    sc_bv<kVector> rdata = 0;                                \
    if (io_read_##idx##_valid) {                             \
      for (int i = 0; i < kLanes; ++i) {                     \
        rdata.set_word(i, regs_[addr][i]);                   \
      }                                                      \
      if (io_read_##idx##_ready) {                           \
        assert(read_[addr] > 0);                             \
        read_[addr]--;                                       \
      }                                                      \
    }                                                        \
    if (idx == 1 && io_scalar_0_valid) {                     \
      for (int i = 0; i < kLanes; ++i) {                     \
        rdata.set_word(i, scalar_[i]);                       \
      }                                                      \
    }                                                        \
    if (idx == 4 && io_scalar_1_valid) {                     \
      for (int i = 0; i < kLanes; ++i) {                     \
        rdata.set_word(i, scalar_[i]);                       \
      }                                                      \
    }                                                        \
    io_read_##idx##_data = rdata;                            \
  }
    if (idx == 0) READ_DATA(0);
    if (idx == 1) READ_DATA(1);
    if (idx == 2) READ_DATA(2);
    if (idx == 3) READ_DATA(3);
    if (idx == 4) READ_DATA(4);
    if (idx == 5) READ_DATA(5);
    if (idx == 6) READ_DATA(6);
  }
#undef READ_DATA

  void PrepareInputs(const int idx, uint64_t& wactive) {
    bool valid = rand_int(0, 3);
    inputs_t in;

    in.op = rand_int(0, encode::kOpEntries - 1);
    in.f2 = rand_int(0, 7);
    in.sz = 1u << rand_int(0, 2);
    in.m = rand_int(0, 7) == 0;
    in.cmdsync = false;
    in.sv.valid = rand_int(0, 7) == 0;
    in.sv.addr = rand_uint32();
    in.sv.data = rand_uint32();

    if (in.op == encode::vevn || in.op == encode::vevnodd ||
        in.op == encode::vodd) {
      // Disallow even/odd in CRT.
      in.op = encode::vadd;
    }

    if (in.op == encode::vdwconv) {
      // Disallow DW in CRT.
      in.op = encode::vadd;
    }

    // Assign random values to inactive read addr/tag.
    for (int i = 0; i < kReadPorts; ++i) {
      in.r[i].valid = false;
      in.r[i].addr = rand_uint32() & (in.m ? 60 : 63);
      in.r[i].tag = rand_int(0, 15);
    }

    // Assign random values to inactive write addr, will be overridden.
    for (int i = 0; i < kWritePorts; ++i) {
      in.w[i].valid = false;
      in.w[i].addr = rand_uint32() & (in.m ? 60 : 63);
    }

    switch (in.op) {
      case encode::vabsd:
      case encode::vadd:
      case encode::vadds:
      case encode::vhadd:
      case encode::vhsub:
      case encode::vmax:
      case encode::vmin:
      case encode::vrsub:
      case encode::vsub:
      case encode::vsubs:
      case encode::veq:
      case encode::vne:
      case encode::vlt:
      case encode::vle:
      case encode::vgt:
      case encode::vge:
      case encode::vand:
      case encode::vclb:
      case encode::vclz:
      case encode::vcpop:
      case encode::vevn:
      case encode::vor:
      case encode::vrev:
      case encode::vror:
      case encode::vxor:
      case encode::vdmulh:
      case encode::vmul:
      case encode::vmulh:
      case encode::vmuls:
      case encode::vshl:
      case encode::vshr:
      case encode::vshf:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.w[0].valid = true;
        break;
      case encode::vaddw:
      case encode::vevnodd:
      case encode::vsubw:
      case encode::vmulw:
      case encode::vmvp:
      case encode::vzip:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.w[0].valid = true;
        in.w[1].valid = true;
        break;
      case encode::vacc:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.r[2].valid = true;
        in.w[0].valid = true;
        in.w[1].valid = true;
        break;
      case encode::vadd3:
      case encode::vmadd:
      case encode::vsrans:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.r[2].valid = true;
        in.w[0].valid = true;
        break;
      case encode::vsraqs:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.r[2].valid = true;
        in.r[3].valid = true;
        in.r[5].valid = true;
        in.w[0].valid = true;
        in.cmdsync = true;
        break;
      case encode::vdup:
        in.r[1].valid = true;
        in.w[0].valid = true;
        break;
      case encode::vmv:
      case encode::vpadd:
      case encode::vpsub:
        in.r[0].valid = true;
        in.w[0].valid = true;
        break;
      case encode::vodd:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.w[1].valid = true;
        break;
      case encode::vdwconv:
        in.r[0].valid = true;
        in.r[1].valid = true;
        in.r[2].valid = true;
        in.r[3].valid = true;
        in.r[4].valid = true;
        in.r[5].valid = true;
        in.w[0].valid = true;
        in.w[1].valid = true;
        in.w[2].valid = true;
        in.w[3].valid = true;
        in.cmdsync = true;
        break;
      default:
        valid = false;
        // Assign random values, should not be accepted by queue.
        for (int i = 0; i < kReadPorts; ++i) {
          in.r[i].valid = rand_bool();
        }
        for (int i = 0; i < kWritePorts; ++i) {
          in.w[i].valid = rand_bool();
        }
        break;
    }

    if (in.sv.valid) {
      in.r[1].valid = false;
    }

    // Assign inactive write addresses.
    if (in.op == encode::vzip) {
      int addr = 0;
      valid = valid && FindInactiveWriteAddr2(in.m, wactive, addr);
      in.w[0].valid = valid;
      in.w[0].addr = addr;
      in.w[1].valid = valid;
      in.w[1].addr = addr + 1;
    } else {
      for (int i = 0; i < kWritePorts; ++i) {
        if (in.w[i].valid) {
          int addr = 0;
          valid = valid && FindInactiveWriteAddr(in.m, wactive, addr);
          in.w[i].addr = addr;
        }
      }
      for (int i = 0; i < kWritePorts; ++i) {
        in.w[i].valid &= valid;
      }
    }

    if (valid) {
      int raddr[7] = {in.r[0].addr, in.r[1].addr, in.r[2].addr, in.r[3].addr,
                      in.r[4].addr, in.r[5].addr, in.r[6].addr};
      int waddr[4] = {in.w[0].addr, in.w[1].addr, in.w[2].addr, in.w[3].addr};
      for (int m = 0; m < (in.m ? 4 : 1); ++m) {
        valu_t alu;
        alu.op = in.op;
        alu.f2 = in.f2;
        alu.sz = in.sz;
        alu.sv.data = in.sv.data;
        for (int i = 0; i < kReadPorts; ++i) {
          alu.r[i].valid = in.r[i].valid;
          alu.r[i].addr = raddr[i];
          for (int j = 0; j < kLanes; ++j) {
            alu.in[i].data[j] = regs_[raddr[i]][j];
          }
          raddr[i]++;  // stripmine update
        }

        // Scalar read first register.
        alu.scalar.valid = in.sv.valid;
        if (in.sv.valid) {
          for (int j = 0; j < kLanes; ++j) {
            alu.in[1].data[j] = scalar_[j];
          }
        }

        for (int i = 0; i < kWritePorts; ++i) {
          alu.w[i].valid = false;
          alu.w[i].addr = waddr[i];
        }

        VAlu(alu);  // the reference model

        for (int i = 0; i < kWritePorts; ++i) {
          if (alu.w[i].valid) {
            wactive |= 1ull << waddr[i];
            if (in.op == encode::vzip) {
              waddr[i] += 2;
            } else {
              waddr[i]++;  // stripmine update
            }
          }
        }

        cmdq_[idx].write(alu);
      }
    }

#define IN_BITS(x)                                  \
  if (idx == x) {                                   \
    io_in_bits_##x##_valid = valid;                 \
    io_in_bits_##x##_bits_op = in.op;               \
    io_in_bits_##x##_bits_f2 = in.f2;               \
    io_in_bits_##x##_bits_sz = in.sz;               \
    io_in_bits_##x##_bits_m = in.m;                 \
    io_in_bits_##x##_bits_vd_valid = in.w[0].valid; \
    io_in_bits_##x##_bits_ve_valid = in.w[1].valid; \
    io_in_bits_##x##_bits_vf_valid = in.w[2].valid; \
    io_in_bits_##x##_bits_vg_valid = in.w[3].valid; \
    io_in_bits_##x##_bits_vs_valid = in.r[0].valid; \
    io_in_bits_##x##_bits_vt_valid = in.r[1].valid; \
    io_in_bits_##x##_bits_vu_valid = in.r[2].valid; \
    io_in_bits_##x##_bits_vx_valid = in.r[3].valid; \
    io_in_bits_##x##_bits_vy_valid = in.r[4].valid; \
    io_in_bits_##x##_bits_vz_valid = in.r[5].valid; \
    io_in_bits_##x##_bits_vd_addr = in.w[0].addr;   \
    io_in_bits_##x##_bits_ve_addr = in.w[1].addr;   \
    io_in_bits_##x##_bits_vf_addr = in.w[2].addr;   \
    io_in_bits_##x##_bits_vg_addr = in.w[3].addr;   \
    io_in_bits_##x##_bits_vs_addr = in.r[0].addr;   \
    io_in_bits_##x##_bits_vt_addr = in.r[1].addr;   \
    io_in_bits_##x##_bits_vu_addr = in.r[2].addr;   \
    io_in_bits_##x##_bits_vx_addr = in.r[3].addr;   \
    io_in_bits_##x##_bits_vy_addr = in.r[4].addr;   \
    io_in_bits_##x##_bits_vz_addr = in.r[5].addr;   \
    io_in_bits_##x##_bits_vs_tag = in.r[0].tag;     \
    io_in_bits_##x##_bits_vt_tag = in.r[1].tag;     \
    io_in_bits_##x##_bits_vu_tag = in.r[2].tag;     \
    io_in_bits_##x##_bits_vx_tag = in.r[3].tag;     \
    io_in_bits_##x##_bits_vy_tag = in.r[4].tag;     \
    io_in_bits_##x##_bits_vz_tag = in.r[5].tag;     \
    io_in_bits_##x##_bits_sv_valid = in.sv.valid;   \
    io_in_bits_##x##_bits_sv_addr = in.sv.addr;     \
    io_in_bits_##x##_bits_sv_data = in.sv.data;     \
    io_in_bits_##x##_bits_cmdsync = in.cmdsync;     \
  }
    REPEAT(IN_BITS, KP_instructionLanes);
  }
#undef IN_BITS

#define IDX_NOT_VALID(x) || ((idx == x) && !io_in_bits_##x##_valid)
  void ProcessInputs(const int idx) {
    // clang-format off
    if (!(io_in_valid && io_in_ready) REPEAT(IDX_NOT_VALID, KP_instructionLanes)) {
      cmdq_[idx].clear();
      return;
    }
    // clang-format on
#undef IDX_NOT_VALID

    valu_t op;
    while (cmdq_[idx].read(op)) {
      bool has_write = false;
      for (int i = 0; i < kWritePorts; ++i) {
        if (op.w[i].valid) {
          const int addr = op.w[i].addr;
          const uint32_t* data = op.out[i].data;
          check(!write_[addr].valid, "ProcessInputs::io.write.valid");
          write_[addr].valid = true;
          wactive_ |= 1ull << addr;
          write_[addr].op = op.op;
          write_[addr].f2 = op.f2;
          write_[addr].sz = op.sz;
          for (int j = 0; j < kReadPorts; ++j) {
            write_[addr].r[j].valid = op.r[j].valid;
            write_[addr].r[j].addr = op.r[j].addr;
          }
          for (int j = 0; j < kLanes; ++j) {
            write_[addr].data[j] = data[j];
          }
        }
        has_write = true;
      }
      if (has_write) {
        for (int j = 0; j < kReadPorts; ++j) {
          if (op.r[j].valid) {  // only add reads once
            read_[op.r[j].addr]++;
          }
        }
      }
    }
  }

  void ProcessOutputs(const int idx) {
    // clang-format off
    if ((idx == 0 && !io_write_0_valid) ||
        (idx == 1 && !io_write_1_valid) ||
        (idx == 2 && !io_write_2_valid) ||
        (idx == 3 && !io_write_3_valid)) {
      return;
    }
    // clang-format on

    int addr;
    uint32_t dut[kLanes];
#define OUT_WRITE(x)                                   \
  if (idx == x) {                                      \
    addr = io_write_##x##_addr.read().get_word(0);     \
    for (int i = 0; i < kLanes; ++i) {                 \
      dut[i] = io_write_##x##_data.read().get_word(i); \
    }                                                  \
  }
    REPEAT(OUT_WRITE, 4);
#undef OUT_WRITE

    check(write_[addr].valid, "ProcessOutputs::io.write.valid");
    write_[addr].valid = false;
    wactive_ &= ~(1ull << addr);

    uint32_t* ref = write_[addr].data;

    if (memcmp(dut, ref, kLanes * 4)) {
      char s[100];
      snprintf(s, sizeof(s), "valu op=%d f2=%d sz=%d", write_[addr].op,
               write_[addr].f2, write_[addr].sz);
      printf("ref[%2d]  ", addr);
      for (int i = 0; i < kLanes; ++i) {
        printf(" %08x", ref[i]);
      }
      printf("\n");
      printf("dut[%2d]  ", addr);
      for (int i = 0; i < kLanes; ++i) {
        printf(" %08x", dut[i]);
      }
      printf("\n");
      for (int j = 0; j < kReadPorts; ++j) {
        bool active = write_[addr].r[j].valid;
        const int ridx = write_[addr].r[j].addr;
        printf("read[%c][%2d] ", active ? 'x' : ' ', ridx);
        for (int i = 0; i < kLanes; ++i) {
          printf(" %08x", regs_[ridx][i]);
        }
        printf("\n");
      }
      check(false, s);
    }
  }
};

static void VAlu_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_read_0_valid;
  sc_signal<bool> io_read_1_valid;
  sc_signal<bool> io_read_2_valid;
  sc_signal<bool> io_read_3_valid;
  sc_signal<bool> io_read_4_valid;
  sc_signal<bool> io_read_5_valid;
  sc_signal<bool> io_read_6_valid;
  sc_signal<bool> io_read_0_ready;
  sc_signal<bool> io_read_1_ready;
  sc_signal<bool> io_read_2_ready;
  sc_signal<bool> io_read_3_ready;
  sc_signal<bool> io_read_4_ready;
  sc_signal<bool> io_read_5_ready;
  sc_signal<bool> io_read_6_ready;
  sc_signal<bool> io_write_0_valid;
  sc_signal<bool> io_write_1_valid;
  sc_signal<bool> io_write_2_valid;
  sc_signal<bool> io_write_3_valid;
  sc_signal<bool> io_whint_0_valid;
  sc_signal<bool> io_whint_1_valid;
  sc_signal<bool> io_whint_2_valid;
  sc_signal<bool> io_whint_3_valid;
  sc_signal<bool> io_scalar_0_valid;
  sc_signal<bool> io_scalar_1_valid;
  sc_signal<sc_bv<64> > io_active;
  sc_signal<sc_bv<128> > io_vrfsb;
  sc_signal<sc_bv<6> > io_read_0_addr;
  sc_signal<bool> io_read_0_tag;
  sc_signal<sc_bv<kVector> > io_read_0_data;
  sc_signal<sc_bv<6> > io_read_1_addr;
  sc_signal<bool> io_read_1_tag;
  sc_signal<sc_bv<kVector> > io_read_1_data;
  sc_signal<sc_bv<6> > io_read_2_addr;
  sc_signal<bool> io_read_2_tag;
  sc_signal<sc_bv<kVector> > io_read_2_data;
  sc_signal<sc_bv<6> > io_read_3_addr;
  sc_signal<bool> io_read_3_tag;
  sc_signal<sc_bv<kVector> > io_read_3_data;
  sc_signal<sc_bv<6> > io_read_4_addr;
  sc_signal<bool> io_read_4_tag;
  sc_signal<sc_bv<kVector> > io_read_4_data;
  sc_signal<sc_bv<6> > io_read_5_addr;
  sc_signal<bool> io_read_5_tag;
  sc_signal<sc_bv<kVector> > io_read_5_data;
  sc_signal<sc_bv<6> > io_read_6_addr;
  sc_signal<bool> io_read_6_tag;
  sc_signal<sc_bv<kVector> > io_read_6_data;
  sc_signal<sc_bv<6> > io_write_0_addr;
  sc_signal<sc_bv<kVector> > io_write_0_data;
  sc_signal<sc_bv<6> > io_write_1_addr;
  sc_signal<sc_bv<kVector> > io_write_1_data;
  sc_signal<sc_bv<6> > io_write_2_addr;
  sc_signal<sc_bv<kVector> > io_write_2_data;
  sc_signal<sc_bv<6> > io_write_3_addr;
  sc_signal<sc_bv<kVector> > io_write_3_data;
  sc_signal<sc_bv<6> > io_whint_0_addr;
  sc_signal<sc_bv<6> > io_whint_1_addr;
  sc_signal<sc_bv<6> > io_whint_2_addr;
  sc_signal<sc_bv<6> > io_whint_3_addr;
  sc_signal<sc_bv<32> > io_scalar_0_data;
  sc_signal<sc_bv<32> > io_scalar_1_data;
#define IO_BITS(x)                                     \
  sc_signal<bool> io_in_bits_##x##_valid;              \
  sc_signal<bool> io_in_bits_##x##_bits_m;             \
  sc_signal<bool> io_in_bits_##x##_bits_vd_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_ve_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vf_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vg_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vs_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vt_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vu_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vx_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vy_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_vz_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_sv_valid;      \
  sc_signal<bool> io_in_bits_##x##_bits_cmdsync;       \
  sc_signal<sc_bv<7> > io_in_bits_##x##_bits_op;       \
  sc_signal<sc_bv<3> > io_in_bits_##x##_bits_f2;       \
  sc_signal<sc_bv<3> > io_in_bits_##x##_bits_sz;       \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vd_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_ve_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vf_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vg_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vs_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vt_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vu_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vx_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vy_addr;  \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vz_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vs_tag;   \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vt_tag;   \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vu_tag;   \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vx_tag;   \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vy_tag;   \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vz_tag;   \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_sv_addr; \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_sv_data;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  VAlu_tb tb("VAlu_tb", loops);
  VVAlu valu(name);

  if (trace) {
    tb.trace(&valu);
  }

  valu.clock(tb.clock);
  valu.reset(tb.reset);
  BIND2(tb, valu, io_in_ready);
  BIND2(tb, valu, io_in_valid);
  BIND2(tb, valu, io_read_0_valid);
  BIND2(tb, valu, io_read_1_valid);
  BIND2(tb, valu, io_read_2_valid);
  BIND2(tb, valu, io_read_3_valid);
  BIND2(tb, valu, io_read_4_valid);
  BIND2(tb, valu, io_read_5_valid);
  BIND2(tb, valu, io_read_6_valid);
  BIND2(tb, valu, io_read_0_ready);
  BIND2(tb, valu, io_read_1_ready);
  BIND2(tb, valu, io_read_2_ready);
  BIND2(tb, valu, io_read_3_ready);
  BIND2(tb, valu, io_read_4_ready);
  BIND2(tb, valu, io_read_5_ready);
  BIND2(tb, valu, io_read_6_ready);
  BIND2(tb, valu, io_write_0_valid);
  BIND2(tb, valu, io_write_1_valid);
  BIND2(tb, valu, io_write_2_valid);
  BIND2(tb, valu, io_write_3_valid);
  BIND2(tb, valu, io_whint_0_valid);
  BIND2(tb, valu, io_whint_1_valid);
  BIND2(tb, valu, io_whint_2_valid);
  BIND2(tb, valu, io_whint_3_valid);
  BIND2(tb, valu, io_scalar_0_valid);
  BIND2(tb, valu, io_scalar_1_valid);
  BIND2(tb, valu, io_active);
  BIND2(tb, valu, io_vrfsb);
  BIND2(tb, valu, io_read_0_addr);
  BIND2(tb, valu, io_read_0_tag);
  BIND2(tb, valu, io_read_0_data);
  BIND2(tb, valu, io_read_1_addr);
  BIND2(tb, valu, io_read_1_tag);
  BIND2(tb, valu, io_read_1_data);
  BIND2(tb, valu, io_read_2_addr);
  BIND2(tb, valu, io_read_2_tag);
  BIND2(tb, valu, io_read_2_data);
  BIND2(tb, valu, io_read_3_addr);
  BIND2(tb, valu, io_read_3_tag);
  BIND2(tb, valu, io_read_3_data);
  BIND2(tb, valu, io_read_4_addr);
  BIND2(tb, valu, io_read_4_tag);
  BIND2(tb, valu, io_read_4_data);
  BIND2(tb, valu, io_read_5_addr);
  BIND2(tb, valu, io_read_5_tag);
  BIND2(tb, valu, io_read_5_data);
  BIND2(tb, valu, io_read_6_addr);
  BIND2(tb, valu, io_read_6_tag);
  BIND2(tb, valu, io_read_6_data);
  BIND2(tb, valu, io_write_0_addr);
  BIND2(tb, valu, io_write_0_data);
  BIND2(tb, valu, io_write_1_addr);
  BIND2(tb, valu, io_write_1_data);
  BIND2(tb, valu, io_write_2_addr);
  BIND2(tb, valu, io_write_2_data);
  BIND2(tb, valu, io_write_3_addr);
  BIND2(tb, valu, io_write_3_data);
  BIND2(tb, valu, io_whint_0_addr);
  BIND2(tb, valu, io_whint_1_addr);
  BIND2(tb, valu, io_whint_2_addr);
  BIND2(tb, valu, io_whint_3_addr);
  BIND2(tb, valu, io_scalar_0_data);
  BIND2(tb, valu, io_scalar_1_data);
#define IO_BIND(x)                                 \
  BIND2(tb, valu, io_in_bits_##x##_valid);         \
  BIND2(tb, valu, io_in_bits_##x##_bits_m);        \
  BIND2(tb, valu, io_in_bits_##x##_bits_vd_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_ve_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vf_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vg_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vs_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vt_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vu_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vx_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vy_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_vz_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_sv_valid); \
  BIND2(tb, valu, io_in_bits_##x##_bits_cmdsync);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_op);       \
  BIND2(tb, valu, io_in_bits_##x##_bits_f2);       \
  BIND2(tb, valu, io_in_bits_##x##_bits_sz);       \
  BIND2(tb, valu, io_in_bits_##x##_bits_vd_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_ve_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vf_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vg_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vs_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vt_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vu_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vx_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vy_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vz_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_vs_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_vt_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_vu_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_vx_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_vy_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_vz_tag);   \
  BIND2(tb, valu, io_in_bits_##x##_bits_sv_addr);  \
  BIND2(tb, valu, io_in_bits_##x##_bits_sv_data);
  REPEAT(IO_BIND, KP_instructionLanes);
#undef IO_BIND

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VAlu_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
