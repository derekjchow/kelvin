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
load("//rules:kelvin_v2.bzl", "kelvin_v2_binary")
load("//rules:utils.bzl", "cc_embed_data")
load(":rules.bzl", "tlgen_rule")

package(default_visibility = ["//visibility:public"])

_CLOCK_FREQUENCY_MHZ = "10"

# This is the tlgen.py script itself
py_binary(
    name = "tlgen_tool",
    srcs = ["@lowrisc_opentitan_gh//util:tlgen.py"],
    main = "@lowrisc_opentitan_gh//util:tlgen.py",
    deps = [
        "@kelvin_pip_deps_hjson//:pkg",
        "@lowrisc_opentitan_gh//util/tlgen",
    ],
)

tlgen_rule(
    name = "tl_crossbar_generated",
    topcfg = "tl_config.hjson",
)

py_binary(
    name = "post_process_xbar",
    srcs = ["post_process_xbar.py"],
)

genrule(
    name = "tl_crossbar_processed",
    srcs = [":tl_crossbar_generated"],
    outs = [
        "tl_crossbar_processed_out",
    ],
    cmd = "$(execpath :post_process_xbar) " +
          "--input-dir $(location :tl_crossbar_generated) " +
          "--output-dir $(location tl_crossbar_processed_out) " +
          "--cores kelvinv2:ip:kelvin_tlul:0.1",
    tools = [":post_process_xbar"],
)

filegroup(
    name = "tl_crossbar",
    srcs = [
        ":tl_crossbar_processed_out",
    ],
)

filegroup(
    name = "tl_crossbar_core",
    srcs = [":tl_crossbar"],
)

filegroup(
    name = "rtl_files",
    srcs = glob(["**/*.sv"]) + glob(["**/*.core"]) + [
        "//fpga/ip/kelvin_tlul:rtl_files",
        "//fpga/ip/rv_core_ibex:rtl_files",
        "//fpga/ip/rvv_core_mini_tlul:rtl_files",
        "//fpga/ip/sram:rtl_files",
        "//fpga/ip/tlul_width_bridge:rtl_files",
        "//fpga/rtl:rtl_files",
    ],
)

string_list_flag(
    name = "verilator_options",
    build_setting_default = [
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
        "-DRVFI",
        "-DUSE_GENERIC",
    ],
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

kelvin_v2_binary(
    name = "ibex_boot_rom",
    srcs = [
        "sw/ibex_boot_rom.S",
        "sw/main.cc",
    ],
    hdrs = [":add_uint32_m1_bin_header"],
    copts = ["-DCLOCK_FREQUENCY_MHZ=" + _CLOCK_FREQUENCY_MHZ],
    linker_script = "sw/ibex_boot_rom.ld",
)

kelvin_v2_binary(
    name = "add_uint32_m1",
    srcs = ["sw/add_uint32_m1.cc"],
    copts = ["-DCLOCK_FREQUENCY_MHZ=" + _CLOCK_FREQUENCY_MHZ],
)

filegroup(
    name = "ibex_boot_rom_bin",
    srcs = [":ibex_boot_rom"],
    output_group = "bin_file",
)

filegroup(
    name = "add_uint32_m1_bin",
    srcs = [":add_uint32_m1"],
    output_group = "bin_file",
)

KELVIN_SOC_CORES = [
    "//fpga/ip/rv_core_ibex:rv_core_ibex.core",
    ":kelvin_soc.core",
    ":kelvin_soc_pkg.core",
    ":racl_pkg.core",
    ":tl_crossbar_core",
    "@lowrisc_opentitan_gh//hw:check_tool_requirements.core",
]

KELVIN_SOC_SRCS = [
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
    srcs = KELVIN_SOC_SRCS + [
        ":ibex_boot_rom.vmem",
        "@lowrisc_opentitan_gh//hw:dpi_files",
    ],
    cores = KELVIN_SOC_CORES + [
        ":chip_verilator.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi.core",
        "@lowrisc_opentitan_gh//hw/dv:dpi/uartdpi/uartdpi_sv.core",
    ],
    flags = [
        "--MemInitFile=$(location :ibex_boot_rom.vmem)",
        "--ClockFrequencyMhz=" + _CLOCK_FREQUENCY_MHZ,
    ],
    make_options = ":make_options",
    output_groups = {
        "binary": ["com.google.kelvin_fpga_chip_verilator_0.1/sim-verilator/Vchip_verilator"],
    },
    systems = ["com.google.kelvin:fpga:chip_verilator:0.1"],
    target = "sim",
    verilator_options = ":verilator_options",
    tags = ["manual"],
)

_PREFIX = "../../../../../../../../.."

#          "../../../../../../../"bazel-out/k8-fastbuild-ST-be77d280135c/bin/fpga
#          "../../../../../../../"bazel-out/k8-fastbuild-ST-be77d280135c/bin/fpga/wfi.vmem
_IBEX_BOOT_ROM_VMEM = ":ibex_boot_rom.vmem"

IBEX_BOOT_ROM_VMEM_PATH = "{}/$(location {})".format(_PREFIX, _IBEX_BOOT_ROM_VMEM)

fusesoc_build(
    name = "build_chip_nexus_bitstream",
    srcs = KELVIN_SOC_SRCS + [
        "pins.xdc",
        "vivado_setup_hooks.tcl",
        ":ibex_boot_rom.vmem",
    ],
    cores = KELVIN_SOC_CORES + [":chip_nexus.core"],
    flags = [
        "--MemInitFile=" + IBEX_BOOT_ROM_VMEM_PATH,
        "--ClockFrequencyMhz=" + _CLOCK_FREQUENCY_MHZ,
    ],
    output_groups = {
        # /home/atv/.cache/bazel/_bazel_atv/cb485e413f28624e05d5dee28237de6d/sandbox/
        # linux-sandbox/34/execroot/kelvin_hw/bazel-out/k8-fastbuild/bin/fpga/
        # build.build_chip_nexus_bitstream/
        # com.google.kelvin_fpga_chip_nexus_0.1/synth-vivado/com.google.kelvin_fpga_chip_nexus_0.1.runs/impl_1/chip_nexus.bit
        "bitstream": ["com.google.kelvin_fpga_chip_nexus_0.1/synth-vivado/com.google.kelvin_fpga_chip_nexus_0.1.runs/impl_1/chip_nexus.bit"],
        # /home/atv/.cache/bazel/_bazel_atv/cb485e413f28624e05d5dee28237de6d/sandbox/
        # linux-sandbox/34/execroot/kelvin_hw/bazel-out/k8-fastbuild/bin/fpga/
        # build.build_chip_nexus_bitstream/
        # com.google.kelvin_fpga_chip_nexus_0.1/synth-vivado/com.google.kelvin_fpga_chip_nexus_0.1.runs/
        "logs": ["com.google.kelvin_fpga_chip_nexus_0.1/synth-vivado/com.google.kelvin_fpga_chip_nexus_0.1.runs/"],
    },
    systems = ["com.google.kelvin:fpga:chip_nexus:0.1"],
    target = "synth",
    tags = ["manual"],
)
