#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
KELVIN_DIR=${SCRIPT_DIR}/../../../

BAZEL_BIN_DIR=$(cd ${KELVIN_DIR}; bazel info bazel-bin)
(cd ${KELVIN_DIR}; bazel build //tests/renode:Vtop_bin)
(cd ${KELVIN_DIR}; bazel build //tests/renode:Vtop_master)
(cd ${KELVIN_DIR}; bazel build //tests/renode:Vtop_slave)
(cd ${KELVIN_DIR}; bazel build //tests/renode/rv_core:rv_core.elf)

${KELVIN_DIR}/bazel-bin/tests/renode/Vtop_bin &
VTOP_PID=$!
trap "kill ${VTOP_PID}" exit

(cd ${KELVIN_DIR}; renode --disable-xwt -e " \
    i @tests/renode/kelvin-verilator.resc; \
    core_mini_axi_slave SimulationFilePathLinux @${BAZEL_BIN_DIR}/tests/renode/Vtop_slave; \
    core_mini_axi_master SimulationFilePathLinux @${BAZEL_BIN_DIR}/tests/renode/Vtop_master; \
    sysbus LoadELF @${BAZEL_BIN_DIR}/tests/renode/rv_core/rv_core.elf false true rv_core; \
    start; \
    rv_core IsHalted false; \
")
