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


def _get_math_result(x: np.array,
                     y: np.array,
                     symbol: str):
    if symbol == 'add':
        return np.add(x, y)
    elif symbol == 'sub':
        return np.subtract(x, y)
    elif symbol == 'mul':
        return np.multiply(x,y)
    return 0 # todo raise error

async def arithmetic_test(dut,
                          dtype,
                          elf_name: str,
                          math_op: str,
                          num_bytes: int):

    """RVV arithmetic test template.

    Each test performs a math op loading `in_buf_1` and `in_buf_2` and storing the output to `out_buf`.
    """
    fixture = await Fixture.Create(dut)
    await fixture.load_elf_and_lookup_symbols(
        '../tests/cocotb/rvv/arithmetics/' + elf_name,
        ['in_buf_1', 'in_buf_2', 'out_buf'],
    )

    num_values = int(num_bytes / np.dtype(dtype).itemsize)
    min_value = np.iinfo(dtype).min
    max_value = np.iinfo(dtype).max + 1  # One above.
    input_1 = np.random.randint(min_value, max_value, num_values, dtype=dtype)
    input_2 = np.random.randint(min_value, max_value, num_values, dtype=dtype)
    expected_output = np.asarray(_get_math_result(input_1, input_2, math_op), dtype=dtype)

    await fixture.write('in_buf_1', input_1)
    await fixture.write('in_buf_2', input_2)
    await fixture.write('out_buf', np.zeros([num_values], dtype=dtype))

    await fixture.run_to_halt()

    actual_output = (await fixture.read('out_buf', num_bytes)).view(dtype)
    debug_msg = str({
        'input_1': input_1,
        'input_2': input_2,
        'expected': expected_output,
        'actual': actual_output,
    })

    assert (actual_output == expected_output).all(), debug_msg

@cocotb.test()
async def add_i8_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int8,
                          elf_name = 'rvv_add_i8_m1.elf',
                          math_op = 'add',
                          num_bytes = 16)

@cocotb.test()
async def add_i16_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int16,
                          elf_name = 'rvv_add_i16_m1.elf',
                          math_op = 'add',
                          num_bytes = 16)

@cocotb.test()
async def add_i32_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int32,
                          elf_name = 'rvv_add_i32_m1.elf',
                          math_op = 'add',
                          num_bytes = 16)

@cocotb.test()
async def sub_i8_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int8,
                          elf_name = 'rvv_sub_i8_m1.elf',
                          math_op = 'sub',
                          num_bytes = 16)

@cocotb.test()
async def sub_i16_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int16,
                          elf_name = 'rvv_sub_i16_m1.elf',
                          math_op = 'sub',
                          num_bytes = 16)

@cocotb.test()
async def sub_i32_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int32,
                          elf_name = 'rvv_sub_i32_m1.elf',
                          math_op = 'sub',
                          num_bytes = 16)

@cocotb.test()
async def mul_i8_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int8,
                          elf_name = 'rvv_mul_i8_m1.elf',
                          math_op = 'mul',
                          num_bytes = 16)

@cocotb.test()
async def mul_i16_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int16,
                          elf_name = 'rvv_mul_i16_m1.elf',
                          math_op = 'mul',
                          num_bytes = 16)

@cocotb.test()
async def mul_i32_m1(dut):
    await arithmetic_test(dut = dut,
                          dtype = np.int32,
                          elf_name = 'rvv_mul_i32_m1.elf',
                          math_op = 'mul',
                          num_bytes = 16)