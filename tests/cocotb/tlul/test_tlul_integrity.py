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
from cocotb.triggers import RisingEdge, ClockCycles, with_timeout

from coralnpu_test_utils.TileLinkULInterface import TileLinkULInterface, create_a_channel_req
from coralnpu_test_utils.secded_golden import get_cmd_intg, get_data_intg, get_rsp_intg


def create_d_channel_rsp(opcode,
                         data,
                         size,
                         source,
                         param=0,
                         sink=0,
                         error=False):
    """Creates a standard TileLink-UL D-channel response dictionary."""
    return {
        "opcode": opcode,
        "param": param,
        "size": size,
        "source": source,
        "sink": sink,
        "data": data,
        "error": error,
        "user": {
            "rsp_intg": 0,
            "data_intg": 0
        }
    }


async def setup_dut(dut):
    """Common setup for all tests."""
    clock = Clock(dut.clock, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await RisingEdge(dut.clock)


@cocotb.test()
async def test_request_integrity_gen(dut):
    """Test that the RequestIntegrityGen module generates correct integrity."""
    await setup_dut(dut)

    # Drive the input A-channel
    req = create_a_channel_req(address=0x1000,
                               data=0x112233445566778899aabbccddeeff00,
                               mask=0xFFFF,
                               width=128)
    dut.io_req_gen_a_i_valid.value = 1
    dut.io_req_gen_a_i_bits_opcode.value = req["opcode"]
    dut.io_req_gen_a_i_bits_param.value = req["param"]
    dut.io_req_gen_a_i_bits_size.value = req["size"]
    dut.io_req_gen_a_i_bits_source.value = req["source"]
    dut.io_req_gen_a_i_bits_address.value = req["address"]
    dut.io_req_gen_a_i_bits_mask.value = req["mask"]
    dut.io_req_gen_a_i_bits_data.value = req["data"]
    dut.io_req_gen_a_i_bits_user_cmd_intg.value = get_cmd_intg(req)
    dut.io_req_gen_a_i_bits_user_data_intg.value = get_data_intg(req["data"],
                                                                   width=128)
    dut.io_req_gen_a_i_bits_user_rsvd.value = 0
    dut.io_req_gen_a_i_bits_user_instr_type.value = 0

    # Signal that we are ready to accept the output.
    dut.io_req_gen_a_o_ready.value = 1

    # TODO: Timeout loop
    await RisingEdge(dut.clock)

    # Check the output A-channel
    assert dut.io_req_gen_a_o_valid.value
    assert dut.io_req_gen_a_o_bits_opcode.value == req["opcode"]
    assert dut.io_req_gen_a_o_bits_address.value == req["address"]
    assert dut.io_req_gen_a_o_bits_data.value == req["data"]

    assert dut.io_req_gen_a_o_bits_user_cmd_intg.value == get_cmd_intg(req)
    assert dut.io_req_gen_a_o_bits_user_data_intg.value == get_data_intg(
        req["data"], width=128)


@cocotb.test()
async def test_request_integrity_check(dut):
    """Test that the RequestIntegrityCheck module correctly identifies faults."""
    await setup_dut(dut)
    req = create_a_channel_req(address=0x1000,
                               data=0x112233445566778899aabbccddeeff00,
                               mask=0xFFFF,
                               width=128)

    # --- Transaction 1: Correct integrity ---
    dut.io_req_check_a_i_valid.value = 1
    dut.io_req_check_a_i_bits_opcode.value = req["opcode"]
    dut.io_req_check_a_i_bits_param.value = req["param"]
    dut.io_req_check_a_i_bits_size.value = req["size"]
    dut.io_req_check_a_i_bits_source.value = req["source"]
    dut.io_req_check_a_i_bits_address.value = req["address"]
    dut.io_req_check_a_i_bits_mask.value = req["mask"]
    dut.io_req_check_a_i_bits_data.value = req["data"]
    dut.io_req_check_a_i_bits_user_cmd_intg.value = get_cmd_intg(req)
    dut.io_req_check_a_i_bits_user_data_intg.value = get_data_intg(req["data"],
                                                                   width=128)
    dut.io_req_check_a_i_bits_user_rsvd.value = 0
    dut.io_req_check_a_i_bits_user_instr_type.value = 0

    for _ in range(10):
        if dut.io_req_check_a_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_req_check_a_i_ready"

    await RisingEdge(dut.clock)
    dut.io_req_check_a_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert not dut.io_req_check_fault.value
    await ClockCycles(dut.clock, 5)  # Delay for clarity in logs/waves

    # --- Transaction 2: Command integrity fault ---
    dut.io_req_check_a_i_valid.value = 1
    dut.io_req_check_a_i_bits_data.value = req["data"]
    correct_cmd_intg = get_cmd_intg(req)
    dut.io_req_check_a_i_bits_user_cmd_intg.value = ~correct_cmd_intg & 0x7F

    for _ in range(10):
        if dut.io_req_check_a_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_req_check_a_i_ready"

    await RisingEdge(dut.clock)
    dut.io_req_check_a_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert dut.io_req_check_fault.value
    await ClockCycles(dut.clock, 5)  # Delay for clarity in logs/waves

    # --- Transaction 3: Data integrity fault ---
    dut.io_req_check_a_i_valid.value = 1
    dut.io_req_check_a_i_bits_data.value = req["data"]
    dut.io_req_check_a_i_bits_user_cmd_intg.value = get_cmd_intg(
        req)  # Restore cmd_intg
    correct_data_intg = get_data_intg(req["data"], width=128)
    dut.io_req_check_a_i_bits_user_data_intg.value = ~correct_data_intg & 0x7F

    for _ in range(10):
        if dut.io_req_check_a_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_req_check_a_i_ready"

    await RisingEdge(dut.clock)
    dut.io_req_check_a_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert dut.io_req_check_fault.value
    await RisingEdge(dut.clock)


@cocotb.test()
async def test_response_integrity_gen(dut):
    """Test that the ResponseIntegrityGen module generates correct integrity."""
    await setup_dut(dut)

    # Drive the input D-channel
    rsp = create_d_channel_rsp(opcode=1,
                               data=0x112233445566778899aabbccddeeff00,
                               size=4,
                               source=1)
    dut.io_rsp_gen_d_i_valid.value = 1
    dut.io_rsp_gen_d_i_bits_opcode.value = rsp["opcode"]
    dut.io_rsp_gen_d_i_bits_param.value = rsp["param"]
    dut.io_rsp_gen_d_i_bits_size.value = rsp["size"]
    dut.io_rsp_gen_d_i_bits_source.value = rsp["source"]
    dut.io_rsp_gen_d_i_bits_sink.value = rsp["sink"]
    dut.io_rsp_gen_d_i_bits_data.value = rsp["data"]
    dut.io_rsp_gen_d_i_bits_error.value = rsp["error"]

    # Signal that we are ready to accept the output.
    dut.io_rsp_gen_d_o_ready.value = 1

    await RisingEdge(dut.clock)

    # Check the output D-channel
    assert dut.io_rsp_gen_d_o_valid.value
    assert dut.io_rsp_gen_d_o_bits_opcode.value == rsp["opcode"]
    assert dut.io_rsp_gen_d_o_bits_data.value == rsp["data"]

    assert dut.io_rsp_gen_d_o_bits_user_rsp_intg.value == get_rsp_intg(rsp)
    assert dut.io_rsp_gen_d_o_bits_user_data_intg.value == get_data_intg(
        rsp["data"], width=128)


@cocotb.test()
async def test_response_integrity_check(dut):
    """Test that the ResponseIntegrityCheck module correctly identifies faults."""
    await setup_dut(dut)
    rsp = create_d_channel_rsp(opcode=1,
                               data=0x112233445566778899aabbccddeeff00,
                               size=4,
                               source=1)

    # --- Transaction 1: Correct integrity ---
    dut.io_rsp_check_d_i_valid.value = 1
    dut.io_rsp_check_d_i_bits_opcode.value = rsp["opcode"]
    dut.io_rsp_check_d_i_bits_param.value = rsp["param"]
    dut.io_rsp_check_d_i_bits_size.value = rsp["size"]
    dut.io_rsp_check_d_i_bits_source.value = rsp["source"]
    dut.io_rsp_check_d_i_bits_sink.value = rsp["sink"]
    dut.io_rsp_check_d_i_bits_data.value = rsp["data"]
    dut.io_rsp_check_d_i_bits_error.value = rsp["error"]
    dut.io_rsp_check_d_i_bits_user_rsp_intg.value = get_rsp_intg(rsp)
    dut.io_rsp_check_d_i_bits_user_data_intg.value = get_data_intg(rsp["data"],
                                                                   width=128)

    for _ in range(10):
        if dut.io_rsp_check_d_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_rsp_check_d_i_ready"
    await RisingEdge(dut.clock)
    dut.io_rsp_check_d_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert not dut.io_rsp_check_fault.value
    await ClockCycles(dut.clock, 5)  # Delay for clarity in logs/waves

    # --- Transaction 2: Response integrity fault ---
    dut.io_rsp_check_d_i_valid.value = 1
    dut.io_rsp_check_d_i_bits_data.value = rsp["data"]  # Keep data same
    correct_rsp_intg = get_rsp_intg(rsp)
    dut.io_rsp_check_d_i_bits_user_rsp_intg.value = ~correct_rsp_intg & 0x7F

    for _ in range(10):
        if dut.io_rsp_check_d_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_rsp_check_d_i_ready"
    await RisingEdge(dut.clock)
    dut.io_rsp_check_d_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert dut.io_rsp_check_fault.value
    await ClockCycles(dut.clock, 5)  # Delay for clarity in logs/waves

    # --- Transaction 3: Data integrity fault ---
    dut.io_rsp_check_d_i_valid.value = 1
    dut.io_rsp_check_d_i_bits_data.value = rsp["data"]
    dut.io_rsp_check_d_i_bits_user_rsp_intg.value = get_rsp_intg(
        rsp)  # Restore rsp_intg
    correct_data_intg = get_data_intg(rsp["data"], width=128)
    dut.io_rsp_check_d_i_bits_user_data_intg.value = ~correct_data_intg & 0x7F

    for _ in range(10):
        if dut.io_rsp_check_d_i_ready.value:
            break
        await RisingEdge(dut.clock)
    else:
        assert False, "Timeout waiting for dut.io_rsp_check_d_i_ready"
    await RisingEdge(dut.clock)
    dut.io_rsp_check_d_i_valid.value = 0
    await RisingEdge(dut.clock)
    assert dut.io_rsp_check_fault.value
    await RisingEdge(dut.clock)
