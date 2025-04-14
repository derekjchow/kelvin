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

load("//rules:coco_tb.bzl", "vcs_cocotb_test", "verilator_cocotb_test")
load("//rules:kelvin_v2.bzl", "kelvin_v2_binary")
load("//rules:utils.bzl", "template_rule")
load("@kelvin_pip_deps//:requirements.bzl", "requirement")

exports_files(["wfi_slot_0.elf"])

template_rule(
    verilator_cocotb_test,
    {
        "core_mini_axi_sim_cocotb": {
            "hdl_toplevel": "CoreMiniAxi",
            "verilog_sources": [
                "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
            ],
            "size": "enormous",
        },
        "rvv_core_mini_axi_sim_cocotb": {
            "hdl_toplevel": "RvvCoreMiniAxi",
            "verilog_sources": [
                "//hdl/chisel/src/kelvin:rvv_core_mini_axi_cc_library_verilog"
            ],
            "size": "enormous",
            "tags": ["manual"], # This suite takes a really long time
        },
    },
    build_args = [
        "-Wno-WIDTH",
        "-Wno-CASEINCOMPLETE",
        "-Wno-LATCH",
        "-Wno-SIDEEFFECT",
        "-Wno-MULTIDRIVEN",
        "-Wno-UNOPTFLAT",
        "-Wno-CASEOVERLAP",
        # Warnings that we disable for fpnew
        "-Wno-ASCRANGE",
        "-Wno-WIDTHEXPAND",
        "-Wno-WIDTHTRUNC",
        "-Wno-UNSIGNED",
    ],
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    seed = "42",
    test_module = ["core_mini_axi_sim.py"],
    deps = [
        "//kelvin_test_utils:core_mini_axi_sim_interface",
        requirement("tqdm"),
    ],
    data = glob(["**/*.elf"]) + glob(["**/*.o"]) + [
        ":align_test.elf",
        ":float_csr_interlock_test",
    ],
)

TESTCASES = [
    "core_mini_axi_basic_write_read_memory",
    "core_mini_axi_run_wfi_in_all_slots",
    "core_mini_axi_slow_bready",
    "core_mini_axi_write_read_memory_stress_test",
    "core_mini_axi_master_write_alignment",
    "core_mini_axi_finish_txn_before_halt_test",
    "core_mini_axi_riscv_tests",
    "core_mini_axi_riscv_dv",
    "core_mini_axi_csr_test",
    "core_mini_axi_exceptions_test",
    "core_mini_axi_kelvin_isa_test",
    "core_mini_axi_rand_instr_test",
    "core_mini_axi_burst_types_test",
]

vcs_cocotb_test(
    name = "vcs_core_mini_axi_sim_cocotb",
    size = "large",
    defines = {
        "USE_GENERIC" : "",
    },
    waves = True,
    hdl_toplevel = "CoreMiniAxi",
    seed = "42",
    test_module = ["core_mini_axi_sim.py"],
    verilog_sources = [
        "//hdl/chisel/src/kelvin:core_mini_axi_cc_library_verilog"
    ],
    testcases = TESTCASES,
    build_args = [
        "+define+SYNTHESIS=1",
        "-timescale=1ns/1ps",
        "-kdb",
        "+vcs+fsdbon",
        "-debug_access+all",
        "-cm",
        "line+cond+tgl+branch+assert",
    ],
    test_args = [
        "+vcs+fsdbon",
        "-cm",
        "line+cond+tgl+branch+assert",
    ],
    deps = [
        "//kelvin_test_utils:core_mini_axi_sim_interface",
        requirement("tqdm"),
    ],
    data = glob(["**/*.elf"]) + glob(["**/*.o"]),
)

kelvin_v2_binary(
    name = "align_test",
    srcs = [
        "align_test.cc",
    ],
    semihosting = True,
)

kelvin_v2_binary(
    name = "float_csr_interlock_test",
    srcs = [
        "float_csr_interlock_test.S",
    ],
)
