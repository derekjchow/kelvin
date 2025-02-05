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

#ifndef TESTS_VERILATOR_SIM_SYSC_MODULE_H_
#define TESTS_VERILATOR_SIM_SYSC_MODULE_H_

#include <systemc.h>
using sc_dt::sc_bv;

struct Sysc_module : sc_module {
  sc_in_clk clock;
  sc_in<bool> reset;

  virtual void eval() = 0;

  SC_CTOR(Sysc_module) {
    SC_METHOD(eval);
    sensitive << reset << clock.pos();
  }
};

#endif  // TESTS_VERILATOR_SIM_SYSC_MODULE_H_
