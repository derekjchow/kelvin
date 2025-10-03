# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb

from coralnpu_test_utils.core_mini_axi_interface import CoreMiniAxiInterface


class Fixture:

    def __init__(self, dut, **kwargs):
        self.core_mini_axi = CoreMiniAxiInterface(dut, **kwargs)
        self.entry_point = None
        self.symbols = {}

    @classmethod
    async def Create(cls, dut, **kwargs):
        if kwargs.get("highmem"):
            inst = cls(dut, csr_base_addr=0x200000)
        else:
            inst = cls(dut, **kwargs)
        await inst.core_mini_axi.init()
        await inst.core_mini_axi.reset()
        cocotb.start_soon(inst.core_mini_axi.clock.start())
        return inst

    async def load_elf_and_lookup_symbols(
        self,
        path: str,
        symbols: list[str],
    ):
        await self.core_mini_axi.reset()
        with open(path, "rb") as f:
            self.entry_point = await self.core_mini_axi.load_elf(f)
            self.symbols = {
                s: self.core_mini_axi.lookup_symbol(f, s)
                for s in symbols
            }

    async def write(self, symbol: str, data):
        await self.core_mini_axi.write(self.symbols[symbol], data)

    async def write_word(self, symbol: str, data):
        await self.core_mini_axi.write_word(self.symbols[symbol], data)

    async def write_ptr(
            self, addr_symbol: str, data_symbol: str, offset: int = 0):
        await self.core_mini_axi.write_word(
            self.symbols[addr_symbol], self.symbols[data_symbol] + offset)

    async def read(self, symbol: str, size: int):
        return await self.core_mini_axi.read(self.symbols[symbol], size)

    async def read_word(self, symbol: str):
        return await self.core_mini_axi.read_word(self.symbols[symbol])

    async def run_to_halt(self, timeout_cycles=10000):
        await self.core_mini_axi.execute_from(self.entry_point)
        return await self.core_mini_axi.wait_for_halted(
            timeout_cycles=timeout_cycles)

    async def run_to_fault(self, timeout_cycles=10000):
        await self.core_mini_axi.execute_from(self.entry_point)
        return await self.core_mini_axi.wait_for_fault(
            timeout_cycles=timeout_cycles)

    def fault(self):
        return self.core_mini_axi.dut.io_fault.value == 1
