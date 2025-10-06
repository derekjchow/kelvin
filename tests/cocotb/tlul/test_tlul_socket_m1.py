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
import math
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
async def test_arbitration(dut):
    """Verify requests are arbitrated and responses are routed correctly."""
    await setup_dut(dut)

    M = 0
    while hasattr(dut, f"io_tl_h_{M}_a_valid"):
        M += 1

    StIdW = math.ceil(math.log2(M))

    host_ifs = [
        TileLinkULInterface(dut, host_if_name=f"io_tl_h_{i}") for i in range(M)
    ]
    device_if = TileLinkULInterface(dut, device_if_name="io_tl_d")

    reqs = {
        i:
        create_a_channel_req(address=0x1000 + i * 0x100,
                             data=0x11223344 + i,
                             mask=0xF,
                             source=i)
        for i in range(M)
    }
    received_reqs = {}

    async def device_responder():
        while len(received_reqs) < M:
            req_seen = await device_if.device_get_request()
            host_index = req_seen["source"].to_unsigned() & ((1 << StIdW) - 1)
            assert req_seen["source"].to_unsigned(
            ) >> StIdW == reqs[host_index]["source"]
            received_reqs[host_index] = req_seen
            await device_if.device_respond(opcode=0,
                                           param=0,
                                           size=req_seen["size"],
                                           source=req_seen["source"])

    device_task = cocotb.start_soon(device_responder())

    for i in range(M):
        await host_ifs[i].host_put(reqs[i])

    for i in range(M):
        response = await host_ifs[i].host_get_response()
        assert response["source"] == reqs[i]["source"]

    await with_timeout(device_task, 1000)
