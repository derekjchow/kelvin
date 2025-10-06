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
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, with_timeout
import random

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req


async def setup_dut(dut):
    """Common setup for all tests."""
    clock = Clock(dut.clock, 10)
    cocotb.start_soon(clock.start())
    dut.reset.value = 1
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await RisingEdge(dut.clock)


@cocotb.test()
async def test_steering(dut):
    """Verify requests are steered to the correct device port."""
    await setup_dut(dut)

    N = 4  # This is hardcoded in the Chisel emitter for now
    host_if = TileLinkULInterface(dut, host_if_name="io_tl_h")
    device_ifs = [
        TileLinkULInterface(dut, device_if_name=f"io_tl_d_{i}")
        for i in range(N)
    ]

    async def device_responder(device_if, i):
        req_seen = await device_if.device_get_request()
        await device_if.device_respond(opcode=0,
                                       param=0,
                                       size=req_seen["size"],
                                       source=req_seen["source"])

    # Start all device responders
    for i in range(N):
        cocotb.start_soon(device_responder(device_ifs[i], i))

    for i in range(N):
        dut.io_dev_select_i.value = i
        req = create_a_channel_req(address=0x1000 + i * 0x100,
                                   data=0x11223344 + i,
                                   mask=0xF,
                                   source=i)

        await host_if.host_put(req)
        response = await host_if.host_get_response()

        assert response["source"] == i
        # TODO(atv): Can we do this better?
        # Allow some time for the device responder to process the request
        await ClockCycles(dut.clock, 5)


@cocotb.test()
async def test_error_response(dut):
    """Verify error response for out-of-bounds dev_select."""
    await setup_dut(dut)

    N = 4  # This is hardcoded in the Chisel emitter for now
    host_if = TileLinkULInterface(dut, host_if_name="io_tl_h")

    # dev_select_i is NWD bits wide, where NWD = ceil(log2(N+1))
    # So, a value of N should be out of bounds and trigger an error
    dut.io_dev_select_i.value = N
    req = create_a_channel_req(address=0xBAD,
                               data=0xBAD,
                               mask=0xF,
                               source=(1 << 6) - 1)

    await host_if.host_put(req)
    response = await host_if.host_get_response()

    assert response["error"] == 1
    assert response["source"] == req["source"]
