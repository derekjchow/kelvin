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

#include <string>

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/flags/usage.h"
#include "absl/log/check.h"
#include "absl/log/log.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

// Headers for our Verilator model.
#include "VCoreMiniAxi.h"
#include "hdl/chisel/src/kelvin/VCoreMiniAxi_parameters.h"

/* clang-format off */
#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "checkers/pc-axi.h"
#include "tlm-bridges/tlm2axi-bridge.h"
#include "tlm-bridges/axi2tlm-bridge.h"
#include "traffic-generators/tg-tlm.h"
#include "traffic-generators/traffic-desc.h"

#include "tests/test-modules/signals-axi.h"
#include "tests/test-modules/utils.h"
/* clang-format on */

ABSL_FLAG(int, cycles, 100000000, "Simulation cycles");
ABSL_FLAG(bool, trace, false, "Dump VCD trace");
ABSL_FLAG(std::string, binary, "", "Binary to execute");
ABSL_FLAG(bool, debug_axi, false, "Enable AXI traffic debugging");

struct SlogIO {
  sc_signal<bool> valid;
  sc_signal<sc_bv<5>> addr;
  sc_signal<sc_bv<32>> data;
};

struct DebugIO {
  sc_signal<sc_bv<4>> en;
  sc_signal<sc_bv<32>> cycles;
  sc_signal<sc_bv<32>> addr_0;
  sc_signal<sc_bv<32>> addr_1;
  sc_signal<sc_bv<32>> addr_2;
  sc_signal<sc_bv<32>> addr_3;
  sc_signal<sc_bv<32>> inst_0;
  sc_signal<sc_bv<32>> inst_1;
  sc_signal<sc_bv<32>> inst_2;
  sc_signal<sc_bv<32>> inst_3;
};

// "Crossbar" containing a memory and a UART.
class Xbar : sc_core::sc_module {
 public:
  Xbar(sc_core::sc_module_name name) : sc_core::sc_module(std::move(name)) {
    memset(memory_, 0xa5, kMemorySizeBytes);
    socket_.register_b_transport(this, &Xbar::b_transport);
  }

  tlm_utils::simple_target_socket<Xbar>& socket() { return socket_; }

  void b_transport(tlm::tlm_generic_payload& trans, sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address();
    unsigned int len = trans.get_data_length();

    if (((addr & kMemoryAddr) == kMemoryAddr) &&
        (addr + len < kMemoryAddr + kMemorySizeBytes)) {
      memory_b_transport_(trans, delay);
    } else if ((addr & kUartAddr) == kUartAddr) {
      uart_b_transport_(trans, delay);
    } else {
      trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
      return;
    }
  }

 private:
  void memory_b_transport_(tlm::tlm_generic_payload& trans, sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address() & ~kMemoryAddr;
    unsigned char* ptr = trans.get_data_ptr();
    unsigned int len = trans.get_data_length();
    unsigned int streaming_width = trans.get_streaming_width();
    unsigned int be_len = trans.get_byte_enable_length();
    if (streaming_width == 0) {
      streaming_width = len;
    }
    if (be_len || streaming_width != len) {
      trans.set_response_status(tlm::TLM_BYTE_ENABLE_ERROR_RESPONSE);
      SC_REPORT_FATAL("Memory", "BE unsupported\n");
      return;
    } else {
      if ((addr + len) > sc_dt::uint64(kMemorySizeBytes)) {
        trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
        SC_REPORT_FATAL("Memory", "Bad address\n");
        return;
      }

      if (trans.is_read()) {
        memcpy(ptr, memory_ + addr, len);
      } else if (trans.is_write()) {
        memcpy(memory_ + addr, ptr, len);
      } else {
        trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
        SC_REPORT_FATAL("Memory", "Bad command\n");
        return;
      }
    }
  }

  void uart_b_transport_(tlm::tlm_generic_payload& trans, sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address() & ~kUartAddr;
    unsigned char* ptr = trans.get_data_ptr();
    unsigned int len = trans.get_data_length();
    unsigned int streaming_width = trans.get_streaming_width();
    unsigned char* be = trans.get_byte_enable_ptr();
    unsigned int be_len = trans.get_byte_enable_length();
    if (streaming_width == 0) {
      streaming_width = len;
    }

    if (be_len || streaming_width != len) {
      for (unsigned int pos = 0; pos < len / 8; ++pos) {
        bool do_access = true;
        if (be_len) {
          do_access = be[pos % (be_len / 8)] == TLM_BYTE_ENABLED;
        }
        if (do_access) {
          if (addr != 0 || trans.is_read()) {
            trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
            SC_REPORT_FATAL("Uart", "Unsupported access\n");
            return;
          }
          if (ptr[pos] == '\n') {
            uart_buffer_.push_back('\0');
            LOG(INFO) << uart_buffer_.data();
            uart_buffer_.clear();
          } else {
            uart_buffer_.push_back(ptr[pos]);
          }
        }
      }
    } else {
      trans.set_response_status(tlm::TLM_BYTE_ENABLE_ERROR_RESPONSE);
      SC_REPORT_FATAL("Uart", "Non-BE unsupported\n");
      return;
    }
  }

  static constexpr uint32_t kMemoryAddr = 0x20000000;
  static constexpr size_t kMemorySizeBytes = 0x400000;
  static constexpr uint32_t kUartAddr = 0x54000000;
  uint8_t memory_[kMemorySizeBytes];
  std::vector<char> uart_buffer_;
  tlm_utils::simple_target_socket<Xbar> socket_;
};

struct CoreMiniAxi_tb : Sysc_tb {
  sc_in<bool> io_halted;
  sc_in<bool> io_fault;
  sc_in<bool> io_wfi;
  sc_out<bool> io_irqn;

  CoreMiniAxi_tb(sc_module_name n, int loops, bool random, std::string binary)
      : Sysc_tb(n, loops, random),
        file_name_(binary),
        tg_("traffic_generator"),
        tlm2axi_bridge_("tlm2axi_bridge"),
        axi2tlm_bridge_("axi2tlm_bridge"),
        tlm2axi_checker_("tlm2axi_checker"),
        axi2tlm_checker_("axi2tlm_checker"),
        tlm2axi_signals_("tlm2axi_signals"),
        axi2tlm_signals_("axi2tlm_signals"),
        xbar_("xbar") {
    if (CoreMiniAxi_tb::singleton_ != nullptr) {
      CHECK(false);
    }
    CoreMiniAxi_tb::singleton_ = this;

    // TLM2AXI
    tlm2axi_bridge_.clk(clock);
    tlm2axi_bridge_.resetn(resetn);
    // AXI Protocol checker
    tlm2axi_checker_.clk(clock);
    tlm2axi_checker_.resetn(resetn);

    // AXI2TLM
    axi2tlm_bridge_.clk(clock);
    axi2tlm_bridge_.resetn(resetn);
    axi2tlm_checker_.clk(clock);
    axi2tlm_checker_.resetn(resetn);

    tlm2axi_signals_.connect(tlm2axi_bridge_);
    tlm2axi_signals_.connect(tlm2axi_checker_);
    axi2tlm_signals_.connect(axi2tlm_bridge_);
    axi2tlm_signals_.connect(axi2tlm_checker_);

    int fd = open(file_name_.c_str(), 0);
    CHECK(fd > 0);
    struct stat sb;
    CHECK(fstat(fd, &sb) == 0);
    file_size_ = sb.st_size;
    file_data_ = mmap(nullptr, file_size_, PROT_READ, MAP_PRIVATE, fd, 0);
    CHECK(file_data_ != MAP_FAILED);
    close(fd);

    // Transaction to fill ITCM with the provided binary.
    uint8_t* data8 = reinterpret_cast<uint8_t*>(file_data_);
    bin_transfer_ =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(0, data8, file_size_), utils::Read(0, file_size_),
             utils::Expect(data8, file_size_)})));

    // Transaction to disable the internal clock gate.
    disable_cg_transfer_ =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(csr_addr_, DATA(1, 0, 0, 0)), utils::Read(csr_addr_, 4),
             utils::Expect(DATA(1, 0, 0, 0), 4)})));

    // Transaction to release the reset signal.
    release_reset_transfer_ =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(csr_addr_, DATA(0, 0, 0, 0)), utils::Read(csr_addr_, 4),
             utils::Expect(DATA(0, 0, 0, 0), 4)})));

    // Transaction to read the status register.
    status_read_transfer_ =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Read(csr_addr_ + 0x8, 4), utils::Expect(DATA(1, 0, 0, 0), 4)})));

    DataTransfer wrap_write, wrap_read, wrap_expect;
    /* WRAP */
    wrap_write.addr = 0x0;
    wrap_write.cmd = DataTransfer::WRITE;
    wrap_write.data =
        DATA(0x81, 0x82, 0x83, 0x84, 0x71, 0x72, 0x73, 0x74, 0x91, 0x92, 0x93,
             0x94, 0x81, 0x82, 0x83, 0x84, 0xa1, 0xa2, 0xa3, 0xa4, 0x91, 0x92,
             0x93, 0x94, 0xb1, 0xb2, 0xb3, 0xb4, 0xa1, 0xa2, 0xa3, 0xa4);
    wrap_write.byte_enable = nullptr;
    wrap_write.length = 32;
    wrap_write.streaming_width = 32;
    wrap_write.ext.gen_attr.enabled = true;
    wrap_write.ext.gen_attr.wrap = true;

    wrap_read.addr = 0x0;
    wrap_read.cmd = DataTransfer::READ;
    wrap_read.byte_enable = nullptr;
    wrap_read.length = 32;
    wrap_read.streaming_width = 32;
    wrap_read.ext.gen_attr.enabled = true;
    wrap_read.ext.gen_attr.wrap = true;
    wrap_transfer_ =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>({
            utils::Write(0,
                         DATA(0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad,
                              0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad,
                              0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad,
                              0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad),
                         32),
            wrap_write,
            wrap_read,
            utils::Expect(DATA(0xa1, 0xa2, 0xa3, 0xa4, 0x91, 0x92, 0x93, 0x94,
                               0xb1, 0xb2, 0xb3, 0xb4, 0xa1, 0xa2, 0xa3, 0xa4,
                               0xa1, 0xa2, 0xa3, 0xa4, 0x91, 0x92, 0x93, 0x94,
                               0xb1, 0xb2, 0xb3, 0xb4, 0xa1, 0xa2, 0xa3, 0xa4),
                          32),
        })));

    tg_.setStartDelay(sc_time(5, SC_US));
    tg_.addTransfers(bin_transfer_.get(), 0,
                     CoreMiniAxi_tb::bin_transfer_done_cb);
    tg_.socket.bind(tlm2axi_bridge_.tgt_socket);
    if (absl::GetFlag(FLAGS_debug_axi)) {
      tg_.enableDebug();
    }

    axi2tlm_bridge_.socket.bind(xbar_.socket());
  }

  ~CoreMiniAxi_tb() {
    if (file_data_) {
      munmap(file_data_, file_size_);
      file_data_ = nullptr;
      file_size_ = 0;
    }
    singleton_ = nullptr;
  }

  void posedge() {
    check(!io_fault, "io_fault");
    static bool enqueued_csr_read = false;
    if (io_halted && !enqueued_csr_read) {
      enqueued_csr_read = true;
      tg_.addTransfers(status_read_transfer_.get(), 0,
                       CoreMiniAxi_tb::status_read_transfer_done_cb);
    }

    static bool wfi_seen = false;
    if (io_wfi && !wfi_seen) {
      io_irqn = false;
      wfi_seen = true;
    } else if (wfi_seen) {
      io_irqn = true;
      wfi_seen = false;
    } else {
      io_irqn = true;
    }
  }

  typedef AXISignals<KP_axi2AddrBits,  // ADDR_WIDTH
                     KP_lsuDataBits,   // DATA_WIDTH
                     KP_axi2IdBits,    // ID_WIDTH
                     8,                // AxLEN_WIDTH
                     2,                // AxLOCK_WIDTH
                     0, 0, 0, 0, 0     // User
                     >
      CoreMiniAxiSignals;
  CoreMiniAxiSignals* tlm2axi_signals() { return &tlm2axi_signals_; }
  CoreMiniAxiSignals* axi2tlm_signals() { return &axi2tlm_signals_; }

  static void bin_transfer_done_cb(TLMTrafficGenerator* gen, int threadId) {
    getSingleton()->bin_transfer_done_cb_(gen, threadId);
  }
  static void disable_cg_transfer_done_cb(TLMTrafficGenerator* gen,
                                          int threadId) {
    getSingleton()->disable_cg_transfer_done_cb_(gen, threadId);
  }
  static void status_read_transfer_done_cb(TLMTrafficGenerator* gen,
                                           int threadId) {
    getSingleton()->status_read_transfer_done_cb_(gen, threadId);
  }
  static void wrap_transfer_done_cb(TLMTrafficGenerator* gen, int threadId) {
    getSingleton()->wrap_transfer_done_cb_(gen, threadId);
  }

 private:
  std::string file_name_;
  TLMTrafficGenerator tg_;

  tlm2axi_bridge<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8, 2, 0, 0, 0,
                 0, 0>
      tlm2axi_bridge_;
  axi2tlm_bridge<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8, 2, 0, 0, 0,
                 0, 0>
      axi2tlm_bridge_;

  typedef AXIProtocolChecker<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8,
                             2, 0, 0, 0, 0, 0>
      CoreMiniAxiProtocolChecker;
  CoreMiniAxiProtocolChecker tlm2axi_checker_;
  CoreMiniAxiProtocolChecker axi2tlm_checker_;
  // NB: Used to bind bridge and checker, DUT needs manual wiring.
  CoreMiniAxiSignals tlm2axi_signals_;
  CoreMiniAxiSignals axi2tlm_signals_;
  Xbar xbar_;
  size_t file_size_;
  void* file_data_ = nullptr;

  std::unique_ptr<TrafficDesc> bin_transfer_;
  void bin_transfer_done_cb_(TLMTrafficGenerator* gen, int threadId) {
    tg_.addTransfers(disable_cg_transfer_.get(), 0,
                     CoreMiniAxi_tb::disable_cg_transfer_done_cb);
  }

  std::unique_ptr<TrafficDesc> disable_cg_transfer_;
  void disable_cg_transfer_done_cb_(TLMTrafficGenerator* gen, int threadId) {
    tg_.addTransfers(release_reset_transfer_.get(), 0);
  }

  std::unique_ptr<TrafficDesc> release_reset_transfer_;

  std::unique_ptr<TrafficDesc> status_read_transfer_;
  void status_read_transfer_done_cb_(TLMTrafficGenerator* gen, int threadId) {
    tg_.addTransfers(wrap_transfer_.get(), 0,
                     CoreMiniAxi_tb::wrap_transfer_done_cb);
  }

  std::unique_ptr<TrafficDesc> wrap_transfer_;
  void wrap_transfer_done_cb_(TLMTrafficGenerator* gen, int threadId) {
    sc_stop();
  }

  static CoreMiniAxi_tb* singleton_;
  static CoreMiniAxi_tb* getSingleton() { return singleton_; }
  static constexpr uint32_t csr_addr_ = 0x30000;
};
CoreMiniAxi_tb* CoreMiniAxi_tb::singleton_ = nullptr;

static void run(const char* name, const std::string binary, const int cycles,
                const bool trace) {
  VCoreMiniAxi core(name);

  CoreMiniAxi_tb tb("CoreMiniAxi_tb", cycles, /* random= */ false, binary);

  sc_signal<bool> io_halted;
  sc_signal<bool> io_fault;
  sc_signal<bool> io_wfi;
  sc_signal<bool> io_irqn;
  tb.io_halted(io_halted);
  tb.io_fault(io_fault);
  tb.io_wfi(io_wfi);
  tb.io_irqn(io_irqn);

  core.io_aclk(tb.clock);
  core.io_aresetn(tb.resetn);
  core.io_halted(io_halted);
  core.io_fault(io_fault);
  core.io_wfi(io_wfi);
  core.io_irqn(io_irqn);

  SlogIO slog;
  core.io_slog_valid(slog.valid);
  core.io_slog_addr(slog.addr);
  core.io_slog_data(slog.data);

  DebugIO debug;
  core.io_debug_en(debug.en);
  core.io_debug_cycles(debug.cycles);
  core.io_debug_addr_0(debug.addr_0);
  core.io_debug_addr_1(debug.addr_1);
  core.io_debug_addr_2(debug.addr_2);
  core.io_debug_addr_3(debug.addr_3);
  core.io_debug_inst_0(debug.inst_0);
  core.io_debug_inst_1(debug.inst_1);
  core.io_debug_inst_2(debug.inst_2);
  core.io_debug_inst_3(debug.inst_3);

  // AR
  core.io_axi_master_read_addr_ready(tb.axi2tlm_signals()->arready);
  core.io_axi_master_read_addr_valid(tb.axi2tlm_signals()->arvalid);
  core.io_axi_master_read_addr_bits_addr(tb.axi2tlm_signals()->araddr);
  core.io_axi_master_read_addr_bits_prot(tb.axi2tlm_signals()->arprot);
  core.io_axi_master_read_addr_bits_id(tb.axi2tlm_signals()->arid);
  core.io_axi_master_read_addr_bits_len(tb.axi2tlm_signals()->arlen);
  core.io_axi_master_read_addr_bits_size(tb.axi2tlm_signals()->arsize);
  core.io_axi_master_read_addr_bits_burst(tb.axi2tlm_signals()->arburst);
  core.io_axi_master_read_addr_bits_lock(tb.axi2tlm_signals()->arlock);
  core.io_axi_master_read_addr_bits_cache(tb.axi2tlm_signals()->arcache);
  core.io_axi_master_read_addr_bits_qos(tb.axi2tlm_signals()->arqos);
  core.io_axi_master_read_addr_bits_region(tb.axi2tlm_signals()->arregion);
  // R
  core.io_axi_master_read_data_ready(tb.axi2tlm_signals()->rready);
  core.io_axi_master_read_data_valid(tb.axi2tlm_signals()->rvalid);
  core.io_axi_master_read_data_bits_data(tb.axi2tlm_signals()->rdata);
  core.io_axi_master_read_data_bits_id(tb.axi2tlm_signals()->rid);
  core.io_axi_master_read_data_bits_resp(tb.axi2tlm_signals()->rresp);
  core.io_axi_master_read_data_bits_last(tb.axi2tlm_signals()->rlast);
  // AW
  core.io_axi_master_write_addr_ready(tb.axi2tlm_signals()->awready);
  core.io_axi_master_write_addr_valid(tb.axi2tlm_signals()->awvalid);
  core.io_axi_master_write_addr_bits_addr(tb.axi2tlm_signals()->awaddr);
  core.io_axi_master_write_addr_bits_prot(tb.axi2tlm_signals()->awprot);
  core.io_axi_master_write_addr_bits_id(tb.axi2tlm_signals()->awid);
  core.io_axi_master_write_addr_bits_len(tb.axi2tlm_signals()->awlen);
  core.io_axi_master_write_addr_bits_size(tb.axi2tlm_signals()->awsize);
  core.io_axi_master_write_addr_bits_burst(tb.axi2tlm_signals()->awburst);
  core.io_axi_master_write_addr_bits_lock(tb.axi2tlm_signals()->awlock);
  core.io_axi_master_write_addr_bits_cache(tb.axi2tlm_signals()->awcache);
  core.io_axi_master_write_addr_bits_qos(tb.axi2tlm_signals()->awqos);
  core.io_axi_master_write_addr_bits_region(tb.axi2tlm_signals()->awregion);
  // W
  core.io_axi_master_write_data_ready(tb.axi2tlm_signals()->wready);
  core.io_axi_master_write_data_valid(tb.axi2tlm_signals()->wvalid);
  core.io_axi_master_write_data_bits_data(tb.axi2tlm_signals()->wdata);
  core.io_axi_master_write_data_bits_last(tb.axi2tlm_signals()->wlast);
  core.io_axi_master_write_data_bits_strb(tb.axi2tlm_signals()->wstrb);
  // B
  core.io_axi_master_write_resp_ready(tb.axi2tlm_signals()->bready);
  core.io_axi_master_write_resp_valid(tb.axi2tlm_signals()->bvalid);
  core.io_axi_master_write_resp_bits_id(tb.axi2tlm_signals()->bid);
  core.io_axi_master_write_resp_bits_resp(tb.axi2tlm_signals()->bresp);

  // AR
  core.io_axi_slave_read_addr_ready(tb.tlm2axi_signals()->arready);
  core.io_axi_slave_read_addr_valid(tb.tlm2axi_signals()->arvalid);
  core.io_axi_slave_read_addr_bits_addr(tb.tlm2axi_signals()->araddr);
  core.io_axi_slave_read_addr_bits_prot(tb.tlm2axi_signals()->arprot);
  core.io_axi_slave_read_addr_bits_id(tb.tlm2axi_signals()->arid);
  core.io_axi_slave_read_addr_bits_len(tb.tlm2axi_signals()->arlen);
  core.io_axi_slave_read_addr_bits_size(tb.tlm2axi_signals()->arsize);
  core.io_axi_slave_read_addr_bits_burst(tb.tlm2axi_signals()->arburst);
  core.io_axi_slave_read_addr_bits_lock(tb.tlm2axi_signals()->arlock);
  core.io_axi_slave_read_addr_bits_cache(tb.tlm2axi_signals()->arcache);
  core.io_axi_slave_read_addr_bits_qos(tb.tlm2axi_signals()->arqos);
  core.io_axi_slave_read_addr_bits_region(tb.tlm2axi_signals()->arregion);
  // R
  core.io_axi_slave_read_data_ready(tb.tlm2axi_signals()->rready);
  core.io_axi_slave_read_data_valid(tb.tlm2axi_signals()->rvalid);
  core.io_axi_slave_read_data_bits_data(tb.tlm2axi_signals()->rdata);
  core.io_axi_slave_read_data_bits_id(tb.tlm2axi_signals()->rid);
  core.io_axi_slave_read_data_bits_resp(tb.tlm2axi_signals()->rresp);
  core.io_axi_slave_read_data_bits_last(tb.tlm2axi_signals()->rlast);
  // AW
  core.io_axi_slave_write_addr_ready(tb.tlm2axi_signals()->awready);
  core.io_axi_slave_write_addr_valid(tb.tlm2axi_signals()->awvalid);
  core.io_axi_slave_write_addr_bits_addr(tb.tlm2axi_signals()->awaddr);
  core.io_axi_slave_write_addr_bits_prot(tb.tlm2axi_signals()->awprot);
  core.io_axi_slave_write_addr_bits_id(tb.tlm2axi_signals()->awid);
  core.io_axi_slave_write_addr_bits_len(tb.tlm2axi_signals()->awlen);
  core.io_axi_slave_write_addr_bits_size(tb.tlm2axi_signals()->awsize);
  core.io_axi_slave_write_addr_bits_burst(tb.tlm2axi_signals()->awburst);
  core.io_axi_slave_write_addr_bits_lock(tb.tlm2axi_signals()->awlock);
  core.io_axi_slave_write_addr_bits_cache(tb.tlm2axi_signals()->awcache);
  core.io_axi_slave_write_addr_bits_qos(tb.tlm2axi_signals()->awqos);
  core.io_axi_slave_write_addr_bits_region(tb.tlm2axi_signals()->awregion);
  // W
  core.io_axi_slave_write_data_ready(tb.tlm2axi_signals()->wready);
  core.io_axi_slave_write_data_valid(tb.tlm2axi_signals()->wvalid);
  core.io_axi_slave_write_data_bits_data(tb.tlm2axi_signals()->wdata);
  core.io_axi_slave_write_data_bits_last(tb.tlm2axi_signals()->wlast);
  core.io_axi_slave_write_data_bits_strb(tb.tlm2axi_signals()->wstrb);
  // B
  core.io_axi_slave_write_resp_ready(tb.tlm2axi_signals()->bready);
  core.io_axi_slave_write_resp_valid(tb.tlm2axi_signals()->bvalid);
  core.io_axi_slave_write_resp_bits_id(tb.tlm2axi_signals()->bid);
  core.io_axi_slave_write_resp_bits_resp(tb.tlm2axi_signals()->bresp);

  if (trace) {
    tb.trace(&core);
  }

  tb.start();
}

extern "C" int sc_main(int argc, char** argv) {
  absl::SetProgramUsageMessage("CoreMiniAxi simulator");
  auto args = absl::ParseCommandLine(argc, argv);
  argc = args.size();
  argv = &args[0];

  if (absl::GetFlag(FLAGS_binary) == "") {
    LOG(ERROR) << "--binary is required!";
    return -1;
  }

  run(Sysc_tb::get_name(argv[0]), absl::GetFlag(FLAGS_binary),
      absl::GetFlag(FLAGS_cycles), absl::GetFlag(FLAGS_trace));

  return 0;
}