# Copyright 2025 Google LLC
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

load("@bazel_skylib//rules:common_settings.bzl", "string_list_flag")
load("@lowrisc_opentitan_gh//rules:fusesoc.bzl", "fusesoc_build")
load("//rules:coralnpu_v2.bzl", "coralnpu_v2_binary")
load("//rules:utils.bzl", "cc_embed_data")
load("@internal_check//:status.bzl", internal_exists = "FOLDER_EXISTS")

package(default_visibility = ["//visibility:public"])

_CLOCK_FREQUENCY_MHZ = "80"
_NEXUS_CLOCK_FREQUENCY_MHZ = "80"

filegroup(
    name = "rtl_files",
    srcs = glob(["**/*.sv"]) + glob(["**/*.core"]) + [
        "//fpga/ip/spi_dpi_master:rtl_files",
        "//fpga/ip/coralnpu_tlul:rtl_files",
        "//fpga/ip/coralnpu_chisel_subsystem_default:rtl_files",
        "//fpga/ip/coralnpu_chisel_subsystem_highmem:rtl_files",
        "//fpga/ip/sram:rtl_files",
        "//fpga/rtl:rtl_files",
    ],
)

VERILATOR_OPTIONS_COMMON = [
    "-Wno-ALWCOMBORDER",
    "-Wno-WIDTHEXPAND",
    "-Wno-WIDTHTRUNC",
    "-Wno-UNUSEDSIGNAL",
    "-Wno-UNUSEDPARAM",
    "-Wno-VARHIDDEN",
    # TODO: The MULTIDRIVEN warnings are caused by the `prim_arbiter_fixed`
    # module and the `tlul_fifo_sync` module. We should investigate these
    # modules and fix the underlying issues.
    # "-Wno-MULTIDRIVEN",
    "-Wno-UNOPTTHREADS",
    "-Wno-GENUNNAMED",
    "-Wno-DECLFILENAME",
    "-Wno-ASCRANGE",
    "-DRVFI",
    "-DUSE_GENERIC",
    "-DUSE_DPI_MEMORY",
]

string_list_flag(
    name = "verilator_options_default",
    build_setting_default = VERILATOR_OPTIONS_COMMON,
)
string_list_flag(
    name = "verilator_options_highmem",
    build_setting_default = [
        "-CFLAGS \"-DCHISEL_SUBSYSTEM_HIGHMEM\"",
    ] + VERILATOR_OPTIONS_COMMON,
)

string_list_flag(
    name = "make_options",
    build_setting_default = [
        "-j16",
    ],
)

cc_embed_data(
    name = "add_uint32_m1_bin_header",
    srcs = [":add_uint32_m1_bin"],
    var_name = "add_uint32_m1_bin",
)

coralnpu_v2_binary(
    name = "add_uint32_m1",
    srcs = ["sw/add_uint32_m1.cc"],
    copts = ["-DCLOCK_FREQUENCY_MHZ=" + _CLOCK_FREQUENCY_MHZ],
)

filegroup(
    name = "add_uint32_m1_bin",
    srcs = [":add_uint32_m1"],
    output_group = "bin_file",
)

CORALNPU_SOC_CORES = [
    ":coralnpu_soc.core",
    ":coralnpu_soc_pkg.core",
    ":racl_pkg.core",
    "@lowrisc_opentitan_gh//hw:check_tool_requirements.core",
]

CORALNPU_SOC_SRCS = [
    ":rtl_files",
    "@lowrisc_opentitan_gh//hw/dv/sv:dv_macros",
    "@lowrisc_opentitan_gh//hw/dv:verilator_files",
    "@lowrisc_opentitan_gh//hw:check_tool_requirements.py",
    "@lowrisc_opentitan_gh//hw:lint/tools/verilator/common.vlt",
    "@lowrisc_opentitan_gh//hw:lint/tools/verilator/comportable.vlt",
    "@lowrisc_opentitan_gh//hw:rtl_files",
    "@lowrisc_opentitan_gh//hw:tool_requirements.py",
    "@lowrisc_opentitan_gh//hw:vendor/lint/pulp_riscv_dbg.vlt",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/debug_rom/debug_rom.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/debug_rom/debug_rom_one_scratch.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dm_csrs.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dm_mem.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dm_pkg.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dm_sba.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dm_top.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dmi_cdc.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dmi_jtag.sv",
    "@lowrisc_opentitan_gh//hw:vendor/pulp_riscv_dbg/src/dmi_jtag_tap.sv",
    "@lowrisc_opentitan_gh//hw:verilator_files",
    "main.cc",
]

fusesoc_build(
    name = "build_chip_verilator",
    srcs = CORALNPU_SOC_SRCS + [
        "//fpga/ip/spi_dpi_master:dpi_files",
        "@lowrisc_opentitan_gh//hw:dpi_files",
    ],
    cores = CORALNPU_SOC_CORES + [
        ":chip_verilator.core",
        "//fpga/ip/coralnpu_chisel_subsystem_default:coralnpu_chisel_subsystem_default.core",
        "//fpga/ip/spi_dpi_master:spi_dpi_master.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi_sv.core",
    ],
    flags = [
        "--ClockFrequencyMhz=" + _CLOCK_FREQUENCY_MHZ,
    ],
    make_options = ":make_options",
    output_groups = {
        "binary": ["com.google.coralnpu_fpga_chip_verilator_0.1/sim-verilator/Vchip_verilator"],
    },
    systems = ["com.google.coralnpu:fpga:chip_verilator:0.1"],
    target = "sim",
    verilator_options = ":verilator_options_default",
    tags = ["manual"],
)

fusesoc_build(
    name = "build_chip_verilator_highmem",
    srcs = CORALNPU_SOC_SRCS + [
        "//fpga/ip/spi_dpi_master:dpi_files",
        "@lowrisc_opentitan_gh//hw:dpi_files",
    ],
    cores = CORALNPU_SOC_CORES + [
        ":chip_verilator.core",
        "//fpga/ip/coralnpu_chisel_subsystem_highmem:coralnpu_chisel_subsystem_highmem.core",
        "//fpga/ip/spi_dpi_master:spi_dpi_master.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi_sv.core",
    ],
    flags = [
        "--ClockFrequencyMhz=" + _CLOCK_FREQUENCY_MHZ,
    ],
    make_options = ":make_options",
    output_groups = {
        "binary": ["com.google.coralnpu_fpga_chip_verilator_0.1/sim-verilator/Vchip_verilator"],
    },
    systems = ["com.google.coralnpu:fpga:chip_verilator:0.1"],
    target = "sim",
    verilator_options = ":verilator_options_highmem",
    tags = ["manual"],
)

_PREFIX = "../../../../../../../../.."
DDR_CORES = [
    "//internal/fpga/ip/ddr4:ddr4.core",
    "//internal/fpga/ip/ddr4_phy:ddr4_phy.core",
] if internal_exists else [
    "//fpga/ip/ddr4_stub:ddr4_stub.core",
]
DDR_SRCS = [
    "//internal/fpga/ip/ddr4:elf_files",
    "//internal/fpga/ip/ddr4:rtl_files",
    "//internal/fpga/ip/ddr4_phy:rtl_files",
] if internal_exists else [
    "//fpga/ip/ddr4_stub:rtl_files",
]

fusesoc_build(
    name = "build_chip_nexus_bitstream",
    srcs = CORALNPU_SOC_SRCS + [
        "pins_nexus.xdc",
        "vivado_setup_hooks.tcl",
        "vivado_hook_write_bitstream_post.tcl",
    ] + DDR_SRCS,
    cores = CORALNPU_SOC_CORES + [
        ":chip_nexus.core",
        "//fpga/ip/coralnpu_chisel_subsystem_default:coralnpu_chisel_subsystem_default.core",
    ] + DDR_CORES,
    flags = [
        "--ClockFrequencyMhz=" + _NEXUS_CLOCK_FREQUENCY_MHZ,
    ],
    output_groups = {
        "bitstream": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/com.google.coralnpu_fpga_chip_nexus_0.1.runs/impl_1/chip_nexus.bit"],
        "logs": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/com.google.coralnpu_fpga_chip_nexus_0.1.runs/"],
        "synth": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/"],
        "all": ["com.google.coralnpu_fpga_chip_nexus_0.1/"],
    },
    systems = ["com.google.coralnpu:fpga:chip_nexus:0.1"],
    target = "synth",
    tags = ["manual"],
)

fusesoc_build(
    name = "build_chip_nexus_bitstream_highmem",
    srcs = CORALNPU_SOC_SRCS + [
        "pins_nexus.xdc",
        "vivado_setup_hooks.tcl",
        "vivado_hook_write_bitstream_post.tcl",
    ] + DDR_SRCS,
    cores = CORALNPU_SOC_CORES + [
        ":chip_nexus.core",
        "//fpga/ip/coralnpu_chisel_subsystem_highmem:coralnpu_chisel_subsystem_highmem.core",
    ] + DDR_CORES,
    flags = [
        "--ClockFrequencyMhz=" + _NEXUS_CLOCK_FREQUENCY_MHZ,
    ],
    output_groups = {
        "bitstream": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/com.google.coralnpu_fpga_chip_nexus_0.1.runs/impl_1/chip_nexus.bit"],
        "logs": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/com.google.coralnpu_fpga_chip_nexus_0.1.runs/"],
        "synth": ["com.google.coralnpu_fpga_chip_nexus_0.1/synth-vivado/"],
        "all": ["com.google.coralnpu_fpga_chip_nexus_0.1/"],
    },
    systems = ["com.google.coralnpu:fpga:chip_nexus:0.1"],
    target = "synth",
    tags = ["manual"],
)

filegroup(
    name = "chip_verilator_binary",
    srcs = [":build_chip_verilator"],
    output_group = "binary",
    tags = ["manual"],
)

genrule(
    name = "copy_chip_verilator_binary",
    srcs = [":chip_verilator_binary"],
    outs = ["Vchip_verilator"],
    cmd = "cp $< $@",
    tags = ["manual"],
)
