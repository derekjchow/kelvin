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

#include "VVAluInt.h"  // Generated.
#include "tests/verilator_sim/coralnpu/valu.h"
#include "tests/verilator_sim/sysc_tb.h"

struct VAluInt_tb : Sysc_tb {
  sc_out<bool> io_in_valid;
  sc_out<sc_bv<encode::kOpBits> > io_in_op;
  sc_out<sc_bv<3> > io_in_f2;
  sc_out<sc_bv<3> > io_in_sz;
  sc_out<sc_bv<6> > io_in_vd_addr;
  sc_out<sc_bv<6> > io_in_ve_addr;
  sc_out<sc_bv<32> > io_in_sv_data;
  sc_out<sc_bv<kVector> > io_read_0_data;
  sc_out<sc_bv<kVector> > io_read_1_data;
  sc_out<sc_bv<kVector> > io_read_2_data;
  sc_out<sc_bv<kVector> > io_read_3_data;
  sc_out<sc_bv<kVector> > io_read_4_data;
  sc_out<sc_bv<kVector> > io_read_5_data;
  sc_out<sc_bv<kVector> > io_read_6_data;
  sc_in<bool> io_write_0_valid;
  sc_in<bool> io_write_1_valid;
  sc_in<sc_bv<6> > io_write_0_addr;
  sc_in<sc_bv<6> > io_write_1_addr;
  sc_in<sc_bv<kVector> > io_write_0_data;
  sc_in<sc_bv<kVector> > io_write_1_data;
  sc_in<bool> io_whint_0_valid;
  sc_in<bool> io_whint_1_valid;
  sc_in<sc_bv<6> > io_whint_0_addr;
  sc_in<sc_bv<6> > io_whint_1_addr;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // Generate.
    const bool valid = rand_int(0, 63);
    const uint8_t f2 = rand_int(0, 7);
    const uint8_t sz = 1u << rand_int(0, 2);
    const uint8_t vd_addr = rand_int(0, 63);
    const uint8_t ve_addr = rand_int(0, 63);
    uint32_t sv_data = 0;

    uint8_t op = rand_int(0, encode::kOpEntries - 1);

    // Inputs.
    valu_t r = {0};
    r_.read(r);

    if (op == encode::vdwconv) {
      // Disallow DW in CRT.
      op = 0;
    }

    io_in_valid = valid;
    io_in_op = op;
    io_in_f2 = f2;
    io_in_sz = sz;
    io_in_vd_addr = vd_addr;
    io_in_ve_addr = ve_addr;
    io_in_sv_data = sv_data;

    sc_bv<kVector> rbits[7];
    for (int i = 0; i < 7; ++i) {
      for (int j = 0; j < kLanes; ++j) {
        rbits[i].set_word(j, r.in[i].data[j]);
      }
    }

    io_read_0_data = rbits[0];
    io_read_1_data = rbits[1];
    io_read_2_data = rbits[2];
    io_read_3_data = rbits[3];
    io_read_4_data = rbits[4];
    io_read_5_data = rbits[5];
    io_read_6_data = rbits[6];

    if (valid) {
      valu_t in = {op, f2, sz};
      for (int i = 0; i < 7; ++i) {
        for (int j = 0; j < kLanes; ++j) {
          in.in[i].data[j] = rand_int(0, 9) ? rand_uint32()
                                            : rand_int(-33, 33);  // shift range
        }
      }
      in.sv.data = sv_data;
      in.w[0].addr = vd_addr;
      in.w[1].addr = ve_addr;
      VAlu(in);
      r_.write(in);
      if (in.w[0].valid || in.w[1].valid) {
        w_.write(in);
      }
    }

    // Outputs.
    if (io_write_0_valid || io_write_1_valid) {
      valu_t ref, dut;
      check(w_.read(ref), "op read");
      dut = ref;
      dut.w[0].valid = io_write_0_valid;
      dut.w[1].valid = io_write_1_valid;
      dut.w[0].addr = io_write_0_addr.read().get_word(0);
      dut.w[1].addr = io_write_1_addr.read().get_word(0);
      for (int i = 0; i < kLanes; ++i) {
        dut.out[0].data[i] = io_write_0_data.read().get_word(i);
        dut.out[1].data[i] = io_write_1_data.read().get_word(i);
      }

      if (ref != dut) {
        ref.print("ref");
        dut.print("dut", true);
        check(false);
      }

      for (int i = 0; i < 2; ++i) {
        if (dut.w[i].valid) {
          if (dut.w[i].valid != whint_[i].valid ||
              dut.w[i].addr != whint_[i].addr) {
            printf("whint(%d) %d,%d : %d,%d\n", i,
                dut.w[i].valid, dut.w[i].addr, whint_[i].valid, whint_[i].addr);
            check(false);
          }
        }
      }
    }

    whint_[0].valid = io_whint_0_valid;
    whint_[1].valid = io_whint_1_valid;
    whint_[0].addr = io_whint_0_addr.read().get_word(0);
    whint_[1].addr = io_whint_1_addr.read().get_word(0);
  }

 private:
  fifo_t<valu_t> r_;
  fifo_t<valu_t> w_;
  struct whint_t {
    bool valid;
    uint8_t addr:6;
  } whint_[2];
};

static void VAluInt_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_in_valid;
  sc_signal<sc_bv<encode::kOpBits> > io_in_op;
  sc_signal<sc_bv<3> > io_in_f2;
  sc_signal<sc_bv<3> > io_in_sz;
  sc_signal<sc_bv<6> > io_in_vd_addr;
  sc_signal<sc_bv<6> > io_in_ve_addr;
  sc_signal<sc_bv<32> > io_in_sv_data;
  sc_signal<sc_bv<kVector> > io_read_0_data;
  sc_signal<sc_bv<kVector> > io_read_1_data;
  sc_signal<sc_bv<kVector> > io_read_2_data;
  sc_signal<sc_bv<kVector> > io_read_3_data;
  sc_signal<sc_bv<kVector> > io_read_4_data;
  sc_signal<sc_bv<kVector> > io_read_5_data;
  sc_signal<sc_bv<kVector> > io_read_6_data;
  sc_signal<bool> io_write_0_valid;
  sc_signal<bool> io_write_1_valid;
  sc_signal<sc_bv<6> > io_write_0_addr;
  sc_signal<sc_bv<6> > io_write_1_addr;
  sc_signal<sc_bv<kVector> > io_write_0_data;
  sc_signal<sc_bv<kVector> > io_write_1_data;
  sc_signal<bool> io_whint_0_valid;
  sc_signal<bool> io_whint_1_valid;
  sc_signal<sc_bv<6> > io_whint_0_addr;
  sc_signal<sc_bv<6> > io_whint_1_addr;

  VAluInt_tb tb("VAluInt_tb", loops);
  VVAluInt valuint(name);

  if (trace) {
    tb.trace(&valuint);
  }

  valuint.clock(tb.clock);
  valuint.reset(tb.reset);
  BIND2(tb, valuint, io_in_valid);
  BIND2(tb, valuint, io_in_op);
  BIND2(tb, valuint, io_in_f2);
  BIND2(tb, valuint, io_in_sz);
  BIND2(tb, valuint, io_in_vd_addr);
  BIND2(tb, valuint, io_in_ve_addr);
  BIND2(tb, valuint, io_in_sv_data);
  BIND2(tb, valuint, io_read_0_data);
  BIND2(tb, valuint, io_read_1_data);
  BIND2(tb, valuint, io_read_2_data);
  BIND2(tb, valuint, io_read_3_data);
  BIND2(tb, valuint, io_read_4_data);
  BIND2(tb, valuint, io_read_5_data);
  BIND2(tb, valuint, io_read_6_data);
  BIND2(tb, valuint, io_write_0_valid);
  BIND2(tb, valuint, io_write_1_valid);
  BIND2(tb, valuint, io_write_0_addr);
  BIND2(tb, valuint, io_write_1_addr);
  BIND2(tb, valuint, io_write_0_data);
  BIND2(tb, valuint, io_write_1_data);
  BIND2(tb, valuint, io_whint_0_valid);
  BIND2(tb, valuint, io_whint_1_valid);
  BIND2(tb, valuint, io_whint_0_addr);
  BIND2(tb, valuint, io_whint_1_addr);

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VAluInt_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
