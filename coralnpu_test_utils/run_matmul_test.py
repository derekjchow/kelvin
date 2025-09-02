#!/usr/bin/env python3
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import numpy as np
from elftools.elf.elffile import ELFFile
from ftdi_spi_master import FtdiSpiMaster

class MatmulRunner:
    """Runs a matrix multiplication test on the CoralNPU hardware."""

    def __init__(self, elf_path, usb_serial, ftdi_port=1):
        """
        Initializes the MatmulRunner.

        Args:
            elf_path: Path to the rvv_matmul.elf file.
            usb_serial: USB serial number of the FTDI device.
            ftdi_port: Port number of the FTDI device.
        """
        self.elf_path = elf_path
        self.spi_master = FtdiSpiMaster(usb_serial, ftdi_port)
        self.addr_lhs = None
        self.addr_rhs = None
        self.addr_result = None
        self.entry_point = None
        self._parse_elf()

    def _parse_elf(self):
        """Parses the ELF file to find symbol addresses and the entry point."""
        print(f"Parsing ELF file: {self.elf_path}")
        with open(self.elf_path, 'rb') as f:
            elf = ELFFile(f)
            self.entry_point = elf.header['e_entry']
            symtab = elf.get_section_by_name('.symtab')
            if not symtab:
                raise ValueError("No symbol table found in ELF file.")

            symbols = {
                'lhs_input': 'addr_lhs',
                'rhs_input': 'addr_rhs',
                'result_output': 'addr_result'
            }
            for sym in symtab.iter_symbols():
                if sym.name in symbols:
                    addr = sym['st_value']
                    setattr(self, symbols[sym.name], addr)
                    print(f"  Found symbol '{sym.name}' at 0x{addr:x}")

        if not all([self.addr_lhs, self.addr_rhs, self.addr_result]) or self.entry_point is None:
            raise ValueError("Could not find all required symbols in ELF file.")

    def _generate_data(self):
        """Generates input matrices and a golden output matrix."""
        # Dimensions from tests/cocotb/rvv/ml_ops/rvv_matmul.cc
        k_lhs_rows = 16
        k_rhs_cols = 16
        k_inner = 48

        print("Generating test data...")
        # Using int8 for the input matrices
        self.lhs_input = np.random.randint(-128, 127, size=(k_lhs_rows, k_inner), dtype=np.int8)
        self.rhs_input = np.random.randint(-128, 127, size=(k_inner, k_rhs_cols), dtype=np.int8)

        # The C++ code performs the matmul as int8*int8 -> int32
        # We need to cast the inputs to a wider type before multiplication to avoid overflow
        golden_lhs = self.lhs_input.astype(np.int32)
        golden_rhs = self.rhs_input.astype(np.int32)
        self.golden_output = np.matmul(golden_lhs, golden_rhs)
        print("Test data generated.")

    def run_test(self):
        """Executes the full matrix multiplication test flow."""
        # TODO(atv): Re-enable this when toggling POR through FTDI doesn't break DDR.
        # self.spi_master.device_reset()
        self.spi_master.idle_clocking(20)
        self._generate_data()

        # 1. Load ELF (without starting the core)
        self.spi_master.load_elf(self.elf_path, start_core=False)

        # 2. Load input matrices into memory
        print(f"Loading LHS matrix ({self.lhs_input.nbytes} bytes) to 0x{self.addr_lhs:x}")
        self.spi_master.load_data(self.lhs_input.tobytes(), self.addr_lhs)

        print(f"Loading RHS matrix ({self.rhs_input.nbytes} bytes) to 0x{self.addr_rhs:x}")
        self.spi_master.load_data(self.rhs_input.flatten(order='F').tobytes(), self.addr_rhs)

        # 3. Start the core
        self.spi_master.set_entry_point(self.entry_point)
        self.spi_master.start_core()

        # 4. Wait for the core to halt
        if not self.spi_master.poll_for_halt(timeout=20.0):
            print("TEST FAILED: Core did not halt.")
            return

        # 5. Retrieve the output matrix
        result_size_bytes = self.golden_output.nbytes
        print(f"Reading result matrix ({result_size_bytes} bytes) from 0x{self.addr_result:x}")
        result_data = self.spi_master.read_data(self.addr_result, result_size_bytes)

        # 6. Compare with the golden result
        result_array = np.frombuffer(result_data, dtype=self.golden_output.dtype)
        result_array = result_array.reshape(self.golden_output.shape)

        print("\nVerifying result...")
        if np.array_equal(self.golden_output, result_array):
            print("TEST PASSED!")
        else:
            print("TEST FAILED: Output does not match golden reference.")
            print("Golden:\n", self.golden_output)
            print("Received:\n", result_array)


def main():
    parser = argparse.ArgumentParser(description="Run Matrix Multiplication test on CoralNPU.")
    parser.add_argument("elf_file", help="Path to the rvv_matmul.elf file.")
    parser.add_argument("--usb-serial", required=True, help="USB serial number of the FTDI device.")
    parser.add_argument("--ftdi-port", type=int, default=1, help="Port number of the FTDI device.")
    args = parser.parse_args()

    try:
        runner = MatmulRunner(args.elf_file, args.usb_serial, args.ftdi_port)
        runner.run_test()
    except (ValueError, FileNotFoundError) as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
