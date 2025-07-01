import cocotb
import numpy as np
import argparse
from kelvin_test_utils.core_mini_axi_interface import CoreMiniAxiInterface

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

    elf_path = "../tests/cocotb/rvv/rvv_load2.elf"
    with open(elf_path, "rb") as f:
        entry_point = await core_mini_axi.load_elf(f)
        input_1_addr = core_mini_axi.lookup_symbol(f, "input_1")
        output_1_addr = core_mini_axi.lookup_symbol(f, "output_1")

    await core_mini_axi.write(input_1_addr, np.arange(32, dtype=np.uint8))
    await core_mini_axi.write(output_1_addr, np.zeros(32, dtype=np.uint8))
    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_wfi()
    routputs = (await core_mini_axi.read(output_1_addr, 32)).view(np.uint8)
    print(routputs, flush=True)

# @cocotb.test()
# async def core_mini_rvv_load(dut):
#     """Testbench to test RVV load intrinsics.

#     This test loads 16 bytes of data and read back from the input address.
#     Todo: update the test with store unit.
#     """
#     # Test bench setup
#     core_mini_axi = CoreMiniAxiInterface(dut)
#     await core_mini_axi.init()
#     await core_mini_axi.reset()
#     cocotb.start_soon(core_mini_axi.clock.start())

#     elf_path = "../tests/cocotb/rvv/rvv_load.elf"
#     num_test_bytes = 16
#     intial_pass = True
#     if not elf_path:
#         raise ValueError("elf_path must consist a valid path")
#     with open(elf_path, "rb") as f:
#         entry_point = await core_mini_axi.load_elf(f)

#     #Write your program inputs
#     with open(elf_path, "rb") as f:
#         input_1_addr = core_mini_axi.lookup_symbol(f, "input_1")
#         output_1_addr = core_mini_axi.lookup_symbol(f, "output_1")

#     for data_type in [np.int8, np.int16, np.int32]:

#         num_bytes = np.dtype(data_type).itemsize
#         min_value = np.iinfo(data_type).min
#         max_value = np.iinfo(data_type).max
#         num_values = int(num_test_bytes / num_bytes)
#         input_1_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)
#         await core_mini_axi.write(input_1_addr, input_1_data)
#         if intial_pass:
#             intial_pass = False
#             await core_mini_axi.execute_from(entry_point)

#         await core_mini_axi.wait_for_wfi()
#         routputs = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
#         print(f"loaded inputs are {routputs}", flush=True)
#         print(f" number of values supposed to be printed {num_values}", flush=True)
#         await core_mini_axi.raise_irq()
#     await core_mini_axi.wait_for_halted()


# @cocotb.test()
# async def core_mini_rvv_add(dut):
#     """Testbench to test RVV add intrinsics.

#     This test loads 16 bytes of data from each input buffer and saved result into a register.

#     Todo: update the test with store unit.
#     """
#     # Test bench setup
#     core_mini_axi = CoreMiniAxiInterface(dut)
#     await core_mini_axi.init()
#     await core_mini_axi.reset()
#     cocotb.start_soon(core_mini_axi.clock.start())

#     elf_path = "../tests/cocotb/rvv/rvv_add.elf"
#     num_test_bytes = 16
#     intial_pass = True

#     if not elf_path:
#       raise ValueError("elf_path must consist a valid path ")
#     with open(elf_path, "rb") as f:
#       entry_point = await core_mini_axi.load_elf(f)

#     #Write your program inputs
#     with open(elf_path, "rb") as f:
#       input_1_addr = core_mini_axi.lookup_symbol(f, "input_1")
#       input_2_addr = core_mini_axi.lookup_symbol(f, "input_2")
#       output_1_addr = core_mini_axi.lookup_symbol(f, "output_1")

#     # todo ,np.uint8, np.uint16, np.uint32
#     for data_type in [np.int8, np.int16, np.int32]:

#         num_bytes = np.dtype(data_type).itemsize
#         min_value = np.iinfo(data_type).min
#         max_value = np.iinfo(data_type).max
#         num_values = int(num_test_bytes / num_bytes)
#         input_1_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)
#         input_2_data = np.random.randint(min_value, max_value, num_values, dtype=data_type)

#         await core_mini_axi.write(input_1_addr, input_1_data)
#         if intial_pass:
#             intial_pass = False
#             await core_mini_axi.execute_from(entry_point)
#         await core_mini_axi.wait_for_wfi()
#         routputs = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
#         print(f"loaded inputs are {routputs}", flush=True)
#         routputs2 = (await core_mini_axi.read(input_1_addr, num_test_bytes)).view(data_type)
#         print(f"loaded inputs are {routputs2}", flush=True)
#         print(f" number of values supposed to be printed {num_values}", flush=True)
#         await core_mini_axi.raise_irq()
#     await core_mini_axi.wait_for_halted()
