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
        "@lowrisc_opentitan//hw/ip/prim_generic:rtl/prim_generic_buf.sv",
        "@lowrisc_opentitan//hw/ip/prim_generic:rtl/prim_generic_clock_gating.sv",
        "@lowrisc_opentitan//hw/ip/prim_generic:rtl/prim_generic_flop.sv",
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
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_alert_pkg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_mubi_pkg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_secded_pkg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_subreg_pkg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_util_pkg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_alert_sender.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_assert.sv",
        # Verilator
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_assert_dummy_macros.svh",
        # Synth
        # "@lowrisc_opentitan//hw/ip/prim:rtl/prim_assert_standard_macros.svh",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_assert_sec_cm.svh",
        "@lowrisc_opentitan//hw:vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_buf.sv",
        "@lowrisc_opentitan//hw:vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_clock_gating.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_count.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_diff_decode.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_fifo_sync.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_fifo_sync_cnt.sv",
        "@lowrisc_opentitan//hw:vendor/lowrisc_ibex/dv/uvm/core_ibex/common/prim/prim_flop.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_flop_2sync.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_flop_macros.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_intr_hw.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_onehot_check.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_reg_we_check.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_sec_anchor_buf.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_sec_anchor_flop.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_secded_inv_64_57_dec.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_secded_inv_39_32_dec.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_secded_inv_39_32_enc.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_secded_inv_64_57_enc.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_subreg.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_subreg_arb.sv",
        "@lowrisc_opentitan//hw/ip/prim:rtl/prim_subreg_ext.sv",
    ],
    deps = [
        ":prim_generic",
        ":prim_xilinx",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "top",
    srcs = [
        "top_pkg.sv",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "tlul",
    # Do not sort: "tlul_pkg" comes first.
    srcs = [
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_pkg.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_adapter_reg.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_cmd_intg_chk.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_data_integ_dec.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_data_integ_enc.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_err.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_rsp_intg_gen.sv",
    ],
    deps = [
        ":top",
        ":prim",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "tlul_adapter_sram",
    srcs = [
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_adapter_sram.sv",
        "@lowrisc_opentitan//hw/ip/tlul:rtl/tlul_sram_byte.sv",
    ],
    deps = [
        ":prim",
        ":tlul",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "uart",
    srcs = [
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart_reg_pkg.sv",
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart_core.sv",
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart_reg_top.sv",
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart_rx.sv",
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart_tx.sv",
        "@lowrisc_opentitan//hw/ip/uart:rtl/uart.sv",
    ],
    deps = [
        ":prim",
        ":tlul",
    ],
    visibility = ["//visibility:public"],
)
