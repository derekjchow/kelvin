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

# This script extracts detailed information for all BRAMs in the
# lmb_bram_I and second_lmb_bram_I hierarchies.

open_project com.google.coralnpu_fpga_chip_nexus_0.1.xpr
open_run impl_1

set output_file "bram_details.txt"
set fileout [open $output_file "w"]

puts "Extracting BRAM details to $output_file..."

set lmb_brams [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BLOCKRAM.BRAM.* && NAME =~ "*/lmb_bram_I/*"}]
set second_lmb_brams [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BLOCKRAM.BRAM.* && NAME =~ "*/second_lmb_bram_I/*"}]
set all_brams [lsort -dictionary [concat $lmb_brams $second_lmb_brams]]

if {[llength $all_brams] == 0} {
    puts "ERROR: No BRAMs found in the specified hierarchies. Aborting."
    close $fileout
    exit 1
}

puts $fileout "Found [llength $all_brams] BRAMs."
puts $fileout "----------------------------------------"

foreach bram_cell $all_brams {
    set cell [get_cells $bram_cell]
    puts $fileout "Instance:      [get_property NAME $cell]"
    puts $fileout "  Type:          [get_property REF_NAME $cell]"
    puts $fileout "  Location:      [get_property LOC $cell]"
    puts $fileout "  SLR Index:     [get_property SLR_INDEX $cell]"
    puts $fileout "  Read Width A:  [get_property READ_WIDTH_A $cell]"
    puts $fileout "  Write Width A: [get_property WRITE_WIDTH_A $cell]"
    puts $fileout "  Read Width B:  [get_property READ_WIDTH_B $cell]"
    puts $fileout "  Write Width B: [get_property WRITE_WIDTH_B $cell]"
    puts $fileout "  BMM Info:      [get_property bmm_info_memory_device $cell]"
    puts $fileout "----------------------------------------"
}

close $fileout
puts "Successfully extracted BRAM details to $output_file"

exit
