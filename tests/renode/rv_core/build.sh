#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
riscv32-unknown-elf-gcc \
    -march=rv32im \
    -nostdlib \
    -ffreestanding \
    -I. \
    -o ${SCRIPT_DIR}/rv_core.elf \
    -T ${SCRIPT_DIR}/link.ld \
    ${SCRIPT_DIR}/main.cc \
    ${SCRIPT_DIR}/start.S \
    ${SCRIPT_DIR}/kelvin_hello_world_cc.c
