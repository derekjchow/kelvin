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

#include "VVDecodeInstruction.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/coralnpu/vdecode.h"

struct VDecodeInstruction_tb : Sysc_tb {
  sc_out<sc_bv<32> > io_in_inst;
  sc_out<sc_bv<32> > io_in_addr;
  sc_out<sc_bv<32> > io_in_data;
  sc_in<bool> io_undef;
  sc_in<sc_bv<7> > io_out_op;
  sc_in<sc_bv<3> > io_out_f2;
  sc_in<sc_bv<3> > io_out_sz;
  sc_in<bool> io_out_m;
  sc_in<bool> io_out_cmdsync;
  sc_in<bool> io_out_vd_valid;
  sc_in<bool> io_out_ve_valid;
  sc_in<bool> io_out_vf_valid;
  sc_in<bool> io_out_vg_valid;
  sc_in<bool> io_out_vs_valid;
  sc_in<bool> io_out_vt_valid;
  sc_in<bool> io_out_vu_valid;
  sc_in<bool> io_out_vx_valid;
  sc_in<bool> io_out_vy_valid;
  sc_in<bool> io_out_vz_valid;
  sc_in<bool> io_out_sv_valid;
  sc_in<sc_bv<6> > io_out_vd_addr;
  sc_in<sc_bv<6> > io_out_ve_addr;
  sc_in<sc_bv<6> > io_out_vf_addr;
  sc_in<sc_bv<6> > io_out_vg_addr;
  sc_in<sc_bv<6> > io_out_vs_addr;
  sc_in<sc_bv<6> > io_out_vt_addr;
  sc_in<sc_bv<6> > io_out_vu_addr;
  sc_in<sc_bv<6> > io_out_vx_addr;
  sc_in<sc_bv<6> > io_out_vy_addr;
  sc_in<sc_bv<6> > io_out_vz_addr;
  sc_in<sc_bv<4> > io_out_vs_tag;
  sc_in<sc_bv<4> > io_out_vt_tag;
  sc_in<sc_bv<4> > io_out_vu_tag;
  sc_in<sc_bv<4> > io_out_vx_tag;
  sc_in<sc_bv<4> > io_out_vy_tag;
  sc_in<sc_bv<4> > io_out_vz_tag;
  sc_in<sc_bv<32> > io_out_sv_addr;
  sc_in<sc_bv<32> > io_out_sv_data;
  sc_in<bool> io_cmdq_alu;
  sc_in<bool> io_cmdq_conv;
  sc_in<bool> io_cmdq_ldst;
  sc_in<bool> io_cmdq_ld;
  sc_in<bool> io_cmdq_st;
  sc_in<sc_bv<64> > io_actv_ractive;
  sc_in<sc_bv<64> > io_actv_wactive;

  using Sysc_tb::Sysc_tb;

  void init() {
    const uint32_t inst = 0x13;  // nop
    const uint32_t addr = 0;
    const uint32_t data = 0;
    io_in_inst = inst;
    io_in_addr = addr;
    io_in_data = data;
    inst_.write({inst, addr, data, 0});
  }

  void posedge() {
    // Inputs.
    uint32_t inst = rand_uint32();
    uint32_t addr = rand_uint32();
    uint32_t data = rand_uint32();

    uint32_t index = rand_uint32(0, range_ - 1);
    if (index) {
      inst = op_[index].match;

      // Randomize the fields.
      uint32_t size = rand_int(0, 2) << 12;
      uint32_t m = rand_int(0, 1) << 5;
      uint32_t x = rand_int(0, 1) << 1;
      inst |= size | m | x;
      if (op_[index].rand) {
        inst |= op_[index].rand(rand_uint32());
      }
    }

    io_in_inst = inst;
    io_in_addr = addr;
    io_in_data = data;

    inst_.write({inst, addr, data, index});

    // Outputs.
    vdecode_in_t ref_in;
    vdecode_out_t ref, dut;

    dut.op = io_out_op.read().get_word(0);
    dut.f2 = io_out_f2.read().get_word(0);
    dut.sz = io_out_sz.read().get_word(0);
    dut.m = io_out_m;
    dut.cmdsync = io_out_cmdsync;
    dut.vd.valid = io_out_vd_valid;
    dut.ve.valid = io_out_ve_valid;
    dut.vf.valid = io_out_vf_valid;
    dut.vg.valid = io_out_vg_valid;
    dut.vs.valid = io_out_vs_valid;
    dut.vt.valid = io_out_vt_valid;
    dut.vu.valid = io_out_vu_valid;
    dut.vx.valid = io_out_vx_valid;
    dut.vy.valid = io_out_vy_valid;
    dut.vz.valid = io_out_vz_valid;
    dut.sv.valid = io_out_sv_valid;
    dut.vd.addr = io_out_vd_addr.read().get_word(0);
    dut.ve.addr = io_out_ve_addr.read().get_word(0);
    dut.vf.addr = io_out_vf_addr.read().get_word(0);
    dut.vg.addr = io_out_vg_addr.read().get_word(0);
    dut.vs.addr = io_out_vs_addr.read().get_word(0);
    dut.vt.addr = io_out_vt_addr.read().get_word(0);
    dut.vu.addr = io_out_vu_addr.read().get_word(0);
    dut.vx.addr = io_out_vx_addr.read().get_word(0);
    dut.vy.addr = io_out_vy_addr.read().get_word(0);
    dut.vz.addr = io_out_vz_addr.read().get_word(0);
    dut.vs.tag = io_out_vs_tag.read().get_word(0);
    dut.vt.tag = io_out_vt_tag.read().get_word(0);
    dut.vu.tag = io_out_vu_tag.read().get_word(0);
    dut.vx.tag = io_out_vx_tag.read().get_word(0);
    dut.vy.tag = io_out_vy_tag.read().get_word(0);
    dut.vz.tag = io_out_vz_tag.read().get_word(0);
    dut.sv.addr = io_out_sv_addr.read().get_word(0);
    dut.sv.data = io_out_sv_data.read().get_word(0);
    dut.cmdq.alu = io_cmdq_alu;
    dut.cmdq.conv = io_cmdq_conv;
    dut.cmdq.ldst = io_cmdq_ldst;
    dut.cmdq.ld = io_cmdq_ld;
    dut.cmdq.st = io_cmdq_st;
    dut.ractive = io_actv_ractive.read().get_word(0) |
                  (uint64_t(io_actv_ractive.read().get_word(1)) << 32);
    dut.wactive = io_actv_wactive.read().get_word(0) |
                  (uint64_t(io_actv_wactive.read().get_word(1)) << 32);

    check(inst_.read(ref_in), "instruction fifo is empty");

    memset(&ref, 0, sizeof(vdecode_out_t));
    if (!ref_in.op || !VDecode(ref_in.op, ref_in, ref)) {
      for (int i = kOpStart; i < kOpStop; ++i) {
        if (VDecode(i, ref_in, ref)) {
          break;
        }
      }
    }

    if (ref != dut) {
      printf("Error::Inst op=%d:%d inst=%08x addr=%08x data=%08x  \"%s\"\n",
             ref_in.op, dut.op, ref_in.inst, ref_in.addr, ref_in.data,
             InstStr(ref_in.inst).c_str());
      Print(ref, dut);
      check(false, "vdecodeinstruction mismatch");
    }
  }

 private:
  const int range_ = sizeof(op_) / sizeof(op_[0]);
  fifo_t<vdecode_in_t> inst_;
};

static void VDecodeInstruction_test(char* name, int loops, bool trace) {
  sc_signal<sc_bv<32> > io_in_inst;
  sc_signal<sc_bv<32> > io_in_addr;
  sc_signal<sc_bv<32> > io_in_data;
  sc_signal<bool> io_undef;
  sc_signal<sc_bv<7> > io_out_op;
  sc_signal<sc_bv<3> > io_out_f2;
  sc_signal<sc_bv<3> > io_out_sz;
  sc_signal<bool> io_out_m;
  sc_signal<bool> io_out_cmdsync;
  sc_signal<bool> io_out_vd_valid;
  sc_signal<bool> io_out_ve_valid;
  sc_signal<bool> io_out_vf_valid;
  sc_signal<bool> io_out_vg_valid;
  sc_signal<bool> io_out_vs_valid;
  sc_signal<bool> io_out_vt_valid;
  sc_signal<bool> io_out_vu_valid;
  sc_signal<bool> io_out_vx_valid;
  sc_signal<bool> io_out_vy_valid;
  sc_signal<bool> io_out_vz_valid;
  sc_signal<bool> io_out_sv_valid;
  sc_signal<sc_bv<6> > io_out_vd_addr;
  sc_signal<sc_bv<6> > io_out_ve_addr;
  sc_signal<sc_bv<6> > io_out_vf_addr;
  sc_signal<sc_bv<6> > io_out_vg_addr;
  sc_signal<sc_bv<6> > io_out_vs_addr;
  sc_signal<sc_bv<6> > io_out_vt_addr;
  sc_signal<sc_bv<6> > io_out_vu_addr;
  sc_signal<sc_bv<6> > io_out_vx_addr;
  sc_signal<sc_bv<6> > io_out_vy_addr;
  sc_signal<sc_bv<6> > io_out_vz_addr;
  sc_signal<sc_bv<4> > io_out_vs_tag;
  sc_signal<sc_bv<4> > io_out_vt_tag;
  sc_signal<sc_bv<4> > io_out_vu_tag;
  sc_signal<sc_bv<4> > io_out_vx_tag;
  sc_signal<sc_bv<4> > io_out_vy_tag;
  sc_signal<sc_bv<4> > io_out_vz_tag;
  sc_signal<sc_bv<32> > io_out_sv_addr;
  sc_signal<sc_bv<32> > io_out_sv_data;
  sc_signal<bool> io_cmdq_alu;
  sc_signal<bool> io_cmdq_conv;
  sc_signal<bool> io_cmdq_ldst;
  sc_signal<bool> io_cmdq_ld;
  sc_signal<bool> io_cmdq_st;
  sc_signal<sc_bv<64> > io_actv_ractive;
  sc_signal<sc_bv<64> > io_actv_wactive;

  VDecodeInstruction_tb tb("VDecodeInstruction_tb", loops, true);
  VVDecodeInstruction d(name);

  d.clock(tb.clock);
  d.reset(tb.reset);

  BIND2(tb, d, io_in_inst);
  BIND2(tb, d, io_in_addr);
  BIND2(tb, d, io_in_data);
  BIND2(tb, d, io_undef);
  BIND2(tb, d, io_out_op);
  BIND2(tb, d, io_out_f2);
  BIND2(tb, d, io_out_sz);
  BIND2(tb, d, io_out_m);
  BIND2(tb, d, io_out_cmdsync);
  BIND2(tb, d, io_out_vd_valid);
  BIND2(tb, d, io_out_ve_valid);
  BIND2(tb, d, io_out_vf_valid);
  BIND2(tb, d, io_out_vg_valid);
  BIND2(tb, d, io_out_vs_valid);
  BIND2(tb, d, io_out_vt_valid);
  BIND2(tb, d, io_out_vu_valid);
  BIND2(tb, d, io_out_vx_valid);
  BIND2(tb, d, io_out_vy_valid);
  BIND2(tb, d, io_out_vz_valid);
  BIND2(tb, d, io_out_sv_valid);
  BIND2(tb, d, io_out_vd_addr);
  BIND2(tb, d, io_out_ve_addr);
  BIND2(tb, d, io_out_vf_addr);
  BIND2(tb, d, io_out_vg_addr);
  BIND2(tb, d, io_out_vs_addr);
  BIND2(tb, d, io_out_vt_addr);
  BIND2(tb, d, io_out_vu_addr);
  BIND2(tb, d, io_out_vx_addr);
  BIND2(tb, d, io_out_vy_addr);
  BIND2(tb, d, io_out_vz_addr);
  BIND2(tb, d, io_out_vs_tag);
  BIND2(tb, d, io_out_vt_tag);
  BIND2(tb, d, io_out_vu_tag);
  BIND2(tb, d, io_out_vx_tag);
  BIND2(tb, d, io_out_vy_tag);
  BIND2(tb, d, io_out_vz_tag);
  BIND2(tb, d, io_out_sv_addr);
  BIND2(tb, d, io_out_sv_data);
  BIND2(tb, d, io_cmdq_alu);
  BIND2(tb, d, io_cmdq_conv);
  BIND2(tb, d, io_cmdq_ldst);
  BIND2(tb, d, io_cmdq_ld);
  BIND2(tb, d, io_cmdq_st);
  BIND2(tb, d, io_actv_ractive);
  BIND2(tb, d, io_actv_wactive);

  if (trace) {
    tb.trace(&d);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  VDecodeInstruction_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
