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

load("//rules:kelvin_v2.bzl", "kelvin_v2_binary")
load("//rules:utils.bzl", "template_rule")
load("//tests/cocotb/rvv/arithmetics:rvv_arithmetic.bzl", "rvv_arithmetic_test", "rvv_reduction_test")
package(default_visibility = ["//visibility:public"])

MATH_OPS = ["add", "sub", "mul","div"]
REDUCTION_OPS = ["redsum", "redmin", "redmax"]

# tuple format DTYPE (sew, sign, dtype, vl)
DTYPES = [
    ("8", "i", "int8", "16"),
    ("16", "i", "int16", "8"),
    ("32", "i", "int32", "4"),
    ("8", "u", "uint8", "16"),
    ("16", "u", "uint16", "8"),
    ("32", "u", "uint32", "4"),
]
MATH_OP_TYPE_PAIRS = [(op, sew, sign, dtype, vl) for op in MATH_OPS for (sew, sign, dtype, vl) in DTYPES]
REDUCTION_OP_TYPE_PAIRS = [(op, sew, sign, dtype, vl) for op in REDUCTION_OPS for (sew, sign, dtype, vl) in DTYPES]

# Division has different op code for signed and usigned
template_rule(
    rvv_arithmetic_test,
    {
        "template_{}_{}_m1".format(op, dtype): {
            "dtype": dtype,
            "sew": sew,
            "sign": sign,
            "num_operands": vl,
            "math_op": ['divu' if op == 'div' and dtype[0] == "u" else op][0],
            "in_data_size": "16",
            "out_data_size": "16",
        }
        for (op, sew, sign, dtype, vl) in MATH_OP_TYPE_PAIRS
    }
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
    }
)

template_rule(
    kelvin_v2_binary,
    {
        "rvv_{}_{}_m1".format(op, dtype): {
            "srcs": ["template_{}_{}_m1".format(op, dtype)],
        }
        for (op, _, _, dtype, _) in MATH_OP_TYPE_PAIRS + REDUCTION_OP_TYPE_PAIRS
    }
)

filegroup(
    name = "rvv_arith_tests",
    srcs = [
        ":rvv_{}_{}_m1.elf".format(op, dtype)
        for (op, _, _, dtype, _) in MATH_OP_TYPE_PAIRS + REDUCTION_OP_TYPE_PAIRS
    ],
)
