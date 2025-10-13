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

load("@coralnpu_hw//third_party/python:requirements.bzl", "requirement")
load("@rules_pkg//:pkg.bzl", "pkg_zip")
load("//rules:coco_tb.bzl", "cocotb_test_suite", "verilator_cocotb_model")
load("//rules:coralnpu_v2.bzl", "coralnpu_v2_binary")
load("//rules:utils.bzl", "template_rule")
load(
    "//tests/cocotb:build_defs.bzl",
    "VCS_BUILD_ARGS",
    "VCS_DEFINES",
    "VCS_TEST_ARGS",
    "VERILATOR_BUILD_ARGS",
)

package(default_visibility = ["//visibility:public"])

COCOTB_TEST_BINARY_TARGETS = glob(["**/*.elf"]) + glob(["**/*.o"]) + [
    ":align_test.elf",
    ":float_csr_interlock_test.elf",
    ":finish_txn_before_halt.elf",
    ":stress_test.elf",
    ":wfi_slot_0.elf",
    ":wfi_slot_1.elf",
    ":wfi_slot_2.elf",
    ":wfi_slot_3.elf",
]

verilator_cocotb_model(
    name = "core_mini_axi_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "CoreMiniAxi",
    verilog_source = "//hdl/chisel/src/coralnpu:CoreMiniAxi.sv",
)

verilator_cocotb_model(
    name = "core_mini_debug_axi_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "CoreMiniDebugAxi",
    verilog_source = "//hdl/chisel/src/coralnpu:CoreMiniDebugAxi.sv",
)

verilator_cocotb_model(
    name = "rvv_core_mini_axi_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "RvvCoreMiniAxi",
    verilog_source = "//hdl/chisel/src/coralnpu:RvvCoreMiniAxi.sv",
)

verilator_cocotb_model(
    name = "rvv_core_mini_highmem_axi_model",
    cflags = VERILATOR_BUILD_ARGS,
    hdl_toplevel = "RvvCoreMiniHighmemAxi",
    verilog_source = "//hdl/chisel/src/coralnpu:RvvCoreMiniHighmemAxi.sv",
)

# BEGIN_TESTCASES_FOR_core_mini_axi_sim_cocotb
CORE_MINI_AXI_SIM_TESTCASES = [
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
    "core_mini_axi_coralnpu_isa_test",
    "core_mini_axi_rand_instr_test",
    "core_mini_axi_burst_types_test",
    "core_mini_axi_float_csr_test",
]
# END_TESTCASES_FOR_core_mini_axi_sim_cocotb

# BEGIN_TESTCASES_FOR_rvv_core_mini_axi_sim_cocotb
RVV_CORE_MINI_AXI_SIM_TESTCASES = [
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
    "core_mini_axi_coralnpu_isa_test",
    "core_mini_axi_rand_instr_test",
    "core_mini_axi_burst_types_test",
    "core_mini_axi_float_csr_test",
]
# END_TESTCASES_FOR_rvv_core_mini_axi_sim_cocotb

CORE_MINI_AXI_SIM_COMMON_TEST_KWARGS = {
    "waves": True,
    "seed": "42",
    "test_module": ["core_mini_axi_sim.py"],
    "deps": [
        "//coralnpu_test_utils:core_mini_axi_sim_interface",
        requirement("tqdm"),
        "@bazel_tools//tools/python/runfiles",
    ],
    "data": COCOTB_TEST_BINARY_TARGETS,
    "size": "enormous",
}

template_rule(
    cocotb_test_suite,
    {
        "core_mini_axi_sim_cocotb": {
            "tests_kwargs": dict(
                CORE_MINI_AXI_SIM_COMMON_TEST_KWARGS,
                hdl_toplevel = "CoreMiniAxi",
            ),
            "vcs_verilog_sources": ["//hdl/chisel/src/coralnpu:core_mini_axi_cc_library_verilog"],
            "verilator_model": ":core_mini_axi_model",
            "testcases": CORE_MINI_AXI_SIM_TESTCASES,
            "testcases_vname": "CORE_MINI_AXI_SIM_TESTCASES",
        },
        "rvv_core_mini_axi_sim_cocotb": {
            "tests_kwargs": dict(
                CORE_MINI_AXI_SIM_COMMON_TEST_KWARGS,
                hdl_toplevel = "RvvCoreMiniAxi",
                tags = ["manual"],
            ),
            "vcs_verilog_sources": ["//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_verilog"],
            "verilator_model": ":rvv_core_mini_axi_model",
            "testcases": RVV_CORE_MINI_AXI_SIM_TESTCASES,
            "testcases_vname": "RVV_CORE_MINI_AXI_SIM_TESTCASES",
        },
    },
    simulators = [
        "verilator",
        "vcs",
    ],
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = COCOTB_TEST_BINARY_TARGETS + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
)

# BEGIN_TESTCASES_FOR_core_mini_axi_debug_cocotb
CORE_MINI_AXI_DEBUG_TESTCASES = [
    "core_mini_axi_debug_gdbserver",
    "core_mini_axi_debug_dmactive",
    "core_mini_axi_debug_probe_impl",
    "core_mini_axi_debug_ndmreset",
    "core_mini_axi_debug_halt_resume",
    "core_mini_axi_debug_hartsel",
    "core_mini_axi_debug_abstract_access_registers",
    "core_mini_axi_debug_abstract_access_nonexistent_register",
    "core_mini_axi_debug_single_step",
    "core_mini_axi_debug_breakpoint",
    "core_mini_axi_debug_scalar_registers",
]
# END_TESTCASES_FOR_core_mini_axi_debug_cocotb

# BEGIN_TESTCASES_FOR_rvv_assembly_cocotb_test
RVV_ASSEMBLY_TESTCASES = [
    "core_mini_rvv_load",
    "core_mini_rvv_add",
    "core_mini_vstart_store",
    "core_mini_vcsr_test",
    "core_mini_viota_test",
    "core_mini_vfirst_test",
    "core_mini_vcpop_exception_test",
    "core_mini_vcpop_test",
    "core_mini_vcompress_test",
    "core_mini_vmsbf_test",
    "core_mini_vmsof_test",
    "core_mini_vmsif_test",
    "core_mini_vill_test",
    "core_mini_vl_test",
    "vsetvl_test",
]
# END_TESTCASES_FOR_rvv_assembly_cocotb_test

# BEGIN_TESTCASES_FOR_rvv_load_store_test
RVV_LOAD_STORE_TESTCASES = [
    "load_store_bits",
    "load_store_whole_register_test",
    "load_unit_masked",
    "load_unit_all_vtypes_test",
    "load_strided_all_vtypes_test",
    "load8_index8",
    "load8_index8_seg",
    "load8_index16",
    "load8_index16_seg",
    "load8_index32",
    "load8_index32_seg",
    "load8_seg_unit",
    "load8_stride2_m1",
    "load8_stride2_m1_partial",
    "load8_stride2_mf4",
    "load16_index8",
    "load16_index8_seg",
    "load16_index16_seg",
    "load16_index32_seg",
    "load16_seg_unit",
    "load16_stride4_m1",
    "load16_stride4_m1_partial",
    "load16_stride4_mf2",
    "load32_index8",
    "load32_index8_seg",
    "load32_index16_seg",
    "load32_index32_seg",
    "load32_seg_unit",
    "load32_stride8_m1",
    "load32_stride8_m1_partial",
    "load_store8_unit_m2",
    "load_store16_unit_m2",
    "load_store32_unit_m2",
    "load8_segment2_stride6_m1",
    "load16_segment2_stride6_m1",
    "store_unit_masked",
    "store_unit_all_vtypes_test",
    "store_strided_all_vtypes_test",
    "store8_index8",
    "store8_index8_seg",
    "store8_index16",
    "store8_index32",
    "store16_index8",
    "store16_index16",
    "store16_index32",
    "store32_index8",
    "store32_index16",
    "store32_index32",
    "store8_seg_unit",
    "store16_seg_unit",
    "store32_seg_unit",
    "load_store8_test",
]
# END_TESTCASES_FOR_rvv_load_store_test

# BEGIN_TESTCASES_FOR_rvv_arithmetic_cocotb_test
RVV_ARITHMETIC_TESTCASES = [
    "arithmetic_m1_vanilla_ops",
    "reduction_m1_vanilla_ops",
    "reduction_m1_failure_ops",
    "widen_math_ops_test_impl",
    "vnclip_test",
    "vnclipu_test",
    "vnsra_test",
    "vnsrl_test",
    "binary_op_vx",
]
# END_TESTCASES_FOR_rvv_arithmetic_cocotb_test

cocotb_test_suite(
    name = "core_mini_axi_debug_cocotb",
    simulators = [
        "verilator",
        "vcs",
    ],
    testcases = CORE_MINI_AXI_DEBUG_TESTCASES,
    testcases_vname = "CORE_MINI_AXI_DEBUG_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "CoreMiniDebugAxi",
        "waves": True,
        "seed": "42",
        "test_module": ["core_mini_axi_debug.py"],
        "size": "enormous",
        "deps": [
            "//coralnpu_test_utils:core_mini_axi_sim_interface",
            "//coralnpu_test_utils:core_mini_axi_pyocd_gdbserver",
            "@bazel_tools//tools/python/runfiles",
        ],
        "data": [
            ":fptr.elf",
            ":math.elf",
            ":noop.elf",
            ":registers.elf",
        ],
    },
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = [
        ":fptr.elf",
        ":math.elf",
        ":noop.elf",
        ":registers.elf",
    ] + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_verilog_sources = ["//hdl/chisel/src/coralnpu:core_mini_axi_debug_cc_library_verilog"],
    verilator_model = ":core_mini_debug_axi_model",
)

cocotb_test_suite(
    name = "rvv_assembly_cocotb_test",
    simulators = [
        "verilator",
        "vcs",
    ],
    testcases = RVV_ASSEMBLY_TESTCASES,
    testcases_vname = "RVV_ASSEMBLY_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "RvvCoreMiniAxi",
        "waves": True,
        "seed": "42",
        "test_module": ["rvv_assembly_cocotb_test.py"],
        "deps": [
            "//coralnpu_test_utils:core_mini_axi_sim_interface",
            "//coralnpu_test_utils:rvv_type_util",
            "//coralnpu_test_utils:sim_test_fixture",
            requirement("tqdm"),
            "@bazel_tools//tools/python/runfiles",
        ],
        "data": ["//tests/cocotb/rvv:rvv_assem_tests"],
        "size": "large",
    },
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = ["//tests/cocotb/rvv:rvv_assem_tests"] + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_verilog_sources = ["//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_verilog"],
    verilator_model = ":rvv_core_mini_axi_model",
)

coralnpu_v2_binary(
    name = "align_test",
    srcs = [
        "align_test.cc",
    ],
    semihosting = True,
)

coralnpu_v2_binary(
    name = "wfi_slot_0",
    srcs = [
        "wfi_slot_0.c",
    ],
)

coralnpu_v2_binary(
    name = "wfi_slot_1",
    srcs = [
        "wfi_slot_1.c",
    ],
)

coralnpu_v2_binary(
    name = "wfi_slot_2",
    srcs = [
        "wfi_slot_2.c",
    ],
)

coralnpu_v2_binary(
    name = "wfi_slot_3",
    srcs = [
        "wfi_slot_3.c",
    ],
)

coralnpu_v2_binary(
    name = "finish_txn_before_halt",
    srcs = [
        "finish_txn_before_halt.cc",
    ],
)

coralnpu_v2_binary(
    name = "stress_test",
    srcs = [
        "stress_test.cc",
    ],
)

coralnpu_v2_binary(
    name = "float_csr_interlock_test",
    srcs = [
        "float_csr_interlock_test.S",
    ],
)

coralnpu_v2_binary(
    name = "fptr",
    srcs = [
        "fptr.cc",
    ],
)

coralnpu_v2_binary(
    name = "math",
    srcs = [
        "math.cc",
    ],
)

coralnpu_v2_binary(
    name = "noop",
    srcs = [
        "noop.cc",
    ],
)

coralnpu_v2_binary(
    name = "registers",
    srcs = [
        "registers.S",
    ],
)

coralnpu_v2_binary(
    name = "float_store",
    srcs = ["float_store.cc"],
)

coralnpu_v2_binary(
    name = "vector_store",
    srcs = ["vector_store.cc"],
)

cocotb_test_suite(
    name = "rvv_load_store_test",
    simulators = [
        "verilator",
        "vcs",
    ],
    testcases = RVV_LOAD_STORE_TESTCASES,
    testcases_vname = "RVV_LOAD_STORE_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "RvvCoreMiniAxi",
        "waves": True,
        "seed": "42",
        "test_module": ["rvv_load_store_test.py"],
        "deps": [
            "//coralnpu_test_utils:rvv_type_util",
            "//coralnpu_test_utils:sim_test_fixture",
            "@bazel_tools//tools/python/runfiles",
            requirement("tqdm"),
        ],
        "data": ["//tests/cocotb/rvv/load_store:rvv_load_store_tests"],
        "size": "large",
        "timeout": "eternal",
    },
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = ["//tests/cocotb/rvv/load_store:rvv_load_store_tests"] + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_verilog_sources = ["//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_verilog"],
    verilator_model = ":rvv_core_mini_axi_model",
)

cocotb_test_suite(
    name = "rvv_arithmetic_cocotb_test",
    simulators = [
        "verilator",
        "vcs",
    ],
    testcases = RVV_ARITHMETIC_TESTCASES,
    testcases_vname = "RVV_ARITHMETIC_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "RvvCoreMiniAxi",
        "waves": True,
        "seed": "42",
        "test_module": ["rvv_arithmetic_cocotb_test.py"],
        "deps": [
            "//coralnpu_test_utils:sim_test_fixture",
            "@bazel_tools//tools/python/runfiles",
            requirement("tqdm"),
        ],
        "data": ["//tests/cocotb/rvv/arithmetics:rvv_arith_tests"],
        "size": "large",
    },
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = ["//tests/cocotb/rvv/arithmetics:rvv_arith_tests"] + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_verilog_sources = ["//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_verilog"],
    verilator_model = ":rvv_core_mini_axi_model",
)

pkg_zip(
    name = "rvv_test_binaries",
    srcs = [
        "//tests/cocotb/rvv/arithmetics:rvv_arith_tests",
        "//tests/cocotb/rvv/load_store:rvv_load_store_tests",
    ],
)

# BEGIN_TESTCASES_FOR_rvv_ml_ops_cocotb_test
RVV_ML_OPS_TESTCASES = [
    "core_mini_rvv_matmul_test",
]
# END_TESTCASES_FOR_rvv_ml_ops_cocotb_test

cocotb_test_suite(
    name = "rvv_ml_ops_cocotb_test",
    simulators = [
        "verilator",
        "vcs",
    ],
    testcases = RVV_ML_OPS_TESTCASES,
    testcases_vname = "RVV_ML_OPS_TESTCASES",
    tests_kwargs = {
        "hdl_toplevel": "RvvCoreMiniAxi",
        "waves": True,
        "seed": "42",
        "test_module": ["rvv_ml_ops_cocotb_test.py"],
        "deps": [
            "//coralnpu_test_utils:sim_test_fixture",
            "@bazel_tools//tools/python/runfiles",
        ],
        "data": ["//tests/cocotb/rvv/ml_ops:rvv_mlop_tests"],
        "size": "large",
    },
    vcs_build_args = VCS_BUILD_ARGS,
    vcs_data = ["//tests/cocotb/rvv/ml_ops:rvv_mlop_tests"] + [":coverage_exclude.cfg"],
    vcs_defines = VCS_DEFINES,
    vcs_test_args = VCS_TEST_ARGS,
    vcs_verilog_sources = ["//hdl/chisel/src/coralnpu:rvv_core_mini_axi_cc_library_verilog"],
    verilator_model = ":rvv_core_mini_axi_model",
)
