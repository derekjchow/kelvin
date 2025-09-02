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

load("@kelvin_hw//rules:chisel.bzl", "chisel_binary", "chisel_cc_library", "chisel_library")
load("@kelvin_hw//rules:coco_tb.bzl", "verilator_cocotb_model")

package(default_visibility = ["//visibility:public"])

load(
    "//tests/cocotb:build_defs.bzl",
    "VERILATOR_BUILD_ARGS",
)

chisel_library(
    name = "crossbar_config_lib",
    srcs = [
        "CrossbarConfig.scala",
        "SoCChiselConfig.scala",
    ],
    deps = [
        "//hdl/chisel/src/kelvin:kelvin_params",
    ],
)

chisel_binary(
    name = "validate_crossbar_config",
    main_class = "kelvin.soc.CrossbarConfigValidator",
    deps = [":crossbar_config_lib"],
)

chisel_library(
    name = "kelvin_xbar_lib",
    srcs = ["KelvinXbar.scala"],
    deps = [
        ":crossbar_config_lib",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/kelvin",
        "//hdl/chisel/src/kelvin:kelvin_params",
    ],
)

chisel_cc_library(
    name = "kelvin_xbar_cc_library",
    chisel_lib = ":kelvin_xbar_lib",
    emit_class = "kelvin.soc.KelvinXbarEmitter",
    module_name = "KelvinXbar",
)

chisel_cc_library(
    name = "kelvin_xbar_testharness_cc_library",
    chisel_lib = ":kelvin_xbar_lib",
    emit_class = "kelvin.soc.KelvinXbarEmitter",
    module_name = "KelvinXbarTestHarness",
    gen_flags = ["--enableTestHarness"],
)

verilator_cocotb_model(
    name = "kelvin_xbar_testharness_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "KelvinXbarTestHarness",
    trace = True,
    verilog_source = ":kelvin_xbar_testharness_cc_library_emit_verilog",
)

chisel_library(
    name = "kelvin_chisel_subsystem_lib",
    srcs = ["KelvinChiselSubsystem.scala"],
    deps = [
        ":crossbar_config_lib",
        ":kelvin_xbar_lib",
        "//hdl/chisel/src/bus",
        "//hdl/chisel/src/kelvin",
        "//hdl/chisel/src/kelvin:kelvin_params",
    ],
)

chisel_cc_library(
    name = "kelvin_chisel_subsystem_cc_library",
    chisel_lib = ":kelvin_chisel_subsystem_lib",
    emit_class = "kelvin.soc.KelvinChiselSubsystemEmitter",
    module_name = "KelvinChiselSubsystem",
)


verilator_cocotb_model(
    name = "kelvin_chisel_subsystem_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "KelvinChiselSubsystem",
    trace = True,
    verilog_source = "//hdl/chisel/src/soc:KelvinChiselSubsystem.sv",
)

chisel_cc_library(
    name = "kelvin_chisel_subsystem_testharness_cc_library",
    chisel_lib = ":kelvin_chisel_subsystem_lib",
    emit_class = "kelvin.soc.KelvinChiselSubsystemEmitter",
    module_name = "KelvinChiselSubsystemTestHarness",
    gen_flags = ["--enableTestHarness"],
)

verilator_cocotb_model(
    name = "kelvin_chisel_subsystem_testharness_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "KelvinChiselSubsystemTestHarness",
    trace = True,
    verilog_source = ":kelvin_chisel_subsystem_testharness_cc_library_emit_verilog",
)
