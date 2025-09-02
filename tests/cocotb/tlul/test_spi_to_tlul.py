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
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, FallingEdge
from kelvin_test_utils.TileLinkULInterface import TileLinkULInterface
from kelvin_test_utils.spi_master import SPIMaster

async def setup_dut(dut):
    # Main clock started by the test
    dut.io_spi_csb.value = 1  # Start with chip select inactive
    dut.reset.value = 1
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await RisingEdge(dut.clock)

@cocotb.test()
async def test_register_read_write(dut):
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    await setup_dut(dut)
    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )

    # Write Transaction
    write_data = random.randint(0, 255)
    await spi_master.write_reg(0x04, write_data)

    # Read Transaction
    read_data = await spi_master.read_reg(0x04)
    assert read_data == write_data, f"Read data 0x{read_data:x} does not match written data 0x{write_data:x}"

    await ClockCycles(dut.clock, 20)

@cocotb.test()
async def test_tlul_read(dut):
    """Tests back-to-back TileLink UL read transactions initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    await setup_dut(dut)
    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    # --- Device Responder Task ---
    async def device_responder():
        for i in range(3):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) == 4, f"Expected Get opcode (4), got {req['opcode']}"

            # Formulate a unique response for each transaction
            response_data = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i

            await tl_device.device_respond(
                opcode=1,  # AccessAckData
                param=0,
                size=req['size'],
                source=req['source'],
                data=response_data,
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    for i in range(3):
        # 1. Configure the TileLink read via SPI
        target_addr = 0x40001000 + (i * 16) # Use a new address for each transaction
        # Write address (32 bits) byte by byte
        for j in range(4):
            addr_byte = (target_addr >> (j * 8)) & 0xFF
            await spi_master.write_reg(0x00 + j, addr_byte)

        # Write length (0 means 1 beat)
        await spi_master.write_reg(0x04, 0x00)

        # 2. Issue the read command
        await spi_master.write_reg(0x05, 0x01, wait_cycles=0)

        # --- Verification ---
        # 1. Poll the status register until the transaction is done
        assert await spi_master.poll_reg_for_value(0x06, 0x02), "Timed out waiting for status to be Done"

        # 2. Read the data from the buffer port
        read_data = await spi_master.bulk_read_data(0x07, 16)

        # 3. Compare with expected data
        expected_data = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i
        assert read_data == expected_data

        # 4. Clear the status to return FSM to Idle
        await spi_master.write_reg(0x05, 0x00)

    await responder_task

@cocotb.test()
async def test_tlul_multi_beat_read(dut):
    """Tests a multi-beat TileLink UL read transaction initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    await setup_dut(dut)
    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 4

    # --- Device Responder Task ---
    async def device_responder():
        for i in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) == 4, f"Expected Get opcode (4), got {req['opcode']}"

            # Formulate a unique response for each transaction
            response_data = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i

            await tl_device.device_respond(
                opcode=1,  # AccessAckData
                param=0,
                size=req['size'],
                source=req['source'],
                data=response_data,
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # 1. Configure the TileLink read via SPI
    target_addr = 0x40001000
    # Write address (32 bits) byte by byte
    for j in range(4):
        addr_byte = (target_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(0x00 + j, addr_byte)

    # Write length (N-1 for N beats)
    await spi_master.write_reg(0x04, num_beats - 1)

    # 2. Issue the read command
    await spi_master.write_reg(0x05, 0x01, wait_cycles=0)

    # Add a delay to allow the status to propagate across the CDC
    await ClockCycles(dut.clock, 20)

    # --- Verification ---
    # 1. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(0x06, 0x02), "Timed out waiting for status to be Done"

    # 2. Read the data from the buffer port
    bytes_to_read = num_beats * 16
    read_data = await spi_master.bulk_read_data(0x07, bytes_to_read)

    # 3. Compare with expected data
    expected_data = 0
    for i in range(num_beats):
        word = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i
        expected_data |= (word << (i * 128))

    assert read_data == expected_data

    # 4. Clear the status to return FSM to Idle
    await spi_master.write_reg(0x05, 0x00)

    await responder_task

@cocotb.test()
async def test_tlul_write(dut):
    """Tests back-to-back TileLink UL write transactions initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    await setup_dut(dut)
    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    # --- Device Responder Task ---
    # This task will receive the write requests and send acknowledgments.
    received_data_list = []
    async def device_responder():
        for _ in range(3):
            req = await tl_device.device_get_request()

            # For a 'Put' request, we expect opcode 0 (PutFull) or 1 (PutPartial)
            assert int(req['opcode']) in [0, 1], f"Expected PutFullData or PutPartialData, got opcode {req['opcode']}"

            # Capture the data for verification
            received_data_list.append(int(req['data']))

            # A 'Put' operation is acknowledged with a single 'AccessAck'
            await tl_device.device_respond(
                opcode=0,  # AccessAck
                param=0,
                size=req['size'],
                source=req['source'],
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    expected_data_list = []
    for i in range(3):
        # 1. Write data to the DUT's internal buffer
        write_data = 0x11223344_55667788_99AABBCC_DDEEFF00 + i
        expected_data_list.append(write_data)
        await spi_master.bulk_write_data(0x07, write_data, 16)

        # 2. Configure the TileLink write via SPI
        target_addr = 0x40002000 + (i * 16)
        # Write address (32 bits) byte by byte
        for j in range(4):
            addr_byte = (target_addr >> (j * 8)) & 0xFF
            await spi_master.write_reg(0x00 + j, addr_byte)

        # Write length (0 means 1 beat)
        await spi_master.write_reg(0x04, 0x00)

        # 3. Issue the write command
        await spi_master.write_reg(0x05, 0x02, wait_cycles=20) # Start write command

        # --- Verification ---
        # 1. Poll the status register until the transaction is done
        assert await spi_master.poll_reg_for_value(0x08, 0x02), "Timed out waiting for write status to be Done"

        # 4. Clear the status to return FSM to Idle
        await spi_master.write_reg(0x05, 0x00)

    # Wait for the responder to finish handling all requests
    await responder_task

    # Verify all data received by the responder
    assert len(received_data_list) == 3, f"Responder received {len(received_data_list)} transactions, expected 3"
    assert received_data_list == expected_data_list, f"Received data {received_data_list} does not match expected data {expected_data_list}"

@cocotb.test()
async def test_tlul_multi_beat_write(dut):
    """Tests a multi-beat TileLink UL write transaction initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    await setup_dut(dut)
    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 4

    # --- Device Responder Task ---
    received_data_list = []
    async def device_responder():
        # For a multi-beat write, we expect num_beats requests, with an ack after each.
        for i in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) in [0, 1], f"Expected PutFullData or PutPartialData, got opcode {req['opcode']}"
            received_data_list.append(int(req['data']))

            # Send an AccessAck after each beat
            await tl_device.device_respond(
                opcode=0,  # AccessAck
                param=0,
                size=req['size'],
                source=req['source'],
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # 1. Prepare and write data to the DUT's internal buffer
    expected_data_list = []
    full_write_data = 0
    for i in range(num_beats):
        word = 0x11223344_55667788_99AABBCC_DDEEFF00 + i
        expected_data_list.append(word)
        full_write_data |= (word << (i * 128))

    bytes_to_write = num_beats * 16
    await spi_master.bulk_write_data(0x07, full_write_data, bytes_to_write)

    # 2. Configure the TileLink write via SPI
    target_addr = 0x40002000
    # Write address (32 bits) byte by byte
    for j in range(4):
        addr_byte = (target_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(0x00 + j, addr_byte)

    # Write length (N-1 for N beats)
    await spi_master.write_reg(0x04, num_beats - 1)

    # 3. Issue the write command
    await spi_master.write_reg(0x05, 0x02, wait_cycles=20) # Start write command

    # --- Verification ---
    # 1. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(0x08, 0x02), "Timed out waiting for write status to be Done"

    # 2. Wait for the responder to finish
    await responder_task

    # 3. Verify the data received by the responder
    assert len(received_data_list) == num_beats, f"Responder received {len(received_data_list)} beats, expected {num_beats}"
    assert received_data_list == expected_data_list, f"Received data {received_data_list} does not match expected data {expected_data_list}"

    # 4. Clear the status to return FSM to Idle
    await spi_master.write_reg(0x05, 0x00)