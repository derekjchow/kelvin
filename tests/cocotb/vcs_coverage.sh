#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BAZEL_OUT=$(bazel info output_path)
WORKDIR=$(mktemp -d)
trap "rm -rf ${WORKDIR}" EXIT

# Enumerate and execute the cocotb tests.
# This will generate output zip files for each test case.
# The zips are then exploded into WORKDIR.
TESTS=$(bazel query 'kind(cocotb_test, //tests/cocotb:*)' | grep vcs_core_mini_axi_sim_cocotb_)
for TEST in ${TESTS}; do
    TEST_NAME=$(echo ${TEST} | awk '{c=split($0, array, ":"); print array[2]}')
    bazel run --config=vcs ${TEST}
    mkdir -p ${WORKDIR}/${TEST_NAME}
    pushd ${WORKDIR}/${TEST_NAME}
    unzip ${BAZEL_OUT}/k8-fastbuild/testlogs/tests/cocotb/${TEST_NAME}/test.outputs/outputs.zip
    mv simv.vdb ${TEST_NAME}.vdb
    popd
done

# Process the VDB files that are in WORKDIR.
URG_CMD="urg -full64 -elfile ${SCRIPT_DIR}/CoreMiniAxi.el"
VDBS=$(find ${WORKDIR} -name '*.vdb' -type d)
for VDB in ${VDBS}; do
    URG_CMD="${URG_CMD} -dir ${VDB}"
done
pushd ${WORKDIR}
${URG_CMD} -grade score rarecounts
popd

# Export the coverage report.
cp -r ${WORKDIR}/urgReport $(pwd)
mkdir -p $(pwd)/vdbs
cp -r ${VDBS} $(pwd)/vdbs
