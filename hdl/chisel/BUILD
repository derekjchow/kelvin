# Copyright 2023 Google LLC
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
    name = "matcha_kelvin_verilog",
    srcs = [
        "//hdl/chisel/src/matcha:Kelvin.sv",
        "//hdl/verilog:ClockGate.v",
        "//hdl/verilog:Sram_1rw_256x256.v",
        "//hdl/verilog:Sram_1rwm_256x288.v",
    ],
    outs = [
        "kelvin.sv",
        "ClockGate.v",
        "Sram_1rw_256x256.v",
        "Sram_1rwm_256x288.v",
    ],
    # Prepend extra definition on Kelvin.v for DV. Collect other verilog files
    # to the GenDir so they can be referenced by kelvin.core.
    cmd = """
    echo "\\`define STOP_COND 0
\\`define PRINTF_COND 0
\\`define ASSERT_VERBOSE_COND 0
" > $(location kelvin.sv)
    cat $(location //hdl/chisel/src/matcha:Kelvin.sv) >> $(location kelvin.sv)
    cp -f $(location //hdl/verilog:ClockGate.v) $(location ClockGate.v)
    cp -f $(location //hdl/verilog:Sram_1rw_256x256.v) $(location Sram_1rw_256x256.v)
    cp -f $(location //hdl/verilog:Sram_1rwm_256x288.v) $(location Sram_1rwm_256x288.v)
    """,
    visibility = ["//visibility:public"],
)

# Generate kelvin.core from this template so it can sit at the same GenDir as
# the RTL files.
genrule(
    name = "kelvin_core",
    srcs = [
        "kelvin.core.in",
        "matcha_kelvin_verilog",
    ],
    outs = ["kelvin.core"],
    cmd = "cp -f $(location kelvin.core.in) $@",
    visibility = ["//visibility:public"],
)
