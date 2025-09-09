# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from enum import IntEnum

class SpiRegAddress(IntEnum):
    TL_ADDR_REG_0 = 0x00
    TL_ADDR_REG_1 = 0x01
    TL_ADDR_REG_2 = 0x02
    TL_ADDR_REG_3 = 0x03
    TL_LEN_REG    = 0x04
    TL_CMD_REG    = 0x05
    TL_STATUS_REG = 0x06
    DATA_BUF_PORT = 0x07
    TL_WRITE_STATUS_REG = 0x08
    BULK_WRITE_PORT = 0x09
    BULK_READ_PORT = 0x0A
    BULK_READ_STATUS_REG = 0x0B

class SpiCommand(IntEnum):
    CMD_NULL = 0x00
    CMD_READ_START = 0x01
    CMD_WRITE_START = 0x02

class TlStatus(IntEnum):
    IDLE = 0x00
    BUSY = 0x01
    DONE = 0x02
    ERROR = 0xFF

CMD_WRITE = 0x80
