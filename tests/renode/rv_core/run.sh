#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
KELVIN_DIR=${SCRIPT_DIR}/../../../

${SCRIPT_DIR}/build.sh

BAZEL_OPT_BIN_DIR=$(cd ${KELVIN_DIR}; bazel info -c opt bazel-bin)
(cd ${KELVIN_DIR}; bazel build -c opt //tests/renode:Vtop)

(cd ${KELVIN_DIR}; renode --disable-xwt -e " \
    \$core_mini_axi_file = @${BAZEL_OPT_BIN_DIR}/tests/renode/libVtop.so; \
    i @tests/renode/kelvin-verilator.resc; \
    sysbus LoadELF @${SCRIPT_DIR}/rv_core.elf false true rv_core;
    start; \
    rv_core IsHalted false \
")
