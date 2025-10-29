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

load("@rules_hdl//verilog:providers.bzl", "verilog_library")

exports_files(
    srcs = [
        "ClockGate.sv",
        "Sram_12ffcp_128x128.v",
        "Sram_512x128.v",
        "Sram_2048x128.v",
        "Sram_1rw_256x256.v",
        "Sram_1rwm_256x288.v",
        "RstSync.sv",
        "TlulAdapterSram.sv",
        "Uart.sv",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "clock_gate",
    srcs = ["ClockGate.sv"],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "RstSync",
    srcs = ["RstSync.sv"],
    visibility = ["//visibility:public"],
    deps = [
        ":clock_gate",
    ]
)

verilog_library(
    name = "sram_1rw_256x256",
    srcs = ["Sram_1rw_256x256.v"],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "Sram_12ffcp_128x128",
    srcs = ["Sram_12ffcp_128x128.v"],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "sram_1rw_256x288",
    srcs = ["Sram_1rwm_256x288.v"],
    visibility = ["//visibility:public"],
)
