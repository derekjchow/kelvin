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
from cocotb.triggers import RisingEdge, ClockCycles, Event

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req


async def setup_dut(dut):
    """Common setup for all tests."""
    cocotb.start_soon(Clock(dut.clock, 10, unit="us").start())

    dut.reset.value = 1
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await RisingEdge(dut.clock)


@cocotb.test()
async def test_passthrough_with_spare(dut):
    """Test basic data transfer and spare channels through the FIFO."""
    await setup_dut(dut)
    host_if = TileLinkULInterface(dut, host_if_name="io_host")
    device_if = TileLinkULInterface(dut, device_if_name="io_device")

    # Create a simple PutFullData request
    a_data = create_a_channel_req(address=0x1000,
                                  data=0x11223344,
                                  mask=0xF,
                                  width=32)
    spare_req_val = 1
    spare_rsp_val = 0

    # Create a concurrent task that acts as the device model
    async def device_model():
        # Wait for the request from the DUT (coming from the host)
        req = await device_if.device_get_request()

        # Verify the request is what we expect
        assert req["opcode"] == a_data["opcode"], f"Request opcode mismatch"
        assert req["param"] == a_data["param"], f"Request param mismatch"
        assert req["size"] == a_data["size"], f"Request size mismatch"
        assert req["source"] == a_data["source"], f"Request source mismatch"
        assert req["address"] == a_data["address"], f"Request address mismatch"
        assert req["mask"] == a_data["mask"], f"Request mask mismatch"
        assert req["data"] == a_data["data"], f"Request data mismatch"
        for field, value in a_data["user"].items():
            assert req["user"][
                field] == value, f"Request user.{field} mismatch"

        # Check spare request channel
        assert dut.io_spare_req_o.value == spare_req_val, "Spare request data mismatch"

        # Drive spare response channel before sending the main response
        dut.io_spare_rsp_i.value = spare_rsp_val

        # Send a simple AccessAck response
        await device_if.device_respond(
            opcode=0,  # AccessAck
            param=0,
            size=req["size"],
            source=req["source"])

    # Start the device model task
    device_task = cocotb.start_soon(device_model())

    # Drive spare request channel before sending the main request
    dut.io_spare_req_i.value = spare_req_val

    # Drive the transaction from the host side
    await host_if.host_put(a_data)

    # Wait for the response on the host side
    response = await host_if.host_get_response()

    # Verify the response
    assert response["opcode"] == 0, "Response opcode mismatch"
    assert response["param"] == 0, "Response param mismatch"
    assert response["size"] == a_data["size"], "Response size mismatch"
    assert response["source"] == a_data["source"], "Response source mismatch"
    assert response["sink"] == 0, "Response sink mismatch"
    assert response["data"] == 0, "Response data mismatch"
    assert response["error"] == 0, "Response error mismatch"
    assert response["user"]["rsp_intg"] != 0, "Response user.rsp_intg should not be zero"
    assert response["user"]["data_intg"] != 0, "Response user.data_intg should not be zero"

    # Check spare response channel
    assert dut.io_spare_rsp_o.value == spare_rsp_val, "Spare response data mismatch"

    # Ensure the device model task completed successfully
    await device_task
