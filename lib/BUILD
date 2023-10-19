# Copyright 2023 Google LLC
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

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "chisel_lib",
    scalacopts = [
        "-Xplugin:$(execpath @edu_berkeley_cs_chisel3_plugin//jar)",
        "-P:chiselplugin:genBundleElements",
    ],
    visibility = ["//visibility:public"],
    exports = [
        "@com_github_scopt//jar",
        "@com_thoughtworks_paranamer//jar",
        "@edu_berkeley_cs_chisel3//jar",
        "@edu_berkeley_cs_chisel3_core//jar",
        "@edu_berkeley_cs_chisel3_macros//jar",
        "@edu_berkeley_cs_chisel3_plugin//jar",
        "@edu_berkeley_cs_firrtl//jar",
        "@net_jcazevedo_moultingyaml//jar",
        "@org_apache_commons_commons_lang3//jar",
        "@org_apache_commons_commons_text//jar",
        "@org_json4s_json4s_ast//jar",
        "@org_json4s_json4s_core//jar",
        "@org_json4s_json4s_native//jar",
        "@org_json4s_json4s_scalap//jar",
    ],
    deps = [
        "@com_github_scopt//jar",
        "@com_thoughtworks_paranamer//jar",
        "@edu_berkeley_cs_chisel3//jar",
        "@edu_berkeley_cs_chisel3_core//jar",
        "@edu_berkeley_cs_chisel3_macros//jar",
        "@edu_berkeley_cs_chisel3_plugin//jar",
        "@edu_berkeley_cs_firrtl//jar",
        "@net_jcazevedo_moultingyaml//jar",
        "@org_apache_commons_commons_lang3//jar",
        "@org_apache_commons_commons_text//jar",
        "@org_json4s_json4s_ast//jar",
        "@org_json4s_json4s_core//jar",
        "@org_json4s_json4s_native//jar",
        "@org_json4s_json4s_scalap//jar",
    ],
)
