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
from cocotb.triggers import RisingEdge, ClockCycles

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req


async def setup_dut(dut):
    """Common setup for all tests."""
    h_clock = Clock(dut.io_clk_h_i, 10)
    d_clock = Clock(dut.io_clk_d_i, 13)  # Asymmetric clocks
    cocotb.start_soon(h_clock.start())
    cocotb.start_soon(d_clock.start())

    dut.io_rst_h_i.value = 1
    dut.io_rst_d_i.value = 1
    await ClockCycles(dut.io_clk_h_i, 2)
    await ClockCycles(dut.io_clk_d_i, 2)
    dut.io_rst_h_i.value = 0
    dut.io_rst_d_i.value = 0
    await RisingEdge(dut.io_clk_h_i)
    await RisingEdge(dut.io_clk_d_i)


@cocotb.test()
async def test_async_crossing(dut):
    """Verify requests are arbitrated and responses are routed correctly."""
    await setup_dut(dut)

    host_if = TileLinkULInterface(dut,
                                  host_if_name="io_tl_h",
                                  clock_name="io_clk_h_i",
                                  reset_name="io_rst_h_i")
    device_if = TileLinkULInterface(dut,
                                    device_if_name="io_tl_d",
                                    clock_name="io_clk_d_i",
                                    reset_name="io_rst_d_i")

    req = create_a_channel_req(address=0x1000,
                               data=0x11223344,
                               mask=0xF,
                               source=1)

    # Start a concurrent task to handle the device-side interaction
    async def device_responder():
        req_seen = await device_if.device_get_request()
        assert req_seen["source"] == req["source"]
        await device_if.device_respond(opcode=0,
                                       param=0,
                                       size=req_seen["size"],
                                       source=req_seen["source"])

    device_task = cocotb.start_soon(device_responder())

    # Send the request from the host
    await host_if.host_put(req)

    # Wait for the response on the host side
    response = await host_if.host_get_response()
    assert response["source"] == req["source"]

    # Wait for the device task to complete
    await device_task
