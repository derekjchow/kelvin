import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles, FallingEdge, NextTimeStep

class CoreMiniAxiInterface:
  def __init__(self, dut):
    self.dut = dut
    self.clock = Clock(dut.io_aclk, 10, units="us")
    #cocotb.start_soon(clock.start())

  async def toggle_clock(self, n=1):
    for _ in range(n):
      self.dut.io_aclk.value = 0
      await Timer(100, units="ns")
      self.dut.io_aclk.value = 1
      await Timer(100, units="ns")

  async def reset(self):
    # #await self.toggle_clock(5)
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(0)
    await Timer(500, units="ns")
    self.dut.io_aresetn.setimmediatevalue(1)
    await Timer(500, units="ns")


  async def writeAddr(self, addr, size):
    self.dut.io_axi_slave_write_addr_valid.value = 1
    self.dut.io_axi_slave_write_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_write_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_write_addr_bits_id.value     = 0
    self.dut.io_axi_slave_write_addr_bits_len.value    = 0
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

  async def writeDataWord(self, data):
    self.dut.io_axi_slave_write_data_valid.value = 1
    self.dut.io_axi_slave_write_data_bits_data.value = data
    self.dut.io_axi_slave_write_data_bits_last.value = 1 #
    self.dut.io_axi_slave_write_data_bits_strb.value = 1 # Just the LSB?
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
    write_addr_task = self.writeAddr(addr, 2) # Write one word
    write_data_task = self.writeDataWord(data)

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

  async def writeLine(self, addr, data):
    # Convert numpy to buff
    bdata = cocotb.binary.BinaryValue()
    bdata.buff = reversed(data.tobytes()) # TODO(derekjchow): Check endianness

    self.dut.io_axi_slave_write_resp_ready.value = 0
    write_addr_task = self.writeAddr(addr, 4) # Write 16 bytes
    write_data_task = self.writeDataLine(bdata, last=True)

    await write_addr_task
    await write_data_task

    await self.waitWriteResponse()
    self.dut.io_axi_slave_write_resp_ready.value = 0

  # TODO(derekjchow): Write bulk thing of memory

  # TODO(derekjchow): Read functions
  async def readAddr(self, addr, size):
    self.dut.io_axi_slave_read_addr_valid.value = 1
    self.dut.io_axi_slave_read_addr_bits_addr.value   = addr
    self.dut.io_axi_slave_read_addr_bits_prot.value   = 2
    self.dut.io_axi_slave_read_addr_bits_id.value     = 0
    self.dut.io_axi_slave_read_addr_bits_len.value    = 0
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

  async def read(self, addr):
     await self.readAddr(addr, 4) # Read 16 bytes
     return await self.readData()

@cocotb.test()
async def core_mini_axi_write_read_memory(dut):
    """Basic test to check if memory can be written and read back."""
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    await ClockCycles(dut.io_aclk, 10)

    await core_mini_axi.writeWord(0x0100, 0x42)

    wdata = np.arange(16, dtype=np.int8)
    await core_mini_axi.writeLine(0x0, wdata)
    rdata = await core_mini_axi.read(0x0)
    
    assert (wdata == rdata).all()

    # print("20 cycles")
    # await ClockCycles(dut.io_aclk, 40)
    # print("20 cycles done")
