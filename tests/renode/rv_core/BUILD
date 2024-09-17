# Copyright 2024 Google LLC
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

genrule(
    name = "rv_core_bins",
    srcs = [
        "build.sh",
        "kelvin_hello_world.c",
        "kelvin_hello_world_cc.h",
        "kelvin_start.S",
        "kelvin_tcm.ld",
        "link.ld",
        "main.cc",
        "start.S",
    ],
    outs = [
        "rv_core.elf",
    ],
    cmd = """
        $(location :build.sh) $(location :rv_core.elf)
    """,
    executable = False,
    local = True,
)

sh_test(
    name = "rv_core",
    size = "small",
    srcs = [
        "//tests/renode/rv_core:robot.sh",
    ],
    data = glob(["rv_core/**"]) + [
        "//tests/renode:stty",
        "//tests/renode:Vtop_bin",
        "//tests/renode:kelvin-verilator.resc",
        "//tests/renode:kelvin-verilator.repl",
        "//tests/renode:Vtop_master",
        "//tests/renode:Vtop_slave",
        "//tests/renode/rv_core:rv_core.elf",
        "//tests/renode/rv_core:rv_core.robot",
    ],
    local = True,
)
