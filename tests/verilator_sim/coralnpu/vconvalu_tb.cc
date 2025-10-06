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

#include "VVConvAlu.h"
#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/sysc_tb.h"

constexpr int kCount = kVector / 32;

struct VConvAlu_tb : Sysc_tb {
  sc_out<bool> io_op_conv;
  sc_out<bool> io_op_init;
  sc_out<bool> io_op_tran;
  sc_out<bool> io_op_clear;
  sc_out<sc_bv<ctz(kCount)> > io_index;
  sc_out<bool> io_asign;
  sc_out<bool> io_bsign;
  sc_out<sc_bv<kVector> > io_adata;
  sc_out<sc_bv<kVector> > io_bdata;
  sc_out<sc_bv<9> > io_abias;
  sc_out<sc_bv<9> > io_bbias;
  sc_in<sc_bv<kVector> > io_out_0;
  sc_in<sc_bv<kVector> > io_out_1;
  sc_in<sc_bv<kVector> > io_out_2;
  sc_in<sc_bv<kVector> > io_out_3;
#if CORALNPU_SIMD >= 256
  sc_in<sc_bv<kVector> > io_out_4;
  sc_in<sc_bv<kVector> > io_out_5;
  sc_in<sc_bv<kVector> > io_out_6;
  sc_in<sc_bv<kVector> > io_out_7;
#endif
#if CORALNPU_SIMD >= 512
  sc_in<sc_bv<kVector> > io_out_8;
  sc_in<sc_bv<kVector> > io_out_9;
  sc_in<sc_bv<kVector> > io_out_10;
  sc_in<sc_bv<kVector> > io_out_11;
  sc_in<sc_bv<kVector> > io_out_12;
  sc_in<sc_bv<kVector> > io_out_13;
  sc_in<sc_bv<kVector> > io_out_14;
  sc_in<sc_bv<kVector> > io_out_15;
#endif

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // Input set.
    const bool clear = rand_int(0, 255) == 0;
    const bool conv = !clear && rand_int(0, 7);
    const bool init = !clear && !conv && rand_bool();
    const bool tran = !clear && !conv && !init && rand_bool();
    const int index = rand_int(0, kCount - 1);

    sc_bv<kVector> adata;
    sc_bv<kVector> bdata;
    for (int i = 0; i < kCount; ++i) {
      adata.set_word(i, rand_uint32());
      bdata.set_word(i, rand_uint32());
    }
    io_op_conv = conv;
    io_op_init = init;
    io_op_tran = tran;
    io_op_clear = clear;
    io_index = index;
    io_adata = adata;
    io_bdata = bdata;
    io_abias = rand_uint32();
    io_bbias = rand_uint32();
    io_asign = rand_bool();
    io_bsign = rand_bool();

    // Output compare.
    for (int i = 0; i < kCount; ++i) {
      sc_bv<kVector> out;
      switch (i) {
        case 0: out = io_out_0.read(); break;
        case 1: out = io_out_1.read(); break;
        case 2: out = io_out_2.read(); break;
        case 3: out = io_out_3.read(); break;
#if CORALNPU_SIMD >= 256
        case 4: out = io_out_4.read(); break;
        case 5: out = io_out_5.read(); break;
        case 6: out = io_out_6.read(); break;
        case 7: out = io_out_7.read(); break;
#endif
#if CORALNPU_SIMD >= 512
        case 8: out = io_out_8.read(); break;
        case 9: out = io_out_9.read(); break;
        case 10: out = io_out_10.read(); break;
        case 11: out = io_out_11.read(); break;
        case 12: out = io_out_12.read(); break;
        case 13: out = io_out_13.read(); break;
        case 14: out = io_out_14.read(); break;
        case 15: out = io_out_15.read(); break;
#endif
      }
      for (int j = 0; j < kCount; ++j) {
        const uint32_t ref = out_[i][j];
        const uint32_t dut = out.get_word(j);
        if (ref != dut) {
          printf("**error::vconvalu_tb[%d][%d] %08x %08x\n", i, j, ref, dut);
          check(false);
        }
      }
    }

    // Input capture.
    if (io_op_clear) {
      for (int i = 0; i < kCount; ++i) {
        for (int j = 0; j < kCount; ++j) {
          acc_[i][j] = 0;
        }
      }
    }

    const int idx = io_index.read().get_word(0);

    if (io_op_conv) {
      bool asign = io_asign;
      bool bsign = io_bsign;
      uint32_t abias = io_abias.read().get_word(0);
      uint32_t bbias = io_bbias.read().get_word(0);
      for (int i = 0; i < kCount; ++i) {
        for (int j = 0; j < kCount; ++j) {
          uint32_t adata = io_adata.read().get_word(i);
          uint32_t bdata = io_bdata.read().get_word(j);
          acc_[i][j] += DotProduct(adata, bdata, abias, bbias, asign, bsign);
        }
      }
    }
    if (io_op_init) {
      // Outputs are interleaved so must deinterleave inputs.
      for (int i = 0; i < kCount; ++i) {
        for (int j = 0; j < kCount; ++j) {
          int si, sj;
          Interleave(i, j, si, sj);
          uint32_t bdata = io_bdata.read().get_word(sj);
          if (si == idx) {
            acc_[i][j] = bdata;
          }
        }
      }
    }
    if (io_op_tran) {
      // Outputs are interleaved so must deinterleave inputs.
      for (int i = 0; i < kCount; ++i) {
        for (int j = 0; j < kCount; ++j) {
          int si, sj;
          Interleave(i, j, si, sj);
          uint32_t adata = io_adata.read().get_word(sj);
          if (si == idx) {
            acc_[i][j] = adata;
          }
        }
      }
    }

    for (int i = 0; i < kCount; ++i) {
      for (int j = 0; j < kCount; ++j) {
        int si, sj;
        Interleave(i, j, si, sj);
        out_[si][sj] = acc_[i][j];
      }
    }
  }

 private:
  uint32_t acc_[kCount][kCount] = {0};
  uint32_t out_[kCount][kCount] = {0};

  void Interleave(const int i, const int j, int &si, int &sj) {
    constexpr int interleave[4] = {0, 2, 1, 3};
    const int rbase = i & ~3;
    const int rquad = i & 3;
    const int word  = j;
    si = rbase + interleave[word & 3];
    sj = rquad * (kCount / 4) + (word / 4);
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

static void VConvAlu_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_op_conv;
  sc_signal<bool> io_op_init;
  sc_signal<bool> io_op_tran;
  sc_signal<bool> io_op_clear;
  sc_signal<sc_bv<ctz(kCount)> > io_index;
  sc_signal<bool> io_asign;
  sc_signal<bool> io_bsign;
  sc_signal<sc_bv<kVector> > io_adata;
  sc_signal<sc_bv<kVector> > io_bdata;
  sc_signal<sc_bv<9> > io_abias;
  sc_signal<sc_bv<9> > io_bbias;
  sc_signal<sc_bv<kVector> > io_out_0;
  sc_signal<sc_bv<kVector> > io_out_1;
  sc_signal<sc_bv<kVector> > io_out_2;
  sc_signal<sc_bv<kVector> > io_out_3;
#if CORALNPU_SIMD >= 256
  sc_signal<sc_bv<kVector> > io_out_4;
  sc_signal<sc_bv<kVector> > io_out_5;
  sc_signal<sc_bv<kVector> > io_out_6;
  sc_signal<sc_bv<kVector> > io_out_7;
#endif
#if CORALNPU_SIMD >= 256
  sc_signal<sc_bv<kVector> > io_out_8;
  sc_signal<sc_bv<kVector> > io_out_9;
  sc_signal<sc_bv<kVector> > io_out_10;
  sc_signal<sc_bv<kVector> > io_out_11;
  sc_signal<sc_bv<kVector> > io_out_12;
  sc_signal<sc_bv<kVector> > io_out_13;
  sc_signal<sc_bv<kVector> > io_out_14;
  sc_signal<sc_bv<kVector> > io_out_15;
#endif

  VConvAlu_tb tb("VConvAlu_tb", loops, true /*random*/);
  VVConvAlu conv(name);

  conv.clock(tb.clock);
  conv.reset(tb.reset);
  BIND2(tb, conv, io_op_conv);
  BIND2(tb, conv, io_op_init);
  BIND2(tb, conv, io_op_tran);
  BIND2(tb, conv, io_op_clear);
  BIND2(tb, conv, io_index);
  BIND2(tb, conv, io_asign);
  BIND2(tb, conv, io_bsign);
  BIND2(tb, conv, io_adata);
  BIND2(tb, conv, io_bdata);
  BIND2(tb, conv, io_abias);
  BIND2(tb, conv, io_bbias);
  BIND2(tb, conv, io_out_0);
  BIND2(tb, conv, io_out_1);
  BIND2(tb, conv, io_out_2);
  BIND2(tb, conv, io_out_3);
#if CORALNPU_SIMD >= 256
  BIND2(tb, conv, io_out_4);
  BIND2(tb, conv, io_out_5);
  BIND2(tb, conv, io_out_6);
  BIND2(tb, conv, io_out_7);
#endif
#if CORALNPU_SIMD >= 512
  BIND2(tb, conv, io_out_8);
  BIND2(tb, conv, io_out_9);
  BIND2(tb, conv, io_out_10);
  BIND2(tb, conv, io_out_11);
  BIND2(tb, conv, io_out_12);
  BIND2(tb, conv, io_out_13);
  BIND2(tb, conv, io_out_14);
  BIND2(tb, conv, io_out_15);
#endif

  if (trace) {
    tb.trace(&conv);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VConvAlu_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
