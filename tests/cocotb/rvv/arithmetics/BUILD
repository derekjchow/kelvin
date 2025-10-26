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
load("//rules:utils.bzl", "template_rule")
load("//tests/cocotb/rvv/arithmetics:rvv_arithmetic.bzl", "rvv_arithmetic_test", "rvv_reduction_test", "rvv_widen_arithmetic_test")

package(default_visibility = ["//visibility:public"])

MATH_OPS = [
    "add",
    "sub",
    "mul",
    "div",
]

REDUCTION_OPS = [
    "redsum",
    "redmin",
    "redmax",
]

# tuple format DTYPE (sew, sign, dtype, vl)
DTYPES = [
    ("8", "i", "int8", "16"),
    ("16", "i", "int16", "8"),
    ("32", "i", "int32", "4"),
    ("8", "u", "uint8", "16"),
    ("16", "u", "uint16", "8"),
    ("32", "u", "uint32", "4"),
]

WIDEN_DTYPES = [
    ("i", "int8", "int16", "8", "16", "8", "256"),
    ("i", "int16", "int32", "16", "32", "4", "256"),
]

MATH_OP_TYPE_PAIRS = [
    (op, sew, sign, dtype, vl)
    for op in MATH_OPS
    for (sew, sign, dtype, vl) in DTYPES
]

MATH_WIDEN_OP_TYPE_PAIRS = [
    (op, sign, in_dtype, out_dtype, in_sew, out_sew, vl_step, num_test_values)
    for op in MATH_OPS[:3]
    for (sign, in_dtype, out_dtype, in_sew, out_sew, vl_step, num_test_values) in WIDEN_DTYPES
]

REDUCTION_OP_TYPE_PAIRS = [
    (op, sew, sign, dtype, vl)
    for op in REDUCTION_OPS
    for (sew, sign, dtype, vl) in DTYPES
]

# Division has different op code for signed and usigned
template_rule(
    rvv_arithmetic_test,
    {
        "template_{}_{}_m1".format(op, dtype): {
            "dtype": dtype,
            "sew": sew,
            "sign": sign,
            "num_operands": vl,
            "math_op": ["divu" if op == "div" and dtype[0] == "u" else op][0],
            "in_data_size": "16",
            "out_data_size": "16",
        }
        for (op, sew, sign, dtype, vl) in MATH_OP_TYPE_PAIRS
    },
)

template_rule(
    rvv_reduction_test,
    {
        "template_{}_{}_m1".format(op, dtype): {
            "dtype": dtype,
            "sew": sew,
            "sign": sign,
            "num_operands": vl,
            # redmin and redmax have different operators for signed/unsigned
            "reduction_op": op + "u" if ((op == "redmin" or op == "redmax") and dtype[0] == "u") else op,
            "in_data_size": "16",
            "out_data_size": "16",
        }
        for (op, sew, sign, dtype, vl) in REDUCTION_OP_TYPE_PAIRS
    },
)

template_rule(
    rvv_widen_arithmetic_test,
    {
        "template_widen_{}_{}_{}".format(op, in_dtype, out_dtype): {
            "in_dtype": in_dtype,
            "out_dtype": out_dtype,
            "in_sew": in_sew,
            "out_sew": out_sew,
            "sign": sign,
            "step_operands": vl_step,
            "math_op": op,
            "num_test_values": num_test_values,
        }
        for (op, sign, in_dtype, out_dtype, in_sew, out_sew, vl_step, num_test_values) in MATH_WIDEN_OP_TYPE_PAIRS
    },
)

template_rule(
    coralnpu_v2_binary,
    {
        "rvv_{}_{}_m1".format(op, dtype): {
            "srcs": ["template_{}_{}_m1".format(op, dtype)],
        }
        for (op, _, _, dtype, _) in MATH_OP_TYPE_PAIRS + REDUCTION_OP_TYPE_PAIRS
    },
)

template_rule(
    coralnpu_v2_binary,
    {
        "rvv_widen_{}_{}_{}".format(op, in_dtype, out_dtype): {
            "srcs": ["template_widen_{}_{}_{}".format(op, in_dtype, out_dtype)],
        }
        for (op, _, in_dtype, out_dtype, _, _, _, _) in MATH_WIDEN_OP_TYPE_PAIRS
    },
)

template_rule(
    coralnpu_v2_binary,
    {
        "vnclip_test": {
            "srcs": ["vnclip_test.cc"],
        },
        "vnclipu_test": {
            "srcs": ["vnclipu_test.cc"],
        },
        "vnsra_test": {
            "srcs": ["vnsra_test.cc"],
        },
        "vnsrl_test": {
            "srcs": ["vnsrl_test.cc"],
        },
    },
)

SAME_TYPE_BINARY_VX_CASES = [
    ("vadd_vx_test", "Vadd", []),
    ("vsadd_vx_test", "Vsadd", []),
    ("vsub_vx_test", "Vsub", []),
    ("vssub_vx_test", "Vssub", []),
    ("vrsub_vx_test", "Vrsub", []),
    ("vmul_vx_test", "Vmul", []),
    ("vmulh_vx_test", "Vmulh", []),
    ("vmin_vx_test", "Vmin", []),
    ("vmax_vx_test", "Vmax", []),
    ("vand_vx_test", "Vand", []),
    ("vor_vx_test", "Vor", []),
    ("vxor_vx_test", "Vxor", []),
]

[
    coralnpu_v2_binary(
        name = name,
        srcs = ["rvv_vx_arithmetics.cc"],
        defines = ["VX_FUNCTION={}".format(fn)] + extra_defines,
        deps = [
            "//coralnpu_test_utils:rvv_cpp_util"
        ],
    )
    for name, fn, extra_defines in SAME_TYPE_BINARY_VX_CASES
]

filegroup(
    name = "rvv_same_type_binary_vx_cases",
    srcs = ["{}.elf".format(name) for name, _, _ in SAME_TYPE_BINARY_VX_CASES],
)

MIXED_SIGN_SAME_WIDTH_BINARY_CASES = [
    ("Vsll", []),
    ("Vsra", ["SIGNED_ONLY"]),
    ("Vsrl", ["UNSIGNED_ONLY"]),
    ("Vmulhsu", ["SIGNED_ONLY"]),
]

[
    coralnpu_v2_binary(
        name = "{}_vx_test".format(fn.lower()),
        srcs = ["rvv_vx_arithmetics.cc"],
        defines = [
            "VX_FUNCTION={}".format(fn),
            "FORCE_X_UNSIGNED",
        ] + extra_defines,
        deps = [
            "//coralnpu_test_utils:rvv_cpp_util"
        ],
    )
    for fn, extra_defines in MIXED_SIGN_SAME_WIDTH_BINARY_CASES
]

filegroup(
    name = "rvv_mixed_sign_same_width_type_binary_vx_cases",
    srcs = [
        "{}_vx_test.elf".format(fn.lower())
        for fn, _ in MIXED_SIGN_SAME_WIDTH_BINARY_CASES],
)

filegroup(
    name = "rvv_arith_tests",
    srcs = [
        ":rvv_{}_{}_m1.elf".format(op, dtype)
        for (op, _, _, dtype, _) in MATH_OP_TYPE_PAIRS + REDUCTION_OP_TYPE_PAIRS
    ] + [
        "rvv_widen_{}_{}_{}".format(op, in_dtype, out_dtype)
        for (op, _, in_dtype, out_dtype, _, _, _, _) in MATH_WIDEN_OP_TYPE_PAIRS
    ] + [
        "vnclip_test.elf",
        "vnclipu_test.elf",
        "vnsra_test.elf",
        "vnsrl_test.elf",
        ":rvv_same_type_binary_vx_cases",
        ":rvv_mixed_sign_same_width_type_binary_vx_cases",
    ],
)
