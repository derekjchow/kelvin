#!/bin/bash --norc
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

#ln -sf driver.sh objcopy example linker cmd

PROG=$(basename "$0")
DRIVER_DIR=$(dirname "$0")
TOOLCHAIN="toolchain_coralnpu_v2"
PREFIX="riscv32-unknown-elf"

ARGS=()
POSTARGS=()
case "${PROG}" in
    gcc)
        ;;
esac

exec "external/${TOOLCHAIN}/bin/${PREFIX}-${PROG}" \
    "${ARGS[@]}" \
    "$@"\
    "${POSTARGS[@]}"
