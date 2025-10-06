// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//----------------------------------------------------------------------------
// Interface: coralnpu_irq_if
// Description: Simple interface for misc control/status signals
//----------------------------------------------------------------------------
interface coralnpu_irq_if (input logic clk, input logic resetn);

  // Control Inputs to DUT
  logic irq;
  logic te; // Test Enable

  // Status Outputs from DUT
  logic halted;
  logic fault;
  logic wfi;

  // Clocking block for Testbench Driver (drives DUT inputs)
  clocking tb_ctrl_cb @(posedge clk);
    default input #1step output #2ns;
    output irq;
    output te;
    input halted; // Can be sampled by driver/test if needed
    input fault;
    input wfi;
  endclocking : tb_ctrl_cb

  // Modport for Testbench Driver/Controller
  modport TB_IRQ_DRIVER (clocking tb_ctrl_cb, input clk, input resetn);

  // Modport for DUT connection
  modport DUT_IRQ_PORT (
    input clk, resetn,
    input irq, te,
    output halted, fault, wfi
  );

endinterface: coralnpu_irq_if
