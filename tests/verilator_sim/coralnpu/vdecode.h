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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_VDECODE_H_
#define TESTS_VERILATOR_SIM_CORALNPU_VDECODE_H_

#include <stdint.h>

#include <string>

#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/coralnpu/vdecodeop.h"
#include "tests/verilator_sim/coralnpu/vencodeop.h"

// clang-format off
#define VDUP    "01000x_0xxxxx_000000_xx_xxxxxx_x_111_11"
#define VLDST   "xxxxxx_0xxxxx_xxxxx0_xx_xxxxxx_x_111_11"
#define VFMT0   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_000_x0"
#define VFMT1   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_001_x0"
#define VFMT2   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_010_x0"
#define VFMT3   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_011_x0"
#define VFMT4   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_100_x0"
#define VFMT6   "xxxxxx_xxxxxx_xxxxxx_xx_xxxxxx_x_110_x0"
#define ACONV   "xxxxxx_1xxxxx_xxxxxx_10_xxxxxx_0_00_101"
#define VDWCONV "xxxxxx_0xxxxx_xxxxxx_10_xxxxxx_x_10_101"
#define ADWCONV "xxxxxx_1xxxxx_xxxxxx_10_xxxxxx_x_10_101"
// clang-format on

namespace encode {

enum mask {
  vd = 0x3f << 6,
  vs = 0x3f << 14,
  vt = 0x3f << 20,
  vu = 0x3fu << 26,
  xs = 0x1f << 15,
  xt = 0x1f << 20,
  func2 = 0x3fu << 26,
};

};  // namespace encode

struct vdecode_in_t {
  uint32_t inst;
  uint32_t addr;
  uint32_t data;
  uint32_t op;

  uint8_t is_xx() const { return (inst & 3) == 3; }
  uint8_t is_vx() const { return (inst & 3) == 2; }
  uint8_t is_vv() const { return (inst & 3) == 0; }

  uint8_t func1() const { return (inst >> 2) & 0x7; }
  uint8_t func2() const { return (inst >> 26) & 0x3f; }

  uint8_t size() const { return (inst >> 12) & 0x3; }
  uint8_t sz() const { return 1 << size(); }
  uint8_t f2() const { return func2() & 7; }
  uint8_t m() const { return (inst >> 5) & 0x1; }
  uint8_t xt() const { return (inst >> 1) & 1; }

  uint8_t pair() const { return m() && xt(); }

  uint8_t vd() const { return (inst >> 6) & 0x3f; }
  uint8_t ve() const { return (m() ? vd() + 4 : vd() + 1) & 0x3f; }
  uint8_t vs() const { return (inst >> 14) & 0x3f; }
  uint8_t vs2() const { return (m() ? vs() + 4 : vs() + 1) & 0x3f; }
  uint8_t vt() const { return (inst >> 20) & 0x3f; }
  uint8_t vu() const { return (inst >> 26) & 0x3f; }

  uint32_t saddr() const { return addr; }

  uint32_t sdata() const {
    uint32_t s8 = data & 0xff;
    uint32_t s16 = data & 0xffff;
    uint32_t s32 = data;
    switch (sz()) {
      case 1:
        return s8 | (s8 << 8) | (s8 << 16) | (s8 << 24);
      case 2:
        return s16 | (s16 << 16);
      case 4:
        return s32;
    }
    return 0;
  }

  uint32_t sdataw() const {
    uint32_t s8 = data & 0xff;
    uint32_t s16 = data & 0xffff;
    switch (sz()) {
      case 2:
        return s8 | (s8 << 8) | (s8 << 16) | (s8 << 24);
      case 4:
        return s16 | (s16 << 16);
    }
    return 0;
  }
};

struct vdecode_out_t {
  uint32_t inst;
  uint32_t addr;
  uint32_t data;

  uint32_t op;
  uint8_t f2 : 3;
  uint8_t sz : 3;
  bool m;
  bool cmdsync;

  uint64_t ractive;
  uint64_t wactive;

  uint64_t vrfsbset[2];  // do not check

  struct vdecode_dst_addr_t {
    bool valid;
    uint32_t addr : 6;
  } vd, ve, vf, vg;

  struct vdecode_src_addr_t {
    bool valid;
    uint32_t addr : 6;
    uint32_t tag : 4;
  } vs, vt, vu, vx, vy, vz;

  struct vdecode_scalar_t {
    bool valid;
    uint32_t addr;
    uint32_t data;
  } sv;

  struct vdecode_cmdq_t {
    bool alu;
    bool conv;
    bool ldst;
    bool ld;
    bool st;
  } cmdq;

  bool operator==(const vdecode_out_t& rhs) const {
    if (op == 0 && rhs.op == 0) {
      return true;
    }

    if (op != rhs.op) return false;

    if (f2 != rhs.f2) return false;

    if (m != rhs.m) return false;

    if (cmdsync != rhs.cmdsync) return false;

    if (vd.valid != rhs.vd.valid) return false;
    if (ve.valid != rhs.ve.valid) return false;
    if (vf.valid != rhs.vf.valid) return false;
    if (vg.valid != rhs.vg.valid) return false;
    if (vs.valid != rhs.vs.valid) return false;
    if (vt.valid != rhs.vt.valid) return false;
    if (vu.valid != rhs.vu.valid) return false;
    if (vx.valid != rhs.vx.valid) return false;
    if (vy.valid != rhs.vy.valid) return false;
    if (vz.valid != rhs.vz.valid) return false;
    if (sv.valid != rhs.sv.valid) return false;

    if (vd.valid && vd.addr != rhs.vd.addr) return false;
    if (ve.valid && ve.addr != rhs.ve.addr) return false;
    if (vf.valid && vf.addr != rhs.vf.addr) return false;
    if (vg.valid && vg.addr != rhs.vg.addr) return false;
    if (vs.valid && vs.addr != rhs.vs.addr) return false;
    if (vt.valid && vt.addr != rhs.vt.addr) return false;
    if (vu.valid && vu.addr != rhs.vu.addr) return false;
    if (vx.valid && vx.addr != rhs.vx.addr) return false;
    if (vy.valid && vy.addr != rhs.vy.addr) return false;
    if (vz.valid && vz.addr != rhs.vz.addr) return false;

    if (vs.valid && vs.tag != rhs.vs.tag) return false;
    if (vt.valid && vt.tag != rhs.vt.tag) return false;
    if (vu.valid && vu.tag != rhs.vu.tag) return false;
    if (vx.valid && vx.tag != rhs.vx.tag) return false;
    if (vy.valid && vy.tag != rhs.vy.tag) return false;
    if (vz.valid && vz.tag != rhs.vz.tag) return false;

    if (sv.valid && sv.addr != rhs.sv.addr) return false;
    if (sv.valid && sv.data != rhs.sv.data) return false;

    if (cmdq.alu != rhs.cmdq.alu) return false;
    if (cmdq.conv != rhs.cmdq.conv) return false;
    if (cmdq.ldst != rhs.cmdq.ldst) return false;
    if (cmdq.ld != rhs.cmdq.ld) return false;
    if (cmdq.st != rhs.cmdq.st) return false;

    if (ractive != rhs.ractive) return false;
    if (wactive != rhs.wactive) return false;

    // Do not test these, if relevant a testbench will group and test.
    //  if (vrfsbset[0] != rhs.vrfsbset[0]) return false;
    //  if (vrfsbset[1] != rhs.vrfsbset[1]) return false;

    return true;
  }

  bool operator!=(const vdecode_out_t& rhs) const { return !(*this == rhs); }
};

struct vencode_inst_t {
  // Decode the instruction, or leave output unmodified.
  void (*decode)(const vdecode_in_t& in, vdecode_out_t& out);

  // Instruction match and mask.
  uint32_t match;
  uint32_t mask;

  // {optional} Add additional random state with testbench random bits.
  uint32_t (*rand)(uint32_t v) = nullptr;
};

static void Print(const vdecode_out_t& a, const vdecode_out_t& b) {
#define printInt(t, f) \
  if (a.f != b.f) printf("  %s %d  %d\n", t, a.f, b.f)
#define printH32(t, f) \
  if (a.f != b.f) printf("  %s %08x  %08x\n", t, a.f, b.f)
#define printH64(t, f) \
  if (a.f != b.f) printf("  %s %016lx  %016lx\n", t, a.f, b.f)

  printInt("op          ", op);
  printInt("f2          ", f2);
  printInt("sz          ", sz);
  printInt("m           ", m);
  printInt("cmdsync     ", cmdsync);

  printInt("vd.valid    ", vd.valid);
  printInt("ve.valid    ", ve.valid);
  printInt("vf.valid    ", vf.valid);
  printInt("vg.valid    ", vg.valid);
  printInt("vs.valid    ", vs.valid);
  printInt("vt.valid    ", vt.valid);
  printInt("vu.valid    ", vu.valid);
  printInt("vx.valid    ", vx.valid);
  printInt("vy.valid    ", vy.valid);
  printInt("vz.valid    ", vz.valid);
  printInt("sv.valid    ", sv.valid);

  if (a.vd.valid) printInt("vd.addr     ", vd.addr);
  if (a.ve.valid) printInt("ve.addr     ", ve.addr);
  if (a.vf.valid) printInt("vf.addr     ", vf.addr);
  if (a.vg.valid) printInt("vg.addr     ", vg.addr);
  if (a.vs.valid) printInt("vs.addr     ", vs.addr);
  if (a.vt.valid) printInt("vt.addr     ", vt.addr);
  if (a.vu.valid) printInt("vu.addr     ", vu.addr);
  if (a.vx.valid) printInt("vx.addr     ", vx.addr);
  if (a.vy.valid) printInt("vy.addr     ", vy.addr);
  if (a.vz.valid) printInt("vz.addr     ", vz.addr);

  if (a.vs.valid) printInt("vs.tag      ", vs.tag);
  if (a.vt.valid) printInt("vt.tag      ", vt.tag);
  if (a.vu.valid) printInt("vu.tag      ", vu.tag);
  if (a.vx.valid) printInt("vx.tag      ", vx.tag);
  if (a.vy.valid) printInt("vy.tag      ", vy.tag);
  if (a.vz.valid) printInt("vz.tag      ", vz.tag);

  if (a.sv.valid) printH32("sv.addr     ", sv.addr);
  if (a.sv.valid) printH32("sv.data     ", sv.data);

  printInt("cmdq.alu    ", cmdq.alu);
  printInt("cmdq.conv   ", cmdq.conv);
  printInt("cmdq.ldst   ", cmdq.ldst);
  printInt("cmdq.ld     ", cmdq.ld);
  printInt("cmdq.st     ", cmdq.st);

  printH64("ractive     ", ractive);
  printH64("wactive     ", wactive);
}

static const std::string InstStr(const uint32_t inst) {
  std::string s;
  s.clear();
  bool vvv = (inst & 3) == 1;
  for (int i = 31; i >= 0; --i) {
    s += (inst >> i) & 1 ? '1' : '0';
    if (i == 26 || i == 20 || i == 14 || i == 12 || i == 6 || i == 5 ||
        (i == 3 && vvv) || (i == 2 && !vvv)) {
      s += '_';
    }
  }
  return s;
}

template <bool is_match>
static uint32_t MatchMask(const char* insn) {
  const int len = strlen(insn);
  uint32_t match = 0;
  uint32_t mask = 0;
  int p = 0;
  int i = 0;
  while (p < len && i < 32) {
    const char ch = insn[p];
    p++;
    if (ch == '_') continue;

    const uint32_t bit = 1u << (31 - i);
    switch (ch) {
      case 'x':
        break;
      case '1':
        match |= bit;
        // fall-through
      case '0':
        mask |= bit;
        break;
      default:
        printf("Error::Decode (%s)\n", insn);
        assert(false);
        break;
    }
    i++;
  }

  return is_match ? match : mask;
}

static uint32_t Match(const char* s) { return MatchMask<1>(s); }

static uint32_t Mask(const char* s) { return MatchMask<0>(s); }

static uint64_t Active(int v, bool m, bool active = true) {
  if (!active) return 0;
  if (m) return 15ull << (v & 0x3c);
  return 1ull << v;
}

static uint64_t Active2(int v, bool m, bool active = true) {
  uint64_t r = Active(v, m, active);
  r = m ? r << 4 : r << 1;
  return r;
}

static uint64_t Active3(int v, bool m, bool active = true) {
  uint64_t r = Active(v, m, active);
  r = m ? r << 8 : r << 2;
  return r;
}

static uint64_t Active4(int v, bool m, bool active = true) {
  uint64_t r = Active(v, m, active);
  r = m ? r << 12 : r << 3;
  return r;
}

static void DualIssue(const vdecode_in_t& in, vdecode_out_t& out) {
  const uint8_t vd = in.vd();
  const uint8_t vs = in.vs();
  assert(out.sv.valid);
  out.m = false;  // stripmine replaced by composite opcode
  out.cmdsync = true;
  out.vd.valid = true;
  out.ve.valid = true;
  out.vf.valid = true;
  out.vg.valid = true;
  out.vs.valid = true;
  out.vt.valid = false;
  out.vu.valid = true;
  out.vx.valid = true;
  out.vy.valid = false;
  out.vz.valid = true;
  out.vd.addr = vd;
  out.ve.addr = vd + 1;
  out.vf.addr = vd + 2;
  out.vg.addr = vd + 3;
  out.vs.addr = vs;
  out.vu.addr = vs + 1;
  out.vx.addr = vs + 2;
  out.vz.addr = vs + 3;
}

#define MM(op) Match(op), Mask(op)

static uint32_t rand_vdup(const uint32_t v) {
  uint8_t ft[] = {0, 1};
  uint32_t r = v & (encode::mask::xs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  r |= f;
  return r;
}

static uint32_t rand_vldst(const uint32_t v) {
  uint8_t ft[] = {0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 26, 30};
  uint32_t r = v & (encode::mask::xt | encode::mask::xs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  r |= f;
  return r;
}

static uint32_t rand_vfmt0(const uint32_t v) {
  uint8_t ft[] = {0, 1, 2, 4, 6, 7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  uint32_t u = ((v >> 8) & 1) << 26;
  r |= f;
  r |= u;
  return r;
}

static uint32_t rand_vfmt1(const uint32_t v) {
  uint8_t ft[] = {0, 1, 2, 3, 4, 5, 8, 9, 10, 12, 13, 16, 17, 18};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  r |= f;
  return r;
}

static uint32_t rand_vfmt2(const uint32_t v) {
  uint8_t ft[] = {1, 2, 3, 8, 9, 16, 24};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  r |= f;
  return r;
}

static uint32_t rand_vfmt3(const uint32_t v) {
  uint8_t ft[] = {0, 2, 4, 8, 9, 16, 20, 20, 21};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  uint32_t u = ((v >> 8) & 1) << 26;
  uint32_t d = ((v >> 9) & 1) << 27;
  r |= f | u | d;
  return r;
}

static uint32_t rand_vfmt4(const uint32_t v) {
  uint8_t ft[] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 20, 24};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  uint32_t u = ((v >> 8) & 1) << 26;
  uint32_t d = ((v >> 9) & 3) << 27;
  r |= f | u | d;
  return r;
}

static uint32_t rand_vfmt6(const uint32_t v) {
  uint8_t ft[] = {0, 4, 8, 12, 16, 20, 24, 25, 26, 28};
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd);
  uint32_t f = ft[v % sizeof(ft)] << 26;
  uint32_t nn = ((v >> 8) & 3) << 26;
  r |= f | nn;
  return r;
}

static uint32_t rand_vfmtv(const uint32_t v) {
  uint32_t r = v & (encode::mask::vt | encode::mask::vs | encode::mask::vd |
                    encode::mask::vd);
  return r;
}

static void undef(const vdecode_in_t& in, vdecode_out_t& out) {}

static void vdup(const vdecode_in_t& in, vdecode_out_t& out) {
  switch (in.func2()) {
    case decode::vdup | 0:
    case decode::vdup | 1:
      break;
    default:
      return;
  }

  out.op = encode::vdup;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.vd.addr = in.vd();
  out.sv.valid = true;
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.wactive = Active(in.vd(), in.m());
}

static void vldst(const vdecode_in_t& in, vdecode_out_t& out) {
  bool vld = false;
  bool vst = false;
  switch (in.func2()) {
    case decode::vld | decode::psL:
    case decode::vld | decode::pSl:
    case decode::vld | decode::Psl:
    case decode::vld | decode::PsL:
    case decode::vld | decode::PSl:
    case decode::vld | decode::PSL:
    case decode::vld:
      vld = true;
      out.op = encode::vld;
      out.vd.valid = true;
      out.vd.addr = in.vd();
      break;
    case decode::vst | decode::psL:
    case decode::vst | decode::pSl:
    case decode::vst | decode::Psl:
    case decode::vst | decode::PsL:
    case decode::vst | decode::PSl:
    case decode::vst | decode::PSL:
    case decode::vst:
      vst = true;
      out.op = encode::vst;
      out.vs.valid = true;
      out.vs.addr = in.vd();
      break;
    case decode::vstq | 2:
    case decode::vstq | 6:
      vst = true;
      out.op = encode::vstq;
      out.vs.valid = true;
      out.vs.addr = in.vd();
      break;
    default:
      return;
  }

  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.sv.addr = in.saddr();
  out.sv.data = in.data;
  out.cmdq.ldst = true;
  out.cmdq.ld = false;
  out.cmdq.st = false;
  out.ractive = Active(in.vd(), in.m(), vst);
  out.wactive = Active(in.vd(), in.m(), vld);
}

static void vfmt0(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vadd:  op = encode::vadd;  break;
    case decode::vsub:  op = encode::vsub;  break;
    case decode::vrsub: op = encode::vrsub; break;
    case decode::veq:   op = encode::veq;   break;
    case decode::vne:   op = encode::vne;   break;
    case decode::vlt | decode::u:
    case decode::vlt:   op = encode::vlt;   break;
    case decode::vle | decode::u:
    case decode::vle:   op = encode::vle;   break;
    case decode::vgt | decode::u:
    case decode::vgt:   op = encode::vgt;   break;
    case decode::vge | decode::u:
    case decode::vge:   op = encode::vge;   break;
    case decode::vabsd | decode::u:
    case decode::vabsd: op = encode::vabsd; break;
    case decode::vmax | decode::u:
    case decode::vmax:  op = encode::vmax;  break;
    case decode::vmin | decode::u:
    case decode::vmin:  op = encode::vmin;  break;
    case decode::vadd3: op = encode::vadd3; break;
    default: return;
  }
  // clang-format on

  bool vadd3 = op == encode::vadd3;

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.vu.valid = vadd3;
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.vs.addr = in.vs();
  out.vt.addr = in.vt();
  out.vu.addr = in.vd();
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt());
  out.wactive = Active(in.vd(), in.m());
}

static void vfmt1(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vand:  op = encode::vand;  break;
    case decode::vor:   op = encode::vor;   break;
    case decode::vxor:  op = encode::vxor;  break;
    case decode::vnot:  op = encode::vnot;  break;
    case decode::vrev:  op = encode::vrev;  break;
    case decode::vror:  op = encode::vror;  break;
    case decode::vclb:  op = encode::vclb;  break;
    case decode::vclz:  op = encode::vclz;  break;
    case decode::vcpop: op = encode::vcpop; break;
    case decode::vmv:   op = encode::vmv;   break;
    case decode::vmvp:  op = encode::vmvp;  break;
    case decode::acset: {
      if (!in.xt() || in.m() || in.vt() != 0) return;
      op = encode::acset;
      }
      break;
    case decode::actr:  {
      if (!in.xt() || in.m() || in.vt() != 0) return;
      op = encode::actr;
      }
      break;
    case decode::adwinit: op = encode::adwinit; break;
    default: return;
  }
  // clang-format on

  if (op == encode::vmv && in.pair()) {
    op = encode::vmv2;
  }

  bool vmv2 = op == encode::vmv2;
  bool vmvp = op == encode::vmvp;
  bool acset = op == encode::acset;
  bool actr = op == encode::actr;
  bool adwinit = op == encode::adwinit;

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.vs.addr = in.vs();
  out.vt.addr = in.vt();
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt());
  out.wactive = Active(in.vd(), in.m());

  if (vmv2) {
    DualIssue(in, out);
  }

  if (vmvp) {
    out.ve.valid = vmvp;
    out.ve.addr = in.ve();
    out.wactive |= Active2(in.vd(), in.m());
  }

  if (acset) {
    constexpr uint64_t mask = kVector == 128   ? 0xfull
                              : kVector == 256 ? 0xffull
                                               : 0xffffull;
    constexpr uint8_t rsel = kVector == 128   ? 0x3c
                             : kVector == 256 ? 0x38
                                              : 0x30;

    out.ractive |= (mask << (in.vs() & rsel));

    out.vd.valid = false;
    out.vd.valid = false;
    out.vs.valid = false;
    out.sv.valid = false;
    out.cmdq.conv = true;
    out.cmdq.alu = false;
    out.ractive = (mask << (in.vs() & rsel));
    out.wactive = 0;
  }

  if (actr) {
    constexpr uint64_t mask = kVector == 128   ? 0xfull
                              : kVector == 256 ? 0xffull
                                               : 0xffffull;
    constexpr uint8_t rsel = 0x30;
    out.vd.valid = false;
    out.vs.valid = false;
    out.sv.valid = false;
    out.cmdq.conv = true;
    out.cmdq.alu = false;
    out.ractive = (mask << (in.vs() & rsel));
    out.wactive = 0;
  }

  if (adwinit) {
    const uint8_t vd = in.vd();
    const uint8_t vs = in.vs();
    out.cmdsync = true;
    out.vd.valid = false;
    out.ve.valid = false;
    out.vf.valid = false;
    out.vg.valid = false;
    out.vs.valid = true;
    out.vt.valid = true;
    out.vx.valid = true;
    out.vy.valid = true;
    out.sv.valid = false;
    out.vd.addr = vd;
    out.ve.addr = vd + 1;
    out.vf.addr = vd + 2;
    out.vg.addr = vd + 3;
    out.vs.addr = vs;
    out.vt.addr = vs + 1;
    out.vx.addr = vs + 2;
    out.vy.addr = vs + 3;
    out.ractive = Active(vs, true);
    out.wactive = 0;
  }
}

static void vfmt2(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vsll:  op = encode::vshl;   break;
    case decode::vsra:  op = encode::vshr;   break;
    case decode::vsrl:  op = encode::vshr;   break;
    case decode::vsha | decode::r:
    case decode::vsha: op = encode::vshf;   break;
    case decode::vshl | decode::r:
    case decode::vshl: op = encode::vshf;   break;
    case decode::vsrans | decode::r | decode::u:
    case decode::vsrans | decode::r:
    case decode::vsrans | decode::u:
    case decode::vsrans: op = encode::vsrans; break;
    case decode::vsraqs | decode::r | decode::u:
    case decode::vsraqs | decode::r:
    case decode::vsraqs | decode::u:
    case decode::vsraqs: op = encode::vsraqs; break;
    default: return;
  }
  // clang-format on

  bool vsrans = op == encode::vsrans;
  bool vsraqs = op == encode::vsraqs;

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.vu.valid = vsrans;
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.vs.addr = in.vs();
  out.vt.addr = in.vt();
  out.vu.addr = in.vs2();
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt()) |
                Active2(in.vs(), in.m(), out.vu.valid);
  out.wactive = Active(in.vd(), in.m());

  if (vsraqs) {
    const uint8_t vs = in.vs();
    const uint8_t vt = in.vt();
    const int m4 = in.m() ? 4 : 1;
    out.cmdsync = vsraqs;
    out.vs.valid = true;
    out.vt.valid = !in.xt();
    out.vu.valid = true;
    out.vx.valid = true;
    out.vy.valid = !in.xt();
    out.vz.valid = true;

    out.vs.addr = vs;
    out.vu.addr = vs + m4 * 1;
    out.vx.addr = vs + m4 * 2;
    out.vy.addr = vt;
    out.vz.addr = vs + m4 * 3;

    out.ractive = Active(in.vs(), in.m()) | Active2(in.vs(), in.m()) |
                  Active3(in.vs(), in.m()) | Active4(in.vs(), in.m()) |
                  Active(in.vt(), in.m(), !in.xt());
    out.wactive = Active(in.vd(), in.m());
  }
}

static void vfmt3(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vmul:   op = encode::vmul;   break;
    case decode::vmuls | decode::u:
    case decode::vmuls:  op = encode::vmuls;  break;
    case decode::vmulw | decode::u:
    case decode::vmulw:  op = encode::vmulw;  break;
    case decode::vmulh | decode::r:
    case decode::vmulh:  op = encode::vmulh;  break;
    case decode::vmulhu | decode::r:
    case decode::vmulhu: op = encode::vmulh; break;
    case decode::vdmulh | decode::r | decode::u:
    case decode::vdmulh | decode::r:
    case decode::vdmulh | decode::u:
    case decode::vdmulh: op = encode::vdmulh; break;
    case decode::vmacc:  op = encode::vmadd; break;
    case decode::vmadd:  op = encode::vmadd;  break;
    default: return;
  }
  // clang-format on

  if (in.pair()) {
    // clang-format off
    switch (op) {
      case encode::vdmulh: op = encode::vdmulh2; break;
      case encode::vmul:   op = encode::vmul2;   break;
      case encode::vmulh:  op = encode::vmulh2;  break;
      case encode::vmuls:  op = encode::vmuls2;  break;
    }
    // clang-format off
  }

  bool vmulw = op == encode::vmulw;
  bool vmacc = in.func2() == decode::vmacc;
  bool vmadd = op == encode::vmadd && !vmacc;
  bool vdmulh2 = op == encode::vdmulh2;
  bool vmul2 = op == encode::vmul2;
  bool vmulh2 = op == encode::vmulh2;
  bool vmuls2 = op == encode::vmuls2;

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.ve.valid = vmulw;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.vu.valid = vmacc || vmadd;
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.ve.addr = in.ve();
  out.vs.addr = vmadd ? in.vd() : in.vs();
  out.vt.addr = in.vt();
  out.vu.addr = vmadd ? in.vs() : in.vd();
  out.sv.addr = in.saddr();
  out.sv.data = vmulw ? in.sdataw() : in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt()) |
                Active(in.vd(), in.m(), vmacc || vmadd);
  out.wactive =
      Active(in.vd(), in.m()) | Active2(in.vd(), in.m(), out.ve.valid);

  if (vdmulh2 || vmul2 || vmulh2 || vmuls2) {
    DualIssue(in, out);
  }
}

static void vfmt4(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vadds | decode::u:
    case decode::vadds:  op = encode::vadds;  break;
    case decode::vsubs | decode::u:
    case decode::vsubs:  op = encode::vsubs;  break;
    case decode::vaddw | decode::u:
    case decode::vaddw:  op = encode::vaddw;  break;
    case decode::vsubw | decode::u:
    case decode::vsubw:  op = encode::vsubw;  break;
    case decode::vacc | decode::u:
    case decode::vacc: op = encode::vacc;   break;
    case decode::vpadd | decode::u:
    case decode::vpadd: op = encode::vpadd;  break;
    case decode::vpsub | decode::u:
    case decode::vpsub: op = encode::vpsub;  break;
    case decode::vhadd | decode::r | decode::u:
    case decode::vhadd | decode::r:
    case decode::vhadd | decode::u:
    case decode::vhadd: op = encode::vhadd;  break;
    case decode::vhsub | decode::r | decode::u:
    case decode::vhsub | decode::r:
    case decode::vhsub | decode::u:
    case decode::vhsub: op = encode::vhsub;  break;
    default: return;
  }
  // clang-format on

  bool vacc = op == encode::vacc;
  bool vaddw = op == encode::vaddw;
  bool vsubw = op == encode::vsubw;

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = true;
  out.ve.valid = vacc || vaddw || vsubw;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.vu.valid = vacc;
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.ve.addr = in.ve();
  out.vs.addr = in.vs();
  out.vt.addr = in.vt();
  out.vu.addr = vacc ? in.vs2() : in.vd();
  out.sv.addr = in.saddr();
  out.sv.data = vaddw || vsubw ? in.sdataw() : in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt());
  out.wactive =
      Active(in.vd(), in.m()) | Active2(in.vd(), in.m(), out.ve.valid);
}

static void vfmt6(const vdecode_in_t& in, vdecode_out_t& out) {
  uint32_t op;
  // clang-format off
  switch (in.func2()) {
    case decode::vslidevn | decode::n1:
    case decode::vslidevn | decode::n2:
    case decode::vslidevn | decode::n3:
    case decode::vslidevn | decode::n4: op = encode::vslidevn; break;
    case decode::vslidehn | decode::n1:
    case decode::vslidehn | decode::n2:
    case decode::vslidehn | decode::n3:
    case decode::vslidehn | decode::n4:
      op = !in.m() ? encode::vslidehn : encode::vslidehn2;
      break;
    case decode::vslidevp | decode::n1:
    case decode::vslidevp | decode::n2:
    case decode::vslidevp | decode::n3:
    case decode::vslidevp | decode::n4: op = encode::vslidevp; break;
    case decode::vslidehp | decode::n1:
    case decode::vslidehp | decode::n2:
    case decode::vslidehp | decode::n3:
    case decode::vslidehp | decode::n4:
      op = !in.m() ? encode::vslidehp : encode::vslidehp2;
      break;
    case decode::vsel: op = encode::vsel; break;
    case decode::vevn: op = encode::vevn;    break;
    case decode::vodd: op = encode::vodd;    break;
    case decode::vevnodd: op = encode::vevnodd; break;
    case decode::vzip: op = encode::vzip;    break;
    default: return;
  }
  // clang-format on

  bool vevnodd = op == encode::vevnodd;
  bool vzip = op == encode::vzip;
  bool vslidehn2 = op == encode::vslidehn2;
  bool vslidehp2 = op == encode::vslidehp2;
  bool vsel = op == encode::vsel;

  bool vevn3m = in.m() && (op == encode::vevn || op == encode::vevnodd ||
                           op == encode::vodd);

  out.op = op;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.cmdsync = false;
  out.vd.valid = true;
  out.ve.valid = vevnodd || vzip;
  out.vs.valid = true;
  out.vt.valid = !in.xt();
  out.vu.valid = vevn3m || vsel;
  out.sv.valid = in.xt();
  out.vd.addr = in.vd();
  out.ve.addr = in.ve();
  out.vs.addr = in.vs();
  out.vt.addr = vevn3m ? in.vs() + 1 : in.vt();
  out.vu.addr = vsel ? in.vd() : in.vt();
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(in.vs(), in.m()) | Active(in.vt(), in.m(), !in.xt());
  out.wactive =
      Active(in.vd(), in.m()) | Active2(in.vd(), in.m(), out.ve.valid);

  if (vslidehn2 || vslidehp2) {
    const uint8_t vd = in.vd();
    const uint8_t vs = in.vs();
    const uint8_t vt = in.vt();

    out.m = false;  // stripmine replaced by composite opcode
    out.cmdsync = true;
    out.vd.valid = true;
    out.ve.valid = true;
    out.vf.valid = true;
    out.vg.valid = true;
    out.vs.valid = true;
    out.vt.valid = !in.xt();
    out.vu.valid = true;
    out.vx.valid = true;
    out.vy.valid = true;
    out.vz.valid = true;
    out.vd.addr = vd;
    out.ve.addr = vd + 1;
    out.vf.addr = vd + 2;
    out.vg.addr = vd + 3;
    if (vslidehn2) {
      out.vs.addr = vs;
      out.vt.addr = vs + 1;
      out.vu.addr = vs + 2;
      out.vx.addr = vs + 2;
      out.vy.addr = vs + 3;
      out.vz.addr = vt;

      out.ractive = Active(out.vs.addr, false) | Active(out.vt.addr, false) |
                    Active(out.vu.addr, false) | Active(out.vx.addr, false) |
                    Active(out.vy.addr, false) |
                    Active(out.vz.addr, false, !in.xt());
    } else {
      out.vs.addr = vs + 3;
      out.vt.addr = vt;
      out.vu.addr = vt + 1;
      out.vx.addr = vt + 1;
      out.vy.addr = vt + 2;
      out.vz.addr = vt + 3;

      out.ractive = Active(out.vs.addr, false) |
                    Active(out.vt.addr, false, !in.xt()) |
                    Active(out.vu.addr, false, !in.xt()) |
                    Active(out.vx.addr, false, !in.xt()) |
                    Active(out.vy.addr, false, !in.xt()) |
                    Active(out.vz.addr, false, !in.xt());
    }

    out.wactive = Active(in.vd(), true);
  }

  if (vzip) {
    out.ve.addr = out.vd.addr + 1;
  }
}

static void aconv(const vdecode_in_t& in, vdecode_out_t& out) {
  const bool aconv = (in.inst & 7) == 5 && ((in.inst >> 25) & 1) == 1;
  assert(aconv);

  out.op = encode::aconv;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.vd.valid = false;
  out.vs.valid = aconv;
  out.vt.valid = false;
  out.vu.valid = aconv;
  out.sv.valid = false;
  out.vd.addr = in.vd();
  out.ve.addr = in.ve();
  out.vs.addr = in.vs();
  out.vt.addr = in.vt();
  out.vu.addr = in.vu();
  out.sv.data = in.sdata();
  out.cmdq.conv = true;

  constexpr uint64_t mask = kVector == 128   ? 0xfull
                            : kVector == 256 ? 0xffull
                                             : 0xffffull;
  constexpr uint8_t rsel1 = 0x30;
  constexpr uint8_t rsel2 = kVector == 128   ? 0x3c
                            : kVector == 256 ? 0x38
                                             : 0x30;

  out.ractive |= (mask << (in.vs() & rsel1));
  out.ractive |= (mask << (in.vu() & rsel2));

  out.wactive = 0;
}

static void vdwconv(const vdecode_in_t& in, vdecode_out_t& out) {
  uint8_t regbase = (in.data >> 4) & 15;
  uint8_t vstlb[] = {0, 1, 2, 3, 4, 5, 6, 1, 1, 3, 5, 7, 2, 4, 6, 8};
  uint8_t vttlb[] = {1, 2, 3, 4, 5, 6, 7, 0, 2, 4, 6, 8, 0, 0, 0, 0};
  uint8_t vutlb[] = {2, 3, 4, 5, 6, 7, 8, 2, 0, 0, 0, 0, 1, 1, 1, 1};
  uint8_t vs = (in.vs() + vstlb[regbase]) & 0x3f;
  uint8_t vt = (in.vs() + vttlb[regbase]) & 0x3f;
  uint8_t vu = (in.vs() + vutlb[regbase]) & 0x3f;
  uint8_t vd = in.vd();

  uint8_t vx = in.vu();
  uint8_t vy = (in.vu() + (in.m() ? 4 : 1)) & 0x3f;
  uint8_t vz = (in.vu() + (in.m() ? 8 : 2)) & 0x3f;

  bool vdwconv = !((in.inst >> 25) & 1);

  out.op = vdwconv ? encode::vdwconv : encode::adwconv;
  out.f2 = in.f2();
  out.sz = in.sz();
  out.m = in.m();
  out.cmdsync = true;
  out.vd.valid = vdwconv;
  out.ve.valid = vdwconv;
  out.vf.valid = vdwconv;
  out.vg.valid = vdwconv;
  out.vs.valid = true;
  out.vt.valid = true;
  out.vu.valid = true;
  out.vx.valid = true;
  out.vy.valid = true;
  out.vz.valid = true;
  out.sv.valid = false;
  out.vd.addr = vd;
  out.ve.addr = vd + 1;
  out.vf.addr = vd + 2;
  out.vg.addr = vd + 3;
  out.vs.addr = vs;
  out.vt.addr = vt;
  out.vu.addr = vu;
  out.vx.addr = vx;
  out.vy.addr = vy;
  out.vz.addr = vz;
  out.sv.addr = in.saddr();
  out.sv.data = in.sdata();
  out.cmdq.alu = true;
  out.ractive = Active(vs, false) | Active(vt, false) | Active(vu, false) |
                Active(vx, in.m()) | Active(vy, in.m()) | Active(vz, in.m());
  out.wactive = Active(in.vd(), true, vdwconv);
}

// clang-format off
// A list matching the entries in VEncodeOp.scala
static vencode_inst_t op_[] = {
    {undef, 0, 0},
    // LdSt
    {vdup,   MM(VDUP),   rand_vdup},   // vdup  [kOpStart=1]
    {vldst,  MM(VLDST),  rand_vldst},  // vld
    {vldst,  MM(VLDST),  rand_vldst},  // vst
    {vldst,  MM(VLDST),  rand_vldst},  // vstq
    {vldst,  MM(VLDST),  rand_vldst},  // vcget
    // Format0
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vadd
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vsub
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vrsub
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // veq
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vne
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vlt
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vle
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vgt
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vge
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vabsd
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vmax
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vmin
    {vfmt0,  MM(VFMT0),  rand_vfmt0},  // vadd3
    // Format1
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vand
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vor
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vxor
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vnot
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vrev
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vror
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vclb
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vclz
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vcpop
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vmv
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vmv2
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // vmvp
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // acset
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // actr
    {vfmt1,  MM(VFMT1),  rand_vfmt1},  // adwinit
    // Format2
    {vfmt2,  MM(VFMT2),  rand_vfmt2},  // vshl
    {vfmt2,  MM(VFMT2),  rand_vfmt2},  // vshr
    {vfmt2,  MM(VFMT2),  rand_vfmt2},  // vshf
    {vfmt2,  MM(VFMT2),  rand_vfmt2},  // vsrans
    {vfmt2,  MM(VFMT2),  rand_vfmt2},  // vsraqs
    // Format3
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmul
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmul2
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmuls
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmuls2
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmulh
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmulh2
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vdmulh
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vdmulh2
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmulw
    {vfmt3,  MM(VFMT3),  rand_vfmt3},  // vmadd
    // Format4
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vadds
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vsubs
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vaddw
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vsubw
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vacc
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vpadd
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vpsub
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vhadd
    {vfmt4,  MM(VFMT4),  rand_vfmt4},  // vhsub
    // Format6
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidevn
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidehn
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidehn2
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidevp
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidehp
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vslidehp2
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vsel
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vevn
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vodd
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vevnodd
    {vfmt6,  MM(VFMT6),  rand_vfmt6},  // vzip
    // FormatVVV
    {aconv,    MM(ACONV),   rand_vfmtv},
    {vdwconv,  MM(VDWCONV), rand_vfmtv},
    {vdwconv,  MM(ADWCONV), rand_vfmtv},
};
// clang-format on

static_assert(sizeof(op_) / sizeof(vencode_inst_t) == encode::kOpEntries);

constexpr int kOpStart = 1;
constexpr int kOpStop = sizeof(op_) / sizeof(op_[0]);

static bool VDecode(const uint32_t op, const vdecode_in_t& in,
                    vdecode_out_t& out) {
  assert(op && op < sizeof(op_) / sizeof(op_[0]));

  out.inst = in.inst;
  out.addr = in.addr;
  out.data = in.data;

  // Check undef.
  if (!op || op >= sizeof(op_) / sizeof(op_[0])) {
    return false;
  }

  // Check mask.
  const uint32_t match = op_[op].match;
  const uint32_t mask = op_[op].mask;
  if ((in.inst & mask) != (match & mask)) {
    return false;
  }

  // Check size.
  if (in.size() == 3) {
    return false;
  }

  op_[op].decode(in, out);
  return true;
}

#endif  // TESTS_VERILATOR_SIM_CORALNPU_VDECODE_H_
