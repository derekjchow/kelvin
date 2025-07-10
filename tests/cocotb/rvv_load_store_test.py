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
import numpy as np

from kelvin_test_utils.sim_test_fixture import Fixture


async def vector_load_store(
        dut,
        elf_name: str,
        dtype,
        in_size: int,
        out_size: int,
        pattern: list[int],
):
    """RVV load-store test template.

    Each test performs some kind of patterned copy from `in_buf` to `out_buf`.
    """
    fixture = await Fixture.Create(dut)
    await fixture.load_elf_and_lookup_symbols(
        '../tests/cocotb/rvv/load_store/' + elf_name,
        ['in_buf', 'out_buf'],
    )

    min_value = np.iinfo(dtype).min
    max_value = np.iinfo(dtype).max + 1  # One above.
    rng = np.random.default_rng()
    input_data = rng.integers(min_value, max_value, in_size, dtype=dtype)
    expected_outputs = input_data[pattern]
    sbz = np.zeros(out_size - len(pattern), dtype=dtype)
    expected_outputs = np.concat((expected_outputs, sbz))

    await fixture.write('in_buf', input_data)
    await fixture.write('out_buf', np.zeros([out_size], dtype=dtype))

    await fixture.run_to_halt()

    actual_outputs = (await fixture.read(
        'out_buf', out_size * np.dtype(dtype).itemsize)).view(dtype)
    debug_msg = str({
        'input': input_data,
        'expected': expected_outputs,
        'actual': actual_outputs,
    })

    assert (actual_outputs == expected_outputs).all(), debug_msg

async def vector_load_indexed(
        dut,
        elf_name: str,
        dtype,
):
    """RVV load-store test template for indexed loads.

    Each test performs a gather operation and writes the result to an output.
    """
    fixture = await Fixture.Create(dut)
    await fixture.load_elf_and_lookup_symbols(
        '../tests/cocotb/rvv/load_store/' + elf_name,
        ['input_indices', 'input_data', 'output_data'],
    )

    indices_count = 16 // np.dtype(dtype).itemsize
    in_data_count = 4096 // np.dtype(dtype).itemsize
    out_data_count = 16 // np.dtype(dtype).itemsize

    min_value = np.iinfo(dtype).min
    max_value = np.iinfo(dtype).max + 1  # One above.
    rng = np.random.default_rng()
    input_data = rng.integers(min_value, max_value, in_data_count, dtype=dtype)
    input_indices = rng.integers(
        0, min(max_value, in_data_count-1), indices_count, dtype=dtype)

    expected_outputs = np.take(input_data, input_indices)

    await fixture.write('input_data', input_data)
    await fixture.write('input_indices', input_indices)
    await fixture.write('output_data', np.zeros([out_data_count], dtype=dtype))

    await fixture.run_to_halt()

    actual_outputs = (await fixture.read(
        'output_data', out_data_count * np.dtype(dtype).itemsize)).view(dtype)

    assert (actual_outputs == expected_outputs).all()

async def vector_store_indexed(
        dut,
        elf_name: str,
        dtype,
):
    """RVV load-store test template for indexed stores.

    Each test loads indices and data and performs a scatter operation.
    """
    fixture = await Fixture.Create(dut)
    await fixture.load_elf_and_lookup_symbols(
        '../tests/cocotb/rvv/load_store/' + elf_name,
        ['input_indices', 'input_data', 'output_data'],
    )

    indices_count = 16 // np.dtype(dtype).itemsize
    in_data_count = 16 // np.dtype(dtype).itemsize
    out_data_count = 4096 // np.dtype(dtype).itemsize

    min_value = np.iinfo(dtype).min
    max_value = np.iinfo(dtype).max + 1  # One above.
    rng = np.random.default_rng()
    input_data = rng.integers(min_value, max_value, in_data_count, dtype=dtype)
    input_indices = rng.integers(
        0, min(max_value, out_data_count-1), indices_count, dtype=dtype)
    original_outputs = rng.integers(
        min_value, max_value, out_data_count, dtype=dtype)

    await fixture.write('input_data', input_data)
    await fixture.write('input_indices', input_indices)
    await fixture.write('output_data', original_outputs)

    expected_outputs = np.copy(original_outputs)
    for idx, data in zip(input_indices, input_data):
      expected_outputs[idx] = data

    await fixture.run_to_halt()

    actual_outputs = (await fixture.read(
        'output_data', out_data_count * np.dtype(dtype).itemsize)).view(dtype)

    assert (actual_outputs == expected_outputs).all()

@cocotb.test()
async def load8_stride2_m1(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load8_stride2_m1.elf',
        dtype = np.uint8,
        in_size = 32,
        out_size = 16,
        pattern = list(range(0, 31, 2)),
    )

@cocotb.test()
async def load8_stride2_m1_partial(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load8_stride2_m1_partial.elf',
        dtype = np.uint8,
        in_size = 32,
        out_size = 16,
        pattern = list(range(0, 29, 2)),
    )

@cocotb.test()
async def load8_stride2_mf4(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load8_stride2_mf4.elf',
        dtype = np.uint8,
        in_size = 32,
        out_size = 16,
        pattern = [0, 2, 4, 6],
    )

@cocotb.test()
async def load16_stride4_m1(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load16_stride4_m1.elf',
        dtype = np.uint16,
        in_size = 16,
        out_size = 8,
        pattern = list(range(0, 15, 2)),
    )

@cocotb.test()
async def load16_stride4_m1_partial(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load16_stride4_m1_partial.elf',
        dtype = np.uint16,
        in_size = 16,
        out_size = 8,
        pattern = list(range(0, 13, 2)),
    )

@cocotb.test()
async def load16_stride4_mf2(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load16_stride4_mf2.elf',
        dtype = np.uint16,
        in_size = 16,
        out_size = 8,
        pattern = [0, 2, 4, 6],
    )

@cocotb.test()
async def load32_stride8_m1(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load32_stride8_m1.elf',
        dtype = np.uint32,
        in_size = 8,
        out_size = 4,
        pattern = [0, 2, 4, 6],
    )

@cocotb.test()
async def load32_stride8_m1_partial(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load32_stride8_m1_partial.elf',
        dtype = np.uint32,
        in_size = 8,
        out_size = 4,
        pattern = [0, 2, 4],
    )

@cocotb.test()
async def load_store8_unit_m2(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load_store8_unit_m2.elf',
        dtype = np.uint8,
        in_size = 64,
        out_size = 64,
        pattern = list(range(0, 32)),
    )

@cocotb.test()
async def load8_indexed_m1(dut):
    await vector_load_indexed(
        dut = dut,
        elf_name = 'load8_indexed_m1.elf',
        dtype = np.uint8,
    )

@cocotb.test()
async def store8_indexed_m1(dut):
    await vector_store_indexed(
        dut = dut,
        elf_name = 'store8_indexed_m1.elf',
        dtype = np.uint8,
    )
