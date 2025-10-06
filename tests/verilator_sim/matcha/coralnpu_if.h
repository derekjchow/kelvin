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

#ifndef TESTS_VERILATOR_SIM_MATCHA_CORALNPU_IF_H_
#define TESTS_VERILATOR_SIM_MATCHA_CORALNPU_IF_H_

#include "tests/verilator_sim/coralnpu/memory_if.h"
#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"

#define PARAMS_HEADER_PREFIX hdl/chisel/src/matcha/
#define PARAMS_HEADER_SUFFIX _parameters.h
#define PARAMS_HEADER STR(PARAMS_HEADER_PREFIX VERILATOR_MODEL PARAMS_HEADER_SUFFIX)
#include PARAMS_HEADER

//     [Bus]  addr
// 1cc [SRAM] addr
// 2cc [SRAM] rdata
//     [Bus]  rdata
constexpr int kWaitState = 2;
constexpr int kBusBits = KP_lsuDataBits;

struct CoralNPU_if : Memory_if {
  sc_in<bool> io_bus_cvalid;
  sc_out<bool> io_bus_cready;
  sc_in<bool> io_bus_cwrite;
  sc_in<sc_bv<7> > io_bus_cid;
  sc_in<sc_bv<32> > io_bus_caddr;
  sc_in<sc_bv<kBusBits> > io_bus_wdata;
  sc_in<sc_bv<kBusBits / 8> > io_bus_wmask;

  sc_out<bool> io_bus_rvalid;
  sc_out<sc_bv<7> > io_bus_rid;
  sc_out<sc_bv<kBusBits> > io_bus_rdata;

  CoralNPU_if(sc_module_name n, const char* bin) : Memory_if(n, bin) {
    for (int i = 0; i < kBusBits / 32; ++i) {
      runused_.set_word(i, 0);
    }
  }

  void eval() {
    if (reset) {
      return;
    }
    cycle_++;

    io_bus_cready = true;

    // Bus read.
    if (io_bus_cvalid && io_bus_cready && !io_bus_cwrite) {
      sc_bv<kBusBits> rdata;
      uint32_t addr = io_bus_caddr.read().get_word(0);
      uint32_t words[kBusBits / 32];
      Read(addr, kBusBits / 8, reinterpret_cast<uint8_t*>(words));

      for (int i = 0; i < kBusBits / 32; ++i) {
        rdata.set_word(i, words[i]);
      }

      resp_t resp;
      resp.cycle = cycle_;
      resp.id = io_bus_cid.read().get_word(0);
      for (int i = 0; i < kBusBits / 32; ++i) {
        resp.data.set_word(i, words[i]);
      }
      resp_.write(resp);
    }

    // Bus read response.
    resp_t resp;
    bool read = resp_.next(resp);
    if (read && (cycle_ - resp.cycle) >= kWaitState) {
      assert(resp_.remove());
      io_bus_rid = resp.id;
      io_bus_rdata = resp.data;
    } else {
      read = false;
      io_bus_rid = 0;
      io_bus_rdata = runused_;
    }
    io_bus_rvalid = read;

    // Bus write.
    if (io_bus_cvalid && io_bus_cready && io_bus_cwrite) {
      uint8_t wdata[kBusBits / 8];
      uint32_t addr = io_bus_caddr.read().get_word(0);
      uint32_t* p_wdata = reinterpret_cast<uint32_t*>(wdata);

      for (int i = 0; i < kBusBits / 32; ++i) {
        p_wdata[i] = io_bus_wdata.read().get_word(i);
      }

      for (int i = 0; i < kBusBits / 8; ++i) {
        if (io_bus_wmask.read().get_bit(i) != 0) {
          Write(addr + i, 1, wdata + i);
        }
      }
    }
  }

 private:
  uint32_t cycle_ = 0;

  struct resp_t {
    uint32_t cycle;
    uint32_t id : 7;
    sc_bv<kBusBits> data;
  };

  fifo_t<resp_t> resp_;
  sc_bv<kBusBits> runused_;
};

#endif  // TESTS_VERILATOR_SIM_MATCHA_CORALNPU_IF_H_
