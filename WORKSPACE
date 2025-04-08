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

workspace(name = "kelvin_hw")

load("//rules:repos.bzl", "kelvin_repos", "renode_repos")

kelvin_repos()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()

# Minimal set from grpc_extra_deps
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@build_bazel_rules_apple//apple:repositories.bzl", "apple_rules_dependencies")

apple_rules_dependencies(ignore_version_differences = False)

load("@com_google_googleapis//:repository_rules.bzl", "switched_rules_by_language")

switched_rules_by_language(
    name = "com_google_googleapis_imports",
    cc = True,
    grpc = True,
    python = True,
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

# Scala setup
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config(scala_version = "2.13.11")

load("@io_bazel_rules_scala//scala:scala.bzl", "rules_scala_setup", "rules_scala_toolchain_deps_repositories")

rules_scala_setup()

rules_scala_toolchain_deps_repositories(fetch_sources = True)

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")

scala_register_toolchains()

load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")

scalatest_repositories()

scalatest_toolchain()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()

load("//rules:deps.bzl", "kelvin_deps")

kelvin_deps()

renode_repos()

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python39",
    python_version = "3.9",
)

load("@python39//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "kelvin_pip_deps",
    python_interpreter_target = interpreter,
    requirements_lock = "//external:requirements.txt",
)

load("@kelvin_pip_deps//:requirements.bzl", "install_deps")

install_deps()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "toolchain_kelvin_v2",
    build_file_content = """
licenses(["notice"])
exports_files(glob(["**"]))
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "all_files",
    srcs = glob(["**"]),
)
""",
    sha256 = "1940ed35120ecf76eec74b85d95b06dedb93771d9974d1647eabdf5931002c41",
    urls = [
        "https://storage.googleapis.com/shodan-public-artifacts/toolchain_kelvin_tar_files/toolchain_kelvin_v2-2025-04-01.tar.gz",
    ],
    strip_prefix = "toolchain_kelvin_v2",
)

register_toolchains(
    "//toolchain:cc_kelvin_v2_toolchain",
    "//toolchain:cc_kelvin_v2_semihosting_toolchain",
)
