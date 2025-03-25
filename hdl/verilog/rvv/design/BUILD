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
load("//rules:vcs.bzl", "vcs_testbench_test")

exports_files(
    srcs = [
        "rvv_backend.sv",
        "rvv_backend_alu.sv",
        "rvv_backend_alu_unit.sv",
        "rvv_backend_alu_unit_addsub.sv",
        "rvv_backend_alu_unit_execution_p1.sv",
        "rvv_backend_alu_unit_mask.sv",
        "rvv_backend_alu_unit_mask_viota.sv",
        "rvv_backend_alu_unit_other.sv",
        "rvv_backend_alu_unit_shift.sv",
        "rvv_backend_decode.sv",
        "rvv_backend_decode_ctrl.sv",
        "rvv_backend_decode_unit.sv",
        "rvv_backend_decode_unit_ari.sv",
        "rvv_backend_decode_unit_lsu.sv",
        "rvv_backend_dispatch.sv",
        "rvv_backend_dispatch_bypass.sv",
        "rvv_backend_dispatch_ctrl.sv",
        "rvv_backend_dispatch_operand.sv",
        "rvv_backend_dispatch_opr_byte_type.sv",
        "rvv_backend_dispatch_raw_uop_rob.sv",
        "rvv_backend_dispatch_raw_uop_uop.sv",
        "rvv_backend_dispatch_structure_hazard.sv",
        "rvv_backend_div.sv",
        "rvv_backend_div_unit_divider.sv",
        "rvv_backend_div_unit.sv",
        "rvv_backend_lsu_remap.sv",
        "rvv_backend_mac_unit.sv",
        "rvv_backend_mul_unit.sv",
        "rvv_backend_mul_unit_mul8.sv",
        "rvv_backend_mulmac.sv",
        "rvv_backend_pmtrdt.sv",
        "rvv_backend_pmtrdt_unit.sv",
        "rvv_backend_retire.sv",
        "rvv_backend_rob.sv",
        "rvv_backend_vrf.sv",
        "rvv_backend_vrf_reg.sv",
        "rvv_define.svh",
        "rvv.svh",
        "Aligner.sv",
        "MultiFifo.sv",
        "RvvCore.sv",
        "RvvFrontEnd.sv",
    ],
    visibility = ["//visibility:public"],
)

verilog_library(
    name = "aligner",
    srcs = [
        "Aligner.sv",
    ],
    visibility = ["//visibility:public"],
)

vcs_testbench_test(
    name = "aligner_tb",
    srcs = ["Aligner_tb.sv"],
    module = "Aligner_tb",
    deps = ":aligner",
)

verilog_library(
    name = "multififo",
    srcs = [
        "MultiFifo.sv",
    ],
    visibility = ["//visibility:public"],
)

vcs_testbench_test(
    name = "multififo_tb",
    srcs = ["MultiFifo_tb.sv"],
    module = "MultiFifo_tb",
    deps = ":multififo",
)
