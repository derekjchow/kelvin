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

load("@kelvin_hw//rules:chisel.bzl", "chisel_cc_library", "chisel_library")

chisel_library(
    name = "common",
    srcs = glob(["src/common/*.scala"]),
)

chisel_library(
    name = "kelvin",
    srcs = glob(["src/kelvin/**/*.scala"]),
    deps = [
        ":common",
    ],
)

chisel_library(
    name = "matcha",
    srcs = glob(["src/matcha/**/*.scala"]),
    deps = [
        ":common",
        ":kelvin",
    ],
)

chisel_cc_library(
    name = "kelvin_cc_library",
    chisel_lib = ":matcha",
    emit_class = "matcha.EmitKelvin",
    module_name = "Kelvin",
    verilog_deps = [
        "//hdl/verilog:clock_gate",
        "//hdl/verilog:sram_1rw_256x256",
        "//hdl/verilog:sram_1rw_256x288",
    ],
)

chisel_cc_library(
    name = "core_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    module_name = "Core",
)

chisel_cc_library(
    name = "dbus2axi_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitDBus2Axi",
    module_name = "DBus2Axi",
)

chisel_cc_library(
    name = "l1dcache_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitL1DCache",
    module_name = "L1DCache",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x288",
    ],
)

chisel_cc_library(
    name = "l1dcachebank_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitL1DCacheBank",
    module_name = "L1DCacheBank",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x288",
    ],
)

chisel_cc_library(
    name = "l1icache_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitL1ICache",
    module_name = "L1ICache",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
    ],
)

chisel_cc_library(
    name = "valu_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVAlu",
    module_name = "VAlu",
)

chisel_cc_library(
    name = "valuint_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVAluInt",
    module_name = "VAluInt",
)

chisel_cc_library(
    name = "vcmdq_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVCmdq",
    module_name = "VCmdq",
)

chisel_cc_library(
    name = "vconvalu_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVConvAlu",
    module_name = "VConvAlu",
)

chisel_cc_library(
    name = "vconvctrl_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVConvCtrl",
    module_name = "VConvCtrl",
)

chisel_cc_library(
    name = "vdecode_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVDecode",
    module_name = "VDecode",
)

chisel_cc_library(
    name = "vdecodeinstruction_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVDecodeInstruction",
    module_name = "VDecodeInstruction",
)

chisel_cc_library(
    name = "vldst_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVLdSt",
    module_name = "VLdSt",
)

chisel_cc_library(
    name = "vld_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVLd",
    module_name = "VLd",
)

chisel_cc_library(
    name = "vregfile_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVRegfile",
    module_name = "VRegfile",
)

chisel_cc_library(
    name = "vregfilesegment_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVRegfileSegment",
    module_name = "VRegfileSegment",
)

chisel_cc_library(
    name = "vst_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitVSt",
    module_name = "VSt",
)

genrule(
    name = "matcha_kelvin_verilog",
    srcs = [
        ":Kelvin.sv",
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
" > $(location kelvin.sv)
    cat $(location Kelvin.sv) >> $(location kelvin.sv)
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
