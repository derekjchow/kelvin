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

#include "hw_sim/core_mini_axi_wrapper.h"
#include "hw_sim/kelvin_simulator.h"

class CoreMiniAxiSimulator : public KelvinSimulator {
 public:
  CoreMiniAxiSimulator()
    : context_(),
      wrapper_(&context_) {
    wrapper_.Reset();
  }
  ~CoreMiniAxiSimulator() final = default;

  void ReadTCM(uint32_t addr, size_t size, char* data) final;
  void WriteTCM(uint32_t addr, size_t size, const char* data) final;
  void Run(uint32_t start_addr) final;

 private:
  VerilatedContext context_;
  CoreMiniAxiWrapper wrapper_;
};

void CoreMiniAxiSimulator::ReadTCM(uint32_t addr, size_t size, char* data) {
  std::vector<uint8_t> read_result = wrapper_.Read(addr, size);
  memcpy(data, read_result.data(), size);
}

void CoreMiniAxiSimulator::WriteTCM(
    uint32_t addr, size_t size, const char* data) {
  wrapper_.Write(
      addr,
      absl::Span<const uint8_t>(reinterpret_cast<const uint8_t*>(data), size));
}

void CoreMiniAxiSimulator::Run(uint32_t start_addr) {
  wrapper_.WriteWord(0x30004, start_addr);
  wrapper_.WriteWord(0x30000, 1u);
  wrapper_.WriteWord(0x30000, 0u);
}

// static
KelvinSimulator* Create() {
  return new CoreMiniAxiSimulator();
}