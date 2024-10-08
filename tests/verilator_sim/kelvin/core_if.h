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

#ifndef TESTS_VERILATOR_SIM_KELVIN_CORE_IF_H_
#define TESTS_VERILATOR_SIM_KELVIN_CORE_IF_H_

#include "tests/verilator_sim/fifo.h"
#include "tests/verilator_sim/kelvin/kelvin_cfg.h"
#include "tests/verilator_sim/kelvin/memory_if.h"

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

static bool rand_bool_axi_w() {
#if 1
  return rand_bool();
#else
  return true;
#endif
}

static bool rand_bool_axi_r() {
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

  sc_in<bool> io_dbus_valid;
  sc_out<bool> io_dbus_ready;
  sc_in<bool> io_dbus_write;
  sc_in<sc_bv<32> > io_dbus_addr;
  sc_in<sc_bv<32> > io_dbus_adrx;
  sc_in<sc_bv<KP_dbusSize> > io_dbus_size;
  sc_in<sc_bv<KP_lsuDataBits> > io_dbus_wdata;
  sc_in<sc_bv<KP_lsuDataBits / 8> > io_dbus_wmask;
  sc_out<sc_bv<KP_lsuDataBits> > io_dbus_rdata;

#if KP_enableVector
  sc_out<bool> io_axi0_write_addr_ready;
  sc_in<bool> io_axi0_write_addr_valid;
  sc_in<sc_bv<32> > io_axi0_write_addr_bits_addr;
  sc_in<sc_bv<kUncId> > io_axi0_write_addr_bits_id;
  sc_in<sc_bv<4> > io_axi0_write_addr_bits_region;
  sc_in<sc_bv<4> > io_axi0_write_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi0_write_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi0_write_addr_bits_cache;
  sc_in<sc_bv<2> > io_axi0_write_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi0_write_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi0_write_addr_bits_size;
  sc_in<sc_bv<8> > io_axi0_write_addr_bits_len;
  sc_out<bool> io_axi0_write_data_ready;
  sc_in<bool> io_axi0_write_data_valid;
  sc_in<sc_bv<KP_lsuDataBits> > io_axi0_write_data_bits_data;
  sc_in<sc_bv<KP_lsuDataBits/8> > io_axi0_write_data_bits_strb;
  sc_in<bool> io_axi0_write_data_bits_last;
  sc_in<bool> io_axi0_write_resp_ready;
  sc_out<bool> io_axi0_write_resp_valid;
  sc_out<sc_bv<kUncId> > io_axi0_write_resp_bits_id;
  sc_out<sc_bv<2> > io_axi0_write_resp_bits_resp;
  sc_out<bool> io_axi0_read_addr_ready;
  sc_in<bool> io_axi0_read_addr_valid;
  sc_in<sc_bv<32> > io_axi0_read_addr_bits_addr;
  sc_in<sc_bv<kUncId> > io_axi0_read_addr_bits_id;
  sc_in<sc_bv<4> > io_axi0_read_addr_bits_region;
  sc_in<sc_bv<4> > io_axi0_read_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi0_read_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi0_read_addr_bits_cache;
  sc_in<sc_bv<2> > io_axi0_read_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi0_read_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi0_read_addr_bits_size;
  sc_in<sc_bv<8> > io_axi0_read_addr_bits_len;
  sc_in<bool> io_axi0_read_data_ready;
  sc_out<bool> io_axi0_read_data_valid;
  sc_out<sc_bv<2> > io_axi0_read_data_bits_resp;
  sc_out<sc_bv<kUncId> > io_axi0_read_data_bits_id;
  sc_out<sc_bv<KP_lsuDataBits> > io_axi0_read_data_bits_data;
  sc_out<bool> io_axi0_read_data_bits_last;
#endif  // KP_enableVector
  sc_out<bool> io_axi1_write_addr_ready;
  sc_in<bool> io_axi1_write_addr_valid;
  sc_in<sc_bv<32> > io_axi1_write_addr_bits_addr;
  sc_in<sc_bv<kUncId> > io_axi1_write_addr_bits_id;
  sc_in<sc_bv<4> > io_axi1_write_addr_bits_region;
  sc_in<sc_bv<4> > io_axi1_write_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi1_write_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi1_write_addr_bits_cache;
  sc_in<sc_bv<2> > io_axi1_write_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi1_write_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi1_write_addr_bits_size;
  sc_in<sc_bv<8> > io_axi1_write_addr_bits_len;
  sc_out<bool> io_axi1_write_data_ready;
  sc_in<bool> io_axi1_write_data_valid;
  sc_in<sc_bv<KP_lsuDataBits> > io_axi1_write_data_bits_data;
  sc_in<sc_bv<KP_lsuDataBits/8> > io_axi1_write_data_bits_strb;
  sc_in<bool> io_axi1_write_data_bits_last;
  sc_in<bool> io_axi1_write_resp_ready;
  sc_out<bool> io_axi1_write_resp_valid;
  sc_out<sc_bv<kUncId> > io_axi1_write_resp_bits_id;
  sc_out<sc_bv<2> > io_axi1_write_resp_bits_resp;
  sc_out<bool> io_axi1_read_addr_ready;
  sc_in<bool> io_axi1_read_addr_valid;
  sc_in<sc_bv<32> > io_axi1_read_addr_bits_addr;
  sc_in<sc_bv<kUncId> > io_axi1_read_addr_bits_id;
  sc_in<sc_bv<4> > io_axi1_read_addr_bits_region;
  sc_in<sc_bv<4> > io_axi1_read_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi1_read_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi1_read_addr_bits_cache;
  sc_in<sc_bv<2> > io_axi1_read_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi1_read_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi1_read_addr_bits_size;
  sc_in<sc_bv<8> > io_axi1_read_addr_bits_len;
  sc_in<bool> io_axi1_read_data_ready;
  sc_out<bool> io_axi1_read_data_valid;
  sc_out<sc_bv<2> > io_axi1_read_data_bits_resp;
  sc_out<sc_bv<kUncId> > io_axi1_read_data_bits_id;
  sc_out<sc_bv<KP_lsuDataBits> > io_axi1_read_data_bits_data;
  sc_out<bool> io_axi1_read_data_bits_last;

  Core_if(sc_module_name n, const char* bin) : Memory_if(n, bin) {
    for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
      runused_.set_word(i, 0);
    }
  }

  void eval() {
    if (reset) {
      io_ibus_ready = false;
#if KP_enableVector
      io_axi0_read_addr_ready = false;
      io_axi0_read_data_valid = false;
      io_axi0_write_addr_ready = false;
      io_axi0_write_data_ready = false;
      io_axi0_write_resp_valid = false;
#endif  // KP_enableVector
      io_axi1_read_addr_ready = false;
      io_axi1_read_data_valid = false;
      io_axi1_write_addr_ready = false;
      io_axi1_write_data_ready = false;
      io_axi1_write_resp_valid = false;
    } else if (clock->posedge()) {
      cycle_++;

#if KP_enableVector
      const bool axi0_write_ready = rand_bool_axi_w();
#endif
      const bool axi1_write_ready = rand_bool_axi_w();

      io_ibus_ready = rand_bool_ibus();
      io_dbus_ready = rand_bool_dbus();
#if KP_enableVector
      io_axi0_read_addr_ready = true;
      io_axi0_write_addr_ready = axi0_write_ready;
      io_axi0_write_data_ready = axi0_write_ready;
      io_axi0_write_resp_valid = false;
#endif  // KP_enableVector
      io_axi1_read_addr_ready = true;
      io_axi1_write_addr_ready = axi1_write_ready;
      io_axi1_write_data_ready = axi1_write_ready;
      io_axi1_write_resp_valid = false;

      // Instruction bus read.
      if (io_ibus_valid && io_ibus_ready) {
        sc_bv<256> rdata;
        uint32_t addr = io_ibus_addr.read().get_word(0);
        uint32_t words[256 / 32];
        Read(addr, 256 / 8, reinterpret_cast<uint8_t*>(words));

        for (int i = 0; i < 256 / 32; ++i) {
          rdata.set_word(i, words[i]);
        }

        io_ibus_rdata = rdata;
      }

      // Data bus read.
      if (io_dbus_valid && io_dbus_ready && !io_dbus_write) {
        sc_bv<KP_lsuDataBits> rdata;
        uint32_t addr = io_dbus_addr.read().get_word(0);
        uint32_t words[KP_lsuDataBits / 32] = {0};
        memset(words, 0xcc, sizeof(words));
        int bytes = io_dbus_size.read().get_word(0);
        Read(addr, bytes, reinterpret_cast<uint8_t*>(words));
        ReadSwizzle(addr, KP_lsuDataBits / 8, reinterpret_cast<uint8_t*>(words));
        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          rdata.set_word(i, words[i]);
        }
        io_dbus_rdata = rdata;
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
        Write(addr, bytes, reinterpret_cast<uint8_t*>(words));
      }

      rtcm_t tcm_read;
      sc_bv<KP_lsuDataBits> rdata;

#if KP_enableVector
      // axi0 read.
      if (io_axi0_read_addr_valid && io_axi0_read_addr_ready) {
        uint32_t addr = io_axi0_read_addr_bits_addr.read().get_word(0);
        uint32_t words[KP_lsuDataBits / 32];
        Read(addr, KP_lsuDataBits / 8, reinterpret_cast<uint8_t*>(words));

        tcm_read.cycle = cycle_;
        tcm_read.id = io_axi0_read_addr_bits_id.read().get_word(0);
        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          tcm_read.data.set_word(i, words[i]);
        }
        rtcm_[0].write(tcm_read);
      }

      bool read0 = rand_bool_axi_r() && rtcm_[0].next(tcm_read);
      if (read0 && (cycle_ - tcm_read.cycle) >= kAxiWaitState) {
        assert(rtcm_[0].remove());
        io_axi0_read_data_bits_id = tcm_read.id;
        io_axi0_read_data_bits_data = tcm_read.data;
      } else {
        read0 = false;
        io_axi0_read_data_bits_id = 0;
        io_axi0_read_data_bits_data = runused_;
      }
      io_axi0_read_data_valid = read0;

      // axi0 write.
      if (io_axi0_write_addr_valid && io_axi0_write_addr_ready) {
        assert(io_axi0_write_data_valid && io_axi0_write_data_valid);
        uint8_t wdata[KP_lsuDataBits / 8];
        uint32_t addr = io_axi0_write_addr_bits_addr.read().get_word(0);
        uint32_t* p_wdata = reinterpret_cast<uint32_t*>(wdata);

        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          p_wdata[i] = io_axi0_write_data_bits_data.read().get_word(i);
        }

        for (int i = 0; i < KP_lsuDataBits / 8; ++i) {
          if (io_axi0_write_data_bits_strb.read().get_bit(i) != 0) {
            Write(addr + i, 1, wdata + i);
          }
        }
      }

      if (io_axi0_write_addr_valid && io_axi0_write_addr_ready) {
        io_axi0_write_resp_valid = true;
        io_axi0_write_resp_bits_id = io_axi0_write_addr_bits_id;
      }
#endif  // KP_enableVector

      // axi1 read.
      if (io_axi1_read_addr_valid && io_axi1_read_addr_ready) {
        uint32_t addr = io_axi1_read_addr_bits_addr.read().get_word(0);
        uint32_t words[KP_lsuDataBits / 32];
        Read(addr, KP_lsuDataBits / 8, reinterpret_cast<uint8_t*>(words));

        tcm_read.cycle = cycle_;
        tcm_read.id = io_axi1_read_addr_bits_id.read().get_word(0);
        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          tcm_read.data.set_word(i, words[i]);
        }
        rtcm_[1].write(tcm_read);
      }

      bool read1 = rand_bool_axi_r() && rtcm_[1].next(tcm_read);
      if (read1 && (cycle_ - tcm_read.cycle) >= kAxiWaitState) {
        assert(rtcm_[1].remove());
        io_axi1_read_data_bits_id = tcm_read.id;
        io_axi1_read_data_bits_data = tcm_read.data;
      } else {
        read1 = false;
        io_axi1_read_data_bits_id = 0;
        io_axi1_read_data_bits_data = runused_;
      }
      io_axi1_read_data_valid = read1;

      // axi1 write.
      if (io_axi1_write_addr_valid && io_axi1_write_addr_ready) {
        assert(io_axi1_write_data_valid && io_axi1_write_data_valid);
        uint8_t wdata[KP_lsuDataBits / 8];
        uint32_t addr = io_axi1_write_addr_bits_addr.read().get_word(0);
        uint32_t* p_wdata = reinterpret_cast<uint32_t*>(wdata);

        for (int i = 0; i < KP_lsuDataBits / 32; ++i) {
          p_wdata[i] = io_axi1_write_data_bits_data.read().get_word(i);
        }

        for (int i = 0; i < KP_lsuDataBits / 8; ++i) {
          if (io_axi1_write_data_bits_strb.read().get_bit(i) != 0) {
            Write(addr + i, 1, wdata + i);
          }
        }
      }

      if (io_axi1_write_addr_valid && io_axi1_write_addr_ready) {
        io_axi1_write_resp_valid = true;
        io_axi1_write_resp_bits_id = io_axi1_write_addr_bits_id;
      }
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

#endif  // TESTS_VERILATOR_SIM_KELVIN_CORE_IF_H_
