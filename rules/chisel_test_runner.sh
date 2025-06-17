#!/bin/bash

TEST_NAME=$(basename $0)
PWD=$(realpath .)

cat >${PWD}/external/verilator/verilator <<EOF
#!/bin/bash

export VERILATOR_PYTHON3=`which python3`
export VERILATOR_AR=`which ar`
export VERILATOR_CXX=`which g++`
export VERILATOR_ROOT=${PWD}/external/verilator

${PWD}/external/verilator/verilator_bin \
    "\${@}"
EOF
chmod +x ${PWD}/external/verilator/verilator

export PATH=${PWD}/external/verilator:$PATH
export CHISEL_FIRTOOL_PATH=third_party/llvm-firtool
SCALATEST_BIN=$(find . -name ${TEST_NAME}_scalatest)
${SCALATEST_BIN}