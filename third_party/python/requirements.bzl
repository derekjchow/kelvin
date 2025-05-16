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
            deps = [
                "@kelvin_pip_deps_find_libpython//:pkg",
                "@kelvin_pip_deps_pytest//:pkg",
            ],
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

    http_archive(
        name = "kelvin_pip_deps_pytest",
        urls = [
            "https://files.pythonhosted.org/packages/30/3d/64ad57c803f1fa1e963a7946b6e0fea4a70df53c1a7fed304586539c2bac/pytest-8.3.5-py3-none-any.whl",
        ],
        sha256 = "c69214aa47deac29fad6c2a4f590b9c4a9fdb16a403176fe154b79c0b4d4d820",
        type = "zip",
        build_file_content = _build_file_content(
            pypi_name = "pytest",
            pypi_version = "8.3.5",
            deps = [
                "@kelvin_pip_deps_pluggy//:pkg",
                "@kelvin_pip_deps_iniconfig//:pkg",
                "@kelvin_pip_deps_packaging//:pkg",
                "@kelvin_pip_deps_exceptiongroup//:pkg",
            ],
        ),
    )

    http_archive(
        name = "kelvin_pip_deps_pluggy",
        urls = [
            "https://files.pythonhosted.org/packages/54/20/4d324d65cc6d9205fabedc306948156824eb9f0ee1633355a8f7ec5c66bf/pluggy-1.6.0-py3-none-any.whl",
        ],
        sha256 = "e920276dd6813095e9377c0bc5566d94c932c33b27a3e3945d8389c374dd4746",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "pluggy", pypi_version = "1.6.0"),
    )

    http_archive(
        name = "kelvin_pip_deps_iniconfig",
        urls = [
            "https://files.pythonhosted.org/packages/2c/e1/e6716421ea10d38022b952c159d5161ca1193197fb744506875fbb87ea7b/iniconfig-2.1.0-py3-none-any.whl",
        ],
        sha256 = "9deba5723312380e77435581c6bf4935c94cbfab9b1ed33ef8d238ea168eb760",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "iniconfig", pypi_version = "2.1.0"),
    )

    http_archive(
        name = "kelvin_pip_deps_packaging",
        urls = [
            "https://files.pythonhosted.org/packages/20/12/38679034af332785aac8774540895e234f4d07f7545804097de4b666afd8/packaging-25.0-py3-none-any.whl",
        ],
        sha256 = "29572ef2b1f17581046b3a2227d5c611fb25ec70ca1ba8554b24b0e69331a484",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "packaging", pypi_version = "25.0"),
    )

    http_archive(
        name = "kelvin_pip_deps_exceptiongroup",
        urls = [
            "https://files.pythonhosted.org/packages/36/f4/c6e662dade71f56cd2f3735141b265c3c79293c109549c1e6933b0651ffc/exceptiongroup-1.3.0-py3-none-any.whl",
        ],
        sha256 = "4d111e6e0c13d0644cad6ddaa7ed0261a0b36971f6d23e7ec9b4b9097da78a10",
        type = "zip",
        build_file_content = _build_file_content(
            pypi_name = "exceptiongroup",
            pypi_version = "1.3.0",
            deps = [
                "@kelvin_pip_deps_typing_extensions//:pkg",
            ],
        ),
    )

    http_archive(
        name = "kelvin_pip_deps_typing_extensions",
        urls = [
            "https://files.pythonhosted.org/packages/8b/54/b1ae86c0973cc6f0210b53d508ca3641fb6d0c56823f288d108bc7ab3cc8/typing_extensions-4.13.2-py3-none-any.whl",
        ],
        sha256 = "a439e7c04b49fec3e5d3e2beaa21755cadbbdc391694e28ccdd36ca4a1408f8c",
        type = "zip",
        build_file_content = _build_file_content(pypi_name = "typing_extensions", pypi_version = "4.13.2"),
    )
