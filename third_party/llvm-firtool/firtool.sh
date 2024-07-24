#!/bin/bash

SCRIPT_DIR="$(dirname "$BASH_SOURCE")"
RUNFILES_DIR=$SCRIPT_DIR/firtool.runfiles

${RUNFILES_DIR}/llvm_firtool/org.chipsalliance/llvm-firtool/linux-x64/bin/firtool $*
exit $?
