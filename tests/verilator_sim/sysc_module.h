// Copyright 2023 Google LLC

#ifndef TESTS_VERILATOR_SIM_SYSC_MODULE_H_
#define TESTS_VERILATOR_SIM_SYSC_MODULE_H_

#include <systemc>
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
