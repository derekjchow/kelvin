// Copyright 2023 Google LLC
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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_MEMORY_IF_H_
#define TESTS_VERILATOR_SIM_CORALNPU_MEMORY_IF_H_

#include <stdint.h>
#include <stdio.h>

#include <algorithm>
#include <map>

#include "tests/verilator_sim/sysc_module.h"

// A memory model base class
struct Memory_if : Sysc_module {
  const int kPageSize = 4 * 1024;
  const int kPageMask = ~(kPageSize - 1);

  struct memory_page_t {
    uint32_t addr;
    uint8_t  data[4096];
  };

  Memory_if(sc_module_name n, const char* bin, int limit = -1) :
      Sysc_module(n) {
    FILE *f = fopen(bin, "rb");

    fseek(f, 0, SEEK_END);
    int64_t fsize = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *fdata = new uint8_t[fsize];

    fread(fdata, fsize, 1, f);
    fclose(f);

    if (limit > 0 && fsize > limit) {
      printf("***ERROR Memory_if limit exceeded [%ld > %d]\n", fsize, limit);
      exit(-1);
    }

    int addr = 0;
    for (; addr < fsize; addr += kPageSize) {
      const int64_t size = std::min(fsize - addr, int64_t(kPageSize));
      AddPage(addr, size, fdata + addr);
    }
    // Create pages for the rest of our memory space, that was not created
    // for inserting the binary.
    for (; addr < 0x400000; addr += kPageSize) {
      AddPage(addr, kPageSize, nullptr);
    }

    delete [] fdata;
  }

  bool Read(uint32_t addr, int bytes, uint8_t* data) {
    while (bytes > 0) {
      const uint32_t maddr = addr & kPageMask;
      const uint32_t offset = addr - maddr;
      const int limit = kPageSize - offset;
      const int len = std::min(bytes, limit);

      if (!HasPage(maddr)) {
        return false;
      }

      auto& p = page_[maddr];
      uint8_t* d = p.data;
      memcpy(data, d + offset, len);
#if 0
      printf("READ  %08x", addr);
      for (int i = 0; i < len; i++) {
        printf(" %02x", data[i]);
      }
      printf("\n");
#endif
      addr += len;
      data += len;
      bytes -= len;
      assert(bytes >= 0);
    }
    return true;
  }

  bool Write(uint32_t addr, int bytes, const uint8_t* data) {
    while (bytes > 0) {
      const uint32_t maddr = addr & kPageMask;
      const uint32_t offset = addr - maddr;
      const int limit = kPageSize - offset;
      const int len = std::min(bytes, limit);

      if (!HasPage(maddr)) {
        return false;
      }

      auto& p = page_[maddr];
      uint8_t* d = p.data;
      memcpy(d + offset, data, len);
#if 0
      printf("WRITE %08x", addr);
      for (int i = 0; i < len; i++) {
        printf(" %02x", data[i]);
      }
      printf("\n");
#endif
      addr += len;
      data += len;
      bytes -= len;
      assert(bytes >= 0);
    }
    return true;
  }

 protected:
  void ReadSwizzle(const uint32_t addr, const int bytes, uint8_t* data) {
    const int mask = bytes - 1;
    const int alignment = (bytes - (addr & mask)) & mask;  // left shuffle
    uint8_t tmp[512/8];

    if (!alignment) return;

    for (int i = 0; i < bytes; ++i) {
      tmp[i] = data[i];
    }

    for (int i = 0; i < bytes; ++i) {
      data[i] = tmp[(i + alignment) & mask];
    }
  }

  void WriteSwizzle(const uint32_t addr, const int bytes, uint8_t* data) {
    const int mask = bytes - 1;
    const int alignment = addr & mask;  // right shuffle
    uint8_t tmp[512/8];

    if (!alignment) return;

    for (int i = 0; i < bytes; ++i) {
      tmp[i] = data[i];
    }

    for (int i = 0; i < bytes; ++i) {
      data[i] = tmp[(i + alignment) & mask];
    }
  }

 private:
  std::map<uint32_t, memory_page_t> page_;

  bool HasPage(const uint32_t addr) {
    return page_.find(addr) != page_.end();
  }

  void AddPage(const uint32_t addr, const int bytes,
               const uint8_t* data = nullptr) {
    const uint32_t addrbase = addr & kPageMask;
    if (addr != addrbase) {
      printf("AddPage(%08x, %d)\n", addr, bytes);
      assert(false && "AddPage: address not page aligned");
    }

    if (HasPage(addr)) {
      printf("AddPage(%08x, %d)\n", addr, bytes);
      assert(false && "AddPage: address already populated");
    }

    auto& p = page_[addr];
    uint8_t* d = p.data;

    if (bytes < kPageSize || data == nullptr) {
#if 1
      // remove need for .bss  (hacky?)
      memset(d, 0x00, kPageSize);
#else
      memset(d, 0xcc, kPageSize);
#endif
    }

    if (data) {
      memcpy(d, data, bytes);
    }
  }
};

#endif  // TESTS_VERILATOR_SIM_CORALNPU_MEMORY_IF_H_
