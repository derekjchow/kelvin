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

package(default_visibility = ["//visibility:public"])

load("@com_github_grpc_grpc//bazel:grpc_build_system.bzl", "grpc_proto_library")
load("@com_github_grpc_grpc//bazel:python_rules.bzl", "py_grpc_library", "py_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

exports_files([
    "stty",
    "coralnpu-verilator.resc",
    "coralnpu-verilator.repl",
    "Vtop_bin.py",
    "Vtop_master.py",
    "Vtop_slave.py",
])

grpc_proto_library(
    name = "coralnpu_grpc_cc",
    srcs = [":coralnpu.proto"],
)

proto_library(
    name = "coralnpu_proto_descriptor",
    srcs = [":coralnpu.proto"],
)

py_proto_library(
    name = "coralnpu_py_pb2",
    deps = [":coralnpu_proto_descriptor"],
)

py_grpc_library(
    name = "coralnpu_grpc_py",
    deps = [":coralnpu_py_pb2"],
    srcs = [":coralnpu_proto_descriptor"],
)

py_binary(
    name = "Vtop_master",
    main = "Vtop_master.py",
    srcs = [":Vtop_master.py"],
    deps = [":coralnpu_grpc_py"],
)

py_binary(
    name = "Vtop_slave",
    main = "Vtop_slave.py",
    srcs = [":Vtop_slave.py"],
    deps = [":coralnpu_grpc_py"],
)

cc_library(
    name = "Vtop_internal",
    srcs = [
      "sim_main.cc",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/communication/socket_channel.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/buses/axi.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/buses/axi-slave.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/buses/wishbone.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/buses/apb3.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/buses/axilite.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/peripherals/uart.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/renode_dpi.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/src/renode_bus.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/libs/socket-cpp/Socket/TCPClient.cpp",
      "@renode//:src/Plugins/VerilatorPlugin/VerilatorIntegrationLibrary/libs/socket-cpp/Socket/Socket.cpp",
    ],
    deps = [
        ":coralnpu_grpc_cc",
        "@com_github_grpc_grpc//:grpc++",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:core_mini_axi_cc_library_cc",
        "@renode//:VerilatorIntegrationLibrary",
        "@verilator//:libverilator",
    ],
)

cc_binary(
    name = "Vtop_bin",
    deps = [
        ":Vtop_internal",
        "@coralnpu_hw//hdl/chisel/src/coralnpu:core_mini_axi_cc_library_cc",
        "@renode//:VerilatorIntegrationLibrary",
        "@verilator//:libverilator",
    ],
)
