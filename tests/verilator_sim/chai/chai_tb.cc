// Copyright 2024 Google LLC
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

#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include <algorithm>

#include "VChAI.h"  // Generated
#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/flags/usage.h"
#include "absl/log/check.h"
#include "absl/log/log.h"
#include "tests/verilator_sim/sysc_module.h"
#include "tests/verilator_sim/sysc_tb.h"

ABSL_FLAG(int, cycles, 10'000'000, "Simulation cycles");
ABSL_FLAG(bool, trace, false, "Enable tracing");

namespace {

struct ChAI_tb : Sysc_tb {
  sc_in<bool> io_halted;
  sc_in<bool> io_fault;
  using Sysc_tb::Sysc_tb;  // constructor

  void posedge() {
    check(!io_fault, "io_fault");
    if (io_halted) sc_stop();
  }
};

struct Memory : Sysc_module {
  sc_out<sc_bv<17> > write_address;
  sc_out<bool> write_enable;
  sc_out<sc_bv<256> > write_data;
  sc_out<bool> loadedn;

  sc_bv<256> wdata = 0;

  Memory(sc_module_name n, const char* path)
      : Sysc_module(n), path_(path), offset_(0) {
    int fd = open(path, 0);
    CHECK(fd > 0);
    struct stat sb;
    CHECK(fstat(fd, &sb) == 0);
    LOG(INFO) << "Input file size: " << sb.st_size;
    size_ = sb.st_size;
    if (size_ % 256 != 0) {
      LOG(FATAL) << "Please align your file size to 256 bytes.";
    }
    void* data = mmap(nullptr, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    CHECK(data != MAP_FAILED);
    close(fd);
    data_ = reinterpret_cast<uint8_t*>(data);
    data32_ = reinterpret_cast<uint32_t*>(data_);
  }

  ~Memory() {
    LOG(INFO) << "Cycles at teardown: " << cycle_;
    munmap(data_, size_);
    data_ = nullptr;
    data32_ = nullptr;
  }

  void eval() {
    if (reset) {
      cycle_ = 0;
      loadedn = true;
      write_address = 0;
      write_enable = false;
      write_data = 0;
    }
    if (clock->posedge()) {
      cycle_++;
      if (offset_ == size_) {
        static bool logged = false;
        if (!logged) {
          LOG(INFO) << "[" << cycle_ << "] setting loadedn to false";
          logged = true;
        }
        loadedn = false;
        write_enable = false;
      }
      if (offset_ < size_) {
        const size_t wordsPerWrite = 32 / sizeof(uint32_t);  // 32B / 4B
        for (size_t i = 0; i < wordsPerWrite; i++) {
          uint32_t val = data32_[(offset_ / sizeof(uint32_t)) + i];
          wdata.set_word(i, val);
        }
        write_data.write(wdata);
        write_enable = true;
        write_address = offset_ >> 5;
        offset_ += 32;  // 32 bytes == 8 words
      }
    }
    if (cycle_ % 10000 == 0) {
      LOG(INFO) << "Cycle " << cycle_;
    }
  }

 private:
  uint32_t cycle_ = 0;
  const char* path_;
  size_t offset_;     // bytes
  size_t size_;       // bytes
  uint8_t* data_;     // bytes
  uint32_t* data32_;  // words
};

struct Uart : Sysc_module {
  sc_in<bool> rx;
  sc_out<bool> tx;
  Uart(sc_module_name n) : Sysc_module(n) {}
  uint64_t kBaudrate = 115200;
  uint64_t kFrequencyHz = 10000000; // 10MHz
  uint32_t nco_rx = static_cast<uint32_t>((kBaudrate << 20) / kFrequencyHz);
  void eval() {
    if (reset) {
      last_rx_val_ = true;
      uart_baud_ctr_ = 0;
      baud_cnt_ = 0;
      s_ = State::sIdle;
      bit_in_pkt_ = 0;
      rx_data_ = 0;
    }
    if (clock->posedge()) {
      if (uart_baud_ctr_ & 0x10000) {
        baud_cnt_++;
      }
      if (baud_cnt_ == 16) {
        bool rx_val = rx;
        bool edge = rx_val != last_rx_val_;
        switch (s_) {
          case State::sIdle: {
            if (edge) {
              s_ = State::sStarted;
              bit_in_pkt_ = 0;
            }
            break;
          }
          case State::sStarted: {
            if (bit_in_pkt_ == 8) {
              LOG(INFO) << "UART val: " << (char)rx_data_;
              rx_data_ = 0;
              s_ = State::sIdle;
            }
            rx_data_ = (rx_data_ >> 1) | ((uint8_t)rx_val << 7);
            bit_in_pkt_++;
            break;
          }
        }
        last_rx_val_ = rx_val;
        baud_cnt_ = 0;
      }
      uart_baud_ctr_ = (uart_baud_ctr_ & 0xFFFF) + nco_rx;
    }
  }

 private:
  enum class State { sIdle, sStarted };
  bool last_rx_val_ = true;
  size_t uart_baud_ctr_ = 0;
  size_t baud_cnt_ = 0;
  State s_ = State::sIdle;
  size_t bit_in_pkt_ = 0;
  uint8_t rx_data_ = 0;
};

void ChAI_run(const char* name, const char* path, const int cycles,
              const bool trace) {
  VChAI chai(name);
  ChAI_tb tb("ChAI_tb", cycles, /* random= */ false);
  Memory mem("ChAI_mem", path);
  Uart uart("ChAI_uart");

  sc_signal<bool> io_halted, io_fault;
  sc_signal<sc_bv<17> > io_sram_write_address;
  sc_signal<bool> io_sram_write_enable;
  sc_signal<sc_bv<256> > io_sram_write_data;
  sc_signal<bool> mem_loadedn;
  sc_signal<bool> uart_tx;  // Output from ChAI
  sc_signal<bool> uart_rx;  // Input to ChAI

  tb.io_halted(io_halted);
  tb.io_fault(io_fault);

  chai.io_clk_i(tb.clock);
  chai.io_rst_ni(tb.resetn);
  chai.io_sram_write_address(io_sram_write_address);
  chai.io_sram_write_enable(io_sram_write_enable);
  chai.io_sram_write_data(io_sram_write_data);
  chai.io_finish(io_halted);
  chai.io_fault(io_fault);
  chai.io_freeze(mem_loadedn);
  chai.io_uart_tx(uart_tx);
  chai.io_uart_rx(uart_rx);

  mem.clock(tb.clock);
  mem.reset(tb.reset);
  mem.write_address(io_sram_write_address);
  mem.write_enable(io_sram_write_enable);
  mem.write_data(io_sram_write_data);
  mem.loadedn(mem_loadedn);

  uart.clock(tb.clock);
  uart.reset(tb.reset);
  uart.rx(uart_tx);
  uart.tx(uart_rx);

  if (trace) {
    tb.trace(&chai);
  }

  tb.start();
}

}  // namespace

extern "C" int sc_main(int argc, char** argv) {
  absl::SetProgramUsageMessage("ChAI sim");
  auto out_args = absl::ParseCommandLine(argc, argv);
  argc = out_args.size();
  argv = &out_args[0];
  if (argc < 2) {
    LOG(FATAL) << "Need an input file";
  }
  const char* path = argv[1];
  ChAI_run(Sysc_tb::get_name(argv[0]), path, absl::GetFlag(FLAGS_cycles),
           absl::GetFlag(FLAGS_trace));
  return 0;
}