# Copyright 2024 Google LLC
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
#
# NB: Before running this test, you must build Vtop_bin.
# bazel build //tests/renode:Vtop_bin
*** Variables ***
${SCRIPT}       ${CURDIR}/../kelvin-verilator.resc

*** Keywords ***
Create Machine
    Set Test Variable   ${core_mini_axi_args}   ; address: "127.0.0.1"
    Set Test Variable   ${vtop_slave_bin}             ${CURDIR}/../Vtop_slave
    Set Test Variable   ${vtop_master_bin}             ${CURDIR}/../Vtop_master

    ExecuteCommand      $repl_file="${CURDIR}/../kelvin-verilator.repl"
    Execute Script      ${SCRIPT}
    Execute Command     core_mini_axi_slave SimulationFilePathLinux "${vtop_slave_bin}"
    Execute Command     core_mini_axi_master SimulationFilePathLinux "${vtop_master_bin}"
    Execute Command     sysbus LoadELF @${CURDIR}/rv_core.elf false true rv_core

*** Test Cases ***
Run rv_core ELF
    Start Process       ${CURDIR}/../Vtop_bin
    Create Machine
    Create Terminal Tester  sysbus.uart0
    Execute Command         rv_core IsHalted false
    Start Emulation
    Wait For Line On Uart   beefb0ba
    Wait For Line On Uart   0xb0bacafe
    Wait For Line On Uart   PASS
    Reset Emulation
    Terminate All Processes

