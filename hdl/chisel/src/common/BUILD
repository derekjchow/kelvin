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
    "chisel_cc_library",
    "chisel_library",
    "chisel_test",
)

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
        "Fifo.scala",
        "FifoIxO.scala",
        "FifoX.scala",
        "FifoXe.scala",
        "IDiv.scala",
        "KelvinArbiter.scala",
        "MathUtil.scala",
        "Slice.scala",
    ],
    visibility = ["//visibility:public"],
    exports = [
        ":library",
    ],
    deps = [
        ":library",
    ],
)

chisel_library(
    name = "aligner",
    srcs = [
        "Aligner.scala"
    ],
    resources = [
        "//hdl/verilog/rvv/design:Aligner.sv",
    ],
    visibility = ["//visibility:public"],
)

chisel_test(
    name = "aligner_test",
    srcs = [
        "AlignerTest.scala",
    ],
    tags = ["verilator"],
    deps = [
        ":aligner",
    ],
)

chisel_library(
    name = "scatter_gather",
    srcs = [
        "ScatterGather.scala",
    ],
    visibility = ["//visibility:public"],
)

chisel_library(
    name = "fp",
    srcs = [
        "Fp.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":library",
    ],
)

chisel_library(
    name = "fp_test_utils",
    srcs = [
        "FpTestUtils.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":fp",
        "@edu_berkeley_cs_chiseltest//jar",
    ],
)

chisel_library(
    name = "instruction_buffer",
    srcs = [
        "InstructionBuffer.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":library",
    ],
)

chisel_library(
    name = "circular_buffer_multi",
    srcs = [
        "CircularBufferMulti.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":library",
    ],
)

chisel_test(
    name = "common_test",
    srcs = [
        "KelvinArbiterTest.scala",
    ],
    deps = [
        ":common",
    ],
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

chisel_test(
    name = "instruction_buffer_test",
    srcs = [
        "InstructionBufferTest.scala",
    ],
    deps = [
        ":instruction_buffer",
    ],
)

chisel_test(
    name = "circular_buffer_multi_test",
    srcs = [
        "CircularBufferMultiTest.scala",
    ],
    deps = [
        ":circular_buffer_multi",
    ],
)

chisel_test(
    name = "library_test",
    srcs = [
        "LibraryTest.scala",
    ],
    deps = [
        ":library",
    ],
)

chisel_test(
    name = "scatter_gather_test",
    srcs = [
        "ScatterGatherTest.scala",
    ],
    deps = [
        ":scatter_gather",
    ],
    size = "large",
)

chisel_library(
    name = "fma",
    srcs = [
        "Fma.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":common",
        ":fp",
    ],
)

chisel_test(
    name = "fma_test",
    srcs = [
        "FmaTest.scala",
    ],
    deps = [
        ":fma",
        ":fp",
    ],
)

chisel_library(
    name = "testing",
    srcs = [
        "TestingUtils.scala",
    ],
    visibility = ["//visibility:public"],
)
