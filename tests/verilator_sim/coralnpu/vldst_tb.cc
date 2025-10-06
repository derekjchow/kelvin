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

#include "VVLdSt.h"
#include "hdl/chisel/src/coralnpu/VCore_parameters.h"
#include "tests/verilator_sim/coralnpu/core_if.h"
#include "tests/verilator_sim/coralnpu/vencodeop.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

using encode::vld;
using encode::vst;
using encode::vstq;

struct VLdSt_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_in<bool> io_read_valid;
  sc_out<bool> io_read_ready;
  sc_in<bool> io_read_stall;
  sc_in<bool> io_write_valid;
  sc_in<bool> io_dbus_valid;
  sc_out<bool> io_dbus_ready;
  sc_in<bool> io_dbus_write;
  sc_in<sc_bv<64> > io_active;
  sc_out<sc_bv<128> > io_vrfsb;
  sc_in<sc_bv<6> > io_read_addr;
  sc_in<bool> io_read_tag;
  sc_out<sc_bv<kVector> > io_read_data;
  sc_in<sc_bv<6> > io_write_addr;
  sc_in<sc_bv<kVector> > io_write_data;
  sc_in<sc_bv<32> > io_dbus_addr;
  sc_in<sc_bv<32> > io_dbus_adrx;
  sc_in<sc_bv<kDbusBits> > io_dbus_size;
  sc_in<sc_bv<kVector> > io_dbus_wdata;
  sc_in<sc_bv<kVector / 8> > io_dbus_wmask;
  sc_out<sc_bv<kVector> > io_dbus_rdata;
  sc_in<sc_bv<32> > io_dbus_pc;
  sc_in<bool> io_last;
  sc_in<bool> io_vstoreCount;
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

    // Inputs.
    io_dbus_ready = rand_bool();
    io_read_ready = rand_int(0, 7) != 0;

#define IN_RAND(idx)                                                       \
  {                                                                        \
    const int op = rand_int(vld, vstq);                                    \
    const bool m = rand_bool();                                            \
    const int vd_addr = rand_uint32() & (m ? 60 : 63);                     \
    const int vs_addr = rand_uint32() & (m ? 60 : 63);                     \
    const int vs_tag = rand_uint32();                                      \
    uint32_t sv_addr = std::min(rand_uint32() & ~0x80000000, 0x7fffff00u); \
    uint32_t sv_data = (rand_uint32() >> rand_int(0, 31));                 \
    sv_data = std::min(((0x80000000u - sv_addr) / 64), sv_data);           \
    io_in_bits_##idx##_valid = rand_bool();                                \
    io_in_bits_##idx##_bits_op = op;                                       \
    io_in_bits_##idx##_bits_f2 = rand_int(0, 7);                           \
    io_in_bits_##idx##_bits_sz = 1 << rand_int(0, 2);                      \
    io_in_bits_##idx##_bits_m = m;                                         \
    io_in_bits_##idx##_bits_vd_valid = op == vld;                          \
    io_in_bits_##idx##_bits_vs_valid = op == vst || op == vstq;            \
    io_in_bits_##idx##_bits_vd_addr = vd_addr;                             \
    io_in_bits_##idx##_bits_vs_addr = vs_addr;                             \
    io_in_bits_##idx##_bits_vs_tag = vs_tag;                               \
    io_in_bits_##idx##_bits_sv_valid = false;                              \
    io_in_bits_##idx##_bits_sv_addr = sv_addr;                             \
    io_in_bits_##idx##_bits_sv_data = sv_data;                             \
  }

    io_in_valid = rand_bool();
    REPEAT(IN_RAND, KP_instructionLanes);
#undef IN_RAND

#define IN_READ(idx)                                           \
  if (io_in_bits_##idx##_valid) {                              \
    Input(io_in_bits_##idx##_bits_m,                           \
          io_in_bits_##idx##_bits_op.read().get_word(0),       \
          io_in_bits_##idx##_bits_f2.read().get_word(0),       \
          io_in_bits_##idx##_bits_sz.read().get_word(0),       \
          io_in_bits_##idx##_bits_vd_valid,                    \
          io_in_bits_##idx##_bits_vd_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_vs_valid,                    \
          io_in_bits_##idx##_bits_vs_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_vs_tag.read().get_word(0),   \
          io_in_bits_##idx##_bits_sv_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_sv_data.read().get_word(0)); \
  }

    if (io_in_valid && io_in_ready) {
      REPEAT(IN_READ, KP_instructionLanes);
    }
#undef IN_READ

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
      const uint32_t* src = (const uint32_t*)r.data;
      for (int i = 0; i < kVector / 32; ++i) {
        rbits.set_word(i, src[i]);
      }
      io_read_data = rbits;
    }

    if (io_write_valid) {
      wreg_t ref, dut;
      check(wreg_.read(ref), "wreg empty");
      dut.addr = io_write_addr.read().get_word(0);
      uint32_t* dst = reinterpret_cast<uint32_t*>(dut.data);
      for (int i = 0; i < kVector / 32; ++i) {
        dst[i] = io_write_data.read().get_word(i);
      }

      if (ref != dut) {
        ref.print("ref");
        dut.print("dut");
        check(false, "io.write");
      }
    }

    if (io_dbus_valid && io_dbus_ready) {
      dbus_t ref, dut;
      check(dbus_.read(ref), "dbus empty");
      dut.addr = io_dbus_addr.read().get_word(0);
      dut.adrx = io_dbus_adrx.read().get_word(0);
      dut.size = io_dbus_size.read().get_word(0);
      dut.last = io_last;
      dut.write = io_dbus_write;
      uint32_t* dst = reinterpret_cast<uint32_t*>(dut.wdata);
      for (int i = 0; i < kVector / 32; ++i) {
        dst[i] = io_dbus_wdata.read().get_word(i);
      }
      for (int i = 0; i < kVector / 8; i += 32) {
        const uint32_t wmask = io_dbus_wmask.read().get_word(i / 32);
        for (int j = 0; j < std::min(32, kVector / 8); ++j) {
          dut.wmask[i + j] = wmask & (1u << j) ? 1 : 0;
        }
      }

      if (ref != dut) {
        ref.print("ref");
        dut.print("dut");
        check(false, "io.dbus");
      }

      if (!ref.write) {
        sc_bv<kVector> rbits;
        const uint32_t* src = (const uint32_t*)ref.rdata;
        for (int i = 0; i < kVector / 32; ++i) {
          rbits.set_word(i, src[i]);
        }
        io_dbus_rdata = rbits;
      }
    }
  }

 private:
  struct dbus_t {
    uint32_t addr;
    uint32_t adrx;
    uint32_t size;
    uint32_t widx;
    bool last;
    bool write;
    uint8_t rdata[kVector / 8];
    uint8_t wdata[kVector / 8];
    uint8_t wmask[kVector / 8];

    bool operator!=(const dbus_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (adrx != rhs.adrx) return true;
      if (size != rhs.size) return true;
      if (last != rhs.last) return true;
      if (write != rhs.write) return true;
      if (write && memcmp(wdata, rhs.wdata, kVector / 8)) return true;
      if (write && memcmp(wmask, rhs.wmask, kVector / 8)) return true;
      return false;
    }

    void print(const char* name) {
      printf("dbus::%s addr=%08x adrx=%08x size=%d last=%d write=%d", name,
             addr, adrx, size, last, write);
      if (write) {
        printf("  wdata=");
        for (int i = 0; i < kVector / 8; ++i) {
          if (i) printf(" ");
          printf("%02x", wdata[i]);
        }
        printf("  wmask=");
        for (int i = 0; i < kVector / 8; ++i) {
          if (i) printf(" ");
          printf("%02x", wmask[i]);
        }
      }
      printf("\n");
    }
  };

  struct rreg_t {
    uint8_t addr : 6;
    uint8_t tag : 1;
    uint8_t data[kVector / 8];
  };

  struct wreg_t {
    uint8_t addr : 6;
    uint8_t data[kVector / 8];

    bool operator!=(const wreg_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (memcmp(data, rhs.data, kVector / 8)) return true;
      return false;
    }

    void print(const char* name) {
      printf("wreg::%s addr=%d ", name, addr);
      printf("  data=");
      for (int i = 0; i < kVector / 8; ++i) {
        if (i) printf(" ");
        printf("%02x", data[i]);
      }
      printf("\n");
    }
  };

  fifo_t<dbus_t> dbus_;
  fifo_t<rreg_t> rreg_;
  fifo_t<wreg_t> wreg_;

  void Input(bool m, uint8_t op, uint8_t f2, uint8_t sz, bool vd_valid,
             uint8_t vd_addr, bool vs_valid, uint8_t vs_addr, uint8_t vs_tag,
             uint32_t addr, uint32_t data) {
    assert(!(op == vst && (vd_valid || !vs_valid)));
    assert(!(op == vstq && (vd_valid || !vs_valid)));
    assert(!(op == vld && (!vd_valid || vs_valid)));

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

      wreg_t w;
      if (vd_valid) {
        w.addr = vd_addr;
        uint32_t* dst = reinterpret_cast<uint32_t*>(w.data);
        for (int i = 0; i < kVector / 32; ++i) {
          dst[i] = rand_uint32();
        }
      }

      const bool is_vstq = op == vstq;
      const bool last = !m || i == 3;

      int n = Dbus(0, op, offset, stride, r, w, addr, remain, last && !is_vstq);
      if (is_vstq) {
        if (vs_valid) rreg_.write(r);
        if (vs_valid) rreg_.write(r);
        if (vs_valid) rreg_.write(r);

        Dbus(1, op, offset, stride, r, w, addr, remain);
        Dbus(2, op, offset, stride, r, w, addr, remain);
        Dbus(3, op, offset, stride, r, w, addr, remain, last);
      }

      // Write register lane zeroing.
      if (vd_valid) {
        uint8_t* src = reinterpret_cast<uint8_t*>(w.data);
        for (int i = 0; i < kVector / 8; ++i) {
          if (i < n) continue;
          src[i] = 0;
        }
      }

      if (vs_valid) rreg_.write(r);
      if (vd_valid) wreg_.write(w);

      if (vd_valid) vd_addr++;
      if (vs_valid) vs_addr++;
    }
  }

  int Dbus(const int step, const uint8_t op, const uint32_t offset,
           const bool stride, const rreg_t& r, const wreg_t& w, uint32_t& addr,
           uint32_t& remain, const bool last = false) {
    dbus_t d;
    d.addr = addr;
    d.adrx = d.addr + (kVector / 8);
    d.last = last;
    d.write = op == vst || op == vstq;
    d.size = std::min(remain, op == vstq ? VLENB / 4 : VLENB);
    d.widx = w.addr;
    const uint32_t vstq_adj = op == vstq ? step * VLENB / 4 : 0;
    const uint32_t lsb_addr = addr & ((kVector / 8) - 1);
    const uint32_t lsb_ashf = (addr - vstq_adj) & ((kVector / 8) - 1);

    if (d.write) {
      const uint8_t* src = (const uint8_t*)r.data;
      uint8_t* dst = reinterpret_cast<uint8_t*>(d.wdata);
      for (int i = 0; i < kVector / 8; ++i) {
        const int idx0 = (i + lsb_addr) % (kVector / 8);
        const int idx1 = (i + lsb_ashf) % (kVector / 8);
        d.wmask[idx0] = static_cast<uint8_t>(static_cast<uint32_t>(i) < d.size);
        dst[idx1] = src[i];
      }
    } else {
      const uint8_t* src = (const uint8_t*)w.data;
      uint8_t* dst = reinterpret_cast<uint8_t*>(d.rdata);
      for (int i = 0; i < kVector / 8; ++i) {
        const int idx = (i + lsb_addr) % (kVector / 8);
        dst[idx] = src[i];
      }
    }

    dbus_.write(d);

    if (stride) {
      addr += offset;
    } else {
      addr += op == vstq ? VLENB / 4 : VLENB;
    }

    remain = std::max(0u, remain - d.size);

    return d.size;
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

static void VLdSt_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_read_valid;
  sc_signal<bool> io_read_ready;
  sc_signal<bool> io_read_stall;
  sc_signal<bool> io_write_valid;
  sc_signal<bool> io_dbus_valid;
  sc_signal<bool> io_dbus_ready;
  sc_signal<bool> io_dbus_write;
  sc_signal<sc_bv<64> > io_active;
  sc_signal<sc_bv<128> > io_vrfsb;
  sc_signal<sc_bv<6> > io_read_addr;
  sc_signal<bool> io_read_tag;
  sc_signal<sc_bv<kVector> > io_read_data;
  sc_signal<sc_bv<6> > io_write_addr;
  sc_signal<sc_bv<kVector> > io_write_data;
  sc_signal<sc_bv<32> > io_dbus_addr;
  sc_signal<sc_bv<32> > io_dbus_adrx;
  sc_signal<sc_bv<kDbusBits> > io_dbus_size;
  sc_signal<sc_bv<kVector> > io_dbus_wdata;
  sc_signal<sc_bv<kVector / 8> > io_dbus_wmask;
  sc_signal<sc_bv<kVector> > io_dbus_rdata;
  sc_signal<sc_bv<32>> io_dbus_pc;
  sc_signal<bool> io_last;
  sc_signal<bool> io_vstoreCount;
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

  VLdSt_tb tb("VLdSt_tb", loops, true /* random */);
  VVLdSt ldst(name);

  ldst.clock(tb.clock);
  ldst.reset(tb.reset);
  BIND2(tb, ldst, io_in_ready);
  BIND2(tb, ldst, io_in_valid);
  BIND2(tb, ldst, io_read_valid);
  BIND2(tb, ldst, io_read_ready);
  BIND2(tb, ldst, io_read_stall);
  BIND2(tb, ldst, io_write_valid);
  BIND2(tb, ldst, io_dbus_valid);
  BIND2(tb, ldst, io_dbus_ready);
  BIND2(tb, ldst, io_dbus_write);
  BIND2(tb, ldst, io_active);
  BIND2(tb, ldst, io_vrfsb);
  BIND2(tb, ldst, io_read_addr);
  BIND2(tb, ldst, io_read_tag);
  BIND2(tb, ldst, io_read_data);
  BIND2(tb, ldst, io_write_addr);
  BIND2(tb, ldst, io_write_data);
  BIND2(tb, ldst, io_dbus_addr);
  BIND2(tb, ldst, io_dbus_adrx);
  BIND2(tb, ldst, io_dbus_size);
  BIND2(tb, ldst, io_dbus_wdata);
  BIND2(tb, ldst, io_dbus_wmask);
  BIND2(tb, ldst, io_dbus_rdata);
  BIND2(tb, ldst, io_dbus_pc);
  BIND2(tb, ldst, io_last);
  BIND2(tb, ldst, io_vstoreCount);
#define IO_BIND(x)                                 \
  BIND2(tb, ldst, io_in_bits_##x##_valid);         \
  BIND2(tb, ldst, io_in_bits_##x##_bits_m);        \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vd_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_ve_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vf_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vg_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vs_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vt_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vu_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vx_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vy_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vz_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_sv_valid); \
  BIND2(tb, ldst, io_in_bits_##x##_bits_cmdsync);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_op);       \
  BIND2(tb, ldst, io_in_bits_##x##_bits_f2);       \
  BIND2(tb, ldst, io_in_bits_##x##_bits_sz);       \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vd_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_ve_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vf_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vg_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vs_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vt_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vu_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vx_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vy_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vz_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vs_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vt_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vu_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vx_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vy_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_vz_tag);   \
  BIND2(tb, ldst, io_in_bits_##x##_bits_sv_addr);  \
  BIND2(tb, ldst, io_in_bits_##x##_bits_sv_data);
  REPEAT(IO_BIND, KP_instructionLanes);
#undef IO_BIND

  if (trace) {
    tb.trace(&ldst);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VLdSt_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
