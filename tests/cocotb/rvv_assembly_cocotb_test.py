import cocotb
import numpy as np
from kelvin_test_utils.core_mini_axi_interface import CoreMiniAxiInterface
from bazel_tools.tools.python.runfiles import runfiles

@cocotb.test()
async def core_mini_rvv_load(dut):
    """Testbench to test RVV load intrinsics.

    This test loads 16 bytes of data and read back from the input address.
    Todo: update the test with store unit.
    """
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    r = runfiles.Create()

    elf_path = r.Rlocation("kelvin_hw/tests/cocotb/rvv/rvv_load.elf")
    num_test_bytes = 16
    intial_pass = True
    if not elf_path:
        raise ValueError("elf_path must consist a valid path")
    with open(elf_path, "rb") as f:
        entry_point = await core_mini_axi.load_elf(f)

    #Write your program inputs
    with open(elf_path, "rb") as f:
        input_1_addr = core_mini_axi.lookup_symbol(f, "input_1")
        output_1_addr = core_mini_axi.lookup_symbol(f, "output_1")

    for data_type in [np.int8, np.int16, np.int32]:

        num_bytes = np.dtype(data_type).itemsize
        min_value = np.iinfo(data_type).min
        max_value = np.iinfo(data_type).max
        num_values = int(num_test_bytes / num_bytes)
        input_1_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)
        await core_mini_axi.write(input_1_addr, input_1_data)
        if intial_pass:
            intial_pass = False
            await core_mini_axi.execute_from(entry_point)

        await core_mini_axi.wait_for_wfi()
        routputs = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
        print(f"loaded inputs are {routputs}", flush=True)
        print(f" number of values supposed to be printed {num_values}", flush=True)
        await core_mini_axi.raise_irq()
    await core_mini_axi.wait_for_halted()


@cocotb.test()
async def core_mini_rvv_add(dut):
    """Testbench to test RVV add intrinsics.

    This test loads 16 bytes of data from each input buffer and saved result into a register.

    Todo: update the test with store unit.
    """
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    r = runfiles.Create()

    elf_path = r.Rlocation("kelvin_hw/tests/cocotb/rvv/rvv_add.elf")
    num_test_bytes = 16
    intial_pass = True

    if not elf_path:
      raise ValueError("elf_path must consist a valid path ")
    with open(elf_path, "rb") as f:
      entry_point = await core_mini_axi.load_elf(f)

    #Write your program inputs
    with open(elf_path, "rb") as f:
      input_1_addr = core_mini_axi.lookup_symbol(f, "input_1")
      input_2_addr = core_mini_axi.lookup_symbol(f, "input_2")
      output_1_addr = core_mini_axi.lookup_symbol(f, "output_1")

    # todo ,np.uint8, np.uint16, np.uint32
    for data_type in [np.int8, np.int16, np.int32]:

        num_bytes = np.dtype(data_type).itemsize
        min_value = np.iinfo(data_type).min
        max_value = np.iinfo(data_type).max
        num_values = int(num_test_bytes / num_bytes)
        input_1_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)
        input_2_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)

        await core_mini_axi.write(input_1_addr, input_1_data)
        if intial_pass:
            intial_pass = False
            await core_mini_axi.execute_from(entry_point)
        await core_mini_axi.wait_for_wfi()
        routputs = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
        print(f"loaded inputs are {routputs}", flush=True)
        routputs2 = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
        print(f"loaded inputs are {routputs2}", flush=True)
        print(f" number of values supposed to be printed {num_values}", flush=True)
        await core_mini_axi.raise_irq()
    await core_mini_axi.wait_for_halted()


@cocotb.test()
async def core_mini_vstart_store(dut):
    """Testbench to test vstart store.
    """
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    r = runfiles.Create()

    elf_path = r.Rlocation("kelvin_hw/tests/cocotb/rvv/vstart_store.elf")
    if not elf_path:
        raise ValueError("elf_path must consist a valid path")
    with open(elf_path, "rb") as f:
        entry_point = await core_mini_axi.load_elf(f)

    #Write your program inputs
    with open(elf_path, "rb") as f:
        input_addr = core_mini_axi.lookup_symbol(f, "input_data")
        output_addr = core_mini_axi.lookup_symbol(f, "output_data")

    input_data = np.random.randint(
        np.iinfo(np.uint8).min, np.iinfo(np.uint8).max, 16, dtype=np.uint8)
    await core_mini_axi.write(input_addr, input_data)
    await core_mini_axi.write(output_addr, np.zeros(16, dtype=np.uint8))

    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_wfi()

    output_data = (await core_mini_axi.read(output_addr, 16)).view(np.uint8)

    # vstart is 4, so first 4 elements are skipped.
    # 12 elements are stored.
    assert np.array_equal(output_data[0:4], np.zeros(4, dtype=np.uint8))
    assert np.array_equal(output_data[4:], input_data[4:])

    await core_mini_axi.raise_irq()
    await core_mini_axi.wait_for_halted()


@cocotb.test()
async def core_mini_vcsr_test(dut):
    """Testbench to test vstart store.
    """
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    r = runfiles.Create()

    elf_path = r.Rlocation("kelvin_hw/tests/cocotb/rvv/vcsr_test.elf")
    if not elf_path:
        raise ValueError("elf_path must consist a valid path")
    with open(elf_path, "rb") as f:
        entry_point = await core_mini_axi.load_elf(f)
        vma_addr = core_mini_axi.lookup_symbol(f, "vma")
        vta_addr = core_mini_axi.lookup_symbol(f, "vta")
        sew_addr = core_mini_axi.lookup_symbol(f, "sew")
        lmul_addr = core_mini_axi.lookup_symbol(f, "lmul")
        vl_addr = core_mini_axi.lookup_symbol(f, "vl")
        vtype_addr = core_mini_axi.lookup_symbol(f, "vtype")

    SEWS = [
        0b000,  # SEW8
        0b001,  # SEW16
        0b010,  # SEW32
    ]

    LMULS = [
        0b101,  # LMUL1/8
        0b110,  # LMUL1/4
        0b111,  # LMUL1/2
        0b000,  # LMUL1
        0b001,  # LMUL2
        0b010,  # LMUL4
        0b011,  # LMUL8
    ]

    for ma in range(2):
      for ta in range(2):
        for sew in SEWS:
          for lmul in LMULS:
            await core_mini_axi.write_word(vma_addr, ma)
            await core_mini_axi.write_word(vta_addr, ta)
            await core_mini_axi.write_word(sew_addr, sew)
            await core_mini_axi.write_word(lmul_addr, lmul)
            # TODO(derekjchow): Pick random VL
            await core_mini_axi.write_word(vl_addr, 1)

            await core_mini_axi.execute_from(entry_point)
            await core_mini_axi.wait_for_halted()

            vtype_result = (
                await core_mini_axi.read_word(vtype_addr)).view(np.uint32)[0]
            ma_result = (vtype_result & (1 << 7)) >> 7
            ta_result = (vtype_result & (1 << 6)) >> 6
            sew_result = (vtype_result & (0b111 << 3)) >> 3
            lmul_result = (vtype_result & 0b111)

            assert (ma == ma_result)
            assert (ta == ta_result)
            assert (sew == sew_result)
            assert (lmul == lmul_result)
