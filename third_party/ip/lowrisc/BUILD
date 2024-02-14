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

load("@rules_hdl//verilog:providers.bzl", "verilog_library")

verilog_library(
    name = "prim_generic",
    srcs = [
        "@lowrisc_opentitan//hw/ip/prim_generic:rtl/prim_generic_clock_gating.sv",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "prim_xilinx",
    srcs = [
        "@lowrisc_opentitan//hw/ip/prim_xilinx:rtl/prim_xilinx_clock_gating.sv",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "prim",
    # Do not sort: "*_pkg" comes first.
    srcs = [
        "@lowrisc_opentitan//hw:vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_pkg.sv",
        "@lowrisc_opentitan//hw:vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_clock_gating.sv",
    ],
    deps = [
        ":prim_generic",
        ":prim_xilinx",
    ],
    visibility = ["//visibility:public"],
)
