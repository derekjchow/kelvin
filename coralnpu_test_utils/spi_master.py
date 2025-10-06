# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge
from coralnpu_test_utils.spi_constants import SpiRegAddress, SpiCommand, TlStatus, CMD_WRITE


class SPIMaster:
    def __init__(self, clk, csb, mosi, miso, main_clk, log):
        self.clk = clk
        self.csb = csb
        self.mosi = mosi
        self.miso = miso
        self.main_clk = main_clk
        self.log = log
        self.spi_clk_driver = Clock(self.clk, 10)
        self.clock_task = None

        # Initialize signal values
        self.clk.value = 0
        self.csb.value = 1
        self.mosi.value = 0

    async def start_clock(self):
        if self.clock_task is None:
            self.clock_task = cocotb.start_soon(self.spi_clk_driver.start())

    async def stop_clock(self):
        if self.clock_task:
            self.clock_task.kill()
            self.clock_task = None
            self.clk.value = 0

    async def _set_cs(self, active):
        self.csb.value = not active

    async def _clock_byte(self, data_out):
        data_in = 0
        for i in range(8):
            self.mosi.value = (data_out >> (7-i)) & 1
            await FallingEdge(self.clk)
            data_in = (data_in << 1) | int(self.miso.value)
        return data_in

    async def idle_clocking(self, cycles):
        await self.start_clock()
        await ClockCycles(self.clk, cycles)
        await self.stop_clock()

    async def spi_transaction(self, byte_out):
        # Provide a setup time for CSb before the clock starts
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)

        await self.start_clock()
        byte_in = await self._clock_byte(byte_out)
        await self.stop_clock()

        # Provide a hold time for CSb after the clock stops
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)
        await ClockCycles(self.main_clk, 2) # Small delay between transactions
        return byte_in

    async def write_reg(self, reg_addr, data, wait_cycles=10):
        """Writes a byte to a register via SPI."""
        write_cmd = CMD_WRITE | reg_addr
        await self.spi_transaction(write_cmd)
        await self.spi_transaction(data)
        if wait_cycles > 0:
            await ClockCycles(self.main_clk, wait_cycles)

    async def write_reg_16b(self, base_addr, data, wait_cycles=10):
        """Writes a 16-bit value to a register pair via SPI."""
        await self.write_reg(base_addr, data & 0xFF, wait_cycles=0)
        await self.write_reg(base_addr + 1, (data >> 8) & 0xFF, wait_cycles=0)
        if wait_cycles > 0:
            await ClockCycles(self.main_clk, wait_cycles)

    async def read_reg(self, reg_addr):
        """Reads a byte from a register via SPI."""
        read_cmd = reg_addr # MSB is 0 for read
        await self.spi_transaction(read_cmd)
        await ClockCycles(self.main_clk, 10)
        await self.idle_clocking(5)
        await ClockCycles(self.main_clk, 10)
        read_data = await self.spi_transaction(0x00)
        return read_data

    async def read_spi_domain_reg(self, reg_addr):
        """Reads a byte from a register that lives in the SPI clock domain."""
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)
        await self.start_clock()
        await self._clock_byte(reg_addr)
        read_data = await self._clock_byte(0x00)
        await self.stop_clock()
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)
        await ClockCycles(self.main_clk, 1)
        return read_data

    async def read_spi_domain_reg_16b(self, base_addr):
        """Reads a 16-bit value from a register pair in the SPI clock domain."""
        val_l = await self.read_spi_domain_reg(base_addr)
        val_h = await self.read_spi_domain_reg(base_addr + 1)
        return (val_h << 8) | val_l

    async def poll_reg_for_value(self, reg_addr, expected_value, max_polls=20):
        """Polls a register until it reads an expected value."""
        read_cmd = reg_addr # MSB is 0 for read
        read_data = -1

        # The first transaction just kicks off the read pipeline. The data is junk.
        await self.spi_transaction(read_cmd)

        for i in range(max_polls):
            # Each subsequent transaction sends a new read command and receives the
            # result of the PREVIOUS command.
            read_data = await self.spi_transaction(read_cmd)
            if read_data == expected_value:
                self.log.info(f"Successfully polled 0x{reg_addr:x} and got 0x{expected_value:x} after {i+1} attempts.")
                return True
            await ClockCycles(self.main_clk, 5) # Wait before next poll

        self.log.error(f"Timed out after {max_polls} polls waiting for register 0x{reg_addr:x} to be 0x{expected_value:x}, got 0x{read_data:x}")
        return False

    async def packed_write_transaction(self, target_addr, data):
        """Writes a block of data using a packed SPI transaction.

        Args:
            target_addr: The starting address for the write.
            data: A list of 128-bit integers to write.
        """
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)

        await self.start_clock()

        # Write addr
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_ADDR_REG_0)
        await self._clock_byte((target_addr >> 0) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_ADDR_REG_1)
        await self._clock_byte((target_addr >> 8) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_ADDR_REG_2)
        await self._clock_byte((target_addr >> 16) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_ADDR_REG_3)
        await self._clock_byte((target_addr >> 24) & 0xFF)

        # Write beats
        num_beats = len(data)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_LEN_REG_L)
        await self._clock_byte((num_beats - 1) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_LEN_REG_H)
        await self._clock_byte(((num_beats - 1) >> 8) & 0xFF)

        # Write data using bulk transfer
        all_data_bytes = []
        for beat in data:
            for i in range(16):
                all_data_bytes.append((beat >> (i * 8)) & 0xFF)

        # Command for bulk write
        num_bytes = len(all_data_bytes)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_WRITE_PORT_L)
        await self._clock_byte((num_bytes - 1) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_WRITE_PORT_H)
        await self._clock_byte(((num_bytes - 1) >> 8) & 0xFF)
        # Data stream
        for byte in all_data_bytes:
            await self._clock_byte(byte)

        await self._clock_byte(CMD_WRITE | SpiRegAddress.TL_CMD_REG)
        await self._clock_byte(SpiCommand.CMD_WRITE_START)

        await self.stop_clock()
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)

    async def bulk_write(self, data: list[int]):
        """Writes a block of data using a single bulk SPI transaction."""
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)

        await self.start_clock()

        # Command and Length for bulk write (L, H)
        num_bytes = len(data)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_WRITE_PORT_L)
        await self._clock_byte((num_bytes - 1) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_WRITE_PORT_H)
        await self._clock_byte(((num_bytes - 1) >> 8) & 0xFF)

        # Data stream
        for byte in data:
            await self._clock_byte(byte)

        await self.stop_clock()
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)

    async def bulk_read(self, num_bytes: int) -> list[int]:
        """Reads a block of data using a single bulk SPI transaction."""
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)

        await self.start_clock()

        # Command and Length to initiate a bulk read (L, H)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_READ_PORT_L)
        await self._clock_byte((num_bytes - 1) & 0xFF)
        await self._clock_byte(CMD_WRITE | SpiRegAddress.BULK_READ_PORT_H)
        await self._clock_byte(((num_bytes - 1) >> 8) & 0xFF)

        # The MISO pipeline has latency. The first dummy transfer flushes a junk byte.
        await self._clock_byte(0x00)

        # The subsequent transfers clock in the actual data.
        received_bytes = []
        for _ in range(num_bytes):
            byte_in = await self._clock_byte(0x00)
            received_bytes.append(byte_in)

        await self.stop_clock()
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)

        return received_bytes
