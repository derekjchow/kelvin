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

load("@coralnpu_hw//third_party/python:requirements.bzl", "requirement")

package(default_visibility = ["//visibility:public"])

# Library for interacting with the SPI DPI master via ctypes.
py_library(
    name = "spi_driver",
    srcs = ["spi_driver.py"],
)

# Binary to load a program onto the CoralNPU SoC and start execution.
py_binary(
    name = "loader",
    srcs = ["loader.py"],
    deps = [
        ":spi_driver",
        "//coralnpu_test_utils:spi_constants",
        requirement("pyelftools"),
    ],
)

# Binary to run the full SoC simulation and monitor its execution.
py_binary(
    name = "run_simulation",
    srcs = ["run_simulation.py"],
    data = [
        ":loader",
        "//fpga:copy_chip_verilator_binary",
    ],
    tags = ["manual"],
    deps = [
        "@bazel_tools//tools/python/runfiles",
    ],
)
