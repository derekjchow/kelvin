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
        sha256 = "1b560fe7d4100486784d6f2329e82a63dd37301e185ba77d0fd69b3ecc299649",
        strip_prefix = "bazel_rules_hdl-7a1ba0e8d229200b4628e8a676917fc6b8e165d1",
        urls = [
            "https://github.com/hdl/bazel_rules_hdl/archive/7a1ba0e8d229200b4628e8a676917fc6b8e165d1.tar.gz",
        ],
        patches = [
            "@kelvin_hw//external:0001-Use-systemc-in-verilator-and-support-verilator-in-co.patch",
            "@kelvin_hw//external:0002-Update-cocotb-script-to-support-newer-version.patch",
            "@kelvin_hw//external:0003-Export-vdb-via-undeclared-test-outputs.patch",
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
        sha256 = "d22a894f2f8652b6c26e1d2a66551a7f015ce46e48f2bcdd785b01b9c8739277",
        urls = ["https://repo1.maven.org/maven2/org/chipsalliance/llvm-firtool/1.52.0/llvm-firtool-1.52.0.jar"],
        build_file = "@kelvin_hw//third_party/llvm-firtool:BUILD.bazel",
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
