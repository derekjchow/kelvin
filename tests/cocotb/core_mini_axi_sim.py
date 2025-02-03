import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles, FallingEdge, NextTimeStep

def format_line_from_word(word, addr):
  shift = addr % 16
  line = np.zeros([4], dtype=np.uint32)
  line[0] = word
  line = np.roll(line.view(np.uint8), shift)
  bdata = cocotb.binary.BinaryValue()
  bdata.buff = reversed(line.tobytes())
  return bdata

class CoreMiniAxiInterface:
  def __init__(self, dut):
    self.dut = dut
    self.clock = Clock(dut.io_aclk, 10, units="us")

  async def reset(self):
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(0)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")

  async def _writeAddr(self, addr, size):
    self.dut.io_axi_slave_write_addr_valid.value = 1
    self.dut.io_axi_slave_write_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_write_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_write_addr_bits_id.value     = 0
    self.dut.io_axi_slave_write_addr_bits_len.value    = 0 # 0+1 beats
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

  async def writeDataWord(self, data, shift):
    self.dut.io_axi_slave_write_data_valid.value = 1
    self.dut.io_axi_slave_write_data_bits_data.value = data
    self.dut.io_axi_slave_write_data_bits_strb.value = 0xF << shift # Just the LSB?
    self.dut.io_axi_slave_write_data_bits_last.value = 1 #
    while self.dut.io_axi_slave_write_data_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)

    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_write_data_valid.value = 0

  async def waitWriteResponse(self):
    self.dut.io_axi_slave_write_resp_ready.value = 1
    while self.dut.io_axi_slave_write_resp_valid.value != 1:
       await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_write_resp_ready.value = 0

  async def writeWord(self, addr, data):
    self.dut.io_axi_slave_write_resp_ready.value = 0
    write_addr_task = self._writeAddr(addr, 2) # Write one word (2^2 = 4 bytes)

    shift = addr % 16
    line = np.zeros([4], dtype=np.uint32)
    line[0] = data
    line = np.roll(line.view(np.uint8), shift)
    bdata = cocotb.binary.BinaryValue()
    bdata.buff = reversed(line.tobytes())
    write_data_task = self.writeDataWord(bdata, shift)

    await write_addr_task
    await write_data_task

    await self.waitWriteResponse()

  async def writeDataLine(self, data, last):
     # TODO(derekjchow): For the time being, we assume a full 128 bit line is
     # being written to an aligned address. Relax this.
    self.dut.io_axi_slave_write_data_valid.value = 1
    self.dut.io_axi_slave_write_data_bits_data.value = data
    self.dut.io_axi_slave_write_data_bits_last.value = last
    self.dut.io_axi_slave_write_data_bits_strb.value = 0xFFFF # 16 bytes all 1's
    while self.dut.io_axi_slave_write_data_ready.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)

    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_slave_write_data_valid.value = 0

  async def _writeLine(self, addr, data):
    # Convert numpy to buff
    bdata = cocotb.binary.BinaryValue()
    bdata.buff = reversed(data.tobytes()) # TODO(derekjchow): Check endianness

    self.dut.io_axi_slave_write_resp_ready.value = 0
    write_addr_task = self._writeAddr(addr, 4) # Write 2^4=16 bytes
    write_data_task = self.writeDataLine(bdata, last=True)

    await write_addr_task
    await write_data_task

    await self.waitWriteResponse()
    self.dut.io_axi_slave_write_resp_ready.value = 0

  async def write(self, addr, data):
    # TODO(derekjchow): "reinterpret_cast" into uint8_t
    # Pad data to multiples of 16 or set write masks
    padding = 16 - (len(data) % 16)
    data = np.pad(data, (0, padding))
    # TODO(derekjchow): Unaligned writes / partial writes
    n_bytes = len(data)
    idx = 0
    while idx < n_bytes:
       line = data[idx:idx+16]
       await self._writeLine(addr + idx, line)
       idx += 16

  # TODO(derekjchow): Read functions
  async def readAddr(self, addr, size):
    self.dut.io_axi_slave_read_addr_valid.value = 1
    self.dut.io_axi_slave_read_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_read_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_read_addr_bits_id.value     = 0
    self.dut.io_axi_slave_read_addr_bits_len.value    = 0 # 0+1 beats
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

  async def readData(self):
    self.dut.io_axi_slave_read_data_ready.value = 1
    last = False

    data = []
    while not last:
        while self.dut.io_axi_slave_read_data_valid.value != 1:
            await ClockCycles(self.dut.io_aclk, 1)

        data.append(np.frombuffer(
            self.dut.io_axi_slave_read_data_bits_data.value.buff,
            dtype=np.int8))
        last = self.dut.io_axi_slave_read_data_bits_last        
        # TODO(derekjchow): Exception on error?
        # TODO(derekjchow): Mask?
        await ClockCycles(self.dut.io_aclk, 1)

    self.dut.io_axi_slave_read_data_ready.value = 0
    return np.array(list(reversed(data[0]))) # TODO(derekjchow): Check endianness

  async def read_line(self, addr):
    await self.readAddr(addr, 4) # Read 16 bytes
    return await self.readData()

  async def read(self, addr, size):
    assert(size % 16 == 0), "Reads muliple of 16 only supported for now"
    assert(addr % 16 == 0), "Reads aligned to 16 only supported for now"
    # TODO(derekjchow): Handle unaligned and burst
    idx = 0
    data = None
    while idx < size:
      line = await self.read_line(addr + idx)
      if data is None:
        data = line
      else:
        data = np.concatenate([data, line])
      idx += 16
    return data

  async def execute_from(self, start_pc):
    # Program starting address
    kelvin_pc_csr_addr = 0x30004
    await self.writeWord(kelvin_pc_csr_addr, start_pc)

    # Release clock gate
    kelvin_reset_csr_addr = 0x30000
    await self.writeWord(kelvin_reset_csr_addr, 1)

    # Release reset
    await self.writeWord(kelvin_reset_csr_addr, 0)

  async def wait_for_wfi(self):
    while self.dut.io_wfi.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)

  async def wait_for_master_axi_read(self):
    self.dut.io_axi_master_read_addr_ready.value = 1
    while self.dut.io_axi_master_read_addr_valid.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)
    return {
        "addr": self.dut.io_axi_master_read_addr_bits_addr.value,
        "size": self.dut.io_axi_master_read_addr_bits_size.value,
        "len": self.dut.io_axi_master_read_addr_bits_len.value,
        "id": self.dut.io_axi_master_read_addr_bits_id.value,
    }

  async def respond_to_read_word(self, addr, word, id):
    self.dut.io_axi_master_read_data_valid.value = 1
    self.dut.io_axi_master_read_data_bits_id.value = id
    self.dut.io_axi_master_read_data_bits_data.value = \
        format_line_from_word(word, addr)
    self.dut.io_axi_master_read_data_bits_resp.value = 0 # OKAY
    self.dut.io_axi_master_read_data_bits_last.value = 1

    while self.dut.io_axi_master_read_addr_ready.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)

    self.dut.io_axi_master_read_data_valid.value = 0

  async def receive_master_write(self):
    self.dut.io_axi_master_write_addr_ready.value = 1
    while self.dut.io_axi_master_write_addr_valid.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    id = self.dut.io_axi_master_write_addr_bits_id.value
    addr = self.dut.io_axi_master_write_addr_bits_addr.value
    size = self.dut.io_axi_master_write_addr_bits_size.value
    length = self.dut.io_axi_master_write_addr_bits_len.value
    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_write_addr_ready.value = 0

    last = False
    data = []
    masks = []
    self.dut.io_axi_master_write_data_ready.value = 1
    while not last:
      while self.dut.io_axi_master_write_data_valid.value != 1:
        await ClockCycles(self.dut.io_aclk, 1)

      line = np.frombuffer(
          self.dut.io_axi_master_write_data_bits_data.value.buff,
          dtype=np.int8)
      data.append(list(reversed(line)))
      masks.append(self.dut.io_axi_master_write_data_bits_strb.value)
      last = self.dut.io_axi_slave_read_data_bits_last        
      # TODO(derekjchow): Exception on error?
      # TODO(derekjchow): Mask?
      await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_write_data_ready.value = 0

    assert len(data) == length + 1
    assert len(masks) == length + 1

    # Send response
    self.dut.io_axi_master_write_resp_valid.value = 1
    self.dut.io_axi_master_write_resp_bits_id.value = id
    self.dut.io_axi_master_write_resp_bits_resp.value = 0 # Okay
    while self.dut.io_axi_master_write_resp_ready.value != 1:
      await ClockCycles(self.dut.io_aclk, 1)
    await ClockCycles(self.dut.io_aclk, 1)
    self.dut.io_axi_master_write_resp_valid.value = 0

    return {
      'addr': addr,
      'size': size,
      'len': length,
      'data': data,
      'masks': masks,
    }


@cocotb.test()
async def core_mini_axi_write_read_memory(dut):
    """Basic test to check if TCM memory can be written and read back."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    await core_mini_axi.writeWord(0x100, 0x42)
    await core_mini_axi.writeWord(0x104, 0x43)
    rdata = await core_mini_axi.read_line(0x100)

    wdata = np.arange(16, dtype=np.int8)
    await core_mini_axi.write(0x0, wdata)
    rdata = await core_mini_axi.read_line(0x0)

    assert (wdata == rdata).all()


@cocotb.test()
async def core_mini_axi_run_binary_example_add(dut):
    """Basic test to start up a binary."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    program_binary = np.fromfile(
        "/home/derekjchow/code/kelvin/tests/cocotb/example_add.bin",
        dtype=np.uint8)
    await core_mini_axi.write(0x0, program_binary)

    # Program inputs
    inputs1 = np.arange(8, dtype=np.int32)
    inputs2 = np.ones([8], dtype=np.int32)
    await core_mini_axi.write(0x00010000, inputs1.view(np.uint8))
    await core_mini_axi.write(0x00010100, inputs2.view(np.uint8))

    await core_mini_axi.execute_from(0xdc)
    await core_mini_axi.wait_for_wfi()

    result = (await core_mini_axi.read(0x00010200, 32)).view(np.int32)
    assert (result == (inputs1 + inputs2)).all()


@cocotb.test()
async def core_mini_axi_run_binary_example_read(dut):
    """Basic test to check reads from Kelvin over AXI."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    program_binary = np.fromfile(
        "/home/derekjchow/code/kelvin/tests/cocotb/example_external_read.bin",
        dtype=np.uint8)
    await core_mini_axi.write(0x0, program_binary)
    await core_mini_axi.execute_from(0xac)
    
    for i in range(0, 4):
      master_read = await core_mini_axi.wait_for_master_axi_read()
      await core_mini_axi.respond_to_read_word(
          master_read['addr'], 42+i, master_read['id'])

    await core_mini_axi.wait_for_wfi()

    result = (await core_mini_axi.read(0x00010000, 16)).view(np.int32)
    assert (result == (42+np.arange(4, dtype=np.int32))).all()


@cocotb.test()
async def core_mini_axi_run_binary_example_write(dut):
    """Basic test to check writes from Kelvin over AXI."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    program_binary = np.fromfile(
        "/home/derekjchow/code/kelvin/tests/cocotb/example_external_write.bin",
        dtype=np.uint8)
    await core_mini_axi.write(0x0, program_binary)
    await core_mini_axi.execute_from(0x94)
    
    for i in range(0, 4):
      master_write = await core_mini_axi.receive_master_write()
      assert len(master_write["data"]) == 1
      assert len(master_write["masks"]) == 1
      assert master_write["size"] == 2
      assert master_write["addr"] == 0x00040000 + (4*i)
      word = np.array(master_write["data"][0][4*i:(4*i)+4], dtype=np.uint8)
      word = word.view(np.uint32)
      assert word == 7000 + i

    await core_mini_axi.wait_for_wfi()

