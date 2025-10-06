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
import argparse
from coralnpu_test_utils.core_mini_axi_interface import CoreMiniAxiInterface
from bazel_tools.tools.python.runfiles import runfiles

@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your CoralNPU program."""
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
    r = runfiles.Create()

    #Elf file is generated from bazel build //examples:coralnpu_v2_hello_world_add_floats
    elf_path = r.Rlocation("coralnpu_hw/examples/coralnpu_v2_hello_world_add_floats.elf")
    if not elf_path:
      raise ValueError("elf_path must consist a valid path ")
    #Load your program into ITCM with "load_elf"
    with open(elf_path, "rb") as f:
      entry_point = await core_mini_axi.load_elf(f)

    #Write your program inputs
    with open(elf_path, "rb") as f:
      inputs1_addr = core_mini_axi.lookup_symbol(f, "input1")
      inputs2_addr = core_mini_axi.lookup_symbol(f, "input2")
      outputs_addr = core_mini_axi.lookup_symbol(f, "output")

    # this example is passing inputs from dctm instead of defining in memory.
    input1_data = np.arange(1,9, dtype=np.float32)
    input2_data = 0.213 * np.ones(8, dtype=np.float32)

    await core_mini_axi.write(inputs1_addr, input1_data)
    await core_mini_axi.write(inputs2_addr, input2_data)
    rinput1 = (await core_mini_axi.read(inputs1_addr, 4 * 8)).view(np.float32)
    rinput2 = (await core_mini_axi.read(inputs2_addr, 4 * 8)).view(np.float32)
    print(f"Reading input1 values : {rinput1}")
    print(f"Reading input2 values : {rinput2}")

    #Run your program and wait for halted
    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_halted()
    #Read your program outputs and print the result
    expected = input1_data + input2_data
    routputs = (await core_mini_axi.read(outputs_addr, 4 * 8)).view(np.float32)
    print(f"outputs are {routputs}")
    rinput1 = (await core_mini_axi.read(inputs1_addr, 4 * 8)).view(np.float32)
    rinput2 = (await core_mini_axi.read(inputs2_addr, 4 * 8)).view(np.float32)
    #check for correctness
    for idx in range(len(routputs)):
      if expected[idx] == routputs[idx]:
        continue
      else:
        raise ValueError(f"expected value at {idx} doesn't with result {expected[idx]} vs {routputs[idx]}")
    print(f"Outputs from program {routputs}")

