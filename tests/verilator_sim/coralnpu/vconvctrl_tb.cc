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

#include "VVConvCtrl.h"
#include "hdl/chisel/src/coralnpu/VCore_parameters.h"
#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/coralnpu/vencodeop.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

using encode::aconv;
using encode::vcget;
using encode::acset;
using encode::actr;

constexpr int kIndex = ctz(kVector / 32);

struct VConvCtrl_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_in<bool> io_out_valid;
  sc_in<bool> io_out_ready;
  sc_in<bool> io_out_op_conv;
  sc_in<bool> io_out_op_init;
  sc_in<bool> io_out_op_tran;
  sc_in<bool> io_out_op_wclr;
  sc_in<bool> io_out_asign;
  sc_in<bool> io_out_bsign;
  sc_in<sc_bv<64> > io_active;
  sc_out<sc_bv<128> > io_vrfsb;
  sc_in<sc_bv<6> > io_out_addr1;
  sc_in<sc_bv<6> > io_out_addr2;
  sc_in<sc_bv<2> > io_out_mode;
  sc_in<sc_bv<kIndex> > io_out_index;
  sc_in<sc_bv<9> > io_out_abias;
  sc_in<sc_bv<9> > io_out_bbias;
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
    uint64_t aref = Active();
    uint64_t adut = io_active.read().get_word(0) |
                    (uint64_t(io_active.read().get_word(1)) << 32);
    if (aref != adut) {
      printf("**error::Active %08x:%08x : %08x:%08x\n", uint32_t(aref >> 32),
             uint32_t(aref), uint32_t(adut >> 32), uint32_t(adut));
      check(false);
    }

    constexpr uint32_t limit = (kVector / 32) - 1;
    constexpr uint32_t vs_mask = ~limit;

    // Inputs.
#define IN_RAND(idx)                                                         \
  {                                                                          \
    const int ops[] = {aconv, vcget, acset, actr};                           \
    const int op = ops[rand_int(0, 3)];                                      \
    const bool valid = rand_bool();                                          \
    const bool m = 0;                                                        \
    const uint32_t mode = 0;                                                 \
    const uint32_t start = rand_uint32(0, limit);                            \
    const uint32_t stop  = std::min(limit, start + rand_uint32(0, limit));   \
    const uint32_t sbias1 = rand_uint32() & 0x1ff;                           \
    const uint32_t sdata1 = rand_uint32() & 1;                               \
    const uint32_t sbias2 = rand_uint32() & 0x1ff;                           \
    const uint32_t sdata2 = rand_uint32() & 1;                               \
    const int vd = 48;                                                       \
    const int vs = std::min(47u, rand_uint32() & 63) & vs_mask;              \
    const int vu = std::min(47u - (stop - start), rand_uint32() & 63);       \
    const uint32_t data = (sdata2 << 31) | (sbias2 << 22) | (sdata1 << 21) | \
                          (sbias1 << 12) | (stop << 7) | (start << 2) |      \
                          (mode << 0);                                       \
                                                                             \
    io_in_bits_##idx##_valid = valid;                                        \
    io_in_bits_##idx##_bits_m = m;                                           \
    io_in_bits_##idx##_bits_vd_valid = false;                                \
    io_in_bits_##idx##_bits_vs_valid = false;                                \
    io_in_bits_##idx##_bits_vt_valid = false;                                \
    io_in_bits_##idx##_bits_vu_valid = false;                                \
    io_in_bits_##idx##_bits_op = op;                                         \
    io_in_bits_##idx##_bits_sz = 1 << rand_int(0, 2);                        \
    io_in_bits_##idx##_bits_vd_addr = vd;                                    \
    io_in_bits_##idx##_bits_vs_addr = vs;                                    \
    io_in_bits_##idx##_bits_vu_addr = vu;                                    \
    io_in_bits_##idx##_bits_sv_data = data;                                  \
  }

    io_in_valid = rand_int(0, 7) == 0;  // Try to hit both full and empty.

    REPEAT(IN_RAND, KP_instructionLanes);
#undef IN_RAND

#if 1
    // Scoreboard.
    sc_bv<128> vrfsb = 0;
    for (int i = 0; i < 4; ++i) {
      vrfsb.set_bit(rand_int(0, 127), sc_dt::Log_1);
    }
    io_vrfsb = vrfsb;
#endif

#define IN_READ(idx)                                           \
  if (io_in_bits_##idx##_valid) {                              \
    Input(io_in_bits_##idx##_bits_op.read().get_word(0),       \
          io_in_bits_##idx##_bits_vd_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_vs_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_vu_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_sv_data.read().get_word(0)); \
  }

    if (io_in_valid && io_in_ready) {
      REPEAT(IN_READ, KP_instructionLanes);
    }
#undef IN_READ

    // Outputs.
    conv_t dut, ref;
    dut.conv  = io_out_op_conv;
    dut.init  = io_out_op_init;
    dut.tran  = io_out_op_tran;
    dut.wclr  = io_out_op_wclr;
    dut.addr1 = io_out_addr1.read().get_word(0);
    dut.addr2 = io_out_addr2.read().get_word(0);
    dut.index = io_out_index.read().get_word(0);
    dut.asign = io_out_asign;
    dut.bsign = io_out_bsign;
    dut.abias = io_out_abias.read().get_word(0);
    dut.bbias = io_out_bbias.read().get_word(0);

    // Write clear.
    if (io_out_valid && io_out_ready) {
      // Outputs must match.
      check(conv_.read(ref), "conv[1] fifo empty");
      if (ref != dut) {
        printf("**error::vconv\n");
        ref.print("ref");
        dut.print("dut");
        check(false);
      }
    }
  }

 private:
  struct conv_t {
    uint8_t op : 7;
    bool conv;
    bool init;
    bool tran;
    bool wclr;
    uint8_t addr1 : 6;
    uint8_t addr2 : 6;
    uint32_t index : 8;
    uint32_t asign : 1;
    uint32_t bsign : 1;
    uint32_t abias : 9;
    uint32_t bbias : 9;

    bool operator!=(const conv_t& rhs) const {
      if (conv  != rhs.conv)  return true;
      if (tran  != rhs.tran)  return true;
      if (wclr  != rhs.wclr)  return true;

      if (addr1 != rhs.addr1) return true;
      if (addr2 != rhs.addr2) return true;
      if (index != rhs.index) return true;
      if (asign != rhs.asign) return true;
      if (bsign != rhs.bsign) return true;
      if (abias != rhs.abias) return true;
      if (bbias != rhs.bbias) return true;

      return false;
    }

    void print(const char* name) {
      printf(
          "[%s]: conv=%d tran=%d wclr=%d "
          "addr1=%d addr2=%d index=%d asign=%d bsign=%d "
          "abias=%d "
          "bbias=%d\n",
          name, conv, tran, wclr, addr1, addr2, index, asign, bsign, abias,
          bbias);
    }
  };

  fifo_t<conv_t> conv_;

  void Input(uint8_t op, uint8_t vd_addr, uint8_t vs_addr, uint8_t vu_addr,
             uint32_t data) {
    conv_t c;
    memset(&c, 0, sizeof(conv_t));

    union {
      struct {
        uint32_t mode : 2;
        uint32_t start : 5;
        uint32_t stop : 5;
        uint32_t sbias1 : 9;
        uint32_t sdata1 : 1;
        uint32_t sbias2 : 9;
        uint32_t sdata2 : 1;
      } d;
      static_assert(sizeof(d) == sizeof(uint32_t));
      uint32_t d_u32;
    };

    d_u32 = data;

    assert(d.mode == 0);
    assert(d.stop >= d.start);
    assert((d.stop - d.start) < (kVector / 32));

    c.op = op;
    c.addr1 = vs_addr;
    c.addr2 = vu_addr;
    c.index = d.start;
    c.asign = d.sdata1;
    c.bsign = d.sdata2;
    c.abias = d.sbias1;
    c.bbias = d.sbias2;

    if (op == vcget) {
      c.wclr = true;
      conv_.write(c);
      return;
    }

    if (op == acset || op == actr) {
      if (op == acset) {
        c.addr2 = vs_addr;
      }
      d.start = 0;
      d.stop = (kVector / 32) - 1;
      c.index = 0;
      c.init = op == acset;
      c.tran = op == actr;
      for (int i = d.start; i <= d.stop; ++i) {
        conv_.write(c);
        c.addr2++;
        c.index++;
      }
      return;
    }

    c.conv = true;

    for (int i = d.start; i <= d.stop; ++i) {
      conv_.write(c);
      c.addr2++;
      c.index++;
    }
  }

  uint64_t Active() {
    if (conv_.count() == 0) {
      return 0;
    }
    constexpr uint64_t mask = kVector == 128   ? 0x000f
                              : kVector == 256 ? 0x00ff
                                               : 0xffff;
    uint64_t active = 0;
    for (int i = 0; i < conv_.count(); ++i) {
      conv_t c;
      check(conv_.next(c, i), "values fifo next");

      if (c.op == vcget) continue;

      // Read narrow.
      if (c.op != acset) {
        active |= mask << c.addr1;
      }

      // Read wide.
      if (c.op != actr) {
        active |= 1llu << c.addr2;
      }
    }
    return active;
  }
};

static void VConvCtrl_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_out_valid;
  sc_signal<bool> io_out_ready;
  sc_signal<bool> io_out_op_conv;
  sc_signal<bool> io_out_op_init;
  sc_signal<bool> io_out_op_tran;
  sc_signal<bool> io_out_op_wclr;
  sc_signal<bool> io_out_asign;
  sc_signal<bool> io_out_bsign;
  sc_signal<sc_bv<64> > io_active;
  sc_signal<sc_bv<128> > io_vrfsb;
  sc_signal<sc_bv<6> > io_out_addr1;
  sc_signal<sc_bv<6> > io_out_addr2;
  sc_signal<sc_bv<2> > io_out_mode;
  sc_signal<sc_bv<kIndex> > io_out_index;
  sc_signal<sc_bv<9> > io_out_abias;
  sc_signal<sc_bv<9> > io_out_bbias;
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

  VConvCtrl_tb tb("VConvCtrl_tb", loops, true /*random*/);
  VVConvCtrl conv(name);

  conv.clock(tb.clock);
  conv.reset(tb.reset);
  BIND2(tb, conv, io_in_ready);
  BIND2(tb, conv, io_in_valid);
  BIND2(tb, conv, io_out_valid);
  BIND2(tb, conv, io_out_ready);
  BIND2(tb, conv, io_out_op_conv);
  BIND2(tb, conv, io_out_op_init);
  BIND2(tb, conv, io_out_op_tran);
  BIND2(tb, conv, io_out_op_wclr);
  BIND2(tb, conv, io_out_asign);
  BIND2(tb, conv, io_out_bsign);
  BIND2(tb, conv, io_active);
  BIND2(tb, conv, io_vrfsb);
  BIND2(tb, conv, io_out_addr1);
  BIND2(tb, conv, io_out_addr2);
  BIND2(tb, conv, io_out_mode);
  BIND2(tb, conv, io_out_index);
  BIND2(tb, conv, io_out_abias);
  BIND2(tb, conv, io_out_bbias);
#define IO_BIND(x)                                 \
  BIND2(tb, conv, io_in_bits_##x##_valid);         \
  BIND2(tb, conv, io_in_bits_##x##_bits_m);        \
  BIND2(tb, conv, io_in_bits_##x##_bits_vd_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_ve_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vf_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vg_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vs_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vt_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vu_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vx_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vy_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_vz_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_sv_valid); \
  BIND2(tb, conv, io_in_bits_##x##_bits_cmdsync);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_op);       \
  BIND2(tb, conv, io_in_bits_##x##_bits_f2);       \
  BIND2(tb, conv, io_in_bits_##x##_bits_sz);       \
  BIND2(tb, conv, io_in_bits_##x##_bits_vd_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_ve_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vf_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vg_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vs_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vs_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_vt_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vt_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_vu_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vu_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_vx_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vx_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_vy_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vy_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_vz_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_vz_tag);   \
  BIND2(tb, conv, io_in_bits_##x##_bits_sv_addr);  \
  BIND2(tb, conv, io_in_bits_##x##_bits_sv_data);
  REPEAT(IO_BIND, KP_instructionLanes);
#undef IO_BIND

  if (trace) {
    tb.trace(&conv);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VConvCtrl_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
