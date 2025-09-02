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
import os
import random
import numpy as np
from ftdi_spi_master import FtdiSpiMaster

class SramTestRunner:
    """Runs a SRAM test on the CoralNPU hardware."""

    SRAM_ADDR = 0x20000000
    SRAM_SIZE_BYTES = 16 * 1024  # Test a 16kB block

    def __init__(self, usb_serial, ftdi_port=1):
        """
        Initializes the SramTestRunner.

        Args:
            usb_serial: USB serial number of the FTDI device.
            ftdi_port: Port number of the FTDI device.
        """
        self.spi_master = FtdiSpiMaster(usb_serial, ftdi_port)

    def _generate_data(self):
        """Generates random data to fill the SRAM."""
        print(f"Generating {self.SRAM_SIZE_BYTES} bytes of random data...")
        # Using uint8 for byte-level data
        self.golden_data = np.random.randint(0, 255, size=self.SRAM_SIZE_BYTES, dtype=np.uint8)
        print("Test data generated.")

    def run_test(self):
        """Executes the full SRAM test flow."""
        # TODO(atv): Re-enable this when toggling POR through FTDI doesn't break DDR.
        # self.spi_master.device_reset()
        self.spi_master.idle_clocking(20)
        self._generate_data()

        # 1. Load random data into SRAM
        print(f"Loading {self.SRAM_SIZE_BYTES} bytes to SRAM at 0x{self.SRAM_ADDR:x}")
        self.spi_master.load_data(self.golden_data.tobytes(), self.SRAM_ADDR)

        # 2. Retrieve the entire 256-byte page for verification
        print(f"\nReading {self.SRAM_SIZE_BYTES} bytes for verification from 0x{self.SRAM_ADDR:x}")
        result_data = self.spi_master.read_data(self.SRAM_ADDR, self.SRAM_SIZE_BYTES)

        # 3. Compare with the golden result
        result_array = np.frombuffer(result_data, dtype=self.golden_data.dtype)

        print("\nVerifying result...")
        if np.array_equal(self.golden_data, result_array):
            print("TEST PASSED: Verified 16kB memory.")
        else:
            print("TEST FAILED: SRAM data does not match golden reference.")
            mismatch_indices = np.where(self.golden_data != result_array)[0]
            print(f"Found {len(mismatch_indices)} mismatched bytes in the {self.SRAM_SIZE_BYTES}-byte block.")
            for i in range(min(10, len(mismatch_indices))): # Print first 10 mismatches
                idx = mismatch_indices[i]
                print(f"  Mismatch at index {idx}: "
                      f"Golden=0x{self.golden_data[idx]:02x}, "
                      f"Read=0x{result_array[idx]:02x}")


def main():
    parser = argparse.ArgumentParser(description="Run SRAM test on CoralNPU.")
    parser.add_argument("--usb-serial", required=True, help="USB serial number of the FTDI device.")
    parser.add_argument("--ftdi-port", type=int, default=1, help="Port number of the FTDI device.")
    args = parser.parse_args()

    try:
        runner = SramTestRunner(args.usb_serial, args.ftdi_port)
        runner.run_test()
    except (ValueError, FileNotFoundError) as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()

