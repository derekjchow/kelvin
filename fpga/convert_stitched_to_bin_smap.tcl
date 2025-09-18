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

set input_bit_file "./com.google.coralnpu_fpga_chip_nexus_0.1.runs/impl_1/chip_nexus.bit"
set output_bin_file "chip_nexus.bin"

if {![file exists $input_bit_file]} {
    puts "ERROR: Input file not found: $input_bit_file"
    exit 1
}

write_cfgmem -format BIN -disablebitswap -loadbit "up 0x0 ${input_bit_file}" -file ${output_bin_file} -force

puts "Successfully converted ${input_bit_file} to ${output_bin_file}"

exit
