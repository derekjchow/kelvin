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
import itertools
import math
import numpy as np
import random


from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge
from elftools.elf.elffile import ELFFile


class AxiResp:
  OKAY = 0
  EXOKAY = 1
  SLVERR = 2
  DECERR = 3


class AxiBurst:
  FIXED = 0
  INCR = 1
  WRAP = 2


def format_line_from_word(word, addr):
  shift = addr % 16
  line = np.zeros([4], dtype=np.uint32)
  line[0] = word
  line = np.roll(line.view(np.uint8), shift)
  return convert_to_binary_value(line)

def pad_to_multiple(x, multiple):
  padding = multiple - (len(x) % multiple)
  if padding == multiple:
    return x
  return np.pad(x, (0, padding))

def get_strb(mask):
  val = 0
  for m in reversed(mask):
    val = val << 1
    if m:
      val += 1
  return val

def convert_to_binary_value(data):
  return cocotb.types.LogicArray.from_bytes(data, byteorder="little")


class CoreMiniAxiInterface:
  def __init__(self, dut):
    self.dut = dut
    self.dut.io_aclk.value = 0
    self.dut.io_irq.value = 0
    self.dut.io_te.value = 0
    self.dut.io_axi_slave_read_addr_valid.value = 0
    self.dut.io_axi_slave_read_addr_bits_addr.value = 0
    self.dut.io_axi_slave_read_data_ready.value = 0
    self.dut.io_axi_slave_write_addr_valid.value = 0
    self.dut.io_axi_slave_write_addr_bits_addr.value = 0
    self.dut.io_axi_slave_write_data_valid.value = 0
    self.dut.io_axi_slave_write_resp_ready.value = 0
    self.dut.io_axi_master_read_data_valid.value = 0
    self.dut.io_axi_master_write_resp_valid.value = 0
    self.clock = Clock(dut.io_aclk, 10, unit="us")
    self.memory_base_addr = 0x20000000
    self.memory = np.zeros([4 * 1024 * 1024], dtype=np.uint8)
    self.master_arfifo = Queue()
    self.master_awfifo = Queue()
    self.master_rfifo = Queue()
    self.master_wfifo = Queue()
    self.master_bfifo = Queue()
    self.slave_arfifo = Queue()
    self.slave_awfifo = Queue()
    self.slave_rfifo = Queue()
    self.slave_wfifo = Queue()
    self.slave_bfifo = Queue()

  async def init(self):
    cocotb.start_soon(self.master_awagent())
    cocotb.start_soon(self.master_wagent())
    cocotb.start_soon(self.master_bagent())
    cocotb.start_soon(self.master_aragent())
    cocotb.start_soon(self.master_ragent())
    cocotb.start_soon(self.slave_awagent())
    cocotb.start_soon(self.slave_wagent())
    cocotb.start_soon(self.slave_bagent())
    cocotb.start_soon(self.slave_aragent())
    cocotb.start_soon(self.slave_ragent())
    cocotb.start_soon(self.memory_write_agent())
    cocotb.start_soon(self.memory_read_agent())

  async def slave_awagent(self, timeout=4096):
    self.dut.io_axi_slave_write_addr_valid.value = 0
    self.dut.io_axi_slave_write_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_write_addr_bits_lock.value   = 0
    self.dut.io_axi_slave_write_addr_bits_cache.value  = 0
    self.dut.io_axi_slave_write_addr_bits_qos.value    = 0
    self.dut.io_axi_slave_write_addr_bits_region.value = 0
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        self.dut.io_axi_slave_write_addr_valid.value = 0
        if self.slave_awfifo.qsize():
          break
      awdata = await self.slave_awfifo.get()
      self.dut.io_axi_slave_write_addr_valid.value = 1
      self.dut.io_axi_slave_write_addr_bits_addr.value = awdata["addr"]
      self.dut.io_axi_slave_write_addr_bits_id.value = awdata["id"]
      self.dut.io_axi_slave_write_addr_bits_len.value = awdata["len"]
      self.dut.io_axi_slave_write_addr_bits_size.value = awdata["size"]
      self.dut.io_axi_slave_write_addr_bits_burst.value = awdata["burst"]
      await FallingEdge(self.dut.io_aclk)
      timeout_count = 0
      while self.dut.io_axi_slave_write_addr_ready.value == 0:
        await FallingEdge(self.dut.io_aclk)
        timeout_count += 1
        if timeout_count >= timeout:
          assert False, "timeout waiting for awready"

  async def slave_wagent(self, timeout=4096):
    self.dut.io_axi_slave_write_data_valid.value = 0
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        self.dut.io_axi_slave_write_data_valid.value = 0
        if self.slave_wfifo.qsize():
          break
      wdata = await self.slave_wfifo.get()
      self.dut.io_axi_slave_write_data_valid.value = 1
      self.dut.io_axi_slave_write_data_bits_data.value = wdata["data"]
      self.dut.io_axi_slave_write_data_bits_strb.value = wdata["strb"]
      self.dut.io_axi_slave_write_data_bits_last.value = wdata["last"]
      await FallingEdge(self.dut.io_aclk)
      timeout_count = 0
      while self.dut.io_axi_slave_write_data_ready.value == 0:
        await FallingEdge(self.dut.io_aclk)
        timeout_count += 1
        if timeout_count >= timeout:
          assert False, "timeout waiting for wready"

  async def slave_bagent(self):
    self.dut.io_axi_slave_write_resp_ready.value = 1
    while True:
      await RisingEdge(self.dut.io_aclk)
      try:
        if self.dut.io_axi_slave_write_resp_valid.value:
          bdata = dict()
          bdata["id"] = self.dut.io_axi_slave_write_resp_bits_id
          bdata["resp"] = self.dut.io_axi_slave_write_resp_bits_resp
          await self.slave_bfifo.put(bdata)
      except Exception as e:
        print('X seen in slave_bagent: ' + str(e))

  async def slave_aragent(self, timeout=4096):
    self.dut.io_axi_slave_read_addr_valid.value = 0
    self.dut.io_axi_slave_read_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_read_addr_bits_lock.value   = 0
    self.dut.io_axi_slave_read_addr_bits_cache.value  = 0
    self.dut.io_axi_slave_read_addr_bits_qos.value    = 0
    self.dut.io_axi_slave_read_addr_bits_region.value = 0
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        self.dut.io_axi_slave_read_addr_valid.value = 0
        if self.slave_arfifo.qsize():
          break
      ardata = await self.slave_arfifo.get()
      self.dut.io_axi_slave_read_addr_valid.value = 1
      self.dut.io_axi_slave_read_addr_bits_addr.value = ardata["addr"]
      self.dut.io_axi_slave_read_addr_bits_id.value = ardata["id"]
      self.dut.io_axi_slave_read_addr_bits_len.value = ardata["len"]
      self.dut.io_axi_slave_read_addr_bits_size.value = ardata["size"]
      self.dut.io_axi_slave_read_addr_bits_burst.value = ardata["burst"]
      await FallingEdge(self.dut.io_aclk)
      timeout_count = 0
      while self.dut.io_axi_slave_read_addr_ready.value == 0:
        await FallingEdge(self.dut.io_aclk)
        timeout_count += 1
        if timeout_count >= timeout:
          assert False, "timeout waiting for arready"

  async def slave_ragent(self):
    self.dut.io_axi_slave_read_data_ready.value = 1
    while True:
      await RisingEdge(self.dut.io_aclk)
      try:
        if self.dut.io_axi_slave_read_data_valid.value:
          rdata = dict()
          # Parse binary string value, replacing "X" with zero
          # TODO(derekjchow): Consider passing in a x mask for checking downstream
          nonx_data = str(self.dut.io_axi_slave_read_data_bits_data.value).replace("X", "0")
          nonx_data = [ int(nonx_data[i:i+8], 2) for i in range(0, len(nonx_data), 8)]
          nonx_data = np.array(nonx_data, dtype=np.uint8)
          rdata["data"] = nonx_data
          rdata["id"] = self.dut.io_axi_slave_read_data_bits_id.value
          rdata["last"] = self.dut.io_axi_slave_read_data_bits_last.value
          rdata["resp"] = self.dut.io_axi_slave_read_data_bits_resp.value
          await self.slave_rfifo.put(rdata)
      except Exception as e:
        print('X seen in slave_ragent: ' + str(e))

  async def memory_read_agent(self):
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        if self.master_arfifo.qsize():
          break
      ardata = await self.master_arfifo.get()
      data = self.read_memory(ardata)
      if data is None:
        for i in range(0, ardata["len"] + 1):
          rdata = dict()
          rdata["id"] = ardata["id"]
          rdata["data"] = 0
          rdata["resp"] = AxiResp.SLVERR
          rdata["last"] = 1 if (i == ardata["len"]) else 0
          await self.master_rfifo.put(rdata)
      else:
        for i in range(0, ardata["len"] + 1):
          rdata = dict()
          rdata["id"] = ardata["id"]
          rdata["data"] = convert_to_binary_value(data)
          rdata["resp"] = AxiResp.OKAY
          rdata["last"] = 1 if (i == ardata["len"]) else 0
          await self.master_rfifo.put(rdata)

  async def master_aragent(self):
    self.dut.io_axi_master_read_addr_ready.value = 1
    while True:
      await RisingEdge(self.dut.io_aclk)
      try:
        if self.dut.io_axi_master_read_addr_valid.value:
          ardata = dict()
          ardata["id"] = self.dut.io_axi_master_read_addr_bits_id.value.to_unsigned()
          ardata["addr"] = self.dut.io_axi_master_read_addr_bits_addr.value.to_unsigned()
          ardata["size"] = self.dut.io_axi_master_read_addr_bits_size.value.to_unsigned()
          ardata["len"] = self.dut.io_axi_master_read_addr_bits_len.value.to_unsigned()
          ardata["burst"] = self.dut.io_axi_master_read_addr_bits_burst.value.to_unsigned()
          await self.master_arfifo.put(ardata)
      except Exception as e:
        print('X seen in master_aragent: ' + str(e))

  async def master_ragent(self, timeout=4096):
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        self.dut.io_axi_master_read_data_valid.value = 0
        if self.master_rfifo.qsize():
          break
      rdata = await self.master_rfifo.get()
      self.dut.io_axi_master_read_data_valid.value = 1
      self.dut.io_axi_master_read_data_bits_id.value = rdata["id"]
      self.dut.io_axi_master_read_data_bits_data.value = rdata["data"]
      self.dut.io_axi_master_read_data_bits_resp.value = rdata["resp"]
      self.dut.io_axi_master_read_data_bits_last.value = rdata["last"]
      await FallingEdge(self.dut.io_aclk)
      timeout_count = 0
      while self.dut.io_axi_master_read_data_ready.value == 0:
        await FallingEdge(self.dut.io_aclk)
        timeout_count += 1
        if timeout_count >= timeout:
          assert False, "timeout waiting for rready"

  async def memory_write_agent(self):
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        if self.master_awfifo.qsize() and self.master_wfifo.qsize():
          break
      awdata = await self.master_awfifo.get()
      data = []
      strb = []
      while True:
        wdata = await self.master_wfifo.get()
        line = np.frombuffer(wdata['data'], dtype=np.uint8)
        data.append(list(reversed(line)))
        strb.append(list(reversed(wdata['strb'])))
        if wdata['last']:
          break
      assert len(data) == awdata['len'] + 1
      assert len(strb) == awdata['len'] + 1
      ret = self.write_memory({
        'addr': awdata['addr'],
        'size': awdata['size'],
        'len': awdata['len'],
        'data': data,
        'strb': strb,
      })
      bdata = dict()
      bdata["id"] = awdata["id"]
      bdata["resp"] = AxiResp.OKAY if ret else AxiResp.SLVERR
      await self.master_bfifo.put(bdata)

  async def master_awagent(self):
    self.dut.io_axi_master_write_addr_ready.value = 1
    while True:
      await RisingEdge(self.dut.io_aclk)
      try:
        if self.dut.io_axi_master_write_addr_valid.value:
          awdata = dict()
          awdata["id"] = self.dut.io_axi_master_write_addr_bits_id.value.to_unsigned()
          awdata["addr"] = self.dut.io_axi_master_write_addr_bits_addr.value.to_unsigned()
          awdata["size"] = self.dut.io_axi_master_write_addr_bits_size.value.to_unsigned()
          awdata["len"] = self.dut.io_axi_master_write_addr_bits_len.value.to_unsigned()
          await self.master_awfifo.put(awdata)
      except Exception as e:
        print('X seen in master_awagent: ' + str(e))

  async def master_wagent(self):
    self.dut.io_axi_master_write_data_ready.value = 1
    while True:
      await RisingEdge(self.dut.io_aclk)
      try:
        if self.dut.io_axi_master_write_data_valid.value:
          wdata = dict()
          wdata["data"] = self.dut.io_axi_master_write_data_bits_data.value.buff
          wdata["strb"] = self.dut.io_axi_master_write_data_bits_strb.value
          wdata["last"] = self.dut.io_axi_master_write_data_bits_last.value
          await self.master_wfifo.put(wdata)
      except Exception as e:
        print('X seen in master_wagent: ' + str(e))

  async def master_bagent(self, timeout=4096):
    while True:
      while True:
        await RisingEdge(self.dut.io_aclk)
        self.dut.io_axi_master_write_resp_valid.value = 0
        if self.master_bfifo.qsize():
          break
      bdata = await self.master_bfifo.get()
      self.dut.io_axi_master_write_resp_valid.value = 1
      self.dut.io_axi_master_write_resp_bits_id.value = bdata["id"]
      self.dut.io_axi_master_write_resp_bits_resp.value = bdata["resp"]
      await FallingEdge(self.dut.io_aclk)
      timeout_count = 0
      while self.dut.io_axi_master_write_resp_ready.value == 0:
        await FallingEdge(self.dut.io_aclk)
        timeout_count += 1
        if timeout_count >= timeout:
          assert False, "timeout waiting for bready"

  async def reset(self):
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(1, unit="us")
    self.dut.io_aresetn.setimmediatevalue(0)
    await Timer(1, unit="us")
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(1, unit="us")

  async def halt(self):
    kelvin_reset_csr_addr = 0x30000
    await self.write_word(kelvin_reset_csr_addr, 3)

  async def _write_addr(self, addr, size, burst_len=1, axi_id=0, burst=AxiBurst.INCR):
    awdata = dict()
    awdata["addr"] = addr
    awdata["id"] = axi_id
    awdata["len"] = burst_len - 1
    awdata["size"] = size
    awdata["burst"] = burst
    await self.slave_awfifo.put(awdata)

  async def _wait_write_response(self, delay_bready: int = 0):
    self.dut.io_axi_slave_write_resp_ready.value = 0
    if delay_bready:
      await ClockCycles(self.dut.io_aclk, delay_bready)
    self.dut.io_axi_slave_write_resp_ready.value = 1
    timeout_cycles = 100
    cyclesawaited = 0
    while self.dut.io_axi_slave_write_resp_valid.value != 1 and \
          timeout_cycles > 0:
       await ClockCycles(self.dut.io_aclk, 1)
       cyclesawaited += 1
       timeout_cycles = timeout_cycles - 1
    assert timeout_cycles > 0
    if cyclesawaited == 0:
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_write_resp_ready.value = 0

  async def _write_data_beat(self, data, mask, last):
    """Writes one beat to the write data line."""
    assert len(data) % 16 == 0
    assert len(mask) % 16 == 0
    wdata = dict()
    wdata["data"] = convert_to_binary_value(data)
    wdata["strb"] = get_strb(mask)
    wdata["last"] = last
    await self.slave_wfifo.put(wdata)

  def _determine_transaction_size(self, addr: int, data_len: int) -> int:
    # Transactions cannot cross 4k boundary
    offset4096 = addr % 4096
    remainder4096 = 4096 - offset4096
    # Max transaction size is 256 beats * 16 bytes, but cannot cross 4kB boundary
    max_transaction_size_bytes = min(4096, remainder4096)
    return min(data_len, max_transaction_size_bytes)

  async def _write_data(self, addr, data, masks, beats):
    beats_sent = 0
    while len(data) > 0:
      base_addr = (addr // 16) * 16
      sub_addr = addr - base_addr
      bytes_to_write = 16 - sub_addr
      bytes_to_write = min(len(data), bytes_to_write)
      local_data = data[0:bytes_to_write]
      local_data = np.pad(local_data, (sub_addr, 0))
      local_data = pad_to_multiple(local_data, 16)
      local_masks = masks[0:bytes_to_write]
      local_masks = np.pad(local_masks, (sub_addr, 0))
      local_masks = pad_to_multiple(local_masks, 16)
      data = data[bytes_to_write:]
      masks = masks[bytes_to_write:]
      last = (len(data) == 0)
      # TODO(derekjchow): Insert RNG delays
      await self._write_data_beat(local_data, local_masks, last)
      addr = addr + bytes_to_write
      beats_sent = beats_sent + 1
    assert beats_sent == beats

  async def _write_transaction(self,
                               addr: int,
                               data: np.array,
                               masks: np.array,
                               delay_bready: int = 0,
                               axi_id: int = 0,
                               burst: AxiBurst = AxiBurst.INCR) -> None:
    # Compute number of beats
    start_addr = addr
    end_addr = addr + len(data) - 1 # Last address written
    start_line = start_addr // 16
    end_line = end_addr // 16
    beats = (end_line - start_line) + 1
    # Compute size of transaction
    # TODO(derekjchow): Fuzz element size?
    write_addr_size = math.ceil(math.log2(len(data)))
    write_addr_size = min(write_addr_size, 4) # Size of 16 for increment
    write_addr_task = self._write_addr(addr, write_addr_size, beats, axi_id, burst)
    write_data_task = self._write_data(addr, data, masks, beats)
    await write_addr_task
    await write_data_task
    bdata = await self.slave_bfifo.get()
    assert bdata["id"].value == axi_id

  async def write(self,
                  addr: int,
                  data: np.array,
                  delay_bready: int = 0,
                  masks: np.array = None,
                  burst: AxiBurst = AxiBurst.INCR) -> None:
    """Writes data into Kelvin memory."""
    axi_id = random.randint(0,63)
    data = data.view(np.uint8)
    if masks is None:
      masks = np.copy(np.ones_like(data, dtype=bool))
    while len(data) > 0:
      transaction_size = self._determine_transaction_size(addr, len(data))
      local_data = data[0:transaction_size]
      local_masks = masks[0:transaction_size]
      await self._write_transaction(addr, local_data, local_masks, delay_bready, axi_id, burst)
      addr += len(local_data)
      data = data[transaction_size:]
      masks = masks[transaction_size:]

  async def write_word(self, addr: int, data: int) -> None:
    axi_id = random.randint(0,63)
    await self.write(addr, np.array([data], dtype=np.uint32), axi_id)

  async def _read_addr(self,
                       addr: int,
                       size: int,
                       beats: int = 1,
                       axi_id: int = 0,
                       burst: AxiBurst = AxiBurst.INCR):
    ardata = dict()
    ardata["addr"] = addr
    ardata["id"] = axi_id
    ardata["len"] = beats - 1
    ardata["size"] = size
    ardata["burst"] = burst
    await self.slave_arfifo.put(ardata)

  async def _read_data(self, expected_resp=AxiResp.OKAY, axi_id=0):
    rdata = await self.slave_rfifo.get()
    data = np.frombuffer(
        rdata["data"],
        dtype=np.uint8)
    last = rdata["last"]
    assert rdata["resp"] == expected_resp
    assert rdata["id"] == axi_id
    return last, np.flip(data)

  async def _read_transaction(self,
                              addr: int,
                              bytes_to_read: int,
                              expected_resp: AxiResp = AxiResp.OKAY,
                              axi_id: int = 0,
                              burst: AxiBurst = AxiBurst.INCR):
    # Compute number of beats
    start_addr = addr
    end_addr = addr + bytes_to_read - 1 # Last address written
    start_line = start_addr // 16
    end_line = end_addr // 16
    beats = (end_line - start_line) + 1
    await self._read_addr(start_line * 16, 4, beats, axi_id, burst)
    data = []
    bytes_remaining = bytes_to_read
    for beat in range(beats):
      base_addr = (addr // 16) * 16
      sub_addr = addr - base_addr
      (last, beat_data) = await self._read_data(expected_resp, axi_id)
      beat_data = beat_data[sub_addr:]
      if len(beat_data) > bytes_remaining:
        beat_data = beat_data[0:bytes_remaining]
      data.append(beat_data)
      bytes_remaining = bytes_remaining - len(beat_data)
      addr = addr + len(beat_data)
      if beat == (beats - 1):
        assert last
    return np.concatenate(data)

  async def read(self, addr, bytes_to_read, burst: AxiBurst=AxiBurst.INCR):
    """Reads data from Kelvin Memory."""
    axi_id = random.randint(0,63)
    data = []
    while bytes_to_read > 0:
      transaction_size = self._determine_transaction_size(addr, bytes_to_read)
      data.append(await self._read_transaction(addr, transaction_size, 0, axi_id, burst))
      bytes_to_read -= transaction_size
      addr += transaction_size
    if len(data) == 0:
      return data
    return np.concatenate(data)

  async def read_word(self, addr, expected_resp=AxiResp.OKAY):
    axi_id = random.randint(0,63)
    data = []
    offset = addr % 16
    await self._read_addr(addr, 4, 1, axi_id)
    (last, beat_data) = await self._read_data(expected_resp, axi_id)
    assert (last == True)
    data.append(beat_data[offset:offset+4])
    return np.concatenate(data)

  async def load_elf(self, f):
    """Loads an ELF file into DUT memory, and returns the entry point address."""
    elf_file = ELFFile(f)
    entry_point = elf_file.header["e_entry"]
    for segment in elf_file.iter_segments(type="PT_LOAD"):
      header = segment.header
      data = np.frombuffer(segment.data(), dtype=np.uint8)
      await self.write(header["p_paddr"], data)
    return entry_point

  def lookup_symbol(self, f, symbol_name):
    elf_file = ELFFile(f)
    symtab_section = next(elf_file.iter_sections(type='SHT_SYMTAB'))
    i1 = symtab_section.get_symbol_by_name(symbol_name)
    if i1:
      return i1[0].entry['st_value']
    return None

  def write_memory(self, wdata):
    """Write `wdata` to memory."""
    addr = int(wdata["addr"])
    data = wdata["data"]
    strb = wdata["strb"]
    if addr < self.memory_base_addr or addr >= (self.memory_base_addr + len(self.memory)):
      return False
    line_start = (addr - self.memory_base_addr) & 0xFFFFFFF0
    flat_data = list(itertools.chain(*data))
    flat_strb = list(itertools.chain(*strb))
    for i in range(0,len(flat_data)):
      if flat_strb[i] == 1:
        self.memory[line_start + i] = flat_data[i]
    return True

  def read_memory(self, raddr):
    addr = int(raddr["addr"])
    size = (2 ** raddr["size"])
    if addr < self.memory_base_addr or addr >= (self.memory_base_addr + len(self.memory)):
      return None
    offset = (addr - self.memory_base_addr)
    data = self.memory[offset:offset+size]
    padded_data = pad_to_multiple(data, 16)
    line_shift = addr % 16
    return np.roll(padded_data.view(np.uint8), line_shift)

  async def execute_from(self, start_pc):
    # Program starting address
    kelvin_pc_csr_addr = 0x30004
    await self.write_word(kelvin_pc_csr_addr, start_pc)
    # Release clock gate
    kelvin_reset_csr_addr = 0x30000
    await self.write_word(kelvin_reset_csr_addr, 1)
    # Release reset
    await self.write_word(kelvin_reset_csr_addr, 0)

  async def wait_for_wfi(self, timeout_cycles=1000):
    while self.dut.io_wfi.value != 1 and timeout_cycles > 0:
      await ClockCycles(self.dut.io_aclk, 1)
      timeout_cycles = timeout_cycles - 1
    assert timeout_cycles > 0

  async def raise_irq(self, cycles=1):
    self.dut.io_irq.value = 1
    await ClockCycles(self.dut.io_aclk, cycles)
    self.dut.io_irq.value = 0

  async def wait_for_halted(self, timeout_cycles=1000):
    while self.dut.io_halted.value != 1 and timeout_cycles > 0:
      await ClockCycles(self.dut.io_aclk, 1)
      timeout_cycles = timeout_cycles - 1
    assert timeout_cycles > 0

  async def wait_for_halted_semihost(self, elf, timeout_cycles=1000000):
    tohost = self.lookup_symbol(elf, "tohost")
    assert tohost != None
    if cocotb.SIM_NAME == "Verilator":
      rv = await self.watch(tohost, timeout_cycles=timeout_cycles)
      assert np.sum(np.frombuffer(rv[12:16], dtype=np.uint8)) == 1
    else:
      initial_rv = await self.read_word(tohost)
      while True:
        await ClockCycles(self.dut.io_aclk, 1)
        rv = await self.read_word(tohost)
        if not (rv == initial_rv).all():
          assert np.sum(rv) == 1
          break
        timeout_cycles = timeout_cycles - 1
        assert timeout_cycles > 0

  async def watch(self, addr, timeout_cycles=1_000_000):
    elem_addr = addr % 16
    line_addr = addr - elem_addr
    expected_wmask = 0xF << elem_addr
    while timeout_cycles > 0:
      if self.dut.core.io_dbus_valid.value == 1:
        if self.dut.core.io_dbus_addr.value == line_addr:
          if self.dut.core.io_dbus_write.value == 1:
            wmask = int(self.dut.core.io_dbus_wmask.value)
            if (expected_wmask & wmask) == expected_wmask:
              return self.dut.core.io_dbus_wdata.value.buff

      await ClockCycles(self.dut.io_aclk, 1)
      timeout_cycles = timeout_cycles - 1
    assert timeout_cycles > 0
