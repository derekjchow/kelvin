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

package(default_visibility = ["//visibility:public"])

genrule(
    name = "kelvin_xbar",
    srcs = ["//hdl/chisel/src/soc:KelvinXbar.sv"],
    outs = ["KelvinXbar.sv"],
    cmd = "cp $< $@",
)

genrule(
    name = "generate_core_file",
    srcs = [
        "xbar_kelvin_soc_chisel.core.tpl",
        ":kelvin_xbar",
    ],
    outs = ["xbar_kelvin_soc_chisel.core"],
    cmd = "sed 's|__VERILOG_FILE__|KelvinXbar.sv|' $(location xbar_kelvin_soc_chisel.core.tpl) > $@",
)

filegroup(
    name = "rtl_files",
    srcs = glob([
        "*.sv",
        "*.core",
    ]) + [
        ":KelvinXbar.sv",
    ],
)
