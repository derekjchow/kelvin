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

load("@kelvin_hw//rules:coco_tb.bzl", "cocotb_test_suite", "verilator_cocotb_model")
load("@kelvin_hw//third_party/python:requirements.bzl", "requirement")

package(default_visibility = ["//visibility:public"])

load(
    "//tests/cocotb:build_defs.bzl",
    "VCS_BUILD_ARGS",
    "VCS_DEFINES",
    "VCS_TEST_ARGS",
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
    simulators = [
        "verilator",
        "vcs",
    ],
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
    verilator_model = "//hdl/chisel/src/bus:tlul2axi_model",
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)

# BEGIN_TESTCASES_FOR_axi2tlul_cocotb_test
AXI2TLUL_TESTCASES = [
    "test_write_request",
    "test_read_request",
    "test_read_error",
]
# END_TESTCASES_FOR_axi2tlul_cocotb_test

cocotb_test_suite(
    name = "axi2tlul_cocotb_test",
    simulators = [
        "verilator",
        "vcs",
    ],
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
    verilator_model = "//hdl/chisel/src/bus:axi2tlul_model",
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)

# BEGIN_TESTCASES_FOR_tlul_integrity_cocotb_test
TLUL_INTEGRITY_TESTCASES = [
    "test_request_integrity_gen",
    "test_request_integrity_check",
    "test_response_integrity_gen",
    "test_response_integrity_check",
]
# END_TESTCASES_FOR_tlul_integrity_cocotb_test

cocotb_test_suite(
    name = "tlul_integrity_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = TLUL_INTEGRITY_TESTCASES,
    testcases_vname = "TLUL_INTEGRITY_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "TlulIntegrityTestbench",
        "test_module": ["test_tlul_integrity.py"],
        "deps": [
            "//kelvin_test_utils:TileLinkULInterface",
            "//kelvin_test_utils:secded_golden",
        ],
        "waves": True,
    },
    verilator_model = "//hdl/chisel/src/bus:tlul_integrity_testbench_model",
    vcs_verilog_sources = ["//hdl/chisel/src/bus:tlul_integrity_testbench_cc_library_verilog"],
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)



# BEGIN_TESTCASES_FOR_secded_encoder_cocotb_test
SECDED_ENCODER_TESTCASES = [
    "test_secded_encoder",
]
# END_TESTCASES_FOR_secded_encoder_cocotb_test

cocotb_test_suite(
    name = "secded_encoder_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = SECDED_ENCODER_TESTCASES,
    testcases_vname = "SECDED_ENCODER_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "SecdedEncoderTestbench128",
        "test_module": ["test_secded_encoder.py"],
        "deps": [
            "//kelvin_test_utils:secded_golden",
        ],
        "waves": True,
    },
    verilator_model = "//hdl/chisel/src/bus:secded_encoder_testbench_model",
    vcs_verilog_sources = ["//hdl/chisel/src/bus:secded_encoder_testbench_cc_library_verilog"],
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)

cocotb_test_suite(
    name = "secded_encoder_32_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = SECDED_ENCODER_TESTCASES,
    testcases_vname = "SECDED_ENCODER_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "SecdedEncoderTestbench32",
        "test_module": ["test_secded_encoder.py"],
        "deps": [
            "//kelvin_test_utils:secded_golden",
        ],
        "waves": True,
    },
    verilator_model = "//hdl/chisel/src/bus:secded_encoder_testbench_32_model",
    vcs_verilog_sources = ["//hdl/chisel/src/bus:secded_encoder_testbench_32_cc_library_verilog"],
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)

cocotb_test_suite(
    name = "secded_encoder_57_cocotb_test",
    simulators = ["verilator", "vcs"],
    testcases = SECDED_ENCODER_TESTCASES,
    testcases_vname = "SECDED_ENCODER_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "SecdedEncoderTestbench57",
        "test_module": ["test_secded_encoder.py"],
        "deps": [
            "//kelvin_test_utils:secded_golden",
        ],
        "waves": True,
    },
    verilator_model = "//hdl/chisel/src/bus:secded_encoder_testbench_57_model",
    vcs_verilog_sources = ["//hdl/chisel/src/bus:secded_encoder_testbench_57_cc_library_verilog"],
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_defines = VCS_DEFINES,
)
