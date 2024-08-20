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

cc_shared_library(
    name = "Vtop",
    deps = [
        ":Vtop_internal",
        "@kelvin_hw//hdl/chisel/src/kelvin:core_mini_axi_cc_library",
        "@renode//:VerilatorIntegrationLibrary",
        "@verilator//:libverilator",
    ],
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
        "@kelvin_hw//hdl/chisel/src/kelvin:core_mini_axi_cc_library",
        "@renode//:VerilatorIntegrationLibrary",
        "@verilator//:libverilator",
    ],
)
