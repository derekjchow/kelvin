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
import os

from bazel_tools.tools.python.runfiles import runfiles
from coralnpu_test_utils.sim_test_fixture import Fixture

STR_TO_NP_TYPE = {
    "int8": np.int8,
    "int16": np.int16,
    "int32": np.int32,
    "uint8": np.uint8,
    "uint16": np.uint16,
    "uint32": np.uint32,
}


def _get_math_result(x: np.array, y: np.array, symbol: str, dtype=None):
    if symbol == 'add':
        return np.add(x, y, dtype=dtype)
    elif symbol == 'sub':
        return np.subtract(x, y, dtype=dtype)
    elif symbol == 'mul':
        return np.multiply(x, y, dtype=dtype)
    elif symbol == 'div':
        orig_settings = np.seterr(divide='ignore')
        divide_output = np.divide(x, y, dtype=dtype)
        np.seterr(**orig_settings)
        return divide_output
    elif symbol == 'redsum':
        return y[0] + np.add.reduce(x)
    elif symbol == 'redmin':
        return np.min(np.concatenate((x, y)))
    elif symbol == 'redmax':
        return np.max(np.concatenate((x, y)))
    raise ValueError(f"Unsupported math symbol: {symbol}")


async def arithmetic_m1_vanilla_ops_test(dut, dtypes, math_ops: str,
                                         num_bytes: int):
    """RVV arithmetic test template.

    Each test performs a math op loading `in_buf_1` and `in_buf_2` and storing the output to `out_buf`.
    """
    m1_vanilla_op_elfs = [
        f"rvv_{math_op}_{dtype}_m1.elf" for math_op in math_ops
        for dtype in dtypes
    ]
    pattern_extract = re.compile("rvv_(.*)_(.*)_m1.elf")

    r = runfiles.Create()
    fixture = await Fixture.Create(dut)
    with tqdm.tqdm(m1_vanilla_op_elfs) as t:
        for elf_name in tqdm.tqdm(m1_vanilla_op_elfs):
            t.set_postfix({"binary": os.path.basename(elf_name)})
            elf_path = r.Rlocation("coralnpu_hw/tests/cocotb/rvv/arithmetics/" +
                                   elf_name)
            await fixture.load_elf_and_lookup_symbols(
                elf_path,
                ['in_buf_1', 'in_buf_2', 'out_buf'],
            )
            math_op, dtype = pattern_extract.match(elf_name).groups()
            np_type = STR_TO_NP_TYPE[dtype]
            num_test_values = int(num_bytes / np.dtype(np_type).itemsize)
            min_value = np.iinfo(np_type).min
            max_value = np.iinfo(np_type).max + 1  # One above.
            input_1 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=np_type)
            input_2 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=np_type)
            expected_output = np.asarray(_get_math_result(
                input_1, input_2, math_op),
                                         dtype=np_type)
            if math_op == "div":
                # riscv_vdiv clobbers divide by zero with -1
                # riscv_vdivu clobbers divide by zero with max value of SEW
                for idx, divisor in enumerate(input_2):
                    if divisor == 0 and dtype[:3] == "int":
                        expected_output[idx] = -1
                    elif divisor == 0 and dtype[:4] == "uint":
                        expected_output[idx] = max_value - 1

            await fixture.write('in_buf_1', input_1)
            await fixture.write('in_buf_2', input_2)
            await fixture.write('out_buf',
                                np.zeros([num_test_values], dtype=np_type))

            await fixture.run_to_halt()

            actual_output = (await fixture.read('out_buf',
                                                num_bytes)).view(np_type)
            debug_msg = str({
                'input_1': input_1,
                'input_2': input_2,
                'expected': expected_output,
                'actual': actual_output,
            })

            assert (actual_output == expected_output).all(), debug_msg


@cocotb.test()
async def arithmetic_m1_vanilla_ops(dut):
    await arithmetic_m1_vanilla_ops_test(
        dut=dut,
        dtypes=["int8", "int16", "int32", "uint8", "uint16", "uint32"],
        math_ops=["add", "sub", "mul", "div"],
        num_bytes=16)


async def reduction_m1_vanilla_ops_test(dut, dtypes, math_ops: str,
                                        num_bytes: int):
    """RVV reduction test template.

    Each test performs a reduction op loading `in_buf_1` and storing the output to `out_buf`.
    """
    m1_vanilla_op_elfs = [
        f"rvv_{math_op}_{dtype}_m1.elf" for math_op in math_ops
        for dtype in dtypes
    ]
    pattern_extract = re.compile("rvv_(.*)_(.*)_m1.elf")

    r = runfiles.Create()
    fixture = await Fixture.Create(dut)
    with tqdm.tqdm(m1_vanilla_op_elfs) as t:
        for elf_name in tqdm.tqdm(m1_vanilla_op_elfs):
            t.set_postfix({"binary": os.path.basename(elf_name)})
            elf_path = r.Rlocation(
                f"coralnpu_hw/tests/cocotb/rvv/arithmetics/{elf_name}")
            await fixture.load_elf_and_lookup_symbols(
                elf_path,
                ['in_buf_1', 'scalar_input', 'out_buf'],
            )
            math_op, dtype = pattern_extract.match(elf_name).groups()
            np_type = STR_TO_NP_TYPE[dtype]
            itemsize = np.dtype(np_type).itemsize
            num_test_values = int(num_bytes / np.dtype(np_type).itemsize)
            min_value = np.iinfo(np_type).min
            max_value = np.iinfo(np_type).max + 1  # One above.
            input_1 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=np_type)
            input_2 = np.random.randint(min_value, max_value, 1, dtype=np_type)
            expected_output = np.asarray(_get_math_result(
                input_1, input_2, math_op),
                                         dtype=np_type)

            await fixture.write('in_buf_1', input_1)
            await fixture.write('scalar_input', input_2)
            await fixture.write('out_buf', np.zeros(1, dtype=np_type))
            await fixture.run_to_halt()

            actual_output = (await fixture.read('out_buf',
                                                itemsize)).view(np_type)
            debug_msg = str({
                'input_1': input_1,
                'input_2': input_2,
                'expected': expected_output,
                'actual': actual_output,
            })
            assert (actual_output == expected_output).all(), debug_msg


@cocotb.test()
async def reduction_m1_vanilla_ops(dut):
    await reduction_m1_vanilla_ops_test(
        dut=dut,
        dtypes=["int8", "int16", "int32", "uint8", "uint16", "uint32"],
        math_ops=["redsum", "redmin", "redmax"],
        num_bytes=16)


async def reduction_m1_failure_test(dut, dtypes, math_ops: str, num_bytes: int):
    """RVV reduction test template.

    Each test performs a reduction op loading `in_buf_1` and storing the output to `out_buf`.
    """
    m1_failure_op_elfs = [
        f"rvv_{math_op}_{dtype}_m1.elf" for math_op in math_ops
        for dtype in dtypes
    ]
    pattern_extract = re.compile("rvv_(.*)_(.*)_m1.elf")

    r = runfiles.Create()
    fixture = await Fixture.Create(dut)

    with tqdm.tqdm(m1_failure_op_elfs) as t:
        for elf_name in t:
            t.set_postfix({"binary": os.path.basename(elf_name)})
            elf_path = r.Rlocation(
                f"coralnpu_hw/tests/cocotb/rvv/arithmetics/{elf_name}")
            await fixture.load_elf_and_lookup_symbols(
                elf_path,
                ['in_buf_1', 'scalar_input', 'out_buf', 'vstart', 'vl',
                 'faulted', 'mcause'],
            )
            math_op, dtype = pattern_extract.match(elf_name).groups()
            np_type = STR_TO_NP_TYPE[dtype]
            itemsize = np.dtype(np_type).itemsize
            num_test_values = int(num_bytes / np.dtype(np_type).itemsize)

            min_value = np.iinfo(np_type).min
            max_value = np.iinfo(np_type).max + 1  # One above.
            input_1 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=np_type)
            input_2 = np.random.randint(min_value, max_value, 1, dtype=np_type)

            await fixture.write('in_buf_1', input_1)
            await fixture.write('scalar_input', input_2)
            await fixture.write('vstart', np.array([1], dtype=np.uint32))
            await fixture.write('out_buf', np.zeros(1, dtype=np_type))

            await fixture.run_to_halt()
            faulted = (await fixture.read('faulted', 4)).view(np.uint32)
            mcause = (await fixture.read('mcause', 4)).view(np.uint32)
            assert(faulted == True)
            assert(mcause == 0x2) # Invalid instruction


@cocotb.test()
async def reduction_m1_failure_ops(dut):
    await reduction_m1_failure_test(
        dut=dut,
        dtypes=["int8", "int16", "int32", "uint8", "uint16", "uint32"],
        math_ops=["redsum", "redmin", "redmax"],
        num_bytes=16)


async def _widen_math_ops_test_impl(
    dut,
    dtypes,
    math_ops: str,
    num_test_values: int = 256,
):
    """RVV widen arithmetic test template.

    Each test performs a widen math op on 256 random inputs and stores into output buffer.
    """
    widen_op_elfs = [
        f"rvv_widen_{math_op}_{in_dtype}_{out_dtype}.elf"
        for math_op in math_ops for in_dtype, out_dtype in dtypes
    ]
    pattern_extract = re.compile("rvv_widen_(.*)_(.*)_(.*).elf")

    r = runfiles.Create()
    fixture = await Fixture.Create(dut)
    with tqdm.tqdm(widen_op_elfs) as t:
        for elf_name in tqdm.tqdm(widen_op_elfs):
            t.set_postfix({"binary": os.path.basename(elf_name)})
            elf_path = r.Rlocation("coralnpu_hw/tests/cocotb/rvv/arithmetics/" +
                                   elf_name)
            await fixture.load_elf_and_lookup_symbols(
                elf_path,
                ['in_buf_1', 'in_buf_2', 'out_buf_widen'],
            )
            math_op, in_dtype, out_dtype = pattern_extract.match(
                elf_name).groups()
            in_np_type = STR_TO_NP_TYPE[in_dtype]
            out_np_type = STR_TO_NP_TYPE[out_dtype]

            min_value = np.iinfo(in_np_type).min
            max_value = np.iinfo(in_np_type).max + 1  # One above.
            input_1 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=in_np_type)
            input_2 = np.random.randint(min_value,
                                        max_value,
                                        num_test_values,
                                        dtype=in_np_type)
            expected_output = np.asarray(_get_math_result(input_1,
                                                          input_2,
                                                          math_op,
                                                          dtype=out_np_type),
                                         dtype=out_np_type)
            await fixture.write('in_buf_1', input_1)
            await fixture.write('in_buf_2', input_2)
            await fixture.write('out_buf_widen',
                                np.zeros([num_test_values], dtype=out_np_type))
            await fixture.run_to_halt()

            actual_output = (await fixture.read(
                'out_buf_widen',
                num_test_values *
                np.dtype(out_np_type).itemsize)).view(out_np_type)
            debug_msg = str({
                'input_1': input_1,
                'input_2': input_2,
                'expected': expected_output,
                'actual': actual_output,
            })

            assert (actual_output == expected_output).all(), debug_msg


@cocotb.test()
async def widen_math_ops_test_impl(dut):
    await _widen_math_ops_test_impl(dut=dut,
                                    dtypes=[['int8', 'int16'],
                                            ['int16', 'int32']],
                                    math_ops=['add', 'sub', 'mul'])


async def test_narrowing_math_op(
        dut,
        elf_name: str,
        cases: list[dict],  # keys: impl, vl, in_dtype, maxshift, vxs, saturate
):
    """RVV narrowing instructions test template.

    All these instructions narrow down the input vector elements into half
    width output elements, with:
    - a right shift (A or L, by immediate, scalar or vector)
    - an optional saturation (signed or unsigned accordingly)
      if saturation is selected, the shift result is rounded (see vxrm)
    """
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('coralnpu_hw/tests/cocotb/rvv/arithmetics/' + elf_name),
        [
            'impl', 'vl', 'shift_scalar',
            'buf8', 'buf16', 'buf32',
            'buf_shift8', 'buf_shift16'
        ] + list({c['impl'] for c in cases}),
    )

    rng = np.random.default_rng()
    for c in tqdm.tqdm(cases):
        impl = c['impl']
        vl = c['vl']
        in_dtype = c['in_dtype']
        maxshift = c['maxshift']
        vxs = c['vxs']
        saturate = c['saturate']
        if in_dtype == np.int16:
            out_dtype = np.int8
        elif in_dtype == np.uint16:
            out_dtype = np.uint8
        elif in_dtype == np.int32:
            out_dtype = np.int16
        elif in_dtype == np.uint32:
            out_dtype = np.uint16
        else:
            assert False, f"Unsupported in_dtype {in_dtype}"

        input_data = rng.integers(
            0, np.iinfo(in_dtype).max + 1, vl, dtype=in_dtype)
        shift_scalar = rng.integers(0, maxshift + 1, 1, dtype=np.uint32)[0]
        shifts = rng.integers(0, maxshift + 1, vl, dtype=out_dtype)
        if (vxs):
            shift_results = np.bitwise_right_shift(input_data, shift_scalar)
        else:
            shift_results = np.bitwise_right_shift(input_data, shifts)
        if saturate:
            shift_results = np.minimum(shift_results, np.iinfo(out_dtype).max)
            shift_results = np.maximum(shift_results, np.iinfo(out_dtype).min)
        expected_outputs = shift_results.astype(out_dtype)

        await fixture.write_ptr('impl', impl)
        await fixture.write_word('vl', vl)
        await fixture.write_word('shift_scalar', shift_scalar)
        if (in_dtype == np.int16) or (in_dtype == np.uint16):
            await fixture.write('buf16', input_data)
            await fixture.write('buf_shift8', shifts)
        elif (in_dtype == np.int32) or (in_dtype == np.uint32):
            await fixture.write('buf32', input_data)
            await fixture.write('buf_shift16', shifts)

        await fixture.run_to_halt()

        if (out_dtype == np.int8) or (out_dtype == np.uint8):
            actual_outputs = (await fixture.read('buf8', vl))
        elif (out_dtype == np.int16) or (out_dtype == np.uint16):
            actual_outputs = (await fixture.read('buf16', vl * 2))
        actual_outputs = actual_outputs.view(out_dtype)

        debug_msg = str({
            'impl': impl,
            'input': input_data,
            'shift_scalar': shift_scalar,
            'shifts': shifts,
            'expected': expected_outputs,
            'actual': actual_outputs,
        })
        assert (actual_outputs == expected_outputs).all(), debug_msg


@cocotb.test()
async def vnsra_test(dut):
    """Test vnsra usage accessible from intrinsics.

    This covers vncvt (signed).
    """
    def make_test_case(impl, vl, in_dtype, vxs):
        if in_dtype == np.int16:
            maxshift = 15
        elif in_dtype == np.int32:
            maxshift = 31
        else:
            assert False, "Unsupported in_dtype"
        return {
            'impl': impl,
            'vl': vl,
            'in_dtype': in_dtype,
            'maxshift': maxshift,
            'vxs': vxs,
            'saturate': False,
        }

    await test_narrowing_math_op(
        dut = dut,
        elf_name = 'vnsra_test.elf',
        cases = [
            # 32 to 16, vxv
            make_test_case('vnsra_wv_i16mf2', 4, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16mf2', 3, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m1', 8, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m1', 7, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m2', 16, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m2', 15, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m4', 32, np.int32, vxs=False),
            make_test_case('vnsra_wv_i16m4', 31, np.int32, vxs=False),
            # 32 to 16, vxs
            make_test_case('vnsra_wx_i16mf2', 4, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16mf2', 3, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m1', 8, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m1', 7, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m2', 16, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m2', 15, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m4', 32, np.int32, vxs=True),
            make_test_case('vnsra_wx_i16m4', 31, np.int32, vxs=True),
            # 16 to 8, vxv
            make_test_case('vnsra_wv_i8mf4', 4, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8mf4', 3, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8mf2', 8, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8mf2', 7, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m1', 16, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m1', 15, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m2', 32, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m2', 31, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m4', 64, np.int16, vxs=False),
            make_test_case('vnsra_wv_i8m4', 63, np.int16, vxs=False),
            # 16 to 8, vxv
            make_test_case('vnsra_wx_i8mf4', 4, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8mf4', 3, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8mf2', 8, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8mf2', 7, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m1', 16, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m1', 15, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m2', 32, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m2', 31, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m4', 64, np.int16, vxs=True),
            make_test_case('vnsra_wx_i8m4', 63, np.int16, vxs=True),
        ],
    )


@cocotb.test()
async def vnsrl_test(dut):
    """Test vnsrl usage accessible from intrinsics.

    This covers vncvt (unsigned).
    """
    def make_test_case(impl, vl, in_dtype, vxs):
        if in_dtype == np.uint16:
            maxshift = 15
        elif in_dtype == np.uint32:
            maxshift = 31
        else:
            assert False, "Unsupported in_dtype"
        return {
            'impl': impl,
            'vl': vl,
            'in_dtype': in_dtype,
            'maxshift': maxshift,
            'vxs': vxs,
            'saturate': False,
        }

    await test_narrowing_math_op(
        dut = dut,
        elf_name = 'vnsrl_test.elf',
        cases = [
            # 32 to 16, vxv
            make_test_case('vnsrl_wv_u16mf2', 4, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16mf2', 3, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m1', 8, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m1', 7, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m2', 16, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m2', 15, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m4', 32, np.uint32, vxs=False),
            make_test_case('vnsrl_wv_u16m4', 31, np.uint32, vxs=False),
            # 32 to 16, vxs
            make_test_case('vnsrl_wx_u16mf2', 4, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16mf2', 3, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m1', 8, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m1', 7, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m2', 16, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m2', 15, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m4', 32, np.uint32, vxs=True),
            make_test_case('vnsrl_wx_u16m4', 31, np.uint32, vxs=True),
            # 16 to 8, vxv
            make_test_case('vnsrl_wv_u8mf4', 4, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8mf4', 3, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8mf2', 8, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8mf2', 7, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m1', 16, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m1', 15, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m2', 32, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m2', 31, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m4', 64, np.uint16, vxs=False),
            make_test_case('vnsrl_wv_u8m4', 63, np.uint16, vxs=False),
            # 16 to 8, vxv
            make_test_case('vnsrl_wx_u8mf4', 4, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8mf4', 3, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8mf2', 8, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8mf2', 7, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m1', 16, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m1', 15, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m2', 32, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m2', 31, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m4', 64, np.uint16, vxs=True),
            make_test_case('vnsrl_wx_u8m4', 63, np.uint16, vxs=True),
        ],
    )


@cocotb.test()
async def vnclip_test(dut):
    """Test vnclip usage accessible from intrinsics."""
    # TODO(davidgao): test different vxrm here too.
    def make_test_case(impl, vl, in_dtype, vxs):
        if in_dtype == np.int16:
            maxshift = 15
        elif in_dtype == np.int32:
            maxshift = 31
        else:
            assert False, "Unsupported in_dtype"
        return {
            'impl': impl,
            'vl': vl,
            'in_dtype': in_dtype,
            'maxshift': maxshift,
            'vxs': vxs,
            'saturate': True,
        }

    await test_narrowing_math_op(
        dut = dut,
        elf_name = 'vnclip_test.elf',
        cases = [
            # 32 to 16, vxv
            make_test_case('vnclip_wv_i16mf2', 4, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16mf2', 3, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m1', 8, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m1', 7, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m2', 16, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m2', 15, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m4', 32, np.int32, vxs=False),
            make_test_case('vnclip_wv_i16m4', 31, np.int32, vxs=False),
            # 32 to 16, vxs
            make_test_case('vnclip_wx_i16mf2', 4, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16mf2', 3, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m1', 8, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m1', 7, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m2', 16, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m2', 15, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m4', 32, np.int32, vxs=True),
            make_test_case('vnclip_wx_i16m4', 31, np.int32, vxs=True),
            # 16 to 8, vxv
            make_test_case('vnclip_wv_i8mf4', 4, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8mf4', 3, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8mf2', 8, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8mf2', 7, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m1', 16, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m1', 15, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m2', 32, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m2', 31, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m4', 64, np.int16, vxs=False),
            make_test_case('vnclip_wv_i8m4', 63, np.int16, vxs=False),
            # 16 to 8, vxv
            make_test_case('vnclip_wx_i8mf4', 4, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8mf4', 3, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8mf2', 8, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8mf2', 7, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m1', 16, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m1', 15, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m2', 32, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m2', 31, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m4', 64, np.int16, vxs=True),
            make_test_case('vnclip_wx_i8m4', 63, np.int16, vxs=True),
        ],
    )


@cocotb.test()
async def vnclipu_test(dut):
    """Test vnclipu usage accessible from intrinsics."""
    # TODO(davidgao): test different vxrm here too.
    def make_test_case(impl, vl, in_dtype, vxs):
        if in_dtype == np.uint16:
            maxshift = 15
        elif in_dtype == np.uint32:
            maxshift = 31
        else:
            assert False, "Unsupported in_dtype"
        return {
            'impl': impl,
            'vl': vl,
            'in_dtype': in_dtype,
            'maxshift': maxshift,
            'vxs': vxs,
            'saturate': True,
        }

    await test_narrowing_math_op(
        dut = dut,
        elf_name = 'vnclipu_test.elf',
        cases = [
            # 32 to 16, vxv
            make_test_case('vnclipu_wv_u16mf2', 4, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16mf2', 3, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m1', 8, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m1', 7, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m2', 16, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m2', 15, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m4', 32, np.uint32, vxs=False),
            make_test_case('vnclipu_wv_u16m4', 31, np.uint32, vxs=False),
            # 32 to 16, vxs
            make_test_case('vnclipu_wx_u16mf2', 4, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16mf2', 3, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m1', 8, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m1', 7, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m2', 16, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m2', 15, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m4', 32, np.uint32, vxs=True),
            make_test_case('vnclipu_wx_u16m4', 31, np.uint32, vxs=True),
            # 16 to 8, vxv
            make_test_case('vnclipu_wv_u8mf4', 4, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8mf4', 3, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8mf2', 8, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8mf2', 7, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m1', 16, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m1', 15, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m2', 32, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m2', 31, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m4', 64, np.uint16, vxs=False),
            make_test_case('vnclipu_wv_u8m4', 63, np.uint16, vxs=False),
            # 16 to 8, vxv
            make_test_case('vnclipu_wx_u8mf4', 4, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8mf4', 3, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8mf2', 8, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8mf2', 7, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m1', 16, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m1', 15, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m2', 32, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m2', 31, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m4', 64, np.uint16, vxs=True),
            make_test_case('vnclipu_wx_u8m4', 63, np.uint16, vxs=True),
        ],
    )

def reference_sadd(lhs, rhs):
    dtype = lhs.dtype
    return np.clip(lhs.astype(np.int64) + rhs,
                   np.iinfo(dtype).min,
                   np.iinfo(dtype).max)


def reference_ssub(lhs, rhs):
    dtype = lhs.dtype
    return np.clip(lhs.astype(np.int64) - rhs,
                   np.iinfo(dtype).min,
                   np.iinfo(dtype).max)


def reference_rsub(lhs, rhs):
    return rhs - lhs


def reference_mul(lhs, rhs):
    return lhs * rhs


def reference_vmulh(lhs, rhs):
    dtype = lhs.dtype
    bitwidth = np.iinfo(dtype).bits
    return ((lhs.astype(np.int64) * rhs) >> bitwidth) & \
            (~np.array([0], dtype=dtype))


def reference_sll(lhs, rhs):
    dtype = lhs.dtype
    mask = ~np.array([0], dtype=dtype)
    shift = rhs & ((np.dtype(dtype).itemsize * 8) - 1)
    return ((lhs << shift) & mask).astype(dtype)


def reference_srl(lhs, rhs):
    dtype = lhs.dtype
    mask = ~np.array([0], dtype=dtype)
    shift = rhs & ((np.dtype(dtype).itemsize * 8) - 1)
    return ((lhs >> shift) & mask).astype(dtype)


def reference_sra(lhs, rhs):
    shift = rhs & ((np.dtype(lhs.dtype).itemsize * 8) - 1)
    divisor = 1 << shift
    return lhs // divisor


# Test name, vl, vs1 type, xs2 type, vd type
SAME_TYPE_TEST_CASES = [
    ("test_i8_mf4",   4, np.int8,  np.int8,  np.int8),
    ("test_i8_mf2",   8, np.int8,  np.int8,  np.int8),
    ("test_i8_m1",   16, np.int8,  np.int8,  np.int8),
    ("test_i8_m2",   32, np.int8,  np.int8,  np.int8),
    ("test_i8_m4",   64, np.int8,  np.int8,  np.int8),
    ("test_i8_m8",  128, np.int8,  np.int8,  np.int8),
    ("test_i16_mf2",  4, np.int16, np.int16, np.int16),
    ("test_i16_m1",   8, np.int16, np.int16, np.int16),
    ("test_i16_m2",  16, np.int16, np.int16, np.int16),
    ("test_i16_m4",  32, np.int16, np.int16, np.int16),
    ("test_i16_m8",  64, np.int16, np.int16, np.int16),
    ("test_i32_m1",   4, np.int32, np.int32, np.int32),
    ("test_i32_m2",   8, np.int32, np.int32, np.int32),
    ("test_i32_m4",  16, np.int32, np.int32, np.int32),
    ("test_i32_m8",  32, np.int32, np.int32, np.int32),
    ("test_u8_mf4",   4, np.uint8,  np.uint8,  np.uint8),
    ("test_u8_mf2",   8, np.uint8,  np.uint8,  np.uint8),
    ("test_u8_m1",   16, np.uint8,  np.uint8,  np.uint8),
    ("test_u8_m2",   32, np.uint8,  np.uint8,  np.uint8),
    ("test_u8_m4",   64, np.uint8,  np.uint8,  np.uint8),
    ("test_u8_m8",  128, np.uint8,  np.uint8,  np.uint8),
    ("test_u16_mf2",  4, np.uint16, np.uint16, np.uint16),
    ("test_u16_m1",   8, np.uint16, np.uint16, np.uint16),
    ("test_u16_m2",  16, np.uint16, np.uint16, np.uint16),
    ("test_u16_m4",  32, np.uint16, np.uint16, np.uint16),
    ("test_u16_m8",  64, np.uint16, np.uint16, np.uint16),
    ("test_u32_m1",   4, np.uint32, np.uint32, np.uint32),
    ("test_u32_m2",   8, np.uint32, np.uint32, np.uint32),
    ("test_u32_m4",  16, np.uint32, np.uint32, np.uint32),
    ("test_u32_m8",  32, np.uint32, np.uint32, np.uint32),
]


def _force_unsigned(dtype):
    bitdepth = np.dtype(dtype).itemsize * 8
    return np.dtype(f'uint{bitdepth}')


SAME_TYPE_RHS_FORCED_UNSIGNED_TEST_CASES = [
    (name, vl, lhs_dtype, _force_unsigned(rhs_dtype), result_type)
    for name, vl, lhs_dtype, rhs_dtype, result_type in SAME_TYPE_TEST_CASES
]

UNSIGNED_ONLY_TEST_CASES = [
    (name, vl, lhs_dtype, rhs_dtype, result_type)
    for name, vl, lhs_dtype, rhs_dtype, result_type in SAME_TYPE_TEST_CASES
    if np.dtype(lhs_dtype).kind == 'u'
]

SIGNED_LHS_UNSIGNED_RHS_ONLY_TEST_CASES = [
    (name, vl, lhs_dtype, _force_unsigned(rhs_dtype), result_type)
    for name, vl, lhs_dtype, rhs_dtype, result_type in SAME_TYPE_TEST_CASES
    if np.dtype(lhs_dtype).kind == 'i'
]

@cocotb.test()
async def binary_op_vx(dut):
    r = runfiles.Create()
    fixture = await Fixture.Create(dut)
    test_binaries = [
        ("vadd_vx_test.elf", SAME_TYPE_TEST_CASES, np.add),
        ("vsadd_vx_test.elf", SAME_TYPE_TEST_CASES, reference_sadd),
        ("vsub_vx_test.elf", SAME_TYPE_TEST_CASES, np.subtract),
        ("vssub_vx_test.elf", SAME_TYPE_TEST_CASES, reference_ssub),
        ("vrsub_vx_test.elf", SAME_TYPE_TEST_CASES, reference_rsub),
        ("vmul_vx_test.elf", SAME_TYPE_TEST_CASES, np.multiply),
        ("vmulh_vx_test.elf", SAME_TYPE_TEST_CASES, reference_vmulh),
        ("vmin_vx_test.elf", SAME_TYPE_TEST_CASES, np.minimum),
        ("vmax_vx_test.elf", SAME_TYPE_TEST_CASES, np.maximum),
        ("vand_vx_test.elf", SAME_TYPE_TEST_CASES, np.bitwise_and),
        ("vor_vx_test.elf", SAME_TYPE_TEST_CASES, np.bitwise_or),
        ("vxor_vx_test.elf", SAME_TYPE_TEST_CASES, np.bitwise_xor),
        ("vsll_vx_test.elf", SAME_TYPE_RHS_FORCED_UNSIGNED_TEST_CASES,
                             reference_sll),
        ("vsrl_vx_test.elf", UNSIGNED_ONLY_TEST_CASES, reference_srl),
        ("vsra_vx_test.elf", SIGNED_LHS_UNSIGNED_RHS_ONLY_TEST_CASES,
                             reference_sra),
        ("vmulhsu_vx_test.elf", SIGNED_LHS_UNSIGNED_RHS_ONLY_TEST_CASES,
                                reference_vmulh),
    ]
    with tqdm.tqdm(test_binaries) as pbar:
        for test_binary_op_vx, test_cases, expected_fn in pbar:
            pbar.set_postfix({'binary': test_binary_op_vx})
            test_binary_path = r.Rlocation(
                f"coralnpu_hw/tests/cocotb/rvv/arithmetics/{test_binary_op_vx}")

            fn_names = list(set([x[0] for x in test_cases]))
            await fixture.load_elf_and_lookup_symbols(
                test_binary_path, ['vl', 'vs1', 'xs2', 'vd', 'impl'] + fn_names)

            for test_fn_name, vlmax, vs1_dtype, xs2_dtype, vd_dtype in test_cases:
                for vl in [1, vlmax-1, vlmax]:
                    # Write random data to vs1 and xs2
                    rng = np.random.default_rng()
                    vs1_data = rng.integers(
                        np.iinfo(vs1_dtype).min,
                        np.iinfo(vs1_dtype).max + 1,
                        size=vl,
                        dtype=vs1_dtype)
                    xs2_data = rng.integers(
                        np.iinfo(xs2_dtype).min,
                        np.iinfo(xs2_dtype).max + 1,
                        size=1,
                        dtype=xs2_dtype)

                    await fixture.write('vl', np.array([vl], dtype=np.uint32))
                    await fixture.write('vs1', vs1_data)
                    await fixture.write('xs2', xs2_data.astype(np.uint32))
                    await fixture.write('vd', np.zeros(128, dtype=np.uint8))

                    # Execute the test function
                    await fixture.write_ptr('impl', test_fn_name)
                    await fixture.run_to_halt()

                    # Read the result and assert
                    expected_vd_data = expected_fn(vs1_data, xs2_data[0])
                    actual_vd_data = (await fixture.read(
                        'vd', vl*np.dtype(vd_dtype).itemsize)).view(vd_dtype)
                    assert (actual_vd_data == expected_vd_data).all(), (
                        f"binary: {test_binary_op_vx}, "
                        f"test_fn_name: {test_fn_name}, "
                        f"vs1: {vs1_data}, xs2: {xs2_data}, "
                        f"expected: {expected_vd_data}, actual: {actual_vd_data}")
