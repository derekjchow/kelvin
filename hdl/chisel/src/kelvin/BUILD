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

load(
    "@kelvin_hw//rules:chisel.bzl",
    "chisel_binary",
    "chisel_cc_library",
    "chisel_library",
    "chisel_test",
)
load("@kelvin_hw//rules:verilog.bzl", "verilog_zip_bundle")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "kelvin_float",
    srcs = [
        "scalar/FRegfile.scala",
        "scalar/Fpu.scala",
    ],
    deps = [
        ":kelvin",
        ":kelvin_base",
        "//hdl/chisel/src/common:fma",
        "//hdl/chisel/src/common:fp",
    ],
)

chisel_test(
    name = "kelvin_float_tests",
    srcs = [
        "scalar/FRegfileTest.scala",
        "scalar/FpuTest.scala",
    ],
    deps = [
        ":kelvin",
        ":kelvin_base",
        ":kelvin_float",
        "//hdl/chisel/src/common:fp",
    ],
)

chisel_test(
    name = "kelvin_scalar_tests",
    srcs = [
        "scalar/MluTest.scala",
    ],
    deps = [
        ":kelvin_base",
        ":kelvin_scalar",
    ],
)

chisel_test(
    name = "kelvin_uncached_fetch_tests",
    srcs = [
        "scalar/UncachedFetchTest.scala",
    ],
    deps = [
        ":kelvin_base",
        ":kelvin_scalar",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_test(
    name = "kelvin_core_axi_tests",
    srcs = [
        "AxiSlave2ChiselSRAMTest.scala",
        "CoreAxiCSRTest.scala",
        "CoreAxiSlaveMuxTest.scala",
    ],
    deps = [
        ":kelvin",
        ":kelvin_base",
        "//hdl/chisel/src/bus",
    ],
)

chisel_library(
    name = "kelvin_base",
    srcs = [
        "ClockGate.scala",
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
        "vector/VLd.scala",
        "vector/VLdSt.scala",
        "vector/VRegfile.scala",
        "vector/VRegfileSegment.scala",
        "vector/VSt.scala",
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
        ":kelvin_base",
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/common:instruction_buffer",
    ],
)

chisel_library(
    name = "kelvin",
    srcs = [
        "AxiSlave2ChiselSRAM.scala",
        "Core.scala",
        "CoreAxi.scala",
        "CoreAxiCSR.scala",
        "CoreAxiSlaveMux.scala",
    ],
    deps = [
        ":kelvin_base",
        ":kelvin_scalar",
        ":kelvin_vector",
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
    name = "core_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    module_name = "Core",
    extra_outs = [
        "VCore_parameters.h",
    ],
)

chisel_cc_library(
    name = "core_scalar_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    module_name = "CoreScalar",
    verilog_file_path = "CoreScalar.sv",
    gen_flags = [
        "--enableVector=False",
        "--moduleName=CoreScalar",
    ],
    extra_outs = [
        "VCoreScalar_parameters.h",
    ],
)

chisel_cc_library(
    name = "core_mini_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    module_name = "CoreMini",
    verilog_file_path = "CoreMini.sv",
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--moduleName=CoreMini",
    ],
    extra_outs = [
        "VCoreMini_parameters.h",
    ],
)

chisel_cc_library(
    name = "core_mini_axi_cc_library",
    chisel_lib = ":kelvin",
    emit_class = "kelvin.EmitCore",
    module_name = "CoreMiniAxi",
    verilog_file_path = "CoreMiniAxi.sv",
    systemc = False,
    gen_flags = [
        "--enableFetchL0=False",
        "--fetchDataBits=128",
        "--lsuDataBits=128",
        "--enableVector=False",
        "--moduleName=CoreMini",
        "--useAxi",
    ],
    extra_outs = [
        "VCoreMiniAxi_parameters.h",
    ],
    verilog_deps = [
        "//hdl/verilog:clock_gate",
    ],
)

verilog_zip_bundle(
    name = "core_mini_axi_bundle",
    lib = ":core_mini_axi_cc_library_verilog",
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
