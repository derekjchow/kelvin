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

#include "VVDecode.h"
#include "hdl/chisel/src/coralnpu/VCore_parameters.h"
#include "tests/verilator_sim/coralnpu/vdecode.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

struct VDecode_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_in<bool> io_stall;
  sc_in<bool> io_undef;
  sc_in<bool> io_nempty;
  sc_in<bool> io_vrfsb_set_valid;
  sc_in<sc_bv<128> > io_vrfsb_set_bits;
  sc_out<sc_bv<128> > io_vrfsb_data;
  sc_out<sc_bv<64> > io_active;
#define IO_BITS(x)                               \
  sc_out<bool> io_in_bits_##x##_valid;           \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_inst; \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_addr; \
  sc_out<sc_bv<32> > io_in_bits_##x##_bits_data; \
  sc_out<bool> io_out_##x##_ready;               \
  sc_in<bool> io_out_##x##_valid;                \
  sc_in<bool> io_out_##x##_bits_m;               \
  sc_in<bool> io_out_##x##_bits_vd_valid;        \
  sc_in<bool> io_out_##x##_bits_ve_valid;        \
  sc_in<bool> io_out_##x##_bits_vf_valid;        \
  sc_in<bool> io_out_##x##_bits_vg_valid;        \
  sc_in<bool> io_out_##x##_bits_vs_valid;        \
  sc_in<bool> io_out_##x##_bits_vt_valid;        \
  sc_in<bool> io_out_##x##_bits_vu_valid;        \
  sc_in<bool> io_out_##x##_bits_vx_valid;        \
  sc_in<bool> io_out_##x##_bits_vy_valid;        \
  sc_in<bool> io_out_##x##_bits_vz_valid;        \
  sc_in<bool> io_out_##x##_bits_sv_valid;        \
  sc_in<bool> io_cmdq_##x##_alu;                 \
  sc_in<bool> io_cmdq_##x##_conv;                \
  sc_in<bool> io_cmdq_##x##_ldst;                \
  sc_in<bool> io_cmdq_##x##_ld;                  \
  sc_in<bool> io_cmdq_##x##_st;                  \
  sc_in<bool> io_out_##x##_bits_cmdsync;         \
  sc_in<sc_bv<7> > io_out_##x##_bits_op;         \
  sc_in<sc_bv<3> > io_out_##x##_bits_f2;         \
  sc_in<sc_bv<3> > io_out_##x##_bits_sz;         \
  sc_in<sc_bv<6> > io_out_##x##_bits_vd_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_ve_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vf_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vg_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vs_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vt_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vu_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vx_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vy_addr;    \
  sc_in<sc_bv<6> > io_out_##x##_bits_vz_addr;    \
  sc_in<sc_bv<4> > io_out_##x##_bits_vs_tag;     \
  sc_in<sc_bv<4> > io_out_##x##_bits_vt_tag;     \
  sc_in<sc_bv<4> > io_out_##x##_bits_vu_tag;     \
  sc_in<sc_bv<4> > io_out_##x##_bits_vx_tag;     \
  sc_in<sc_bv<4> > io_out_##x##_bits_vy_tag;     \
  sc_in<sc_bv<4> > io_out_##x##_bits_vz_tag;     \
  sc_in<sc_bv<32> > io_out_##x##_bits_sv_addr;   \
  sc_in<sc_bv<32> > io_out_##x##_bits_sv_data;   \
  sc_in<sc_bv<64> > io_actv_##x##_ractive;       \
  sc_in<sc_bv<64> > io_actv_##x##_wactive;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // Inputs.
    io_in_valid = rand_bool();

#define RAND_IO(x)                      \
  io_in_bits_##x##_valid = rand_bool(); \
  io_out_##x##_ready = rand_bool();

    REPEAT(RAND_IO, KP_instructionLanes);
#undef RAND_IO

    int n = rand_int(0, 8);
    sc_bv<64> active = 0;
    for (int i = 0; i < n; ++i) {
      active.set_bit(rand_int(0, 63), sc_dt::Log_1);
    }
    io_active = active;

    n = rand_int(0, 8);
    sc_bv<128> vrfsb_data = 0;
    for (int i = 0; i < n; ++i) {
      vrfsb_data.set_bit(rand_int(0, 127), sc_dt::Log_1);
    }
    io_vrfsb_data = vrfsb_data;

    uint32_t inst[KP_instructionLanes];
    uint32_t addr[KP_instructionLanes];
    uint32_t data[KP_instructionLanes];
    uint32_t index[KP_instructionLanes];

    for (int i = 0; i < KP_instructionLanes; ++i) {
      inst[i] = rand_uint32();
      addr[i] = rand_uint32();
      data[i] = rand_uint32();

      index[i] = rand_uint32(0, range_ - 1);
      if (index[i]) {
        inst[i] = op_[index[i]].match;

        // Randomize the fields.
        uint32_t size = rand_int(0, 2) << 12;
        uint32_t m = rand_int(0, 1) << 5;
        uint32_t x = rand_int(0, 1) << 1;
        inst[i] |= size | m | x;
        if (op_[index[i]].rand) {
          inst[i] |= op_[index[i]].rand(rand_uint32());
        }
      }
    }

#define INST_BITS(x)                    \
  io_in_bits_##x##_bits_inst = inst[x]; \
  io_in_bits_##x##_bits_addr = addr[x]; \
  io_in_bits_##x##_bits_data = data[x];

    REPEAT(INST_BITS, KP_instructionLanes);
#undef INST_BITS

    check(count_ >= 0, "count");

    // vfifo(depth - 8) + out(4)
    constexpr int depth = 16;
    check(!(io_stall && count_ <= ((depth - 8) + 4)), "io.stall");

    if (io_in_valid && io_in_ready) {
      for (int i = 0; i < KP_instructionLanes; ++i) {
        bool valid = false;
        vdecode_in_t in;

#define GET_WORDS(x)                                      \
  if (i == x && io_in_bits_##x##_valid) {                 \
    valid = true;                                         \
    count_++;                                             \
    in = {io_in_bits_##x##_bits_inst.read().get_word(0),  \
          io_in_bits_##x##_bits_addr.read().get_word(0),  \
          io_in_bits_##x##_bits_data.read().get_word(0)}; \
  }

        REPEAT(GET_WORDS, KP_instructionLanes);
#undef GET_WORDS

        if (valid) {
          vdecode_out_t out;
          memset(&out, 0, sizeof(vdecode_out_t));
          for (int j = kOpStart; j < kOpStop; ++j) {
            if (VDecode(j, in, out)) {
              break;
            }
          }
          UpdateRegs(out);
          inst_.write(out);
        }
      }
    }

    // Outputs.
    vdecode_out_t ref[KP_instructionLanes], dut[KP_instructionLanes];
    bool dut_active[KP_instructionLanes];
    bool ref_read[KP_instructionLanes];

    for (int i = 0; i < KP_instructionLanes; ++i) {
      ref_read[i] = inst_.next(ref[i], i);
    }

#define DUT_ACTIVE(x)                                       \
  dut_active[x] = io_out_##x##_valid && io_out_##x##_ready; \
  check(!(dut_active[x] && !ref_read[x]), "instruction fifo[" STRINGIFY(x) "]");

    REPEAT(DUT_ACTIVE, KP_instructionLanes);
#undef DUT_ACTIVE

    // Entries are not ordered, remove in reverse order so that index correct.
    for (int i = KP_instructionLanes - 1; i >= 0; --i) {
      if (dut_active[i]) inst_.remove(i);
    }

#define DUT_OUT(i)                                                            \
  if (io_out_##i##_valid && io_out_##i##_ready) {                             \
    count_--;                                                                 \
    dut[i].op = io_out_##i##_bits_op.read().get_word(0);                      \
    dut[i].f2 = io_out_##i##_bits_f2.read().get_word(0);                      \
    dut[i].sz = io_out_##i##_bits_sz.read().get_word(0);                      \
    dut[i].m = io_out_##i##_bits_m;                                           \
    dut[i].cmdsync = io_out_##i##_bits_cmdsync;                               \
    dut[i].vd.valid = io_out_##i##_bits_vd_valid;                             \
    dut[i].ve.valid = io_out_##i##_bits_ve_valid;                             \
    dut[i].vf.valid = io_out_##i##_bits_vf_valid;                             \
    dut[i].vg.valid = io_out_##i##_bits_vg_valid;                             \
    dut[i].vs.valid = io_out_##i##_bits_vs_valid;                             \
    dut[i].vt.valid = io_out_##i##_bits_vt_valid;                             \
    dut[i].vu.valid = io_out_##i##_bits_vu_valid;                             \
    dut[i].vx.valid = io_out_##i##_bits_vx_valid;                             \
    dut[i].vy.valid = io_out_##i##_bits_vy_valid;                             \
    dut[i].vz.valid = io_out_##i##_bits_vz_valid;                             \
    dut[i].sv.valid = io_out_##i##_bits_sv_valid;                             \
    dut[i].vd.addr = io_out_##i##_bits_vd_addr.read().get_word(0);            \
    dut[i].ve.addr = io_out_##i##_bits_ve_addr.read().get_word(0);            \
    dut[i].vf.addr = io_out_##i##_bits_vf_addr.read().get_word(0);            \
    dut[i].vg.addr = io_out_##i##_bits_vg_addr.read().get_word(0);            \
    dut[i].vs.addr = io_out_##i##_bits_vs_addr.read().get_word(0);            \
    dut[i].vt.addr = io_out_##i##_bits_vt_addr.read().get_word(0);            \
    dut[i].vu.addr = io_out_##i##_bits_vu_addr.read().get_word(0);            \
    dut[i].vy.addr = io_out_##i##_bits_vy_addr.read().get_word(0);            \
    dut[i].vx.addr = io_out_##i##_bits_vx_addr.read().get_word(0);            \
    dut[i].vz.addr = io_out_##i##_bits_vz_addr.read().get_word(0);            \
    dut[i].vs.tag = io_out_##i##_bits_vs_tag.read().get_word(0);              \
    dut[i].vt.tag = io_out_##i##_bits_vt_tag.read().get_word(0);              \
    dut[i].vu.tag = io_out_##i##_bits_vu_tag.read().get_word(0);              \
    dut[i].vy.tag = io_out_##i##_bits_vy_tag.read().get_word(0);              \
    dut[i].vx.tag = io_out_##i##_bits_vx_tag.read().get_word(0);              \
    dut[i].vz.tag = io_out_##i##_bits_vz_tag.read().get_word(0);              \
    dut[i].sv.addr = io_out_##i##_bits_sv_addr.read().get_word(0);            \
    dut[i].sv.data = io_out_##i##_bits_sv_data.read().get_word(0);            \
    dut[i].cmdq.alu = io_cmdq_##i##_alu;                                      \
    dut[i].cmdq.conv = io_cmdq_##i##_conv;                                    \
    dut[i].cmdq.ldst = io_cmdq_##i##_ldst;                                    \
    dut[i].cmdq.ld = io_cmdq_##i##_ld;                                        \
    dut[i].cmdq.st = io_cmdq_##i##_st;                                        \
    dut[i].ractive =                                                          \
        io_actv_##i##_ractive.read().get_word(0) |                            \
        (uint64_t(io_actv_##i##_ractive.read().get_word(1)) << 32);           \
    dut[i].wactive =                                                          \
        io_actv_##i##_wactive.read().get_word(0) |                            \
        (uint64_t(io_actv_##i##_wactive.read().get_word(1)) << 32);           \
                                                                              \
    if (ref[i] != dut[i]) {                                                   \
      printf(                                                                 \
          "Error::Inst[%d] op=%d:%d inst=%08x addr=%08x data=%08x  \"%s\"\n", \
          i, ref[i].op, dut[i].op, ref[i].inst, ref[i].addr, ref[i].data,     \
          InstStr(ref[i].inst).c_str());                                      \
      Print(ref[i], dut[i]);                                                  \
      check(false, "vdecode mismatch");                                       \
    }                                                                         \
  }

    REPEAT(DUT_OUT, KP_instructionLanes);
#undef DUT_OUT

    // Scoreboard Set.
    bool ref_vrfsbvalid = false;
    bool dut_vrfsbvalid;
    uint64_t ref_vrfsbset[2] = {0, 0};
    uint64_t dut_vrfsbset[2] = {0, 0};

#define VRFSB_OUT(i)                              \
  if (io_out_##i##_valid && io_out_##i##_ready) { \
    assert(ref_read[i]);                          \
    ref_vrfsbset[0] |= ref[i].vrfsbset[0];        \
    ref_vrfsbset[1] |= ref[i].vrfsbset[1];        \
    ref_vrfsbvalid = true;                        \
  }

    dut_vrfsbvalid = io_vrfsb_set_valid;

    dut_vrfsbset[0] = io_vrfsb_set_bits.read().get_word(0) |
                      (uint64_t(io_vrfsb_set_bits.read().get_word(1)) << 32);
    dut_vrfsbset[1] = io_vrfsb_set_bits.read().get_word(2) |
                      (uint64_t(io_vrfsb_set_bits.read().get_word(3)) << 32);

    REPEAT(VRFSB_OUT, KP_instructionLanes);
#undef VRFSB_OUT

    if (ref_vrfsbvalid != dut_vrfsbvalid) {
      printf("Error:Vrfsb %d %d\n", ref_vrfsbvalid, dut_vrfsbvalid);
      check(false, "io.vrfsb.set.bits");
    }

    if (ref_vrfsbset[0] != dut_vrfsbset[0] ||
        ref_vrfsbset[1] != dut_vrfsbset[1]) {
      printf("Error::Vrfsb %08lx:%08lx:%08lx:%08lx\n", ref_vrfsbset[1] >> 32,
             ref_vrfsbset[1], ref_vrfsbset[0] >> 32, ref_vrfsbset[0]);
      printf("             %08lx:%08lx:%08lx:%08lx\n", dut_vrfsbset[1] >> 32,
             dut_vrfsbset[1], dut_vrfsbset[0] >> 32, dut_vrfsbset[0]);
      check(false, "io.vrfsb.set.bits");
    }

    // Writes must not dispatch past previous read/write usage or dispatch.
    uint64_t wactive = io_vrfsb_data.read().get_word(0) |
                       io_vrfsb_data.read().get_word(2) |
                       (uint64_t(io_vrfsb_data.read().get_word(1)) << 32) |
                       (uint64_t(io_vrfsb_data.read().get_word(3)) << 32) |
                       io_active.read().get_word(0) |
                       uint64_t(io_active.read().get_word(1)) << 32;
    // bool wdepends[4] = {false, false, false, false};
    bool wdepends[KP_instructionLanes] = {};

    for (int i = 0; i < KP_instructionLanes; ++i) {
      wdepends[i] = ref[i].wactive & wactive;
      if (ref_read[i]) {
        wactive |= ref[i].ractive;
        wactive |= ref[i].wactive;
      }
    }

#define WDEPEND(x)                            \
  check(!(io_out_##x##_valid && wdepends[x]), \
        "write dependency[" STRINGIFY(x) "]");
    REPEAT(WDEPEND, KP_instructionLanes);
#undef WDEPEND

    // Reads must not dispatch past previous write dispatch.
    uint64_t ractive = 0;
    bool rdepends[KP_instructionLanes] = {};

    for (int i = 0; i < KP_instructionLanes; ++i) {
      rdepends[i] = ref[i].ractive & ractive;
      if (ref_read[i]) {
        ractive |= ref[i].wactive;
      }
    }

#define RDEPEND(x)                            \
  check(!(io_out_##x##_valid && rdepends[x]), \
        "read dependency[" STRINGIFY(x) "]");
    REPEAT(RDEPEND, KP_instructionLanes);
#undef RDEPEND
  }

 private:
  const int range_ = sizeof(op_) / sizeof(op_[0]);
  fifo_t<vdecode_out_t> inst_;
  int count_ = 0;
  uint64_t tag_ = 0;

  void UpdateRegs(vdecode_out_t& out) {
    if (out.vs.valid) UpdateReg(out.vs);
    if (out.vt.valid) UpdateReg(out.vt);
    if (out.vu.valid) UpdateReg(out.vu);
    if (out.vx.valid) UpdateReg(out.vx);
    if (out.vy.valid) UpdateReg(out.vy);
    if (out.vz.valid) UpdateReg(out.vz);
    tag_ ^= out.wactive;
    out.vrfsbset[0] = out.wactive & ~tag_;
    out.vrfsbset[1] = out.wactive & tag_;
  }

  void UpdateReg(vdecode_out_t::vdecode_src_addr_t& r) {
    const uint32_t addr = r.addr;
    const uint32_t a0 = (addr & ~3) | 0;
    const uint32_t a1 = (addr & ~3) | 1;
    const uint32_t a2 = (addr & ~3) | 2;
    const uint32_t a3 = (addr & ~3) | 3;
    const uint32_t t0 = ((tag_ >> a0) & 1) << 0;
    const uint32_t t1 = ((tag_ >> a1) & 1) << 1;
    const uint32_t t2 = ((tag_ >> a2) & 1) << 2;
    const uint32_t t3 = ((tag_ >> a3) & 1) << 3;
    r.tag = t0 | t1 | t2 | t3;
  }
};

static void VDecode_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_stall;
  sc_signal<bool> io_undef;
  sc_signal<bool> io_nempty;
  sc_signal<bool> io_vrfsb_set_valid;
  sc_signal<sc_bv<128> > io_vrfsb_set_bits;
  sc_signal<sc_bv<128> > io_vrfsb_data;
  sc_signal<sc_bv<64> > io_active;
#define IO_BITS(x)                                  \
  sc_signal<bool> io_in_bits_##x##_valid;           \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_inst; \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_addr; \
  sc_signal<sc_bv<32> > io_in_bits_##x##_bits_data; \
  sc_signal<bool> io_out_##x##_ready;               \
  sc_signal<bool> io_out_##x##_valid;               \
  sc_signal<bool> io_out_##x##_bits_m;              \
  sc_signal<bool> io_out_##x##_bits_vd_valid;       \
  sc_signal<bool> io_out_##x##_bits_ve_valid;       \
  sc_signal<bool> io_out_##x##_bits_vf_valid;       \
  sc_signal<bool> io_out_##x##_bits_vg_valid;       \
  sc_signal<bool> io_out_##x##_bits_vs_valid;       \
  sc_signal<bool> io_out_##x##_bits_vt_valid;       \
  sc_signal<bool> io_out_##x##_bits_vu_valid;       \
  sc_signal<bool> io_out_##x##_bits_vx_valid;       \
  sc_signal<bool> io_out_##x##_bits_vy_valid;       \
  sc_signal<bool> io_out_##x##_bits_vz_valid;       \
  sc_signal<bool> io_out_##x##_bits_sv_valid;       \
  sc_signal<bool> io_cmdq_##x##_alu;                \
  sc_signal<bool> io_cmdq_##x##_conv;               \
  sc_signal<bool> io_cmdq_##x##_ldst;               \
  sc_signal<bool> io_cmdq_##x##_ld;                 \
  sc_signal<bool> io_cmdq_##x##_st;                 \
  sc_signal<bool> io_out_##x##_bits_cmdsync;        \
  sc_signal<sc_bv<7> > io_out_##x##_bits_op;        \
  sc_signal<sc_bv<3> > io_out_##x##_bits_f2;        \
  sc_signal<sc_bv<3> > io_out_##x##_bits_sz;        \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vd_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_ve_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vf_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vg_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vs_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vt_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vu_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vx_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vy_addr;   \
  sc_signal<sc_bv<6> > io_out_##x##_bits_vz_addr;   \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vs_tag;    \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vt_tag;    \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vu_tag;    \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vx_tag;    \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vy_tag;    \
  sc_signal<sc_bv<4> > io_out_##x##_bits_vz_tag;    \
  sc_signal<sc_bv<32> > io_out_##x##_bits_sv_addr;  \
  sc_signal<sc_bv<32> > io_out_##x##_bits_sv_data;  \
  sc_signal<sc_bv<64> > io_actv_##x##_ractive;      \
  sc_signal<sc_bv<64> > io_actv_##x##_wactive;
  REPEAT(IO_BITS, KP_instructionLanes);
#undef IO_BITS

  VDecode_tb tb("VDecode_tb", loops, true);
  VVDecode d(name);

  d.clock(tb.clock);
  d.reset(tb.reset);

  BIND2(tb, d, io_in_ready);
  BIND2(tb, d, io_in_valid);
  BIND2(tb, d, io_stall);
  BIND2(tb, d, io_undef);
  BIND2(tb, d, io_nempty);
  BIND2(tb, d, io_vrfsb_set_valid);
  BIND2(tb, d, io_vrfsb_set_bits);
  BIND2(tb, d, io_vrfsb_data);
  BIND2(tb, d, io_active);
#define IO_BIND(x)                          \
  BIND2(tb, d, io_in_bits_##x##_valid);     \
  BIND2(tb, d, io_in_bits_##x##_bits_inst); \
  BIND2(tb, d, io_in_bits_##x##_bits_addr); \
  BIND2(tb, d, io_in_bits_##x##_bits_data); \
  BIND2(tb, d, io_out_##x##_ready);         \
  BIND2(tb, d, io_out_##x##_valid);         \
  BIND2(tb, d, io_out_##x##_bits_m);        \
  BIND2(tb, d, io_out_##x##_bits_vd_valid); \
  BIND2(tb, d, io_out_##x##_bits_ve_valid); \
  BIND2(tb, d, io_out_##x##_bits_vf_valid); \
  BIND2(tb, d, io_out_##x##_bits_vg_valid); \
  BIND2(tb, d, io_out_##x##_bits_vs_valid); \
  BIND2(tb, d, io_out_##x##_bits_vt_valid); \
  BIND2(tb, d, io_out_##x##_bits_vu_valid); \
  BIND2(tb, d, io_out_##x##_bits_vx_valid); \
  BIND2(tb, d, io_out_##x##_bits_vy_valid); \
  BIND2(tb, d, io_out_##x##_bits_vz_valid); \
  BIND2(tb, d, io_out_##x##_bits_sv_valid); \
  BIND2(tb, d, io_cmdq_##x##_alu);          \
  BIND2(tb, d, io_cmdq_##x##_conv);         \
  BIND2(tb, d, io_cmdq_##x##_ldst);         \
  BIND2(tb, d, io_cmdq_##x##_ld);           \
  BIND2(tb, d, io_cmdq_##x##_st);           \
  BIND2(tb, d, io_out_##x##_bits_cmdsync);  \
  BIND2(tb, d, io_out_##x##_bits_op);       \
  BIND2(tb, d, io_out_##x##_bits_f2);       \
  BIND2(tb, d, io_out_##x##_bits_sz);       \
  BIND2(tb, d, io_out_##x##_bits_vd_addr);  \
  BIND2(tb, d, io_out_##x##_bits_ve_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vf_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vg_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vs_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vt_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vu_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vx_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vy_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vz_addr);  \
  BIND2(tb, d, io_out_##x##_bits_vs_tag);   \
  BIND2(tb, d, io_out_##x##_bits_vt_tag);   \
  BIND2(tb, d, io_out_##x##_bits_vu_tag);   \
  BIND2(tb, d, io_out_##x##_bits_vx_tag);   \
  BIND2(tb, d, io_out_##x##_bits_vy_tag);   \
  BIND2(tb, d, io_out_##x##_bits_vz_tag);   \
  BIND2(tb, d, io_out_##x##_bits_sv_addr);  \
  BIND2(tb, d, io_out_##x##_bits_sv_data);  \
  BIND2(tb, d, io_actv_##x##_ractive);      \
  BIND2(tb, d, io_actv_##x##_wactive);
  REPEAT(IO_BIND, KP_instructionLanes);
#undef IO_BIND

  if (trace) {
    tb.trace(&d);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VDecode_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
