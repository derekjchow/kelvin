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

load("@kelvin_hw//rules:chisel.bzl",
     "chisel_cc_library", "chisel_library", "chisel_test")

chisel_library(
    name = "common",
    srcs = [
        "Fifo4e.scala",
        "Fifo4.scala",
        "Fifo4x4.scala",
        "Fifo.scala",
        "IDiv.scala",
        "Library.scala",
        "MathUtil.scala",
        "Slice.scala",
    ],
    visibility = ["//visibility:public"],
)

chisel_library(
    name = "fp",
    srcs = [
        "Fp.scala",
    ],
)

chisel_test(
    name = "fp_test",
    srcs = [
        "FpTest.scala",
    ],
    deps = [
        ":fp",
    ],
)

chisel_library(
    name = "fpu",
    srcs = [
        "Fpu.scala",
    ],
    deps = [
        ":common",
        ":fp",
    ],
)

chisel_test(
    name = "fpu_test",
    srcs = [
        "FpuTest.scala",
    ],
    deps = [
        ":fp",
        ":fpu",
    ],
)
