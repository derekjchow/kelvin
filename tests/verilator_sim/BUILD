# Copyright 2023 Google LLC

cc_library(
    name = "sim_libs",
    hdrs = [
        "fifo.h",
        "sysc_module.h",
        "sysc_tb.h",
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
        "//hdl/chisel:core_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "dbus2axi_tb",
    srcs = [
        "kelvin/dbus2axi_tb.cc",
    ],
    deps = [
        ":sim_libs",
        "//hdl/chisel:dbus2axi_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "l1dcache_tb",
    srcs = [
        "kelvin/l1dcache_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:l1dcache_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "l1icache_tb",
    srcs = [
        "kelvin/l1icache_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:l1icache_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

# TODO(derekjchow): Add valu and valuint test benches

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

cc_binary(
    name = "vcmdq_tb",
    srcs = [
        "kelvin/vcmdq_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel:vcmdq_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "vconvalu_tb",
    srcs = [
        "kelvin/vconvalu_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:vconvalu_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_test(
    name = "vconvctrl_tb",
    srcs = [
        "kelvin/vconvctrl_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel:vconvctrl_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_test(
    name = "vdecodeinstruction_tb",
    srcs = [
        "kelvin/vdecodeinstruction_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vdecode",
        "//hdl/chisel:vdecodeinstruction_cc_library",
        "@accellera_systemc//:systemc",
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
        "//hdl/chisel:vdecode_cc_library",
        "@accellera_systemc//:systemc",
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
        "//hdl/chisel:vldst_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_test(
    name = "vld_tb",
    srcs = [
        "kelvin/vld_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        ":vencodeop",
        "//hdl/chisel:vld_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "vregfilesegment_tb",
    srcs = [
        "kelvin/vregfilesegment_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:vregfilesegment_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "vregfile_tb",
    srcs = [
        "kelvin/vregfile_tb.cc",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:vregfile_cc_library",
        "@accellera_systemc//:systemc",
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
        "//hdl/chisel:vst_cc_library",
        "@accellera_systemc//:systemc",
    ],
)

cc_binary(
    name = "kelvin_tb",
    srcs = [
        "matcha/kelvin_tb.cc",
        "matcha/kelvin_if.h",
    ],
    deps = [
        ":kelvin_if",
        ":sim_libs",
        "//hdl/chisel:kelvin_cc_library",
        "@accellera_systemc//:systemc",
    ]
)
