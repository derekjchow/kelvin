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

# This script converts the bram_details.txt file into a complete MMI file,
# with specific endian-reversed sorting for both BRAM groups.

set input_file "bram_details.txt"
set output_file "chip_nexus_bram_final.mmi"
set processor_inst "i_ddr4/inst/u_ddr4_mem_intfc/u_ddr_cal_riu/mcs0/inst/microblaze_I"
set address_space_name "i_ddr4_inst_u_ddr4_mem_intfc_u_ddr_cal_riu_mcs0_inst_microblaze_I.i_ddr4_inst_u_ddr4_mem_intfc_u_ddr_cal_riu_mcs0_inst_dlmb_cntlr"

# --- Define address space boundaries ---
set total_address_end 98303
set first_space_end 65535
set second_space_begin 65536
set second_space_end 98303
set first_block_addr_depth 16384

# --- Custom sort procedure for endian-reversed sorting ---
# Sorts by byte lane ascending, and then by LSB descending within the byte.
proc endian_reverse_sort {bram1 bram2} {
    set lsb1 [lindex $bram1 3]
    set lsb2 [lindex $bram2 3]

    set byte1 [expr {floor($lsb1 / 8)}]
    set byte2 [expr {floor($lsb2 / 8)}]

    if {$byte1 < $byte2} {
        return -1
    } elseif {$byte1 > $byte2} {
        return 1
    } else {
        # Bytes are the same, sort by LSB descending
        if {$lsb1 > $lsb2} {
            return -1
        } elseif {$lsb1 < $lsb2} {
            return 1
        } else {
            return 0
        }
    }
}

# --- Main script ---
set fin [open $input_file "r"]

set first_bram_group {}
set second_bram_group {}

# Skip the first two header lines of the input file
gets $fin
gets $fin

# 1. Read and Store all BRAM data from the input file
while {[gets $fin line] >= 0} {
    if {[string match "Instance:*" $line]} {
        set instance_path $line
        gets $fin type_line
        gets $fin loc_line
        gets $fin slr_line
        gets $fin rwa_line
        gets $fin wwa_line
        gets $fin rwb_line
        gets $fin wwb_line
        gets $fin bmm_line
        gets $fin separator_line

        regexp {RAMB\d+} $loc_line mem_type
        regexp {X\d+Y\d+} $loc_line placement
        regexp {BMM Info:\s+\[(\d+):(\d+)\]\[(\d+):(\d+)\]} $bmm_line match msb lsb addr_begin addr_end

        set bram_details [list $mem_type $placement $msb $lsb $addr_begin $addr_end]

        if {[string match "*second_lmb_bram_I*" $instance_path]} {
            lappend second_bram_group $bram_details
        } else {
            lappend first_bram_group $bram_details
        }
    }
}
close $fin

# 2. Sort the two groups using the same logic
set sorted_first_group [lsort -command endian_reverse_sort $first_bram_group]
set sorted_second_group [lsort -command endian_reverse_sort $second_bram_group]


# 3. Write the sorted data to the output file
set fout [open $output_file "w"]

# Write MMI Header
puts $fout {<?xml version="1.0" encoding="UTF-8"?>}
puts $fout {<MemInfo Version="1" Minor="9">}
puts $fout [format {  <Processor Endianness="Little" InstPath="%s">} $processor_inst]
puts $fout [format {    <AddressSpace Name="%s" Begin="0" End="%d">} $address_space_name $total_address_end]

# Write first address space range
puts $fout [format {      <AddressSpaceRange Name="%s" Begin="0" End="%d" CoreMemory_Width="32" MemoryType="RAM_SP" MemoryConfiguration="">} $address_space_name $first_space_end]
puts $fout {        <BusBlock>}
foreach bram $sorted_first_group {
    set mem_type   [lindex $bram 0]
    set placement  [lindex $bram 1]
    set msb        [lindex $bram 2]
    set lsb        [lindex $bram 3]
    set addr_begin [lindex $bram 4]
    set addr_end   [lindex $bram 5]
    puts $fout [format {          <BitLane MemType="%s" Placement="%s" Read_Width="0" SLR_INDEX="-1">} $mem_type $placement]
    puts $fout [format {            <DataWidth MSB="%d" LSB="%d"/>} $msb $lsb]
    puts $fout [format {            <AddressRange Begin="%d" End="%d"/>} $addr_begin $addr_end]
    puts $fout {            <BitLayout pattern=""/>}
    puts $fout {            <Parity ON="false" NumBits="0"/>}
    puts $fout {          </BitLane>}
}
puts $fout {        </BusBlock>}
puts $fout {      </AddressSpaceRange>}

# Write second address space range
puts $fout [format {      <AddressSpaceRange Name="%s" Begin="%d" End="%d" CoreMemory_Width="32" MemoryType="RAM_SP" MemoryConfiguration="">} $address_space_name $second_space_begin $second_space_end]
puts $fout {        <BusBlock>}
foreach bram $sorted_second_group {
    set mem_type   [lindex $bram 0]
    set placement  [lindex $bram 1]
    set msb        [lindex $bram 2]
    set lsb        [lindex $bram 3]
    set addr_begin [expr {[lindex $bram 4] + $first_block_addr_depth}]
    set addr_end   [expr {[lindex $bram 5] + $first_block_addr_depth}]
    puts $fout [format {          <BitLane MemType="%s" Placement="%s" Read_Width="0" SLR_INDEX="-1">} $mem_type $placement]
    puts $fout [format {            <DataWidth MSB="%d" LSB="%d"/>} $msb $lsb]
    puts $fout [format {            <AddressRange Begin="%d" End="%d"/>} $addr_begin $addr_end]
    puts $fout {            <BitLayout pattern=""/>}
    puts $fout {            <Parity ON="false" NumBits="0"/>}
    puts $fout {          </BitLane>}
}
puts $fout {        </BusBlock>}
puts $fout {      </AddressSpaceRange>}

# Write MMI Footer
puts $fout {    </AddressSpace>}
puts $fout {  </Processor>}
puts $fout {  <Config>}
puts $fout {    <Option Name="Part" Val="xcvu13p-fhga2104-2-e"/>}
puts $fout {  </Config>}
puts $fout {  <DRC>}
puts $fout {    <Rule Name="RDADDRCHANGE" Val="false"/>}
puts $fout {  </DRC>}
puts $fout {</MemInfo>}

close $fout

puts "Successfully converted $input_file to $output_file"
