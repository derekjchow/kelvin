load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "chisel_lib",

    deps = [
        "@com_thoughtworks_paranamer//jar",
        "@org_json4s_json4s_scalap//jar",
        "@org_json4s_json4s_ast//jar",
        "@org_json4s_json4s_core//jar",
        "@org_json4s_json4s_native//jar",
        "@org_apache_commons_commons_lang3//jar",
        "@org_apache_commons_commons_text//jar",
        "@edu_berkeley_cs_chisel3_plugin//jar",
        "@com_github_scopt//jar",
        "@net_jcazevedo_moultingyaml//jar",
        "@edu_berkeley_cs_firrtl//jar",
        "@edu_berkeley_cs_chisel3_core//jar",
        "@edu_berkeley_cs_chisel3_macros//jar",
        "@edu_berkeley_cs_chisel3//jar",
    ],

    exports = [
        "@com_thoughtworks_paranamer//jar",
        "@org_json4s_json4s_scalap//jar",
        "@org_json4s_json4s_ast//jar",
        "@org_json4s_json4s_core//jar",
        "@org_json4s_json4s_native//jar",
        "@org_apache_commons_commons_lang3//jar",
        "@org_apache_commons_commons_text//jar",
        "@edu_berkeley_cs_chisel3_plugin//jar",
        "@com_github_scopt//jar",
        "@net_jcazevedo_moultingyaml//jar",
        "@edu_berkeley_cs_firrtl//jar",
        "@edu_berkeley_cs_chisel3_core//jar",
        "@edu_berkeley_cs_chisel3_macros//jar",
        "@edu_berkeley_cs_chisel3//jar",
    ],

    visibility = ["//visibility:public"],

    scalacopts = [
        "-Xplugin:$(execpath @edu_berkeley_cs_chisel3_plugin//jar)",
        "-P:chiselplugin:genBundleElements",
    ],
)