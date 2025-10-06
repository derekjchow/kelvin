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

load("@coralnpu_hw//rules:chisel.bzl", "chisel_cc_library", "chisel_library")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "matcha",
    srcs = [
        "Axi2Sram.scala",
        "Crossbar.scala",
        "CoralNPU.scala",
        "MatchaParameters.scala",
    ],
    deps = [
        "//hdl/chisel/src/bus:bus",
        "//hdl/chisel/src/common:common",
        "//hdl/chisel/src/coralnpu:clock_gate",
        "//hdl/chisel/src/coralnpu:coralnpu",
        "//hdl/chisel/src/coralnpu:coralnpu_base",
    ],
)

chisel_cc_library(
    name = "coralnpu_cc_library",
    chisel_lib = ":matcha",
    emit_class = "matcha.EmitCoralNPU",
    module_name = "CoralNPU",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
        "//hdl/verilog:sram_1rw_256x288",
    ],
    extra_outs = [
        "VCoralNPU_parameters.h",
    ],
    vopts = [
        "-DUSE_GENERIC",
    ],
)

chisel_cc_library(
    name = "coralnpu_scalar_cc_library",
    chisel_lib = ":matcha",
    emit_class = "matcha.EmitCoralNPU",
    module_name = "CoralNPUScalar",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
        "//hdl/verilog:sram_1rw_256x288",
    ],
    verilog_file_path = "CoralNPUScalar.sv",
    gen_flags = [
        "--enableVector=False",
        "--moduleName=CoralNPUScalar",
    ],
    extra_outs = [
        "VCoralNPUScalar_parameters.h",
    ],
    vopts = [
        "-DUSE_GENERIC",
    ],
)

chisel_cc_library(
    name = "coralnpu_mini_cc_library",
    chisel_lib = ":matcha",
    emit_class = "matcha.EmitCoralNPU",
    module_name = "CoralNPUMini",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
        "//hdl/verilog:sram_1rw_256x288",
    ],
    verilog_file_path = "CoralNPUMini.sv",
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--moduleName=CoralNPUMini",
    ],
    extra_outs = [
        "VCoralNPUMini_parameters.h",
    ],
    vopts = [
        "-DUSE_GENERIC",
    ],
)

chisel_cc_library(
    name = "crossbar_cc_library",
    chisel_lib = ":matcha",
    emit_class = "matcha.EmitCrossbar",
    module_name = "Crossbar",
)
