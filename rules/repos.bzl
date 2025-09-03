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

# CoralNPU repositories
#

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def coralnpu_repos():
    http_archive(
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
    )

    http_archive(
        name = "com_google_absl",
        urls = ["https://storage.googleapis.com/grpc-bazel-mirror/github.com/abseil/abseil-cpp/archive/20230802.0.tar.gz", "https://github.com/abseil/abseil-cpp/archive/20230802.0.tar.gz"],
        sha256 = "59d2976af9d6ecf001a81a35749a6e551a335b949d34918cfade07737b9d93c5",
        strip_prefix = "abseil-cpp-20230802.0",
    )

    http_archive(
        name = "rules_java",
        urls = ["https://github.com/bazelbuild/rules_java/archive/981f06c3d2bd10225e85209904090eb7b5fb26bd.zip"],
        sha256 = "7979ece89e82546b0dcd1dff7538c34b5a6ebc9148971106f0e3705444f00665",
        strip_prefix = "rules_java-981f06c3d2bd10225e85209904090eb7b5fb26bd",
    )

    http_archive(
        name = "rules_pkg",
        urls = ["https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz", "https://github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz"],
        sha256 = "8a298e832762eda1830597d64fe7db58178aa84cd5926d76d5b744d6558941c2",
    )

    http_archive(
        name = "rules_proto",
        urls = ["https://github.com/bazelbuild/rules_proto/archive/f7a30f6f80006b591fa7c437fe5a951eb10bcbcf.zip"],
        sha256 = "a4382f78723af788f0bc19fd4c8411f44ffe0a72723670a34692ffad56ada3ac",
        strip_prefix = "rules_proto-f7a30f6f80006b591fa7c437fe5a951eb10bcbcf",
    )

    http_archive(
        name = "rules_python",
        urls = ["https://github.com/bazelbuild/rules_python/archive/912a5051f51581784fd64094f6bdabf93f6d698f.zip"],
        sha256 = "a3e4b4ade7c4a52e757b16a16e94d0b2640333062180cba577d81fac087a501d",
        strip_prefix = "rules_python-912a5051f51581784fd64094f6bdabf93f6d698f",
    )

    http_archive(
        name = "rules_hdl",
        sha256 = "1b560fe7d4100486784d6f2329e82a63dd37301e185ba77d0fd69b3ecc299649",
        strip_prefix = "bazel_rules_hdl-7a1ba0e8d229200b4628e8a676917fc6b8e165d1",
        urls = [
            "https://github.com/hdl/bazel_rules_hdl/archive/7a1ba0e8d229200b4628e8a676917fc6b8e165d1.tar.gz",
        ],
        patches = [
            "@coralnpu_hw//external:0001-Use-systemc-in-verilator-and-support-verilator-in-co.patch",
            "@coralnpu_hw//external:0002-Update-cocotb-script-to-support-newer-version.patch",
            "@coralnpu_hw//external:0003-Export-vdb-via-undeclared-test-outputs.patch",
            "@coralnpu_hw//external:0004-More-jobs-for-cocotb.patch",
            "@coralnpu_hw//external:0005-Use-num_failed-for-exit-code.patch",
            "@coralnpu_hw//external:0006-Separate-build-from-test-for-Verilator.patch",
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
        build_file = "@coralnpu_hw//third_party/llvm-firtool:BUILD.bazel",
        sha256 = "f93a831e6b5696df2e3327626df3cc183e223bf0c9c0fddf9ae9e51f502d0492",
    )

    http_archive(
        name = "libsystemctlm_soc",
        urls = [
            "https://github.com/Xilinx/libsystemctlm-soc/archive/79d624f3c7300a2ead97ca35e683c38f0b6f5021.zip",
        ],
        strip_prefix = "libsystemctlm-soc-79d624f3c7300a2ead97ca35e683c38f0b6f5021",
        sha256 = "5c9d08bd33eb6738e3b4a0dda81e24a6d30067e8149bada6ae05aedcab5b786c",
        build_file = "@coralnpu_hw//third_party/libsystemctlm-soc:BUILD.bazel",
    )

    http_archive(
        name = "chipsalliance_rocket_chip",
        build_file = "@coralnpu_hw//third_party/rocket_chip:BUILD.bazel",
        urls = ["https://github.com/chipsalliance/rocket-chip/archive/f517abbf41abb65cea37421d3559f9739efd00a9.zip"],
        sha256 = "e77bb13328e919ca43ba83a1c110b5314900841125b9ff22813a4b9fe73672a2",
        strip_prefix = "rocket-chip-f517abbf41abb65cea37421d3559f9739efd00a9",
    )

    http_archive(
        name = "chipsalliance_diplomacy",
        urls = ["https://github.com/chipsalliance/diplomacy/archive/6590276fa4dac315ae7c7c01371b954c5687a473.zip"],
        sha256 = "3f536b2eba360eb71a542d2a201eabe3a45cfa86302f14d1d565def0ed43ee20",
        strip_prefix = "diplomacy-6590276fa4dac315ae7c7c01371b954c5687a473",
        build_file_content = """
exports_files(["diplomacy/src/diplomacy/nodes/HeterogeneousBag.scala"])
        """,
    )

def cvfpu_repos():
    http_archive(
        name = "cvfpu",
        sha256 = "fe9278105886ed23ee889c58b2c28f89732e06a0d12f7fa4a8ce60dd680290f6",
        urls = ["https://github.com/openhwgroup/cvfpu/archive/refs/tags/v0.8.1.zip"],
        build_file = "@coralnpu_hw//third_party/cvfpu:BUILD.bazel",
        strip_prefix = "cvfpu-0.8.1",
        patches = [
            "@coralnpu_hw//third_party/cvfpu:0001-Fix-max_num_lanes-issue-in-DC.patch",
            "@coralnpu_hw//third_party/cvfpu:0002-Remove-SVH-includes.patch",
            "@coralnpu_hw//third_party/cvfpu:0003-Fill-in-unreachable-state-in-fpnew_divsqrt_th_32-fsm.patch",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "common_cells",
        sha256 = "4d27dfb483e856556812bac7760308ea1b576adc4bd172d08f7421cea488e5ab",
        urls = ["https://github.com/pulp-platform/common_cells/archive/6aeee85d0a34fedc06c14f04fd6363c9f7b4eeea.zip"],
        strip_prefix = "common_cells-6aeee85d0a34fedc06c14f04fd6363c9f7b4eeea",
        build_file = "@coralnpu_hw//third_party/common_cells:BUILD.bazel",
    )

    http_archive(
        name = "fpu_div_sqrt_mvp",
        sha256 = "27bd475637d51215416acf6fdb78e613569f8de0b90040ccc0e3e4679572d8c4",
        urls = ["https://github.com/pulp-platform/fpu_div_sqrt_mvp/archive/86e1f558b3c95e91577c41b2fc452c86b04e85ac.zip"],
        build_file = "@coralnpu_hw//third_party/fpu_div_sqrt_mvp:BUILD.bazel",
        strip_prefix = "fpu_div_sqrt_mvp-86e1f558b3c95e91577c41b2fc452c86b04e85ac",
    )

def rvvi_repos():
    http_archive(
        name = "RVVI",
        # Reflects tag 20240403.0 (before it's update)
        urls = ["https://github.com/riscv-verification/RVVI/archive/5786f0d39b84f3fd15ef75b792bdea4281941afe.zip"],
        sha256 = "18090eed44752f88e84d7631dc525c130ba6c6a5143d7cc2004dc2ca3641eaa2",
        strip_prefix = "RVVI-5786f0d39b84f3fd15ef75b792bdea4281941afe",
        build_file = "@coralnpu_hw//third_party/RVVI:BUILD.bazel",
        patches = [
            "@coralnpu_hw//third_party/RVVI:0001-Rename-name-queue-to-avoid-conflict.patch",
        ],
        patch_args = ["-p1"],
    )

def fpga_repos():
    http_archive(
        name = "lowrisc_opentitan_gh",
        urls = ["https://github.com/lowRISC/opentitan/archive/1b1945fd76799666156f817e163222725c518c59.zip"],
        sha256 = "b881378cdffee2284a88c2032c9fb13e68c889f1cac38cf715b0cff7b40fcf7e",
        strip_prefix = "opentitan-1b1945fd76799666156f817e163222725c518c59",
        patches = [
            "@coralnpu_hw//fpga:0001-Export-hw-ip_templates.patch",
        ],
        patch_args = ["-p1"],
    )

def tflite_repos():
    http_archive(
        name = "tflite_micro",
        url = "https://github.com/tensorflow/tflite-micro/archive/b75c6ff4e2270047f2b48fa01f833c8101c31f43.zip",
        sha256 = "ac3e675b71c55529a32d19a8cf0912413c1d1b9a551512e2665883a1666fb0ba",
        strip_prefix = "tflite-micro-b75c6ff4e2270047f2b48fa01f833c8101c31f43",
        patches = [
            "@coralnpu_hw//third_party/tflite-micro:Tflite-Micro-CoralNPU-integration.patch",
            "@coralnpu_hw//third_party/tflite-micro:0001-Remove-xtensa-and-hifi-kernels.patch",
        ],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "hedron_compile_commands",
        sha256 = "bacabfe758676fdc19e4bea7c4a3ac99c7e7378d259a9f1054d341c6a6b44ff6",
        strip_prefix = "bazel-compile-commands-extractor-1266d6a25314d165ca78d0061d3399e909b7920e",
        url = "https://github.com/hedronvision/bazel-compile-commands-extractor/archive/1266d6a25314d165ca78d0061d3399e909b7920e.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "9d04041ac92a0985e344235f5d946f71ac543f1b1565f2cdbc9a2aaee8adf55b",
        strip_prefix = "rules_python-0.26.0",
        url = "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.26.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "pybind11_bazel",
        strip_prefix = "pybind11_bazel-faf56fb3df11287f26dbc66fdedf60a2fc2c6631",
        urls = ["https://github.com/pybind/pybind11_bazel/archive/faf56fb3df11287f26dbc66fdedf60a2fc2c6631.zip"],
        sha256 = "a185aa68c93b9f62c80fcb3aadc3c83c763854750dc3f38be1dadcb7be223837",
    )
