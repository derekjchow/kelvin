#!/bin/bash

SCRIPT_DIR="$(dirname "$BASH_SOURCE")"
ROOTDIR=${SCRIPT_DIR}/../../

FIRTOOL_EXE=$(find ${ROOTDIR} -name 'firtool' -ipath '*linux-x64*' -print -quit)

${FIRTOOL_EXE} $*

exit $?
