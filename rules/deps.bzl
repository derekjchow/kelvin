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

"""CoralNPU HW dependent repositories."""

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

def coralnpu_chisel_deps():
    """Dependent repositories to build chisel"""

    # scala-reflect
    scala_maven_import_external(
        name = "org_scala_lang_scala_reflect",
        artifact = "org.scala-lang:scala-reflect:%s" % "2.13.11",
        artifact_sha256 = "6a46ed9b333857e8b5ea668bb254ed8e47dacd1116bf53ade9467aa4ae8f1818",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # paranamer
    scala_maven_import_external(
        name = "com_thoughtworks_paranamer",
        artifact = "com.thoughtworks.paranamer:paranamer:%s" % "2.8",
        artifact_sha256 = "688cb118a6021d819138e855208c956031688be4b47a24bb615becc63acedf07",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # json4s
    scala_maven_import_external(
        name = "org_json4s_json4s_ast",
        artifact = "org.json4s:json4s-ast_2.13:%s" % "4.0.6",
        artifact_sha256 = "c9fa3c4799615ebf299f616e4817efd16dcff341e1ee04e51e741d8add68bb43",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_scalap",
        artifact = "org.json4s:json4s-scalap_2.13:%s" % "4.0.6",
        artifact_sha256 = "4ff2f359e2a6595d7b709ca1de43ed6da8c2cf67fe8b78f334e10f27c21c4361",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_core",
        artifact = "org.json4s:json4s-core_2.13:%s" % "4.0.6",
        artifact_sha256 = "7f7a6b7802a05d75a7612d0f5c54832bd473a7c60118192713f45d80d1d51e71",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_json4s_json4s_native",
        artifact = "org.json4s:json4s-native_2.13:%s" % "4.0.6",
        artifact_sha256 = "f7089df299f43c6f76cfa2876d3a9cf9fd4d983e952f6ecfe11ed4b5f129e0c6",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # org.apache.commons
    scala_maven_import_external(
        name = "org_apache_commons_commons_lang3",
        artifact = "org.apache.commons:commons-lang3:%s" % "3.11",
        artifact_sha256 = "4ee380259c068d1dbe9e84ab52186f2acd65de067ec09beff731fca1697fdb16",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_apache_commons_commons_text",
        artifact = "org.apache.commons:commons-text:%s" % "1.10.0",
        artifact_sha256 = "770cd903fa7b604d1f7ef7ba17f84108667294b2b478be8ed1af3bffb4ae0018",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # scopt
    scala_maven_import_external(
        name = "com_github_scopt",
        artifact = "com.github.scopt:scopt_2.13:%s" % "3.7.1",
        artifact_sha256 = "6592cd15368f6e26d1d73f81ed5bc93cf0dea713b8b2936a8f2f0edd3b392820",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # moultingyaml
    scala_maven_import_external(
        name = "net_jcazevedo_moultingyaml",
        artifact = "net.jcazevedo:moultingyaml_2.13:%s" % "0.4.2",
        artifact_sha256 = "a304da2389f760f1a36513d8b10ba546d50243cf0b94415ea2a76906114d7197",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # data-class
    scala_maven_import_external(
        name = "io_github_alexarchambault_data_class",
        artifact = "io.github.alexarchambault:data-class_2.13:%s" % "0.2.5",
        artifact_sha256 = "debdf4eca3430173c5af8300276e194437b2c6c6608aca3a285fd3d98be54ce7",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # os-lib
    scala_maven_import_external(
        name = "com_lihaoyi_os_lib",
        artifact = "com.lihaoyi:os-lib_2.13:%s" % "0.8.1",
        artifact_sha256 = "5036c31a889a702a107f30124efb5fd8ca462818723db001e96494c4360ff96f",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # geny
    scala_maven_import_external(
        name = "com_lihaoyi_geny",
        artifact = "com.lihaoyi:geny_2.13:%s" % "0.7.1",
        artifact_sha256 = "fc01dab696f7b84ba5ac28bbf2e60d8bcbd9ab96717e50fdbeb4e8acf3452a56",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # upickle
    scala_maven_import_external(
        name = "com_lihaoyi_upickle",
        artifact = "com.lihaoyi:upickle_2.13:%s" % "2.0.0",
        artifact_sha256 = "e372ec234360a794eca87124a52a7bfbea4c13556ba3c5eada5243733b6bb77f",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # Chisel3
    scala_maven_import_external(
        name = "org_chipsalliance_chisel",
        artifact = "org.chipsalliance:chisel_2.13:%s" % "7.0.0-RC1",
        artifact_sha256 = "2d807710cd655b4a9adfeb5211f1b288558e09707d912817d320a16ecae5630b",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_chipsalliance_chisel_plugin",
        artifact = "org.chipsalliance:chisel-plugin_2.13.6:%s" % "7.0.0-RC1",
        artifact_sha256 = "f8ba4dea4cfcd28927bff4249758d690a85e3c59abf05c1b0105b2e7c692606a",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_chipsalliance_firtool_resolver",
        artifact = "org.chipsalliance:firtool-resolver_2.13:%s" % "2.0.0",
        artifact_sha256 = "dab7354296f5b39de45c5b300fba33061ee70b9cae6f8994ad1ce00afa9a6f3d",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    scala_maven_import_external(
        name = "com_outr_moduload",
        artifact = "com.outr:moduload_2.13:%s" % "1.1.7",
        artifact_sha256 = "53bdf91631e018b2cbb3a96151d34576d8c7551288a398444fc4ce6e1fbdbea1",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "com_outr_scribe",
        artifact = "com.outr:scribe_2.13:%s" % "3.15.2",
        artifact_sha256 = "d65a5e43cb562ea93f32663f0512e21bc6f4118467003c1c146016e456784898",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )


    # Chiseltest
    scala_maven_import_external(
        name = "edu_berkeley_cs_firrtl",
        artifact = "edu.berkeley.cs:firrtl_2.13:%s" % "5.0.0",
        artifact_sha256 = "7e42b367bbf050cd41658957d25a1f27a73c92e55d3612a9b41d63d0feba50b3",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )
    scala_maven_import_external(
        name = "org_scalatest_scalatest",
        artifact = "org.scalatest:scalatest_3:%s" % "3.2.16",
        artifact_sha256 = "594c3c68d5fccf9bf57f3eef012652c2d66d58d42e6335517ec71fdbeb427352",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    # Antlr4
    scala_maven_import_external(
        name = "org_antlr_antlr4_runtime",
        artifact = "org.antlr:antlr4-runtime:%s" % "4.13.1",
        artifact_sha256 = "54665d2838cc66458343468efc539e454fc95b46a8a04b13c6ac43fc9be63505",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

    scala_maven_import_external(
        name = "net_java_dev_jna",
        artifact = "net.java.dev.jna:jna:%s" % "5.14.0",
        artifact_sha256 = "34ed1e1f27fa896bca50dbc4e99cf3732967cec387a7a0d5e3486c09673fe8c6",
        server_urls = default_maven_server_urls(),
        licenses = ["notice"],
    )

def coralnpu_deps():
    """Full coralnpu dependent repositories

    Including chisel and systemC test code
    """
    rules_foreign_cc_dependencies()
    rules_hdl_dependency_support()
    coralnpu_chisel_deps()

    http_archive(
        name = "accellera_systemc",
        build_file = "@coralnpu_hw//external:systemc.BUILD",
        sha256 = "bfb309485a8ad35a08ee78827d1647a451ec5455767b25136e74522a6f41e0ea",
        strip_prefix = "systemc-2.3.4",
        urls = [
            "https://github.com/accellera-official/systemc/archive/refs/tags/2.3.4.tar.gz",
        ],
    )
