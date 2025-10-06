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

SEWS = [
    0b000,
    0b001,
    0b010,
]

SEW_TO_LMULS_AND_VLMAXS = {
    0b000: [
        (0b110, 4),
        (0b111, 8),
        (0b000, 16),
        (0b001, 32),
        (0b010, 64),
        (0b011, 128),
    ],
    0b001: [
        (0b111, 4),
        (0b000, 8),
        (0b001, 16),
        (0b010, 32),
        (0b011, 64),
    ],
    0b010: [
        (0b000, 4),
        (0b001, 8),
        (0b010, 16),
        (0b011, 32),
    ],
}

LMUL_TO_EMUL = {
    0b110: 1,
    0b111: 1,
    0b000: 1,
    0b001: 2,
    0b010: 4,
    0b011: 8,
}

def construct_vtype(ma, ta, sew, lmul):
    """Constructs the vtype register."""
    return (ma << 7) | (ta << 6) | (sew << 3) | lmul