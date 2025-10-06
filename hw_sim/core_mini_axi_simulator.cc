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

#include <vector>

#include "hw_sim/core_mini_axi_wrapper.h"
#include "hw_sim/coralnpu_simulator.h"

class CoreMiniAxiSimulator : public CoralNPUSimulator {
 public:
  CoreMiniAxiSimulator() : context_(), wrapper_(&context_) {
    auto read_cb = [this](const AxiAddr& axi_addr) {
      return this->ReadCallback(axi_addr);
    };
    wrapper_.RegisterReadCallback(read_cb);

    auto write_cb = [this](const AxiAddr& axi_addr, const AxiWData& axi_data) {
      return this->WriteCallback(axi_addr, axi_data);
    };
    wrapper_.RegisterWriteCallback(write_cb);

    wrapper_.Reset();
  }
  ~CoreMiniAxiSimulator() final = default;

  void ReadTCM(uint32_t addr, size_t size, char* data) final;
  const CoralNPUMailbox& ReadMailbox(void) final;
  void WriteTCM(uint32_t addr, size_t size, const char* data) final;
  void WriteMailbox(const CoralNPUMailbox& mailbox) final;
  void Run(uint32_t start_addr) final;
  bool WaitForTermination(int timeout) final;

 private:
  VerilatedContext context_;
  CoreMiniAxiWrapper wrapper_;

  AxiWResp WriteCallback(const AxiAddr&, const AxiWData&);
  AxiRData ReadCallback(const AxiAddr&);
};

void CoreMiniAxiSimulator::ReadTCM(uint32_t addr, size_t size, char* data) {
  std::vector<uint8_t> read_result = wrapper_.Read(addr, size);
  memcpy(data, read_result.data(), size);
}

const CoralNPUMailbox& CoreMiniAxiSimulator::ReadMailbox(void) {
  return wrapper_.ReadMailbox();
}

void CoreMiniAxiSimulator::WriteTCM(uint32_t addr, size_t size,
                                    const char* data) {
  wrapper_.Write(addr, size, data);
}

void CoreMiniAxiSimulator::WriteMailbox(const CoralNPUMailbox& mailbox) {
  wrapper_.WriteMailbox(mailbox);
}

void CoreMiniAxiSimulator::Run(uint32_t start_addr) {
  wrapper_.WriteWord(0x30004, start_addr);
  wrapper_.WriteWord(0x30000, 1u);
  wrapper_.WriteWord(0x30000, 0u);
}

bool CoreMiniAxiSimulator::WaitForTermination(int timeout = 10000) {
  return wrapper_.WaitForTermination(timeout);
}

AxiWResp CoreMiniAxiSimulator::WriteCallback(const AxiAddr& addr,
                                             const AxiWData& data) {
  CoralNPUMailbox& mailbox = wrapper_.mailbox();
  uint8_t* mailbox_data = reinterpret_cast<uint8_t*>(mailbox.message);
  const uint8_t* write_data =
      reinterpret_cast<const uint8_t*>(&data.write_data_bits_data[0]);
  for (int i = 0; i < 16; i++) {
    if (data.write_data_bits_strb & (1 << i)) {
      mailbox_data[i] = write_data[i];
    }
  }

  AxiWResp resp;
  resp.write_resp_bits_id = addr.addr_bits_id;
  resp.write_resp_bits_resp = 0;
  return resp;
}

AxiRData CoreMiniAxiSimulator::ReadCallback(const AxiAddr& addr) {
  const CoralNPUMailbox& mailbox = wrapper_.mailbox();
  const uint8_t* mailbox_data =
      reinterpret_cast<const uint8_t*>(mailbox.message);
  AxiRData data;
  uint8_t* read_data =
      reinterpret_cast<uint8_t*>(&(data.read_data_bits_data[0]));
  for (int i = 0; i < 16; i++) {
    read_data[i] = mailbox_data[i];
  }

  data.read_data_bits_id = addr.addr_bits_id;
  data.read_data_bits_resp = 0;
  data.read_data_bits_last = 1;

  return data;
}

// static
CoralNPUSimulator* CoralNPUSimulator::Create() {
  return new CoreMiniAxiSimulator();
}
