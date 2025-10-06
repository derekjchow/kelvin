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

#include "VVRegfile.h"

#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/sysc_tb.h"

struct VRegfile_tb : Sysc_tb {
  sc_out<bool> io_read_0_valid;
  sc_out<sc_bv<6> > io_read_0_addr;
  sc_out<bool> io_read_0_tag;
  sc_in<sc_bv<kVector> > io_read_0_data;
  sc_out<bool> io_read_1_valid;
  sc_out<sc_bv<6> > io_read_1_addr;
  sc_out<bool> io_read_1_tag;
  sc_in<sc_bv<kVector> > io_read_1_data;
  sc_out<bool> io_read_2_valid;
  sc_out<sc_bv<6> > io_read_2_addr;
  sc_out<bool> io_read_2_tag;
  sc_in<sc_bv<kVector> > io_read_2_data;
  sc_out<bool> io_read_3_valid;
  sc_out<sc_bv<6> > io_read_3_addr;
  sc_out<bool> io_read_3_tag;
  sc_in<sc_bv<kVector> > io_read_3_data;
  sc_out<bool> io_read_4_valid;
  sc_out<sc_bv<6> > io_read_4_addr;
  sc_out<bool> io_read_4_tag;
  sc_in<sc_bv<kVector> > io_read_4_data;
  sc_out<bool> io_read_5_valid;
  sc_out<sc_bv<6> > io_read_5_addr;
  sc_out<bool> io_read_5_tag;
  sc_in<sc_bv<kVector> > io_read_5_data;
  sc_out<bool> io_read_6_valid;
  sc_out<sc_bv<6> > io_read_6_addr;
  sc_out<bool> io_read_6_tag;
  sc_in<sc_bv<kVector> > io_read_6_data;
  sc_out<bool> io_scalar_0_valid;
  sc_out<sc_bv<32> > io_scalar_0_data;
  sc_out<bool> io_scalar_1_valid;
  sc_out<sc_bv<32> > io_scalar_1_data;
  sc_out<bool> io_write_0_valid;
  sc_out<sc_bv<6> > io_write_0_addr;
  sc_out<sc_bv<kVector> > io_write_0_data;
  sc_out<bool> io_write_1_valid;
  sc_out<sc_bv<6> > io_write_1_addr;
  sc_out<sc_bv<kVector> > io_write_1_data;
  sc_out<bool> io_write_2_valid;
  sc_out<sc_bv<6> > io_write_2_addr;
  sc_out<sc_bv<kVector> > io_write_2_data;
  sc_out<bool> io_write_3_valid;
  sc_out<sc_bv<6> > io_write_3_addr;
  sc_out<sc_bv<kVector> > io_write_3_data;
  sc_out<bool> io_write_4_valid;
  sc_out<sc_bv<6> > io_write_4_addr;
  sc_out<sc_bv<kVector> > io_write_4_data;
  sc_out<bool> io_write_5_valid;
  sc_out<sc_bv<6> > io_write_5_addr;
  sc_out<sc_bv<kVector> > io_write_5_data;
  sc_out<bool> io_whint_0_valid;
  sc_out<sc_bv<6> > io_whint_0_addr;
  sc_out<bool> io_whint_1_valid;
  sc_out<sc_bv<6> > io_whint_1_addr;
  sc_out<bool> io_whint_2_valid;
  sc_out<sc_bv<6> > io_whint_2_addr;
  sc_out<bool> io_whint_3_valid;
  sc_out<sc_bv<6> > io_whint_3_addr;
  sc_out<bool> io_transpose_valid;
  sc_out<sc_bv<6> > io_transpose_addr;
  sc_out<sc_bv<ctz(kVector / 32)> > io_transpose_index;
  sc_in<sc_bv<kVector> > io_transpose_data;
  sc_out<bool> io_conv_valid;
  sc_out<bool> io_conv_ready;
  sc_out<bool> io_conv_op_conv;
  sc_out<bool> io_conv_op_init;
  sc_out<bool> io_conv_op_tran;
  sc_out<bool> io_conv_op_wclr;
  sc_out<sc_bv<6> > io_conv_addr1;
  sc_out<sc_bv<6> > io_conv_addr2;
  sc_out<sc_bv<2> > io_conv_mode;
  sc_out<sc_bv<ctz(kVector / 32)> > io_conv_index;
  sc_out<sc_bv<9> > io_conv_abias;
  sc_out<sc_bv<9> > io_conv_bbias;
  sc_out<bool> io_conv_asign;
  sc_out<bool> io_conv_bsign;
  sc_out<bool> io_vrfsb_set_valid;
  sc_out<sc_bv<128> > io_vrfsb_set_bits;
  sc_in<sc_bv<128> > io_vrfsb_data;
  sc_in<sc_bv<3> > io_vrfwriteCount;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    if (init_ < 64) {
      io_write_0_valid = true;
      io_write_0_addr = init_;
      sc_bv<kVector> wdata;
      for (int i = 0; i < kVector / 32; ++i) {
        uint32_t data = rand_uint32();
        vreg_[init_][i] = data;
        wdata.set_word(i, data);
      }
      io_write_0_data = wdata;
      init_++;
      return;
    }

    if (init_ < 72) {
      io_write_0_valid = false;
      io_write_0_addr = 0;
      io_write_0_data = 0;
      init_++;
      return;
    }

    conv_prev_ = conv_curr_;
    conv_curr_ = io_conv_valid && io_conv_ready;

    // Inputs.
    bool wvalid[6];
    uint8_t waddr[6];
    if ((cycle() & 1023) < 64) {
      // Periodically mask writes so convolution can burst.
      memset(wvalid, 0, sizeof(wvalid));
    } else {
      // Randomly write.
      for (int i = 0; i < 6; ++i) {
        wvalid[i] = rand_bool();
      }
    }
    RandWriteAddresses(waddr, conv_curr_);

    write_mask1_ = write_mask0_;
    write_mask0_ = 0;
    for (int i = 0; i < 6; ++i) {
      if (wvalid[i]) {
        write_mask0_ |= 1ull << waddr[i];
      }
    }

    const uint64_t write_mask = write_mask0_ | write_mask1_;

    io_write_0_valid = wvalid[0];
    io_write_1_valid = wvalid[1];
    io_write_2_valid = wvalid[2];
    io_write_3_valid = wvalid[3];
    io_write_4_valid = wvalid[4];
    io_write_5_valid = wvalid[5];

    io_write_0_addr = waddr[0];
    io_write_1_addr = waddr[1];
    io_write_2_addr = waddr[2];
    io_write_3_addr = waddr[3];
    io_write_4_addr = waddr[4];
    io_write_5_addr = waddr[5];

    bool pvalid[4];
    uint8_t paddr[4];
    for (int i = 0; i < 4; ++i) {
      pvalid[i] = rand_bool();
      paddr[i] = rand_uint32(0, 63);
    }

    io_whint_0_valid = pvalid[0];
    io_whint_1_valid = pvalid[1];
    io_whint_2_valid = pvalid[2];
    io_whint_3_valid = pvalid[3];

    io_whint_0_addr = paddr[0];
    io_whint_1_addr = paddr[1];
    io_whint_2_addr = paddr[2];
    io_whint_3_addr = paddr[3];

#define WRITE_DATA(idx)                      \
  {                                          \
    sc_bv<kVector> wdata;                    \
    for (int i = 0; i < kVector / 32; ++i) { \
      wdata.set_word(i, rand_uint32());      \
    }                                        \
    io_write_##idx##_data = wdata;           \
  }

    WRITE_DATA(0);
    WRITE_DATA(1);
    WRITE_DATA(2);
    WRITE_DATA(3);
    WRITE_DATA(4);
    WRITE_DATA(5);

    uint8_t conv_addr1 = 0;
    uint8_t conv_addr2 = 0;
    uint8_t conv_index = rand_uint32(0, (kVector / 32) - 1);
    bool conv_valid = rand_uint32(0, 7) != 0 &&
                      RandConvAddr(conv_addr1, conv_addr2, write_mask);
    bool conv_ready = rand_bool();
    bool conv_op_wclr = rand_uint32(0, 7) == 0 && (write_mask >> 48) == 0;
    bool conv_op_conv = !conv_op_wclr;
    bool conv_op_init = false;
    bool conv_op_tran = false;
    bool scalar0valid = rand_int(0, 7) == 0;
    bool scalar1valid = rand_int(0, 7) == 0;

    io_conv_valid = conv_valid;
    io_conv_ready = conv_ready;
    io_conv_op_conv = conv_op_conv;
    io_conv_op_init = conv_op_init;
    io_conv_op_tran = conv_op_tran;
    io_conv_op_wclr = conv_op_wclr;
    io_conv_addr1 = conv_addr1;
    io_conv_addr2 = conv_addr2;
    io_conv_mode = 0;
    io_conv_index = conv_index;
    io_conv_abias = rand_uint32();
    io_conv_bbias = rand_uint32();
    io_conv_asign = rand_bool();
    io_conv_bsign = rand_bool();

    io_read_0_valid = rand_bool();
    io_read_1_valid = rand_bool() && !scalar0valid;
    io_read_2_valid = rand_bool();
    io_read_3_valid = rand_bool();
    io_read_4_valid = rand_bool() && !scalar1valid;
    io_read_5_valid = rand_bool();
    io_read_6_valid = rand_bool();

    io_read_0_addr = rand_uint32(0, 63);
    io_read_1_addr = rand_uint32(0, 63);
    io_read_2_addr = rand_uint32(0, 63);
    io_read_3_addr = rand_uint32(0, 63);
    io_read_4_addr = rand_uint32(0, 63);
    io_read_5_addr = rand_uint32(0, 63);
    io_read_6_addr = rand_uint32(0, 63);

    io_read_0_tag = rand_bool();
    io_read_1_tag = rand_bool();
    io_read_2_tag = rand_bool();
    io_read_3_tag = rand_bool();
    io_read_4_tag = rand_bool();
    io_read_5_tag = rand_bool();
    io_read_6_tag = rand_bool();

    io_scalar_0_valid = scalar0valid;
    io_scalar_1_valid = scalar1valid;

    io_scalar_0_data = rand_uint32();
    io_scalar_1_data = rand_uint32();

    uint8_t transpose_addr = 0;
    bool transpose_valid =
        rand_bool() && RandTransposeAddr(transpose_addr, write_mask);
    io_transpose_valid =
        transpose_valid && !conv_valid && !conv_curr_ && !conv_prev_;
    io_transpose_addr = transpose_addr;
    io_transpose_index = rand_uint32(0, (kVector / 32) - 1);

    // Read.
#define READ_CHECK(idx)                                                     \
  if (read_valid_[idx] || read_scalar_valid_[idx]) {                        \
    for (int i = 0; i < kVector / 32; ++i) {                                \
      uint32_t value = read_scalar_valid_[idx] ? read_scalar_data_[idx]     \
                                               : vreg_[read_addr_[idx]][i]; \
      check(io_read_##idx##_data.read().get_word(i) == value, "read data"); \
    }                                                                       \
  }

    READ_CHECK(0);
    READ_CHECK(1);
    READ_CHECK(2);
    READ_CHECK(3);
    READ_CHECK(4);
    READ_CHECK(5);

    // Reads from convolution accumulator writes will be ignored by schedule.
#define READ_LATCH(idx)                                                \
  read_valid_[idx] = io_read_##idx##_valid.read() &&                   \
                     !((conv_curr_ || conv_prev_) &&                   \
                       io_read_##idx##_addr.read().get_word(0) >= 48); \
  read_addr_[idx] = io_read_##idx##_addr.read().get_word(0);           \
  if (idx == 1) {                                                      \
    read_scalar_valid_[idx] = io_scalar_0_valid;                       \
    read_scalar_data_[idx] = io_scalar_0_data.read().get_word(0);      \
  }                                                                    \
  if (idx == 4) {                                                      \
    read_scalar_valid_[idx] = io_scalar_1_valid;                       \
    read_scalar_data_[idx] = io_scalar_1_data.read().get_word(0);      \
  }

    READ_LATCH(0);
    READ_LATCH(1);
    READ_LATCH(2);
    READ_LATCH(3);
    READ_LATCH(4);
    READ_LATCH(5);

    // Transpose.
    for (int i = 0; i < kVector / 32; ++i) {
      if (transpose_valid_) {
        check(io_transpose_data.read().get_word(i) ==
                  vreg_[transpose_addr_ + i][transpose_index_],
              "transpose data");
      }
    }

    transpose_valid_ = io_transpose_valid;
    transpose_addr_ = io_transpose_addr.read().get_word(0);
    transpose_index_ = io_transpose_index.read().get_word(0);

    // Scoreboard.
    io_vrfsb_set_valid = rand_bool();
    io_vrfsb_set_bits = ScoreboardSet();

    for (int i = 0; i < 2; ++i) {
      uint64_t sb_ref = scoreboard_[i];
      uint64_t sb_dut =
          io_vrfsb_data.read().get_word(2 * i + 0) |
          (uint64_t(io_vrfsb_data.read().get_word(2 * i + 1)) << 32);
      check(sb_ref == sb_dut, "Scoreboard");
    }

    // Update model.
#define WRITE_UPDATE(idx)                                        \
  if (io_write_##idx##_valid) {                                  \
    int addr = io_write_##idx##_addr.read().get_word(0);         \
    uint64_t clear = ~(1ull << addr);                            \
    scoreboard_[0] &= clear;                                     \
    scoreboard_[1] &= clear;                                     \
    for (int i = 0; i < kVector / 32; ++i) {                     \
      vreg_[addr][i] = io_write_##idx##_data.read().get_word(i); \
    }                                                            \
  }
#define WHINT_UPDATE(idx)                                \
  if (io_whint_##idx##_valid) {                          \
    int addr = io_whint_##idx##_addr.read().get_word(0); \
    uint64_t clear = ~(1ull << addr);                    \
    scoreboard_[0] &= clear;                             \
    scoreboard_[1] &= clear;                             \
  }

    WRITE_UPDATE(0);
    WRITE_UPDATE(1);
    WRITE_UPDATE(2);
    WRITE_UPDATE(3);
    WRITE_UPDATE(4);
    WRITE_UPDATE(5);

    WHINT_UPDATE(0);
    WHINT_UPDATE(1);
    WHINT_UPDATE(2);
    WHINT_UPDATE(3);

    if (wclr_) {
      const uint64_t clear = ~(kVector == 128   ? 0x000f000000000000llu
                               : kVector == 256 ? 0x00ff000000000000llu
                                                : 0xffff000000000000llu);
      scoreboard_[0] &= clear;
      scoreboard_[1] &= clear;
    }
    // delayed one cycle beyond io.conv.wclr, no forwarding to read ports.
    wclr_ = io_conv_valid && io_conv_ready && io_conv_op_wclr;

    if (io_vrfsb_set_valid) {
      scoreboard_[0] |= io_vrfsb_set_bits.read().get_word(0);
      scoreboard_[0] |= uint64_t(io_vrfsb_set_bits.read().get_word(1)) << 32;
      scoreboard_[1] |= io_vrfsb_set_bits.read().get_word(2);
      scoreboard_[1] |= uint64_t(io_vrfsb_set_bits.read().get_word(3)) << 32;
    }

    if (io_conv_valid && io_conv_ready) {
      if (io_conv_op_conv) {
        uint8_t addr1 = io_conv_addr1.read().get_word(0);
        uint8_t addr2 = io_conv_addr2.read().get_word(0);
        uint32_t abias = io_conv_abias.read().get_word(0);
        uint32_t bbias = io_conv_bbias.read().get_word(0);
        bool asign = io_conv_asign;
        bool bsign = io_conv_bsign;
        int index = io_conv_index.read().get_word(0);
        for (int i = 0; i < kVector / 32; ++i) {
          for (int j = 0; j < kVector / 32; ++j) {
            uint32_t adata = vreg_[addr1 + i][index];
            uint32_t bdata = vreg_[addr2][j];
            vacc_[i][j] +=
                DotProduct(adata, bdata, abias, bbias, asign, bsign);
          }
        }
      }

      if (io_conv_op_wclr) {
        for (int i = 0; i < kVector / 32; ++i) {
          for (int j = 0; j < kVector / 32; ++j) {
            constexpr int interleave[4] = {0, 2, 1, 3};
            const int rbase = i & ~3;
            const int rquad = i & 3;
            const int word  = j;
            const int si = rbase + interleave[word & 3];
            const int sj = rquad * (kVector / 32 / 4) + (word / 4);
            vreg_[si + 48][sj] = vacc_[i][j];
            vacc_[i][j] = 0;
          }
        }
      }
    }
  }

 private:
  int init_ = 0;
  bool wclr_ = false;
  uint32_t vreg_[64][kVector / 32];
  uint32_t vacc_[kVector / 32][kVector / 32] = {0};

  bool read_valid_[6] = {false};
  uint8_t read_addr_[6];

  bool read_scalar_valid_[6] = {false};
  uint32_t read_scalar_data_[6];

  bool transpose_valid_ = false;
  uint8_t transpose_addr_;
  uint8_t transpose_index_;

  uint64_t write_mask0_ = 0;  // current cycle
  uint64_t write_mask1_ = 0;  // previous cycle

  uint64_t scoreboard_[2] = {0};

  bool conv_curr_ = false;
  bool conv_prev_ = false;

  void RandWriteAddresses(uint8_t addr[6], bool exclude_accumulators) {
    uint8_t active[64];
    int mark = 0;
    memset(active, 0, 64);
    while (mark < 6) {
      int r = rand_uint32(0, exclude_accumulators ? 47 : 63);
      if (active[r]) continue;
      active[r] = 1;
      addr[mark] = r;
      ++mark;
    }
  }

  sc_bv<128> ScoreboardSet() {
    sc_bv<128> data = 0;
    int n = rand_int(4, 8);
    for (int i = 0; i < n; ++i) {
      data.set_bit(rand_int(0, 127), sc_dt::Log_1);
    }
    return data;
  }

  bool RandConvAddr(uint8_t& addr1, uint8_t& addr2, uint64_t writevalid) {
    const int range1 = 16;
    uint8_t bank1 = rand_uint32(0, 2);
    uint8_t bank2 = rand_uint32(0, 2);
    while (bank1 == bank2) {
      bank2 = rand_uint32(0, 2);
    }
    addr1 = bank1 * 16;
    addr2 = bank2 * 16 + rand_uint32(0, 15);
    // Do not overlap with an active write (which takes 2 cycles).
    for (int i = addr1; i < addr1 + range1; ++i) {
      if (writevalid & (1ull << i)) return false;
    }
    if (writevalid & (1ull << addr2)) return false;
    for (int i = 48; i < 64; ++i) {
      if (writevalid & (1ull << i)) return false;
    }
    return true;
  }

  bool RandTransposeAddr(uint8_t& addr, uint64_t writevalid) {
    int bank = rand_uint32(0, 3);
    addr = 0;
    // Do not transpose from an active write (which takes 2 cycles).
    for (int attempt = 0; attempt < 4; ++attempt) {
      uint8_t test = (bank + attempt) & 3;
      if ((writevalid & (0xffffull << (test * 16))) == 0) {
        addr = test * 16;
        return true;
      }
    }
    return false;
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

static void VRegfile_test(char* name, int loops, bool trace) {
  sc_signal<bool> clock;
  sc_signal<bool> reset;

  sc_signal<bool> io_read_0_valid;
  sc_signal<sc_bv<6> > io_read_0_addr;
  sc_signal<bool> io_read_0_tag;
  sc_signal<sc_bv<kVector> > io_read_0_data;
  sc_signal<bool> io_read_1_valid;
  sc_signal<sc_bv<6> > io_read_1_addr;
  sc_signal<bool> io_read_1_tag;
  sc_signal<sc_bv<kVector> > io_read_1_data;
  sc_signal<bool> io_read_2_valid;
  sc_signal<sc_bv<6> > io_read_2_addr;
  sc_signal<bool> io_read_2_tag;
  sc_signal<sc_bv<kVector> > io_read_2_data;
  sc_signal<bool> io_read_3_valid;
  sc_signal<sc_bv<6> > io_read_3_addr;
  sc_signal<bool> io_read_3_tag;
  sc_signal<sc_bv<kVector> > io_read_3_data;
  sc_signal<bool> io_read_4_valid;
  sc_signal<sc_bv<6> > io_read_4_addr;
  sc_signal<bool> io_read_4_tag;
  sc_signal<sc_bv<kVector> > io_read_4_data;
  sc_signal<bool> io_read_5_valid;
  sc_signal<sc_bv<6> > io_read_5_addr;
  sc_signal<bool> io_read_5_tag;
  sc_signal<sc_bv<kVector> > io_read_5_data;
  sc_signal<bool> io_read_6_valid;
  sc_signal<sc_bv<6> > io_read_6_addr;
  sc_signal<bool> io_read_6_tag;
  sc_signal<sc_bv<kVector> > io_read_6_data;
  sc_signal<bool> io_scalar_0_valid;
  sc_signal<sc_bv<32> > io_scalar_0_data;
  sc_signal<bool> io_scalar_1_valid;
  sc_signal<sc_bv<32> > io_scalar_1_data;
  sc_signal<bool> io_write_0_valid;
  sc_signal<sc_bv<6> > io_write_0_addr;
  sc_signal<sc_bv<kVector> > io_write_0_data;
  sc_signal<bool> io_write_1_valid;
  sc_signal<sc_bv<6> > io_write_1_addr;
  sc_signal<sc_bv<kVector> > io_write_1_data;
  sc_signal<bool> io_write_2_valid;
  sc_signal<sc_bv<6> > io_write_2_addr;
  sc_signal<sc_bv<kVector> > io_write_2_data;
  sc_signal<bool> io_write_3_valid;
  sc_signal<sc_bv<6> > io_write_3_addr;
  sc_signal<sc_bv<kVector> > io_write_3_data;
  sc_signal<bool> io_write_4_valid;
  sc_signal<sc_bv<6> > io_write_4_addr;
  sc_signal<sc_bv<kVector> > io_write_4_data;
  sc_signal<bool> io_write_5_valid;
  sc_signal<sc_bv<6> > io_write_5_addr;
  sc_signal<sc_bv<kVector> > io_write_5_data;
  sc_signal<bool> io_whint_0_valid;
  sc_signal<sc_bv<6> > io_whint_0_addr;
  sc_signal<bool> io_whint_1_valid;
  sc_signal<sc_bv<6> > io_whint_1_addr;
  sc_signal<bool> io_whint_2_valid;
  sc_signal<sc_bv<6> > io_whint_2_addr;
  sc_signal<bool> io_whint_3_valid;
  sc_signal<sc_bv<6> > io_whint_3_addr;
  sc_signal<bool> io_transpose_valid;
  sc_signal<sc_bv<6> > io_transpose_addr;
  sc_signal<sc_bv<ctz(kVector / 32)> > io_transpose_index;
  sc_signal<sc_bv<kVector> > io_transpose_data;
  sc_signal<bool> io_conv_valid;
  sc_signal<bool> io_conv_ready;
  sc_signal<bool> io_conv_op_conv;
  sc_signal<bool> io_conv_op_init;
  sc_signal<bool> io_conv_op_tran;
  sc_signal<bool> io_conv_op_wclr;
  sc_signal<sc_bv<6> > io_conv_addr1;
  sc_signal<sc_bv<6> > io_conv_addr2;
  sc_signal<sc_bv<2> > io_conv_mode;
  sc_signal<sc_bv<ctz(kVector / 32)> > io_conv_index;
  sc_signal<sc_bv<9> > io_conv_abias;
  sc_signal<sc_bv<9> > io_conv_bbias;
  sc_signal<bool> io_conv_asign;
  sc_signal<bool> io_conv_bsign;
  sc_signal<sc_bv<128> > io_vrfsb_set_bits;
  sc_signal<sc_bv<128> > io_vrfsb_data;
  sc_signal<bool> io_vrfsb_set_valid;
  sc_signal<sc_bv<3> > io_vrfwriteCount;

  VRegfile_tb tb("VRegfile_tb", loops, true /*random*/);
  VVRegfile vrf(name);

  if (trace) {
    tb.trace(&vrf);
  }

  vrf.clock(tb.clock);
  vrf.reset(tb.reset);

  BIND2(tb, vrf, io_read_0_valid);
  BIND2(tb, vrf, io_read_0_addr);
  BIND2(tb, vrf, io_read_0_tag);
  BIND2(tb, vrf, io_read_0_data);
  BIND2(tb, vrf, io_read_1_valid);
  BIND2(tb, vrf, io_read_1_addr);
  BIND2(tb, vrf, io_read_1_tag);
  BIND2(tb, vrf, io_read_1_data);
  BIND2(tb, vrf, io_read_2_valid);
  BIND2(tb, vrf, io_read_2_addr);
  BIND2(tb, vrf, io_read_2_tag);
  BIND2(tb, vrf, io_read_2_data);
  BIND2(tb, vrf, io_read_3_valid);
  BIND2(tb, vrf, io_read_3_addr);
  BIND2(tb, vrf, io_read_3_tag);
  BIND2(tb, vrf, io_read_3_data);
  BIND2(tb, vrf, io_read_4_valid);
  BIND2(tb, vrf, io_read_4_addr);
  BIND2(tb, vrf, io_read_4_tag);
  BIND2(tb, vrf, io_read_4_data);
  BIND2(tb, vrf, io_read_5_valid);
  BIND2(tb, vrf, io_read_5_addr);
  BIND2(tb, vrf, io_read_5_tag);
  BIND2(tb, vrf, io_read_5_data);
  BIND2(tb, vrf, io_read_6_valid);
  BIND2(tb, vrf, io_read_6_addr);
  BIND2(tb, vrf, io_read_6_tag);
  BIND2(tb, vrf, io_read_6_data);
  BIND2(tb, vrf, io_scalar_0_valid);
  BIND2(tb, vrf, io_scalar_0_data);
  BIND2(tb, vrf, io_scalar_1_valid);
  BIND2(tb, vrf, io_scalar_1_data);
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
  BIND2(tb, vrf, io_whint_0_valid);
  BIND2(tb, vrf, io_whint_0_addr);
  BIND2(tb, vrf, io_whint_1_valid);
  BIND2(tb, vrf, io_whint_1_addr);
  BIND2(tb, vrf, io_whint_2_valid);
  BIND2(tb, vrf, io_whint_2_addr);
  BIND2(tb, vrf, io_whint_3_valid);
  BIND2(tb, vrf, io_whint_3_addr);
  BIND2(tb, vrf, io_transpose_valid);
  BIND2(tb, vrf, io_transpose_addr);
  BIND2(tb, vrf, io_transpose_index);
  BIND2(tb, vrf, io_transpose_data);
  BIND2(tb, vrf, io_conv_valid);
  BIND2(tb, vrf, io_conv_ready);
  BIND2(tb, vrf, io_conv_op_conv);
  BIND2(tb, vrf, io_conv_op_init);
  BIND2(tb, vrf, io_conv_op_tran);
  BIND2(tb, vrf, io_conv_op_wclr);
  BIND2(tb, vrf, io_conv_addr1);
  BIND2(tb, vrf, io_conv_addr2);
  BIND2(tb, vrf, io_conv_mode);
  BIND2(tb, vrf, io_conv_index);
  BIND2(tb, vrf, io_conv_abias);
  BIND2(tb, vrf, io_conv_bbias);
  BIND2(tb, vrf, io_conv_asign);
  BIND2(tb, vrf, io_conv_bsign);
  BIND2(tb, vrf, io_vrfsb_set_valid);
  BIND2(tb, vrf, io_vrfsb_set_bits);
  BIND2(tb, vrf, io_vrfsb_data);
  BIND2(tb, vrf, io_vrfwriteCount);

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VRegfile_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
