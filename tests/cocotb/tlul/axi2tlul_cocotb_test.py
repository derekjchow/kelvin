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
import enum
import random

from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

class TLUL_OpcodeA(enum.IntEnum):
    PutFullData    = 0
    PutPartialData = 1
    Get            = 4

class TLUL_OpcodeD(enum.IntEnum):
    AccessAck     = 0
    AccessAckData = 1

async def reset_dut(dut):
    """Applies reset to the DUT."""
    dut.reset.value = 1
    dut.io_axi_read_addr_valid.value = 0
    dut.io_axi_write_addr_valid.value = 0
    dut.io_axi_write_data_valid.value = 0
    dut.io_axi_write_resp_ready.value = 0
    dut.io_axi_read_data_ready.value = 0
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await ClockCycles(dut.clock, 2)

async def axi_send_write(dut, address, source, size, data, strb, timeout_cycles=1000):
    """Sends an AXI write transaction."""
    dut.io_axi_write_addr_valid.value = 1
    dut.io_axi_write_addr_bits_addr.value = address
    dut.io_axi_write_addr_bits_id.value = source
    dut.io_axi_write_addr_bits_size.value = size

    dut.io_axi_write_data_valid.value = 1
    dut.io_axi_write_data_bits_data.value = data
    dut.io_axi_write_data_bits_strb.value = strb

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clock)
        if dut.io_axi_write_addr_ready.value == 1 and dut.io_axi_write_data_ready.value == 1:
            break
    else:
        raise RuntimeError(f"Timeout waiting for AXI write ready")

    dut.io_axi_write_addr_valid.value = 0
    dut.io_axi_write_data_valid.value = 0

async def axi_send_read(dut, address, source, size, timeout_cycles=1000):
    """Sends an AXI read transaction."""
    dut.io_axi_read_addr_valid.value = 1
    dut.io_axi_read_addr_bits_addr.value = address
    dut.io_axi_read_addr_bits_id.value = source
    dut.io_axi_read_addr_bits_size.value = size

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clock)
        if dut.io_axi_read_addr_ready.value == 1:
            break
    else:
        raise RuntimeError(f"Timeout waiting for AXI read ready")

    dut.io_axi_read_addr_valid.value = 0

@cocotb.test()
async def test_write_request(dut):
    """Tests a simple AXI write request."""
    clock = Clock(dut.clock, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    dut.io_tl_a_ready.value = 0
    dut.io_tl_d_valid.value = 0

    addr_width = 32
    source_width = 6
    data_width_bytes = 32
    timeout_cycles = 1000

    size_power = random.randint(0, 5)
    test_size = size_power
    num_bytes = 2**size_power

    test_addr = random.randint(0, (2**addr_width) - 1)
    test_source = random.randint(0, (2**source_width) - 1)
    test_data = random.randint(0, (2**(data_width_bytes*8)) - 1)
    test_strb = (1 << num_bytes) - 1

    await axi_send_write(dut, address=test_addr, source=test_source, size=test_size, data=test_data, strb=test_strb, timeout_cycles=timeout_cycles)

    await RisingEdge(dut.clock)
    assert dut.io_tl_a_valid.value, "TL A_VALID should be high"
    assert dut.io_tl_a_bits_opcode.value == TLUL_OpcodeA.PutFullData, "TL A_OPCODE should be PutFullData"
    assert dut.io_tl_a_bits_address.value == test_addr, "TL A_ADDRESS is incorrect"
    assert dut.io_tl_a_bits_source.value == test_source, "TL A_SOURCE is incorrect"
    assert dut.io_tl_a_bits_size.value == test_size, "TL A_SIZE is incorrect"
    assert dut.io_tl_a_bits_data.value == test_data, "TL A_DATA is incorrect"
    assert dut.io_tl_a_bits_mask.value == test_strb, "TL A_MASK is incorrect"

    dut.io_tl_a_ready.value = 1
    await RisingEdge(dut.clock)
    dut.io_tl_a_ready.value = 0

    dut.io_axi_write_resp_ready.value = 1
    dut.io_tl_d_valid.value = 1
    dut.io_tl_d_bits_opcode.value = TLUL_OpcodeD.AccessAck
    dut.io_tl_d_bits_source.value = test_source

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clock)
        if dut.io_tl_d_ready.value:
            assert dut.io_axi_write_resp_valid.value, "AXI BVALID should be high"
            assert dut.io_axi_write_resp_bits_id.value == test_source, "AXI BID is incorrect"
            assert dut.io_axi_write_resp_bits_resp.value == 0, "AXI BRESP is incorrect"
            dut.io_axi_write_resp_ready.value = 0
            break
    else:
        raise RuntimeError("Timeout waiting for io_tl_d_ready")

    await RisingEdge(dut.clock)
    dut.io_tl_d_valid.value = 0

    await ClockCycles(dut.clock, 5)

@cocotb.test()
async def test_read_request(dut):
    """Tests a simple AXI read request."""
    clock = Clock(dut.clock, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    dut.io_tl_a_ready.value = 0
    dut.io_tl_d_valid.value = 0

    addr_width = 32
    source_width = 6
    data_width_bytes = 32
    timeout_cycles = 1000

    size_power = random.randint(0, 5)
    test_size = size_power

    test_addr = random.randint(0, (2**addr_width) - 1)
    test_source = random.randint(0, (2**source_width) - 1)
    test_data = random.randint(0, (2**(data_width_bytes*8)) - 1)

    await axi_send_read(dut, address=test_addr, source=test_source, size=test_size, timeout_cycles=timeout_cycles)

    await RisingEdge(dut.clock)
    assert dut.io_tl_a_valid.value, "TL A_VALID should be high"
    assert dut.io_tl_a_bits_opcode.value == TLUL_OpcodeA.Get, "TL A_OPCODE should be Get"
    assert dut.io_tl_a_bits_address.value == test_addr, "TL A_ADDRESS is incorrect"
    assert dut.io_tl_a_bits_source.value == test_source, "TL A_SOURCE is incorrect"
    assert dut.io_tl_a_bits_size.value == test_size, "TL A_SIZE is incorrect"

    dut.io_tl_a_ready.value = 1
    await RisingEdge(dut.clock)
    dut.io_tl_a_ready.value = 0

    await RisingEdge(dut.clock)
    dut.io_tl_d_valid.value = 1
    dut.io_tl_d_bits_opcode.value = TLUL_OpcodeD.AccessAckData
    dut.io_tl_d_bits_source.value = test_source
    dut.io_tl_d_bits_data.value = test_data
    dut.io_tl_d_bits_error.value = 0

    dut.io_axi_read_data_ready.value = 1

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clock)
        if dut.io_tl_d_ready.value:
            assert dut.io_axi_read_data_valid.value, "AXI RVALID should be high"
            assert dut.io_axi_read_data_bits_id.value == test_source, "AXI RID is incorrect"
            assert dut.io_axi_read_data_bits_data.value == test_data, "AXI RDATA is incorrect"
            assert dut.io_axi_read_data_bits_resp.value == 0, "AXI RRESP is incorrect"
            dut.io_axi_read_data_ready.value = 0
            break
    else:
        raise RuntimeError("Timeout waiting for io_tl_d_ready")

    await RisingEdge(dut.clock)
    dut.io_tl_d_valid.value = 0

    await ClockCycles(dut.clock, 5)


@cocotb.test()
async def test_read_error(dut):
    """Tests a simple AXI read request that results in a TL error."""
    clock = Clock(dut.clock, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    dut.io_tl_a_ready.value = 0
    dut.io_tl_d_valid.value = 0

    addr_width = 32
    source_width = 6
    data_width_bytes = 32
    timeout_cycles = 1000

    size_power = random.randint(0, 5)
    test_size = size_power

    test_addr = random.randint(0, (2**addr_width) - 1)
    test_source = random.randint(0, (2**source_width) - 1)
    test_data = random.randint(0, (2**(data_width_bytes*8)) - 1)

    await axi_send_read(dut, address=test_addr, source=test_source, size=test_size, timeout_cycles=timeout_cycles)

    await RisingEdge(dut.clock)
    assert dut.io_tl_a_valid.value, "TL A_VALID should be high"
    assert dut.io_tl_a_bits_opcode.value == TLUL_OpcodeA.Get, "TL A_OPCODE should be Get"
    assert dut.io_tl_a_bits_address.value == test_addr, "TL A_ADDRESS is incorrect"
    assert dut.io_tl_a_bits_source.value == test_source, "TL A_SOURCE is incorrect"
    assert dut.io_tl_a_bits_size.value == test_size, "TL A_SIZE is incorrect"

    dut.io_tl_a_ready.value = 1
    await RisingEdge(dut.clock)
    dut.io_tl_a_ready.value = 0

    await RisingEdge(dut.clock)
    dut.io_tl_d_valid.value = 1
    dut.io_tl_d_bits_opcode.value = TLUL_OpcodeD.AccessAckData
    dut.io_tl_d_bits_source.value = test_source
    dut.io_tl_d_bits_data.value = test_data
    dut.io_tl_d_bits_error.value = 1

    dut.io_axi_read_data_ready.value = 1

    for _ in range(timeout_cycles):
        await RisingEdge(dut.clock)
        if dut.io_tl_d_ready.value:
            assert dut.io_axi_read_data_valid.value, "AXI RVALID should be high"
            assert dut.io_axi_read_data_bits_id.value == test_source, "AXI RID is incorrect"
            assert dut.io_axi_read_data_bits_data.value == test_data, "AXI RDATA is incorrect"
            assert dut.io_axi_read_data_bits_resp.value == 2, "AXI RRESP is incorrect"
            dut.io_axi_read_data_ready.value = 0
            break
    else:
        raise RuntimeError("Timeout waiting for io_tl_d_ready")

    await RisingEdge(dut.clock)
    dut.io_tl_d_valid.value = 0

    await ClockCycles(dut.clock, 5)
