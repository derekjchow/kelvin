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

load("@coralnpu_hw//rules:vcs.bzl", "vcs_systemc_binary")

package(default_visibility = ["//visibility:public"])

vcs_systemc_binary(
    name = "core_mini_axi_sim",
    module = "CoreMiniAxi",
    portmap = "core_mini_axi.map",
    systemc_deps = [
        "@libsystemctlm_soc//:libsystemctlm_soc",
        "//tests/verilator_sim:elf",
        "//tests/systemc:Xbar",
        "//tests/systemc:instruction_trace",
    ],
    systemc_srcs = [
        "top.cc",
        "main.cc",
    ],
    verilog_deps = [
        "//hdl/chisel/src/coralnpu:core_mini_axi_cc_library_verilog",
    ],
    verilog_srcs = [
        "//internal/syn/libs/tsmc12ffc:ts1n12ffcllsblvtd512x128m4swbsho_130b/VERILOG/ts1n12ffcllsblvtd512x128m4swbsho_130b.v",
        "//internal/syn/libs/tsmc12ffc:ts1n12ffcllmblvtd2048x128m4swbsho_130d/VERILOG/ts1n12ffcllmblvtd2048x128m4swbsho_130d.v",
        "//internal/syn/libs/tsmc12ffc:tcbn12ffcllbwp6t20p96cpdlvt.v",
    ],
    build_args = [
        "+define+TSMC_INITIALIZE_MEM_USING_DEFAULT_TASKS",
        "+define+TSMC_MEM_LOAD_RANDOM",
    ],
)
