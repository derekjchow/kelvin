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

#ifndef HW_SIM_HW_PRIMITIVES_H_
#define HW_SIM_HW_PRIMITIVES_H_

#include <functional>
#include <queue>
#include <vector>

#include "absl/types/span.h"
#include "VCoreMiniAxi.h"


// A class that wraps and controls a verilator clock signal. Also provides an
// observer mechanism
class Clock {
 public:
  // A class that observes changes to the clock signal. The constructor and
  // destructor will automatically subscribe/unsubscribe from the clock.
  class Observer {
   public:
    Observer(Clock* clock);
    virtual ~Observer();

    virtual void OnRisingEdge() {}
    virtual void OnFallingEdge() {}
   protected:
    Clock& clock() { return *clock_; }
   private:
    Clock* const clock_;
  };

  template<typename Model>
  Clock(VerilatedContext* context, uint8_t* clock, Model* model)
    : context_(context),
      clock_(clock),
      eval_function_([model](){ model->eval(); }) {}
  ~Clock() = default;

  // Advance the clock on cycle (one positive edge, one negative edge).
  void Step();

  // Update the simulation. If observers change input signals to the design,
  // they should call this function to ensure internal signals get updated.
  void Eval();

 private:
  void AddObserver(Observer* observer);
  void RemoveObserver(Observer* observer);

  VerilatedContext* const context_;
  uint8_t* const clock_;
  std::function<void()> eval_function_;
  std::vector<Observer*> observers_;
};

// Struct representing the data transferred in an AXI4 read/write addr channel.
struct AxiAddr {
  uint32_t addr_bits_addr;
  uint8_t addr_bits_prot;
  uint8_t addr_bits_id;
  uint8_t addr_bits_len;
  uint8_t addr_bits_size;
  uint8_t addr_bits_burst;
  uint8_t addr_bits_lock;
  uint8_t addr_bits_cache;
  uint8_t addr_bits_qos;
  uint8_t addr_bits_region;

  // Create an AxiAddr from a transfer id, starting address and transaction
  // length.
  static AxiAddr FromIdAddrSize(int id, uint32_t addr, uint32_t byte_length);
};

// Struct representing the data transferred in an AXI4 write data channel.
struct AxiWData {
  VlWide<4> write_data_bits_data;
  uint16_t write_data_bits_strb;
  uint8_t write_data_bits_last;
};

// A driver to control interactions of the write channels in an AXI4 slave.
class AxiSlaveWriteDriver : Clock::Observer {
 public:
  AxiSlaveWriteDriver(Clock* clock,
                      uint8_t* write_addr_valid,
                      uint32_t* write_addr_bits_addr,
                      uint8_t* write_addr_bits_prot,
                      uint8_t* write_addr_bits_id,
                      uint8_t* write_addr_bits_len,
                      uint8_t* write_addr_bits_size,
                      uint8_t* write_addr_bits_burst,
                      uint8_t* write_addr_bits_lock,
                      uint8_t* write_addr_bits_cache,
                      uint8_t* write_addr_bits_qos,
                      uint8_t* write_addr_bits_region,
                      const uint8_t* write_addr_ready,
                      uint8_t* write_data_valid,
                      VlWide<4>* write_data_bits_data,
                      uint16_t* write_data_bits_strb,
                      uint8_t* write_data_bits_last,
                      const uint8_t* write_data_ready,
                      const uint8_t* write_resp_valid,
                      const uint8_t* write_resp_bits_id,
                      const uint8_t* write_resp_bits_resp,
                      uint8_t* write_resp_ready)
    : Clock::Observer(clock),
      write_addr_valid_(write_addr_valid),
      write_addr_bits_addr_(write_addr_bits_addr),
      write_addr_bits_prot_(write_addr_bits_prot),
      write_addr_bits_id_(write_addr_bits_id),
      write_addr_bits_len_(write_addr_bits_len),
      write_addr_bits_size_(write_addr_bits_size),
      write_addr_bits_burst_(write_addr_bits_burst),
      write_addr_bits_lock_(write_addr_bits_lock),
      write_addr_bits_cache_(write_addr_bits_cache),
      write_addr_bits_qos_(write_addr_bits_qos),
      write_addr_bits_region_(write_addr_bits_region),
      write_addr_ready_(write_addr_ready),
      write_data_valid_(write_data_valid),
      write_data_bits_data_(write_data_bits_data),
      write_data_bits_strb_(write_data_bits_strb),
      write_data_bits_last_(write_data_bits_last),
      write_data_ready_(write_data_ready),
      write_resp_valid_(write_resp_valid),
      write_resp_bits_id_(write_resp_bits_id),
      write_resp_bits_resp_(write_resp_bits_resp),
      write_resp_ready_(write_resp_ready) {
    // Always ready to accept response
    *write_resp_ready_ = 1;
  }
  ~AxiSlaveWriteDriver() final = default;

  std::shared_ptr<bool> WriteTransaction(
      int id, uint32_t addr, absl::Span<const uint8_t> data) {
    // Enqueue addr
    AxiAddr axi_addr = AxiAddr::FromIdAddrSize(id, addr, data.size());
    EnqueueAddr(axi_addr);

    // Enqueue data
    while (data.size() > 0) {
      uint32_t base_addr = (addr / 16) * 16;
      uint32_t sub_addr = addr - base_addr;
      uint32_t bytes_to_write = 16 - sub_addr;
      bytes_to_write = std::min(static_cast<uint32_t>(data.size()),
                                bytes_to_write);
      absl::Span<const uint8_t> local_data = data.subspan(0, bytes_to_write);

      AxiWData axi_data;
      uint8_t* data_ptr =
          reinterpret_cast<uint8_t*>(&(axi_data.write_data_bits_data[0])) +
          sub_addr;
      memcpy(data_ptr, local_data.data(), bytes_to_write);
      axi_data.write_data_bits_strb = 0;
      for (uint32_t i = sub_addr; i < sub_addr + bytes_to_write; i++) {
        axi_data.write_data_bits_strb |= (1 << i);
      }
      axi_data.write_data_bits_last = (bytes_to_write == data.size());
      EnqueueData(axi_data);

      data.remove_prefix(bytes_to_write);
      addr += bytes_to_write;
    }

    assert(outstanding_transactions_.find(id) ==
           outstanding_transactions_.end());

    const auto [it, success] = outstanding_transactions_.insert({
        id, std::make_shared<bool>(false)});
    return it->second;
  }

 private:
  void EnqueueAddr(const AxiAddr& addr) {
    addr_queue_.push(addr);
  }

  void EnqueueData(const AxiWData& data) {
    data_queue_.push(data);
  }

  void OnFallingEdge() final {
    // Send Addr
    *write_addr_valid_ = !addr_queue_.empty();
    clock().Eval();
    if (!addr_queue_.empty()) {
      *write_addr_bits_addr_ = addr_queue_.front().addr_bits_addr;
      *write_addr_bits_prot_ = addr_queue_.front().addr_bits_prot;
      *write_addr_bits_id_ = addr_queue_.front().addr_bits_id;
      *write_addr_bits_len_ = addr_queue_.front().addr_bits_len;
      *write_addr_bits_size_ = addr_queue_.front().addr_bits_size;
      *write_addr_bits_burst_ = addr_queue_.front().addr_bits_burst;
      *write_addr_bits_lock_ = addr_queue_.front().addr_bits_lock;
      *write_addr_bits_cache_ = addr_queue_.front().addr_bits_cache;
      *write_addr_bits_qos_ = addr_queue_.front().addr_bits_qos;
      *write_addr_bits_region_ = addr_queue_.front().addr_bits_region;
      if (*write_addr_ready_) {
        addr_queue_.pop();
      }
      clock().Eval();
    }

    // Send Data
    *write_data_valid_ = !data_queue_.empty();
    clock().Eval();
    if (!data_queue_.empty()) {

      *write_data_bits_data_ = data_queue_.front().write_data_bits_data;
      *write_data_bits_strb_ = data_queue_.front().write_data_bits_strb;
      *write_data_bits_last_ = data_queue_.front().write_data_bits_last;
      if (*write_data_ready_) {
        data_queue_.pop();
      }
      clock().Eval();
    }

    // Receive Response
    if (*write_resp_valid_) {
      assert(*write_resp_bits_resp_ == 0);
      auto it = outstanding_transactions_.find(*write_resp_bits_id_);
      if (it != outstanding_transactions_.end()) {
        *(it->second) = true;
        outstanding_transactions_.erase(it);
      }
    }
  }

  // Signals
  // WAddr
  uint8_t* const write_addr_valid_;
  uint32_t* const write_addr_bits_addr_;
  uint8_t* const write_addr_bits_prot_;
  uint8_t* const write_addr_bits_id_;
  uint8_t* const write_addr_bits_len_;
  uint8_t* const write_addr_bits_size_;
  uint8_t* const write_addr_bits_burst_;
  uint8_t* const write_addr_bits_lock_;
  uint8_t* const write_addr_bits_cache_;
  uint8_t* const write_addr_bits_qos_;
  uint8_t* const write_addr_bits_region_;
  const uint8_t* const write_addr_ready_;
  // WData
  uint8_t* const write_data_valid_;
  VlWide<4>* const write_data_bits_data_;
  uint16_t* const write_data_bits_strb_;
  uint8_t* const write_data_bits_last_;
  const uint8_t* const write_data_ready_;
  // WResp
  const uint8_t* const write_resp_valid_;
  const uint8_t* const write_resp_bits_id_;
  const uint8_t* const write_resp_bits_resp_;
  uint8_t* const write_resp_ready_;

  std::queue<AxiAddr> addr_queue_;
  std::queue<AxiWData> data_queue_;
  std::map<uint8_t/*id*/, std::shared_ptr<bool>> outstanding_transactions_;
};

// A driver to control interactions of the read channels in an AXI4 slave.
class AxiSlaveReadDriver : Clock::Observer {
 public:
  struct Transaction {
    bool finished;
    uint32_t start_addr;
    uint32_t end_addr;
    std::vector<uint8_t> data;
  };
  AxiSlaveReadDriver(Clock* clock,
                     uint8_t* read_addr_valid,
                     uint32_t* read_addr_bits_addr,
                     uint8_t* read_addr_bits_prot,
                     uint8_t* read_addr_bits_id,
                     uint8_t* read_addr_bits_len,
                     uint8_t* read_addr_bits_size,
                     uint8_t* read_addr_bits_burst,
                     uint8_t* read_addr_bits_lock,
                     uint8_t* read_addr_bits_cache,
                     uint8_t* read_addr_bits_qos,
                     uint8_t* read_addr_bits_region,
                     const uint8_t* read_addr_ready,
                     const uint8_t* read_data_valid,
                     const VlWide<4>* read_data_bits_data,
                     const uint8_t* read_data_bits_id,
                     const uint8_t* read_data_bits_resp,
                     const uint8_t* read_data_bits_last,
                     uint8_t* read_data_ready
    )
    : Clock::Observer(clock),
      read_addr_valid_(read_addr_valid),
      read_addr_bits_addr_(read_addr_bits_addr),
      read_addr_bits_prot_(read_addr_bits_prot),
      read_addr_bits_id_(read_addr_bits_id),
      read_addr_bits_len_(read_addr_bits_len),
      read_addr_bits_size_(read_addr_bits_size),
      read_addr_bits_burst_(read_addr_bits_burst),
      read_addr_bits_lock_(read_addr_bits_lock),
      read_addr_bits_cache_(read_addr_bits_cache),
      read_addr_bits_qos_(read_addr_bits_qos),
      read_addr_bits_region_(read_addr_bits_region),
      read_addr_ready_(read_addr_ready),
      read_data_valid_(read_data_valid),
      read_data_bits_data(read_data_bits_data),
      read_data_bits_id_(read_data_bits_id),
      read_data_bits_resp_(read_data_bits_resp),
      read_data_bits_last_(read_data_bits_last),
      read_data_ready_(read_data_ready)
      {
    (*read_data_ready_) = 1;
  }

  std::shared_ptr<Transaction> ReadTransaction(int id, uint32_t addr,
                                               uint32_t byte_length) {
    // Enqueue addr
    AxiAddr axi_addr = AxiAddr::FromIdAddrSize(id, addr, byte_length);
    addr_queue_.push(axi_addr);

    // Enqueue data
    assert(outstanding_transactions_.find(id) ==
           outstanding_transactions_.end());
    const auto [it, success] = outstanding_transactions_.insert({
        id, std::make_shared<Transaction>()});
    it->second->finished = false;
    it->second->start_addr = addr;
    it->second->end_addr = addr + byte_length;
    it->second->data.reserve(byte_length);
    return it->second;
  }

 private:
  void OnFallingEdge() final {
    // Send Addr
    *read_addr_valid_ = !addr_queue_.empty();
    clock().Eval();
    if (!addr_queue_.empty()) {
      *read_addr_bits_addr_ = addr_queue_.front().addr_bits_addr;
      *read_addr_bits_prot_ = addr_queue_.front().addr_bits_prot;
      *read_addr_bits_id_ = addr_queue_.front().addr_bits_id;
      *read_addr_bits_len_ = addr_queue_.front().addr_bits_len;
      *read_addr_bits_size_ = addr_queue_.front().addr_bits_size;
      *read_addr_bits_burst_ = addr_queue_.front().addr_bits_burst;
      *read_addr_bits_lock_ = addr_queue_.front().addr_bits_lock;
      *read_addr_bits_cache_ = addr_queue_.front().addr_bits_cache;
      *read_addr_bits_qos_ = addr_queue_.front().addr_bits_qos;
      *read_addr_bits_region_ = addr_queue_.front().addr_bits_region;
      if (*read_addr_ready_) {
        addr_queue_.pop();
      }
      clock().Eval();
    }

    // Received data
    if (*read_data_valid_) {
      assert(*read_data_bits_resp_ == 0);

      auto it = outstanding_transactions_.find(*read_data_bits_id_);
      if (it == outstanding_transactions_.end()) {
        return;
      }

      // TODO(derekjchow): Should probably handle non-INCR mode.
      uint32_t sub_addr = it->second->start_addr % 16;
      uint32_t bytes_to_read = 16 - sub_addr;
      bytes_to_read = std::min(
          bytes_to_read, it->second->end_addr - it->second->start_addr);
      const uint8_t* read_data = reinterpret_cast<const uint8_t*>(
          &(*read_data_bits_data)[0]);
      for (uint32_t i = 0; i < bytes_to_read; i++) {
        it->second->data.push_back(read_data[i + sub_addr]);
      }
      it->second->start_addr += bytes_to_read;
      if (*read_data_bits_last_) {
        it->second->finished = true;
        outstanding_transactions_.erase(it);
      }
    }
  }

  // Signals
  // RAddr
  uint8_t* const read_addr_valid_;
  uint32_t* const read_addr_bits_addr_;
  uint8_t* const read_addr_bits_prot_;
  uint8_t* const read_addr_bits_id_;
  uint8_t* const read_addr_bits_len_;
  uint8_t* const read_addr_bits_size_;
  uint8_t* const read_addr_bits_burst_;
  uint8_t* const read_addr_bits_lock_;
  uint8_t* const read_addr_bits_cache_;
  uint8_t* const read_addr_bits_qos_;
  uint8_t* const read_addr_bits_region_;
  const uint8_t* const read_addr_ready_;
  // RData
  const uint8_t* const read_data_valid_;
  const VlWide<4>* const read_data_bits_data;
  const uint8_t* const read_data_bits_id_;
  const uint8_t* const read_data_bits_resp_;
  const uint8_t* const read_data_bits_last_;
  uint8_t* const read_data_ready_;

  std::queue<AxiAddr> addr_queue_;
  std::map<uint8_t/*id*/, std::shared_ptr<Transaction>>
      outstanding_transactions_;
};

#endif  // HW_SIM_HW_PRIMITIVES_H_