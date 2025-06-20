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


template_rule(
    rvv_arithmetic_test,
    {
        "template_add_i8_m1": {
            "dtype": "int8",
            "sew": "8",
            "num_operands": "16",
            "math_op": "add",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_add_i16_m1": {
            "dtype": "int16",
            "sew": "16",
            "num_operands": "8",
            "math_op": "add",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_add_i32_m1": {
            "dtype": "int32",
            "sew": "32",
            "num_operands": "4",
            "math_op": "add",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_sub_i8_m1": {
            "dtype": "int8",
            "sew": "8",
            "num_operands": "16",
            "math_op": "sub",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_sub_i16_m1": {
            "dtype": "int16",
            "sew": "16",
            "num_operands": "8",
            "math_op": "sub",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_sub_i32_m1": {
            "dtype": "int32",
            "sew": "32",
            "num_operands": "4",
            "math_op": "sub",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_mul_i8_m1": {
            "dtype": "int8",
            "sew": "8",
            "num_operands": "16",
            "math_op": "mul",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_mul_i16_m1": {
            "dtype": "int16",
            "sew": "16",
            "num_operands": "8",
            "math_op": "mul",
            "in_data_size": "16",
            "out_data_size": "16",
        },
        "template_mul_i32_m1": {
            "dtype": "int32",
            "sew": "32",
            "num_operands": "4",
            "math_op": "mul",
            "in_data_size": "16",
            "out_data_size": "16",
        },
    }
)

template_rule(
    kelvin_v2_binary,
    {
        "rvv_add_i8_m1": {
            "srcs": ["template_add_i8_m1.cc"],
        },
        "rvv_add_i16_m1": {
            "srcs": ["template_add_i16_m1.cc"],
        },
        "rvv_add_i32_m1": {
            "srcs": ["template_add_i32_m1.cc"],
        },
        "rvv_sub_i8_m1": {
            "srcs": ["template_sub_i8_m1.cc"],
        },
        "rvv_sub_i16_m1": {
            "srcs": ["template_sub_i16_m1.cc"],
        },
        "rvv_sub_i32_m1": {
            "srcs": ["template_sub_i32_m1.cc"],
        },
        "rvv_mul_i8_m1": {
            "srcs": ["template_mul_i8_m1.cc"],
        },
        "rvv_mul_i16_m1": {
            "srcs": ["template_mul_i16_m1.cc"],
        },
        "rvv_mul_i32_m1": {
            "srcs": ["template_mul_i32_m1.cc"],
        },
    },
)
