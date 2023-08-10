// Copyright 2023 Google LLC

#include "VVLd.h"

#include "tests/verilator_sim/kelvin/core_if.h"
#include "tests/verilator_sim/kelvin/vencodeop.h"
#include "tests/verilator_sim/sysc_tb.h"

using encode::vld;

struct VLd_tb : Sysc_tb {
  sc_in<bool> io_in_ready;
  sc_out<bool> io_in_valid;
  sc_out<bool> io_in_bits_0_valid;
  sc_out<bool> io_in_bits_0_bits_m;
  sc_out<bool> io_in_bits_0_bits_vd_valid;
  sc_out<bool> io_in_bits_0_bits_ve_valid;
  sc_out<bool> io_in_bits_0_bits_vf_valid;
  sc_out<bool> io_in_bits_0_bits_vg_valid;
  sc_out<bool> io_in_bits_0_bits_vs_valid;
  sc_out<bool> io_in_bits_0_bits_vt_valid;
  sc_out<bool> io_in_bits_0_bits_vu_valid;
  sc_out<bool> io_in_bits_0_bits_vx_valid;
  sc_out<bool> io_in_bits_0_bits_vy_valid;
  sc_out<bool> io_in_bits_0_bits_vz_valid;
  sc_out<bool> io_in_bits_0_bits_sv_valid;
  sc_out<bool> io_in_bits_0_bits_cmdsync;
  sc_out<bool> io_in_bits_1_valid;
  sc_out<bool> io_in_bits_1_bits_m;
  sc_out<bool> io_in_bits_1_bits_vd_valid;
  sc_out<bool> io_in_bits_1_bits_ve_valid;
  sc_out<bool> io_in_bits_1_bits_vf_valid;
  sc_out<bool> io_in_bits_1_bits_vg_valid;
  sc_out<bool> io_in_bits_1_bits_vs_valid;
  sc_out<bool> io_in_bits_1_bits_vt_valid;
  sc_out<bool> io_in_bits_1_bits_vu_valid;
  sc_out<bool> io_in_bits_1_bits_vx_valid;
  sc_out<bool> io_in_bits_1_bits_vy_valid;
  sc_out<bool> io_in_bits_1_bits_vz_valid;
  sc_out<bool> io_in_bits_1_bits_sv_valid;
  sc_out<bool> io_in_bits_1_bits_cmdsync;
  sc_out<bool> io_in_bits_2_valid;
  sc_out<bool> io_in_bits_2_bits_m;
  sc_out<bool> io_in_bits_2_bits_vd_valid;
  sc_out<bool> io_in_bits_2_bits_ve_valid;
  sc_out<bool> io_in_bits_2_bits_vf_valid;
  sc_out<bool> io_in_bits_2_bits_vg_valid;
  sc_out<bool> io_in_bits_2_bits_vs_valid;
  sc_out<bool> io_in_bits_2_bits_vt_valid;
  sc_out<bool> io_in_bits_2_bits_vu_valid;
  sc_out<bool> io_in_bits_2_bits_vx_valid;
  sc_out<bool> io_in_bits_2_bits_vy_valid;
  sc_out<bool> io_in_bits_2_bits_vz_valid;
  sc_out<bool> io_in_bits_2_bits_sv_valid;
  sc_out<bool> io_in_bits_2_bits_cmdsync;
  sc_out<bool> io_in_bits_3_valid;
  sc_out<bool> io_in_bits_3_bits_m;
  sc_out<bool> io_in_bits_3_bits_vd_valid;
  sc_out<bool> io_in_bits_3_bits_ve_valid;
  sc_out<bool> io_in_bits_3_bits_vf_valid;
  sc_out<bool> io_in_bits_3_bits_vg_valid;
  sc_out<bool> io_in_bits_3_bits_vs_valid;
  sc_out<bool> io_in_bits_3_bits_vt_valid;
  sc_out<bool> io_in_bits_3_bits_vu_valid;
  sc_out<bool> io_in_bits_3_bits_vx_valid;
  sc_out<bool> io_in_bits_3_bits_vy_valid;
  sc_out<bool> io_in_bits_3_bits_vz_valid;
  sc_out<bool> io_in_bits_3_bits_sv_valid;
  sc_out<bool> io_in_bits_3_bits_cmdsync;
  sc_in<bool> io_write_valid;
  sc_out<bool> io_axi_addr_ready;
  sc_in<bool> io_axi_addr_valid;
  sc_in<bool> io_axi_data_ready;
  sc_out<bool> io_axi_data_valid;
  sc_in<bool> io_nempty;
  sc_out<sc_bv<7> > io_in_bits_0_bits_op;
  sc_out<sc_bv<3> > io_in_bits_0_bits_f2;
  sc_out<sc_bv<3> > io_in_bits_0_bits_sz;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vd_addr;
  sc_out<sc_bv<6> > io_in_bits_0_bits_ve_addr;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vf_addr;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vg_addr;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vs_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vs_tag;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vt_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vt_tag;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vu_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vu_tag;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vx_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vx_tag;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vy_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vy_tag;
  sc_out<sc_bv<6> > io_in_bits_0_bits_vz_addr;
  sc_out<sc_bv<4> > io_in_bits_0_bits_vz_tag;
  sc_out<sc_bv<32> > io_in_bits_0_bits_sv_addr;
  sc_out<sc_bv<32> > io_in_bits_0_bits_sv_data;
  sc_out<sc_bv<7> > io_in_bits_1_bits_op;
  sc_out<sc_bv<3> > io_in_bits_1_bits_f2;
  sc_out<sc_bv<3> > io_in_bits_1_bits_sz;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vd_addr;
  sc_out<sc_bv<6> > io_in_bits_1_bits_ve_addr;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vf_addr;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vg_addr;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vs_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vs_tag;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vt_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vt_tag;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vu_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vu_tag;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vx_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vx_tag;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vy_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vy_tag;
  sc_out<sc_bv<6> > io_in_bits_1_bits_vz_addr;
  sc_out<sc_bv<4> > io_in_bits_1_bits_vz_tag;
  sc_out<sc_bv<32> > io_in_bits_1_bits_sv_addr;
  sc_out<sc_bv<32> > io_in_bits_1_bits_sv_data;
  sc_out<sc_bv<7> > io_in_bits_2_bits_op;
  sc_out<sc_bv<3> > io_in_bits_2_bits_f2;
  sc_out<sc_bv<3> > io_in_bits_2_bits_sz;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vd_addr;
  sc_out<sc_bv<6> > io_in_bits_2_bits_ve_addr;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vf_addr;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vg_addr;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vs_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vs_tag;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vt_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vt_tag;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vu_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vu_tag;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vx_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vx_tag;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vy_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vy_tag;
  sc_out<sc_bv<6> > io_in_bits_2_bits_vz_addr;
  sc_out<sc_bv<4> > io_in_bits_2_bits_vz_tag;
  sc_out<sc_bv<32> > io_in_bits_2_bits_sv_addr;
  sc_out<sc_bv<32> > io_in_bits_2_bits_sv_data;
  sc_out<sc_bv<7> > io_in_bits_3_bits_op;
  sc_out<sc_bv<3> > io_in_bits_3_bits_f2;
  sc_out<sc_bv<3> > io_in_bits_3_bits_sz;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vd_addr;
  sc_out<sc_bv<6> > io_in_bits_3_bits_ve_addr;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vf_addr;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vg_addr;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vs_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vs_tag;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vt_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vt_tag;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vu_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vu_tag;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vx_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vx_tag;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vy_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vy_tag;
  sc_out<sc_bv<6> > io_in_bits_3_bits_vz_addr;
  sc_out<sc_bv<4> > io_in_bits_3_bits_vz_tag;
  sc_out<sc_bv<32> > io_in_bits_3_bits_sv_addr;
  sc_out<sc_bv<32> > io_in_bits_3_bits_sv_data;
  sc_in<sc_bv<6> > io_write_addr;
  sc_in<sc_bv<kVector> > io_write_data;
  sc_in<sc_bv<32> > io_axi_addr_bits_addr;
  sc_in<sc_bv<6> > io_axi_addr_bits_id;
  sc_out<sc_bv<2> > io_axi_data_bits_resp;
  sc_out<sc_bv<6> > io_axi_data_bits_id;
  sc_out<sc_bv<kVector> > io_axi_data_bits_data;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // Status.
    bool nempty = !raxi_.empty() || !rresp_.empty();
    check(io_nempty == nempty, "io.nempty");

    // Inputs.
    if (io_axi_data_valid && io_axi_data_ready) {
      assert(cmd_count_ > 0);
      assert(raxi_count_ > 0);
      cmd_count_--;
      raxi_count_--;
      check(rresp_.remove(), "rresp empty");
    }

    raxi_t r;
    io_axi_addr_ready = rand_bool();
    io_axi_data_valid = rand_bool() && rresp_.next(r) && raxi_count_;

    sc_bv<kVector> rdata;
    const uint32_t* src = (const uint32_t*)r.data;
    for (int i = 0; i < kVector / 32; ++i) {
      rdata.set_word(i, src[i]);
    }
    io_axi_data_bits_resp = 0;
    io_axi_data_bits_id = r.id;
    io_axi_data_bits_data = rdata;

#define IN_READ(idx)                                           \
  {                                                            \
    Input(io_in_bits_##idx##_bits_m,                           \
          io_in_bits_##idx##_bits_op.read().get_word(0),       \
          io_in_bits_##idx##_bits_f2.read().get_word(0),       \
          io_in_bits_##idx##_bits_sz.read().get_word(0),       \
          io_in_bits_##idx##_bits_vd_valid,                    \
          io_in_bits_##idx##_bits_vd_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_sv_addr.read().get_word(0),  \
          io_in_bits_##idx##_bits_sv_data.read().get_word(0)); \
    cmd_count_ += io_in_bits_##idx##_bits_m ? 4 : 1;           \
  }

    if (io_in_valid && io_in_ready) {
      if (io_in_bits_0_valid) {
        IN_READ(0);
      }
      if (io_in_bits_1_valid) {
        IN_READ(1);
      }
      if (io_in_bits_2_valid) {
        IN_READ(2);
      }
      if (io_in_bits_3_valid) {
        IN_READ(3);
      }
    }

#define IN_RAND(idx)                                      \
  {                                                       \
    const bool in_valid = rand_bool();                    \
    const int op = vld;                                   \
    const bool m = rand_bool();                           \
    const int vd_addr = rand_uint32() & (m ? 60 : 63);    \
    const uint8_t f2 = rand_int(0, 7);                    \
    const bool stride = (f2 >> 1) & 1;                    \
    const uint32_t mask = ~((1u << kAlignedLsb) - 1);     \
    uint32_t addr = (rand_uint32() & mask) | 0x80000000u; \
    uint32_t data = rand_uint32() >> rand_int(0, 32);     \
    data = std::min(((0xffffffffu - addr) / 16), data);   \
    if (stride) data = data & mask;                       \
    if (in_valid) cmd_valid += m ? 4 : 1;                 \
    io_in_bits_##idx##_valid = in_valid;                  \
    io_in_bits_##idx##_bits_op = op;                      \
    io_in_bits_##idx##_bits_f2 = f2;                      \
    io_in_bits_##idx##_bits_sz = 1 << rand_int(0, 2);     \
    io_in_bits_##idx##_bits_m = m;                        \
    io_in_bits_##idx##_bits_vd_valid = op == vld;         \
    io_in_bits_##idx##_bits_vd_addr = vd_addr;            \
    io_in_bits_##idx##_bits_sv_valid = false;             \
    io_in_bits_##idx##_bits_sv_addr = addr;               \
    io_in_bits_##idx##_bits_sv_data = data;               \
  }

    int cmd_valid = 0;

    IN_RAND(0);
    IN_RAND(1);
    IN_RAND(2);
    IN_RAND(3);

    io_in_valid = rand_int(0, 4) == 0 && (cmd_count_ + cmd_valid) <= 64;

    // Outputs.
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

    if (io_axi_addr_valid && io_axi_addr_ready) {
      raxi_t ref, dut;
      check(raxi_.read(ref), "axi empty");
      raxi_count_++;
      dut.addr = io_axi_addr_bits_addr.read().get_word(0);
      dut.id   = io_axi_addr_bits_id.read().get_word(0);

      if (ref != dut) {
        ref.print("ref");
        dut.print("dut");
        check(false, "io.axi");
      }
    }
  }

 private:
  struct raxi_t {
    uint32_t addr;
    uint32_t size;
    uint32_t id : 6;
    uint8_t data[kVector / 8];

    bool operator!=(const raxi_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (id   != rhs.id) return true;
      return false;
    }

    void print(const char* name) {
      printf("axi::%s addr=%08x id=%d\n", name, addr, id);
    }
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

  fifo_t<raxi_t> raxi_;
  fifo_t<raxi_t> rresp_;
  fifo_t<wreg_t> wreg_;
  int cmd_count_ = 0;
  int raxi_count_ = 0;

  void Input(bool m, uint8_t op, uint8_t f2, uint8_t sz, bool vd_valid,
             uint8_t vd_addr, uint32_t addr, uint32_t data) {
    assert(!(op == vld && !vd_valid));

    const bool stride = (f2 >> 1) & 1;
    const bool length = (f2 >> 0) & 1;

    const int sm = m ? 4 : 1;
    uint32_t offset = stride ? data * sz : VLENB;
    uint32_t remain;
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
      wreg_t w;
      w.addr = vd_addr;
      uint32_t* dst = reinterpret_cast<uint32_t*>(w.data);
      for (int i = 0; i < kVector / 32; ++i) {
        dst[i] = rand_uint32();
      }

      // Turn off the warning for the debug code.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"
      const int n = RAxi(0, op, offset, stride, w, addr, remain);
#pragma GCC diagnostic pop

#if 0  // Do not use
      // Write register lane zeroing.
      uint8_t* src = reinterpret_cast<uint8_t*>(w.data);
      for (int i = 0; i < kVector / 8; ++i) {
        if (i < n) continue;
        src[i] = 0;
      }
#endif
      wreg_.write(w);

      vd_addr++;
    }
  }

  int RAxi(const int step, const uint8_t op, const uint32_t offset,
           const bool stride, const wreg_t& w, uint32_t& addr,
           uint32_t& remain) {
    raxi_t r;
    r.addr = addr & ~0x80000000;
    r.size = std::min(remain, VLENB);
    r.id = w.addr;
    const uint32_t lsb_addr = addr & ((kVector / 8) - 1);

    const uint8_t* src = (const uint8_t*)w.data;
    uint8_t* dst = reinterpret_cast<uint8_t*>(r.data);
    for (int i = 0; i < kVector / 8; ++i) {
      const int idx = (i + lsb_addr) % (kVector / 8);
      dst[idx] = src[i];
    }

    rresp_.write(r);
    raxi_.write(r);

    if (stride) {
      addr += offset;
    } else {
      addr += VLENB;
    }

    remain = std::max(0u, remain - r.size);

    return r.size;
  }
};

static void VLd_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_ready;
  sc_signal<bool> io_in_valid;
  sc_signal<bool> io_in_bits_0_valid;
  sc_signal<bool> io_in_bits_0_bits_m;
  sc_signal<bool> io_in_bits_0_bits_vd_valid;
  sc_signal<bool> io_in_bits_0_bits_ve_valid;
  sc_signal<bool> io_in_bits_0_bits_vf_valid;
  sc_signal<bool> io_in_bits_0_bits_vg_valid;
  sc_signal<bool> io_in_bits_0_bits_vs_valid;
  sc_signal<bool> io_in_bits_0_bits_vt_valid;
  sc_signal<bool> io_in_bits_0_bits_vu_valid;
  sc_signal<bool> io_in_bits_0_bits_vx_valid;
  sc_signal<bool> io_in_bits_0_bits_vy_valid;
  sc_signal<bool> io_in_bits_0_bits_vz_valid;
  sc_signal<bool> io_in_bits_0_bits_sv_valid;
  sc_signal<bool> io_in_bits_0_bits_cmdsync;
  sc_signal<bool> io_in_bits_1_valid;
  sc_signal<bool> io_in_bits_1_bits_m;
  sc_signal<bool> io_in_bits_1_bits_vd_valid;
  sc_signal<bool> io_in_bits_1_bits_ve_valid;
  sc_signal<bool> io_in_bits_1_bits_vf_valid;
  sc_signal<bool> io_in_bits_1_bits_vg_valid;
  sc_signal<bool> io_in_bits_1_bits_vs_valid;
  sc_signal<bool> io_in_bits_1_bits_vt_valid;
  sc_signal<bool> io_in_bits_1_bits_vu_valid;
  sc_signal<bool> io_in_bits_1_bits_vx_valid;
  sc_signal<bool> io_in_bits_1_bits_vy_valid;
  sc_signal<bool> io_in_bits_1_bits_vz_valid;
  sc_signal<bool> io_in_bits_1_bits_sv_valid;
  sc_signal<bool> io_in_bits_1_bits_cmdsync;
  sc_signal<bool> io_in_bits_2_valid;
  sc_signal<bool> io_in_bits_2_bits_m;
  sc_signal<bool> io_in_bits_2_bits_vd_valid;
  sc_signal<bool> io_in_bits_2_bits_ve_valid;
  sc_signal<bool> io_in_bits_2_bits_vf_valid;
  sc_signal<bool> io_in_bits_2_bits_vg_valid;
  sc_signal<bool> io_in_bits_2_bits_vs_valid;
  sc_signal<bool> io_in_bits_2_bits_vt_valid;
  sc_signal<bool> io_in_bits_2_bits_vu_valid;
  sc_signal<bool> io_in_bits_2_bits_vx_valid;
  sc_signal<bool> io_in_bits_2_bits_vy_valid;
  sc_signal<bool> io_in_bits_2_bits_vz_valid;
  sc_signal<bool> io_in_bits_2_bits_sv_valid;
  sc_signal<bool> io_in_bits_2_bits_cmdsync;
  sc_signal<bool> io_in_bits_3_valid;
  sc_signal<bool> io_in_bits_3_bits_m;
  sc_signal<bool> io_in_bits_3_bits_vd_valid;
  sc_signal<bool> io_in_bits_3_bits_ve_valid;
  sc_signal<bool> io_in_bits_3_bits_vf_valid;
  sc_signal<bool> io_in_bits_3_bits_vg_valid;
  sc_signal<bool> io_in_bits_3_bits_vs_valid;
  sc_signal<bool> io_in_bits_3_bits_vt_valid;
  sc_signal<bool> io_in_bits_3_bits_vu_valid;
  sc_signal<bool> io_in_bits_3_bits_vx_valid;
  sc_signal<bool> io_in_bits_3_bits_vy_valid;
  sc_signal<bool> io_in_bits_3_bits_vz_valid;
  sc_signal<bool> io_in_bits_3_bits_sv_valid;
  sc_signal<bool> io_in_bits_3_bits_cmdsync;
  sc_signal<bool> io_write_valid;
  sc_signal<bool> io_axi_addr_ready;
  sc_signal<bool> io_axi_addr_valid;
  sc_signal<bool> io_axi_data_ready;
  sc_signal<bool> io_axi_data_valid;
  sc_signal<bool> io_nempty;
  sc_signal<sc_bv<7> > io_in_bits_0_bits_op;
  sc_signal<sc_bv<3> > io_in_bits_0_bits_f2;
  sc_signal<sc_bv<3> > io_in_bits_0_bits_sz;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vd_addr;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_ve_addr;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vf_addr;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vg_addr;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vs_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vs_tag;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vt_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vt_tag;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vu_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vu_tag;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vx_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vx_tag;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vy_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vy_tag;
  sc_signal<sc_bv<6> > io_in_bits_0_bits_vz_addr;
  sc_signal<sc_bv<4> > io_in_bits_0_bits_vz_tag;
  sc_signal<sc_bv<32> > io_in_bits_0_bits_sv_addr;
  sc_signal<sc_bv<32> > io_in_bits_0_bits_sv_data;
  sc_signal<sc_bv<7> > io_in_bits_1_bits_op;
  sc_signal<sc_bv<3> > io_in_bits_1_bits_f2;
  sc_signal<sc_bv<3> > io_in_bits_1_bits_sz;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vd_addr;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_ve_addr;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vf_addr;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vg_addr;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vs_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vs_tag;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vt_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vt_tag;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vu_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vu_tag;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vx_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vx_tag;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vy_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vy_tag;
  sc_signal<sc_bv<6> > io_in_bits_1_bits_vz_addr;
  sc_signal<sc_bv<4> > io_in_bits_1_bits_vz_tag;
  sc_signal<sc_bv<32> > io_in_bits_1_bits_sv_addr;
  sc_signal<sc_bv<32> > io_in_bits_1_bits_sv_data;
  sc_signal<sc_bv<7> > io_in_bits_2_bits_op;
  sc_signal<sc_bv<3> > io_in_bits_2_bits_f2;
  sc_signal<sc_bv<3> > io_in_bits_2_bits_sz;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vd_addr;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_ve_addr;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vf_addr;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vg_addr;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vs_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vs_tag;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vt_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vt_tag;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vu_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vu_tag;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vx_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vx_tag;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vy_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vy_tag;
  sc_signal<sc_bv<6> > io_in_bits_2_bits_vz_addr;
  sc_signal<sc_bv<4> > io_in_bits_2_bits_vz_tag;
  sc_signal<sc_bv<32> > io_in_bits_2_bits_sv_addr;
  sc_signal<sc_bv<32> > io_in_bits_2_bits_sv_data;
  sc_signal<sc_bv<7> > io_in_bits_3_bits_op;
  sc_signal<sc_bv<3> > io_in_bits_3_bits_f2;
  sc_signal<sc_bv<3> > io_in_bits_3_bits_sz;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vd_addr;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_ve_addr;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vf_addr;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vg_addr;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vs_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vs_tag;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vt_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vt_tag;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vu_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vu_tag;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vx_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vx_tag;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vy_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vy_tag;
  sc_signal<sc_bv<6> > io_in_bits_3_bits_vz_addr;
  sc_signal<sc_bv<4> > io_in_bits_3_bits_vz_tag;
  sc_signal<sc_bv<32> > io_in_bits_3_bits_sv_addr;
  sc_signal<sc_bv<32> > io_in_bits_3_bits_sv_data;
  sc_signal<sc_bv<6> > io_write_addr;
  sc_signal<sc_bv<kVector> > io_write_data;
  sc_signal<sc_bv<32> > io_axi_addr_bits_addr;
  sc_signal<sc_bv<6> > io_axi_addr_bits_id;
  sc_signal<sc_bv<2> > io_axi_data_bits_resp;
  sc_signal<sc_bv<6> > io_axi_data_bits_id;
  sc_signal<sc_bv<kVector> > io_axi_data_bits_data;

  VLd_tb tb("VLd_tb", loops, true /*random*/);
  VVLd ld(name);

  ld.clock(tb.clock);
  ld.reset(tb.reset);
  BIND2(tb, ld, io_in_ready);
  BIND2(tb, ld, io_in_valid);
  BIND2(tb, ld, io_in_bits_0_valid);
  BIND2(tb, ld, io_in_bits_0_bits_m);
  BIND2(tb, ld, io_in_bits_0_bits_vd_valid);
  BIND2(tb, ld, io_in_bits_0_bits_ve_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vf_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vg_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vs_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vt_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vu_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vx_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vy_valid);
  BIND2(tb, ld, io_in_bits_0_bits_vz_valid);
  BIND2(tb, ld, io_in_bits_0_bits_sv_valid);
  BIND2(tb, ld, io_in_bits_0_bits_cmdsync);
  BIND2(tb, ld, io_in_bits_1_valid);
  BIND2(tb, ld, io_in_bits_1_bits_m);
  BIND2(tb, ld, io_in_bits_1_bits_vd_valid);
  BIND2(tb, ld, io_in_bits_1_bits_ve_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vf_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vg_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vs_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vt_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vu_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vx_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vy_valid);
  BIND2(tb, ld, io_in_bits_1_bits_vz_valid);
  BIND2(tb, ld, io_in_bits_1_bits_sv_valid);
  BIND2(tb, ld, io_in_bits_1_bits_cmdsync);
  BIND2(tb, ld, io_in_bits_2_valid);
  BIND2(tb, ld, io_in_bits_2_bits_m);
  BIND2(tb, ld, io_in_bits_2_bits_vd_valid);
  BIND2(tb, ld, io_in_bits_2_bits_ve_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vf_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vg_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vs_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vt_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vu_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vx_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vy_valid);
  BIND2(tb, ld, io_in_bits_2_bits_vz_valid);
  BIND2(tb, ld, io_in_bits_2_bits_sv_valid);
  BIND2(tb, ld, io_in_bits_2_bits_cmdsync);
  BIND2(tb, ld, io_in_bits_3_valid);
  BIND2(tb, ld, io_in_bits_3_bits_m);
  BIND2(tb, ld, io_in_bits_3_bits_vd_valid);
  BIND2(tb, ld, io_in_bits_3_bits_ve_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vf_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vg_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vs_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vt_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vu_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vx_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vy_valid);
  BIND2(tb, ld, io_in_bits_3_bits_vz_valid);
  BIND2(tb, ld, io_in_bits_3_bits_sv_valid);
  BIND2(tb, ld, io_in_bits_3_bits_cmdsync);
  BIND2(tb, ld, io_write_valid);
  BIND2(tb, ld, io_axi_addr_ready);
  BIND2(tb, ld, io_axi_addr_valid);
  BIND2(tb, ld, io_axi_data_ready);
  BIND2(tb, ld, io_axi_data_valid);
  BIND2(tb, ld, io_nempty);
  BIND2(tb, ld, io_in_bits_0_bits_op);
  BIND2(tb, ld, io_in_bits_0_bits_f2);
  BIND2(tb, ld, io_in_bits_0_bits_sz);
  BIND2(tb, ld, io_in_bits_0_bits_vd_addr);
  BIND2(tb, ld, io_in_bits_0_bits_ve_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vf_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vg_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vs_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vs_tag);
  BIND2(tb, ld, io_in_bits_0_bits_vt_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vt_tag);
  BIND2(tb, ld, io_in_bits_0_bits_vu_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vu_tag);
  BIND2(tb, ld, io_in_bits_0_bits_vx_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vx_tag);
  BIND2(tb, ld, io_in_bits_0_bits_vy_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vy_tag);
  BIND2(tb, ld, io_in_bits_0_bits_vz_addr);
  BIND2(tb, ld, io_in_bits_0_bits_vz_tag);
  BIND2(tb, ld, io_in_bits_0_bits_sv_addr);
  BIND2(tb, ld, io_in_bits_0_bits_sv_data);
  BIND2(tb, ld, io_in_bits_1_bits_op);
  BIND2(tb, ld, io_in_bits_1_bits_f2);
  BIND2(tb, ld, io_in_bits_1_bits_sz);
  BIND2(tb, ld, io_in_bits_1_bits_vd_addr);
  BIND2(tb, ld, io_in_bits_1_bits_ve_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vf_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vg_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vs_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vs_tag);
  BIND2(tb, ld, io_in_bits_1_bits_vt_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vt_tag);
  BIND2(tb, ld, io_in_bits_1_bits_vu_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vu_tag);
  BIND2(tb, ld, io_in_bits_1_bits_vx_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vx_tag);
  BIND2(tb, ld, io_in_bits_1_bits_vy_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vy_tag);
  BIND2(tb, ld, io_in_bits_1_bits_vz_addr);
  BIND2(tb, ld, io_in_bits_1_bits_vz_tag);
  BIND2(tb, ld, io_in_bits_1_bits_sv_addr);
  BIND2(tb, ld, io_in_bits_1_bits_sv_data);
  BIND2(tb, ld, io_in_bits_2_bits_op);
  BIND2(tb, ld, io_in_bits_2_bits_f2);
  BIND2(tb, ld, io_in_bits_2_bits_sz);
  BIND2(tb, ld, io_in_bits_2_bits_vd_addr);
  BIND2(tb, ld, io_in_bits_2_bits_ve_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vf_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vg_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vs_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vs_tag);
  BIND2(tb, ld, io_in_bits_2_bits_vt_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vt_tag);
  BIND2(tb, ld, io_in_bits_2_bits_vu_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vu_tag);
  BIND2(tb, ld, io_in_bits_2_bits_vx_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vx_tag);
  BIND2(tb, ld, io_in_bits_2_bits_vy_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vy_tag);
  BIND2(tb, ld, io_in_bits_2_bits_vz_addr);
  BIND2(tb, ld, io_in_bits_2_bits_vz_tag);
  BIND2(tb, ld, io_in_bits_2_bits_sv_addr);
  BIND2(tb, ld, io_in_bits_2_bits_sv_data);
  BIND2(tb, ld, io_in_bits_3_bits_op);
  BIND2(tb, ld, io_in_bits_3_bits_f2);
  BIND2(tb, ld, io_in_bits_3_bits_sz);
  BIND2(tb, ld, io_in_bits_3_bits_vd_addr);
  BIND2(tb, ld, io_in_bits_3_bits_ve_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vf_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vg_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vs_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vs_tag);
  BIND2(tb, ld, io_in_bits_3_bits_vt_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vt_tag);
  BIND2(tb, ld, io_in_bits_3_bits_vu_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vu_tag);
  BIND2(tb, ld, io_in_bits_3_bits_vx_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vx_tag);
  BIND2(tb, ld, io_in_bits_3_bits_vy_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vy_tag);
  BIND2(tb, ld, io_in_bits_3_bits_vz_addr);
  BIND2(tb, ld, io_in_bits_3_bits_vz_tag);
  BIND2(tb, ld, io_in_bits_3_bits_sv_addr);
  BIND2(tb, ld, io_in_bits_3_bits_sv_data);
  BIND2(tb, ld, io_write_addr);
  BIND2(tb, ld, io_write_data);
  BIND2(tb, ld, io_axi_addr_bits_addr);
  BIND2(tb, ld, io_axi_addr_bits_id);
  BIND2(tb, ld, io_axi_data_bits_resp);
  BIND2(tb, ld, io_axi_data_bits_id);
  BIND2(tb, ld, io_axi_data_bits_data);

  if (trace) {
    tb.trace(ld);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VLd_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
