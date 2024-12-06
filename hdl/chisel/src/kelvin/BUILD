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

load("@kelvin_hw//rules:autogen.bzl", "autogen_scm_info")
load(
    "@kelvin_hw//rules:chisel.bzl",
    "chisel_binary",
    "chisel_cc_library",
    "chisel_library",
    "chisel_test",
)
load("@kelvin_hw//rules:lint.bzl", "vcstatic_lint")
load("@kelvin_hw//rules:verilog.bzl", "verilog_zip_bundle")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "kelvin_float",
    srcs = [
        "scalar/FRegfile.scala",
        "scalar/Fpu.scala",
        "float/FloatCore.scala",
        "float/FloatCoreInterface.scala",
    ],
    resources = [
        "@cvfpu//:all_srcs",
        "@common_cells//:all_srcs",
        "@fpu_div_sqrt_mvp//:all_srcs",
    ],
    deps = [
        ":kelvin_base",
        "//hdl/chisel/src/common:fma",
        "//hdl/chisel/src/common:fp",
        "//hdl/chisel/src/common:library",
    ],
)

chisel_test(
    name = "kelvin_float_tests",
    srcs = [
        "scalar/FRegfileTest.scala",
        "scalar/FpuTest.scala",
    ],
    size = "medium",
    deps = [
        ":kelvin",
        ":kelvin_base",
        ":kelvin_float",
        "//hdl/chisel/src/common:fp",
    ],
)


chisel_library(
    name = "kelvin_rvv",
    srcs = [
        "rvv/RvvAlu.scala",
        "rvv/RvvCore.scala",
        "rvv/RvvDecode.scala",
        "rvv/RvvInterface.scala",
    ],
    resources = [
        "//hdl/verilog/rvv/inc:rvv_backend.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_alu.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_div.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_define.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_config.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_dispatch.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_pmtrdt.svh",
        "//hdl/verilog/rvv/inc:rvv_backend_sva.svh",
        "//hdl/verilog/rvv/common:cdffr.sv",
        "//hdl/verilog/rvv/common:compressor_3_2.sv",
        "//hdl/verilog/rvv/common:compressor_4_2.sv",
        "//hdl/verilog/rvv/common:dff.sv",
        "//hdl/verilog/rvv/common:edff.sv",
        "//hdl/verilog/rvv/common:edff_2d.sv",
        "//hdl/verilog/rvv/common:multi_fifo.sv",
        "//hdl/verilog/rvv/design:Aligner.sv",
        "//hdl/verilog/rvv/design:MultiFifo.sv",
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
        "//hdl/verilog/rvv/design:rvv_backend_vrf.sv",
        "//hdl/verilog/rvv/design:rvv_backend_vrf_reg.sv",
        "//hdl/verilog/rvv/design:rvv_backend_rob.sv",
    ],
    deps = [
        ":kelvin_base",
        "//hdl/chisel/src/common:library",
    ],
)

chisel_test(
    name = "kelvin_rvv_tests",
    srcs = [
        "rvv/RvvDecodeTest.scala",
    ],
    args = [
        "-P",  # Allows parallel tests.
    ],
    deps = [
        ":kelvin_rvv",
        "//hdl/chisel/src/common:testing",
    ],
)

chisel_test(
    name = "kelvin_scalar_tests",
    srcs = [
        "scalar/AluTest.scala",
        "scalar/MluTest.scala",
    ],
    args = [
        "-P",  # Allows parallel tests.
    ],
    size = "medium",
    deps = [
        ":kelvin_base",
        ":kelvin_scalar",
        "//hdl/chisel/src/common:testing",
    ],
)

chisel_test(
    name = "kelvin_uncached_fetch_tests",
    srcs = [
        "scalar/UncachedFetchTest.scala",
    ],
    size = "medium",
    deps = [
        ":kelvin_base",
        ":kelvin_scalar",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_test(
    name = "kelvin_core_axi_tests",
    size = "medium",
    srcs = [
        "CoreAxiCSRTest.scala",
        "DBus2AxiTest.scala",
        "FabricTest.scala",
    ],
    deps = [
        ":kelvin",
        ":kelvin_base",
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
        ":kelvin_base",
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

autogen_scm_info(name = "KelvinScmInfo")

chisel_library(
    name = "kelvin_base",
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
    ],
)

chisel_library(
    name = "kelvin_vector",
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
        ":kelvin_base",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/common",
    ],
)

chisel_library(
    name = "kelvin_scalar",
    srcs = [
        "scalar/Alu.scala",
        "scalar/Bru.scala",
        "scalar/Csr.scala",
        "scalar/Debug.scala",
        "scalar/Decode.scala",
        "scalar/Dvu.scala",
        "scalar/FaultManager.scala",
        "scalar/Fetch.scala",
        "scalar/Flush.scala",
        "scalar/Lsu.scala",
        "scalar/Mlu.scala",
        "scalar/Regfile.scala",
        "scalar/SCore.scala",
        "scalar/SLog.scala",
        "scalar/UncachedFetch.scala",
    ],
    deps = [
        ":KelvinScmInfo",
        ":kelvin_base",
        ":kelvin_float",
        ":kelvin_rvv",
        "//hdl/chisel/src/common",
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
        "Sram_12ffcp_2048x128.scala",
        "Sram_12ffcp_512x128.scala",
    ],
    resources = [
        "//hdl/verilog:Sram_12ffcp_128x128.v",
        "//hdl/verilog:Sram_12ffcp_2048x128.v",
        "//hdl/verilog:Sram_12ffcp_512x128.v",
    ],
    deps = [
        ":kelvin_base",
    ],
)

chisel_library(
    name = "kelvin",
    srcs = [
        "AxiSlave.scala",
        "Core.scala",
        "CoreAxi.scala",
        "CoreAxiCSR.scala",
        "Fabric.scala",
        "TCM.scala",
        "SRAM.scala",
    ],
    deps = [
        ":RstSync",
        ":clock_gate",
        ":kelvin_base",
        ":kelvin_float",
        ":kelvin_rvv",
        ":kelvin_scalar",
        ":kelvin_vector",
        ":srams",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_library(
    name = "kelvin_params",
    srcs = [
        "Parameters.scala",
    ],
    deps = [
    ],
)

chisel_cc_library(
    name = "alu_cc_library",
    chisel_lib = ":kelvin_scalar",
    emit_class = "kelvin.EmitAlu",
    module_name = "Alu",
)

chisel_cc_library(
    name = "core_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    extra_outs = [
        "VCore_parameters.h",
    ],
    module_name = "Core",
)

chisel_cc_library(
    name = "core_scalar_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
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
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
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

chisel_cc_library(
    name = "core_mini_axi_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    extra_outs = [
        "VCoreMiniAxi_parameters.h",
        "CoreMiniAxi.zip",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--enableFloat=True",
        "--moduleName=CoreMini",
        "--useAxi",
    ],
    module_name = "CoreMiniAxi",
    verilog_file_path = "CoreMiniAxi.sv",
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
    name = "core_mini_axi_highmem_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    extra_outs = [
        "VCoreMiniHighmemAxi_parameters.h",
        "CoreMiniHighmemAxi.zip",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--moduleName=CoreMiniHighmem",
        "--useAxi",
        "--tcmHighmem",
    ],
    module_name = "CoreMiniHighmemAxi",
    verilog_file_path = "CoreMiniHighmemAxi.sv",
    vopts = [
        "-DUSE_GENERIC",
    ],
)


CORE_MINI_AXI_BLACKBOX_DESIGNS = [
    "CKLNQD10BWP6T20P96CPDLVT",
    "TS1N12FFCLLMBLVTD2048X128M4SWBSHO",
    "TS1N12FFCLLSBLVTD512X128M4SWBSHO",
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

chisel_cc_library(
    name = "rvv_core_mini_axi_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    extra_outs = [
        "VRvvCoreMiniAxi_parameters.h",
        "RvvCoreMiniAxi.zip",
    ],
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--enableRvv=True",
        "--enableFloat=True",
        "--moduleName=RvvCoreMini",
        "--useAxi",
    ],
    vopts = [
        "-DUSE_GENERIC",
        # RVV
        "-Wno-WIDTH",
        "-Wno-CASEINCOMPLETE",
        "-Wno-LATCH",
        "-Wno-SIDEEFFECT",
        "-Wno-MULTIDRIVEN",
        "-Wno-UNOPTFLAT",
        "-Wno-CASEOVERLAP",
        # FPNEW
        "-Wno-ASCRANGE",
        "-Wno-WIDTHEXPAND",
        "-Wno-WIDTHTRUNC",
        "-Wno-UNSIGNED",
        "-Ihdl/verilog/rvv/inc",
    ],
    module_name = "RvvCoreMiniAxi",
    verilog_file_path = "RvvCoreMiniAxi.sv",
)

verilog_zip_bundle(
    name = "core_mini_axi_bundle",
    lib = ":core_mini_axi_cc_library_verilog",
)

chisel_cc_library(
    name = "dbus2axi_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitDBus2Axi",
    module_name = "DBus2AxiV1",
)

chisel_cc_library(
    name = "dvu_cc_library",
    chisel_lib = ":kelvin_scalar",
    emit_class = "kelvin.EmitDvu",
    module_name = "Dvu",
)

chisel_cc_library(
    name = "mlu_cc_library",
    chisel_lib = ":kelvin_scalar",
    emit_class = "kelvin.EmitMlu",
    module_name = "Mlu",
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
