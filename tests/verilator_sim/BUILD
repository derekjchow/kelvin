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

load("//rules:utils.bzl", "template_rule")

cc_library(
    name = "elf",
    srcs = [
        "elf.cc",
    ],
    hdrs = [
        "elf.h",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "util",
    hdrs = [
        "util.h",
    ],
)

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
    name = "coralnpu_if",
    hdrs = [
        "coralnpu/core_if.h",
        "coralnpu/debug_if.h",
        "coralnpu/coralnpu_cfg.h",
        "coralnpu/memory_if.h",
    ],
    defines = ["CORALNPU_SIMD=256"],
)

cc_binary(
    name = "core_sim",
    srcs = [
        "coralnpu/core_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCore",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        "//hdl/chisel/src/coralnpu:core_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_SRCS = [
    "coralnpu/core_mini_axi_tb.cc",
]

CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_DEPS = [
    ":elf",
    ":sim_libs",
    ":util",
    "//tests/systemc:Xbar",
    "//tests/systemc:instruction_trace",
    "@accellera_systemc//:systemc",
    "@com_google_absl//absl/log",
    "@com_google_absl//absl/log:check",
    "@com_google_absl//absl/log:initialize",
    "@com_google_absl//absl/status",
    "@libsystemctlm_soc",
]

template_rule(
    cc_library,
    {
        "core_mini_axi_tb": {
            "srcs": [
                "@coralnpu_hw//hdl/chisel/src/coralnpu:VCoreMiniAxi_parameters.h",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_SRCS,
            "deps": [
                "//hdl/chisel/src/coralnpu:core_mini_axi_cc_library",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_DEPS,
            "defines": [
                "VERILATOR_MODEL=VCoreMiniAxi",
            ],
        },
        "core_mini_verification_axi_tb": {
            "srcs": [
                "@coralnpu_hw//hdl/chisel/src/coralnpu:VCoreMiniVerificationAxi_parameters.h",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_SRCS,
            "deps": [
                "//hdl/chisel/src/coralnpu:core_mini_verification_axi_cc_library",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_DEPS,
            "defines": [
                "VERILATOR_MODEL=VCoreMiniVerificationAxi",
            ],
        },
        "rvv_core_mini_axi_tb": {
            "srcs": [
                "@coralnpu_hw//hdl/chisel/src/coralnpu:VRvvCoreMiniAxi_parameters.h",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_SRCS,
            "deps": [
                "//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_DEPS,
            "defines": [
                "VERILATOR_MODEL=VRvvCoreMiniAxi",
            ],
        },
        "rvv_core_mini_verification_axi_tb": {
            "srcs": [
                "@coralnpu_hw//hdl/chisel/src/coralnpu:VRvvCoreMiniVerificationAxi_parameters.h",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_SRCS,
            "deps": [
                "//hdl/chisel/src/coralnpu:rvv_core_mini_verification_axi_cc_library",
            ] + CORE_MINI_AXI_TB_CC_LIBRARY_COMMON_DEPS,
            "defines": [
                "VERILATOR_MODEL=VRvvCoreMiniVerificationAxi",
            ],
        },
    },
    hdrs = [
        "coralnpu/core_mini_axi_tb.h",
    ],
)

CORE_MINI_AXI_SIM_CC_BINARY_COMMON_DEPS = [
    "@com_google_absl//absl/flags:flag",
    "@com_google_absl//absl/flags:parse",
    "@com_google_absl//absl/flags:usage",
    "@com_google_absl//absl/log",
    "@com_google_absl//absl/log:check",
]

template_rule(
    cc_binary,
    {
        "core_mini_axi_sim": {
            "deps": [
                ":core_mini_axi_tb",
            ] + CORE_MINI_AXI_SIM_CC_BINARY_COMMON_DEPS,
        },
        "core_mini_verification_axi_sim": {
            "deps": [
                ":core_mini_verification_axi_tb",
            ] + CORE_MINI_AXI_SIM_CC_BINARY_COMMON_DEPS,
        },
        "rvv_core_mini_axi_sim": {
            "deps": [
                ":rvv_core_mini_axi_tb",
            ] + CORE_MINI_AXI_SIM_CC_BINARY_COMMON_DEPS,
        },
        "rvv_core_mini_verification_axi_sim": {
            "deps": [
                ":rvv_core_mini_verification_axi_tb",
            ] + CORE_MINI_AXI_SIM_CC_BINARY_COMMON_DEPS,
        },
    },
    srcs = [
        "coralnpu/core_mini_axi_sim.cc",
    ],
)

cc_test(
    name = "core_mini_axi_non_incr_tests",
    srcs = [
        "coralnpu/core_mini_axi_non_incr_tests.cc",
    ],
    deps = [
        ":core_mini_axi_tb",
    ],
)

cc_binary(
    name = "core_scalar_sim",
    srcs = [
        "coralnpu/core_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCoreScalar_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCoreScalar",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        "//hdl/chisel/src/coralnpu:core_scalar_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_binary(
    name = "core_mini_sim",
    srcs = [
        "coralnpu/core_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCoreMini_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCoreMini",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        "//hdl/chisel/src/coralnpu:core_mini_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_binary(
    name = "coralnpu_tb",
    srcs = [
        "matcha/coralnpu_if.h",
        "matcha/coralnpu_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/matcha:VCoralNPU_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCoralNPU",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/matcha:coralnpu_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_binary(
    name = "coralnpu_scalar_tb",
    srcs = [
        "matcha/coralnpu_if.h",
        "matcha/coralnpu_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/matcha:VCoralNPUScalar_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCoralNPUScalar",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/matcha:coralnpu_scalar_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_binary(
    name = "coralnpu_mini_tb",
    srcs = [
        "matcha/coralnpu_if.h",
        "matcha/coralnpu_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/matcha:VCoralNPUMini_parameters.h",
    ],
    defines = [
        "VERILATOR_MODEL=VCoralNPUMini",
    ],
    deps = [
        "coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/matcha:coralnpu_mini_cc_library",
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        "@com_google_absl//absl/flags:usage",
    ],
)

cc_test(
    name = "dbus2axi_tb",
    srcs = [
        "coralnpu/dbus2axi_tb.cc",
    ],
    deps = [
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:dbus2axi_cc_library",
    ],
)

cc_test(
    name = "l1dcache_tb",
    size = "large",
    srcs = [
        "coralnpu/l1dcache_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:l1dcache_cc_library",
    ],
)

cc_test(
    name = "l1dcachebank_tb",
    size = "large",
    srcs = [
        "coralnpu/l1dcache_tb.cc",
    ],
    defines = [
        "L1DCACHEBANK",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:l1dcachebank_cc_library",
    ],
)

cc_test(
    name = "l1icache_tb",
    srcs = [
        "coralnpu/l1icache_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:l1icache_cc_library",
    ],
)

cc_library(
    name = "valu",
    hdrs = [
        "coralnpu/alu_ref.h",
        "coralnpu/valu.h",
    ],
    deps = [
        ":vencodeop",
    ],
)

cc_test(
    name = "valu_tb",
    size = "enormous",
    srcs = [
        "coralnpu/valu_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        ":valu",
        "//hdl/chisel/src/coralnpu:valu_cc_library",
    ],
)

cc_test(
    name = "valuint_tb",
    size = "large",
    srcs = [
        "coralnpu/valuint_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":valu",
        "//hdl/chisel/src/coralnpu:valuint_cc_library",
    ],
)

cc_library(
    name = "vdecode",
    hdrs = [
        "coralnpu/vdecode.h",
    ],
    deps = [
        ":vdecodeop",
        ":vencodeop",
    ],
)

cc_library(
    name = "vdecodeop",
    hdrs = [
        "coralnpu/vdecodeop.h",
    ],
)

cc_library(
    name = "vencodeop",
    hdrs = [
        "coralnpu/vencodeop.h",
    ],
)

cc_test(
    name = "vcmdq_tb",
    srcs = [
        "coralnpu/vcmdq_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        ":vencodeop",
        "//hdl/chisel/src/coralnpu:vcmdq_cc_library",
    ],
)

cc_test(
    name = "vconvalu_tb",
    srcs = [
        "coralnpu/vconvalu_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:vconvalu_cc_library",
    ],
)

cc_test(
    name = "vconvctrl_tb",
    srcs = [
        "coralnpu/vconvctrl_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        ":vencodeop",
        "//hdl/chisel/src/coralnpu:vconvctrl_cc_library",
    ],
)

cc_test(
    name = "vdecodeinstruction_tb",
    srcs = [
        "coralnpu/vdecodeinstruction_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":vdecode",
        "//hdl/chisel/src/coralnpu:vdecodeinstruction_cc_library",
    ],
)

cc_test(
    name = "vdecode_tb",
    srcs = [
        "coralnpu/vdecode_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        ":vdecode",
        "//hdl/chisel/src/coralnpu:vdecode_cc_library",
    ],
)

cc_test(
    name = "vldst_tb",
    srcs = [
        "coralnpu/vldst_tb.cc",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:VCore_parameters.h",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        ":util",
        ":vencodeop",
        "//hdl/chisel/src/coralnpu:vldst_cc_library",
    ],
)

cc_test(
    name = "vregfilesegment_tb",
    srcs = [
        "coralnpu/vregfilesegment_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:vregfilesegment_cc_library",
    ],
)

cc_test(
    name = "vregfile_tb",
    size = "large",
    srcs = [
        "coralnpu/vregfile_tb.cc",
    ],
    deps = [
        ":coralnpu_if",
        ":sim_libs",
        "//hdl/chisel/src/coralnpu:vregfile_cc_library",
    ],
)
