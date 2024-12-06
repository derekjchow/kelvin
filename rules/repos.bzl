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

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
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
        sha256 = "1b560fe7d4100486784d6f2329e82a63dd37301e185ba77d0fd69b3ecc299649",
        strip_prefix = "bazel_rules_hdl-7a1ba0e8d229200b4628e8a676917fc6b8e165d1",
        urls = [
            "https://github.com/hdl/bazel_rules_hdl/archive/7a1ba0e8d229200b4628e8a676917fc6b8e165d1.tar.gz",
        ],
        patches = [
            "@kelvin_hw//external:0001-Use-systemc-in-verilator-and-support-verilator-in-co.patch",
            "@kelvin_hw//external:0002-Update-cocotb-script-to-support-newer-version.patch",
            "@kelvin_hw//external:0003-Export-vdb-via-undeclared-test-outputs.patch",
            "@kelvin_hw//external:0004-More-jobs-for-cocotb.patch",
            "@kelvin_hw//external:0005-Use-num_failed-for-exit-code.patch"
        ],
        patch_args = ["-p1"],
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
        name = "llvm_firtool",
        urls = ["https://repo1.maven.org/maven2/org/chipsalliance/llvm-firtool/1.114.0/llvm-firtool-1.114.0.jar"],
        build_file = "@kelvin_hw//third_party/llvm-firtool:BUILD.bazel",
        sha256 = "f93a831e6b5696df2e3327626df3cc183e223bf0c9c0fddf9ae9e51f502d0492",
    )

    http_archive(
        name = "lowrisc_opentitan",
        sha256 = "cffed2c3c9c026ecb0b14a48b6cc300aa145bb2a316903dcb4cb7976ca8857af",
        strip_prefix = "opentitan-f243e6802143374741739d2c164c4f2f61697669",
        urls = ["https://github.com/lowrisc/opentitan/archive/f243e6802143374741739d2c164c4f2f61697669.zip"],
        patches = [
            "@kelvin_hw//third_party/ip/lowrisc:0001-Add-BUILD.bazel.patch",
            "@kelvin_hw//third_party/ip/lowrisc:0002-Modify-TLUL-and-SRAM-adapter-for-ChAI.patch",
            "@kelvin_hw//third_party/ip/lowrisc:0003-Modify-UART-for-ChAI.patch",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "com_github_grpc_grpc",
        urls = [
            "https://github.com/grpc/grpc/archive/v1.58.0.tar.gz",
        ],
        strip_prefix = "grpc-1.58.0",
        sha256 = "ec64fdab22726d50fc056474dd29401d914cc616f53ab8f2fe4866772881d581",
    )

    http_archive(
        name = "libsystemctlm_soc",
        urls = [
            "https://github.com/Xilinx/libsystemctlm-soc/archive/79d624f3c7300a2ead97ca35e683c38f0b6f5021.zip",
        ],
        strip_prefix = "libsystemctlm-soc-79d624f3c7300a2ead97ca35e683c38f0b6f5021",
        sha256 = "5c9d08bd33eb6738e3b4a0dda81e24a6d30067e8149bada6ae05aedcab5b786c",
        build_file = "@kelvin_hw//third_party/libsystemctlm-soc:BUILD.bazel",
    )

def renode_repos():
    http_archive(
        name = "renode",
        sha256 = "ca98b8df2ed09e225b72f35c616c85207e451d8a4b00d96594064e5065493cf1",
        strip_prefix = "renode_1.15.2_source",
        urls = ["https://github.com/renode/renode/releases/download/v1.15.2/renode_1.15.2_source.tar.xz"],
        build_file = "@kelvin_hw//third_party/renode:BUILD.bazel",
        patches = [
            "@kelvin_hw//third_party/renode:0001-Tweaks-to-AXI.patch",
            "@kelvin_hw//third_party/renode:0002-AXI-S-fixups.patch",
            "@kelvin_hw//third_party/renode:0003-Invert-AXI-reset-polarity.patch",
        ],
        patch_args = ["-p1"],
    )

def cvfpu_repos():
    http_archive(
        name = "cvfpu",
        sha256 = "fe9278105886ed23ee889c58b2c28f89732e06a0d12f7fa4a8ce60dd680290f6",
        urls = ["https://github.com/openhwgroup/cvfpu/archive/refs/tags/v0.8.1.zip"],
        build_file = "@kelvin_hw//third_party/cvfpu:BUILD.bazel",
        strip_prefix = "cvfpu-0.8.1",
        patches = [
            "@kelvin_hw//third_party/cvfpu:0001-Fix-max_num_lanes-issue-in-DC.patch",
            "@kelvin_hw//third_party/cvfpu:0002-Remove-SVH-includes.patch",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "common_cells",
        sha256 = "4d27dfb483e856556812bac7760308ea1b576adc4bd172d08f7421cea488e5ab",
        urls = ["https://github.com/pulp-platform/common_cells/archive/6aeee85d0a34fedc06c14f04fd6363c9f7b4eeea.zip"],
        strip_prefix = "common_cells-6aeee85d0a34fedc06c14f04fd6363c9f7b4eeea",
        build_file = "@kelvin_hw//third_party/common_cells:BUILD.bazel",
    )

    http_archive(
        name = "fpu_div_sqrt_mvp",
        sha256 = "27bd475637d51215416acf6fdb78e613569f8de0b90040ccc0e3e4679572d8c4",
        urls = ["https://github.com/pulp-platform/fpu_div_sqrt_mvp/archive/86e1f558b3c95e91577c41b2fc452c86b04e85ac.zip"],
        build_file = "@kelvin_hw//third_party/fpu_div_sqrt_mvp:BUILD.bazel",
        strip_prefix = "fpu_div_sqrt_mvp-86e1f558b3c95e91577c41b2fc452c86b04e85ac",
    )
