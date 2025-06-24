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

load("@kelvin_hw//third_party/python:requirements.bzl", "requirement")

py_library(
    name = "core_mini_axi_sim_interface",
    srcs = [
        "core_mini_axi_interface.py",
    ],
    deps = [
        requirement("cocotb"),
        requirement("numpy"),
        requirement("pyelftools"),
    ],
    visibility = [ "//visibility:public" ],
)

py_library(
    name = "sim_test_fixture",
    srcs = [
        "sim_test_fixture.py",
    ],
    deps = [
        requirement("cocotb"),
        requirement("numpy"),
        ":core_mini_axi_sim_interface",
    ],
    visibility = [ "//visibility:public" ],
)

py_library(
    name = "core_mini_axi_pyocd_gdbserver",
    srcs = [
        "core_mini_axi_pyocd_gdbserver.py",
    ],
    deps = [
        requirement("cocotb"),
        requirement("pyocd"),
    ],
    data = [
        "//toolchain:gdb",
    ],
    visibility = ["//visibility:public"],
)