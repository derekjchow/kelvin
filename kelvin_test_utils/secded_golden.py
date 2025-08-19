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
"""Golden model for TileLink-UL integrity calculations."""
import struct


def _parity(n):
    """Calculates the parity of an integer."""
    p = 0
    while n > 0:
        p ^= (n & 1)
        n >>= 1
    return p


def secded_inv_39_32_enc(data):
    """Golden model for prim_secded_inv_39_32_enc. Returns 7-bit ECC."""
    data_o = data  # Start with the 32-bit data

    # Calculate parity bits based on the initial 32-bit data
    p0 = _parity(data_o & 0x002606BD25)
    p1 = _parity(data_o & 0x00DEBA8050)
    p2 = _parity(data_o & 0x00413D89AA)
    p3 = _parity(data_o & 0x0031234ED1)
    p4 = _parity(data_o & 0x00C2C1323B)
    p5 = _parity(data_o & 0x002DCC624C)
    p6 = _parity(data_o & 0x0098505586)

    # Assemble the 39-bit word
    data_o |= p0 << 32
    data_o |= p1 << 33
    data_o |= p2 << 34
    data_o |= p3 << 35
    data_o |= p4 << 36
    data_o |= p5 << 37
    data_o |= p6 << 38

    # XOR the full 39-bit word with the inversion constant
    inverted_data = data_o ^ 0x2A00000000

    # Return the top 7 bits (the ECC)
    return inverted_data >> 32


def secded_inv_64_57_enc(data):
    """Golden model for prim_secded_inv_64_57_enc. Returns 7-bit ECC."""
    data_o = data  # Start with the 57-bit data

    # Calculate parity bits based on the initial 57-bit data
    p0 = _parity(data_o & 0x0103FFF800007FFF)
    p1 = _parity(data_o & 0x017C1FF801FF801F)
    p2 = _parity(data_o & 0x01BDE1F87E0781E1)
    p3 = _parity(data_o & 0x01DEEE3B8E388E22)
    p4 = _parity(data_o & 0x01EF76CDB2C93244)
    p5 = _parity(data_o & 0x01F7BB56D5525488)
    p6 = _parity(data_o & 0x01FBDDA769A46910)

    # Assemble the 64-bit word
    data_o |= p0 << 57
    data_o |= p1 << 58
    data_o |= p2 << 59
    data_o |= p3 << 60
    data_o |= p4 << 61
    data_o |= p5 << 62
    data_o |= p6 << 63

    # XOR the full 64-bit word with the inversion constant
    inverted_data = data_o ^ 0x5400000000000000

    # Return the top 7 bits (the ECC)
    return inverted_data >> 57


def get_cmd_intg(a_channel, width=128):
    """Packs A-channel fields and returns the command integrity."""
    # Packing order (MSB to LSB) from TlulIntegrity.scala
    # Cat(instr_type, address, opcode, mask)
    # instr_type: 4 bits
    # address:    32 bits
    # opcode:     3 bits
    # mask:       variable bits
    mask_width = width // 8
    packed = ((int(a_channel["user"]["instr_type"]) << (32 + 3 + mask_width)) |
              (int(a_channel["address"]) <<
               (3 + mask_width)) | (int(a_channel["opcode"]) << mask_width) |
              (int(a_channel["mask"])))

    return secded_inv_64_57_enc(packed)


def get_data_intg(data, width=32):
    """Returns the data integrity."""
    dataint = int(data)
    if width == 32:
        return secded_inv_39_32_enc(dataint)
    elif width == 128:
        # Folded scheme
        d0 = dataint & 0xFFFFFFFF
        d1 = (dataint >> 32) & 0xFFFFFFFF
        d2 = (dataint >> 64) & 0xFFFFFFFF
        d3 = (dataint >> 96) & 0xFFFFFFFF
        ecc0 = secded_inv_39_32_enc(d0)
        ecc1 = secded_inv_39_32_enc(d1)
        ecc2 = secded_inv_39_32_enc(d2)
        ecc3 = secded_inv_39_32_enc(d3)
        return ecc0 ^ ecc1 ^ ecc2 ^ ecc3
    else:
        raise ValueError(f"Unsupported data width: {width}")


import math


def get_rsp_intg(d_channel, width=128):
    """Packs D-channel fields and returns the response integrity."""
    # Packing order (MSB to LSB) from TlulIntegrity.scala
    # Cat(opcode, size, error)
    # opcode: 3 bits
    # size:   variable bits
    # error:  1 bit
    size_width = math.ceil(math.log2(width // 8))
    packed = ((int(d_channel["opcode"]) << (size_width + 1)) |
              (int(d_channel["size"]) << 1) | (int(d_channel["error"])))

    return secded_inv_64_57_enc(packed)
