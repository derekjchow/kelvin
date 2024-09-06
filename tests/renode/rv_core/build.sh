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

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
OUTPUT_DIR=${1:-${SCRIPT_DIR}}
OUTPUT_DIR=$(dirname ${OUTPUT_DIR})

set -e

# Build Kelvin binary
riscv32-unknown-elf-gcc \
    -march=rv32im \
    -nostdlib \
    -ffreestanding \
    -I. \
    -o ${SCRIPT_DIR}/kelvin.elf \
    -T ${SCRIPT_DIR}/kelvin_tcm.ld \
    ${SCRIPT_DIR}/kelvin_start.S \
    ${SCRIPT_DIR}/kelvin_hello_world.c
riscv32-unknown-elf-objcopy ${SCRIPT_DIR}/kelvin.elf -O binary ${SCRIPT_DIR}/kelvin.bin
xxd -i -n kelvin_hello_world_cc_bin ${SCRIPT_DIR}/kelvin.bin > ${SCRIPT_DIR}/kelvin_hello_world_cc.c

# Build RV core binary
riscv32-unknown-elf-gcc \
    -march=rv32im \
    -nostdlib \
    -ffreestanding \
    -I. \
    -o ${OUTPUT_DIR}/rv_core.elf \
    -T ${SCRIPT_DIR}/link.ld \
    ${SCRIPT_DIR}/main.cc \
    ${SCRIPT_DIR}/start.S \
    ${SCRIPT_DIR}/kelvin_hello_world_cc.c
