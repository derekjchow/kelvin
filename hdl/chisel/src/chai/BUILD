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

load("@kelvin_hw//rules:chisel.bzl", "chisel_cc_library", "chisel_library")

package(default_visibility = ["//visibility:public"])

chisel_library(
    name = "chai",
    srcs = [
        "ChAI.scala",
        "TlulAdapterSram.scala",
        "Uart.scala",
    ],
    deps = [
        "//hdl/chisel/src/bus:bus",
        "//hdl/chisel/src/kelvin:kelvin",
        "//hdl/chisel/src/kelvin:kelvin_params",
        "//hdl/chisel/src/matcha:matcha",
    ],
)

chisel_cc_library(
    name = "chai_cc_library",
    chisel_lib = ":chai",
    emit_class = "chai.EmitChAI",
    module_name = "ChAI",
    verilog_deps = [
        "//hdl/verilog:sram_1rw_256x256",
        "//hdl/verilog:sram_1rw_256x288",
        "//hdl/verilog:tlul_adapter_sram",
        "//hdl/verilog:uart",
    ],
    vopts = [
        "-DUSE_GENERIC",
    ],
)
