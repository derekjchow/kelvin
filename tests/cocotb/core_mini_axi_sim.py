import cocotb
import itertools
import math
import numpy as np
import tqdm
import random

from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles
from elftools.elf.elffile import ELFFile

def format_line_from_word(word, addr):
  shift = addr % 16
  line = np.zeros([4], dtype=np.uint32)
  line[0] = word
  line = np.roll(line.view(np.uint8), shift)
  bdata = cocotb.binary.BinaryValue()
  bdata.buff = reversed(line.tobytes())
  return bdata

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
  bdata = cocotb.binary.BinaryValue()
  bdata.buff = reversed(data.tobytes())
  return bdata


class CoreMiniAxiInterface:
  def __init__(self, dut):
    self.dut = dut
    self.clock = Clock(dut.io_aclk, 10, units="us")
    self.memory_base_addr = 0x20000000
    self.memory = np.zeros([4 * 1024 * 1024], dtype=np.uint8)

  async def reset(self):
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(0)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")

  async def _write_addr(self, addr, size, burst_len=1):
    self.dut.io_axi_slave_write_addr_valid.value = 1
    self.dut.io_axi_slave_write_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_write_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_write_addr_bits_id.value     = 0
    self.dut.io_axi_slave_write_addr_bits_len.value    = burst_len - 1
    self.dut.io_axi_slave_write_addr_bits_size.value   = size
    self.dut.io_axi_slave_write_addr_bits_burst.value  = 1
    self.dut.io_axi_slave_write_addr_bits_lock.value   = 0
    self.dut.io_axi_slave_write_addr_bits_cache.value  = 0
    self.dut.io_axi_slave_write_addr_bits_qos.value    = 0
    self.dut.io_axi_slave_write_addr_bits_region.value = 0

    while self.dut.io_axi_slave_write_addr_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)

    self.dut.io_axi_slave_write_addr_valid.value = 0

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

    self.dut.io_axi_slave_write_data_valid.value = 1
    self.dut.io_axi_slave_write_data_bits_data.value = convert_to_binary_value(
        data)
    self.dut.io_axi_slave_write_data_bits_strb.value = get_strb(mask)

    self.dut.io_axi_slave_write_data_bits_last.value = last
    while self.dut.io_axi_slave_write_data_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)

    self.dut.io_axi_slave_write_data_valid.value = 0

  def _determine_transaction_size(self, addr: int, data_len: int) -> int:
    # Transactions cannot cross 4k boundary
    offset4096 = addr % 4096
    remainder4096 = 4096 - offset4096

    # Max transaction size is 16 beats * 16 bytes, but cannot cross 4kB boundary
    max_transaction_size_bytes = min(256, remainder4096)

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
                               delay_bready: int = 0) -> None:
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
    write_addr_task = self._write_addr(addr, write_addr_size, beats)
    write_data_task = self._write_data(addr, data, masks, beats)

    await write_addr_task
    await write_data_task

    await self._wait_write_response(delay_bready=delay_bready)

  async def write(self,
                  addr: int,
                  data: np.array,
                  delay_bready: int = 0,
                  masks: np.array = None) -> None:
    """Writes data into Kelvin memory."""
    data = data.view(np.uint8)
    if masks is None:
      masks = np.copy(np.ones_like(data, dtype=bool))
    while len(data) > 0:
      transaction_size = self._determine_transaction_size(addr, len(data))
      local_data = data[0:transaction_size]
      local_masks = masks[0:transaction_size]
      await self._write_transaction(addr, local_data, local_masks, delay_bready)
      addr += len(local_data)
      data = data[transaction_size:]
      masks = masks[transaction_size:]

  async def write_word(self, addr: int, data: int) -> None:
    await self.write(addr, np.array([data], dtype=np.uint32))

  async def _read_addr(self, addr, size, beats=1):
    self.dut.io_axi_slave_read_addr_valid.value = 1
    self.dut.io_axi_slave_read_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_read_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_read_addr_bits_id.value     = 0
    self.dut.io_axi_slave_read_addr_bits_len.value    = beats-1
    self.dut.io_axi_slave_read_addr_bits_size.value   = size
    self.dut.io_axi_slave_read_addr_bits_burst.value  = 1
    self.dut.io_axi_slave_read_addr_bits_lock.value   = 0
    self.dut.io_axi_slave_read_addr_bits_cache.value  = 0
    self.dut.io_axi_slave_read_addr_bits_qos.value    = 0
    self.dut.io_axi_slave_read_addr_bits_region.value = 0

    while self.dut.io_axi_slave_read_addr_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)

    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_read_addr_valid.value = 0

  async def _read_data(self):
    self.dut.io_axi_slave_read_data_ready.value = 1
    while self.dut.io_axi_slave_read_data_valid.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)

    data = np.frombuffer(
        self.dut.io_axi_slave_read_data_bits_data.value.buff,
        dtype=np.uint8)
    last = self.dut.io_axi_slave_read_data_bits_last.value
    assert self.dut.io_axi_slave_read_data_bits_resp == 0 # OKAY

    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_read_data_ready.value = 0

    return last, np.flip(data)

  async def _read_transaction(self, addr, bytes_to_read):
    # Compute number of beats
    start_addr = addr
    end_addr = addr + bytes_to_read - 1 # Last address written
    start_line = start_addr // 16
    end_line = end_addr // 16
    beats = (end_line - start_line) + 1

    await self._read_addr(start_line * 16, 4, beats)

    data = []
    bytes_remaining = bytes_to_read
    for beat in range(beats):
      base_addr = (addr // 16) * 16
      sub_addr = addr - base_addr
      (last, beat_data) = await self._read_data()

      beat_data = beat_data[sub_addr:]
      if len(beat_data) > bytes_remaining:
        beat_data = beat_data[0:bytes_remaining]

      data.append(beat_data)
      bytes_remaining = bytes_remaining - len(beat_data)
      addr = addr + len(beat_data)
      if beat == (beats - 1):
        assert last

    return np.concatenate(data)

  async def read(self, addr, bytes_to_read):
    """Reads data from Kelvin Memory."""
    data = []
    while bytes_to_read > 0:
      transaction_size = self._determine_transaction_size(addr, bytes_to_read)
      data.append(await self._read_transaction(addr, transaction_size))
      bytes_to_read -= transaction_size
      addr += transaction_size

    if len(data) == 0:
      return data
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
    masks = wdata["masks"]
    assert addr >= self.memory_base_addr
    assert addr < self.memory_base_addr + len(self.memory)
    line_start = (addr - self.memory_base_addr) & 0xFFFFFFF0
    flat_data = list(itertools.chain(*data))
    flat_masks = list(itertools.chain(*masks))
    for i in range(0,len(flat_data)):
      if flat_masks[i] == 1:
        self.memory[line_start + i] = flat_data[i]

  def read_memory(self, raddr):
    addr = int(raddr["addr"])
    size = (2 ** raddr["size"])
    assert addr >= self.memory_base_addr
    assert addr < self.memory_base_addr + len(self.memory)
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

  async def wait_for_master_axi_read(self, timeout_cycles=1000):
    assert(self.dut.io_axi_master_read_addr_ready.value == 0)
    self.dut.io_axi_master_read_addr_ready.value = 1
    while self.dut.io_axi_master_read_addr_valid.value != 1 or self.dut.io_axi_master_read_addr_ready.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_read_addr_ready.value = 0
    rv = {
        "addr": self.dut.io_axi_master_read_addr_bits_addr.value,
        "size": self.dut.io_axi_master_read_addr_bits_size.value,
        "len": self.dut.io_axi_master_read_addr_bits_len.value,
        "id": self.dut.io_axi_master_read_addr_bits_id.value,
    }
    await ClockCycles(self.dut.io_aclk, 1)
    return rv

  async def respond_to_read(self, addr, word, id, size, len):
    assert(self.dut.io_axi_master_read_data_valid.value == 0)
    for i in range(0, len+1):
      self.dut.io_axi_master_read_data_valid.value = 1
      self.dut.io_axi_master_read_data_bits_id.value = id
      self.dut.io_axi_master_read_data_bits_data.value = \
        format_line_from_word(word, addr)
      self.dut.io_axi_master_read_data_bits_resp.value = 0 # OKAY
      self.dut.io_axi_master_read_data_bits_last.value = 1 if i == len else 0
      while (self.dut.io_axi_master_read_data_ready.value != 1 or self.dut.io_axi_master_read_data_valid.value != 1):
        await ClockCycles(self.dut.io_aclk, 1)
      self.dut.io_axi_master_read_data_valid.value = 0
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_read_data_valid.value = 0
    await ClockCycles(self.dut.io_aclk, 1)

  async def receive_master_write(self, timeout_cycles=1000):
    assert(self.dut.io_axi_master_write_addr_ready.value == 0)
    self.dut.io_axi_master_write_addr_ready.value = 1
    while self.dut.io_axi_master_write_addr_valid.value != 1 or self.dut.io_axi_master_write_addr_ready.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_write_addr_ready.value = 0

    id = self.dut.io_axi_master_write_addr_bits_id.value
    addr = self.dut.io_axi_master_write_addr_bits_addr.value
    size = self.dut.io_axi_master_write_addr_bits_size.value
    length = self.dut.io_axi_master_write_addr_bits_len.value

    last = False
    data = []
    masks = []
    assert (self.dut.io_axi_master_write_data_ready.value == 0)
    self.dut.io_axi_master_write_data_ready.value = 1
    while not last:
      while self.dut.io_axi_master_write_data_valid.value != 1 or self.dut.io_axi_master_write_data_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)

      line = np.frombuffer(
          self.dut.io_axi_master_write_data_bits_data.value.buff,
          dtype=np.uint8)
      data.append(list(reversed(line)))
      masks.append(list(reversed(self.dut.io_axi_master_write_data_bits_strb.value)))
      last = self.dut.io_axi_master_write_data_bits_last.value
    self.dut.io_axi_master_write_data_ready.value = 0

    assert len(data) == length + 1
    assert len(masks) == length + 1

    # Send response
    self.dut.io_axi_master_write_resp_valid.value = 1
    self.dut.io_axi_master_write_resp_bits_id.value = id
    self.dut.io_axi_master_write_resp_bits_resp.value = 0 # Okay
    while self.dut.io_axi_master_write_resp_ready.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_write_resp_valid.value = 0
    await ClockCycles(self.dut.io_aclk, 1)

    return {
      'addr': addr,
      'size': size,
      'len': length,
      'data': data,
      'masks': masks,
    }

@cocotb.test()
async def core_mini_axi_basic_write_read_memory(dut):
    """Basic test to check if TCM memory can be written and read back."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    # Test reading/writing words
    await core_mini_axi.write_word(0x100, 0x42)
    await core_mini_axi.write_word(0x104, 0x43)
    rdata = (await core_mini_axi.read(0x100, 16)).view(np.uint32)
    assert (rdata[0:2] == np.array([0x42, 0x43])).all()

    # Three write/read data burst
    wdata = np.arange(48, dtype=np.uint8)
    await core_mini_axi.write(0x0, wdata)
    rdata = await core_mini_axi.read(0x0, 48)
    assert (wdata == rdata).all()

    # Unaligned read, taking two bursts
    rdata = await core_mini_axi.read(0x8, 16)
    assert (np.arange(8, 24, dtype=np.uint8) == rdata).all()

    # Unaligned write, taking two bursts
    wdata = np.arange(20, dtype=np.uint8)
    await core_mini_axi.write(0x204, wdata)
    rdata = await core_mini_axi.read(0x200, 32)
    assert (wdata == rdata[4:24]).all()


@cocotb.test()
async def core_mini_axi_run_wfi_in_all_slots(dut):
    """Tests the WFI instruction in each of the 4 issue slots."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    cocotb.start_soon(core_mini_axi.clock.start())

    for slot in range(0,4):
      with open(f"../tests/cocotb/wfi_slot_{slot}.elf", "rb") as f:
        await core_mini_axi.reset()
        await ClockCycles(dut.io_aclk, 10)
        entry_point = await core_mini_axi.load_elf(f)
        await core_mini_axi.execute_from(entry_point)

        await core_mini_axi.wait_for_wfi()
        await core_mini_axi.raise_irq()
        await core_mini_axi.wait_for_halted()

@cocotb.test()
async def core_mini_axi_slow_bready(dut):
  """Test that BVALID stays high until BREADY is presented"""
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())
  await ClockCycles(dut.io_aclk, 10)

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
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    # TODO(derekjchow): Write stress program to run on Kelvin

    # Range for a DTCM buffer we can read/write too.
    DTCM_START = 0x12000
    DTCM_END = 0x14000
    dtcm_model_buffer = np.zeros((DTCM_END - DTCM_START))

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

@cocotb.test()
async def core_mini_axi_master_write_alignment(dut):
  """Test data alignment during AXI master writes"""
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())
  await ClockCycles(dut.io_aclk, 10)

  with open("../tests/cocotb/align_test.elf", "rb") as f:
    entry_point = await core_mini_axi.load_elf(f)
    await core_mini_axi.execute_from(entry_point)

    async def master_read_worker(core_mini_axi):
      while core_mini_axi.dut.io_halted.value != 1:
        raddr = await core_mini_axi.wait_for_master_axi_read()
        size = (2 ** raddr["size"]) # AXI size is an exponent
        data_flat = core_mini_axi.read_memory(raddr)
        await core_mini_axi.respond_to_read(raddr["addr"], data_flat, raddr["id"], size, raddr["len"])

    async def master_write_worker(core_mini_axi):
      while core_mini_axi.dut.io_halted.value != 1:
        wdata = await core_mini_axi.receive_master_write()
        core_mini_axi.write_memory(wdata)

    workers = []
    workers.append(cocotb.start_soon(master_read_worker(core_mini_axi)))
    workers.append(cocotb.start_soon(master_write_worker(core_mini_axi)))

    await core_mini_axi.wait_for_halted(timeout_cycles=10000)
    assert core_mini_axi.dut.io_fault.value == 0

    for w in workers:
      w.cancel()
      await w.join()
    dut.io_axi_master_read_addr_ready.value = 0
    dut.io_axi_master_write_addr_ready.value = 0
    await ClockCycles(dut.io_aclk, 1)

@cocotb.test()
async def core_mini_axi_finish_txn_before_halt_test(dut):
  core_mini_axi = CoreMiniAxiInterface(dut)
  await core_mini_axi.reset()
  cocotb.start_soon(core_mini_axi.clock.start())
  await ClockCycles(dut.io_aclk, 10)

  async def master_read_worker(core_mini_axi):
    while core_mini_axi.dut.io_halted.value != 1:
      raddr = await core_mini_axi.wait_for_master_axi_read()
      size = (2 ** raddr["size"]) # AXI size is an exponent
      data_flat = core_mini_axi.read_memory(raddr)
      await core_mini_axi.respond_to_read(raddr["addr"], data_flat, raddr["id"], size, raddr["len"])

  async def master_write_worker(core_mini_axi):
    while core_mini_axi.dut.io_halted.value != 1:
      wdata = await core_mini_axi.receive_master_write()
      core_mini_axi.write_memory(wdata)

  with open("../tests/cocotb/finish_txn_before_halt.elf", "rb") as f:
    entry_point = await core_mini_axi.load_elf(f)
    await core_mini_axi.execute_from(entry_point)

    workers = []
    workers.append(cocotb.start_soon(master_read_worker(core_mini_axi)))
    workers.append(cocotb.start_soon(master_write_worker(core_mini_axi)))

    await core_mini_axi.wait_for_halted()

    for w in workers:
      w.cancel()
      await w.join()
    dut.io_axi_master_read_addr_ready.value = 0
    dut.io_axi_master_write_addr_ready.value = 0
    await ClockCycles(dut.io_aclk, 1)
