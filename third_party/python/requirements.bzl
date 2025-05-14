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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _clean_name(name):
    return name.replace("-", "_").replace(".", "_").lower()

def requirement(name):
    return "@kelvin_pip_deps_" + _clean_name(name) + "//:pkg"

def _build_file_content(pypi_name, pypi_version, deps = []):
    return """
package(default_visibility = ["//visibility:public"])
py_library(
    name = "pkg",
    srcs = glob(["**/*.py"]),
    data = [] + glob(["**/*"], exclude=["**/* *", "**/*.dist-info/RECORD", "**/*.py", "**/*.pyc"]),
    imports = ["."],
    deps = {deps},
    tags = ["pypi_name={pypi_name}","pypi_version={pypi_version}"],
)
""".format(pypi_name = pypi_name, pypi_version = pypi_version, deps = deps)

def install_deps():
    http_archive(
        name = "kelvin_pip_deps_tqdm",
        urls = [
            "https://files.pythonhosted.org/packages/d0/30/dc54f88dd4a2b5dc8a0279bdd7270e735851848b762aeb1c1184ed1f6b14/tqdm-4.67.1-py3-none-any.whl",
        ],
        sha256 = "26445eca388f82e72884e0d580d5464cd801a3ea01e63e5601bdff9ba6a48de2",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "tqdm", pypi_version = "4.67.1"),
    )

    http_archive(
        name = "kelvin_pip_deps_cocotb",
        urls = [
            "https://storage.googleapis.com/shodan-public-artifacts/cocotb-2.0.0.dev0-cp39-cp39-linux_x86_64.whl",
        ],
        sha256 = "a37aee75565a1bcb5a7398f5331703cc5891e8dd526156b621ea479c6f4ec507",
        type = "zip",
        build_file_content = _build_file_content(
            pypi_name = "cocotb",
            pypi_version = "20.0.0.dev0",
            deps = ["@kelvin_pip_deps_find_libpython//:pkg"],
        ),
    )

    http_archive(
        name = "kelvin_pip_deps_find_libpython",
        urls = [
            "https://files.pythonhosted.org/packages/1d/89/6b4624122d5c61a86e8aebcebd377866338b705ce4f115c45b046dc09b99/find_libpython-0.4.0-py3-none-any.whl",
        ],
        sha256 = "034a4253bd57da3408aefc59aeac1650150f6c1f42e10fdd31615cf1df0842e3",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "find_libpython", pypi_version = "0.4.0"),
    )

    http_archive(
        name = "kelvin_pip_deps_numpy",
        urls = [
            "https://files.pythonhosted.org/packages/87/d3/74e627205462a170f39e7d7ddd2b4166a0d8ab163377592c7f4fa935cc8c/numpy-2.0.0-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl",
        ],
        sha256 = "821eedb7165ead9eebdb569986968b541f9908979c2da8a4967ecac4439bae3d",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "numpy", pypi_version = "2.0.0"),
    )

    http_archive(
        name = "kelvin_pip_deps_pyelftools",
        urls = [
            "https://files.pythonhosted.org/packages/04/7c/867630e6e6293793f838b31034aa1875e1c3bd8c1ec34a0929a2506f350c/pyelftools-0.29-py2.py3-none-any.whl",
        ],
        sha256 = "519f38cf412f073b2d7393aa4682b0190fa901f7c3fa0bff2b82d537690c7fc1",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "pyelftools", pypi_version = "0.29"),
    )
