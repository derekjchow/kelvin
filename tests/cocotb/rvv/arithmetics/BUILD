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
load(":rvv_arithmetic.bzl", "rvv_arithmetic_test")
package(default_visibility = ["//visibility:public"])

MATH_OPS = ["add", "sub", "mul"]
DTYPES = [("8", "16"), ("16","8"), ("32","4")]
OP_TYPE_PAIRS = [(op, dtype, vl) for op in MATH_OPS for (dtype, vl) in DTYPES]

template_rule(
    rvv_arithmetic_test,
    {
        "template_{}_i{}_m1".format(op, dtype): {
            "dtype": "int{}".format(dtype),
            "sew": dtype,
            "num_operands": vl,
            "math_op": op,
            "in_data_size": "16",
            "out_data_size": "16",
        }
        for (op, dtype, vl) in OP_TYPE_PAIRS
    }
)

template_rule(
    kelvin_v2_binary,
    {
        "rvv_{}_i{}_m1".format(op, dtype): {
            "srcs": ["template_{}_i{}_m1".format(op, dtype)],
        }
        for (op, dtype, _) in OP_TYPE_PAIRS
    }
)