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

#include <cstdint>
#include <deque>
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
    // DBus signals
    sc_signal<bool> dbus_valid;
    sc_signal<sc_bv<32>> dbus_bits_addr;
    sc_signal<sc_bv<KP_lsuDataBits>> dbus_bits_wdata;
    sc_signal<bool> dbus_bits_write;
    // Dispatch signals
    sc_signal<bool> dispatch_0_instFire;
    sc_signal<bool> dispatch_1_instFire;
    sc_signal<bool> dispatch_2_instFire;
    sc_signal<bool> dispatch_3_instFire;
    sc_signal<sc_bv<32>> dispatch_0_instAddr;
    sc_signal<sc_bv<32>> dispatch_1_instAddr;
    sc_signal<sc_bv<32>> dispatch_2_instAddr;
    sc_signal<sc_bv<32>> dispatch_3_instAddr;
    sc_signal<sc_bv<32>> dispatch_0_instInst;
    sc_signal<sc_bv<32>> dispatch_1_instInst;
    sc_signal<sc_bv<32>> dispatch_2_instInst;
    sc_signal<sc_bv<32>> dispatch_3_instInst;
    // Regfile signals
    sc_signal<bool> regfile_writeAddr_0_valid;
    sc_signal<bool> regfile_writeAddr_1_valid;
    sc_signal<bool> regfile_writeAddr_2_valid;
    sc_signal<bool> regfile_writeAddr_3_valid;
    sc_signal<sc_bv<5>> regfile_writeAddr_0_bits;
    sc_signal<sc_bv<5>> regfile_writeAddr_1_bits;
    sc_signal<sc_bv<5>> regfile_writeAddr_2_bits;
    sc_signal<sc_bv<5>> regfile_writeAddr_3_bits;
    sc_signal<bool> regfile_writeData_0_valid;
    sc_signal<bool> regfile_writeData_1_valid;
    sc_signal<bool> regfile_writeData_2_valid;
    sc_signal<bool> regfile_writeData_3_valid;
    sc_signal<bool> regfile_writeData_4_valid;
    sc_signal<bool> regfile_writeData_5_valid;
    sc_signal<sc_bv<5>> regfile_writeData_0_bits_addr;
    sc_signal<sc_bv<5>> regfile_writeData_1_bits_addr;
    sc_signal<sc_bv<5>> regfile_writeData_2_bits_addr;
    sc_signal<sc_bv<5>> regfile_writeData_3_bits_addr;
    sc_signal<sc_bv<5>> regfile_writeData_4_bits_addr;
    sc_signal<sc_bv<5>> regfile_writeData_5_bits_addr;
    sc_signal<sc_bv<32>> regfile_writeData_0_bits_data;
    sc_signal<sc_bv<32>> regfile_writeData_1_bits_data;
    sc_signal<sc_bv<32>> regfile_writeData_2_bits_data;
    sc_signal<sc_bv<32>> regfile_writeData_3_bits_data;
    sc_signal<sc_bv<32>> regfile_writeData_4_bits_data;
    sc_signal<sc_bv<32>> regfile_writeData_5_bits_data;
  };

  CoreMiniAxi_tb(sc_module_name n, int loops, bool random, bool debug_axi,
                 bool instr_trace,
                 std::optional<std::function<void()>> wfi_cb,
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
  bool tohost_halt = false;
  uint32_t tohost_val = 0;

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
  void TraceInstructions();

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

  std::optional<uint32_t> tohost_addr_;
  std::optional<uint32_t> fromhost_addr_;

  struct Instruction {
    uint32_t pc;
    uint32_t inst;
    uint32_t reg;
    uint32_t cycle;
    uint32_t data;
    bool completed;
  };
  bool instr_trace_ = false;
  std::vector<Instruction> committed_insts_;
  std::deque<Instruction> retirement_buffer_;
};
#endif  // TESTS_VERILATOR_SIM_KELVIN_CORE_MINI_AXI_TB_H_
