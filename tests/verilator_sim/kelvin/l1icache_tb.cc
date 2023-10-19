// Copyright 2023 Google LLC

#include "tests/verilator_sim/sysc_tb.h"

#include "VL1ICache.h"

#include "tests/verilator_sim/kelvin/kelvin_cfg.h"

struct L1ICache_tb : Sysc_tb {
  sc_out<bool> io_flush_valid;
  sc_in<bool> io_flush_ready;
  sc_out<bool> io_ibus_valid;
  sc_in<bool> io_ibus_ready;
  sc_out<sc_bv<32> > io_ibus_addr;
  sc_in<sc_bv<kL1IAxiBits> > io_ibus_rdata;
  sc_in<bool> io_axi_read_addr_valid;
  sc_out<bool> io_axi_read_addr_ready;
  sc_in<sc_bv<kL1IAxiId> > io_axi_read_addr_bits_id;
  sc_in<sc_bv<32> > io_axi_read_addr_bits_addr;
  sc_out<bool> io_axi_read_data_valid;
  sc_in<bool> io_axi_read_data_ready;
  sc_out<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_out<sc_bv<kL1IAxiId> > io_axi_read_data_bits_id;
  sc_out<sc_bv<kL1IAxiBits> > io_axi_read_data_bits_data;
  sc_in<bool> io_volt_sel;

  using Sysc_tb::Sysc_tb;

  void posedge() {
    // flush
    io_flush_valid = rand_int(0, 255) == 0;

    // ibus
    if (ibus_resp_pipeline_) {
      ibus_resp_pipeline_ = false;
      for (int i = 0; i < ibusw_; ++i) {
        uint32_t ref = ibus_resp_data_ + i * 4;
        uint32_t dut = io_ibus_rdata.read().get_word(i);
        check(ref == dut, "ibus read data");
      }
    }

    if (io_ibus_valid && io_ibus_ready) {
      ibus_resp_pipeline_ = true;
      ibus_resp_data_ = io_ibus_addr.read().get_word(0) & ~(ibusb_ - 1);

      command_t cmd({io_ibus_addr.read().get_word(0)});
      history_.write(cmd);
      if (history_.count() > 16) {
        history_.remove();
      }
    }

    if (!io_ibus_valid || io_ibus_ready) {  // latch transaction
      command_t cmd;
      bool newaddr = rand_int(0, 3) == 0 || !history_.rand(cmd);
      uint32_t addr = newaddr ? rand_uint32() : cmd.addr;
      if (rand_int(0, 7) == 0) {
        addr &= 0x3fff;
      }
      io_ibus_valid = rand_bool();
      io_ibus_addr = addr;
    }

    timeout_ = io_ibus_ready ? 0 : timeout_ + io_ibus_valid;
    check(timeout_ < 100, "ibus timeout");

    // kxi_read_addr
    io_axi_read_addr_ready = rand_bool();

    if (io_axi_read_addr_valid && io_axi_read_addr_ready) {
      uint32_t id = io_axi_read_addr_bits_id.read().get_word(0);
      uint32_t addr = io_axi_read_addr_bits_addr.read().get_word(0);
      response_t resp({id, addr});
      resp_.write(resp);
    }

    // kxi_read_data
    io_axi_read_data_valid = false;
    io_axi_read_data_bits_id = 0;
    io_axi_read_data_bits_data = 0;

    if (io_axi_read_data_valid && io_axi_read_data_ready) {
      check(resp_.remove(), "no response to erase");
      resp_.shuffle();
    }

    response_t resp;
    if (resp_.next(resp)) {
      io_axi_read_data_valid = rand_bool();
      io_axi_read_data_bits_id = resp.id;
      uint32_t data = resp.data;
      sc_bv<kL1IAxiBits> out;
      for (int i = 0; i < axiw_; ++i) {
        out.set_word(i, data);
        data += 4;
      }
      io_axi_read_data_bits_data = out;
    }
  }

 private:
  struct command_t {
    uint32_t addr;
  };

  struct response_t {
    uint32_t id;
    uint32_t data;
  };

  const int ibusb_ = kL1IAxiBits / 8;
  const int ibusw_ = kL1IAxiBits / 32;
  const int axib_ = kL1IAxiBits / 8;
  const int axiw_ = kL1IAxiBits / 32;

  int timeout_ = 0;

  bool ibus_resp_pipeline_ = false;
  uint32_t ibus_resp_data_ = 0;
  fifo_t<command_t> history_;
  fifo_t<response_t> resp_;
};

static void L1ICache_test(char* name, int loops, bool trace) {
  sc_signal<bool> io_flush_valid;
  sc_signal<bool> io_flush_ready;
  sc_signal<bool> io_ibus_valid;
  sc_signal<bool> io_ibus_ready;
  sc_signal<sc_bv<32> > io_ibus_addr;
  sc_signal<sc_bv<kL1IAxiBits> > io_ibus_rdata;
  sc_signal<bool> io_axi_read_addr_valid;
  sc_signal<bool> io_axi_read_addr_ready;
  sc_signal<sc_bv<kL1IAxiId> > io_axi_read_addr_bits_id;
  sc_signal<sc_bv<32> > io_axi_read_addr_bits_addr;
  sc_signal<bool> io_axi_read_data_valid;
  sc_signal<bool> io_axi_read_data_ready;
  sc_signal<sc_bv<2> > io_axi_read_data_bits_resp;
  sc_signal<sc_bv<kL1IAxiId> > io_axi_read_data_bits_id;
  sc_signal<sc_bv<kL1IAxiBits> > io_axi_read_data_bits_data;
  sc_signal<bool> io_volt_sel;

  L1ICache_tb tb("L1ICache_tb", loops, true /*random*/);
  VL1ICache l1icache(name);

  if (trace) {
    tb.trace(l1icache);
  }

  l1icache.clock(tb.clock);
  l1icache.reset(tb.reset);
  BIND2(tb, l1icache, io_flush_valid);
  BIND2(tb, l1icache, io_flush_ready);
  BIND2(tb, l1icache, io_ibus_valid);
  BIND2(tb, l1icache, io_ibus_ready);
  BIND2(tb, l1icache, io_ibus_addr);
  BIND2(tb, l1icache, io_ibus_rdata);
  BIND2(tb, l1icache, io_axi_read_addr_valid);
  BIND2(tb, l1icache, io_axi_read_addr_ready);
  BIND2(tb, l1icache, io_axi_read_addr_bits_id);
  BIND2(tb, l1icache, io_axi_read_addr_bits_addr);
  BIND2(tb, l1icache, io_axi_read_data_ready);
  BIND2(tb, l1icache, io_axi_read_data_valid);
  BIND2(tb, l1icache, io_axi_read_data_bits_data);
  BIND2(tb, l1icache, io_axi_read_data_bits_id);
  BIND2(tb, l1icache, io_axi_read_data_bits_resp);
  BIND2(tb, l1icache, io_volt_sel);

  tb.start();
}

int sc_main(int argc, char *argv[]) {
  L1ICache_test(Sysc_tb::get_name(argv[0]), 1000000, false);
  return 0;
}
