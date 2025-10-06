import cocotb
import numpy as np
import argparse

from coralnpu_test_utils.sim_test_fixture import Fixture
from bazel_tools.tools.python.runfiles import runfiles


@cocotb.test()
async def core_mini_rvv_matmul_test(dut):
    """Testbench to test matmul with rvv intrinsics.

    This test performs matmul in M1 16x24 M2 24x16 matrices.
    Compares results with native numpy matmul.
    """

    LHS_ROWS = 16
    RHS_COLS = 16
    INNER = 48

    fixture = await Fixture.Create(dut)
    r = runfiles.Create()
    elf_files = ['rvv_matmul.elf', 'rvv_matmul_assembly.elf']
    for elf_file in elf_files:

        await fixture.load_elf_and_lookup_symbols(
            r.Rlocation('coralnpu_hw/tests/cocotb/rvv/ml_ops/' + elf_file),
            ['lhs_input', 'rhs_input', 'result_output'])
        np_type = np.int8
        min_value = np.iinfo(np_type).min
        max_value = np.iinfo(np_type).max + 1  # One above.
        lhs_data = np.random.randint(min_value,
                                     max_value, [LHS_ROWS, INNER],
                                     dtype=np_type)
        rhs_data = np.random.randint(min_value,
                                     max_value, [INNER, RHS_COLS],
                                     dtype=np_type)
        result_data = np.matmul(lhs_data.astype(np.int32),
                                rhs_data.astype(np.int32))

        await fixture.write('lhs_input', lhs_data.flatten())
        await fixture.write('rhs_input', rhs_data.transpose().flatten())
        await fixture.run_to_halt(timeout_cycles=1000000)
        output_matmul_result = (await fixture.read(
            'result_output', LHS_ROWS * RHS_COLS *
            4)).view(dtype=np.int32).reshape([LHS_ROWS, RHS_COLS])

        assert ((result_data == output_matmul_result).all())
