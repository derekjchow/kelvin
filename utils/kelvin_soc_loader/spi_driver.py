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

import os
import socket
import struct

class SPIDriver:
    """A driver that mimics the cocotb SPIMaster API and communicates with a
    DPI-based server in the simulation over a TCP socket."""

    class CommandType:
        WRITE_REG = 0
        POLL_REG = 1
        IDLE_CLOCKING = 2
        PACKED_WRITE = 3
        BULK_READ = 4
        READ_SPI_DOMAIN_REG = 5
        WRITE_REG_16B = 6
        READ_SPI_DOMAIN_REG_16B = 7

    # Format: < (little-endian), B (u8), I (u32), Q (u64), I (u32)
    COMMAND_FORMAT = "<BIQI"
    # Format: < (little-endian), Q (u64), B (u8)
    RESPONSE_FORMAT = "<QB"

    def __init__(self, port: int = 5555):
        port_str = os.environ.get("SPI_DPI_PORT")
        self.port = int(port_str) if port_str else port
        print(f"SPI_DRIVER: Connecting to localhost:{self.port}...")
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect(("localhost", self.port))
        print("SPI_DRIVER: Connected.")

    def close(self):
        if self.sock:
            print("SPI_DRIVER: Closing socket.")
            self.sock.close()
            self.sock = None

    def _send_command(self, cmd_type, addr=0, data=0, count=0, payload=b''):
        cmd_header = struct.pack(self.COMMAND_FORMAT, cmd_type, addr, data, count)
        self.sock.sendall(cmd_header)

        if payload:
            self.sock.sendall(payload)

        response_data = self.sock.recv(struct.calcsize(self.RESPONSE_FORMAT))
        if not response_data:
            raise ConnectionAbortedError("Socket connection broken.")

        unpacked = struct.unpack(self.RESPONSE_FORMAT, response_data)
        if not unpacked[1]: # success flag
             raise RuntimeError(f"SPI command {cmd_type} failed in simulation.")
        return unpacked[0] # data

    def write_reg(self, reg_addr, data):
        self._send_command(self.CommandType.WRITE_REG, addr=reg_addr, data=data)

    def poll_reg_for_value(self, reg_addr, expected_value, max_polls=20):
        """Sends a single command to the DPI server to perform a polling loop."""
        response = self._send_command(self.CommandType.POLL_REG, addr=reg_addr, data=expected_value, count=max_polls)
        return response == 1

    def idle_clocking(self, cycles):
        """Sends a command to toggle the SPI clock for a number of cycles."""
        self._send_command(self.CommandType.IDLE_CLOCKING, count=cycles)

    def packed_write_transaction(self, target_addr, num_beats, data):
        payload = data.to_bytes(num_beats * 16, 'little')
        self._send_command(self.CommandType.PACKED_WRITE, addr=target_addr, count=num_beats, payload=payload)

    def read_spi_domain_reg(self, reg_addr):
        """Sends a command to read a register in the SPI clock domain."""
        return self._send_command(self.CommandType.READ_SPI_DOMAIN_REG, addr=reg_addr)

    def write_reg_16b(self, reg_addr, data):
        """Sends a command to write a 16-bit value to a register pair."""
        self._send_command(self.CommandType.WRITE_REG_16B, addr=reg_addr, data=data)

    def read_spi_domain_reg_16b(self, reg_addr):
        """Sends a command to read a 16-bit register pair in the SPI clock domain."""
        return self._send_command(self.CommandType.READ_SPI_DOMAIN_REG_16B, addr=reg_addr)

    def bulk_read(self, num_bytes):
        """Sends the new bulk read command and receives the data payload."""
        self._send_command(self.CommandType.BULK_READ, count=num_bytes)
        # After the command is acknowledged, the server sends the raw data payload.
        read_payload = self.sock.recv(num_bytes)
        return list(read_payload)
