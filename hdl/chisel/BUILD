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
    name = "matcha_coralnpu_verilog",
    srcs = [
        "//hdl/chisel/src/matcha:CoralNPU.sv",
        "//hdl/chisel/src/matcha:Crossbar.sv",
        "//hdl/verilog:ClockGate.sv",
        "//hdl/verilog:Sram_1rw_256x256.v",
        "//hdl/verilog:Sram_1rwm_256x288.v",
    ],
    outs = [
        "coralnpu.sv",
        "crossbar.sv",
        "ClockGate.sv",
        "Sram_1rw_256x256.v",
        "Sram_1rwm_256x288.v",
    ],
    # Prepend extra definition on CoralNPU.v for DV. Collect other verilog files
    # to the GenDir so they can be referenced by coralnpu.core.
    cmd = """
    echo "\\`define STOP_COND 0
\\`define PRINTF_COND 0
\\`define ASSERT_VERBOSE_COND 0
" > $(location coralnpu.sv)
    cat $(location //hdl/chisel/src/matcha:CoralNPU.sv) >> $(location coralnpu.sv)
    echo "\\`define STOP_COND 0
\\`define PRINTF_COND 0
\\`define ASSERT_VERBOSE_COND 0
" > $(location crossbar.sv)
    cat $(location //hdl/chisel/src/matcha:Crossbar.sv) >> $(location crossbar.sv)
    cp -f $(location //hdl/verilog:ClockGate.sv) $(location ClockGate.sv)
    cp -f $(location //hdl/verilog:Sram_1rw_256x256.v) $(location Sram_1rw_256x256.v)
    cp -f $(location //hdl/verilog:Sram_1rwm_256x288.v) $(location Sram_1rwm_256x288.v)
    """,
    visibility = ["//visibility:public"],
)

# Generate coralnpu.core from this template so it can sit at the same GenDir as
# the RTL files.
genrule(
    name = "coralnpu_core",
    srcs = [
        "crossbar.core.in",
        "coralnpu.core.in",
        "matcha_coralnpu_verilog",
    ],
    outs = [
        "crossbar.core",
        "coralnpu.core",
    ],
    cmd = """
    cp -f $(location coralnpu.core.in) $(location coralnpu.core)
    cp -f $(location crossbar.core.in) $(location crossbar.core)
    """,
    visibility = ["//visibility:public"],
)
