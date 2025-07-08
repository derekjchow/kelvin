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
        "rvv_add": {
            "srcs": ["rvv_add.S"],
        },
        "rvv_load": {
            "srcs": ["rvv_load.S"],
        },
        "vstart_store": {
            "srcs": ["vstart_store.S"],
        },
    },
)
