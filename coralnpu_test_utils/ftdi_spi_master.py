#!/usr/bin/env python3
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

import argparse
import math
import time
import os
from pyftdi.ftdi import Ftdi, FtdiFeatureError
from elftools.elf.elffile import ELFFile
from coralnpu_test_utils.spi_constants import SpiRegAddress, SpiCommand, TlStatus

class FtdiSpiMaster:
    """A class to manage SPI communication using an FTDI device."""

    def __init__(self, usb_serial, ftdi_port=1):
        """Initializes the FTDI SPI master."""
        # pyftdi uses ftdi://<vendor>:<product>/<serial> or ftdi://<vendor>:<product>:<index>
        url = f'ftdi://::{usb_serial}/{ftdi_port}'
        print(f"Opening FTDI device at: {url}")
        self.ftdi = Ftdi()
        self.ftdi.open_mpsse_from_url(
            url,
            direction=0x0b, # SCK, MOSI, CS# outputs
            initial=0x08,   # CS# high
            frequency=30E6)

        # Enable 3-phase clocking to provide a hold time on data reads.
        # This is critical for the slave device to have time to drive the MISO
        # line before the FTDI chip samples it.
        # Opcode: 0x8C = Enable 3-Phase Clocking
        self.ftdi.write_data(bytes([0x8C]))

    def _get_spi_exchange_cmd(self, write_data=b'', read_len=0, extra_cycles=0):
        """
        Generates the raw MPSSE command buffer for a complete SPI transaction.
        This includes asserting CS, clocking data, and de-asserting CS.
        It returns the command buffer, which can be batched by the caller.
        """
        cmd = bytearray()
        # Set CS low (transaction start).
        # The SET_BITS_LOW command sets the values for the low byte (ADBUS0-7).
        # Value 0x00 sets bit 3 (CS) low. Direction 0x0b keeps SCK, MOSI, CS as outputs.
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])

        # Handle extra clock cycles while CS is low (for CDC).
        if extra_cycles > 0:
            num_full_bytes = extra_cycles // 8
            remaining_bits = extra_cycles % 8
            if num_full_bytes > 0:
                cmd.append(Ftdi.WRITE_BYTES_NVE_MSB)
                length = num_full_bytes - 1
                cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
                cmd.extend(b'\x00' * num_full_bytes)
            if remaining_bits > 0:
                cmd.extend([Ftdi.WRITE_BITS_NVE_MSB, remaining_bits - 1, 0x00])

        # Main data exchange command. All operations are duplex (RW_BYTES) to match
        # the behavior of the original pyftdi.spi library, which was found to be
        # necessary for this specific slave device.
        if write_data or read_len:
            # If only writing, we still perform a duplex exchange but will ignore the read data.
            # If only reading, we write dummy bytes to clock the data in.
            exchange_len = max(len(write_data), read_len)
            if len(write_data) < exchange_len:
                write_data += b'\x00' * (exchange_len - len(write_data))

            cmd.append(Ftdi.RW_BYTES_PVE_NVE_MSB)
            length = exchange_len - 1
            cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
            cmd.extend(write_data[:exchange_len])

        # Set CS high (transaction end). Value 0x08 sets bit 3 (CS) high.
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])
        return cmd

    def _spi_exchange(self, write_data=b'', read_len=0, extra_cycles=0):
        """Executes a complete SPI transaction."""
        cmd = self._get_spi_exchange_cmd(write_data, read_len, extra_cycles)

        if read_len > 0:
            cmd.append(Ftdi.SEND_IMMEDIATE)

        self.ftdi.write_data(cmd)

        if read_len > 0:
            read_buf = self.ftdi.read_data_bytes(read_len, attempt=4)
            if len(read_buf) != read_len:
                print(f"Warning: SPI exchange expected {read_len} bytes, "
                      f"received {len(read_buf)}")
            return read_buf
        return None

    def device_reset(self):
        """Drives ADBUS7 low to reset the device, then returns it high."""
        print("Resetting device...")
        # ADBUS7 is reset, active-low.
        # Original direction: 0x0b (SCK, MOSI, CS# outputs)
        # New direction with reset: 0x8b (ADBUS7, SCK, MOSI, CS# outputs)

        # 1. Assert reset (drive ADBUS7 low)
        #    Value: 0x08 (CS# high, SCK/MOSI low, ADBUS7 low)
        self.ftdi.write_data(bytes([Ftdi.SET_BITS_LOW, 0x08, 0x8b]))
        time.sleep(0.01) # 10ms reset pulse

        # 2. De-assert reset (drive ADBUS7 high)
        #    Value: 0x88 (CS# high, SCK/MOSI low, ADBUS7 high)
        self.ftdi.write_data(bytes([Ftdi.SET_BITS_LOW, 0x88, 0x8b]))
        time.sleep(0.01)

        # 3. Restore original direction mask, keeping pins in idle state.
        self.ftdi.write_data(bytes([Ftdi.SET_BITS_LOW, 0x08, 0x0b]))
        print("Reset complete.")

    def read_line(self, address):
        """Reads a single 128-bit line from memory via SPI."""
        # 1. Configure the read
        self.write_reg(SpiRegAddress.TL_ADDR_REG_0, (address >> 0) & 0xFF)
        self.write_reg(SpiRegAddress.TL_ADDR_REG_1, (address >> 8) & 0xFF)
        self.write_reg(SpiRegAddress.TL_ADDR_REG_2, (address >> 16) & 0xFF)
        self.write_reg(SpiRegAddress.TL_ADDR_REG_3, (address >> 24) & 0xFF)
        self.write_reg_16b(SpiRegAddress.TL_LEN_REG_L, 0)  # 1 beat

        # 2. Issue the read command
        self.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START, wait_cycles=0)

        # 3. Poll for completion of the main TL transaction
        if not self.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE):
            raise RuntimeError(f"Timed out waiting for TL read at 0x{address:x}")

        # 4. Poll the bulk read status register for the expected number of bytes.
        #    This must be done BEFORE clearing the command FSM.
        bytes_available = 0
        max_polls = 100
        timeout = 1.0
        start_time = time.time()
        for i in range(max_polls):
            bytes_available = self.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
            if bytes_available == 16:
                break
            if time.time() - start_time > timeout:
                break
            time.sleep(0.01)

        if bytes_available != 16:
            raise RuntimeError(f"Expected 16 bytes, but status reported {bytes_available} after polling.")

        # 5. Perform the bulk read to retrieve the data.
        read_data_bytes = self.bulk_read(bytes_available)
        read_data = int.from_bytes(bytes(read_data_bytes), 'little')

        # 6. NOW, clear the command register to return the FSM to idle.
        self.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)

        return read_data

    def write_lines(self, start_addr, num_beats, data_as_bytes):
        """
        Writes a contiguous block of data and blocks until the hardware
        confirms the write has completed.
        """
        write_d = self.packed_write_transaction(start_addr, num_beats, data_as_bytes)

        # Poll for completion of the main TL write transaction
        if not self.poll_reg_for_value(SpiRegAddress.TL_WRITE_STATUS_REG, TlStatus.DONE, timeout=5.0):
            raise RuntimeError(f"Timed out waiting for TL write at 0x{start_addr:x}")

        # Acknowledge the FSM to allow the next transaction.
        ack_start_time = time.time()
        self.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
        ack_duration = time.time() - ack_start_time

        return write_d, ack_duration

    def write_line(self, address, data):
        """Writes a single 128-bit line (given as an int) to an address."""
        data_as_bytes = data.to_bytes(16, 'little')
        return self.write_lines(address, 1, data_as_bytes)

    def write_word(self, address, data):
        line_addr = (address // 16) * 16
        offset = address % 16
        line_data = self.read_line(line_addr)
        mask = 0xFFFFFFFF << (offset * 8)
        updated_data = (line_data & ~mask) | (data << (offset * 8))
        self.write_line(line_addr, updated_data)

    def load_file(self, file_path, address):
        """
        Loads an arbitrary binary file into memory at a specific address.
        Handles unaligned start and end addresses correctly.
        """
        if not os.path.exists(file_path):
            raise ValueError(f"File not found: {file_path}")

        with open(file_path, 'rb') as f:
            file_data = f.read()

        file_size = len(file_data)
        print(f"Loading {file_size} bytes from '{os.path.basename(file_path)}' "
              f"to 0x{address:x}...")
        self.load_data(file_data, address)

    def load_data(self, data, address):
        size = len(data)
        start_address = address
        end_address = start_address + size

        total_write_duration = 0.0
        total_ack_duration = 0.0
        total_prep_duration = 0.0

        data_ptr = 0

        # 1. Handle the first line if it's unaligned
        start_offset = start_address % 16
        if start_offset != 0:
            line_addr = start_address - start_offset
            bytes_to_write = min(16 - start_offset, size)

            prep_start_time = time.time()
            data_chunk = data[data_ptr : data_ptr + bytes_to_write]
            data_ptr += bytes_to_write

            old_line_int = self.read_line(line_addr)
            old_line_bytes = old_line_int.to_bytes(16, 'little')

            new_line_bytes = bytearray(old_line_bytes)
            new_line_bytes[start_offset : start_offset + bytes_to_write] = data_chunk
            new_line_int = int.from_bytes(new_line_bytes, 'little')
            total_prep_duration += (time.time() - prep_start_time)

            write_d, ack_d = self.write_line(line_addr, new_line_int)
            total_write_duration += write_d
            total_ack_duration += ack_d

        # 2. Handle all the full, aligned lines in the middle
        loop_start_addr = (start_address + 15) & ~0xF
        loop_end_addr = end_address & ~0xF
        if loop_end_addr > loop_start_addr:
            full_lines_data_size = loop_end_addr - loop_start_addr

            # Process in 4096-byte (128-line) chunks
            for i in range(0, full_lines_data_size, 4096):
                prep_start_time = time.time()
                chunk_start_addr = loop_start_addr + i
                chunk_size = min(4096, full_lines_data_size - i)
                num_lines_in_chunk = chunk_size // 16

                data_chunk_bytes = data[data_ptr : data_ptr + chunk_size]
                data_ptr += chunk_size
                total_prep_duration += (time.time() - prep_start_time)

                if data_chunk_bytes:
                    write_d, ack_d = self.write_lines(chunk_start_addr, num_lines_in_chunk, data_chunk_bytes)
                    total_write_duration += write_d
                    total_ack_duration += ack_d

        # 3. Handle the last line if it's unaligned
        end_offset = end_address % 16
        if end_offset != 0:
            # Ensure we don't re-process the first line if the whole file fits within one
            line_addr = end_address - end_offset
            if line_addr != (start_address - start_offset):
                prep_start_time = time.time()
                bytes_to_write = end_offset
                data_chunk = data[data_ptr : data_ptr + bytes_to_write]

                old_line_int = self.read_line(line_addr)
                old_line_bytes = old_line_int.to_bytes(16, 'little')

                new_line_bytes = bytearray(old_line_bytes)
                new_line_bytes[0:bytes_to_write] = data_chunk
                new_line_int = int.from_bytes(new_line_bytes, 'little')
                total_prep_duration += (time.time() - prep_start_time)

                write_d, ack_d = self.write_line(line_addr, new_line_int)
                total_write_duration += write_d
                total_ack_duration += ack_d

        total_duration = total_write_duration + total_ack_duration + total_prep_duration
        if total_duration > 0:
            rate_kbs = (size / 1024) / total_duration
            print(f"Load complete. Transferred {size} bytes "
                  f"in {total_duration:.2f} seconds ({rate_kbs:.2f} KB/s).")
            if total_duration > 0:
                print(f"  - Breakdown: Prep: {total_prep_duration:.2f}s, "
                      f"SPI Write: {total_write_duration:.2f}s, "
                      f"ACK: {total_ack_duration:.2f}s")

    def load_elf(self, elf_file, start_core=True):
        print(f'load_elf elf_file={elf_file}')
        total_bytes_transferred = 0
        total_write_duration = 0.0
        total_ack_duration = 0.0
        total_prep_duration = 0.0

        with open(elf_file, 'rb') as f:
            elf_file = ELFFile(f)
            entry_point = elf_file.header["e_entry"]
            for segment in elf_file.iter_segments(type="PT_LOAD"):
                paddr = segment.header.p_paddr
                data = segment.data()
                total_bytes_transferred += len(data)
                data_ptr = 0

                for i in range(0, len(data), 256):
                    prep_start_time = time.time()
                    chunk_start_addr = paddr + i
                    chunk_size = min(256, len(data) - i)
                    num_lines_in_chunk = (chunk_size + 15) // 16

                    # Pad chunk to be a multiple of 16
                    data_chunk_bytes = bytearray(data[i : i + chunk_size])
                    while len(data_chunk_bytes) % 16 != 0:
                        data_chunk_bytes.append(0)

                    total_prep_duration += (time.time() - prep_start_time)

                    if not data_chunk_bytes:
                        continue

                    write_d, ack_d = self.write_lines(chunk_start_addr, num_lines_in_chunk, data_chunk_bytes)
                    total_write_duration += write_d
                    total_ack_duration += ack_d

        total_duration = total_write_duration + total_ack_duration + total_prep_duration
        if total_duration > 0:
            rate_kbs = (total_bytes_transferred / 1024) / total_duration
            print(f"ELF data loaded. Transferred {total_bytes_transferred} bytes "
                  f"in {total_duration:.2f} seconds ({rate_kbs:.2f} KB/s).")
            if total_duration > 0:
                print(f"  - Breakdown: Prep: {total_prep_duration:.2f}s, "
                      f"SPI Write: {total_write_duration:.2f}s, "
                      f"ACK: {total_ack_duration:.2f}s")

        if start_core:
            self.set_entry_point(entry_point)
            self.start_core()

    def set_entry_point(self, entry_point):
        """Sets the core's entry point address."""
        print(f"Setting entry point to 0x{entry_point:x}")
        self.write_word(0x30004, entry_point)

    def start_core(self):
        """Releases the core from reset to begin execution."""
        print("Starting core...")
        self.write_word(0x30000, 1)
        self.write_word(0x30000, 0)

    def read_word(self, address):
        """Reads a single 32-bit word from a given address."""
        line_addr = (address // 16) * 16
        offset = address % 16
        line_data = self.read_line(line_addr)
        word = (line_data >> (offset * 8)) & 0xFFFFFFFF
        return word

    def read_spi_domain_reg(self, reg_addr):
        """
        Reads a register in the SPI clock domain. This uses simplex write and
        read commands within a single transaction, with both operations in
        SPI Mode 1.
        """
        cmd = bytearray()
        # --- Start of single SPI transaction ---
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low

        # 1. Send the address byte using the standard SPI Mode 1.
        #    Opcode: Clock Data Bytes Out on -ve clock edge MSB first (no read)
        cmd.extend([Ftdi.WRITE_BYTES_NVE_MSB, 0x00, 0x00, reg_addr])

        # 2. Read the result byte using the SPI Mode 1 read command.
        #    Opcode: Clock Data Bytes In on -ve clock edge MSB first (no write)
        cmd.extend([Ftdi.READ_BYTES_NVE_MSB, 0x00, 0x00])

        # --- End of single SPI transaction ---
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High

        # Flush the command buffer to the FTDI chip.
        cmd.append(Ftdi.SEND_IMMEDIATE)
        self.ftdi.write_data(cmd)

        # We expect only ONE byte back from the single read command.
        read_buf = self.ftdi.read_data_bytes(1)
        if not read_buf:
            raise RuntimeError("Failed to read any data from FTDI device.")
        return read_buf[0]

    def read_spi_domain_reg_16b(self, base_addr):
        """Reads a 16-bit value from a register pair in the SPI clock domain."""
        val_l = self.read_spi_domain_reg(base_addr)
        val_h = self.read_spi_domain_reg(base_addr + 1)
        return (val_h << 8) | val_l

    def bulk_read(self, num_bytes):
        """
        Reads a block of data using a sequence of simplex MPSSE commands to
        correctly handle the hardware's MISO pipeline latency. This version
        internally chunks reads to stay within the FTDI device's buffer limits,
        while performing the entire operation in a single CS assertion.
        """
        if num_bytes == 0:
            return []

        # Determine a safe chunk size for FTDI transfers.
        try:
            ftdi_chunk_size = self.fifo_sizes[0] // 2
        except (FtdiFeatureError, AttributeError):
            ftdi_chunk_size = 1024

        # --- Start of single SPI transaction ---
        cmd = bytearray()
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low

        # Step 1: Simplex write the 4-byte command to kick off the total read.
        num_bytes_val = num_bytes - 1
        len_l = num_bytes_val & 0xFF
        len_h = (num_bytes_val >> 8) & 0xFF
        write_payload_cmd = bytes([
            0x80 | SpiRegAddress.BULK_READ_PORT_L, len_l,
            0x80 | SpiRegAddress.BULK_READ_PORT_H, len_h,
        ])
        cmd.extend(self._get_spi_write_bytes_cmd(write_payload_cmd))

        # Step 2: Simplex write a single dummy byte for MISO pipeline latency.
        cmd.extend(self._get_spi_write_bytes_cmd(bytes(1)))

        # Send the setup command.
        self.ftdi.write_data(cmd)

        # Step 3: Read the data in FTDI-safe chunks.
        read_buf = bytearray()
        bytes_remaining = num_bytes
        while bytes_remaining > 0:
            chunk_read_size = min(bytes_remaining, ftdi_chunk_size)

            read_cmd = bytearray()
            read_cmd.append(Ftdi.READ_BYTES_NVE_MSB)
            length = chunk_read_size - 1
            read_cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
            read_cmd.append(Ftdi.SEND_IMMEDIATE)

            self.ftdi.write_data(read_cmd)
            chunk_data = self.ftdi.read_data_bytes(chunk_read_size)

            if len(chunk_data) != chunk_read_size:
                raise RuntimeError(f"Expected {chunk_read_size} bytes from FTDI, "
                                   f"got {len(chunk_data)}")
            read_buf.extend(chunk_data)
            bytes_remaining -= chunk_read_size

        # --- End of single SPI transaction ---
        footer_cmd = bytearray()
        footer_cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High
        self.ftdi.write_data(footer_cmd)

        if len(read_buf) != num_bytes:
            raise RuntimeError(f"Expected a total of {num_bytes} bytes, "
                               f"got {len(read_buf)}")
        return list(read_buf)

    def poll_for_halt(self, timeout=10.0):
        """Polls the halt status address until the core is halted."""
        print("Polling for halt...")
        halt_addr = 0x30008
        start_time = time.time()
        while time.time() - start_time < timeout:
            value = self.read_word(halt_addr)
            if value == 1:
                print("Core halted.")
                return True
            time.sleep(0.01) # 10ms poll interval
        print("Timed out waiting for core to halt.")
        return False

    def read_data(self, address, size):
        """
        Reads a block of data of a given size from a memory address using
        efficient, chunked bulk TileLink transactions.
        """
        if size == 0:
            return bytearray()

        data = bytearray()
        bytes_remaining = size
        current_addr = address

        total_prep_duration = 0.0
        total_setup_duration = 0.0
        total_hw_wait_duration = 0.0
        total_spi_read_duration = 0.0
        total_ack_duration = 0.0

        # 1. Handle the first line if the start address is unaligned
        start_offset = current_addr % 16
        if start_offset != 0:
            prep_start_time = time.time()
            line_addr = current_addr - start_offset
            bytes_to_read = min(16 - start_offset, bytes_remaining)
            line_data = self.read_line(line_addr)
            line_bytes = line_data.to_bytes(16, 'little')
            data.extend(line_bytes[start_offset : start_offset + bytes_to_read])
            bytes_remaining -= bytes_to_read
            current_addr += bytes_to_read
            total_prep_duration += (time.time() - prep_start_time)

        # 2. Read all aligned data in chunks
        while bytes_remaining > 0:
            prep_start_time = time.time()
            # Set the desired TL transaction size. We aim for 2kB, but don't
            # request more than what's left.
            tl_txn_size = min(2048, bytes_remaining)

            # The number of beats must be a multiple of 16 bytes.
            num_beats = (tl_txn_size + 15) // 16
            expected_bytes = num_beats * 16
            total_prep_duration += (time.time() - prep_start_time)

            # Configure and issue a single TileLink read for the chunk
            setup_start_time = time.time()
            # Program Address / Length for TL
            num_beats_val = num_beats - 1
            header = bytearray([
                0x80 | SpiRegAddress.TL_ADDR_REG_0, (current_addr >> 0) & 0xFF,
                0x80 | SpiRegAddress.TL_ADDR_REG_1, (current_addr >> 8) & 0xFF,
                0x80 | SpiRegAddress.TL_ADDR_REG_2, (current_addr >> 16) & 0xFF,
                0x80 | SpiRegAddress.TL_ADDR_REG_3, (current_addr >> 24) & 0xFF,
                0x80 | SpiRegAddress.TL_LEN_REG_L, num_beats_val & 0xFF,
                0x80 | SpiRegAddress.TL_LEN_REG_H, (num_beats_val >> 8) & 0xFF,
            ])
            footer = bytearray([0x80 | SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_READ_START])

            setup_cmd = bytearray()
            setup_cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])
            setup_cmd.extend(self._get_spi_write_bytes_cmd(header))
            setup_cmd.extend(self._get_spi_write_bytes_cmd(footer))
            setup_cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])
            setup_cmd.append(Ftdi.SEND_IMMEDIATE)
            self.ftdi.write_data(setup_cmd)
            self.ftdi.read_data_bytes(1)
            total_setup_duration += (time.time() - setup_start_time)

            # Poll for completion
            hw_wait_start_time = time.time()
            if not self.poll_reg_for_value(SpiRegAddress.TL_STATUS_REG, TlStatus.DONE):
                raise RuntimeError(f"Timed out waiting for bulk TL read at 0x{current_addr:x}")

            # Manually poll the SPI-domain register for the data to be ready
            bytes_available = 0
            max_polls = 100
            timeout = 1.0
            poll_start_time = time.time()
            for _ in range(max_polls):
                bytes_available = self.read_spi_domain_reg_16b(SpiRegAddress.BULK_READ_STATUS_REG_L)
                if bytes_available == expected_bytes:
                    break
                if time.time() - poll_start_time > timeout:
                    break
                time.sleep(0.01)
            total_hw_wait_duration += (time.time() - hw_wait_start_time)

            if bytes_available != expected_bytes:
                raise RuntimeError(f"Timed out waiting for {expected_bytes} bytes at 0x{current_addr:x}, "
                                   f"got {bytes_available}")

            # Perform a single bulk read to get the chunk
            spi_read_start_time = time.time()
            read_data_bytes = self.bulk_read(expected_bytes)
            data.extend(read_data_bytes)
            total_spi_read_duration += (time.time() - spi_read_start_time)

            # Clear the command FSM
            ack_start_time = time.time()
            self.write_reg(SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_NULL)
            total_ack_duration += (time.time() - ack_start_time)

            bytes_remaining -= expected_bytes
            current_addr += expected_bytes

        total_duration = (total_prep_duration + total_setup_duration +
                          total_hw_wait_duration + total_spi_read_duration +
                          total_ack_duration)
        if total_duration > 0:
            rate_kbs = (size / 1024) / total_duration
            print(f"Read complete. Transferred {size} bytes "
                  f"in {total_duration:.2f} seconds ({rate_kbs:.2f} KB/s).")
            if total_duration > 0:
                print(f"  - Breakdown: Prep: {total_prep_duration:.2f}s, "
                      f"Setup: {total_setup_duration:.2f}s, "
                      f"HW Wait: {total_hw_wait_duration:.2f}s, "
                      f"SPI Read: {total_spi_read_duration:.2f}s, "
                      f"ACK: {total_ack_duration:.2f}s")

        # Return only the originally requested number of bytes
        return data[:size]

    def _get_spi_rw_bytes_cmd(self, write_data):
        """
        Generates the core MPSSE command for a duplex SPI data exchange,
        without any CS# toggling.
        """
        cmd = bytearray()
        exchange_len = len(write_data)
        if exchange_len == 0:
            return cmd

        # Command for clocking bytes with positive clock edge data capture (output)
        # and negative clock edge data change (input).
        cmd.append(Ftdi.RW_BYTES_PVE_NVE_MSB)
        # Length is encoded as (len - 1)
        length = exchange_len - 1
        cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
        cmd.extend(write_data)
        return cmd

    def _get_spi_write_bytes_cmd(self, write_data):
        """
        Generates the core MPSSE command for a simplex SPI data write,
        without any CS# toggling.
        """
        cmd = bytearray()
        exchange_len = len(write_data)
        if exchange_len == 0:
            return cmd

        # Command for clocking bytes out on negative clock edge, MSB first (no read)
        cmd.append(Ftdi.WRITE_BYTES_NVE_MSB)
        # Length is encoded as (len - 1)
        length = exchange_len - 1
        cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
        cmd.extend(write_data)
        return cmd

    def packed_write_transaction(self, target_addr, num_beats, data_bytes):
        """
        Performs a packed write transaction in a single SPI transaction using the
        efficient bulk write command. This version chunks the data payload to
        avoid overflowing the FTDI device's USB buffer and uses simplex
        (write-only) commands to avoid filling the read buffer.
        """
        if len(data_bytes) != num_beats * 16:
            raise ValueError("Data length must be num_beats * 16")

        try:
            chunk_size = self.fifo_sizes[0] // 2
        except (FtdiFeatureError, AttributeError):
            chunk_size = 1024

        # 1. Construct the logical payload components
        num_beats_val = num_beats - 1
        header = bytearray([
            0x80 | SpiRegAddress.TL_ADDR_REG_0, (target_addr >> 0) & 0xFF,
            0x80 | SpiRegAddress.TL_ADDR_REG_1, (target_addr >> 8) & 0xFF,
            0x80 | SpiRegAddress.TL_ADDR_REG_2, (target_addr >> 16) & 0xFF,
            0x80 | SpiRegAddress.TL_ADDR_REG_3, (target_addr >> 24) & 0xFF,
            0x80 | SpiRegAddress.TL_LEN_REG_L, num_beats_val & 0xFF,
            0x80 | SpiRegAddress.TL_LEN_REG_H, (num_beats_val >> 8) & 0xFF,
        ])

        num_bytes_val = len(data_bytes) - 1
        bulk_write_header = bytearray([
            0x80 | SpiRegAddress.BULK_WRITE_PORT_L, num_bytes_val & 0xFF,
            0x80 | SpiRegAddress.BULK_WRITE_PORT_H, (num_bytes_val >> 8) & 0xFF,
        ])

        footer = bytearray([0x80 | SpiRegAddress.TL_CMD_REG, SpiCommand.CMD_WRITE_START])

        # 2. Build and send the command in chunks
        write_start_time = time.time()

        # Part 1: Send setup commands (CS# Low, header, bulk header)
        setup_cmd = bytearray()
        setup_cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b]) # CS Low
        setup_cmd.extend(self._get_spi_write_bytes_cmd(header))
        setup_cmd.extend(self._get_spi_write_bytes_cmd(bulk_write_header))
        self.ftdi.write_data(setup_cmd)

        # Part 2: Send data payload in chunks
        for i in range(0, len(data_bytes), chunk_size):
            chunk = data_bytes[i:i + chunk_size]
            self.ftdi.write_data(self._get_spi_write_bytes_cmd(chunk))

        # Part 3: Send footer, CS# High, and force execution
        footer_cmd = bytearray()
        footer_cmd.extend(self._get_spi_write_bytes_cmd(footer))
        footer_cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b]) # CS High
        footer_cmd.append(Ftdi.GET_BITS_LOW)
        footer_cmd.append(Ftdi.SEND_IMMEDIATE)
        self.ftdi.write_data(footer_cmd)
        
        write_duration = time.time() - write_start_time

        # Wait for and discard the 1-byte response from GET_BITS_LOW.
        self.ftdi.read_data_bytes(1)
        
        return write_duration

    def _get_write_reg_cmd(self, addr, data):
        """
        Generates the raw MPSSE command buffer for a write_reg operation
        using simplex (write-only) commands for efficiency and robustness.
        """
        write_cmd_byte = (1 << 7) | addr
        cmd = bytearray()

        # Transaction 1: Write the address byte
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low
        cmd.extend([Ftdi.WRITE_BYTES_NVE_MSB, 0x00, 0x00, write_cmd_byte])
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High

        # Transaction 2: Write the data byte
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low
        cmd.extend([Ftdi.WRITE_BYTES_NVE_MSB, 0x00, 0x00, data])
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High

        return cmd

    def write_reg(self, addr, data, wait_cycles=10):
        """
        Writes a byte to a register using simplex commands.
        """
        cmd = self._get_write_reg_cmd(addr, data)
        if wait_cycles > 0:
            cmd.extend(self._get_idle_clocking_cmd(wait_cycles))

        # Simplex writes do not return any data from the device, so we just
        # send the command buffer and don't wait for a response.
        self.ftdi.write_data(cmd)

    def write_reg_16b(self, base_addr, data, wait_cycles=10):
        """Writes a 16-bit value to a register pair via SPI."""
        self.write_reg(base_addr, data & 0xFF, wait_cycles=0)
        self.write_reg(base_addr + 1, (data >> 8) & 0xFF, wait_cycles=0)
        if wait_cycles > 0:
            self.idle_clocking(wait_cycles)


    def _get_read_reg_cmd(self, addr):
        """
        Generates the raw MPSSE command buffer for a complete read_reg operation
        using simplex commands.
        """
        read_cmd = addr # MSB is 0 for read
        cmd = bytearray()

        # Part 1: Write the read command (simplex write)
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low
        cmd.extend([Ftdi.WRITE_BYTES_NVE_MSB, 0x00, 0x00, read_cmd])
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High

        # Part 2: Idle clocking
        cmd.extend(self._get_idle_clocking_cmd(5))

        # Part 3: Read the data byte (simplex read)
        cmd.extend([Ftdi.SET_BITS_LOW, 0x00, 0x0b])  # CS Low
        cmd.extend([Ftdi.READ_BYTES_NVE_MSB, 0x00, 0x00])
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])  # CS High

        # This sequence will ask the FTDI chip to return exactly one byte.
        return (cmd, 1)

    def read_reg(self, addr):
        """Reads a byte from a register using simplex commands."""
        cmd, total_bytes_to_read = self._get_read_reg_cmd(addr)
        cmd.append(Ftdi.SEND_IMMEDIATE)
        self.ftdi.write_data(cmd)
        read_buf = self.ftdi.read_data_bytes(total_bytes_to_read, attempt=4)

        # The single byte returned is the data we want.
        return read_buf[0]

    def poll_reg_for_value(self, addr, expected_value, max_polls=100, timeout=1.0):
        """Polls a register until it reads an expected value."""
        start_time = time.time()
        for i in range(max_polls):
            value = self.read_reg(addr)
            if value == expected_value:
                return True
            if time.time() - start_time > timeout:
                break
        print(f"Timed out after {max_polls} polls waiting for register "
              f"0x{addr:x} to be 0x{expected_value:x}, got 0x{value:x}")
        return False

    def bulk_write(self, addr, data, num_bytes):
        """
        Writes a block of data to a single register by batching commands and
        then synchronizing with the FTDI chip.
        """
        full_cmd = bytearray()
        for i in range(num_bytes):
            byte = (data >> (i * 8)) & 0xFF
            full_cmd.extend(self._get_write_reg_cmd(addr, byte))

        # Add a command that requires a response to force the MPSSE to finish
        # executing the buffer before this function returns. This is a robust
        # way to "wait" and prevent race conditions.
        full_cmd.append(Ftdi.GET_BITS_LOW)
        full_cmd.append(Ftdi.SEND_IMMEDIATE)

        self.ftdi.write_data(full_cmd)
        # Wait for and discard the 1-byte response from GET_BITS_LOW.
        # We expect 1 byte for GET_BITS_LOW, plus 2 junk bytes for each
        # write_reg call in the loop.
        bytes_to_read = 1 + (num_bytes * 2)
        self.ftdi.read_data_bytes(bytes_to_read)

    def _get_idle_clocking_cmd(self, cycles):
        """Generates the raw MPSSE command for idle clocking with bit-level precision."""
        if cycles <= 0:
            return b''

        cmd = bytearray()
        # Ensure CS is high, direction is set for outputs
        cmd.extend([Ftdi.SET_BITS_LOW, 0x08, 0x0b])

        num_full_bytes = cycles // 8
        remaining_bits = cycles % 8

        if num_full_bytes > 0:
            # Command to write bytes
            cmd.append(Ftdi.WRITE_BYTES_PVE_MSB)
            length = num_full_bytes - 1
            cmd.extend([length & 0xFF, (length >> 8) & 0xFF])
            cmd.extend(b'\x00' * num_full_bytes)

        if remaining_bits > 0:
            # Command to write bits. The bit count is 0-7, so we subtract 1.
            # We write the most significant `remaining_bits` of a dummy 0x00 byte.
            cmd.extend([Ftdi.WRITE_BITS_PVE_MSB, remaining_bits - 1, 0x00])

        return cmd

    def idle_clocking(self, cycles):
        """Generates idle clock cycles with CS high."""
        cmd = self._get_idle_clocking_cmd(cycles)
        if cmd:
            self.ftdi.write_data(cmd)


def main():
    """Main function to handle command-line arguments."""
    parser = argparse.ArgumentParser(description="FTDI SPI Master Utility")
    parser.add_argument("--usb-serial", required=True, help="USB serial number of the FTDI device.")
    parser.add_argument("--ftdi-port", type=int, default=1, help="Port number of the FTDI device.")

    subparsers = parser.add_subparsers(dest="command", required=True)

    # Write command
    write_parser = subparsers.add_parser("write", help="Write to a register")
    write_parser.add_argument("addr", type=lambda x: int(x, 0), help="Register address (can be hex)")
    write_parser.add_argument("data", type=lambda x: int(x, 0), help="Data to write (can be hex)")

    # Read command
    read_parser = subparsers.add_parser("read", help="Read from a register")
    read_parser.add_argument("addr", type=lambda x: int(x, 0), help="Register address (can be hex)")

    # Poll command
    poll_parser = subparsers.add_parser("poll", help="Poll a register for a value")
    poll_parser.add_argument("addr", type=lambda x: int(x, 0), help="Register address (can be hex)")
    poll_parser.add_argument("expected_value", type=lambda x: int(x, 0), help="Value to poll for (can be hex)")
    poll_parser.add_argument("--timeout", type=float, default=1.0, help="Polling timeout in seconds")

    # Bulk write command
    bulk_write_parser = subparsers.add_parser("bulk-write", help="Write a block of data")
    bulk_write_parser.add_argument("addr", type=lambda x: int(x, 0), help="Register address (can be hex)")
    bulk_write_parser.add_argument("data", type=lambda x: int(x, 0), help="Data to write (can be hex)")
    bulk_write_parser.add_argument("num_bytes", type=int, help="Number of bytes to write")

    load_elf_parser = subparsers.add_parser("load-elf", help="Load an ELF file")
    load_elf_parser.add_argument("elf_file", type=str)

    read_line_parser = subparsers.add_parser("read-line", help="Read a line via TL")
    read_line_parser.add_argument("addr", type=lambda x: int(x, 0), help="Memory address (can be hex)")

    reset_parser = subparsers.add_parser("reset", help="Reset the target device")

    load_file_parser = subparsers.add_parser("load-file", help="Load a binary file to a specific address")
    load_file_parser.add_argument("file_path", type=str, help="Path to the binary file")
    load_file_parser.add_argument("address", type=lambda x: int(x, 0), help="Memory address to load to (can be hex)")

    args = parser.parse_args()

    try:
        spi_master = FtdiSpiMaster(args.usb_serial, args.ftdi_port)
        spi_master.idle_clocking(20)
        # time.sleep(1)

        if args.command == "write":
            spi_master.write_reg(args.addr, args.data)
            print(f"Wrote 0x{args.data:02x} to register 0x{args.addr:02x}")
        elif args.command == "read":
            value = spi_master.read_reg(args.addr)
            print(f"Read 0x{value:02x} from register 0x{args.addr:02x}")
        elif args.command == "poll":
            if spi_master.poll_reg_for_value(args.addr, args.expected_value, timeout=args.timeout):
                print("Poll successful.")
            else:
                print("Poll timed out.")
        elif args.command == "bulk-write":
            spi_master.bulk_write(args.addr, args.data, args.num_bytes)
            print("Bulk write complete.")
        elif args.command == "load-elf":
            spi_master.load_elf(args.elf_file)
        elif args.command == "read-line":
            line_data = spi_master.read_line(args.addr)
            print(f"Line data: 0x{line_data:x}")
        elif args.command == "reset":
            spi_master.device_reset()
        elif args.command == "load-file":
            spi_master.load_file(args.file_path, args.address)

    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
