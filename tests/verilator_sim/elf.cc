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

#include <cstring>
#include <elf.h>

uint32_t LoadElf(uint8_t* data, CopyFn copy_fn) {
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
  return elf_header->e_entry;
}

bool LookupSymbol(const uint8_t* data, const std::string& symbol_name, uint32_t* symbol_addr) {
  if (symbol_addr == nullptr)
    return false;
  const Elf32_Ehdr* elf_header = reinterpret_cast<const Elf32_Ehdr*>(data);

  // Locate .shstrtab
  if (elf_header->e_shstrndx == SHN_UNDEF)
    return false;
  const Elf32_Half section_string_table_idx = elf_header->e_shstrndx;
  const Elf32_Shdr* section_string_table_header = reinterpret_cast<const Elf32_Shdr*>(
    data + elf_header->e_shoff + sizeof(Elf32_Shdr) * section_string_table_idx);
  const char* section_string_table =
    reinterpret_cast<const char*>(data + section_string_table_header->sh_offset);

  // Locate .strtab and .symtab
  const Elf32_Sym* symbol_table = nullptr;
  uint32_t symbol_count;
  const char* string_table = nullptr;
  for (int i = 0; i < elf_header->e_shnum; ++i) {
    const Elf32_Shdr* section_header = reinterpret_cast<const Elf32_Shdr*>(
      data + elf_header->e_shoff + sizeof(Elf32_Shdr) * i);
    if (section_header->sh_type == SHT_SYMTAB) {
      const char* symtab_name = (section_string_table + section_header->sh_name);
      const char* expected_symtab_name = ".symtab";
      if (strncmp(symtab_name, expected_symtab_name, strlen(expected_symtab_name)) == 0) {
        symbol_count = section_header->sh_size / sizeof(Elf32_Sym);
        symbol_table = reinterpret_cast<const Elf32_Sym*>(
          data + section_header->sh_offset);
      }
    }
    if (section_header->sh_type == SHT_STRTAB) {
      const char* strtab_name = (section_string_table + section_header->sh_name);
      const char* expected_strtab_name = ".strtab";
      if (strncmp(strtab_name, expected_strtab_name, strlen(expected_strtab_name)) == 0) {
        string_table = reinterpret_cast<const char*>(data + section_header->sh_offset);
      }
    }
  }
  if (string_table == nullptr || symbol_table == nullptr)
    return false;

  // Find our symbol!
  for (uint32_t i = 0; i < symbol_count; ++i) {
    const Elf32_Sym* symbol = symbol_table + i;
    if (symbol->st_name != 0) {
      const char* found_symbol_name = string_table + symbol->st_name;
      if (strncmp(found_symbol_name, symbol_name.c_str(), symbol_name.length()) == 0) {
        *symbol_addr = symbol->st_value;
        return true;
      }
    }
  }
  return false;
}