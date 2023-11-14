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

"""Kelvin HW dependent repositories."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    "scala_maven_import_external",
)
load(
    "@rules_foreign_cc//foreign_cc:repositories.bzl",
    "rules_foreign_cc_dependencies",
)
load(
    "@rules_hdl//dependency_support:dependency_support.bzl",
    rules_hdl_dependency_support = "dependency_support",
)

def kelvin_chisel_deps():
    """Dependent repositories to build chisel"""

    # paranamer
    scala_maven_import_external(
        name = "com_thoughtworks_paranamer",
        artifact = "com.thoughtworks.paranamer:paranamer:%s" % "2.8",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # json4s
    scala_maven_import_external(
        name = "org_json4s_json4s_ast",
        artifact = "org.json4s:json4s-ast_2.13:%s" % "3.6.12",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_scalap",
        artifact = "org.json4s:json4s-scalap_2.13:%s" % "3.6.12",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_core",
        artifact = "org.json4s:json4s-core_2.13:%s" % "3.6.12",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_native",
        artifact = "org.json4s:json4s-native_2.13:%s" % "3.6.12",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # org.apache.commons
    scala_maven_import_external(
        name = "org_apache_commons_commons_lang3",
        artifact = "org.apache.commons:commons-lang3:%s" % "3.11",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_apache_commons_commons_text",
        artifact = "org.apache.commons:commons-text:%s" % "1.9",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # scopt
    scala_maven_import_external(
        name = "com_github_scopt",
        artifact = "com.github.scopt:scopt_2.13:%s" % "3.7.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # moultingyaml
    scala_maven_import_external(
        name = "net_jcazevedo_moultingyaml",
        artifact = "net.jcazevedo:moultingyaml_2.13:%s" % "0.4.2",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # FIRRTL
    scala_maven_import_external(
        name = "edu_berkeley_cs_firrtl",
        artifact = "edu.berkeley.cs:firrtl_2.13:%s" % "1.5.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # Chisel3
    scala_maven_import_external(
        name = "edu_berkeley_cs_chisel3",
        artifact = "edu.berkeley.cs:chisel3_2.13:%s" % "3.5.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "edu_berkeley_cs_chisel3_core",
        artifact = "edu.berkeley.cs:chisel3-core_2.13:%s" % "3.5.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "edu_berkeley_cs_chisel3_macros",
        artifact = "edu.berkeley.cs:chisel3-macros_2.13:%s" % "3.5.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "edu_berkeley_cs_chisel3_plugin",
        artifact = "edu.berkeley.cs:chisel3-plugin_2.13.6:%s" % "3.5.1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

def kelvin_deps():
    """Full kelvin dependent repositories

    Including chisel and systemC test code
    """
    rules_foreign_cc_dependencies()
    rules_hdl_dependency_support()
    kelvin_chisel_deps()

    http_archive(
        name = "accellera_systemc",
        build_file = "@kelvin_hw//external:systemc.BUILD",
        sha256 = "bfb309485a8ad35a08ee78827d1647a451ec5455767b25136e74522a6f41e0ea",
        strip_prefix = "systemc-2.3.4",
        urls = [
            "https://github.com/accellera-official/systemc/archive/refs/tags/2.3.4.tar.gz",
        ],
    )
