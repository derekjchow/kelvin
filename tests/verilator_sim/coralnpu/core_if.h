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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_CORE_IF_H_
#define TESTS_VERILATOR_SIM_CORALNPU_CORE_IF_H_

#include "tests/verilator_sim/fifo.h"
#include "tests/verilator_sim/coralnpu/coralnpu_cfg.h"
#include "tests/verilator_sim/coralnpu/memory_if.h"

constexpr int kAxiWaitState = 3;

static bool rand_bool() {
  return rand() & 1;
}

static bool rand_bool_ibus() {
#if 1
  return rand_bool();
#else
  return true;
#endif
}

static bool rand_bool_dbus() {
#if 1
  return rand_bool();
#else
  return true;
#endif
}

// ScalarCore Memory Interface.
struct Core_if : Memory_if {
  sc_in<bool>         io_ibus_valid;
  sc_out<bool>        io_ibus_ready;
  sc_in<sc_bv<32> >   io_ibus_addr;
  sc_out<sc_bv<KP_fetchDataBits> > io_ibus_rdata;

  sc_out<bool> io_ibus_fault_valid;
  sc_out<bool> io_ibus_fault_bits_write;
  sc_out<sc_bv<32>> io_ibus_fault_bits_addr;
  sc_out<sc_bv<32>> io_ibus_fault_bits_epc;

  sc_in<bool> io_dbus_valid;
  sc_out<bool> io_dbus_ready;
  sc_in<bool> io_dbus_write;
  sc_in<sc_bv<32> > io_dbus_addr;
  sc_in<sc_bv<32> > io_dbus_adrx;
  sc_in<sc_bv<KP_dbusSize> > io_dbus_size;
  sc_in<sc_bv<KP_lsuDataBits> > io_dbus_wdata;
  sc_in<sc_bv<KP_lsuDataBits / 8> > io_dbus_wmask;
  sc_out<sc_bv<KP_lsuDataBits> > io_dbus_rdata;

  Core_if(sc_module_name n, const char* bin) : Memory_if(n, bin) {
    for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
      runused_.set_word(i, 0);
    }
  }

  void eval() {
    if (reset) {
      io_ibus_ready = false;
    } else if (clock->posedge()) {
      cycle_++;

      io_ibus_ready = rand_bool_ibus();
      io_dbus_ready = rand_bool_dbus();

      // Instruction bus read.
      if (io_ibus_valid && io_ibus_ready) {
        sc_bv<256> rdata;
        uint32_t addr = io_ibus_addr.read().get_word(0);
        uint32_t words[256 / 32];
        if (Read(addr, 256 / 8, reinterpret_cast<uint8_t*>(words))) {
          for (int i = 0; i < 256 / 32; ++i) {
            rdata.set_word(i, words[i]);
          }

          io_ibus_rdata = rdata;
        } else {
          io_ibus_fault_valid = true;
          io_ibus_fault_bits_write = false;
          io_ibus_fault_bits_addr = 0;
          io_ibus_fault_bits_epc = addr;
        }
      } else {
       io_ibus_fault_valid = false;
      }

      // Data bus read.
      if (io_dbus_valid && io_dbus_ready && !io_dbus_write) {
        sc_bv<KP_lsuDataBits> rdata;
        uint32_t addr = io_dbus_addr.read().get_word(0);
        uint32_t words[KP_lsuDataBits / 32] = {0};
        memset(words, 0xcc, sizeof(words));
        int bytes = io_dbus_size.read().get_word(0);
        if (Read(addr, bytes, reinterpret_cast<uint8_t*>(words))) {
          ReadSwizzle(addr, KP_lsuDataBits / 8, reinterpret_cast<uint8_t*>(words));
          for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
            rdata.set_word(i, words[i]);
          }
          io_dbus_rdata = rdata;
        } else {
          assert(false);
        }
      }

      // Data bus write.
      if (io_dbus_valid && io_dbus_ready && io_dbus_write) {
        sc_bv<KP_lsuDataBits> wdata = io_dbus_wdata;
        uint32_t addr = io_dbus_addr.read().get_word(0);
        uint32_t words[KP_lsuDataBits / 32];
        int bytes = io_dbus_size.read().get_word(0);
        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          words[i] = wdata.get_word(i);
        }
        WriteSwizzle(addr, KP_lsuDataBits / 8, reinterpret_cast<uint8_t*>(words));
        if (!Write(addr, bytes, reinterpret_cast<uint8_t*>(words))) {
          assert(false);
        }
      }

      rtcm_t tcm_read;
      sc_bv<KP_lsuDataBits> rdata;
    }
  }

 private:
  uint32_t cycle_ = 0;

  struct rtcm_t {
    uint32_t cycle;
    uint32_t id : 7;
    sc_bv<KP_lsuDataBits> data;
  };

  fifo_t<rtcm_t> rtcm_[2];
  sc_bv<KP_lsuDataBits> runused_;
};

#endif  // TESTS_VERILATOR_SIM_CORALNPU_CORE_IF_H_
