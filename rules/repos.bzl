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

# Kelvin repositories
#

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def kelvin_repos():
    http_archive(
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
    )

    http_archive(
        name = "rules_hdl",
        sha256 = "223bce01f8375b29073a1475591c0c7e0d86c0d0b2ed73cbdb85f9e9dfa0dda3",
        strip_prefix = "bazel_rules_hdl-b58d34add60108ae20d273ee480193b25e96d000",
        urls = [
            "https://github.com/hdl/bazel_rules_hdl/archive/b58d34add60108ae20d273ee480193b25e96d000.tar.gz",
        ],
        patches = [
            "@kelvin_hw//external:0001-Update-version-of-Googletest-for-bazel-compatitibili.patch",
            "@kelvin_hw//external:0002-SystemC-support-for-verilator.patch",
            "@kelvin_hw//external:0003-Add-systemc-lib-support.patch",
            "@kelvin_hw//external:0004-Build-verilator-v4.226.patch",
        ],
    )

    # See https://github.com/bazelbuild/rules_scala/releases for up to date version information.
    rules_scala_version = "73719cbf88134d5c505daf6c913fe4baefd46917"
    http_archive(
        name = "io_bazel_rules_scala",
        sha256 = "48124dfd3387c72fd13d3d954b246a5c34eb83646c0c04a727c9a1ba98e876a6",
        strip_prefix = "rules_scala-%s" % rules_scala_version,
        type = "zip",
        url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
    )

    http_archive(
        name = "rules_foreign_cc",
        sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
        strip_prefix = "rules_foreign_cc-0.9.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/refs/tags/0.9.0.tar.gz",
    )

    http_archive(
        name = "com_google_absl",
        sha256 = "3ea49a7d97421b88a8c48a0de16c16048e17725c7ec0f1d3ea2683a2a75adc21",
        strip_prefix = "abseil-cpp-20230125.0",
        urls = ["https://github.com/abseil/abseil-cpp/archive/refs/tags/20230125.0.tar.gz"],
    )

    http_archive(
        name = "glibc-2.37",
        sha256 = "811f19f9200118ff94ede28a6e12307584152cdcbf3d366cd729ea2f855db255",
        strip_prefix = "glibc-2.37",
        urls = ["https://ftp.gnu.org/gnu/glibc/glibc-2.37.tar.gz"],
        build_file = "@kelvin_hw//third_party/glibc-2.37:BUILD.bazel",
    )

    http_archive(
        name = "llvm_firtool",
        sha256 = "d22a894f2f8652b6c26e1d2a66551a7f015ce46e48f2bcdd785b01b9c8739277",
        urls = ["https://repo1.maven.org/maven2/org/chipsalliance/llvm-firtool/1.52.0/llvm-firtool-1.52.0.jar"],
        build_file = "@kelvin_hw//third_party/llvm-firtool:BUILD.bazel",
    )
