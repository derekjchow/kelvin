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
// Class: coralnpu_rvvi_transaction
// Description: Defines the raw architectural state changes of the coralnpu core
//              for each instruction retirement.
//--------------------------------------------------------------------------------
class coralnpu_rvvi_transaction extends uvm_sequence_item;

  bit [63:0]order;
  bit [(`XLEN-1):0] pc;
  bit [(`ILEN-1):0] insn;
  bit trap;
  bit halt;
  bit [31:0][(`XLEN-1):0] x_wdata;
  bit [31:0] x_wb;
  bit [31:0][(`FLEN-1):0] f_wdata;
  bit [31:0] f_wb;
  bit [31:0][(`VLEN-1):0] v_wdata;
  bit [31:0] v_wb;
  bit [4095:0][(`XLEN-1):0] csr_wdata;
  bit [4095:0] csr_wb;

  //CSR register
  bit[(`XLEN-1):0] mstatus;
  bit[(`XLEN-1):0] misa;
  bit[(`XLEN-1):0] mie;
  bit[(`XLEN-1):0] mtvec;
  bit[(`XLEN-1):0] mscratch;
  bit[(`XLEN-1):0] mepc;
  bit[(`XLEN-1):0] mcause;
  bit[(`XLEN-1):0] mtval;
  bit[(`XLEN-1):0] mcycle;
  bit[(`XLEN-1):0] mcycleh;
  bit[(`XLEN-1):0] minstret;
  bit[(`XLEN-1):0] minstreth;

  //vector csr
  logic[(`XLEN-1):0] vstart;//0-127
  logic[(`XLEN-1):0] vxsat;//fixed point saturate flag
  vxrm_e vxrm;//fixed point rounding mode
  logic[(`XLEN-1):0] vcsr;
  logic[(`XLEN-1):0] vl;
  logic[(`XLEN-1):0] vtype;
  logic[(`XLEN-1):0] vlenb;
  agnostic_e vtype_vma;
  agnostic_e vtype_vta;
  sew_e  vtype_vsew; //000-8,001-16,010-32
  lmul_e vtype_vlmul;
  logic [0:0] vtype_vill;

  `uvm_object_utils_begin(coralnpu_rvvi_transaction)
    `uvm_field_int (order, UVM_DEFAULT)
    `uvm_field_int (pc, UVM_DEFAULT)
    `uvm_field_int (insn, UVM_DEFAULT)
    `uvm_field_int (trap, UVM_DEFAULT)
    `uvm_field_int (halt, UVM_DEFAULT)
    `uvm_field_int (x_wdata, UVM_DEFAULT)
    `uvm_field_int (x_wb, UVM_DEFAULT)
    `uvm_field_int (f_wdata, UVM_DEFAULT)
    `uvm_field_int (f_wb, UVM_DEFAULT)
    `uvm_field_int (v_wdata, UVM_DEFAULT)
    `uvm_field_int (v_wb, UVM_DEFAULT)
    `uvm_field_int (csr_wdata, UVM_DEFAULT)
    `uvm_field_int (csr_wb, UVM_DEFAULT)
  `uvm_object_utils_end

  function new (string name = "coralnpu_rvvi_transaction");
    super.new(name);
  endfunction : new


endclass : coralnpu_rvvi_transaction
