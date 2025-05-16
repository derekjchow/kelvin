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

"""Convinence wrapper for Verilator driven cocotb."""

load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@kelvin_hw//third_party/python:requirements.bzl", "requirement")
load("@rules_hdl//cocotb:cocotb.bzl", "cocotb_test")
load("@rules_python//python:defs.bzl", "py_library")

def verilator_cocotb_test(name,
                          hdl_toplevel,
                          test_module,
                          deps=[],
                          data=[],
                          **kwargs):
    kwargs.update(
        hdl_toplevel_lang="verilog",
        sim_name = "verilator",
        sim = [
            "@verilator//:verilator",
            "@verilator//:verilator_bin",
        ])

    # Wrap in py_library so we can forward data
    py_library(
        name = name + "_test_data",
        srcs = [],
        deps = deps + [
            requirement("cocotb"),
            requirement("numpy"),
            requirement("pytest"),
        ],
        data = data,
    )

    cocotb_test(
        name = name,
        hdl_toplevel = hdl_toplevel,
        test_module = test_module,
        deps = [
            ":{}_test_data".format(name),
        ],
        **kwargs,
    )

def vcs_cocotb_test(name,
                    hdl_toplevel,
                    test_module,
                    testcases=[],
                    deps=[],
                    data=[],
                    **kwargs):
    tags = kwargs.pop("tags", [])
    tags.append("vcs")
    kwargs.update(
        hdl_toplevel_lang="verilog",
        sim_name = "vcs",
        sim = [],
        tags = tags)

    # Wrap in py_library so we can forward data
    py_library(
        name = name + "_test_data",
        srcs = [],
        deps = deps + [
            requirement("cocotb"),
            requirement("numpy"),
            requirement("pytest"),
        ],
        data = data,
    )

    test_args = kwargs.pop("test_args", [""])
    [cocotb_test(
        name = "{}_{}".format(name, tc),
        hdl_toplevel = hdl_toplevel,
        test_module = test_module,
        testcase = [tc],
        test_args = ["{} -cm_name {}".format(test_args[0], tc)] + test_args[1:],
        deps = [
            ":{}_test_data".format(name),
        ],
        **kwargs,
    ) for tc in testcases]
