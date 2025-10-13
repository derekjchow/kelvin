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

load("@coralnpu_hw//rules:autogen.bzl", "autogen_scm_info")
load(
    "@coralnpu_hw//rules:chisel.bzl",
    "chisel_binary",
    "chisel_cc_library",
    "chisel_library",
    "chisel_test",
)
load("@coralnpu_hw//rules:lint.bzl", "vcstatic_lint")
load("@coralnpu_hw//rules:verilog.bzl", "verilog_zip_bundle")
load("@coralnpu_hw//rules:utils.bzl", "template_rule")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "coralnpu_float",
    srcs = [
        "float/FloatCore.scala",
        "float/FloatCoreInterface.scala",
        "scalar/FRegfile.scala",
        "scalar/Fpu.scala",
    ],
    resources = [
        "@common_cells//:all_srcs",
        "@cvfpu//:all_srcs",
        "@fpu_div_sqrt_mvp//:all_srcs",
    ],
    deps = [
        ":coralnpu_base",
        "//hdl/chisel/src/common:fma",
        "//hdl/chisel/src/common:fp",
        "//hdl/chisel/src/common:library",
    ],
)

chisel_test(
    name = "coralnpu_float_tests",
    size = "medium",
    srcs = [
        "scalar/FRegfileTest.scala",
        "scalar/FpuTest.scala",
    ],
    deps = [
        ":coralnpu",
        ":coralnpu_base",
        ":coralnpu_float",
        "//hdl/chisel/src/common:fp",
    ],
)

chisel_library(
    name = "rvvi_trace",
    srcs = [
        "RvviTrace.scala",
    ],
    resources = [
        "@RVVI//:all_srcs",
    ],
    deps = [
        ":coralnpu_base",
    ],
)

chisel_library(
    name = "retirement_buffer",
    srcs = [
        "RetirementBuffer.scala",
    ],
    deps = [
        ":coralnpu_base",
        "//hdl/chisel/src/common:aligner",
        "//hdl/chisel/src/common:circular_buffer_multi",
        "//hdl/chisel/src/common:library",
    ],
)

chisel_library(
    name = "coralnpu_rvv",
    srcs = [
        "rvv/RvvAlu.scala",
        "rvv/RvvCore.scala",
        "rvv/RvvDecode.scala",
        "rvv/RvvInterface.scala",
    ],
    resources = [
        "//hdl/verilog/rvv/common:cdffr.sv",
        "//hdl/verilog/rvv/common:compressor_3_2.sv",
        "//hdl/verilog/rvv/common:compressor_4_2.sv",
        "//hdl/verilog/rvv/common:dff.sv",
        "//hdl/verilog/rvv/common:edff.sv",
        "//hdl/verilog/rvv/common:edff_2d.sv",
        "//hdl/verilog/rvv/common:multi_fifo.sv",
        "//hdl/verilog/rvv/design:Aligner.sv",
        "//hdl/verilog/rvv/design:RvvCore.sv",
        "//hdl/verilog/rvv/design:RvvFrontEnd.sv",
        "//hdl/verilog/rvv/design:rvv_backend.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_addsub.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_execution_p1.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_mask.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_mask_viota.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_other.sv",
        "//hdl/verilog/rvv/design:rvv_backend_alu_unit_shift.sv",
        "//hdl/verilog/rvv/design:rvv_backend_decode.sv",
        "//hdl/verilog/rvv/design:rvv_backend_decode_ctrl.sv",
        "//hdl/verilog/rvv/design:rvv_backend_decode_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_decode_unit_ari.sv",
        "//hdl/verilog/rvv/design:rvv_backend_decode_unit_lsu.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_bypass.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_ctrl.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_operand.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_opr_byte_type.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_raw_uop_rob.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_raw_uop_uop.sv",
        "//hdl/verilog/rvv/design:rvv_backend_dispatch_structure_hazard.sv",
        "//hdl/verilog/rvv/design:rvv_backend_div.sv",
        "//hdl/verilog/rvv/design:rvv_backend_div_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_div_unit_divider.sv",
        "//hdl/verilog/rvv/design:rvv_backend_lsu_remap.sv",
        "//hdl/verilog/rvv/design:rvv_backend_mac_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_mul_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_mul_unit_mul8.sv",
        "//hdl/verilog/rvv/design:rvv_backend_mulmac.sv",
        "//hdl/verilog/rvv/design:rvv_backend_pmtrdt.sv",
        "//hdl/verilog/rvv/design:rvv_backend_pmtrdt_unit.sv",
        "//hdl/verilog/rvv/design:rvv_backend_retire.sv",
        "//hdl/verilog/rvv/design:rvv_backend_rob.sv",
        "//hdl/verilog/rvv/design:rvv_backend_vrf.sv",
        "//hdl/verilog/rvv/design:rvv_backend_vrf_reg.sv",
        "//hdl/verilog/rvv/inc:rvv_backend.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_alu.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_config.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_define.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_dispatch.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_div.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_pmtrdt.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_sva.svh",
    ],
    deps = [
        ":coralnpu_base",
        "//hdl/chisel/src/common:library",
    ],
)

chisel_test(
    name = "coralnpu_rvv_tests",
    srcs = [
        "rvv/RvvDecodeTest.scala",
    ],
    args = [
        "-P",  # Allows parallel tests.
    ],
    deps = [
        ":coralnpu_rvv",
        "//hdl/chisel/src/common:testing",
    ],
)

chisel_test(
    name = "coralnpu_scalar_tests",
    size = "large",
    srcs = [
        "scalar/AluTest.scala",
        "scalar/MluTest.scala",
    ],
    args = [
        "-P",  # Allows parallel tests.
    ],
    deps = [
        ":coralnpu_base",
        ":coralnpu_scalar",
        "//hdl/chisel/src/common:testing",
    ],
)

chisel_test(
    name = "coralnpu_uncached_fetch_tests",
    size = "medium",
    srcs = [
        "scalar/UncachedFetchTest.scala",
    ],
    deps = [
        ":coralnpu_base",
        ":coralnpu_scalar",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_test(
    name = "coralnpu_core_axi_tests",
    size = "large",
    srcs = [
        "CoreAxiCSRTest.scala",
        "DBus2AxiTest.scala",
        "FabricTest.scala",
    ],
    deps = [
        ":coralnpu",
        ":coralnpu_base",
        "//hdl/chisel/src/bus",
    ],
)

chisel_library(
    name = "clock_gate",
    srcs = [
        "ClockGate.scala",
    ],
    resource_strip_prefix = "hdl/verilog",
    resources = [
        "//hdl/verilog:ClockGate.sv",
    ],
)

chisel_test(
    name = "clock_gate_test",
    srcs = [
        "ClockGateTest.scala",
    ],
    deps = [
        ":clock_gate",
        ":coralnpu_base",
    ],
)

chisel_library(
    name = "RstSync",
    srcs = [
        "RstSync.scala",
    ],
    resource_strip_prefix = "hdl/verilog",
    resources = [
        "//hdl/verilog:RstSync.sv",
    ],
)

autogen_scm_info(name = "CoralNPUScmInfo")

chisel_library(
    name = "coralnpu_base",
    srcs = [
        "DBus2Axi.scala",
        "DBusMux.scala",
        "IBus2Axi.scala",
        "Interfaces.scala",
        "L1DCache.scala",
        "L1ICache.scala",
        "Library.scala",
        "Parameters.scala",
    ],
    deps = [
        ":clock_gate",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:fp",
    ],
)

chisel_library(
    name = "coralnpu_vector",
    srcs = [
        "vector/VAlu.scala",
        "vector/VAluInt.scala",
        "vector/VCmdq.scala",
        "vector/VCommon.scala",
        "vector/VConvAlu.scala",
        "vector/VConvCtrl.scala",
        "vector/VCore.scala",
        "vector/VDecode.scala",
        "vector/VDecodeInstruction.scala",
        "vector/VDecodeOp.scala",
        "vector/VDot.scala",
        "vector/VEncodeOp.scala",
        "vector/VInst.scala",
        "vector/VLdSt.scala",
        "vector/VRegfile.scala",
        "vector/VRegfileSegment.scala",
    ],
    deps = [
        ":coralnpu_base",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/common",
    ],
)

chisel_library(
    name = "coralnpu_scalar",
    srcs = [
        "scalar/Alu.scala",
        "scalar/Bru.scala",
        "scalar/Csr.scala",
        "scalar/Debug.scala",
        "scalar/Decode.scala",
        "scalar/Dvu.scala",
        "scalar/FaultManager.scala",
        "scalar/Fetch.scala",
        "scalar/Lsu.scala",
        "scalar/Mlu.scala",
        "scalar/Regfile.scala",
        "scalar/SCore.scala",
        "scalar/UncachedFetch.scala",
    ],
    deps = [
        ":CoralNPUScmInfo",
        ":coralnpu_base",
        ":coralnpu_float",
        ":coralnpu_rvv",
        ":retirement_buffer",
        ":rvvi_trace",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:aligner",
        "//hdl/chisel/src/common:circular_buffer_multi",
        "//hdl/chisel/src/common:fp",
        "//hdl/chisel/src/common:instruction_buffer",
        "//hdl/chisel/src/common:scatter_gather",
    ],
)

chisel_library(
    name = "srams",
    srcs = [
        "SramNx128.scala",
        "Sram_12ffcp_128x128.scala",
        "Sram_2048x128.scala",
        "Sram_512x128.scala",
    ],
    resources = [
        "//hdl/verilog:Sram_12ffcp_128x128.v",
        "//hdl/verilog:Sram_2048x128.v",
        "//hdl/verilog:Sram_512x128.v",
    ],
    deps = [
        ":coralnpu_base",
    ],
)

chisel_library(
    name = "coralnpu",
    srcs = [
        "AxiSlave.scala",
        "Core.scala",
        "CoreAxi.scala",
        "CoreAxiCSR.scala",
        "CoreTlul.scala",
        "Fabric.scala",
        "SRAM.scala",
        "TCM.scala",
    ],
    deps = [
        ":RstSync",
        ":clock_gate",
        ":coralnpu_base",
        ":coralnpu_float",
        ":coralnpu_rvv",
        ":coralnpu_scalar",
        ":coralnpu_vector",
        ":srams",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_library(
    name = "coralnpu_params",
    srcs = [
        "Parameters.scala",
    ],
    deps = [
    ],
)

chisel_cc_library(
    name = "alu_cc_library",
    chisel_lib = ":coralnpu_scalar",
    emit_class = "coralnpu.EmitAlu",
    module_name = "Alu",
)

chisel_cc_library(
    name = "core_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    extra_outs = [
        "VCore_parameters.h",
    ],
    module_name = "Core",
)

chisel_cc_library(
    name = "core_scalar_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    extra_outs = [
        "VCoreScalar_parameters.h",
    ],
    gen_flags = [
        "--enableVector=False",
        "--moduleName=CoreScalar",
    ],
    module_name = "CoreScalar",
    verilog_file_path = "CoreScalar.sv",
)

chisel_cc_library(
    name = "core_mini_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    extra_outs = [
        "VCoreMini_parameters.h",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--moduleName=CoreMini",
    ],
    module_name = "CoreMini",
    verilog_file_path = "CoreMini.sv",
)

template_rule(
    chisel_cc_library,
    {
        "core_mini_axi_cc_library": {
            "extra_outs": [
                "VCoreMiniAxi_parameters.h",
                "CoreMiniAxi.zip",
            ],
            "gen_flags": [
                "--enableFetchL0=False",
                "--fetchDataBits=128",
                "--lsuDataBits=128",
                "--enableVector=False",
                "--enableFloat=True",
                "--moduleName=CoreMini",
                "--useAxi",
            ],
            "module_name": "CoreMiniAxi",
            "verilog_file_path": "CoreMiniAxi.sv",
        },
        "core_mini_verification_axi_cc_library": {
            "extra_outs": [
                "VCoreMiniVerificationAxi_parameters.h",
                "CoreMiniVerificationAxi.zip",
            ],
            "gen_flags": [
                "--enableFetchL0=False",
                "--fetchDataBits=128",
                "--lsuDataBits=128",
                "--enableVector=False",
                "--enableFloat=True",
                "--moduleName=CoreMiniVerification",
                "--useAxi",
                "--enableVerification=True",
                # Verification requires DispatchV2 and LsuV2
                "--enableDispatchV2=True",
            ],
            "module_name": "CoreMiniVerificationAxi",
            "verilog_file_path": "CoreMiniVerificationAxi.sv",
        },
    },
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    vopts = [
        "-DUSE_GENERIC",
        # Warnings that we disable for fpnew
        "-Wno-UNOPTFLAT",
        "-Wno-ASCRANGE",
        "-Wno-WIDTHEXPAND",
        "-Wno-WIDTHTRUNC",
        "-Wno-UNSIGNED",
    ],
)

chisel_cc_library(
    name = "core_mini_highmem_axi_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    extra_outs = [
        "VCoreMiniHighmemAxi_parameters.h",
        "CoreMiniHighmemAxi.zip",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--enableFloat=True",
        "--moduleName=CoreMiniHighmem",
        "--useAxi",
        "--tcmHighmem",
    ],
    module_name = "CoreMiniHighmemAxi",
    verilog_file_path = "CoreMiniHighmemAxi.sv",
    vopts = [
        "-DUSE_GENERIC",
        # Warnings that we disable for fpnew
        "-Wno-UNOPTFLAT",
        "-Wno-ASCRANGE",
        "-Wno-WIDTHEXPAND",
        "-Wno-WIDTHTRUNC",
        "-Wno-UNSIGNED",
    ],
)

chisel_cc_library(
    name = "core_mini_axi_debug_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    extra_outs = [
        "VCoreMiniDebugAxi_parameters.h",
        "CoreMiniDebugAxi.zip",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--enableDispatchV2=True",
        "--enableDebug=True",
        "--enableFloat=True",
        "--moduleName=CoreMiniDebug",
        "--useAxi",
    ],
    module_name = "CoreMiniDebugAxi",
    verilog_file_path = "CoreMiniDebugAxi.sv",
    vopts = [
        "-DUSE_GENERIC",
    ],
)

CORE_MINI_AXI_BLACKBOX_DESIGNS = [
    "CKLNQD10BWP6T20P96CPDLVT",
    "TS1N12FFCLLMBLVTD2048X128M4SWBSHO",
    "TS1N12FFCLLSBLVTD512X128M4SWBSHO",
    "sasdulssd8LOW1p512x128m4b1w0c0p0d0l0rm3sdrw01",
    "sasdulssd8LOW1p2048x128m4b2w0c0p0d0l0rm3sdrw01",
]

CORE_MINI_AXI_LINT_TAGS = [
    "STARC05-1.3.1.3",
    "STARC05-2.7.1.3a",
    "STARC05-2.7.1.3b",
]

vcstatic_lint(
    name = "core_mini_axi_cc_library_lint_check",
    blackbox_designs = CORE_MINI_AXI_BLACKBOX_DESIGNS,
    lint_tags = CORE_MINI_AXI_LINT_TAGS,
    module = "CoreMiniAxi",
    package = "core_mini_axi_cc_library_verilog",
)

vcstatic_lint(
    name = "core_mini_axi_cc_library_lint",
    blackbox_designs = CORE_MINI_AXI_BLACKBOX_DESIGNS,
    goal = "lint_rtl",
    lint_tags = CORE_MINI_AXI_LINT_TAGS,
    module = "CoreMiniAxi",
    package = "core_mini_axi_cc_library_verilog",
    waive_tags = ["UndrivenInTerm-ML"],
)

vcstatic_lint(
    name = "rvv_core_mini_axi_cc_library_lint",
    blackbox_designs = CORE_MINI_AXI_BLACKBOX_DESIGNS,
    goal = "lint_rtl",
    lint_tags = CORE_MINI_AXI_LINT_TAGS,
    module = "RvvCoreMiniAxi",
    package = "rvv_core_mini_axi_cc_library_verilog",
    waive_tags = ["UndrivenInTerm-ML"],
)

RVV_CORE_MINI_AXI_COMMON_GEN_FLAGS = [
    "--enableFetchL0=False",
    "--fetchDataBits=128",
    "--lsuDataBits=128",
    "--enableVector=False",
    "--enableRvv=True",
    "--enableFloat=True",
    "--useAxi",
]

template_rule(
    chisel_cc_library,
    {
        "rvv_core_mini_tlul_cc_library": {
            "verilog_file_path": "RvvCoreMiniTlul.sv",
            "extra_outs": [
                "VRvvCoreMiniTlul_parameters.h",
                "RvvCoreMiniTlul.zip",
            ],
            "gen_flags": [
                "--moduleName=RvvCoreMini",
                "--enableFetchL0=False",
                "--fetchDataBits=128",
                "--lsuDataBits=128",
                "--enableVector=False",
                "--enableRvv=True",
                "--enableFloat=True",
                "--useTlul=True",
            ],
            "module_name": "RvvCoreMiniTlul",
        },
        "rvv_core_mini_axi_cc_library": {
            "verilog_file_path": "RvvCoreMiniAxi.sv",
            "extra_outs": [
                "VRvvCoreMiniAxi_parameters.h",
                "RvvCoreMiniAxi.zip",
            ],
            "gen_flags": [
                "--moduleName=RvvCoreMini",
            ] + RVV_CORE_MINI_AXI_COMMON_GEN_FLAGS,
            "module_name": "RvvCoreMiniAxi",
        },
        "rvv_core_mini_verification_axi_cc_library": {
            "verilog_file_path": "RvvCoreMiniVerificationAxi.sv",
            "extra_outs": [
                "VRvvCoreMiniVerificationAxi_parameters.h",
                "RvvCoreMiniVerificationAxi.zip",
            ],
            "gen_flags": [
                "--moduleName=RvvCoreMiniVerification",
                "--enableVerification=True",
            ] + RVV_CORE_MINI_AXI_COMMON_GEN_FLAGS,
            "module_name": "RvvCoreMiniVerificationAxi",
        },
        "rvv_core_mini_debug_axi_cc_library": {
            "verilog_file_path": "RvvCoreMiniDebugAxi.sv",
            "extra_outs": [
                "VRvvCoreMiniDebugAxi_parameters.h",
                "RvvCoreMiniDebugAxi.zip",
            ],
            "gen_flags": [
                "--moduleName=RvvCoreMiniDebug",
                "--enableDebug=True",
            ] + RVV_CORE_MINI_AXI_COMMON_GEN_FLAGS,
            "module_name": "RvvCoreMiniDebugAxi",
        },
        "rvv_core_mini_highmem_axi_cc_library": {
            "verilog_file_path": "RvvCoreMiniHighmemAxi.sv",
            "extra_outs": [
                "VRvvCoreMiniHighmemAxi_parameters.h",
                "RvvCoreMiniHighmemAxi.zip",
            ],
            "gen_flags": [
                "--moduleName=RvvCoreMiniHighmem",
                "--tcmHighmem=True",
            ] + RVV_CORE_MINI_AXI_COMMON_GEN_FLAGS,
            "module_name": "RvvCoreMiniHighmemAxi",
        },
    },
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitCore",
    vopts = [
        "-DUSE_GENERIC",
        # RVV
        "-Wno-WIDTH",
        "-Wno-CASEINCOMPLETE",
        "-Wno-LATCH",
        "-Wno-SIDEEFFECT",
        "-Wno-MULTIDRIVEN",
        "-Wno-UNOPTFLAT",
        # FPNEW
        "-Wno-ASCRANGE",
        "-Wno-WIDTHEXPAND",
        "-Wno-WIDTHTRUNC",
        "-Wno-UNSIGNED",
        "-Ihdl/verilog/rvv/inc",
    ],
)

filegroup(
    name = "rvv_core_mini_tlul_verilog",
    srcs = [":rvv_core_mini_tlul_cc_library_verilog"],
)

verilog_zip_bundle(
    name = "core_mini_axi_bundle",
    lib = ":core_mini_axi_cc_library_verilog",
)

chisel_cc_library(
    name = "dbus2axi_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitDBus2Axi",
    module_name = "DBus2AxiV1",
)

chisel_cc_library(
    name = "dvu_cc_library",
    chisel_lib = ":coralnpu_scalar",
    emit_class = "coralnpu.EmitDvu",
    module_name = "Dvu",
)

chisel_cc_library(
    name = "mlu_cc_library",
    chisel_lib = ":coralnpu_scalar",
    emit_class = "coralnpu.EmitMlu",
    module_name = "Mlu",
)

chisel_cc_library(
    name = "l1dcache_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitL1DCache",
    module_name = "L1DCache",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x288",
    ],
)

chisel_cc_library(
    name = "l1dcachebank_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitL1DCacheBank",
    module_name = "L1DCacheBank",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x288",
    ],
)

chisel_cc_library(
    name = "l1icache_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitL1ICache",
    module_name = "L1ICache",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
    ],
)

chisel_cc_library(
    name = "valu_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVAlu",
    module_name = "VAlu",
)

chisel_cc_library(
    name = "valuint_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVAluInt",
    module_name = "VAluInt",
)

chisel_cc_library(
    name = "vcmdq_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVCmdq",
    module_name = "VCmdq",
)

chisel_cc_library(
    name = "vconvalu_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVConvAlu",
    module_name = "VConvAlu",
)

chisel_cc_library(
    name = "vconvctrl_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVConvCtrl",
    module_name = "VConvCtrl",
)

chisel_cc_library(
    name = "vdecode_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVDecode",
    module_name = "VDecode",
)

chisel_cc_library(
    name = "vdecodeinstruction_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVDecodeInstruction",
    module_name = "VDecodeInstruction",
)

chisel_cc_library(
    name = "vldst_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVLdSt",
    module_name = "VLdSt",
)

chisel_cc_library(
    name = "vregfile_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVRegfile",
    module_name = "VRegfile",
)

chisel_cc_library(
    name = "vregfilesegment_cc_library",
    chisel_lib = ":coralnpu",
    emit_class = "coralnpu.EmitVRegfileSegment",
    module_name = "VRegfileSegment",
)
