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
import numpy as np
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, with_timeout
from elftools.elf.elffile import ELFFile
from bazel_tools.tools.python.runfiles import runfiles

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req
from coralnpu_test_utils.axi_slave import AxiSlave
from coralnpu_test_utils.spi_master import SPIMaster
from coralnpu_test_utils.spi_constants import SpiRegAddress, SpiCommand, TlStatus

# --- Constants ---
BUS_WIDTH_BITS = 128
BUS_WIDTH_BYTES = 16

async def setup_dut(dut):
    """Common setup logic for all tests."""
    # Default all TL-UL input signals to a safe state
    for i in range(4): # 4 external device ports
        getattr(dut, f"io_external_devices_ports_{i}_d_valid").value = 0

    # Start the main clock
    clock = Clock(dut.io_clk_i, 10)
    cocotb.start_soon(clock.start())

    # Start the asynchronous test clock
    test_clock = Clock(dut.io_async_ports_hosts_clocks_0, 20)
    cocotb.start_soon(test_clock.start())

    # Reset the DUT
    dut.io_rst_ni.value = 0
    dut.io_async_ports_hosts_resets_0.value = 1
    await ClockCycles(dut.io_clk_i, 5)
    dut.io_rst_ni.value = 1
    dut.io_async_ports_hosts_resets_0.value = 0
    await ClockCycles(dut.io_clk_i, 5)

    # Add a final delay to ensure all reset synchronizers have settled
    await ClockCycles(dut.io_clk_i, 10)

    return clock

async def load_elf(dut, elf_file, host_if):
    """Parses an ELF file and loads its segments into memory via TileLink."""
    elf = ELFFile(elf_file)
    entry_point = elf.header.e_entry

    for segment in elf.iter_segments():
        if segment.header.p_type == 'PT_LOAD':
            paddr = segment.header.p_paddr
            data = segment.data()
            dut._log.info(f"Loading segment at 0x{paddr:08x}, size {len(data)} bytes")

            # Write segment data word by word (32 bits)
            for i in range(0, len(data), 4):
                word_addr = paddr + i
                # Handle potentially short final word
                word_data = data[i:i+4]
                while len(word_data) < 4:
                    word_data += b'\x00'

                # Convert bytes to integer for the transaction
                int_data = int.from_bytes(word_data, byteorder='little')

                # Create and send the write transaction
                write_txn = create_a_channel_req(
                    address=word_addr,
                    data=int_data,
                    mask=0xF,  # Full 32-bit mask
                    width=host_if.width
                )
                await host_if.host_put(write_txn)

                # Wait for the acknowledgment
                resp = await host_if.host_get_response()
                assert resp["error"] == 0, f"Received error response while writing to 0x{word_addr:08x}"

    return entry_point

async def load_elf_via_spi(dut, elf_file, spi_master):
    """Parses an ELF file and loads its segments into memory via SPI."""
    elf = ELFFile(elf_file)
    entry_point = elf.header.e_entry

    for segment in elf.iter_segments():
        if segment.header.p_type == 'PT_LOAD':
            paddr = segment.header.p_paddr
            data = segment.data()
            dut._log.info(f"Loading segment at 0x{paddr:08x}, size {len(data)} bytes via SPI")

            # Load data line by line
            for i in range(0, len(data), BUS_WIDTH_BYTES):
                line_addr = paddr + i
                line_data = data[i:i+BUS_WIDTH_BYTES]
                while len(line_data) < BUS_WIDTH_BYTES:
                    line_data += b'\x00'
                int_data = int.from_bytes(line_data, byteorder='little')
                dut._log.info(f"Loading line at 0x{line_addr:08x}")
                await write_line_via_spi(spi_master, line_addr, int_data)

    return entry_point


async def read_line_via_spi(spi_master, address):
    """Reads a full 128-bit bus line from a given address via the SPI bridge."""
    assert address % BUS_WIDTH_BYTES == 0, f"Address 0x{address:X} is not aligned to the bus width of {BUS_WIDTH_BYTES} bytes"

    # 1. Configure the TileLink read via SPI
    # Write address (32 bits) byte by byte
    for j in range(4):
        addr_byte = (address >> (j * 8)) & 0xFF
        await spi_master.write_reg(SpiRegAddress.TL_ADDR_REG_0 + j, addr_byte)

    # Write length (0 means 1 beat of 128 bits)
    await spi_master.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, 0)

    # 2. Issue the read command
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

    # 3. Poll the status register until the transaction is done
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE), \
        f"Timed out waiting for SPI read from 0x{address:08x} to complete"

    # 4. Read the data from the buffer port
    read_data = await spi_master.bulk_read(BUS_WIDTH_BYTES)

    # 5. Clear the status to return FSM to Idle
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

    return int.from_bytes(bytes(read_data), byteorder='little')


async def update_line_via_spi(spi_master, address, data, mask):
    """Performs a read-modify-write to update a 128-bit line via SPI."""
    assert address % BUS_WIDTH_BYTES == 0, f"Address 0x{address:X} is not aligned to the bus width of {BUS_WIDTH_BYTES} bytes"
    # Read the current line from memory
    line_data = await read_line_via_spi(spi_master, address)

    # Apply the masked data update
    # The mask is a bitmask where each bit corresponds to a byte.
    updated_data = 0
    for i in range(BUS_WIDTH_BYTES):
        byte_mask = (mask >> i) & 1
        if byte_mask:
            updated_data |= ((data >> (i * 8)) & 0xFF) << (i * 8)
        else:
            updated_data |= ((line_data >> (i * 8)) & 0xFF) << (i * 8)

    # Write the modified line back to memory
    await write_line_via_spi(spi_master, address, updated_data)


async def write_line_via_spi(spi_master, address, data):
    """Writes a 128-bit bus line to a given address via the SPI bridge."""
    assert address % BUS_WIDTH_BYTES == 0, f"Address 0x{address:X} is not aligned to the bus width of {BUS_WIDTH_BYTES} bytes"

    # Emit a full transaction for the line.
    await spi_master.packed_write_transaction(target_addr=address, data=[data])

    # Poll status register until the transaction is done.
    assert await spi_master.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE), \
        f"Timed out waiting for SPI write to 0x{address:08x} to complete"

    # Clear the status to return FSM to Idle.
    await spi_master.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)


async def write_word_via_spi(spi_master, address, data):
    """Writes a 32-bit value to a specific address using the SPI bridge.

    Note: This function performs a read-modify-write operation on the underlying
    128-bit bus. It is not suitable for writing to memory-mapped registers
    where the read operation has side effects.
    """
    line_addr = (address // BUS_WIDTH_BYTES) * BUS_WIDTH_BYTES
    offset = address % BUS_WIDTH_BYTES
    mask = 0xF << offset  # 4-byte mask at the correct offset
    shifted_data = data << (offset * 8)
    await update_line_via_spi(spi_master, line_addr, shifted_data, mask)

@cocotb.test()
async def test_tlul_passthrough(dut):
    """Drives a TL-UL transaction through an external host and device port."""
    clock = await setup_dut(dut)

    # Instantiate a TL-UL host to drive the first external host port (ibex_core_i)
    host_if = TileLinkULInterface(
        dut,
        host_if_name="io_external_hosts_ports_0",
        clock_name="io_async_ports_hosts_clocks_0",
        reset_name="io_async_ports_hosts_resets_0",
        width=32)

    # Instantiate a TL-UL device to act as the first external device (rom)
    device_if = TileLinkULInterface(
        dut,
        device_if_name="io_external_devices_ports_0",
        clock_name="io_clk_i",
        reset_name="io_rst_ni",
        width=32)

    # Initialize the interfaces
    await host_if.init()
    await device_if.init()

    # --- Device Responder Task ---
    # This task mimics the behavior of the external ROM device.
    ROM_BASE_ADDR = 0x10000000
    TEST_SOURCE_ID = 5
    TEST_DATA = 0xCAFED00D

    async def device_responder():
        """A mock responder for the external ROM."""
        req = await device_if.device_get_request()

        # Verify the incoming request
        assert (req["opcode"] == 0) or (req["opcode"] == 1), f"Expected Put-type opcode (0 or 1), got {req['opcode']}"
        assert req["address"] == ROM_BASE_ADDR, f"Expected address {ROM_BASE_ADDR:X}, got {req['address']:X}"
        assert req["data"] == TEST_DATA, f"Expected data {TEST_DATA:X}, got {req['data']:X}"

        # Send an AccessAck response
        await device_if.device_respond(
            opcode=0,  # AccessAck
            param=0,
            size=req["size"],
            source=req["source"],
            error=0
        )

    # Start the device responder coroutine
    responder_task = cocotb.start_soon(device_responder())

    # --- Host Stimulus ---
    # Create and send a 'PutFullData' request from the host.
    write_txn = create_a_channel_req(
        address=ROM_BASE_ADDR,
        source=TEST_SOURCE_ID,
        data=TEST_DATA,
        mask=0xF, # Full mask for 32 bits
        width=host_if.width
    )
    await host_if.host_put(write_txn)

    # Wait for and verify the response.
    resp = await host_if.host_get_response()
    assert resp["error"] == 0, "Response indicated an error"
    assert resp["source"] == TEST_SOURCE_ID, f"Expected source ID {TEST_SOURCE_ID}, got {resp['source']}"
    assert resp["opcode"] == 0, f"Expected AccessAck opcode (0), got {resp['opcode']}"

    # Ensure the responder task finished cleanly.
    await responder_task

@cocotb.test()
async def test_program_execution_via_host(dut):
    """Loads and executes a program via an external host port."""
    clock = await setup_dut(dut)

    # Instantiate a TL-UL host to drive the 0-th external host port (test_host_32)
    host_if = TileLinkULInterface(
        dut,
        host_if_name="io_external_hosts_ports_0",
        clock_name="io_async_ports_hosts_clocks_0",
        reset_name="io_async_ports_hosts_resets_0",
        width=32)

    # Initialize the interface
    await host_if.init()

    # Find and load the ELF file
    r = runfiles.Create()
    elf_path = r.Rlocation("coralnpu_hw/tests/cocotb/rvv/arithmetics/rvv_add_int32_m1.elf")
    assert elf_path, "Could not find ELF file"

    with open(elf_path, "rb") as f:
        entry_point = await load_elf(dut, f, host_if)

    dut._log.info(f"Program loaded. Entry point: 0x{entry_point:08x}")

    # --- Execute Program ---
    # From the integration guide:
    # 1. Program the start PC
    # 2. Release clock gate
    # 3. Release reset

    coralnpu_pc_csr_addr = 0x30004
    coralnpu_reset_csr_addr = 0x30000

    # Program the start PC
    dut._log.info(f"Programming start PC to 0x{entry_point:08x}")
    write_txn = create_a_channel_req(
        address=coralnpu_pc_csr_addr,
        data=entry_point,
        mask=0xF,
        width=host_if.width
    )
    await host_if.host_put(write_txn)
    resp = await host_if.host_get_response()
    assert resp["error"] == 0

    # Release clock gate
    dut._log.info("Releasing clock gate...")
    write_txn = create_a_channel_req(
        address=coralnpu_reset_csr_addr,
        data=1,
        mask=0xF,
        width=host_if.width
    )
    await host_if.host_put(write_txn)
    resp = await host_if.host_get_response()
    assert resp["error"] == 0

    await ClockCycles(dut.io_clk_i, 1)

    # Release reset
    dut._log.info("Releasing reset...")
    write_txn = create_a_channel_req(
        address=coralnpu_reset_csr_addr,
        data=0,
        mask=0xF,
        width=host_if.width
    )
    await host_if.host_put(write_txn)
    resp = await host_if.host_get_response()
    assert resp["error"] == 0

    # --- Wait for Completion ---
    dut._log.info("Waiting for program to halt...")
    timeout_cycles = 100000
    for i in range(timeout_cycles):
        if dut.io_external_ports_0.value == 1:  # halted is port 0
            break
        await ClockCycles(dut.io_clk_i, 1)
    else:  # This else belongs to the for loop, executed if the loop finishes without break
        assert False, f"Timeout: Program did not halt within {timeout_cycles} cycles."

    dut._log.info("Program halted.")
    assert dut.io_external_ports_1.value == 0, "Program halted with fault!"

@cocotb.test()
async def test_program_execution_via_spi(dut):
    """Loads and executes a program via the SPI to TL-UL bridge."""
    clock = await setup_dut(dut)

    spi_master = SPIMaster(
        clk=dut.io_external_ports_5,
        csb=dut.io_external_ports_6,
        mosi=dut.io_external_ports_7,
        miso=dut.io_external_ports_8,
        main_clk=dut.io_clk_i,
        log=dut._log
    )
    await spi_master.idle_clocking(20)

    # Find and load the ELF file
    r = runfiles.Create()
    elf_path = r.Rlocation("coralnpu_hw/tests/cocotb/rvv/arithmetics/rvv_add_int32_m1.elf")
    assert elf_path, "Could not find ELF file"

    with open(elf_path, "rb") as f:
        entry_point = await load_elf_via_spi(dut, f, spi_master)

    dut._log.info(f"Program loaded via SPI. Entry point: 0x{entry_point:08x}")

    # --- Execute Program ---
    coralnpu_pc_csr_addr = 0x30004
    coralnpu_reset_csr_addr = 0x30000

    # Program the start PC
    dut._log.info(f"Programming start PC to 0x{entry_point:08x}")
    await write_word_via_spi(spi_master, coralnpu_pc_csr_addr, entry_point)

    # Release clock gate
    dut._log.info("Releasing clock gate...")
    await write_word_via_spi(spi_master, coralnpu_reset_csr_addr, 1)

    await ClockCycles(dut.io_clk_i, 1)

    # Release reset
    dut._log.info("Releasing reset...")
    await write_word_via_spi(spi_master, coralnpu_reset_csr_addr, 0)

    # --- Wait for Completion ---
    dut._log.info("Waiting for program to halt...")
    timeout_cycles = 100000
    for i in range(timeout_cycles):
        if dut.io_external_ports_0.value == 1:  # halted is port 0
            break
        await ClockCycles(dut.io_clk_i, 1)
    else:  # This else belongs to the for loop, executed if the loop finishes without break
        assert False, f"Timeout: Program did not halt within {timeout_cycles} cycles."

    dut._log.info("Program halted.")
    assert dut.io_external_ports_1.value == 0, "Program halted with fault!"

@cocotb.test()
async def test_ddr_access(dut):
    """Tests TileLink transactions to the DDR domain."""
    await setup_dut(dut)

    # --- DDR Clock and Reset Setup ---
    ddr_clk_signal = dut.io_async_ports_devices_clocks_0
    ddr_rst_signal = dut.io_async_ports_devices_resets_0
    ddr_rst_signal.value = 1

    ddr_clock = Clock(ddr_clk_signal, 2)
    cocotb.start_soon(ddr_clock.start())

    ddr_rst_signal.value = 0
    await ClockCycles(dut.io_clk_i, 5)
    ddr_rst_signal.value = 1
    await ClockCycles(dut.io_clk_i, 5)
    ddr_rst_signal.value = 0
    await ClockCycles(dut.io_clk_i, 5)

    # Instantiate a TL-UL host to drive transactions
    host_if = TileLinkULInterface(
        dut,
        host_if_name="io_external_hosts_ports_0",
        clock_name="io_async_ports_hosts_clocks_0",
        reset_name="io_async_ports_hosts_resets_0",
        width=32)
    await host_if.init()

    # --- AXI Responder Models ---
    DDR_CTRL_BASE = 0x70000000
    DDR_MEM_BASE = 0x80000000
    TEST_DATA = 0x12345678

    ddr_ctrl_slave = AxiSlave(dut, "ddr_ctrl_axi", ddr_clk_signal, ddr_rst_signal, dut._log, has_memory=True, mem_base_addr=DDR_CTRL_BASE)
    ddr_mem_slave = AxiSlave(dut, "ddr_mem_axi", ddr_clk_signal, ddr_rst_signal, dut._log, has_memory=True, mem_base_addr=DDR_MEM_BASE)
    ddr_ctrl_slave.start()
    ddr_mem_slave.start()

    # Allow the AXI slave coroutines to start and initialize signals
    await RisingEdge(ddr_clk_signal)

    # --- Stimulus ---
    # Write to ddr_ctrl
    dut._log.info("Sending write to ddr_ctrl...")
    write_txn = create_a_channel_req(address=DDR_CTRL_BASE, data=TEST_DATA, mask=0xF, width=host_if.width)
    await host_if.host_put(write_txn)
    resp = await with_timeout(host_if.host_get_response(), 10000)
    assert resp["error"] == 0, "ddr_ctrl write response indicated an error"
    dut._log.info("Write to ddr_ctrl successful.")

    # Write to ddr_mem
    dut._log.info("Sending write to ddr_mem...")
    write_txn = create_a_channel_req(address=DDR_MEM_BASE, data=TEST_DATA, mask=0xF, width=host_if.width)
    await host_if.host_put(write_txn)
    resp = await host_if.host_get_response()
    assert resp["error"] == 0, "ddr_mem write response indicated an error"
    dut._log.info("Write to ddr_mem successful.")

    dut._log.info("Sending read to ddr_ctrl...")
    read_txn = create_a_channel_req(address=DDR_CTRL_BASE, width=host_if.width, is_read=True)
    await host_if.host_put(read_txn)
    resp = await with_timeout(host_if.host_get_response(), 10000)
    assert resp["error"] == 0, "ddr_ctrl read response had error"
    dut._log.info("Read from ddr_ctrl successful.")

    dut._log.info("Sending read to ddr_mem...")
    read_txn = create_a_channel_req(address=DDR_MEM_BASE, width=host_if.width, is_read=True)
    await host_if.host_put(read_txn)
    resp = await with_timeout(host_if.host_get_response(), 10000)
    assert resp["error"] == 0, "ddr_mem read response had error"
    dut._log.info("Read from ddr_mem successful.")

    await ClockCycles(dut.io_clk_i, 20)

@cocotb.test()
async def test_ddr_access_via_spi(dut):
    clock = await setup_dut(dut)

    spi_master = SPIMaster(
        clk=dut.io_external_ports_5,
        csb=dut.io_external_ports_6,
        mosi=dut.io_external_ports_7,
        miso=dut.io_external_ports_8,
        main_clk=dut.io_clk_i,
        log=dut._log
    )
    await spi_master.idle_clocking(20)

    # --- DDR Clock and Reset Setup ---
    ddr_clk_signal = dut.io_async_ports_devices_clocks_0
    ddr_rst_signal = dut.io_async_ports_devices_resets_0
    ddr_rst_signal.value = 1

    ddr_clock = Clock(ddr_clk_signal, 2)
    cocotb.start_soon(ddr_clock.start())

    ddr_rst_signal.value = 0
    await ClockCycles(dut.io_clk_i, 5)
    ddr_rst_signal.value = 1
    await ClockCycles(dut.io_clk_i, 5)
    ddr_rst_signal.value = 0
    await ClockCycles(dut.io_clk_i, 5)

    # --- AXI Responder Models ---
    DDR_MEM_BASE = 0x80000000
    ddr_mem_slave = AxiSlave(dut, "ddr_mem_axi", ddr_clk_signal, ddr_rst_signal, dut._log, has_memory=True, mem_base_addr=DDR_MEM_BASE)
    ddr_mem_slave.start()

    # Allow the AXI slave coroutines to start and initialize signals
    await RisingEdge(ddr_clk_signal)


    data0 = 0x00112233445566778899AABBCCDDEEFF
    data1 = 0xFFEEDDCCBBAA99887766554433221100
    await write_line_via_spi(spi_master, DDR_MEM_BASE, data0)
    await write_line_via_spi(spi_master, DDR_MEM_BASE + 0x10, data1)

    rdata0 = await read_line_via_spi(spi_master, DDR_MEM_BASE)
    rdata1 = await read_line_via_spi(spi_master, DDR_MEM_BASE + 0x10)

    assert (data0 == rdata0)
    assert (data1 == rdata1)
