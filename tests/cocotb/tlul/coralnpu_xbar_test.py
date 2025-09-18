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
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, with_timeout

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req
from coralnpu_test_utils.secded_golden import get_cmd_intg, get_data_intg, get_rsp_intg

# --- Configuration Constants ---
# These constants are derived from CrossbarConfig.scala to make tests readable.
HOST_MAP = {"coralnpu_core": 0, "spi2tlul": 1, "test_host_32": 2}
DEVICE_MAP = {
    "coralnpu_device": 0,
    "rom": 1,
    "sram": 2,
    "uart0": 3,
    "uart1": 4,
}
SRAM_BASE = 0x20000000
UART1_BASE = 0x40010000
CORALNPU_DEVICE_BASE = 0x00000000
INVALID_ADDR = 0x50000000
TIMEOUT_CYCLES = 500


# --- Test Setup ---
async def setup_dut(dut):
    """Common setup logic for all tests."""
    # Start the main clock
    clock = Clock(dut.clock, 5)
    cocotb.start_soon(clock.start())

    # Start the asynchronous test clock
    test_clock = Clock(dut.io_async_ports_hosts_0_clock, 10)
    cocotb.start_soon(test_clock.start())

    # Create a dictionary of TileLink interfaces for all hosts and devices
    host_widths = {"coralnpu_core": 128, "spi2tlul": 128, "test_host_32": 32}
    device_widths = {
        "coralnpu_device": 128,
        "rom": 32,
        "sram": 32,
        "uart0": 32,
        "uart1": 32,
    }

    interfaces = {
        "hosts": [
            TileLinkULInterface(dut,
                                host_if_name=f"io_hosts_{i}",
                                clock_name="clock" if name != "test_host_32" else "io_async_ports_hosts_0_clock",
                                reset_name="reset" if name != "test_host_32" else "io_async_ports_hosts_0_reset",
                                width=host_widths[name])
            for name, i in HOST_MAP.items()
        ],
        "devices": [
            TileLinkULInterface(dut,
                                device_if_name=f"io_devices_{i}",
                                clock_name="clock",
                                reset_name="reset",
                                width=device_widths[name])
            for name, i in DEVICE_MAP.items()
        ],
    }

    # Reset the DUT
    dut.reset.value = 1
    dut.io_async_ports_hosts_0_reset.value = 1
    await ClockCycles(dut.clock, 5)
    dut.reset.value = 0
    dut.io_async_ports_hosts_0_reset.value = 0
    await ClockCycles(dut.clock, 5)

    return interfaces, clock



# --- Test Cases ---


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_coralnpu_core_to_sram(dut):
    """Verify a simple write/read transaction from coralnpu_core to sram."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["coralnpu_core"]]
    device_if = interfaces["devices"][DEVICE_MAP["sram"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 128-bit write request from the host
    test_data = 0x112233445566778899AABBCCDDEEFF00
    write_txn = create_a_channel_req(address=SRAM_BASE,
                                     data=test_data,
                                     mask=0xFFFF,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect four 32-bit transactions on the device side, order not guaranteed
    received_reqs = []
    for _ in range(4):
        req = await with_timeout(device_if.device_get_request(), timeout_ns,
                                 "ns")
        received_reqs.append(req)
        await with_timeout(
            device_if.device_respond(opcode=0,
                                     param=0,
                                     size=req["size"],
                                     source=req["source"]), timeout_ns, "ns")

    # Sort received requests by address for comparison
    received_reqs.sort(key=lambda r: r["address"].integer)

    # Verify all beats were received correctly
    for i in range(4):
        assert received_reqs[i]["address"] == SRAM_BASE + (i * 4)
        expected_data = (test_data >> (i * 32)) & 0xFFFFFFFF
        assert received_reqs[i]["data"] == expected_data

    # Use the last beat (highest address) for the response source
    last_req = received_reqs[-1]

    # Receive the response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0
    assert resp["source"] == write_txn["source"]


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_coralnpu_core_to_invalid_addr(dut):
    """Verify that a request to an unmapped address gets an error response."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["coralnpu_core"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a write request to an invalid address
    write_txn = create_a_channel_req(address=INVALID_ADDR,
                                     data=0,
                                     mask=0xF,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect an error response
    try:
        resp = await with_timeout(host_if.host_get_response(), timeout_ns,
                                  "ns")
        assert resp["error"] == 1
        assert resp["source"] == write_txn["source"]
    except Exception as e:
        # Allow the simulation to run for a few more cycles to get a clean waveform
        await ClockCycles(dut.clock, 20)
        raise e

@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_coralnpu_core_to_uart1(dut):
    """Verify a 128-bit to 32-bit write transaction."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["coralnpu_core"]]
    device_if = interfaces["devices"][DEVICE_MAP["uart1"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 128-bit write request
    test_data = 0x112233445566778899AABBCCDDEEFF00
    write_txn = create_a_channel_req(address=UART1_BASE,
                                     data=test_data,
                                     mask=0xF0F0,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect four 32-bit transactions on the device side, order not guaranteed
    received_reqs = []
    for i in range(2):
        req = await with_timeout(device_if.device_get_request(), timeout_ns,
                                 "ns")
        received_reqs.append(req)
        await with_timeout(
            device_if.device_respond(opcode=0,
                                     param=0,
                                     size=req["size"],
                                     source=req["source"],
                                     width=device_if.width), timeout_ns, "ns")

    # Sort received requests by address for comparison
    received_reqs.sort(key=lambda r: r["address"].integer)

    # Verify all beats were received correctly
    for idx, key in [(0, 1), (1, 3)]:
        assert received_reqs[idx]["address"] == UART1_BASE + (key * 4)
        expected_data = (test_data >> (key * 32)) & 0xFFFFFFFF
        assert received_reqs[idx]["data"] == expected_data

    # Use the last beat (highest address) for the response source
    last_req = received_reqs[-1]

    # Receive the response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0
    assert resp["source"] == write_txn["source"]


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_test_host_32_to_coralnpu_device(dut):
    """Verify a 32-bit to 128-bit write transaction."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["test_host_32"]]
    device_if = interfaces["devices"][DEVICE_MAP["coralnpu_device"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 32-bit write request
    write_txn = create_a_channel_req(address=CORALNPU_DEVICE_BASE,
                                     data=0x12345678,
                                     mask=0xF,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect a single 128-bit transaction on the device side
    req = await with_timeout(device_if.device_get_request(), timeout_ns, "ns")
    assert req["address"] == CORALNPU_DEVICE_BASE
    assert req["data"] == 0x12345678

    # Send a response from the device
    await with_timeout(
        device_if.device_respond(opcode=0,
                                 param=0,
                                 size=req["size"],
                                 source=req["source"],
                                 width=device_if.width), timeout_ns, "ns")

    # Expect a single response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_coralnpu_core_to_coralnpu_device(dut):
    """Verify a 128-bit to 128-bit write transaction (no bridge)."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["coralnpu_core"]]
    device_if = interfaces["devices"][DEVICE_MAP["coralnpu_device"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 128-bit write request
    write_txn = create_a_channel_req(address=CORALNPU_DEVICE_BASE,
                                     data=0x112233445566778899AABBCCDDEEFF00,
                                     mask=0xFFFF,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect a single 128-bit transaction on the device side
    req = await with_timeout(device_if.device_get_request(), timeout_ns, "ns")
    assert req["address"] == CORALNPU_DEVICE_BASE
    assert req["data"] == 0x112233445566778899AABBCCDDEEFF00

    # Send a response from the device
    await with_timeout(
        device_if.device_respond(opcode=0,
                                 param=0,
                                 size=req["size"],
                                 source=req["source"]), timeout_ns, "ns")

    # Expect a single response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0





@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_test_host_32_to_coralnpu_device_csr_read(dut):
    """Verify that test_host_32 can correctly read a CSR from the CoralNPU device.

    This test specifically checks the return path through the width bridge.
    """
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["test_host_32"]]
    device_if = interfaces["devices"][DEVICE_MAP["coralnpu_device"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period
    csr_addr = CORALNPU_DEVICE_BASE + 0x8  # Match the CSR address
    halted_status = 0x1  # Bit 0 for halted

    async def device_responder():
        """A mock responder for the coralnpu_device."""
        req = await with_timeout(device_if.device_get_request(), timeout_ns,
                                 "ns")
        # The address should be aligned to the device width (128-bit)
        aligned_addr = csr_addr & ~((device_if.width // 8) - 1)
        assert req["address"] == aligned_addr, f"Expected aligned address 0x{aligned_addr:X}, but got 0x{req['address'].integer:X}"
        # The CSR data is in the third 32-bit lane of the 128-bit bus.
        resp_data = halted_status << 64
        await with_timeout(
            device_if.device_respond(
                opcode=1,  # AccessAckData
                param=0,
                size=req["size"],
                source=req["source"],
                data=resp_data,
                width=device_if.width,
            ),
            timeout_ns,
            "ns")

    # Start the device responder coroutine
    cocotb.start_soon(device_responder())

    # Send a 32-bit read request from the host
    # TODO(atv): Do this thru helper?
    read_txn = {
        "opcode": 4,  # Get
        "param": 0,
        "size": 2,  # 4 bytes
        "source": 1,
        "address": csr_addr,
        "mask": 0xF,
        "data": 0,
        "user": {
            "cmd_intg": 0,
            "data_intg": 0,
            "instr_type": 0,
            "rsvd": 0
        }
    }
    read_txn["user"]["cmd_intg"] = get_cmd_intg(read_txn, width=host_if.width)
    read_txn["user"]["data_intg"] = get_data_intg(read_txn["data"],
                                                  width=host_if.width)
    await with_timeout(host_if.host_put(read_txn), timeout_ns, "ns")

    # Expect a single response on the host side with the correct data
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0
    assert resp[
        "data"] == halted_status, f"Expected CSR data {halted_status}, but got {resp['data']}"


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_test_host_32_to_coralnpu_device_specific_addr(dut):
    """Verify a write to a specific address in the coralnpu_device range."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["test_host_32"]]
    device_if = interfaces["devices"][DEVICE_MAP["coralnpu_device"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 32-bit write request to 0x30000
    test_addr = 0x30000
    write_txn = create_a_channel_req(address=test_addr,
                                     data=0xDEADBEEF,
                                     mask=0xF,
                                     width=host_if.width)
    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect a single 128-bit transaction on the device side
    req = await with_timeout(device_if.device_get_request(), timeout_ns, "ns")
    assert req[
        "address"] == test_addr, f"Expected address 0x{test_addr:X}, but got 0x{req['address'].integer:X}"
    assert req["data"] == 0xDEADBEEF

    # Send a response from the device
    await with_timeout(
        device_if.device_respond(opcode=0,
                                 param=0,
                                 size=req["size"],
                                 source=req["source"],
                                 width=device_if.width), timeout_ns, "ns")

    # Expect a single response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")
    assert resp["error"] == 0


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_wide_to_narrow_integrity(dut):
    """Verify integrity is checked and regenerated across the width bridge."""
    interfaces, clock = await setup_dut(dut)
    host_if = interfaces["hosts"][HOST_MAP["coralnpu_core"]]
    device_if = interfaces["devices"][DEVICE_MAP["uart1"]]
    timeout_ns = TIMEOUT_CYCLES * clock.period

    # Send a 128-bit write request from the host with correct integrity
    test_data = 0x112233445566778899AABBCCDDEEFF00
    write_txn = create_a_channel_req(address=UART1_BASE,
                                     data=test_data,
                                     mask=0xFFFF,
                                     width=host_if.width)

    await with_timeout(host_if.host_put(write_txn), timeout_ns, "ns")

    # Expect four 32-bit transactions on the device side
    received_reqs = []
    for i in range(4):
        req = await with_timeout(device_if.device_get_request(), timeout_ns,
                                 "ns")

        # Verify that the bridge regenerated integrity correctly for each beat
        assert req["user"]["cmd_intg"] == get_cmd_intg(req,
                                                       width=device_if.width)
        assert req["user"]["data_intg"] == get_data_intg(req["data"],
                                                         width=device_if.width)

        received_reqs.append(req)

        # Create a response with correct integrity
        resp_beat = {
            "opcode": 0,
            "param": 0,
            "size": req["size"],
            "source": req["source"],
            "sink": 0,
            "data": 0,
            "error": 0
        }
        resp_beat["user"] = {
            "rsp_intg": get_rsp_intg(resp_beat, width=device_if.width),
            "data_intg": get_data_intg(0, width=device_if.width)
        }
        await device_if.device_d_fifo.put(resp_beat)

    # Receive the final assembled response on the host side
    resp = await with_timeout(host_if.host_get_response(), timeout_ns, "ns")

    # Verify that the bridge checked and regenerated integrity correctly
    expected_resp = resp.copy()
    expected_resp["error"] = 0
    assert resp["user"]["rsp_intg"] == get_rsp_intg(expected_resp,
                                                    width=host_if.width)
    assert resp["user"]["data_intg"] == get_data_intg(resp["data"],
                                                      width=host_if.width)
    assert resp["error"] == 0



