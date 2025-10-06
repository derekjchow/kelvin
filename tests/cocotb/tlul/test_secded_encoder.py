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
from cocotb.triggers import RisingEdge, ClockCycles
import random

from coralnpu_test_utils.secded_golden import get_data_intg, secded_inv_39_32_enc, secded_inv_64_57_enc


async def setup_dut(dut):
    """Common setup for all tests."""
    clock = Clock(dut.clock, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    await ClockCycles(dut.clock, 2)
    dut.reset.value = 0
    await RisingEdge(dut.clock)


@cocotb.test()
async def test_secded_encoder(dut):
    """Test that the SecdedEncoder module matches the golden model for random data."""
    await setup_dut(dut)

    # Determine the data width from the DUT.
    data_width = len(dut.io_data_i)
    num_iterations = 1000

    for i in range(num_iterations):
        # Generate a random integer of the correct width.
        random_data = random.getrandbits(data_width)

        # Drive the random data into the DUT.
        dut.io_data_i.value = random_data
        await RisingEdge(dut.clock)

        # Get the ECC from the DUT.
        dut_ecc = dut.io_ecc_o.value

        # Calculate the expected ECC using the golden model.
        if data_width == 32:
            golden_ecc = secded_inv_39_32_enc(random_data)
        elif data_width == 57:
            golden_ecc = secded_inv_64_57_enc(random_data)
        elif data_width == 128:
            golden_ecc = get_data_intg(random_data, width=data_width)
        else:
            raise ValueError(f"Unsupported data width: {data_width}")

        # Compare the DUT's output with the golden model.
        assert dut_ecc == golden_ecc, f"Mismatch on iteration {i}: data={hex(random_data)}, dut_ecc={hex(dut_ecc)}, golden_ecc={hex(golden_ecc)}"

    dut._log.info(
        f"Successfully compared {num_iterations} random data values for data width {data_width}."
    )
