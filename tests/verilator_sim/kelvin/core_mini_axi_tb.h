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

#ifndef TESTS_VERILATOR_SIM_KELVIN_CORE_MINI_AXI_TB_H_
#define TESTS_VERILATOR_SIM_KELVIN_CORE_MINI_AXI_TB_H_

#include <functional>
#include <optional>
#include <queue>
#include <vector>

#include "absl/status/status.h"
#include "absl/synchronization/mutex.h"
#include "hdl/chisel/src/kelvin/VCoreMiniAxi_parameters.h"
#include "tests/systemc/Xbar.h"
#include "tests/verilator_sim/sysc_tb.h"

// Headers for our Verilator model.
#include "VCoreMiniAxi.h"

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
/* clang-format on */

struct CoreMiniAxi_tb : Sysc_tb {
 public:
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

  CoreMiniAxi_tb(sc_module_name n, int loops, bool random, std::string binary,
                 bool debug_axi, std::optional<std::function<void()>> wfi_cb,
                 std::optional<std::function<void()>> halted_cb);
  ~CoreMiniAxi_tb();
  static void axi_transaction_done_cb(TLMTrafficGenerator* gen, int threadId);

  typedef AXISignals<KP_axi2AddrBits,  // ADDR_WIDTH
                     KP_lsuDataBits,   // DATA_WIDTH
                     KP_axi2IdBits,    // ID_WIDTH
                     8,                // AxLEN_WIDTH
                     2,                // AxLOCK_WIDTH
                     0, 0, 0, 0, 0     // User
                     >
      CoreMiniAxiSignals;

  sc_signal<bool> io_halted;
  sc_signal<bool> io_fault;
  sc_signal<bool> io_wfi;
  sc_signal<bool> io_irq;
  sc_signal<bool> io_te;

  absl::Status LoadElfSync(const std::string& file_name);
  absl::Status LoadElfAsync(const std::string& file_name);
  // ClockGate and Reset should be done in the correct order:
  // ClockGate(false); Reset(false);
  // OR
  // Reset(true); ClockGate(true);
  absl::Status ClockGateSync(bool enable);
  absl::Status ClockGateAsync(bool enable);
  absl::Status ResetSync(bool enable);
  absl::Status ResetAsync(bool enable);
  absl::Status CheckStatusSync();
  absl::Status CheckStatusAsync();

  VCoreMiniAxi* core() { return core_.get(); }

  void EnqueueTransactionSync(std::vector<DataTransfer> transfers);
  void EnqueueTransactionAsync(std::vector<DataTransfer> transfers);

 protected:
  void posedge() override;

 private:
  void Connect();
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
  SlogIO slog_io_;
  DebugIO debug_io_;
  Xbar xbar_;
  std::optional<std::function<void()>> wfi_cb_;
  std::optional<std::function<void()>> halted_cb_;

  std::unique_ptr<TrafficDesc> wrap_transfer_;
  std::unique_ptr<TrafficDesc> narrow_transfer_;
  bool transfer_in_progress_;

  absl::Mutex transfer_queue_mtx_;
  absl::CondVar transfer_queue_cv_;
  std::queue<std::unique_ptr<TrafficDesc>> transfer_queue_;

  void axi_transaction_done_cb_(TLMTrafficGenerator* gen, int threadId);

  static CoreMiniAxi_tb* singleton_;
  static CoreMiniAxi_tb* getSingleton() { return singleton_; }
  static constexpr uint32_t csr_addr_ = 0x30000;
  std::unique_ptr<VCoreMiniAxi> core_;
};
#endif  // TESTS_VERILATOR_SIM_KELVIN_CORE_MINI_AXI_TB_H_
