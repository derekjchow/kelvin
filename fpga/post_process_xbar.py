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
"""A script to post-process the output of tlgen.

This script takes an input directory and an output directory. It copies the
contents of the input directory to the output directory, and then modifies the
generated SystemVerilog file to use the correct TileLink types.
"""

import argparse
import os
import re
import shutil
import stat


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input-dir",
        required=True,
        help="The input directory.",
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        help="The output directory.",
    )
    parser.add_argument(
        "--cores",
        nargs="+",
        required=True,
        help="The cores to add as dependencies.",
    )
    args = parser.parse_args()

    # Copy the contents of the input directory to the output directory.
    if os.path.exists(args.output_dir):
        shutil.rmtree(args.output_dir)
    shutil.copytree(args.input_dir, args.output_dir)

    # Find the generated SystemVerilog file.
    sv_file = None
    for root, _, files in os.walk(args.output_dir):
        for f in files:
            if f == "xbar_kelvin_soc_xbar.sv":
                sv_file = os.path.join(root, f)
                break
        if sv_file:
            break

    if sv_file is None:
        raise RuntimeError("Could not find generated SystemVerilog file.")

    # Make the file writable.
    os.chmod(sv_file, stat.S_IWRITE | stat.S_IREAD)

    # Read the file and perform the replacements.
    with open(sv_file, "r") as f:
        content = f.read()
    original_content = content
    content = content.replace("tlul_pkg::tl_h2d_t",
                              "kelvin_tlul_pkg_128::tl_h2d_t")
    content = content.replace("tlul_pkg::tl_d2h_t",
                              "kelvin_tlul_pkg_128::tl_d2h_t")
    content = content.replace("import tlul_pkg::*",
                              "import kelvin_tlul_pkg_128::*")
    content = content.replace("tlul_socket_1n #", "tlul_socket_1n_128 #")
    content = content.replace("tlul_socket_m1 #", "tlul_socket_m1_128 #")
    content = content.replace("tlul_fifo_async #", "tlul_fifo_async_128 #")

    if original_content == content:
        print("Warning: No replacements made.")
    else:
        print("Success: Replacements made.")

    with open(sv_file, "w") as f:
        f.write(content)

    core_file = None
    for root, _, files in os.walk(args.output_dir):
        for f in files:
            if f == "xbar_kelvin_soc_xbar.core":
                core_file = os.path.join(root, f)
                break
            if core_file:
                break
    if core_file is None:
        raise RuntimeError("Could not find generated core file.")
    os.chmod(core_file, stat.S_IWRITE | stat.S_IREAD)
    with open(core_file, "r") as f:
        content = f.read()
    original_content = content
    for core in args.cores:
        content = re.sub(r"(\s+)depend:", r"\1depend:\n\1  - " + core, content)
    if original_content == content:
        print("Warning: No replacements made (core).")
    else:
        print("Success: replacesments made (core).")
    with open(core_file, "w") as f:
        f.write(content)


if __name__ == "__main__":
    main()
