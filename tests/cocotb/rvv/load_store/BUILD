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
        "load_store_bits": {
            "srcs": ["load_store_bits.cc"],
        },
        "load8_index8": {
            "srcs": ["load8_index8.cc"],
        },
        "load8_index16": {
            "srcs": ["load8_index16.cc"],
        },
        "load8_index32": {
            "srcs": ["load8_index32.cc"],
        },
        "load8_seg_unit": {
            "srcs": ["load8_seg_unit.cc"],
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
        "load_store8_test": {
            "srcs": ["load_store8_test.cc"],
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
        "load16_index8": {
            "srcs": ["load16_index8.cc"],
        },
        "load16_seg_unit": {
            "srcs": ["load16_seg_unit.cc"],
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
        "load32_index8": {
            "srcs": ["load32_index8.cc"],
        },
        "load32_seg_unit": {
            "srcs": ["load32_seg_unit.cc"],
        },
        "load32_stride8_m1": {
            "srcs": ["load32_stride8_m1.cc"],
        },
        "load32_stride8_m1_partial": {
            "srcs": ["load32_stride8_m1_partial.cc"],
        },
        "store8_index8": {
            "srcs": ["store8_index8.cc"],
        },
        "store16_index16": {
            "srcs": ["store16_index16.cc"],
        },
        "store32_index32": {
            "srcs": ["store32_index32.cc"],
        },
        "store8_seg_unit": {
            "srcs": ["store8_seg_unit.cc"],
        },
        "store16_seg_unit": {
            "srcs": ["store16_seg_unit.cc"],
        },
        "store32_seg_unit": {
            "srcs": ["store32_seg_unit.cc"],
        },
    },
)

filegroup(
    name = "rvv_load_store_tests",
    srcs = [
        ":load_store_bits.elf",
        ":load8_index8.elf",
        ":load8_index16.elf",
        ":load8_index32.elf",
        ":load8_seg_unit.elf",
        ":load8_segment2_stride6_m1.elf",
        ":load16_segment2_stride6_m1.elf",
        ":load8_stride2_m1.elf",
        ":load8_stride2_m1_partial.elf",
        ":load8_stride2_mf4.elf",
        ":load_store8_test.elf",
        ":load_store8_unit_m2.elf",
        ":load_store16_unit_m2.elf",
        ":load_store32_unit_m2.elf",
        ":load16_index8.elf",
        ":load16_seg_unit.elf",
        ":load16_stride4_m1.elf",
        ":load16_stride4_m1_partial.elf",
        ":load16_stride4_mf2.elf",
        ":load32_index8.elf",
        ":load32_seg_unit.elf",
        ":load32_stride8_m1.elf",
        ":load32_stride8_m1_partial.elf",
        ":store8_index8.elf",
        ":store16_index16.elf",
        ":store32_index32.elf",
        ":store8_seg_unit",
        ":store16_seg_unit",
        ":store32_seg_unit",
    ],
)