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
import os
import math
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, FallingEdge
from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface
from coralnpu_test_utils.spi_master import SPIMaster
from coralnpu_test_utils.spi_constants import SpiRegAddress, SpiCommand, TlStatus

async def setup_dut(dut, spi_master):
    # Main clock started by the test
    dut.io_spi_csb.value = 1  # Start with chip select inactive
    dut.reset.value = 1
    await spi_master.start_clock()
    await ClockCycles(dut.clock, 5) # Ensure reset assertion is sampled
    dut.reset.value = 0
    await ClockCycles(dut.clock, 5) # Ensure reset de-assertion is sampled
    await spi_master.stop_clock()
    await RisingEdge(dut.clock)

@cocotb.test()
async def test_register_read_write(dut):
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)

    # Write Transaction
    write_data = random.randint(0, 255)
    await spi_master.write_reg(SpiRegAddress.TL_LEN_REG_L, write_data)

    # Read Transaction
    read_data = await spi_master.read_reg(SpiRegAddress.TL_LEN_REG_L)
    assert read_data == write_data, f"Read data 0x{read_data:x} does not match written data 0x{write_data:x}"

    await ClockCycles(dut.clock, 20)

@cocotb.test()
async def test_tlul_read(dut):
    """Tests back-to-back TileLink UL read transactions initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
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
            await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

        # Write length (0 means 1 beat)
        await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, 0)

        # 2. Issue the read command
        await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

        # --- Verification ---
        # 1. Poll the status register until the transaction is done
        assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE), "Timed out waiting for status to be Done"

        # 2. Check that the correct number of bytes are available
        bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
        assert bytes_available == 16

        # 3. Read the data from the buffer port using the new bulk read
        read_data_bytes = await spi_master.bulk_read(16)
        read_data = 0
        for j, byte in enumerate(read_data_bytes):
            read_data |= (byte << (j * 8))

        # 4. Compare with expected data
        expected_data = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i
        assert read_data == expected_data

        # 4. Clear the status to return FSM to Idle
        await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

    await responder_task

@cocotb.test()
async def test_tlul_multi_beat_read(dut):
    """Tests a multi-beat TileLink UL read transaction initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
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
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

    # Write length (N-1 for N beats)
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)

    # 2. Issue the read command
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

    # --- Verification ---
    # 1. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE), "Timed out waiting for status to be Done"

    # 2. Check that the correct number of bytes are available
    bytes_to_read = num_beats * 16
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    assert bytes_available == bytes_to_read

    # 3. Read the data from the buffer port using the new bulk read
    read_data_bytes = await spi_master.bulk_read(bytes_to_read)
    read_data = 0
    for i, byte in enumerate(read_data_bytes):
        read_data |= (byte << (i * 8))

    # 4. Compare with expected data
    expected_data = 0
    for i in range(num_beats):
        word = 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i
        expected_data |= (word << (i * 128))

    assert read_data == expected_data

    # 4. Clear the status to return FSM to Idle
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

    await responder_task

@cocotb.test()
async def test_tlul_write(dut):
    """Tests back-to-back TileLink UL write transactions initiated via SPI."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
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
        write_data_bytes = list(write_data.to_bytes(16, 'little'))
        await spi_master.bulk_write(write_data_bytes)

        # 2. Configure the TileLink write via SPI
        target_addr = 0x40002000 + (i * 16)
        # Write address (32 bits) byte by byte
        for j in range(4):
            addr_byte = (target_addr >> (j * 8)) & 0xFF
            await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

        # Write length (0 means 1 beat)
        await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, 0)

        # 3. Issue the write command
        await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_WRITE_START, wait_cycles=20) # Start write command

        # --- Verification ---
        # 1. Poll the status register until the transaction is done
        assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), "Timed out waiting for write status to be Done"

        # 4. Clear the status to return FSM to Idle
        await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

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

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
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
    write_data_bytes = []
    for i in range(num_beats):
        word = 0x11223344_55667788_99AABBCC_DDEEFF00 + i
        expected_data_list.append(word)
        write_data_bytes.extend(list(word.to_bytes(16, 'little')))

    await spi_master.bulk_write(write_data_bytes)

    # 2. Configure the TileLink write via SPI
    target_addr = 0x40002000
    # Write address (32 bits) byte by byte
    for j in range(4):
        addr_byte = (target_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

    # Write length (N-1 for N beats)
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)

    # 3. Issue the write command
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_WRITE_START, wait_cycles=20) # Start write command

    # --- Verification ---
    # 1. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), "Timed out waiting for write status to be Done"

    # 2. Wait for the responder to finish
    await responder_task

    # 3. Verify the data received by the responder
    assert len(received_data_list) == num_beats, f"Responder received {len(received_data_list)} beats, expected {num_beats}"
    assert received_data_list == expected_data_list, f"Received data {received_data_list} does not match expected data {expected_data_list}"

    # 4. Clear the status to return FSM to Idle
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

@cocotb.test()
async def test_packed_write_transaction(dut):
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 16
    async def device_responder():
        for i in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) in [0, 1], f"Expected PutFullData or PutPartialData, got opcode {req['opcode']}"
            assert req['data'] == 0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i

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

    data = [0xDEADBEEF_CAFEF00D_ABAD1DEA_C0DED00D + i for i in range(num_beats)]
    await spi_master.packed_write_transaction(
        target_addr=0x40001000,
        data=data,
    )

    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), "Timed out waiting for write status to be Done"
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    await responder_task


@cocotb.test()
async def test_tlul_bulk_write(dut):
    """Tests a TileLink UL write transaction initiated via the new bulk SPI write."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 2
    expected_data_list = []
    write_data_bytes = []

    for i in range(num_beats):
        word = 0xCAFEF00D_DEADBEEF_C0DED00D_ABAD1DEA + i
        expected_data_list.append(word)
        for j in range(16):
            write_data_bytes.append((word >> (j * 8)) & 0xFF)

    # --- Device Responder Task ---
    received_data_list = []
    async def device_responder():
        for _ in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) in [0, 1]
            received_data_list.append(int(req['data']))
            await tl_device.device_respond(
                opcode=0,
                param=0,
                size=req['size'],
                source=req['source'],
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # 1. Write data to the DUT's internal buffer using the new bulk write method
    await spi_master.bulk_write(write_data_bytes)

    # 2. Configure the TileLink write via SPI
    target_addr = 0x40003000
    for j in range(4):
        addr_byte = (target_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)

    # 3. Issue the write command
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_WRITE_START, wait_cycles=20)

    # --- Verification ---
    # 1. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), "Timed out waiting for write status to be Done"

    # 2. Wait for the responder to finish
    await responder_task

    # 3. Verify the data received by the responder
    assert len(received_data_list) == num_beats
    assert received_data_list == expected_data_list

    # 4. Clear the status to return FSM to Idle
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)


@cocotb.test()
async def test_tlul_bulk_read(dut):
    """Tests a TileLink UL read transaction initiated via SPI and read via the new bulk SPI read."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 2
    expected_data_list = []
    for i in range(num_beats):
        word = 0xABAD1DEA_C0DED00D_DEADBEEF_CAFEF00D + i
        expected_data_list.append(word)

    # --- Device Responder Task ---
    async def device_responder():
        for i in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) == 4, f"Expected Get opcode (4), got {req['opcode']}"
            await tl_device.device_respond(
                opcode=1,  # AccessAckData
                param=0,
                size=req['size'],
                source=req['source'],
                data=expected_data_list[i],
                error=0,
                width=128
            )

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # 1. Configure the TileLink read via SPI
    target_addr = 0x40001000
    for j in range(4):
        addr_byte = (target_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)

    # 2. Issue the read command
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

    # 3. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE), "Timed out waiting for status to be Done"

    # 3a. Read the bulk read status register
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    dut._log.info(f"BULK_READ_STATUS_REG = {bytes_available}")

    # 4. Initiate the bulk read from the data buffer
    num_bytes_to_read = num_beats * 16
    read_data_bytes = await spi_master.bulk_read(num_bytes_to_read)

    # --- Verification ---
    # 1. Convert the received bytes back into words
    read_data_list = []
    for i in range(num_beats):
        word = 0
        for j in range(16):
            word |= (read_data_bytes[i*16 + j] << (j * 8))
        read_data_list.append(word)

    # 2. Verify the data
    assert read_data_list == expected_data_list, f"{[hex(x) for x in read_data_list]} =/= {[hex(x) for x in expected_data_list]}"

    # 3. Clear the status to return FSM to Idle
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

    await responder_task

@cocotb.test(timeout_time=300, timeout_unit="sec")
async def test_large_tlul_transfer(dut):
    """Verify increasingly large transfers (up to 16KB) via Spi2TLUL."""
    # Start the main clock
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    # Test parameters
    base_addr = 0x20000000
    write_chunk_size = 256  # Max for bulk_write
    read_chunk_size = 128   # As requested
    bus_width_bytes = 128 // 8

    transfer_sizes = [1024 * x for x in [1, 2, 4, 8, 16]]

    for total_size in transfer_sizes:
        dut._log.info(f"--- Starting {total_size // 1024}KB Transfer Test ---")

        # Generate random data
        dut._log.info(f"Generating {total_size // 1024}KB of random data...")
        golden_data = os.urandom(total_size)
        dut._log.info("Data generation complete.")

        # --- Device Responder Task ---
        async def device_responder():
            mem = {}
            total_bytes_written = 0
            total_beats_to_write = total_size // bus_width_bytes

            # --- Write Phase ---
            dut._log.info(f"Device responder waiting for {total_size} bytes...")
            for _ in range(total_beats_to_write):
                req = await tl_device.device_get_request()
                assert int(req['opcode']) in [0, 1]

                addr = int(req['address'])
                data = int(req['data'])
                mask = int(req['mask'])

                for byte_idx in range(bus_width_bytes):
                    if (mask >> byte_idx) & 1:
                        byte_val = (data >> (byte_idx * 8)) & 0xFF
                        mem[addr + byte_idx] = byte_val

                await tl_device.device_respond(
                    opcode=0, param=0, size=req['size'], source=req['source'], error=0, width=128
                )
                total_bytes_written += bin(mask).count('1')
            dut._log.info(f"Device responder received {total_bytes_written} bytes.")

            # --- Read Phase ---
            dut._log.info(f"Device responder waiting for read requests...")
            total_bytes_read = 0
            while total_bytes_read < total_size:
                req = await tl_device.device_get_request()
                assert int(req['opcode']) == 4

                addr = int(req['address'])
                size = int(req['size'])
                num_bytes = 1 << size

                response_data = 0
                for i in range(num_bytes):
                    byte_val = mem.get(addr + i, 0)
                    response_data |= (byte_val << (i * 8))

                await tl_device.device_respond(
                    opcode=1, param=0, size=size, source=req['source'], data=response_data, error=0, width=128
                )
                total_bytes_read += num_bytes
            dut._log.info(f"Device responder sent {total_bytes_read} bytes.")

        responder_task = cocotb.start_soon(device_responder())

        # --- Main Test Logic: Write Phase ---
        dut._log.info(f"Starting {total_size // 1024}KB write phase...")
        for i in range(0, total_size, write_chunk_size):
            chunk = golden_data[i:i + write_chunk_size]
            num_beats = int(math.ceil(len(chunk) / bus_width_bytes))
            current_addr = base_addr + i

            await spi_master.bulk_write(list(chunk))

            for j in range(4):
                addr_byte = (current_addr >> (j * 8)) & 0xFF
                await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

            await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)
            await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_WRITE_START, wait_cycles=20)

            assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), f"Timed out waiting for write status at addr {current_addr:x}"
            await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
        dut._log.info("Write phase complete.")

        # --- Main Test Logic: Read Phase ---
        dut._log.info(f"Starting {total_size // 1024}KB read phase...")
        read_back_data = bytearray()
        for i in range(0, total_size, read_chunk_size):
            num_beats = int(math.ceil(read_chunk_size / bus_width_bytes))
            current_addr = base_addr + i

            for j in range(4):
                addr_byte = (current_addr >> (j * 8)) & 0xFF
                await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

            await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats - 1)
            await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

            assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE), f"Timed out waiting for read status at addr {current_addr:x}"

            bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
            assert bytes_available == read_chunk_size

            read_data_bytes = await spi_master.bulk_read(read_chunk_size)
            read_back_data.extend(read_data_bytes)

            await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
        dut._log.info("Read phase complete.")

        # --- Verification ---
        dut._log.info(f"Verifying {total_size // 1024}KB of data...")
        assert read_back_data == golden_data, "Read-back data does not match golden data"
        dut._log.info(f"Data verification successful for {total_size // 1024}KB!")

        await responder_task
        dut._log.info(f"--- {total_size // 1024}KB Transfer Test Passed ---")


@cocotb.test(timeout_time=300, timeout_unit="sec")
async def test_large_packed_write_transaction(dut):
    """Tests a single large (4KB) packed write transaction."""
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    num_beats = 256  # 256 beats * 16 bytes/beat = 4096 bytes
    dut._log.info(f"Generating {num_beats * 16 // 1024}KB of random data...")
    golden_data = [random.randint(0, (1 << 128) - 1) for _ in range(num_beats)]
    dut._log.info("Data generation complete.")

    async def device_responder():
        dut._log.info(f"Device responder waiting for {num_beats} beats...")
        for i in range(num_beats):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) in [0, 1], f"Expected PutFullData or PutPartialData, got opcode {req['opcode']}"
            assert req['data'] == golden_data[i], f"Data mismatch on beat {i}"

            # Send an AccessAck after each beat
            await tl_device.device_respond(
                opcode=0,  # AccessAck
                param=0,
                size=req['size'],
                source=req['source'],
                error=0,
                width=128
            )
        dut._log.info("Device responder received all beats successfully.")

    responder_task = cocotb.start_soon(device_responder())

    await spi_master.packed_write_transaction(
        target_addr=0x40001000,
        data=golden_data,
    )

    # Need large max_polls here for the large transfer size.
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for write status to be Done"
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    await responder_task
    dut._log.info("--- Large Packed Write Test Passed ---")


@cocotb.test(timeout_time=400, timeout_unit="sec")
async def test_large_pipelined_read(dut):
    """Tests two back-to-back large (2KB) read transactions."""
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    total_size = 4096
    read_chunk_size = 2048
    bus_width_bytes = 128 // 8
    num_beats_total = total_size // bus_width_bytes
    num_beats_per_read = read_chunk_size // bus_width_bytes
    base_addr = 0x20000000

    dut._log.info(f"Generating {total_size // 1024}KB of random data...")
    golden_data_words = [random.randint(0, (1 << 128) - 1) for _ in range(num_beats_total)]
    golden_data_bytes = bytearray()
    for word in golden_data_words:
        golden_data_bytes.extend(word.to_bytes(16, 'little'))
    dut._log.info("Data generation complete.")

    # --- Device Responder Task ---
    async def device_responder():
        mem = {}  # Byte-addressable memory
        # Pre-populate memory
        for i, byte_val in enumerate(golden_data_bytes):
            mem[base_addr + i] = byte_val

        # --- Read Phase: Serve data from memory for two separate reads ---
        dut._log.info(f"Device responder waiting for {num_beats_total} read beats...")
        for i in range(num_beats_total):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) == 4
            addr = int(req['address'])
            response_data = 0
            for byte_idx in range(bus_width_bytes):
                byte_val = mem.get(addr + byte_idx, 0)
                response_data |= (byte_val << (byte_idx * 8))
            await tl_device.device_respond(
                opcode=1, param=0, size=req['size'], source=req['source'], data=response_data, error=0, width=128
            )
        dut._log.info("Device responder read phase complete.")

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # Read Phase: Read the 4KB back in two 2KB chunks
    read_data_bytes = bytearray()

    # First 2KB read
    dut._log.info("Starting first 2KB read from device...")
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats_per_read - 1)
    for j in range(4):
        addr_byte = (base_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for first read status to be Done"
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    assert bytes_available == read_chunk_size, f"Expected {read_chunk_size} bytes available, but got {bytes_available}"
    read_data_bytes.extend(await spi_master.bulk_read(read_chunk_size))
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    dut._log.info("First 2KB read complete.")

    # Second 2KB read
    dut._log.info("Starting second 2KB read from device...")
    second_chunk_addr = base_addr + read_chunk_size
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats_per_read - 1)
    for j in range(4):
        addr_byte = (second_chunk_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for second read status to be Done"
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    assert bytes_available == read_chunk_size, f"Expected {read_chunk_size} bytes available, but got {bytes_available}"
    read_data_bytes.extend(await spi_master.bulk_read(read_chunk_size))
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    dut._log.info("Second 2KB read complete.")

    # --- Verification ---
    dut._log.info("Verifying data...")
    assert read_data_bytes == golden_data_bytes, "Read-back data does not match golden data"
    dut._log.info("Data verification successful!")

    await responder_task
    dut._log.info("--- Large Pipelined Read Test Passed ---")


@cocotb.test(timeout_time=500, timeout_unit="sec")
async def test_large_write_then_pipelined_read(dut):
    """Tests a large write (4KB) followed by two pipelined reads (2KB each)."""
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())

    spi_master = SPIMaster(
        clk=dut.io_spi_clk,
        csb=dut.io_spi_csb,
        mosi=dut.io_spi_mosi,
        miso=dut.io_spi_miso,
        main_clk=dut.clock,
        log=dut._log
    )
    await setup_dut(dut, spi_master)
    tl_device = TileLinkULInterface(dut, device_if_name="io_tl", width=128)
    await tl_device.init()

    total_size = 4096
    read_chunk_size = 2048
    bus_width_bytes = 128 // 8
    num_beats_total = total_size // bus_width_bytes
    num_beats_per_read = read_chunk_size // bus_width_bytes
    base_addr = 0x20000000

    dut._log.info(f"Generating {total_size // 1024}KB of random data...")
    golden_data = [random.randint(0, (1 << 128) - 1) for _ in range(num_beats_total)]
    dut._log.info("Data generation complete.")

    # --- Device Responder Task ---
    async def device_responder():
        mem = {}  # Byte-addressable memory

        # --- Write Phase: Populate memory ---
        dut._log.info(f"Device responder waiting for {num_beats_total} write beats...")
        for i in range(num_beats_total):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) in [0, 1]
            addr = int(req['address'])
            data = int(req['data'])
            for byte_idx in range(bus_width_bytes):
                byte_val = (data >> (byte_idx * 8)) & 0xFF
                mem[addr + byte_idx] = byte_val
            await tl_device.device_respond(
                opcode=0, param=0, size=req['size'], source=req['source'], error=0, width=128
            )
        dut._log.info("Device responder write phase complete.")

        # --- Read Phase: Serve data from memory for two separate reads ---
        dut._log.info(f"Device responder waiting for {num_beats_total} read beats...")
        for i in range(num_beats_total):
            req = await tl_device.device_get_request()
            assert int(req['opcode']) == 4
            addr = int(req['address'])
            response_data = 0
            for byte_idx in range(bus_width_bytes):
                byte_val = mem.get(addr + byte_idx, 0)
                response_data |= (byte_val << (byte_idx * 8))
            await tl_device.device_respond(
                opcode=1, param=0, size=req['size'], source=req['source'], data=response_data, error=0, width=128
            )
        dut._log.info("Device responder read phase complete.")

    responder_task = cocotb.start_soon(device_responder())

    # --- Main Test Logic ---
    # 1. Write Phase: Write the 4KB of data to the device's memory
    dut._log.info("Starting 4KB write to device...")
    await spi_master.packed_write_transaction(
        target_addr=base_addr,
        data=golden_data,
    )
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for write status to be Done"
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    dut._log.info("Write to device complete.")

    # 2. Read Phase: Read the 4KB back in two 2KB chunks
    read_data_bytes = bytearray()

    # First 2KB read
    dut._log.info("Starting first 2KB read from device...")
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats_per_read - 1)
    for j in range(4):
        addr_byte = (base_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for first read status to be Done"
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    assert bytes_available == read_chunk_size, f"Expected {read_chunk_size} bytes available, but got {bytes_available}"
    read_data_bytes.extend(await spi_master.bulk_read(read_chunk_size))
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    dut._log.info("First 2KB read complete.")

    # Second 2KB read
    dut._log.info("Starting second 2KB read from device...")
    second_chunk_addr = base_addr + read_chunk_size
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, num_beats_per_read - 1)
    for j in range(4):
        addr_byte = (second_chunk_addr >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE, max_polls=2000), "Timed out waiting for second read status to be Done"
    bytes_available = await spi_master.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
    assert bytes_available == read_chunk_size, f"Expected {read_chunk_size} bytes available, but got {bytes_available}"
    read_data_bytes.extend(await spi_master.bulk_read(read_chunk_size))
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
    dut._log.info("Second 2KB read complete.")

    # --- Verification ---
    dut._log.info("Verifying data...")
    golden_data_bytes = bytearray()
    for word in golden_data:
        golden_data_bytes.extend(word.to_bytes(16, 'little'))

    assert read_data_bytes == golden_data_bytes, "Read-back data does not match golden data"
    dut._log.info("Data verification successful!")

    await responder_task
    dut._log.info("--- Large Write/Pipelined Read Test Passed ---")

