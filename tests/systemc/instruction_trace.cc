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

#include "tests/systemc/instruction_trace.h"

#include <cassert>
#include <cstdio>
#include <vector>

constexpr uint32_t kEcallInst = 0x00000073;

void InstructionTrace::TraceInstruction(
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
  const std::vector<int>& executeRegBases
) {
  assert(fires.size() == addrs.size());
  assert(fires.size() == insts.size());
  assert(fires.size() == scalarWriteAddrValids.size());
  assert(scalarWriteAddrValids.size() == scalarWriteAddrAddrs.size());
  assert(floatWriteAddrValids.size() == floatWriteAddrAddrs.size());
  assert(writeDataValids.size() == writeDataAddrs.size());
  assert(writeDataValids.size() == writeDataDatas.size());
  assert(writeDataValids.size() == executeRegBases.size());

  // Push data about the instructions that were dispatched this cycle into
  // the retirement buffer. Newly queued instructions are marked as incomplete.
  for (size_t i = 0; i < floatWriteAddrValids.size(); ++i) {
    bool fire = fires[i];
    bool valid = floatWriteAddrValids[i];
    uint32_t inst = insts[i];
    uint32_t pc = addrs[i];
    int reg = floatWriteAddrAddrs[i] + kFloatBaseReg;
    if (fire && valid) {
      Instruction in(pc, inst, reg);
      retirement_buffer_.push_back(in);
    }
  }
  for (size_t i = 0; i < scalarWriteAddrValids.size(); ++i) {
    bool fire = fires[i];
    bool valid = scalarWriteAddrValids[i];
    uint32_t inst = insts[i];
    uint32_t pc = addrs[i];
    int reg = scalarWriteAddrAddrs[i] + kScalarBaseReg;
    if (fire && valid && (reg != 0)) {
      Instruction in(pc, inst, reg);
      retirement_buffer_.push_back(in);
    }
    if (fire && (inst == kEcallInst)) {
      Instruction in(pc, inst, kEcallBaseReg);
      retirement_buffer_.push_back(in);
    }
  }

  // Iterate over the write ports, and find the first incomplete instruction
  // that matches the write. Mark that instruction as completed, and move
  // to the next write port.
  for (size_t i = 0; i < writeDataValids.size(); ++i) {
    bool valid = writeDataValids[i];
    uint32_t addr = writeDataAddrs[i] + executeRegBases[i];
    uint32_t data = writeDataDatas[i];
    for (auto& in : retirement_buffer_) {
      if (in.completed) continue;
      if (valid && (addr == in.reg)) {
        in.data.resize(4);
        in.data[0] = (data >> 24) & 0xff;
        in.data[1] = (data >> 16) & 0xff;
        in.data[2] = (data >> 8) & 0xff;
        in.data[3] = data & 0xff;
        in.completed = true;
        break;
      }
      if (in.inst == kEcallInst) {
        in.completed = true;
        break;
      }
    }
  }

  // Iterate over the retirement buffer, moving completed instructions
  // from the front into the committed_insts_ buffer.
  // When we see an incomplete instruction, stop.
  while (!retirement_buffer_.empty()) {
    auto in = retirement_buffer_.front();
    if (!in.completed) {
      break;
    } else {
      committed_insts_.push_back(in);
      retirement_buffer_.pop_front();
    }
  }
}

void InstructionTrace::TraceInstructionRaw(uint32_t pc, uint32_t inst,
                                           uint32_t reg,
                                           const std::vector<uint8_t>& data,
                                           const bool trap) {
  Instruction in(pc, inst, reg, trap);
  in.data = data;
  committed_insts_.push_back(in);
}

void InstructionTrace::PrintTrace() const {
  printf("PC,INST,REG,DATA\n");
  for (auto& inst : committed_insts_) {
    printf("0x%08x,0x%08x,0x%02x,0x", inst.pc, inst.inst, inst.reg);
    for (auto d : inst.data) {
      printf("%02x", d);
    }
    printf(",trap=%s\n", inst.trap ? "yes" : "no");
  }
}
