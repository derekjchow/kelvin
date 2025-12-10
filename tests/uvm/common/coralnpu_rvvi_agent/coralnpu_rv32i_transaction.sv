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

//--------------------------------------------------------------------------------
// Class: coralnpu_rv32i_transaction
// Description: Defines a transaction item for RV32I base integer instructions.
//--------------------------------------------------------------------------------
class coralnpu_rv32i_transaction extends coralnpu_rvvi_decode_transaction;

  //for FENCE instruction,instruction format:FENCE pred,succ
  bit[3:0] fm;
  bit[3:0] pred;//predecessors,Bit3:PI,bit2:PO,bit3:PR,bit0:PW
  bit[3:0] succ;//Successors,Bit3:SI,bit2:SO,bit3:SR,bit0:SW


  `uvm_object_utils_begin(coralnpu_rv32i_transaction)
    `uvm_field_int (fm, UVM_DEFAULT)
    `uvm_field_int (pred, UVM_DEFAULT)
    `uvm_field_int (succ, UVM_DEFAULT)
  `uvm_object_utils_end

  function new (string name = "coralnpu_rv32i_transaction");
    super.new(name);
  endfunction : new


endclass : coralnpu_rv32i_transaction
