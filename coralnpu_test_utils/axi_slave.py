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
from cocotb.queue import Queue
from cocotb.triggers import RisingEdge, FallingEdge

class AxiSlave:
    def __init__(self, dut, name, clock, reset, log, has_memory=False, mem_base_addr=0):
        self.dut = dut
        self.name = name
        self.clock = clock
        self.reset = reset
        self.log = log
        self.has_memory = has_memory
        self.mem_base_addr = mem_base_addr

        if self.has_memory:
            self.memory = {}

        self.ar_queue = Queue()
        self.aw_queue = Queue()
        self.w_queue = Queue()
        self.r_queue = Queue()
        self.b_queue = Queue()

    def start(self):
        cocotb.start_soon(self._aw_agent())
        cocotb.start_soon(self._w_agent())
        cocotb.start_soon(self._b_agent())
        cocotb.start_soon(self._ar_agent())
        cocotb.start_soon(self._r_agent())
        cocotb.start_soon(self._write_handler())
        cocotb.start_soon(self._read_handler())

    async def _read_handler(self):
        while True:
            ardata = await self.ar_queue.get()
            if self.has_memory:
                addr = ardata["addr"] - self.mem_base_addr
                num_bytes = 2**ardata["size"]
                read_bytes = bytearray()
                for i in range(num_bytes):
                    read_bytes.append(self.memory.get(addr + i, 0xBD))
                read_data = int.from_bytes(read_bytes, byteorder='little')
            else:
                read_data = 0xDEADBEEF

            # Create a dummy response
            rdata = {
                "id": ardata["id"],
                "data": read_data,
                "resp": 0,
                "last": 1
            }
            await self.r_queue.put(rdata)

    async def _write_handler(self):
        while True:
            awdata = await self.aw_queue.get()
            wdata = await self.w_queue.get()
            resp = 0
            if self.has_memory:
                addr = awdata["addr"] - self.mem_base_addr
                strb = int(wdata["strb"])
                data = wdata["data"]
                for i in range(len(data)):
                    if (strb >> i) & 1:
                        self.memory[addr + i] = data[len(data)-1-i]
            else:
                resp = 3 # DECERR
                self.log.error(f"Write received on slave {self.name}, which does not have memory.")

            # Create a response
            bdata = {
                "id": awdata["id"],
                "resp": resp,
            }
            await self.b_queue.put(bdata)

    async def _ar_agent(self):
        getattr(self.dut, f'io_{self.name}_read_addr_ready').value = 1
        while True:
          await RisingEdge(self.clock)
          try:
            if getattr(self.dut, f'io_{self.name}_read_addr_valid').value:
              ardata = dict()
              for prop in ["id", "addr", "size", "len", "burst"]:
                  ardata[prop] = int(getattr(self.dut, f'io_{self.name}_read_addr_bits_{prop}').value)
              await self.ar_queue.put(ardata)
          except Exception as e:
            print('X seen in _ar_agent: ' + str(e), flush=True)

    async def _r_agent(self, timeout=4096):
        while True:
          while True:
            await RisingEdge(self.clock)
            getattr(self.dut, f'io_{self.name}_read_data_valid').value = 0
            if self.r_queue.qsize():
              break
          rdata = await self.r_queue.get()
          getattr(self.dut, f'io_{self.name}_read_data_valid').value = 1
          for prop in ["id", "data", "resp", "last"]:
            getattr(self.dut, f'io_{self.name}_read_data_bits_{prop}').value = rdata[prop]
          await FallingEdge(self.clock)
          timeout_count = 0
          while getattr(self.dut, f'io_{self.name}_read_data_ready').value == 0:
            await FallingEdge(self.clock)
            timeout_count += 1
            if timeout_count >= timeout:
              assert False, "timeout waiting for rready"

    async def _aw_agent(self):
        getattr(self.dut, f'io_{self.name}_write_addr_ready').value = 1
        while True:
          await RisingEdge(self.clock)
          try:
            if getattr(self.dut, f'io_{self.name}_write_addr_valid').value:
              awdata = dict()
              for prop in ["id", "addr", "size", "len"]:
                  awdata[prop] = int(getattr(self.dut, f'io_{self.name}_write_addr_bits_{prop}').value)
              await self.aw_queue.put(awdata)
          except Exception as e:
            print('X seen in _aw_agent: ' + str(e), flush=True)

    async def _w_agent(self):
        getattr(self.dut, f'io_{self.name}_write_data_ready').value = 1
        while True:
          await RisingEdge(self.clock)
          try:
            if getattr(self.dut, f'io_{self.name}_write_data_valid').value:
              wdata = dict()
              wdata["data"] = getattr(self.dut, f'io_{self.name}_write_data_bits_data').value.buff
              for prop in ["strb", "last"]:
                  wdata[prop] = getattr(self.dut, f'io_{self.name}_write_data_bits_{prop}').value
              await self.w_queue.put(wdata)
          except Exception as e:
            print('X seen in _w_agent: ' + str(e), flush=True)

    async def _b_agent(self):
        while True:
          while True:
            await RisingEdge(self.clock)
            getattr(self.dut, f'io_{self.name}_write_resp_valid').value = 0
            if self.b_queue.qsize():
              break
          bdata = await self.b_queue.get()
          getattr(self.dut, f'io_{self.name}_write_resp_valid').value = 1
          for prop in ["id", "resp"]:
              getattr(self.dut, f'io_{self.name}_write_resp_bits_{prop}').value = bdata[prop]
          await FallingEdge(self.clock)
          timeout_count = 0
          while getattr(self.dut, f'io_{self.name}_write_resp_ready').value == 0:
            await FallingEdge(clock)
            timeout_count += 1
            if timeout_count >= timeout:
              assert False, "timeout waiting for bready"
