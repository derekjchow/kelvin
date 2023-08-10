// Copyright 2023 Google LLC

#include "tests/verilator_sim/sysc_tb.h"

#ifndef L1DCACHEBANK
#include "VL1DCache.h"
constexpr int kDBusBankAdj = 0;
#else
constexpr int kDBusBankAdj = 1;
#endif

#include "tests/verilator_sim/kelvin/kelvin_cfg.h"

constexpr int kLineSize = kVector / 8;
constexpr int kLineBase = ~(kLineSize - 1);
constexpr int kLineOffset = kLineSize - 1;

struct L1DCache_tb : Sysc_tb
{
  sc_out<bool> io_flush_valid;
  sc_in<bool>  io_flush_ready;
  sc_out<bool> io_flush_all;
  sc_out<bool> io_flush_clean;

  sc_out<bool> io_dbus_valid;
  sc_in<bool> io_dbus_ready;
  sc_out<bool> io_dbus_write;
  sc_out<sc_bv<kDbusBits> > io_dbus_size;
  sc_out<sc_bv<32 - kDBusBankAdj> > io_dbus_addr;
  sc_out<sc_bv<32 - kDBusBankAdj> > io_dbus_adrx;
  sc_in<sc_bv<kVector> > io_dbus_rdata;
  sc_out<sc_bv<kVector> > io_dbus_wdata;
  sc_out<sc_bv<kVector / 8> > io_dbus_wmask;

  sc_in<bool> io_axi_read_addr_valid;
  sc_out<bool> io_axi_read_addr_ready;
  sc_in<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_read_addr_bits_id;
  sc_in<sc_bv<32 - kDBusBankAdj> > io_axi_read_addr_bits_addr;

  sc_out<bool> io_axi_read_data_valid;
  sc_in<bool> io_axi_read_data_ready;
  sc_out<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_out<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_read_data_bits_id;
  sc_out<sc_bv<kL1DAxiBits> > io_axi_read_data_bits_data;

  sc_in<bool> io_axi_write_addr_valid;
  sc_out<bool> io_axi_write_addr_ready;
  sc_in<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_write_addr_bits_id;
  sc_in<sc_bv<32 - kDBusBankAdj> > io_axi_write_addr_bits_addr;

  sc_in<bool> io_axi_write_data_valid;
  sc_out<bool> io_axi_write_data_ready;
  sc_in<sc_bv<kL1DAxiStrb> > io_axi_write_data_bits_strb;
  sc_in<sc_bv<kL1DAxiBits> > io_axi_write_data_bits_data;

  sc_out<bool> io_axi_write_resp_valid;
  sc_in<bool> io_axi_write_resp_ready;
  sc_out<sc_bv<2> > io_axi_write_resp_bits_resp;
  sc_out<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_write_resp_bits_id;

  sc_in<bool> io_volt_sel;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // dbus
#ifdef L1DCACHEBANK
    // Checks a bank cache line.
    if (dbus_resp_pipeline_) {
      dbus_resp_pipeline_ = false;
      uint32_t addr = dbus_resp_addr_;
      int size = dbus_resp_size_;
      for (int i = 0; i < vlenb_ && size; ++i) {
        uint8_t ref = dbus_resp_data_[i];
        uint8_t dut = io_dbus_rdata.read().get_word(i / 4) >> (8 * i);
        if (ref != dut) {
          printf("DDD(%d) %08x : %02x %02x\n", i, (addr & ~(vlenb_ - 1)) + i, ref, dut);
        }
        check(ref == dut, "dbus read data");
      }
    }
#else
    if (dbus_resp_pipeline_) {
      dbus_resp_pipeline_ = false;
      uint32_t addr = dbus_resp_addr_;
      int size = dbus_resp_size_;
      for (int j = addr; j < addr + size; ++j) {
        int i = j & (vlenb_ - 1);
        uint8_t ref = dbus_resp_data_[i];
        uint8_t dut = io_dbus_rdata.read().get_word(i / 4) >> (8 * i);
        check(ref == dut, "dbus read data");
      }
    }
#endif

    if (io_dbus_valid && io_dbus_ready && !io_dbus_write) {
      dbus_active_ = false;
      dbus_resp_pipeline_ = true;
      dbus_resp_addr_ = io_dbus_addr.read().get_word(0);
      dbus_resp_size_ = io_dbus_size.read().get_word(0);
#ifdef L1DCACHEBANK
      ReadBus(dbus_resp_addr_ & kLineBase, vlenb_, dbus_resp_data_);
#else
      ReadBus(dbus_resp_addr_, vlenb_, dbus_resp_data_);
#endif
      history_t cmd({dbus_resp_addr_});
      history_.write(cmd);
      if (history_.count() > 16) {
        history_.remove();
      }
    }

    if (io_dbus_valid && io_dbus_ready && io_dbus_write) {
      dbus_active_ = false;

      uint32_t addr = io_dbus_addr.read().get_word(0);
      int size = io_dbus_size.read().get_word(0);
      uint8_t wdata[vlenb_];
      uint32_t* p_wdata = (uint32_t*) wdata;
      for (int i = 0; i < vlenw_; ++i) {
        p_wdata[i] = io_dbus_wdata.read().get_word(i);
      }
      const uint32_t linemask = vlenb_ - 1;
      const uint32_t linebase = addr & ~linemask;
      for (int i = 0; i < size; ++i, ++addr) {
        const uint32_t lineoffset = addr & linemask;
        if (io_dbus_wmask.read().get_bit(lineoffset)) {
#ifdef L1DCACHEBANK
          WriteBus(linebase + lineoffset, wdata[lineoffset]);
#else
          WriteBus(addr, wdata[lineoffset]);
#endif
        }
      }
    }

    if (io_flush_valid && io_flush_ready) {
      flush_valid_ = false;
      flush_all_ = false;
      flush_clean_ = false;
    }

    if (++flush_count_ > 5000 && !dbus_active_ && !flush_valid_) {
      // Flush controls must not change during handshake.
      flush_count_ = 0;
      flush_valid_ = true;
      flush_all_   = rand_bool();
      flush_clean_ = rand_bool();
    }

    io_flush_valid = flush_valid_;
    io_flush_all   = flush_all_;
    io_flush_clean = flush_clean_;

    history_t dbus;
    if (!io_dbus_valid || !dbus_active_) {  // latch transaction
      bool valid = rand_bool() && !flush_valid_;
      bool write = rand_int(0, 3) == 0;
      bool newaddr = rand_int(0, 3) == 0 || !history_.rand(dbus);
      uint32_t addr = newaddr ? rand_uint32() : (dbus.addr + rand_int(-vlenb_, vlenb_));
      addr = std::min(0xffffff00u, addr);  // TODO: avoids a raxi() crash.
      if (kDBusBankAdj) {
        addr &= 0x7fffffff;
      }
      if (rand_int(0, 7) == 0) {
        addr &= 0x3fff;
      }
#ifdef L1DCACHEBANK
      int size = rand_int(1, vlenb_);
#else
      int size = rand_int(0, vlenb_);
#endif
      io_dbus_valid = valid;
      io_dbus_write = write;
      io_dbus_addr = addr;
      io_dbus_adrx = addr + vlenb_;
      io_dbus_size = size;
      if (valid) {
        dbus_active_ = true;
        CheckAddr(addr, size);
      }

      sc_bv<kVector> wdata = 0;
      sc_bv<kVector / 8> wmask = 0;

      if (write) {
        for (int i = 0; i < vlenw_; ++i) {
          wdata.set_word(i, rand_uint32());
        }
        const uint32_t linemask = vlenb_ - 1;
        const uint32_t lineoffset = addr & linemask;
        const bool all = rand_bool();
        for (int i = 0; i < size; ++i) {
          if (all || rand_bool()) {
            wmask.set_bit((i + lineoffset) & linemask, sc_dt::Log_1);
          }
        }
      }

      io_dbus_wdata.write(wdata);
      io_dbus_wmask.write(wmask);
    }

    timeout_ = io_dbus_ready ? 0 : timeout_ + io_dbus_valid;
    check(timeout_ < 10000, "dbus timeout");

    // axi_read_addr
    io_axi_read_addr_ready = rand_bool();

    if (io_axi_read_addr_valid && io_axi_read_addr_ready) {
      uint32_t id = io_axi_read_addr_bits_id.read().get_word(0);
      uint32_t addr = io_axi_read_addr_bits_addr.read().get_word(0);
      response_t resp({id, addr});
      resp_.write(resp);
    }

    // axi_read_data
    io_axi_read_data_valid = false;
    io_axi_read_data_bits_id = 0;
    io_axi_read_data_bits_data = 0;

    if (io_axi_read_data_valid && io_axi_read_data_ready) {
      check(resp_.remove(), "no response to erase");
    }

    response_t resp;
    resp_.shuffle();
    if (resp_.next(resp)) {
      io_axi_read_data_valid = rand_bool();
      io_axi_read_data_bits_id = resp.id;
      uint32_t addr = resp.addr;
      sc_bv<kL1DAxiBits> out;
      for (int i = 0; i < axiw_; ++i) {
        uint32_t data;
        ReadAxi(addr, 4, (uint8_t*) &data);
        out.set_word(i, data);
        addr += 4;
      }
      io_axi_read_data_bits_data = out;
    }

    // axi_write_addr
    bool writedataready = rand_bool();

    io_axi_write_addr_ready = writedataready;

    if (io_axi_write_addr_valid && io_axi_write_addr_ready) {
      axiwaddr_t p;
      p.id = io_axi_write_addr_bits_id.read().get_word(0);
      p.addr = io_axi_write_addr_bits_addr.read().get_word(0);
      waddr_.write(p);
    }

    // axi_write_data
    io_axi_write_data_ready = writedataready;

    if (io_axi_write_data_valid && io_axi_write_data_ready) {
      axiwdata_t p;
      uint32_t* ptr = (uint32_t*) p.data;
      for (int i = 0; i < axiw_; ++i, ++ptr) {
        ptr[0] = io_axi_write_data_bits_data.read().get_word(i);
      }
      for (int i = 0; i < axib_; ++i) {
        p.mask[i] = io_axi_write_data_bits_strb.read().get_bit(i);
      }
      wdata_.write(p);
    }

    // axi_write_resp
    if (io_axi_write_resp_valid && io_axi_write_resp_ready) {
      wresp_.remove();
    }

    axiwaddr_t wr;
    io_axi_write_resp_valid = rand_int(0, 4) == 0 && wresp_.next(wr);
    io_axi_write_resp_bits_id = wr.id;

    // Process axi data write, and populate response.
    axiwaddr_t wa;
    axiwdata_t wd;
    if (waddr_.next(wa) && wdata_.next(wd)) {
      waddr_.remove();
      wdata_.remove();
      wresp_.write(wa);

      uint32_t addr = wa.addr;
      for (int i = 0; i < axib_; ++i, ++addr) {
        if (wd.mask[i]) {
          WriteAxi(addr, wd.data[i]);
        }
      }
    }
  }

private:
  struct history_t {
    uint32_t addr;
  };

  struct response_t {
    uint32_t id;
    uint32_t addr;
  };

  struct axiwaddr_t {
    uint32_t id;
    uint32_t addr;
  };

  struct axiwdata_t {
    uint8_t data[kL1DAxiBits / 8];
    bool    mask[kL1DAxiBits / 8];
  };

  const int vlenb_ = kVector / 8;
  const int vlenw_ = kVector / 32;
  const int axib_ = kL1DAxiBits / 8;
  const int axiw_ = kL1DAxiBits / 32;

  int timeout_ = 0;
  int flush_count_ = 0;
  bool flush_valid_ = false;
  bool flush_all_ = false;
  bool flush_clean_ = false;

  bool dbus_active_ = false;
  bool dbus_resp_pipeline_ = false;
  uint32_t dbus_resp_addr_ = 0;
  uint32_t dbus_resp_size_ = 0;
  uint8_t dbus_resp_data_[kVector / 8];
  fifo_t<response_t> resp_;
  fifo_t<history_t> history_;
  fifo_t<axiwaddr_t> waddr_;
  fifo_t<axiwdata_t> wdata_;
  fifo_t<axiwaddr_t> wresp_;

private:
  std::map<uint32_t, uint8_t[kLineSize]> mem_bus_;
  std::map<uint32_t, uint8_t[kLineSize]> mem_axi_;

  void _CheckAddr(uint32_t addr, uint8_t size) {
    const uint32_t paddr = addr & kLineBase;
    if (mem_bus_.find(paddr) == mem_bus_.end()) {
      uint8_t data[kLineSize];
      uint32_t* p_data = (uint32_t*) data;
      for (int i = 0; i < kLineSize / 4; ++i) {
        p_data[i] = rand();
        // p_data[i] = paddr + 4 * i;  // debug
      }
      memcpy(mem_bus_[paddr], data, kLineSize);
      memcpy(mem_axi_[paddr], data, kLineSize);
    }
  }

  void CheckAddr(uint32_t addr, uint8_t size) {
    _CheckAddr(addr, size);
    // if ((addr & kLineBase) == ((addr + size) & kLineBase)) return;
    _CheckAddr(addr + kLineSize, size);
  }

  template<int outsz>
  void _Read(uint32_t addr, uint8_t size, uint8_t* data,
             std::map<uint32_t, uint8_t[kLineSize]>& m) {
    const uint32_t laddr = addr & kLineBase;
    const uint32_t loffset = addr & kLineOffset;
    const uint32_t doffset = addr & (outsz - 1);
    uint32_t start = addr;
    uint32_t end = std::min(addr + size, laddr + kLineSize);
    int size0 = end - start;
    int size1 = size - size0;

    memset(data, 0xCC, outsz);
#ifdef L1DCACHEBANK
    assert(doffset == 0);
    memcpy(data + doffset, m[laddr] + loffset, outsz);
#else
    memcpy(data + doffset, m[laddr] + loffset, size0);
    if (!size1) return;
    memcpy(data, m[laddr + kLineSize], size1);
#endif
  }

  void _Write(uint32_t addr, uint8_t data,
              std::map<uint32_t, uint8_t[kLineSize]>& m) {
    const uint32_t laddr = addr & kLineBase;
    const uint32_t loffset = addr & kLineOffset;

    m[laddr][loffset] = data;
  }

  void ReadBus(uint32_t addr, uint8_t size, uint8_t* data) {
    _Read<kVector / 8>(addr, size, data, mem_bus_);
  }

  void ReadAxi(uint32_t addr, uint8_t size, uint8_t* data) {
    _Read<4>(addr, size, data, mem_axi_);
  }

  void WriteBus(uint32_t addr, uint8_t data) {
    _Write(addr, data, mem_bus_);
  }

  void WriteAxi(uint32_t addr, uint8_t data) {
    _Write(addr, data, mem_axi_);
  }
};

static void L1DCache_test(char* name, int loops, bool trace) {
  sc_signal<bool> clock;
  sc_signal<bool> reset;

  sc_signal<bool> io_flush_valid;
  sc_signal<bool> io_flush_ready;
  sc_signal<bool> io_flush_all;
  sc_signal<bool> io_flush_clean;

  sc_signal<bool> io_dbus_valid;
  sc_signal<bool> io_dbus_ready;
  sc_signal<bool> io_dbus_write;
  sc_signal<sc_bv<kDbusBits> > io_dbus_size;
  sc_signal<sc_bv<32 - kDBusBankAdj> > io_dbus_addr;
  sc_signal<sc_bv<32 - kDBusBankAdj> > io_dbus_adrx;
  sc_signal<sc_bv<kVector> > io_dbus_rdata;
  sc_signal<sc_bv<kVector> > io_dbus_wdata;
  sc_signal<sc_bv<kVector / 8> > io_dbus_wmask;

  sc_signal<bool> io_axi_read_addr_valid;
  sc_signal<bool> io_axi_read_addr_ready;
  sc_signal<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_read_addr_bits_id;
  sc_signal<sc_bv<32 - kDBusBankAdj> > io_axi_read_addr_bits_addr;

  sc_signal<bool> io_axi_read_data_valid;
  sc_signal<bool> io_axi_read_data_ready;
  sc_signal<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_signal<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_read_data_bits_id;
  sc_signal<sc_bv<kL1DAxiBits> > io_axi_read_data_bits_data;

  sc_signal<bool> io_axi_write_addr_valid;
  sc_signal<bool> io_axi_write_addr_ready;
  sc_signal<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_write_addr_bits_id;
  sc_signal<sc_bv<32 - kDBusBankAdj> > io_axi_write_addr_bits_addr;

  sc_signal<bool> io_axi_write_data_valid;
  sc_signal<bool> io_axi_write_data_ready;
  sc_signal<sc_bv<kL1DAxiStrb> > io_axi_write_data_bits_strb;
  sc_signal<sc_bv<kL1DAxiBits> > io_axi_write_data_bits_data;

  sc_signal<bool> io_axi_write_resp_valid;
  sc_signal<bool> io_axi_write_resp_ready;
  sc_signal<sc_bv<2> > io_axi_write_resp_bits_resp;
  sc_signal<sc_bv<kL1DAxiId - kDBusBankAdj> > io_axi_write_resp_bits_id;

  sc_signal<bool> io_volt_sel;

  L1DCache_tb tb("L1DCache_tb", loops, true /*random*/);
#ifdef L1DCACHEBANK
  VL1DCacheBank l1dcache(name);
#else
  VL1DCache l1dcache(name);
#endif

  if (trace) {
    tb.trace(l1dcache);
  }

  l1dcache.clock(tb.clock);
  l1dcache.reset(tb.reset);

  BIND2(tb, l1dcache, io_flush_valid);
  BIND2(tb, l1dcache, io_flush_ready);
  BIND2(tb, l1dcache, io_flush_all);
  BIND2(tb, l1dcache, io_flush_clean);

  BIND2(tb, l1dcache, io_dbus_valid);
  BIND2(tb, l1dcache, io_dbus_ready);
  BIND2(tb, l1dcache, io_dbus_write);
  BIND2(tb, l1dcache, io_dbus_size);
  BIND2(tb, l1dcache, io_dbus_addr);
  BIND2(tb, l1dcache, io_dbus_adrx);
  BIND2(tb, l1dcache, io_dbus_rdata);
  BIND2(tb, l1dcache, io_dbus_wdata);
  BIND2(tb, l1dcache, io_dbus_wmask);

  BIND2(tb, l1dcache, io_axi_read_addr_valid);
  BIND2(tb, l1dcache, io_axi_read_addr_ready);
  BIND2(tb, l1dcache, io_axi_read_addr_bits_id);
  BIND2(tb, l1dcache, io_axi_read_addr_bits_addr);

  BIND2(tb, l1dcache, io_axi_read_data_valid);
  BIND2(tb, l1dcache, io_axi_read_data_ready);
  BIND2(tb, l1dcache, io_axi_read_data_bits_resp);
  BIND2(tb, l1dcache, io_axi_read_data_bits_id);
  BIND2(tb, l1dcache, io_axi_read_data_bits_data);

  BIND2(tb, l1dcache, io_axi_write_addr_valid);
  BIND2(tb, l1dcache, io_axi_write_addr_ready);
  BIND2(tb, l1dcache, io_axi_write_addr_bits_id);
  BIND2(tb, l1dcache, io_axi_write_addr_bits_addr);

  BIND2(tb, l1dcache, io_axi_write_data_valid);
  BIND2(tb, l1dcache, io_axi_write_data_ready);
  BIND2(tb, l1dcache, io_axi_write_data_bits_strb);
  BIND2(tb, l1dcache, io_axi_write_data_bits_data);

  BIND2(tb, l1dcache, io_axi_write_resp_valid);
  BIND2(tb, l1dcache, io_axi_write_resp_ready);
  BIND2(tb, l1dcache, io_axi_write_resp_bits_resp);
  BIND2(tb, l1dcache, io_axi_write_resp_bits_id);

  BIND2(tb, l1dcache, io_volt_sel);

  tb.start();
}

int sc_main(int argc, char *argv[]) {
  L1DCache_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
