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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_VDECODEOP_H_
#define TESTS_VERILATOR_SIM_CORALNPU_VDECODEOP_H_

namespace decode {

enum VDecodeOp {
  // func2
  u = 1,
  r = 2,

  r1 = 2,
  r2 = 4,
  r3 = 6,

  n1 = 0,
  n2 = 1,
  n3 = 2,
  n4 = 3,

  psL = 1,
  pSl = 2,
  Psl = 4,
  PsL = 5,
  PSl = 6,
  PSL = 7,

  // LdSt
  vld = 0,
  vst = 8,
  vstq = 24,

  // Dup
  vdup = 16,

  // Format0,
  vadd = 0,
  vsub = 1,
  vrsub = 2,
  veq = 6,
  vne = 7,
  vlt = 8,
  vle = 10,
  vgt = 12,
  vge = 14,
  vabsd = 16,
  vmax = 18,
  vmin = 20,
  vadd3 = 24,

  // Format1
  vand = 0,
  vor = 1,
  vxor = 2,
  vnot = 3,
  vrev = 4,
  vror = 5,
  vclb = 8,
  vclz = 9,
  vcpop = 10,
  vmv = 12,
  vmvp = 13,
  acset = 16,
  actr = 17,
  adwinit = 18,

  // Format2
  vsll = 1,
  vsra = 2,
  vsrl = 3,
  vsha = 8,
  vshl = 9,
  vsrans = 16,
  vsraqs = 24,

  // Format3
  vmul = 0,
  vmuls = 2,
  vmulw = 4,
  vmulh = 8,
  vmulhu = 9,
  vdmulh = 16,
  vmacc = 20,
  vmadd = 21,

  // Format4
  vadds = 0,
  vsubs = 2,
  vaddw = 4,
  vsubw = 6,
  vacc = 10,
  vpadd = 12,
  vpsub = 14,
  vhadd = 16,
  vhsub = 20,

  // Format6
  vsliden = 0,
  vslidevn = 0,
  vslidehn = 4,
  vslidep = 8,
  vslidevp = 8,
  vslidehp = 12,
  vsel = 16,
  vevn = 24,
  vodd = 25,
  vevnodd = 26,
  vzip = 28,

  // FormatVVV
  aconv = 8,
  vdwconv = 10,
};

}  // namespace decode

#endif  // TESTS_VERILATOR_SIM_CORALNPU_VDECODEOP_H_
