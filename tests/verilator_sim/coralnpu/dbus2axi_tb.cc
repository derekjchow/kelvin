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

#include "VDBus2AxiV1.h"
#include "tests/verilator_sim/sysc_tb.h"

struct DBus2Axi_tb : Sysc_tb {
  sc_out<bool> io_dbus_valid;
  sc_in<bool> io_dbus_ready;
  sc_out<bool> io_dbus_write;
  sc_out<bool> io_axi_write_addr_ready;
  sc_in<bool> io_axi_write_addr_valid;
  sc_out<bool> io_axi_write_data_ready;
  sc_in<bool> io_axi_write_data_valid;
  sc_in<bool> io_axi_write_resp_ready;
  sc_out<bool> io_axi_write_resp_valid;
  sc_out<bool> io_axi_read_addr_ready;
  sc_in<bool> io_axi_read_addr_valid;
  sc_in<bool> io_axi_read_data_ready;
  sc_out<bool> io_axi_read_data_valid;
  sc_out<sc_bv<32> > io_dbus_addr;
  sc_out<sc_bv<32> > io_dbus_adrx;
  sc_out<sc_bv<6> > io_dbus_size;
  sc_out<sc_bv<256> > io_dbus_wdata;
  sc_out<sc_bv<32> > io_dbus_wmask;
  sc_in<sc_bv<256> > io_dbus_rdata;
  sc_in<sc_bv<32> > io_dbus_pc;
  sc_in<bool> io_fault_valid;
  sc_in<bool> io_fault_bits_write;
  sc_in<sc_bv<32> > io_fault_bits_addr;
  sc_in<sc_bv<32>> io_fault_bits_epc;
  sc_in<sc_bv<32> > io_axi_write_addr_bits_addr;
  sc_in<sc_bv<6> > io_axi_write_addr_bits_id;
  sc_in<sc_bv<4> > io_axi_write_addr_bits_region;
  sc_in<sc_bv<4> > io_axi_write_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi_write_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi_write_addr_bits_cache;
  sc_in<bool> io_axi_write_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi_write_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi_write_addr_bits_size;
  sc_in<sc_bv<8> > io_axi_write_addr_bits_len;
  sc_in<sc_bv<256> > io_axi_write_data_bits_data;
  sc_in<sc_bv<32> > io_axi_write_data_bits_strb;
  sc_in<bool> io_axi_write_data_bits_last;
  sc_out<sc_bv<6> > io_axi_write_resp_bits_id;
  sc_out<sc_bv<2> > io_axi_write_resp_bits_resp;
  sc_in<sc_bv<32> > io_axi_read_addr_bits_addr;
  sc_in<sc_bv<6> > io_axi_read_addr_bits_id;
  sc_in<sc_bv<4> > io_axi_read_addr_bits_region;
  sc_in<sc_bv<4> > io_axi_read_addr_bits_qos;
  sc_in<sc_bv<3> > io_axi_read_addr_bits_prot;
  sc_in<sc_bv<4> > io_axi_read_addr_bits_cache;
  sc_in<bool> io_axi_read_addr_bits_lock;
  sc_in<sc_bv<2> > io_axi_read_addr_bits_burst;
  sc_in<sc_bv<3> > io_axi_read_addr_bits_size;
  sc_in<sc_bv<8> > io_axi_read_addr_bits_len;
  sc_out<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_out<sc_bv<6> > io_axi_read_data_bits_id;
  sc_out<sc_bv<256> > io_axi_read_data_bits_data;
  sc_out<bool> io_axi_read_data_bits_last;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    sc_bv<32> dbus_wmask;
    sc_bv<256> dbus_wdata;
    for (int i = 0; i < 8; ++i) dbus_wdata.set_word(i, rand_uint32());
    dbus_wmask.set_word(0, rand_uint32());

    if (!io_dbus_valid || io_dbus_ready) {
      io_dbus_valid = rand_bool();
      io_dbus_write = rand_bool();
      io_dbus_addr = rand_uint32();
      io_dbus_adrx = rand_uint32();
      io_dbus_size = 1 << rand_int(0, 5);
      io_dbus_wdata = dbus_wdata;
      io_dbus_wmask = dbus_wmask;
    }

    io_axi_read_addr_ready = rand_bool();

    const bool write_ready = rand_bool();
    io_axi_write_addr_ready = write_ready;
    io_axi_write_data_ready = write_ready;

    // *************************************************************************
    // DBus Addr.
    if (io_dbus_valid && !io_dbus_write && !dbus_read_ready_) {
      dbus_read_ready_ = true;
      axi_read_addr_t r;
      r.addr = io_dbus_addr.read().get_word(0);
      r.id = 0x00;  // from RTL
      axi_read_addr_.write(r);
    }

    if (io_dbus_valid && io_dbus_write && !dbus_write_active_) {
      dbus_write_active_ = true;
      axi_write_addr_t w;
      sc_bv<256> data;
      sc_bv<32> strb;
      w.addr = io_dbus_addr.read().get_word(0);
      w.id = 0x00;  // from RTL
      w.strb = io_dbus_wmask;
      w.data = io_dbus_wdata;
      axi_write_addr_.write(w);
    }

    // *************************************************************************
    // DBus Read Data.
    if (dbus_read_active_) {
      dbus_read_active_ = false;
      axi_read_fired_ = false;
      dbus_read_data_t ref, dut;
      check(dbus_read_data_.read(ref), "dbus read data");
      dut.data = io_dbus_rdata;
      if (ref != dut) {
        ref.print("ref::dbus_read_addr");
        dut.print("dut::dbus_read_addr");
        check(false);
      }
    }

    if (io_dbus_valid && io_dbus_ready && !io_dbus_write) {
      dbus_read_ready_ = false;
      dbus_read_active_ = true;
    }

    if (io_dbus_valid && io_dbus_ready && io_dbus_write) {
      dbus_write_active_ = false;
      dbus_write_resp_phase_ = false;
    }

    // *************************************************************************
    // AXI Read Addr.
    if (io_axi_read_addr_valid && io_axi_read_addr_ready && !axi_read_fired_) {
      axi_read_fired_ = true;
      axi_read_addr_t dut, ref;
      check(axi_read_addr_.read(ref), "axi read addr");
      dut.addr = io_axi_read_addr_bits_addr.read().get_word(0);
      dut.id = io_axi_read_addr_bits_id.read().get_word(0);
      if (ref != dut) {
        ref.print("ref::axi_read_addr");
        dut.print("dut::axi_read_addr");
        check(false);
      }

      sc_bv<256> data;
      for (int i = 0; i < 8; ++i) data.set_word(i, rand_uint32());
      axi_read_data_t raxi;
      raxi.id = dut.id;
      raxi.data = data;
      raxi.resp = rand_int();
      axi_read_data_.write(raxi);

      dbus_read_data_t dbus;
      dbus.data = data;
      dbus_read_data_.write(dbus);
    }

    // *************************************************************************
    // AXI Read Data.
    if (io_axi_read_data_valid && io_axi_read_data_ready) {
      check(axi_read_data_.remove(), "axi read data");
    }

    axi_read_data_t rdata;
    bool read_data_valid = axi_read_data_.next(rdata);
    io_axi_read_data_valid = read_data_valid && rand_bool();
    io_axi_read_data_bits_id = rdata.id;
    io_axi_read_data_bits_data = rdata.data;
    io_axi_read_data_bits_resp = rdata.resp;

    // *************************************************************************
    // AXI Write Addr.
    if (io_axi_write_addr_valid && io_axi_write_addr_ready && !dbus_write_resp_phase_) {
      assert(io_axi_write_data_valid && io_axi_write_data_ready);
      axi_write_addr_t dut, ref;
      check(axi_write_addr_.read(ref), "axi write addr");
      dut.addr = io_axi_write_addr_bits_addr.read().get_word(0);
      dut.id = io_axi_write_addr_bits_id.read().get_word(0);
      dut.data = io_axi_write_data_bits_data;
      dut.strb = io_axi_write_data_bits_strb;
      if (ref != dut) {
        ref.print("ref::axi_write_addr");
        dut.print("dut::axi_write_addr");
        check(false);
      }

      axi_write_resp_t resp;
      resp.id = dut.id;
      resp.resp = rand_int();
      axi_write_resp_.write(resp);
      dbus_write_resp_phase_ = true;
    }

    // *************************************************************************
    // AXI Write Resp.
    if (io_axi_write_resp_valid && io_axi_write_resp_ready) {
      check(axi_write_resp_.remove(), "axi write resp");
    }

    axi_write_resp_t wresp;
    bool write_resp_valid = axi_write_resp_.next(wresp);
    io_axi_write_resp_valid = write_resp_valid;
    io_axi_write_resp_bits_id = wresp.id;
    io_axi_write_resp_bits_resp = wresp.resp;
  }


 private:
  struct axi_read_addr_t {
    uint32_t addr;
    uint32_t id : 7;

    bool operator!=(const axi_read_addr_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (id != rhs.id) return true;
      return false;
    }

    void print(const char* name) {
      printf("[%s]: id=%x addr=%08x\n", name, id, addr);
    }
  };

  struct axi_read_data_t {
    uint32_t id : 7;
    uint32_t resp : 7;
    sc_bv<256> data;

    bool operator!=(const axi_read_data_t& rhs) const {
      if (id != rhs.id) return true;
      if (data != rhs.data) return true;
      return false;
    }

    void print(const char* name) {
      printf("[%s]: id=%x data=", name, id);
      for (int i = 0; i < 256 / 32; ++i) {
        printf("%08x ", data.get_word(i));
      }
      printf("\n");
    }
  };

  struct axi_write_addr_t {
    uint32_t addr;
    uint32_t id : 7;
    sc_bv<256> data;
    sc_bv<32> strb;

    bool operator!=(const axi_write_addr_t& rhs) const {
      if (addr != rhs.addr) return true;
      if (id != rhs.id) return true;
      if (strb != rhs.strb) return true;
      if (data != rhs.data) return true;
      return false;
    }

    void print(const char* name) {
      printf("[%s]: id=%x addr=%08x strb=%08x data=", name, id, addr,
             strb.get_word(0));
      for (int i = 0; i < 256 / 32; ++i) {
        printf("%08x ", data.get_word(0));
      }
      printf("\n");
    }
  };

  struct axi_write_resp_t {
    uint32_t id : 7;
    uint32_t resp : 2;
  };

  struct dbus_read_data_t {
    sc_bv<256> data;

    bool operator!=(const dbus_read_data_t& rhs) const {
      if (data != rhs.data) return true;
      return false;
    }

    void print(const char* name) {
      printf("[%s]: data=", name);
      for (int i = 0; i < 256 / 32; ++i) {
        printf("%08x ", data.get_word(i));
      }
      printf("\n");
    }
  };

  bool dbus_read_ready_ = false;
  bool dbus_read_active_ = false;
  bool dbus_write_active_ = false;
  bool dbus_write_resp_phase_ = false;
  bool axi_read_fired_ = false;
  fifo_t<axi_read_addr_t> axi_read_addr_;
  fifo_t<axi_read_data_t> axi_read_data_;
  fifo_t<axi_write_addr_t> axi_write_addr_;
  fifo_t<axi_write_resp_t> axi_write_resp_;
  fifo_t<dbus_read_data_t> dbus_read_data_;
};

static void DBus2Axi_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_dbus_valid;
  sc_signal<bool> io_dbus_ready;
  sc_signal<bool> io_dbus_write;
  sc_signal<bool> io_axi_write_addr_ready;
  sc_signal<bool> io_axi_write_addr_valid;
  sc_signal<bool> io_axi_write_data_ready;
  sc_signal<bool> io_axi_write_data_valid;
  sc_signal<bool> io_axi_write_resp_ready;
  sc_signal<bool> io_axi_write_resp_valid;
  sc_signal<bool> io_axi_read_addr_ready;
  sc_signal<bool> io_axi_read_addr_valid;
  sc_signal<bool> io_axi_read_data_ready;
  sc_signal<bool> io_axi_read_data_valid;
  sc_signal<sc_bv<32> > io_dbus_addr;
  sc_signal<sc_bv<32> > io_dbus_adrx;
  sc_signal<sc_bv<6> > io_dbus_size;
  sc_signal<sc_bv<256> > io_dbus_wdata;
  sc_signal<sc_bv<32> > io_dbus_wmask;
  sc_signal<sc_bv<256> > io_dbus_rdata;
  sc_signal<sc_bv<32> > io_dbus_pc;
  sc_signal<bool> io_fault_valid;
  sc_signal<bool> io_fault_bits_write;
  sc_signal<sc_bv<32> > io_fault_bits_addr;
  sc_signal<sc_bv<32> > io_fault_bits_epc;
  sc_signal<sc_bv<32> > io_axi_write_addr_bits_addr;
  sc_signal<sc_bv<6> > io_axi_write_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi_write_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi_write_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi_write_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi_write_addr_bits_cache;
  sc_signal<bool> io_axi_write_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi_write_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi_write_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi_write_addr_bits_len;
  sc_signal<sc_bv<256> > io_axi_write_data_bits_data;
  sc_signal<sc_bv<32> > io_axi_write_data_bits_strb;
  sc_signal<bool> io_axi_write_data_bits_last;
  sc_signal<sc_bv<6> > io_axi_write_resp_bits_id;
  sc_signal<sc_bv<2> > io_axi_write_resp_bits_resp;
  sc_signal<sc_bv<32> > io_axi_read_addr_bits_addr;
  sc_signal<sc_bv<6> > io_axi_read_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi_read_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi_read_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi_read_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi_read_addr_bits_cache;
  sc_signal<bool> io_axi_read_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi_read_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi_read_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi_read_addr_bits_len;
  sc_signal<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_signal<sc_bv<6> > io_axi_read_data_bits_id;
  sc_signal<sc_bv<256> > io_axi_read_data_bits_data;
  sc_signal<bool> io_axi_read_data_bits_last;

  DBus2Axi_tb tb("DBus2Axi_tb", loops, true /*random*/);
  VDBus2AxiV1 d2a(name);

  d2a.clock(tb.clock);
  d2a.reset(tb.reset);
  BIND2(tb, d2a, io_fault_valid);
  BIND2(tb, d2a, io_fault_bits_epc);
  BIND2(tb, d2a, io_fault_bits_addr);
  BIND2(tb, d2a, io_fault_bits_write);
  BIND2(tb, d2a, io_dbus_valid);
  BIND2(tb, d2a, io_dbus_ready);
  BIND2(tb, d2a, io_dbus_write);
  BIND2(tb, d2a, io_axi_write_addr_ready);
  BIND2(tb, d2a, io_axi_write_addr_valid);
  BIND2(tb, d2a, io_axi_write_data_ready);
  BIND2(tb, d2a, io_axi_write_data_valid);
  BIND2(tb, d2a, io_axi_write_resp_ready);
  BIND2(tb, d2a, io_axi_write_resp_valid);
  BIND2(tb, d2a, io_axi_read_addr_ready);
  BIND2(tb, d2a, io_axi_read_addr_valid);
  BIND2(tb, d2a, io_axi_read_data_ready);
  BIND2(tb, d2a, io_axi_read_data_valid);
  BIND2(tb, d2a, io_dbus_addr);
  BIND2(tb, d2a, io_dbus_adrx);
  BIND2(tb, d2a, io_dbus_size);
  BIND2(tb, d2a, io_dbus_wdata);
  BIND2(tb, d2a, io_dbus_wmask);
  BIND2(tb, d2a, io_dbus_rdata);
  BIND2(tb, d2a, io_dbus_pc);
  BIND2(tb, d2a, io_axi_write_addr_bits_addr);
  BIND2(tb, d2a, io_axi_write_addr_bits_id);
  BIND2(tb, d2a, io_axi_write_addr_bits_region);
  BIND2(tb, d2a, io_axi_write_addr_bits_qos);
  BIND2(tb, d2a, io_axi_write_addr_bits_prot);
  BIND2(tb, d2a, io_axi_write_addr_bits_cache);
  BIND2(tb, d2a, io_axi_write_addr_bits_lock);
  BIND2(tb, d2a, io_axi_write_addr_bits_burst);
  BIND2(tb, d2a, io_axi_write_addr_bits_size);
  BIND2(tb, d2a, io_axi_write_addr_bits_len);
  BIND2(tb, d2a, io_axi_write_data_bits_data);
  BIND2(tb, d2a, io_axi_write_data_bits_strb);
  BIND2(tb, d2a, io_axi_write_data_bits_last);
  BIND2(tb, d2a, io_axi_write_resp_bits_id);
  BIND2(tb, d2a, io_axi_write_resp_bits_resp);
  BIND2(tb, d2a, io_axi_read_addr_bits_addr);
  BIND2(tb, d2a, io_axi_read_addr_bits_id);
  BIND2(tb, d2a, io_axi_read_addr_bits_region);
  BIND2(tb, d2a, io_axi_read_addr_bits_qos);
  BIND2(tb, d2a, io_axi_read_addr_bits_prot);
  BIND2(tb, d2a, io_axi_read_addr_bits_cache);
  BIND2(tb, d2a, io_axi_read_addr_bits_lock);
  BIND2(tb, d2a, io_axi_read_addr_bits_burst);
  BIND2(tb, d2a, io_axi_read_addr_bits_size);
  BIND2(tb, d2a, io_axi_read_addr_bits_len);
  BIND2(tb, d2a, io_axi_read_data_bits_resp);
  BIND2(tb, d2a, io_axi_read_data_bits_id);
  BIND2(tb, d2a, io_axi_read_data_bits_data);
  BIND2(tb, d2a, io_axi_read_data_bits_last);

  if (trace) {
    tb.trace(&d2a);
  }

  tb.start();
}

int sc_main(int argc, char* argv[]) {
  DBus2Axi_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
