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

set -e

# Export our own PATH so renode-test finds the fake stty binary.
# Real stty causes hangs due to the process being detached.
export PATH=tests/renode:$PATH

# Force using Python-interpreted protobuf for compatbility.
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

`which renode-test` tests/renode/rv_core/rv_core.robot