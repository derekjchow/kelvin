# Copyright 2023 Google LLC
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
    srcs = [":Kelvin.v"],
    outs = ["kelvin.v"],
    cmd = """
    echo "// SHA: $$(awk '/KELVIN_BUILD_GIT_VERSION/ { print $$2 }' \
      bazel-out/volatile-status.txt)" > $@
    cat $< >> $@
    """,
    stamp = 1,  # this provides volatile-status.txt
)
