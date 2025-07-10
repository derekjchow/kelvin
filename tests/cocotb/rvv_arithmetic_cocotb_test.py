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
import tqdm
import re
import numpy as np

from bazel_tools.tools.python.runfiles import runfiles
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
    elif symbol == 'div':
        orig_settings = np.seterr(divide='ignore')
        divide_output = np.divide(x, y)
        np.seterr(**orig_settings)

        return divide_output
    return 0 # todo raise error

async def arithmetic_m1_vanilla_ops_test(dut,
                          dtypes,
                          math_ops: str,
                          num_bytes: int):

    """RVV arithmetic test template.

    Each test performs a math op loading `in_buf_1` and `in_buf_2` and storing the output to `out_buf`.
    """
    str_to_np_type ={
        "int8": np.int8,
        "int16": np.int16,
        "int32": np.int32,
        "uint8": np.uint8,
        "uint16": np.uint16,
        "uint32": np.uint32,
    }
    m1_vanilla_op_elfs = [f"rvv_{math_op}_{dtype}_m1.elf" for math_op in math_ops for dtype in dtypes]
    pattern_extract = re.compile("rvv_(.*)_(.*)_m1.elf")


    r = runfiles.Create()
    fixture = await Fixture.Create(dut)
    with tqdm.tqdm(m1_vanilla_op_elfs) as t:
        for elf_name in tqdm.tqdm(m1_vanilla_op_elfs):
            elf_path = r.Rlocation("kelvin_hw/tests/cocotb/rvv/arithmetics/" + elf_name)
            await fixture.load_elf_and_lookup_symbols(
                elf_path,
                ['in_buf_1', 'in_buf_2', 'out_buf'],
            )
            math_op, dtype = pattern_extract.match(elf_name).groups()
            np_type = str_to_np_type[dtype]
            num_values = int(num_bytes / np.dtype(np_type).itemsize)
            min_value = np.iinfo(np_type).min
            max_value = np.iinfo(np_type).max + 1  # One above.
            input_1 = np.random.randint(min_value, max_value, num_values, dtype=np_type)
            input_2 = np.random.randint(min_value, max_value, num_values, dtype=np_type)
            expected_output = np.asarray(_get_math_result(input_1, input_2, math_op), dtype=np_type)
            if math_op == "div":
                # riscv_vdiv clobbers divide by zero with -1
                # riscv_vdivu clobbers divide by zero with max value of SEW
                for idx, divisor in enumerate(input_2):
                    if divisor == 0 and dtype[:3] == "int":
                        expected_output[idx] = -1
                    elif  divisor == 0 and dtype[:4] == "uint":
                        expected_output[idx] = max_value - 1

            await fixture.write('in_buf_1', input_1)
            await fixture.write('in_buf_2', input_2)
            await fixture.write('out_buf', np.zeros([num_values], dtype=np_type))

            await fixture.run_to_halt()

            actual_output = (await fixture.read('out_buf', num_bytes)).view(np_type)
            debug_msg = str({
                'input_1': input_1,
                'input_2': input_2,
                'expected': expected_output,
                'actual': actual_output,
            })

            assert (actual_output == expected_output).all(), debug_msg

@cocotb.test()
async def arithmetic_m1_vanilla_ops(dut):
    await arithmetic_m1_vanilla_ops_test(dut = dut,
                          dtypes = ["int8", "int16", "int32", "uint8", "uint16", "uint32"],
                          math_ops = ["add", "sub", "mul", "div"],
                          num_bytes = 16)
