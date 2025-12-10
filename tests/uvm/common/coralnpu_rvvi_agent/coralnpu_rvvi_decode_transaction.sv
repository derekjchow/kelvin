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
// Class: coralnpu_rvvi_decode_transaction
// Description:  Defines a transaction item for decoded rvvi transaction.
//--------------------------------------------------------------------------------
class coralnpu_rvvi_decode_transaction extends uvm_sequence_item;

  bit [63:0]order;
  bit [(`XLEN-1):0] pc;
  bit trap;
  bit halt;
  bit [(`ILEN-1):0] insn;
  insn_name_enum insn_name;
  logic[4:0] rd_addr;
  logic[4:0] rs1_addr;
  logic[4:0] rs2_addr;
  bit signed [(`XLEN-1):0] rd_val;
  bit signed [(`XLEN-1):0] rs1_val;
  bit signed [(`XLEN-1):0] rs2_val;
  bit signed [11:0] imm_12bit;
  bit signed [19:0] imm_20bit;

  //for GPR HAZARD
  bit raw_hazard_hit;
  bit waw_hazard_hit;
  bit war_hazard_hit;

  `uvm_object_utils_begin(coralnpu_rvvi_decode_transaction)
    `uvm_field_int (order, UVM_DEFAULT)
    `uvm_field_int (pc, UVM_DEFAULT)
    `uvm_field_int (insn, UVM_DEFAULT)
    `uvm_field_enum(insn_name_enum,insn_name, UVM_DEFAULT)
    `uvm_field_int (trap, UVM_DEFAULT)
    `uvm_field_int (halt, UVM_DEFAULT)
    `uvm_field_int (rd_val, UVM_DEFAULT)
    `uvm_field_int (rd_addr, UVM_DEFAULT)
    `uvm_field_int (rs1_val, UVM_DEFAULT)
    `uvm_field_int (rs1_addr, UVM_DEFAULT)
    `uvm_field_int (rs2_val, UVM_DEFAULT)
    `uvm_field_int (rs2_addr, UVM_DEFAULT)
    `uvm_field_int (imm_12bit, UVM_DEFAULT)
    `uvm_field_int (imm_20bit, UVM_DEFAULT)
    `uvm_field_int (raw_hazard_hit, UVM_DEFAULT)
    `uvm_field_int (waw_hazard_hit, UVM_DEFAULT)
    `uvm_field_int (war_hazard_hit, UVM_DEFAULT)
  `uvm_object_utils_end

  function new (string name = "coralnpu_rvvi_decode_transaction");
    super.new(name);
  endfunction : new

endclass : coralnpu_rvvi_decode_transaction
