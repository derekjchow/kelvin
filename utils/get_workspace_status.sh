#!/bin/bash
# Copyright 2023 Google LLC
#
# This script will be run by bazel when the build process wants to generate
# information about the status of the workspace.
#
# The output will be key-value pairs in the form:
# KEY1 VALUE1
#
# If this script exits with a non-zero exit code, it's considered as a failure
# and the output will be discarded.

git_rev=$(git rev-parse HEAD)
if [[ $? != 0 ]];
then
  exit 1
fi
echo "KELVIN_BUILD_GIT_VERSION ${git_rev}"
