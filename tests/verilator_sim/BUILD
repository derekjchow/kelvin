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

cc_library(
    name = "sim_libs",
    hdrs = [
        "fifo.h",
        "sysc_module.h",
        "sysc_tb.h",
    ],
    includes = [
        "systemc/include",
    ],
    deps = [
        "@accellera_systemc//:systemc",
    ],
)

cc_library(
    name = "kelvin_if",
    hdrs = [
        "kelvin/core_if.h",
        "kelvin/debug_if.h",
        "kelvin/kelvin_cfg.h",
        "kelvin/memory_if.h",
    ],
    defines = ["KELVIN_SIMD=256"],
)

cc_binary(
    name = "core_sim",
    srcs = [
        "kelvin/core_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:core_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_binary(
    name = "kelvin_tb",
    srcs = [
        "matcha/kelvin_if.h",
        "matcha/kelvin_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/matcha:kelvin_cc_library",
    ],
)

cc_test(
    name = "dbus2axi_tb",
    size = "small",
    srcs = [
        "kelvin/dbus2axi_tb.cc",
    ],
    deps = [
        ":sim_libs",
        "//hdl/chisel/src/kelvin:dbus2axi_cc_library",
    ],
)

cc_test(
    name = "l1dcache_tb",
    size = "large",
    srcs = [
        "kelvin/l1dcache_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:l1dcache_cc_library",
    ],
)

cc_test(
    name = "l1dcachebank_tb",
    srcs = [
        "kelvin/l1dcache_tb.cc",
    ],
    defines = [
        "L1DCACHEBANK",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:l1dcachebank_cc_library",
    ],
)

cc_test(
    name = "l1icache_tb",
    srcs = [
        "kelvin/l1icache_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:l1icache_cc_library",
    ],
)

cc_library(
    name = "valu",
    hdrs = [
        "kelvin/alu_ref.h",
        "kelvin/valu.h",
    ],
    deps = [
        ":vencodeop",
    ],
)

cc_test(
    name = "valu_tb",
    size = "large",
    srcs = [
        "kelvin/valu_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":valu",
        "//hdl/chisel/src/kelvin:valu_cc_library",
    ],
)

cc_test(
    name = "valuint_tb",
    size = "large",
    srcs = [
        "kelvin/valuint_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":valu",
        "//hdl/chisel/src/kelvin:valuint_cc_library",
    ],
)

cc_library(
    name = "vdecode",
    hdrs = [
        "kelvin/vdecode.h",
    ],
    deps = [
        ":vdecodeop",
        ":vencodeop",
    ],
)

cc_library(
    name = "vdecodeop",
    hdrs = [
        "kelvin/vdecodeop.h",
    ],
)

cc_library(
    name = "vencodeop",
    hdrs = [
        "kelvin/vencodeop.h",
    ],
)

cc_test(
    name = "vcmdq_tb",
    srcs = [
        "kelvin/vcmdq_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel/src/kelvin:vcmdq_cc_library",
    ],
)

cc_test(
    name = "vconvalu_tb",
    srcs = [
        "kelvin/vconvalu_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:vconvalu_cc_library",
    ],
)

cc_test(
    name = "vconvctrl_tb",
    size = "small",
    srcs = [
        "kelvin/vconvctrl_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel/src/kelvin:vconvctrl_cc_library",
    ],
)

cc_test(
    name = "vdecodeinstruction_tb",
    size = "small",
    srcs = [
        "kelvin/vdecodeinstruction_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vdecode",
        "//hdl/chisel/src/kelvin:vdecodeinstruction_cc_library",
    ],
)

cc_test(
    name = "vdecode_tb",
    srcs = [
        "kelvin/vdecode_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vdecode",
        "//hdl/chisel/src/kelvin:vdecode_cc_library",
    ],
)

cc_test(
    name = "vldst_tb",
    srcs = [
        "kelvin/vldst_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel/src/kelvin:vldst_cc_library",
    ],
)

cc_test(
    name = "vld_tb",
    size = "small",
    srcs = [
        "kelvin/vld_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel/src/kelvin:vld_cc_library",
    ],
)

cc_test(
    name = "vregfilesegment_tb",
    size = "small",
    srcs = [
        "kelvin/vregfilesegment_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:vregfilesegment_cc_library",
    ],
)

cc_test(
    name = "vregfile_tb",
    srcs = [
        "kelvin/vregfile_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel/src/kelvin:vregfile_cc_library",
    ],
)

cc_test(
    name = "vst_tb",
    srcs = [
        "kelvin/vst_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel/src/kelvin:vst_cc_library",
    ],
)
