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

load("//rules:coralnpu_v2.bzl", "coralnpu_v2_binary")

cc_library(
    name = "hw_primitives",
    srcs = [
        "hw_primitives.cc",
    ],
    hdrs = [
        "hw_primitives.h",
    ],
    deps = [
        "@com_google_absl//absl/types:span",
        "@verilator//:libverilator",
    ],
)

cc_library(
    name = "core_mini_axi_wrapper",
    hdrs = [
        "core_mini_axi_wrapper.h",
        "mailbox.h",
    ],
    deps = [
        ":hw_primitives",
        "//hdl/chisel/src/coralnpu:core_mini_axi_cc_library_cc",
        "//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_cc",
    ],
)

cc_binary(
    name = "core_mini_axi_wrapper_example",
    srcs = [
        "core_mini_axi_wrapper_example.cc",
    ],
    data = [
        "//tests/cocotb:wfi_slot_0.elf",
    ],
    deps = [
        ":core_mini_axi_wrapper",
        "//tests/verilator_sim:elf",
    ],
)

cc_library(
    name = "coralnpu_simulator_headers",
    hdrs = [
        "coralnpu_simulator.h",
        "mailbox.h",
    ],
)

cc_library(
    name = "core_mini_axi_simulator",
    srcs = ["core_mini_axi_simulator.cc"],
    linkstatic = True,
    deps = [
        ":core_mini_axi_wrapper",
        ":coralnpu_simulator_headers",
    ],
    alwayslink = True,
)

cc_library(
    name = "core_mini_axi_simulator_rvv",
    srcs = ["core_mini_axi_simulator.cc"],
    copts = ["-DENABLE_RVV"],
    linkstatic = True,
    deps = [
        ":core_mini_axi_wrapper",
        ":coralnpu_simulator_headers",
    ],
    alwayslink = True,
)

coralnpu_v2_binary(
    name = "mailbox_example",
    srcs = [
        "mailbox_example.cc",
    ],
)

cc_binary(
    name = "core_mini_axi_simulator_example",
    srcs = [
        "core_mini_axi_simulator_example.cc",
    ],
    data = [
        ":mailbox_example.elf",
    ],
    deps = [
        ":core_mini_axi_simulator",
        "//tests/verilator_sim:elf",
    ],
)

# generate libraries for external projects
cc_binary(
    name = "libcoralnpu_simulator.so",
    linkshared = True,
    visibility = ["//visibility:public"],
    deps = [":core_mini_axi_simulator"],
)

cc_binary(
    name = "libcoralnpu_simulator_rvv.so",
    linkshared = True,
    visibility = ["//visibility:public"],
    deps = [":core_mini_axi_simulator_rvv"],
)
