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
        await ClockCycles(self.clk, 2)
        await self.stop_clock()

        # Provide a hold time for CSb after the clock stops
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)
        await ClockCycles(self.main_clk, 2) # Small delay between transactions
        return byte_in

    async def write_reg(self, reg_addr, data, wait_cycles=10):
        """Writes a byte to a register via SPI."""
        write_cmd = (1 << 7) | reg_addr
        await self.spi_transaction(write_cmd)
        await self.spi_transaction(data)
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

    async def bulk_read_data(self, reg_addr, num_bytes):
        """Reads a block of data from a pipelined port."""
        read_cmd = reg_addr

        # The read pipeline is two stages deep. We need to send two commands
        # to discard two junk bytes before the first valid data byte is received.
        for _ in range(2):
            await self.spi_transaction(read_cmd)
            await ClockCycles(self.main_clk, 10)
            await self.idle_clocking(5)
            await ClockCycles(self.main_clk, 10)

        # Read the valid bytes.
        received_bytes = []
        for _ in range(num_bytes):
            read_byte = await self.spi_transaction(read_cmd)
            received_bytes.append(read_byte)
            await ClockCycles(self.main_clk, 5)

        # Assemble the received bytes into a single large integer
        read_data = 0
        for i, byte in enumerate(received_bytes):
            read_data |= (byte << (i * 8))

        return read_data

    async def bulk_write_data(self, reg_addr, data, num_bytes):
        """Writes a block of data to a port."""
        for i in range(num_bytes):
            byte = (data >> (i * 8)) & 0xFF
            await self.write_reg(reg_addr, byte, wait_cycles=5)

    async def packed_write_transaction(self, target_addr, num_beats, data_generator):
        await self._set_cs(True)
        await ClockCycles(self.main_clk, 1)

        await self.start_clock()

        # Write addr
        await self._clock_byte(0x80)
        await self._clock_byte((target_addr >> 0) & 0xFF)
        await self._clock_byte(0x81)
        await self._clock_byte((target_addr >> 8) & 0xFF)
        await self._clock_byte(0x82)
        await self._clock_byte((target_addr >> 16) & 0xFF)
        await self._clock_byte(0x83)
        await self._clock_byte((target_addr >> 24) & 0xFF)

        # Write beats
        await self._clock_byte(0x84)
        await self._clock_byte(num_beats - 1)

        # Write data
        for j in range(num_beats):
            data = data_generator(j)
            for i in range(16):
                byte = (data >> (i * 8)) & 0xFF
                await self._clock_byte(0x87)
                await self._clock_byte(byte)

        await self._clock_byte(0x85)
        await self._clock_byte(0x02)

        await self.stop_clock()
        await ClockCycles(self.main_clk, 1)
        await self._set_cs(False)
