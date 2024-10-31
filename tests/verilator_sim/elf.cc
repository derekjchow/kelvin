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

#include "tests/verilator_sim/elf.h"

#include <elf.h>

absl::Status LoadElf(uint8_t* data, CopyFn copy_fn) {
  const Elf32_Ehdr* elf_header = reinterpret_cast<Elf32_Ehdr*>(data);
  for (int i = 0; i < elf_header->e_phnum; ++i) {
    const Elf32_Phdr* program_header = reinterpret_cast<Elf32_Phdr*>(
        data + elf_header->e_phoff + sizeof(Elf32_Phdr) * i);
    if (program_header->p_type != PT_LOAD) {
      continue;
    }
    if (program_header->p_filesz == 0) {
      continue;
    }
    copy_fn(reinterpret_cast<void*>(program_header->p_paddr),
            reinterpret_cast<void*>(data + program_header->p_offset),
            program_header->p_filesz);
  }
  return absl::OkStatus();
}
