import cocotb
import numpy as np

from kelvin_test_utils.core_mini_axi_interface import CoreMiniAxiInterface

class Fixture:
    def __init__(self, dut):
        self.core_mini_axi = CoreMiniAxiInterface(dut)
        self.entry_point = None
        self.symbols = {}

    @classmethod
    async def Create(cls, dut):
        inst = cls(dut)
        await inst.core_mini_axi.init()
        await inst.core_mini_axi.reset()
        cocotb.start_soon(inst.core_mini_axi.clock.start())
        return inst

    async def load_elf_and_lookup_symbols(
        self,
        path: str,
        symbols: list[str],
    ):
        await self.core_mini_axi.reset()
        with open(path, "rb") as f:
            self.entry_point = await self.core_mini_axi.load_elf(f)
            self.symbols = {
                s: self.core_mini_axi.lookup_symbol(f, s)
                for s in symbols
            }

    async def write(self, symbol: str, data):
        await self.core_mini_axi.write(self.symbols[symbol], data)

    async def read(self, symbol: str, size: int):
        return await self.core_mini_axi.read(self.symbols[symbol], size)

    async def run_to_halt(self):
        await self.core_mini_axi.execute_from(self.entry_point)
        await self.core_mini_axi.wait_for_halted()


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
        '../tests/cocotb/rvv/' + elf_name,
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

# TODO: enable this test once stride fix is in.
# @cocotb.test()
async def load16_stride4_mf2(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load16_stride4_mf2.elf',
        dtype = np.uint16,
        in_size = 16,
        out_size = 8,
        pattern = [0, 2, 4, 6],
    )

# TODO: enable this test once stride fix is in.
# @cocotb.test()
async def load32_stride8_m1(dut):
    await vector_load_store(
        dut = dut,
        elf_name = 'load32_stride8_m1.elf',
        dtype = np.uint32,
        in_size = 8,
        out_size = 4,
        pattern = [0, 2, 4, 6],
    )
