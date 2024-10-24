# Copyright 2023 Google LLC

load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

cmake(
    name = "systemc",
    cache_entries = {
        "CMAKE_POSITION_INDEPENDENT_CODE": "ON",
        "CMAKE_CXX_STANDARD": "17",
        "BUILD_SHARED_LIBS": "False",
        "CMAKE_INSTALL_LIBDIR": "lib",
    },
    generate_args = [
        "-G Ninja",
    ],
    install = True,
    lib_source = "@accellera_systemc//:all_srcs",
    out_static_libs = ["libsystemc.a"],
    targets = ["systemc"],
    visibility = ["//visibility:public"],
)
