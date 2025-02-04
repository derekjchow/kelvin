// Copyright 2025 Google LLC
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

#include "tests/verilator_sim/kelvin/core_mini_axi_tb.h"

#include <elf.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include <cstddef>
#include <memory>
#include <string>

#include "absl/log/check.h"
#include "absl/log/log.h"
#include "absl/status/status.h"
#include "hdl/chisel/src/kelvin/VCoreMiniAxi_parameters.h"
#include "tests/verilator_sim/elf.h"
#include "tests/verilator_sim/sysc_tb.h"

/* clang-format off */
#include <systemc>
#include "traffic-generators/traffic-desc.h"
namespace internal {
#include "tests/test-modules/utils.h"
}
using namespace internal;
/* clang-format on */

CoreMiniAxi_tb::CoreMiniAxi_tb(sc_module_name n, int loops, bool random,
                               std::string binary, bool debug_axi,
                               std::optional<std::function<void()>> wfi_cb,
                               std::optional<std::function<void()>> halted_cb)
    : Sysc_tb(n, loops, random),
      tg_("traffic_generator"),
      tlm2axi_bridge_("tlm2axi_bridge"),
      axi2tlm_bridge_("axi2tlm_bridge"),
      tlm2axi_checker_("tlm2axi_checker"),
      axi2tlm_checker_("axi2tlm_checker"),
      tlm2axi_signals_("tlm2axi_signals"),
      axi2tlm_signals_("axi2tlm_signals"),
      xbar_("xbar"),
      wfi_cb_(wfi_cb),
      halted_cb_(halted_cb) {
  if (CoreMiniAxi_tb::singleton_ != nullptr) {
    CHECK(false);
  }
  CoreMiniAxi_tb::singleton_ = this;
  core_ = std::make_unique<VCoreMiniAxi>("core");

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

  Connect();

  tg_.setStartDelay(sc_time(5, SC_US));
  tg_.socket.bind(tlm2axi_bridge_.tgt_socket);
  if (debug_axi) {
    tg_.enableDebug();
  }

  axi2tlm_bridge_.socket.bind(xbar_.socket());
}

CoreMiniAxi_tb::~CoreMiniAxi_tb() { singleton_ = nullptr; }

void CoreMiniAxi_tb::Connect() {
  core_->io_aclk(clock);
  core_->io_aresetn(resetn);
  core_->io_halted(io_halted);
  core_->io_fault(io_fault);
  core_->io_wfi(io_wfi);
  core_->io_irq(io_irq);
  core_->io_te(io_te);

  core_->io_slog_valid(slog_io_.valid);
  core_->io_slog_addr(slog_io_.addr);
  core_->io_slog_data(slog_io_.data);

  core_->io_debug_en(debug_io_.en);
  core_->io_debug_cycles(debug_io_.cycles);
  core_->io_debug_addr_0(debug_io_.addr_0);
  core_->io_debug_addr_1(debug_io_.addr_1);
  core_->io_debug_addr_2(debug_io_.addr_2);
  core_->io_debug_addr_3(debug_io_.addr_3);
  core_->io_debug_inst_0(debug_io_.inst_0);
  core_->io_debug_inst_1(debug_io_.inst_1);
  core_->io_debug_inst_2(debug_io_.inst_2);
  core_->io_debug_inst_3(debug_io_.inst_3);

  // AR
  core_->io_axi_master_read_addr_ready(axi2tlm_signals_.arready);
  core_->io_axi_master_read_addr_valid(axi2tlm_signals_.arvalid);
  core_->io_axi_master_read_addr_bits_addr(axi2tlm_signals_.araddr);
  core_->io_axi_master_read_addr_bits_prot(axi2tlm_signals_.arprot);
  core_->io_axi_master_read_addr_bits_id(axi2tlm_signals_.arid);
  core_->io_axi_master_read_addr_bits_len(axi2tlm_signals_.arlen);
  core_->io_axi_master_read_addr_bits_size(axi2tlm_signals_.arsize);
  core_->io_axi_master_read_addr_bits_burst(axi2tlm_signals_.arburst);
  core_->io_axi_master_read_addr_bits_lock(axi2tlm_signals_.arlock);
  core_->io_axi_master_read_addr_bits_cache(axi2tlm_signals_.arcache);
  core_->io_axi_master_read_addr_bits_qos(axi2tlm_signals_.arqos);
  core_->io_axi_master_read_addr_bits_region(axi2tlm_signals_.arregion);
  // R
  core_->io_axi_master_read_data_ready(axi2tlm_signals_.rready);
  core_->io_axi_master_read_data_valid(axi2tlm_signals_.rvalid);
  core_->io_axi_master_read_data_bits_data(axi2tlm_signals_.rdata);
  core_->io_axi_master_read_data_bits_id(axi2tlm_signals_.rid);
  core_->io_axi_master_read_data_bits_resp(axi2tlm_signals_.rresp);
  core_->io_axi_master_read_data_bits_last(axi2tlm_signals_.rlast);
  // AW
  core_->io_axi_master_write_addr_ready(axi2tlm_signals_.awready);
  core_->io_axi_master_write_addr_valid(axi2tlm_signals_.awvalid);
  core_->io_axi_master_write_addr_bits_addr(axi2tlm_signals_.awaddr);
  core_->io_axi_master_write_addr_bits_prot(axi2tlm_signals_.awprot);
  core_->io_axi_master_write_addr_bits_id(axi2tlm_signals_.awid);
  core_->io_axi_master_write_addr_bits_len(axi2tlm_signals_.awlen);
  core_->io_axi_master_write_addr_bits_size(axi2tlm_signals_.awsize);
  core_->io_axi_master_write_addr_bits_burst(axi2tlm_signals_.awburst);
  core_->io_axi_master_write_addr_bits_lock(axi2tlm_signals_.awlock);
  core_->io_axi_master_write_addr_bits_cache(axi2tlm_signals_.awcache);
  core_->io_axi_master_write_addr_bits_qos(axi2tlm_signals_.awqos);
  core_->io_axi_master_write_addr_bits_region(axi2tlm_signals_.awregion);
  // W
  core_->io_axi_master_write_data_ready(axi2tlm_signals_.wready);
  core_->io_axi_master_write_data_valid(axi2tlm_signals_.wvalid);
  core_->io_axi_master_write_data_bits_data(axi2tlm_signals_.wdata);
  core_->io_axi_master_write_data_bits_last(axi2tlm_signals_.wlast);
  core_->io_axi_master_write_data_bits_strb(axi2tlm_signals_.wstrb);
  // B
  core_->io_axi_master_write_resp_ready(axi2tlm_signals_.bready);
  core_->io_axi_master_write_resp_valid(axi2tlm_signals_.bvalid);
  core_->io_axi_master_write_resp_bits_id(axi2tlm_signals_.bid);
  core_->io_axi_master_write_resp_bits_resp(axi2tlm_signals_.bresp);

  // AR
  core_->io_axi_slave_read_addr_ready(tlm2axi_signals_.arready);
  core_->io_axi_slave_read_addr_valid(tlm2axi_signals_.arvalid);
  core_->io_axi_slave_read_addr_bits_addr(tlm2axi_signals_.araddr);
  core_->io_axi_slave_read_addr_bits_prot(tlm2axi_signals_.arprot);
  core_->io_axi_slave_read_addr_bits_id(tlm2axi_signals_.arid);
  core_->io_axi_slave_read_addr_bits_len(tlm2axi_signals_.arlen);
  core_->io_axi_slave_read_addr_bits_size(tlm2axi_signals_.arsize);
  core_->io_axi_slave_read_addr_bits_burst(tlm2axi_signals_.arburst);
  core_->io_axi_slave_read_addr_bits_lock(tlm2axi_signals_.arlock);
  core_->io_axi_slave_read_addr_bits_cache(tlm2axi_signals_.arcache);
  core_->io_axi_slave_read_addr_bits_qos(tlm2axi_signals_.arqos);
  core_->io_axi_slave_read_addr_bits_region(tlm2axi_signals_.arregion);
  // R
  core_->io_axi_slave_read_data_ready(tlm2axi_signals_.rready);
  core_->io_axi_slave_read_data_valid(tlm2axi_signals_.rvalid);
  core_->io_axi_slave_read_data_bits_data(tlm2axi_signals_.rdata);
  core_->io_axi_slave_read_data_bits_id(tlm2axi_signals_.rid);
  core_->io_axi_slave_read_data_bits_resp(tlm2axi_signals_.rresp);
  core_->io_axi_slave_read_data_bits_last(tlm2axi_signals_.rlast);
  // AW
  core_->io_axi_slave_write_addr_ready(tlm2axi_signals_.awready);
  core_->io_axi_slave_write_addr_valid(tlm2axi_signals_.awvalid);
  core_->io_axi_slave_write_addr_bits_addr(tlm2axi_signals_.awaddr);
  core_->io_axi_slave_write_addr_bits_prot(tlm2axi_signals_.awprot);
  core_->io_axi_slave_write_addr_bits_id(tlm2axi_signals_.awid);
  core_->io_axi_slave_write_addr_bits_len(tlm2axi_signals_.awlen);
  core_->io_axi_slave_write_addr_bits_size(tlm2axi_signals_.awsize);
  core_->io_axi_slave_write_addr_bits_burst(tlm2axi_signals_.awburst);
  core_->io_axi_slave_write_addr_bits_lock(tlm2axi_signals_.awlock);
  core_->io_axi_slave_write_addr_bits_cache(tlm2axi_signals_.awcache);
  core_->io_axi_slave_write_addr_bits_qos(tlm2axi_signals_.awqos);
  core_->io_axi_slave_write_addr_bits_region(tlm2axi_signals_.awregion);
  // W
  core_->io_axi_slave_write_data_ready(tlm2axi_signals_.wready);
  core_->io_axi_slave_write_data_valid(tlm2axi_signals_.wvalid);
  core_->io_axi_slave_write_data_bits_data(tlm2axi_signals_.wdata);
  core_->io_axi_slave_write_data_bits_last(tlm2axi_signals_.wlast);
  core_->io_axi_slave_write_data_bits_strb(tlm2axi_signals_.wstrb);
  // B
  core_->io_axi_slave_write_resp_ready(tlm2axi_signals_.bready);
  core_->io_axi_slave_write_resp_valid(tlm2axi_signals_.bvalid);
  core_->io_axi_slave_write_resp_bits_id(tlm2axi_signals_.bid);
  core_->io_axi_slave_write_resp_bits_resp(tlm2axi_signals_.bresp);
}

absl::Status CoreMiniAxi_tb::LoadElfSync(const std::string& file_name) {
  CHECK_OK(LoadElfAsync(file_name));
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_cv_.Wait(&transfer_queue_mtx_);
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::LoadElfAsync(const std::string& file_name) {
  absl::MutexLock lock(&transfer_queue_mtx_);
  int fd = open(file_name.c_str(), 0);
  CHECK(fd > 0);
  struct stat sb;
  CHECK(fstat(fd, &sb) == 0);
  auto file_size = sb.st_size;
  auto file_data = mmap(nullptr, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
  CHECK(file_data != MAP_FAILED);
  close(fd);

  uint32_t elf_magic = 0x464c457f;
  uint8_t* data8 = reinterpret_cast<uint8_t*>(file_data);
  if (memcmp(file_data, &elf_magic, sizeof(elf_magic)) == 0) {
    std::vector<DataTransfer> elf_transfers;
    const Elf32_Ehdr* elf_header = reinterpret_cast<Elf32_Ehdr*>(file_data);
    auto entry_point = elf_header->e_entry;
    // Reserve space for write+read+expect for each section, and one additional
    // for the entry point CSR.
    elf_transfers.reserve(3 * elf_header->e_phnum + 1);
    ::LoadElf(data8,
              [&elf_transfers](void* dest, const void* src, size_t count) {
                elf_transfers.push_back(utils::Write(
                    reinterpret_cast<uint64_t>(dest),
                    reinterpret_cast<uint8_t*>(const_cast<void*>(src)), count));
                elf_transfers.push_back(
                    utils::Read(reinterpret_cast<uint64_t>(dest), count));
                elf_transfers.push_back(utils::Expect(
                    reinterpret_cast<uint8_t*>(const_cast<void*>(src)), count));
                return dest;
              });
    elf_transfers.push_back(utils::Write(
      csr_addr_ + 0x4, reinterpret_cast<uint8_t*>(&entry_point), sizeof(entry_point)
    ));
    transfer_queue_.push(
        std::make_unique<TrafficDesc>(utils::merge(elf_transfers)));
  } else {
    // Transaction to fill ITCM with the provided binary.
    transfer_queue_.push(
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(0, data8, file_size), utils::Read(0, file_size),
             utils::Expect(data8, file_size)}))));
  }
  munmap(file_data, file_size);
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::ClockGateSync(bool enable) {
  CHECK_OK(ClockGateAsync(enable));
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_cv_.Wait(&transfer_queue_mtx_);
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::ClockGateAsync(bool enable) {
  absl::MutexLock lock(&transfer_queue_mtx_);
  uint8_t enable8 = enable ? 3 : 1;
  transfer_queue_.push(
      std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
          {utils::Write(csr_addr_, DATA(enable8, 0, 0, 0)),
           utils::Read(csr_addr_, 4),
           utils::Expect(DATA(enable8, 0, 0, 0), 4)}))));
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::ResetSync(bool enable) {
  CHECK_OK(ResetAsync(enable));
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_cv_.Wait(&transfer_queue_mtx_);
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::ResetAsync(bool enable) {
  absl::MutexLock lock(&transfer_queue_mtx_);
  uint8_t enable8 = enable ? 1 : 0;
  transfer_queue_.push(
      std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
          {utils::Write(csr_addr_, DATA(enable8, 0, 0, 0)),
           utils::Read(csr_addr_, 4),
           utils::Expect(DATA(enable8, 0, 0, 0), 4)}))));
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::CheckStatusSync() {
  CHECK_OK(CheckStatusAsync());
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_cv_.Wait(&transfer_queue_mtx_);
  return absl::OkStatus();
}

absl::Status CoreMiniAxi_tb::CheckStatusAsync() {
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_.push(std::make_unique<TrafficDesc>(utils::merge(
      std::vector<DataTransfer>({utils::Read(csr_addr_ + 0x8, 4),
                                 utils::Expect(DATA(1, 0, 0, 0), 4)}))));
  return absl::OkStatus();
}

void CoreMiniAxi_tb::posedge() {
  static bool invoked_halted_cb = false;
  if ((io_halted || io_fault) && !invoked_halted_cb) {
    invoked_halted_cb = true;
    if (halted_cb_) {
      halted_cb_.value()();
    }
  }

  static bool wfi_seen = false;
  if (io_wfi && !wfi_seen) {
    io_irq = true;
    wfi_seen = true;
    if (wfi_cb_) {
      wfi_cb_.value()();
    }
  } else if (!io_wfi && wfi_seen) {
    io_irq = false;
    wfi_seen = false;
  } else {
    io_irq = false;
  }

  if (!transfer_in_progress_) {
    absl::MutexLock lock(&transfer_queue_mtx_);
    if (!transfer_queue_.empty()) {
      ITrafficDesc* transfer = transfer_queue_.front().get();
      tg_.addTransfers(transfer, 0, CoreMiniAxi_tb::axi_transaction_done_cb);
      transfer_in_progress_ = true;
    }
  }
}

void CoreMiniAxi_tb::EnqueueTransactionSync(
    std::vector<DataTransfer> transfers) {
  EnqueueTransactionAsync(transfers);
  absl::MutexLock lock(&transfer_queue_mtx_);
  transfer_queue_cv_.Wait(&transfer_queue_mtx_);
}

void CoreMiniAxi_tb::EnqueueTransactionAsync(
    std::vector<DataTransfer> transfers) {
  absl::MutexLock lock_(&transfer_queue_mtx_);
  transfer_queue_.push(std::make_unique<TrafficDesc>(utils::merge(transfers)));
}

void CoreMiniAxi_tb::axi_transaction_done_cb(TLMTrafficGenerator* gen,
                                             int threadId) {
  getSingleton()->axi_transaction_done_cb_(gen, threadId);
}

void CoreMiniAxi_tb::axi_transaction_done_cb_(TLMTrafficGenerator* gen,
                                              int threadId) {
  absl::MutexLock lock(&transfer_queue_mtx_);
  CHECK(!transfer_queue_.empty());
  transfer_queue_.pop();
  transfer_in_progress_ = false;
  transfer_queue_cv_.SignalAll();
}

CoreMiniAxi_tb* CoreMiniAxi_tb::singleton_ = nullptr;