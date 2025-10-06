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

#include "VVSt.h"
#include "hdl/chisel/src/coralnpu/VCore_parameters.h"
#include "tests/verilator_sim/coralnpu/core_if.h"
#include "tests/verilator_sim/coralnpu/vencodeop.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

using encode::vld;
using encode::vst;
using encode::vstq;

struct VSt_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_in<bool> io_read_valid;
  sc_out<bool> io_read_ready;
  sc_in<bool> io_read_stall;
  sc_in<bool> io_read_tag;
  sc_out<bool> io_axi_addr_ready;
  sc_in<bool> io_axi_addr_valid;
  sc_out<bool> io_axi_data_ready;
  sc_in<bool> io_axi_data_valid;
  sc_in<bool> io_axi_resp_ready;
  sc_out<bool> io_axi_resp_valid;
  sc_in<bool> io_nempty;
  sc_in<bool> io_vstoreCount;
  sc_in<sc_bv<64> > io_active;
  sc_out<sc_bv<128> > io_vrfsb;
  sc_in<sc_bv<6> > io_read_addr;
  sc_out<sc_bv<kVector> > io_read_data;
  sc_in<sc_bv<32> > io_axi_addr_bits_addr;
  sc_in<sc_bv<6> > io_axi_addr_bits_id;
  sc_in<sc_bv<4> > io_axi_addr_bits_region;
  sc_in<sc_bv<4> > io_axi_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi_addr_bits_cache;
  sc_in<sc_bv<2> > io_axi_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi_addr_bits_size;
  sc_in<sc_bv<8> > io_axi_addr_bits_len;
  sc_in<sc_bv<kVector> > io_axi_data_bits_data;
  sc_in<sc_bv<kUncStrb> > io_axi_data_bits_strb;
  sc_in<bool> io_axi_data_bits_last;
  sc_out<sc_bv<6> > io_axi_resp_bits_id;
  sc_out<sc_bv<2> > io_axi_resp_bits_resp;
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
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vs_tag;   \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vt_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vt_tag;   \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vu_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vu_tag;   \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vx_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vx_tag;   \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vy_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vy_tag;   \
  sc_out<sc_bv<6> > io_in_bits_##x##_bits_vz_addr;  \
  sc_out<sc_bv<4> > io_in_bits_##x##_bits_vz_tag;   \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_sv_addr; \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_sv_data;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // Active.
    const uint64_t active = io_active.read().get_word(0) |
                            (uint64_t(io_active.read().get_word(1)) << 32);
    check(active == Active(), "io.active");

    // Scoreboard.
    sc_bv<128> vrfsb = 0;
    for (int i = 0; i < 4; ++i) {
      vrfsb.set_bit(rand_int(0, 127), sc_dt::Log_1);
    }
    io_vrfsb = vrfsb;

    // Status.
    bool nempty = !waxi_.empty() || !wresp_.empty();
    check(io_nempty == nempty, "io.nempty");

    // Inputs.
    if (io_axi_resp_valid && io_axi_resp_ready) {
      assert(cmd_count_ > 0);
      assert(waxi_count_ > 0);
      cmd_count_--;
      waxi_count_--;
      check(wresp_.remove(), "wresp empty");
    }

    const bool axi_ready = rand_bool();
    io_read_ready = rand_int(0, 7) != 0;
    io_axi_addr_ready = axi_ready;
    io_axi_data_ready = axi_ready;

    waxi_t w;
    io_axi_resp_valid = rand_bool() && wresp_.next(w) && waxi_count_;
    io_axi_resp_bits_resp = 0;
    io_axi_resp_bits_id = w.id;

#define IN_READ(idx)                                                     \
  if (io_in_bits_##idx##_valid) {                                        \
    Input(io_in_bits_##idx##_bits_m,                                     \
          io_in_bits_##idx##_bits_op.read().get_word(0),                 \
          io_in_bits_##idx##_bits_f2.read().get_word(0),                 \
          io_in_bits_##idx##_bits_sz.read().get_word(0),                 \
          io_in_bits_##idx##_bits_vs_valid,                              \
          io_in_bits_##idx##_bits_vs_addr.read().get_word(0),            \
          io_in_bits_##idx##_bits_vs_tag.read().get_word(0),             \
          io_in_bits_##idx##_bits_sv_addr.read().get_word(0),            \
          io_in_bits_##idx##_bits_sv_data.read().get_word(0));           \
    cmd_count_ +=                                                        \
        (io_in_bits_##idx##_bits_m ? 4 : 1) *                            \
        (io_in_bits_##idx##_bits_op.read().get_word(0) == vstq ? 4 : 1); \
  }

    if (io_in_valid && io_in_ready) {
      REPEAT(IN_READ, KP_instructionLanes);
    }
#undef IN_READ

#define IN_RAND(idx)                                                    \
  {                                                                     \
    const bool in_valid = rand_bool();                                  \
    const int op = rand_int(vst, vstq);                                 \
    const bool m = rand_bool();                                         \
    const int vs_addr = rand_uint32() & (m ? 60 : 63);                  \
    const int vs_tag = rand_uint32();                                   \
    const uint8_t f2 = rand_int(0, 7);                                  \
    const bool stride = (f2 >> 1) & 1;                                  \
    const uint32_t mask = ~(op == vst ? (1u << kAlignedLsb) - 1         \
                                      : (1u << (kAlignedLsb - 2)) - 1); \
    uint32_t addr = (rand_uint32() & mask) | 0x80000000u;               \
    uint32_t data = rand_uint32() >> rand_int(0, 32);                   \
    data = std::min(((0xffffffffu - addr) / 64), data);                 \
    if (stride) data = data & mask;                                     \
    if (in_valid) cmd_valid += m ? 4 : 1;                               \
    io_in_bits_##idx##_valid = in_valid;                                \
    io_in_bits_##idx##_bits_op = op;                                    \
    io_in_bits_##idx##_bits_f2 = f2;                                    \
    io_in_bits_##idx##_bits_sz = 1 << rand_int(0, 2);                   \
    io_in_bits_##idx##_bits_m = m;                                      \
    io_in_bits_##idx##_bits_vs_valid = op == vst || op == vstq;         \
    io_in_bits_##idx##_bits_vs_addr = vs_addr;                          \
    io_in_bits_##idx##_bits_vs_tag = vs_tag;                            \
    io_in_bits_##idx##_bits_sv_valid = false;                           \
    io_in_bits_##idx##_bits_sv_addr = addr;                             \
    io_in_bits_##idx##_bits_sv_data = data;                             \
  }

    int cmd_valid = 0;

    REPEAT(IN_RAND, KP_instructionLanes);
#undef IN_RAND

    io_in_valid = rand_int(0, 4) == 0 && (cmd_count_ + cmd_valid) <= 256;

    // Outputs.
    if (io_read_valid) {
      rreg_t r;
      check(rreg_.next(r), "rreg empty");
      if (io_read_ready && !io_read_stall) {
        rreg_.remove();
      }

      int ref = r.addr;
      int dut = io_read_addr.read().get_word(0);
      if (ref != dut) {
        printf("read.addr %d %d\n", ref, dut);
        check(false, "vs.addr");
      }

      ref = r.tag;
      dut = io_read_tag.read();
      if (ref != dut) {
        printf("read.tag %d %d\n", ref, dut);
        check(false, "vs.tag");
      }

      sc_bv<kVector> rbits;
      const uint32_t* src = reinterpret_cast<const uint32_t*>(r.data);
      for (int i = 0; i < kVector / 32; ++i) {
        rbits.set_word(i, src[i]);
      }
      io_read_data = rbits;
    }

    if (io_axi_addr_valid && io_axi_addr_ready) {
      waxi_t ref, dut;
      check(waxi_.read(ref), "axi empty");
      waxi_count_++;
      dut.addr = io_axi_addr_bits_addr.read().get_word(0);
      dut.id   = io_axi_addr_bits_id.read().get_word(0);
      uint32_t* dst = reinterpret_cast<uint32_t*>(dut.data);
      for (int i = 0; i < kVector / 32; ++i) {
        dst[i] = io_axi_data_bits_data.read().get_word(i);
      }
      for (int i = 0; i < kVector / 8; i += 32) {
        const uint32_t strb = io_axi_data_bits_strb.read().get_word(i / 32);
        for (int j = 0; j < std::min(32, kVector / 8); ++j) {
          dut.strb[i + j] = strb & (1u << j) ? 1 : 0;
        }
      }

      if (ref != dut) {
        ref.print("ref");
        dut.print("dut");
        check(false, "io.axi");
      }
    }
  }

 private:
  struct waxi_t {
    uint32_t addr;
    uint32_t id;
    uint32_t size;
    uint8_t data[kVector / 8];
    uint8_t strb[kVector / 8];

    bool operator!=(const waxi_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (id   != rhs.id) return true;
      if (memcmp(data, rhs.data, kVector / 8)) return true;
      if (memcmp(strb, rhs.strb, kVector / 8)) return true;
      return false;
    }

    void print(const char* name) {
      printf("axi::%s addr=%08x id=%d", name, addr, id);
      printf("  data=");
      for (int i = 0; i < kVector / 8; ++i) {
        if (i) printf(" ");
        printf("%02x", data[i]);
      }
      printf("  strb=");
      for (int i = 0; i < kVector / 8; ++i) {
        if (i) printf(" ");
        printf("%02x", strb[i]);
      }
      printf("\n");
    }
  };

  struct rreg_t {
    uint8_t addr : 6;
    uint8_t tag : 1;
    uint8_t data[kVector / 8];
  };

  fifo_t<waxi_t> waxi_;
  fifo_t<waxi_t> wresp_;
  fifo_t<rreg_t> rreg_;
  int cmd_count_ = 0;
  int waxi_count_ = 0;

  void Input(bool m, uint8_t op, uint8_t f2, uint8_t sz, bool vs_valid,
             uint8_t vs_addr, uint8_t vs_tag, uint32_t addr, uint32_t data) {
    const bool stride = (f2 >> 1) & 1;
    const bool length = (f2 >> 0) & 1;

    const int sm = m ? 4 : 1;
    uint32_t offset = 0;
    uint32_t remain = 0;

    if (stride) {
      offset = data * sz;
    } else {
      offset = VLENB;
    }

    if (length) {
      switch (sz) {
        case 1:
          remain = 1 * std::min(VLENB * sm, data);
          break;
        case 2:
          remain = 2 * std::min(VLENH * sm, data);
          break;
        case 4:
          remain = 4 * std::min(VLENW * sm, data);
          break;
        default:
          assert(false);
          break;
      }
    } else {
      remain = VLENB * sm;
    }

    for (int i = 0; i < (m ? 4 : 1); ++i) {
      rreg_t r;
      if (vs_valid) {
        r.addr = vs_addr;
        r.tag = vs_tag >> (vs_addr & 3);
        uint32_t* dst = reinterpret_cast<uint32_t*>(r.data);
        for (int i = 0; i < kVector / 32; ++i) {
          dst[i] = rand_uint32();
        }
      }

      const bool is_vstq = op == vstq;

      WAxi(0, op, offset, stride, r, addr, remain);
      if (is_vstq) {
        rreg_.write(r);
        rreg_.write(r);
        rreg_.write(r);

        WAxi(1, op, offset, stride, r, addr, remain);
        WAxi(2, op, offset, stride, r, addr, remain);
        WAxi(3, op, offset, stride, r, addr, remain);
      }

      if (vs_valid) rreg_.write(r);
      if (vs_valid) vs_addr++;
    }
  }

  void WAxi(const int step, const uint8_t op, const uint32_t offset,
           const bool stride, const rreg_t& r, uint32_t& addr,
           uint32_t& remain) {
    const bool is_vstq = op == vstq;
    const uint32_t lsb_addr = addr & ((kVector / 8) - 1);
    const uint32_t vstq_quad = step;
    const uint32_t vstq_offset = vstq_quad << (kAlignedLsb - 2);
    const uint8_t* src = reinterpret_cast<const uint8_t*>(r.data);

    waxi_t w;
    w.addr = addr & ~0x80000000 & ~(VLENB - 1);  // align to line
    w.size = std::min(remain, is_vstq ? VLENB / 4 : VLENB);
    w.id   = r.addr;

    uint8_t* dst = reinterpret_cast<uint8_t*>(w.data);

    for (int i = 0; i < kVector / 8; ++i) {
      const int idx0 = (i + lsb_addr) % (kVector / 8);
      const int idx1 = is_vstq ? (i % (kVector / 8 / 4)) + vstq_offset : i;
      w.strb[idx0] = static_cast<uint8_t>(static_cast<uint32_t>(i) < w.size);
      dst[i] = src[idx1];
    }

    wresp_.write(w);
    waxi_.write(w);

    if (stride) {
      addr += offset;
    } else {
      addr += op == vstq ? VLENB / 4 : VLENB;
    }

    remain = std::max(0u, remain - w.size);
  }

  uint64_t Active() {
    uint64_t active = 0;
    for (int i = 0; i < rreg_.count(); ++i) {
      rreg_t v;
      check(rreg_.next(v, i), "rreg active");
      active |= 1ull << v.addr;
    }
    return active;
  }
};

static void VSt_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_read_valid;
  sc_signal<bool> io_read_ready;
  sc_signal<bool> io_read_stall;
  sc_signal<bool> io_read_tag;
  sc_signal<bool> io_axi_addr_ready;
  sc_signal<bool> io_axi_addr_valid;
  sc_signal<bool> io_axi_data_ready;
  sc_signal<bool> io_axi_data_valid;
  sc_signal<bool> io_axi_resp_ready;
  sc_signal<bool> io_axi_resp_valid;
  sc_signal<bool> io_nempty;
  sc_signal<bool> io_vstoreCount;
  sc_signal<sc_bv<64> > io_active;
  sc_signal<sc_bv<128> > io_vrfsb;
  sc_signal<sc_bv<6> > io_read_addr;
  sc_signal<sc_bv<kVector> > io_read_data;
  sc_signal<sc_bv<32> > io_axi_addr_bits_addr;
  sc_signal<sc_bv<6> > io_axi_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi_addr_bits_cache;
  sc_signal<sc_bv<2> > io_axi_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi_addr_bits_len;
  sc_signal<sc_bv<kVector> > io_axi_data_bits_data;
  sc_signal<sc_bv<kUncStrb> > io_axi_data_bits_strb;
  sc_signal<bool> io_axi_data_bits_last;
  sc_signal<sc_bv<6> > io_axi_resp_bits_id;
  sc_signal<sc_bv<2> > io_axi_resp_bits_resp;
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
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vs_tag;   \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vt_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vt_tag;   \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vu_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vu_tag;   \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vx_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vx_tag;   \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vy_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vy_tag;   \
  sc_signal<sc_bv<6> > io_in_bits_##x##_bits_vz_addr;  \
  sc_signal<sc_bv<4> > io_in_bits_##x##_bits_vz_tag;   \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_sv_addr; \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_sv_data;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  VSt_tb tb("VSt_tb", loops, true /*random*/);
  VVSt st(name);

  st.clock(tb.clock);
  st.reset(tb.reset);
  BIND2(tb, st, io_in_ready);
  BIND2(tb, st, io_in_valid);
  BIND2(tb, st, io_read_valid);
  BIND2(tb, st, io_read_ready);
  BIND2(tb, st, io_read_stall);
  BIND2(tb, st, io_read_tag);
  BIND2(tb, st, io_axi_addr_ready);
  BIND2(tb, st, io_axi_addr_valid);
  BIND2(tb, st, io_axi_data_ready);
  BIND2(tb, st, io_axi_data_valid);
  BIND2(tb, st, io_axi_resp_ready);
  BIND2(tb, st, io_axi_resp_valid);
  BIND2(tb, st, io_nempty);
  BIND2(tb, st, io_vstoreCount);
  BIND2(tb, st, io_active);
  BIND2(tb, st, io_vrfsb);
  BIND2(tb, st, io_read_addr);
  BIND2(tb, st, io_read_data);
  BIND2(tb, st, io_axi_addr_bits_addr);
  BIND2(tb, st, io_axi_addr_bits_id);
  BIND2(tb, st, io_axi_addr_bits_region);
  BIND2(tb, st, io_axi_addr_bits_qos);
  BIND2(tb, st, io_axi_addr_bits_prot);
  BIND2(tb, st, io_axi_addr_bits_cache);
  BIND2(tb, st, io_axi_addr_bits_lock);
  BIND2(tb, st, io_axi_addr_bits_burst);
  BIND2(tb, st, io_axi_addr_bits_size);
  BIND2(tb, st, io_axi_addr_bits_len);
  BIND2(tb, st, io_axi_data_bits_data);
  BIND2(tb, st, io_axi_data_bits_strb);
  BIND2(tb, st, io_axi_data_bits_last);
  BIND2(tb, st, io_axi_resp_bits_id);
  BIND2(tb, st, io_axi_resp_bits_resp);
#define IO_BIND(x)                               \
  BIND2(tb, st, io_in_bits_##x##_valid);         \
  BIND2(tb, st, io_in_bits_##x##_bits_m);        \
  BIND2(tb, st, io_in_bits_##x##_bits_vd_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_ve_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vf_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vg_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vs_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vt_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vu_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vx_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vy_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_vz_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_sv_valid); \
  BIND2(tb, st, io_in_bits_##x##_bits_cmdsync);  \
  BIND2(tb, st, io_in_bits_##x##_bits_op);       \
  BIND2(tb, st, io_in_bits_##x##_bits_f2);       \
  BIND2(tb, st, io_in_bits_##x##_bits_sz);       \
  BIND2(tb, st, io_in_bits_##x##_bits_vd_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_ve_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vf_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vg_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vs_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vs_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_vt_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vt_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_vu_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vu_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_vx_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vx_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_vy_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vy_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_vz_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_vz_tag);   \
  BIND2(tb, st, io_in_bits_##x##_bits_sv_addr);  \
  BIND2(tb, st, io_in_bits_##x##_bits_sv_data);
  REPEAT(IO_BIND, KP_instructionLanes);
#undef IO_BIND

  if (trace) {
    tb.trace(&st);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VSt_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
