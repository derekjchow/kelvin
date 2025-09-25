# Copyright 2025 Google LLC
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

import numpy as np

# Maps
DTYPE_TO_SEW = {
    np.uint8: 0b000,
    np.uint16: 0b001,
    np.uint32: 0b010,
}

def construct_vtype(ma, ta, sew, lmul):
    """Constructs the vtype register."""
    return (ma << 7) | (ta << 6) | (sew << 3) | lmul