import cocotb
import glob
import itertools
import math
import numpy as np
import os
import tqdm
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

def format_line_from_word(word, addr):
  shift = addr % 16
  line = np.zeros([4], dtype=np.uint32)
  line[0] = word
  line = np.roll(line.view(np.uint8), shift)
  return convert_to_binary_value(line)

async def halt(self):
  kelvin_reset_csr_addr = 0x30000
  await self.write_word(kelvin_reset_csr_addr, 3)

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
    await cocotb.start(self.master_awagent())
    await cocotb.start(self.master_wagent())
    await cocotb.start(self.master_bagent())
    await cocotb.start(self.master_aragent())
    await cocotb.start(self.master_ragent())

    await cocotb.start(self.slave_awagent())
    await cocotb.start(self.slave_wagent())
    await cocotb.start(self.slave_bagent())
    await cocotb.start(self.slave_aragent())
    await cocotb.start(self.slave_ragent())

    await cocotb.start(self.memory_write_agent())
    await cocotb.start(self.memory_read_agent())

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
      word = self.read_memory(ardata)
      if word is None:
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
          rdata["data"] = format_line_from_word(word, ardata["addr"])
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
    data = self.memory[offset:offset+size].astype(np.uint32)
    data_flat = 0
    for i in range(0,size):
      data_flat = data_flat + (data[i] << (i * 8))
    return data_flat

  async def execute_from(self, start_pc):
    # Program starting address
    kelvin_pc_csr_addr = 0x30004
    await self.write_word(kelvin_pc_csr_addr, start_pc)

    # Release clock gate
    kelvin_reset_csr_addr = 0x30000
    await self.write_word(kelvin_reset_csr_addr, 1)

    # Release reset
    await self.write_word(kelvin_reset_csr_addr, 0)

  async def wait_for_wfi(self):
    while self.dut.io_wfi.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)

  async def raise_irq(self, cycles=1):
    self.dut.io_irq.value = 1
    await ClockCycles(self.dut.io_aclk, cycles)
    self.dut.io_irq.value = 0

  async def wait_for_halted(self, timeout_cycles=1000):
    while self.dut.io_halted.value != 1 and timeout_cycles > 0:
      await ClockCycles(self.dut.io_aclk, 1)
      timeout_cycles = timeout_cycles - 1
    assert timeout_cycles > 0

@cocotb.test()
async def core_mini_axi_basic_write_read_memory(dut):
    """Basic test to check if TCM memory can be written and read back."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())

    # Test reading/writing words
    await core_mini_axi.write_word(0x100, 0x42)
    await core_mini_axi.write_word(0x104, 0x43)
    rdata = (await core_mini_axi.read(0x100, 16)).view(np.uint32)
    assert (rdata[0:2] == np.array([0x42, 0x43])).all()

    # Three write/read data burst
    wdata = np.arange(48, dtype=np.uint8)
    await core_mini_axi.write(0x0, wdata)

    # Unaligned read, taking two bursts
    rdata = await core_mini_axi.read(0x8, 16)
    assert (np.arange(8, 24, dtype=np.uint8) == rdata).all()

    # Unaligned write, taking two bursts
    wdata = np.arange(20, dtype=np.uint8)
    await core_mini_axi.write(0x204, wdata)
    rdata = await core_mini_axi.read(0x200, 32)
    assert (wdata == rdata[4:24]).all()

    # Iterate over both TCMs with all valid AXI sizes
    for size in range(13):
      txn_bytes = 2 ** size
      wdata = np.random.randint(0, 255, txn_bytes, dtype=np.uint8)
      for i in tqdm.tqdm(range((8 * 1024) // txn_bytes)):
        await core_mini_axi.write(i * txn_bytes, wdata)
      for i in tqdm.tqdm(range((32 * 1024) // txn_bytes)):
        await core_mini_axi.write(0x10000 + (i * txn_bytes), wdata)

      for i in tqdm.tqdm(range((8 * 1024) // txn_bytes)):
        rdata = await core_mini_axi.read(i * txn_bytes, txn_bytes)
        assert(rdata == wdata).all()
      for i in tqdm.tqdm(range((32 * 1024) // txn_bytes)):
        rdata = await core_mini_axi.read(0x10000 + (i * txn_bytes), txn_bytes)
        assert(rdata == wdata).all()

@cocotb.test()
async def core_mini_axi_run_wfi_in_all_slots(dut):
    """Tests the WFI instruction in each of the 4 issue slots."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    cocotb.start_soon(core_mini_axi.clock.start())
    await core_mini_axi.init()

    for slot in range(0,4):
      with open(f"../tests/cocotb/wfi_slot_{slot}.elf", "rb") as f:
        await core_mini_axi.reset()
        entry_point = await core_mini_axi.load_elf(f)
        await core_mini_axi.execute_from(entry_point)

        await core_mini_axi.wait_for_wfi()
        await core_mini_axi.raise_irq()
        await core_mini_axi.wait_for_halted()

@cocotb.test()
async def core_mini_axi_slow_bready(dut):
  """Test that BVALID stays high until BREADY is presented"""
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  wdata = np.arange(16, dtype=np.uint8)
  for i in tqdm.trange(100):
    bready_delay = random.randint(0, 50)
    await core_mini_axi.write(i*32, wdata, delay_bready=bready_delay)

  for _ in tqdm.trange(100):
    rdata = await core_mini_axi.read(i*32, 16)
    assert (wdata == rdata).all()

@cocotb.test()
async def core_mini_axi_write_read_memory_stress_test(dut):
    """Stress test reading/writing from DTCM."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())

    with open(f"../tests/cocotb/stress_test.elf", "rb") as f:
      halt = core_mini_axi.lookup_symbol(f, "halt")
      dtcm_vec = core_mini_axi.lookup_symbol(f, "dtcm_vec")
      entry_point = await core_mini_axi.load_elf(f)
    await core_mini_axi.execute_from(entry_point)

    # Range for a DTCM buffer we can read/write too.
    DTCM_START = dtcm_vec
    DTCM_SIZE = 0x2000
    DTCM_END = DTCM_START + DTCM_SIZE
    dtcm_model_buffer = await core_mini_axi.read(DTCM_START, DTCM_SIZE)

    for i in tqdm.trange(1000):
      start_addr = random.randint(DTCM_START, DTCM_END-2)
      end_addr = random.randint(start_addr, DTCM_END-1)
      transaction_length = end_addr - start_addr

      if random.randint(0, 1) == 1:
        wdata = np.random.randint(0, 256, transaction_length, dtype=np.uint8)
        await core_mini_axi.write(start_addr, wdata)
        dtcm_model_buffer[start_addr-DTCM_START: end_addr-DTCM_START] = wdata
      else:
        expected = dtcm_model_buffer[start_addr-DTCM_START: end_addr-DTCM_START]
        rdata = await core_mini_axi.read(start_addr, transaction_length)
        assert (expected == rdata).all()

    await core_mini_axi.write_word(halt, 1)
    await core_mini_axi.wait_for_halted()

@cocotb.test()
async def core_mini_axi_master_write_alignment(dut):
  """Test data alignment during AXI master writes"""
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  with open("../tests/cocotb/align_test.elf", "rb") as f:
    entry_point = await core_mini_axi.load_elf(f)
    await core_mini_axi.execute_from(entry_point)

    await core_mini_axi.wait_for_halted(timeout_cycles=10000)
    assert core_mini_axi.dut.io_fault.value == 0

@cocotb.test()
async def core_mini_axi_finish_txn_before_halt_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  with open("../tests/cocotb/finish_txn_before_halt.elf", "rb") as f:
    entry_point = await core_mini_axi.load_elf(f)
    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_halted()

    assert (core_mini_axi.master_arfifo.qsize() + \
            core_mini_axi.master_rfifo.qsize() + \
            core_mini_axi.master_awfifo.qsize() + \
            core_mini_axi.master_wfifo.qsize() + \
            core_mini_axi.master_bfifo.qsize()) == 0

@cocotb.test()
async def core_mini_axi_riscv_tests(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  cocotb.start_soon(core_mini_axi.clock.start())

  riscv_test_elfs = glob.glob("../tests/cocotb/riscv-tests/*.elf")
  for elf in tqdm.tqdm(riscv_test_elfs):
    with open(elf, "rb") as f:
      await core_mini_axi.reset()
      entry_point = await core_mini_axi.load_elf(f)
      await core_mini_axi.execute_from(entry_point)
      await core_mini_axi.wait_for_halted()
      assert core_mini_axi.dut.io_fault.value == 0

@cocotb.test()
async def core_mini_axi_riscv_dv(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  cocotb.start_soon(core_mini_axi.clock.start())

  riscv_dv_elfs = glob.glob("../tests/cocotb/riscv-dv/*.o")
  for elf in tqdm.tqdm(riscv_dv_elfs):
    with open(elf, "rb") as f:
      await core_mini_axi.reset()
      entry_point = await core_mini_axi.load_elf(f)
      await core_mini_axi.execute_from(entry_point)
      await core_mini_axi.wait_for_halted(timeout_cycles=1000000)
      assert core_mini_axi.dut.io_fault.value == 0

@cocotb.test()
async def core_mini_axi_csr_test(dut):
  """Exercises the CoreAxiCSR module."""
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  for _ in tqdm.tqdm(range(10000)):
    reset_csr_wdata = np.random.randint(0, 255, 4, dtype=np.uint8)
    await core_mini_axi.write(0x30000, reset_csr_wdata)
    reset_csr_rdata = await core_mini_axi.read_word(0x30000)
    assert (reset_csr_wdata == reset_csr_rdata).all()

  for _ in tqdm.tqdm(range(10000)):
    pc_start_csr_wdata = np.random.randint(0, 255, 4, dtype=np.uint8)
    await core_mini_axi.write(0x30004, pc_start_csr_wdata)
    pc_start_csr_rdata = await core_mini_axi.read_word(0x30004)
    assert (pc_start_csr_wdata == pc_start_csr_rdata).all()

  # Neither of these are valid CSRs, but this will exercise the top half of the wdata field.
  for _ in tqdm.tqdm(range(10000)):
    csr_wdata = np.random.randint(0, 255, 4, dtype=np.uint8)
    await core_mini_axi.write(0x30008, csr_wdata)
    await core_mini_axi.write(0x3000c, csr_wdata)

  status_reg_csr_rdata = await core_mini_axi.read_word(0x30008)
  # Because we write a random value to the reset CSR, it's possible
  # for this register to either be 0, 1, or 3.
  assert (status_reg_csr_rdata.view(np.uint32) <= 3)

  # Read valid CSRs
  for i in range(8):
    misc_csr_rdata = await core_mini_axi.read_word(0x30100 + (4 * i))
  # Read invalid CSRs, expect error response
  for i in range(3, 0x100 // 4):
    misc_csr_rdata = await core_mini_axi.read_word(0x30000 + (4 * i), expected_resp=AxiResp.SLVERR)
  for i in range(8, 0x2000 // 4):
    misc_csr_rdata = await core_mini_axi.read_word(0x30100 + (4 * i), expected_resp=AxiResp.SLVERR)

@cocotb.test()
async def core_mini_axi_exceptions_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  # ELF file -> [pc, mepc, mtval, mcause]
  expected_csrs = dict({
    'illegal_elf.elf': [0x160, 0x15c, 0x02007043, 2],
    'instr_align_0_elf.elf': [0x160, 0x160, 0, 0],
    'instr_align_1_elf.elf': [0x15c, 0x15c, 0, 0],
    'instr_align_2_elf.elf': [0x15c, 0x15c, 0, 0],
    'instr_fault_elf.elf': [0x40000000, 0x40000010, 0, 1],
    'load_fault_0_elf.elf': [0x40000000, 0x40000010, 0, 1],
    'load_fault_1_elf.elf': [0x16c, 0x160, 0xA0000000, 5],
    'mret_fault_elf.elf': [0x310, 0x326, 0, 0],
    'store_fault_1_elf.elf': [0x138, 0x168, 0xA0000000, 7],
  })
  exceptions_elfs = glob.glob("../tests/cocotb/exceptions/*.elf")
  for elf in tqdm.tqdm(exceptions_elfs):
    with open(elf, "rb") as f:
      await core_mini_axi.reset()
      entry_point = await core_mini_axi.load_elf(f)
      await core_mini_axi.execute_from(entry_point)
      await core_mini_axi.wait_for_halted()
      assert core_mini_axi.dut.io_fault.value == 1
      pc = await core_mini_axi.read_word(0x30100)
      mepc = await core_mini_axi.read_word(0x30104)
      mtval = await core_mini_axi.read_word(0x30108)
      mcause = await core_mini_axi.read_word(0x3010c)
      expected = expected_csrs.get(os.path.basename(elf))
      if expected != None:
        assert pc.view(np.uint32)[0] == expected[0]
        assert mepc.view(np.uint32)[0] == expected[1]
        assert mtval.view(np.uint32)[0] == expected[2]
        assert mcause.view(np.uint32)[0] == expected[3]

      assert (pc != 0).any()
      assert (mepc != 0).any()

@cocotb.test()
async def core_mini_axi_kelvin_isa_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  kelvin_isa_elfs = glob.glob("../tests/cocotb/kelvin_isa/*.elf")
  for elf in tqdm.tqdm(kelvin_isa_elfs):
    with open(elf, "rb") as f:
      await core_mini_axi.reset()
      entry_point = await core_mini_axi.load_elf(f)
      await core_mini_axi.execute_from(entry_point)
      await core_mini_axi.wait_for_halted()
      assert core_mini_axi.dut.io_fault.value == 0

@cocotb.test()
async def core_mini_axi_rand_instr_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  cocotb.start_soon(core_mini_axi.clock.start())

  for _ in tqdm.tqdm(range(1000)):
    instr = np.random.randint(0, 2**32, 1, dtype=np.uint32)
    mpause = np.array([0x8000073], dtype=np.uint32)
    wdata = np.concatenate([instr, mpause, mpause, mpause])
    await core_mini_axi.reset()
    await core_mini_axi.write(0, wdata)
    await core_mini_axi.execute_from(0)
    try:
      await core_mini_axi.wait_for_halted()
    except:
      await core_mini_axi.halt()

@cocotb.test()
async def core_mini_axi_burst_types_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.init()
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())

  # AxiBurst.FIXED
  for _ in tqdm.trange(1000):
    beats = random.randint(2, 255)
    wdata = np.random.randint(0, 255, 16 * beats, dtype=np.uint8)
    await core_mini_axi.write(0, wdata, burst=AxiBurst.FIXED)
    rdata = await core_mini_axi.read(0, 16, burst=AxiBurst.FIXED)
    assert (wdata[((beats - 1) * 16):(beats * 16)] == rdata).all()

  # AxiBurst.INCR
  for _ in tqdm.trange(1000):
    beats = random.randint(2, 255)
    wdata = np.random.randint(0, 255, 16 * beats, dtype=np.uint8)
    await core_mini_axi.write(0, wdata, burst=AxiBurst.INCR)
    rdata = await core_mini_axi.read(0, beats * 16, burst=AxiBurst.INCR)
    assert (wdata == rdata).all()

  # AxiBurst.WRAP
  for _ in tqdm.trange(1000):
    beats = random.randint(2, 255)
    wdata = np.random.randint(0, 255, 16 * beats, dtype=np.uint8)
    write_offset = random.randint(1, 15)
    read_offset = random.randint(1, 15)
    await core_mini_axi.write(write_offset, wdata, burst=AxiBurst.WRAP)
    rdata = await core_mini_axi.read(read_offset, 16, burst=AxiBurst.WRAP)
    expected = np.concatenate([wdata[-write_offset:], wdata[-16:-write_offset]])
    assert (expected == np.roll(rdata, read_offset)).all()
