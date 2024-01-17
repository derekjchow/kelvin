#!/bin/bash

SCRIPT_DIR="$(dirname "$BASH_SOURCE")"
RUNFILES_DIR=$SCRIPT_DIR/firtool.runfiles

# ./bazel-out/k8-opt-exec-2B5CBBC6/bin/third_party/llvm-firtool/firtool.runfiles/kelvin_hw/third_party/llvm-firtool/firtool
# ./bazel-out/k8-opt-exec-2B5CBBC6/bin/third_party/llvm-firtool/firtool.runfiles/llvm_firtool/org.chipsalliance/llvm-firtool/linux-x64/bin/firtool
# ./bazel-out/k8-opt-exec-2B5CBBC6/bin/third_party/llvm-firtool/firtool.runfiles/glibc-2.37/glibc-2.37/lib/ld-linux-x86-64.so.2

LD_SO=${RUNFILES_DIR}/glibc-2.37/glibc-2.37/lib/ld-linux-x86-64.so.2
LIB_PATH=${RUNFILES_DIR}/glibc-2.37/glibc-2.37/lib:/usr/lib/x86_64-linux-gnu:/usr/lib64:/usr/lib

${LD_SO} --library-path ${LIB_PATH} ${RUNFILES_DIR}/llvm_firtool/org.chipsalliance/llvm-firtool/linux-x64/bin/firtool $*
exit $?