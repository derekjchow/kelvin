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

"""chisel build rules"""

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")
load("@kelvin_hw//rules:verilator.bzl", "verilator_cc_library")
load("@rules_hdl//verilog:providers.bzl", "verilog_library")

SCALA_COPTS = [
    "-Ymacro-annotations",
    "-Xplugin:$(execpath @org_chipsalliance_chisel_plugin//jar)",
    "-explaintypes",
    "-feature",
    "-language:reflectiveCalls",
    "-unchecked",
    "-Xcheckinit",
    "-Xlint:infer-any",
]

def chisel_library(
        name,
        srcs = [],
        deps = [],
        visibility = None):
    scala_library(
        name = name,
        srcs = srcs,
        deps = [
            "@kelvin_hw//lib:chisel_lib",
            "@org_chipsalliance_chisel_plugin//jar",
        ] + deps,
        scalacopts = SCALA_COPTS,
        visibility = visibility,
    )

def chisel_binary(
        name,
        main_class,
        srcs = [],
        deps = [],
        visibility = None):
    scala_binary(
        name = name,
        srcs = srcs,
        main_class = main_class,
        deps = [
            "@kelvin_hw//lib:chisel_lib",
            "@org_chipsalliance_chisel_plugin//jar",
        ] + deps,
        scalacopts = SCALA_COPTS,
        visibility = visibility,
    )

def chisel_cc_library(
        name,
        chisel_lib,
        emit_class,
        module_name,
        verilog_deps = []):
    gen_binary_name = name + "_emit_verilog_binary"
    chisel_binary(
        name = gen_binary_name,
        deps = [chisel_lib],
        main_class = emit_class,
    )

    native.genrule(
        name = name + "_emit_verilog",
        srcs = [],
        outs = [module_name + ".sv"],
        cmd = "PATH=$$(dirname $(execpath @kelvin_hw//third_party/llvm-firtool:firtool)):$$PATH ./$(location " + gen_binary_name + ") --target-dir $(RULEDIR)",
        tools = [
            ":{}".format(gen_binary_name),
            "@kelvin_hw//third_party/llvm-firtool:firtool",
        ],
    )

    verilog_library(
        name = name + "_verilog",
        srcs = [module_name + ".sv"],
        deps = verilog_deps,
    )

    verilator_cc_library(
        name = name,
        module = ":{}_verilog".format(name),
        module_top = module_name,
        visibility = ["//visibility:public"],
        # TODO(derekjchow): Re-enable the default -Wall?
        vopts = [],
    )
