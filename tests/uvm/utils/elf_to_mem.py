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

"""
A script to parse an ELF file and generate Verilog hex-formatted memory files
for ITCM and DTCM, and a simulator arguments file.
"""

import argparse
import os
import logging
from elftools.elf.elffile import ELFFile

# Define the memory map for the CoralNPU core
MEM_MAP = {
    'itcm': {'base': 0x00000000, 'size': 8 * 1024, 'file': 'itcm.mem'},
    'dtcm': {'base': 0x00010000, 'size': 32 * 1024, 'file': 'dtcm.mem'},
}

def contains(mem_info, addr):
    """Checks if the given address is within the memory region."""
    return mem_info['base'] <= addr < mem_info['base'] + mem_info['size']

def process_and_dump_segments(segments, mem_info, out_dir, word_size_bytes=16):
    """
    Processes a list of memory segments, sorts them, and dumps them to a
    Verilog hex file, handling memory locations. Returns True if data was
    written.
    """
    file_path = os.path.join(out_dir, mem_info['file'])
    mem_base = mem_info['base']

    with open(file_path, 'w') as f:
        if not segments:
            logging.error("No segments found for %s. Created empty file.",
                          mem_info['file'])
            return False

        segments.sort(key=lambda s: s['p_addr'])
        last_addr_written = -1

        for seg in segments:
            p_addr = seg['p_addr']
            data = seg['data']
            data_len = len(data)
            current_addr_offset = p_addr - mem_base

            # Check if the segment start address is aligned to the memory word size.
            if current_addr_offset % word_size_bytes != 0:
                logging.error(
                    f"ELF segment at address 0x{p_addr:08x} has an unaligned "
                    f"offset of 0x{current_addr_offset:08x}. Exiting. "
                )
                sys.exit(1)

            if current_addr_offset > last_addr_written:
                aligned_addr = (current_addr_offset // word_size_bytes)
                f.write(f"@{aligned_addr:08x}\n")

            for i in range(0, data_len, word_size_bytes):
                chunk = data[i:i + word_size_bytes]
                while len(chunk) < word_size_bytes:
                    chunk += b'\x00'
                word = int.from_bytes(chunk, byteorder='little')
                f.write(f"{word:0{word_size_bytes*2}x}\n")

            last_addr_written = current_addr_offset + data_len - 1
        return True

def find_tohost_addr(elf):
    """Finds the 'tohost' symbol in the ELF file's symbol table."""
    symtab = elf.get_section_by_name('.symtab')
    if not symtab:
        logging.warning("No symbol table found in ELF file.")
        return None
    for symbol in symtab.iter_symbols():
        if symbol.name == 'tohost':
            logging.info("Found 'tohost' symbol at 0x%08x", symbol['st_value'])
            return symbol['st_value']
    logging.warning("'tohost' symbol not found in ELF file.")
    return None

def main():
    """Main function to parse ELF and generate files."""
    logging.basicConfig(level=logging.INFO,
                        format='%(levelname)s: %(message)s')

    parser = argparse.ArgumentParser(
        description='Generate memory and argument files from an ELF file.')
    parser.add_argument('--elf_file', required=True, help='Path to input ELF.')
    parser.add_argument('--out_dir', required=True, help='Output directory for .mem files.')
    args = parser.parse_args()

    if not os.path.exists(args.out_dir):
        logging.info("Output directory '%s' not found. Creating it.", args.out_dir)
        os.makedirs(args.out_dir)

    logging.info("Processing ELF file: %s", args.elf_file)

    itcm_segments = []
    dtcm_segments = []
    tohost_addr = None
    run_opts_file = os.path.join(args.out_dir, 'elf_run_opts.f')

    try:
        with open(args.elf_file, 'rb') as f:
            elf = ELFFile(f)
            tohost_addr = find_tohost_addr(elf)

            for segment in elf.iter_segments():
                if segment['p_type'] != 'PT_LOAD':
                    continue

                p_addr = segment['p_paddr']
                data = segment.data()
                logging.info("Found segment at 0x%08x, size %d bytes", p_addr, len(data))

                if contains(MEM_MAP['itcm'], p_addr):
                    itcm_segments.append({'p_addr': p_addr, 'data': data})
                elif contains(MEM_MAP['dtcm'], p_addr):
                    dtcm_segments.append({'p_addr': p_addr, 'data': data})
                else:
                    logging.warning("Segment at 0x%08x is outside known memory map. Skipping.", p_addr)

    except Exception as e:
        if isinstance(e, FileNotFoundError):
            logging.error(f"ERROR: ELF file not found at {args.elf_file}")
        else:
            logging.error("An error occurred: %s", e, exc_info=True)
        open(run_opts_file, 'w').close()
        open(os.path.join(args.out_dir, MEM_MAP['itcm']['file']), 'w').close()
        open(os.path.join(args.out_dir, MEM_MAP['dtcm']['file']), 'w').close()
        exit(1)

    # Process segments and dump memory files
    itcm_written = process_and_dump_segments(
        itcm_segments, MEM_MAP['itcm'], args.out_dir)
    dtcm_written = process_and_dump_segments(
        dtcm_segments, MEM_MAP['dtcm'], args.out_dir)

    # Generate the arguments file
    with open(run_opts_file, 'w') as f_args:
        logging.info("Generating arguments file: %s", run_opts_file)
        if itcm_written:
            f_args.write(f"+ITCM_MEM_FILE=" +
                         f"{os.path.join(args.out_dir, MEM_MAP['itcm']['file'])}\n")
        if dtcm_written:
            f_args.write(f"+DTCM_MEM_FILE=" +
                         f"{os.path.join(args.out_dir, MEM_MAP['dtcm']['file'])}\n")
        if tohost_addr is not None:
            f_args.write(f"+TOHOST_ADDR='h{tohost_addr:08x}\n")

    logging.info("Successfully generated memory and argument files.")

if __name__ == '__main__':
    main()
