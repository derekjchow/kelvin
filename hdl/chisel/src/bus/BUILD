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
    "@coralnpu_hw//rules:chisel.bzl",
    "chisel_library",
    "chisel_cc_library",
)
load("@coralnpu_hw//rules:coco_tb.bzl", "cocotb_test_suite", "verilator_cocotb_model")
load("@coralnpu_hw//third_party/python:requirements.bzl", "requirement")

package(default_visibility = ["//visibility:public"])

load(
    "//tests/cocotb:build_defs.bzl",
    "VERILATOR_BUILD_ARGS",
)

chisel_library(
    name = "bus",
    srcs = [
        "Axi.scala",
        "TlulIdRemapper.scala",
        "TLUL2Axi.scala",
        "Axi2TLUL.scala",
        "CoralNPUMemIO.scala",
        "SecdedEncoderTestbench.scala",
        "Spi2TLUL.scala",
        "TileLinkUL.scala",
        "TlulFifoAsync.scala",
        "TlulFifoSync.scala",
        "TlulIntegrity.scala",
        "TlulIntegrityTestbench.scala",
        "TlulSocket1N.scala",
        "TlulSocketM1.scala",
        "TlulWidthBridge.scala",
    ],
    deps = [
        "//hdl/chisel/src/common",
        "//hdl/chisel/src/coralnpu:coralnpu_params",
        "@chipsalliance_rocket_chip//:asyncqueue",
    ],
)

chisel_cc_library(
    name = "axi2tlul_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitAxi2TLUL",
    module_name = "Axi2TLUL",
)

chisel_cc_library(
    name = "tlul2axi_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitTLUL2Axi",
    module_name = "TLUL2Axi",
)

chisel_cc_library(
    name = "tlul_fifo_async_128_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.TlulFifoAsync128Emitter",
    module_name = "TlulFifoAsync128",
)

chisel_cc_library(
    name = "tlul_socket_1n_128_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.TlulSocket1N_128Emitter",
    module_name = "TlulSocket1N_128",
)

chisel_cc_library(
    name = "tlul_fifo_sync_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.TlulFifoSyncEmitter",
    module_name = "TlulFifoSync",
)

chisel_cc_library(
    name = "tlul_socket_m1_2_128_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.TlulSocketM1_2_128Emitter",
    module_name = "TlulSocketM1_2_128",
)

chisel_cc_library(
    name = "tlul_socket_m1_3_128_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.TlulSocketM1_3_128Emitter",
    module_name = "TlulSocketM1_3_128",
)

chisel_cc_library(
    name = "spi2tlul_128_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.Spi2TLUL_128_Emitter",
    module_name = "Spi2TLUL",
)

verilator_cocotb_model(
    name = "spi2tlul_128_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "Spi2TLUL",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:Spi2TLUL.sv",
)

verilator_cocotb_model(
    name = "tlul_socket_m1_2_128_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TlulSocketM1_2_128",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TlulSocketM1_2_128.sv",
)

verilator_cocotb_model(
    name = "tlul_fifo_async_128_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TlulFifoAsync128",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TlulFifoAsync128.sv",
)

verilator_cocotb_model(
    name = "tlul_fifo_sync_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TlulFifoSync",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TlulFifoSync.sv",
)

verilator_cocotb_model(
    name = "axi2tlul_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "Axi2TLUL",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:Axi2TLUL.sv",
)

verilator_cocotb_model(
    name = "tlul2axi_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TLUL2Axi",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TLUL2Axi.sv",
)

chisel_cc_library(
    name = "tlul_integrity_testbench_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitTlulIntegrityTestbench",
    module_name = "TlulIntegrityTestbench",
)

verilator_cocotb_model(
    name = "tlul_integrity_testbench_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TlulIntegrityTestbench",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TlulIntegrityTestbench.sv",
)

verilator_cocotb_model(
    name = "tlul_socket_1n_128_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "TlulSocket1N_128",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:TlulSocket1N_128.sv",
)

chisel_cc_library(
    name = "secded_encoder_testbench_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitSecdedEncoderTestbench",
    module_name = "SecdedEncoderTestbench128",
)

verilator_cocotb_model(
    name = "secded_encoder_testbench_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "SecdedEncoderTestbench128",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:SecdedEncoderTestbench128.sv",
)

chisel_cc_library(
    name = "secded_encoder_testbench_32_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitSecdedEncoderTestbench32",
    module_name = "SecdedEncoderTestbench32",
)

verilator_cocotb_model(
    name = "secded_encoder_testbench_32_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "SecdedEncoderTestbench32",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:SecdedEncoderTestbench32.sv",
)

chisel_cc_library(
    name = "secded_encoder_testbench_57_cc_library",
    chisel_lib = ":bus",
    emit_class = "bus.EmitSecdedEncoderTestbench57",
    module_name = "SecdedEncoderTestbench57",
)

verilator_cocotb_model(
    name = "secded_encoder_testbench_57_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "SecdedEncoderTestbench57",
    trace = True,
    verilog_source = "//hdl/chisel/src/bus:SecdedEncoderTestbench57.sv",
)
