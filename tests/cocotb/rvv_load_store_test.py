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
import tqdm

from bazel_tools.tools.python.runfiles import runfiles
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
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('kelvin_hw/tests/cocotb/rvv/load_store/' + elf_name),
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

async def vector_load_store_v2(
        dut,
        elf_name: str,
        cases: list[dict],  # keys: impl, vl, in_size, out_size, pattern.
        dtype,
):
    """RVV load-store test template.

    Each test performs some kind of patterned copy from `in_buf` to `out_buf`.
    """
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('kelvin_hw/tests/cocotb/rvv/load_store/' + elf_name),
        ['impl', 'vl', 'in_buf', 'out_buf'] +
            list({c['impl'] for c in cases}),
    )

    min_value = np.iinfo(dtype).min
    max_value = np.iinfo(dtype).max + 1  # One above.
    rng = np.random.default_rng()
    for c in tqdm.tqdm(cases):
        impl = c['impl']
        vl = c['vl']
        in_size = c['in_size']
        out_size = c['out_size']
        pattern = c['pattern']

        input_data = rng.integers(min_value, max_value, in_size, dtype=dtype)
        expected_outputs = input_data[pattern]
        sbz = np.zeros(out_size - len(pattern), dtype=dtype)
        expected_outputs = np.concat((expected_outputs, sbz))

        await fixture.write_ptr('impl', impl)
        await fixture.write_word('vl', vl)
        await fixture.write('in_buf', input_data)
        await fixture.write('out_buf', np.zeros([out_size], dtype=dtype))

        await fixture.run_to_halt()

        actual_outputs = (await fixture.read(
            'out_buf', out_size * np.dtype(dtype).itemsize)).view(dtype)

        debug_msg = str({
            'impl': impl,
            'input': input_data,
            'expected': expected_outputs,
            'actual': actual_outputs,
        })
        assert (actual_outputs == expected_outputs).all(), debug_msg


async def vector_load_indexed(
        dut,
        elf_name: str,
        cases: list[dict],  # keys: impl, vl, in_bytes, out_size.
        dtype,
        index_dtype,
):
    """RVV load-store test template for indexed loads.

    Each test performs a gather operation and writes the result to an output.
    """
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('kelvin_hw/tests/cocotb/rvv/load_store/' + elf_name),
        ['impl', 'vl', 'in_buf', 'out_buf', 'index_buf'] +
            list({c['impl'] for c in cases}),
    )

    rng = np.random.default_rng()
    for c in tqdm.tqdm(cases):
        impl = c['impl']
        vl = c['vl']
        in_bytes = c['in_bytes']
        out_size = c['out_size']

        # Don't go beyond the buffer.
        index_max = in_bytes - np.dtype(dtype).itemsize + 1
        # TODO(davidgao): currently assuming the vl is supported.
        # We'll eventually want to test unsupported vl.
        indices = rng.integers(0, index_max, out_size, dtype=index_dtype)
        # Index is in bytes so input needs to be in bytes.
        input_data = rng.integers(0, 256, in_bytes, dtype=np.uint8)
        # Input needs to be reinterpreted.
        indices_in_use = np.array([
            np.arange(x, x + np.dtype(dtype).itemsize)
            for x in indices[:vl].astype(np.uint32)]).astype(index_dtype)
        expected_outputs = input_data[indices_in_use].view(dtype)[..., 0]
        sbz = np.zeros(out_size - vl, dtype=dtype)
        expected_outputs = np.concat((expected_outputs, sbz))

        await fixture.write_ptr('impl', impl)
        await fixture.write_word('vl', vl)
        await fixture.write('index_buf', indices)
        await fixture.write('in_buf', input_data)
        await fixture.write('out_buf', np.zeros([out_size], dtype=dtype))

        await fixture.run_to_halt()

        actual_outputs = (await fixture.read(
            'out_buf', out_size * np.dtype(dtype).itemsize)).view(dtype)

        debug_msg = str({
            'impl': impl,
            'input': input_data,
            'indices': indices,
            'expected': expected_outputs,
            'actual': actual_outputs,
        })
        assert (actual_outputs == expected_outputs).all(), debug_msg


async def vector_store_indexed(
        dut,
        elf_name: str,
        dtype,
):
    """RVV load-store test template for indexed stores.

    Each test loads indices and data and performs a scatter operation.
    """
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('kelvin_hw/tests/cocotb/rvv/load_store/' + elf_name),
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
async def load_store_bits(dut):
    """Test vlm/vsm usage accessible from intrinsics."""
    # mask is not accessible from here.
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    cases = [
        {'impl': 'vlm_vsm_v_b1', 'vl': 128},
        {'impl': 'vlm_vsm_v_b1', 'vl': 121},
        {'impl': 'vlm_vsm_v_b1', 'vl': 120},
        {'impl': 'vlm_vsm_v_b2', 'vl': 64},
        {'impl': 'vlm_vsm_v_b2', 'vl': 57},
        {'impl': 'vlm_vsm_v_b2', 'vl': 56},
        {'impl': 'vlm_vsm_v_b4', 'vl': 32},
        {'impl': 'vlm_vsm_v_b4', 'vl': 25},
        {'impl': 'vlm_vsm_v_b4', 'vl': 24},
        {'impl': 'vlm_vsm_v_b8', 'vl': 16},
        {'impl': 'vlm_vsm_v_b8', 'vl': 9},
        {'impl': 'vlm_vsm_v_b8', 'vl': 8},
        {'impl': 'vlm_vsm_v_b16', 'vl': 8},
        {'impl': 'vlm_vsm_v_b16', 'vl': 1},
        {'impl': 'vlm_vsm_v_b32', 'vl': 4},
        {'impl': 'vlm_vsm_v_b32', 'vl': 1},
    ]
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation(
            'kelvin_hw/tests/cocotb/rvv/load_store/load_store_bits.elf'),
        ['vl', 'in_buf', 'out_buf', 'impl'] +
            list({c['impl'] for c in cases}),
    )
    rng = np.random.default_rng()
    for c in cases:
        impl = c['impl']
        vl = c['vl']
        in_bytes = (vl + 7) // 8
        last_byte_mask = (1 << (vl % 8) - 1) if vl % 8 else 0xFF

        input_data = rng.integers(
            low=0, high=256, size=in_bytes, dtype=np.uint8)
        expected_output = input_data
        expected_output[-1] = expected_output[-1] & last_byte_mask

        await fixture.write_ptr('impl', impl)
        await fixture.write_word('vl', vl)
        await fixture.write('in_buf', input_data)
        await fixture.write('out_buf', np.zeros([in_bytes], dtype=np.uint8))

        await fixture.run_to_halt()

        actual_output = (await fixture.read('out_buf', in_bytes)).view(np.uint8)

        debug_msg = str({
            'impl': impl,
            'input': input_data,
            'expected': expected_output,
            'actual': actual_output,
        })
        assert (actual_output == expected_output).all(), debug_msg


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
async def load_store16_unit_m2(dut):
    await vector_load_store(
        dut=dut,
        elf_name='load_store16_unit_m2.elf',
        dtype=np.uint16,
        in_size=32,
        out_size=32,
        pattern=list(range(0, 16)),
    )


@cocotb.test()
async def load_store32_unit_m2(dut):
    await vector_load_store(
        dut=dut,
        elf_name='load_store32_unit_m2.elf',
        dtype=np.uint32,
        in_size=16,
        out_size=16,
        pattern=list(range(0, 8)),
    )


@cocotb.test()
async def load8_seg_unit(dut):
    """Test vlseg*e8 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern':[
                elem * n_segs + seg
                for seg in range(n_segs) for elem in range(vl)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'load8_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vlseg2e8_v_u8mf4x2', vl=4, n_segs=2),
            make_test_case('vlseg2e8_v_u8mf4x2', vl=3, n_segs=2),
            make_test_case('vlseg2e8_v_u8mf2x2', vl=8, n_segs=2),
            make_test_case('vlseg2e8_v_u8mf2x2', vl=7, n_segs=2),
            make_test_case('vlseg2e8_v_u8m1x2', vl=16, n_segs=2),
            make_test_case('vlseg2e8_v_u8m1x2', vl=15, n_segs=2),
            make_test_case('vlseg2e8_v_u8m2x2', vl=32, n_segs=2),
            make_test_case('vlseg2e8_v_u8m2x2', vl=31, n_segs=2),
            make_test_case('vlseg2e8_v_u8m4x2', vl=64, n_segs=2),
            make_test_case('vlseg2e8_v_u8m4x2', vl=63, n_segs=2),
            # Seg 3
            make_test_case('vlseg3e8_v_u8mf4x3', vl=4, n_segs=3),
            make_test_case('vlseg3e8_v_u8mf4x3', vl=3, n_segs=3),
            make_test_case('vlseg3e8_v_u8mf2x3', vl=8, n_segs=3),
            make_test_case('vlseg3e8_v_u8mf2x3', vl=7, n_segs=3),
            make_test_case('vlseg3e8_v_u8m1x3', vl=16, n_segs=3),
            make_test_case('vlseg3e8_v_u8m1x3', vl=15, n_segs=3),
            make_test_case('vlseg3e8_v_u8m2x3', vl=32, n_segs=3),
            make_test_case('vlseg3e8_v_u8m2x3', vl=31, n_segs=3),
            # Seg 4
            make_test_case('vlseg4e8_v_u8mf4x4', vl=4, n_segs=4),
            make_test_case('vlseg4e8_v_u8mf4x4', vl=3, n_segs=4),
            make_test_case('vlseg4e8_v_u8mf2x4', vl=8, n_segs=4),
            make_test_case('vlseg4e8_v_u8mf2x4', vl=7, n_segs=4),
            make_test_case('vlseg4e8_v_u8m1x4', vl=16, n_segs=4),
            make_test_case('vlseg4e8_v_u8m1x4', vl=15, n_segs=4),
            make_test_case('vlseg4e8_v_u8m2x4', vl=32, n_segs=4),
            make_test_case('vlseg4e8_v_u8m2x4', vl=31, n_segs=4),
            # Seg 5
            make_test_case('vlseg5e8_v_u8mf4x5', vl=4, n_segs=5),
            make_test_case('vlseg5e8_v_u8mf4x5', vl=3, n_segs=5),
            make_test_case('vlseg5e8_v_u8mf2x5', vl=8, n_segs=5),
            make_test_case('vlseg5e8_v_u8mf2x5', vl=7, n_segs=5),
            make_test_case('vlseg5e8_v_u8m1x5', vl=16, n_segs=5),
            make_test_case('vlseg5e8_v_u8m1x5', vl=15, n_segs=5),
            # Seg 6
            make_test_case('vlseg6e8_v_u8mf4x6', vl=4, n_segs=6),
            make_test_case('vlseg6e8_v_u8mf4x6', vl=3, n_segs=6),
            make_test_case('vlseg6e8_v_u8mf2x6', vl=8, n_segs=6),
            make_test_case('vlseg6e8_v_u8mf2x6', vl=7, n_segs=6),
            make_test_case('vlseg6e8_v_u8m1x6', vl=16, n_segs=6),
            make_test_case('vlseg6e8_v_u8m1x6', vl=15, n_segs=6),
            # Seg 7
            make_test_case('vlseg7e8_v_u8mf4x7', vl=4, n_segs=7),
            make_test_case('vlseg7e8_v_u8mf4x7', vl=3, n_segs=7),
            make_test_case('vlseg7e8_v_u8mf2x7', vl=8, n_segs=7),
            make_test_case('vlseg7e8_v_u8mf2x7', vl=7, n_segs=7),
            make_test_case('vlseg7e8_v_u8m1x7', vl=16, n_segs=7),
            make_test_case('vlseg7e8_v_u8m1x7', vl=15, n_segs=7),
            # Seg 8
            make_test_case('vlseg8e8_v_u8mf4x8', vl=4, n_segs=8),
            make_test_case('vlseg8e8_v_u8mf4x8', vl=3, n_segs=8),
            make_test_case('vlseg8e8_v_u8mf2x8', vl=8, n_segs=8),
            make_test_case('vlseg8e8_v_u8mf2x8', vl=7, n_segs=8),
            make_test_case('vlseg8e8_v_u8m1x8', vl=16, n_segs=8),
            make_test_case('vlseg8e8_v_u8m1x8', vl=15, n_segs=8),
        ],
        dtype = np.uint8,
    )


@cocotb.test()
async def load8_index8(dut):
    """Test vl*xei8_v_u8 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_bytes': 256,
            'out_size': vl * 2,
        }

    await vector_load_indexed(
        dut = dut,
        elf_name = 'load8_index8.elf',
        cases = [
            # Unordered
            make_test_case('vluxei8_v_u8mf4', vl = 4),
            make_test_case('vluxei8_v_u8mf4', vl = 3),
            make_test_case('vluxei8_v_u8mf2', vl = 8),
            make_test_case('vluxei8_v_u8mf2', vl = 7),
            make_test_case('vluxei8_v_u8m1', vl = 16),
            make_test_case('vluxei8_v_u8m1', vl = 15),
            make_test_case('vluxei8_v_u8m2', vl = 32),
            make_test_case('vluxei8_v_u8m2', vl = 31),
            make_test_case('vluxei8_v_u8m4', vl = 64),
            make_test_case('vluxei8_v_u8m4', vl = 63),
            make_test_case('vluxei8_v_u8m8', vl = 128),
            make_test_case('vluxei8_v_u8m8', vl = 127),
            # Ordered
            make_test_case('vloxei8_v_u8mf4', vl = 4),
            make_test_case('vloxei8_v_u8mf4', vl = 3),
            make_test_case('vloxei8_v_u8mf2', vl = 8),
            make_test_case('vloxei8_v_u8mf2', vl = 7),
            make_test_case('vloxei8_v_u8m1', vl = 16),
            make_test_case('vloxei8_v_u8m1', vl = 15),
            make_test_case('vloxei8_v_u8m2', vl = 32),
            make_test_case('vloxei8_v_u8m2', vl = 31),
            make_test_case('vloxei8_v_u8m4', vl = 64),
            make_test_case('vloxei8_v_u8m4', vl = 63),
            make_test_case('vloxei8_v_u8m8', vl = 128),
            make_test_case('vloxei8_v_u8m8', vl = 127),
        ],
        dtype = np.uint8,
        index_dtype = np.uint8,
    )


@cocotb.test()
async def load8_index16(dut):
    """Test vl*xei16_v_u8 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_bytes': 32000,  # DTCM is 32KB
            'out_size': vl * 2,
        }

    await vector_load_indexed(
        dut = dut,
        elf_name = 'load8_index16.elf',
        cases = [
            # Unordered
            make_test_case('vluxei16_v_u8mf4', vl = 4),
            make_test_case('vluxei16_v_u8mf4', vl = 3),
            make_test_case('vluxei16_v_u8mf2', vl = 8),
            make_test_case('vluxei16_v_u8mf2', vl = 7),
            make_test_case('vluxei16_v_u8m1', vl = 16),
            make_test_case('vluxei16_v_u8m1', vl = 15),
            make_test_case('vluxei16_v_u8m2', vl = 32),
            make_test_case('vluxei16_v_u8m2', vl = 31),
            make_test_case('vluxei16_v_u8m4', vl = 64),
            make_test_case('vluxei16_v_u8m4', vl = 63),
            # Ordered
            make_test_case('vloxei16_v_u8mf4', vl = 4),
            make_test_case('vloxei16_v_u8mf4', vl = 3),
            make_test_case('vloxei16_v_u8mf2', vl = 8),
            make_test_case('vloxei16_v_u8mf2', vl = 7),
            make_test_case('vloxei16_v_u8m1', vl = 16),
            make_test_case('vloxei16_v_u8m1', vl = 15),
            make_test_case('vloxei16_v_u8m2', vl = 32),
            make_test_case('vloxei16_v_u8m2', vl = 31),
            make_test_case('vloxei16_v_u8m4', vl = 64),
            make_test_case('vloxei16_v_u8m4', vl = 63),
        ],
        dtype = np.uint8,
        index_dtype = np.uint16,
    )


@cocotb.test()
async def load8_index32(dut):
    """Test vl*xei32_v_u8 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_bytes': 32000,  # DTCM is 32KB
            'out_size': vl * 2,
        }

    await vector_load_indexed(
        dut = dut,
        elf_name = 'load8_index32.elf',
        cases = [
            # Unordered
            make_test_case('vluxei32_v_u8mf4', vl = 4),
            make_test_case('vluxei32_v_u8mf4', vl = 3),
            make_test_case('vluxei32_v_u8mf2', vl = 8),
            make_test_case('vluxei32_v_u8mf2', vl = 7),
            make_test_case('vluxei32_v_u8m1', vl = 16),
            make_test_case('vluxei32_v_u8m1', vl = 15),
            make_test_case('vluxei32_v_u8m2', vl = 32),
            make_test_case('vluxei32_v_u8m2', vl = 31),
            # Ordered
            make_test_case('vloxei32_v_u8mf4', vl = 4),
            make_test_case('vloxei32_v_u8mf4', vl = 3),
            make_test_case('vloxei32_v_u8mf2', vl = 8),
            make_test_case('vloxei32_v_u8mf2', vl = 7),
            make_test_case('vloxei32_v_u8m1', vl = 16),
            make_test_case('vloxei32_v_u8m1', vl = 15),
            make_test_case('vloxei32_v_u8m2', vl = 32),
            make_test_case('vloxei32_v_u8m2', vl = 31),
        ],
        dtype = np.uint8,
        index_dtype = np.uint32,
    )


@cocotb.test()
async def load16_index8(dut):
    """Test vl*xei8_v_u16 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_bytes': 256,
            'out_size': vl * 2,
        }

    await vector_load_indexed(
        dut = dut,
        elf_name = 'load16_index8.elf',
        cases = [
            # Unordered
            make_test_case('vluxei8_v_u16mf2', vl = 4),
            make_test_case('vluxei8_v_u16mf2', vl = 3),
            make_test_case('vluxei8_v_u16m1', vl = 8),
            make_test_case('vluxei8_v_u16m1', vl = 7),
            # make_test_case('vluxei8_v_u16m2', vl = 16),
            # make_test_case('vluxei8_v_u16m2', vl = 15),
            # make_test_case('vluxei8_v_u16m4', vl = 32),
            # make_test_case('vluxei8_v_u16m4', vl = 31),
            # make_test_case('vluxei8_v_u16m8', vl = 64),
            # make_test_case('vluxei8_v_u16m8', vl = 63),
            # Ordered
            make_test_case('vloxei8_v_u16mf2', vl = 4),
            make_test_case('vloxei8_v_u16mf2', vl = 3),
            make_test_case('vloxei8_v_u16m1', vl = 8),
            make_test_case('vloxei8_v_u16m1', vl = 7),
            # make_test_case('vloxei8_v_u16m1', vl = 16),
            # make_test_case('vloxei8_v_u16m1', vl = 15),
            # make_test_case('vloxei8_v_u16m4', vl = 32),
            # make_test_case('vloxei8_v_u16m4', vl = 31),
            # make_test_case('vloxei8_v_u16m8', vl = 64),
            # make_test_case('vloxei8_v_u16m8', vl = 63),
        ],
        dtype = np.uint16,
        index_dtype = np.uint8,
    )


@cocotb.test()
async def load16_seg_unit(dut):
    """Test vlseg*e16 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern':[
                elem * n_segs + seg
                for seg in range(n_segs) for elem in range(vl)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'load16_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vlseg2e16_v_u16mf2x2', vl=4, n_segs=2),
            make_test_case('vlseg2e16_v_u16mf2x2', vl=3, n_segs=2),
            make_test_case('vlseg2e16_v_u16m1x2', vl=8, n_segs=2),
            make_test_case('vlseg2e16_v_u16m1x2', vl=7, n_segs=2),
            make_test_case('vlseg2e16_v_u16m2x2', vl=16, n_segs=2),
            make_test_case('vlseg2e16_v_u16m2x2', vl=15, n_segs=2),
            make_test_case('vlseg2e16_v_u16m4x2', vl=32, n_segs=2),
            make_test_case('vlseg2e16_v_u16m4x2', vl=31, n_segs=2),
            # Seg 3
            make_test_case('vlseg3e16_v_u16mf2x3', vl=4, n_segs=3),
            make_test_case('vlseg3e16_v_u16mf2x3', vl=3, n_segs=3),
            make_test_case('vlseg3e16_v_u16m1x3', vl=8, n_segs=3),
            make_test_case('vlseg3e16_v_u16m1x3', vl=7, n_segs=3),
            make_test_case('vlseg3e16_v_u16m2x3', vl=16, n_segs=3),
            make_test_case('vlseg3e16_v_u16m2x3', vl=15, n_segs=3),
            # Seg 4
            make_test_case('vlseg4e16_v_u16mf2x4', vl=4, n_segs=4),
            make_test_case('vlseg4e16_v_u16mf2x4', vl=3, n_segs=4),
            make_test_case('vlseg4e16_v_u16m1x4', vl=8, n_segs=4),
            make_test_case('vlseg4e16_v_u16m1x4', vl=7, n_segs=4),
            make_test_case('vlseg4e16_v_u16m2x4', vl=16, n_segs=4),
            make_test_case('vlseg4e16_v_u16m2x4', vl=15, n_segs=4),
            # Seg 5
            make_test_case('vlseg5e16_v_u16mf2x5', vl=4, n_segs=5),
            make_test_case('vlseg5e16_v_u16mf2x5', vl=3, n_segs=5),
            make_test_case('vlseg5e16_v_u16m1x5', vl=8, n_segs=5),
            make_test_case('vlseg5e16_v_u16m1x5', vl=7, n_segs=5),
            # Seg 6
            make_test_case('vlseg6e16_v_u16mf2x6', vl=4, n_segs=6),
            make_test_case('vlseg6e16_v_u16mf2x6', vl=3, n_segs=6),
            make_test_case('vlseg6e16_v_u16m1x6', vl=8, n_segs=6),
            make_test_case('vlseg6e16_v_u16m1x6', vl=7, n_segs=6),
            # Seg 7
            make_test_case('vlseg7e16_v_u16mf2x7', vl=4, n_segs=7),
            make_test_case('vlseg7e16_v_u16mf2x7', vl=3, n_segs=7),
            make_test_case('vlseg7e16_v_u16m1x7', vl=8, n_segs=7),
            make_test_case('vlseg7e16_v_u16m1x7', vl=7, n_segs=7),
            # Seg 8
            make_test_case('vlseg8e16_v_u16mf2x8', vl=4, n_segs=8),
            make_test_case('vlseg8e16_v_u16mf2x8', vl=3, n_segs=8),
            make_test_case('vlseg8e16_v_u16m1x8', vl=8, n_segs=8),
            make_test_case('vlseg8e16_v_u16m1x8', vl=7, n_segs=8),
        ],
        dtype = np.uint16,
    )


@cocotb.test()
async def load32_index8(dut):
    """Test vl*xei8_v_u32 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_bytes': 256,
            'out_size': vl * 2,
        }

    await vector_load_indexed(
        dut = dut,
        elf_name = 'load32_index8.elf',
        cases = [
            # Unordered
            make_test_case('vluxei8_v_u32m1', vl = 4),
            make_test_case('vluxei8_v_u32m1', vl = 3),
            # make_test_case('vluxei8_v_u32m2', vl = 8),
            # make_test_case('vluxei8_v_u32m2', vl = 7),
            # make_test_case('vluxei8_v_u32m4', vl = 16),
            # make_test_case('vluxei8_v_u32m4', vl = 15),
            # make_test_case('vluxei8_v_u32m8', vl = 32),
            # make_test_case('vluxei8_v_u32m8', vl = 31),
            # Ordered
            make_test_case('vloxei8_v_u32m1', vl = 4),
            make_test_case('vloxei8_v_u32m1', vl = 3),
            # make_test_case('vloxei8_v_u32m1', vl = 16),
            # make_test_case('vloxei8_v_u32m1', vl = 15),
            # make_test_case('vloxei8_v_u32m4', vl = 32),
            # make_test_case('vloxei8_v_u32m4', vl = 31),
            # make_test_case('vloxei8_v_u32m8', vl = 64),
            # make_test_case('vloxei8_v_u32m8', vl = 63),
        ],
        dtype = np.uint32,
        index_dtype = np.uint8,
    )


@cocotb.test()
async def load32_seg_unit(dut):
    """Test vlseg*e32 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern':[
                elem * n_segs + seg
                for seg in range(n_segs) for elem in range(vl)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'load32_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vlseg2e32_v_u32m1x2', vl=4, n_segs=2),
            make_test_case('vlseg2e32_v_u32m1x2', vl=3, n_segs=2),
            make_test_case('vlseg2e32_v_u32m2x2', vl=8, n_segs=2),
            make_test_case('vlseg2e32_v_u32m2x2', vl=7, n_segs=2),
            make_test_case('vlseg2e32_v_u32m4x2', vl=16, n_segs=2),
            make_test_case('vlseg2e32_v_u32m4x2', vl=15, n_segs=2),
            # Seg 3
            make_test_case('vlseg3e32_v_u32m1x3', vl=4, n_segs=3),
            make_test_case('vlseg3e32_v_u32m1x3', vl=3, n_segs=3),
            make_test_case('vlseg3e32_v_u32m2x3', vl=8, n_segs=3),
            make_test_case('vlseg3e32_v_u32m2x3', vl=7, n_segs=3),
            # Seg 4
            make_test_case('vlseg4e32_v_u32m1x4', vl=4, n_segs=4),
            make_test_case('vlseg4e32_v_u32m1x4', vl=3, n_segs=4),
            make_test_case('vlseg4e32_v_u32m2x4', vl=8, n_segs=4),
            make_test_case('vlseg4e32_v_u32m2x4', vl=7, n_segs=4),
            # Seg 5
            make_test_case('vlseg5e32_v_u32m1x5', vl=4, n_segs=5),
            make_test_case('vlseg5e32_v_u32m1x5', vl=3, n_segs=5),
            # Seg 6
            make_test_case('vlseg6e32_v_u32m1x6', vl=4, n_segs=6),
            make_test_case('vlseg6e32_v_u32m1x6', vl=3, n_segs=6),
            # Seg 7
            make_test_case('vlseg7e32_v_u32m1x7', vl=4, n_segs=7),
            make_test_case('vlseg7e32_v_u32m1x7', vl=3, n_segs=7),
            # Seg 8
            make_test_case('vlseg8e32_v_u32m1x8', vl=4, n_segs=8),
            make_test_case('vlseg8e32_v_u32m1x8', vl=3, n_segs=8),
        ],
        dtype = np.uint32,
    )


@cocotb.test()
async def load8_segment2_stride6_m1(dut):
    await vector_load_store(
        dut=dut,
        elf_name='load8_segment2_stride6_m1.elf',
        dtype=np.uint8,
        in_size=256,
        out_size=64,
        pattern=([i * 6 for i in range(16)] + [i * 6 + 1 for i in range(16)]),
    )


@cocotb.test()
async def load16_segment2_stride6_m1(dut):
    await vector_load_store(
        dut=dut,
        elf_name='load16_segment2_stride6_m1.elf',
        dtype=np.uint16,
        in_size=128,
        out_size=32,
        pattern=([i * 3 for i in range(8)] + [i * 3 + 1 for i in range(8)]),
    )


@cocotb.test()
async def store8_indexed_m1(dut):
    await vector_store_indexed(
        dut = dut,
        elf_name = 'store8_indexed_m1.elf',
        dtype = np.uint8,
    )


@cocotb.test()
async def store8_seg_unit(dut):
    """Test vsseg*e8 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern': [
                seg * vl + elem
                for elem in range(vl) for seg in range(n_segs)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'store8_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vsseg2e8_v_u8mf4x2', vl=4, n_segs=2),
            make_test_case('vsseg2e8_v_u8mf4x2', vl=3, n_segs=2),
            make_test_case('vsseg2e8_v_u8mf2x2', vl=8, n_segs=2),
            make_test_case('vsseg2e8_v_u8mf2x2', vl=7, n_segs=2),
            make_test_case('vsseg2e8_v_u8m1x2', vl=16, n_segs=2),
            make_test_case('vsseg2e8_v_u8m1x2', vl=15, n_segs=2),
            make_test_case('vsseg2e8_v_u8m2x2', vl=32, n_segs=2),
            make_test_case('vsseg2e8_v_u8m2x2', vl=31, n_segs=2),
            make_test_case('vsseg2e8_v_u8m4x2', vl=64, n_segs=2),
            make_test_case('vsseg2e8_v_u8m4x2', vl=63, n_segs=2),
            # Seg 3
            make_test_case('vsseg3e8_v_u8mf4x3', vl=4, n_segs=3),
            make_test_case('vsseg3e8_v_u8mf4x3', vl=3, n_segs=3),
            make_test_case('vsseg3e8_v_u8mf2x3', vl=8, n_segs=3),
            make_test_case('vsseg3e8_v_u8mf2x3', vl=7, n_segs=3),
            make_test_case('vsseg3e8_v_u8m1x3', vl=16, n_segs=3),
            make_test_case('vsseg3e8_v_u8m1x3', vl=15, n_segs=3),
            make_test_case('vsseg3e8_v_u8m2x3', vl=32, n_segs=3),
            make_test_case('vsseg3e8_v_u8m2x3', vl=31, n_segs=3),
            # Seg 4
            make_test_case('vsseg4e8_v_u8mf4x4', vl=4, n_segs=4),
            make_test_case('vsseg4e8_v_u8mf4x4', vl=3, n_segs=4),
            make_test_case('vsseg4e8_v_u8mf2x4', vl=8, n_segs=4),
            make_test_case('vsseg4e8_v_u8mf2x4', vl=7, n_segs=4),
            make_test_case('vsseg4e8_v_u8m1x4', vl=16, n_segs=4),
            make_test_case('vsseg4e8_v_u8m1x4', vl=15, n_segs=4),
            make_test_case('vsseg4e8_v_u8m2x4', vl=32, n_segs=4),
            make_test_case('vsseg4e8_v_u8m2x4', vl=31, n_segs=4),
            # Seg 5
            make_test_case('vsseg5e8_v_u8mf4x5', vl=4, n_segs=5),
            make_test_case('vsseg5e8_v_u8mf4x5', vl=3, n_segs=5),
            make_test_case('vsseg5e8_v_u8mf2x5', vl=8, n_segs=5),
            make_test_case('vsseg5e8_v_u8mf2x5', vl=7, n_segs=5),
            make_test_case('vsseg5e8_v_u8m1x5', vl=16, n_segs=5),
            make_test_case('vsseg5e8_v_u8m1x5', vl=15, n_segs=5),
            # Seg 6
            make_test_case('vsseg6e8_v_u8mf4x6', vl=4, n_segs=6),
            make_test_case('vsseg6e8_v_u8mf4x6', vl=3, n_segs=6),
            make_test_case('vsseg6e8_v_u8mf2x6', vl=8, n_segs=6),
            make_test_case('vsseg6e8_v_u8mf2x6', vl=7, n_segs=6),
            make_test_case('vsseg6e8_v_u8m1x6', vl=16, n_segs=6),
            make_test_case('vsseg6e8_v_u8m1x6', vl=15, n_segs=6),
            # Seg 7
            make_test_case('vsseg7e8_v_u8mf4x7', vl=4, n_segs=7),
            make_test_case('vsseg7e8_v_u8mf4x7', vl=3, n_segs=7),
            make_test_case('vsseg7e8_v_u8mf2x7', vl=8, n_segs=7),
            make_test_case('vsseg7e8_v_u8mf2x7', vl=7, n_segs=7),
            make_test_case('vsseg7e8_v_u8m1x7', vl=16, n_segs=7),
            make_test_case('vsseg7e8_v_u8m1x7', vl=15, n_segs=7),
            # Seg 8
            make_test_case('vsseg8e8_v_u8mf4x8', vl=4, n_segs=8),
            make_test_case('vsseg8e8_v_u8mf4x8', vl=3, n_segs=8),
            make_test_case('vsseg8e8_v_u8mf2x8', vl=8, n_segs=8),
            make_test_case('vsseg8e8_v_u8mf2x8', vl=7, n_segs=8),
            make_test_case('vsseg8e8_v_u8m1x8', vl=16, n_segs=8),
            make_test_case('vsseg8e8_v_u8m1x8', vl=15, n_segs=8),
        ],
        dtype = np.uint8,
    )


@cocotb.test()
async def store16_seg_unit(dut):
    """Test vsseg*e16 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern': [
                seg * vl + elem
                for elem in range(vl) for seg in range(n_segs)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'store16_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vsseg2e16_v_u16mf2x2', vl=4, n_segs=2),
            make_test_case('vsseg2e16_v_u16mf2x2', vl=3, n_segs=2),
            make_test_case('vsseg2e16_v_u16m1x2', vl=8, n_segs=2),
            make_test_case('vsseg2e16_v_u16m1x2', vl=7, n_segs=2),
            make_test_case('vsseg2e16_v_u16m2x2', vl=16, n_segs=2),
            make_test_case('vsseg2e16_v_u16m2x2', vl=15, n_segs=2),
            make_test_case('vsseg2e16_v_u16m4x2', vl=32, n_segs=2),
            make_test_case('vsseg2e16_v_u16m4x2', vl=31, n_segs=2),
            # Seg 3
            make_test_case('vsseg3e16_v_u16mf2x3', vl=4, n_segs=3),
            make_test_case('vsseg3e16_v_u16mf2x3', vl=3, n_segs=3),
            make_test_case('vsseg3e16_v_u16m1x3', vl=8, n_segs=3),
            make_test_case('vsseg3e16_v_u16m1x3', vl=7, n_segs=3),
            make_test_case('vsseg3e16_v_u16m2x3', vl=16, n_segs=3),
            make_test_case('vsseg3e16_v_u16m2x3', vl=15, n_segs=3),
            # Seg 4
            make_test_case('vsseg4e16_v_u16mf2x4', vl=4, n_segs=4),
            make_test_case('vsseg4e16_v_u16mf2x4', vl=3, n_segs=4),
            make_test_case('vsseg4e16_v_u16m1x4', vl=8, n_segs=4),
            make_test_case('vsseg4e16_v_u16m1x4', vl=7, n_segs=4),
            make_test_case('vsseg4e16_v_u16m2x4', vl=16, n_segs=4),
            make_test_case('vsseg4e16_v_u16m2x4', vl=15, n_segs=4),
            # Seg 5
            make_test_case('vsseg5e16_v_u16mf2x5', vl=4, n_segs=5),
            make_test_case('vsseg5e16_v_u16mf2x5', vl=3, n_segs=5),
            make_test_case('vsseg5e16_v_u16m1x5', vl=8, n_segs=5),
            make_test_case('vsseg5e16_v_u16m1x5', vl=7, n_segs=5),
            # Seg 6
            make_test_case('vsseg6e16_v_u16mf2x6', vl=4, n_segs=6),
            make_test_case('vsseg6e16_v_u16mf2x6', vl=3, n_segs=6),
            make_test_case('vsseg6e16_v_u16m1x6', vl=8, n_segs=6),
            make_test_case('vsseg6e16_v_u16m1x6', vl=7, n_segs=6),
            # Seg 7
            make_test_case('vsseg7e16_v_u16mf2x7', vl=4, n_segs=7),
            make_test_case('vsseg7e16_v_u16mf2x7', vl=3, n_segs=7),
            make_test_case('vsseg7e16_v_u16m1x7', vl=8, n_segs=7),
            make_test_case('vsseg7e16_v_u16m1x7', vl=7, n_segs=7),
            # Seg 8
            make_test_case('vsseg8e16_v_u16mf2x8', vl=4, n_segs=8),
            make_test_case('vsseg8e16_v_u16mf2x8', vl=3, n_segs=8),
            make_test_case('vsseg8e16_v_u16m1x8', vl=8, n_segs=8),
            make_test_case('vsseg8e16_v_u16m1x8', vl=7, n_segs=8),
        ],
        dtype = np.uint16,
    )



@cocotb.test()
async def store32_seg_unit(dut):
    """Test vsseg*e32 usage accessible from intrinsics."""
    def make_test_case(impl: str, vl: int, n_segs: int):
        return {
            'impl': impl,
            'vl': vl,
            'in_size': vl * n_segs * 2,
            'out_size': vl * n_segs * 2,
            'pattern': [
                seg * vl + elem
                for elem in range(vl) for seg in range(n_segs)]
        }

    await vector_load_store_v2(
        dut = dut,
        elf_name = 'store32_seg_unit.elf',
        cases = [
            # Seg 2
            make_test_case('vsseg2e32_v_u32m1x2', vl=4, n_segs=2),
            make_test_case('vsseg2e32_v_u32m1x2', vl=3, n_segs=2),
            make_test_case('vsseg2e32_v_u32m2x2', vl=8, n_segs=2),
            make_test_case('vsseg2e32_v_u32m2x2', vl=7, n_segs=2),
            make_test_case('vsseg2e32_v_u32m4x2', vl=16, n_segs=2),
            make_test_case('vsseg2e32_v_u32m4x2', vl=15, n_segs=2),
            # Seg 3
            make_test_case('vsseg3e32_v_u32m1x3', vl=4, n_segs=3),
            make_test_case('vsseg3e32_v_u32m1x3', vl=3, n_segs=3),
            make_test_case('vsseg3e32_v_u32m2x3', vl=8, n_segs=3),
            make_test_case('vsseg3e32_v_u32m2x3', vl=7, n_segs=3),
            # Seg 4
            make_test_case('vsseg4e32_v_u32m1x4', vl=4, n_segs=4),
            make_test_case('vsseg4e32_v_u32m1x4', vl=3, n_segs=4),
            make_test_case('vsseg4e32_v_u32m2x4', vl=8, n_segs=4),
            make_test_case('vsseg4e32_v_u32m2x4', vl=7, n_segs=4),
            # Seg 5
            make_test_case('vsseg5e32_v_u32m1x5', vl=4, n_segs=5),
            make_test_case('vsseg5e32_v_u32m1x5', vl=3, n_segs=5),
            # Seg 6
            make_test_case('vsseg6e32_v_u32m1x6', vl=4, n_segs=6),
            make_test_case('vsseg6e32_v_u32m1x6', vl=3, n_segs=6),
            # Seg 7
            make_test_case('vsseg7e32_v_u32m1x7', vl=4, n_segs=7),
            make_test_case('vsseg7e32_v_u32m1x7', vl=3, n_segs=7),
            # Seg 8
            make_test_case('vsseg8e32_v_u32m1x8', vl=4, n_segs=8),
            make_test_case('vsseg8e32_v_u32m1x8', vl=3, n_segs=8),
        ],
        dtype = np.uint32,
    )


@cocotb.test()
async def load_store8_test(dut):
    """Testbench to test RVV load."""
    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    await fixture.load_elf_and_lookup_symbols(
        r.Rlocation('kelvin_hw/tests/cocotb/rvv/load_store/load_store8_test.elf'),
        ['buffer', 'in_ptr', 'out_ptr', 'vl'],
    )

    vl = 16
    input_data = np.random.randint(0, 255, vl, dtype=np.uint8)
    target_in_addr = fixture.symbols['buffer'] + 16
    target_out_addr = fixture.symbols['buffer'] + 64

    await fixture.core_mini_axi.write(target_in_addr, input_data)
    await fixture.write('in_ptr', np.array([target_in_addr], dtype=np.uint32))
    await fixture.write('out_ptr', np.array([target_out_addr], dtype=np.uint32))
    await fixture.write('vl', np.array([vl], dtype=np.uint32))

    await fixture.run_to_halt()

    routputs = (await fixture.core_mini_axi.read(target_out_addr, vl)).view(
        np.uint8)
    assert (input_data == routputs).all()
