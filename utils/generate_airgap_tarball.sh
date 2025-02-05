#!/bin/bash
# Copyright 2024 Google LLC
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

# Generates a tar file containing required artifacts to build and test Kelvin without
# an internet connection.
# To use the artifacts, extract them to a known location, and use the --distdir and --repository_cache
# arguments for Bazel.
# An example command which will build and test is as follows:
# bazel test --distdir=kelvin_airgap_7d188ddd04e3ecd80527a41889e0c6175102af8b/bazel-distdir \
#            --repository_cache=kelvin_airgap_7d188ddd04e3ecd80527a41889e0c6175102af8b/bazel-cachedir \
#            --build_tag_filters="-renode,-verilator" --test_tag_filters="-renode,-verilator" //...
# Additionally, the bazel binary is included in the tarball, in case
# it is not available on your system.

set -euo pipefail

function clean {
    if [[ -d "${WORKDIR}" ]]; then
        rm -rf ${WORKDIR}
    fi
}

REPO_TOP="$(git rev-parse --show-toplevel)"
KELVIN_VERSION="$(git rev-parse HEAD)"
BAZEL_VERSION="$(cat ${REPO_TOP}/.bazelversion)"
WORKDIR=$(mktemp -d)
trap clean EXIT

mkdir ${WORKDIR}/bazel-distdir
cd ${WORKDIR}
curl --silent --location \
    https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 \
    --output bazel
chmod +x bazel
git clone -b "${BAZEL_VERSION}" --depth 1 \
    https://github.com/bazelbuild/bazel bazel-repo
cd bazel-repo
../bazel build @additional_distfiles//:archives.tar
tar xvf bazel-bin/external/additional_distfiles/archives.tar \
    -C "../bazel-distdir" \
    --strip-components=2
cd ..
rm -rf bazel-repo

cd ${REPO_TOP}
mkdir ${WORKDIR}/bazel-cachedir
${WORKDIR}/bazel clean --expunge
${WORKDIR}/bazel fetch \
    --repository_cache=${WORKDIR}/bazel-cachedir \
    //... \
    @cmake-3.23.2-linux-x86_64//:all \
    @gnumake_src//:all \
    @io_bazel_rules_scala_scala_compiler//:all \
    @io_bazel_rules_scala_scala_library//:all \
    @io_bazel_rules_scala_scala_parser_combinators//:all \
    @io_bazel_rules_scala_scala_reflect//:all \
    @io_bazel_rules_scala_scala_xml//:all \
    @io_bazel_rules_scala_scalactic//:all \
    @io_bazel_rules_scala_scalatest//:all \
    @io_bazel_rules_scala_scalatest_compatible//:all \
    @io_bazel_rules_scala_scalatest_core//:all \
    @io_bazel_rules_scala_scalatest_featurespec//:all \
    @io_bazel_rules_scala_scalatest_flatspec//:all \
    @io_bazel_rules_scala_scalatest_freespec//:all \
    @io_bazel_rules_scala_scalatest_funspec//:all \
    @io_bazel_rules_scala_scalatest_funsuite//:all \
    @io_bazel_rules_scala_scalatest_matchers_core//:all \
    @io_bazel_rules_scala_scalatest_mustmatchers//:all \
    @io_bazel_rules_scala_scalatest_shouldmatchers//:all \
    @ninja_1.11.0_linux//:all \
    @remote_java_tools_linux//:all \
    @remotejdk11_linux//:jdk \
    @rules_hdl//:all \
    @com_github_grpc_grpc//:all

cat <<EOF >${WORKDIR}/bazel.sh
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
\${SCRIPT_DIR}/bazel \$* \\
    --distdir=\${SCRIPT_DIR}/bazel-distdir \\
    --repository_cache=\${SCRIPT_DIR}/bazel-cachedir \\
    --test_tag_filters="-renode,-verilator" \\
    --build_tag_filters="-renode,-verilator"
EOF
chmod +x ${WORKDIR}/bazel.sh

tar --transform="s|/|/kelvin_airgap_${KELVIN_VERSION}/|" -cf "${REPO_TOP}/kelvin_airgap_${KELVIN_VERSION}.tar" -C ${WORKDIR}  .
echo "Tarball containing dependencies for building Kelvin offline are available at ${REPO_TOP}/kelvin_airgap_${KELVIN_VERSION}.tar"
