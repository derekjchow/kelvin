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
    "chisel_library",
    "chisel_cc_library",
)
load("@kelvin_hw//rules:coco_tb.bzl", "cocotb_test_suite", "verilator_cocotb_model")
load("@kelvin_hw//third_party/python:requirements.bzl", "requirement")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "bus",
    srcs = [
        "Axi.scala",
        "TLUL2Axi.scala",
        "Axi2TLUL.scala",
        "KelvinMemIO.scala",
        "KelvinToTlul.scala",
        "TileLinkUL.scala",
    ],
    deps = [
        "//hdl/chisel/src/kelvin:kelvin_params",
        "//hdl/chisel/src/common",
    ],
)

chisel_cc_library(
    name = "tlul2axi_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitTLUL2Axi",
    module_name = "TLUL2Axi",
)

verilator_cocotb_model(
    name = "tlul2axi_model",
    hdl_toplevel = "TLUL2Axi",
    verilog_source = "//hdl/chisel/src/bus:TLUL2Axi.sv",
    cflags = [],
    trace = True,
)

# BEGIN_TESTCASES_FOR_tlul2axi_cocotb_test
TLUL2AXI_TESTCASES = [
    "test_put_request",
    "test_get_request",
    "test_backpressure",
    "test_put_then_get",
]
# END_TESTCASES_FOR_tlul2axi_cocotb_test

cocotb_test_suite(
    name = "tlul2axi_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = TLUL2AXI_TESTCASES,
    testcases_vname = "TLUL2AXI_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "TLUL2Axi",
        "test_module": ["tlul2axi_cocotb_test.py"],
        "size": "large",
        "deps": [
            "@bazel_tools//tools/python/runfiles",
            requirement("tqdm"),
        ],
        "waves": True,
    },
    vcs_verilog_sources = ["//hdl/chisel/src/bus:tlul2axi_cc_library_verilog"],
    verilator_model = ":tlul2axi_model",
)

chisel_cc_library(
    name = "axi2tlul_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitAxi2TLUL",
    module_name = "Axi2TLUL",
)

verilator_cocotb_model(
    name = "axi2tlul_model",
    hdl_toplevel = "Axi2TLUL",
    verilog_source = "//hdl/chisel/src/bus:Axi2TLUL.sv",
    cflags = [],
    trace = True,
)

# BEGIN_TESTCASES_FOR_axi2tlul_cocotb_test
AXI2TLUL_TESTCASES = [
    "test_write_request",
    "test_read_request",
]
# END_TESTCASES_FOR_axi2tlul_cocotb_test

cocotb_test_suite(
    name = "axi2tlul_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = AXI2TLUL_TESTCASES,
    testcases_vname = "AXI2TLUL_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "Axi2TLUL",
        "test_module": ["axi2tlul_cocotb_test.py"],
        "size": "large",
        "deps": [
            "@bazel_tools//tools/python/runfiles",
            requirement("tqdm"),
        ],
        "waves": True,
    },
    vcs_verilog_sources = ["//hdl/chisel/src/bus:axi2tlul_cc_library_verilog"],
    verilator_model = ":axi2tlul_model",
)