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

#ifndef TESTS_SYSTEMC_INSTRUCTION_TRACE_H_
#define TESTS_SYSTEMC_INSTRUCTION_TRACE_H_

#include <cstdint>
#include <deque>
#include <vector>

class InstructionTrace {
 public:
  void TraceInstruction(
    const std::vector<bool>& fires,
    const std::vector<uint32_t>& addrs,
    const std::vector<uint32_t>& insts,
    const std::vector<bool>& scalarWriteAddrValids,
    const std::vector<uint32_t>& scalarWriteAddrAddrs,
    const std::vector<bool>& floatWriteAddrValids,
    const std::vector<uint32_t>& floatWriteAddrAddrs,
    const std::vector<bool>& writeDataValids,
    const std::vector<uint32_t>& writeDataAddrs,
    const std::vector<uint32_t>& writeDataDatas,
    const std::vector<int>& executeRegBases);
  void TraceInstructionRaw(uint32_t pc, uint32_t inst, uint32_t reg,
                           const std::vector<uint8_t>& data, const bool trap);
  void PrintTrace() const;

  static const int kScalarBaseReg = 0;
  static const int kFloatBaseReg = 32;
  static const int kEcallBaseReg = 64;

 private:
  struct Instruction {
    Instruction() = default;
    ~Instruction() = default;
    Instruction(const Instruction&) = default;
    Instruction(uint32_t pc, uint32_t inst, uint32_t reg)
        : Instruction(pc, inst, reg, false) {}
    Instruction(uint32_t pc, uint32_t inst, uint32_t reg, bool trap) :
      pc(pc),
      inst(inst),
      reg(reg),
      trap(trap),
      completed(false) {}

    uint32_t pc;
    uint32_t inst;
    uint32_t reg;
    std::vector<uint8_t> data;
    bool trap;
    bool completed;
  };
  std::vector<Instruction> committed_insts_;
  std::deque<Instruction> retirement_buffer_;
};

#endif  // TESTS_SYSTEMC_INSTRUCTION_TRACE_H_
