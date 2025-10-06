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

#include "VVRegfileSegment.h"

#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/sysc_tb.h"

struct VRegfileSegment_tb : Sysc_tb {
  sc_out<sc_bv<6> > io_read_0_addr;
  sc_in<sc_bv<32> > io_read_0_data;
  sc_out<sc_bv<6> > io_read_1_addr;
  sc_in<sc_bv<32> > io_read_1_data;
  sc_out<sc_bv<6> > io_read_2_addr;
  sc_in<sc_bv<32> > io_read_2_data;
  sc_out<sc_bv<6> > io_read_3_addr;
  sc_in<sc_bv<32> > io_read_3_data;
  sc_out<sc_bv<6> > io_read_4_addr;
  sc_in<sc_bv<32> > io_read_4_data;
  sc_out<sc_bv<6> > io_read_5_addr;
  sc_in<sc_bv<32> > io_read_5_data;
  sc_out<sc_bv<6> > io_read_6_addr;
  sc_in<sc_bv<32> > io_read_6_data;
  sc_out<sc_bv<6> > io_transpose_addr;
  sc_in<sc_bv<kVector> > io_transpose_data;
  sc_out<sc_bv<6> > io_internal_addr;
  sc_in<sc_bv<32> > io_internal_data;
  sc_out<bool> io_write_0_valid;
  sc_out<sc_bv<6> > io_write_0_addr;
  sc_out<sc_bv<32> > io_write_0_data;
  sc_out<bool> io_write_1_valid;
  sc_out<sc_bv<6> > io_write_1_addr;
  sc_out<sc_bv<32> > io_write_1_data;
  sc_out<bool> io_write_2_valid;
  sc_out<sc_bv<6> > io_write_2_addr;
  sc_out<sc_bv<32> > io_write_2_data;
  sc_out<bool> io_write_3_valid;
  sc_out<sc_bv<6> > io_write_3_addr;
  sc_out<sc_bv<32> > io_write_3_data;
  sc_out<bool> io_write_4_valid;
  sc_out<sc_bv<6> > io_write_4_addr;
  sc_out<sc_bv<32> > io_write_4_data;
  sc_out<bool> io_write_5_valid;
  sc_out<sc_bv<6> > io_write_5_addr;
  sc_out<sc_bv<32> > io_write_5_data;
  sc_out<bool> io_conv_valid;
  sc_out<sc_bv<32> > io_conv_data_0;
  sc_out<sc_bv<32> > io_conv_data_1;
  sc_out<sc_bv<32> > io_conv_data_2;
  sc_out<sc_bv<32> > io_conv_data_3;
#if CORALNPU_SIMD >= 256
  sc_out<sc_bv<32> > io_conv_data_4;
  sc_out<sc_bv<32> > io_conv_data_5;
  sc_out<sc_bv<32> > io_conv_data_6;
  sc_out<sc_bv<32> > io_conv_data_7;
#endif
#if CORALNPU_SIMD >= 512
  sc_out<sc_bv<32> > io_conv_data_8;
  sc_out<sc_bv<32> > io_conv_data_9;
  sc_out<sc_bv<32> > io_conv_data_10;
  sc_out<sc_bv<32> > io_conv_data_11;
  sc_out<sc_bv<32> > io_conv_data_12;
  sc_out<sc_bv<32> > io_conv_data_13;
  sc_out<sc_bv<32> > io_conv_data_14;
  sc_out<sc_bv<32> > io_conv_data_15;
#endif

  using Sysc_tb::Sysc_tb;

  void posedge() {
    if (init_ < 64) {
      io_write_0_valid = true;
      io_write_0_addr = init_;
      io_write_0_data = vreg_[init_] = rand_uint32();
      init_++;
      return;
    }

    // Inputs.
    bool conv = rand_int(0, 3) != 0;

    io_read_0_addr = rand_uint32(0, 63);
    io_read_1_addr = rand_uint32(0, 63);
    io_read_2_addr = rand_uint32(0, 63);
    io_read_3_addr = rand_uint32(0, 63);
    io_read_4_addr = rand_uint32(0, 63);
    io_read_5_addr = rand_uint32(0, 63);
    io_read_6_addr = rand_uint32(0, 63);

    io_transpose_addr = rand_uint32(0, 63) & ~15;

    io_internal_addr = rand_uint32(0, 63);

    io_write_0_valid = rand_bool();
    io_write_1_valid = rand_bool();
    io_write_2_valid = rand_bool();
    io_write_3_valid = rand_bool();
    io_write_4_valid = rand_bool();
    io_write_5_valid = rand_bool();

    uint8_t waddr[6];
    RandWriteAddresses(waddr, conv);
    io_write_0_addr = waddr[0];
    io_write_1_addr = waddr[1];
    io_write_2_addr = waddr[2];
    io_write_3_addr = waddr[3];
    io_write_4_addr = waddr[4];
    io_write_5_addr = waddr[5];

    io_write_0_data = rand_uint32();
    io_write_1_data = rand_uint32();
    io_write_2_data = rand_uint32();
    io_write_3_data = rand_uint32();
    io_write_4_data = rand_uint32();
    io_write_5_data = rand_uint32();

    io_conv_valid = conv;
    io_conv_data_0 = rand_uint32();
    io_conv_data_1 = rand_uint32();
    io_conv_data_2 = rand_uint32();
    io_conv_data_3 = rand_uint32();
#if CORALNPU_SIMD >= 256
    io_conv_data_4 = rand_uint32();
    io_conv_data_5 = rand_uint32();
    io_conv_data_6 = rand_uint32();
    io_conv_data_7 = rand_uint32();
#endif
#if CORALNPU_SIMD >= 512
    io_conv_data_8 = rand_uint32();
    io_conv_data_9 = rand_uint32();
    io_conv_data_10 = rand_uint32();
    io_conv_data_11 = rand_uint32();
    io_conv_data_12 = rand_uint32();
    io_conv_data_13 = rand_uint32();
    io_conv_data_14 = rand_uint32();
    io_conv_data_15 = rand_uint32();
#endif

    // Read.
#define READ_CHECK(idx)                                     \
  check(io_read_##idx##_data.read().get_word(0) ==          \
            vreg_[io_read_##idx##_addr.read().get_word(0)], \
        "read data");

    READ_CHECK(0);
    READ_CHECK(1);
    READ_CHECK(2);
    READ_CHECK(3);
    READ_CHECK(4);
    READ_CHECK(5);

    // Transpose.
    for (int i = 0; i < kVector / 32; ++i) {
      check(io_transpose_data.read().get_word(i) ==
                vreg_[io_transpose_addr.read().get_word(0) + i],
            "transpose data");
    }

    // Internal.
    check(io_internal_data.read().get_word(0) ==
              vreg_[io_internal_addr.read().get_word(0)],
          "internal data");

    // Update model.
#define WRITE_DATA(idx)                               \
  if (io_write_##idx##_valid) {                       \
    vreg_[io_write_##idx##_addr.read().get_word(0)] = \
        io_write_##idx##_data.read().get_word(0);     \
  }

    WRITE_DATA(0);
    WRITE_DATA(1);
    WRITE_DATA(2);
    WRITE_DATA(3);
    WRITE_DATA(4);
    WRITE_DATA(5);

    if (io_conv_valid) {
      for (int i = 0; i < kVector / 32; ++i) {
        uint32_t data;
        if (i == 0) data = io_conv_data_0.read().get_word(0);
        if (i == 1) data = io_conv_data_1.read().get_word(0);
        if (i == 2) data = io_conv_data_2.read().get_word(0);
        if (i == 3) data = io_conv_data_3.read().get_word(0);
#if CORALNPU_SIMD >= 256
        if (i == 4) data = io_conv_data_4.read().get_word(0);
        if (i == 5) data = io_conv_data_5.read().get_word(0);
        if (i == 6) data = io_conv_data_6.read().get_word(0);
        if (i == 7) data = io_conv_data_7.read().get_word(0);
#endif
#if CORALNPU_SIMD >= 512
        if (i == 8) data = io_conv_data_8.read().get_word(0);
        if (i == 9) data = io_conv_data_9.read().get_word(0);
        if (i == 10) data = io_conv_data_10.read().get_word(0);
        if (i == 11) data = io_conv_data_11.read().get_word(0);
        if (i == 12) data = io_conv_data_12.read().get_word(0);
        if (i == 13) data = io_conv_data_13.read().get_word(0);
        if (i == 14) data = io_conv_data_14.read().get_word(0);
        if (i == 15) data = io_conv_data_15.read().get_word(0);
#endif
        vreg_[i + 48] = data;
      }
    }
  }

 private:
  int init_ = 0;
  uint32_t vreg_[64];

  void RandWriteAddresses(uint8_t addr[6], bool exclude_accumulators) {
    uint8_t active[64];
    int mark = 0;
    memset(active, 0, 64);
    if (exclude_accumulators) {
      memset(active + 48, 1, 16);
    }
    while (mark < 6) {
      int r = rand_uint32(0, 63);
      if (active[r]) continue;
      active[r] = 1;
      addr[mark] = r;
      ++mark;
    }
  }

  uint32_t DotProduct(uint32_t adata, uint32_t bdata, uint32_t abias,
                      uint32_t bbias, bool asign, bool bsign) {
    int32_t dotp = 0;
    int32_t s_abias = int32_t(abias << 23) >> 23;
    int32_t s_bbias = int32_t(bbias << 23) >> 23;
    for (int i = 0; i < 4; ++i) {
      int32_t s_adata = int32_t(uint8_t(adata >> (8 * i)));
      int32_t s_bdata = int32_t(uint8_t(bdata >> (8 * i)));
      if (asign) {
        s_adata = int8_t(s_adata);
      }
      if (bsign) {
        s_bdata = int8_t(s_bdata);
      }
      dotp += (s_adata + s_abias) * (s_bdata + s_bbias);
    }
    return dotp;
  }
};

static void VRegfileSegment_test(char* name, int loops, bool trace) {
  sc_signal<bool> clock;
  sc_signal<bool> reset;

  sc_signal<sc_bv<6> > io_read_0_addr;
  sc_signal<sc_bv<32> > io_read_0_data;
  sc_signal<sc_bv<6> > io_read_1_addr;
  sc_signal<sc_bv<32> > io_read_1_data;
  sc_signal<sc_bv<6> > io_read_2_addr;
  sc_signal<sc_bv<32> > io_read_2_data;
  sc_signal<sc_bv<6> > io_read_3_addr;
  sc_signal<sc_bv<32> > io_read_3_data;
  sc_signal<sc_bv<6> > io_read_4_addr;
  sc_signal<sc_bv<32> > io_read_4_data;
  sc_signal<sc_bv<6> > io_read_5_addr;
  sc_signal<sc_bv<32> > io_read_5_data;
  sc_signal<sc_bv<6> > io_read_6_addr;
  sc_signal<sc_bv<32> > io_read_6_data;
  sc_signal<sc_bv<6> > io_transpose_addr;
  sc_signal<sc_bv<kVector> > io_transpose_data;
  sc_signal<sc_bv<6> > io_internal_addr;
  sc_signal<sc_bv<32> > io_internal_data;
  sc_signal<bool> io_write_0_valid;
  sc_signal<sc_bv<6> > io_write_0_addr;
  sc_signal<sc_bv<32> > io_write_0_data;
  sc_signal<bool> io_write_1_valid;
  sc_signal<sc_bv<6> > io_write_1_addr;
  sc_signal<sc_bv<32> > io_write_1_data;
  sc_signal<bool> io_write_2_valid;
  sc_signal<sc_bv<6> > io_write_2_addr;
  sc_signal<sc_bv<32> > io_write_2_data;
  sc_signal<bool> io_write_3_valid;
  sc_signal<sc_bv<6> > io_write_3_addr;
  sc_signal<sc_bv<32> > io_write_3_data;
  sc_signal<bool> io_write_4_valid;
  sc_signal<sc_bv<6> > io_write_4_addr;
  sc_signal<sc_bv<32> > io_write_4_data;
  sc_signal<bool> io_write_5_valid;
  sc_signal<sc_bv<6> > io_write_5_addr;
  sc_signal<sc_bv<32> > io_write_5_data;
  sc_signal<bool> io_conv_valid;
  sc_signal<sc_bv<32> > io_conv_data_0;
  sc_signal<sc_bv<32> > io_conv_data_1;
  sc_signal<sc_bv<32> > io_conv_data_2;
  sc_signal<sc_bv<32> > io_conv_data_3;
#if CORALNPU_SIMD >= 256
  sc_signal<sc_bv<32> > io_conv_data_4;
  sc_signal<sc_bv<32> > io_conv_data_5;
  sc_signal<sc_bv<32> > io_conv_data_6;
  sc_signal<sc_bv<32> > io_conv_data_7;
#endif
#if CORALNPU_SIMD >= 512
  sc_signal<sc_bv<32> > io_conv_data_8;
  sc_signal<sc_bv<32> > io_conv_data_9;
  sc_signal<sc_bv<32> > io_conv_data_10;
  sc_signal<sc_bv<32> > io_conv_data_11;
  sc_signal<sc_bv<32> > io_conv_data_12;
  sc_signal<sc_bv<32> > io_conv_data_13;
  sc_signal<sc_bv<32> > io_conv_data_14;
  sc_signal<sc_bv<32> > io_conv_data_15;
#endif

  VRegfileSegment_tb tb("VRegfileSegment_tb", loops, true /*random*/);
  VVRegfileSegment vrf(name);

  if (trace) {
    tb.trace(&vrf);
  }

  vrf.clock(tb.clock);
  vrf.reset(tb.reset);

  BIND2(tb, vrf, io_read_0_addr);
  BIND2(tb, vrf, io_read_0_data);
  BIND2(tb, vrf, io_read_1_addr);
  BIND2(tb, vrf, io_read_1_data);
  BIND2(tb, vrf, io_read_2_addr);
  BIND2(tb, vrf, io_read_2_data);
  BIND2(tb, vrf, io_read_3_addr);
  BIND2(tb, vrf, io_read_3_data);
  BIND2(tb, vrf, io_read_4_addr);
  BIND2(tb, vrf, io_read_4_data);
  BIND2(tb, vrf, io_read_5_addr);
  BIND2(tb, vrf, io_read_5_data);
  BIND2(tb, vrf, io_read_6_addr);
  BIND2(tb, vrf, io_read_6_data);
  BIND2(tb, vrf, io_transpose_addr);
  BIND2(tb, vrf, io_transpose_data);
  BIND2(tb, vrf, io_internal_addr);
  BIND2(tb, vrf, io_internal_data);
  BIND2(tb, vrf, io_write_0_valid);
  BIND2(tb, vrf, io_write_0_addr);
  BIND2(tb, vrf, io_write_0_data);
  BIND2(tb, vrf, io_write_1_valid);
  BIND2(tb, vrf, io_write_1_addr);
  BIND2(tb, vrf, io_write_1_data);
  BIND2(tb, vrf, io_write_2_valid);
  BIND2(tb, vrf, io_write_2_addr);
  BIND2(tb, vrf, io_write_2_data);
  BIND2(tb, vrf, io_write_3_valid);
  BIND2(tb, vrf, io_write_3_addr);
  BIND2(tb, vrf, io_write_3_data);
  BIND2(tb, vrf, io_write_4_valid);
  BIND2(tb, vrf, io_write_4_addr);
  BIND2(tb, vrf, io_write_4_data);
  BIND2(tb, vrf, io_write_5_valid);
  BIND2(tb, vrf, io_write_5_addr);
  BIND2(tb, vrf, io_write_5_data);
  BIND2(tb, vrf, io_conv_valid);
  BIND2(tb, vrf, io_conv_data_0);
  BIND2(tb, vrf, io_conv_data_1);
  BIND2(tb, vrf, io_conv_data_2);
  BIND2(tb, vrf, io_conv_data_3);
#if CORALNPU_SIMD >= 256
  BIND2(tb, vrf, io_conv_data_4);
  BIND2(tb, vrf, io_conv_data_5);
  BIND2(tb, vrf, io_conv_data_6);
  BIND2(tb, vrf, io_conv_data_7);
#endif
#if CORALNPU_SIMD >= 512
  BIND2(tb, vrf, io_conv_data_8);
  BIND2(tb, vrf, io_conv_data_9);
  BIND2(tb, vrf, io_conv_data_10);
  BIND2(tb, vrf, io_conv_data_11);
  BIND2(tb, vrf, io_conv_data_12);
  BIND2(tb, vrf, io_conv_data_13);
  BIND2(tb, vrf, io_conv_data_14);
  BIND2(tb, vrf, io_conv_data_15);
#endif

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VRegfileSegment_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
