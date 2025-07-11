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

package(default_visibility = ["//visibility:public"])

template_rule(
    kelvin_v2_binary,
    {
        "load8_indexed_m1": {
            "srcs": ["load8_indexed_m1.cc"],
        },
        "load8_segment2_unit_m1": {
            "srcs": ["load8_segment2_unit_m1.cc"],
        },
        "load16_segment2_unit_m1": {
            "srcs": ["load16_segment2_unit_m1.cc"],
        },
        "load32_segment2_unit_m1": {
            "srcs": ["load32_segment2_unit_m1.cc"],
        },
        "load8_segment2_unit_m2": {
            "srcs": ["load8_segment2_unit_m2.cc"],
        },
        "load16_segment2_unit_m2": {
            "srcs": ["load16_segment2_unit_m2.cc"],
        },
        "load32_segment2_unit_m2": {
            "srcs": ["load32_segment2_unit_m2.cc"],
        },
        "load8_segment2_stride6_m1": {
            "srcs": ["load8_segment2_stride6_m1.cc"],
        },
        "load16_segment2_stride6_m1": {
            "srcs": ["load16_segment2_stride6_m1.cc"],
        },
        "load8_stride2_m1": {
            "srcs": ["load8_stride2_m1.cc"],
        },
        "load8_stride2_m1_partial": {
            "srcs": ["load8_stride2_m1_partial.cc"],
        },
        "load8_stride2_mf4": {
            "srcs": ["load8_stride2_mf4.cc"],
        },
        "load_store8_unit_m2": {
            "srcs": ["load_store8_unit_m2.cc"],
        },
        "load_store16_unit_m2": {
            "srcs": ["load_store16_unit_m2.cc"],
        },
        "load_store32_unit_m2": {
            "srcs": ["load_store32_unit_m2.cc"],
        },
        "load16_stride4_m1": {
            "srcs": ["load16_stride4_m1.cc"],
        },
        "load16_stride4_m1_partial": {
            "srcs": ["load16_stride4_m1_partial.cc"],
        },
        "load16_stride4_mf2": {
            "srcs": ["load16_stride4_mf2.cc"],
        },
        "load32_stride8_m1": {
            "srcs": ["load32_stride8_m1.cc"],
        },
        "load32_stride8_m1_partial": {
            "srcs": ["load32_stride8_m1_partial.cc"],
        },
        "store8_indexed_m1": {
            "srcs": ["store8_indexed_m1.cc"],
        },
    },
)
