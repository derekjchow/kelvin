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
    name = "library",
    srcs = [
        "Library.scala",
    ],
    visibility = ["//visibility:public"],
)

chisel_library(
    name = "common",
    srcs = [
        "FifoXe.scala",
        "FifoX.scala",
        "FifoIxO.scala",
        "Fifo.scala",
        "IDiv.scala",
        "MathUtil.scala",
        "Slice.scala",
    ],
    deps = [
        ":library",
    ],
    visibility = ["//visibility:public"],
)

chisel_library(
    name = "fp",
    srcs = [
        "Fp.scala",
    ],
    deps = [
        ":library",
    ],
    visibility = ["//visibility:public"],
)

chisel_library(
    name = "fp_test_utils",
    srcs = [
        "FpTestUtils.scala",
    ],
    deps = [
        "@edu_berkeley_cs_chiseltest//jar",
        ":fp",
    ],
    visibility = ["//visibility:public"],
)

chisel_test(
    name = "fp_test",
    srcs = [
        "FpTest.scala",
    ],
    deps = [
        ":fp",
        ":fp_test_utils",
    ],
)

chisel_library(
    name = "fma",
    srcs = [
        "Fma.scala",
    ],
    deps = [
        ":common",
        ":fp",
    ],
    visibility = ["//visibility:public"],
)

chisel_test(
    name = "fma_test",
    srcs = [
        "FmaTest.scala",
    ],
    deps = [
        ":fp",
        ":fma",
    ],
)
